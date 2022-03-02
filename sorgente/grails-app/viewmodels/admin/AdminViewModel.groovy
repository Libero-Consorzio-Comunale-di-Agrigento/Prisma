package admin

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioneService
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAzione
import it.finmatica.jobscheduler.JobConfig
import it.finmatica.jobscheduler.JobSchedulerManager
import it.finmatica.protocollo.admin.AggiornamentoService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiSi4CSService
import it.finmatica.protocollo.jobs.NumerazioneFascicoloTask
import it.finmatica.protocollo.jobs.ProtocolloJob
import it.finmatica.protocollo.jobs.RegistroGiornalieroJob
import it.finmatica.protocollo.jobs.TrascodificaStoricoTask
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
public class AdminViewModel {

    @WireVariable
    SpringSecurityService springSecurityService
    @WireVariable
    AggiornamentoService aggiornamentoService
    @WireVariable
    ImpostazioneService impostazioneService
    @WireVariable
    ProtocolloJob protocolloJob
    @WireVariable
    JobSchedulerManager jobSchedulerManager
    @WireVariable
    TrascodificaStoricoTask trascodificaStoricoTask
    @WireVariable
    NumerazioneFascicoloTask numerazioneFascicoloTask
    @WireVariable
    RegistroGiornalieroJob registroGiornalieroJob
    @WireVariable
    MessaggiSi4CSService messaggiSi4CSService

    Window self

    private List<Map<String, Integer>> azioniVecchie

    private List<Map<String, Long>> azioniVecchieSelezionate

    private Set<Long> azioneNuovaSelezionata

    private String filtroNuoveAzioni

    private List<Map<String, Integer>> azioniNuove
    private JobConfig jobConfig

    String idmessappoggiocreazione

