package it.finmatica.protocollo.documenti.exception

import groovy.transform.CompileStatic

@CompileStatic
class RegistroGiornalieroCreazioneException extends RegistroGiornalieroException {
    RegistroGiornalieroCreazioneException() {
    }

    RegistroGiornalieroCreazioneException(String message) {
        super(message)
    }

    RegistroGiornalieroCreazioneException(String message, Throwable cause) {
        super(message, cause)
    }

    RegistroGiornalieroCreazioneException(Throwable cause) {
        super(cause)
    }

    RegistroGiornalieroCreazioneException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace)
    }
}
