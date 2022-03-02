package it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione

import javax.jws.WebParam
import javax.jws.WebResult
import javax.jws.WebService
import javax.jws.soap.SOAPBinding

@WebService(name = "NotificaRicezioneService", serviceName = "NotificaRicezioneService", portName = "NotificaRicezionePort", targetNamespace = "http://ws.finmatica.it/")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
public interface NotificaRicezioneService {
    @WebResult(name = "return", targetNamespace = "http://ws.finmatica.it/", partName = "return")
    public it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevutoResponse sendMessaggioRicevuto(
            @WebParam(partName = "sendMessaggioRicevuto", name = "sendMessaggioRicevuto", targetNamespace = "http://ws.finmatica.it/")
                    SendMessaggioRicevuto sendMessaggioRicevuto
    )
}
