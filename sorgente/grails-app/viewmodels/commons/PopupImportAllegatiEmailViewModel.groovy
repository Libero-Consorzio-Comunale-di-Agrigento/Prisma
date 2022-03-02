package commons

import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.integrazioni.ricercadocumenti.DocumentoEsterno
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.utils.zip.SevenZipUtils
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.zkoss.bind.BindUtils
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
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Radio
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupImportAllegatiEmailViewModel {

    // servizi
    @WireVariable
    private AllegatoProtocolloService allegatoProtocolloService
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private ProtocolloFileDownloader fileDownloader
    @WireVariable
    private DocumentoCollegatoRepository documentoCollegatoRepository
    @WireVariable
    private IGestoreFile gestoreFile

    // componenti
    Window self

    // dati
    ProtocolloDTO protocollo
    List<AllegatoEsterno> allegatiDisponibili = []
    List<AllegatoEsterno> allegatiDaImportare = []
    List<AllegatoEsterno> allegatiSecondariDaImportare = []
    AllegatoEsterno allegatoPrincipale
    AllegatoEsterno allegatoZipDaCuiImportare
    AllegatoEsterno allegatoVuoto = new AllegatoEsterno(idFileEsterno: -1, idDocumentoEsterno: -1, idDocumentoPrincipale: -1)

    String titolo
    String nomePulsanteSalvaImporta
    boolean importaAllegatiMancanti
    boolean unzip
    boolean scegliAllegatiSecondari

    static Window apriPopup(Component component,
                            ProtocolloDTO protocollo,
                            boolean importaAllegatiMancanti = true,
                            boolean unzip = false,
                            boolean unzipFilePrincipaleProtocollo = false) {
        Window window = (Window) Executions.createComponents("/commons/popupImportAllegatiEmail.zul", component, [protocollo                   : protocollo,
                                                                                                                  importaAllegatiMancanti      : importaAllegatiMancanti,
                                                                                                                  unzip                        : unzip,
                                                                                                                  unzipFilePrincipaleProtocollo: unzipFilePrincipaleProtocollo])
        window.doModal()
        return window
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") ProtocolloDTO protocollo,
              @ExecutionArgParam('importaAllegatiMancanti') boolean importaAllegatiMancanti, @ExecutionArgParam('unzip') boolean unzip,
              @ExecutionArgParam('unzipFilePrincipaleProtocollo') boolean unzipFilePrincipaleProtocollo) {
        this.self = w
        this.protocollo = protocollo
        this.allegatoPrincipale = allegatoVuoto
        this.importaAllegatiMancanti = importaAllegatiMancanti
        this.unzip = unzip
        this.nomePulsanteSalvaImporta = "Importa"

        if (unzipFilePrincipaleProtocollo) {
            //Provengo da protocollo manuale con un file ZIP allegato ed ho scelto di unzipparlo per sostituire
            //File principale ed eventuali allegati
            titolo = 'Decomprimi archivio'
            this.nomePulsanteSalvaImporta = "Salva"

            AllegatoEsterno allegatoEsterno = new AllegatoEsterno(idFileEsterno: protocollo.testoPrincipale.idFileEsterno,
                    idDocumentoEsterno: protocollo.idDocumentoEsterno,
                    nome: protocollo.testoPrincipale.nome,
                    formatoFile: FilenameUtils.getExtension(protocollo.testoPrincipale.nome),
                    contentType: protocollo.testoPrincipale.contentType
            )
            onUnzipAllegato(allegatoEsterno)
        } else {
            DocumentoCollegato documentoCollegato
            documentoCollegato = documentoCollegatoRepository.collegamentoPadrePerTipologia(protocollo.domainObject,
                    TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL))
            if (documentoCollegato != null && protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
                //Provengo da un protocollo in partenza collegato ad un messaggio in arrivo.
                //Faccio vedere i file del messaggio da importare
                scegliAllegatiSecondari = true
                MessaggioRicevuto messaggioRicevuto = (MessaggioRicevuto) documentoCollegato.documento
                for (FileDocumento fileDocumento : messaggioRicevuto.fileDocumenti) {

                    allegatiDisponibili << new AllegatoEsterno(idFileEsterno: fileDocumento.idFileEsterno
                            , idDocumentoEsterno: null
                            , nome: fileDocumento.nome
                            , formatoFile: FilenameUtils.getExtension(fileDocumento.nome)
                            , contentType: fileDocumento.contentType)
                }
            } else {
                if (importaAllegatiMancanti) {
                    titolo = 'Importa Allegati Email'
                    allegatiDisponibili = allegatoProtocolloService.getAllegatiEmailNonImportati(protocollo.domainObject)
                } else {
                    titolo = 'Seleziona file principale'
                    allegatiDisponibili = allegatoProtocolloService.getFileDaPec(protocollo.domainObject)
                }
            }
        }
    }

    @Command
    void onSelezionaAllegatoPrincipale(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        Radio radio = event.target
        if (!radio.checked) {
            radio.radiogroup.selectedIndex = -1
        } else {
            radio.checked = true
        }
    }

    @Command
    void onImportaAllegati() {
        if (importaAllegatiMancanti) {
            importaAllegatiMancanti()
        } else {
            if (!importaAllegati()) {
                return
            }
        }

        ClientsUtils.showInfo("Allegati importati")
        Events.postEvent(Events.ON_CLOSE, self, true)
    }

    @Command
    void onCambiaNome() {
        BindUtils.postNotifyChange(null, null, this, "allegatiDisponibili")
    }

    @Command
    void onAggiungiAllegatoDaImportare(@BindingParam("fileAllegato") AllegatoEsterno allegatoEsterno) {
        if (allegatiSecondariDaImportare.contains(allegatoEsterno)) {
            allegatiSecondariDaImportare.remove(allegatoEsterno)
        } else {
            allegatiSecondariDaImportare.add(allegatoEsterno)
        }
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileAllegato") AllegatoEsterno allegatoEsterno) {
        fileDownloader.downloadFileAllegato(new DocumentoEsterno(), allegatoEsterno, false)
    }

    @NotifyChange(["allegatiDisponibili", "unzip", "scegliAllegatiSecondari"])
    @Command
    void onUnzipAllegato(@BindingParam("fileAllegato") AllegatoEsterno allegatoEsterno) {
        //Escludo la possibilità di fare unzip dell'unzip
        this.unzip = false
        this.scegliAllegatiSecondari = true
        this.allegatoZipDaCuiImportare = allegatoEsterno

        File tempZip = allegatoProtocolloService.getFileTemporaneoZipAllegato(allegatoEsterno)

        try {
            SevenZipUtils zipUtils = new SevenZipUtils()
            List<String> listaNomiFile = zipUtils.flatUnzipFile(tempZip, "_")
            allegatiDisponibili = []

            for (nomeFile in listaNomiFile) {
                allegatiDisponibili << new AllegatoEsterno(idFileEsterno: null
                        , idDocumentoEsterno: null
                        , nome: nomeFile
                        , formatoFile: FilenameUtils.getExtension(nomeFile)
                        , contentType: null)
            }
        } finally {
            FileUtils.deleteQuietly(tempZip)
        }
    }

    private void importaAllegatiMancanti() {
        // mi assicuro di non importare il file principale
        if (protocollo.numero > 0) {
            allegatoPrincipale = null
        }

        if (allegatoPrincipale?.idFileEsterno > 0 && !(allegatiDaImportare.idFileEsterno.contains(allegatoPrincipale?.idFileEsterno))) {
            ClientsUtils.showWarning("Attenzione: il file selezionato come principale non è selezionato per essere importato.")
            return
        }

        Protocollo p = protocollo.domainObject
        protocolloService.salva(p, protocollo)
        allegatoProtocolloService.importaAllegatiEmail(p, allegatiDaImportare, allegatoPrincipale)
    }

    private boolean importaAllegati() {

        if (!checkUnivocitaNomiFile()) {
            return false
        }

        Protocollo p = protocollo.domainObject
        protocolloService.salva(p, protocollo)

        if (allegatoZipDaCuiImportare != null) {
            //Elimino dai secondari il principale se checcato per errore
            if (allegatiSecondariDaImportare.contains(allegatiDaImportare[0])) {
                allegatiSecondariDaImportare.remove(allegatiDaImportare[0])
            }
            allegatoProtocolloService.importaAllegatiDaZip(p, allegatoZipDaCuiImportare, allegatiSecondariDaImportare, allegatiDaImportare[0])
        } else if (allegatiDaImportare && allegatiDaImportare.size() > 0) {
            if (allegatiDaImportare[0].nome.contains("'") || allegatiDaImportare[0].nome.contains("@")) {
                ClientsUtils.showError("Impossibile caricare il file: il nome dell'allegato contiene caratteri non consentiti ( ' @ ). E' possibile rinominarlo")
                return false
            }
            allegatoProtocolloService.importaAllegatiEmail(p, allegatiDisponibili, allegatiDaImportare[0])
        }

        return true
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    private boolean checkUnivocitaNomiFile() {
        for (allegatoI in allegatiSecondariDaImportare) {
            AllegatoProtocolloService.UNIVOCITA_NOMI_FILE univocitaNomiFile
            univocitaNomiFile = allegatoProtocolloService.isNomeFileUnivoco(protocollo.domainObject, null, allegatoI.nome)
            if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_PRINCIPALE)) {
                ClientsUtils.showError("Impossibile caricare il file: il file ${allegatoI.nome} ha lo stesso nome dei file principale del documento.")
                return false
            }
            if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_ALLEGATO)) {
                ClientsUtils.showError("Non è possibile caricare due volte un file con lo stesso nome: ${allegatoI.nome}.")
                return false
            }
        }

        return true
    }
}