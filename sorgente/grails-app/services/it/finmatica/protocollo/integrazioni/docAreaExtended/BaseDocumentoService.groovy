package it.finmatica.protocollo.integrazioni.docAreaExtended

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService

@CompileStatic
abstract class BaseDocumentoService extends BaseService {
    SchemaProtocolloService schemaProtocolloService
    BaseDocumentoService(DocAreaExtendedHelperService docAreaExtenedHelperService,SchemaProtocolloService schemaProtocolloService) {
        super(docAreaExtenedHelperService)
        this.schemaProtocolloService = schemaProtocolloService
    }

    void setTipoDocumento(Node xml, it.finmatica.protocollo.documenti.Protocollo protocollo) {
        String tipoDocumento = getTipoDocumento(xml)
        List<SchemaProtocollo> sp = schemaProtocolloService.list(1, 0, tipoDocumento, false)
        if(sp) {
            protocollo.schemaProtocollo = sp.first() as SchemaProtocollo
        }
    }

    @CompileDynamic
    String getClassificazione(Node node) {
        node.CLASS_COD?.text()
    }

    @CompileDynamic
    String getFascicoloAnno(Node node) {
        node.FASCICOLO_ANNO?.text()
    }

    @CompileDynamic
    String getFascicoloNumero(Node node) {
        node.FASCICOLO_NUMERO?.text()
    }

    @CompileDynamic
    String getOggetto(Node node) {
        node.OGGETTO?.text()
    }

    @CompileDynamic
    String getNote(Node node) {
        node.NOTE?.text()
    }

    @CompileDynamic
    String getAmministrazione(Node node) {
        node.CODICE_AMMINISTRAZIONE?.text()
    }

    @CompileDynamic
    String getAoo(Node node) {
        node.CODICE_AOO?.text()
    }

    @CompileDynamic
    String getModalita(Node node) {
        node.MODALITA?.text()
    }

    @CompileDynamic
    String getTipoDocumento(Node node) {
        node.TIPO_DOCUMENTO?.text()
    }

    @CompileDynamic
    String getUnitaProtocollante(Node node) {
        node.UNITA_PROTOCOLLANTE?.text()
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
}
