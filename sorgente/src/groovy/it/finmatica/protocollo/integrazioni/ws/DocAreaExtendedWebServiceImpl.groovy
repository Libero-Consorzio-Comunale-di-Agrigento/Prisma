package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.integrazioni.DocAreaExtendedHelperService
import it.finmatica.protocollo.integrazioni.protocolloextended.ProtocolloExtendedService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam

@CompileStatic
@Slf4j
class DocAreaExtendedWebServiceImpl implements ProtocolloExtendedService {
    @Autowired
    DocAreaExtendedHelperService docAreaExtendedHelperService

    @Override
    String getDocumentiProtocollati(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'getDocumentiProtocollati')
    }

    @Override
    String modFascicolo(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'modFascicolo')
    }

    @Override
    String getFascicoli(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'getFascicoli')
    }

    @Override
    String modProtocollo(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'modProtocollo')
    }

    @Override
    String collegaFascicoli(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'collegaFascicoli')
    }

    @Override
    String getInfoPec(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'getInfoPec')
    }

    @Override
    String addFilePrincipale(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'addFilePrincipale')
    }

    @Override
    String delFilePrincipale(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'delFilePrincipale')

    }

    @Override
    String delDocumento(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'delDocumento')

    }

    @Override
    String getClassifiche(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'getClassifiche')

    }

    @Override
    String addRapporto(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'addRapporto')

    }

    @Override
    String getDocumentiNonProtocollati(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'getDocumentiNonProtocollati')
    }

    @Override
    String collegaDocumenti(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'collegaDocumenti')
    }

    @Override
    String creaFascicolo(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'creaFascicolo')
    }

    @Override
    String rimuoviDocumentoDalFascicolo(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'rimuoviDocumentoDalFascicolo')
    }

    @Override
    String inserisciDocumentoInFascicolo(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'inserisciDocumentoInFascicolo')
    }

    @Override
    String inserisciDocumentoInFascicoloSecondario(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'inserisciDocumentoInFascicoloSecondario')
    }

    @Override
    String getDocumento(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'getDocumento')
    }

    @Override
    String creaDocumento(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'creaDocumento')
    }

    @Override
    String delFascicolo(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'delFascicolo')
    }

    @Override
    String modDocumento(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'modDocumento')
    }

    @Override
    String delRapporto(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'delRapporto')
    }

    @Override
    String addSmistamento(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'addSmistamento')
    }

    @Override
    String delSmistamento(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'delSmistamento')
    }

    @Override
    String getUrlBarcodeProtocollo(@WebParam(name = "user", targetNamespace = "") String user, @WebParam(name = "DST", targetNamespace = "") String dst, @WebParam(name = "xml", targetNamespace = "") String xml) {
        return docAreaExtendedHelperService.executeService(user, dst, xml, 'getUrlBarcodeProtocollo')
    }
}
