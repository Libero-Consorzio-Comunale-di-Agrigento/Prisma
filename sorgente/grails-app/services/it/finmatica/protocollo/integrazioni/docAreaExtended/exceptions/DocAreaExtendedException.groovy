package it.finmatica.protocollo.integrazioni.docAreaExtended.exceptions

import groovy.transform.CompileStatic
import it.finmatica.protocollo.integrazioni.ws.dati.response.docAreaExtended.ResultStatus

@CompileStatic
class DocAreaExtendedException extends RuntimeException {
    ResultStatus status
    int errorNumber
    String message

    DocAreaExtendedException(int errorNumber, String message) {
        this.status = ResultStatus.KO
        this.errorNumber = errorNumber
        this.message = message
    }
}
