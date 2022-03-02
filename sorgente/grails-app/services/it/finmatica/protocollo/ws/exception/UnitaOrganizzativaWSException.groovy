package it.finmatica.protocollo.ws.exception

class UnitaOrganizzativaWSException extends GeneralExceptionWS {

    public UnitaOrganizzativaWSException(String msg) {
        super(msg)
    }

    public UnitaOrganizzativaWSException(int codice, String descrizione) {
        super(codice, descrizione);
    }

}
