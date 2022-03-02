package it.finmatica.protocollo.jobs

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.jobscheduler.JobConfig
import it.finmatica.jobscheduler.JobSchedulerRepository
import it.finmatica.jobscheduler.ScheduledJob
import it.finmatica.protocollo.scaricoipa.CriteriScaricoIpaDTO
import it.finmatica.protocollo.scaricoipa.CriteriScaricoIpaService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value

@CompileStatic
@Slf4j
class ScaricoIpaJob implements ScheduledJob {

    @Autowired
    private CriteriScaricoIpaService criteriScaricoIpaService
    @Autowired
    private JobSchedulerRepository jobSchedulerRepository
    @Autowired
    private ScaricoIpaJobExecutor scaricoIpaJobExecutor
    @Autowired
    private SuccessHandler successHandler

    @Value("\${finmatica.protocollo.utenteBatch}")
    String utenteBatch

    String getTitolo() {
        return 'Scarico Ipa Job'
    }

    String getBeanName() {
        return 'scaricoIpaJob'
    }

    @Override
    void run(long idJobLog) {
        log.info("Eseguo il Job ScaricoIPA")

        try {
            // eseguo l'autenticazione con l'utente batch
            String[] codiciEnti = scaricoIpaJobExecutor.eseguiAutenticazione(utenteBatch)

            for (String codiceEnte : codiciEnti) {
                boolean lockOttenuto = false
                log.info("Eseguo il Job ScaricoIPA per l'ente con codice: ${codiceEnte}")

                try {
                    // come prima cosa ottengo il lock per evitare che due tomcat eseguano questo job in contemporanea:
                    lockOttenuto = scaricoIpaJobExecutor.lock(codiceEnte)

                    // se non ho ottenuto il lock, significa che c'è un altro job che sta eseguendo, quindi esco.
                    if (lockOttenuto == false) {
                        log.warn("C'è già un token per il job notturno e l'ente: ${codiceEnte}. Non eseguo il job ScaricoIPA.")
                        return
                    }

                    log.info("run job ..")
                    JobConfig config = criteriScaricoIpaService.getConfigForLogId(idJobLog)
                    CriteriScaricoIpaDTO criteriScaricoIpaDTO = criteriScaricoIpaService.getCriterio(config.parametri.toLong()) as CriteriScaricoIpaDTO
                    criteriScaricoIpaService.elaboraCriterio(criteriScaricoIpaDTO)
                } finally {
                    // rilascio il lock
                    if (lockOttenuto) {
                        scaricoIpaJobExecutor.unlock(codiceEnte)
                    }
                }
            }
        } finally {
            successHandler.clearMessages()
        }
    }
}
