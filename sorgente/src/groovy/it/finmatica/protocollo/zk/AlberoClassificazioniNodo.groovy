package it.finmatica.protocollo.zk

import groovy.transform.CompileStatic
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.FiltroDataClassificazioni

@CompileStatic
interface AlberoClassificazioniNodo {

    /**
     * Indica se il nodo è stato "pienamente" caricato.
     * Il nodo infatti può essere "parzialmente" caricato se ne sono state caricate solo le unità figlie o solo i componenti.
     * Questa è una ottimizzazione per evitare di caricare dati quando non necessario.
     *
     * @return
     */
    boolean isCaricato()
    /**
     * Carica i nodi figli di questo nodo.
     *
     * @param caricaComponenti indica se caricare i componenti
     * @param caricaUnita indica se caricare le unità
     * @param ruoloDiscriminante indica il ruolo con cui discriminare un componente abilitato da uno non abilitato.
     */
    void caricaNodi()

    void setFiltro (String filtro)

    void setFiltroData (FiltroDataClassificazioni filtroData)

    List<? extends AlberoClassificazioniNodo> getNodi()

    ClassificazioneDTO getClassificazione()
    void setClassificazione(ClassificazioneDTO classificazioneDTO)

    int getIndex()

    AlberoClassificazioniNodo getPadre()
}