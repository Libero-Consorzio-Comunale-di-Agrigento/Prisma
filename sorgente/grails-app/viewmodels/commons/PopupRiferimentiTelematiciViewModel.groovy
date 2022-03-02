package commons


import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematico
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematicoService
import org.apache.log4j.Logger
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

import java.text.DecimalFormat

@VariableResolver(DelegatingVariableResolver)
class PopupRiferimentiTelematiciViewModel {

    private static final Logger log = Logger.getLogger(PopupRiferimentiTelematiciViewModel.class)

    Window self

    @WireVariable
    ProtocolloRiferimentoTelematicoService protocolloRiferimentoTelematicoService

    Date dataDefault = new Date()
    Protocollo protocollo
    List<ProtocolloRiferimentoTelematico> riferimentiSelezionati = []

    ProtocolloRiferimentoTelematico riferimentoTelematicoSelezionato

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") Protocollo protocollo) {
        this.self = w
        this.protocollo = protocollo
    }

    static Window apriPopup(Component component,
                            ProtocolloDTO protocollo) {
        Window window = (Window) Executions.createComponents("/protocollo/documenti/commons/popupRiferimentiTelematici.zul", component, [protocollo: protocollo.domainObject])
        window.doModal()
        return window
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, protocollo)
    }

    @Command
    @NotifyChange('riferimentiSelezionati')
    void onImporta() {
        if (riferimentiSelezionati) {
            riferimentiSelezionati = protocolloRiferimentoTelematicoService.importaRiferimenti(riferimentiSelezionati)
            List<ProtocolloRiferimentoTelematico> nonCorretti = riferimentiSelezionati.findAll { it.correttezzaImpronta == 'N' }
            boolean procedi = !nonCorretti
            if (!procedi) {
                Messagebox.show("Esistono riferimenti con impronta non conforme. Procedo con l'importazione?", "Impronte non conformi", Messagebox.OK | Messagebox.CANCEL, Messagebox.EXCLAMATION, { Event e ->
                    if (e.name == Messagebox.ON_OK) {
                        eseguiImportaRiferimenti(nonCorretti.size())
                    }
                })
            }
            else {
                eseguiImportaRiferimenti(nonCorretti.size())
            }
        }
    }

    Set<ProtocolloRiferimentoTelematico> getRiferimentiTelematiciVisibili() {
        return protocollo.riferimentiTelematici?.findAll { !it.scaricato }
    }

    String getDimensioneFormat(Long dimensione) {
        DecimalFormat df = new DecimalFormat("#.##");

        return df.format(dimensione / 1048576)
    }

    private void eseguiImportaRiferimenti(int sizeNonCorretti) {
        protocolloRiferimentoTelematicoService.salvaRiferimentiSuProtocollo(protocollo,riferimentiSelezionati)
        Messagebox.show("Importati ${riferimentiSelezionati?.size()} riferimenti di cui ${sizeNonCorretti} con impronta non conforme", "Importazione completata", Messagebox.OK, Messagebox.INFORMATION, { Event e ->
            Events.postEvent(Events.ON_OK, self, protocollo)
            onChiudi()
        })
    }
}
