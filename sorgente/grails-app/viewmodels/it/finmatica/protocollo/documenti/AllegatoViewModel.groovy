package it.finmatica.protocollo.documenti

import commons.PopupImportAllegatiUnzipViewModel
import commons.PopupProtocolloFileFirmatoViewModel
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoAllegatoDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.firma.GestioneDocumentiFirmaService
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.impostazioni.FunzioniService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.FirmaAction
import it.finmatica.protocollo.zk.components.upload.CaricaFileEvent
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.apache.commons.io.FilenameUtils
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Textbox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class AllegatoViewModel {

    // services
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private ProtocolloFileDownloader fileDownloader
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private DocumentoService documentoService
    @WireVariable
    private AllegatoProtocolloService allegatoProtocolloService

    @WireVariable
    GestioneDocumentiFirmaService gestioneDocumentiFirmaService
    @WireVariable
    FirmaAction firmaAction
    @WireVariable
    AllegatoRepository allegatoRepository
    @WireVariable
    private FunzioniService funzioniService

    // componenti
    Window self

    // dati
    AllegatoDTO allegato
    def fileAllegati

    // stato
    def competenze
    ProtocolloDTO documentoPadre
    String uploadAttributeValue
    List<TipoAllegatoDTO> listaTipoAllegato
    boolean abilitaCercaDocumenti
    boolean abilitaConversionePdf
    boolean abilitaImportAllegatiGdm
    boolean abilitaRadioStampaUnica = true
    boolean visButtonFirma = false
    boolean visStampaBrAllegato = false

    static Window apri(Component parent, long idAllegato, ProtocolloDTO protocollo, boolean competenzeModifica) {
        Window w = (Window) Executions.createComponents('/protocollo/documenti/allegato.zul', parent, [id: idAllegato, documento: protocollo, modifica: competenzeModifica])
        w.doModal()
        return w
    }

    @NotifyChange(["allegato", "listaTipoAllegato", "abilitaCreaFascicolo"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") long idAllegato, @ExecutionArgParam("documento") ProtocolloDTO documentoPadre, @ExecutionArgParam("modifica") boolean modifica) {
        this.self = w
        this.documentoPadre = documentoPadre

        competenze = [modifica: modifica, lettura: true, cancellazione: modifica]

        abilitaCercaDocumenti = (Impostazioni.DOCER.abilitato || Impostazioni.IMPORT_ALLEGATO_GDM.abilitato)
        abilitaConversionePdf = Impostazioni.ALLEGATO_CONVERTI_PDF.abilitato
        abilitaImportAllegatiGdm = Impostazioni.IMPORT_ALLEGATO_GDM.abilitato

        if (idAllegato > 0) {
            Allegato a = Allegato.get(idAllegato)
            allegato = a.toDTO()
        } else {
            allegato = new AllegatoDTO(id: idAllegato, valido: true)
            allegato.descrizione = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)?.toDTO()?.descrizione
            allegato.tipoAllegato = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)?.toDTO()
            allegato.stampaUnica = Impostazioni.ALLEGATO_STAMPA_UNICA_DEFAULT.abilitato
            allegato.numPagine = 1
            allegato.quantita = 1
            allegato.statoFirma = StatoFirma.valueOf(Impostazioni.ALLEGATO_STATO_FIRMA_DEFAULT.valore)
            allegato.sequenza = getSequenzaNuovoAllegato()
        }

        // inizializzo i parametri necessari all'accettazione dell'allegato inserito
        uploadAttributeValue = "true,maxsize=${(Integer.parseInt(Impostazioni.ALLEGATO_DIMENSIONE_MASSIMA.valore) * 1024)}"

        listaTipoAllegato = TipoAllegato.findAllByValidoAndCodiceNotInList(true, [TipoAllegato.CODICE_TIPO_STAMPA_UNICA], [sort: "descrizione", order: "asc"]).toDTO()

        ricaricaFileAllegati()
    }

    @Command
    public void doCommand(@BindingParam("val") String val, @BindingParam("descrizioneAllegato") Textbox descrizioneAllegato) {
        if (descrizioneAllegato.getValue().length() == 0) {
            allegato.commento = val
            descrizioneAllegato.value = val
        }
    }

    @AfterCompose
    void afterCompose() {
        if(allegato.id > 0){
            visStampaBrAllegato = true
        }
        Selectors.wireComponents(self, this, false)
    }

    @Command
    void onStampaBarcode() {
      funzioniService.onStampaBcAllegato(allegato)
    }

    private void verificaAbilitazioneRadioStampaUnica() {
        if (!allegatoProtocolloService.isAbilitazioneStampaUnica(allegato)) {
            allegato.stampaUnica = false
            abilitaRadioStampaUnica = false
        } else {
            abilitaRadioStampaUnica = true
        }
        BindUtils.postNotifyChange(null, null, this, "allegato")
        BindUtils.postNotifyChange(null, null, this, "abilitaRadioStampaUnica")
    }

    private int getSequenzaNuovoAllegato() {
        return documentoService.getSequenzaNuovoAllegato(documentoPadre)
    }

    private void verificaPulsanteFirma() {

        if (!allegato.statoFirma?.isFirmaInterrotta()) {
            if (allegato.id != -1 && fileAllegati.size() > 0 && allegato.statoFirma == StatoFirma.DA_FIRMARE && ImpostazioniProtocollo.FIRMA_ALLEGATO.valore == 'Y' && competenze.modifica == true) {
                visButtonFirma = true
            } else {
                visButtonFirma = false
            }
        } else {
            visButtonFirma = true
        }

        BindUtils.postNotifyChange(null, null, this, "visButtonFirma")
    }

    private void ricaricaFileAllegati() {
        fileAllegati = Allegato.createCriteria().list {
            projections {
                fileDocumenti {
                    property "nome"           // 0
                    property "id"             // 1
                    property "contentType"    // 2
                    property "modificabile"   // 3
                    property "firmato"        // 4
                    property "dimensione"     // 5
                    property "idFileEsterno"  // 6
                    property "dataVerifica"   // 7
                    property "esitoVerifica"  // 8
                }
            }
            eq("id", allegato.id)
            fileDocumenti {
                eq("valido", true)
                eq("codice", FileDocumento.CODICE_FILE_ALLEGATO)
                ge("idFileEsterno", (long) 0)
            }
            fileDocumenti {
                order("id", "asc")
            }
        }.collect { row -> new FileDocumentoDTO(nome: row[0], id: row[1], contentType: row[2], modificabile: row[3], firmato: row[4], dimensione: row[5], idFileEsterno: row[6],
                dataVerifica: row[7], esitoVerifica: row[8]) }

        verificaPulsanteFirma()
        verificaAbilitazioneRadioStampaUnica()

        BindUtils.postNotifyChange(null, null, this, "fileAllegati")
    }

    private void ricaricaAllegato() {
        allegato = Allegato.createCriteria().get {
            eq("id", allegato.id)
        }.toDTO()
        BindUtils.postNotifyChange(null, null, this, "allegato")
    }

    @Command
    void onCaricaFile(@ContextParam(ContextType.TRIGGER_EVENT) CaricaFileEvent event) {
        allegato = documentoService.salvaAllegato(allegato, documentoPadre).toDTO()
        documentoService.uploadFile(allegato.domainObject, event.filename, event.contentType, event.inputStream)
        if (documentoPadre.numero > 0) {
            protocolloService.storicizzaProtocollo(documentoPadre.domainObject)
        }
        if (event.last) {
            ricaricaFileAllegati()
            ClientsUtils.showInfo('File salvato')
        }
    }

    @Command
    void onApriPopupRicercaDocumenti() {
        if (allegato.descrizione == null) {
            ClientsUtils.showWarning("Compilare il campo obbligatorio titolo")
            return
        }

        Window w = Executions.createComponents("/commons/popupImportAllegati.zul", self, [documento: documentoPadre, allegato: allegato])
        w.onClose { event ->
            if (event.data) {
                allegato = event.data
                ricaricaFileAllegati()
                BindUtils.postNotifyChange(null, null, this, "allegato")
                BindUtils.postNotifyChange(null, null, this, "fileAllegati")
            }
        }
        w.doModal()
    }

    @NotifyChange("fileAllegati")
    @Command
    void onEliminaFileAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("fileAllegato") value) {
        if (!allegatoProtocolloService.isFileAllegatoEliminabile(allegato)) {
            ClientsUtils.showError(StringUtils.join("Impossibile elimare il file.\nDeve esistere almeno un file su ogni allegato.", "\n"))
            return
        } else {
            Messagebox.show("Eliminare il file selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (Messagebox.ON_OK.equals(e.getName())) {
                    documentoService.eliminaFileDocumento(allegato.domainObject, value.id)
                    if (documentoPadre.numero > 0) {
                        protocolloService.storicizzaProtocollo(documentoPadre.domainObject)
                    }
                    this.ricaricaFileAllegati()
                }
            }
        }
    }

    @Command
    void onChangeStatoFirma() {
        verificaPulsanteFirma()
    }

    @Command
    void onDownloadFileAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("fileAllegato") value) {
        if (FileDocumento.get(value.id).isFirmato() || (FileDocumento.get(value.id).isPdf() && ImpostazioniProtocollo.COPIA_CONFORME_PDF.abilitato)) {
            PopupProtocolloFileFirmatoViewModel.apriPopup(allegato, FileDocumento.get(value.id).toDTO(), false).addEventListener(Events.ON_CLOSE) {
                ricaricaFileAllegati()
            }
        } else {
            fileDownloader.downloadFile(allegato.domainObject, FileDocumento.get(value.id), false)
        }
    }

    @Command
    void onCambiaNome() {
        this.ricaricaFileAllegati()
    }

    private boolean validaMaschera() {
        def messaggi = []

        if (allegato.descrizione?.size() > 255) {
            messaggi << ("Dimensioni del campo Titolo superiori a 255 caratteri")
        }

        if (allegato.descrizione == null) {
            messaggi << ("il campo 'Titolo' è obbligatorio")
        }

        if (allegato.descrizione != null && !Utils.controllaCharset(allegato.descrizione)) {
            messaggi << "Il campo 'Titolo' contiene dei caratteri non supportati."
        }

        if (allegato.statoFirma == StatoFirma.DA_FIRMARE && !(fileAllegati?.size() > 0)) {
            messaggi << ("Se si vuole firmare l'allegato è necessario inserire almeno un file")
        }

        if (allegato.stampaUnica && !(fileAllegati?.size() > 0)) {
            messaggi << ("Se si vuole inserire l'allegato in stampa unica è necessario inserire almeno un file")
        }

        if (allegato.stampaUnica && allegato.riservato) {
            messaggi << ("Un allegato riservato non può essere inserito in stampa unica")
        }

        if (allegato.descrizione != null && !Utils.controllaCharset(allegato.descrizione)) {
            messaggi << "Il campo 'Descrizione' contiene dei caratteri non supportati."
        }

        if (allegato.tipoAllegato == null) {
            messaggi << "Il campo 'Tipo Allegato' è obbligatorio."
        }

        if (messaggi.size() > 0) {
            messaggi.add(0, "Impossibile salvare l'allegato:")
            ClientsUtils.showError(StringUtils.join(messaggi, "\n"))
            return false
        }

        return true
    }

    @Command
    void onSalva() {

        AllegatoProtocolloService.UNIVOCITA_NOMI_FILE univocitaNomiFile
        univocitaNomiFile = allegatoProtocolloService.isUnivocitaFileAllegati(documentoPadre.domainObject, allegato, allegato.statoFirma)
        if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_ALLEGATO)) {
            ClientsUtils.showError("Non è possibile caricare due volte un file con lo stesso nome.")
            return
        }

        if (!validaMaschera()) {
            return
        }
        allegato = documentoService.salvaAllegato(allegato, documentoPadre).toDTO()
        if (documentoPadre.numero > 0) {
            protocolloService.storicizzaProtocollo(documentoPadre.domainObject)
        }
        verificaPulsanteFirma()
        visStampaBrAllegato = true

        BindUtils.postNotifyChange(null, null, this, "visStampaBrAllegato")
        Clients.showNotification("Allegato Salvato", Clients.NOTIFICATION_TYPE_INFO, self, "before_center", 3000, true)
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onSalvaChiudi() {
        if (!validaMaschera()) {
            return
        }
        onSalva()
        onChiudi()
    }

    @Command
    void onEditaFileDocumento(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("fileAllegato") FileDocumentoDTO fileDocumentoDTO) {
        documentoService.editaTesto(allegato, fileDocumentoDTO)
    }

    @Command
    void onDownloadPdfFileAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("fileAllegato") def value) {
        documentoService.anteprimaAllegatoPdf(allegato.domainObject, FileDocumento.get(value.id));
    }

    boolean fileCompresso(FileDocumentoDTO fileDocumentoDTO) {
        String ext
        ext = FilenameUtils.getExtension(fileDocumentoDTO?.nome)

        return (ext?.equals("rar") || ext?.equals("zip"))
    }

    @Command
    void onUnzipAllegato(@BindingParam("fileAllegato") FileDocumentoDTO fileDocumentoDTO) {
        PopupImportAllegatiUnzipViewModel.apriPopup(null, fileDocumentoDTO, allegato, documentoPadre).addEventListener(Events.ON_CLOSE) {
            ricaricaFileAllegati()
        }
    }

    @Command
    void onFirmaAllegato() {

        // recupero il documento
        Documento allegato = Documento.findById(allegato.id)

        // setto il firmatario
        Ad4Utente utenteAd4 = springSecurityService.currentUser
        gestioneDocumentiFirmaService.aggiungiFirmatarioAllaCoda(allegato, utenteAd4)

        // preparo gli allegati per la firma
        gestioneDocumentiFirmaService.preparaFirmatarioInCoda(allegato)
        List<FileDocumento> listaFileDocumento = allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO)
        firmaAction.verificaFilePdfFirmaPADES(allegato, listaFileDocumento)
        gestioneDocumentiFirmaService.preparaFilePerFirma(listaFileDocumento)

        // predispongo per la firma
        gestioneDocumentiFirmaService.finalizzaTransazioneFirma()

        // apro ulr firma
        Window w = Executions.createComponents("/commons/popupFirma.zul", self, [urlPopupFirma: gestioneDocumentiFirmaService.urlPopupFirma])
        w.onClose { event ->
            ricaricaAllegato()
            ricaricaFileAllegati()
        }
        w.doModal()
    }
}
