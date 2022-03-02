package it.finmatica.protocollo.integrazioni.ws

import it.finmatica.protocollo.integrazioni.ws.dati.Protocollo
import it.finmatica.protocollo.integrazioni.ws.dati.Soggetto
import it.finmatica.protocollo.integrazioni.ws.dati.response.CaricaProtocolloResponse
import it.finmatica.protocollo.integrazioni.ws.dati.response.CreaLetteraResponse
import javax.jws.WebMethod
import javax.jws.WebParam
import javax.jws.WebService
import javax.jws.soap.SOAPBinding

@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@WebService(name = "Protocollo", serviceName = "ProtocolloService", portName = "ProtocolloPort")
interface ProtocolloWebService {

    /**
     *   - tipo_protocollo (se non passato prevedere un default su parametro)
         - schema_protocollo
         - oggetto
         - classifica
         - fascicolo
         - modalità
         - riservato
         - data_redazione
         - note
         - utente creazione => redazione
         - corrispondenti
         - smistamenti
         - file principale
         - allegati
         - documenti collegati (precedente per rispondi)

         ritorni un oggetto contenente:
         - esito
         - messaggio di errore
         - id_lettera
         - id_lettera_gdm
         - url relativo per aprire la maschera
     * @param
     * @param
     * @return
     */
    @WebMethod
    CreaLetteraResponse creaLettera(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = "protocollo") Protocollo protocollo)

    @WebMethod(operationName = 'getLettera')
    CaricaProtocolloResponse getLettera(@WebParam(name = "operatore") Soggetto operatore, @WebParam(name = "ente") long ente, @WebParam(name = 'id') Long id)
}
