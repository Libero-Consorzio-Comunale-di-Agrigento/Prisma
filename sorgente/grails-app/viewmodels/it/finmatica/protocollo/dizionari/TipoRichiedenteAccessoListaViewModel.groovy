package it.finmatica.protocollo.dizionari

import it.finmatica.gorm.criteria.PagedResultList
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.afc.AfcAbstractGrid
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class TipoRichiedenteAccessoListaViewModel extends AfcAbstractGrid{

	// services
	@WireVariable private AccessoCivicoService accessoCivicoService

	// componenti
	Window self

	// dati
	List<TipoRichiedenteAccessoDTO> lista

    @Init init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
		caricaLista()
    }

	@NotifyChange(["lista", "totalSize"])
	private void caricaLista(String filterCondition = filtro) {
		PagedResultList listaP = TipoRichiedenteAccesso.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
			if(!visualizzaTutti) eq ("valido",true)
			if(filterCondition?:"" != "") ilike("descrizione","%${filterCondition}%")
			order("codice", "asc")
		}
		totalSize  = listaP.totalCount
		lista = listaP.toDTO()
	}

	@NotifyChange(["lista", "totalSize"])
	@Command void onPagina() {
		caricaLista()
	}

	@Command void onModifica (@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
		Long id = isNuovoRecord? null: selectedRecord.id
		Window w = Executions.createComponents ("/dizionari/tipoRichiedenteAccessoDettaglio.zul", self, [id: id])
		w.onClose {
			activePage 	= 0
			caricaLista()
			BindUtils.postNotifyChange(null, null, this, "lista")
			BindUtils.postNotifyChange(null, null, this, "totalSize")
			BindUtils.postNotifyChange(null, null, this, "activePage")
		}
		w.doModal()
	}

	@NotifyChange(["lista", "totalSize", "selectedRecord", "activePage"])
	@Command void onRefresh () {
		activePage = 0
		caricaLista()
		selectedRecord = null
	}

	@Command void onElimina () {
		Messagebox.show(Labels.getLabel("dizionario.cancellaRecordMessageBoxTesto"), Labels.getLabel("dizionario.cancellaRecordMessageBoxTitolo"),
			Messagebox.OK | Messagebox.CANCEL, Messagebox.EXCLAMATION,
			new org.zkoss.zk.ui.event.EventListener() {
				void onEvent(Event e){
					if(Messagebox.ON_OK.equals(e.getName())) {
						//se è l'ultimo della pagina di visualizzazione decremento di uno la activePage
						if(lista.size() == 1){
							TipoRichiedenteAccessoListaViewModel.this.activePage= TipoRichiedenteAccessoListaViewModel.this.activePage==0?0:TipoRichiedenteAccessoListaViewModel.this.activePage-1
						}
						accessoCivicoService.elimina(TipoRichiedenteAccessoListaViewModel.this.selectedRecord)
						TipoRichiedenteAccessoListaViewModel.this.selectedRecord = null
						TipoRichiedenteAccessoListaViewModel.this.caricaLista()
						BindUtils.postNotifyChange(null, null, TipoRichiedenteAccessoListaViewModel.this, "activePage")
						BindUtils.postNotifyChange(null, null, TipoRichiedenteAccessoListaViewModel.this, "lista")
						BindUtils.postNotifyChange(null, null, TipoRichiedenteAccessoListaViewModel.this, "totalSize")
						BindUtils.postNotifyChange(null, null, TipoRichiedenteAccessoListaViewModel.this, "selectedRecord")
					} else if(Messagebox.ON_CANCEL.equals(e.getName())) {
						//Cancel is clicked
					}
				}
			}
		)
	}

	@NotifyChange(["lista", "totalSize", "activePage","visualizzaTutti"])
	@Command void onVisualizzaTutti() {
		activePage = 0
		visualizzaTutti = !visualizzaTutti
		caricaLista()
	}

	@NotifyChange(["lista", "totalSize", "activePage"])
	@Command void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT)Event event) {
		activePage = 0
//		Passa l'evento generato su onChanging del textbox filtro e ricarica i dati
		if(event instanceof InputEvent){
			caricaLista(event.value)
		}
		else{
			caricaLista()
		}
	}

	@NotifyChange(["lista", "totalSize", "filtro", "activePage"])
	@Command void onCancelFiltro() {
		activePage = 0
		filtro = ""
		caricaLista()
	}
}