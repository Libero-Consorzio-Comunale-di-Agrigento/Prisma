package it.finmatica.protocollo.corrispondenti

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils

import javax.persistence.Column

class MessaggioDTO implements it.finmatica.dto.DTO<Messaggio> {
    private static final long serialVersionUID = 1L

    Long id
    Long version

    String dataSpedizioneMemo
    Date dataRicezione
    String statoMemo
    String mittente
    String oggetto
    String corpo
    String destinatari
    String destinatariConoscenza
    String destinatariNascosti
    boolean inPartenza
    boolean spedito
    boolean registrataAccettazione
    boolean registrataNonAccettazione
    String linkDocumento
    Long idDocumentoEsterno

    String mittenteAmministrazione
    String mittenteAOO
    String mittenteCodiceUO

    String note

    Date dateCreated
    Date lastUpdated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido

    Set<CorrispondenteMessaggioDTO> corrispondenti

    Messaggio getDomainObject() {
        return Messaggio.get(this.id)
    }

    Messaggio copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.
}
