package it.finmatica.protocollo.corrispondenti

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO

class MezzoTrasmissivoDTO implements it.finmatica.dto.DTO<MezzoTrasmissivo> {
    private static final long serialVersionUID = 1L

    Long id
    Long version

    Date dateCreated
    Date lastUpdated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    String codice
    String descrizione

    EnteDTO ente

    MezzoTrasmissivo getDomainObject () {
        return MezzoTrasmissivo.get(this.id)
    }

    MezzoTrasmissivo copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

	/* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
	// qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
