package it.finmatica.protocollo.documenti

import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsternoDTO
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupDocumentiEsterniViewModel {

    Window self

    List<ProtocolloEsternoDTO> documentiEsterni

    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    private ProtocolloService protocolloService

    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("documentiEsterni") List<ProtocolloEsternoDTO> documentiEsterni) {
        this.self = w
        for (ProtocolloEsternoDTO protocolloEsternoDTO : documentiEsterni) {

            Protocollo prot = Protocollo.findByIdDocumentoEsterno(protocolloEsternoDTO.idDocumentoEsterno)
            if (prot == null) {
                prot = protocolloService.salvaDto(protocolloEsternoDTO, TipoProtocollo.findByCategoria(protocolloEsternoDTO.categoria))
            }

            Map competenzePrecedente = gestoreCompetenze.getCompetenze(prot)
            if (!competenzePrecedente || !competenzePrecedente?.lettura) {
                protocolloEsternoDTO.oggetto = "Non si dispone dei diritti per visualizzare il documento"
            }
        }
        this.documentiEsterni = documentiEsterni
    }

    @Command
    onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

}
