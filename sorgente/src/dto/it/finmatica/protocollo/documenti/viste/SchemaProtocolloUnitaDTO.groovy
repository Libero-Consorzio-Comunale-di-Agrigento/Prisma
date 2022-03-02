package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.autenticazione.Ad4RuoloDTO
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.gestionetesti.reporter.GestioneTestiModelloDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class SchemaProtocolloUnitaDTO implements it.finmatica.dto.DTO<SchemaProtocolloUnita> {

    Long id
    Long version
    Date dateCreated
    EnteDTO ente
    Date lastUpdated

    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    SchemaProtocolloDTO schemaProtocollo

    So4UnitaPubbDTO unita

    Ad4RuoloDTO ruoloAd4
    Ad4UtenteDTO utenteAd4

    Long idDocumentoEsterno


    SchemaProtocolloUnita getDomainObject () {
        return SchemaProtocolloUnita.get(this.id)
    }

    SchemaProtocolloUnita copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
