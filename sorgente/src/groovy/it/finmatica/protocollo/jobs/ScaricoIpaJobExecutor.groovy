package it.finmatica.protocollo.jobs

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.TokenIntegrazione
import it.finmatica.gestionedocumenti.commons.TokenIntegrazioneService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.integrazioni.firma.GestioneDocumentiFirmaService
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.protocollo.documenti.ProtocolloEsternoRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Transactional
class ScaricoIpaJobExecutor {

    private static String JOB_ID = "JOB_SCARICO_IPA"
    private static String JOB_TYPE = "SCARICO_IPA_JOB"

    private @Autowired TokenIntegrazioneService tokenIntegrazioneService
    private @Autowired SpringSecurityService springSecurityService
    private @Autowired ProtocolloGdmService protocolloGdmService
    private @Autowired NotificheService notificheService
    private @Autowired DocumentoService documentoService
    private @Autowired GestioneDocumentiFirmaService gestioneDocumentiFirmaService
    private @Autowired ProtocolloService protocolloService
    private @Autowired ProtocolloEsternoRepository protocolloEsternoRepository

    String[] eseguiAutenticazione(String utente) {
        return Utils.eseguiAutenticazione(utente)
    }

    boolean lock(String codiceAmmistrazione) {
        // imposto il filtro dell'ente per la sessione hibernate e seleziono l'amministrazione di login
        Utils.setAmministrazioneOttica(codiceAmmistrazione)

        // ottengo il lock sulla tabella TOKEN_INTEGRAZIONI in modo tale di essere sicuro che con più tomcat ne parta uno solo:
        TokenIntegrazione token = tokenIntegrazioneService.beginTokenTransaction(JOB_ID, JOB_TYPE)
        if (!token.statoInCorso) {
            log.info("C'è già un job che sta girando per l'ente con codice: ${codiceAmmistrazione}, esco e non faccio nulla.")
            return false
        }

        return true
    }

    void unlock(String amministrazione) {
        Utils.setAmministrazioneOttica(amministrazione)
        tokenIntegrazioneService.endTokenTransaction(JOB_ID, JOB_TYPE)
    }

    void rimuoviVecchioToken() {
        tokenIntegrazioneService.rimuoviVecchioToken(JOB_ID, JOB_TYPE)
    }

    void rimuoviToken() {
        tokenIntegrazioneService.rimuoviToken(JOB_ID, JOB_TYPE)
    }
}