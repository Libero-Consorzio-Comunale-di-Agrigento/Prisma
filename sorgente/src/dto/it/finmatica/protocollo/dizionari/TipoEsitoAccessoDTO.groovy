package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO

class TipoEsitoAccessoDTO implements it.finmatica.dto.DTO<TipoEsitoAccesso> {

	private static final long serialVersionUID = 1L

	String 	codice
	String 	descrizione
	String  commento
	String 	tipo

	Long id
	Long version
	Date dateCreated
	EnteDTO ente
	Date lastUpdated
	Ad4UtenteDTO utenteIns
	Ad4UtenteDTO utenteUpd
	boolean valido


    TipoEsitoAccesso getDomainObject () {
		return TipoEsitoAccesso.get(this.id)
	}

    TipoEsitoAccesso copyToDomainObject () {
		return DtoUtils.copyToDomainObject(this)
	}

	/* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
	// qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.
}
