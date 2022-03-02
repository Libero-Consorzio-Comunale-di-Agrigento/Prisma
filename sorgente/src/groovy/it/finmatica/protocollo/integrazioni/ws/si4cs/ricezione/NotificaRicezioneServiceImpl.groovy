package it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione

import groovy.util.logging.Slf4j
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiSi4CSService
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebMethod
import javax.jws.WebService
import java.util.logging.Logger

@Slf4j
@WebService(serviceName = "NotificaRicezioneService", portName = "NotificaRicezionePort", targetNamespace = "http://ws.finmatica.it/")
public class NotificaRicezioneServiceImpl implements NotificaRicezioneService {
    private static final Logger LOG = Logger.getLogger(NotificaRicezioneServiceImpl.class.getName())
    @Autowired
    MessaggiSi4CSService messaggiRicevutiSi4CSService

    @WebMethod
    SendMessaggioRicevutoResponse sendMessaggioRicevuto(SendMessaggioRicevuto sendMessaggioRicevuto) {
        LOG.info("Executing operation sendMessaggioRicevuto con messageId=" + sendMessaggioRicevuto.arg0.id)
        SendMessaggioRicevutoResponse _return = new SendMessaggioRicevutoResponse()

        try {
            Protocollo protocollo = messaggiRicevutiSi4CSService.creaMessaggioRicevutoAgsprDaSi4CS("" + sendMessaggioRicevuto.arg0.id)

            if (protocollo != null) {
                try {
                    String messaggio = messaggiRicevutiSi4CSService.protocollaMessaggioRicevutoSi4CS(protocollo)

                    if (messaggio != null) {
                        messaggiRicevutiSi4CSService.salvaMessaggioErroreprotocollazioneMessaggioRicevutoSi4CS(protocollo, messaggio)
                    }
                } catch (Exception exi) {
                    //dontcare
                }
            }
            _return.setReturn("Ricevuto S")
            return _return
        } catch (Exception ex) {
            ex.printStackTrace()
            _return.setReturn("Errore. " + ex.getMessage())
            return _return
        }
    }
}
