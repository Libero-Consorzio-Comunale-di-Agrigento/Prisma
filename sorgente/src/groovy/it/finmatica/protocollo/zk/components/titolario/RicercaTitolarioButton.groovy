package it.finmatica.protocollo.zk.components.titolario

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Toolbarbutton
import org.zkoss.zul.Window

@Slf4j
@CompileStatic
@ComponentAnnotation(['fascicolo:@ZKBIND(ACCESS=both, SAVE_EVENT=onSelectFascicolo)', 'classificazione:@ZKBIND(ACCESS=both, SAVE_EVENT=onSelectClassificazione)'])
class RicercaTitolarioButton extends Toolbarbutton implements EventListener<Event> {

    private ClassificazioneDTO classificazione
    private FascicoloDTO fascicolo

    RicercaTitolarioButton() {
        image = "/images/ags/16x16/annotate.png"
        tooltiptext = "Ricerca Fascicolo"
        addEventListener(Events.ON_CLICK, this)
    }

    FascicoloDTO getFascicolo() {
        return fascicolo
    }

    void setFascicolo(FascicoloDTO fascicolo) {
        this.fascicolo = fascicolo
    }

    boolean isFascicoliChiusi() {
        return fascicoliChiusi
    }

    void setFascicoliChiusi(boolean fascicoliChiusi) {
        this.fascicoliChiusi = fascicoliChiusi
    }

    ClassificazioneDTO getClassificazione() {
        return classificazione
    }

    void setClassificazione(ClassificazioneDTO classificazione) {
        this.classificazione = classificazione
        if (this.classificazione == null || (this.fascicolo != null && this.fascicolo.classificazione?.id != this.classificazione.id)) {
            if(this.fascicolo != null){
                setFascicolo(null)
                Events.postEvent('onSelectFascicolo', this, fascicolo)
            }
        }
    }

    @CompileDynamic
    void onEvent(Event event) throws Exception {
        switch (event.name) {
            case Events.ON_CLICK:
                openRicercaTitolarioPopup()
                break
            case Events.ON_CLOSE:
                if (event.data != null) {
                    setClassificazione(event.data.classificazione)
                    setFascicolo(event.data.fascicolo)
                    Events.postEvent('onSelectClassificazione', this, classificazione)
                    Events.postEvent('onSelectFascicolo', this, fascicolo)
                }
                break
            default:
                break
        }
    }

    private void openRicercaTitolarioPopup() {
        Window window = (Window) Executions.createComponents("/commons/popupRicercaFascicolo.zul", null, [classificazione: classificazione, fascicolo: fascicolo])
        window.addEventListener(Events.ON_CLOSE, this)
        window.doModal()
    }
}
