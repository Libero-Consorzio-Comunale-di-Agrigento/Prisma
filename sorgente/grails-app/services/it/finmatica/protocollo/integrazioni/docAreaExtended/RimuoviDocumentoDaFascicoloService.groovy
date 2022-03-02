package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
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
class RimuoviDocumentoDaFascicoloService extends BaseFascicoloService implements DocAreaExtendedService {

    @Autowired
    ClassificazioneService classificazioneService
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    ProtocolloService protocolloService

    RimuoviDocumentoDaFascicoloService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired So4Repository so4Repository,@Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, so4Repository, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'rimuoviDocumentoDalFascicolo'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        // questi sono alternativi rispetto a sopra...
        String anno = getAnno(xml)
        String numero = getNumero(xml)
        String tipoRegistro = getTipoRegistro(xml)
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento): protocolloService.findByAnnoAndNumeroAndTipoRegistro(getInteger(anno),getInteger(numero),tipoRegistro)
        if(protocollo) {
            protocollo.fascicolo = null
            if(!ImpostazioniProtocollo.CLASS_OB.abilitato) {
                protocollo.classificazione = null
            }
            protocolloService.salva(protocollo,true,true,ignoraCompetenze,false)
            return toXml(resp)
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
/* stato fascicolo
        RR Con richiesta di scarto rifiutata
        CO Conservato
        AA In attesa di approvazione dello scarto
        PS Proposto per lo scarto
        SC Scartato
        ** default
    */


}