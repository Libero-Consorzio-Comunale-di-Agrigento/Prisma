package it.finmatica.protocollo.scaricoipa

class DescrizioneTipologiaEnteAmministrazioni {

    String codiceAmministrazione
    String descrizioneAmministrazione
    String tipologiaEnte

    DescrizioneTipologiaEnteAmministrazioni(String codiceAmministrazione, String descrizioneAmministrazione, String tipologiaEnte) {
        codiceAmministrazione = codiceAmministrazione.toUpperCase().trim()
        descrizioneAmministrazione = descrizioneAmministrazione.toUpperCase().trim()
        tipologiaEnte = tipologiaEnte.toUpperCase().trim()
    }

}
