package commons.menu

import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
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
 * Costuisce il menu della form Messaggio in arrivo dalla pec
 */
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation(['protocollo:@ZKBIND(ACCESS=both)'])
class MenuItemMessaggioArrivo extends Span implements EventListener<Event> {
    public static final String CREA_PROTOCOLLO = "CREA_PROTOCOLLO"
    public static final String SCARTA_MESSAGGIO = "SCARTA_MESSAGGIO"
    public static final String CREA_PG_PARTENZA = "CREA_PG_PARTENZA"
    public static final String SCARICA_EML = "SCARICA_EML"

    public static final List<MenuItem> menuItems = [
            new MenuItem(CREA_PROTOCOLLO, "Crea Protocollo", "onCreaProtocollo"),
            new MenuItem(SCARTA_MESSAGGIO, "Scarta", "onScartaMessaggio"),
            new MenuItem(CREA_PG_PARTENZA, "Crea Protocollo in Partenza", "onCreaProtocolloPartenza"),
            new MenuItem(SCARICA_EML, "Visualizza messaggio di posta (eml) ", "onScaricaEml"),
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
    ]

    private MessaggioRicevutoDTO messaggioRicevutoDTO
    private final Menupopup menupopup
    private final Button button
    private List<String> vociMenuAbilitate

    MenuItemMessaggioArrivo() {
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

    MessaggioRicevutoDTO getMessaggioRicevutoDTO() {
        return messaggioRicevutoDTO
    }

    void setMessaggioRicevutoDTO(MessaggioRicevutoDTO messaggioRicevutoDTO) {
        this.messaggioRicevutoDTO = messaggioRicevutoDTO
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
        if (this.messaggioRicevutoDTO == null) {
            return
        }

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
