package commons

import groovy.transform.CompileStatic
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class PopupTestoMessaggioViewModel {

    // componenti
    Window self

    String testo

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("testo") String testo) {
        this.self = w
        this.testo = testo
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
