package it.finmatica.protocollo.dizionari
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window
import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel

@VariableResolver(DelegatingVariableResolver)
class TipoAccessoCivicoDettaglioViewModel extends DizionariDettaglioViewModel {

    @WireVariable private SuccessHandler 			successHandler
	TipoAccessoCivicoDTO 	selectedRecord

	// services
	@WireVariable private AccessoCivicoService accessoCivicoService

	@NotifyChange(["selectedRecord"])
    @Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") Long id) {
		this.self = w


		if (id != null) {
			selectedRecord = caricaElemntoDto(id)
			aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
			aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
		} else {
			selectedRecord = new TipoAccessoCivicoDTO(valido:true)
		}
    }

	private TipoAccessoCivicoDTO caricaElemntoDto(Long id){
		return TipoAccessoCivico.get(id)?.toDTO()
	}

	//Estendo i metodi abstract di AfcAbstractRecord
	@NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
	@Command void onSalva () {

		Collection<String> messaggiValidazione = validaMaschera()
		if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
			Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
			return
		}

		selectedRecord = accessoCivicoService.salva(selectedRecord)
		aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
		aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
		successHandler.showMessage("Tipo di Accesso Civico salvato")
	}

	@NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
	@Command void onSalvaChiudi() {
		onSalva()
		onChiudi ()
	}

	@Command void onSettaValido(@BindingParam("valido") boolean valido) {
		Messagebox.show(Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTesto",[valido?"valido":"non valido"].toArray()), Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTitolo"),
			Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
			new org.zkoss.zk.ui.event.EventListener() {
				@NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
				void onEvent(Event e){
					if(Messagebox.ON_OK.equals(e.getName())) {
						selectedRecord.valido = valido
						onSalva()
						BindUtils.postNotifyChange(null, null, TipoAccessoCivicoDettaglioViewModel.this, "selectedRecord")
						BindUtils.postNotifyChange(null, null, TipoAccessoCivicoDettaglioViewModel.this, "datiCreazione")
						BindUtils.postNotifyChange(null, null, TipoAccessoCivicoDettaglioViewModel.this, "datiModifica")
					} else if(Messagebox.ON_CANCEL.equals(e.getName())) {
						//Cancel is clicked
					}
				}
			}
		)
	}
}
