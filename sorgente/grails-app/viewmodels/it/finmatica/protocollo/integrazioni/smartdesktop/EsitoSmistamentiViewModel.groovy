package it.finmatica.protocollo.integrazioni.smartdesktop
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class EsitoSmistamentiViewModel {

	// services
	@WireVariable private SpringSecurityService    springSecurityService


	// componenti
	Window self

	// dati
	List<EsitoSmartDesktop> esitoSmartDesktopList

	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("esitoSmartDesktopList") ArrayList<EsitoSmartDesktop> esitoSmartDesktopList) {

		this.self = w
		this.esitoSmartDesktopList = esitoSmartDesktopList
	}

}
