package it.finmatica.protocollo.integrazioni.ricercadocumenti

import org.springframework.core.Ordered
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

/**
 * Created by DScandurra on 05/12/2017.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
class NessunaRicercaAllegati implements RicercaAllegatiDocumentiEsterni {

    @Override
    boolean isAbilitato() {
        return true
    }

    @Override
    String getTitolo() {
        return "-- nessuno --"
    }

    @Override
    String getDescrizione() {
        return "nessuno"
    }

    @Override
    String getZulCampiRicerca() {
        return ""
    }

    @Override
    it.finmatica.gestionedocumenti.zk.PagedList<DocumentoEsterno> ricerca(CampiRicerca campiRicerca) {
        return new it.finmatica.gestionedocumenti.zk.PagedList<DocumentoEsterno>([], 0)
    }

    @Override
    CampiRicerca getCampiRicerca() {
        return new CampiRicerca()
    }
}

