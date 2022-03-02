package it.finmatica.protocollo.zk.components.upload

import groovy.transform.CompileStatic
import org.zkoss.util.media.Media
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.UploadEvent
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button

/**
 * Un pulsante che carica uno o più file
 */
@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class CaricaFileButton extends AbstractCaricaFileButton implements EventListener<UploadEvent> {

    CaricaFileButton() {
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Button))

        addEventListener(Events.ON_UPLOAD, this)
        setAutodisable('self')
        setMold('trendy')
        setImage('/images/afc/16x16/attach.png')
        setUpload('true,maxsize=-1,native')
        setTooltiptext('Carica File')
    }

    @Override
    void onEvent(UploadEvent event) throws Exception {
        if (event.name == Events.ON_UPLOAD) {
            List<UploadedFile> uploadedFiles = []
            for (Media media : event.medias) {
                uploadedFiles << new UploadedFile(media)
            }
            uploadFiles(uploadedFiles)
        }
    }
}
