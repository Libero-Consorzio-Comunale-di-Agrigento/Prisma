package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class ClassificazioneUnitaDTO implements DTO<ClassificazioneUnita> {

    Long id
    ClassificazioneDTO classificazione
    EnteDTO ente
    So4UnitaPubbDTO unita

    Long version
    Date dateCreated
    Date lastUpdated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    
    
    ClassificazioneUnita getDomainObject() {
        return ClassificazioneUnita.get(id)
    }

    ClassificazioneUnita copyToDomainObject() {
        return null
    }

    /* * * codice personalizzato * * */  // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}