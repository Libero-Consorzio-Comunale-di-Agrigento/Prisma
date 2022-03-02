package commons

import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupFiltriRicercaClassificazioniViewModel {

    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService

    def selectedRecord

    Window self

    String datePattern = 'dd/MM/yyyy'
    Date now = new Date()
    Date dataAperturaInizio
    Date dataAperturaFine
    Date dataCreazioneInizio
    Date dataCreazioneFine
    Date dataChiusuraInizio
    Date dataChiusuraFine
    String usoClassifica

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("dataAperturaInizio") dataAperturaInizio
              , @ExecutionArgParam("dataAperturaFine") dataAperturaFine
              , @ExecutionArgParam("dataCreazioneInizio") dataCreazioneInizio
              , @ExecutionArgParam("dataCreazioneFine") dataCreazioneFine
              , @ExecutionArgParam("dataChiusuraInizio") dataChiusuraInizio
              , @ExecutionArgParam("dataChiusuraFine") dataChiusuraFine
              , @ExecutionArgParam("usoClassifica") usoClassifica) {
        this.self = w

        this.dataAperturaInizio = dataAperturaInizio
        this.dataAperturaFine = dataAperturaFine
        this.dataCreazioneInizio = dataCreazioneInizio
        this.dataCreazioneFine = dataCreazioneFine
        this.dataChiusuraInizio = dataChiusuraInizio
        this.dataChiusuraFine = dataChiusuraFine
        this.usoClassifica = usoClassifica
    }

    @AfterCompose
    void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false)
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onRicerca() {
        def mapFilter = [:]
        mapFilter["dataAperturaInizio"] = dataAperturaInizio
        mapFilter["dataAperturaFine"] = dataAperturaFine
        mapFilter["dataCreazioneInizio"] = dataCreazioneInizio
        mapFilter["dataCreazioneFine"] = dataCreazioneFine
        mapFilter["dataChiusuraInizio"] = dataChiusuraInizio
        mapFilter["dataChiusuraFine"] = dataChiusuraFine
        mapFilter["usoClassifica"] = usoClassifica
        Events.postEvent(Events.ON_CLOSE, self, mapFilter)
    }

    @NotifyChange(["dataAperturaInizio", "dataAperturaFine", "dataCreazioneInizio", "dataCreazioneFine", "dataChiusuraInizio", "dataChiusuraFine", "usoClassifica"])
    @Command
    void onCancellaFiltri() {
        dataAperturaInizio = null
        dataAperturaFine = null
        dataCreazioneInizio = null
        dataCreazioneFine = null
        dataChiusuraInizio = null
        dataChiusuraFine = null
        usoClassifica = null
    }



}
