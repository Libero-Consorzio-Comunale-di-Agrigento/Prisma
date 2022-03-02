package it.finmatica.protocollo.ws.exception

class FascicoloWSException extends GeneralExceptionWS {

    public FascicoloWSException(String msg) {
        super(msg)
    }
    public FascicoloWSException(int codice,String descrizione) {
        super(codice,descrizione)
    }

}
