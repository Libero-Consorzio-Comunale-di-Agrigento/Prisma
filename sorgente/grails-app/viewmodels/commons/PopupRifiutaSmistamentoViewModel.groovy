package commons

import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.ISmistabileDTO
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupRifiutaSmistamentoViewModel {

    Window self

    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private SmistamentoService smistamentoService

    ISmistabileDTO smistabileDTO
    String testo

    boolean diretto = false

    static Window apriPopup(ISmistabileDTO smistabileDTO) {
        Window w = (Window) Executions.createComponents("/commons/popupRifiutaSmistamento.zul", null, [smistabileDTO: smistabileDTO])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("smistabileDTO") ISmistabileDTO smistabileDTO) {
        this.self = w
        this.smistabileDTO = smistabileDTO
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onInviaRifiuto() {
        if (StringUtils.isEmpty(testo)) {
            Clients.showNotification("Valorizzare il motivo del rifiuto", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
            return
        }

        smistamentoService.rifiuta(smistabileDTO.domainObject, springSecurityService.currentUser, testo)
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}