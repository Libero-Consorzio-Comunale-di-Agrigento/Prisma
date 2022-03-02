package it.finmatica.protocollo

import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.ad4.security.SpringSecurityService
import org.zkoss.bind.BindContext
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.Executions
import org.zkoss.zul.Tab
import org.zkoss.zul.Tabbox
import org.zkoss.zul.Tabpanel
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class ProtocolloIndexViewModel {

	// services
	@WireVariable
	private SpringSecurityService	springSecurityService
	@WireVariable
	private PrivilegioUtenteService	privilegioUtenteService

	// componenti
	Window self
	def listaTab

	String selezionato

	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("codiceTab") String codiceTab) {
		this.self = w

        // TODO[SPRINGBOOT]
        //GrailsUtil.environment == "development"
        boolean inSviluppo = true
		boolean daAnnullareVisible =  privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO, springSecurityService.currentUser)

		boolean registroGiornalieroVisibile = springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SUPER_UTENTE.valore) || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_CONSERVAZIONE.valore)

		boolean iterFascicolareVisibile = ImpostazioniProtocollo.ITER_FASCICOLI.abilitato

		listaTab = [
				  [codice:"miei_documenti",			nome: "I Miei Documenti"				, zul: "/protocollo/documentiMiei.zul", 						visibile: inSviluppo && ( null == codiceTab || null!= codiceTab && codiceTab=="miei_documenti" )]
				, [codice:"pec",					nome: "Posta Elettronica Certificata"	, zul: "/protocollo/pec/pecIndex.zul", 							visibile: ImpostazioniProtocollo.PEC_USA_SI4CS_WS.valore == "Y" &&  inSviluppo && ( null == codiceTab || null!= codiceTab && codiceTab=="pec" )]
				, [codice:"registro_giornaliero",	nome: "Registro Giornaliero"			, zul: "/protocollo/registroGiornalieroLista.zul", 				visibile: registroGiornalieroVisibile && ( null == codiceTab || ( null!= codiceTab && codiceTab=="registro_giornaliero"))]
				, [codice:"da_firmare",				nome: "Da Firmare"		 				, zul: "/documentiDaFirmare.zul", 	            				visibile: null == codiceTab || ( null!= codiceTab && codiceTab=="da_firmare" )]
				, [codice:"da_annullare",			nome: "Da Annullare"		 			, zul: "/documentiDaAnnullare.zul", 	        				visibile: daAnnullareVisible &&  ( null == codiceTab || ( null!= codiceTab && codiceTab=="da_annullare"))]
				, [codice:"iter_documentale",		nome: "Iter Documentale"		 		, zul: "/iterdocumentale/iterDocumentaleIndex.zul", 	       	visibile: inSviluppo &&  ( null == codiceTab || ( null!= codiceTab && codiceTab=="iter_documentale"))]
				, [codice:"iter_fascicolare",		nome: "Iter Fascicolare"		 		, zul: "/iterfascicolare/iterFascicolareIndex.zul", 	       	visibile: iterFascicolareVisibile && inSviluppo &&  ( null == codiceTab || ( null!= codiceTab && codiceTab=="iter_fascicolare"))]
		]
		selezionato = (codiceTab)?codiceTab:"miei_documenti"

	}

	@Command caricaTab(@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx, @BindingParam("zul") String zul) {
		Tab tab				= (Tab) ctx.getComponent()
		Tabpanel tabPanel	= tab.linkedPanel
		if (tabPanel != null && (tabPanel.children == null || tabPanel.children.empty)) {
			Executions.createComponents(zul, tabPanel, null)
		}
	}

	@Command caricaPrimoTab(@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx) {
		Tabbox tabbox 		= (Tabbox) ctx.getComponent()
		Tabpanel tabPanel 	= tabbox.getSelectedTab()?.linkedPanel
		if (tabPanel != null && (tabPanel.children == null || tabPanel.children.empty)) {
			Executions.createComponents(listaTab.find { it.codice == selezionato }.zul, tabPanel, null)
		}
	}
}
