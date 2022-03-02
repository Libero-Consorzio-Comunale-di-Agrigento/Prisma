package it.finmatica.protocollo.ws.exception

class ClassificazioneWSException extends  GeneralExceptionWS {

    public ClassificazioneWSException(String msg) {
        super(msg)
    }
    public ClassificazioneWSException(int codice,String descrizione) {
        super(codice,descrizione)
    }

}
