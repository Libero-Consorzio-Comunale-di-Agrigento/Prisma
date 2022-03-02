package it.finmatica.protocollo.integrazioni.ws

import javax.jws.WebService
import javax.jws.soap.SOAPBinding

@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.WRAPPED, style = SOAPBinding.Style.RPC)
@WebService(name = "Protocollo", serviceName = "ProtocolloService", portName = "ProtocolloPort")
interface ProtocolloWebServiceV2 extends ProtocolloWebService{

}
