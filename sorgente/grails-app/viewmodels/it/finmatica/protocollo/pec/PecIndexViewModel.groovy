package it.finmatica.protocollo.pec

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import org.zkoss.bind.BindContext
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Tab
import org.zkoss.zul.Tabbox
import org.zkoss.zul.Tabpanel
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PecIndexViewModel {

    // services
    @WireVariable
    private SpringSecurityService springSecurityService

    // componenti
    Window self
    def listaTab

    String selezionato

    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("codiceTab") String codiceTab) {
        this.self = w

        // TODO[SPRINGBOOT]
        //GrailsUtil.environment == "development"
        boolean inSviluppo = true

        listaTab = [
                [codice: "messaggi_ricevuti", nome: "Messaggi in arrivo", zul: "/protocollo/integrazioni/si4cs/indexMessaggiRicevuti.zul", visibile: inSviluppo && (null == codiceTab || null != codiceTab && codiceTab == "messaggi_ricevuti")],
                [codice: "da_protocollare", nome: "Da Protocollare", zul: "/protocollo/pec/pecDaProtocollare.zul", visibile: inSviluppo && (null == codiceTab || null != codiceTab && codiceTab == "da_protocollare")]
        ]
        selezionato = (codiceTab) ? codiceTab : "messaggi_ricevuti"
    }

    @Command
    caricaTab(@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx, @BindingParam("zul") String zul) {
        Tab tab = (Tab) ctx.getComponent()
        Tabpanel tabPanel = tab.linkedPanel
        if (tabPanel != null && (tabPanel.children == null || tabPanel.children.empty)) {
            Executions.createComponents(zul, tabPanel, null)
        }
    }

    @Command
    caricaPrimoTab(@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx) {
        Tabbox tabbox = (Tabbox) ctx.getComponent()
        Tabpanel tabPanel = tabbox.getSelectedTab()?.linkedPanel
        if (tabPanel != null && (tabPanel.children == null || tabPanel.children.empty)) {
            Executions.createComponents(listaTab.find { it.codice == selezionato }.zul, tabPanel, null)
        }
    }
}
