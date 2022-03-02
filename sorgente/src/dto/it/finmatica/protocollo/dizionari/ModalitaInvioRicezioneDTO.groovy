package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO

class ModalitaInvioRicezioneDTO implements DTO<ModalitaInvioRicezione> {

    private static final long serialVersionUID = 1L

    Long id
    Long version

    String codice
    String descrizione
    BigDecimal costo
    TipoSpedizioneDTO tipoSpedizione
    Date validoDal
    Date validoAl

    boolean valido
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    Date dateCreated
    Date lastUpdated
    EnteDTO ente

    ModalitaInvioRicezione getDomainObject() {
        return ModalitaInvioRicezione.get(this.id)
    }

    ModalitaInvioRicezione copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }
}
