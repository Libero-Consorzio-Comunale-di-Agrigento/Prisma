package it.finmatica.protocollo.zk

import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.dizionari.FiltroDataFascicoli

/**
 * Questa classe rappresenta un nodo nell'albero delle classificazioni
 * Fornisce inoltre diversi metodi per la costruzione e la ricerca di tale albero.
 *
 * Ogni nodo può rappresentare:
 *
 *
 *
 * Created by rcossu on 12/07/2018.
 */
class AlberoFascicoliNodoInMemoria implements AlberoFascicoliNodo {

    // dati della classificazione
    FascicoloDTO fascicolo

    List<AlberoFascicoliNodoInMemoria> nodi = []
    String filtro
    FiltroDataFascicoli filtroData
    AlberoFascicoliNodoInMemoria padre
    AlberoFascicoliNodoInMemoria self

    private boolean caricato = true
    int index

    AlberoFascicoliNodoInMemoria(FascicoloDTO fascicolo) {
        this.fascicolo = fascicolo
        self = this
    }

    /**
     * Indica se il nodo è stato "pienamente" caricato.
     * Il nodo infatti può essere "parzialmente" caricato se ne sono state caricate solo le unità figlie o solo i componenti.
     * Questa è una ottimizzazione per evitare di caricare dati quando non necessario.
     *
     * @return
     */
    @Override
    boolean isCaricato() {
        return caricato
    }

    /**
     * Carica i nodi figli di questo nodo.
     *
     * @param caricaComponenti indica se caricare i componenti
     * @param caricaUnita indica se caricare le unità
     * @param ruoloDiscriminante indica il ruolo con cui discriminare un componente abilitato da uno non abilitato.
     */
    @Override
    void caricaNodi() {
        caricato = true
    }

    @Override
    void setFiltro(String filtro) {
        this.filtro = filtro
        nodi.each { it.filtro = filtro }
    }

    @Override
    void setFiltroData(FiltroDataFascicoli filtroData) {
        this.filtroData = filtroData
        nodi.each { it.filtroData = filtroData }
    }

    @Override
    void setFascicolo(FascicoloDTO fascicoloDTO) {
    }
}
