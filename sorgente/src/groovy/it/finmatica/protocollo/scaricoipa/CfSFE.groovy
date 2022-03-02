package it.finmatica.protocollo.scaricoipa

class CfSFE {

    String chiave
    String codiceFiscaleSFE

    String getChiave() {
        return chiave
    }

    void setChiave(String chiave) {
        this.chiave = chiave
    }

    String getCodiceFiscaleSFE() {
        return codiceFiscaleSFE
    }

    void setCodiceFiscaleSFE(String codiceFiscaleSFE) {
        this.codiceFiscaleSFE = codiceFiscaleSFE
    }

    CfSFE(String key, String cfSFE) {
        chiave = key.toUpperCase().trim()
        codiceFiscaleSFE = cfSFE.toUpperCase().trim()
    }
}