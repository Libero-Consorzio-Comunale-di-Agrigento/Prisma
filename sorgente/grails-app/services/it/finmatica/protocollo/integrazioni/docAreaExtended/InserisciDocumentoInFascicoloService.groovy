package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioService
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class InserisciDocumentoInFascicoloService extends BaseFascicoloService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneRepository classificazioneRepository
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DocumentoTitolarioService documentoTitolarioService

    InserisciDocumentoInFascicoloService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired So4Repository so4Repository, @Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, so4Repository, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'inserisciDocumentoInFascicolo'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        Fascicolo fascicolo
        // questi sono alternativi rispetto a sopra...
        String anno = getAnno(xml)
        String numero = getNumero(xml)
        String tipoRegistro = getTipoRegistro(xml)
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento):protocolloService.findByAnnoAndNumeroAndTipoRegistro(getInteger(anno),getInteger(numero),tipoRegistro)
        if(protocollo) {
            if (utentePuoModificareDocumento(protocollo)) {
                String classificazione = getClassificazione(xml)
                String fascicoloAnno = getFascicoloAnno(xml)
                String fascicoloNumero = getFascicoloNumero(xml)
                List<Classificazione> byCod = classificazioneRepository.findTopByCodice(classificazione, new PageRequest(0,1))
                Classificazione cl = byCod ? byCod.first() : null
                if(!cl) {
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Classificazione non trovata')
                }
                fascicolo = fascicoloRepository.getFascicolo(cl.id, getInteger(fascicoloAnno), fascicoloNumero)
                if(!fascicolo) {
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Fascicolo non trovato')
                }
                def docTit = documentoTitolarioService.getDocumentoTitolario(protocollo.id, fascicolo.id, cl.id)
                if(docTit) {
                    //FIXME questo probabilmente è un bug, perché qua non ci entra eppure ho errore di non unicità
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Fascicolo già associato al protocollo')
                }
                protocollo.fascicolo = fascicolo
                protocolloService.salva(protocollo)
                return toXml(resp)
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Utente non autorizzato alla modifica del protocollo')
            }
        } else {
            throw  new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Id documento assente o protocollo non trovato')
        }
    }

    @CompileDynamic
    String getIdDocumento(Node node) {
        node.ID_DOCUMENTO?.text()
    }

    @CompileDynamic
    String getAnno(Node node) {
        node.ANNO?.text()
    }

    @CompileDynamic
    String getNumero(Node node) {
        node.NUMERO?.text()
    }

    @CompileDynamic
    String getTipoRegistro(Node node) {
        node.TIPO_REGISTRO?.text()
    }
    @CompileDynamic
    String getFascicoloNumero(Node node) {
        node.FASCICOLO_NUMERO?.text()
    }


}
