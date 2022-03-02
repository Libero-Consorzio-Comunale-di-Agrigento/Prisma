package it.finmatica.protocollo.ws.exception

class GeneralExceptionWS extends Exception {

    private int codice=-9999
    private String descrizione=""

    public GeneralExceptionWS(String msg) {
        super(msg)
        setDescrizione(msg)
    }
    public GeneralExceptionWS(int codice,String descrizione) {
        super(codice + " - " + descrizione)
        setCodice(codice)
        setDescrizione(descrizione)
    }
    public int getCodice() {
        return codice
    }
    public void setCodice(int codice) {
        this.codice = codice
    }
    public String getDescrizione() {
        return descrizione
    }
    public void setDescrizione(String descrizione) {
        this.descrizione = descrizione
    }
}
