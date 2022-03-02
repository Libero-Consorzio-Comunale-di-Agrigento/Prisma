package it.finmatica.protocollo.titolario

import commons.menu.MenuItem
import commons.menu.MenuItemFascicolo
import commons.menu.MenuItemProtocollo
import groovy.sql.GroovyRowResult
import groovy.util.logging.Slf4j
import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.documenti.TipoCollegamentoDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.dizionari.FiltriDocumentiEsterni
import it.finmatica.protocollo.dizionari.StatoScarto
import it.finmatica.protocollo.dizionari.StatoScartoDTO
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.DocumentoSoggettoRepository
import it.finmatica.protocollo.documenti.ProtocolloRepository
import it.finmatica.protocollo.documenti.ProtocolloStoricoService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.scarto.DocumentoDatiScarto
import it.finmatica.protocollo.documenti.scarto.DocumentoDatiScartoDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.storico.StoricoProtocolloViewModel
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioRepository
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.FunzioniService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.gdm.converters.MovimentoConverter
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.menu.MenuItemFasicolocoService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.trasco.TrascoService
import it.finmatica.protocollo.zk.components.smistamenti.SmistamentiComponent
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.hibernate.SessionFactory
import org.hibernate.envers.RevisionType
import org.springframework.beans.factory.annotation.Autowired
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Combobox
import org.zkoss.zul.Filedownload
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Menupopup
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

