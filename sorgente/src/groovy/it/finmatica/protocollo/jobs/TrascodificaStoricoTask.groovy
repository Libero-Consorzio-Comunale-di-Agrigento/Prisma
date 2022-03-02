package it.finmatica.protocollo.jobs

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.protocollo.documenti.ProtocolloStoricoTrascoService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.scheduling.annotation.Async
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@CompileStatic
@Service
class TrascodificaStoricoTask {
    @Value("\${finmatica.protocollo.utenteBatch}")
    String utenteBatch

    @Autowired
    ProtocolloStoricoTrascoService protocolloStoricoTrascoService

    @Async
    @Transactional
    void trascodificaStorico() {
        Utils.eseguiAutenticazione(utenteBatch)
        protocolloStoricoTrascoService.trascodificaStorico()
    }
}
