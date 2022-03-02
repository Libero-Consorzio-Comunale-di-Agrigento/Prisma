package it.finmatica.protocollo.dizionari.impostazioni
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.As4SoggettoCorrenteDTO
import it.finmatica.protocollo.impostazioni.FunzioniAvanzateService
import org.apache.commons.lang.StringUtils
import org.hibernate.FetchMode
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.event.OpenEvent
import org.zkoss.zk.ui.event.SelectEvent
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window
import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel

@VariableResolver(DelegatingVariableResolver)
class CambioUtenteDettaglioViewModel extends DizionariDettaglioViewModel{

	// services
	@WireVariable private FunzioniAvanzateService funzioniAvanzateService

	Window self

	def	listaOggetti
	def	tipoSoggetto
	String tipoDoc

	String filtroSoggetti
	String soggetto

	List<As4SoggettoCorrenteDTO> soggettiList
	As4SoggettoCorrenteDTO		 selectedSoggetto
	Ad4UtenteDTO 				 utentePrecedente

	int pageSize 	= 10
	int activePage 	= 0
	int totalSize	= 0

	@NotifyChange(["soggettiList"])
    @Init void init(@ContextParam(ContextType.COMPONENT) Window w
				, @ExecutionArgParam("listaOggetti") listaOggetti
				, @ExecutionArgParam("tipoDoc") String tipoDocumento
				, @ExecutionArgParam("tipoSoggetto") tipoSoggetto
				, @ExecutionArgParam("utentePrecedente") Ad4UtenteDTO utentePrec	) {
		this.self 				= w
		this.listaOggetti 		= listaOggetti
		this.tipoDoc 			= tipoDocumento
		this.tipoSoggetto 		= tipoSoggetto
		this.utentePrecedente 	= utentePrec
		soggettiList 			= loadSoggetti().toDTO()
    }

	//////////////////////////////////////////
	//				SOGGETTI				//
	//////////////////////////////////////////

	@NotifyChange(["soggettiList", "totalSize", "activePage"])
	@Command void onChangingSoggetto(@ContextParam(ContextType.TRIGGER_EVENT) InputEvent event) {

		// onChanging può scattare anche subito dopo l'apertura del popup
		if (event.getValue() != soggetto){
			selectedSoggetto = null
			activePage = 0
			filtroSoggetti = event.getValue()
			soggettiList = loadSoggetti().toDTO()
		}
	}

	@Command void onChangeSoggetto(@ContextParam(ContextType.TRIGGER_EVENT) InputEvent event) {
		if (filtroSoggetti != "" && selectedSoggetto == null){
			Messagebox.show("Soggetto non valido")
		}
	}

	@NotifyChange(["soggettiList", "totalSize", "activePage"])
	@Command void onOpenSoggetto(@ContextParam(ContextType.TRIGGER_EVENT) OpenEvent event) {
		if (event.open){
			activePage = 0
			soggettiList = loadSoggetti().toDTO()
		}
	}

	@NotifyChange(["soggettiList", "totalSize"])
	@Command void onPaginaSoggetto() {
		soggettiList = loadSoggetti().toDTO()
	}

	@NotifyChange(["selectedSoggetto", "soggetto"])
	@Command void onSelectSoggetto(@ContextParam(ContextType.TRIGGER_EVENT)SelectEvent event, @BindingParam("target")Component target) {
		// SOLO se ho selezionato un solo item
		if (event.getSelectedItems()?.size() == 1) {
			filtroSoggetti = ""
			selectedSoggetto = event.getSelectedItems().toArray()[0].value
			soggetto = (selectedSoggetto?.cognome?:"") + (selectedSoggetto?.nome?(" "+selectedSoggetto?.nome):"")
			target?.close()
		}
	}

	private PagedResultList loadSoggetti () {
		PagedResultList elencoSoggetti = As4SoggettoCorrente.createCriteria().list(max:pageSize, offset: pageSize*activePage) {
			or {
				ilike ("cognome", 		"%"+filtroSoggetti+"%")
				ilike ("nome", 			"%"+filtroSoggetti+"%")
				ilike ("denominazione", "%"+filtroSoggetti+"%")
			}

			isNotNull("utenteAd4")

			order ("cognome", "asc")
			order ("nome", 	  "asc")

			fetchMode("utenteAd4", FetchMode.JOIN)
		}
		totalSize = elencoSoggetti.totalCount
		return elencoSoggetti
	}

	//////////////////////////////////////////
	//				COMANDI					//
	//////////////////////////////////////////

	@Command void onChiudi () {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}

	@Command void onCambiaUtente () {

		funzioniAvanzateService.cambiaUtenteDocumenti(listaOggetti, utentePrecedente, selectedSoggetto.utenteAd4, tipoSoggetto.codice)
        Events.postEvent(Events.ON_CLOSE, self, null)
	}
}
