package it.finmatica.protocollo.titolario

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggetto
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.dizionari.FiltroDataClassificazioni
import it.finmatica.protocollo.dizionari.FiltroDataFascicoli
import it.finmatica.protocollo.dizionari.ImportazioneCSVException
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.protocollo.zk.AlberoClassificazioni
import it.finmatica.protocollo.zk.AlberoClassificazioniNodo
import it.finmatica.protocollo.zk.AlberoClassificazioniNodoInMemoria
import it.finmatica.protocollo.zk.AlberoFascicoli
import it.finmatica.protocollo.zk.AlberoFascicoliNodo
import it.finmatica.protocollo.zk.AlberoFascicoliNodoInMemoria
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.zk.afc.AfcAbstractGrid
import org.apache.commons.lang.StringUtils
import org.apache.commons.lang3.time.FastDateFormat
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.event.UploadEvent
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class ClassificazioneListaViewModel extends AfcAbstractGrid {

    public static final int PAGE_SIZE_DEFAULT = 50

    // services
    @WireVariable
    ClassificazioneService classificazioneService
    @WireVariable
    FascicoloService fascicoloService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    SpringSecurityService springSecurityService
    @WireVariable
    ProtocolloPkgService protocolloPkgService

    // componenti
    Window self

    AlberoClassificazioni alberoClassificazioni
    String urlIcone
    String urlIconaFiltro
    Set<AlberoClassificazioniNodo> selectedRecords
    ListModelList<FiltroDataClassificazioni> sceltaData = new ListModelList<>(FiltroDataClassificazioni.values())
    FiltroDataClassificazioni filtroData = FiltroDataClassificazioni.VIS_ATTIVE
    FiltroDataFascicoli filtroDataF = FiltroDataFascicoli.VIS_TUTTE
    Date dataChiusura
    boolean chiudiVisibile = false
    FastDateFormat fdf = FastDateFormat.getInstance('dd/MM/yyyy')
    private String separatore = ImpostazioniProtocollo.SEP_CLASSIFICA.valore

    String datePattern = 'dd/MM/yyyy'
    Date now = new Date()
    Date dataValiditaTitolario = now
    boolean visDataValiditaTitolario
    boolean abilitaRefreshFascicoli

    Date dataAperturaInizio
    Date dataAperturaFine
    Date dataCreazioneInizio
    Date dataCreazioneFine
    Date dataChiusuraInizio
    Date dataChiusuraFine
    String codiceClassifica
    String descrizioneClassifica
    String usoClassifica

    boolean daRicerca
    boolean iterFascicolare = ImpostazioniProtocollo.ITER_FASCICOLI.abilitato

    AlberoFascicoli alberoFascicoli
    Set<AlberoFascicoliNodo> selectedRecordsFasc
    boolean abilitaRicercaFascicolo = false
    boolean abilitaAggiuntaDocumento = true
    String valoreRicarcaFascicoli = "APERTI"
    Map soggetti = [:]
    Long idTipologia = TipologiaSoggetto.findByTipoOggetto(it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto.get("FASCICOLO"))?.id
    Map<String, String> filtriRicerca = [:]
    Integer annoInizioRicerca = now.year + 1900
    Integer annoFineRicerca = now.year + 1900
    String numeroInizioRicerca = ""
    String numeroFineRicerca = ""
    String oggettoRicerca = ""

    boolean visFascicoliChiusi
    boolean visFascicoliFuturi
    boolean visMassimarioScarto

    String labelFascicoli = "Fascicoli"

    // competenze in creazione
    boolean creaClassifica
    boolean creaFascicolo
    boolean creaProtocollo
    boolean creaLettera
    boolean creaDocumentoDaFascicolare
    boolean abilitaInserimentoSub

    // competenze classificazioni
    boolean storicizzaClassificazione
    boolean storicizzaClassificazioneAction
    boolean chiudiClassificazione
    boolean eliminaClassificazione

    int pageSize = PAGE_SIZE_DEFAULT

    static Window apriPopup() {
        Window window
        window = (Window) Executions.createComponents("/titolario/classificazioneLista.zul", null, null)
        window.doModal()
        return window
    }

    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        alberoClassificazioni = initAlbero()
        alberoClassificazioni.filtroData = filtroData
        this.urlIcone = "/images/icon/action/18x18/"
        this.urlIconaFiltro = "/images/afc/16x16/filter.png"
        self.addEventListener(AlberoClassificazioni.EVT_SAVED, { event ->
            onRefresh()
            BindUtils.postNotifyChange(null, null, this, 'alberoClassificazioni')
        })

        initAlberoFascicoli()

        if (privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.VFC) || privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.VFCU) | privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.VFCUCRE)) {
            visFascicoliChiusi = true
        }
        if (privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.CFFUTURO)) {
            visFascicoliFuturi = true
        }
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.VCCTOT) || privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.VCC)) {
            visDataValiditaTitolario = true
        }
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.AGPSUP) || privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.AGPPRALL)) {
            visMassimarioScarto = true
        }
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.AGPSUP) || privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.AGPPRALL)) {
            visMassimarioScarto = true
        }

        // gestione competenze in creazione
        if (privilegioUtenteService.isCreaFascicolo()) {
            creaFascicolo = true
        }
        if (privilegioUtenteService.isCreaClassificazione()) {
            creaClassifica = true
        }
        if (privilegioUtenteService.isCreaProtocollo()) {
            creaProtocollo = true
        }
        if (privilegioUtenteService.isCreaLettera()) {
            creaLettera = true
        }
        if (privilegioUtenteService.isCreaDocumentoDaFascicolare()) {
            creaDocumentoDaFascicolare = true
        }

        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.MCCTOT) || privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.MCC)) {
            storicizzaClassificazione = true
        }
        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_CLASSIFICAZIONI_APERTE_TUTTE) || privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.ELIMINA_DA_CLASSIFICAZIONI_APERTE)) {
            eliminaClassificazione = true
        }
    }

    private AlberoClassificazioni initAlbero() {
        ClassificazioneDTO root = new ClassificazioneDTO()
        def nodoDefault = new AlberoClassificazioniNodoInMemoria(root)
        nodoDefault.index = 0
        alberoClassificazioni = new AlberoClassificazioni(classificazioneService, filtro, filtroData, dataValiditaTitolario, dataAperturaInizio, dataAperturaFine, dataCreazioneInizio, dataCreazioneFine, dataChiusuraInizio, dataChiusuraFine, codiceClassifica, descrizioneClassifica, usoClassifica, daRicerca)
        alberoClassificazioni
    }

    @NotifyChange(['alberoFascicoli', 'totalsize', 'activePage'])
    @Command
    void onPagina() {
        abilitaRefreshFascicoli = true
        popolaAlberoFascicoli(filtriRicerca)

        BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
        BindUtils.postNotifyChange(null, null, this, "totalsize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
    }

    void onModifica(boolean isNuovoRecord) {
    }

    @NotifyChange(['selectedRecord', 'selectedRecords'])
    @Command('onModifica')
    void doModifica(@BindingParam("isNuovoRecord") boolean isNuovoRecord, @BindingParam("target") AlberoClassificazioniNodo target) {

        boolean insert = true
        if (target) {
            selectedRecord = target
            selectedRecords = [target] as Set
        }

        AlberoClassificazioniNodo padre = selectedRecords?.size() == 1 ? selectedRecords.first() : null

        if (!isNuovoRecord && !privilegioUtenteService.isCompetenzaVisualizzaClassificazione(selectedRecord?.classificazione?.domainObject)) {
            Clients.showNotification("Non è possibile aprire la classifica. Utente non abilitato alla visualizzazione.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 5000, true)
            return
        }

        if (padre && !isAttivo(padre) && isNuovoRecord) {
            insert = false
            Clients.showNotification("Attenzione: non è possibile inserire una sottoclassifica di una classifica già chiusa.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
        }

        if (insert) {
            Window w = Executions.createComponents("/titolario/classificazioneDettaglio.zul", self, [nodo        : isNuovoRecord ? null : selectedRecord,
                                                                                                     modificabile: true, padre: isNuovoRecord ? selectedRecord?.classificazione : (padre ? padre?.classificazione : null)])
            w.doModal()
        }
    }

    @NotifyChange(['selectedRecord', 'selectedRecords'])
    @Command
    void onAggiungiFascicolo(@BindingParam("target") AlberoClassificazioniNodo target) {
        if (target) {
            selectedRecord = target
            selectedRecords = [target] as Set
        }

        AlberoClassificazioniNodo padre = selectedRecords?.size() == 1 ? selectedRecords.first() : null

        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false, titolario: padre?.classificazione])
        w.doModal()

        w.onClose { event ->
            if (event.data) {
                onModificaNuovo(event.data["titolario"], event.data["duplica"])
            } else {
                BindUtils.postNotifyChange(null, null, this, 'selectedRecord')
                BindUtils.postNotifyChange(null, null, this, 'selectedRecords')
                BindUtils.postNotifyChange(null, null, this, "alberoClassificazioni")
                BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
                BindUtils.postNotifyChange(null, null, this, "selectedRecordsFasc")
            }
        }
    }

    @Command
    void onStoricizza() {
        if (selectedRecords) {
            Window w = Executions.createComponents("/titolario/classificazioneStoricizza.zul", self, [nodi: selectedRecords])
            w.doModal()
        }
    }

    @Command
    void onChiudi() {
        if (selectedRecords) {
            Window w = Executions.createComponents("/titolario/classificazioneChiudi.zul", self, [nodi: selectedRecords])
            w.doModal()
        }
    }

    @Command
    void onEliminaClassifica() {
        AlberoClassificazioniNodo padre = selectedRecords?.size() == 1 ? selectedRecords.first() : null
        if (classificazioneService.isEliminabile(padre?.classificazione)) {
            classificazioneService.elimina(padre?.classificazione)
            ClientsUtils.showInfo("Classificazione eliminata.")
        } else {
            Clients.showNotification('Non è possibile eliminare la classificazione.', Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 5000, true)
        }
        onRefresh()
    }

    @NotifyChange('selectedRecord')
    @Command
    void onSelectClassificazione() {
        if (selectedRecords?.size() == 1) {
            abilitaRicercaFascicolo = true
            selectedRecord = selectedRecords.first()
            abilitaAggiuntaDocumento = true
            if (!selectedRecord.classificazione.contenitoreDocumenti) {
                abilitaAggiuntaDocumento = false
            }
        } else {
            abilitaRicercaFascicolo = false
            selectedRecord = null
        }

        if (selectedRecords?.size() > 0) {
            storicizzaClassificazioneAction = true
            selectedRecords.each {
                if (!it.classificazione.isAperta()) {
                    storicizzaClassificazioneAction = false
                }
            }
        } else {
            storicizzaClassificazioneAction = false
        }

        BindUtils.postNotifyChange(null, null, this, 'storicizzaClassificazioneAction')
        BindUtils.postNotifyChange(null, null, this, 'storicizzaClassificazione')
        BindUtils.postNotifyChange(null, null, this, 'abilitaRicercaFascicolo')
        BindUtils.postNotifyChange(null, null, this, 'abilitaAggiuntaDocumento')
    }

    @NotifyChange(['alberoClassificazioni'])
    @Command
    void onRefresh() {
        selectedRecord = null
        selectedRecords = []
        alberoClassificazioni = initAlbero()
        getIconaFiltri()
        BindUtils.postNotifyChange(null, null, this, 'alberoClassificazioni')
        BindUtils.postNotifyChange(null, null, this, 'storicizzaClassificazioneAction')
        BindUtils.postNotifyChange(null, null, this, 'abilitaAggiuntaDocumento')
        BindUtils.postNotifyChange(null, null, this, 'selectedRecord')
        BindUtils.postNotifyChange(null, null, this, 'selectedRecords')
        BindUtils.postNotifyChange(null, null, this, 'urlIconaFiltro')
    }

    @NotifyChange(['chiudiVisibile', 'dataChiusura'])
    @Command
    void onElimina() {
        chiudiVisibile = !chiudiVisibile
        dataChiusura = new Date()
    }

    @NotifyChange([])
    @Command
    void onVisualizzaTutti() {
    }

    @NotifyChange(["alberoClassificazioni", 'filtro'])
    @Command
    void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        if (event instanceof InputEvent) {
            filtro = event.value
        }

        alberoClassificazioni.filtroRicerca = filtro
        daRicerca = true

        onRefresh()
    }

    @Command
    void onFiltriAvanzati() {
        Window w = Executions.createComponents("/commons/popupFiltriRicercaClassificazioni.zul", self, [dataAperturaInizio: dataAperturaInizio, dataAperturaFine: dataAperturaFine, dataCreazioneInizio: dataCreazioneInizio, dataCreazioneFine: dataCreazioneFine, dataChiusuraInizio: dataChiusuraInizio, dataChiusuraFine: dataChiusuraFine, usoClassifica: usoClassifica])
        w.onClose { event ->
            if (event.data) {
                dataAperturaInizio = event.data["dataAperturaInizio"]
                dataAperturaFine = event.data["dataAperturaFine"]
                dataCreazioneInizio = event.data["dataCreazioneInizio"]
                dataCreazioneFine = event.data["dataCreazioneFine"]
                dataChiusuraInizio = event.data["dataChiusuraInizio"]
                dataChiusuraFine = event.data["dataChiusuraFine"]
                usoClassifica = event.data["usoClassifica"]
                onFiltro()
            }
        }
        w.doModal()
    }

    @NotifyChange(["alberoClassificazioni", 'filtro'])
    @Command
    void onCancelFiltro() {
        filtro = ''
        alberoClassificazioni.filtroRicerca = filtro
    }

    String getIcona(AlberoClassificazioniNodo nodo) {
        ClassificazioneDTO c = nodo?.classificazione
        if (c.al) {
            return 'folderclose.png'
        } else {
            return 'folder.png'
        }
    }

    @NotifyChange(["alberoClassificazioni"])
    @Command
    void onFiltraData() {
        alberoClassificazioni.filtroData = filtroData
        onRefresh()
    }

    @NotifyChange(['chiudiVisibile', 'dataChiusura', 'alberoClassificazioni'])
    @Command
    void onChiudiClassificazioni() {
        if (!dataChiusura || (dataChiusura - new Date()) < 0) {
            Clients.showNotification('Impostare una data di chiusura per oggi o un giorno successivo', Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }
        for (nodo in selectedRecords) {
            classificazioneService.chiudiClassificazione(nodo?.classificazione, dataChiusura)
        }
        chiudiVisibile = false
        dataChiusura = null
        initAlbero()
    }

    @NotifyChange('alberoClassificazioni')
    @Command
    void onImportaCSV(@ContextParam(ContextType.TRIGGER_EVENT) UploadEvent event) {
        String csv = event.media.stringData
        try {
            classificazioneService.importaCsv(csv, springSecurityService.principal.username)
            Clients.showNotification('Importazione completata', Clients.NOTIFICATION_TYPE_INFO, self, "middle_center", 3000, true)
            initAlbero()
        } catch (ImportazioneCSVException e) {
            Messagebox.show(StringUtils.join(e.errori, "\n"), 'Errori importazione', Messagebox.OK, Messagebox.ERROR)
        }
    }

    String denominazione(AlberoClassificazioniNodo nodo) {
        ClassificazioneDTO cl = nodo?.classificazione
        String base = "${cl.codice} ${separatore} ${cl.descrizione ?: ''}"

        if (isAttivo(nodo)) {
            return "${base}.Valido dal ${formatDate(cl.dal)}"
        } else {
            return "${base}.Valido dal ${formatDate(cl.dal)} al ${formatDate(cl.al)}"
        }
    }

    boolean isContenitore(AlberoClassificazioniNodo nodo) {
        nodo.classificazione?.contenitoreDocumenti
    }

    private boolean isAttivo(AlberoClassificazioniNodo nodo) {
        ClassificazioneDTO cl = nodo?.classificazione
        if (cl) {
            Date dal = cl.dal ?: new Date()
            Date al = cl.al ?: new Date() + 100
            Date now = new Date()
            return (now - dal >= 0) && (now - al <= 0)
        }
        return false
    }

    private String formatDate(Date d) {
        d ? fdf.format(d) : 'sempre'
    }

    // gestione fascicoli
    @Command
    void onRicercaFascicoli() {

        if (!selectedRecords[0]) {
            return
        }

        if (annoInizioRicerca == null && annoFineRicerca == null) {
            Clients.showNotification('Indicare il campo anno per la ricerca', Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }
        if (numeroInizioRicerca == "0" || numeroFineRicerca == "0") {
            Clients.showNotification('Indicare il campo numero valido per la ricerca', Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        filtriRicerca = [:]
        filtriRicerca = [classifica: selectedRecords[0]?.classificazione?.id, annoInizio: annoInizioRicerca, annoFine: annoFineRicerca, numeroInizio: fascicoloService.numeroOrdinato(numeroInizioRicerca), numeroFine: fascicoloService.numeroOrdinato(numeroFineRicerca), oggetto: oggettoRicerca, filtro: valoreRicarcaFascicoli, uoCompetenza: soggetti.UO_COMPETENZA?.unita?.progr]

        labelFascicoli = "Fascicoli presenti in " + selectedRecords[0]?.classificazione?.getNome()
        abilitaRefreshFascicoli = true
        activePage = 0
        totalSize = fascicoloService.list(filtriRicerca)
        popolaAlberoFascicoli(filtriRicerca)
    }

    @Command
    void onSelectFascicolo() {
        if (selectedRecordsFasc?.size() == 1) {
            abilitaInserimentoSub = true
        } else {
            abilitaInserimentoSub = false
        }
        BindUtils.postNotifyChange(null, null, this, 'abilitaInserimentoSub')
    }

    @NotifyChange(['alberoFascicoli', 'totalsize', 'activePage'])
    @Command
    void onRefreshFascicoli() {
        activePage = 0
        popolaAlberoFascicoli(filtriRicerca)
        BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
        BindUtils.postNotifyChange(null, null, this, "totalsize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
    }

    @Command
    void onEliminaFascicolo() {
        if (fascicoloService.isEliminabile(selectedRecordsFasc[0].fascicolo)) {
            fascicoloService.eliminaFascicolo(selectedRecordsFasc[0].fascicolo)
            ClientsUtils.showInfo("Fascicolo eliminato.")
        } else {
            Clients.showNotification('Non è possibile eliminare il fascicolo.', Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 5000, true)
        }
        onRefreshFascicoli()
    }

    @Command
    void onModificaFascicoloAlbero(@BindingParam("isNuovoRecord") boolean isNuovoRecord, @BindingParam("target") AlberoFascicoliNodo target) {
        onModificaFascicolo(target.fascicolo)
    }

    @Command
    void onModificaFascicoloMenu() {
        onModificaFascicolo(selectedRecordsFasc[0].fascicolo)
    }

    void onModificaFascicolo(FascicoloDTO fascicolo) {

        if (!privilegioUtenteService.isCompetenzaVisualizzaFascicolo(fascicolo?.domainObject)) {
            Clients.showNotification("Non è possibile aprire il fascicolo. Utente non abilitato alla visualizzazione.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 5000, true)
            return
        }

        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: fascicolo.id, isNuovoRecord: false, standalone: false, titolario: null])
        w.onClose { event ->
            if (event.data) {
                onModificaNuovo(event.data["titolario"], event.data["duplica"])
            } else {
                onRicercaFascicoli()
                BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
            }
        }
        w.doModal()
    }

    @Command
    void onSub() {
        onModificaNuovo(selectedRecordsFasc[0].fascicolo, false)
    }

    @Command
    void onAggiungiFascicoloF() {
        AlberoClassificazioniNodo padre = selectedRecords?.size() == 1 ? selectedRecords.first() : null
        onModificaNuovo(padre?.classificazione, false)
    }

    @Command
    void onAggiungiFascicoloFSub() {
        onModificaNuovo(selectedRecordsFasc[0].fascicolo, false)
    }

    @Command
    void onModificaNuovo(def titolario, boolean duplica) {
        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false, titolario: titolario, duplica: duplica])
        w.onClose { event ->
            if (event.data) {
                onModificaNuovo(event.data["titolario"], event.data["duplica"])
            } else {
                onRicercaFascicoli()
                selectedRecordsFasc = null
                BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
                BindUtils.postNotifyChange(null, null, this, "selectedRecordsFasc")
            }
        }
        w.doModal()
    }

    private AlberoFascicoli initAlberoFascicoli() {
        alberoFascicoli = new AlberoFascicoli(fascicoloService, privilegioUtenteService, filtro, filtroDataF, null, 0, 0)
        alberoFascicoli
        BindUtils.postNotifyChange(null, null, this, 'alberoFascicoli')
        BindUtils.postNotifyChange(null, null, this, "selectedRecordsFasc")
    }

    private AlberoFascicoli popolaAlberoFascicoli(Map filtriRicerca) {
        FascicoloDTO root = new FascicoloDTO()
        def nodoDefault = new AlberoFascicoliNodoInMemoria(root)
        nodoDefault.index = 0

        alberoFascicoli = new AlberoFascicoli(fascicoloService, privilegioUtenteService, filtro, filtroDataF, filtriRicerca, pageSize, activePage)

        BindUtils.postNotifyChange(null, null, this, 'abilitaRefreshFascicoli')
        BindUtils.postNotifyChange(null, null, this, 'alberoFascicoli')
        BindUtils.postNotifyChange(null, null, this, 'labelFascicoli')

        BindUtils.postNotifyChange(null, null, this, 'totalSize')
        BindUtils.postNotifyChange(null, null, this, 'activePage')
    }

    String denominazioneFascicolo(AlberoFascicoliNodo nodo) {
        if (nodo.fascicolo?.riservato) {
            if (nodo.fascicolo?.numero) {
                return nodo.fascicolo?.anno + "/" + (nodo.fascicolo?.numero) + " - RISERVATO"
            } else {
                return " / - RISERVATO"
            }
        } else {
            return (nodo.fascicolo?.nome) ? nodo.fascicolo?.nome : " / - " + nodo.fascicolo?.oggetto
        }
    }

    String coloreFascicolo(AlberoFascicoliNodo nodo) {
        if (nodo?.fascicolo.isVuoto()) {
            return "color:gray"
        } else {
            return "color:black"
        }
    }

    String statoFascicolo(AlberoFascicoliNodo nodo) {
        FascicoloDTO f = nodo.fascicolo
        String base = "${f.statoFascicolo}"
        return base
    }

    String annoArchiviazioneFascicolo(AlberoFascicoliNodo nodo) {
        FascicoloDTO f = nodo.fascicolo
        String base = "${f.annoArchiviazione}"
        return base
    }

    String getIconaFascicolo(AlberoFascicoliNodo nodo) {
        return fascicoloService.iconcaFascicolo(nodo?.fascicolo?.domainObject, iterFascicolare)
    }

    boolean openTreeItemFascicolo(AlberoFascicoliNodo nodo) {
        return true
    }

    boolean openTreeItem(AlberoClassificazioniNodo nodo) {
        if (daRicerca) {
            return true
        } else {
            return false
        }
    }

    String getIconaFiltri() {
        if (dataAperturaInizio || dataAperturaFine || dataCreazioneInizio || dataCreazioneFine || dataChiusuraInizio || dataChiusuraFine || usoClassifica) {
            urlIconaFiltro = "/images/afc/16x16/filter_active.png"
        } else {
            urlIconaFiltro = "/images/afc/16x16/filter.png"
        }
    }

    @Command
    void onNuovoProtocolloClassificazione(@BindingParam("categoria") String categoria) {
        AlberoClassificazioniNodo padre = selectedRecords?.size() == 1 ? selectedRecords.first() : null
        if (padre) {
            ProtocolloViewModel.apriPopup(protocolloPkgService.getIdCartella(padre?.classificazione?.idDocumentoEsterno), categoria).addEventListener(Events.ON_CLOSE) {
                BindUtils.postNotifyChange(null, null, this, 'selectedRecord')
                BindUtils.postNotifyChange(null, null, this, 'selectedRecords')
                BindUtils.postNotifyChange(null, null, this, "alberoClassificazioni")
                BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
                BindUtils.postNotifyChange(null, null, this, "selectedRecordsFasc")
            }
        } else {
            ProtocolloViewModel.apriPopup(categoria).addEventListener(Events.ON_CLOSE) {
                BindUtils.postNotifyChange(null, null, this, 'selectedRecord')
                BindUtils.postNotifyChange(null, null, this, 'selectedRecords')
                BindUtils.postNotifyChange(null, null, this, "alberoClassificazioni")
                BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
                BindUtils.postNotifyChange(null, null, this, "selectedRecordsFasc")
            }
        }
    }

    @Command
    void onNuovoProtocolloFascicolo(@BindingParam("categoria") String categoria) {
        if (selectedRecordsFasc) {
            ProtocolloViewModel.apriPopup(protocolloPkgService.getIdCartella(selectedRecordsFasc[0].fascicolo?.idDocumentoEsterno), categoria).addEventListener(Events.ON_CLOSE) {
                BindUtils.postNotifyChange(null, null, this, 'selectedRecord')
                BindUtils.postNotifyChange(null, null, this, 'selectedRecords')
                BindUtils.postNotifyChange(null, null, this, "alberoClassificazioni")
                BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
                BindUtils.postNotifyChange(null, null, this, "selectedRecordsFasc")
            }
        } else {
            AlberoClassificazioniNodo padre = selectedRecords?.size() == 1 ? selectedRecords.first() : null
            ProtocolloViewModel.apriPopup(protocolloPkgService.getIdCartella(padre?.classificazione?.idDocumentoEsterno), categoria).addEventListener(Events.ON_CLOSE) {
                BindUtils.postNotifyChange(null, null, this, 'selectedRecord')
                BindUtils.postNotifyChange(null, null, this, 'selectedRecords')
                BindUtils.postNotifyChange(null, null, this, "alberoClassificazioni")
                BindUtils.postNotifyChange(null, null, this, "alberoFascicoli")
                BindUtils.postNotifyChange(null, null, this, "selectedRecordsFasc")
            }
        }
    }
}
