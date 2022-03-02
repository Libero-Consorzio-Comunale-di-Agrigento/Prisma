package it.finmatica.protocollo.dizionari
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gorm.criteria.PagedResultList
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
class ListaDistribuzioneListaViewModel extends AfcAbstractGrid{

	// services
	@WireVariable private ListaDistribuzioneService listaDistribuzioneService

	// componenti
	Window self

	// dati
	List<ListaDistribuzioneDTO> lista

    @Init void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
		caricaLista()
    }

	@NotifyChange(["lista", "totalSize"])
	private void caricaLista(String filterCondition = filtro) {
		PagedResultList listaP = listaDistribuzioneService.list(pageSize,activePage,filterCondition,visualizzaTutti)
		totalSize  = listaP.totalCount
		lista = listaP.toDTO()
		//ordinamento di string contenente numeri e char
		Collections.sort(lista, new Comparator<ListaDistribuzioneDTO>() {
			public int compare(ListaDistribuzioneDTO o1, ListaDistribuzioneDTO o2) {
				return extractInt(o1.codice) - extractInt(o2.codice);
			}

			int extractInt(String s) {
				String num = s.replaceAll("\\D", "");
				// return 0 if no digits found
				return num.isEmpty() ? 0 : Integer.parseInt(num);
			}
		});
	}

	@NotifyChange(["lista", "totalSize"])
	@Command void onPagina() {
		caricaLista()
	}

	@Command void onModifica (@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
		Long id = isNuovoRecord? null: selectedRecord.id
		Window w = Executions.createComponents ("/dizionari/listaDistribuzioneDettaglio.zul", self, [id: id, modificabile : true])
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
							ListaDistribuzioneListaViewModel.this.activePage= ListaDistribuzioneListaViewModel.this.activePage==0?0:ListaDistribuzioneListaViewModel.this.activePage-1
						}
						listaDistribuzioneService.elimina(ListaDistribuzioneListaViewModel.this.selectedRecord)
						ListaDistribuzioneListaViewModel.this.selectedRecord = null
						ListaDistribuzioneListaViewModel.this.caricaLista()
						BindUtils.postNotifyChange(null, null, ListaDistribuzioneListaViewModel.this, "activePage")
						BindUtils.postNotifyChange(null, null, ListaDistribuzioneListaViewModel.this, "lista")
						BindUtils.postNotifyChange(null, null, ListaDistribuzioneListaViewModel.this, "totalSize")
						BindUtils.postNotifyChange(null, null, ListaDistribuzioneListaViewModel.this, "selectedRecord")
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
        // Passa l'evento generato su onChanging del textbox filtro e ricarica i dati
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
