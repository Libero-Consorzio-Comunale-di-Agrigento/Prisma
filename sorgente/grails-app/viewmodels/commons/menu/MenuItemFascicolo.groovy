package commons.menu

import it.finmatica.protocollo.dizionari.FascicoloDTO
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Menuitem
import org.zkoss.zul.Menupopup
import org.zkoss.zul.Menuseparator
import org.zkoss.zul.Span

/**
 *
 * Costuisce il menu della form Fascicolo
 */
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation(['protocollo:@ZKBIND(ACCESS=both)'])
class MenuItemFascicolo extends Span implements EventListener<Event> {

    public static final String NUOVO_FASCICOLO = "NUOVO_FASCICOLO"
    public static final String NUOVO_SUB_FASCICOLO = "NUOVO_SUB_FASCICOLO"
    public static final String DUPLICA_FASCICOLO = "DUPLICA_FASCICOLO"
    public static final String DOCUMENTI_IN_FASCICOLO = "DOCUMENTI_IN_FASCICOLO"
    public static final String STAMPA_COPERTINA = "STAMPA_COPERTINA"
    public static final String STAMPA_DOCUMENTI = "STAMPA_DOCUMENTI"

    public static final String RIPUDIO = "RIPUDIO"
    public static final String CARICO = "CARICO"
    public static final String APRI_CARICO_FLEX = "APRI_CARICO_FLEX"
    public static final String CARICO_ESEGUI = "CARICO_ESEGUI"
    public static final String APRI_CARICO_ASSEGNA = "APRI_CARICO_ASSEGNA"
    public static final String APRI_ESEGUI_FLEX = "APRI_ESEGUI_FLEX"
    public static final String FATTO_IN_VISUALIZZA = "FATTO_IN_VISUALIZZA"
    public static final String APRI_CARICO_ESEGUI_FLEX = "APRI_CARICO_ESEGUI_FLEX"
    public static final String APRI_INOLTRA_FLEX = "APRI_INOLTRA_FLEX"
    public static final String FATTO = "FATTO"
    public static final String APRI_ASSEGNA = "APRI_ASSEGNA"

    public static final List<MenuItem> menuItems = [
            new MenuItem(NUOVO_FASCICOLO, "Nuovo", "onNuovo"),
            new MenuItem(NUOVO_SUB_FASCICOLO, "Crea Sub", "onSub"),
            new MenuItem(DUPLICA_FASCICOLO, "Duplica", "onDuplica"),
            MenuItem.SEPARATORE,
            new MenuItem(STAMPA_COPERTINA, "Stampa copertina", "onStampaCopertina"),
            new MenuItem(STAMPA_DOCUMENTI, "Stampa documenti in fascicolo", "onStampaDocumenti"),
            MenuItem.SEPARATORE,
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.CARICO },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.APRI_CARICO_ASSEGNA },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.APRI_CARICO_FLEX },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.CARICO_ESEGUI },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.APRI_ESEGUI_FLEX },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.RIPUDIO },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.FATTO },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.FATTO_IN_VISUALIZZA },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.APRI_ASSEGNA },
            MenuItemProtocollo.menuItems.find { it.codice == MenuItemProtocollo.APRI_INOLTRA_FLEX }

            /*new MenuItem(RIPUDIO, "Rifiuta Smistamento", "onRifiutaSmistamento"),
            new MenuItem(CARICO, "Prendi in carico", "onPrendiIncarico",),
            new MenuItem(APRI_CARICO_FLEX, "Prendi in carico ed inoltra"),
            new MenuItem(CARICO_ESEGUI, "Prendi in carico ed esegui", "onPrendiIncaricoEsegui"),
            new MenuItem(APRI_CARICO_ASSEGNA, "Prendi in carico ed assegna"),
            new MenuItem(APRI_ESEGUI_FLEX, "Prendi in carico, smista ed Esegui"),
            new MenuItem(APRI_ASSEGNA, "Assegna"),
            new MenuItem(APRI_INOLTRA_FLEX, "Inoltra"),
            new MenuItem(FATTO, "Esegui", "onEsegui"),
            new MenuItem(FATTO_IN_VISUALIZZA, "Esegui", "onEsegui"),
            new MenuItem(APRI_CARICO_ESEGUI_FLEX, "Prendi in carico e Esegui")*/
    ]

    private FascicoloDTO fascicoloDTO
    private final Menupopup menupopup
    private final Button button
    private List<String> vociMenuAbilitate

    boolean disabled

    MenuItemFascicolo() {
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

    @Override
    void onEvent(Event event) throws Exception {
        MenuItem item = getVoceMenu(((Menuitem) event.target).value)

        Events.postEvent(new Event("onClickVoceMenu", this, item))
    }

    FascicoloDTO getFascicoloDTO() {
        return fascicoloDTO
    }

    void setFascicoloDTO(FascicoloDTO fascicoloDTO) {
        this.fascicoloDTO = fascicoloDTO
    }

    void setDisabled(boolean disabled) {
        this.disabled = disabled
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

    void refreshMenu(List<String> vociMenu) {
        List<MenuItem> items = creaMenuDaVoci(vociMenu)
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