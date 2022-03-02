package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.protocollo.dizionari.ListaDistribuzione

class ListaDistribuzioneDTO implements it.finmatica.dto.DTO<ListaDistribuzione> {
    private static final long serialVersionUID = 1L

    String codice
    String descrizione
    Long   idDocumentoEsterno

    Long id
    Long version
    Date dateCreated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    Date lastUpdated
    boolean valido

    EnteDTO ente

    Set<ComponenteListaDistribuzioneDTO> componenti

    ListaDistribuzione getDomainObject () {
        return ListaDistribuzione.get(this.id)
    }

    ListaDistribuzione copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }

    /* * * codice personalizzato * * */ // attenzione: non modificare questa riga se si vuole mantenere il codice personalizzato che segue.
    // qui è possibile inserire codice personalizzato che non verrà eliminato dalla rigenerazione dei DTO.

    void addToCorrispondenti (ComponenteListaDistribuzioneDTO componente) {
        if (this.componenti == null)
            this.componenti = new HashSet<ComponenteListaDistribuzioneDTO>()
        this.componenti.add (componente)
        componente.listaDistribuzione = this
    }

    void removeFromCorrispondenti (ComponenteListaDistribuzioneDTO componente) {
        if (this.componenti == null)
            this.componenti = new HashSet<ComponenteListaDistribuzioneDTO>()
        this.componenti.remove (componente)
        componenti.listaDistribuzione = null
    }
}
