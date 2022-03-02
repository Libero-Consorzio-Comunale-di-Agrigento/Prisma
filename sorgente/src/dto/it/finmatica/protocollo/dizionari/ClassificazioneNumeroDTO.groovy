package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.commons.EnteDTO

class ClassificazioneNumeroDTO implements DTO<ClassificazioneNumero> {

    Long id
    Integer anno
    ClassificazioneDTO classificazione
    Integer ultimoNumeroFascicolo

    Long version
    Date dateCreated
    EnteDTO ente
    Date lastUpdated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    
    
    ClassificazioneNumero getDomainObject() {
        return ClassificazioneNumero.get(id)
    }

    ClassificazioneNumero copyToDomainObject() {
        return null
    }

    /* * * codice personalizzato * * */  // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}