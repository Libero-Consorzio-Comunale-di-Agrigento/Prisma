package it.finmatica.protocollo.dizionari
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window
import it.finmatica.afc.AfcAbstractRecord

@VariableResolver(DelegatingVariableResolver)
class ListaDistribuzioneDettaglioViewModel extends AfcAbstractRecord {

	@WireVariable private SuccessHandler 			successHandler
	ListaDistribuzioneDTO 	selectedRecord
	List<ComponenteListaDistribuzioneDTO> componenti

	// services
	@WireVariable private ListaDistribuzioneService listaDistribuzioneService
	@WireVariable private CorrispondenteService	  corrispondenteService

	boolean modificabile = true

	@NotifyChange(["selectedRecord"])
    @Init void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") Long id, @ExecutionArgParam("modificabile") boolean modificabile) {

		this.self = w

		if (id != null) {
			selectedRecord = caricaElementoDto(id)
			aggiornaDatiCreazione(selectedRecord.utenteIns?.id, selectedRecord.dateCreated)
			aggiornaDatiModifica(selectedRecord.utenteUpd?.id, selectedRecord.lastUpdated)
		} else {
			selectedRecord = new ListaDistribuzioneDTO(valido:true)
		}

		this.modificabile = modificabile

    }

	private ListaDistribuzioneDTO caricaElementoDto(Long id){
		selectedRecord = ListaDistribuzione.get(id)?.toDTO(["componenti"])
		componenti = new ArrayList<ComponenteListaDistribuzioneDTO>()
		for(ComponenteListaDistribuzioneDTO c : selectedRecord.componenti){
			ComponenteListaDistribuzioneDTO comp = c
			comp.denominazione = c.denominazione

			if(!StringUtils.isEmpty(comp.codiceAmministrazione)){
				comp.recapito = listaDistribuzioneService.getRecapitoAmministrazione(comp.codiceAmministrazione, comp.aoo, comp.uo)
			}

			componenti.add(comp)
		}
		componenti = componenti?.sort {
			it.denominazione
			//it.tipoIndirizzo
		}

		BindUtils.postNotifyChange(null, null, this, "selectedRecord")
		BindUtils.postNotifyChange(null, null, this, "componenti")

		self.invalidate()
		return selectedRecord
	}

	@NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
	@Command void onAggiungiComponente() {

		Collection<String> messaggiValidazione = this.validaMaschera()
		if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
			Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
			return
		}

		Window w = Executions.createComponents ("/commons/popupSceltaComponenti.zul", self, null)
		w.onClose { event ->
			if (event.data != null) {
				ComponenteListaDistribuzioneDTO selectedComponente = event.data
				listaDistribuzioneService.aggiungiComponente(selectedRecord, selectedComponente)
				caricaElementoDto(selectedRecord.id)
			}
		}
		w.doModal()
	}

	@NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
	@Command void onRimuoviComponente(@BindingParam("componente") ComponenteListaDistribuzioneDTO componente) {

		Collection<String> messaggiValidazione = this.validaMaschera()
		if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
			Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
			return
		}

		Messagebox.show(Labels.getLabel("dizionario.cancellaRecordMessageBoxTesto"), Labels.getLabel("dizionario.cancellaRecordMessageBoxTitolo"),
				Messagebox.OK | Messagebox.CANCEL, Messagebox.EXCLAMATION,
				new org.zkoss.zk.ui.event.EventListener() {
					void onEvent(Event e){
						if(Messagebox.ON_OK.equals(e.getName())) {
							//se è l'ultimo della pagina di visualizzazione decremento di uno la activePage
//							if(lista.size() == 1){
//								ListaDistribuzioneDettaglioViewModel.this.activePage= ListaDistribuzioneDettaglioViewModel.this.activePage==0?0:TipoAccessoCivicoListaViewModel.this.activePage-1
//							}

							ListaDistribuzioneDettaglioViewModel.this.selectedRecord = listaDistribuzioneService.rimuoviComponente(ListaDistribuzioneDettaglioViewModel.this.selectedRecord, componente)
							caricaElementoDto(ListaDistribuzioneDettaglioViewModel.this.selectedRecord.id)

						} else if(Messagebox.ON_CANCEL.equals(e.getName())) {
							//Cancel is clicked
						}
					}
				}
		)
	}

	//Estendo i metodi abstract di AfcAbstractRecord
	@NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
	@Command void onSalva () {

		this.validaMaschera()
		selectedRecord = listaDistribuzioneService.salva(selectedRecord)
		caricaElementoDto(selectedRecord.id)
		aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
		aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
		successHandler.showMessage("Lista salvata")
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
						BindUtils.postNotifyChange(null, null, ListaDistribuzioneDettaglioViewModel.this, "selectedRecord")
						BindUtils.postNotifyChange(null, null, ListaDistribuzioneDettaglioViewModel.this, "datiCreazione")
						BindUtils.postNotifyChange(null, null, ListaDistribuzioneDettaglioViewModel.this, "datiModifica")
					} else if(Messagebox.ON_CANCEL.equals(e.getName())) {
						//Cancel is clicked
					}
				}
			}
		)
	}

    Collection<String> validaMaschera () {

		Collection<String> messaggi = []

        if (StringUtils.isEmpty(selectedRecord?.codice)) {
            messaggi << "Codice Obbligatorio."
        }

        if (StringUtils.isEmpty(selectedRecord?.descrizione)) {
            messaggi << "Descrizione Obbligatorio."
        }

        if (messaggi.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggi, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
        }

    }
}
