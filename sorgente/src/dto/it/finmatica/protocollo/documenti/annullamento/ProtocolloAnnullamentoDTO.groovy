package it.finmatica.protocollo.documenti.annullamento

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class ProtocolloAnnullamentoDTO implements it.finmatica.dto.DTO<ProtocolloAnnullamento> {

    Long id
    Long version
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido
    Date dateCreated
    Date lastUpdated

    ProtocolloDTO     protocollo
    String            motivo
    String            motivoRifiuto
    StatoAnnullamento stato
    So4UnitaPubbDTO   unita
    Ad4UtenteDTO      utenteAccettazioneRifiuto

    Date dataAccettazioneRifiuto

    ProtocolloAnnullamento getDomainObject () {
        return ProtocolloAnnullamento.get(this.id)
    }

    ProtocolloAnnullamento copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.
}