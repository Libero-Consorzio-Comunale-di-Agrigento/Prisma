package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionetesti.EsitoRichiestaLock
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import org.apache.commons.lang.StringUtils
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Label
import org.zkoss.zul.Span

@CompileStatic
class EditaTestoComponent extends Span implements EventListener<Event> {

    private final EditaTestoButton btnEditaTesto = new EditaTestoButton()
    private final EditaTestoLockImage imgLock = new EditaTestoLockImage()

    private DocumentoDTO documento
    private FileDocumentoDTO testo
    private final Label label = new Label()
    private boolean readOnly

    EditaTestoComponent() {
        appendChild(label)
        appendChild(imgLock)
        appendChild(btnEditaTesto)

        btnEditaTesto.addEventListener(EditaTestoButton.ON_LOCK_TESTO, this)
        btnEditaTesto.addEventListener(EditaTestoButton.ON_VERIFICA_FIRMA, this)
    }

    DocumentoDTO getDocumento() {
        return documento
    }

    void setDocumento(DocumentoDTO documento) {
        this.documento = documento
        updateView()
    }

    FileDocumentoDTO getTesto() {
        return testo
    }

    void setTesto(FileDocumentoDTO testo) {
        this.testo = testo
        updateView()
    }

    boolean getReadOnly() {
        return readOnly
    }

    void setReadOnly(boolean readOnly) {
        this.readOnly = readOnly ||
                documento?.statoFirma?.firmato ||
                testo?.firmato ||
                documento?.statoFirma?.firmaInterrotta ||
                !(testo?.modificabile ?: true)
        updateView()
    }

    @Override
    void onEvent(Event event) throws Exception {
        if (event.name == EditaTestoButton.ON_LOCK_TESTO) {
            imgLock.setLocked(((EsitoRichiestaLock) event.data).esitoLock)
        } else if (event.name == EditaTestoButton.ON_VERIFICA_FIRMA) {
            Events.postEvent(EditaTestoButton.ON_VERIFICA_FIRMA, this, documento)
        }
    }

    private void updateView() {
        if (!visible) {
            return
        }
        if (testo) {
            btnEditaTesto.setTesto(testo)
            btnEditaTesto.setDocumento(documento)
            btnEditaTesto.setReadOnly(readOnly)
        }
        if ( documento?.statoFirma?.firmato || testo?.firmato ) {
            label.style = "margin-right:10px"
            label.setValue(testo?.nome)
        } else if (readOnly && testo?.modelloTesto != null) {
            String descrizione = testo.modelloTesto.domainObject.descrizione
            if (!StringUtils.isEmpty(descrizione)) {
                label.style = "margin-right:10px"
                label.setValue(descrizione)
            }
        } else {
            label.setValue("")
        }

        imgLock.setVisible(!readOnly && testo?.idFileEsterno != null)

        if (!readOnly && documento?.idDocumentoEsterno == null) {
            setVisible(false)
        }
    }
}
