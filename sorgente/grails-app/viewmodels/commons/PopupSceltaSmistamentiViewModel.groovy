package commons

import commons.menu.MenuItemProtocollo
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.zk.AlberoStrutturaOrganizzativa
import it.finmatica.gestionedocumenti.zk.AlberoStrutturaOrganizzativaNodo
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.sinonimi.RadiceAreaUtente
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubbDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.DropEvent
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaSmistamentiViewModel {

    // services
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private StrutturaOrganizzativaService strutturaOrganizzativaService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService

    // componenti
    Window self
    String urlIcone
    String labelOperazione

    boolean visualizzaBottoneInsertUnitaComponente = false
    boolean visualizzaBottoneInsertComponente = false
    String labelBottoneInsertUnitaComponente = " "

    // dati per la costruzione dell'albero
    AlberoStrutturaOrganizzativa alberoSo4
    String filtroRicerca
    int livelloApertura = 1
    private int livelloAperturaIniziale = 1
    So4UnitaPubbDTO unitaTrasmissione
    List<So4UnitaPubbDTO> listaUnitaTrasmissione

    // dati per l'assegnazione:
    String modalitaAssegnazione = DatiSmistamento.MODALITA_ASSEGNAZIONE_AGGIUNGI
    List<So4ComponentePubbDTO> listaComponentiUnita
    private So4UnitaPubbDTO unitaSmistamento

    // dati sugli smistamenti
    String tipoSmistamento
    List<DatiDestinatario> listaUnitaSelezionate
    List<DatiDestinatario> listaComponentiSelezionati
    private List<SmistamentoDTO> smistamentiEsistenti
    boolean smistaSoloUtentiAbilitati = true
    boolean tipoSmistamentoModificabile = true
    boolean tipoSmistamentoVisibile = true
    boolean unitaTrasmissioneModificabile = true

    boolean inserimentoInSchemaProtocollo = false
    boolean isSequenza = false
    boolean smartDesktop = false
    boolean fascicoloObbligatorio = false
    String indirizzoEmail
    Integer sequenza

    boolean concatenaCodiceDescrizioneUO = false

    AlberoStrutturaOrganizzativaNodo selectedItem
    So4ComponentePubbDTO componenteSelected

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window window
              , @ExecutionArgParam("smistamenti") List<SmistamentoDTO> smistamentiEsistenti
              , @ExecutionArgParam("listaUnitaTrasmissione") List<So4UnitaPubbDTO> listaUnitaTrasmissione
              , @ExecutionArgParam("tipoSmistamento") String tipoSmistamento
              , @ExecutionArgParam("tipoSmistamentoVisibile") boolean tipoSmistamentoVisibile
              , @ExecutionArgParam("unitaTrasmissioneModificabile") boolean unitaTrasmissioneModificabile
              , @ExecutionArgParam("operazione") String operazione
              , @ExecutionArgParam("isSequenza") boolean isSequenza
              , @ExecutionArgParam("smartDesktop") boolean smartDesktop
              , @ExecutionArgParam("unitaTrasmissione") So4UnitaPubbDTO unitaTrasmissione) {
        this.self = window
        this.smistamentiEsistenti = smistamentiEsistenti
        this.smistaSoloUtentiAbilitati = ImpostazioniProtocollo.CHECK_COMPONENTI.abilitato
        this.livelloApertura = ImpostazioniProtocollo.UNITA_EXPAND_LEVEL.valoreInt
        this.unitaTrasmissione = unitaTrasmissione
        this.urlIcone = "images/ags/16x16/"
        this.unitaSmistamento = unitaSmistamento
        this.unitaTrasmissioneModificabile = unitaTrasmissioneModificabile

        this.labelOperazione = MenuItemProtocollo.getLabel(operazione)
        this.tipoSmistamentoModificabile = (tipoSmistamento == null)
        this.tipoSmistamento = tipoSmistamento ?: Smistamento.COMPETENZA
        this.tipoSmistamentoVisibile = tipoSmistamentoVisibile
        this.concatenaCodiceDescrizioneUO = Impostazioni.UNITA_CONCAT_CODICE.abilitato

        this.listaUnitaTrasmissione = listaUnitaTrasmissione

        if (unitaTrasmissioneModificabile && (listaUnitaTrasmissione == null || listaUnitaTrasmissione.size() == 0)) {
            Events.postEvent(Events.ON_CLOSE, self, null)
            throw new ProtocolloRuntimeException("Operazione non consentita: Nessuna Unità di trasmissione selezionabile")
        }

        this.unitaTrasmissioneModificabile = unitaTrasmissioneModificabile && listaUnitaTrasmissione.size() > 1
        this.isSequenza = isSequenza
        this.smartDesktop = smartDesktop

        if (isSequenza) {
            this.tipoSmistamento = Smistamento.CONOSCENZA
            this.tipoSmistamentoModificabile = false
            this.tipoSmistamentoVisibile = true
        }

        livelloApertura = 1
        livelloAperturaIniziale = livelloApertura

        listaUnitaSelezionate = []
        listaComponentiSelezionati = []

        onCerca()
        if (unitaTrasmissione != null) {
            caricaComponentiUnita(unitaTrasmissione)
            cambiaUnitaTrassmissione()
        }

        if (operazione == MenuItemProtocollo.CREA_SMISTAMENTO_SCHEMA) {
            inserimentoInSchemaProtocollo = true
        }
        BindUtils.postNotifyChange(null, null, this, "unitaTrasmissioneModificabile")
    }

    @Command
    void cambiaUnitaTrassmissione() {
        if (unitaTrasmissione && tipoSmistamento == Smistamento.CONOSCENZA && tipoSmistamentoModificabile == false && tipoSmistamentoVisibile) {
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, unitaTrasmissione.codice)) {
                tipoSmistamentoModificabile = true
                tipoSmistamento = null
            }
        }
    }

    @Command
    void caricaComponentiUnita(So4UnitaPubbDTO unitaSmistamento) {
        if (filtroRicerca == null) {
            listaComponentiUnita = So4ComponentePubb.allaData(new Date()).perOttica(unitaSmistamento.ottica.codice).findAllByProgrUnita(unitaSmistamento.progr).toDTO(["soggetto.utenteAd4"]).sort {
                it.nominativoSoggetto
            }
        } else {
            listaComponentiUnita = So4ComponentePubb.allaData(new Date()).perOttica(unitaSmistamento.ottica.codice).findAllByProgrUnitaAndNominativoSoggettoIlike(unitaSmistamento.progr, "%$filtroRicerca%").toDTO(["soggetto.utenteAd4"]).sort {
                it.nominativoSoggetto
            }
        }
        BindUtils.postNotifyChange(null, null, this, "listaComponentiUnita")
    }

    boolean componenteHaRuolo(So4ComponentePubbDTO componente, So4UnitaPubbDTO unitaSmistamento) {
        if (smistaSoloUtentiAbilitati) {
            return strutturaOrganizzativaService.soggettoHaRuoloPerUnita(componente.soggetto.id, ImpostazioniProtocollo.RUOLO_ACCESSO_APPLICATIVO.valore, unitaSmistamento?.progr, unitaSmistamento.ottica.codice)
        } else {
            return true
        }
    }

    boolean isAbilitato(AlberoStrutturaOrganizzativaNodo nodo) {

        // se è una UO è sempre abilitato
        if (nodo.tipoNodo == "UO") {
            if (nodo.unitaSenzaComponenti || nodo.unitaSenzaComponentiAbilitati) {
                if (!smistaSoloUtentiAbilitati) {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        }

        // se è un nodo di ragguppamento di componenti non è draggabile
        if (nodo.tipoNodo == "COMPONENTI") {
            return false
        }

        // se non devo controllare è sempre abilitato
        if (!smistaSoloUtentiAbilitati && nodo.tipoNodo == "COMPONENTE") {
            return true
        }

        if (nodo.tipoNodo == "COMPONENTE" && nodo.conRuolo && smistaSoloUtentiAbilitati) {
            return true
        }

        return false
    }

    @NotifyChange(["alberoSo4", "livelloApertura"])
    @Command
    void onCerca() {
        if (filtroRicerca?.length() > 0) {
            // in caso di ricerca, mostro tutti i nodi aperti:
            livelloApertura = Integer.MAX_VALUE
        } else {
            // ripristino il livello di apertura di defalut
            livelloApertura = livelloAperturaIniziale
        }

        // carico l'albero dalla radice
        String ruoloAccesso = ImpostazioniProtocollo.RUOLO_ACCESSO_APPLICATIVO.valore
        boolean mostraComponenti = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.VISUALIZZA_COMPONENTI_TUTTE_UNITA)
        boolean mostraTuttoAlbero = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.VISUALIZZA_TUTTE_UNITA)
        List<Long> radici
        if (!mostraTuttoAlbero) {
            radici = gestoreCompetenze.getUnitaPerPrivilegio(springSecurityService.currentUser, RadiceAreaUtente.VISUALIZZA_AREA_UNITA)*.progr
        }
        if (mostraComponenti) {
            alberoSo4 = new AlberoStrutturaOrganizzativa(springSecurityService.principal.ottica().codice, mostraComponenti, ruoloAccesso, filtroRicerca, radici)
        } else {
            alberoSo4 = new AlberoStrutturaOrganizzativa(springSecurityService.principal.ottica().codice, gestoreCompetenze.getUnitaPerPrivilegio(springSecurityService.currentUser, PrivilegioUtente.VISUALIZZA_COMPONENTI_UNITA)*.progr, ruoloAccesso, filtroRicerca, radici)
        }
    }

    @NotifyChange(["listaUnitaSelezionate"])
    @Command
    void onAggiungiUnita(@ContextParam(ContextType.TRIGGER_EVENT) DropEvent event) {
        AlberoStrutturaOrganizzativaNodo nodo = event.dragged.value
        if (!nodo.isUnita()) {
            Clients.showNotification("Per aggiungere un componente è necessario trascinarlo sull'elenco dei componenti", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        aggiugniUnita(nodo)
    }

    /**
     *
     * @param nodo
     */
    private void aggiugniUnita(AlberoStrutturaOrganizzativaNodo nodo) {

        if (inserimentoInSchemaProtocollo && listaUnitaSelezionate?.size() > 0) {
            Clients.showNotification("E' possibile inserire solo un'unità.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        def unita = listaUnitaSelezionate.find { it.unita.progr == nodo.getUnita().progr }
        if (unita != null) {
            Clients.showNotification("Non è possibile aggiungere l'unità '${nodo.getUnita().descrizione}' perché già presente.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        def smistamento = smistamentiEsistenti.find {
            it.unitaSmistamento.progr == nodo.getUnita().progr && it.utenteAssegnatario == null && (it.statoSmistamento == Smistamento.DA_RICEVERE || it.statoSmistamento == Smistamento.IN_CARICO || it.statoSmistamento == Smistamento.CREATO)
        }
        if (smistamento != null) {
            Clients.showNotification("Non è possibile aggiungere l'unità '${nodo.getUnita().descrizione}' perché già presente in uno smistamento valido.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        //verifica se ho inserito già un componente per l'unità in questo casa diamo possibilità di scegliere se eliminare il componente e aggiungere l'unità
        List<DatiDestinatario> unitaComponente = listaComponentiSelezionati.findAll{it.unita.progr == nodo.unita.progr}
        if(unitaComponente?.size() > 0){
            String msg = creaMsgEliminaComponenteAggiungiUnita(unitaComponente)
            Messagebox.show(msg,  "Avvertenza",
                    Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (Messagebox.ON_OK == e.getName()) {
                    eliminaComponenteEAggiungiUnita(unitaComponente, nodo)
                }
                else if (Messagebox.ON_CANCEL == e.getName()) {
                    return
                }
            }
        } else {
            listaUnitaSelezionate << new DatiDestinatario(unita: nodo.getUnita())
        }
    }

    private void eliminaComponenteEAggiungiUnita(List<DatiDestinatario> unitaComponente, AlberoStrutturaOrganizzativaNodo nodo) {
        eliminaComponentiSelezionati(unitaComponente)
        listaUnitaSelezionate << new DatiDestinatario(unita: nodo.getUnita())
        BindUtils.postNotifyChange(null, null, this, "listaComponentiSelezionati")
        BindUtils.postNotifyChange(null, null, this, "listaUnitaSelezionate")
    }

    private void eliminaComponentiSelezionati(List<DatiDestinatario> unitaComponente) {
        for (DatiDestinatario datiDestinatario : unitaComponente) {
            listaComponentiSelezionati.remove(listaComponentiSelezionati.findIndexOf {
                it.componente.id == datiDestinatario.componente.id
            })
        }
    }

    private String creaMsgEliminaComponenteAggiungiUnita(List<DatiDestinatario> unitaComponente) {
        String msg = ""
        if(unitaComponente?.size() == 1){
            msg = "E' già stato selezionato il componente " + unitaComponente.get(0).componente.nominativoSoggetto + " dell'unità. Si vuole smistare il documento alla sola unità cancellando l'assegnazione al componente?"
        }
        else if(unitaComponente?.size() > 1) {
            String componenti = ""
            for(DatiDestinatario datiDestinatario : unitaComponente){
                componenti = componenti.concat(datiDestinatario.componente.nominativoSoggetto).concat(",")
            }
            msg = "Sono già stati selezionati i componenti: " +  componenti + " dell'unità. Si vuole smistare il documento alla sola unità cancellando l'assegnazione ai componenti?"
        }
        return  msg
    }

    @NotifyChange(["listaUnitaSelezionate", "listaComponentiSelezionati", "selectedItem"])
    @Command
    void onAggiungiUnitaComponente(@BindingParam("unitaComponente") AlberoStrutturaOrganizzativaNodo value) {
        if (value.unita) {
            aggiugniUnita(value)
        } else if (value.componente) {
            aggiungiComponente(value.componente)
        } else {
            Clients.showNotification("Operazione non valida", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
        }
        resetBottoneInserimentoUnitaComponente()
    }

    @NotifyChange("selectedItem")
    public void setSelectedItem(AlberoStrutturaOrganizzativaNodo value) {

        //verifica se abilitare il bottone (segue le stesse regole del drag&drop)
        if (isAbilitato(value)) {

            //Se non ho selezionato una componente e una unità ritorno e resetto il bottone (caso in cui sono sull'etichetta "componente"
            if (null == value.componente && null == value.unita) {
                visualizzaBottoneInsertUnitaComponente = false
                labelBottoneInsertUnitaComponente = " "
            }
            if (value.unita) {
                visualizzaBottoneInsertUnitaComponente = true
                labelBottoneInsertUnitaComponente = "Aggiungi Unità"
            } else if (value.componente) {
                visualizzaBottoneInsertUnitaComponente = true
                labelBottoneInsertUnitaComponente = "Aggiungi Componente "
            } else {
                visualizzaBottoneInsertUnitaComponente = false
                labelBottoneInsertUnitaComponente = " "
            }
        } else {
            visualizzaBottoneInsertUnitaComponente = false
            labelBottoneInsertUnitaComponente = " "
        }

        selectedItem = value

        BindUtils.postNotifyChange(null, null, this, "visualizzaBottoneInsertUnitaComponente")
        BindUtils.postNotifyChange(null, null, this, "labelBottoneInsertUnitaComponente")
    }

    @NotifyChange("componenteSelected")
    public void setComponenteSelected(So4ComponentePubbDTO value) {
        //Se non ho selezionato una componente e una unità ritorno e resetto il bottone (caso in cui sono sull'etichetta "componente"
        if (null != value) {
            visualizzaBottoneInsertComponente = true
        } else {
            visualizzaBottoneInsertUnitaComponente = false
        }
        componenteSelected = value

        BindUtils.postNotifyChange(null, null, this, "visualizzaBottoneInsertComponente")
    }

    @Command
    void onInserisciNota(@BindingParam("componente") DatiDestinatario datiDestinatario) {
        Window w = Executions.createComponents("/commons/popupInserimentoNota.zul", self, [nota: datiDestinatario.note, modifica: true])
        w.onClose { event ->
            datiDestinatario.note = event.data
        }
        w.doModal()
    }

    @NotifyChange(["listaUnitaSelezionate"])
    @Command
    void onEliminaUnita(@BindingParam("unita") DatiDestinatario unitaOrganizzativa) {
        listaUnitaSelezionate.remove(listaUnitaSelezionate.findIndexOf {
            it.unita.progr == unitaOrganizzativa.unita.progr
        })
    }

    @NotifyChange(["listaComponentiSelezionati"])
    @Command
    void onAggiungiComponente(@ContextParam(ContextType.TRIGGER_EVENT) DropEvent event) {
        So4ComponentePubbDTO componenteSelezionato = null
        if (event.dragged.value instanceof AlberoStrutturaOrganizzativaNodo) {
            AlberoStrutturaOrganizzativaNodo nodo = event.dragged.value
            if (!nodo.isComponente()) {
                Clients.showNotification("Per aggiungere una unità è necessario trascinarla sull'elenco delle unità", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
                return
            }

            componenteSelezionato = nodo.componente
        } else if (event.dragged.value instanceof So4ComponentePubbDTO) {
            componenteSelezionato = (So4ComponentePubbDTO) event.dragged.value
        } else {
            Clients.showNotification("Tipo di oggetto non riconosciuto: ${event.dragged.value?.class}", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 3000, true)
            return
        }

        aggiungiComponente(componenteSelezionato)
    }

    @NotifyChange(["listaComponentiSelezionati", "componenteSelected"])
    @Command
    void onAggiungiComponenteSelected(@BindingParam("componenteSelected") So4ComponentePubbDTO componente) {
        aggiungiComponente(componente)
        resettaBottoneInserimentoComponente()
    }
    /**
     *
     * @param componenteSelezionato
     */
    private void aggiungiComponente(So4ComponentePubbDTO componenteSelezionato) {

        DatiDestinatario componente = listaComponentiSelezionati.find { it.componente.id == componenteSelezionato.id }
        if (componente != null) {
            Clients.showNotification("Non è possibile aggiungere il componente ${componenteSelezionato.nominativoSoggetto} perché già presente.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        SmistamentoDTO smistamento = smistamentiEsistenti.find {
            it.unitaSmistamento.progr == componenteSelezionato.progrUnita && it.utenteAssegnatario?.id == componenteSelezionato.soggetto.utenteAd4.id && (it.statoSmistamento == Smistamento.DA_RICEVERE || it.statoSmistamento == Smistamento.IN_CARICO || it.statoSmistamento == Smistamento.CREATO)
        }
        if (smistamento != null) {
            Clients.showNotification("Non è possibile aggiungere il componente ${componenteSelezionato.nominativoSoggetto} perché già presente in uno smistamento valido.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        //verifica se ho inserito già l'unità del componente, in questo casa diamo possibilità di scegliere se eliminare l'unità e aggiungere il compoenente
        DatiDestinatario componenteUnita = listaUnitaSelezionate.find {it.unita.progr == componenteSelezionato.progrUnita}
        if(componenteUnita != null){
            String msg = "E' già stata selezionata l'unità " + componenteUnita.unita.descrizione + " di cui il componente " + componenteSelezionato.nominativoSoggetto + " fa parte. Si vuole assegnare il documento a " +
                         componenteSelezionato.nominativoSoggetto + ", cancellando lo smistamento all'intera unità ?"
            Messagebox.show(msg, "Avvertenza",
                    Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (Messagebox.ON_OK == e.getName()) {
                    listaUnitaSelezionate.remove(listaUnitaSelezionate.findIndexOf {
                        it.unita.progr == componenteUnita.unita.progr
                    })
                    listaComponentiSelezionati << new DatiDestinatario(utente: Ad4Utente.get(componenteSelezionato.soggetto.utenteAd4.id)?.toDTO(), componente: componenteSelezionato, unita: So4UnitaPubb.getUnita(componenteSelezionato.progrUnita, componenteSelezionato.ottica.codice).get().toDTO())
                    BindUtils.postNotifyChange(null, null, this, "listaUnitaSelezionate")
                    BindUtils.postNotifyChange(null, null, this, "listaComponentiSelezionati")
                }
                else if (Messagebox.ON_CANCEL == e.getName()) {
                    return
                }
            }
        } else {
            listaComponentiSelezionati << new DatiDestinatario(utente: Ad4Utente.get(componenteSelezionato.soggetto.utenteAd4.id)?.toDTO(), componente: componenteSelezionato, unita: So4UnitaPubb.getUnita(componenteSelezionato.progrUnita, componenteSelezionato.ottica.codice).get().toDTO())
        }
    }

    @NotifyChange(["listaComponentiSelezionati"])
    @Command
    void onEliminaComponente(@BindingParam("componente") DatiDestinatario componente) {
        listaComponentiSelezionati.remove(listaComponentiSelezionati.findIndexOf {
            it.componente.id == componente.componente.id
        })
    }

    @Command
    void onAnnulla() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onSelezionaDestinatari() {
        boolean inserimento = true
        String componentePresente = ""

        DatiSmistamento ds = new DatiSmistamento(tipoSmistamento: tipoSmistamento
                , destinatari: (listaUnitaSelezionate + listaComponentiSelezionati)
                , unitaTrasmissione: unitaTrasmissione
                , utenteTrasmissione: springSecurityService.currentUser.toDTO()
                , modalitaAssegnazione: modalitaAssegnazione)

        if (inserimentoInSchemaProtocollo) {
            ds.fascicoloObbligatorio = fascicoloObbligatorio
            ds.indirizzoEmail = indirizzoEmail
            if (tipoSmistamento == Smistamento.COMPETENZA) {
                ds.sequenza = sequenza
            }
        }

        Events.postEvent(Events.ON_CLOSE, self, ds)
    }

    @Command
    void onSalvaENuovo() {
        boolean inserimento = true
        String componentePresente = ""

        DatiSmistamento ds = new DatiSmistamento(tipoSmistamento: tipoSmistamento
                , destinatari: (listaUnitaSelezionate + listaComponentiSelezionati)
                , unitaTrasmissione: unitaTrasmissione
                , utenteTrasmissione: springSecurityService.currentUser.toDTO()
                , modalitaAssegnazione: modalitaAssegnazione
                , salvaENuovo: true)

        if (inserimentoInSchemaProtocollo) {
            ds.fascicoloObbligatorio = fascicoloObbligatorio
            ds.indirizzoEmail = indirizzoEmail
            if (tipoSmistamento == Smistamento.COMPETENZA) {
                ds.sequenza = sequenza
            }
        }

        Events.postEvent(Events.ON_CLOSE, self, ds)
    }

    static class DatiSmistamento {

        public static final String MODALITA_ASSEGNAZIONE_AGGIUNGI = "AGGIUNGI"
        public static final String MODALITA_ASSEGNAZIONE_SOSTITUISCI = "SOSTITUISCI"

        String tipoSmistamento
        List<DatiDestinatario> destinatari
        So4UnitaPubbDTO unitaTrasmissione
        Ad4UtenteDTO utenteTrasmissione
        String modalitaAssegnazione
        boolean salvaENuovo = false

        boolean fascicoloObbligatorio = false
        String indirizzoEmail
        Integer sequenza
    }

    static class DatiDestinatario {
        So4ComponentePubbDTO componente
        So4UnitaPubbDTO unita
        Ad4UtenteDTO utente
        String note
    }

    /**
     * Resetto la visibilita, la label del bottone e il valore selezionato
     */
    private void resetBottoneInserimentoUnitaComponente() {
        visualizzaBottoneInsertUnitaComponente = false
        labelBottoneInsertUnitaComponente = " "
        selectedItem = null

        BindUtils.postNotifyChange(null, null, this, "visualizzaBottoneInsertUnitaComponente")
        BindUtils.postNotifyChange(null, null, this, "labelBottoneInsertUnitaComponente")
    }

    /**
     * Resetto la visibilita e il valore selezionato (per popup assegnatari)
     */
    private void resettaBottoneInserimentoComponente() {
        visualizzaBottoneInsertComponente = false
        componenteSelected = null

        BindUtils.postNotifyChange(null, null, this, "visualizzaBottoneInsertComponente")
    }

    public AlberoStrutturaOrganizzativaNodo getSelectedItem() {
        return selectedItem
    }

    So4ComponentePubbDTO getComponenteSelected() {
        return componenteSelected
    }
}
