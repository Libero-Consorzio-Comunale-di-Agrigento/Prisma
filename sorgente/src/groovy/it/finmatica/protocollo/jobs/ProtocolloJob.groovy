package it.finmatica.protocollo.jobs

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.notifiche.Allegato
import it.finmatica.gestionedocumenti.notifiche.Mail
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.documenti.StampaUnicaService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.apache.commons.io.FileUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.scheduling.annotation.Async
import org.springframework.scheduling.annotation.Scheduled

@Slf4j
class ProtocolloJob {

    private @Autowired
    ProtocolloJobExecutor protocolloJobExecutor
    private @Autowired
    SuccessHandler successHandler
    private @Autowired
    SpringSecurityService springSecurityService
    private @Autowired
    StampaUnicaService stampaUnicaService

    @Value("\${finmatica.protocollo.utenteBatch}")
    String utenteBatch

    @Value("\${finmatica.protocollo.emailProblemi}")
    String emailProblemi

    @Scheduled(cron = "\${it.finmatica.protocollo.jobs.ProtocolloJob.job.cron:0 0 4 * * *}")
    void job() {
        log.info("Eseguo il Job di....")

        try {

            // eseguo l'autenticazione con l'utente batch
            String[] codiciEnti = protocolloJobExecutor.eseguiAutenticazione(utenteBatch)

            for (String codiceEnte : codiciEnti) {
                boolean lockOttenuto = false
                log.info("Eseguo il Job per l'ente con codice: ${codiceEnte}")

                try {
                    // come prima cosa ottengo il lock per evitare che due tomcat eseguano questo job in contemporanea:
                    lockOttenuto = protocolloJobExecutor.lock(codiceEnte)
                    // se non ho ottenuto il lock, significa che c'è un altro job che sta eseguendo, quindi esco.

                    if (lockOttenuto == false) {
                        log.warn("C'è già un token per il job notturno e l'ente: ${codiceEnte}. Non eseguo il job.")
                        return
                    }
                    log.info("Eseguo il Job per l'ente con codice: ${codiceEnte}")
                    executeJob(codiceEnte)
                } finally {
                    // rilascio il lock
                    if (lockOttenuto) {
                        protocolloJobExecutor.unlock(codiceEnte)
                    }
                }
            }
        } finally {
            successHandler.clearMessages()
        }

    }

    private void executeJob(String codiceEnte) {

        File errorLogFile = File.createTempFile("error", "log")

        try {

            log.info('Iniziato il Job Verifica firma')

            protocolloJobExecutor.verificaFirma(codiceEnte)

            log.info('Finito il Job Verifica firma')

            // elimino le transazioni di firma vecchie
            log.info("Elimino le transazioni di firma vecchie.")
            try {
                protocolloJobExecutor.eliminaTransazioniFirmaVecchie(codiceEnte)
            } catch (Throwable t) {
                log.error("Errore nell'eliminare le transazioni di firma vecchie per l'ente con codice: ${codiceEnte}", t)
                errorLogFile << "Errore nell'eliminare le transazioni di firma vecchie per l'ente con codice: ${codiceEnte} \n${t.message}:${t.getStackTrace().toString().replace(')', ')\n')}";
            }


            log.info('Iniziato il Job Avviso scadenza')

            protocolloJobExecutor.inviaAvviso(codiceEnte)

            log.info('Finito il Job Avviso scadenza')

        } finally {
            inviaMailErrori(errorLogFile)
            FileUtils.deleteQuietly(errorLogFile)
        }
    }

    private void inviaMailErrori(File errorLogFile) {
        if (errorLogFile.size() == 0) {
            return
        }

        Mail.invia(Impostazioni.TAG_MAIL_AUTO.valore,
                ImpostazioniProtocollo.MITTENTE_INVIO_MAIL.valore,
                [emailProblemi],
                "PROTOCOLLO: Si sono verificati dei problemi nell'esecuzione del job notturno.",
                "Errore nel job notturno a: ${springSecurityService.principal.amm().descrizione}",
                [new Allegato("errori.log", new ByteArrayInputStream(errorLogFile.getBytes()))])
    }

    @Async
    void creaStampaUnicaProtocollo(long idProtocollo, String utente, long idEnte, Closure postCreazioneStampa) {
        stampaUnicaService.creaStampaUnicaProtocollo(idProtocollo, utente, idEnte, postCreazioneStampa)
    }
}
