package it.finmatica.protocollo.documenti.exception

import groovy.transform.CompileStatic

@CompileStatic
class RegistroGiornalieroException extends Exception {
    RegistroGiornalieroException() {
    }

    RegistroGiornalieroException(String message) {
        super(message)
    }

    RegistroGiornalieroException(String message, Throwable cause) {
        super(message, cause)
    }

    RegistroGiornalieroException(Throwable cause) {
        super(cause)
    }

    RegistroGiornalieroException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace)
    }
}
