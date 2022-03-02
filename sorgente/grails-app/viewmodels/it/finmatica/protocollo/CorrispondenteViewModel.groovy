package it.finmatica.protocollo

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezioneDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.as4.anagrafica.As4Recapito
import it.finmatica.as4.dizionari.As4TipoRecapito
import it.finmatica.protocollo.corrispondenti.*
import org.apache.log4j.Logger
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class CorrispondenteViewModel {

	private static final Logger log = Logger.getLogger(CorrispondenteViewModel.class)

    Window 		self

	// services
	@WireVariable private CorrispondenteService corrispondenteService
	@WireVariable
	private PrivilegioUtenteService privilegioUtenteService
	@WireVariable
	private SpringSecurityService springSecurityService

	// dati
	CorrispondenteDTO corrispondente
	List<ModalitaInvioRicezioneDTO> mezziTrasmissivi
	def competenze
	boolean modificaRapporti
	boolean modificaAnagrafe
	boolean amministrazione

	@Init
	void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("corrispondente") CorrispondenteDTO corrispondente, @ExecutionArgParam("competenze") competenze, @ExecutionArgParam("modificaRapporti") modificaRapporti , @ExecutionArgParam("modificaAnagrafe") modificaAnagrafe, @ExecutionArgParam("amministrazione") amministrazione) {

		this.self = w
		Ad4Utente utente = springSecurityService.currentUser
		this.corrispondente 	= corrispondente
		this.mezziTrasmissivi 	= ModalitaInvioRicezione.list().toDTO()
		this.competenze 		= competenze
		this.modificaRapporti 	= modificaRapporti
		this.modificaAnagrafe	= modificaAnagrafe && privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.MODIFICA_ANAGRAFICA,utente)
		this.amministrazione    = amministrazione

		caricaDettagli()
	}

    private void caricaDettagli(){

		if(!modificaAnagrafe && corrispondente.id > 0){
			corrispondente = Corrispondente.get(corrispondente.id)?.toDTO(["indirizzi", "modalitaInvioRicezione","protocollo"])

			//controllo che il corrispondente è un'amministrazione (id:2)
			if(corrispondente?.tipoSoggetto?.id != new Long(2)){
				amministrazione = false
				return
			} else {
				amministrazione = true
			}
		}
    }

	@Command void onModificaSoggetto() {

		Window w = Executions.createComponents ("/as4/anagrafica/dettaglio.zul", self, [tipo: "modifica", codiceFiscalePartitaIvaObb: true, selectedSoggettoId: corrispondente.ni, filtriSoggetto: null, progettoChiamante: "AGS", storico: false])
		w.onClose { event ->
			if (event.data != null) {

				List<CorrispondenteDTO> corrispondenti = corrispondenteService.ricercaDestinatari(corrispondente.ni?.toString(), false)
				if(corrispondenti?.size() > 1){

					Window w1 = Executions.createComponents("/commons/popupSceltaRecapiti.zul", self, [corrispondenti: corrispondenti])
					w1.doModal()
					w1.onClose { event1 ->
						if (event1.data != null) {
							CorrispondenteDTO corrispondenteScelto = event1.data
							if (corrispondenteScelto){
								corrispondente = corrispondenteScelto
							}
							Events.postEvent(Events.ON_CLOSE, self, corrispondente)
						}
					}
				}
				else if(corrispondenti?.size() > 0){
					corrispondente = corrispondenti.get(0)
				}
				BindUtils.postNotifyChange(null, null, this, "corrispondente")
			}
		}
		w.doModal()
	}

	@Command onChiudi () {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}

	@Command onSalva () {

		if(modificaAnagrafe){
			Events.postEvent(Events.ON_CLOSE, self, corrispondente)
		}
		else{
			if(corrispondente.protocollo?.idDocumentoEsterno != null){
				corrispondenteService.salva(corrispondente.protocollo.domainObject, [corrispondente])
			}
			Events.postEvent(Events.ON_CLOSE, self, corrispondente)
		}
	}
}
