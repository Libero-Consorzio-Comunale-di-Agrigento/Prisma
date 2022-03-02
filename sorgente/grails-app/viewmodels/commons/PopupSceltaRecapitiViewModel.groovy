package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaRecapitiViewModel {

	CorrispondenteDTO 		selectedCorrispondente
	List<CorrispondenteDTO> corrispondenti

	Window self

	@NotifyChange("corrispondenti")
	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("corrispondenti") List<CorrispondenteDTO> corrispondenti) {

		this.self = w
		this.corrispondenti = corrispondenti
	}


    @Command onSalva(){
		Events.postEvent(Events.ON_CLOSE, self, selectedCorrispondente)
    }

	@Command onChiudi() {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}
}
