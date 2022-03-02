package it.finmatica.protocollo.jobs

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.RegistroGiornalieroService
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.scheduling.TaskScheduler
import org.springframework.stereotype.Service

@Service
@CompileStatic
@Slf4j
class RegistroGiornalieroTaskAnnullamento {
    private static final int           DEFAULT_RITARDO = 2 * 60
    private static final int             MAX_RETRY = 5
    @Autowired          TaskScheduler taskScheduler

    @Autowired RegistroGiornalieroService registroGiornalieroService
    @Autowired NotificheService notificheService
    @Autowired SpringSecurityService springSecurityService

    /**
     * annulla il protocollo corrispondente al registro giornaliero
     * @param idRegistroGiornaliero il registro che individua il protocollo da annullare
     * @param ritardo il ritardo in secondi per eseguire l'operazione (default 2 minuti)
     */
    void annullaRegistroGiornaliero (Long idRegistroGiornaliero, long ritardo = DEFAULT_RITARDO) {
        Calendar cal = Calendar.getInstance()
        cal.add(Calendar.SECOND,ritardo.intValue())
        Date start = cal.time
        Ad4Utente utente = springSecurityService.currentUser
        taskScheduler.schedule(new InternalTask(registroGiornalieroService,taskScheduler,notificheService,0,idRegistroGiornaliero,utente),start)
    }

    private static class InternalTask implements Runnable {
        private RegistroGiornalieroService registroGiornalieroService
        Long idRegistroGiornaliero
        TaskScheduler taskScheduler
        int iteration
        NotificheService notificheService
        Ad4Utente utente

        InternalTask(RegistroGiornalieroService registroGiornalieroService, TaskScheduler taskScheduler, NotificheService notificheService, int iteration, Long idRegistroGiornaliero,Ad4Utente utente) {
            this.registroGiornalieroService = registroGiornalieroService
            this.idRegistroGiornaliero = idRegistroGiornaliero
            this.taskScheduler = taskScheduler
            this.iteration = iteration
            this.notificheService = notificheService
            this.utente = utente
        }

        @Override
        void run() {
            log.debug("Avvio tentativo di annullamento n. {} per registro giornaliero {}",iteration,idRegistroGiornaliero)
            Protocollo protocollo = registroGiornalieroService.findByIdRegistroGiornaliero(idRegistroGiornaliero)
            // la logica qua è che posso annullare il protocollo solo dopo che è stata inviata la notifica; provo un massimo di MAX_RETRY, dopo di che annullo comunque
            boolean notificaPresente = notificheService.isNotificaPresente(RegoleCalcoloNotificheProtocolloRepository.ERRORE_REGISTRO_GIORNALIERO, protocollo, utente)
            if(!notificaPresente) {
                if(iteration == MAX_RETRY) {
                    log.info("Tentativo di notifica n. {}, forzo la notifica",iteration)
                    registroGiornalieroService.annullaRegistro(idRegistroGiornaliero)
                } else {
                    Calendar cal = Calendar.getInstance()
                    cal.add(Calendar.SECOND, DEFAULT_RITARDO.intValue())
                    Date start = cal.time
                    log.debug("La notifica non è ancora stata mandata, rimando l'esecuzione a {}", start)
                    taskScheduler.schedule(nuovaIterazione(), start)
                }
            }
        }

        private InternalTask nuovaIterazione() {
            return new InternalTask(registroGiornalieroService,taskScheduler,notificheService,iteration +1,idRegistroGiornaliero,utente)
        }
    }

}
