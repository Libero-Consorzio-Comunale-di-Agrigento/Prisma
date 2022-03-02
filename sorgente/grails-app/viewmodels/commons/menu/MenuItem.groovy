package commons.menu

/**
 *
 * Costruzione di un menu a tendina
 *
 **/
class MenuItem {

    public static final SEPARATORE = new MenuItem()

    // ci sono alcune voci che sono pilotate dal menu ma non sono visibili nel menu stesso, ad esempio: APRI_SMISTA_FLEX
    private final boolean visibileNelMenu

    private final String codice
    private final String label
    private final boolean separatore
    private final String nomeFunzione

    MenuItem(String codice, String label, String nomeFunzione, boolean visibileNelMenu) {
        this.codice = codice
        this.label = label
        this.separatore = false
        this.nomeFunzione = nomeFunzione
        this.visibileNelMenu = visibileNelMenu
    }

    MenuItem(String codice, String label, String nomeFunzione) {
        this(codice, label, nomeFunzione, true)
    }

    MenuItem(String codice, String label) {
        this(codice, label, null, true)
    }

    MenuItem(String codice, String label, boolean visibileNelMenu) {
        this(codice, label, null, visibileNelMenu)
    }

    MenuItem() {
        this.separatore = true
        this.codice = null
        this.label = null
        this.nomeFunzione = null
        this.visibileNelMenu = true
    }

    // FIXME: alias temporaneo per retrocompatibilità
    String getName() {
        return codice
    }

    String getCodice() {
        return codice
    }

    String getLabel() {
        return label
    }

    boolean isSeparatore() {
        // tratto le voci non visibile come fossero dei separatori perché così è più semplice non includerli nel menu
        return separatore || !visibileNelMenu
    }

    String getNomeFunzione() {
        return nomeFunzione
    }

    boolean isVisibileNelMenu() {
        return visibileNelMenu
    }
}
