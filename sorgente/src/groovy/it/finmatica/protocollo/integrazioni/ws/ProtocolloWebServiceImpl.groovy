package it.finmatica.protocollo.integrazioni.ws

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.Holders
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.integrazioni.ws.dati.Protocollo
import it.finmatica.protocollo.integrazioni.ws.dati.Soggetto
import it.finmatica.protocollo.integrazioni.ws.dati.response.CaricaProtocolloResponse
import it.finmatica.protocollo.integrazioni.ws.dati.response.CreaLetteraResponse
import org.springframework.transaction.annotation.Transactional

import javax.jws.WebParam
import javax.servlet.ServletContext

@Slf4j
@Transactional
class ProtocolloWebServiceImpl extends ProtocolloWebServiceBase implements ProtocolloWebService {

    @Override
    CreaLetteraResponse creaLettera(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = "protocollo") Protocollo protocollo) {
        log.info("INIZIO: Chiamata al WS di creazione della lettera")

        CreaLetteraResponse response = new CreaLetteraResponse()
        try {
            // il webservice è protetto da basic-authentication. Normalmente viene fatto login con una utenza di servizio.
            // Con questo metodo "rifaccio" il login con l'operatore "vero e proprio" con cui risulteranno fatte le operazioni.
            login(operatore, ente)

            it.finmatica.protocollo.documenti.Protocollo p = creaProtocolloDaWS(protocollo)

            response.id = p.id
            response.idDocumentoEsterno = p.idDocumentoEsterno
            response.url = Impostazioni.AG_SERVER_URL.valore + Holders.getApplicationContext().getBean(ServletContext).contextPath + "/standalone.zul?operazione=APRI_DOCUMENTO&tipoDocumento=LETTERA&idDoc=" + p.idDocumentoEsterno
            response.esito = "OK"
        } catch (Throwable t) {
            log.error(t.message, t)
            throw new ProtocolloRuntimeException(t)
        }

        log.info("FINE: Chiamata al WS di creazione della lettera")
        return response
    }

    @Override
    CaricaProtocolloResponse getLettera(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = 'id') Long id) {
        log.info("INIZIO: Chiamata al WS di scaricamento della lettera")

        CaricaProtocolloResponse response = new CaricaProtocolloResponse()

        try {

            // il webservice è protetto da basic-authentication. Normalmente viene fatto login con una utenza di servizio.
            // Con questo metodo "rifaccio" il login con l'operatore "vero e proprio" con cui risulteranno fatte le operazioni.
            login(operatore, ente)

            response.protocollo = caricaProtocolloWs(id)
            response.esito = "OK"
        } catch (Throwable t) {
            log.error(t.message, t)
            throw new ProtocolloRuntimeException(t)
        }

        log.info("FINE: Chiamata al WS di scaricamento lettera")
        return response
    }


}
