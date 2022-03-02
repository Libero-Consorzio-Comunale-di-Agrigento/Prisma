package it.finmatica.protocollo.titolario

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.zk.afc.AfcAbstractGrid
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
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class FascicoloListaViewModel extends AfcAbstractGrid {

    // service
    @WireVariable
    private FascicoloRepository fascicoloRepository
    @WireVariable
    private FascicoloService fascicoloService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    SessionFactory sessionFactory
    @WireVariable
    SpringSecurityService springSecurityService
    @WireVariable
    StrutturaOrganizzativaService strutturaOrganizzativaService

    // componenti
    Window self

    // dati
    ListModelList<FascicoloDTO> listaZul = []

    def lista = []

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        caricaListaFasicoli()
    }

    private void caricaListaFasicoli(String filterCondition = filtro) {
        List listaRet = []
        listaZul = []
        PagedResultList lista = Fascicolo.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
            if (filterCondition ?: "" != "") {
                or {
                    ilike("oggetto", "%${filterCondition}%")
                    ilike("annoNumero", "%${filterCondition}%")
                }
            }
            order('oggetto', 'asc')
        }

        totalSize = lista.totalCount
        listaRet = new ListModelList<FascicoloDTO>(lista.toDTO())

        for (item in listaRet) {

            Fascicolo fascicoloItem = Fascicolo.get(item.id)
            String annoNumero
            if (item.anno && item.numero) {
                annoNumero = item.annoNumero
            }

            listaZul << [numero               : annoNumero,
                         classificazione      : Classificazione.get(item.classificazione?.id).descrizione,
                         classificazioneCodice: Classificazione.get(item.classificazione?.id).codice,
                         oggetto              : item.oggetto,
                         unitaCompetenza      : fascicoloItem.getUnita().toString().toUpperCase(),
                         unitaCreazione       : fascicoloItem.getUnitaCreazione().toString().toUpperCase(),
                         annoArchiviazione    : item.annoArchiviazione,
                         stato                : item.statoFascicolo,
                         id                   : item.id]
        }

        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "listaZul")
    }

    @NotifyChange(["listaZul", "totalSize"])
    @Command
    void onPagina() {
        caricaListaFasicoli()
    }

    void onModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
    }

    @Command
    void onModifica() {

        FascicoloDTO fascicolo = Fascicolo.findById(selectedRecord?.id).toDTO()
        //if (!privilegioUtenteService.isCompetenzaModificaFascicolo(fascicolo)) {
        //    Clients.showNotification("Non è possibile modificare il fascicolo. Utente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
        //    return
        //}

        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: selectedRecord?.id, isNuovoRecord: false, standalone: false, titolario: null])
        w.onClose { event ->

            if (event.data) {
                onModificaNuovo(event.data["titolario"], event.data["duplica"])
            } else {
                caricaListaFasicoli()
                BindUtils.postNotifyChange(null, null, this, "listaZul")
                BindUtils.postNotifyChange(null, null, this, "totalSize")
            }
        }
        w.doModal()
    }

    @Command
    void onModificaNuovo(def titolario, boolean duplica) {
        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false, titolario: titolario, duplica: duplica])
        w.onClose { event ->
            if (event.data) {
                onModificaNuovo(event.data["titolario"], event.data["duplica"])
            } else {
                caricaListaFasicoli()
                BindUtils.postNotifyChange(null, null, this, "listaZul")
                BindUtils.postNotifyChange(null, null, this, "totalSize")
            }
        }
        w.doModal()
    }

    @Command
    void onAggiungi() {
        if (!privilegioUtenteService.isCreaFascicolo()) {
            Clients.showNotification("Non è possibile creare un fascicolo. Utente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false])
        w.onClose { event ->
            if (event.data) {
                onModificaNuovo(event.data["titolario"], event.data["duplica"])
            } else {
                caricaListaFasicoli()
                BindUtils.postNotifyChange(null, null, this, "listaZul")
                BindUtils.postNotifyChange(null, null, this, "totalSize")
            }
        }
        w.doModal()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onRefresh() {
        filtro = null
        selectedRecord = null
        activePage = 0
        caricaListaFasicoli()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord"])
    @Command
    void onAction() {
        Clients.showNotification("DA IMPLEMENTARE", Clients.NOTIFICATION_TYPE_INFO, null, "middle_center", 3000, true)
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onElimina() {
        String messaggioErrore = ""
        FascicoloDTO fascicolo = Fascicolo.findById(selectedRecord?.id).toDTO()
        if (!privilegioUtenteService.isCompetenzaEliminaFascicolo(fascicolo)) {
            Clients.showNotification("Non è possibile eliminare il fascicolo.\nUtente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        // non ha sottofascicoli
        if (fascicoloRepository.listSottoFascicoli(fascicolo?.id).size() > 0) {
            messaggioErrore = messaggioErrore + "Il fascicolo ha dei sottofascicoli. "
        }
        // è vuoto
        if (!fascicoloService.isVuoto(fascicolo)) {
            messaggioErrore = messaggioErrore + "Il fascicolo non è vuoto. "
        }
        // è ultimo
        if (!fascicoloService.isUltimo(fascicolo)) {
            messaggioErrore = messaggioErrore + "Il fascicolo non è l'ultimo. "
        }

        if (messaggioErrore.length() > 0) {
            Clients.showNotification("Non è possibile eliminare il fascicolo.\n" + messaggioErrore, Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        Messagebox.show(Labels.getLabel("fascicolo.cancellaRecordMessageBoxTesto"), Labels.getLabel("protocollo.cancellaRecordMessageBoxTitolo"),
                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                Fascicolo f = fascicolo.domainObject
                fascicoloService.elimina(f)
                onRefresh()
            }
        }
        onRefresh()
    }

    @NotifyChange(["visualizzaTutti", "listaZul", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onVisualizzaTutti() {
        visualizzaTutti = !visualizzaTutti
        selectedRecord = null
        activePage = 0
        caricaListaFasicoli()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage"])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        selectedRecord = null
        activePage = 0
        caricaListaFasicoli()
    }

    @NotifyChange(["listaZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onCancelFiltro() {
        onRefresh()
    }
}
