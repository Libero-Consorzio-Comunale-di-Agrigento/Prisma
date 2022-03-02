package it.finmatica.protocollo.zk.components.catenadocumentale

import it.finmatica.protocollo.documenti.ProtocolloDTO
import org.zkoss.zul.AbstractTreeModel
import org.zkoss.zul.ext.TreeSelectableModel

/**
 * Questa classe rappresenta l'albero della catena documentale
 *
 *
 */

class AlberoCatenaDocumentale extends AbstractTreeModel<CatenaDocumentaleNodo> implements TreeSelectableModel {

    AlberoCatenaDocumentale(ProtocolloDTO protocollo){
        super(CatenaDocumentaleNodo.getRoot(protocollo))
    }

    /**
     * Ritorna false se ha altri nodi figli.
     * Ritorna true in tutti gli altri casi
     */
    @Override
    boolean isLeaf (CatenaDocumentaleNodo nodo) {

        if (nodo == null) {
            return true
        }

        if (!nodo.caricato) {
            return false
        }

        if (nodo.nodi.size() > 0) {
            return false
        }

        return true
    }

    /**
     * Questa funzione ritorna il numero di nodi figli, inoltre carica gli eventuali figli del nodoPadre se questi non sono già stati caricati.
     *      *
     */
     @Override
    int getChildCount (CatenaDocumentaleNodo nodo) {
         if (!nodo.caricato ) {
             nodo.caricaNodi()
         }
        return nodo.nodi?.size()?:0
    }

    /**
     * Questa funzione ritorna il nodo figlio richiesto, inoltre carica gli eventuali figli del nodoPadre se questi non sono già stati caricati.
     *
     * @param nodoPadre
     * @param indiceFiglio
     * @return
     */
     @Override
    CatenaDocumentaleNodo getChild (CatenaDocumentaleNodo nodoPadre, int indiceFiglio) {
        if (!nodoPadre.caricato ) {
            nodoPadre.caricaNodi()
        }
        CatenaDocumentaleNodo child =  nodoPadre.getNodi()[indiceFiglio]
        return child
    }

}
