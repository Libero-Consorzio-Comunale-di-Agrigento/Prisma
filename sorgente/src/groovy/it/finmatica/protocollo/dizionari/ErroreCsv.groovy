package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import org.apache.commons.lang.StringUtils

@CompileStatic
class ErroreCsv {
    int riga
    String[] dati
    String errore


    @Override
    String toString() {
        return "[$riga] - [${StringUtils.join(dati.collect {"\"$it\""},',')}] - $errore"
    }
}
