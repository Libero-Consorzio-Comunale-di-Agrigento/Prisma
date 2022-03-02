package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import groovy.transform.CompileStatic
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class PopupSceltaTipologiaViewModel {

    // componenti
    Window self

    // dati
    List<TipoProtocolloDTO> listaTipologie
    TipoProtocolloDTO selectedRecord

    static Window apriPopup(Component parent, String categoria, List<TipoProtocolloDTO> tipiProtocollo) {
        Window w = (Window) Executions.createComponents("/commons/popupSceltaTipologia.zul", parent, [categoria: categoria, tipiProtocollo: tipiProtocollo])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w,
              @ExecutionArgParam("categoria") String categoria,
              @ExecutionArgParam("tipiProtocollo") List<TipoProtocolloDTO> tipiProtocollo) {
        this.self = w
        caricaListaTipologie(categoria, tipiProtocollo)
    }

    private void caricaListaTipologie(String categoria, List<TipoProtocolloDTO> tipiProtocollo) {
        listaTipologie = tipiProtocollo

        if (listaTipologie?.size() > 0) {
            selectedRecord = listaTipologie[0]
        } else {
            ClientsUtils.showError("Non hai i privilegi per creare documenti di tipo " + categoria)
            Events.postEvent(Events.ON_CLOSE, self, null)
        }

        BindUtils.postNotifyChange(null, null, this, "listaTipologie")
    }

    @Command
    void onScegli() {
        Events.postEvent(Events.ON_CLOSE, self, selectedRecord)
    }

    @Command
    void onAnnulla() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
