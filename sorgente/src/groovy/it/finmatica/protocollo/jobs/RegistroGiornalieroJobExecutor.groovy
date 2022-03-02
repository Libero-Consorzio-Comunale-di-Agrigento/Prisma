package it.finmatica.protocollo.jobs

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.commons.TokenIntegrazione
import it.finmatica.gestionedocumenti.commons.TokenIntegrazioneService
import it.finmatica.gestionedocumenti.commons.Utils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Transactional
class RegistroGiornalieroJobExecutor {
    private static String JOB_ID = "JOB_REGISTRO_GIORNALIERO"
    private static String JOB_TYPE = "REGISTRO_GIORNALIERO_JOB"

    private @Autowired TokenIntegrazioneService tokenIntegrazioneService

    void eseguiAutenticazione(String utente,Long idEnte) {
        Utils.eseguiAutenticazione(utente,idEnte)
    }

    boolean lock(String codiceEnteAoo) {
        // ottengo il lock sulla tabella TOKEN_INTEGRAZIONI in modo tale di essere sicuro che con più tomcat ne parta uno solo:
        TokenIntegrazione token = tokenIntegrazioneService.beginTokenTransaction(JOB_ID, JOB_TYPE)
        if (!token.statoInCorso) {
            log.info("C'è già un job che sta girando per l'ente con codice: ${codiceEnteAoo}, esco e non faccio nulla.")
            return false
        }

        return true
    }

    void unlock(String amministrazione) {
        tokenIntegrazioneService.endTokenTransaction(JOB_ID, "REGISTRO_GIORNALIERO_JOB")
    }

    void rimuoviVecchioToken() {
        tokenIntegrazioneService.rimuoviVecchioToken(JOB_ID, JOB_TYPE)
    }

    void rimuoviToken() {
        tokenIntegrazioneService.rimuoviToken(JOB_ID, JOB_TYPE)
    }



}