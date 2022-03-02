package commons

import org.zkoss.bind.annotation.Command
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupDestinatariViewModel {

    // componenti
    Window self

    // dati
    List<String> destinatari
    String descrizioneTitolo

    @Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("destinatari") ArrayList<String> destinatari,  @ExecutionArgParam("descr") String descr) {

        this.self = w
        this.destinatari = destinatari
        this.descrizioneTitolo = descr
    }

    @Command
    void onAnnulla() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

}
