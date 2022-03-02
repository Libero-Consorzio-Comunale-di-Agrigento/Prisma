package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import it.finmatica.protocollo.integrazioni.DocAreaHelperService
import it.finmatica.protocollo.integrazioni.DocAreaProtocollazioneException
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam
import java.nio.charset.StandardCharsets

@CompileStatic
class ProtocolloDocAreaMTOMServiceImpl implements ProtocolloDocAreaMTOMService {
    @Autowired DocAreaHelperService docAreaHelperService
    @Override
    InserimentoRet inserimento(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST, @WebParam(name = "strAttachment", targetNamespace = "") byte[] strAttachment) {
        return docAreaHelperService.doInserimento(strDST,strUserName,null, strAttachment)
    }

    @Override
    ProtocollazioneRet protocollazione(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST, @WebParam(name = "strAttachment", targetNamespace = "") byte[] strAttachment) {
        try {
            return docAreaHelperService.doProtocollazione(strUserName, strDST, readAttachment(strAttachment))
        } catch (DocAreaProtocollazioneException e) {
            return e.ret
        }
    }

    @Override
    SostituisciDocumentoPrincipaleRet sostituisciDocumentoPrincipale(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST, @WebParam(name = "strAttachment", targetNamespace = "") byte[] strAttachment) {
        return docAreaHelperService.doSostituisciDocumentoPrincipale(strDST,strUserName,readAttachment(strAttachment))
    }

    @Override
    AggiungiAllegatoRet aggiungiAllegato(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST, @WebParam(name = "strAttachment", targetNamespace = "") byte[] strAttachment) {
        return docAreaHelperService.doAggiungiAllegato(strDST,strUserName,readAttachment(strAttachment))
    }

    @Override
    LoginRet login(@WebParam(name = "strCodEnte", targetNamespace = "") String strCodEnte, @WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strPassword", targetNamespace = "") String strPassword) {
        return docAreaHelperService.loginAoo(strCodEnte,null,strUserName,strPassword)
    }

    @Override
    SmistamentoActionRet smistamentoAction(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST, @WebParam(name = "strAttachment", targetNamespace = "") byte[] strAttachment) {
        return docAreaHelperService.doSimistamanentoAction(strDST,strUserName,readAttachment(strAttachment))
    }

    @Override
    LoginRet loginAoo(@WebParam(name = "strCodEnte", targetNamespace = "") String strCodEnte, @WebParam(name = "strAoo", targetNamespace = "") String strAoo, @WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strPassword", targetNamespace = "") String strPassword) {
        return docAreaHelperService.loginAoo(strCodEnte,strAoo,strUserName,strPassword)
    }

    private String readAttachment(byte[] strAttachment) {
        new String(strAttachment, StandardCharsets.UTF_8)
    }
}