package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.protocollo.corrispondenti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.dizionari.ComponenteListaDistribuzioneDTO
import it.finmatica.protocollo.dizionari.ListaDistribuzioneService
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaComponentiViewModel {
	
	@WireVariable private ListaDistribuzioneService listaDistribuzioneService

	ComponenteListaDistribuzioneDTO selectedComponente
	String search
	TipoSoggettoDTO selectedTipoSoggetto

	List<ComponenteListaDistribuzioneDTO> listaComponentiDto
	List<TipoSoggettoDTO> listaTipoSoggetto = new ArrayList<TipoSoggettoDTO>()

	Window self

	@NotifyChange("listaComponentiDto")
	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("search") String search) {

		this.self = w

        selectedTipoSoggetto = new TipoSoggettoDTO(descrizione: "Tutti")

		listaTipoSoggetto.add(TipoSoggetto.get(2)?.toDTO()) // Amministrazioni
		listaTipoSoggetto.add(TipoSoggetto.get(1)?.toDTO()) // Altri Soggetti
		listaTipoSoggetto.add(0,selectedTipoSoggetto)
	
	}

	@NotifyChange(["listaComponentiDto"])
    @Command onCerca (@BindingParam("search") String search, @BindingParam("selectedItem") TipoSoggettoDTO selectedItem) {

        this.search = search
        if(selectedItem){
            selectedTipoSoggetto = selectedItem
        }

        if(search.length()<3){
			Clients.showNotification(StringUtils.join("Inserisci almeno 3 caratteri", "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 2000, true)
			return
		}

		boolean isQuery = true
		if(!selectedTipoSoggetto.id){
			isQuery = false
		}
		listaComponentiDto = listaDistribuzioneService.ricercaComponenti(search,
					isQuery, 
					null,
					null,
					null,
					null,
					null,
					null,
					selectedTipoSoggetto)

        BindUtils.postNotifyChange(null, null, this, "listaComponentiDto")
	}

    @Command onSalva(){
		Events.postEvent(Events.ON_CLOSE, self, selectedComponente)
    }

	@Command onChiudi() {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}
}
