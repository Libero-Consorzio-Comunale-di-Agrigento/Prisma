package it.finmatica.protocollo.corrispondenti;

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO;
import it.finmatica.dto.DtoUtils

public class IndirizzoDTO implements it.finmatica.dto.DTO<Indirizzo> {
    private static final long serialVersionUID = 1L;

    Long id;
    Long version;
    String cap;
    String codice;
    String comune;
    CorrispondenteDTO corrispondente;
    Date dateCreated;
    String denominazione;
    String email;
    String fax;
    String indirizzo;
    Date lastUpdated;
    String provinciaSigla;
    String tipoIndirizzo;
    Ad4UtenteDTO utenteIns;
    Ad4UtenteDTO utenteUpd;
    boolean valido;


    public Indirizzo getDomainObject () {
        return Indirizzo.get(this.id)
    }

    public Indirizzo copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue. 
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.


}
