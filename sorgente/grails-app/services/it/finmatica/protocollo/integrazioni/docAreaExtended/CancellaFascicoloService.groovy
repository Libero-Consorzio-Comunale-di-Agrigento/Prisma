package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import it.finmatica.protocollo.titolario.FascicoloService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class CancellaFascicoloService extends BaseFascicoloService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    FascicoloService fascicoloService

    CancellaFascicoloService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService,@Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, null, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'delFascicolo'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        Fascicolo fascicolo
        String idDocumento = getIdDocumento(xml)
        if(idDocumento) {
            fascicolo = fascicoloRepository.getFascicolo(Long.valueOf(idDocumento))
        } else {
            Classificazione classificazione = classificazioneService.findByCodice(getClassificazione(xml))
            if(classificazione) {
                fascicolo = fascicoloRepository.getFascicolo(classificazione.id, getInteger(getFascicoloAnno(xml)), getFascicoloNumero(xml))
            } else {
                resp.setRESULT(ResultStatus.KO.name())
                resp.setERRORNUMBER(String.valueOf(ErroriWsDocarea.ERRORE_INTERNO.codice))
                resp.setMESSAGE('Classificazione non trovata')
                return toXml(resp)
            }
        }
        if(fascicolo) {
            fascicoloService.elimina(fascicolo,ignoraCompetenze)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Fascicolo non trovato')
        }
        return toXml(resp)
    }

    @CompileDynamic
    String getIdDocumento(Node node) {
        node.ID_DOCUMENTO?.text()
    }

    @CompileDynamic
    String getFascicoloNumero(Node node) {
        node.FASCICOLO_NUMERO?.text()
    }


}
