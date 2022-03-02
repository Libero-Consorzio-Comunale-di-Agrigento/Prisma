package it.finmatica.protocollo.documenti.titolario


import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO

class DocumentoTitolarioDTO implements it.finmatica.dto.DTO<DocumentoTitolario> {
    private static final long serialVersionUID = 1L

    Long id
    ClassificazioneDTO classificazione
    FascicoloDTO fascicolo
    DocumentoDTO       documento

    Date dateCreated
    Date lastUpdated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido
    Long version

    DocumentoTitolario getDomainObject () {
        return DocumentoTitolario.get(this.id)
    }

    DocumentoTitolario copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    String getNome() {
        String nome = classificazione.getNome()
           if (fascicolo) {
               nome = nome + " " + fascicolo.annoNumero + " " + fascicolo.oggetto
           }
        return nome
    }
}
