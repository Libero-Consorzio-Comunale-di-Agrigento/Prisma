package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.JWorklistNotificheDispatcher
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

import javax.servlet.ServletContext

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class DizionariIndexViewModel {

    // componenti
    Window self

    // stato
    String selectedSezione
    String urlSezione

    boolean isPresenteSmartDesktop = false
    boolean configuratoreIterEnabled = false
    boolean moduloSpedizioniAttivo = false

    @WireVariable
    private ServletContext servletContext

    @WireVariable
    private GestioneDocumentiSpringSecurityService springSecurityService

    @WireVariable
    private JWorklistNotificheDispatcher jWorklistNotificheDispatcher

    Map pagineDizionari = [:]

    Map pagineDizionarioProtocollo = [
            "notifica"                          : "/dizionari/gestionedocumenti/notificaLista.zul"
            , "tipoRegistro"                    : "/dizionari/gestionedocumenti/tipoRegistroLista.zul"
            , "gestioneTestiModello"            : "/dizionari/gestioneTestiModelloLista.zul"
            , "tipoProtocollo"                  : "/dizionari/tipoProtocolloLista.zul?tipo="+Protocollo.CATEGORIA_PROTOCOLLO
            , "tipoLettere"                     : "/dizionari/tipoProtocolloLista.zul?tipo="+Protocollo.CATEGORIA_LETTERA
            , "tipoAltro"                       : "/dizionari/tipoProtocolloLista.zul?tipo="+Protocollo.CATEGORIA_DA_NON_PROTOCOLLARE
            , "schemaProtocollo"                : "/dizionari/schemaProtocolloLista.zul"
            , "schemaProtocolloIntegrazioni"    : "/dizionari/schemaProtocolloIntegrazioneLista.zul"
            , "tipoCollegamento"                : "/dizionari/gestionedocumenti/tipoCollegamentoLista.zul"
            , "oggettoRicorrente"               : "/dizionari/oggettoRicorrenteLista.zul"
            , "tipoAllegato"                    : "/dizionari/gestionedocumenti/tipoAllegatoLista.zul"
            , "listaDistribuzione"              : "/dizionari/listaDistribuzioneLista.zul"
            , "tipoAccessoCivico"               : "/dizionari/tipoAccessoCivicoLista.zul"
            , "tipoEsitoAccesso"                : "/dizionari/tipoEsitoAccessoLista.zul"
            , "tipoRichiedenteAccesso"          : "/dizionari/tipoRichiedenteAccessoLista.zul"
            , "bottoneNotifica"                 : "/dizionari/bottoneNotificaLista.zul"
            , "tipoSpedizione"                  : "/dizionari/tipoSpedizioneLista.zul"
            , "modalitaTrasmissione"            : "/dizionari/modalitaInvioRicezioneLista.zul"
            , "titolario"                       : "/titolario/classificazioneLista.zul"
            , "scaricoipa"                      : "/scaricoipa/criteriScaricoIpaLista.zul"
            , "fascicolo"                       : "/titolario/fascicoloLista.zul"
            , "statoScarto"                     : "/dizionari/statoScartoLista.zul"
    ]

    Map pagineDizionarioImpostazioni = [
            "regoleCalcoloAttori"   : "/dizionari/gestionedocumenti/tipologiaSoggettoLista.zul"
            , "impostazione"        : "/dizionari/impostazioni/impostazioneLista.zul"
            , "lockTesti"           : "/gestionetesti/ui/funzionalita/lockDocumentiLista.zul"
            , "gestioneUnita"       : "/dizionari/impostazioni/cambioUnitaLista.zul"
            , "cambioUtente"        : "/dizionari/impostazioni/cambioUtenteLista.zul"
    ]

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        pagineDizionari.putAll(pagineDizionarioProtocollo)
        pagineDizionari.putAll(pagineDizionarioImpostazioni)

        isPresenteSmartDesktop = jWorklistNotificheDispatcher.isPresenteSmartDesktop()
        moduloSpedizioniAttivo = ImpostazioniProtocollo.MOD_SPED_ATTIVO.valore
        configuratoreIterEnabled = Utils.isUtenteAmministratore() || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_PROTOCOLLO.valore)
    }

    List<String> getPatterns() {
        return pagineDizionari.collect { it.key }
    }

    void setSelectedSezione(String value) {
        if (value == null || value.length() == 0) {
            urlSezione = null
        }
        selectedSezione = value
        urlSezione = pagineDizionari[selectedSezione]
        BindUtils.postNotifyChange(null, null, this, "urlSezione")
    }

    @Command
    void apriConfiguratoreIter() {
        Clients.evalJavaScript(" window.open('${servletContext.contextPath}/configuratoreiter/index.zul', '_blank') ")
    }
}
