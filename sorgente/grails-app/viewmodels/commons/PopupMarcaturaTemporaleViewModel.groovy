package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.integrazioni.firma.MarcaturaTemporaleService
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupMarcaturaTemporaleViewModel {

    // servizi
    @WireVariable private MarcaturaTemporaleService marcaturaTemporaleService

    // componenti
    Window self

    // dati
    ProtocolloDTO protocollo
    List<FileDocumentoDTO> allegatiDisponibili
    List<FileDocumentoDTO> allegatiDaMarcare = []

    static Window apriPopup(Component component, ProtocolloDTO protocollo) {
        Window window = (Window) Executions.createComponents("/commons/popupMarcaturaTemporale.zul", component, [protocollo: protocollo])
        window.doModal()
        return window
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") ProtocolloDTO protocollo) {
        this.self = w
        this.protocollo = protocollo
        allegatiDisponibili = marcaturaTemporaleService.getElencoFileDaMarcare(protocollo.domainObject)
    }

    @Command
    void onMarcaAllegati() {
        for (FileDocumentoDTO fileDocumento : allegatiDaMarcare) {
            // ne faccio uno alla volta
            marcaturaTemporaleService.apponiMarcaTemporale(fileDocumento.domainObject)
        }

        ClientsUtils.showInfo("Marcatura Apposta")
        onChiudi()
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
