package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenzaDTO
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service

class ModalitaInvioRicezioneService {

    @Autowired
    ProtocolloService protocolloService

    void elimina(ModalitaInvioRicezioneDTO modalitaInvioRicezioneDTO) {
        ModalitaInvioRicezione modalitaInvioRicezione = ModalitaInvioRicezione.get(modalitaInvioRicezioneDTO.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (modalitaInvioRicezione.version != modalitaInvioRicezione.version) {
            throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        modalitaInvioRicezione.delete(failOnError: true)
    }

    ModalitaInvioRicezioneDTO salva(ModalitaInvioRicezioneDTO modalitaInvioRicezioneDTO) {

        ModalitaInvioRicezione modalitaInvioRicezione = modalitaInvioRicezioneDTO.getDomainObject() ?: new ModalitaInvioRicezione()
        modalitaInvioRicezione.valido = modalitaInvioRicezioneDTO.valido
        modalitaInvioRicezione.codice = modalitaInvioRicezioneDTO.codice.toUpperCase()
        modalitaInvioRicezione.descrizione = modalitaInvioRicezioneDTO.descrizione

        modalitaInvioRicezione.costo = modalitaInvioRicezioneDTO.costo
        modalitaInvioRicezione.tipoSpedizione = modalitaInvioRicezioneDTO.tipoSpedizione?.domainObject
        modalitaInvioRicezione.validoDal = modalitaInvioRicezioneDTO.validoDal
        modalitaInvioRicezione.validoAl = modalitaInvioRicezioneDTO.validoAl

        modalitaInvioRicezione.save()

        return modalitaInvioRicezione.toDTO()
    }

    void elimina(TipoDocumentoCompetenzaDTO tipoDocumentoCompetenzaDto) {
        tipoDocumentoCompetenzaDto?.domainObject?.delete(failOnError: true)
    }

    void eliminaModalitaInvioRicezione(ModalitaInvioRicezioneDTO modalitaInvioRicezioneDTO) {
        ModalitaInvioRicezione modalitaInvioRicezione = modalitaInvioRicezioneDTO.getDomainObject()
        modalitaInvioRicezione.delete(failOnError: true, flush: true)
    }


    PagedResultList ricercaModalitaInvioRicezione(String filtro, int offset, int max) {
        return ricercaModalitaInvioRicezione(new ModalitaInvioRicezioneDTO(codice: filtro, descrizione: filtro), offset, max)
    }

    PagedResultList ricercaModalitaInvioRicezione(ModalitaInvioRicezioneDTO modalitaInvioRicezioneDTO, int offset, int max) {
        Date data = new Date()
        return ModalitaInvioRicezione.createCriteria().list(max: max, offset: offset) {
            eq("valido", true)
            le("validoDal", data.clearTime())
            or {
                isNull("validoAl")
                ge("validoAl", data.clearTime())
            }
            or {
                if (modalitaInvioRicezioneDTO.codice != null) {
                    ilike("codice", "%" + modalitaInvioRicezioneDTO.codice + "%")
                }
                if (modalitaInvioRicezioneDTO.descrizione != null) {
                    ilike("descrizione", "%" + modalitaInvioRicezioneDTO.descrizione + "%")
                }
            }
            order("codice", "asc")
        }
    }

}