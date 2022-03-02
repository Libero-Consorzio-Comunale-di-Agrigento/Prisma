package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.anagrafica.As4Anagrafica
import it.finmatica.as4.dizionari.As4TipoSoggetto
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.documenti.PrivilegioUtenteBlacklistRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtenteBlacklist
import it.finmatica.protocollo.integrazioni.as4.As4Repository
import it.finmatica.protocollo.integrazioni.docAreaExtended.DocAreaExtendedService
import it.finmatica.protocollo.integrazioni.docAreaExtended.Persona
import it.finmatica.protocollo.integrazioni.docAreaExtended.Result
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.DocAreaAuthHelper
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.trasco.TrascoService
import it.finmatica.protocollo.ws.utility.ProtocolloWSUtilityService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.core.io.ClassPathResource
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.xml.sax.SAXException

import javax.xml.XMLConstants
import javax.xml.bind.JAXBContext
import javax.xml.transform.stream.StreamSource
import javax.xml.validation.SchemaFactory
import javax.xml.validation.Validator

@Transactional
@Service
@Slf4j
@CompileStatic
class DocAreaExtendedHelperService {

    private Map<String, DocAreaExtendedService> registeredBeans = [:]

    @Autowired
    DocAreaAuthHelper docAreaAuthHelper

    @Autowired
    DocAreaTokenService docAreaTokenService
    @Autowired
    TrascoService trascoService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    ProtocolloWSUtilityService protocolloWSUtilityService
    @Autowired
    PrivilegioUtenteBlacklistRepository privilegioUtenteBlacklistRepository
    @Autowired
    As4AnagraficiRecapitiRepository as4AnagraficiRecapitiRepository
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    As4Repository as4Repository


    private JAXBContext jcResult = JAXBContext.newInstance(Result)

