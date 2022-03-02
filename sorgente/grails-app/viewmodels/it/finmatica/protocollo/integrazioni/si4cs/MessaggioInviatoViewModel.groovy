package it.finmatica.protocollo.integrazioni.si4cs

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.commons.AbstractViewModel
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.MessaggioDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Filedownload
import org.zkoss.zul.Window

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class MessaggioInviatoViewModel extends AbstractViewModel<MessaggioInviato> {
    @WireVariable
    MessaggiInviatiService messaggiInviatiService
    @WireVariable
    DocumentaleService documentaleService

    // componenti
    Window self

    //variabili del messaggio non memorizzate
    String idMessaggio

    MessaggioInviatoDTO messaggioInviato
    MessaggioDTO messaggioDTO

    Set<DocumentoCollegatoDTO> listaCollegamenti = [] as Set

    static Window apriPopup(Map parametri) {
        Window window
        window = (Window) Executions.createComponents("/protocollo/integrazioni/si4cs/messaggioInviato.zul", null, parametri)
        window.doModal()
        return window
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w,
              @ExecutionArgParam("idMessaggio") String idMsg) {
        this.self = w
        idMessaggio = idMsg

        messaggioInviato = messaggiInviatiService.getMessaggio(Long.parseLong(idMessaggio))?.toDTO(["utente", "fileDocumenti"])
        messaggioDTO = messaggiInviatiService.getMessaggioDto(Long.parseLong(idMessaggio))

        listaCollegamenti = [messaggiInviatiService.getDocumentoCollegato(messaggioInviato.domainObject).toDTO(["tipoCollegamento.*"])]

        for (documentoCollegato in messaggiInviatiService.getDocumentiReferenti(messaggioInviato.domainObject)) {
            listaCollegamenti.add(documentoCollegato.toDTO(["tipoCollegamento.*"]))
        }
    }

    String getUtenteCollegato() {
        return springSecurityService.principal.cognomeNome
    }

    String getStatoSpedizione() {
        if (messaggioInviato.statoSpedizione == null) {
            return "Passato al servizio di spedizione"
        } else {
            return messaggioInviato.statoSpedizione
        }
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileDocumento") fileDocumento) {
        File file = new File()
        file.setId("" + fileDocumento.idFileEsterno)

        file = documentaleService.getFile(new Documento(), file)

        Filedownload.save(file.getInputStream(), file.getContentType(), file.getNome())
    }

    @Command
    void onChiudi() {
        Clients.evalJavaScript(" window.close(); ")
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onApriTestoMessaggio() {
        Window window = (Window) Executions.createComponents("/commons/popupTestoMessaggio.zul", null, [testo: messaggioInviato.testo?.replaceAll("\r\n", "<BR>")])
        window.doModal()
    }

    void aggiornaDocumentoIterabile(MessaggioInviato m) {
    }

    void aggiornaMaschera(MessaggioInviato d) {
    }

    MessaggioInviato getDocumentoIterabile(boolean controllaConcorrenza) {
        super.getDocumentoIterabile(controllaConcorrenza)
    }

    Collection<String> validaMaschera() {
        super.validaMaschera()
    }

    String getOggettoRiferimento(DocumentoCollegatoDTO documentoCollegatoDTO) {
        if (documentoCollegatoDTO.collegato.class == MessaggioRicevutoDTO.class) {
            return documentoCollegatoDTO.collegato.oggetto
        }
        else {
            return documentoCollegatoDTO.documento.oggetto
        }
    }

    @Override
    WkfCfgIter getCfgIter() {
        return null
    }

    @Command
    void apriDocumentoCollegato(@BindingParam("documentoCollegato") DocumentoCollegatoDTO documentoCollegato) {
        DocumentoDTO documento
        if (documentoCollegato.documento.id != messaggioInviato.id) {
            documento = documentoCollegato.documento
        } else {
            documento = documentoCollegato.collegato
        }

        if (documento.class == ProtocolloDTO.class) {
            String link = ProtocolloEsterno.findByIdDocumentoEsterno(documento.idDocumentoEsterno)?.linkDocumento
            Clients.evalJavaScript(" window.open('" + link + "'); ")
        } else if (documento.class == MessaggioRicevutoDTO.class) {
            Clients.evalJavaScript(" window.open('/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_RICEVUTO&id=" + documento.id + "');")
        } else if (documento.class == MessaggioInviatoDTO.class) {
            Clients.evalJavaScript(" window.open('/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_INVIATO&id=" + documento.id + "');")
        }
    }
}