import java.text.SimpleDateFormat
import java.util.regex.Matcher
import java.util.regex.Pattern

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class FascicoloDettaglioViewModel extends DizionariDettaglioViewModel {

    static final String reportNameFascicoloConAtti = 'FascicoloConAtti'
    static final String reportNameCopertinaFascicolo = 'Copertina_Fascicolo'

    static final String relazioneAttiva = 'Relazione Attiva'
    static final String relazionePassiva = 'Relazione Passiva'

    static final String ANNO_DESC_DATA_ASC = 'ANNO_DESC_DATA_ASC'
    static final String ANNO_DATA_ASC = 'ANNO_DATA_ASC'
    static final String ANNO_DATA_DESC = 'ANNO_DATA_DESC'

    static final String LABEL_ANNO_DESC_DATA_ASC = 'Decrescente per Anno e crescente per Data'
    static final String LABEL_ANNO_DATA_ASC = 'Crescente per Anno e Data'
    static final String LABEL_ANNO_DATA_DESC = 'Decrescente per Anno e Data'

    static final String MODELLO_PROTOCOLLO = CategoriaProtocollo.CATEGORIA_PROTOCOLLO.codiceModelloGdm
    static final String MODELLO_LETTERA = CategoriaProtocollo.CATEGORIA_LETTERA.codiceModelloGdm
    static final String MODELLO_EMAIL = CategoriaProtocollo.CATEGORIA_MEMO_PROTOCOLLO.codiceModelloGdm
    static final String MODELLO_DA_FASCICOLARE = CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codiceModelloGdm
    static final String MODELLO_REGISTRO_GIORNALIERO = CategoriaProtocollo.CATEGORIA_REGISTRO_GIORNALIERO.codiceModelloGdm
    static final String MODELLO_PROVVEDIMENTO = CategoriaProtocollo.CATEGORIA_PROVVEDIMENTO.codiceModelloGdm
    static final String MODELLO_PROTOCOLLO_EMERGENZA = CategoriaProtocollo.CATEGORIA_EMERGENZA.codiceModelloGdm
    static final String MODELLO_PROTOCOLLO_INTEROPERABILITA = CategoriaProtocollo.CATEGORIA_PEC.codiceModelloGdm
    static final String MODELLO_DELIBERA = "DELIBERA"
    static final String MODELLO_DETERMINA = "DETERMINA"
    static final String MODELLO_PROPOSTA_DELIBERA = "PROPOSTA_DELIBERA"
    static final String MODELLO_CONTRATTO = "CONTRATTO"
    static final String MODELLO_PROCEDURA = "PROCEDURA"

    static final String TIPOLOGIA_PROTOCOLLO = "protocollo"
    static final String TIPOLOGIA_PROTOCOLLO_INTEROPERABILITA = "pec"
    static final String TIPOLOGIA_LETTERA = "lettera"
    static final String TIPOLOGIA_EMAIL = "memo"
    static final String TIPOLOGIA_DA_FASCICOLARE = "da_non_protocollare"
    static final String TIPOLOGIA_DOCUMENTO = "doc"
    static final String TIPOLOGIA_REGISTRO_GIORNALIERO = "reg_giornaliero"
    static final String TIPOLOGIA_PROVVEDIMENTO = "provvedimento"
    static final String TIPOLOGIA_PROTOCOLLO_EMERGENZA = "emergenza"
    static final String TIPOLOGIA_DELIBERA = "doc"
    static final String TIPOLOGIA_DETERMINA = "doc"
    static final String TIPOLOGIA_PROPOSTA_DELIBERA = "doc"
    static final String TIPOLOGIA_CONTRATTO = "doc"
    static final String TIPOLOGIA_PROCEDURA = "doc"

    static final String TOOLTIP_PROTOCOLLO = "Protocollo"
    static final String TOOLTIP_PROTOCOLLO_INTEROPERABILITA = "Protocollo da Email"
    static final String TOOLTIP_LETTERA = "Lettera"
    static final String TOOLTIP_EMAIL = "Messaggio Email"
    static final String TOOLTIP_DA_FASCICOLARE = "Documento da Fascicolare"
    static final String TOOLTIP_DOCUMENTO = "Documento"
    static final String TOOLTIP_REGISTRO_GIORNALIERO = "Registro Giornaliero"
    static final String TOOLTIP_PROVVEDIMENTO = "Provvedimento"
    static final String TOOLTIP_PROTOCOLLO_EMERGENZA = "Protocollo di Emergenza"
    static final String TOOLTIP_DELIBERA = "Delibera"
    static final String TOOLTIP_DETERMINA = "Determina"
    static final String TOOLTIP_PROPOSTA_DELIBERA = "Proposta di Delibera"
    static final String TOOLTIP_CONTRATTO = "Contratto"
    static final String TOOLTIP_PROCEDURA = "Procedura"

    static final String TOOLTIP_UBICATO_ALTROVE = " ubicato altrove"

    @WireVariable
    SuccessHandler successHandler
    @WireVariable
    FascicoloService fascicoloService
    @WireVariable
    DocumentaleService documentaleService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    FunzioniService funzioniService
    @WireVariable
    ClassificazioneService classificazioneService
    @WireVariable
    ProtocolloRepository protocolloRepository
    @WireVariable
    So4Repository so4Repository
    @WireVariable
    FascicoloRepository fascicoloRepository
    @WireVariable
    DocumentoSoggettoRepository documentoSoggettoRepository
    @WireVariable
    MenuItemFasicolocoService menuItemFasicolocoService
    @WireVariable
    StrutturaOrganizzativaService strutturaOrganizzativaService
    @WireVariable
    SmistamentoService smistamentoService
    @WireVariable
    TipologiaSoggettoService tipologiaSoggettoService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    AllegatoProtocolloService allegatoProtocolloService
    @WireVariable
    private DocumentoTitolarioRepository documentoTitolarioRepository
    @WireVariable
    private DateService dateService
    @WireVariable
    private ProtocolloGdmService protocolloGdmService
    @WireVariable
    private ProtocolloStoricoService protocolloStoricoService
    @WireVariable
    TrascoService trascoService
    @Autowired
    SessionFactory sessionFactory

    // componenti
    @Wire("#mpAllegati")
    Menupopup popupAllegati
    def listaAllegati = []

    def titolario
    FascicoloDTO selectedRecord

    String datePattern = 'dd/MM/yyyy'
    Date now = new Date()

    FascicoloDettaglioViewModel that
    boolean nuovo
    boolean duplica
    boolean forzaChiusura
    boolean visualizzaNote

    List<So4UnitaPubbDTO> listaUnitaCreazione

    Boolean standalone
    boolean smistamentiAbilitati = ImpostazioniProtocollo.ITER_FASCICOLI.abilitato
    boolean chiusa = false
    boolean isSequenza = false
    boolean isSub = false
    boolean visCodiceUo = Impostazioni.UNITA_CONCAT_CODICE.abilitato
    boolean visNumeraAnnoProssimo

    String codice
    String utenteCreazione
    boolean onlyVisualizzazione
    Integer annoCorrente = now.year + 1900

    String widthZul = "100%"
    String heightZul = "100%"

    def mappaListaStati = [Fascicolo.STATO_CORRENTE,
                           Fascicolo.STATO_DEPOSITO,
                           Fascicolo.STATO_STORICO]
    List<Integer> listaAnno = []

    Map competenze = [:]
    Map soggetti = [:]

    // smistamenti
    @Wire("#smistamenti")
    SmistamentiComponent smistamentoComponent
    List<SmistamentoDTO> listaSmistamentiDto = []
    List<SmistamentoDTO> listaSmistamentiStoriciDto = []
    boolean creaSmistamentiAbilitato = true

    // menu
    @Wire("#menuFunzionalita")
    MenuItemFascicolo menuFunzionalita

    // collegamenti
    List<TipoCollegamentoDTO> listaTipiCollegamento
    TipoCollegamentoDTO tipoCollegamento
    ClassificazioneDTO classificazioneCollegamento
    FascicoloDTO fascicoloCollegamento
    List<String> listTipologiaRelazione = [relazioneAttiva, relazionePassiva]
    String tipologiaRelazione = relazioneAttiva
    Set<DocumentoCollegatoDTO> listaCollegamenti = [] as Set
    Set<DocumentoCollegatoDTO> listaCollegamentiNew = [] as Set

    // documenti in fascicolo e sub
    List<Map<String, String>> documentiInFascicolo = []
    List listaDocumentiInFascicoloZul = []
    List documentiSelezionati = []
    List subSelezionati = []
    int pageSize = AfcAbstractGrid.PAGE_SIZE_DEFAULT
    int activePage = 0
    int totalSize = 0
    String filtro
    boolean visualizzaTutti = false
    String pattern = "dd/MM/yyyy"
    List<String> listTipologiaOrdinamento = [ANNO_DESC_DATA_ASC, ANNO_DATA_ASC, ANNO_DATA_DESC]
    String tipologiaOrdinamento = ImpostazioniProtocollo.ORDINAMENTO_FASC.valore.toString()
    List<FascicoloDTO> listaDocumentiSubZul = []

    // storico
    Date ricercaDal
    Date ricercaAl
    def filtroSelezionato
    List filtri
    List<StoricoProtocolloViewModel.DatoStoricoTreeNode> datiStorici = []

    // scarto
    List<StatoScartoDTO> listaStatiScarto

    // paginazione elenco sub
    int pageSizeSub = AfcAbstractGrid.PAGE_SIZE_DEFAULT
    int activePageSub = 0
    int totalSizeSub = 0

    static Window apriPopup(Map parametri) {
        Window window
        window = Executions.createComponents("/titolario/fascicoloDettaglio.zul", null, parametri)
        window.doModal()
        return window
    }

    @NotifyChange(["selectedRecord"])
    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") long id,
         @ExecutionArgParam('titolario') def titolario,
         @ExecutionArgParam('standalone') Boolean standalone,
         @ExecutionArgParam('duplica') Boolean duplica,
         @ExecutionArgParam('isNuovoRecord') Boolean isNuovoRecord,
         @ExecutionArgParam('forzaChiusura') Boolean forzaChiusura) {

        this.self = w
        this.that = this
        this.duplica = duplica
        if (duplica == null) {
            duplica = false
        }
        this.forzaChiusura = forzaChiusura
        if (forzaChiusura == null) {
            forzaChiusura = false
        }

        this.standalone = standalone ? Boolean.TRUE : Boolean.FALSE
        this.titolario = titolario

        filtroSelezionato = [codice: "_TUTTI", titolo: "-- Tutti i Campi --", descrizione: "Mostra tutti i campi", filtri: ["OGGETTO_MOD", "RESPONSABILE_MOD", "RISERVATO_MOD", "DIGITALE_MOD", "STATO_FASCICOLO_MOD", "ANNO_ARCHIVIAZIONE_MOD", "TOPOGRAFIA_MOD", "NOTE_MOD", "DATA_APERTURA_MOD", "DATA_CHIUSURA_MOD", "UNITA_PROGR_MOD"]]
        this.filtri = [filtroSelezionato]

        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.CFFUTURO) && ImpostazioniProtocollo.ITER_FASCICOLI.abilitato == false) {
            visNumeraAnnoProssimo = true
        }

        visualizzaNote = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.VISUALIZZA_NOTE)
        competenze = [lettura: true, modifica: true, cancellazione: true]
        refreshMenu()

        listaTipiCollegamento = fascicoloService.getTipiCollegamentoUtilizzabili()?.toDTO()
        tipoCollegamento = TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_FASC_COLLEGATO)?.toDTO()

        if (id != -1) {
            // in modifica
            selectedRecord = Fascicolo.get(id).toDTO()

            onlyVisualizzazione = !privilegioUtenteService.isCompetenzaModificaFascicolo(selectedRecord?.domainObject)
            if (onlyVisualizzazione) {
                competenze = [lettura: false, modifica: true, cancellazione: true]
            }

            selectedRecord.classificazione = Classificazione.get(selectedRecord.classificazione?.id).toDTO()

            if (selectedRecord?.datiScarto) {
                selectedRecord?.datiScarto = DocumentoDatiScarto.get(selectedRecord?.datiScarto?.id).toDTO()
            }

            So4UnitaPubbDTO UoCreazione = documentoSoggettoRepository.getUnita(selectedRecord.id, TipoSoggetto.UO_CREAZIONE).toDTO()
            So4UnitaPubbDTO UoCompetenza = documentoSoggettoRepository.getUnita(selectedRecord.id, TipoSoggetto.UO_COMPETENZA).toDTO()

            soggetti = tipologiaSoggettoService.calcolaSoggetti(selectedRecord, fascicoloService.getTipologia())
            soggetti?.UO_CREAZIONE?.unita = UoCreazione
            soggetti?.UO_COMPETENZA?.unita = UoCompetenza

            utenteCreazione = selectedRecord.utenteIns?.domainObject.nominativoSoggetto

            refreshSmistamenti()
            refreshListaCollegamenti()
        } else {
            // nuovo record
            selectedRecord = new FascicoloDTO()

            selectedRecord.dataCreazione = new Date()
            selectedRecord.dataApertura = new Date()
            selectedRecord.dataStato = new Date()
            selectedRecord.statoFascicolo = Fascicolo.STATO_CORRENTE
            selectedRecord.movimento = Fascicolo.MOVIMENTO_INTERNO
            selectedRecord.annoArchiviazione = annoCorrente

            if (titolario?.id) {
                if (titolario?.domainObject instanceof Classificazione) {
                    log.info("Creo Fascicolo da una classifica")
                    // provengo da classificazione
                    selectedRecord.classificazione = Classificazione.get(titolario?.id).toDTO()
                    setListaNumerazioneAnno(selectedRecord.classificazione?.domainObject, null)
                } else {
                    // provengo da fascicolo, duplico o creo un sub
                    selectedRecord.classificazione = Classificazione.get(titolario?.classificazione.id).toDTO()

                    if (!duplica) {
                        log.info("Creo Fascicolo da un fascicolo")
                        isSub = true
                        setListaNumerazioneAnno(selectedRecord.classificazione?.domainObject, titolario?.id)
                        selectedRecord.anno = titolario.anno
                        //selectedRecord.oggetto = titolario.oggetto
                    } else {
                        log.info("Duplico un fasicolo")
                        selectedRecord.anno = titolario.anno
                        selectedRecord.oggetto = titolario.oggetto
                        selectedRecord.topografia = titolario.topografia
                        selectedRecord.note = titolario.note
                        selectedRecord.riservato = titolario.riservato
                        selectedRecord.annoArchiviazione = titolario.annoArchiviazione
                        selectedRecord.dataArchiviazione = titolario.dataArchiviazione
                        selectedRecord.dataChiusura = titolario.dataChiusura
                        selectedRecord.digitale = titolario.digitale
                        selectedRecord.responsabile = titolario.responsabile
                        setListaNumerazioneAnno(selectedRecord.classificazione?.domainObject, null)
                        selectedRecord.anno = titolario.anno
                    }
                }
            }

            String search = ""
            listaUnitaCreazione = so4Repository.getListUnita(springSecurityService.currentUser, PrivilegioUtente.CREF, "%" + search + "%").toDTO()
            if (listaUnitaCreazione.size() > 0) {
                soggetti = tipologiaSoggettoService.calcolaSoggetti(selectedRecord, fascicoloService.getTipologia())
                soggetti?.UO_CREAZIONE?.unita = listaUnitaCreazione[0]
                soggetti?.UO_COMPETENZA?.unita = listaUnitaCreazione[0]
            }
        }

        refreshDatiScarto()
        onAggiornaMaschera()
    }

    @AfterCompose
    void afterCompose() {
        Selectors.wireComponents(self, this, false)
        // aggiorno subito il menu funzionalità
        menuFunzionalita.setFascicoloDTO(selectedRecord)
        refreshMenu()
    }

    @Command
    boolean onCrea(@BindingParam("creazione") boolean creazione) {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return false
        }

        // CONTROLLO GLI SMISTAMENTI
        if (smistamentiAbilitati && selectedRecord?.smistamenti?.size() > 0) {
            Integer smistamentiCompetenzaAttivi = 0
            selectedRecord?.smistamenti?.each {
                if (it.tipoSmistamento == Smistamento.COMPETENZA && (it.statoSmistamento == Smistamento.DA_RICEVERE || it.statoSmistamento == Smistamento.IN_CARICO || it.statoSmistamento == Smistamento.CREATO)) {
                    smistamentiCompetenzaAttivi++
                }
            }
            if (smistamentiCompetenzaAttivi > 1) {
                Clients.showNotification("Non è possibile salvare il fascicolo. Deve essere presente solo uno smistamento per COMPETENZA valido.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
                return
            }
        }

        selectedRecord = fascicoloService.salva(selectedRecord, soggetti, titolario, creazione, duplica, listaCollegamentiNew.toList())
        successHandler.showMessage("Fascicolo salvato")

        onAggiornaMaschera()

        // serve per riallineare la pulsantiera dopo la crezione e forzare la chiusura
        if (creazione) {
            widthZul = "99.9%"
            heightZul = "99.9%"
            BindUtils.postNotifyChange(null, null, this, "widthZul")
            BindUtils.postNotifyChange(null, null, this, "heightZul")
            if (forzaChiusura) {
                Events.postEvent(Events.ON_CLOSE, self, [fascicolo: selectedRecord])
            }
        }

        return true
    }

    Collection<String> validaMaschera() {
        List<String> messaggi = []

        if (!selectedRecord.anno && !selectedRecord.numeroProssimoAnno) {
            messaggi << "L'Anno Fascicolo è obbligatorio"
        }
        if (!selectedRecord.oggetto) {
            messaggi << "L'Oggetto è obbligatorio"
        }
        if (!selectedRecord.classificazione) {
            messaggi << "La Classifica è obbligatoria"
        }
        if (!selectedRecord.classificazione.contenitoreDocumenti) {
            messaggi << "La Classifica scelta non può contenere Fascicoli"
        }
        if (!soggetti?.UO_CREAZIONE?.unita) {
            messaggi << "L'Unità di Creazione è obbligatoria"
        }
        if (!soggetti?.UO_COMPETENZA?.unita) {
            messaggi << "L'Unità Competente è obbligatoria"
        }

        return messaggi
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    String getDescrizione(ClassificazioneDTO dto) {
        return "${dto ? "${dto.codice} " : ''}"
    }

    @Command
    void onResponsabile() {
        Window w = Executions.createComponents("/commons/popupSceltaComponenteStruttura.zul", self, [:])
        w.doModal()
        w.onClose { Event event ->
            selectedRecord.responsabile = event.data
            BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        }
    }

    @Command
    void onCambioStato() {
        selectedRecord.dataStato = new Date()
        if (selectedRecord.statoFascicolo == Fascicolo.STATO_CORRENTE) {
            selectedRecord.dataChiusura = null
        }
        if (selectedRecord.statoFascicolo != Fascicolo.STATO_CORRENTE && selectedRecord.dataChiusura == null) {
            selectedRecord.dataChiusura = new Date()
            selectedRecord.annoArchiviazione = annoCorrente.toString()
            selectedRecord.dataArchiviazione = new Date()
        }
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }

    @Command
    void onCheckRiservato() {
        if (!selectedRecord.riservato) {
            Messagebox.show("Rendendo il fascicolo non riservato, tutti i documenti che ne fanno parte saranno considerati non riservati. \n" +
                    "(Faranno eccezione i documenti riservati di per sé o inseriti in altri fascicoli riservati.) \n" +
                    "Si vuole continuare?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (e.getName() == Messagebox.ON_CANCEL) {
                    selectedRecord.riservato = true
                    BindUtils.postNotifyChange(null, null, this, "selectedRecord")
                }
            }
        }

        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }

    @Command
    void onCheckNumeroProssimoAnno() {
        if (selectedRecord.numeroProssimoAnno) {
            // check
            listaAnno = []
            selectedRecord.anno = null
        } else {
            // uncheck
            listaAnno = []
            selectedRecord.anno = null
            setListaNumerazioneAnno(selectedRecord.classificazione?.domainObject, null)
        }
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        BindUtils.postNotifyChange(null, null, this, "listaAnno")
    }

    @Command
    void onSelectClassifica(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        ClassificazioneDTO classificazioneDTO = event.data
        if (classificazioneDTO) {
            setListaNumerazioneAnno(classificazioneDTO?.domainObject, null)
        }
    }

    void setListaNumerazioneAnno(Classificazione classificazione, Long idPadre) {
        List<Integer> anniNumerazioneClassifica = fascicoloService.anniNumerazione(classificazione).unique()?.sort(true, {
            -it
        })

        anniNumerazioneClassifica.each {
            listaAnno << it?.toInteger()
        }

        if (!idPadre) {
            selectedRecord.anno = listaAnno.max { it <= annoCorrente }
        } else {
            // di default setto l'anno del fascicolo padre
            selectedRecord.anno = fascicoloRepository.getAnnoFascicolo(idPadre)
        }
        BindUtils.postNotifyChange(null, null, this, 'listaAnno')
        BindUtils.postNotifyChange(null, null, this, 'soggetti')
    }

    Long getIdTipologia() {
        return fascicoloService.getTipologia()?.id
    }

    @Command
    void onAggiornaSoggettoUoCreazione(@BindingParam("unita") unita) {
        if (unita != null) {
            soggetti?.UO_CREAZIONE?.unita = unita
        }
    }

    @Command
    void onAggiornaSoggettoUoCompetenza(@BindingParam("unita") unita) {
        if (unita != null) {
            soggetti?.UO_COMPETENZA?.unita = unita
        }
    }

    // smistamenti
    void refreshSmistamentiECompetenze(FascicoloDTO fascicolo, So4UnitaPubbDTO unitaCreazione = null) {
        fascicolo.smistamenti = listaSmistamentiDto
        visualizzaNote = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.VISUALIZZA_NOTE)

        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiDto")
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        BindUtils.postNotifyChange(null, null, this, "visualizzaNote")
        BindUtils.postNotifyChange(null, null, this, "isSequenza")

        aggiornaMaschera(selectedRecord?.domainObject, false)
    }

    void refreshSmistamenti() {
        listaSmistamentiDto = smistamentoService.getSmistamentiAttivi(selectedRecord.domainObject).toDTO(["utenteTrasmissione", "unitaTrasmissione", "utentePresaInCarico", "utenteEsecuzione", "utenteAssegnante", "utenteAssegnatario", "utenteRifiuto", "unitaSmistamento"])
        selectedRecord.smistamenti = listaSmistamentiDto

        listaSmistamentiStoriciDto = smistamentoService.getSmistamentiStorici(selectedRecord.domainObject.id).toDTO(["utenteTrasmissione", "unitaTrasmissione", "utentePresaInCarico", "utenteEsecuzione", "utenteAssegnante", "utenteAssegnatario", "utenteRifiuto", "unitaSmistamento"])
        if (listaSmistamentiStoriciDto == null) {
            listaSmistamentiStoriciDto = []
        }
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiDto")
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiStoriciDto")
    }

    @Command
    void onAggiornaMaschera() {
        aggiornaMaschera(selectedRecord?.domainObject, true)
    }

    void aggiornaMaschera(Fascicolo f, boolean aggiornoSmistamenti) {
        if (!f) {
            return
        }

        refreshMenu()
        if (aggiornoSmistamenti) {
            refreshSmistamenti()
        }

        utenteCreazione = selectedRecord.utenteIns?.domainObject.nominativoSoggetto
        onRicercaStorico()
        refreshDatiScarto()
        refreshIdDocumentoEsterno()

        BindUtils.postNotifyChange(null, null, this, 'utenteCreazione')
        BindUtils.postNotifyChange(null, null, this, 'listaAnno')
        BindUtils.postNotifyChange(null, null, this, 'soggetti')
        BindUtils.postNotifyChange(null, null, this, 'selectedRecord')
        BindUtils.postNotifyChange(null, null, this, 'listaSmistamentiDto')
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiStoriciDto")
        BindUtils.postNotifyChange(null, null, this, 'listaCollegamenti')
        BindUtils.postNotifyChange(null, null, this, 'datiStorici')
        BindUtils.postNotifyChange(null, null, this, "visualizzaNote")
        BindUtils.postNotifyChange(null, null, this, "isSequenza")
        BindUtils.postNotifyChange(null, null, this, "isSub")
        BindUtils.postNotifyChange(null, null, this, "listaStatiScarto")
        BindUtils.postNotifyChange(null, null, this, "onlyVisualizzazione")
    }

    // elenco sub
    @Command
    void onSelectElencoSub() {
        refreshIdDocumentoEsterno()
        if (listaDocumentiSubZul.size() == 0) {
            caricaListaDocumentiSub()
        }
    }

    @Command
    void onPaginaSub() {
        caricaListaDocumentiSub()
    }

    @Command
    void apriFascicoloSub() {
        apriPopup([id: subSelezionati[0].id, isNuovoRecord: false, standalone: true, titolario: null]).doModal()
    }

    @Command
    void apriFascicoloSubDoubleClick(@BindingParam("documento") Long idDocumento) {
        apriPopup([id: idDocumento, isNuovoRecord: false, standalone: true, titolario: null]).doModal()
    }

    private void caricaListaDocumentiSub() {

        PagedResultList lista = Fascicolo.createCriteria().list(max: pageSizeSub, offset: pageSizeSub * activePageSub) {
            eq("idFascicoloPadre", selectedRecord?.id)
            order('numeroOrd', 'asc')
        }

        totalSizeSub = lista.totalCount
        listaDocumentiSubZul = new ListModelList<Fascicolo>(lista.toDTO())

        BindUtils.postNotifyChange(null, null, this, "listaDocumentiSubZul")
        BindUtils.postNotifyChange(null, null, this, "totalSizeSub")
    }

    // documenti in fascicolo
    @Command
    void onSelectDocumentiInFascicolo() {
        refreshIdDocumentoEsterno()
        if (listaDocumentiInFascicoloZul.size() == 0) {
            caricaListaDocumentiInFascicolo()
        }
    }

    @Command
    void changeOrdinamento() {
        caricaListaDocumentiInFascicolo()
    }

    private void caricaListaDocumentiInFascicolo(String filterCondition = filtro) {
        String area = ""
        String modello = ""
        String tipologia = ""
        String tooltip = ""
        String s = ""
        String value = ""
        String valoreCampo = ""
        listaDocumentiInFascicoloZul = []
        boolean bozza

        if (!selectedRecord?.idDocumentoEsterno) {
            return
        }

        // mappa campi da leggere
        List<Map<String, String>> campiModello = []
        campiModello.addAll(FiltriDocumentiEsterni.createCriteria().list {
        }.collect {
            [modello: it.chiave, descrizione: it.descrizione, campoDataOrdinamento: it.campoDataOrdinamento]
        })

        it.finmatica.smartdoc.api.struct.Documento documentoSmartFascicolo = protocolloGdmService.buildDocumentoSmart(selectedRecord?.idDocumentoEsterno, false, true, true)
        if (documentoSmartFascicolo) {

            for (it.finmatica.smartdoc.api.struct.Documento docSmart in documentoSmartFascicolo.documentiFigli.findAll {
                it.isFoglia()
            }) {

                modello = docSmart.mappaChiaviExtra.get("MODELLO")
                area = docSmart.mappaChiaviExtra.get("AREA")
                bozza = false

                if (modello == MODELLO_PROTOCOLLO) {
                    tipologia = TIPOLOGIA_PROTOCOLLO
                    tooltip = TOOLTIP_PROTOCOLLO
                } else if (modello == MODELLO_LETTERA) {
                    tipologia = TIPOLOGIA_LETTERA
                    tooltip = TOOLTIP_LETTERA
                } else if (modello == MODELLO_DA_FASCICOLARE) {
                    tipologia = TIPOLOGIA_DA_FASCICOLARE
                    tooltip = TOOLTIP_DA_FASCICOLARE
                } else if (modello == MODELLO_EMAIL) {
                    tipologia = TIPOLOGIA_EMAIL
                    tooltip = TOOLTIP_EMAIL
                } else if (modello == MODELLO_PROVVEDIMENTO) {
                    tipologia = TIPOLOGIA_PROVVEDIMENTO
                    tooltip = TOOLTIP_PROVVEDIMENTO
                } else if (modello == MODELLO_REGISTRO_GIORNALIERO) {
                    tipologia = TIPOLOGIA_REGISTRO_GIORNALIERO
                    tooltip = TOOLTIP_REGISTRO_GIORNALIERO
                } else if (modello == MODELLO_PROTOCOLLO_EMERGENZA) {
                    tipologia = TIPOLOGIA_PROTOCOLLO_EMERGENZA
                    tooltip = TOOLTIP_PROTOCOLLO_EMERGENZA
                } else if (modello == MODELLO_PROTOCOLLO_INTEROPERABILITA) {
                    tipologia = TIPOLOGIA_PROTOCOLLO_INTEROPERABILITA
                    tooltip = TOOLTIP_PROTOCOLLO_INTEROPERABILITA
                } else if (modello == MODELLO_CONTRATTO) {
                    tipologia = TIPOLOGIA_CONTRATTO
                    tooltip = TOOLTIP_CONTRATTO
                } else if (modello == MODELLO_DELIBERA) {
                    tipologia = TIPOLOGIA_DELIBERA
                    tooltip = TOOLTIP_PROTOCOLLO
                } else if (modello == MODELLO_DETERMINA) {
                    tipologia = TIPOLOGIA_DETERMINA
                    tooltip = TOOLTIP_DETERMINA
                } else if (modello == MODELLO_PROPOSTA_DELIBERA) {
                    tipologia = TIPOLOGIA_PROPOSTA_DELIBERA
                    tooltip = TOOLTIP_PROPOSTA_DELIBERA
                } else if (modello == MODELLO_PROCEDURA) {
                    tipologia = TIPOLOGIA_PROCEDURA
                    tooltip = TOOLTIP_PROCEDURA
                } else {
                    tipologia = TIPOLOGIA_DOCUMENTO
                    tooltip = TOOLTIP_DOCUMENTO
                }

                campiModello.findAll { it.modello == area + "@" + modello }.each {
                    s = it.descrizione
                    value = ""
                    valoreCampo = ""
                    Pattern p = Pattern.compile("\\#.*?\\#");
                    Matcher m = p.matcher(s);
                    m.toMatchResult().each {
                        valoreCampo = it.toString().replaceAll("#", "")
                        value = docSmart.campi.find { it.codice == valoreCampo }?.valore?.toString()
                        if (!value) {
                            value = ""
                        }

                        if ((tipologia == TIPOLOGIA_PROTOCOLLO || tipologia == TIPOLOGIA_LETTERA || tipologia == TIPOLOGIA_DA_FASCICOLARE || tipologia == TIPOLOGIA_EMAIL || tipologia == TIPOLOGIA_REGISTRO_GIORNALIERO || tipologia == TIPOLOGIA_PROVVEDIMENTO || tipologia == TIPOLOGIA_PROTOCOLLO_EMERGENZA || tipologia == TIPOLOGIA_PROTOCOLLO_INTEROPERABILITA) && valoreCampo == "MODALITA") {
                            value = MovimentoConverter.INSTANCE.convertFromOld(value)
                        }
                        if ((tipologia == TIPOLOGIA_PROTOCOLLO || tipologia == TIPOLOGIA_PROTOCOLLO_INTEROPERABILITA) && valoreCampo == "NUMERO") {
                            if (value.size() == 0) {
                                bozza = true
                            }
                        }
                        s = s.replaceAll(it.toString(), value)
                    }

                    //s = s.replaceAll('\\$', '\n') // a capo

                    String dataDocumento = docSmart.campi.find { d ->
                        d.codice == "" + it.campoDataOrdinamento
                    }?.valore?.toString()
                    if (!dataDocumento) {
                        dataDocumento = "00/00/0000"
                    }

                    if (ImpostazioniProtocollo.ITER_FASCICOLI.abilitato & (tipologia == TIPOLOGIA_PROTOCOLLO || tipologia == TIPOLOGIA_LETTERA || tipologia == TIPOLOGIA_DA_FASCICOLARE || tipologia == TIPOLOGIA_EMAIL || tipologia == TIPOLOGIA_REGISTRO_GIORNALIERO || tipologia == TIPOLOGIA_PROVVEDIMENTO || tipologia == TIPOLOGIA_PROTOCOLLO_EMERGENZA || tipologia == TIPOLOGIA_PROTOCOLLO_INTEROPERABILITA)) {
                        if (fascicoloRepository.checkUbicazioneVsFascicolo(selectedRecord.id.toLong(), docSmart.id.toLong()) > 0) {
                            tipologia = tipologia + "_red"
                            tooltip = tooltip + TOOLTIP_UBICATO_ALTROVE
                        }
                    }

                    if (!bozza) {
                        documentiInFascicolo.addAll([idDocumentoEsterno: docSmart.id, tipologia: tipologia, tooltip: tooltip, descrizione: s, campoDataOrdinamento: dataDocumento?.substring(6, 10) + dataDocumento?.substring(3, 5) + dataDocumento?.substring(0, 2), campoAnnoOrdinamento: dataDocumento?.substring(6, 10)])
                    }
                }
            }
        }

        //ordinamento
        if (tipologiaOrdinamento == ANNO_DESC_DATA_ASC) {
            documentiInFascicolo.sort { a, b ->
                -a.campoAnnoOrdinamento.toInteger() <=> -b.campoAnnoOrdinamento.toInteger() ?: a.campoDataOrdinamento.toInteger() <=> b.campoDataOrdinamento.toInteger()
            }
        }
        if (tipologiaOrdinamento == ANNO_DATA_ASC) {
            documentiInFascicolo.sort { a, b ->
                a.campoAnnoOrdinamento.toInteger() <=> b.campoAnnoOrdinamento.toInteger() ?: a.campoDataOrdinamento.toInteger() <=> b.campoDataOrdinamento.toInteger()
            }
        }
        if (tipologiaOrdinamento == ANNO_DATA_DESC) {
            documentiInFascicolo.sort { a, b ->
                -a.campoAnnoOrdinamento.toInteger() <=> -b.campoAnnoOrdinamento.toInteger() ?: -a.campoDataOrdinamento.toInteger() <=> -b.campoDataOrdinamento.toInteger()
            }
        }

        // paginazione e popolamento griglia
        totalSize = documentiInFascicolo.size()
        int firstElement = (pageSize * activePage)

        if (totalSize < firstElement) {
            documentiInFascicolo = []
        } else {
            int lastElement = Math.min((pageSize * (activePage + 1)), totalSize)
            documentiInFascicolo = documentiInFascicolo.subList(firstElement, lastElement)
        }

        documentiInFascicolo.each {
            listaDocumentiInFascicoloZul << [documento: it.descrizione,
                                             img      : it.tipologia,
                                             anno     : it.campoAnnoOrdinamento,
                                             data     : it.campoDataOrdinamento,
                                             tooltip  : it.tooltip,
                                             id       : it.idDocumentoEsterno]
        }

        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "documentiInFascicolo")
        BindUtils.postNotifyChange(null, null, this, "listaDocumentiInFascicoloZul")
    }

    @Command
    void apriDocumentoFascicoloDaPulsante() {
        apriDocumentoFascicolo(documentiSelezionati[0]?.id.toInteger(), documentiSelezionati[0]?.img)
    }

    @Command
    void apriDocumentoFascicoloDoubleClick(@BindingParam("documento") Integer idDocumentoEsterno, @BindingParam("tipologia") String tipologia) {
        apriDocumentoFascicolo(idDocumentoEsterno, tipologia)
    }

    void apriDocumentoFascicolo(Integer idDocumentoEsterno, String tipologia) {
        String link = "#"

        if (tipologia == TIPOLOGIA_EMAIL) {
            MessaggioRicevuto messaggioRicevuto = MessaggioRicevuto.findByIdDocumentoEsterno(idDocumentoEsterno)
            if (messaggioRicevuto != null) {
                link = "/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_RICEVUTO&id=" + messaggioRicevuto.id
            } else {
                Messaggio messaggio = Messaggio.findByIdDocumentoEsterno(idDocumentoEsterno)
                link = messaggio.linkDocumento
            }
        } else if (tipologia == TIPOLOGIA_DA_FASCICOLARE) {
            link = "/Protocollo/standalone.zul?operazione=APRI_DOCUMENTO&tipoDocumento=DA_NON_PROTOCOLLARE&idDoc=" + idDocumentoEsterno
        } else if (tipologia == TIPOLOGIA_PROTOCOLLO && !protocolloRepository.getProtocolloFromIdDocumentoEsterno(idDocumentoEsterno.toLong())) {
            Long idDoc = trascoService.creaProtocolloDaGdm(idDocumentoEsterno)
            link = ProtocolloEsterno.findByIdDocumentoEsterno(idDocumentoEsterno)?.linkDocumento
        } else {
            link = ProtocolloEsterno.findByIdDocumentoEsterno(idDocumentoEsterno)?.linkDocumento
        }

        //Clients.evalJavaScript(" window.open('" + link + "','_blank','noopener'); ") non va con explorer
        Clients.evalJavaScript("var newWindow = window.open(); newWindow.opener = null; newWindow.location = '" + link + "';")
    }

    @NotifyChange(["listaDocumentiInFascicoloZul", "totalSize", "selectedRecord", "activePage", "filtro"])
    @Command
    void onRefresh() {
        filtro = null
        activePage = 0
        documentiInFascicolo = []
        caricaListaDocumentiInFascicolo()
    }

    @NotifyChange(["listaDocumentiInFascicoloZul", "totalSize"])
    @Command
    void onPagina() {
        caricaListaDocumentiInFascicolo()
    }

    private void refreshMenu() {
        if (selectedRecord) {
            menuFunzionalita?.refreshMenu(menuItemFasicolocoService.getVociVisibiliMenu(selectedRecord, competenze, onlyVisualizzazione))
        }
    }

    @Command
    void onNascondi() {
        self.setVisible(false)
    }

    @Command
    void menu(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        MenuItem menuitem = (MenuItem) event.data
        switch (menuitem.name) {
            case MenuItemFascicolo.NUOVO_FASCICOLO:
                onNuovo()
                break
            case MenuItemFascicolo.NUOVO_SUB_FASCICOLO:
                onSub()
                break
            case MenuItemFascicolo.DUPLICA_FASCICOLO:
                onDuplica()
                break
            case MenuItemFascicolo.STAMPA_COPERTINA:
                onStampaCopertina()
                break
            case MenuItemFascicolo.STAMPA_DOCUMENTI:
                onStampaDocumenti()
                break

            case MenuItemProtocollo.CARICO:
                menuItemFasicolocoService.onPrendiIncarico(selectedRecord, menuFunzionalita)
                break
            case MenuItemProtocollo.CARICO_ESEGUI:
                menuItemFasicolocoService.onPrendiIncaricoEsegui(selectedRecord, menuFunzionalita)
                break
            case MenuItemProtocollo.RIPUDIO:
                menuItemFasicolocoService.onRifiutaSmistamento(selectedRecord, menuFunzionalita)
                break
            case MenuItemProtocollo.FATTO_IN_VISUALIZZA:
            case MenuItemProtocollo.FATTO:
                menuItemFasicolocoService.onEsegui(selectedRecord, menuFunzionalita)
                break
            case MenuItemProtocollo.APRI_CARICO_ASSEGNA:
            case MenuItemProtocollo.APRI_CARICO_FLEX:
            case MenuItemProtocollo.APRI_ESEGUI_FLEX:
            case MenuItemProtocollo.APRI_ASSEGNA:
            case MenuItemProtocollo.APRI_INOLTRA_FLEX:
                smistamentoComponent.onEvent(new Event(SmistamentiComponent.ON_SELEZIONA_VOCE, smistamentoComponent, menuitem.name))
                break
        }
    }

    @Command
    void onNuovo() {
        if (!privilegioUtenteService.isCreaFascicolo()) {
            Clients.showNotification("Non è possibile creare un fascicolo. Utente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }
        //Faccio questa apertura perche' se apro un fascicolo da iter fascicolare cliccando su nuovo, sub, e duplica chiude tutto e ritona nella pagina dei fasacicoli.
        Window window = (Window) Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false, titolario: null, duplica: false])
        window.addEventListener(Events.ON_CLOSE) {
            Events.postEvent(Events.ON_CLOSE, self, null)
        }
        window.doModal()
    }

    @Command
    void onSub() {
        if (!privilegioUtenteService.isCreaFascicolo()) {
            Clients.showNotification("Non è possibile creare un fascicolo. Utente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }
        //Faccio questa apertura perche' se apro un fascicolo da iter fascicolare cliccando su nuovo, sub, e duplica chiude tutto e ritona nella pagina dei fasacicoli.
        Window window = (Window) Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false, titolario: selectedRecord, duplica: false])
        window.addEventListener(Events.ON_CLOSE) {
            Events.postEvent(Events.ON_CLOSE, self, null)
        }
        window.doModal()
    }

    @Command
    void onDuplica() {
        if (!privilegioUtenteService.isCreaFascicolo()) {
            Clients.showNotification("Non è possibile creare un fascicolo. Utente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }
        //Faccio questa apertura perche' se apro un fascicolo da iter fascicolare cliccando su nuovo, sub, e duplica chiude tutto e ritona nella pagina dei fasacicoli.
        Window window = (Window) Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false, titolario: selectedRecord, duplica: true])
        window.addEventListener(Events.ON_CLOSE) {
            Events.postEvent(Events.ON_CLOSE, self, null)
        }
        window.doModal()
    }

    @Command
    void onCreaStampa() {
        if(onCrea(true)){
            onStampaCopertina()
        }
    }

    @Command
    void onStampaCopertina() {
        Map paramsReport = [CLASS_COD       : selectedRecord.classificazione.codice,
                            CLASS_DAL       : new SimpleDateFormat("dd/MM/yyyy").format(selectedRecord.classificazione.dal),
                            FASCICOLO_ANNO  : selectedRecord.anno,
                            FASCICOLO_NUMERO: selectedRecord.numero]
        funzioniService.onStampaReportFascicoli(reportNameCopertinaFascicolo, paramsReport)
    }

    @Command
    void onStampaDocumenti() {
        Map paramsReport = [CLASS_COD       : selectedRecord.classificazione.codice,
                            CLASS_DAL       : new SimpleDateFormat("dd/MM/yyyy").format(selectedRecord.classificazione.dal),
                            FASCICOLO_ANNO  : selectedRecord.anno,
                            FASCICOLO_NUMERO: selectedRecord.numero,
                            UTENTE_STAMPA   : springSecurityService.currentUser.utente]
        funzioniService.onStampaReportFascicoli(reportNameFascicoloConAtti, paramsReport)
    }

    @Command
    void onOpenInformazioniUtente() {
        Executions.createComponents("/commons/informazioniUtente.zul", null, null).doModal()
    }

    String getUtenteCollegato() {
        return springSecurityService.principal.cognomeNome
    }

    @Command
    void onInserisciCollegato() {

        boolean esistenzaRelazione

        if (!classificazioneCollegamento || !fascicoloCollegamento) {
            Clients.showNotification("Occorre selezionare il fascicolo da collegare.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }

        listaCollegamenti.each {
            if (tipoCollegamento.codice == it.tipoCollegamento.codice && (
                    (it.collegato.id == fascicoloCollegamento.id && it.documento.id == selectedRecord.id)
                            ||
                            (it.collegato.id == selectedRecord.id && it.documento.id == fascicoloCollegamento.id)
            )) {
                esistenzaRelazione = true
            }
        }

        if (esistenzaRelazione) {
            Clients.showNotification("La relazione risulta già inserita.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }

        DocumentoCollegatoDTO documentoCollegatoDTO = new DocumentoCollegatoDTO()
        if (tipologiaRelazione == relazioneAttiva) {
            documentoCollegatoDTO.documento = selectedRecord
            documentoCollegatoDTO.collegato = fascicoloCollegamento
        } else {
            documentoCollegatoDTO.documento = fascicoloCollegamento
            documentoCollegatoDTO.collegato = selectedRecord
        }
        documentoCollegatoDTO.tipoCollegamento = tipoCollegamento

        listaCollegamenti.add(documentoCollegatoDTO)
        listaCollegamentiNew.add(documentoCollegatoDTO)

        aggiornaMaschera()
        BindUtils.postNotifyChange(null, null, this, "classificazioneCollegamento")
        BindUtils.postNotifyChange(null, null, this, "fascicoloCollegamento")
        BindUtils.postNotifyChange(null, null, this, "tipologiaRelazione")
        BindUtils.postNotifyChange(null, null, this, "tipoCollegamento")
        BindUtils.postNotifyChange(null, null, this, "listaCollegamenti")
    }

    private void refreshListaCollegamenti() {
        listaCollegamenti = fascicoloService.getCollegamentiVisibili(selectedRecord.domainObject)?.toDTO(["tipoCollegamento"])
        BindUtils.postNotifyChange(null, null, this, "listaCollegamenti")
    }

    @Command
    void onEliminaDocumentoCollegato(@BindingParam("documentoCollegato") DocumentoCollegatoDTO documentoCollegato) {
        Messagebox.show("Eliminare il collegamento selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (e.getName() == Messagebox.ON_OK) {
                fascicoloService.eliminaDocumentoCollegato(selectedRecord.domainObject, documentoCollegato.collegato.domainObject, documentoCollegato.tipoCollegamento.codice)
                selectedRecord.version = selectedRecord.domainObject.version
                refreshListaCollegamenti()
                onSalva()
            }
        }
    }

    @Command
    void apriDocumentoCollegato(@BindingParam("documentoCollegato") FascicoloDTO documentoCollegato, @BindingParam("tipoCollegamento") String tipo) {
        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: documentoCollegato?.id, isNuovoRecord: false, standalone: false, titolario: null])
        w.doModal()
    }

    @NotifyChange("datiStorici")
    @Command
    void onRicercaStorico() {
        datiStorici = ricercaDatiStorici()
    }

    List<DatoStoricoTreeNode> ricercaDatiStorici() {
        if (selectedRecord == null || selectedRecord?.dataCreazione == null) {
            return []
        }

        Date ricercaDal = this.ricercaDal ?: new Date(0, 01, 01)
        Date ricercaAl = this.ricercaAl ?: new Date(3000, 01, 01)

        List<GroovyRowResult> results = []

        Date dataDiProtocollazione = selectedRecord.dataCreazione.clone()
        dataDiProtocollazione.clearTime()

        // la data di ricerca minima è sempre la data di creazione
        if (!(ricercaDal.after(selectedRecord.dataCreazione))) {
            ricercaDal = selectedRecord.dataCreazione.clone()
        }
        results.addAll(protocolloStoricoService.cercaStorico(ricercaDal, ricercaAl, selectedRecord.id))

        return creaTreeNode(results)
    }

    private List<DatoStoricoTreeNode> creaTreeNode(List<GroovyRowResult> datiStorici) {
        List<DatoStoricoTreeNode> treeNodes = []

        List<DatoStoricoTreeNode> datiCreazione = parseDatiStoriciCreazione(datiStorici[0])
        for (DatoStoricoTreeNode dato : datiCreazione) {
            if (!treeNodes.contains(dato)) {
                treeNodes.add(dato)
            }
        }

        for (GroovyRowResult datoStorico : datiStorici) {
            List<DatoStoricoTreeNode> dati = parseDatiStorici(datoStorico)
            for (DatoStoricoTreeNode dato : dati) {
                if (dato.descrizioneCampo == "Unità Competente" && !dato.valore) {
                } else {
                    if (!treeNodes.contains(dato)) {
                        treeNodes.add(dato)
                    }
                }
            }
        }

        return treeNodes
    }

/**
 * questa funzione aggiunge alla maschera i vari dati ottenuti dalla query.
 * @param result
 * @return
 */
    private List<DatoStoricoTreeNode> parseDatiStorici(GroovyRowResult result) {
        List<DatoStoricoTreeNode> datiStorici = []

        //datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'TEST', 'TEST')

        if (filtroSelezionato.filtri.contains("OGGETTO_MOD") && result.OGGETTO_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Oggetto', result.OGGETTO)
        }

        if (filtroSelezionato.filtri.contains("RESPONSABILE_MOD") && result.RESPONSABILE_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Responsabile', result.RESPONSABILE)
        }

        if (filtroSelezionato.filtri.contains("RISERVATO_MOD") && result.RISERVATO_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Riservato', result.RISERVATO)
        }

        if (filtroSelezionato.filtri.contains("DIGITALE_MOD") && result.DIGITALE_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Digitale', result.DIGITALE)
        }

        if (filtroSelezionato.filtri.contains("STATO_FASCICOLO_MOD") && result.STATO_FASCICOLO_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Stato Fascicolo', result.STATO_FASCICOLO)
        }

        if (filtroSelezionato.filtri.contains("TOPOGRAFIA_MOD") && result.TOPOGRAFIA_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Topografia', result.TOPOGRAFIA)
        }

        if (filtroSelezionato.filtri.contains("NOTE_MOD") && result.NOTE_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Note', result.NOTE)
        }

        if (filtroSelezionato.filtri.contains("DATA_APERTURA_MOD") && result.DATA_APERTURA_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Data Apertura', result.DATA_APERTURA)
        }

        if (filtroSelezionato.filtri.contains("DATA_CHIUSURA_MOD") && result.DATA_CHIUSURA_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Data Chiusura', result.DATA_CHIUSURA)
        }

        if (filtroSelezionato.filtri.contains("ANNO_ARCHIVIAZIONE_MOD") && result.ANNO_ARCHIVIAZIONE_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Anno Archiviazione', result.ANNO_ARCHIVIAZIONE)
        }

        if (filtroSelezionato.filtri.contains("SUB_MOD") && result.SUB_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Sub', result.SUB)
        }

        if (filtroSelezionato.filtri.contains("CLASSIFICAZIONE_MOD") && result.CLASSIFICAZIONE_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Classificazione', "${result.CLASS_COD} - ${result.CLASS_DESCR}")
        }

        if (filtroSelezionato.filtri.contains("UNITA_PROGR_MOD") && result.UNITA_PROGR_MOD > 0) {
            datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Unità Competente', result.UNITA_COMPETENZA)
        }

        if (datiStorici.size() > 0) {
            datiStorici[0].dataModifica = result.DATA_MODIFICA.timestampValue()
            datiStorici[0].nominativoUtente = result.UTENTE_MODIFICA
        }

        return datiStorici
    }

    private List<DatoStoricoTreeNode> parseDatiStoriciCreazione(GroovyRowResult result) {
        List<DatoStoricoTreeNode> datiStorici = []
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Oggetto', result.OGGETTO)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Responsabile', result.RESPONSABILE)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Riservato', result.RISERVATO)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Digitale', result.DIGITALE)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Stato Fascicolo', result.STATO_FASCICOLO)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Topografia', result.TOPOGRAFIA)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Note', result.NOTE)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Data Apertura', result.DATA_APERTURA)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Data Chiusura', result.DATA_CHIUSURA)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Anno Archiviazione', result.ANNO_ARCHIVIAZIONE)
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Classificazione', "${result.CLASS_COD} - ${result.CLASS_DESCR}")
        datiStorici << new DatoStoricoTreeNode(RevisionType.MOD, 'Unità Competente', result.UNITA_COMPETENZA)
        datiStorici[0].dataModifica = result.DATA_MODIFICA.timestampValue()
        datiStorici[0].nominativoUtente = result.UTENTE_MODIFICA
        return datiStorici
    }

    private static RevisionType getRevisionType(BigDecimal revType) {
        switch (revType.intValue()) {
            case RevisionType.ADD.ordinal():
                return RevisionType.ADD
            case RevisionType.MOD.ordinal():
                return RevisionType.MOD
            case RevisionType.DEL.ordinal():
                return RevisionType.DEL
        }
        return null
    }

    static class DatoStoricoTreeNode {

        private Date dataModifica
        private String nominativoUtente
        private final RevisionType tipoModifica
        private final String descrizioneCampo
        private final String valore
        private final Long idFileEsterno
        private final Long revisioneFile
        private final Long idDocumentoEsterno

        DatoStoricoTreeNode(BigDecimal idFileEsterno, BigDecimal revisioneFile, BigDecimal idDocumentoEsterno, RevisionType tipoModifica, String descrizioneCampo, String valore) {
            this.idDocumentoEsterno = idDocumentoEsterno?.toLong()
            this.idFileEsterno = idFileEsterno?.toLong()
            this.revisioneFile = revisioneFile?.toLong()
            this.tipoModifica = tipoModifica
            this.descrizioneCampo = descrizioneCampo
            this.valore = valore
        }

        DatoStoricoTreeNode(RevisionType tipoModifica, String descrizioneCampo, String valore) {
            this(null, null, null, tipoModifica, descrizioneCampo, valore)
        }

        DatoStoricoTreeNode(RevisionType tipoModifica, String descrizioneCampo, String valore, BigDecimal idDocumentoEsterno) {
            this(null, null, idDocumentoEsterno, tipoModifica, descrizioneCampo, valore)
        }

        void setDataModifica(Date dataModifica) {
            this.dataModifica = dataModifica
        }

        void setNominativoUtente(String nominativoUtente) {
            this.nominativoUtente = nominativoUtente
        }

        Date getDataModifica() {
            return dataModifica
        }

        String getNominativoUtente() {
            return nominativoUtente
        }

        RevisionType getTipoModifica() {
            return tipoModifica
        }

        String getTipoStorico() {
            switch (tipoModifica) {
                case RevisionType.ADD:
                    return 'AGGIUNTO'
                case RevisionType.MOD:
                    return 'MODIFICATO'
                case RevisionType.DEL:
                    return 'CANCELLATO'
            }
        }

        String getDescrizioneCampo() {
            return descrizioneCampo
        }

        String getValore() {
            return valore
        }

        Long getIdFileEsterno() {
            return idFileEsterno
        }

        Long getRevisioneFile() {
            return revisioneFile
        }

        Long getIdDocumentoEsterno() {
            return idDocumentoEsterno
        }

        boolean equals(Object o) {
            if (!(o instanceof DatoStoricoTreeNode)) {
                return false
            }
            DatoStoricoTreeNode o1 = (DatoStoricoTreeNode) o

            return (this.dataModifica == o1.dataModifica &&
                    this.nominativoUtente == o1.nominativoUtente &&
                    this.tipoModifica == o1.tipoModifica &&
                    this.descrizioneCampo == o1.descrizioneCampo &&
                    this.valore == o1.valore &&
                    this.idFileEsterno == o1.idFileEsterno &&
                    this.revisioneFile == o1.revisioneFile &&
                    this.idDocumentoEsterno == o1.idDocumentoEsterno)
        }
    }

    private void refreshDatiScarto() {
        listaStatiScarto = StatoScarto.list([sort: "descrizione", order: "asc"]).toDTO()
        BindUtils.postNotifyChange(null, null, this, "listaStatiScarto")
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        BindUtils.postNotifyChange(null, null, this, "selectedRecord.datiScarto")
    }

    private void refreshIdDocumentoEsterno() {
        Documento d = Documento.findById(selectedRecord.id)
        selectedRecord.idDocumentoEsterno = d.idDocumentoEsterno
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }

    @Command
    void cambiaStatoScarto(@BindingParam("statoScarto") Combobox target) {
        selectedRecord.datiScarto = new DocumentoDatiScartoDTO(stato: target.selectedItem.value, dataStato: dateService.getCurrentDate(), nullaOsta: selectedRecord.datiScarto?.nullaOsta, dataNullaOsta: selectedRecord.datiScarto?.dataNullaOsta)
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        BindUtils.postNotifyChange(null, null, this, "selectedRecord.datiScarto")
    }

    @Command
    void onSpostaFascicolo() {
        Window w = (Window) Executions.createComponents("/commons/popupRicercaFascicolo.zul", null, [classificazione: null, fascicolo: null])
        w.doModal()
        w.onClose { Event event ->
            if (event.data != null) {
                documentiSelezionati.each {
                    Documento documento = Documento.findByIdDocumentoEsterno(it.id.toLong())
                    if (documento) {
                        fascicoloService.spostaFascicolo(documento, event.data.fascicolo?.domainObject, event.data.classificazione?.domainObject, selectedRecord.domainObject)
                    } else {
                        Clients.showNotification("Documento " + it.documento + " non presente in archivio Agspr.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 10000, true)
                    }
                }
                onRefresh()
                BindUtils.postNotifyChange(null, null, this, "selectedRecord")
                BindUtils.postNotifyChange(null, null, this, "listaDocumentiInFascicoloZul")
            }
        }
    }

    @Command
    void onAggiungiInFascicolo() {
        Window w = (Window) Executions.createComponents("/commons/popupRicercaFascicolo.zul", null, [classificazione: null, fascicolo: null])
        w.doModal()
        w.onClose { Event event ->
            if (event.data != null) {
                documentiSelezionati.each {
                    Documento documento = Documento.findByIdDocumentoEsterno(it.id.toLong())
                    if (documento) {
                        DocumentoTitolario dt = documentoTitolarioRepository.getDocumentoTitolario(documento?.id, event.data.fascicolo?.id, event.data.classificazione?.id)
                        if (!dt) {
                            DocumentoTitolario dts = fascicoloService.salvaFascicoloSecondario(documento, event.data.fascicolo?.domainObject, event.data.classificazione?.domainObject)
                            // allineo i dati su GDM
                            protocolloGdmService.fascicolaTitolarioSecondario(dts)
                        }
                    } else {
                        Clients.showNotification("Documento " + it.documento + " non presente in archivio Agspr.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 10000, true)
                    }
                }
            }
        }
    }

    String getLabel(String codice) {
        if (codice == ANNO_DESC_DATA_ASC) {
            return LABEL_ANNO_DESC_DATA_ASC
        } else if (codice == ANNO_DATA_ASC) {
            return LABEL_ANNO_DATA_ASC
        } else {
            return LABEL_ANNO_DATA_DESC
        }
    }

    // gestione files allegati nei documenti in fascicolo
    @Command
    void onMostraAllegati(@BindingParam("documento") documento, @ContextParam(ContextType.COMPONENT) Component component) {
        listaAllegati = []

        Documento documentoAgspr = Documento.findByIdDocumentoEsterno(documento)
        if (documentoAgspr) {
            List<AllegatoEsterno> listaAllegatiAgspr = allegatoProtocolloService.getFileAllegatiProtocollo(documentoAgspr)

            for (allegato in listaAllegatiAgspr) {
                listaAllegati << [idAllegato: allegato.idFileEsterno, nomeAllegato: allegato.getNome()]
            }
        } else {
            ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI> componenti = new ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI>()
            componenti.add(it.finmatica.smartdoc.api.struct.Documento.COMPONENTI.FILE)
            componenti.add(it.finmatica.smartdoc.api.struct.Documento.COMPONENTI.DOCUMENTI_ALLEGATI)
            it.finmatica.smartdoc.api.struct.Documento docSmart = new it.finmatica.smartdoc.api.struct.Documento(id: String.valueOf(documento))
            it.finmatica.smartdoc.api.struct.Documento documentoSmart = documentaleService.getDocumento(docSmart, componenti)
            List<File> listFile = documentoSmart.getFiles()
            for (file in listFile) {
                listaAllegati << [idAllegato: file.id, nomeAllegato: file.nome]
            }
            List<it.finmatica.smartdoc.api.struct.Documento> documentiList = documentoSmart.documentiFigli
            for (documentoFiglio in documentiList) {
                ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI> componentiFigli = new ArrayList<it.finmatica.smartdoc.api.struct.Documento.COMPONENTI>()
                componentiFigli.add(it.finmatica.smartdoc.api.struct.Documento.COMPONENTI.FILE)
                it.finmatica.smartdoc.api.struct.Documento documentoSmartFiglio = documentaleService.getDocumento(documentoFiglio, componentiFigli)
                List<File> listFileFigli = documentoFiglio.getFiles()
                for (file in listFileFigli) {
                    listaAllegati << [idAllegato: file.id, nomeAllegato: file.nome]
                }
            }
        }
        if (listaAllegati.size() > 0) {
            popupAllegati.open(component)
        } else {
            Clients.showNotification(StringUtils.join("Nessun allegato presente"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 5000, true)
        }
        BindUtils.postNotifyChange(null, null, this, "listaAllegati")
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileAllegato") fileAllegato) {
        File file = new File()
        file.setId("" + fileAllegato.idAllegato)

        file = documentaleService.getFile(new it.finmatica.smartdoc.api.struct.Documento(), file)

        Filedownload.save(file.getInputStream(), file.getContentType(), file.getNome())
    }

    boolean visGraffettaDownloadAllegato(Long idDocumentoEsterno) {
        Documento documento = Documento.findByIdDocumentoEsterno(idDocumentoEsterno)
        if (documento) {
            List<AllegatoEsterno> listaAllegatiAgspr = allegatoProtocolloService.getFileAllegatiProtocollo(documento)
            if (listaAllegatiAgspr.size() > 0) {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}
