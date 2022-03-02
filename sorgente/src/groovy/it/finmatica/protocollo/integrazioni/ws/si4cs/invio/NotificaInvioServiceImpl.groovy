package it.finmatica.protocollo.integrazioni.ws.si4cs.invio

import it.finmatica.protocollo.integrazioni.si4cs.MessaggiSi4CSService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebMethod
import javax.jws.WebParam
import javax.jws.WebService
import java.util.logging.Logger

@WebService(serviceName = "NotificaInvioService", portName = "NotificaInvioPort", targetNamespace = "http://ws.finmatica.it/")
class NotificaInvioServiceImpl implements NotificaInvioService {
    private static final Logger LOG = Logger.getLogger(NotificaInvioServiceImpl.class.getName())
    @Autowired
    MessaggiSi4CSService messaggiRicevutiSi4CSService

    @WebMethod
    String send(@WebParam(name = "msg", targetNamespace = "") Messaggio msg) {
        LOG.info("Executing operation notificaSpedizioneInvio con messageId=" + msg.id + ", statoSpedizione=" + msg.stato + ", dataSpedizione=" + msg.data)

        SendResponse _return = new SendResponse()
        try {
            messaggiRicevutiSi4CSService.aggiornaMessaggioInviatoASi4Cs("" + msg.id, msg.stato, msg.data.toGregorianCalendar().getTime())
            _return.setReturn("OK")
            return _return.getReturn()
        } catch (Exception ex) {
            ex.printStackTrace()
            _return.setReturn("Errore. " + ex.getMessage())
            return _return.getReturn()
        }
    }
}
