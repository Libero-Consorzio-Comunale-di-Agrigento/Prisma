package it.finmatica.protocollo.documenti.telematici

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO
import it.finmatica.protocollo.documenti.ProtocolloDTO

class ProtocolloRiferimentoTelematicoDTO implements DTO<ProtocolloRiferimentoTelematico> {

    Long id

    ProtocolloDTO protocollo
    String uri
    Long dimensione
    String impronta
    String improntaAlgoritmo
    String improntaCodifica
    String tipo
    String correttezzaImpronta
    boolean scaricato = true
    Long version
    Date dateCreated
    Date lastUpdated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido


    @Override
    ProtocolloRiferimentoTelematico getDomainObject() {
        ProtocolloRiferimentoTelematico.get(id)
    }
}
