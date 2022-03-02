package it.finmatica.protocollo.smistamenti

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class SmistamentoDTO implements it.finmatica.dto.DTO<Smistamento> {
    private static final long serialVersionUID = 1L

    Long id
    Long version
    Date dataAssegnazione
    Date dataEsecuzione
    Date dataPresaInCarico
    Date dataSmistamento
    Date dateCreated
    DocumentoDTO documento
    Date lastUpdated
    String note
    String noteUtente
    String statoSmistamento
    String tipoSmistamento
    So4UnitaPubbDTO unitaSmistamento
    So4UnitaPubbDTO unitaTrasmissione
    Ad4UtenteDTO utenteAssegnante
    Ad4UtenteDTO utenteAssegnatario
    Ad4UtenteDTO utenteEsecuzione
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utentePresaInCarico
    Ad4UtenteDTO utenteTrasmissione
    Ad4UtenteDTO utenteUpd
    boolean valido
    Long idDocumentoEsterno

    String motivoRifiuto
    Ad4UtenteDTO utenteRifiuto
    Date dataRifiuto

    Smistamento getDomainObject() {
        return Smistamento.get(this.id)
    }

    Smistamento copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */
    // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.
    // Se è Creato posso cancellarlo;
    // se è DA_RICEVERE devo testare che l'utente corrente sia uguale all'utente di trasmissione se ho solo competente di lettura;
    // se ho quelle di modifica basta che sia da RICEVERE
    boolean isCancellabile(boolean isSequenza, Map competenze, Ad4Utente currentUser) {

        if (isSequenza && tipoSmistamento == Smistamento.COMPETENZA) {
            return false
        } else {
            if (statoSmistamento == Smistamento.CREATO) {
                return true
            } else if (statoSmistamento == Smistamento.DA_RICEVERE) {
                if (competenze.modifica) {
                    return true
                } else if (competenze.lettura && utenteTrasmissione?.id == currentUser.id) {
                    return true
                }
                return false
            }
            return false
        }
    }

    boolean isProtocollo() {
        return documento.class == ProtocolloDTO.class
    }

    boolean isMessaggioRicevuto() {
        return documento.class == MessaggioRicevutoDTO.class
    }

    boolean isFascicolo() {
        return documento.class == FascicoloDTO.class
    }

}
