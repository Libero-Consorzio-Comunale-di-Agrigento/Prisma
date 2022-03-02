package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic

@CompileStatic
enum FiltroDataFascicoli {
    VIS_TUTTE('Tutte'), VIS_ATTIVE('Attive'), VIS_PASSATE('Passate'), VIS_FUTURE('Future')
    String label

    private FiltroDataFascicoli(String label) {
        this.label = label
    }
}