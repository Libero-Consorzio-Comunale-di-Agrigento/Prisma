package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import it.finmatica.protocollo.smistamenti.SmistamentoRepository
import it.finmatica.protocollo.smistamenti.SmistamentoService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class CancellaSmistamentoService extends BaseService implements DocAreaExtendedService {


    @Autowired
    SmistamentoRepository smistamentoRepository

    @Autowired
    SmistamentoService smistamentoService

    @Autowired
    ProtocolloService protocolloService

    CancellaSmistamentoService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService) {
        super(docAreaExtenedHelperService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'delSmistamento'
    }

    @Override
    @CompileDynamic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        String idDocumento = getIdDocumento(xml)
        if(idDocumento) {
            it.finmatica.protocollo.smistamenti.Smistamento smistamento = smistamentoRepository.findOne(Long.valueOf(idDocumento))
            if(smistamento) {
                try {
                    def prot = protocolloService.findById(smistamento.documento.id)
                    if(prot) {
                        smistamentoService.eliminaSmistamento(prot, smistamento)
                    } else {
                        throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Smistamento non riferito a protocollo')
                    }
                } catch(ClassCastException e) {
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Smistamento non riferito a protocollo')
                }
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Smistamento assente')
            }
            return toXml(resp)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Id documento assente')
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
    String getUnitaCreazione(Node node) {
        node.UNITA_CREAZIONE?.text()
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
