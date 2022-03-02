package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.DocAreaFile
import it.finmatica.protocollo.integrazioni.DocAreaFileService
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
class AggiungiFilePrincipaleService extends BaseDocumentoService implements DocAreaExtendedService {


    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DocAreaFileService docAreaFileService

    AggiungiFilePrincipaleService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'addFilePrincipale'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        String idFile = getIdFile(xml)
        String fileName = getFileName(xml)
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento): null
        if(protocollo) {
            if(idFile?.trim()) {
                DocAreaFile docAreaFile = docAreaFileService.findById(Long.valueOf(idFile))
                if(docAreaFile) {
                    FileDocumento fd = protocolloService.caricaFilePrincipale(protocollo, new ByteArrayInputStream(docAreaFile.content), docAreaFile.contentType, fileName,ignoraCompetenze)
                    resp.id = fd.id
                    return toXml(resp)
                } else {
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'File non trovato')
                }
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'IdFile assente')
            }
        } else {
            throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice,'Protocollo non trovato')
        }
    }

    @CompileDynamic
    String getUnitaSmistamento(Node node) {
        node.UNITA_SMISTAMENTO?.text()
    }

    @CompileDynamic
    String getTipoSmistamento(Node node) {
        node.TIPO_SMISTAMENTO?.text()
    }

    @CompileDynamic
    String getIdFile(Node node) {
        node.ID_FILE?.text()
    }

    @CompileDynamic
    String getFileName(Node node) {
        node.FILENAME?.text()
    }

}
