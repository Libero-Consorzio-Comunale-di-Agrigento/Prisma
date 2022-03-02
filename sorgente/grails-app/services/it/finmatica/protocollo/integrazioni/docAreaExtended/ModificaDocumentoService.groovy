package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class ModificaDocumentoService extends BaseDocumentoService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    So4UnitaPubbService so4UnitaPubbService

    ModificaDocumentoService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'modDocumento'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        String anno = getAnno(xml)
        String numero = getNumero(xml)
        String tipoRegistro = getTipoRegistro(xml)
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento): protocolloService.findByAnnoAndNumeroAndTipoRegistro(getInteger(anno), getInteger(numero), tipoRegistro)
        if(protocollo) {
            String classificazione = getClassificazione(xml)
            if (classificazione) {
                protocollo.classificazione = classificazioneService.findByCodice(classificazione)
            }
            String fascicoloAnno = getFascicoloAnno(xml)
            String fascicoloNumero = getFascicoloNumero(xml)
            if (fascicoloAnno && fascicoloNumero) {
                protocollo.fascicolo = fascicoloRepository.getFascicolo(protocollo.classificazione.id, getInteger(fascicoloAnno), fascicoloNumero)
            }

            def oggetto = getOggetto(xml)
            if (oggetto) {
                protocollo.oggetto = oggetto
            }
            def note = getNote(xml)
            if (note) {
                protocollo.note = note
            }
            String amministrazione = getAmministrazione(xml)
            String aoo = getAoo(xml)
            protocollo.ente = dizionariRepository.findEnteByCodiceAndAoo(amministrazione, aoo)
            String modalita = getModalita(xml)
            if (modalita) {
                switch (modalita) {
                    case 'INT': protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_INTERNO; break
                    case 'PAR': protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_PARTENZA; break
                    case 'ARR': protocollo.movimento = it.finmatica.protocollo.documenti.Protocollo.MOVIMENTO_ARRIVO; break
                }
            }
            setTipoDocumento(xml, protocollo)
            String unitaProtocollante = getUnitaProtocollante(xml)

            if (unitaProtocollante) {
                List so4UnitaPubbs = so4UnitaPubbService.cercaUnitaPubb(amministrazione, Impostazioni.OTTICA_SO4.valore)
                So4UnitaPubb up = so4UnitaPubbs.find { it.codice == unitaProtocollante }
                DocumentoSoggetto unitaProt = new DocumentoSoggetto()
                unitaProt.unitaSo4 = up
                unitaProt.tipoSoggetto = TipoSoggetto.UO_PROTOCOLLANTE
                unitaProt.attivo = true
                protocollo.addToSoggetti(unitaProt)
            }
            protocolloService.salva(protocollo,true,true,ignoraCompetenze,false)
            resp.id = protocollo.id.toString()
            return toXml(resp)
        } else {
            throw  new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Id documento assente o protocollo non trovato')
        }

    }


}
