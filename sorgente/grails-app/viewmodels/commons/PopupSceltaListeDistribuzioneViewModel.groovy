package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.dizionari.ListaDistribuzione
import it.finmatica.protocollo.dizionari.ListaDistribuzioneDTO
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaListeDistribuzioneViewModel {
	
	@WireVariable private CorrispondenteService  corrispondenteService

	List<ListaDistribuzioneDTO> selectedListeDistribuzioneDto
	List<ListaDistribuzioneDTO> listeDistribuzioneDto

	Window self

	@NotifyChange("listeDistribuzioneDto")
	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("search") String search) {

		this.self = w
	}

	@NotifyChange(["listeDistribuzioneDto"])
    @Command onCerca (@BindingParam("search") String search) {

		listeDistribuzioneDto = ListaDistribuzione.findAllByDescrizioneIlike("%"+search+"%")
        BindUtils.postNotifyChange(null, null, this, "listeDistribuzioneDto")
	}

	@Command apriListaDistribuzione (@BindingParam("lista") Long id, @BindingParam("modificabile") boolean modificabile) {
		ListaDistribuzioneDTO lista = ListaDistribuzione.get(id)?.toDTO()
		Window w = Executions.createComponents ("/dizionari/listaDistribuzioneDettaglio.zul", self, [id: id, modificabile: modificabile])
		w.onClose {

		}
		w.doModal()
	}

    @Command onSalva(){

		List<CorrispondenteDTO> corrispondenti = corrispondenteService.getComponentiListeDistribuzione(selectedListeDistribuzioneDto)
		Events.postEvent(Events.ON_CLOSE, self, corrispondenti)
    }

	@Command onChiudi() {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}
}
