package commons

import it.finmatica.protocollo.documenti.viste.SchemaProtocolloUnita
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloUnitaDTO
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.autenticazione.Ad4RuoloDTO
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.competenze.DocumentoCompetenze
import it.finmatica.gestionedocumenti.competenze.DocumentoCompetenzeDTO
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenza
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenzaDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAzioneDTO
import it.finmatica.gestionetesti.competenze.GestioneTestiModelloCompetenza
import it.finmatica.gestionetesti.competenze.GestioneTestiModelloCompetenzaDTO
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbService
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.event.OpenEvent
import org.zkoss.zk.ui.event.SelectEvent
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupCompetenzaDettaglioViewModel {
    @WireVariable private SpringSecurityService springSecurityService
    @WireVariable private So4UnitaPubbService so4UnitaPubbService

    DTO selectedRecord

    List<Ad4UtenteDTO> listaUtenteAd4Dto
    List<Ad4RuoloDTO> listaRuoloAd4Dto
    List<WkfAzioneDTO> listaMetodoCalcolo
    List<So4UnitaPubbDTO> listaUnitaOrganizzativa

    int pageSize = 10
    int activePageUtenteAd4 = 0
    int totalSizeUtenteAd4 = 0
    int activePageRuoloAd4 = 0
    int totalSizeRuoloAd4 = 0
    int activePageUnitaOrganizzativa = 0
    int totalSizeUnitaOrganizzativa = 0

    String filtroUtenteAd4 = ""
    String filtroRuoloAd4 = ""
    String filtroUnitaOrganizzativa = ""

    String valoreUtenteAd4
    String valoreRuoloAd4
    String valoreUnitaOrganizzativa

    String prefissoRuoli = ""

    Window self
    String descrizione

    Map tipiOggetto = [tipoProtocollo     : [isDocumento: false, dto: TipoDocumentoCompetenzaDTO, competenza: TipoDocumentoCompetenza, doc: "tipoDocumento"]
                       , LETTERA          : [isDocumento: true, dto: DocumentoCompetenzeDTO, competenza: DocumentoCompetenze, doc: "protocollo"]
                       , modelloCompetenza: [isDocumento: false, dto: GestioneTestiModelloCompetenzaDTO, competenza: GestioneTestiModelloCompetenza, doc: "gestioneTestiModello"]
                       , schemaProtocollo : [isDocumento: false, dto: SchemaProtocolloUnitaDTO, competenza: SchemaProtocolloUnita, doc: "schemaProtocollo"] ]
    String codiceOggetto
    boolean isDocumento
    boolean isTipoDocumento
    boolean lettura
    boolean modifica

    @NotifyChange(["selectedRecord", "listaUtenteAd4Dto", "listaRuoloAd4Dto", "listaUnitaOrganizzativa", "valoreUtenteAd4"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("documento") doc, @ExecutionArgParam("tipoDocumento") String tipoDoc) {
        this.self = w
        codiceOggetto = tipoDoc
        selectedRecord = tipiOggetto[tipoDoc].dto.newInstance()
        selectedRecord."${tipiOggetto[tipoDoc].doc}" = doc
        isDocumento = tipiOggetto[tipoDoc].isDocumento
        isTipoDocumento = (selectedRecord instanceof SchemaProtocolloUnitaDTO)

        // leggo il prefisso dei ruoli da visualizzare
        prefissoRuoli = ImpostazioniProtocollo.PREFISSO_RUOLO_AD4.valore

        // inizializzo le liste delle combobox
        listaUtenteAd4Dto = caricaListaUtentiAd4()
        listaRuoloAd4Dto = caricaListaRuoliAd4()
        listaUnitaOrganizzativa = caricaListaUnitaOrganizzativa()

        valoreUtenteAd4 = selectedRecord?.utenteAd4?.nominativo
        valoreRuoloAd4 = selectedRecord?.ruoloAd4?.descrizione
        //se è una istanza di SchemaProtocolloUnitaDTO devo recuperalo dal campo unita e imposto isTipoDocumento a true
        So4UnitaPubbDTO unitaSo4 = recuperaUnitaPerSelectedRecord()
        valoreUnitaOrganizzativa = unitaSo4?.descrizione
    }

    // metodi per il calcolo delle combobox
    private List<Ad4UtenteDTO> caricaListaUtentiAd4() {
        PagedResultList utenti = As4SoggettoCorrente.createCriteria().list(max: pageSize, offset: pageSize * activePageUtenteAd4) {
            projections {
                property("utenteAd4")
            }
            utenteAd4 {
                ilike("nominativo", filtroUtenteAd4 + "%")
                order("nominativo", "asc")
            }
        }
        totalSizeUtenteAd4 = utenti.totalCount
        return utenti.toDTO()
    }

    private List<Ad4RuoloDTO> caricaListaRuoliAd4() {
        PagedResultList ruoli = Ad4Ruolo.createCriteria().list(max: pageSize, offset: pageSize * activePageRuoloAd4) {
            ilike("ruolo", prefissoRuoli + "%")
            or {
                ilike("ruolo", "%" + filtroRuoloAd4 + "%")
                ilike("descrizione", "%" + filtroRuoloAd4 + "%")
            }

            order("ruolo", "asc")
        }
        totalSizeRuoloAd4 = ruoli.totalCount
        return ruoli.toDTO()
    }

    List<So4UnitaPubbDTO> caricaListaUnitaOrganizzativa() {
        String ente = springSecurityService.principal.amm()?.codice
        if (ente == null) {
            ente = Ente.get(1)?.amministrazione.id
        }

        String ottica = springSecurityService.principal.ottica()?.codice
        if (ottica == null) {
            ottica = Impostazioni.OTTICA_SO4.valore
        }
        PagedResultList lista = so4UnitaPubbService.cercaUnitaPubb(ente, ottica, new Date(), filtroUnitaOrganizzativa, pageSize, pageSize * activePageUnitaOrganizzativa)
        totalSizeUnitaOrganizzativa = lista.totalCount
        return lista.toDTO()
    }

    private boolean controlloUtenteAd4() {
        if ((valoreUtenteAd4 != null && valoreUtenteAd4 != "") && selectedRecord.utenteAd4 == null) {
            Messagebox.show("L'utente assegnato non è valido, selezionarne uno tra i disponibili oppure svuotare il campo", "Attenzione!", Messagebox.OK, Messagebox.EXCLAMATION)
            return false
        }
        return true
    }

    private boolean controlloRuoloAd4() {
        if ((valoreRuoloAd4 != null && valoreRuoloAd4 != "") && selectedRecord.ruoloAd4 == null) {
            Messagebox.show("Il ruolo assegnato non è valido, selezionarne uno tra i disponibili oppure svuotare il campo", "Attenzione!", Messagebox.OK, Messagebox.EXCLAMATION)
            return false
        }
        return true
    }

    private boolean controlloUnitaOrganizzativa() {
        So4UnitaPubbDTO unitaSo4 = recuperaUnitaPerSelectedRecord()
        if ((valoreUnitaOrganizzativa != null && valoreUnitaOrganizzativa != "") && unitaSo4 == null) {
            Messagebox.show("L'unità organizzativa assegnata non è valida, selezionarne una tra le disponibili oppure svuotare il campo", "Attenzione!", Messagebox.OK, Messagebox.EXCLAMATION)
            return false
        }
        return true
    }

    private boolean controlloValoriNull() {
        // controlli dati inseriti corretti
        if (!controlloUtenteAd4() || !controlloRuoloAd4() || !controlloUnitaOrganizzativa()) {
            return false
        }

        So4UnitaPubbDTO unitaSo4 = recuperaUnitaPerSelectedRecord()

        // controllo che almeno uno dei tre (Utente, Ruolo, Unità Organizzativa) sia selezionato
        if (selectedRecord.utenteAd4 == null && selectedRecord.ruoloAd4 == null && unitaSo4 == null) {
            Messagebox.show("Inserire almeno uno tra i seguenti dati: Utente, Ruolo, Unità Organizzativa!", "Attenzione!", Messagebox.OK, Messagebox.EXCLAMATION)
            return false
        }

        // controllo che se è inserito l'utente allora nessun altro tra Ruolo e Unità Organizzativa sia inserito
        if (selectedRecord.utenteAd4 != null && (selectedRecord.ruoloAd4 != null || unitaSo4 != null)) {
            Messagebox.show("Se viene selezionato un utente allora non si devono inserire i campi: Ruolo e Unità Organizzativa!", "Attenzione!", Messagebox.OK, Messagebox.EXCLAMATION)
            return false
        }

        // se i controlli passano tutti allora è possibile salvare
        return true
    }

    //METODI PER BANDBOX UTENTE AD4
    @NotifyChange(["selectedRecord", "valoreUtenteAd4"])
    @Command
    void onSelectUtenteAd4(@ContextParam(ContextType.TRIGGER_EVENT) SelectEvent event, @BindingParam("target") Component target) {
        // SOLO se ho selezionato un solo item
        if (event.getSelectedItems()?.size() == 1) {
            filtroUtenteAd4 = ""
            selectedRecord.utenteAd4 = event.getSelectedItems().toArray()[0].value
            valoreUtenteAd4 = selectedRecord.utenteAd4.nominativo
            target?.close()
        }
    }

    @NotifyChange(["listaUtenteAd4Dto", "totalSizeUtenteAd4"])
    @Command
    void onPaginaUtenteAd4() {
        listaUtenteAd4Dto = caricaListaUtentiAd4()
    }

    @NotifyChange(["listaUtenteAd4Dto", "totalSizeUtenteAd4", "activePageUtenteAd4"])
    @Command
    void onOpenUtenteAd4(@ContextParam(ContextType.TRIGGER_EVENT) OpenEvent event) {
        if (event.open) {
            activePageUtenteAd4 = 0
            listaUtenteAd4Dto = caricaListaUtentiAd4()
        }
    }

    @NotifyChange(["listaUtenteAd4Dto", "totalSizeUtenteAd4", "activePageUtenteAd4"])
    @Command
    void onChangingUtenteAd4(@ContextParam(ContextType.TRIGGER_EVENT) InputEvent event) {
        selectedRecord.utenteAd4 = null
        activePageUtenteAd4 = 0
        filtroUtenteAd4 = event.getValue()
        listaUtenteAd4Dto = caricaListaUtentiAd4()
    }

    //METODI PER BANDBOX RUOLO AD4
    @NotifyChange(["selectedRecord", "valoreRuoloAd4"])
    @Command
    void onSelectRuoloAd4(@ContextParam(ContextType.TRIGGER_EVENT) SelectEvent event, @BindingParam("target") Component target) {
        // SOLO se ho selezionato un solo item
        if (event.getSelectedItems()?.size() == 1) {
            filtroRuoloAd4 = ""
            selectedRecord.ruoloAd4 = event.getSelectedItems().toArray()[0].value
            valoreRuoloAd4 = selectedRecord.ruoloAd4.descrizione
            target?.close()
        }
    }

    @NotifyChange(["listaRuoloAd4Dto", "totalSizeRuoloAd4"])
    @Command
    void onPaginaRuoloAd4() {
        listaRuoloAd4Dto = caricaListaRuoliAd4()
    }

    @NotifyChange(["listaRuoloAd4Dto", "totalSizeRuoloAd4", "activePageRuoloAd4"])
    @Command
    void onOpenRuoloAd4(@ContextParam(ContextType.TRIGGER_EVENT) OpenEvent event) {
        if (event.open) {
            activePageRuoloAd4 = 0
            listaRuoloAd4Dto = caricaListaRuoliAd4()
        }
    }

    @NotifyChange(["listaRuoloAd4Dto", "totalSizeRuoloAd4", "activePageRuoloAd4"])
    @Command
    void onChangingRuoloAd4(@ContextParam(ContextType.TRIGGER_EVENT) InputEvent event) {
        selectedRecord.ruoloAd4 = null
        activePageRuoloAd4 = 0
        filtroRuoloAd4 = event.getValue()
        listaRuoloAd4Dto = caricaListaRuoliAd4()
    }

    // METODI PER BANDBOX UNITA ORGANIZZATIVA
    @NotifyChange(["selectedRecord", "valoreUnitaOrganizzativa"])
    @Command
    void onSelectUnitaOrganizzativa(@ContextParam(ContextType.TRIGGER_EVENT) SelectEvent event, @BindingParam("target") Component target) {
        // SOLO se ho selezionato un solo item
        if (event.getSelectedItems()?.size() == 1) {
            filtroUnitaOrganizzativa = ""
            if(selectedRecord instanceof SchemaProtocolloUnitaDTO) {
                selectedRecord.unita = event.getSelectedItems().toArray()[0].value
                valoreUnitaOrganizzativa = selectedRecord.unita.descrizione
            } else {
                selectedRecord.unitaSo4 = event.getSelectedItems().toArray()[0].value
                valoreUnitaOrganizzativa = selectedRecord.unitaSo4.descrizione
            }
            target?.close()
        }
    }

    @NotifyChange(["listaUnitaOrganizzativa", "totalSizeUnitaOrganizzativa"])
    @Command
    void onPaginaUnitaOrganizzativa() {
        listaUnitaOrganizzativa = caricaListaUnitaOrganizzativa()
    }

    @NotifyChange(["listaUnitaOrganizzativa", "totalSizeUnitaOrganizzativa", "activePageUnitaOrganizzativa"])
    @Command
    void onOpenUnitaOrganizzativa(@ContextParam(ContextType.TRIGGER_EVENT) OpenEvent event) {
        if (event.open) {
            activePageUnitaOrganizzativa = 0
            listaUnitaOrganizzativa = caricaListaUnitaOrganizzativa()
        }
    }

    @NotifyChange(["listaUnitaOrganizzativa", "totalSizeUnitaOrganizzativa", "activePageUnitaOrganizzativa"])
    @Command
    void onChangingUnitaOrganizzativa(@ContextParam(ContextType.TRIGGER_EVENT) InputEvent event) {
        if(selectedRecord instanceof SchemaProtocolloUnitaDTO){
            selectedRecord.unita = null
        } else {
            selectedRecord.unitaSo4 = null
        }
        activePageUnitaOrganizzativa = 0
        filtroUnitaOrganizzativa = event.getValue()
        listaUnitaOrganizzativa = caricaListaUnitaOrganizzativa()
    }

    @NotifyChange(["listaMetodoCalcolo", "totalSizeMetodoCalcolo"])
    @Command
    void onCambiaTipoOggetto() {
        listaMetodoCalcolo = caricaListaMetodoCalcolo()
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onInserisci() {
        if (controlloValoriNull()) {
            def competenza = tipiOggetto[codiceOggetto].competenza.newInstance()
            competenza."${tipiOggetto[codiceOggetto].doc}" = selectedRecord."${tipiOggetto[codiceOggetto].doc}".getDomainObject()

            if(! isTipoDocumento ) {
                if (isDocumento) {
                    competenza.lettura = lettura
                    competenza.modifica = modifica
                } else {
                    competenza.descrizione = descrizione
                    competenza.lettura = true
                }
            }

            So4UnitaPubbDTO unitaSo4 = recuperaUnitaPerSelectedRecord()
            competenza.utenteAd4 = selectedRecord.utenteAd4?.getDomainObject()
            competenza.ruoloAd4 = selectedRecord.ruoloAd4?.getDomainObject()
            //Setto i valori specifici per schema protocollo
            if(selectedRecord instanceof SchemaProtocolloUnitaDTO) {
                competenza.unita = unitaSo4?.getDomainObject()
                competenza.idDocumentoEsterno = selectedRecord.schemaProtocollo?.idDocumentoEsterno
            } else {
                competenza.unitaSo4 = unitaSo4?.getDomainObject()
            }
            competenza.save(flush: true)

            onChiudi()
        }
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    private So4UnitaPubbDTO recuperaUnitaPerSelectedRecord() {
        So4UnitaPubbDTO unitaSo4
        if (selectedRecord instanceof SchemaProtocolloUnitaDTO) {
            unitaSo4 = selectedRecord.unita
        } else {
            unitaSo4 = selectedRecord.unitaSo4
        }
        unitaSo4
    }
}
