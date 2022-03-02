package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO

class SchemaProtocolloCategoriaDTO implements it.finmatica.dto.DTO<SchemaProtocolloCategoria> {


    Long id
    Long version
    Date dateCreated
    Date lastUpdated

    String categoria

    SchemaProtocolloDTO schemaProtocollo
    TipoProtocolloDTO tipoProtocollo

    boolean modificabile

    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    SchemaProtocolloCategoria getDomainObject() {
        return SchemaProtocolloCategoria.get(this.id)
    }

    SchemaProtocolloCategoria copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }
}
