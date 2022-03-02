package it.finmatica.protocollo.documenti.telematici

import groovy.transform.CompileStatic

@CompileStatic
interface UriStreamer {

    InputStream riferimentoStream(ProtocolloRiferimentoTelematico rif)
}