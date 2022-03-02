package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupRichiediAnnullamentoViewModel {

    @WireVariable private StrutturaOrganizzativaService strutturaOrganizzativaService
    @WireVariable private SpringSecurityService springSecurityService
    @WireVariable private ProtocolloService protocolloService

    Window self

    ProtocolloDTO protocollo
    String testo
    String tipoProvvedimento
    boolean diretto = false
    So4UnitaPubbDTO unita
    List<So4UnitaPubbDTO> listaUnita

    static Window apriPopup (ProtocolloDTO protocollo, boolean diretto) {
        Window w = (Window) Executions.createComponents("/commons/popupRichiediAnnullamento.zul", null, [protocollo: protocollo, diretto: diretto])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") ProtocolloDTO protocollo, @ExecutionArgParam("diretto") boolean diretto) {
        this.self = w
        this.protocollo = protocollo
        this.diretto = diretto

        if (diretto) {
            tipoProvvedimento = ImpostazioniProtocollo.PROVV_ANN.valore
        } else {
            String codiceRuolo = ImpostazioniProtocollo.RUOLO_ACCESSO_APPLICATIVO.valore
            listaUnita = strutturaOrganizzativaService.getUnitaSoggettoConPrefissoRuolo(springSecurityService.principal.id, springSecurityService.principal.ottica().codice, codiceRuolo).toDTO()
            if (listaUnita.size() == 1) {
                this.unita = listaUnita.first()
            }
        }
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onInviaRichiesta() {
        if (StringUtils.isEmpty(testo)) {
            ClientsUtils.showWarning("Valorizzare il motivo della richiesta di Annullamento")
            return
        }

        Protocollo p = protocollo.domainObject
        if (!diretto) {
            if (unita == null) {
                ClientsUtils.showWarning("Selezionare un'unità")
                return
            }
            protocolloService.richiestaAnnullamento(p, testo, unita)
        } else {
            protocolloService.annullamentoDiretto(p, testo, tipoProvvedimento)
        }

        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
