package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloIntegrazioneService
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class SchemaProtocolloIntegrazioneDettaglioViewModel extends DizionariDettaglioViewModel {

    @WireVariable
    private SuccessHandler successHandler
    SchemaProtocolloIntegrazioneDTO selectedRecord
    List<SchemaProtocolloDTO> listaSchemiProtocollo

    // services
    @WireVariable
    private SchemaProtocolloIntegrazioneService schemaProtocolloIntegrazioneService

    @NotifyChange(["selectedRecord"])
    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") Long id) {
        this.self = w
        listaSchemiProtocollo = SchemaProtocollo.findAllByValido(true, true, [sort: "descrizione", order: "asc"]).toDTO()

        if (id != null) {
            selectedRecord = caricaElemntoDto(id)
            aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
            aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
        } else {
            selectedRecord = new SchemaProtocolloIntegrazioneDTO(valido: true)
        }
    }

    private SchemaProtocolloIntegrazioneDTO caricaElemntoDto(Long id) {
        return SchemaProtocolloIntegrazione.get(id)?.toDTO(["schemaProtocollo"])
    }

    //Estendo i metodi abstract di AfcAbstractRecord
    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalva() {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        selectedRecord = schemaProtocolloIntegrazioneService.salva(selectedRecord)
        if (selectedRecord) {
            aggiornaDatiCreazione(selectedRecord?.utenteIns?.id, selectedRecord?.dateCreated)
            aggiornaDatiModifica(selectedRecord?.utenteUpd?.id, selectedRecord?.lastUpdated)
            successHandler.showMessage("Tipo di documento per integrazione salvato")
        }

    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalvaChiudi() {
        onSalva()
        onChiudi()
    }

    @Command
    void onSettaValido(@BindingParam("valido") boolean valido) {
        Messagebox.show(Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTesto", [valido ? "valido" : "non valido"].toArray()), Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTitolo"),
                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
                new org.zkoss.zk.ui.event.EventListener() {
                    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
                    void onEvent(Event e) {
                        if (Messagebox.ON_OK.equals(e.getName())) {
                            selectedRecord.valido = valido
                            onSalva()
                            BindUtils.postNotifyChange(null, null, SchemaProtocolloIntegrazioneDettaglioViewModel.this, "selectedRecord")
                            BindUtils.postNotifyChange(null, null, SchemaProtocolloIntegrazioneDettaglioViewModel.this, "datiCreazione")
                            BindUtils.postNotifyChange(null, null, SchemaProtocolloIntegrazioneDettaglioViewModel.this, "datiModifica")
                        } else if (Messagebox.ON_CANCEL.equals(e.getName())) {
                            //Cancel is clicked
                        }
                    }
                }
        )
    }
}
