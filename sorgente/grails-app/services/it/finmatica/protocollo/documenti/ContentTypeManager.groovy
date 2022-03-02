package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic

@CompileStatic
interface ContentTypeManager {

    /**
     * restituisce il mime type corrispondente alla sequenza di byte inviata (che si suppone sia un file riconoscibile).
     * Può fornire un valore di default se l'individuazione fallisce.
     * @param data la sequenza di byte da analizzare
     * @return il mime type corrispondente
     */
    String guessContentType(byte[] data)
}