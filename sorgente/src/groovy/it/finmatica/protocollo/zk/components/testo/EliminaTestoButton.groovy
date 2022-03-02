package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Messagebox

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class EliminaTestoButton extends Button implements EventListener<Event> {

    public final static String ON_TESTO_ELIMINATO = 'onTestoEliminato'

    @WireVariable
    private DocumentoService documentoService

    private ProtocolloDTO documento
    private FileDocumentoDTO testo

    EliminaTestoButton() {
        setImage('/images/ags/16x16/cancel.png')
        setTooltiptext('Elimina Testo')
        setAutodisable('self')
        setMold('trendy')
        updateView()
        addEventListener(Events.ON_CLICK, this)
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Button))
    }

    ProtocolloDTO getDocumento() {
        return documento
    }

    void setDocumento(ProtocolloDTO documento) {
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

    @Override
    void onEvent(Event event) throws Exception {
        if (event.name == Events.ON_CLICK) {
            Messagebox.show('Eliminare il testo del documento?', 'Attenzione!', Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (Messagebox.ON_OK == e.getName()) {
                    documentoService.eliminaTesto(documento, testo)

                    setTesto(null)
                    Events.postEvent(new Event(ON_TESTO_ELIMINATO, this, testo))
                }
            }
        }
    }

    private void updateView() {
        if(documento?.isProtocollato()) {
            setDisabled( ! ( testo != null && testo.idFileEsterno > 0 && ! documento?.statoFirma?.isFirmaInterrotta() ) )
        } else {
            setDisabled( ! ( testo != null && testo.idFileEsterno > 0 ) )
        }
    }
}
