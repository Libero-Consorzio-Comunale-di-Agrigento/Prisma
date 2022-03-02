package it.finmatica.protocollo.dizionari

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
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class OggettoRicorrenteListaViewModel extends AfcAbstractGrid {

    // services
    @WireVariable
    private OggettoRicorrenteDTOService oggettoRicorrenteDTOService
    @WireVariable
    SessionFactory sessionFactory
    // componenti
    Window self

    // dati
    List<OggettoRicorrenteDTO> listaOggettoRicorrente

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        caricaListaOggettoRicorrente()
    }

    @NotifyChange(["listaOggettoRicorrente", "totalSize"])
    private void caricaListaOggettoRicorrente(String filterCondition = filtro) {
        if (visualizzaTutti) {
            sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        } else {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }

        PagedResultList lista = OggettoRicorrente.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
            if (filterCondition ?: "" != "") {
				ilike("oggetto", "%${filterCondition}%")
			}
            order("codice", "asc")
        }
        totalSize = lista.totalCount
        listaOggettoRicorrente = lista.toDTO()
        //ordinamento di string contenente numeri e char
        Collections.sort(listaOggettoRicorrente, new Comparator<OggettoRicorrenteDTO>() {
            public int compare(OggettoRicorrenteDTO o1, OggettoRicorrenteDTO o2) {
                return extractInt(o1.codice) - extractInt(o2.codice);
            }

            int extractInt(String s) {
                String num = s.replaceAll("\\D", "");
                // return 0 if no digits found
                return num.isEmpty() ? 0 : Integer.parseInt(num);
            }
        });
    }

    @NotifyChange(["listaOggettoRicorrente", "totalSize"])
    @Command
    void onPagina() {
        caricaListaOggettoRicorrente()
    }

    @Command
    void onModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
        Long idOggettoRicorrente = isNuovoRecord ? null : selectedRecord.id
        Window w = Executions.createComponents("/dizionari/oggettoRicorrenteDettaglio.zul", self, [id: idOggettoRicorrente])
        w.onClose {
            activePage = 0
            caricaListaOggettoRicorrente()
            BindUtils.postNotifyChange(null, null, this, "listaOggettoRicorrente")
            BindUtils.postNotifyChange(null, null, this, "totalSize")
            BindUtils.postNotifyChange(null, null, this, "activePage")
        }
        w.doModal()
    }

    @NotifyChange(["listaOggettoRicorrente", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onRefresh() {
        activePage = 0
        caricaListaOggettoRicorrente()
        selectedRecord = null
    }

    //@NotifyChange(["listaOggettoRicorrente", "totalSize", "selectedRecord"])
    @Command
    void onElimina() {
        Messagebox.show(Labels.getLabel("dizionario.cancellaRecordMessageBoxTesto"), Labels.getLabel("dizionario.cancellaRecordMessageBoxTitolo"),
                Messagebox.OK | Messagebox.CANCEL, Messagebox.EXCLAMATION,
                new org.zkoss.zk.ui.event.EventListener() {
                    public void onEvent(Event e) {
                        if (Messagebox.ON_OK.equals(e.getName())) {
                            //se è l'ultimo della pagina di visualizzazione decremento di uno la activePage
                            if (listaOggettoRicorrente.size() == 1) {
                                OggettoRicorrenteListaViewModel.this.activePage = OggettoRicorrenteListaViewModel.this.activePage == 0 ? 0 : OggettoRicorrenteListaViewModel.this.activePage - 1
                            }
                            oggettoRicorrenteDTOService.elimina(OggettoRicorrenteListaViewModel.this.selectedRecord)
                            OggettoRicorrenteListaViewModel.this.selectedRecord = null
                            OggettoRicorrenteListaViewModel.this.caricaListaOggettoRicorrente()
                            BindUtils.postNotifyChange(null, null, OggettoRicorrenteListaViewModel.this, "activePage")
                            BindUtils.postNotifyChange(null, null, OggettoRicorrenteListaViewModel.this, "listaOggettoRicorrente")
                            BindUtils.postNotifyChange(null, null, OggettoRicorrenteListaViewModel.this, "totalSize")
                            BindUtils.postNotifyChange(null, null, OggettoRicorrenteListaViewModel.this, "selectedRecord")
                        } else if (Messagebox.ON_CANCEL.equals(e.getName())) {
                            //Cancel is clicked
                        }
                    }
                }
        )
    }

    @NotifyChange(["listaOggettoRicorrente", "totalSize", "activePage", "visualizzaTutti"])
    @Command
    void onVisualizzaTutti() {
        activePage = 0
        visualizzaTutti = !visualizzaTutti
        caricaListaOggettoRicorrente()
    }

    @NotifyChange(["listaOggettoRicorrente", "totalSize", "activePage"])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        activePage = 0
//		Passa l'evento generato su onChanging del textbox filtro e ricarica i dati
        if (event instanceof InputEvent) {
            caricaListaOggettoRicorrente(event.value)
        } else {
            caricaListaOggettoRicorrente()
        }
    }

    @NotifyChange(["listaOggettoRicorrente", "totalSize", "filtro", "activePage"])
    @Command
    void onCancelFiltro() {
        activePage = 0
        filtro = ""
        caricaListaOggettoRicorrente()
    }
}
