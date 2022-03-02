package it.finmatica.protocollo.zk.components.firma

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionetesti.EsitoRichiestaLock
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Image
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Popup

@CompileStatic
class EsitoFirmaImage extends Image {

    private final static String SRC_IMG_ESITO_VERIFICATO = "/images/icon/action/22x22/cockade.png"
    private final static String SRC_IMG_ESITO_FALLITO = "/images/ags/22x22/esito_ko.png"
    private final static String SRC_IMG_ESITO_NON_VERIFICATO = "/images/ags/22x22/esito_nullo.png"
    private final static String SRC_IMG_ESITO_FORZATO = "/images/icon/action/22x22/cockade_alarm.png"

    private String esitoFirma = ''
    private String dataVerifica = ''

    EsitoFirmaImage() {
         updateView()
    }

    String getEsitoFirma() {
        return esitoFirma
    }

    void setEsitoFirma(String esitoFirma) {
        this.esitoFirma = esitoFirma
        updateView()
    }

    String getDataVerifica() {
        return dataVerifica
    }

    void setDataVerifica(String dataVerifica) {
        this.dataVerifica = dataVerifica
    }

    private void updateView() {
        if (esitoFirma == Protocollo.ESITO_VERIFICATO) {
            setSrc(SRC_IMG_ESITO_VERIFICATO)
            setTooltiptext("Verificato il " + dataVerifica)
        } else if (esitoFirma == Protocollo.ESITO_NON_VERIFICATO) {
            setSrc(SRC_IMG_ESITO_NON_VERIFICATO)
        } else if (esitoFirma == Protocollo.ESITO_FORZATO) {
            setSrc(SRC_IMG_ESITO_FORZATO)
        } else if (esitoFirma == Protocollo.ESITO_FALLITO) {
            setSrc(SRC_IMG_ESITO_FALLITO)
        }
    }
}
