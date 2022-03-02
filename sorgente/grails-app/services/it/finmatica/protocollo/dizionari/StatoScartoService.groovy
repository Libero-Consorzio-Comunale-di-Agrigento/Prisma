package it.finmatica.protocollo.dizionari

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class StatoScartoService {

    StatoScartoDTO salva(StatoScartoDTO statoScartoDTO) {

        StatoScarto statoScarto = statoScartoDTO.getDomainObject() ?: new StatoScarto()
        statoScarto.descrizione = statoScartoDTO.descrizione
        statoScarto.save()

        return statoScarto.toDTO()
    }

}