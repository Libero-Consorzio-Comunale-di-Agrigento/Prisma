package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenzaDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class TipoSpedizioneService {

    @Autowired
    ProtocolloService protocolloService

    void elimina(TipoSpedizioneDTO tipoSpedizioneDTO) {
        TipoSpedizione tipoSpedizione = TipoSpedizione.get(tipoSpedizioneDTO.id)
        /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
        if (tipoSpedizione.version != tipoSpedizione.version) {
            throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        tipoSpedizione.delete(failOnError: true)
    }

    TipoSpedizioneDTO salva(TipoSpedizioneDTO tipoSpedizioneDTO) {

        TipoSpedizione tipoSpedizione = tipoSpedizioneDTO.getDomainObject() ?: new TipoSpedizione()
        tipoSpedizione.valido = tipoSpedizioneDTO.valido
        tipoSpedizione.codice = tipoSpedizioneDTO.codice.toUpperCase()
        tipoSpedizione.descrizione = tipoSpedizioneDTO.descrizione

        tipoSpedizione.barcodeItalia = tipoSpedizioneDTO.barcodeItalia
        tipoSpedizione.barcodeEstero = tipoSpedizioneDTO.barcodeEstero
        tipoSpedizione.stampa = tipoSpedizioneDTO.stampa

        tipoSpedizione.save()

        return tipoSpedizione.toDTO()
    }

    void elimina(TipoDocumentoCompetenzaDTO tipoDocumentoCompetenzaDto) {
        tipoDocumentoCompetenzaDto?.domainObject?.delete(failOnError: true)
    }

    void eliminaTipoSpedizione(TipoSpedizioneDTO tipoSpedizioneDTO) {
        TipoSpedizione tipoSpedizione = tipoSpedizioneDTO.getDomainObject()
        tipoSpedizione.delete(failOnError: true, flush: true)
    }
}