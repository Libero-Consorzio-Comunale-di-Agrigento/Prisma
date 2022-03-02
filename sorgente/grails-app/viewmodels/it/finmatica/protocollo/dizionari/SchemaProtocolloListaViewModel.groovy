package it.finmatica.protocollo.dizionari

import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class SchemaProtocolloListaViewModel extends AfcAbstractGrid {

    // service
    @WireVariable
    SchemaProtocolloService schemaProtocolloService
    @WireVariable ProtocolloService protocolloService

    // componenti
    Window self

    // dati
    ListModelList<SchemaProtocolloDTO> listaSchemaProtocollo

    def lista = []

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w

        caricaListaSchemaProtocollo()
    }

    private void caricaListaSchemaProtocollo(String filterCondition = filtro) {

        PagedResultList lista = schemaProtocolloService.list(pageSize,activePage,filterCondition,visualizzaTutti)
        totalSize = lista.totalCount
        listaSchemaProtocollo = new ListModelList<SchemaProtocolloDTO>(lista.toDTO())

        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocollo")
    }

    /*
     * Implementazione dei metodi per AfcAbstractGrid
     */

    @NotifyChange(["listaSchemaProtocollo", "totalSize"])
    @Command
    void onPagina() {
        caricaListaSchemaProtocollo()
    }

    @Command
    void onModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
        Long idSchemaProtocollo = isNuovoRecord ? null : selectedRecord.id
        Window w = Executions.createComponents("/dizionari/schemaProtocolloDettaglio.zul", self, [id: (isNuovoRecord ? -1 : idSchemaProtocollo)])
        w.onClose {
            caricaListaSchemaProtocollo()
            BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocollo")
            BindUtils.postNotifyChange(null, null, this, "totalSize")
        }
        w.doModal()
    }

    @NotifyChange(["listaSchemaProtocollo", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onRefresh() {
        filtro = null
        selectedRecord = null
        activePage = 0
        caricaListaSchemaProtocollo()
    }

    @NotifyChange(["listaSchemaProtocollo", "totalSize", "selectedRecord"])
    @Command
    void onElimina() {
        Messagebox.show("Sei sicuro di voler eliminare il tipo documento: ${selectedRecord.descrizione} ?", "Attenzione", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                if(protocolloService.isSchemaProtocolloUsed(selectedRecord.id as Long)) {
                    Clients.showNotification("Tipo documento utilizzato; per disattivarlo vai nel dettaglio", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 5000, true)
                } else {
                    schemaProtocolloService.elimina(selectedRecord)
                    selectedRecord = null
                    caricaListaSchemaProtocollo()
                    Clients.showNotification("Tipo documento eliminato", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
                }
            }
        }
    }

    @NotifyChange(["visualizzaTutti", "listaSchemaProtocollo", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onVisualizzaTutti() {
        visualizzaTutti = !visualizzaTutti
        activePage = 0
        caricaListaSchemaProtocollo()
    }

    @NotifyChange(["listaSchemaProtocollo", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        selectedRecord = null
        activePage = 0
        caricaListaSchemaProtocollo()
    }

    @NotifyChange(["listaSchemaProtocollo", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onCancelFiltro() {
        onRefresh()
    }
}
