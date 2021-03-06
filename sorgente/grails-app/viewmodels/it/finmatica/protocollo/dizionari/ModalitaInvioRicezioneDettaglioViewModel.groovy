package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenza
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenzaDTO
import it.finmatica.protocollo.dizionari.TipoSpedizione
import it.finmatica.protocollo.dizionari.TipoSpedizioneDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import org.apache.commons.lang.StringUtils
import org.hibernate.FetchMode
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
class ModalitaInvioRicezioneDettaglioViewModel extends DizionariDettaglioViewModel {

    // services
    @WireVariable
    private ModalitaInvioRicezioneService modalitaInvioRicezioneService

    // dati
    List<TipoDocumentoCompetenzaDTO> listaTipoDocumentoCompetenza
    List<TipoSpedizioneDTO> listaTipologie

    int pageSize = 10

    @NotifyChange(["selectedRecord"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") long id) {
        this.self = w

        listaTipologie = TipoSpedizione.list([sort: "descrizione", order: "asc"]).toDTO()
        listaTipologie.add(0, new TipoSpedizioneDTO(id: -1, codice: "", descrizione: "", valido: true))
        caricaModalitaInvioRicezione(id)

        if (id != -1) {
            aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
            aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
        }
    }

    private void caricaModalitaInvioRicezione(long id) {
        if (id != -1) {
            selectedRecord = ModalitaInvioRicezione.get(id)?.toDTO()
        } else {
            selectedRecord = new ModalitaInvioRicezioneDTO(id: -1, valido: true)
        }
    }

    private void caricaListaTipoDocumentoCompetenza() {
        List<TipoDocumentoCompetenza> lista = TipoDocumentoCompetenza.createCriteria().list {
            eq("tipoDocumento.id", selectedRecord.id)
            fetchMode("utenteAd4", FetchMode.JOIN)
            fetchMode("ruoloAd4", FetchMode.JOIN)
            fetchMode("unitaSo4", FetchMode.JOIN)
        }
        listaTipoDocumentoCompetenza = lista.toDTO()
        BindUtils.postNotifyChange(null, null, this, "listaTipoDocumentoCompetenza")
    }

    /*
     * Implementazione dei metodi per AfcAbstractRecord
     */

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalva() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        boolean isNuovaModalitaInvioRicezione = !(selectedRecord.id > 0)

        selectedRecord = modalitaInvioRicezioneService.salva(selectedRecord)

        if (isNuovaModalitaInvioRicezione) {
            caricaListaTipoDocumentoCompetenza()
        }

        Clients.showNotification("Modalit?? Invio Ricezione salvata.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
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
                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK.equals(e.getName())) {
                this.selectedRecord.valido = valido
                onSalva()
                BindUtils.postNotifyChange(null, null, this, "selectedRecord")
                BindUtils.postNotifyChange(null, null, this, "datiCreazione")
                BindUtils.postNotifyChange(null, null, this, "datiModifica")
            }
        }
    }

    Collection<String> validaMaschera() {
        Collection<String> messaggi = super.validaMaschera()
        if (StringUtils.isEmpty(selectedRecord.codice)) {
            messaggi << "Codice Obbligatorio"
        }
        if (StringUtils.isEmpty(selectedRecord.descrizione)) {
            messaggi << "Descrizione Obbligatoria"
        }
        if (selectedRecord.validoDal == null) {
            messaggi << "Valido Dal Obbligatorio"
        }
        return messaggi
    }
}
