package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic

@CompileStatic
class ImportazioneCSVException extends Exception {
    List<ErroreCsv> errori
    ImportazioneCSVException(List<ErroreCsv> errori) {
        super()
        this.errori = errori
    }

    ImportazioneCSVException(String message) {
        super(message)
    }

    ImportazioneCSVException(String message, Throwable cause) {
        super(message, cause)
    }

    ImportazioneCSVException(Throwable cause) {
        super(cause)
    }

    ImportazioneCSVException(String message, Throwable cause, boolean enableSuppression,
                             boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace)
    }
}
