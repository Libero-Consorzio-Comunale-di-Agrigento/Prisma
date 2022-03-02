package it.finmatica.protocollo.scaricoipa

import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
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
class CriteriScaricoIpaJobViewModel extends DizionariDettaglioViewModel {

    @WireVariable
    CriteriScaricoIpaService criteriScaricoIpaService

    int idCriterio
    String numeroGiorniSel
    String oraSel
    String minutoSel

    List<String> oreList = new ArrayList<>()
    List<String> minutiList = new ArrayList<>()

    @NotifyChange(["numeroGiorniSel", "oraSel", "minutoSel"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") long id, @ExecutionArgParam("numeroGiorni") String numeroGiorni, @ExecutionArgParam("ora") String ora, @ExecutionArgParam("minuti") String minuti) {
        this.self = w

        for (int i = 0; i < 24; i++) {
            oreList.add(i < 10 ? "0" + i + " " : i + " ")
        }

        for (int i = 0; i < 60; i++) {
            minutiList.add(i < 10 ? "0" + i + " " : i + " ")
        }

        this.idCriterio = id
        this.numeroGiorniSel = numeroGiorni
        this.oraSel = ora + " "
        this.minutoSel = minuti + " "
    }

    @NotifyChange(["numeroGiorniSel", "oraSel", "minutoSel"])
    @Command
    void onSalva() {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        CriteriScaricoIpaDTO criterioTDO = criteriScaricoIpaService.getCriterio(idCriterio).toDTO()
        criterioTDO.numeroGiorni = numeroGiorniSel.toLong()
        criterioTDO.oraEsecuzione = oraSel.trim()
        criterioTDO.minutiEsecuzione = minutoSel.trim()
        criterioTDO.stringaCron = formatCronString()
        criteriScaricoIpaService.salva(criterioTDO)
        Events.postEvent(Events.ON_CLOSE, self, criterioTDO)
    }

    Collection<String> validaMaschera() {
        Collection<String> messaggi = super.validaMaschera()
        if (StringUtils.isEmpty(this.numeroGiorniSel)) {
            messaggi << "Numero Giorni obbligatori"
        }
        if (StringUtils.isEmpty(this.oraSel)) {
            messaggi << "Ora obbligatoria"
        }
        if (StringUtils.isEmpty(this.minutoSel)) {
            messaggi << "Minuto obbligatorio"
        }
        return messaggi
    }

    private String formatCronString() {
        String cronString = "0 " + minutoSel.trim() + " " + oraSel.trim() + " 1/" + numeroGiorniSel.toLong() + " * *"
        return cronString
    }

    void aggiornaMaschera() {
        BindUtils.postNotifyChange(null, null, this, "minutoSel")
        BindUtils.postNotifyChange(null, null, this, "oraSel")
    }
}
