package it.finmatica.protocollo.documenti.viste

import it.finmatica.dto.DTO

class RiferimentoDTO implements DTO<Riferimento> {

    Long idDocumento
    Long idRiferimento
    String tipoRiferimento
    String descrizioneTipoRiferimento
    String url
    String urlRiferimento
    String oggetto
    String oggettoRiferimento
    Date dataAggiornamento

    @Override
    Riferimento getDomainObject() {
        return Riferimento.findByIdDocumentoAndIdRiferimentoAndTipoRiferimento(idDocumento, idRiferimento, tipoRiferimento)
    }

    Riferimento copyToDomainObject() {
        return null
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

}
