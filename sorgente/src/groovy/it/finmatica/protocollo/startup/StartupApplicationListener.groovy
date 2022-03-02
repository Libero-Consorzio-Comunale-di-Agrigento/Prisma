package it.finmatica.protocollo.startup

import com.jcabi.manifests.Manifests
import com.jcabi.manifests.ServletMfs
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.protocollo.admin.AggiornamentoService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationListener
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.context.WebApplicationContext

import javax.servlet.ServletContext

@Slf4j
@Transactional
class StartupApplicationListener implements
        ApplicationListener<ApplicationReadyEvent> {

    private final AggiornamentoService aggiornamentoService

    @Autowired
    ServletContext servletContext

    StartupApplicationListener(AggiornamentoService aggiornamentoService) {
        this.aggiornamentoService = aggiornamentoService
    }

    @Override
    void onApplicationEvent(ApplicationReadyEvent event) {
        Utils.eseguiAutenticazione("RPI")
        aggiornamentoService.aggiornaDizionari()
        aggiornamentoService.trascodificaStorico()

        ApplicationContext appContext = servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE) as ApplicationContext
        Manifests manifests = appContext.getBean(Manifests)
        log.info('Inzializzo il manifest del WAR')
        manifests.append(new ServletMfs(servletContext))
    }
}
