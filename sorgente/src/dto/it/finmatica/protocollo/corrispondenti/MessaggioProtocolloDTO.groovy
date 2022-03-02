package it.finmatica.protocollo.corrispondenti

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.protocollo.documenti.ProtocolloDTO

class MessaggioProtocolloDTO implements it.finmatica.dto.DTO<MessaggioProtocollo> {
	private static final long serialVersionUID = 1L


	MessaggioDTO  messaggio
	Long idDocumentoEsterno

	Long id
	Long version

	Date dateCreated
	Date lastUpdated
	Ad4UtenteDTO utenteIns
	Ad4UtenteDTO utenteUpd
	boolean valido

	MessaggioProtocollo getDomainObject () {
		return MessaggioProtocollo.get(this.id)
	}

	MessaggioProtocollo copyToDomainObject () {
		return DtoUtils.copyToDomainObject(this)
	}

	/* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
	// qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
