package it.finmatica.protocollo.dizionari

import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.zk.afc.AfcAbstractGrid
import org.hibernate.SessionFactory
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
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class StatoScartoListaViewModel extends AfcAbstractGrid {


    @WireVariable
    SessionFactory sessionFactory

    // componenti
    Window self

    // dati
    ListModelList<StatoScartoDTO> listaZul = []

    def lista = []

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        caricaListaStatiScarto()
    }

    private void caricaListaStatiScarto(String filterCondition = filtro) {
        listaZul = []
        PagedResultList lista = StatoScarto.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
            if (filterCondition ?: "" != "") {
                or {
                    ilike("codice", "%${filterCondition}%")
                    ilike("descrizione", "%${filterCondition}%")
                    ilike("codiceGdm", "%${filterCondition}%")
                }
            }
            order('codice', 'asc')
        }

        totalSize = lista.totalCount
        listaZul = new ListModelList<StatoScartoDTO>(lista.toDTO())

        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "listaZul")
    }

    @NotifyChange(["listaZul", "totalSize"])
    @Command
    void onPagina() {
        caricaListaStatiScarto()
    }

     void onModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
    }

    @Command
    void onModifica() {
        Window w = Executions.createComponents("/dizionari/statoScartoDettaglio.zul", self, [codice: selectedRecord?.codice])
        w.onClose { event ->
                caricaListaStatiScarto()
                BindUtils.postNotifyChange(null, null, this, "listaZul")
                BindUtils.postNotifyChange(null, null, this, "totalSize")
        }
        w.doModal()
    }

    @Command
    void onAggiungi() {

    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onRefresh() {
        filtro = null
        selectedRecord = null
        activePage = 0
        caricaListaStatiScarto()
    }


    @NotifyChange(["listaZul", "totalSize", "selectedRecord"])
    @Command
    void onElimina() {

    }

    @NotifyChange(["visualizzaTutti", "listaZul", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onVisualizzaTutti() {
        visualizzaTutti = !visualizzaTutti
        selectedRecord = null
        activePage = 0
        caricaListaStatiScarto()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        selectedRecord = null
        activePage = 0
        caricaListaStatiScarto()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onCancelFiltro() {
        onRefresh()
    }
}