package it.finmatica.protocollo.integrazioni.anagrafe

import groovy.util.logging.Slf4j
import it.finmatica.adrier.AdrierGate
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
@Slf4j
class AdrierService {

    String ESITO_OK = "OK"
    String ESITO_KO = "KO"
    String ESITO_NORET = "NORET"

    HashMap<String, String> ricerca(String key) {

        try {

            AdrierGate adrierGate = new AdrierGate(ImpostazioniProtocollo.ADRIER_WS_URL.valore, ImpostazioniProtocollo.ADRIER_WS_USER.valore, ImpostazioniProtocollo.ADRIER_WS_PSW.valore);
            String xmlRet = ""
            try {

                xmlRet = adrierGate.RicercaPerDenominazione(key)
                log.info("RicercaPerDenominazione: " + xmlRet)
            } catch (RuntimeException re) {
                log.error(re.message)
                throw new ProtocolloRuntimeException(re.message)
            }

            HashMap<String, String> mapImprese = parseXml(xmlRet)

            if (!mapImprese["esito"].equals(ESITO_NORET))
                return mapImprese

            //Provo con il codice fiscale
            xmlRet = adrierGate.RicercaPerCodiceFiscale(key)
            mapImprese = parseXml(xmlRet)
            return mapImprese
        } catch (RuntimeException e) {
            log.error(e.getLocalizedMessage())
            throw new ProtocolloRuntimeException(e)
        }

    }

    HashMap<String, String> ricercaDettagli(String sigla, String numero) {
        AdrierGate adrierGate = new AdrierGate(ImpostazioniProtocollo.ADRIER_WS_URL.valore, ImpostazioniProtocollo.ADRIER_WS_USER.valore, ImpostazioniProtocollo.ADRIER_WS_PSW.valore);

        String xmlRet = adrierGate.DettaglioImpresa(sigla, numero)

        return parseXmlDettaglio(xmlRet)
    }

    private HashMap<String, String> parseXml(String xml) {
        def xmlObject = new XmlSlurper().parseText(xml)

        String esito = xmlObject.HEADER.ESITO.text()

        if (esito.equals(ESITO_OK)) {

            String denominazione = xmlObject.DATI.DENOMINAZIONE.text()

            List<HashMap<String, String>> listaImprese = []
            for (impresa in xmlObject.DATI.LISTA_IMPRESE.ESTREMI_IMPRESA) {
                def impresaMap = [:]

                impresaMap.put("denominazione", impresa.DENOMINAZIONE.text())
                impresaMap.put("codiceFiscale", impresa.CODICE_FISCALE.text())
                impresaMap.put("partitaIva", impresa.PARTITA_IVA.text())
                impresaMap.put("sigla", impresa.DATI_ISCRIZIONE_REA.CCIAA.text())
                impresaMap.put("numRea", impresa.DATI_ISCRIZIONE_REA.NREA.text())

                listaImprese.add(impresaMap)
            }

            return [esito: ESITO_OK, listaImprese: listaImprese]
        } else {
            String tipo = xmlObject.DATI.ERRORE.TIPO.text()
            String msg = xmlObject.DATI.ERRORE.MSG_ERR.text()

            if (!tipo.equals("IMP_occorrenza_0") && !tipo.equals("CF_PI_errato"))
                return [esito: ESITO_KO, errore: msg]
            else
                return [esito: ESITO_NORET]
        }
    }

    private HashMap<String, String> parseXmlDettaglio(String xml) {
        def xmlObject = new XmlSlurper().parseText(xml)

        String esito = xmlObject.HEADER.ESITO.text()
        if (esito.equals(ESITO_OK)) {

            HashMap<String, String> impresa = []
            impresa.put("codiceFiscale", xmlObject.DATI.DATI_IMPRESA.ESTREMI_IMPRESA.CODICE_FISCALE.text())
            impresa.put("partitaIva", xmlObject.DATI.DATI_IMPRESA.ESTREMI_IMPRESA.PARTITA_IVA.text())

            List<HashMap<String, String>> listaDettagli = []

            def infoSede = xmlObject.DATI.DATI_IMPRESA.INFORMAZIONI_SEDE

            String indirizzoSede = infoSede.INDIRIZZO.TOPONIMO.text() + " " + infoSede.INDIRIZZO.VIA.text() + " " + infoSede.INDIRIZZO.N_CIVICO.text()
            def indirizzoSedeMap = [:]
            indirizzoSedeMap.put("indirizzo", indirizzoSede)
            indirizzoSedeMap.put("comune", infoSede.INDIRIZZO.COMUNE.text())
            indirizzoSedeMap.put("provincia", infoSede.INDIRIZZO.PROVINCIA.text())
            indirizzoSedeMap.put("cap", infoSede.INDIRIZZO.CAP.text())
            indirizzoSedeMap.put("mail", infoSede.INDIRIZZO.INDIRIZZO_PEC.text())

            listaDettagli.add(indirizzoSedeMap)

            for (localizzazione in xmlObject.DATI.DATI_IMPRESA.LOCALIZZAZIONI.LOCALIZZAZIONE) {
                indirizzoSedeMap = [:]

                String indirizzoLocalizzazione = localizzazione.INDIRIZZO.TOPONIMO.text() + " " + localizzazione.INDIRIZZO.VIA.text() + " " + localizzazione.INDIRIZZO.N_CIVICO.text()

                indirizzoSedeMap.put("indirizzo", indirizzoLocalizzazione)
                indirizzoSedeMap.put("comune", localizzazione.INDIRIZZO.COMUNE.text())
                indirizzoSedeMap.put("provincia", localizzazione.INDIRIZZO.PROVINCIA.text())
                indirizzoSedeMap.put("cap", localizzazione.INDIRIZZO.CAP.text())
                indirizzoSedeMap.put("mail", localizzazione.INDIRIZZO.INDIRIZZO_PEC.text())

                listaDettagli.add(indirizzoSedeMap)
            }

            return [esito: ESITO_OK, listaDettagli: listaDettagli, impresa: impresa]
        } else {
            String msg = xmlObject.DATI.ERRORE.MSG_ERR.text()
            return [esito: ESITO_KO, errore: msg]
        }
    }
}