package it.finmatica.protocollo.documenti.telematici

import groovy.transform.CompileStatic
import org.springframework.stereotype.Service

@CompileStatic
@Service
class UriStreamerImpl implements UriStreamer {

    @Override
    InputStream riferimentoStream(ProtocolloRiferimentoTelematico rif) {
        URL urlAllegato = new URL(rif.uri)
        urlAllegato.openStream()
    }
}
