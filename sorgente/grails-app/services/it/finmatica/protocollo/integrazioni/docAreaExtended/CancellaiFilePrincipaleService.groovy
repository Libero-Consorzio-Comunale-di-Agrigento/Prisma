package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
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
class CancellaiFilePrincipaleService extends BaseDocumentoService implements DocAreaExtendedService {


    @Autowired
    ProtocolloService protocolloService


    CancellaiFilePrincipaleService(@Autowired DocAreaExtendedHelperService docAreaExtenedHelperService, @Autowired SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService,schemaProtocolloService)
        jc = JAXBContext.newInstance(Result)
    }

    @Override
    String getXsdName() {
        return 'delFilePrincipale'
    }

    @Override
    @CompileStatic
    String execute(String user, Node xml, boolean ignoraCompetenze) {
        Result resp = new Result()
        resp.setRESULT(ResultStatus.OK.name())
        String idFile = getIdFile(xml)
        String idString = getIdDocumento(xml)?.trim()
        Long idDocumento = idString ? Long.valueOf(idString) : null
        it.finmatica.protocollo.documenti.Protocollo protocollo = idDocumento ? docAreaExtenedHelperService.getProtocolloFromId(idDocumento): null
        if(protocollo) {
            if (idFile?.trim()) {
                def fileDaRimuovere = protocollo.fileDocumenti.find {it.id == Long.valueOf(idFile)}
                if(fileDaRimuovere) {
                    protocollo.removeFromFileDocumenti(fileDaRimuovere)
                } else {
                    throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'Id file non trovato sul protocollo')
                }
            } else {
                throw new DocAreaExtendedException(ErroriWsDocarea.ERRORE_INTERNO.codice, 'File non trovato')
            }
            return toXml(resp)

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


}
