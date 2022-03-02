package commons.menu

import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.FunzioniService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.menu.MenuItemProtocolloService
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Menuitem
import org.zkoss.zul.Menupopup
import org.zkoss.zul.Menuseparator
import org.zkoss.zul.Span
/**
 *
 * Costuisce il menu dell'applicazione protocollo usando il servizio FunzioniService
 */
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation(['protocollo:@ZKBIND(ACCESS=both)'])
class MenuItemProtocollo extends Span implements EventListener<Event> {

    public static final String NUOVO = "NUOVO"
    public static final String NUOVA_LETTERA = "NUOVA_LETTERA"
    public static final String NUOVO_DA_FASCICOLARE = "NUOVO_DA_FASCICOLARE"
    public static final String NUOVO_INS = "NUOVO_INS"
    public static final String NUOVA_LETTERA_INS = "NUOVA_LETTERA_INS"
    public static final String NUOVO_DA_FASCICOLARE_INS = "NUOVO_DA_FASCICOLARE_INS"
    public static final String COPIA = "COPIA"
    public static final String RISPOSTA = "RISPOSTA"
    public static final String RISPOSTA_CON_LETTERA = "RISPOSTA_CON_LETTERA"
    public static final String CREA_INOLTRO = "CREA_INOLTRO"
    public static final String CREA_INOLTRO_LETTERA = "CREA_INOLTRO_LETTERA" // nota bene: questo codice viene aggiunto da AGSPR quando la barra pulsanti di JProtocollo ritorna il codice "CREA_INOLTRO". Mi serve per poter differenziare l'etichetta e il relativo evento.
    public static final String MAIL = "APRI_MODELLO_INVIO_POPUP"

    public static final String APRI_SMISTA_FLEX = "APRI_SMISTA_FLEX"

    public static final String STAMPA_SMISTAMENTI_INTEGRATI = "STAMPA_SMISTAMENTI_INTEGRATI"
    public static final String STAMPA_BC = "STAMPA_BC"
    public static final String STAMPA_DOCUMENTO = "STAMPA_DOCUMENTO"
    public static final String STAMPA_UNICA = "STAMPA_UNICA"
    public static final String STAMPA_UNICA_SUBITO = "STAMPA_UNICA_SUBITO"
    public static final String STAMPA_RICEVUTA = "Stampa ricevuta"

    public static final String RIPUDIO = "RIPUDIO"
    public static final String CARICO = "CARICO"
    public static final String ESEGUI = "ESEGUI"
    public static final String APRI_CARICO_FLEX = "APRI_CARICO_FLEX"
    public static final String CARICO_ESEGUI = "CARICO_ESEGUI"
    public static final String APRI_CARICO_ASSEGNA = "APRI_CARICO_ASSEGNA"
    public static final String APRI_CARICO_ESEGUI_FLEX = "APRI_CARICO_ESEGUI_FLEX"

    public static final String RICHIEDI_ANNULLAMENTO = "RICHIEDI_ANNULLAMENTO"
    public static final String ANNULLA_PROTOCOLLO = "ANNULLA_PROTOCOLLO"

    public static final String APRI_ASSEGNA = "APRI_ASSEGNA"
    public static final String APRI_INOLTRA_FLEX = "APRI_INOLTRA_FLEX"
    public static final String FATTO = "FATTO"
    public static final String FATTO_IN_VISUALIZZA = "FATTO_IN_VISUALIZZA"
    public static final String APRI_ESEGUI_FLEX = "APRI_ESEGUI_FLEX"
    public static final String APRI_SMISTA_ESEGUI_FLEX = "APRI_SMISTA_ESEGUI_FLEX"

    public static final String PUBBLICA_ALBO = "PUBBLICA_ALBO"

    public static final String IMPORT_ALLEGATI = "IMPORT_ALLEGATI"
    public static final String GESTIONE_ANAGRAFICA = "GESTIONE_ANAGRAFICA"

    // questa "azione" non è di "protocollo GDM" ma è solo di AGSPR. L'ho fatta solo per mantenere una coerenza con tutte le altre azioni.
    public static final String CREA_SMISTAMENTO = "CREA_SMISTAMENTO"
    public static final String CREA_SMISTAMENTO_SCHEMA = "CREA_SMISTAMENTO_SCHEMA"
    public static final String SCARICA_ZIP_ALLEGATI = "SCARICA_ZIP_ALLEGATI"

