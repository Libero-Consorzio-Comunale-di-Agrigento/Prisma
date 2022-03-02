package it.finmatica.protocollo.integrazioni.ws

import groovy.util.logging.Slf4j
import it.finmatica.protocollo.emergenza.ProtocolloEmergenzaService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import org.springframework.beans.factory.annotation.Autowired

import javax.jws.WebParam

@Slf4j
class ProtocolloEmergenzaWebServiceImpl implements ProtocolloEmergenzaWebService {

    @Autowired
    ProtocolloEmergenzaService protocolloEmergenzaService

    @Override
    String importaProtocolliEmergenza(@WebParam(name = "xmlInput") String xmlInput) {
        log.info("INIZIO: Chiamata al WS di import dei protocolli di emergenza con questo xml {}", xmlInput)
        try {
            String response = protocolloEmergenzaService.importaProtocolli(xmlInput)
            log.info("FINE: Chiamata al WS di import dei protocolli di emergenza")
            return response
        } catch (Throwable t) {
            log.error(t.message, t)
            throw new ProtocolloRuntimeException(t)
        }
    }
}
