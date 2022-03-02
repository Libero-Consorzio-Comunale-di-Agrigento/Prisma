package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionetesti.EsitoRichiestaLock
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloService
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class EditaTestoButton extends Button implements EventListener<Event> {

    private final static String SRC_IMG_DOWNLOAD_TESTO = "/images/ags/16x16/document.png"
    private final static String SRC_IMG_EDITA_TESTO = "/images/ags/16x16/pencil.png"
    public final static String ON_LOCK_TESTO = "onLockTesto"
    public final static String ON_VERIFICA_FIRMA = "onVerifcaFirma"

    @WireVariable
    private DocumentoService documentoService
    @WireVariable
    private GestioneTestiService gestioneTestiService
    @WireVariable
    private TipoProtocolloService tipoProtocolloService

    @WireVariable
    private ProtocolloFileDownloader fileDownloader

    private DocumentoDTO documento
    private FileDocumentoDTO testo
    private boolean readOnly = false

    private boolean applet = false

    EditaTestoButton() {

        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Button))

        updateView()
        setAutodisable("self")
        setMold("trendy")
        addEventListener(Events.ON_CLICK, this)
        addEventListener(ON_VERIFICA_FIRMA, this)
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
                documento?.statoFirma?.firmaInterrotta ||
                !(testo?.modificabile ?: true)
        updateView()
    }

    @Override
    void onEvent(Event event) throws Exception {
        if (event.name == Events.ON_CLICK) {
            // se il pulsante è readonly, scarico direttamente il file
            if (readOnly) {
                Window w = fileDownloader.downloadFileAllegato(documento, testo.domainObject, false)
                w?.addEventListener(Events.ON_CLOSE) { Event eventClose ->
                    if (eventClose.data) {
                        setDocumento((ProtocolloDTO) eventClose.data)
                        Events.postEvent(ON_VERIFICA_FIRMA, this, documento)
                    }
                }
                return
            }

            // altrimenti, faccio "edita-testo"
            EsitoRichiestaLock esitoRichiestaLock = documentoService.editaTesto(documento, testo)

            if (esitoRichiestaLock.esitoLock) {
                Events.postEvent(new Event(ON_LOCK_TESTO, this, esitoRichiestaLock))
            }

            boolean testoLockato = esitoRichiestaLock.esitoLock
            // FIXME: è giusto che questo sia qui dentro? non è forse meglio che sia una "reaction" da qualche altra parte?
            if (!testoLockato) {
                Messagebox.show(esitoRichiestaLock.messaggio, "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                    if (Messagebox.ON_OK == e.getName()) {
                        fileDownloader.downloadFileAllegato(documento, testo.domainObject)
                    }
                }
            }

            updateView()
        }
    }

    private void updateView() {

        setVisible(documento?.idDocumentoEsterno > 0 && testo != null)

        if (readOnly) {
            setImage(SRC_IMG_DOWNLOAD_TESTO)
            setLabel("")
        } else {
            setImage(SRC_IMG_EDITA_TESTO)
            setLabel("")
            if (visible && !applet) {
                
                //verificare se instance of protocolloDTO allora verifica categoria modello testo obbligatorio
                //e se ci sono effettivamente dei modelli testo associati al tipo protocollo. Se vero allora caricaApplet = true.
                //Nota: Sono gli stessi controlli che vengono richiamati in ProtocolloViewModel per verificare la presenza dell'edita testo.
                boolean caricaApplet
                if (documento instanceof ProtocolloDTO) {
                    Protocollo protocollo = (Protocollo) documento.domainObject
                    if (protocollo?.categoriaProtocollo != null && protocollo.categoriaProtocollo.modelloTestoObbligatorio) {
                        if (protocollo?.tipoProtocollo?.id != null && tipoProtocolloService.listaModelliTesto(protocollo.tipoProtocollo.id).size() > 0) {
                            caricaApplet = true
                        }
                    }
                }

                if (caricaApplet) {
                    gestioneTestiService.abilitaApplet()
                    applet = true
                }
            }
        }
    }
}
