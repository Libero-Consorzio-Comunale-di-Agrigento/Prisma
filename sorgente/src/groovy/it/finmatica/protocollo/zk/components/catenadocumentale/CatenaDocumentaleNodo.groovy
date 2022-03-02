package it.finmatica.protocollo.zk.components.catenadocumentale

import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.impl.XulElement

/**
 * Classe che rappresenta un nodo dell'albero nella Catena Documentale
 *
 */
@VariableResolver(DelegatingVariableResolver)
class CatenaDocumentaleNodo extends XulElement {

    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze

    //dati del protocollo
    ProtocolloDTO protocollo

    private boolean nodoCaricato = false

    List<CatenaDocumentaleNodo> nodi = []

    int livello

    Long idDocumentoCorrente

    boolean filtraSuccessivi

    boolean figli = true

    /**
     * Costruttore
     */
    CatenaDocumentaleNodo() {
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), null))
    }

    /**
     * Carica i nodi figli di questo nodo.
     *
     */
    void caricaNodi() {

        if (!nodoCaricato && protocollo != null) {
            nodoCaricato = true
            def protocollo = getProtocolliSuccessivi(protocollo.id, idDocumentoCorrente)
            nodi.addAll(creaNodi(livello + 1, protocollo))
        }
        nodoCaricato = true

    }

    /**
     * Indica se il nodo è stato caricato oppure no
     *
     * @return
     */
    boolean isCaricato() {
        return nodoCaricato
    }

    /**
     * Il metodo effettua una chiamata al Service per estrarre i protocolli successivi
     *
     * @param idProtocollo
     * @return
     */
    private List getProtocolliSuccessivi(Long idProtocollo, Long idDocumentoCorrente) {
        List<ProtocolloDTO> protocolliSuccessiviResult = new ArrayList<>()
        if(null!=idProtocollo) {
            List<Protocollo> protocolliSuccessivi = protocolloService.getProtocolliSuccessivi(idProtocollo)
            //indica se devo filtrare solo i sucessivvi relativi al documento corrente oppure no (nel caso di nodo radice e di figli dei successivi del documento corrente non filtro)
            if (filtraSuccessivi) {
                for (Protocollo protocolloSuccessivo : protocolliSuccessivi) {
                    if (protocolloSuccessivo.getId().equals(idDocumentoCorrente)) {
                        verificaCompetenzeERiservato(protocolloSuccessivo, protocolliSuccessiviResult)
                    }
                }
            } else {
                for (Protocollo protocolloSuccessivo : protocolliSuccessivi) {
                    verificaCompetenzeERiservato(protocolloSuccessivo, protocolliSuccessiviResult)
                }

            }
        }
        //ordinamento per numero asc, anno desc e tipoRegistro asc
        protocolliSuccessiviResult = protocolliSuccessiviResult?.sort { protocollo1, protocollo2 -> protocollo1.numero <=> protocollo2.numero ?: protocollo2.anno <=>protocollo1.anno ?: protocollo1.tipoRegistro?.commento <=> protocollo2.tipoRegistro?.commento}
        return protocolliSuccessiviResult
    }

    /**
     * Verifica se un utente ha le competenze per la lettura e si puo' visualizzare i documenti riservati
     * In caso contrario setta l'oggetto con messaggio appropriato sul documento della lista di DTO passatagli come parametro
     *
     * @param protocolloSuccessivo
     * @param protocolliSuccessiviResult
     */
    private void verificaCompetenzeERiservato(Protocollo protocolloSuccessivo, ArrayList<ProtocolloDTO> protocolliSuccessiviResult) {

        ProtocolloDTO protocolloSuccessivoDto = protocolloSuccessivo.toDTO("tipoRegistro")
        //tengo i controlli separati qualora si voglia diversificare il messaggio
        if (null != protocolloSuccessivo) {
            if (!verificaCompetenze(protocolloSuccessivo)) {
                protocolloSuccessivoDto.oggetto = "Non si dispone dei diritti per visualizzare il documento"
            }
            if ((protocolloSuccessivo.riservato || protocolloSuccessivo.fascicolo?.riservato) && !verificaVisualizzaRiservato(protocolloSuccessivo)) {
                protocolloSuccessivoDto.oggetto = "Non si dispone dei diritti per visualizzare il documento"
            }
        }
        protocolliSuccessiviResult.add(protocolloSuccessivoDto)
    }

    /**
     * Verifica se l'utente ha le competenze di lettura sul documento
     *
     * @param protocolloSuccessivo
     */
    private boolean verificaCompetenze(Protocollo protocollo) {
        Map competenze = gestoreCompetenze.getCompetenze(protocollo)
           if (!competenze || !competenze?.lettura) {
               return false
           }
        return true
    }

    /**
     *  Verifica se l'utente ha il privilegio per vedere i doc riservati
     *
     * @param protocolloSuccessivo
     */
    private boolean verificaVisualizzaRiservato(Protocollo protocollo) {
        if (!gestoreCompetenze.utenteCorrenteVedeRiservato(protocollo)) {
           return false
        }
        return true
    }

    /**
     * Il metodo effettua una chiamata al Service per estrarre il protocollo precedente
     *
     * @param idProtocollo
     * @return
     */
    private ProtocolloDTO getProtocolloPrecedente(Long idProtocollo) {
        Protocollo protocolloPrecedente
        ProtocolloDTO protocolloPrecedenteDTO = null
        if(null!=idProtocollo) {
            protocolloPrecedente = protocolloService.getProtocolloPrecedente(idProtocollo)
        }
        if(null!=protocolloPrecedente) {
            protocolloPrecedenteDTO = protocolloPrecedente.toDTO("tipoRegistro")
            if (!verificaCompetenze(protocolloPrecedente)) {
                protocolloPrecedenteDTO.oggetto = "Non si dispone dei diritti per visualizzare il documento"
            }
            if(protocolloPrecedente.riservato || protocolloPrecedente.fascicolo?.riservato) {
                if(!verificaVisualizzaRiservato(protocolloPrecedente)) {
                    protocolloPrecedenteDTO.oggetto = "Non si dispone dei diritti per visualizzare il documento"
                }
            }
        }
        return protocolloPrecedenteDTO
    }


    /**
     *
     * Crea nodi a partire da una lista di protocolloDTO
     *
     * @param livello
     * @param listaProtocolli
     * @return
     */
    private static List<CatenaDocumentaleNodo> creaNodi(int livello, listaProtocolli) {
        List<CatenaDocumentaleNodo> nodi = []

        if (listaProtocolli?.size() > 0) {
            for (def row : listaProtocolli) {
                nodi << new CatenaDocumentaleNodo(protocollo: row
                                                 ,livello: livello)
            }
        }

        return nodi
    }

    /**
     *
     * Crea il nodo radice
     * Rappresenta l'inizio della catena, a partire da questo nodo estraggo i successivi
     *
     * @param livello
     * @param protocollo
     * @return
     */
    private CatenaDocumentaleNodo creaNodoRadice (int livello,  ProtocolloDTO protocollo) {

        CatenaDocumentaleNodo nodoRadice = new CatenaDocumentaleNodo()
        nodoRadice.idDocumentoCorrente = protocollo.id
        ProtocolloDTO protocolloPrecedente = getProtocolloPrecedente(protocollo.id)
        //Se ho un precedente questo sarà la radice altrimenti la radice sarà il protocollo corrente
        if(null!=protocolloPrecedente) {
            nodoRadice.setProtocollo(protocolloPrecedente)
            nodoRadice.setFiltraSuccessivi(true)
        } else {
            nodoRadice.setProtocollo(protocollo)
        }
        nodoRadice.setLivello(livello)

        return nodoRadice

    }


    /**
     * Carica la radice dell'albero
     *
     * @return la radice dell'albero da mostrare
     */
    static CatenaDocumentaleNodo getRoot(ProtocolloDTO protocollo, List<Long> radici = null) {

        CatenaDocumentaleNodo root = new CatenaDocumentaleNodo()

        root.idDocumentoCorrente = protocollo.id
        root.nodi.add(root.creaNodoRadice(0, protocollo))
        root.nodi*.caricaNodi()
        //Se non ho figli non visualizza nulla
        if (root.nodi?.get(0)?.nodi.size() <= 0) {
            root.nodi*.figli = false
        }

        return root

    }

}
