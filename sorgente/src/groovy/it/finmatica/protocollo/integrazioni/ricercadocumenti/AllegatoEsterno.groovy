package it.finmatica.protocollo.integrazioni.ricercadocumenti

import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionetesti.TipoFile

class AllegatoEsterno implements IFileDocumento, DTO<AllegatoEsterno> {

    // dati relativi al documento principale che contiene il file allegato
    String tipoDocumento
    Long idDocumentoPrincipale
    Long idDocumentoEsterno
    Long idFileEsterno
    Long idFileAllegato
    String nome
    String formatoFile
    String contentType

    String estremi
    String oggetto

    IDocumentoEsterno getDocumento() {
        return new DocumentoEsterno(idDocumentoEsterno: idDocumentoEsterno)
    }

    @Override
    String getNome() {
        return nome
    }

    @Override
    String getContentType() {
        return contentType
    }

    @Override
    long getDimensione() {
        return 0
    }

    @Override
    String getTesto() {
        return null
    }

    @Override
    boolean isPdf() {
        return nome.toLowerCase().endsWith(TipoFile.PDF.estensione.toLowerCase())
    }

    @Override
    boolean isP7m() {
        return nome.toLowerCase().endsWith(TipoFile.P7M.estensione.toLowerCase())
    }

    @Override
    boolean isFirmato() {
        return isP7m()
    }

    @Override
    boolean isModificabile() {
        return isP7m() || isPdf()
    }

    transient String getNomeFileSbustato() {
        return this.nome.replaceAll(/(\.[pP]7[mM])+$/, "")
    }

    transient String getNomePdf() {
        return this.nome.replaceAll(/\..+$/, ".pdf")
    }

    @Override
    AllegatoEsterno getDomainObject() {
        return this
    }

    AllegatoEsterno copyToDomainObject() {
        return this
    }

    AllegatoEsterno toDTO() {
        return this
    }

    @Override
    Date getDataVerifica() {
        return null
    }

    @Override
    String getEsitoVerifica() {
        return null
    }
}
