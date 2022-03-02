package it.finmatica.protocollo.integrazioni.anagrafe
import org.springframework.stereotype.Service

import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.solwebservices.SolWebGate
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class SolWebService {
    String ESITO_OK = "OK"
    String ESITO_KO = "KO"


    HashMap<String,String> ricerca(String cognomeCodFiscale, String nome) {
        if (nome==null) nome=""
        if (cognomeCodFiscale==null) cognomeCodFiscale=""

        SolWebGate anagrafica = new SolWebGate(ImpostazioniProtocollo.ANAG_POPOLAZIONE_WS_URL.valore, ImpostazioniProtocollo.ANAG_POPOLAZIONE_WS_USER.valore,
                                                ImpostazioniProtocollo.ANAG_POPOLAZIONE_WS_PSW.valore);

        //Ricerco per nome / cognome
        String  xmlRet= anagrafica.RicercaPerNomeCognome(nome,cognomeCodFiscale);

        HashMap<String,String> mapAnagrafiche = parseXml(xmlRet)

        if (mapAnagrafiche["esito"].equals(ESITO_OK) && nome.equals("")  && mapAnagrafiche["listaAnagrafiche"].size()==0) {
            //Ricerco per codice Fiscale
            xmlRet= anagrafica.RicercaPerCodiceFiscale(cognomeCodFiscale);
            mapAnagrafiche = parseXml(xmlRet)
        }

        return mapAnagrafiche
    }

    private HashMap<String,String> parseXml(String xml) {
        def xmlObject = new XmlSlurper().parseText(xml)


        String esito= xmlObject.HEADER.ESITO.text()

        if (esito.equals(ESITO_OK)) {
            def soggettiObject= xmlObject.SOGGETTI.SOGGETTO

            List<HashMap<String,String>> listaAnagrafiche = []
            for (anagrafica in soggettiObject) {
                def anagraficaMap = [:]

                anagraficaMap.put("cognome",anagrafica.cognome.text())
                anagraficaMap.put("nome",anagrafica.nome.text())
                anagraficaMap.put("codiceFiscale",anagrafica.codiceFiscale.text())
                anagraficaMap.put("indirizzo",anagrafica.indirizzoResidenza.text())
                anagraficaMap.put("comune",anagrafica.comuneResidenza.text())
                anagraficaMap.put("cap",anagrafica.capResidenza.text())
                anagraficaMap.put("sigla",anagrafica.provinciaResidenza.text())

                listaAnagrafiche.add(anagraficaMap)
            }

            return [esito: ESITO_OK, listaAnagrafiche:  listaAnagrafiche ]
        }
        else {
            String msg = xmlObject.HEADER.MESSAGGIO.text()
            return [esito: ESITO_KO, errore: msg]
        }

    }
}