    // protocollo interoperabilità
    public static final String APRI_MOTIVO_ECCEZIONE = "APRI_MOTIVO_ECCEZIONE"
    public static final String INVIA_RICEVUTA = "INVIA_RICEVUTA"
    public static final String ALLEGATI_MAIL = "ALLEGATI_MAIL"
    public static final String MAIL_ORIGINALE = "MAIL_ORIGINALE"

    public static final String VISUALIZZA_SEGNATURA = "VISUALIZZA_SEGNATURA"

    // riferimenti telematici
    public static final String IMPORTA_RIFERIMENTI_TELEMATICI = "IMPORTA_RIFERIMENTI_TELEMATICI"

    @WireVariable
    ProtocolloGestoreCompetenze gestoreCompetenze

    public static final List<MenuItem> menuItems = [
            new MenuItem(NUOVO, "Nuovo", "onNuovo"),
            new MenuItem(NUOVO_INS, "Nuovo (INS)", "onNuovo"),
            new MenuItem(NUOVA_LETTERA, "Nuova Lettera", "onNuovaLettera"),
            new MenuItem(NUOVA_LETTERA_INS, "Nuova Lettera (INS)", "onNuovaLettera"),
            new MenuItem(NUOVO_DA_FASCICOLARE, "Nuovo Da Fascicolare", "onNuovoDaFascicolare"),
            new MenuItem(NUOVO_DA_FASCICOLARE_INS, "Nuovo Da Fascicolare (INS)", "onNuovoDaFascicolare"),
            new MenuItem(COPIA, "Copia", "copiaProtocollo"),
            new MenuItem(RISPOSTA, "Rispondi", "onRisposta"),
            new MenuItem(RISPOSTA_CON_LETTERA, "Rispondi con Lettera", "onRispostaConLettera"),
            new MenuItem(CREA_INOLTRO, "Crea Inoltro", "creaInoltro"),
            new MenuItem(CREA_INOLTRO_LETTERA, "Crea Inoltro con Lettera", "creaInoltroConLettera"),
            MenuItem.SEPARATORE,

            new MenuItem(RICHIEDI_ANNULLAMENTO, "Richiedi Annullamento", "onAnnullamento"),
            new MenuItem(ANNULLA_PROTOCOLLO, "Annulla", "onAnnullamentoDiretto"),
            MenuItem.SEPARATORE,

            // NOTA: APRI_SMISTA_FLEX non deve essere visibile nel menu. Serve invece per abilitare o meno il pulsante "+" sugli smistamenti.
            new MenuItem(APRI_SMISTA_FLEX, "Smista", false),

            new MenuItem(STAMPA_BC, "Stampa Barcode (ALT+B)", "onStampaBc"),
            new MenuItem(STAMPA_DOCUMENTO, "Stampa Protocollo", "onStampaProtocollo"),
            new MenuItem(STAMPA_SMISTAMENTI_INTEGRATI, "Passaggi", "onStampaPassaggi"),
            new MenuItem(STAMPA_RICEVUTA, "Stampa Ricevuta", "onStampaRicevuta"),
            MenuItem.SEPARATORE,

            new MenuItem(MAIL, "Invia Pec", "onInvioPec"),
            MenuItem.SEPARATORE,

            new MenuItem(RIPUDIO, "Rifiuta Smistamento", "onRifiutaSmistamento"),
            new MenuItem(CARICO, "Prendi in carico", "onPrendiIncarico",),
            new MenuItem(APRI_CARICO_FLEX, "Prendi in carico ed inoltra"),
            new MenuItem(CARICO_ESEGUI, "Prendi in carico ed esegui", "onPrendiIncaricoEsegui"),
            new MenuItem(APRI_CARICO_ASSEGNA, "Prendi in carico ed assegna"),
            new MenuItem(APRI_ESEGUI_FLEX, "Prendi in carico, smista ed Esegui"),
            MenuItem.SEPARATORE,

            new MenuItem(APRI_ASSEGNA, "Assegna"),
            new MenuItem(APRI_INOLTRA_FLEX, "Inoltra"),
            new MenuItem(FATTO, "Esegui", "onEsegui"),
            new MenuItem(FATTO_IN_VISUALIZZA, "Esegui", "onEsegui"),
            new MenuItem(APRI_CARICO_ESEGUI_FLEX, "Prendi in carico e Esegui"),
            MenuItem.SEPARATORE,

            // #30371 - La pubblicazione all'albo viene fatta da un pulsante del flusso e non più dal menu funzionalità.
//            new MenuItem(PUBBLICA_ALBO, "Pubblica all'albo", "onPubblicaAlbo"),
//            MenuItem.SEPARATORE,

            new MenuItem(STAMPA_UNICA_SUBITO, "Scarica la Stampa Unica", "scaricaScampaUnica"),
            new MenuItem(STAMPA_UNICA, "Crea la Stampa Unica", "creaStampaUnica"),
            MenuItem.SEPARATORE,

            new MenuItem(SCARICA_ZIP_ALLEGATI, "Scarica Zip Allegati", "scaricaZipAllegati"),
            new MenuItem(IMPORT_ALLEGATI, "Importa Allegati da Documentale", "importaAllegatiDocumentale"),
            MenuItem.SEPARATORE,

            new MenuItem(APRI_MOTIVO_ECCEZIONE, "Notifica Eccezione", "apriNotificaEccezione"),
            new MenuItem(INVIA_RICEVUTA, "Invia Ricevuta", "inviaRicevuta"),
            new MenuItem(ALLEGATI_MAIL, "Importa Allegati Mail...", "apriImportaAllegatiEmail"),
            new MenuItem(MAIL_ORIGINALE, "Scarica Email Originale", "scaricaEmailOriginale"),

            // Questa voce non è mai presente nel menu perché serve per creare uno smistamento dal pulsante "+" del protocollo
            // quando il documento non è ancora stato protocollato.
            new MenuItem(CREA_SMISTAMENTO, "Inserisci e chiudi"), // questa etichetta viene letta dalla popupSceltaSmistamenti.zul
            new MenuItem(APRI_SMISTA_ESEGUI_FLEX    , "Prendi in carico, smista ed esegui"),
            new MenuItem(CREA_SMISTAMENTO_SCHEMA, "Crea Smistamento"), // questa etichetta viene letta per i tipi di documento
            new MenuItem(GESTIONE_ANAGRAFICA, "Gestione Anagrafica"),
            MenuItem.SEPARATORE,

            // riferimenti telematici
            new MenuItem(IMPORTA_RIFERIMENTI_TELEMATICI, "Importa riferimenti telematici","onImportaRiferimentiTelematici"),

            MenuItem.SEPARATORE,

            new MenuItem(VISUALIZZA_SEGNATURA, "Visualizza Segnatura","onVisualizzaSegnatura"),
    ]

