package it.finmatica.protocollo.integrazioni.ws

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.integrazioni.DocAreaHelperService
import it.finmatica.protocollo.integrazioni.DocAreaProtocollazioneException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.filter.RequestContextFilter

import javax.jws.WebParam

@CompileStatic
@Slf4j
class DocAreaProtoWebServiceImpl extends RequestContextFilter implements DOCAREAProtoSoapV2{
    @Autowired DocAreaHelperService docAreaHelperService

    private ObjectFactory of = new ObjectFactory()

    @Override
    InserimentoRet inserimento(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST) {
        try {
            return docAreaHelperService.inserimento(strUserName,strDST)
        } catch (Exception e) {
            def ret = new InserimentoRet()
            ret.lngErrNumber = -1
            ret.strErrString = of.createLoginRetStrErrString(e.message)
            return ret
        }
    }

    @Override
    ProtocollazioneRet protocollazione(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST) {
        try {
            return docAreaHelperService.protocollazione(strUserName,strDST)
        } catch(DocAreaProtocollazioneException e) {
            // uso la eccezione creata dal servizio
            return e.ret
        } catch (Exception e) {
            def ret = new ProtocollazioneRet()
            ret.lngErrNumber = -1
            ret.strErrString = of.createLoginRetStrErrString(e.message)
            return ret
        }
    }

    @Override
    SostituisciDocumentoPrincipaleRet sostituisciDocumentoPrincipale(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST) {
        try {
            return docAreaHelperService.sostituisciDocumentoPrincipale(strUserName,strDST)
        } catch (Exception e) {
            def ret = new SostituisciDocumentoPrincipaleRet()
            ret.lngErrNumber = -1
            ret.strErrString = of.createLoginRetStrErrString(e.message)
            return ret
        }
    }

    @Override
    AggiungiAllegatoRet aggiungiAllegato(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST) {
        try {
            return docAreaHelperService.aggiungiAllegato(strUserName,strDST)
        } catch (Exception e) {
            def ret = new AggiungiAllegatoRet()
            ret.lngErrNumber = -1
            ret.strErrString = of.createLoginRetStrErrString(e.message)
            return ret
        }
    }

    @Override
    LoginRet login(@WebParam(name = "strCodEnte", targetNamespace = "") String strCodEnte, @WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strPassword", targetNamespace = "") String strPassword) {
        try {
            return docAreaHelperService.loginAoo(strCodEnte, null, strUserName, strPassword)
        } catch (Exception e) {
            def ret = new LoginRet()
            ret.lngErrNumber = -1
            ret.strErrString = of.createLoginRetStrErrString(e.message)
            return ret
        }
    }

    @Override
    SmistamentoActionRet smistamentoAction(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST) {
        try {
            return docAreaHelperService.smistamentoAction(strUserName,strDST)
        } catch (Exception e) {
            def ret = new SmistamentoActionRet()
            ret.lngErrNumber = -1
            ret.strErrString = of.createLoginRetStrErrString(e.message)
            return ret
        }
    }

    @Override
    LoginRet loginAoo(@WebParam(name = "strCodEnte", targetNamespace = "") String strCodEnte, @WebParam(name = "strAoo", targetNamespace = "") String strAoo, @WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strPassword", targetNamespace = "") String strPassword) {
        try {
            return docAreaHelperService.loginAoo(strCodEnte,strAoo,strUserName,strPassword)
        } catch (Exception e) {
            def ret = new LoginRet()
            ret.lngErrNumber = -1
            ret.strErrString = of.createLoginRetStrErrString(e.message)
            return ret
        }
    }

}
