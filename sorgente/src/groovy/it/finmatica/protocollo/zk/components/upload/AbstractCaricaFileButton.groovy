package it.finmatica.protocollo.zk.components.upload

import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.AllegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.utils.FileInputStreamDeleteOnClose
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zul.Button
import org.zkoss.zul.Messagebox

/**
 * Racchiude tutti i controlli per il caricamento dei file.
 */
abstract class AbstractCaricaFileButton extends Button {

    @WireVariable
    private DocumentoService documentoService
    @WireVariable
    AllegatoRepository allegatoRepository
    @WireVariable
    AllegatoProtocolloService allegatoProtocolloService

    private IDocumentoEsterno documento
    private AllegatoDTO allegato

    IDocumentoEsterno getDocumento() {
        return documento
    }

    void setDocumento(IDocumentoEsterno documento) {
        this.documento = documento
    }

    AllegatoDTO getAllegato() {
        return allegato
    }

    void setAllegato(AllegatoDTO allegato) {
        this.allegato = allegato
    }

    protected void uploadFile(File file, String fileName, String contentType) {
        uploadFiles([new UploadedFile(file, fileName, contentType)])
    }

    protected void uploadFiles(List<UploadedFile> uploadedFiles) {

        if (uploadedFiles.size() > 1 && !isDuplicateUploadedFiles(uploadedFiles)) {
            return
        }

        for (UploadedFile u : uploadedFiles) {
            if (!isFileCorretto(u)) {
                return
            }
        }

        long dimensioneTotale = (long) (uploadedFiles*.size).sum()
        int dimensioneMaxAllegati = Impostazioni.MAXDIM_ATTACH.valoreInt
        boolean controllaDimensione = dimensioneMaxAllegati > 0

        if (documento instanceof ProtocolloDTO) {
            Protocollo protocollo = this.documento.domainObject
            if(protocollo){
                // calcolo la dimensione totale dei file allegati e verifico se devo caricare il file o no.
                long dimensioneTotaleAllegati = dimensioneTotale + documentoService.calcolaDimensioneAllegati(protocollo, false)
                if (controllaDimensione && (dimensioneTotaleAllegati > dimensioneMaxAllegati)) {
                    boolean bloccaSeDimensioneMassima = Impostazioni.MAXDIM_ATTACH_ALT.abilitato
                    if (bloccaSeDimensioneMassima) {
                        for (UploadedFile u : uploadedFiles) {
                            FileUtils.deleteQuietly(u.file)
                        }
                        ClientsUtils.showError("La dimensione dei file allegati e il documento principale superano la dimensione massima consentita: ${dimensioneMaxAllegati} bytes.")
                    } else {
                        Messagebox.show("Attenzione: La dimensione dei file allegati e il documento principale superano la dimensione massima consentita: ${dimensioneMaxAllegati} bytes. Continuare?", "Attenzione!",
                                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                            if (e.name == Messagebox.ON_OK) {
                                fireCaricaFileEvent(uploadedFiles)
                            }
                        }
                    }
                } else {
                    fireCaricaFileEvent(uploadedFiles)
                }
            }
            else {
                fireCaricaFileEvent(uploadedFiles)
            }
        } else {
            fireCaricaFileEvent(uploadedFiles)
        }
    }

    private void fireCaricaFileEvent(List<UploadedFile> uploadedFiles) {
        for (int i = 0; i < uploadedFiles.size(); i++) {
            UploadedFile u = uploadedFiles[i]
            Events.postEvent(new CaricaFileEvent(this, new FileInputStreamDeleteOnClose(u.file), u.filename, u.contentType, i == (uploadedFiles.size() - 1)))
        }
    }

    private boolean isDuplicateUploadedFiles(List<UploadedFile> uploadedFiles) {
        List<String> elencoNomiFiles = []
        if (!allegato.statoFirma?.daNonFirmare) {
            for (UploadedFile u : uploadedFiles) {
                if (u.filename.contains(".p7m")) {
                    elencoNomiFiles << u.filename
                } else {
                    elencoNomiFiles << u.filename + ".p7m"
                }
            }
        }
        if (elencoNomiFiles.size() > elencoNomiFiles.unique().size()) {
            ClientsUtils.showError("Non è possibile caricare due volte un file con lo stesso nome.")
            return false
        }
        return true
    }

    private boolean isFileCorretto(UploadedFile uploadedFile) {

        String nomefile = uploadedFile.filename
        if (nomefile.contains("'") || nomefile.contains("@")) {
            ClientsUtils.showError("Impossibile caricare il file: il nome dell'allegato contiene caratteri non consentiti ( ' @ ).")
            return false
        }

        if (uploadedFile.file.length() == 0) {
            ClientsUtils.showError("Impossibile caricare un file di dimensione nulla.")
            return false
        }

         //il controllo non va fatto se in ARRIVO per PEC e PROT MANUALE
         boolean  controllaFormatoAllegato = false
         if(documento && documento.movimento != Protocollo.MOVIMENTO_ARRIVO ){
                controllaFormatoAllegato = true
         } else if (! (documento.tipoProtocollo.categoriaProtocollo.isPec() || documento.tipoProtocollo.categoriaProtocollo.isProtocollo())){
                controllaFormatoAllegato = true
         }
         if(controllaFormatoAllegato){
            if (Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valori.size() > 0 && Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valore != "") {
                if (!Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valori.collect{ it.toLowerCase() }.contains(FilenameUtils.getExtension(nomefile).toLowerCase())) {
                        ClientsUtils.showError("Impossibile caricare il file: l'allegato è di un tipo non consentito, le estensioni consentite sono: ${Impostazioni.ALLEGATO_FORMATI_POSSIBILI.valori.join(", ")}.")
                        return false
                }
            }
         }



        // controllo sulla univocità dei files inseriti da maschera allegato
        if (documento instanceof ProtocolloDTO) {
            Protocollo protocollo = (Protocollo) documento.domainObject
            if (protocollo) {

                AllegatoProtocolloService.UNIVOCITA_NOMI_FILE univocitaNomiFile
                univocitaNomiFile = allegatoProtocolloService.isNomeFileUnivoco(protocollo, allegato, nomefile)
                if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_PRINCIPALE)) {
                    ClientsUtils.showError("Impossibile caricare il file: il file ${nomefile} ha lo stesso nome dei file principale del documento.")
                    return
                }
                if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_ALLEGATO)) {
                    ClientsUtils.showError("Non è possibile caricare due volte un file con lo stesso nome: ${nomefile}.")
                    return
                }
            }
        }

        //Verifica se il nome del file contiene caratteri non consentiti
        Set<String> caratteriNonConsentiti = allegatoProtocolloService.verificaCaratteriSpeciali(nomefile)
        if(caratteriNonConsentiti.size() > 0) {
            ClientsUtils.showError("Attenzione sono prensenti caratteri non consentiti "+ caratteriNonConsentiti.each {it -> it + " "} + " nel nome del file. Rinominare il file prima di caricarlo.")
            return false
        }

        return true
    }
}
