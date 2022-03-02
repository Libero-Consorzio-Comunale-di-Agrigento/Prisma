package it.finmatica.protocollo.documenti.scarto

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.protocollo.dizionari.StatoScartoDTO

class DocumentoDatiScartoDTO implements DTO<DocumentoDatiScarto> {

    Long id
    Long version
    EnteDTO ente
    StatoScartoDTO stato
    Date dataStato
    String nullaOsta
    Date dataNullaOsta

    Date dateCreated
    Ad4UtenteDTO utenteIns
    Date lastUpdated
    Ad4UtenteDTO utenteUpd

    @Override
    DocumentoDatiScarto getDomainObject() {
        return DocumentoDatiScarto.get(id)
    }

    DocumentoDatiScarto copyToDomainObject() {
        return null
    }
}