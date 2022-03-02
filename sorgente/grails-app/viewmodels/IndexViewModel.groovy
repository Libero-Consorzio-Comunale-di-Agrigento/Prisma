import com.jcabi.manifests.Manifests
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.so4.login.So4SpringSecurityService
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.Page
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver

@VariableResolver(DelegatingVariableResolver)
class IndexViewModel {

    // services
    @WireVariable
    private So4SpringSecurityService springSecurityService
    @WireVariable
    private GestioneTestiService gestioneTestiService
    @WireVariable
    private Manifests manifests

    // componenti

	// sezioni (referenziate anche dai bottoni)
	def sezioni = [ protocollo: "/protocollo/index.zul",
                    titolario: "/titolario/classificazioneLista.zul",
				    dizionari: 	"/dizionari/index.zul"]

    String selectedSezione = "protocollo"
    String urlSezione

    boolean dizionariVisible = false
    boolean anagraficaVisible = false
    boolean conservazioneVisible = false

    @NotifyChange("urlSezione")
    @Init
    init(@ContextParam(ContextType.PAGE) Page page) {

        urlSezione = sezioni.protocollo
        boolean isUtenteAmministratore = Utils.isUtenteAmministratore()
        //conservazioneVisible   = isUtenteAmministratore || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_CONSERVAZIONE.valore)

        boolean dizProtocolloVisible = isUtenteAmministratore || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_PROTOCOLLO.valore) || springSecurityService.principal.hasRuolo("AGPANAG")
        boolean dizImpVisible = isUtenteAmministratore || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_IMPOSTAZIONI.valore)
        dizionariVisible = (dizProtocolloVisible || dizImpVisible)

        boolean isGestAnag = false
        List<String> ruoliGestAnag = ImpostazioniProtocollo.RUOLI_GEST_ANAG.valori
        for (String ruoloGestAnag : ruoliGestAnag) {
            if (springSecurityService.principal.hasRuolo(ruoloGestAnag)) {
                isGestAnag = true
                break
            }
        }
        anagraficaVisible = (isUtenteAmministratore || isGestAnag)

    }

    List<String> getPatterns() {
        return sezioni.collect { it.key }
    }

    @Command
    onOpenInformazioniUtente() {
        Executions.createComponents("/commons/informazioniUtente.zul", null, null).doModal()
    }

    @Command
    apriSezione(@BindingParam("sezione") String sezione) {
        if (sezione == "dizionari" && !dizionariVisible) {
            selectedSezione = "protocollo"
        } else {
            selectedSezione = sezione
        }
        urlSezione = sezioni[selectedSezione]

        BindUtils.postNotifyChange(null, null, this, "urlSezione")
        BindUtils.postNotifyChange(null, null, this, "selectedSezione")
    }

    @Command
    apriAnagrafica(@BindingParam("sezione") String sezione) {
        String url = ImpostazioniProtocollo.URL_ANAGRAFICA.valore
        Clients.evalJavaScript(" window.open('${url}'); ")
    }

    @Command
    doLogout() {
        Executions.sendRedirect("/logout")
    }

    String getUtenteCollegato() {
        return springSecurityService.principal.cognomeNome
    }

    String getVersioneApplicazione() {
        String versione = findVersionInfo()
        return "© Gruppo Finmatica - AGSPR v$versione"
    }

    String getNomeApplicazione() {
        return findApplicationName()
    }

    String getAmministrazione() {
        return springSecurityService.principal.amm()?.descrizione
    }

    private String findVersionInfo() throws IOException {
        return manifests.get("Implementation-Version")?:"LOCAL"
    }

    private String findApplicationName() throws IOException {
        return manifests.get("Implementation-Name")
    }
}
