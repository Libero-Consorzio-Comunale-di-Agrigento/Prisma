package it.finmatica.protocollo.integrazioni.iter

import it.finmatica.gestioneiter.configuratore.icone.IconaPulsante
import it.finmatica.gestioneiter.configuratore.icone.IconePulsantiSource

/**
 * In questa classe è possibile specificare le icone che sono utilizzabili dai pulsanti dei flussi.
 */
class ProtocolloIconeSource implements IconePulsantiSource {
    @Override
    List<IconaPulsante> getIconePulsanti() {
        return [new IconaPulsante("Ok", "/images/icon/action/16x16/ok.png"),
                new IconaPulsante("Annulla", "/images/icon/action/16x16/cancel.png"),
                new IconaPulsante("Elimina Documento", "/images/icon/action/16x16/doc_cancel.png"),
                new IconaPulsante("Salva", "/images/icon/action/16x16/save.png"),
                new IconaPulsante("Documento", "/images/icon/action/16x16/detail.png"),
                new IconaPulsante("Inoltra", "/images/icon/action/16x16/forward.png"),
                new IconaPulsante("Annulla Documento", "/images/icon/action/16x16/undo.png"),
                new IconaPulsante("Firma", "/images/icon/action/16x16/pen.png"),
                new IconaPulsante("Indietro", "/images/icon/action/16x16/back.png"),
                new IconaPulsante("Numeri", "/images/icon/action/16x16/number.png"),
                new IconaPulsante("Chiudi", "/images/icon/action/16x16/close.png")]
    }
}
