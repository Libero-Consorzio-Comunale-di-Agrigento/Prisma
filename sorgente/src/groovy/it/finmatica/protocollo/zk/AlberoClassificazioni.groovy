package it.finmatica.protocollo.zk

import groovy.transform.CompileStatic
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.dizionari.FiltroDataClassificazioni
import org.zkoss.zul.AbstractTreeModel
/**
 * Classe di data-model per la gestione dell'albero di so4.
 * Features:
 * - Ricerca per Unità / Componente
 * - Differenziazione delle unità (senza componenti, con componenti con un certo ruolo, senza componenti con un certo ruolo)
 * - Differenziazione dei componenti (con un certo ruolo, senza un certo ruolo)
 * - Componenti visibili o meno a seconda di un parametro
 *
 * Utilizzo:
 * In uno zul, definire un tree come segue:
 *   <tree model="@load(vm.alberoSo4)" height="100%" width="100%" vflex="1">
 <template name="model">
 <treeitem open="@load((each.livello lt vm.livelloApertura))" image="@load(c:cat('/images/icon/action/16x16/', each.icona))">
 <treerow>
 <treecell label="@load(each.denominazione)" />
 <treecell label="@load(each.caricato)" />
 <treecell label="@load(each.unita)" />
 </treerow>
 </treeitem>
 </template>
 </tree>
 * La parte riguardante il livelloApertura è necessaria per determinare a quale profondità mostrare l'albero in fase di primo caricamento.
 * È necessario fare in questo modo siccome ZK visiterà ogni nodo ritornato dal data-model forzando il caricamento dei nodi anche di livello più profondo. Spostando la gestione della visibilità nel viewmodel
 * si aggira questo problema.
 *
 * Il componente <tree> di zk, richiamerà i metodi di questa classe in questo ordine per ogni nodo:
 * - isLeaf
 * - getChildCount
 * - getChild
 *
 * Quindi bisogna predisporre il caricamento di ulteriori figli in alcuni di questi metodi.
 *
 * Created by esasdelli on 29/03/2017.
 */
@CompileStatic
class AlberoClassificazioni extends AbstractTreeModel<AlberoClassificazioniNodo> {
    public static final String EVT_SAVED = 'onSaved'
    String filtroRicerca = null
    Date dataValiditaTitolario = null
    FiltroDataClassificazioni filtroData = null
    AlberoClassificazioniNodo root

    ClassificazioneService classificazioneService


    /**
     * Costruisce un albero di classificazioni
     *
     * @param filtroRicerca
     */
    AlberoClassificazioni(String filtroRicerca, AlberoClassificazioniNodo root) {
        super(root)
        this.multiple = true
        this.root = root
        this.filtroRicerca = filtroRicerca
    }

