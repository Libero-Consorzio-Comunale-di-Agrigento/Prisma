package it.finmatica.protocollo.documenti.viste

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class SchemaProtocolloUnitaDTOService {

    SchemaProtocolloUnitaDTO salva(SchemaProtocolloUnitaDTO schemaProtocolloUnitaDto) {
        SchemaProtocolloUnita schemaProtocolloUnita = new SchemaProtocolloUnita()
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (schemaProtocolloUnita.version != schemaProtocolloUnitaDto.version) {
            throw new ConcurrentModificationException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        schemaProtocolloUnita.utenteAd4 = schemaProtocolloUnitaDto?.utenteAd4?.getDomainObject()
        schemaProtocolloUnita.ruoloAd4 = schemaProtocolloUnitaDto?.ruoloAd4?.getDomainObject()
        schemaProtocolloUnita.unita = schemaProtocolloUnitaDto?.unita?.getDomainObject()
        schemaProtocolloUnita.schemaProtocollo = schemaProtocolloUnitaDto.schemaProtocollo.getDomainObject()
        schemaProtocolloUnita = schemaProtocolloUnita.save()

        return (SchemaProtocolloUnitaDTO) schemaProtocolloUnita.toDTO()
    }

    void elimina(SchemaProtocolloUnitaDTO schemaProtocolloUnitaDTO) {
        SchemaProtocolloUnita schemaProtocolloUnita = SchemaProtocolloUnita.get(schemaProtocolloUnitaDTO.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (schemaProtocolloUnita.version != schemaProtocolloUnitaDTO.version) {
            throw new ConcurrentModificationException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        schemaProtocolloUnita.delete(failOnError: true)
    }
}
