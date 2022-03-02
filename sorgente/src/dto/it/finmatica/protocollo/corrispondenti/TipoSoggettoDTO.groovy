package it.finmatica.protocollo.corrispondenti;

import it.finmatica.dto.DtoUtils

public class TipoSoggettoDTO implements it.finmatica.dto.DTO<TipoSoggetto> {
    private static final long serialVersionUID = 1L;

    Long id;
    String descrizione;
    Long sequenza;


    public TipoSoggetto getDomainObject () {
        return TipoSoggetto.get(this.id)
    }

    public TipoSoggetto copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

	/* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
	// qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
