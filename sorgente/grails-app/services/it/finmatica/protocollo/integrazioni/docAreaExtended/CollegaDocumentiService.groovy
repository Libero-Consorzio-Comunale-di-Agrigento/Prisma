package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class CollegaDocumentiService extends BaseFascicoloService implements DocAreaExtendedService {

    @Autowired
    ProtocolloService protocolloService

    @Autowired
    DocumentoCollegatoService documentoCollegatoService

    @Autowired
    DizionariRepository dizionariRepository

    CollegaDocumentiService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService,@Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, null, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'collegaDocumenti'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        Long idDocumento1 = Long.valueOf(getIdDocumento1(xml)?:'-1')
        Long idDocumento2 = Long.valueOf(getIdDocumento2(xml)?:'-1')
        it.finmatica.protocollo.documenti.Protocollo protocollo1 = docAreaExtenedHelperService.getProtocolloFromId(Long.valueOf(idDocumento1))
        it.finmatica.protocollo.documenti.Protocollo protocollo2 = docAreaExtenedHelperService.getProtocolloFromId(Long.valueOf(idDocumento2))
        if(protocollo1 && protocollo2) {
            DocumentoCollegato doc = new DocumentoCollegato()
            doc.setDocumento(protocollo1)
            doc.setCollegato(protocollo2)
            String tipoRelazione = getTipoRelazione(xml)
            def tipoCollegamento = dizionariRepository.getTipoCollegamento(tipoRelazione)
            if (tipoCollegamento) {
                doc.setTipoCollegamento(tipoCollegamento)
                documentoCollegatoService.salvaDocumentiCollegati(protocollo1.toDTO() as ProtocolloDTO, doc.toDTO() as DocumentoCollegatoDTO)
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, "Tipo relazione non trovato: ${tipoRelazione}".toString())
            }
            return toXml(resp)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'Documento non trovato')
        }
    }

    @CompileDynamic
    String getIdDocumento1(Node node) {
        node.ID_DOCUMENTO_1?.text()
    }

    @CompileDynamic
    String getIdDocumento2(Node node) {
        node.ID_DOCUMENTO_2?.text()
    }

    @CompileDynamic
    String getTipoRelazione(Node node) {
        node.TIPO_RELAZIONE?.text()
    }


}
