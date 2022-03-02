package it.finmatica.protocollo.hibernate

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import org.hibernate.envers.boot.internal.EnversService
import org.hibernate.envers.event.spi.EnversPostUpdateEventListenerImpl
import org.hibernate.event.spi.PostUpdateEvent

/**
 * Ad ogni modifica su un file, aggiorna la colonna "revisione_storico" sul rispettivo log envers in modo tale che
 * lo storico envers "punti" direttamente al relativo record su GDM.
 */
@Slf4j
@CompileStatic
class RevisioneStoricoPostUpdateEventListenerImpl extends EnversPostUpdateEventListenerImpl {

    private final RevisioneStoricoRegister revisioneStoricoRegister

    RevisioneStoricoPostUpdateEventListenerImpl(EnversService enversService, RevisioneStoricoRegister revisioneStoricoRegister) {
        super(enversService)
        this.revisioneStoricoRegister = revisioneStoricoRegister
    }

    @Override
    void onPostUpdate(PostUpdateEvent event) {
        if (event.getEntity() instanceof FileDocumento) {
            FileDocumento fileDocumento = (FileDocumento) event.getEntity()
            log.debug("[${fileDocumento.id}][UPDATE]: ${fileDocumento.codice} ${fileDocumento.nome}")
            revisioneStoricoRegister.aggiornaVersioneStorico(fileDocumento)
        }

        super.onPostUpdate(event)
    }
}
