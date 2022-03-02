package it.finmatica.protocollo.zk

import groovy.transform.CompileStatic
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.dizionari.FiltroDataFascicoli
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.titolario.FascicoloService
import org.zkoss.zul.AbstractTreeModel

@CompileStatic
class AlberoFascicoli extends AbstractTreeModel<AlberoFascicoliNodo> {
    public static final String EVT_SAVED = 'onSaved'
    String filtroRicerca = null
    FiltroDataFascicoli filtroData = null
    AlberoFascicoliNodo root

    ClassificazioneService classificazioneService
    PrivilegioUtenteService privilegioUtenteService
    FascicoloService fascicoloService

    FascicoloRepository fascicoloRepository

    /**
     * Costruisce un albero di classificazioni
     *
     * @param filtroRicerca
     */
    AlberoFascicoli(String filtroRicerca, AlberoFascicoliNodo root) {
        super(root)
        this.multiple = true
        this.root = root
        this.filtroRicerca = filtroRicerca
    }

    AlberoFascicoli(FascicoloService fascicoloService, PrivilegioUtenteService privilegioUtenteService, String filtroRicerca, FiltroDataFascicoli filtroData, Map<String, String> filtriRicerca, int pageSize, int activePage) {

        this(filtroRicerca, new AlberoFascicoliNodoInMemoria(new FascicoloDTO()))
        this.fascicoloService = fascicoloService
        this.privilegioUtenteService = privilegioUtenteService
        this.filtroData = filtroData
        List<FascicoloDTO> fascicoli = []
        if (filtriRicerca) {
            fascicoli = fascicoloService.list(pageSize, activePage, filtriRicerca).value
        }
        Map<Long, AlberoFascicoliNodo> cache = [:]
        boolean filtrato = true
        while (filtrato && fascicoli) {
            filtrato = false
            Iterator<FascicoloDTO> iter = fascicoli.iterator()
            while (iter.hasNext()) {
                FascicoloDTO fascicolo = iter.next()
                AlberoFascicoliNodo padre = null

                if (fascicolo.idFascicoloPadre == null) {
                    padre = root as AlberoFascicoliNodo
                } else {
                    padre = cache[fascicolo.idFascicoloPadre]
                }

                AlberoFascicoliNodo classifNodo = cache[fascicolo.id]
                boolean giaInserita = classifNodo

                if (!giaInserita) {
                    classifNodo = new AlberoFascicoliNodoInMemoria(fascicolo)
                    cache[fascicolo.id] = classifNodo
                }
                if (padre) {
                    //if (privilegioUtenteService.isCompetenzaVisualizzaFascicolo(classifNodo.fascicolo)) {
                    padre.nodi.add(classifNodo)
                    //}

                    iter.remove()
                    filtrato = true
                }
            }
        }

        for (fascicolo in fascicoli) {
            // recupero eventuali fascicoli che siano rimasti "orfani" perché il padre è stato filtrato via...
            if (privilegioUtenteService.isCompetenzaVisualizzaFascicolo(fascicolo?.domainObject)) {
                root.nodi.add(new AlberoFascicoliNodoInMemoria(fascicolo as FascicoloDTO) as AlberoFascicoliNodo)
            }
        }
    }

    /**
     * Ritorna false se il nodo non è già stato caricato oppure se il nodo è di tipo "COMPONENTI" (quindi il nodo radice dei componenti) oppure se ha altri nodi figli.
     * Ritorna true in tutti gli altri casi
     */
    @Override
    boolean isLeaf(AlberoFascicoliNodo nodo) {

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
    int getChildCount(AlberoFascicoliNodo nodo) {
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
    AlberoFascicoliNodo getChild(AlberoFascicoliNodo nodoPadre, int indiceFiglio) {
        caricaNodo(nodoPadre)
        AlberoFascicoliNodo child = nodoPadre.nodi[indiceFiglio]
        return child
    }

    void setFiltroRicerca(String filtroRicerca) {
        this.filtroRicerca = filtroRicerca
        root.filtro = filtroRicerca
    }

    void setFiltroData(FiltroDataFascicoli filtroData) {
        this.filtroData = filtroData as FiltroDataFascicoli
        root.filtroData = filtroData as FiltroDataFascicoli
    }

    private void caricaNodo(AlberoFascicoliNodo nodo) {
        if (!nodo.caricato) {
            nodo.caricaNodi()
        }
    }
}
