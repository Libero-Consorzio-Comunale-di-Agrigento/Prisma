package commons

import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubbDTO
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class PopupCompetenzeEspliciteViewModel {

    // servizi
    @WireVariable private SmistamentoService smistamentoService

    // componenti
    Window self

    // dati
    So4ComponentePubbDTO utenteAssegnatario
    ProtocolloDTO protocollo
    List<SmistamentoDTO> utentiCompetenzeEsplicite

    static Window apriPopup(ProtocolloDTO protocollo) {
        return apri([protocollo: protocollo])
    }

    private static Window apri(Map parametri) {
        Window window = (Window) Executions.createComponents('/commons/popupCompetenzeEsplicite.zul', null, parametri)
        window.doModal()
        return window
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window window, @ExecutionArgParam('protocollo') ProtocolloDTO protocollo) {
        this.self = window
        this.protocollo = protocollo
        caricaSmistamentiCompetenze()
    }

    @NotifyChange('utentiCompetenzeEsplicite')
    void caricaSmistamentiCompetenze() {
        utentiCompetenzeEsplicite = smistamentoService.getSmistamentiCompetenzeEsplicite(protocollo.domainObject).toDTO('utenteAssegnatario') as List<SmistamentoDTO>
    }

    @NotifyChange('utentiCompetenzeEsplicite')
    @Command
    void onAggiungiCompetenza() {

        So4ComponentePubb componentePubb = utenteAssegnatario.domainObject
        smistamentoService.creaSmistamentoCompetenzaEsplicita(protocollo.domainObject, componentePubb.soggetto.utenteAd4)
        caricaSmistamentiCompetenze()
    }

    @NotifyChange('utentiCompetenzeEsplicite')
    @Command
    void onEliminaCompetenza(@BindingParam('smistamento') SmistamentoDTO smistamento) {
        smistamentoService.eliminaSmistamento(protocollo.domainObject, smistamento.domainObject, true)
        caricaSmistamentiCompetenze()
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
