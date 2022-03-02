package it.finmatica.protocollo.documenti.tipologie;

import it.finmatica.dto.DtoUtils;
import it.finmatica.gestioneiter.configuratore.dizionari.WkfGruppoStepDTO;
import it.finmatica.protocollo.documenti.tipologie.ParametroTipologia;

public class ParametroTipologiaDTO implements it.finmatica.dto.DTO<ParametroTipologia> {
    private static final long serialVersionUID = 1L;

    Long id;
    Long version;
    String codice;
    WkfGruppoStepDTO gruppoStep;
    TipoProtocolloDTO tipoProtocollo;
    String valore;


    public ParametroTipologia getDomainObject () {
        return ParametroTipologia.get(this.id)
    }

    public ParametroTipologia copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

	/* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
	// qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
