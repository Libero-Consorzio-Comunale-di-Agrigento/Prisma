package it.finmatica.protocollo.dizionari.impostazioni
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.protocollo.impostazioni.FunzioniAvanzateService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window
import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel

@VariableResolver(DelegatingVariableResolver)
class CambioUnitaDettaglioViewModel extends DizionariDettaglioViewModel{

	// Services
	@WireVariable private FunzioniAvanzateService funzioniAvanzateService

	// Componenti
	Window 				self

	// Dati
	So4UnitaPubbDTO		unitaSo4Vecchia
	List<So4UnitaPubbDTO> 	listaUnita
	So4UnitaPubbDTO     unitaSo4Nuova
	def 				listaDocumenti

	// Paginazione
	int pageSize 	= AfcAbstractGrid.PAGE_SIZE_DEFAULT
	int activePage 	= 0
	int	totalSize	= 0

	// Filtro in ricerca
	String 			filtro

    @Init void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("listaDocumenti") listaDocumenti, @ExecutionArgParam("unitaSo4Vecchia") So4UnitaPubbDTO unitaSo4Vecchia) {
		this.self 				= w
		this.unitaSo4Vecchia 	= unitaSo4Vecchia
		this.listaDocumenti 	= listaDocumenti
		caricaListaUnita()
    }

	@NotifyChange(["listaUnita", "totalSize"])
	private void caricaListaUnita() {
		List<So4UnitaPubb> listaUnitaD = So4UnitaPubb.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
			if (filtro != null){
				or{
					ilike("descrizione", "%" + filtro + "%")
					ilike("codice", "%" + filtro + "%")
				}
			}
			isNull("al")
			order("descrizione", "asc")
		}
		totalSize  = listaUnitaD.totalCount
		listaUnita = listaUnitaD?.toDTO()
	}

	@NotifyChange(["listaUnita", "totalSize"])
	@Command void onPagina() {
		caricaListaUnita()
	}

	@NotifyChange(["listaUnita", "totalSize", "unitaSo4Nuova", "activePage", "filtro"])
	@Command void onRefresh () {
		filtro = null
		unitaSo4Nuova = null
		activePage = 0
		caricaListaUnita()
	}

	@NotifyChange(["listaUnita", "totalSize", "unitaSo4Nuova", "activePage"])
	@Command void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT)Event event) {
		unitaSo4Nuova = null
		activePage = 0
		caricaListaUnita()
	}

	//////////////////////////////////////////
	//				SALVATAGGIO				//
	//////////////////////////////////////////

	@Command void onSalvaUnitaSelezionata () {

		Collection<String> messaggiValidazione = validaMaschera()
		if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
			Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
			return
		}

		Messagebox.show("Modificare i riferimenti all'unità \n\n $unitaSo4Vecchia.descrizione \n\n in riferimenti all'unità \n\n $unitaSo4Nuova.descrizione?", "Modifica validità",
			Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
			new org.zkoss.zk.ui.event.EventListener() {
				void onEvent(Event e) {
					if (Messagebox.ON_OK.equals(e.getName())) {
						funzioniAvanzateService.cambiaUnitaDocumenti (listaDocumenti, unitaSo4Vecchia?.domainObject, unitaSo4Nuova?.domainObject)
						onChiudi()
					}
				}
			}
		)
	}

	@Command void onChiudi () {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}
}
