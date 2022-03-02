package commons

import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupNotificaEccezioneViewModel {

    @WireVariable private ProtocolloService protocolloService

    Window self

    ProtocolloDTO protocollo
    String motivazioneEccezione
    boolean protocollaConEccezione = false

    static Window apriPopup(ProtocolloDTO protocollo) {
        Window w = (Window) Executions.createComponents("/commons/popupNotificaEccezione.zul", null, [protocollo: protocollo])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") ProtocolloDTO protocollo) {
        this.self = w
        this.protocollo = protocollo
        protocollaConEccezione = ImpostazioniProtocollo.PROTOCOLLA_NOT_ECC?.valore?.equalsIgnoreCase('Y')
    }

    @Command
    void onChiudi() {
        chiudiPopup()
    }

    @Command
    void onSalva() {
        if (StringUtils.isEmpty(motivazioneEccezione)) {
            ClientsUtils.showError("Valorizzare il motivo della richiesta di Annullamento")
            return
        }

        protocolloService.inviaNotificaEccezione(protocollo.domainObject, motivazioneEccezione)

        protocollaConEccezione ? chiudiPopup() : chiudiPagina()
    }

    private void chiudiPopup() {
        // questo chiude solo il popup (lascia la maschera sotto aperta)
        self.onClose()
    }

    private void chiudiPagina() {
        // questo invece chiude anche la pagina principale
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
