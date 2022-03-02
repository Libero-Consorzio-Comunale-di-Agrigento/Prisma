package it.finmatica.protocollo.dizionari;

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO;
import it.finmatica.dto.DtoUtils;
import it.finmatica.gestionedocumenti.commons.EnteDTO;
import it.finmatica.protocollo.dizionari.OggettoRicorrente;
import java.util.Date;

public class OggettoRicorrenteDTO implements it.finmatica.dto.DTO<OggettoRicorrente> {
    private static final long serialVersionUID = 1L;

    Long id;
    Long version;

    String codice;
    String oggetto;

    boolean valido;
    EnteDTO ente
    Date lastUpdated
    Date dateCreated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd

    public OggettoRicorrente getDomainObject () {
        return OggettoRicorrente.get(this.id)
    }

    public OggettoRicorrente copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
