package it.finmatica.protocollo.titolario

import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.hibernate.SqlDateRevisionListener
import it.finmatica.protocollo.zk.AlberoClassificazioni
import it.finmatica.protocollo.zk.AlberoClassificazioniNodo
import org.apache.commons.lang.StringUtils
import org.slf4j.Logger
import org.slf4j.LoggerFactory
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

import java.sql.SQLException

@VariableResolver(DelegatingVariableResolver)
class ClassificazioneStoricizzaViewModel extends DizionariDettaglioViewModel {

    private static final Logger log = LoggerFactory.getLogger(SqlDateRevisionListener.class);

    @WireVariable
    SuccessHandler successHandler
    // services
    @WireVariable
    ClassificazioneService classificazioneService

    Set<ClassificazioneDTO> records
    String descrizione
    Date now = new Date()
    Date dal
    Date al
    ClassificazioneDTO padre
    String datePattern = 'dd/MM/yyyy'
    boolean visSalva = true

    ClassificazioneStoricizzaViewModel that

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
            records = classificazioneService.getAllById(ids, true, false)
            dal = now + 1
        }
    }

    //Estendo i metodi abstract di AfcAbstractRecord
    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica", "visSalva"])
    @Command
    void onSalva() {
        try {
            Collection<String> messaggiValidazione = validaMaschera()
            if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
                Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
                return
            }
            for (row in records) {
                if (records.size() == 1) {
                    row.descrizione = descrizione
                }
                row.dal = dal
                ClassificazioneDTO salvata = classificazioneService.storicizza(row)
                if (nodi) {
                    AlberoClassificazioniNodo nodoTarget = nodi.find {
                        it.classificazione.progressivo == salvata.progressivo
                    }
                    if (nodoTarget) {
                        nodoTarget.classificazione = salvata
                    }
                }
            }
            visSalva = false

            Events.sendEvent(AlberoClassificazioni.EVT_SAVED, self.parent, null)
            successHandler.showMessage("Classificazioni storicizzate")
        } catch (Exception e) {
            log.error("Errore nella storicizzazione della classifica.", e);
        }
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalvaChiudi() {
        onSalva()
        onChiudi()
    }

    Collection<String> validaMaschera() {

        def messaggi = super.validaMaschera()
        Date now = new Date().clearTime()
        boolean dataInizioOk = dal - now >= 0
        if (dataInizioOk) {
            for (row in records) {
                def storico = classificazioneService.getStoricoPerClassificazione(row)
                for (st in storico) {
                    if (st.al != null && st.al - dal >= 0) {
                        dataInizioOk = false
                    }
                }
            }
        }

        if (!dataInizioOk) {
            messaggi << 'La data di inizio è precedente ad oggi o sovrapposta ad una storicizzazione esistente'
        }
        return messaggi
    }

    String getDescrizione(ClassificazioneDTO dto) {
        return "${dto ? "${dto.codice} " : ''}"
    }
}