    @Init
    public void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.azioniVecchie = aggiornamentoService.getAzioniVecchie()
        jobConfig = JobConfig.findByNomeBean('registroGiornalieroJob')
        this.self = w
    }

    @Command
    void cercaAzioniNuove(@BindingParam("filtroNuoveAzioni") String filtroNuoveAzioni) {
        azioniNuove = [[nome: "-- svuota azione --", id: -1]]
        azioniNuove.addAll(WkfAzione.createCriteria().list {
            eq("valido", true)
            or {
                ilike("nome", "%${filtroNuoveAzioni}%")
                ilike("descrizione", "%${filtroNuoveAzioni}%")
            }

            order("tipoOggetto.codice", "asc")
            order("nomeBean", "asc")
            order("nomeMetodo", "asc")
        }.collect {
            [nome: "${it.tipoOggetto.codice} | ${it.nomeBean}.${it.nomeMetodo}() >> ${it.nome}: ${it.descrizione}", id: it.id]
        })

        //Settare azioni vecchie, azioniNuove e FiltroAzioniNuove
        azioniVecchie = aggiornamentoService.getAzioniVecchie()

        BindUtils.postNotifyChange(null, null, this, "azioniVecchie")
        BindUtils.postNotifyChange(null, null, this, "azioniNuove")
        BindUtils.postNotifyChange(null, null, this, "filtroNuoveAzioni")

        return
    }

    @Command
    void sostituisciVecchioConNuovo() {

        List<Long> azioniVecchieSelezionateId = new ArrayList<>();

        if (azioniVecchieSelezionate?.size() > 0) {
            azioniVecchieSelezionateId = azioniVecchieSelezionate*.id
        }

        //prendo il primo elemento del set se esiste (dovrebbe essere sempre un elemento quello contenuto nel set)
        //uso il set perchè ZK si aspetta una LinkedHashSet per come è stata definita "azioniNuove"
        Long azioneNuova = azioneNuovaSelezionata?.iterator()?.next()?.id

        aggiornamentoService.sostituisciVecchieAzioniConNuove(azioniVecchieSelezionateId, azioneNuova)

        //Settare azioni vecchie, e filtroAzioniNuove
        azioniVecchie = aggiornamentoService.getAzioniVecchie()

        BindUtils.postNotifyChange(null, null, this, "azioniVecchie")
        BindUtils.postNotifyChange(null, null, this, "filtroNuoveAzioni")

        Clients.showNotification("Sostituzione effettuata", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
        return
    }

    @Command
    void aggiornaAzioni() {
        aggiornamentoService.aggiornaAzioni()
        Clients.showNotification("Azioni Aggiornate", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
        return
    }

    @Command
    void eliminaAzioni() {
        aggiornamentoService.eliminaAzioni()

        //Aggiorno le azioni vechie
        azioniVecchie = aggiornamentoService.getAzioniVecchie()

        BindUtils.postNotifyChange(null, null, this, "azioniVecchie")

        Clients.showNotification("Azioni Eliminate", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
        return
    }

    /**Questi due metodi sono commentati anche nel vecchio controller...pertanto li lascio commentati */

    @Command
    void aggiornaTipiModelloTesto() {
        aggiornamentoService.aggiornaTipiModelloTesto()
        Clients.showNotification("Tipi Modelli Testo Standard importati", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
        return
    }
//
//    @Command
//    void installaConfigurazioniIter () {
//        aggiornamentoService.installaConfigurazioniIter(session.servletContext.getRealPath("WEB-INF/configurazioneStandard/flussi"))
//        Clients.showNotification("Flussi Standard importati", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
//        return
//    }

    @Command
    void attivaJob() {
        protocolloJob.job()
        Clients.showNotification("Job Attivato", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
        return
    }

    @Command
    void attivaDisattivaSmartDesktop(@BindingParam("attiva") String attiva) {
        aggiornamentoService.attivaDisattivaIntegrazioneSmartDesktop(attiva)
        Clients.showNotification((attiva.equals("Y")) ? "Integrazione Attivata" : "Integrazione Disattivata", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
        return
    }

    @Command
    def aggiornaImpostazioni() {
        impostazioneService.aggiornaImpostazioni();
        Clients.showNotification("Impostazioni aggiornate", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 5000, true)
        if (springSecurityService.isLoggedIn()) {
            return
        } else {
            //TODO verificare cosa accade qui
            Clients.showNotification("Utente non loggato", Clients.NOTIFICATION_TYPE_WARNING, self, "before_center", 5000, true)
        }
    }

    @Command
    void generaReport() {
        Calendar cal = Calendar.getInstance()
        cal.add(Calendar.MINUTE, 1)
        cal.time
        jobConfig = JobConfig.get(jobConfig.id)
        String oldCron = jobConfig.cron
        jobConfig.cron = "0 ${cal.get(Calendar.MINUTE)} ${cal.get(Calendar.HOUR_OF_DAY)} * * *"
        jobConfig.stato = JobConfig.Stato.IN_ATTESA
        jobConfig.save()
        jobSchedulerManager.rescheduleConfiguredJob(jobConfig)
        jobConfig.cron = oldCron
        jobConfig.save()
        Messagebox.show("Metto in esecuzione alle ${cal.get(Calendar.HOUR_OF_DAY)}:${cal.get(Calendar.MINUTE)}", "Task in esecuzione", Messagebox.OK, Messagebox.INFORMATION)
    }

    @Command
    void trascodificaStorico() {
        trascodificaStoricoTask.trascodificaStorico()
    }

    @Command
    void numerazioneFascicoli() {
        numerazioneFascicoloTask.numerazioneFasciolo()
    }

    @Command
    void cancellaToken() {
        registroGiornalieroJob.rimuoviToken()
        Clients.showNotification('Token cancellato')
    }

    @Command
    void onCreaMsg() {

        /* Protocollo protocollo =  Protocollo.findById(8645334)
          protocollo.valido=false
          protocolloService.salva(protocollo,true,true,true,false)*/

        Protocollo protocollo = messaggiSi4CSService.creaMessaggioRicevutoAgsprDaSi4CS(idmessappoggiocreazione)

        /*if (protocollo != null) {
            try {
                String messaggio = messaggiSi4CSService.protocollaMessaggioRicevutoSi4CS(protocollo)

                if (messaggio != null) {
                    messaggiSi4CSService.salvaMessaggioErroreprotocollazioneMessaggioRicevutoSi4CS(protocollo,messaggio)
                }
            } catch (Exception exi) {
                //dontcare
            }
        }*/

        //provo a spedire la cobferma di ricezione
        //mailService.spedisciConfermaRicezione(Protocollo.findById(6078702))

        // mailService.spedisciNotificaEccezione(Protocollo.findById(6439236))

        //  println  segnaturaInteropService.produciSegnatura(Protocollo.findById(6076746), Messaggio.findById(6076813), false, false, false)

        //test apro un msg inviato

        //   MessaggioInviatoViewModel.apriPopup([idMessaggio: "6072193"])

        //   println Integer.parseInt("0000091")
    }

    List<Map<String, Integer>> getAzioniVecchie() {
        return azioniVecchie
    }

    String getFiltroNuoveAzioni() {
        return filtroNuoveAzioni
    }

    void setFiltroNuoveAzioni(String filtroNuoveAzioni) {
        this.filtroNuoveAzioni = filtroNuoveAzioni
    }

    List<Map<String, Integer>> getAzioniNuove() {
        return azioniNuove
    }

    void setAzioniVecchieSelezionate(List<Map<String, Long>> azioniVecchieSelezionate) {
        this.azioniVecchieSelezionate = azioniVecchieSelezionate
    }

    List<Map<String, Long>> getAzioniVecchieSelezionate() {
        return azioniVecchieSelezionate
    }

    Set<Long> getAzioneNuovaSelezionata() {
        return azioneNuovaSelezionata
    }

    void setAzioneNuovaSelezionata(Set<Long> azioneNuovaSelezionata) {
        this.azioneNuovaSelezionata = azioneNuovaSelezionata
    }
}