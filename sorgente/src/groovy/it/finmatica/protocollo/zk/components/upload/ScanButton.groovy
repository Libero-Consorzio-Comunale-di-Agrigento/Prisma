package it.finmatica.protocollo.zk.components.upload

import groovy.transform.CompileStatic
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.webscan.WebScanCallback
import it.finmatica.webscan.WebScanService
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Textbox
import org.zkoss.zul.Window

@CompileStatic
@VariableResolver(DelegatingVariableResolver)
class ScanButton extends AbstractCaricaFileButton implements EventListener<Event>, WebScanCallback {

    @WireVariable
    private PreferenzeUtenteService preferenzeUtenteService
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private WebScanService webScanService

    // Salvo localmente i file scansionati. È 'accettabile' che la popup di scansione serva per 'un solo file' anche se la stessa consente la scansione di più file alla volta.
    private File fileStore
    private String fileName
    private String contentType
    private long idCallback

    private String prefissoNomeFileScansione = 'scansione'
    private boolean scansioneDiretta = false
    private boolean isPdf = true

    // componenti per la richiesta del nome file
    private Window popupRichiediNomeFileScansione
    @Wire("#salva")
    private Button btnSalva
    @Wire("#annulla")
    private Button btnAnnulla
    @Wire("#reimposta")
    private Button btnReimposta
    @Wire("#nomeFile")
    private Textbox textboxNomeFile

    ScanButton() {
        setImage('/images/afc/16x16/scanner.png')
        setAutodisable('self')
        setMold('trendy')
        setTooltiptext('Scansiona')

        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Button))
        addEventListener(Events.ON_CLICK, this)
    }

    void initPopupRichiediNomeFile() {
        if (popupRichiediNomeFileScansione != null) {
            return
        }

        popupRichiediNomeFileScansione = (Window) Executions.createComponents('/commons/popupRichiediNomeFile.zul', null, [:])
        Selectors.wireComponents(popupRichiediNomeFileScansione, this, false)

        textboxNomeFile.value = prefissoNomeFileScansione

        btnSalva.addEventListener(Events.ON_CLICK) {
            prefissoNomeFileScansione = textboxNomeFile.value
            apriPopupScansione()
            popupRichiediNomeFileScansione.setVisible(false)
        }

        btnAnnulla.addEventListener(Events.ON_CLICK) {
            popupRichiediNomeFileScansione.setVisible(false)
        }

        btnReimposta.addEventListener(Events.ON_CLICK) {
            textboxNomeFile.value = prefissoNomeFileScansione
        }
    }

    @Override
    void onEvent(Event event) throws Exception {
        if (event.name == Events.ON_CLICK) {
            if (preferenzeUtenteService.scanRichiediFilename) {
                initPopupRichiediNomeFile()
                popupRichiediNomeFileScansione.doModal()
                return
            }
            apriPopupScansione()
        } else if (event.name == Events.ON_CLOSE) {
            onChiudiPopupScansione()
        }
    }

    private void apriPopupScansione() {
        idCallback = webScanService.registerCallback(this, getNominativoUtente())

        if (!preferenzeUtenteService.scanAbilitaImpostazioni) {
            scansioneDiretta = true
        }

        String urlScansione = webScanService.buildUrlWebScan(idCallback, scansioneDiretta, isPdf)
        Window popupScansione = (Window) Executions.createComponents('/commons/popupScansione.zul', null, [urlScansione: urlScansione])
        popupScansione.addEventListener(Events.ON_CLOSE, this)
        popupScansione.doModal()
    }

    private void onChiudiPopupScansione() {
        if (isPdf) {
            fileName = prefissoNomeFileScansione+".pdf"
        }

        // se non ho il file salvato, significa che ho annullato la scansione e non faccio nulla.
        if (fileStore == null) {
            ClientsUtils.showWarning("Scansione Annullata.")
            return
        }

        uploadFile(fileStore, fileName, contentType)

        webScanService.unregisterCallback(idCallback)

        // svuoto i campi
        idCallback = -1
        fileStore = null
        fileName = null
        contentType = null
    }

    private String getNominativoUtente() {
        return springSecurityService.principal.username
    }

    @Override
    void callback(String nominativoUtente, String nomeFile, String contentType, InputStream inputStream) {
        fileStore = File.createTempFile("temp", "pdf")
        fileStore << inputStream
        this.fileName = nomeFile
        this.contentType = contentType
    }
}
