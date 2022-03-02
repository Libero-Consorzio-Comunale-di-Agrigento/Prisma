package it.finmatica.protocollo.integrazioni.ws.si4cs.invio

import javax.jws.WebMethod
import javax.jws.WebParam
import javax.jws.WebResult
import javax.jws.WebService
import javax.jws.soap.SOAPBinding
import javax.xml.ws.RequestWrapper
import javax.xml.ws.ResponseWrapper

@WebService(name = "NotificaInvioService", serviceName = "NotificaInvioService", portName = "NotificaInvioPort", targetNamespace = "http://ws.finmatica.it/")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
interface NotificaInvioService {
    @WebResult(name = "return", targetNamespace = "")
    @RequestWrapper(localName = "send", targetNamespace = "http://ws.finmatica.it/", className = "it.finmatica.ws.Send")
    @WebMethod(action = "urn:Send")
    @ResponseWrapper(localName = "sendResponse", targetNamespace = "http://ws.finmatica.it/", className = "it.finmatica.ws.SendResponse")
    String send(@WebParam(name = "msg", targetNamespace = "") Messaggio msg)
}
