package it.finmatica.protocollo.zk.components.titolario

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Toolbarbutton
import org.zkoss.zul.Window

@Slf4j
@CompileStatic
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation('fascicolo:@ZKBIND(ACCESS=load)')
class VisualizzaFascicoloButton extends Toolbarbutton implements EventListener<Event> {

    @WireVariable
    private ProtocolloPkgService protocolloPkgService
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService

    private FascicoloDTO fascicolo

    VisualizzaFascicoloButton() {
        image = "/images/ags/16x16/info.png"
        tooltiptext = "Apri Fascicolo"
        addEventListener(Events.ON_CLICK, this)
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Toolbarbutton))
    }

    FascicoloDTO getFascicolo() {
        return fascicolo
    }

    void setFascicolo(FascicoloDTO fascicolo) {
        this.fascicolo = fascicolo
    }

    @CompileDynamic
    void onEvent(Event event) throws Exception {
        switch (event.name) {
            case Events.ON_CLICK:
                //openFascicoloGdm()
                //if (privilegioUtenteService.isCompetenzaVisualizzaFascicolo(fascicolo) || privilegioUtenteService.isCompetenzaModificaFascicolo(fascicolo)) {
                    Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", null, [id: fascicolo?.id, isNuovoRecord: false, standalone: false, titolario: null])
                    w.onClose { e ->
                        if (e.data) {
                            onModificaNuovo(e.data["titolario"], e.data["duplica"])
                        }
                    }
                    w.doModal()
                    break
                //} else {
                //    Clients.showNotification("Non è possibile visualizzare il fascicolo. Utente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
                //    return
                //}
            default:
                break
        }
    }

    void onModificaNuovo(def titolario, boolean duplica) {
        Window w = (Window) Executions.createComponents("/titolario/fascicoloDettaglio.zul", null, [id: -1, isNuovoRecord: true, standalone: false, titolario: titolario, duplica: duplica])
        w.onClose { e ->
            if (e.data) {
                def tit = e.data["titolario"]
                boolean dup = e.data["duplica"]
                onModificaNuovo(tit, dup)
            }
        }
        w.doModal()
    }

    private void openFascicoloGdm() {
        if (fascicolo != null) {
            String urlFascicolo = protocolloPkgService.gdcUtilityPkgGetUrlCartella(fascicolo.idDocumentoEsterno)
            Clients.evalJavaScript(" window.open('${urlFascicolo}'); ")
        }
    }
}
