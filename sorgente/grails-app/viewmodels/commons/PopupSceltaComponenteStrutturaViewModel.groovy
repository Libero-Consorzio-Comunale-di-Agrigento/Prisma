package commons

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.zk.AlberoStrutturaOrganizzativa
import it.finmatica.gestionedocumenti.zk.AlberoStrutturaOrganizzativaNodo
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.sinonimi.RadiceAreaUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubbDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaComponenteStrutturaViewModel {

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
    //String modalitaAssegnazione = DatiSmistamento.MODALITA_ASSEGNAZIONE_AGGIUNGI
    List<So4ComponentePubbDTO> listaComponentiUnita
    private So4UnitaPubbDTO unitaSmistamento

    // dati sugli smistamenti
    String tipoSmistamento
    private List<SmistamentoDTO> smistamentiEsistenti
    boolean smistaSoloUtentiAbilitati = true
    boolean tipoSmistamentoModificabile = true
    boolean tipoSmistamentoVisibile = true
    boolean unitaTrasmissioneModificabile = true

    boolean isSequenza = false
    boolean smartDesktop = false
    boolean fascicoloObbligatorio = false
    Integer sequenza

    boolean concatenaCodiceDescrizioneUO = false

    AlberoStrutturaOrganizzativaNodo selectedItem
    So4ComponentePubbDTO componenteSelected

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window window) {
        this.self = window
        this.livelloApertura = ImpostazioniProtocollo.UNITA_EXPAND_LEVEL.valoreInt
        this.smistaSoloUtentiAbilitati = ImpostazioniProtocollo.CHECK_COMPONENTI.abilitato
        this.concatenaCodiceDescrizioneUO = Impostazioni.UNITA_CONCAT_CODICE.abilitato
        this.urlIcone = "images/ags/16x16/"

        /*this.smistamentiEsistenti = smistamentiEsistenti
        this.unitaTrasmissione = unitaTrasmissione
        this.urlIcone = "images/ags/16x16/"
        this.unitaSmistamento = unitaSmistamento
        this.unitaTrasmissioneModificabile = unitaTrasmissioneModificabile
        this.tipoSmistamentoModificabile = (tipoSmistamento == null)
        this.tipoSmistamento = tipoSmistamento ?: Smistamento.COMPETENZA
        this.tipoSmistamentoVisibile = tipoSmistamentoVisibile
        this.concatenaCodiceDescrizioneUO = Impostazioni.UNITA_CONCAT_CODICE.abilitato
        this.listaUnitaTrasmissione = listaUnitaTrasmissione
        this.isSequenza = isSequenza
        this.smartDesktop = smartDesktop
        if (isSequenza) {
            this.tipoSmistamento = Smistamento.CONOSCENZA
            this.tipoSmistamentoModificabile = false
            this.tipoSmistamentoVisibile = true
        }*/

        livelloApertura = 1
        livelloAperturaIniziale = livelloApertura

        onCerca()

        BindUtils.postNotifyChange(null, null, this, "unitaTrasmissioneModificabile")
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
            alberoSo4 = new AlberoStrutturaOrganizzativa(springSecurityService.principal.ottica().codice, mostraComponenti, ruoloAccesso, filtroRicerca?.toUpperCase(), radici)
        } else {
            alberoSo4 = new AlberoStrutturaOrganizzativa(springSecurityService.principal.ottica().codice, gestoreCompetenze.getUnitaPerPrivilegio(springSecurityService.currentUser, PrivilegioUtente.VISUALIZZA_COMPONENTI_UNITA)*.progr, ruoloAccesso, filtroRicerca?.toUpperCase(), radici)
        }
    }

    @Command
    void onAggiungiUnitaComponente(@BindingParam("unitaComponente") AlberoStrutturaOrganizzativaNodo value) {
        if (value.componente) {
            Events.postEvent(Events.ON_CLOSE, self, value.componente.nominativoSoggetto)
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
            if (value.componente) {
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

    @Command
    void onAnnulla() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
