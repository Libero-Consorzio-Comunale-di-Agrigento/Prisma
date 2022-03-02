package it.finmatica.protocollo.documenti.viste
import org.springframework.stereotype.Service

import org.springframework.transaction.annotation.Transactional

/**
 * Questo servizio serve solo per poter eseguire i test più facilmente a causa del fatto che Riferimenti è una vista che va su
 * gdm ma è acceduta da agspr. A causa di questo, nei test i dati non sono "visibili" quindi ho bisogno di uno "strato in più" per fare
 * il Mock e ritornare i valori che mi interessano.
 */
@Transactional(readOnly = true)
@Service
class RiferimentoService {

    List<Riferimento> getDocumentiCollegati(long idDocumentoPrincipaleGdm, String tipoRiferimento) {
        return Riferimento.findAllByIdDocumentoAndTipoRiferimento(idDocumentoPrincipaleGdm, tipoRiferimento)
    }

    Riferimento getDocumentoCollegato(long idDocumentoPrincipaleGdm, String tipoRiferimento) {
        List<Riferimento> riferimenti = getDocumentiCollegati(idDocumentoPrincipaleGdm, tipoRiferimento)
        if (riferimenti.size() > 0) {
            return riferimenti[0]
        }

        return null
    }

    Riferimento getRiferimentoPrincipale(long idDocumentoMail) {
        return getDocumentoCollegato(idDocumentoMail, Riferimento.TIPO_RIFERIMENTO_PRINCIPALE)
    }

    Riferimento getRiferimentoStream(long idDocumentoMail) {
        return getDocumentoCollegato(idDocumentoMail, Riferimento.TIPO_RIFERIMENTO_STREAM)
    }

    Riferimento getRiferimentoMail(long idDocumentoProtocollo) {
        return getDocumentoCollegato(idDocumentoProtocollo, Riferimento.TIPO_RIFERIMENTO_MAIL)
    }

    Riferimento getRiferimentoAlboCollegato(long idDocumentoProtocollo) {
        return getDocumentoCollegato(idDocumentoProtocollo, Riferimento.TIPO_RIFERIMENTO_ALBO_COLLEGATO)
    }

    Long getIdProtocolloDaMemo(Long idDocumentoMemo) {
        Riferimento mail = Riferimento.findByTipoRiferimentoAndIdRiferimento(Riferimento.TIPO_RIFERIMENTO_MAIL, idDocumentoMemo)

        // il memo può essere collegato direttamente a un protocollo:
        if (mail != null) {
            return mail.idDocumento
        }

        // oppure può essere collegato ad un documento principale che a sua volta punta al protocollo:
        Riferimento principale = Riferimento.findByTipoRiferimentoAndIdDocumento(Riferimento.TIPO_RIFERIMENTO_PRINCIPALE, idDocumentoMemo)
        if (principale == null) {
            return null
        }

        // dal documento principale, posso risalire all'id del protocollo
        Long idDocumentoProtocollo = Riferimento.findByTipoRiferimentoAndIdRiferimento(Riferimento.TIPO_RIFERIMENTO_MAIL, principale.idRiferimento)?.idDocumento
        if (idDocumentoProtocollo != null) {
            return idDocumentoProtocollo
        }

        return null
    }

    Long getIdStreamDaProtocollo(long idDocumentoProtocollo) {
        Long idMemo = getIdMemoDaProtocollo(idDocumentoProtocollo)
        if (idMemo == null) {
            return null
        }

        Riferimento stream = Riferimento.findByTipoRiferimentoAndIdDocumento(Riferimento.TIPO_RIFERIMENTO_STREAM, idMemo)
        if (stream == null) {
            return null
        }

        return stream.idRiferimento
    }

    Long getIdMemoDaProtocollo(long idDocumentoProtocollo) {
        Riferimento mail = Riferimento.findByTipoRiferimentoAndIdDocumento(Riferimento.TIPO_RIFERIMENTO_MAIL, idDocumentoProtocollo)
        if (mail == null) {
            return null
        }

        // mail può essere:
        // - o il "memo_protocollo" originale
        // - oppure il 'documento principale' intermedio
        // posso scoprire se è il documento principale, se trovo un riferimento con principale:

        Riferimento principale = Riferimento.findByTipoRiferimentoAndIdRiferimento(Riferimento.TIPO_RIFERIMENTO_PRINCIPALE, mail.idRiferimento)
        // se non ho un documento principale, allora posso ritornare l'id del memo protocollo trovato prima:
        if (principale == null) {
            return mail.idRiferimento
        }

        return principale.idDocumento
    }
}
