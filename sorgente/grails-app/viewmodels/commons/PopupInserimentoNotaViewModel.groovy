package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupInserimentoNotaViewModel {

	Window self
	String nota
	boolean modifica
	boolean valorizzato

	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("nota") String nota, @ExecutionArgParam("modifica") Boolean modifica) {
		this.self = w
		this.modifica = modifica
		this.nota = nota
		// tengo traccia se all'orgine era valorizzato
		this.valorizzato = nota
	}

	@Command onChiudi () {
		Events.postEvent(Events.ON_CLOSE, self, valorizzato ? nota : null)
	}

	@Command onInserisci () {
		// setto valorizzato true se la nota contiene qualcosa
		valorizzato = nota
		Events.postEvent(Events.ON_CLOSE, self, nota)
	}

}
