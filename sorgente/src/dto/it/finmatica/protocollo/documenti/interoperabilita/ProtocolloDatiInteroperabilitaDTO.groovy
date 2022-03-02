package it.finmatica.protocollo.documenti.interoperabilita

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO

class ProtocolloDatiInteroperabilitaDTO implements DTO<ProtocolloDatiInteroperabilita> {

    Long id
    Long version

    String codiceAmmPrimaRegistrazione
    String codiceAooPrimaRegistrazione
    Date dataPrimaRegistrazione
    String numeroPrimaRegistrazione
    String codiceRegistroPrimaRegistrazione
    String motivoInterventoOperatore
    boolean inviataConferma
    boolean richiestaConferma
    boolean ricevutaAccettazioneConferma
    String messaggioScarico

    Date dateCreated
    Ad4UtenteDTO utenteIns
    Date lastUpdated
    Ad4UtenteDTO utenteUpd

    @Override
    ProtocolloDatiInteroperabilita getDomainObject() {
        return ProtocolloDatiInteroperabilita.get(id)
    }

    ProtocolloDatiInteroperabilita copyToDomainObject() {
        return null
    }
}