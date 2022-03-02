package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO

class TipoSpedizioneDTO implements DTO<TipoSpedizione> {

    private static final long serialVersionUID = 1L

    Long id
    Long version

    String codice
    String descrizione

    boolean barcodeItalia
    boolean barcodeEstero
    boolean stampa

    boolean valido
    EnteDTO ente
    Date lastUpdated
    Date dateCreated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd

    TipoSpedizione getDomainObject() {
        return TipoSpedizione.get(this.id)
    }

    TipoSpedizione copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }


}
