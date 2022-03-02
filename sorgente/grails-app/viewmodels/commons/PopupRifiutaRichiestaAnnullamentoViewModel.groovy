package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupRifiutaRichiestaAnnullamentoViewModel {

	Window self

	@WireVariable private SpringSecurityService springSecurityService
	@WireVariable private ProtocolloService     protocolloService

	ProtocolloDTO protocollo
	String testo

	boolean diretto = false

	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") ProtocolloDTO protocollo) {

		this.self = w
		this.protocollo = protocollo
	}

    @Command onChiudi () {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command onInviaRifiuto () {

		if(StringUtils.isEmpty(testo)){
			Clients.showNotification("Valorizzare il motivo della richiesta di Annullamento", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
			return
		}

		protocolloService.rifiutaRichiestaAnnullamento(protocollo.domainObject, testo)
		Events.postEvent(Events.ON_CLOSE, self, null)
    }
}