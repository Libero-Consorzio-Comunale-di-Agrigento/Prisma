package it.finmatica.protocollo.scaricoipa

import it.finmatica.ad4.dizionari.Ad4ProvinciaDTO
import it.finmatica.ad4.dizionari.Ad4RegioneDTO
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.jobscheduler.JobLog
import it.finmatica.protocollo.integrazioni.ad4.ProvinceAd4Service
import it.finmatica.protocollo.integrazioni.ad4.RegioniAd4Service
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class CriteriScaricoIpaDettaglioViewModel extends it.finmatica.afc.AfcAbstractRecord {
    CriteriScaricoIpaDTO selectedRecord
    @WireVariable
    CriteriScaricoIpaService criteriScaricoIpaService
    @WireVariable
    SuccessHandler successHandler
    @WireVariable
    RegioniAd4Service regioniAd4Service
    @WireVariable
    ProvinceAd4Service provinceAd4Service

    List<Ad4RegioneDTO> listaRegioni = []
    List<Ad4ProvinciaDTO> listaProvince = []
    List<Ad4ProvinciaDTO> listaProvinceAoo = []

    List<JobLog> jobLogList = []

    //Variabili per la gestione dei job
    def giorniSettimanaCron = [false, false, false, false, false, false, false]
    def giorniSettimanaCronString = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    String oraCron
    String minutoCron

    final String _CRON_ORA_MINUTO_VUOTI = "--"
    final String TIPOLOGIA_ENTE_TUTTI = "(Tutti)"

    String esitoJob = ""
    String ultimaEsecuzione = ""

    def mappaTipologieAmm = [TIPOLOGIA_ENTE_TUTTI,
                             "Agenzie Fiscali",
                             "Agenzie Regionali Sanitarie",
                             "Agenzie Regionali e Provinciale per la Rappresentanza Negoziale",
                             "Agenzie Regionali per le Erogazioni in Agricoltura",
                             "Agenzie ed Enti Regionali del Lavoro",
                             "Agenzie ed Enti Regionali di Sviluppo Agricolo",
                             "Agenzie ed Enti Regionali per la Formazione, la Ricerca e l'Ambiente",
                             "Agenzie ed Enti per il Turismo",
                             "Agenzie, Enti e Consorzi Pubblici per il Diritto allo Studio Universitario",
                             "Altri Enti Locali",
                             "Automobile Club Federati ACI",
                             "Autorita' Amministrative Indipendenti",
                             "Autorita' Portuali",
                             "Autorita' di Ambito Territoriale Ottimale",
                             "Autorita' di Bacino",
                             "Aziende Ospedaliere, Aziende Ospedaliere Universitarie, Policlinici e Istituti di Ricovero e Cura a Carattere Scientifico Pubblici",
                             "Aziende Pubbliche di Servizi alla Persona",
                             "Aziende Sanitarie Locali",
                             "Aziende e Consorzi Pubblici Territoriali per l'Edilizia Residenziale",
                             "Aziende ed Amministrazioni dello Stato ad Ordinamento Autonomo",
                             "Camere di Commercio, Industria, Artigianato e Agricoltura e loro Unioni Regionali",
                             "Citta' Metropolitane",
                             "Comuni e loro Consorzi e Associazioni",
                             "Comunita' Montane e loro Consorzi e Associazioni",
                             "Consorzi Interuniversitari di Ricerca",
                             "Consorzi di Bacino Imbrifero Montano",
                             "Consorzi per l'Area di Sviluppo Industriale",
                             "Consorzi tra Amministrazioni Locali",
                             "Enti Nazionali di Previdenza ed Assistenza Sociale in Conto Economico Consolidato",
                             "Enti Pubblici Non Economici",
                             "Enti Pubblici Produttori di Servizi Assistenziali, Ricreativi e Culturali",
                             "Enti di Regolazione dei Servizi Idrici e o dei Rifiuti",
                             "Enti e Istituzioni di Ricerca Pubblici",
                             "Federazioni Nazionali, Ordini, Collegi e Consigli Professionali",
                             "Fondazioni Lirico, Sinfoniche",
                             "Forze di Polizia ad Ordinamento Civile e Militare per la Tutela dell'Ordine e della Sicurezza Pubblica",
                             "Gestori di Pubblici Servizi",
                             "Istituti Zooprofilattici Sperimentali",
                             "Istituti di Istruzione Statale di Ogni Ordine e Grado",
                             "Istituzioni per l'Alta Formazione Artistica, Musicale e Coreutica - AFAM",
                             "Organi Costituzionali e di Rilievo Costituzionale",
                             "Parchi Nazionali, Consorzi e Enti Gestori di Parchi e Aree Naturali Protette",
                             "Presidenza del Consiglio dei Ministri, Ministeri e Avvocatura dello Stato",
                             "Province e loro Consorzi e Associazioni",
                             "Regioni, Province Autonome e loro Consorzi e Associazioni",
                             "Societa' in Conto Economico Consolidato",
                             "Teatri Stabili ad Iniziativa Pubblica",
                             "Unioni di Comuni e loro Consorzi e Associazioni",
                             "Universita' e Istituti di Istruzione Universitaria Pubblici"]

    @NotifyChange(["selectedRecord", "numeroGiorni", "oraEsecuzione", "minutiEsecuzione", "listaRegioni", "ultimoLog", "oraCron", "minutoCron", "giorniSettimanaCron"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") long id) {
        this.self = w
        oraCron = _CRON_ORA_MINUTO_VUOTI
        minutoCron = _CRON_ORA_MINUTO_VUOTI

        caricaCriterioIpa(id)
        caricaListaRegioni()
        caricaListaProvince(selectedRecord?.regioneAmm)
        caricaListaProvinceAoo(selectedRecord?.regioneAoo)
    }

    @NotifyChange(["selectedRecord"])
    private void caricaCriterioIpa(long id) {

        if (id != -1) {
            selectedRecord = criteriScaricoIpaService.getCriterio(id).toDTO()

            if (selectedRecord.jobConfig != null) {
                jobLogList = JobLog.createCriteria().list {
                    eq("jobConfig.id", selectedRecord.jobConfig)
                    order("dataInizio", "desc")
                }

                if (jobLogList.size() > 0) {
                    ultimaEsecuzione = jobLogList.get(0).dataInizio.format('dd/MM/yyyy HH:mm:ss')
                    esitoJob = jobLogList.get(0).stato
                }
            }

            aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
            aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
        } else {
            selectedRecord = new CriteriScaricoIpaDTO(id: -1, valido: true)
            selectedRecord.importaTutteAmm = 1
            selectedRecord.importaTutteAoo = 0
            selectedRecord.importaTutteUnita = 1
        }
    }

    /*
	 * Implementazione dei metodi per AfcAbstractRecord
	 */

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalva() {
        if (!validateForm()) {
            return
        }

        boolean isNuovoCriterio = !(selectedRecord.id < 0)

        if (selectedRecord.id < 0) {
            selectedRecord.stringaCron = null
        }

        selectedRecord = criteriScaricoIpaService.salva(selectedRecord)

        /*
        if (isNuovoCriterio) {
            aggiornaDatiCreazione(selectedRecord?.utenteIns?.id, selectedRecord.dateCreated)
        }
        aggiornaDatiModifica(selectedRecord?.utenteUpd?.id, selectedRecord.lastUpdated)
        */

        if (selectedRecord.regioneAmm == null) {
            selectedRecord.regioneAmm = new Long("-1")
        }

        successHandler.showMessage("Criterio salvato")
        aggiornaMaschera(selectedRecord)
    }

    @Command
    void onSettaValido(@BindingParam("valido") boolean valido) {
    }

    @NotifyChange(["selectedRecord"])
    @Command
    void onSalvaChiudi() {
        onSalva()
        onChiudi()
    }

    @NotifyChange(["selectedRecord", "selectedRecord.numeroGiorni", "selectedRecord.oraEsecuzione", "selectedRecord.minutiEsecuzione"])
    @Command
    void onPianificazione() {
        Window w = Executions.createComponents("/scaricoipa/criteriScaricoIpaJob.zul", self, [id: selectedRecord.id, numeroGiorni: selectedRecord.numeroGiorni, ora: selectedRecord.oraEsecuzione, minuti: selectedRecord.minutiEsecuzione])
        w.onClose { event ->
            if (event.data != null) {
                aggiornaMaschera((event.data))
            }
        }
        w.doModal()
    }

    @NotifyChange(["listaProvince", "selectedRecord.provinciaAmm"])
    @Command
    void onCaricaProvince(@BindingParam("idRegione") Long idRegione) {
        selectedRecord.provinciaAmm = new Long("-1")
        caricaListaProvince(idRegione)
    }

    @NotifyChange(["listaProvinceAoo", "selectedRecord.provinciaAoo"])
    @Command
    void onCaricaProvinceAoo(@BindingParam("idRegione") Long idRegione) {
        selectedRecord.provinciaAoo = new Long("-1")
        caricaListaProvinceAoo(idRegione)
    }

    @Command
    void onElabora() {
        onSalva()
        criteriScaricoIpaService.elaboraCriterio(selectedRecord)
    }

    private void caricaListaRegioni() {
        listaRegioni = regioniAd4Service.ricerca(new Long("-1"), "")
        listaRegioni.add(0, new Ad4RegioneDTO(regione: -1, denominazione: "Elenco Regioni d'Italia"))
    }

    private void caricaListaProvince(Long regione) {
        listaProvince = provinceAd4Service.ricerca(new Long("-1"), regione)
        listaProvince.add(0, new Ad4ProvinciaDTO(provincia: -1, denominazione: "Elenco delle province in base alla regione scelta"))
    }

    private void caricaListaProvinceAoo(Long regione) {
        listaProvinceAoo = provinceAd4Service.ricerca(new Long("-1"), regione)
        listaProvinceAoo.add(0, new Ad4ProvinciaDTO(provincia: -1, denominazione: "Elenco delle province in base alla regione scelta"))
    }

    private boolean validateForm() {
        if (selectedRecord.nomeCriterio == null) {
            Messagebox.show("Nome criterio obbligatorio!", "Avviso", Messagebox.OK, Messagebox.ERROR);
            return false
        }

        if (esisteAlmenoUnGiornoAttivoCron() && (oraCron.equals(_CRON_ORA_MINUTO_VUOTI) || minutoCron.equals(_CRON_ORA_MINUTO_VUOTI))) {
            Messagebox.show("Avendo scelto un giorno per l'elaborazione, è obbligatorio scegliere anche l'orario!", "Avviso", Messagebox.OK, Messagebox.ERROR);
            return false
        }

        if (!esisteAlmenoUnGiornoAttivoCron() && (!oraCron.equals(_CRON_ORA_MINUTO_VUOTI) || !minutoCron.equals(_CRON_ORA_MINUTO_VUOTI))) {
            Messagebox.show("Avendo scelto un orario per l'elaborazione, è obbligatorio scegliere anche i giorni!", "Avviso", Messagebox.OK, Messagebox.ERROR);
            return false
        }

        return true
    }

    private String formatCronString() {
        boolean almenoUnGiornoAttivo = esisteAlmenoUnGiornoAttivoCron()

        if (!almenoUnGiornoAttivo && oraCron.equals(_CRON_ORA_MINUTO_VUOTI) && minutoCron.equals(_CRON_ORA_MINUTO_VUOTI)) {
            return null
        }

        if (oraCron.equals(_CRON_ORA_MINUTO_VUOTI)) {
            oraCron = "0"
        }
        if (minutoCron.equals(_CRON_ORA_MINUTO_VUOTI)) {
            minutoCron = "0"
        }

        String cronString = "0 " + minutoCron + " " + oraCron + " "

        //day-of-month
        cronString += "* "
        //month
        cronString += "* "

        //day-of-week
        String dayOfWeek = ""
        int index = 0
        for (boolean bcheck in giorniSettimanaCron) {
            if (bcheck) {
                if (!dayOfWeek.equals("")) {
                    dayOfWeek += ","
                }
                dayOfWeek += giorniSettimanaCronString[index]
            }
            index++
        }
        cronString += dayOfWeek

        return cronString
    }

    private void parseCronString(String cronString) {
        String[] items

        items = cronString.split(" ")
        oraCron = items[1]
        minutoCron = items[2]

        String dayOfWeek
        dayOfWeek = items[5]
        if (!dayOfWeek.equals("*")) {
            int indexGiorno = 0
            for (giorno in giorniSettimanaCronString) {
                if (dayOfWeek.indexOf(giorno) != -1) {
                    giorniSettimanaCron[indexGiorno++] = true
                } else {
                    giorniSettimanaCron[indexGiorno++] = false
                }
            }
        }

        if (dayOfWeek.equals("*")) {
            oraCron = _CRON_ORA_MINUTO_VUOTI
            minutoCron = _CRON_ORA_MINUTO_VUOTI
        }
    }

    private boolean esisteAlmenoUnGiornoAttivoCron() {
        boolean almenoUnGiornoAttivo = false
        for (boolean bcheck in giorniSettimanaCron) if (bcheck) {
            almenoUnGiornoAttivo = true
        }

        return almenoUnGiornoAttivo
    }

    void aggiornaMaschera(CriteriScaricoIpaDTO c) {
        if (!c) {
            return
        }

        caricaCriterioIpa(c.id)

        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        BindUtils.postNotifyChange(null, null, this, "jobConfig")
    }
}