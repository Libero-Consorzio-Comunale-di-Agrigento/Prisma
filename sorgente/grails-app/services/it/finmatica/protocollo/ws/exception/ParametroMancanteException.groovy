package it.finmatica.protocollo.ws.exception

class ParametroMancanteException extends  GeneralExceptionWS {

    public ParametroMancanteException(String msg) {
        super(msg)
    }
    public ParametroMancanteException(int codice,String descrizione) {
        super(codice,descrizione)
    }
}
