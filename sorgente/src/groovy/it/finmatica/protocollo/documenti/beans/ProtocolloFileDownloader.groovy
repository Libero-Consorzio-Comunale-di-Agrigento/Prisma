package it.finmatica.protocollo.documenti.beans

import commons.PopupProtocolloFileFirmatoViewModel
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.beans.FileDownloader
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.apache.log4j.Logger
import org.zkoss.zul.Window

class ProtocolloFileDownloader extends FileDownloader {

    private static final Logger log = Logger.getLogger(ProtocolloFileDownloader.class)

    Window downloadFileAllegato(IDocumentoEsterno documento, IFileDocumento fileDocumento, boolean solalettura = true, boolean controllaRiservato = true) {
        if (documento.hasProperty("TIPO_OGGETTO") && documento.hasProperty("id")) {
            ad4Service.logAd4("Download file allegato documento: ${documento?.id}, file: ${fileDocumento?.id}", "Download file allegato con id=${documento?.id}")
        }

        //TODO: gestire qui la riservatezza degli allegati

        // se il file allegato è firmato, apro la popup di download/verifica. A monte viene verificato che il protocollo deve essere numerato.
        if (fileDocumento.isFirmato() || (fileDocumento.isPdf() && ImpostazioniProtocollo.COPIA_CONFORME_PDF.abilitato) ) {
            return PopupProtocolloFileFirmatoViewModel.apriPopup(documento, fileDocumento.toDTO(), solalettura)
        } else {
            downloadFile(documento, fileDocumento, solalettura)
        }
        return null
    }
}
