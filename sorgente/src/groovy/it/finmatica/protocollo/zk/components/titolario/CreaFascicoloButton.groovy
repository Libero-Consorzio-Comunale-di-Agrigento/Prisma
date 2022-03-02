package it.finmatica.protocollo.zk.components.titolario

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Toolbarbutton
import org.zkoss.zul.Window

@Slf4j
@CompileStatic
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation('fascicolo:@ZKBIND(ACCESS=bind)')
class CreaFascicoloButton extends Toolbarbutton implements EventListener<Event> {

    @WireVariable
    private ClassificazioneRepository classificazioneRepository

    private FascicoloDTO fascicolo
    private String codiceClassifica

    CreaFascicoloButton() {
        image = "/images/afc/16x16/add.png"
        tooltiptext = "Crea Fascicolo"
        addEventListener(Events.ON_CLICK, this)
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Toolbarbutton))
    }

    FascicoloDTO getFascicolo() {
        return fascicolo
    }

    void setFascicolo(FascicoloDTO fascicolo) {
        this.fascicolo = fascicolo
    }

    String getCodiceClassifica() {
        return codiceClassifica
    }

    void setCodiceClassifica(String codiceClassifica) {
        this.codiceClassifica = codiceClassifica
    }

    @CompileDynamic
    void onEvent(Event event) throws Exception {
        switch (event.name) {
            case Events.ON_CLICK:

                ClassificazioneDTO classificazioneDTO
                if (codiceClassifica) {
                    classificazioneDTO = classificazioneRepository.getClassificazioneInUso(codiceClassifica)?.toDTO()
                }

                Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", null, [id: -1, isNuovoRecord: true, standalone: false, titolario: classificazioneDTO])
                w.onClose {  e ->
                    if (e.data) {
                        onModificaNuovo(e.data["titolario"], e.data["duplica"])
                    }
                }
                w.doModal()
                break
            default:
                break
        }
    }

    void onModificaNuovo(def titolario, boolean duplica) {
        Window w = (Window) Executions.createComponents("/titolario/fascicoloDettaglio.zul", null, [id: -1, isNuovoRecord: true, standalone: false, titolario: titolario, duplica: duplica])
        w.onClose {  e ->
            if (e.data) {
                def tit = e.data["titolario"]
                boolean dup = e.data["duplica"]
                onModificaNuovo(tit, dup)
            }
        }
        w.doModal()
    }
}
