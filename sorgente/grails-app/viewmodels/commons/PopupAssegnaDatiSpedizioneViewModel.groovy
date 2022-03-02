package commons

import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezioneDTO
import org.apache.log4j.Logger
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupAssegnaDatiSpedizioneViewModel {

    private static final Logger log = Logger.getLogger(PopupAssegnaDatiSpedizioneViewModel.class)

    Window self

    @WireVariable
    private CorrispondenteService corrispondenteService
    @WireVariable
    private DizionariRepository dizionariRepository

    CorrispondenteDTO corrispondente
    List<ModalitaInvioRicezioneDTO> modalitaInvioRicezione
    Date dataDefault = new Date()
    ModalitaInvioRicezioneDTO mir

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("corrispondente") CorrispondenteDTO corrispondente, @ExecutionArgParam("protocollo") protocollo) {
        this.self = w

        if (corrispondente.quantita == null) {
            corrispondente.quantita = 1
        }
        if (corrispondente.dataSpedizione == null) {
            corrispondente.dataSpedizione = dataDefault
        }

        if (corrispondente?.modalitaInvioRicezione?.id != null) {
            mir = dizionariRepository.getModalitaInvioRicezioneFromId(corrispondente.modalitaInvioRicezione.id).toDTO()
        } else if (protocollo.modalitaInvioRicezione != null) {

            mir = dizionariRepository.getModalitaInvioRicezioneFromIdProtocollo(protocollo.id).toDTO()
        }
        corrispondente.costoSpedizione = mir?.costo
        corrispondente.modalitaInvioRicezione = mir

        this.corrispondente = corrispondente
        this.modalitaInvioRicezione = dizionariRepository.getListModalitaInvioRicezione().toDTO()
    }

    @Command
    onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, corrispondente)
    }

    @Command
    onSalva() {
        corrispondenteService.salva(corrispondente.protocollo.domainObject, [corrispondente])
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onCambiaModalitaInvioRicezione() {
        ModalitaInvioRicezioneDTO tempModalita = dizionariRepository.getModalitaInvioRicezioneFromId(corrispondente.modalitaInvioRicezione.id).toDTO()
        corrispondente.costoSpedizione = tempModalita.costo
        BindUtils.postNotifyChange(null, null, this, "corrispondente")
    }
}
