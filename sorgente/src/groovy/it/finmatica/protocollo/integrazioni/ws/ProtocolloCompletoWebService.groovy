package it.finmatica.protocollo.integrazioni.ws

import it.finmatica.protocollo.integrazioni.ws.dati.Allegato
import it.finmatica.protocollo.integrazioni.ws.dati.ProtocolloCompleto
import it.finmatica.protocollo.integrazioni.ws.dati.Soggetto
import it.finmatica.protocollo.integrazioni.ws.dati.response.CaricaProtocolloCompletoResponse

import javax.jws.WebMethod
import javax.jws.WebParam
import javax.jws.WebService
import javax.jws.soap.SOAPBinding

@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.WRAPPED, style = SOAPBinding.Style.RPC)
@WebService(name = "ProtocolloCompleto", serviceName = "ProtocolloCompletoService", portName = "ProtocolloCompletoPort")
interface ProtocolloCompletoWebService {

    @WebMethod
    CaricaProtocolloCompletoResponse creaProtocollo(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = "protocollo") ProtocolloCompleto protocollo)

    @WebMethod
    CaricaProtocolloCompletoResponse creaProtocolloDaSegnatura(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = "xmlSegnatura") String xmlSegnatura, @WebParam(name = "allegati") List<Allegato> allegati)

}