    AlberoClassificazioni(ClassificazioneService classificazioneService, String filtroRicerca, FiltroDataClassificazioni filtroData, Date dataValiditaTitolario, Date dataAperturaInizio, Date dataAperturaFine, Date dataCreazioneInizio, Date dataCreazioneFine, Date dataChiusuraInizio, Date dataChiusuraFine, String codiceClassifica, String descrizioneClassifica, String usoClassifica, boolean daRicerca) {
        this(filtroRicerca,new AlberoClassificazioniNodoInMemoria(new ClassificazioneDTO()))
        this.classificazioneService = classificazioneService
        this.filtroData = filtroData
        if (!dataValiditaTitolario) {
            dataValiditaTitolario= new Date()
        }
        List<ClassificazioneDTO> classificazioni = classificazioneService.list(Integer.MAX_VALUE,0,false,this.filtroRicerca,false,filtroData,dataValiditaTitolario,dataAperturaInizio,dataAperturaFine,dataCreazioneInizio,dataCreazioneFine,dataChiusuraInizio,dataChiusuraFine,codiceClassifica,descrizioneClassifica,usoClassifica,daRicerca).value
        Map<Long, AlberoClassificazioniNodo> cache = [:]
        boolean filtrato = true
        while(filtrato && classificazioni) {
            filtrato = false
            Iterator<ClassificazioneDTO> iter = classificazioni.iterator()
            while(iter.hasNext()) {
                ClassificazioneDTO classificazione = iter.next()
                AlberoClassificazioniNodo padre = null

                if(classificazione.progressivoPadre == null) {
                    padre = root as AlberoClassificazioniNodo
                } else {
                    padre = cache[classificazione.progressivoPadre]
                }

                AlberoClassificazioniNodo classifNodo = cache[classificazione.progressivo]
                boolean giaInserita = classifNodo

                if(!giaInserita) {
                    classifNodo = new AlberoClassificazioniNodoInMemoria(classificazione)
                    cache[classificazione.progressivo] = classifNodo
                }
                /*else {
                    ClassificazioneDTO precedente = classifNodo.classificazione
                    if(isSuccessiva(classificazione,precedente)) {
                        // aggiorna il record con una versione più recente
                        classifNodo.classificazione = classificazione
                    }
                }*/
                if(padre) {
                    //if(!giaInserita) {
                        padre.nodi.add(classifNodo)
                   // }
                    iter.remove()
                    filtrato = true
                }
            }
        }
        for(classificazione in classificazioni) {
            // recupero eventuali classificazioni che siano rimaste "orfane" perché il padre è stato filtrato via...
            root.nodi.add(new AlberoClassificazioniNodoInMemoria(classificazione))
        }

    }

    private boolean isSuccessiva(ClassificazioneDTO attuale, ClassificazioneDTO precedente) {
        if(precedente.al == null) {
            return false
        }
        if(attuale.al == null) {
            return true
        }
        return (attuale.al - precedente.al) > 0
    }

    /**
     * Ritorna false se il nodo non è già stato caricato oppure se il nodo è di tipo "COMPONENTI" (quindi il nodo radice dei componenti) oppure se ha altri nodi figli.
     * Ritorna true in tutti gli altri casi
     */
    @Override
    boolean isLeaf(AlberoClassificazioniNodo nodo) {

        // in fase di reload dell'albero, succede che zk passi null a questa funzione. In tal caso, ritorno true per evitare un NullPointerException.
        if (nodo == null) {
            return true
        }

        // ritorno false perché siccome non ho ancora ultimato di caricare il nodo, non posso sapere se questo avrà figli o no,
        // quindi per "sicurezza" dico che ha figli così che possa comparire la freccia di espansione del nodo
        if (!nodo.caricato) {
            return false
        }

        if (nodo.nodi) {
            return false
        }

        return true
    }

    /**
     * Questa funzione ritorna il numero di nodi figli, inoltre carica gli eventuali figli del nodoPadre se questi non sono già stati caricati.
     */
    @Override
    int getChildCount(AlberoClassificazioniNodo nodo) {
        caricaNodo(nodo)
        return nodo.nodi?.size() ?: 0
    }

    /**
     * Questa funzione ritorna il nodo figlio richiesto, inoltre carica gli eventuali figli del nodoPadre se questi non sono già stati caricati.
     *
     * @param nodoPadre
     * @param indiceFiglio
     * @return
     */
    @Override
    AlberoClassificazioniNodo getChild(AlberoClassificazioniNodo nodoPadre, int indiceFiglio) {
        caricaNodo(nodoPadre)
        AlberoClassificazioniNodo child = nodoPadre.nodi[indiceFiglio]
        return child
    }

    void setFiltroRicerca(String filtroRicerca) {
        this.filtroRicerca = filtroRicerca
        root.filtro = filtroRicerca
    }

    void setFiltroData(FiltroDataClassificazioni filtroData) {
        this.filtroData = filtroData
        root.filtroData = filtroData
    }

    private void caricaNodo(AlberoClassificazioniNodo nodo) {
        if (!nodo.caricato) {
            nodo.caricaNodi()
        }
    }
}
