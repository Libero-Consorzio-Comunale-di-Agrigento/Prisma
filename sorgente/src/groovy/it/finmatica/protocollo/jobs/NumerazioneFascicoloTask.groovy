package it.finmatica.protocollo.jobs

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.protocollo.fascicolo.NumerazioneService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.scheduling.annotation.Async
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@CompileStatic
@Service
class NumerazioneFascicoloTask {
    @Value("\${finmatica.protocollo.utenteBatch}")
    String utenteBatch

    @Autowired
    NumerazioneService numerazioneService

    @Async
    @Transactional
    void numerazioneFasciolo() {
        Utils.eseguiAutenticazione(utenteBatch)
        numerazioneService.numerazione()
    }
}
