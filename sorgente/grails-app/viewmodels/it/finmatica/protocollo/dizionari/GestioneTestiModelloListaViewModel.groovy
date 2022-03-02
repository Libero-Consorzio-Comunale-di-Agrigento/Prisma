package it.finmatica.protocollo.dizionari

import it.finmatica.gestionetesti.GestioneTestiModelloDTOService
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.gestionetesti.reporter.GestioneTestiModelloDTO

import org.hibernate.FetchMode
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window


@VariableResolver(DelegatingVariableResolver)
class GestioneTestiModelloListaViewModel  extends AfcAbstractGrid{

	// services
	@WireVariable
	private GestioneTestiModelloDTOService gestioneTestiModelloDTOService

	// componenti
	Window self

	// dati
	List<GestioneTestiModelloDTO> 	listaGestioneTestiModello

    @Init void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
		caricaListaGestioneTestiModello()
    }

	@NotifyChange(["listaGestioneTestiModello", "totalSize"])
	private void caricaListaGestioneTestiModello(String filterCondition = filtro) {
		def lista = GestioneTestiModello.createCriteria().list() {
			projections{
				property("nome")
				property("descrizione")
				property("valido")
				property("tipoModello")
				property("version")
				property("id")
			}
			if(!visualizzaTutti) eq ("valido",true)
			if(filterCondition?:"" != "" ) {
				or{
					ilike("nome","%${filterCondition}%")
					ilike("descrizione","%${filterCondition}%")
				}
			}
			order ("nome", "asc")
			order ("descrizione","asc")
			maxResults(pageSize)
			firstResult(activePage*pageSize)
			fetchMode("tipoModello", FetchMode.JOIN)
		}
		totalSize  = GestioneTestiModello.createCriteria().get() {
			projections{
				rowCount()
			}
			if(!visualizzaTutti) eq ("valido",true)
			if(filterCondition?:"" != "" ) {
				or{
					ilike("nome","%${filterCondition}%")
					ilike("descrizione","%${filterCondition}%")
				}
			}
			order ("nome", "asc")
			order ("descrizione","asc")
		}
		List<GestioneTestiModelloDTO>	 listaDto = new ArrayList<GestioneTestiModelloDTO>()
		for(int i; i < lista.size(); i++){
			GestioneTestiModelloDTO elDto = new GestioneTestiModelloDTO()
			elDto.nome = lista[i][0]
			elDto.descrizione = lista[i][1]
			elDto.valido = lista[i][2]
			elDto.tipoModello = lista[i][3].toDTO()
			elDto.version = lista[i][4]
			elDto.id = lista[i][5]
			listaDto.add(elDto)
		}
		listaGestioneTestiModello = listaDto
	}

	@NotifyChange(["listaGestioneTestiModello", "totalSize"])
	@Command void onPagina() {
		caricaListaGestioneTestiModello()
	}


	@Command void onModifica (@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
		Long idGestioneTestiModello = isNuovoRecord? null: selectedRecord.id
		Window w = Executions.createComponents ("/dizionari/gestioneTestiModelloDettaglio.zul", self, [id: idGestioneTestiModello])
		w.onClose {
			activePage 	= 0
			caricaListaGestioneTestiModello()
			BindUtils.postNotifyChange(null, null, this, "listaGestioneTestiModello")
			BindUtils.postNotifyChange(null, null, this, "totalSize")
			BindUtils.postNotifyChange(null, null, this, "activePage")
		}
		w.doModal()
	}

	@NotifyChange(["listaGestioneTestiModello", "totalSize", "selectedRecord", "activePage"])
	@Command void onRefresh () {
		activePage = 0
		caricaListaGestioneTestiModello()
		selectedRecord = null
	}

	//@NotifyChange(["listaGestioneTestiModello", "totalSize", "selectedRecord"])
	@Command void onElimina () {
		Messagebox.show(Labels.getLabel("dizionario.cancellaRecordMessageBoxTesto"), Labels.getLabel("dizionario.cancellaRecordMessageBoxTitolo"),
			Messagebox.OK | Messagebox.CANCEL, Messagebox.EXCLAMATION,
			new org.zkoss.zk.ui.event.EventListener () {
				public void onEvent (Event e) {
					if (Messagebox.ON_OK.equals(e.getName())) {
						//se è l'ultimo della pagina di visualizzazione decremento di uno la activePage
						if (listaGestioneTestiModello.size() == 1) {
							GestioneTestiModelloListaViewModel.this.activePage= GestioneTestiModelloListaViewModel.this.activePage==0?0:GestioneTestiModelloListaViewModel.this.activePage-1
						}
						gestioneTestiModelloDTOService.elimina(GestioneTestiModelloListaViewModel.this.selectedRecord)
						GestioneTestiModelloListaViewModel.this.selectedRecord = null
						GestioneTestiModelloListaViewModel.this.caricaListaGestioneTestiModello()
						BindUtils.postNotifyChange(null, null, GestioneTestiModelloListaViewModel.this, "activePage")
						BindUtils.postNotifyChange(null, null, GestioneTestiModelloListaViewModel.this, "listaGestioneTestiModello")
						BindUtils.postNotifyChange(null, null, GestioneTestiModelloListaViewModel.this, "totalSize")
						BindUtils.postNotifyChange(null, null, GestioneTestiModelloListaViewModel.this, "selectedRecord")
					}
				}
			}
		)
	}

	@NotifyChange(["listaGestioneTestiModello", "totalSize", "activePage","visualizzaTutti"])
	@Command void onVisualizzaTutti() {
		activePage = 0
		visualizzaTutti = !visualizzaTutti
		caricaListaGestioneTestiModello()
	}

	@NotifyChange(["listaGestioneTestiModello", "totalSize", "activePage"])
	@Command void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT)Event event) {
		activePage = 0
		// Passa l'evento generato su onChanging del textbox filtro e ricarica i dati
		if (event instanceof InputEvent) {
			caricaListaGestioneTestiModello(event.value)
		} else {
			caricaListaGestioneTestiModello()
		}
	}

	@NotifyChange(["listaGestioneTestiModello", "totalSize", "filtro", "activePage"])
	@Command void onCancelFiltro() {
		activePage = 0
		filtro = ""
		caricaListaGestioneTestiModello()
	}
}
