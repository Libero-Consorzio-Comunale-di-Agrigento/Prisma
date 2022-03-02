package it.finmatica.protocollo.corrispondenti

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils

class CorrispondenteMessaggioDTO implements it.finmatica.dto.DTO<CorrispondenteMessaggio> {
    private static final long serialVersionUID = 1L

    Long id
    Long version
    Date dateCreated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    Date lastUpdated
    boolean valido

    boolean conoscenza = false

    Date 	dataRicezioneAggiornamento
    Date 	dataRicezioneAnnullamento
    Date 	dataRicezioneConferma
    Date 	dataRicezioneEccezione

    boolean	registrataConsegna
    boolean	ricevutaEccezione
    boolean	ricevutoAggiornamento
    boolean	ricevutoAnnullamento
    boolean	registrazioneConsegnaAggiornamento
    boolean registrazioneConsegnaAnnullamento
    boolean registrazioneConsegnaConferma
    boolean	ricevutaMancataConsegna
    boolean	ricevutaMancataConsegnaAggiornamento
    boolean ricevutaMancataConsegnaAnnullamento
    boolean ricevutaMancataConsegnaConferma
    boolean	ricevutaConferma

    Date dataConsegnaConferma
    Date dataMancataConsegnaConferma
    Date dataConsegnaAggiornamento
    Date dataMancataConsegnaAggiornamento
    Date dataConsegnaAnnullamento
    Date dataMancataConsegnaAnnullamento
    Date dataConsegna
    Date dataMancataConsegna

    Date 	dataSpedizione
    String  denominazione
    String  email

    MessaggioDTO 	   messaggio
    CorrispondenteDTO corrispondente


    CorrispondenteMessaggio getDomainObject () {
        return CorrispondenteMessaggio.get(this.id)
    }

    CorrispondenteMessaggio copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue. 
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.


}
