package it.finmatica.protocollo.integrazioni.ricercadocumenti

/**
 * Descrive le operazioni necessarie per effettuare una ricerca di allegati associati ai documenti su altri documentali
 * per poter poi effettuare inserimento dei file allegati.
 *
 * Created by dscandurra on 05/12/2017.
 */
interface RicercaAllegatiDocumentiEsterni {

    boolean isAbilitato()

    String getTitolo()

    String getDescrizione()

    String getZulCampiRicerca()

    it.finmatica.gestionedocumenti.zk.PagedList<AllegatoEsterno> ricerca(CampiRicerca campiRicerca)

    CampiRicerca getCampiRicerca()
}