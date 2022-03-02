package it.finmatica.protocollo.zk.components.upload

import commons.PopupImportAllegatiEmailViewModel
import groovy.transform.CompileStatic
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button

/**
 * Un pulsante che carica uno o più file
 */
@CompileStatic
@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation('protocollo:@ZKBIND(ACCESS=load)')
class ImportaFilePecButton extends Button implements EventListener<Event> {

    public static final String ON_FILE_IMPORTATI = 'onFileImportati'

    private ProtocolloDTO protocollo

    ImportaFilePecButton() {
        addEventListener(Events.ON_CLICK, this)
        setAutodisable('self')
        setMold('trendy')
        setImage('/images/afc/16x16/mail.png')
        setTooltiptext('Seleziona file principale da PEC')
    }

    ProtocolloDTO getProtocollo() {
        return protocollo
    }

    void setProtocollo(ProtocolloDTO protocollo) {
        this.protocollo = protocollo
    }

    @Override
    void onEvent(Event event) throws Exception {

        if (event.name == Events.ON_CLICK) {
            
            boolean unzip = false
            if (ImpostazioniProtocollo.INTEROP_ABILITA_UNZIP.abilitato) {
                unzip = true
            }

            PopupImportAllegatiEmailViewModel.apriPopup(null, protocollo, false, unzip).addEventListener(Events.ON_CLOSE) { Event ev ->
                if (ev.data) {
                    Events.postEvent(ON_FILE_IMPORTATI, this, null)
                }
            }
        }
    }
}
