package it.finmatica.protocollo.documenti.viste

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO

class BottoneNotificaDTO implements it.finmatica.dto.DTO<BottoneNotifica> {


    Long id
    Long version
    Date dateCreated
    EnteDTO ente
    Date lastUpdated

    String  tipo
    String  stato
    String  azione
    String  label
    String  tooltip
    String  icona
    String  iconaShort
    String  modello
    String  tipoAzione
    int     azioneMultipla
    String  modelloAzione
    String  assegnazione
    String  tipoSmistamento
    Integer sequenza
    String  urlAzione

    Date validoDal  // da valorizzare alla creazione del record
    Date validoAl   // deve essere valorizzato con la data di sistema quando valido = false
    // quando valido = true deve essere null

    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    BottoneNotifica getDomainObject () {
        return BottoneNotifica.get(this.id)
    }

    BottoneNotifica copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
