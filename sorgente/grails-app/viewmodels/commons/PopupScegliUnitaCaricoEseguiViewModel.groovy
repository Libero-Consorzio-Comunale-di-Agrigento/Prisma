package commons

import commons.menu.MenuItemProtocollo
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupScegliUnitaCaricoEseguiViewModel {

    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private SmistamentoService smistamentoService
    @WireVariable
    private DateService dateService

    Window self

    ISmistabileDTO smistabileDTO

    String labelOperazione
    String operazione
    So4UnitaPubbDTO unita
    List<SmistamentoDTO> listaSmistamenti
    List<SmistamentoDTO> listaSmistamentiSelezionati = new ArrayList<>()

    static Window apriPopup(ISmistabileDTO smistabileDTO, String operazione) {
        Window w = (Window) Executions.createComponents("/commons/popupScegliUnitaCaricoEsegui.zul", null, [smistabileDTO: smistabileDTO, operazione: operazione])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("smistabileDTO") ISmistabileDTO smistabileDTO, @ExecutionArgParam("operazione") String operazione) {
        this.self = w
        this.smistabileDTO = smistabileDTO
        this.operazione = operazione
        this.labelOperazione = MenuItemProtocollo.getLabel(operazione)

        if (operazione == MenuItemProtocollo.CARICO || operazione == MenuItemProtocollo.CARICO_ESEGUI) {
            listaSmistamenti = smistamentoService.getSmistamentiDaPrendereInCarico(smistabileDTO.domainObject, springSecurityService.currentUser)?.toDTO("unitaSmistamento.descrizione")
        } else if (operazione == MenuItemProtocollo.FATTO) {
            listaSmistamenti = smistamentoService.getSmistamentiInCarico(smistabileDTO.domainObject, springSecurityService.currentUser)?.toDTO("unitaSmistamento.descrizione")
        }

        listaSmistamenti = listaSmistamenti.unique{it.unitaSmistamento.progr}

        if (null == listaSmistamenti || listaSmistamenti.size() == 0) {
           Events.postEvent(Events.ON_CLOSE, self, null)
           ClientsUtils.showError("Non è possibile eseguire operazione di :  " +  this.labelOperazione)
        }

        if (listaSmistamenti.size() == 1) {
            eseguiOperazione()
            Events.postEvent(Events.ON_CLOSE, self, null)
        }
        BindUtils.postNotifyChange(null, null, this, "listaSmistamenti")
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onEseguiOperazione() {

        if (listaSmistamentiSelezionati.size() <= 0) {
            ClientsUtils.showError("Non hai selezionato unità ")
            return
        }

        eseguiOperazione()
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    private void eseguiOperazione() {
        List<Smistamento> smistamenti = listaSmistamentiSelezionati?.domainObject

        if (operazione == MenuItemProtocollo.CARICO) {
            smistamentoService.prendiInCarico(smistabileDTO.domainObject, (Ad4Utente) springSecurityService.currentUser, smistamenti)
        } else if (operazione == MenuItemProtocollo.CARICO_ESEGUI) {
            smistamentoService.prendiInCaricoEdEsegui(smistabileDTO.domainObject, (Ad4Utente) springSecurityService.currentUser, smistamenti)
        } else if (operazione == MenuItemProtocollo.FATTO) {
            smistamentoService.eseguiSmistamenti(smistabileDTO.domainObject, (Ad4Utente) springSecurityService.currentUser, dateService.getCurrentDate(), smistamenti)
        }
    }
}
