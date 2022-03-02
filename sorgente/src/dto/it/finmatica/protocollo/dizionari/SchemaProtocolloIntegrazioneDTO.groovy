package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO

public class SchemaProtocolloIntegrazioneDTO implements it.finmatica.dto.DTO<SchemaProtocolloIntegrazione> {
    private static final long serialVersionUID = 1L;

    Long id;
    Long version;

    String applicativo;
    String tipoPratica;
    SchemaProtocolloDTO schemaProtocollo;

    boolean valido;
    EnteDTO ente
    Date lastUpdated
    Date dateCreated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd

    public SchemaProtocolloIntegrazione getDomainObject() {
        return SchemaProtocolloIntegrazione.get(this.id)
    }

    public SchemaProtocolloIntegrazione copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
