package commons

import it.finmatica.firmadigitale.utils.VerificatoreFirma
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoService
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.StampaUnicaService
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupProtocolloFileFirmatoViewModel {

    // services
    @WireVariable
    private ProtocolloFileDownloader fileDownloader
    @WireVariable
    private StampaUnicaService stampaUnicaService
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private IGestoreFile gestoreFile
    @WireVariable
    private FileDocumentoService fileDocumentoService

    // componenti
    Window self

    // dati
    IDocumentoEsterno documentoDto
    List<VerificatoreFirma.RisultatoVerifica> risultatiVerifica
    IFileDocumento fileAllegatoDto

    // stato
    boolean trasformaInPdf = true
    boolean forzabile = false
    boolean copiaConforme = false
    boolean visualizza = true
    boolean verifica = false
    boolean modificato = false

    boolean fileNonFirmato = false

    String descFile = ""

    static Window apriPopup(IDocumentoEsterno documento, IFileDocumento fileDocumento, boolean trasformaInPdf) {
        Window w = (Window) Executions.createComponents("/protocollo/documenti/commons/popupProtocolloFileFirmato.zul", null,
                [documento: documento, fileAllegato: fileDocumento, trasformaInPdf: trasformaInPdf])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w
              , @ExecutionArgParam("documento") IDocumentoEsterno doc
              , @ExecutionArgParam("fileAllegato") IFileDocumento fileAllegatoDto
              , @ExecutionArgParam("trasformaInPdf") boolean trasformaInPdf) {

        self = w
        documentoDto = doc
        this.fileAllegatoDto = fileAllegatoDto
        this.trasformaInPdf = trasformaInPdf
        if (documentoDto instanceof ProtocolloDTO) {
            copiaConforme = true
            if (documentoDto.esitoVerifica == Protocollo.ESITO_FALLITO) {
                this.forzabile = true
            } else if (documentoDto.esitoVerifica == Protocollo.ESITO_FORZATO) {
                this.forzabile = false
            }

            if (fileAllegatoDto.isPdf()) {
                visualizza = false
                forzabile = false
            }

            if (fileAllegatoDto.isFirmato()) {
                verifica = true
            }

            if (!documentoDto.isProtocollato()) {
                copiaConforme = false
            }
        }

        if (documentoDto instanceof AllegatoDTO) {

            copiaConforme = true
            if (fileAllegatoDto.isPdf()) {
                visualizza = false
                forzabile = false
            }
            if (fileAllegatoDto.isFirmato()) {
                verifica = true
            }

            if (fileAllegatoDto.esitoVerifica == Protocollo.ESITO_FALLITO) {
                this.forzabile = true
            } else if (fileAllegatoDto.esitoVerifica == Protocollo.ESITO_FORZATO) {
                this.forzabile = false
            }

            if (!documentoDto.domainObject.documentoPrincipale.protocollato) {
                copiaConforme = false
            }

            if(documentoDto.domainObject?.tipoAllegato?.acronimo == ImpostazioniProtocollo.ALLEGATO_COPIA_CONFORME.valore){
                copiaConforme = false
            }
        }

        if (this.fileAllegatoDto.firmato) {
            descFile = " Il file " + fileAllegatoDto.nome + " è firmato digitalmente."
        } else {
            descFile = " " + fileAllegatoDto.nome
        }
    }

    @Command
    void onChiudi() {
        if(modificato){
            Events.postEvent(Events.ON_CLOSE, self, documentoDto)
        }else{
            Events.postEvent(Events.ON_CLOSE, self, null)
        }
    }

    @Command
    void onP7m() {
        fileDownloader.downloadFile(documentoDto.domainObject, fileAllegatoDto.domainObject, trasformaInPdf, false)
    }

    @Command
    void onSbusta() {
        fileDownloader.downloadFile(documentoDto.domainObject, fileAllegatoDto.domainObject, trasformaInPdf, true)
    }

    @Command
    void onForza() {
        Documento documento = documentoDto.domainObject
        if (documento instanceof Protocollo) {
            documento.esitoVerifica = Protocollo.ESITO_FORZATO
            protocolloService.salva(documento, documentoDto, false)
            this.forzabile = false
            this.modificato = true
            BindUtils.postNotifyChange(null, null, this, "forzabile")
        }
        else {
            fileDocumentoService.forzaVerificaFirma(fileAllegatoDto.domainObject)
            this.forzabile = false
            this.modificato = true
            BindUtils.postNotifyChange(null, null, this, "forzabile")
        }
        BindUtils.postNotifyChange(null, null, this, "risultatiVerifica")
    }

    @Command
    void onVerifica() {

        boolean firmaValida = true
        risultatiVerifica = new VerificatoreFirma(gestoreFile.getFile(documentoDto.domainObject, fileAllegatoDto.domainObject)).verificaFirma()
        for (VerificatoreFirma.RisultatoVerifica risultatoVerifica : risultatiVerifica) {
            if (!risultatoVerifica.valida) {
                firmaValida = false
                break
            }
        }

        if (documentoDto instanceof ProtocolloDTO) {
            Protocollo documento = documentoDto.domainObject
            if (Protocollo.ESITO_FALLITO == documento.esitoVerifica) {
                documento.esitoVerifica = Protocollo.ESITO_FALLITO
                protocolloService.salva(documento, documentoDto, false)
                risultatiVerifica.empty
                this.forzabile = true
                this.modificato = true
                BindUtils.postNotifyChange(null, null, this, "forzabile")
            } else {
                if (firmaValida) {
                    if (Protocollo.ESITO_VERIFICATO != documento.esitoVerifica) {
                        if (!documento.dataVerifica) {
                            documento.dataVerifica = new Date()
                        }
                        if (documento.esitoVerifica == null || documento.esitoVerifica == "") {
                            documento.esitoVerifica = Protocollo.ESITO_VERIFICATO
                            protocolloService.salva(documento, documentoDto, false)
                            this.modificato = true
                        }
                    }
                } else {
                    if (!documento.dataVerifica) {
                        documento.dataVerifica = new Date()
                    }
                    if (documento.esitoVerifica == null || documento.esitoVerifica == "") {
                        documento.esitoVerifica = Protocollo.ESITO_FALLITO
                        protocolloService.salva(documento, documentoDto, false)
                        forzabile = true
                        this.modificato = true
                        BindUtils.postNotifyChange(null, null, this, "forzabile")
                    }
                }
            }
        }
        else {
            FileDocumento fileDocumentoAllegato
            fileDocumentoAllegato=fileAllegatoDto.domainObject
            fileDocumentoService.aggiornaVerificaFirma(fileDocumentoAllegato)

            this.modificato = true

            if (fileDocumentoAllegato.esitoVerifica == FileDocumento.ESITO_FALLITO) {
                forzabile = true
            }
            else {
                forzabile = false
            }
        }
        if(!risultatiVerifica) {
            fileNonFirmato = true
            BindUtils.postNotifyChange(null, null, this, "fileNonFirmato")
        }
        BindUtils.postNotifyChange(null, null, this, "risultatiVerifica")
    }

    @Command
    void onCopiaConforme() {
        stampaUnicaService.downloadCopiaConforme(documentoDto.domainObject, fileAllegatoDto.domainObject, true, true)
    }
}