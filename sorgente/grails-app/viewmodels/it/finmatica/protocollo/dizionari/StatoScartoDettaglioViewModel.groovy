package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService

import org.apache.commons.lang.StringUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class StatoScartoDettaglioViewModel {

    // services
    @WireVariable
    private StatoScartoService statoScartoService
    @WireVariable
    GestioneDocumentiSpringSecurityService springSecurityService

    int pageSize = 10
    String codice
    Window selectedRecord
    StatoScartoDTO statoScartoDTO
    Window self

    @NotifyChange(["selectedRecord"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("codice") String codice) {
        this.self = w
        this.codice = codice

        caricaStatoScarto(codice)
    }

    private void caricaStatoScarto(String codice) {
        statoScartoDTO = StatoScarto.createCriteria().get {
            eq("codice", codice)
        }.toDTO()
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalva() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        statoScartoDTO = statoScartoService.salva(statoScartoDTO)

        Clients.showNotification("Stato Scarto salvato.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalvaChiudi() {
        onSalva()
        onChiudi()
    }

    @Command
    void onSettaValido() {
    }

    Collection<String> validaMaschera() {
        Collection<String> messaggi = []

        boolean dizProtocolloVisible = Utils.isUtenteAmministratore() || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_PROTOCOLLO.valore)
        if (!dizProtocolloVisible) {
            messaggi << "L'utente ${springSecurityService.principal.username} non puo' accedere a quest'area"
        }

        if (StringUtils.isEmpty(statoScartoDTO.descrizione)) {
            messaggi << "Descrizione Obbligatoria"
        }
        return messaggi
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}