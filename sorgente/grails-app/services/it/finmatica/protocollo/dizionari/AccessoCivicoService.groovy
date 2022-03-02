package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivico
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivicoDTO
import it.finmatica.protocollo.documenti.viste.Riferimento
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.hibernate.criterion.CriteriaSpecification
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class AccessoCivicoService {

    @Autowired
    ProtocolloService protocolloService
    @Autowired
    private GestioneDocumentiSpringSecurityService springSecurityService

    ProtocolloAccessoCivicoDTO salvaRispostaAccesso(ProtocolloAccessoCivicoDTO protocolloAccessoCivicoDTO) {

        // solo modifica
        ProtocolloAccessoCivico pac = ProtocolloAccessoCivico.get(protocolloAccessoCivicoDTO.id)
        if (!pac) {
            return null
        }
        pac.presenzaControinteressati = protocolloAccessoCivicoDTO.presenzaControinteressati
        pac.tipoEsitoAccesso = protocolloAccessoCivicoDTO.tipoEsitoAccesso?.domainObject
        pac.dataProvvedimento = protocolloAccessoCivicoDTO.dataProvvedimento
        pac.motivoRifiuto = protocolloAccessoCivicoDTO.motivoRifiuto
        pac.ufficioCompetenteRiesame = protocolloAccessoCivicoDTO.ufficioCompetenteRiesame?.domainObject
        pac.attivaPubblicazione = protocolloAccessoCivicoDTO.attivaPubblicazione
        pac.protocolloRisposta = protocolloAccessoCivicoDTO.protocolloRisposta?.domainObject

        pac.save()
        return pac.toDTO()
    }

    ProtocolloAccessoCivicoDTO salvaDomandaAccesso(ProtocolloAccessoCivicoDTO protocolloAccessoCivicoDTO) {
        ProtocolloAccessoCivico pac = ProtocolloAccessoCivico.get(protocolloAccessoCivicoDTO.id)
        if (!pac) {
            pac = new ProtocolloAccessoCivico()
        }

        pac.tipoAccessoCivico = protocolloAccessoCivicoDTO.tipoAccessoCivico?.domainObject
        pac.dataPresentazione = protocolloAccessoCivicoDTO.dataPresentazione
        pac.tipoRichiedenteAccesso = protocolloAccessoCivicoDTO.tipoRichiedenteAccesso?.domainObject
        pac.oggetto = protocolloAccessoCivicoDTO.oggetto
        pac.ufficioCompetente = protocolloAccessoCivicoDTO.ufficioCompetente?.domainObject
        pac.attivaPubblicaDomanda = protocolloAccessoCivicoDTO.attivaPubblicaDomanda
        pac.protocolloDomanda = protocolloAccessoCivicoDTO.protocolloDomanda?.domainObject

        pac.save()
        return pac.toDTO()
    }

    TipoAccessoCivicoDTO salva(TipoAccessoCivicoDTO tipoAccessoCivicoDto) {
        TipoAccessoCivico tipoAccessoCivico = TipoAccessoCivico.get(tipoAccessoCivicoDto.id)

        if (TipoAccessoCivico.findByCodice(tipoAccessoCivicoDto.codice) && tipoAccessoCivico == null) {
            throw new ProtocolloRuntimeException("il codice " + tipoAccessoCivicoDto.codice + " è già stato censito")
        }

        if (tipoAccessoCivico == null) {
            tipoAccessoCivico = new TipoAccessoCivico()
        }

        tipoAccessoCivico.codice = tipoAccessoCivicoDto.codice.toUpperCase()
        tipoAccessoCivico.descrizione = tipoAccessoCivicoDto.descrizione
        tipoAccessoCivico.commento = tipoAccessoCivicoDto.commento
        tipoAccessoCivico.valido = tipoAccessoCivicoDto.valido

        tipoAccessoCivico = tipoAccessoCivico.save()

        return tipoAccessoCivico.toDTO()
    }

    void elimina(TipoAccessoCivicoDTO tipoAccessoCivicoDto) {
        TipoAccessoCivico tipoAccessoCivico = TipoAccessoCivico.get(tipoAccessoCivicoDto.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (tipoAccessoCivico.version != tipoAccessoCivicoDto.version) {
            throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        tipoAccessoCivico.delete(failOnError: true)
    }

    TipoEsitoAccessoDTO salva(TipoEsitoAccessoDTO tipoEsitoAccessoDto) {
        TipoEsitoAccesso tipoEsitoAccesso = TipoEsitoAccesso.get(tipoEsitoAccessoDto.id)

        if (TipoEsitoAccesso.findByCodice(tipoEsitoAccessoDto.codice) && tipoEsitoAccesso == null) {
            throw new ProtocolloRuntimeException("il codice " + tipoEsitoAccessoDto.codice + " è già stato censito")
        }

        if (tipoEsitoAccesso == null) {
            tipoEsitoAccesso = new TipoEsitoAccesso()
        }

        tipoEsitoAccesso.codice = tipoEsitoAccessoDto.codice.toUpperCase()
        tipoEsitoAccesso.descrizione = tipoEsitoAccessoDto.descrizione
        tipoEsitoAccesso.commento = tipoEsitoAccessoDto.commento
        tipoEsitoAccesso.tipo = tipoEsitoAccessoDto.tipo
        tipoEsitoAccesso.valido = tipoEsitoAccessoDto.valido

        tipoEsitoAccesso = tipoEsitoAccesso.save()

        return tipoEsitoAccesso.toDTO()
    }

    void elimina(TipoEsitoAccessoDTO tipoEsitoAccessoDto) {
        TipoEsitoAccesso tipoEsitoAccesso = TipoEsitoAccesso.get(tipoEsitoAccessoDto.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (tipoEsitoAccesso.version != tipoEsitoAccessoDto.version) {
            throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        tipoEsitoAccesso.delete(failOnError: true)
    }

    TipoRichiedenteAccessoDTO salva(TipoRichiedenteAccessoDTO tipoRichiedenteAccessoDto) {
        TipoRichiedenteAccesso tipoRichiedenteAccesso = TipoRichiedenteAccesso.get(tipoRichiedenteAccessoDto.id)

        if (TipoRichiedenteAccesso.findByCodice(tipoRichiedenteAccessoDto.codice) && tipoRichiedenteAccesso == null) {
            throw new ProtocolloRuntimeException("il codice " + tipoRichiedenteAccessoDto.codice + " è già stato censito")
        }

        if (tipoRichiedenteAccesso == null) {
            tipoRichiedenteAccesso = new TipoRichiedenteAccesso()
        }

        tipoRichiedenteAccesso.codice = tipoRichiedenteAccessoDto.codice.toUpperCase()
        tipoRichiedenteAccesso.descrizione = tipoRichiedenteAccessoDto.descrizione
        tipoRichiedenteAccesso.commento = tipoRichiedenteAccessoDto.commento
        tipoRichiedenteAccesso.valido = tipoRichiedenteAccessoDto.valido

        tipoRichiedenteAccesso = tipoRichiedenteAccesso.save()

        return tipoRichiedenteAccesso.toDTO()
    }

    void elimina(TipoRichiedenteAccessoDTO tipoRichiedenteAccessoDto) {
        TipoRichiedenteAccesso tipoRichiedenteAccesso = TipoRichiedenteAccesso.get(tipoRichiedenteAccessoDto.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (tipoRichiedenteAccesso.version != tipoRichiedenteAccessoDto.version) {
            throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        tipoRichiedenteAccesso.delete(failOnError: true)
    }

    TipoRichiedenteAccessoDTO duplica(TipoRichiedenteAccessoDTO tipoRichiedenteAccessoDTO) {
        tipoRichiedenteAccessoDTO.version = 0
        tipoRichiedenteAccessoDTO.codice += " (duplica)"
        TipoRichiedenteAccesso duplica = salva(tipoRichiedenteAccessoDTO, null).domainObject
        return duplica.toDTO()
    }

    TipoAccessoCivicoDTO duplica(TipoAccessoCivicoDTO tipoAccessoCivicoDTO) {
        tipoAccessoCivicoDTO.version = 0
        tipoAccessoCivicoDTO.codice += " (duplica)"
        TipoAccessoCivico duplica = salva(tipoAccessoCivicoDTO, null).domainObject
        return duplica.toDTO()
    }

    TipoEsitoAccessoDTO duplica(TipoEsitoAccessoDTO tipoEsitoAccessoDTO) {
        tipoEsitoAccessoDTO.version = 0
        tipoEsitoAccessoDTO.codice += " (duplica)"
        TipoEsitoAccesso duplica = salva(tipoEsitoAccessoDTO, null).domainObject
        return duplica.toDTO()
    }

    boolean isSchemaProtocolloRisposta(Long id) {
        return SchemaProtocollo.createCriteria().count {
            createAlias("schemaProtocolloRisposta", "schemaRisposta", CriteriaSpecification.LEFT_JOIN)

            eq("schemaRisposta.id", id)
            eq("domandaAccesso", true)
            eq("valido", true)
        } > 0
    }

    boolean haRiferimentoAccesso(ProtocolloDTO protocollo) {
        return Riferimento.countByIdRiferimentoAndTipoRiferimento(protocollo.idDocumentoEsterno, TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO) > 0
    }

    ProtocolloAccessoCivicoDTO recuperaDatiAccesso(ProtocolloDTO protocollo) {
        ProtocolloAccessoCivicoDTO protocolloAccessoCivico = null
        if (protocollo.id > 0) {
            protocolloAccessoCivico = ProtocolloAccessoCivico.findByProtocolloRisposta(protocollo?.domainObject)?.toDTO(["tipoAccessoCivico",
                                                                                                                         "tipoRichiedenteAccesso",
                                                                                                                         "tipoEsitoAccesso",
                                                                                                                         "ufficioCompetenteRiesame",
                                                                                                                         "ufficioCompetente"])
        }
        return protocolloAccessoCivico;
    }

    ProtocolloAccessoCivicoDTO recuperaDatiAccessoDallaDomanda(ProtocolloDTO protocollo) {
        return ProtocolloAccessoCivico.findByProtocolloDomanda(protocollo?.domainObject)?.toDTO(["tipoAccessoCivico",
                                                                                                 "tipoRichiedenteAccesso",
                                                                                                 "tipoEsitoAccesso",
                                                                                                 "ufficioCompetenteRiesame",
                                                                                                 "protocolloRisposta",
                                                                                                 "ufficioCompetente"])
    }

    void eliminaAccessoCivico(Protocollo protocollo) {
        // sel il documento è una risposta di accesso civico viene eliminata l'associazione con la domanda
        ProtocolloAccessoCivico protocolloAccessoCivico = ProtocolloAccessoCivico.findByProtocolloRisposta(protocollo)
        if (protocolloAccessoCivico) {
            // elimino i due collegamenti (Precedente e Domanda di Accesso civico)
            protocolloService.eliminaDocumentoCollegato(protocolloAccessoCivico.protocolloRisposta, protocolloAccessoCivico.protocolloDomanda, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
            protocolloService.eliminaDocumentoCollegato(protocolloAccessoCivico.protocolloRisposta, protocolloAccessoCivico.protocolloDomanda, TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO)
            protocolloAccessoCivico.protocolloRisposta = null
            protocolloAccessoCivico.presenzaControinteressati = false
            protocolloAccessoCivico.tipoEsitoAccesso = null
            protocolloAccessoCivico.dataProvvedimento = null
            protocolloAccessoCivico.motivoRifiuto = null
            protocolloAccessoCivico.ufficioCompetenteRiesame = null
            protocolloAccessoCivico.attivaPubblicazione = false
            protocolloAccessoCivico.save()
        }
        // se il documento è una domanda viene eliminata la riga
        else {
            protocolloAccessoCivico = ProtocolloAccessoCivico.findByProtocolloDomanda(protocollo)
            if (protocolloAccessoCivico) {
                protocolloAccessoCivico.delete()
            }
        }
    }

    List<TipoEsitoAccessoDTO> listTipoEsitoAccessoValidi() {
        return TipoEsitoAccesso.findAllByValido(true, [sort: "descrizione", order: "asc"]).toDTO()
    }

    List<TipoAccessoCivicoDTO> listTipoAccessoValidi() {
        return TipoAccessoCivico.findAllByValido(true, [sort: "descrizione", order: "asc"]).toDTO()
    }

    List<TipoRichiedenteAccessoDTO> listTipoRichiedenteAccessoValidi() {
        return TipoRichiedenteAccesso.findAllByValido(true, [sort: "descrizione", order: "asc"]).toDTO()
    }

    PagedResultList ricercaUfficioCompetente(String filtro, int offset, int max) {
        if (filtro != null && !filtro.equals("") && filtro.length() < 2 && offset == 0) {
            return new PagedResultList([], 0)
        }
        return ricercaUfficioCompetente(new So4UnitaPubbDTO(codice: filtro, descrizione: filtro), offset, max)
    }

    PagedResultList ricercaUfficioCompetente(So4UnitaPubbDTO ufficioCompetenteDTO, int offset, int max) {
        return So4UnitaPubb.createCriteria().list(max: max, offset: offset) {
            eq("ottica.codice", springSecurityService.principal.ottica().codice)
            Date d = new Date()
            le("dal", d)
            or {
                ge("al", d)
                isNull("al")
            }
            or {
                if (ufficioCompetenteDTO?.codice?.length() > 0) {
                    ilike("codice", "%" + ufficioCompetenteDTO.codice + "%")
                }
                if (ufficioCompetenteDTO?.descrizione?.length() > 0) {
                    ilike("descrizione", "%" + ufficioCompetenteDTO.descrizione + "%")
                }
            }
            order("codice", "asc")
        }
    }
}