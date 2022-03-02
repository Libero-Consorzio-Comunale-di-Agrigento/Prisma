package it.finmatica.protocollo.integrazioni.ricercadocumenti

/**
 * Created by DScandurra on 05/12/2017.
 */
class CampiRicerca {

    Map<String, Object> filtri
    Map<String, String> ordinamento
    int startFrom
    int maxResults

    CampiRicerca() {
        filtri = [:]
        ordinamento = [:]
        startFrom = 0
        maxResults = 30
    }
}