    @WireVariable
    private FunzioniService funzioniService
    @WireVariable
    private MenuItemProtocolloService menuItemProtocolloService

    private ProtocolloDTO protocollo
    private final Menupopup menupopup
    private final Button button
    private List<String> vociMenuAbilitate
    private boolean competenzaInModifica

    MenuItemProtocollo() {
        this.vociMenuAbilitate = []

        button = new Button()
        button.setLabel("Funzionalità...")
        button.setMold("trendy")
        button.setImage("/images/pulsanti/16x16/klipper_dock.png")
        this.appendChild(button)

        menupopup = new Menupopup()
        this.appendChild(menupopup)
        button.setPopup(menupopup)

        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Span))
        Selectors.wireComponents(this, this, false)
        Selectors.wireEventListeners(this, this)
    }

    boolean getCompetenzaInModifica() {
        return competenzaInModifica
    }

    void setCompetenzaInModifica(boolean competenzaInModifica) {
        if (this.competenzaInModifica != competenzaInModifica) {
            this.competenzaInModifica = competenzaInModifica
            refreshMenu()
        }
    }

    ProtocolloDTO getProtocollo() {
        return protocollo
    }

    void setProtocollo(ProtocolloDTO protocollo) {
         if (this.protocollo != protocollo) {
            this.protocollo = protocollo
            refreshMenu()
        }
    }

    /**
     * Da invocare per far scatenare la "chiudi" della finestra del browser.
     */
    void fireOnClose() {
        Events.postEvent(new Event(Events.ON_CLOSE, this))
    }

    void fireOnAggiornaMaschera() {
        Events.postEvent(new Event("onAggiornaMaschera", this))
    }

    /**
     * Da invocare per "nascondere" la popup di "partenza" (cioè il documento correntemente aperto)
     */
    void fireOnHide() {
        Events.postEvent(new Event("onHide", this))
    }

    @Override
    void onEvent(Event event) throws Exception {
        MenuItem item = getVoceMenu(((Menuitem) event.target).value)

        if(item.codice == STAMPA_UNICA){
            Events.postEvent(new Event("onClickStampaUnica", this, item))
        }
        else if (item.nomeFunzione != null) {
            funzioniService."${item.nomeFunzione}"(this, protocollo)
        } else {
            Events.postEvent(new Event("onClickVoceMenu", this, item))
        }
    }

    void refreshMenu() {
        if (this.protocollo == null) {
            return
        }

        List<MenuItem> items = getVociMenu()
        menupopup.children.clear()
        for (MenuItem item : items) {
            if (item.separatore) {
                menupopup.appendChild(new Menuseparator())
            } else if (item.visibileNelMenu) {
                Menuitem mi = new Menuitem(item.label)
                mi.value = item.codice
                mi.addEventListener(Events.ON_CLICK, this)
                menupopup.appendChild(mi)
            }
        }
    }

    boolean isVoceMenuVisibile(String codice) {
        return vociMenuAbilitate.contains(codice)
    }

    static String getLabel(String codice) {
        return getVoceMenu(codice).label
    }

    static MenuItem getVoceMenu(String codice) {
        for (MenuItem menuItem : menuItems) {
            if (menuItem.codice == codice) {
                return menuItem
            }
        }

        throw new IllegalArgumentException("Non ho trovato la voce di menu con codice: ${codice}")
    }

    private List<MenuItem> getVociMenu() {
        if (protocollo?.idDocumentoEsterno == null) {
            vociMenuAbilitate = [APRI_SMISTA_FLEX]
            // è possibile creare gli smistamenti quando il documento non è ancora creato
            return creaMenuDaVoci(vociMenuAbilitate)
        }

        vociMenuAbilitate = menuItemProtocolloService.getVociVisibiliMenu(protocollo.domainObject, competenzaInModifica,menuItems)

        if (protocollo.numero != null &&  (protocollo.statoFirma == StatoFirma.IN_FIRMA || protocollo.statoFirma == StatoFirma.FIRMATO_DA_SBLOCCARE)
        && protocollo.stato != StatoDocumento.ANNULLATO && protocollo.stato != StatoDocumento.DA_ANNULLARE && protocollo.stato != StatoDocumento.RICHIESTO_ANNULLAMENTO ) {
            if (ImpostazioniProtocollo.ANN_DIRETTO.getValore().equals("Y")) {
                if (gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO)) {
                    vociMenuAbilitate << ANNULLA_PROTOCOLLO
                }
            } else {
                vociMenuAbilitate << RICHIEDI_ANNULLAMENTO
            }
        }

        // se il documenton non è ancora salvato, deve comunque essere possibile creare gli smistamenti
        if (protocollo.idDocumentoEsterno == null) {
            vociMenuAbilitate << APRI_SMISTA_FLEX
        }

        // issue: #30695. La funzione di scarica zip allegati deve essere sempre visibile se il documento è creato:
        if (protocollo.idDocumentoEsterno > 0) {
            vociMenuAbilitate << SCARICA_ZIP_ALLEGATI
        }

        // issue: #32588. Aggiungere il crea inoltro con lettera: la ag_barra ritorna il solo codice "CREA_INOLTRO" per gestire entrambi i tipi di inoltro.
        if (vociMenuAbilitate.contains(CREA_INOLTRO)) {
            vociMenuAbilitate << CREA_INOLTRO_LETTERA
        }

        if(vociMenuAbilitate.contains(NUOVO_DA_FASCICOLARE_INS)){
            vociMenuAbilitate << NUOVO_DA_FASCICOLARE_INS
        }

        return creaMenuDaVoci(vociMenuAbilitate)
    }

    private List<MenuItem> creaMenuDaVoci(List<String> vociMenuAbilitate) {
        List<MenuItem> vociMenu = []
        for (MenuItem item : menuItems) {
            // se la voce di menu è un separatore, lo aggiungo solo se l'ultima voce aggiunta non è un separatore
            if (item.isSeparatore()) {
                if (vociMenu.size() > 0 && !vociMenu.last().isSeparatore()) {
                    vociMenu << item
                }
            } else if (vociMenuAbilitate.contains(item.codice)) {
                // aggiungo la voce di menu solo se è contenuta nelle voci di menu abilitate.
                vociMenu << item
            }
        }
        return vociMenu
    }
}
