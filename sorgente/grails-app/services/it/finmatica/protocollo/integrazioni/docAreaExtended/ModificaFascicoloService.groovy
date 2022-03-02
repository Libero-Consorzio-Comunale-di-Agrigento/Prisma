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
import it.finmatica.protocollo.dizionari.StatoScartoRepository
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.scarto.DocumentoDatiScarto
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class ModificaFascicoloService extends BaseFascicoloService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    StatoScartoRepository statoScartoRepository

    ModificaFascicoloService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService,@Autowired So4Repository so4Repository,@Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, so4Repository, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'modFascicolo'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        Fascicolo fascicolo
        String idDocumento = getIdDocumento(xml)
        if(idDocumento) {
            fascicolo = fascicoloRepository.getFascicolo(Long.valueOf(idDocumento?:'-1'))
        } else {
            Classificazione classificazione = classificazioneService.findByCodice(getClassificazione(xml))
            fascicolo = fascicoloRepository.getFascicolo(classificazione.id,getInteger(getFascicoloAnno(xml)),getFascicoloNumero(xml))
        }
        if(fascicolo) {
            Date dataApertura = getDataApertura(xml)
            if (dataApertura) {
                fascicolo.dataApertura = dataApertura
            }
            Date dataChiusura = getDataChiusura(xml)
            if (dataChiusura) {
                fascicolo.dataChiusura = dataChiusura
            }
            String statoScarto = getStatoScarto(xml)
            if (statoScarto) {
                DocumentoDatiScarto ds = fascicolo.datiScarto
                if (ds == null) {
                    ds = new DocumentoDatiScarto()
                    fascicolo.datiScarto = ds
                }
                ds.stato = statoScartoRepository.findOne(statoScarto)
            }
            String annoArchiviazione = getAnnoArchiviazione(xml)
            if (annoArchiviazione) {
                fascicolo.dataArchiviazione = getDate("01/01/${annoArchiviazione}")
            }
            propComuni(xml, fascicolo)
            String responsabile = getResponsabile(xml) //TODO
            fascicoloRepository.save(fascicolo)
            resp.id = fascicolo.id.toString()
            return toXml(resp)
        } else {
            throw  new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Fascicolo non trovato')
        }
    }

    @CompileDynamic
    String getIdDocumento(Node node) {
        node.ID_DOCUMENTO?.text()
    }

    @CompileDynamic
    String getFascicoloNumero(Node node) {
        node.FASCICOLO_NUMERO?.text()
    }

    @CompileDynamic
    String getStatoScarto(Node node) {
        node.STATO_SCARTO?.text()
    }

    @CompileDynamic
    String getAnnoArchiviazione(Node node) {
        node.ANNO_ARCHIVIAZIONE?.text()
    }
    @CompileDynamic
    String getResponsabile(Node node) {
        node.RESPONSABILE?.text()
    }
    @CompileDynamic
    Date getDataChiusura(Node node) {
        getDate(node.DATA_CHIUSURA?.text())
    }

/* stato fascicolo
        RR Con richiesta di scarto rifiutata
        CO Conservato
        AA In attesa di approvazione dello scarto
        PS Proposto per lo scarto
        SC Scartato
        ** default
    */


}