    private static SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI)

    String executeService(String user, String dst, String xml, String xsdName) {
        DocAreaExtendedService service = registeredBeans.get(xsdName)
        if (service) {
            try {
                DocAreaToken token = docAreaTokenService.findByTokenAndUsername(dst, user)
                if (token) {
                    Node nodo = validateAndParseXml(xsdName, xml)
                    String utente = getUsername(nodo) ?: user
                    Ente e = token.ente
                    docAreaAuthHelper.autenticaEnte(utente, e.id)
                    PrivilegioUtenteBlacklist utenteBlacklist = privilegioUtenteBlacklistRepository.findOne(utente)
                    return service.execute(utente, nodo, utenteBlacklist != null)
                } else {
                    return toXml(getErrorResult("Utente non autorizzato o token non valido: ${user}".toString(),null))
                }
            } catch (SAXException e) {
                log.error('Errore di esecuzione',e)
                return toXml(getErrorResult("Errore di validazione XML",e.getMessage(), ErroriWsDocarea.ERRORE_INTERNO.codice))
            } catch(DocAreaExtendedException e) {
                log.error('Errore di esecuzione',e)
                return toXml(getErrorResult("Errore di esecuzione servizio",e.getMessage(),ErroriWsDocarea.ERRORE_INTERNO.codice))
            } catch(UsernameNotFoundException e) {
                log.error('Errore di esecuzione',e)
                return toXml(getErrorResult("Utente sconosciuto",e.getMessage(),ErroriWsDocarea.ERRORE_INTERNO.codice))
            } catch(Exception e) {
                log.error('Errore di esecuzione',e)
                return toXml(getErrorResult("Errore esecuzione",e.getMessage(),ErroriWsDocarea.ERRORE_INTERNO.codice))
            }
        } else {
            log.error('Errore di esecuzione: servizio non trovato')
            return toXml(getErrorResult("Servizio non trovato: ${xsdName}".toString(),null,ErroriWsDocarea.ERRORE_INTERNO.codice))
        }
    }

    @CompileDynamic
    private String getUsername(Node nodo) {
        nodo.UTENTE?.text()
    }

    Node validateAndParseXml(String xsdName, String xml) {
        ClassPathResource res = new ClassPathResource("docAreaExtended/${xsdName}.xsd".toString())
        Validator val = null
        res.inputStream.withCloseable { inp ->
            val = schemaFactory.newSchema(new StreamSource(res.inputStream)).newValidator()
        }
        val.validate(new StreamSource(new StringReader(xml)))
        new XmlParser(false, false).parseText(xml)
    }

    void register(DocAreaExtendedService bean) {
        registeredBeans.put(bean.xsdName, bean)
    }

    Protocollo getProtocolloFromId(Long id) {
        protocolloWSUtilityService.getProtocolloFromIdAndTrasco(id)
    }

    private String toXml(Result result) {
        def res = new StringWriter()
        jcResult.createMarshaller().marshal(result, res)
        return res.toString()
    }

    private Result getErrorResult(String message,String exception, int errorNumber = -1) {
        Result err = new Result()
        err.RESULT = 'KO'
        err.MESSAGE = message
        err.EXCEPTION = exception
        err.ERRORNUMBER = String.valueOf(errorNumber)
        return err
    }

    CorrispondenteDTO trovaPersona(Persona pers) {
        CorrispondenteDTO corrispondente
        if (pers.id) {
            // è il codice fiscale o la partita iva
            def corrisp = as4AnagraficiRecapitiRepository.findAnagraficaByCFOrPIVA(pers.id)
            if (corrisp) {
                corrispondente = toCorrispondenteDTO(corrisp.first())
            }
        } else if (pers.idSoggetto && pers.idRecapito) {
            // oppure è una ricerca su as4
            As4AnagrificiRecapiti rec
            def idSoggetto = Long.valueOf(pers.idSoggetto)
            def idRecapito = Long.valueOf(pers.idRecapito)
            if (pers.idContatto) {
                rec = as4AnagraficiRecapitiRepository.findFirstByIdSoggettoAndIdRecapitoAndIdContatto(idSoggetto, idRecapito, Long.valueOf(pers.idContatto))
            } else {
                rec = as4AnagraficiRecapitiRepository.findFirstByIdSoggettoAndIdRecapito(idSoggetto, idRecapito)
            }
            if (rec) {
                //corrispondenteService.ricercaPiDenom(rec.codiceFiscale ?: rec.partitaIva, null, true)
                def corrisp = as4AnagraficiRecapitiRepository.findAnagraficaByCFOrPIVA(rec.codiceFiscale ?: rec.partitaIva)
                if (corrisp) {
                    corrispondente = toCorrispondenteDTO(corrisp.first())
                }
            }
        } else {
            // provo una ricerca generica
            def destinatariRic = corrispondenteService.ricercaDestinatari(null, true, "${pers.nome} ${pers.cognome}".toString(), null, pers.codiceFiscale ? pers.codiceFiscale : null)
            if (destinatariRic) {
                corrispondente = (destinatariRic.first() as CorrispondenteDTO)
            }
        }
        // se sono arrivato qua è un nuovo contatto
        if (!corrispondente) {
            corrispondente = new CorrispondenteDTO()
            corrispondente.nome = pers.nome
            corrispondente.cognome = pers.cognome
            corrispondente.codiceFiscale = pers.codiceFiscale
            corrispondente.email = pers.indirizzoTelematico?.content
        }
        return corrispondente
    }

    private CorrispondenteDTO toCorrispondenteDTO(As4Anagrafica anag) {
        CorrispondenteDTO corr = new CorrispondenteDTO()
        corr.partitaIva = anag.partitaIva
        corr.codiceFiscale = anag.codFiscale
        corr.nome = anag.nome
        corr.cognome = anag.cognome
        corr.denominazione = anag.denominazione
        corr.ni = anag.ni
        corr.tipoSoggetto = toTipoSoggetto(anag.tipoSoggetto)
        As4SoggettoCorrente soggettoCorrente = as4Repository.getSoggettoCorrente(anag.ni)
        if(soggettoCorrente) {
            corr.email = soggettoCorrente.indirizzoWeb
            corr.indirizzo = soggettoCorrente.indirizzoResidenza ?: soggettoCorrente.indirizzoDomicilio
            corr.comune = soggettoCorrente.comuneResidenza?.denominazione ?: soggettoCorrente.comuneDomicilio?.denominazione
            corr.provinciaSigla = soggettoCorrente.provinciaResidenza?.sigla ?: soggettoCorrente.provinciaDomicilio?.sigla
            corr.cap = soggettoCorrente.capResidenza ?: soggettoCorrente.capDomicilio
            corr.tipoIndirizzo = soggettoCorrente.indirizzoResidenza ? 'RESIDENZA' : 'DOMICILIO'
        }
        return corr
    }

    TipoSoggettoDTO toTipoSoggetto(As4TipoSoggetto tp) {
        if(tp) {
            TipoSoggettoDTO res = new TipoSoggettoDTO()
            res.descrizione = tp.descrizione
            return res
        } else {
            return null
        }
    }
}
