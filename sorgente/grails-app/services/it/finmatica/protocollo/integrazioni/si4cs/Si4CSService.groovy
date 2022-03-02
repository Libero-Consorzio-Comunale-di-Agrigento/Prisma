package it.finmatica.protocollo.integrazioni.si4cs

import groovy.json.JsonSlurper
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.login.TokenManager
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.segreteria.common.StringUtility
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.boot.configurationprocessor.json.JSONArray
import org.springframework.boot.configurationprocessor.json.JSONObject
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.jdbc.datasource.DataSourceUtils
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

import javax.sql.DataSource
import java.nio.charset.StandardCharsets

@Slf4j
@Service
class Si4CSService {
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    SpringSecurityService springSecurityService
    @Qualifier("ad4DataSource")
    @Autowired
    private DataSource ad4DataSource

    def getMessaggiFiltrati(String destinatari, String mittente, String oggetto, Date dal, Date al, String certificata, String ricevuta) {

        RestTemplate restTemplate = new RestTemplate();

        // OOKKIO --> "includi messaggi automatici" della vecchia form -> è ricevuta...solo true false (tutti nn c'è) mentre certificata può essere SI NO TUTTI

        String url = ImpostazioniProtocollo.URL_SI4CS_SERVICE.valore + "/filtro?fake=1"

        if (!StringUtility.nvl(certificata, "").equals("")) {
            url += "&certificata=" + certificata
        }
        if (!StringUtility.nvl(ricevuta, "").equals("")) {
            url += "&ricevuta=" + ricevuta
        }
        if (!StringUtility.nvl(destinatari, "").equals("")) {
            url += "&destinatari=" + destinatari
        }
        if (!StringUtility.nvl(mittente, "").equals("")) {
            url += "&mittente=" + mittente
        }
        if (!StringUtility.nvl(oggetto, "").equals("")) {
            url += "&oggetto=" + oggetto
        }
        if (dal != null) {
            url += "&dal=" + dal.format("dd/MM/yyyy")
        }
        if (al != null) {
            url += "&al=" + al.format("dd/MM/yyyy")
        }

        String result = restTemplate.getForObject(url, String.class);

        def retList = []
        def json = new JsonSlurper().parseText(result)
        for (jsonItem in json) {
            String certificataRet = jsonItem.certificata
            if (certificataRet.equals("true")) {
                certificataRet = "Da posta elettronica certificata"
            } else {
                certificataRet = "Da posta elettronica ordinaria"
            }

            retList << [messaggio: jsonItem.messaggio, oggetto: jsonItem.oggetto, destinatari: jsonItem.destinatari, data: jsonItem.data_sd, certificata: certificataRet, allegati: jsonItem.allegati]
        }

        return retList
    }

    def getMessaggioDettaglio(String messaggio) {
        RestTemplate restTemplate = new RestTemplate()

        String url = ImpostazioniProtocollo.URL_SI4CS_SERVICE.valore + "/dettagli?messaggio=" + messaggio

        log.info("Si4CSService.getMessaggioDettaglio url richiamato: " + url)

        String result = restTemplate.getForObject(url, String.class)

        def json = new JsonSlurper().parseText(result)
        def allegati = []
        if (json.idDocumento != 0) {
            allegati = json.idAllegati
        }

        String certificataRet = json.certified_type
        if (!certificataRet.equals("PEC") && !certificataRet.equals("RICEVUTA")) {
            certificataRet = "NONPEC"
        }

        def retMap = [messaggio           : json.messaggio, idDocumento: json.idDocumento, allegati: allegati, testo: json.testo, message_id: json.message_id,
                      mittente            : json.mittente, oggetto: json.oggetto, destinatari: json.destinatari, destinatari_conoscenza: json.destinatari_conoscenza,
                      destinatari_nascosti: json.destinatari_nascosti, data: json.data_sd, certificata: certificataRet, testo: json.testo, certified_type: json.certified_type,
                      messaggio_blob      : json.messaggio_blob, id_msg_inviato: json.id_msg_inviato, tipo_ricevuta: json.tipo_ricevuta, destinatario_consegna: json.destinatario_consegna]

        return retMap
    }

    String inviaMessaggio(String tag, String mittente, String emailMittente, String testo, String oggetto,
                          List<String> idAllegati, List<String> destinatari, List<String> destinatariCC,
                          List<String> destinatariBCC, String tipoRicevutaConsegna) {
        RestTemplate restTemplate = new RestTemplate()

        if (tag == null )
            throw new ProtocolloRuntimeException("Errore in inviaMessaggio: tag non presente")
        if (emailMittente == null )
            throw new ProtocolloRuntimeException("Errore in inviaMessaggio: mail mittente non presente")
        if (destinatari == null )
            throw new ProtocolloRuntimeException("Errore in inviaMessaggio: destinatario non presente")

        String url = ImpostazioniProtocollo.URL_SI4CS_SERVICE.valore + "/invio"

        log.info("Si4CSService.inviaMessaggio url richiamato: " + url)
        JSONObject jsonObject = new JSONObject()
        jsonObject.put("tag", tag)

        JSONObject jsonObjectMittente = new JSONObject()
        jsonObjectMittente.put("nome", mittente)
        jsonObjectMittente.put("email", emailMittente)
        jsonObject.put("mittente", jsonObjectMittente)

        JSONArray arr = new JSONArray();
        for (destinatario in destinatari) {
            arr.put(destinatario)
        }
        jsonObject.put("destinatari", arr)

        arr = new JSONArray();
        for (destinatarioCC in destinatariCC) {
            arr.put(destinatarioCC)
        }
        jsonObject.put("cc", arr)

        arr = new JSONArray();
        for (destinatarioBCC in destinatariBCC) {
            arr.put(destinatarioBCC)
        }
        jsonObject.put("bcc", arr)

        arr = new JSONArray();
        for (allegato in idAllegati) {
            arr.put(Integer.parseInt(allegato))
        }
        jsonObject.put("allegati", arr)

        jsonObject.put("testo", (testo == null) ? "" : testo)
        jsonObject.put("oggetto", (oggetto == null) ? "" : oggetto)

        jsonObject.put("nome_progetto", "AGSPR")
        jsonObject.put("modulo_progetto", "AGSPR")
        jsonObject.put("fase_progetto", "")
        jsonObject.put("tipo_consegna", tipoRicevutaConsegna.toLowerCase())

        HttpHeaders headers = new HttpHeaders();
        MediaType mediaType = new MediaType("application", "json", StandardCharsets.UTF_8);
        headers.setContentType(mediaType);

        String password = new TokenManager(DataSourceUtils.getConnection(ad4DataSource), springSecurityService.principal.id).getToken()
        String auth = springSecurityService.principal.id + ":" + password;

        //String auth = "ROMAGNOL:"

        String authHeader = "Basic " + auth.bytes.encodeBase64().toString()
        headers.set("Authorization", authHeader);

        HttpEntity<String> request =
                new HttpEntity<String>(jsonObject.toString(), headers);

        String jsonResponse

        jsonResponse = restTemplate.postForObject(url, request, String.class);

        def json = new JsonSlurper().parseText(jsonResponse)
        if ("" + json.status == "0") {
            return "" + json.id
        } else {
            throw new ProtocolloRuntimeException("Errore in inviaMessaggio: " + json.error)
        }
    }
}