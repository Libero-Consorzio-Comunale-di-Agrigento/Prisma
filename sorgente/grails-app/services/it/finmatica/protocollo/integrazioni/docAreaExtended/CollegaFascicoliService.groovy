package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions.DocAreaExtendedException
import it.finmatica.protocollo.integrazioni.ws.dati.response.ErroriWsDocarea
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.xml.bind.JAXBContext

@Transactional
@Service
@Slf4j
@CompileStatic
class CollegaFascicoliService extends BaseFascicoloService implements DocAreaExtendedService {

    private static String COLLEGAMENTO = "COLLEGAMENTO"
    private static String PRECEDENTE = "PRECEDENTE"


    @Autowired
    FascicoloRepository fascicoloRepository

    @Autowired
    DizionariRepository dizionariRepository

    @Autowired
    DocumentoCollegatoService documentoCollegatoService

    CollegaFascicoliService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService,@Autowired ProtocolloGestoreCompetenze protocolloGestoreCompetenze) {
        super(docAreaExtenedHelperService, null, protocolloGestoreCompetenze)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'collegaFascicoli'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        def idString1 = getIdDocumento1(xml)
        def idString2 = getIdDocumento2(xml)
        Long idDocumento1 = Long.valueOf(idString1)
        Long idDocumento2 = Long.valueOf(idString2)
        def fascicolo1 = fascicoloRepository.getFascicoloFromId(idDocumento1)
        def fascicolo2 = fascicoloRepository.getFascicoloFromId(idDocumento2)
        if(fascicolo1 && fascicolo2) {
            boolean relazioneAttiva = getRelazioneAttiva(xml) == 'SI'
            String tpr = getTipoRelazione(xml)
            String tipoRelazione
            switch (tpr) {
                case COLLEGAMENTO: tipoRelazione = TipoCollegamentoConstants.CODICE_FASC_COLLEGATO; break
                case PRECEDENTE: tipoRelazione = TipoCollegamentoConstants.CODICE_FASC_PREC_SEG; break
            }
            def tipoCollegamento = dizionariRepository.getTipoCollegamento(tipoRelazione)
            if (tipoCollegamento) {
                DocumentoCollegato doc = new DocumentoCollegato()
                doc.setDocumento(fascicolo1)
                doc.setCollegato(fascicolo2)
                doc.tipoCollegamento = tipoCollegamento
                documentoCollegatoService.salvaDocumentiCollegati(fascicolo1.toDTO() as FascicoloDTO, doc.toDTO() as DocumentoCollegatoDTO)
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, "Tipo relazione non trovato: ${tpr}".toString())
            }
            return toXml(resp)
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'Fascicolo non trovato')
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
    String getRelazioneAttiva(Node node) {
        node.RELAZIONE_ATTIVA?.text()
    }

    @CompileDynamic
    String getTipoRelazione(Node node) {
        node.TIPO_RELAZIONE?.text()
    }

}
