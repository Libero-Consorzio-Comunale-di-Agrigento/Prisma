package it.finmatica.protocollo.integrazioni.ws

import javax.jws.WebMethod
import javax.jws.WebParam
import javax.jws.WebService
import javax.jws.soap.SOAPBinding

@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.WRAPPED, style = SOAPBinding.Style.RPC)
@WebService(name = "ProtocolloDocAreaMTOM", serviceName = "ProtocolloDocAreaServiceMTOM", portName = "ProtocolloDocAreaMTOMPort",targetNamespace = 'http://tempuri.org/')
interface ProtocolloDocAreaMTOMService {
    @WebMethod
    InserimentoRet inserimento(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST,@WebParam(name = "strAttachment", targetNamespace = "")
            byte[] strAttachment)

    @WebMethod
    ProtocollazioneRet protocollazione(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST,@WebParam(name = "strAttachment", targetNamespace = "")
            byte[] strAttachment)

    @WebMethod
    SostituisciDocumentoPrincipaleRet sostituisciDocumentoPrincipale(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST,@WebParam(name = "strAttachment", targetNamespace = "")
            byte[] strAttachment)

    @WebMethod
    AggiungiAllegatoRet aggiungiAllegato(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST,@WebParam(name = "strAttachment", targetNamespace = "")
            byte[] strAttachment)

    @WebMethod
    LoginRet login(@WebParam(name = "strCodEnte", targetNamespace = "") String strCodEnte, @WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strPassword", targetNamespace = "") String strPassword)


    @WebMethod
    SmistamentoActionRet smistamentoAction(@WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strDST", targetNamespace = "") String strDST,@WebParam(name = "strAttachment", targetNamespace = "")
            byte[] strAttachment)

    @WebMethod
    LoginRet loginAoo(@WebParam(name = "strCodEnte", targetNamespace = "") String strCodEnte, @WebParam(name = "strAoo", targetNamespace = "") String strAoo, @WebParam(name = "strUserName", targetNamespace = "") String strUserName, @WebParam(name = "strPassword", targetNamespace = "") String strPassword)
}
