package it.finmatica.protocollo.documenti.emergenza

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO

class ProtocolloDatiEmergenzaDTO implements DTO<ProtocolloDatiEmergenza> {

    Long id
    Long version
    Date dataInizioEmergenza
    Date dataFineEmergenza
    String motivoEmergenza
    String provvedimentoEmergenza

    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    Date lastUpdated
    Date dateCreated

    @Override
    ProtocolloDatiEmergenza getDomainObject() {
        return ProtocolloDatiEmergenza.get(id)
    }

    ProtocolloDatiEmergenza copyToDomainObject() {
        return null
    }
}
