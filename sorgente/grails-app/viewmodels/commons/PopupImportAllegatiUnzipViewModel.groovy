package commons

import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.utils.zip.SevenZipUtils
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupImportAllegatiUnzipViewModel {

    // servizi
    @WireVariable
    private AllegatoProtocolloService allegatoProtocolloService

    // componenti
    Window self

    // dati
    FileDocumentoDTO fileDocumentoZip
    AllegatoDTO allegato
    ProtocolloDTO protocollo
    List<AllegatoEsterno> allegatiDaImportare = []
    List<AllegatoEsterno> allegatiDisponibili
    AllegatoEsterno allegatoZipDaCuiImportare

    String titolo

    static Window apriPopup(Component component,
                            FileDocumentoDTO fileDocumentoZip,
                            AllegatoDTO allegato,
                            ProtocolloDTO protocollo) {
        Window window = (Window) Executions.createComponents("/commons/popupImportAllegatiUnzip.zul", component,
                [fileDocumentoZip: fileDocumentoZip, allegatoProtocollo: allegato, protocollo: protocollo])
        window.doModal()
        return window
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("fileDocumentoZip") FileDocumentoDTO fileDocumentoZip,
              @ExecutionArgParam("allegatoProtocollo") AllegatoDTO allegato,
              @ExecutionArgParam("protocollo") ProtocolloDTO protocollo) {
        this.titolo = "Seleziona gli allegati da aggiungere estraendoli dal file compresso"
        this.self = w
        this.allegato = allegato
        this.protocollo = protocollo
        this.fileDocumentoZip = fileDocumentoZip

        allegatoZipDaCuiImportare = new AllegatoEsterno(idFileEsterno: fileDocumentoZip.idFileEsterno
                , idDocumentoEsterno: allegato.idDocumentoEsterno
                , nome: fileDocumentoZip.nome
                , formatoFile: FilenameUtils.getExtension(fileDocumentoZip.nome)
                , contentType: fileDocumentoZip.contentType)

        unzipAllegato(allegatoZipDaCuiImportare)
    }

    private void unzipAllegato(AllegatoEsterno allegatoEsterno) {
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

    @Command
    void onAggiungiAllegatoDaImportare(@BindingParam("fileAllegato") AllegatoEsterno allegatoEsterno) {
        if (allegatiDaImportare.contains(allegatoEsterno)) {
            allegatiDaImportare.remove(allegatoEsterno)
        } else {
            allegatiDaImportare.add(allegatoEsterno)
        }
    }

    @Command
    void onImportaAllegati() {

        if (!checkUnivocitaNomiFile()) {
            return
        }

        allegatoProtocolloService.importaAllegatiDaZip(allegato.domainObject, allegatoZipDaCuiImportare, allegatiDaImportare)

        onChiudi()
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    private boolean checkUnivocitaNomiFile() {
        for (allegatoI in allegatiDaImportare) {
            AllegatoProtocolloService.UNIVOCITA_NOMI_FILE univocitaNomiFile
            univocitaNomiFile = allegatoProtocolloService.isNomeFileUnivoco(protocollo.domainObject, allegato, allegatoI.nome)
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
