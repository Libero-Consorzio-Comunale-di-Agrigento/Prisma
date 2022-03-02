package it.finmatica.protocollo.documenti.accessocivico

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DtoUtils
import it.finmatica.protocollo.dizionari.TipoAccessoCivicoDTO
import it.finmatica.protocollo.dizionari.TipoEsitoAccessoDTO
import it.finmatica.protocollo.dizionari.TipoRichiedenteAccessoDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivico
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO

class ProtocolloAccessoCivicoDTO implements it.finmatica.dto.DTO<ProtocolloAccessoCivico> {

    static final OGGETTO_DEFAULT_OGGETTO = 'OGGETTO'
    static final OGGETTO_DEFAULT_TIPO_ACCESSO = 'TIPO_ACCESSO'


    ProtocolloDTO protocolloRisposta     // id del protocollo corrispondente alla risposta alla domanda di accesso
    ProtocolloDTO protocolloDomanda      // id della domanda di accesso
    TipoAccessoCivicoDTO tipoAccessoCivico
    TipoRichiedenteAccessoDTO tipoRichiedenteAccesso
    TipoEsitoAccessoDTO tipoEsitoAccesso


    Long id
    Long version
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd
    boolean valido
    Date dateCreated
    Date lastUpdated

    Date                    dataPresentazione
    Date                    dataProvvedimento

    String                  oggetto                // oggetto della richiesta
    String                  motivoRifiuto

    So4UnitaPubbDTO            ufficioCompetente
    So4UnitaPubbDTO            ufficioCompetenteRiesame

    boolean                 presenzaControinteressati = false
    boolean                 attivaPubblicaDomanda     = false
    boolean                 attivaPubblicazione       = false


    ProtocolloAccessoCivico getDomainObject () {
        return ProtocolloAccessoCivico.get(this.id)
    }

    ProtocolloAccessoCivico copyToDomainObject () {
        return DtoUtils.copyToDomainObject(this)
    }
}