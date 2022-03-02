package it.finmatica.protocollo.zk.components.testo

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.protocollo.zk.components.upload.CaricaFileButton
import it.finmatica.protocollo.zk.components.upload.CaricaFileEvent
import it.finmatica.protocollo.zk.components.upload.ScanButton
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Span

@CompileStatic
@ComponentAnnotation(['testo:@ZKBIND(ACCESS=both, SAVE_EVENT=onCaricaTesto)', 'documento:@ZKBIND(ACCESS=both, SAVE_EVENT=onCaricaTesto)'])
@VariableResolver(DelegatingVariableResolver)
class CaricaTestoComponent extends Span implements EventListener<CaricaFileEvent> {

    public static final String ON_CARICA_TESTO = 'onCaricaTesto'
    public static final String ON_SALVA_TESTO = 'onSalvaTesto'

    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private PreferenzeUtenteService preferenzeUtenteService

    private final CaricaFileButton btnCaricaTesto = new CaricaFileButton()
    private final LinkTestoButton linkDownloadTesto = new LinkTestoButton()
    private final RinominaFileComponent cambiaNomeComponent = new RinominaFileComponent(false)
    private final ScanButton btnScan = new ScanButton()

    private ProtocolloDTO documento
    private FileDocumentoDTO testo
    private boolean readOnly

    CaricaTestoComponent() {

        appendChild(linkDownloadTesto)
        appendChild(cambiaNomeComponent)

        addEventListener(Events.ON_UPLOAD, this)

        btnCaricaTesto.addEventListener(CaricaFileEvent.EVENT_ON_CARICA_FILE, this)
        btnScan.addEventListener(CaricaFileEvent.EVENT_ON_CARICA_FILE, this)
        linkDownloadTesto.addEventListener(LinkTestoButton.EVENT_ON_VERIFICA_FIRMA) { Event event ->
            setDocumento((ProtocolloDTO) event.data)
            Events.postEvent(ON_CARICA_TESTO, this, documento)
        }
        linkDownloadTesto.setStyle("margin-right:20px")

        cambiaNomeComponent.visible = false
        cambiaNomeComponent.addEventListener(RinominaFileComponent.ON_CHANGE_FILEDOCUMENTO) { Event event ->
            linkDownloadTesto.visible = !cambiaNomeComponent.nomeFileText.visible
        }
        cambiaNomeComponent.addEventListener(RinominaFileComponent.ON_CHANGE_NAME) { Event event ->
            setTesto(documento.testoPrincipale)
        }

        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Span))
    }

    ProtocolloDTO getDocumento() {
        return documento
    }

    void setDocumento(ProtocolloDTO documento) {
        this.documento = documento

        linkDownloadTesto.setDocumento(documento)

        if (isVisibleBtnCaricaTestoAndScan()) {
            //Per il pulsante scan devono valere altre condizione (impostazione scanner = Y e categoria diversa da PEC)
            if(! documento.categoriaProtocollo?.isPec() && ImpostazioniProtocollo.SCANNER.isAbilitato()) {
                appendChild(btnScan)
                btnScan.setDocumento(documento)
            } else {
                removeChild(btnScan)
                btnScan.setDocumento(documento)
            }
            appendChild(btnCaricaTesto)
            btnCaricaTesto.setDocumento(documento)

        } else {
            removeChild(btnScan)
            removeChild(btnCaricaTesto)
            btnCaricaTesto.setDocumento(documento)
            btnScan.setDocumento(documento)
        }
    }

    FileDocumentoDTO getTesto() {
        return testo
    }

    void setTesto(FileDocumentoDTO testo) {
        this.testo = testo
        linkDownloadTesto.setTesto(testo)
        if (testo?.nome != null) {
            cambiaNomeComponent.visible = true
            cambiaNomeComponent.setFileDocumento(testo)
        } else {
            cambiaNomeComponent.setVisible(false)
        }
    }

    boolean getReadOnly() {
        return readOnly
    }

    boolean isVisibleBtnCaricaTestoAndScan() {
        Ad4Utente utenteAd4 = springSecurityService.currentUser
        return protocolloService.isModificabilitaTesto(documento?.domainObject, utenteAd4)
    }

    //(versione4.1) In caso di firma interrotta bisogna rendere visibili i pulsanti
    //per la sostituzione del file (come per la lettera)
    void setReadOnly(boolean readOnly) {
        this.readOnly = readOnly ||
                // documento?.statoFirma?.firmato ||
                //documento?.statoFirma?.firmaInterrotta ||
                !(testo?.modificabile ?: true)
        if (this.readOnly) {
            btnScan.setVisible(false)
            btnCaricaTesto.setVisible(false)
            cambiaNomeComponent.setVisible(false)
            linkDownloadTesto.setVisible(true)
        } else {
            btnScan.setVisible(true)
            btnCaricaTesto.setVisible(true)
            linkDownloadTesto.setVisible(true)
        }
    }

    @Override
    void onEvent(CaricaFileEvent event) throws Exception {
        CaricaFileEvent scanEvent = (CaricaFileEvent) event

        Protocollo protocollo = new Protocollo()
        // salvo il protocollo
        if (documento.idDocumentoEsterno != null) {
            protocollo = documento.domainObject
            protocolloService.salva(protocollo, documento, false)
        } else {
            Events.postEvent(ON_SALVA_TESTO, this, scanEvent)
            return
        }

        protocolloService.caricaFilePrincipale(protocollo, scanEvent.inputStream, scanEvent.contentType, scanEvent.filename)
        documento = (ProtocolloDTO) protocollo.toDTO('fileDocumenti')
        FileDocumentoDTO testo = documento.fileDocumenti.find { it.codice == FileDocumento.CODICE_FILE_PRINCIPALE }

        setTesto(testo)
        setDocumento(documento)

        ClientsUtils.showInfo('Testo Principale caricato')
        Events.postEvent(ON_CARICA_TESTO, this, testo)
    }
}
