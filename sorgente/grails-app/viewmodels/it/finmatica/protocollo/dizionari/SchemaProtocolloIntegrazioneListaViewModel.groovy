package it.finmatica.protocollo.dizionari


import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloIntegrazioneService
import it.finmatica.zk.afc.AfcAbstractGrid
import org.hibernate.SessionFactory
import org.hibernate.criterion.CriteriaSpecification
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
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class SchemaProtocolloIntegrazioneListaViewModel extends AfcAbstractGrid {

    // service
    @WireVariable
    private SchemaProtocolloIntegrazioneService schemaProtocolloIntegrazioneService
    @WireVariable
    SessionFactory sessionFactory

    // componenti
    Window self

    // dati
    List<SchemaProtocolloIntegrazioneDTO> lista


    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w

        caricaLista()
    }

    @NotifyChange(["lista", "totalSize"])
    private void caricaLista(String filterCondition = filtro) {

        if (visualizzaTutti) {
            sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        }
        try {
            PagedResultList listaP = SchemaProtocolloIntegrazione.createCriteria().list(max: pageSize, offset: pageSize * activePage) {

                createAlias("schemaProtocollo", "scpr", CriteriaSpecification.LEFT_JOIN)
                if (!visualizzaTutti) eq("valido", true)
                if (filterCondition ?: "" != "") {
                    or {
                        ilike("scpr.descrizione", "%${filterCondition}%")
                        ilike("scpr.codice", "%${filterCondition}%")
                        ilike("applicativo", "%${filterCondition}%")
                    }
                }

                order("applicativo", "asc")
            }
            totalSize = listaP.totalCount
            lista = listaP.toDTO(["schemaProtocollo"])
        } finally {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }
    }

    @NotifyChange(["lista", "totalSize"])
    @Command
    void onPagina() {
        caricaLista()
    }

    @Command
    void onModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
        Long id = isNuovoRecord ? null : selectedRecord.id
        Window w = Executions.createComponents("/dizionari/schemaProtocolloIntegrazioneDettaglio.zul", self, [id: id])
        w.onClose {
            activePage = 0
            caricaLista()
            BindUtils.postNotifyChange(null, null, this, "lista")
            BindUtils.postNotifyChange(null, null, this, "totalSize")
            BindUtils.postNotifyChange(null, null, this, "activePage")
        }
        w.doModal()
    }

    @Command
    void onElimina() {
        Messagebox.show(Labels.getLabel("dizionario.cancellaRecordMessageBoxTesto"), Labels.getLabel("dizionario.cancellaRecordMessageBoxTitolo"),
                Messagebox.OK | Messagebox.CANCEL, Messagebox.EXCLAMATION,
                new org.zkoss.zk.ui.event.EventListener() {
                    void onEvent(Event e) {
                        if (Messagebox.ON_OK.equals(e.getName())) {
                            //se è l'ultimo della pagina di visualizzazione decremento di uno la activePage
                            if (lista.size() == 1) {
                                SchemaProtocolloIntegrazioneListaViewModel.this.activePage = SchemaProtocolloIntegrazioneListaViewModel.this.activePage == 0 ? 0 : SchemaProtocolloIntegrazioneListaViewModel.this.activePage - 1
                            }
                            schemaProtocolloIntegrazioneService.elimina(SchemaProtocolloIntegrazioneListaViewModel.this.selectedRecord)
                            SchemaProtocolloIntegrazioneListaViewModel.this.selectedRecord = null
                            SchemaProtocolloIntegrazioneListaViewModel.this.caricaLista()
                            BindUtils.postNotifyChange(null, null, SchemaProtocolloIntegrazioneListaViewModel.this, "activePage")
                            BindUtils.postNotifyChange(null, null, SchemaProtocolloIntegrazioneListaViewModel.this, "lista")
                            BindUtils.postNotifyChange(null, null, SchemaProtocolloIntegrazioneListaViewModel.this, "totalSize")
                            BindUtils.postNotifyChange(null, null, SchemaProtocolloIntegrazioneListaViewModel.this, "selectedRecord")
                        } else if (Messagebox.ON_CANCEL.equals(e.getName())) {
                            //Cancel is clicked
                        }
                    }
                }
        )
    }


    @NotifyChange(["lista", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onRefresh() {
        activePage = 0
        caricaLista()
        selectedRecord = null
    }

    @NotifyChange(["lista", "totalSize", "activePage", "visualizzaTutti"])
    @Command
    void onVisualizzaTutti() {
        activePage = 0
        visualizzaTutti = !visualizzaTutti
        caricaLista()
    }

    @NotifyChange(["lista", "totalSize", "activePage"])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        activePage = 0
//		Passa l'evento generato su onChanging del textbox filtro e ricarica i dati
        if (event instanceof InputEvent) {
            caricaLista(event.value)
        } else {
            caricaLista()
        }
    }

    @NotifyChange(["lista", "totalSize", "filtro", "activePage"])
    @Command
    void onCancelFiltro() {
        activePage = 0
        filtro = ""
        caricaLista()
    }
}
