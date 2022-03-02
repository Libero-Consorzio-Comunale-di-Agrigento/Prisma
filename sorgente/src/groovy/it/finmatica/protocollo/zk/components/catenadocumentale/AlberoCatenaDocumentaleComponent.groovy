package it.finmatica.protocollo.zk.components.catenadocumentale

import it.finmatica.protocollo.documenti.ProtocolloDTO
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import groovy.transform.CompileStatic
import org.zkoss.zul.Div

/**
 *
 * Componente che rappresenta l'albero della Catena Documentale
 *
 */
@CompileStatic
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation(['protocollo:@ZKBIND(ACCESS=load)','catenaDocumentale:@ZKBIND(ACCESS=load)' ])
class AlberoCatenaDocumentaleComponent extends Div {

    ProtocolloDTO protocollo
    AlberoCatenaDocumentale catenaDocumentale

    AlberoCatenaDocumentaleComponent() {
        Executions.createComponents("/components/catenaDocumentale.zul", this, null)
        Selectors.wireComponents(this, this, false)
        Selectors.wireEventListeners(this, this)
    }

    AlberoCatenaDocumentale getCatenadocumentale() {
        return catenaDocumentale
    }

    void setCatenadocumentale(AlberoCatenaDocumentale catenaDocumentale) {
        this.catenaDocumentale = catenaDocumentale
    }

    ProtocolloDTO getProtocollo() {
        return protocollo
    }

    void setProtocollo(ProtocolloDTO protocollo) {
        this.protocollo = protocollo
    }

}
