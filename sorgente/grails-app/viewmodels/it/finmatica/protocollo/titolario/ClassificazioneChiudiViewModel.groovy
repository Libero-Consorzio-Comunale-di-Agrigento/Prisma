package it.finmatica.protocollo.titolario

import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.zk.AlberoClassificazioni
import it.finmatica.protocollo.zk.AlberoClassificazioniNodo
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
class ClassificazioneChiudiViewModel extends DizionariDettaglioViewModel {

    @WireVariable
    SuccessHandler successHandler
    // services
    @WireVariable
    ClassificazioneService classificazioneService

    Set<ClassificazioneDTO> records
    Date now = new Date()
    Date al
    String datePattern = 'dd/MM/yyyy'

    ClassificazioneChiudiViewModel that

    Collection<AlberoClassificazioniNodo> nodi
    boolean mostraCodici = false
    List<Map> classificazioniSelezionate = []

    @NotifyChange(["selectedRecord"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("nodi") Collection<AlberoClassificazioniNodo> nodi) {
        this.self = w
        this.that = this
        Collection<Long> ids = nodi ? nodi.collect { it.classificazione.id } : []
        mostraCodici = ids.size() <= 20
        this.nodi = nodi
        if (ids != null) {
            records = classificazioneService.getAllById(ids, false, false)
            al = now + 1
        }
    }

    //Estendo i metodi abstract di AfcAbstractRecord
    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalva() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }
        for (row in records) {
            row.al = al
            classificazioneService.chiudiClassificazione(row)
        }

        Events.sendEvent(AlberoClassificazioni.EVT_SAVED, self.parent, null)
        successHandler.showMessage("Classificazioni chiuse")
        onChiudi()
    }

    Collection<String> validaMaschera() {

        def messaggi = super.validaMaschera()
        boolean dataFineOk = true
        if (al && (al - now) < 0) {
            dataFineOk = false
        }

        if (!dataFineOk) {
            messaggi << "La data fine è precedente ad oggi o ad una data fine esistente"
        }
        return messaggi
    }

    String getDescrizione(ClassificazioneDTO dto) {
        return "${dto ? "${dto.codice}  " : ''}"
    }
}
