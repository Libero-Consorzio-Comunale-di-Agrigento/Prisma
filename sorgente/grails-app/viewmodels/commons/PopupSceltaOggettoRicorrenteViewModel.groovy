package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.protocollo.dizionari.OggettoRicorrente
import it.finmatica.protocollo.dizionari.OggettoRicorrenteDTO
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaOggettoRicorrenteViewModel {

	// componenti
	Window self

	// dati
	List<OggettoRicorrenteDTO> listaOggettiRicorrenti
	OggettoRicorrenteDTO selectedRecord

	@Init init(@ContextParam(ContextType.COMPONENT) Window w){
		this.self = w
		caricaListaOggetti()
	}

	private void caricaListaOggetti () {
		listaOggettiRicorrenti = OggettoRicorrente.createCriteria().list(){
			eq("valido", true)
			order("oggetto", "asc")
		}.toDTO()
		BindUtils.postNotifyChange(null, null, this, "listaOggettiRicorrenti")
	}

	@Command onSelezionaOggettoRicorrente() {
		Events.postEvent(Events.ON_CLOSE, self, selectedRecord.oggetto)
	}

	@Command onAnnulla () {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}
}
