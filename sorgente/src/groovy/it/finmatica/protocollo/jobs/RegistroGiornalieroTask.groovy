package it.finmatica.protocollo.jobs

import groovy.transform.CompileStatic
import it.finmatica.jobscheduler.JobConfig
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.scheduling.annotation.Async
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@CompileStatic
@Service
class RegistroGiornalieroTask {

    @Autowired
    RegistroGiornalieroJob registroGiornalieroJob

    @Async
    @Transactional
    void esegui(JobConfig config) {
        registroGiornalieroJob.esegui(config)
    }
}
