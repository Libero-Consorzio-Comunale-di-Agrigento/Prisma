package it.finmatica.protocollo.integrazioni.ricercadocumenti

import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno

/**
 * Created by DScandurra on 05/12/2017.
 */
class DocumentoEsterno implements IDocumentoEsterno, DTO<DocumentoEsterno> {

    Long idDocumentoEsterno

    long idDocumento
    String tipoDocumento

    String estremi
    String oggetto

    @Override
    DocumentoEsterno getDomainObject() {
        return this
    }

    DocumentoEsterno copyToDomainObject() {
        return this
    }

    DocumentoEsterno toDTO() {
        return this
    }
}
