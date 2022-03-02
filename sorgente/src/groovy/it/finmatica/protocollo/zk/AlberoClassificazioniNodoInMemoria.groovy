package it.finmatica.protocollo.zk

import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.FiltroDataClassificazioni
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
class AlberoClassificazioniNodoInMemoria implements AlberoClassificazioniNodo {



    // dati della classificazione
    ClassificazioneDTO classificazione

    List<AlberoClassificazioniNodoInMemoria> nodi = []
    String filtro
    FiltroDataClassificazioni filtroData
    AlberoClassificazioniNodoInMemoria padre
    AlberoClassificazioniNodoInMemoria self

    private boolean caricato = true
    int index

    AlberoClassificazioniNodoInMemoria(ClassificazioneDTO classificazione) {
        this.classificazione = classificazione
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
    void setFiltro (String filtro) {
        this.filtro = filtro
        nodi.each {it.filtro = filtro}
    }

    @Override
    void setFiltroData (FiltroDataClassificazioni filtroData) {
        this.filtroData = filtroData
        nodi.each {it.filtroData = filtroData}
    }


}
