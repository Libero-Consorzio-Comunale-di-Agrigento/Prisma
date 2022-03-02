package it.finmatica.protocollo.security

import groovy.sql.Sql
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiUserDetails
import org.springframework.context.ApplicationListener
import org.springframework.security.authentication.event.InteractiveAuthenticationSuccessEvent
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource

/**
 * Dopo il login effettuato con successo, invoca il AG_UTILITIES.inizializza_ag_priv_utente_tmp per riempire la tabella dei privilegi di protocollo per l'utente che ha fatto login.
 *
 * Created by esasdelli on 23/05/2017.
 */
@Slf4j
@CompileStatic
class InizializzaAgPrivUtenteTmpDopoLogin implements ApplicationListener<InteractiveAuthenticationSuccessEvent> {

    private final DataSource dataSource_gdm

    InizializzaAgPrivUtenteTmpDopoLogin(DataSource dataSource_gdm) {
        this.dataSource_gdm = dataSource_gdm
    }

    @Transactional
    @Override
    void onApplicationEvent(InteractiveAuthenticationSuccessEvent interactiveAuthenticationSuccessEvent) {
        if (interactiveAuthenticationSuccessEvent.authentication.isAuthenticated()) {
            GestioneDocumentiUserDetails user = (GestioneDocumentiUserDetails) interactiveAuthenticationSuccessEvent.authentication.principal

            if (log.debugEnabled) {
                log.debug("Login effettuato con user: ${user.id}, eseguo AG_UTILITIES.inizializza_ag_priv_utente_tmp")
            }

            new Sql(dataSource_gdm).call("{ call AG_UTILITIES.inizializza_ag_priv_utente_tmp (${user.id}) }")
        }
    }
}
