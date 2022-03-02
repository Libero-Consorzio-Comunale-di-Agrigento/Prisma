package it.finmatica.protocollo.documenti.beans

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.gestioneiter.IDocumentoIterabile
import it.finmatica.gestioneiter.IGestoreEventiIter
import it.finmatica.gestioneiter.motore.WkfIter
import it.finmatica.gestioneiter.motore.WkfStep
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.ApplicationContext

@Slf4j
class ProtocolloGestoreEventiIter implements IGestoreEventiIter {

    @Autowired
    ApplicationContext applicationContext
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    NotificheService notificheService
    @Autowired
    SuccessHandler successHandler

    @Override
    void cambioStep(IDocumentoIterabile documentoIterabile, WkfIter iter, WkfStep stepPrecedente, WkfStep stepSuccessivo) {
        log.debug("Sto cambiando lo step dell'iter '${iter.cfgIter.nome}'(${iter.id}) da '${stepPrecedente?.cfgStep?.nome}'(${stepPrecedente?.id}) -> '${stepSuccessivo?.cfgStep?.nome}'(${stepSuccessivo.id}) per il documento ${documentoIterabile.id}")

        if (stepPrecedente != null && stepPrecedente != stepSuccessivo && successHandler.idIterSaltaControlloTesto != iter.id && documentoIterabile instanceof Protocollo) {
            Protocollo p = (Protocollo) documentoIterabile
            if (p.categoriaProtocollo.modelloTestoObbligatorio) {
                if (p.filePrincipale?.idFileEsterno == null) {
                    throw new ProtocolloRuntimeException("Il file principale è obbligatorio")
                }
            }
        }

        if (stepPrecedente != null && stepPrecedente.attori?.size() > 0 && documentoIterabile instanceof Protocollo) {
            getProtocolloService().storicizzaProtocollo(documentoIterabile, stepPrecedente)

            // dopo la storicizzazione dei dati, elimino le note di trasmissione perché sono già state eventualmente storicizzate
            // e devo dare la possibilità al prossimo utente di scriverne di nuove.
            Protocollo protocollo = documentoIterabile
            protocollo.noteTrasmissione = null
            protocollo.save()
        }

        if (stepPrecedente != null && stepSuccessivo != null && !stepSuccessivo.cfgStep.condizionale && documentoIterabile instanceof Protocollo) {
            getProtocolloService().cambioStepGdm(documentoIterabile)
        }

        // elimino tutte le notifiche di cambio step del nodo corrente (solo se l'ho)
        if (stepPrecedente != null) {
            notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, documentoIterabile.idDocumentoEsterno.toString(), null)
            notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO_FIRMATARIO, documentoIterabile.idDocumentoEsterno.toString(), null)
        }

        // invia le notifiche solo se il nodo in cui vado ha degli attori
        if (stepSuccessivo?.attori?.size() > 0) {

            log.info("Inizio : Invio Notifica di CAMBIO_NODO")
            log.info("Classe del documento per cui invia la notifica: " + documentoIterabile.class.canonicalName)
            notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, documentoIterabile)
            log.info("Fine : Invio Notifica di CAMBIO_NODO")
        }
    }

    // devo fare così perché c'è una dipendenza circolare tra ProtocolloService -> WkfIterService -> ProtocolloGestoreEventiIter -> ProtocolloService
    private ProtocolloService getProtocolloService() {
        return applicationContext.getBean(ProtocolloService.class)
    }
}