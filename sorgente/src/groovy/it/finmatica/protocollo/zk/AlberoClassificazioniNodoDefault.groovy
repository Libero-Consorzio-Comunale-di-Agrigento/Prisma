package it.finmatica.protocollo.zk

import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.titolario.ClassificazioneService
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
class AlberoClassificazioniNodoDefault implements AlberoClassificazioniNodo {

    ClassificazioneService classificazioneService

    // dati della classificazione
    ClassificazioneDTO classificazione

    List<AlberoClassificazioniNodoDefault> nodi = []
    String filtro
    FiltroDataClassificazioni filtroData
    AlberoClassificazioniNodoDefault padre
    AlberoClassificazioniNodoDefault self

    private boolean caricato = false
    int index

    AlberoClassificazioniNodoDefault(ClassificazioneDTO classificazione, ClassificazioneService classificazioneService) {
        this.classificazione = classificazione
        this.classificazioneService = classificazioneService
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
        nodi = classificazioneService.getFigli(classificazione.progressivo, filtro,filtroData).withIndex().collect {ClassificazioneDTO cl, int i ->
            def nuovo = new AlberoClassificazioniNodoDefault(cl,classificazioneService)
            nuovo.filtroData = filtroData
            nuovo.filtro = filtro
            nuovo.padre = self
            nuovo.index = i
            return nuovo
        }
        caricato = true
    }

    @Override
    void setFiltro (String filtro) {
        this.filtro = filtro
        reloadIfNeeded()
        nodi.each {it.filtro = filtro}
    }

    @Override
    void setFiltroData (FiltroDataClassificazioni filtroData) {
        this.filtroData = filtroData
        reloadIfNeeded()
        nodi.each {it.filtroData = filtroData}
    }

    private void reloadIfNeeded() {
        if (caricato) {
            // lo carico solo se già caricato, se no aspetto che ci pensi zk a chiamare il caricamento
            caricaNodi()
        }
    }


}
