package it.finmatica.protocollo.scaricoipa

import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.gorm.criteria.PagedResultList
import org.hibernate.SessionFactory
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class CriteriScaricoIpaListaViewModel extends AfcAbstractGrid {

    // service
    @WireVariable
    private CriteriScaricoIpaService criteriScaricoIpaService

    @WireVariable
    SessionFactory sessionFactory

    // componenti
    Window self

    // dati
    ListModelList<CriteriScaricoIpaDTO> listaZul

    def lista = []

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w

        caricaListaCriteriScaricoIpa()
    }

    private void caricaListaCriteriScaricoIpa(String filterCondition = filtro) {
        if (visualizzaTutti) {
            sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        } else {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }
        PagedResultList lista = CriteriScaricoIpa.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
            if (filterCondition ?: "" != "") {
                or {
                    ilike("nomeCriterio", "%${filterCondition}%")
                }
            }
            order('nomeCriterio', 'asc')
        }

        totalSize = lista.totalCount
        listaZul = new ListModelList<CriteriScaricoIpaDTO>(lista.toDTO())

        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "listaZul")
    }

    @NotifyChange(["listaZul", "totalSize"])
    @Command
    void onPagina() {
        caricaListaCriteriScaricoIpa()
    }

    @Command
    void onModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
        Window w = Executions.createComponents("/scaricoipa/criteriScaricoIpaDettaglio.zul", self, [id: (isNuovoRecord ? -1 : selectedRecord.id)])
        w.onClose {
            caricaListaCriteriScaricoIpa()
            BindUtils.postNotifyChange(null, null, this, "listaZul")
            BindUtils.postNotifyChange(null, null, this, "totalSize")
        }
        w.doModal()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onRefresh() {
        filtro = null
        selectedRecord = null
        activePage = 0
        caricaListaCriteriScaricoIpa()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord"])
    @Command
    void onElimina() {
        Messagebox.show("Cancellando questo Criterio,\nverrà eliminato anche l'eventuale Job collegato.", "Conferma cancellazione Criterio Scarico IPA",
                Messagebox.OK | Messagebox.CANCEL, Messagebox.EXCLAMATION,
                new org.zkoss.zk.ui.event.EventListener() {
                    void onEvent(Event e) {
                        if (Messagebox.ON_OK.equals(e.getName())) {
                            criteriScaricoIpaService.elimina(selectedRecord)
                            selectedRecord = null
                            caricaListaCriteriScaricoIpa()
                        } else if (Messagebox.ON_CANCEL.equals(e.getName())) {
                            //Cancel is clicked
                        }
                    }
                }
        )
    }

    @NotifyChange(["visualizzaTutti", "listaZul", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onVisualizzaTutti() {
        visualizzaTutti = !visualizzaTutti
        selectedRecord = null
        activePage = 0
        caricaListaCriteriScaricoIpa()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        selectedRecord = null
        activePage = 0
        caricaListaCriteriScaricoIpa()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onCancelFiltro() {
        onRefresh()
    }
}