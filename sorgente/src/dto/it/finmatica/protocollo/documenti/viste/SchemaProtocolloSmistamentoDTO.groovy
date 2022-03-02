package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class SchemaProtocolloSmistamentoDTO implements it.finmatica.dto.DTO<SchemaProtocolloSmistamento> {

    Long id
    Long version
    Date dateCreated
    EnteDTO ente
    Date lastUpdated

    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    SchemaProtocolloDTO schemaProtocollo

   // String          ufficioSmistamento
    String          tipoSmistamento
    So4UnitaPubbDTO unitaSo4Smistamento
    Integer         sequenza
    boolean         fascicoloObbligatorio
    String          email

    SchemaProtocolloSmistamento getDomainObject () {
        return SchemaProtocolloSmistamento.get(this.id)
    }

    SchemaProtocolloSmistamento copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
