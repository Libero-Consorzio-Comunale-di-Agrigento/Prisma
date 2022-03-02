package it.finmatica.protocollo.integrazioni.ws

import javax.jws.WebMethod
import javax.jws.WebParam
import javax.jws.WebService
import javax.jws.soap.SOAPBinding

@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@WebService(name = "ProtocolloEmergenza", serviceName = "ProtocolloEmergenzaService", portName = "ProtocolloEmergenzaPort")
interface ProtocolloEmergenzaWebService {
    @WebMethod
    String importaProtocolliEmergenza(@WebParam(name = "xmlInput") String xmlInput)
}