package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.A
import org.zkoss.zul.Button
import org.zkoss.zul.Window

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class LinkTestoButton extends A implements EventListener<Event> {

    public final static String EVENT_ON_VERIFICA_FIRMA = 'onVerificaFirma'

    private static final Integer MAX_LENGTH = 70

    @WireVariable
    private ProtocolloFileDownloader fileDownloader

    private DocumentoDTO documento
    private FileDocumentoDTO testo

    LinkTestoButton() {

        setStyle("margin-right:10px")

        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Button))
        addEventListener(Events.ON_CLICK, this)
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
        String testoShort = ''
        if(testo?.nome != null) {
            if(testo?.nome?.length() > MAX_LENGTH) {
                testoShort = testo?.nome?.substring(0, Math.min(testo?.nome?.length(), MAX_LENGTH)).concat("...")
            } else {
                testoShort = testo?.nome
            }
        }
        setLabel(testoShort)
        updateView()
    }

    private void updateView() {
        if (testo?.idFileEsterno) {
            visible = true
            setTooltiptext("Scarica il file ${testo.nome}")
        } else {
            visible = false
        }
    }

    @Override
    void onEvent(Event event) throws Exception {
        if (event.name == Events.ON_CLICK) {
            Window w = fileDownloader.downloadFileAllegato(documento, testo.domainObject, false)
            w?.addEventListener(Events.ON_CLOSE) { Event eventClose ->
                if (eventClose.data) {
                    setDocumento((ProtocolloDTO) eventClose.data)
                    Events.postEvent(EVENT_ON_VERIFICA_FIRMA, this, documento)
                }
            }
        }
    }
}
