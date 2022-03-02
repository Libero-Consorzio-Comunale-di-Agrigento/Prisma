package it.finmatica.protocollo.hibernate

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import org.hibernate.envers.boot.internal.EnversService
import org.hibernate.envers.event.spi.EnversPostDeleteEventListenerImpl
import org.hibernate.event.spi.PostDeleteEvent

@Slf4j
@CompileStatic
class RevisioneStoricoPostDeleteEventListenerImpl extends EnversPostDeleteEventListenerImpl {

    private final RevisioneStoricoRegister revisioneStoricoRegister

    RevisioneStoricoPostDeleteEventListenerImpl(EnversService enversService, RevisioneStoricoRegister revisioneStoricoRegister) {
        super(enversService)
        this.revisioneStoricoRegister = revisioneStoricoRegister
    }

    @Override
    void onPostDelete(PostDeleteEvent event) {
        if (event.getEntity() instanceof FileDocumento) {
            FileDocumento fileDocumento = (FileDocumento) event.getEntity()
            log.debug("[${fileDocumento.id}][DELETE]: ${fileDocumento.codice} ${fileDocumento.nome}")
            revisioneStoricoRegister.aggiornaVersioneStorico(fileDocumento)
        }

        super.onPostDelete(event)
    }
}
