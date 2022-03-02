package it.finmatica.protocollo.dizionari
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.documenti.viste.BottoneNotifica
import it.finmatica.protocollo.documenti.viste.BottoneNotificaDTO
import it.finmatica.protocollo.documenti.viste.BottoneNotificaService
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Event
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class BottoneNotificaListaViewModel extends AfcAbstractGrid {

    // service
    @WireVariable private BottoneNotificaService  bottoneNotificaService
    @WireVariable private SuccessHandler          successHandler

    // componenti
    Window self

    // dati
    ListModelList<BottoneNotificaDTO> listaBottoneNotifica

    def lista = []

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w

        caricaListaBottoneNotifica()
    }

    private void caricaListaBottoneNotifica(String filterCondition = filtro) {

        PagedResultList lista = bottoneNotificaService.list(pageSize,activePage,filterCondition,visualizzaTutti)

        totalSize = lista.totalCount
        listaBottoneNotifica = new ListModelList<BottoneNotificaDTO>(lista.toDTO())

        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "listaBottoneNotifica")
    }

    /*
     * Implementazione dei metodi per AfcAbstractGrid
     */

    @NotifyChange(["listaBottoneNotifica", "totalSize"])
    @Command
    void onPagina() {
        caricaListaBottoneNotifica()
    }

    @Command
    void onModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
/*        Long idBottoneNotifica = isNuovoRecord? null: selectedRecord.id
        Window w = Executions.createComponents("/dizionari/schemaProtocolloDettaglio.zul", self, [id: (isNuovoRecord ? -1 : idSchemaProtocollo)])
        w.onClose {
            caricaListaBottoneNotifica()
            BindUtils.postNotifyChange(null, null, this, "listaBottoneNotifica")
            BindUtils.postNotifyChange(null, null, this, "totalSize")
        }
        w.doModal()*/
    }

    @Command void onModificaSequenza(@BindingParam("bottoneNotifica") BottoneNotificaDTO bottoneNotifica) {

        bottoneNotifica.domainObject.sequenza = bottoneNotifica.sequenza
        //bottoneNotifica = bottoneNotifica.domainObject.save()?.toDTO()
        //BindUtils.postNotifyChange(null, null, this, "listaBottoneNotifica")
        //successHandler.showMessage("Bottone modificato")
    }

    @Command void onModificaLabel(@BindingParam("bottoneNotifica") BottoneNotificaDTO bottoneNotifica) {

        bottoneNotifica.domainObject.label = bottoneNotifica.label
        //bottoneNotifica = bottoneNotifica.domainObject.save()?.toDTO()
        //BindUtils.postNotifyChange(null, null, this, "listaBottoneNotifica")
        //successHandler.showMessage("Bottone modificato")
    }

    @Command void onModificaTooltip(@BindingParam("bottoneNotifica") BottoneNotificaDTO bottoneNotifica) {

        bottoneNotifica.domainObject.tooltip = bottoneNotifica.tooltip
        //bottoneNotifica = bottoneNotifica.domainObject.save()?.toDTO()
        //BindUtils.postNotifyChange(null, null, this, "listaBottoneNotifica")
        //successHandler.showMessage("Bottone modificato")
    }

    @Command void onModificaIcona(@BindingParam("bottoneNotifica") BottoneNotificaDTO bottoneNotifica) {

        bottoneNotifica.domainObject.icona = bottoneNotifica.icona
        //bottoneNotifica = bottoneNotifica.domainObject.save()?.toDTO()
        //BindUtils.postNotifyChange(null, null, this, "listaBottoneNotifica")
        //successHandler.showMessage("Bottone modificato")
    }

    @NotifyChange(["listaBottoneNotifica", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onRefresh() {
        filtro = null
        selectedRecord = null
        activePage = 0
        caricaListaBottoneNotifica()
    }

    @NotifyChange(["listaBottoneNotifica", "totalSize", "selectedRecord"])
    @Command
    void onElimina() {
//        bottoneNotificaService.elimina(selectedRecord)
//        selectedRecord = null
//        caricaListaBottoneNotifica()
    }

    @NotifyChange(["visualizzaTutti", "listaBottoneNotifica", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onVisualizzaTutti() {
        visualizzaTutti = !visualizzaTutti
        activePage = 0
        caricaListaBottoneNotifica()
    }

    @NotifyChange(["listaBottoneNotifica", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        selectedRecord = null
        activePage = 0
        caricaListaBottoneNotifica()
    }

    @NotifyChange(["listaBottoneNotifica", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onCancelFiltro() {
        onRefresh()
    }

    @NotifyChange(["listaBottoneNotifica"])
    @Command void onSalva () {

        //boolean isNuovoSchemaProtocollo = !(selectedRecord.id < 0)
        //selectedRecord = bottoneNotificaService.salva(selectedRecord)
        for (BottoneNotificaDTO bottoneNotifica : listaBottoneNotifica) {
            bottoneNotificaService.salva(bottoneNotifica)
        }
        caricaListaBottoneNotifica()
        //aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
        //successHandler.showMessage("Bottoni notifica salvati")
    }
}
