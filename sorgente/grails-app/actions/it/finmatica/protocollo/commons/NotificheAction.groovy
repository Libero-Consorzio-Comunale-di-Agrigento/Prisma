package it.finmatica.protocollo.commons

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestioneiter.IDocumentoIterabile
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.gestioneiter.annotations.Action.TipoAzione
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import org.springframework.beans.factory.annotation.Autowired

@Action
class NotificheAction {

    // services
    @Autowired
    NotificheService notificheService
    @Autowired
    SpringSecurityService springSecurityService

    /*
     * Azioni di notifica
     */

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "L'utente ha una notifica sulla jworklist?",
            descrizione = "Ritorna TRUE se l'utente corrente ha una notifica sulla jworklist non legata al cambio step.")
    boolean isNotificaPresente(Protocollo d) {
        return notificheService.isNotificaPresente(d, springSecurityService.currentUser)
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica dello Step DA INVIARE al Firmatario",
            descrizione = "Notifica di Cambio Step, usata nello step DA INVIARE, per inviare la stessa notifica al Firmatario")
    IDocumentoIterabile notificaFirmatario(Protocollo d) {
        Ad4Utente utenteDirigente = d.getSoggetto(TipoSoggetto.FIRMATARIO)?.utenteAd4
        Ad4Utente utenteRedattore = d.getSoggetto(TipoSoggetto.REDATTORE)?.utenteAd4
        if (utenteDirigente.id != utenteRedattore.id) {
            notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO_FIRMATARIO, d)
        }
        return d
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica del Cambio Nodo",
            descrizione = "Notifica del Cambio Nodo")
    IDocumentoIterabile notificaCambioNodo(Protocollo d) {
        d = Protocollo.get(d.id)

        notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, d.idDocumentoEsterno.toString(), null)
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, d)

        return d
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 1",
            descrizione = "Notifica generica 1")
    IDocumentoIterabile notificaGenerica_1(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_1, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 2",
            descrizione = "Notifica generica 2")
    IDocumentoIterabile notificaGenerica_2(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_2, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 3",
            descrizione = "Notifica generica 3")
    IDocumentoIterabile notificaGenerica_3(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_3, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 4",
            descrizione = "Notifica generica 4")
    IDocumentoIterabile notificaGenerica_4(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_4, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 5",
            descrizione = "Notifica generica 5")
    IDocumentoIterabile notificaGenerica_5(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_5, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 6",
            descrizione = "Notifica generica 6")
    IDocumentoIterabile notificaGenerica_6(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_6, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 7",
            descrizione = "Notifica generica 7")
    IDocumentoIterabile notificaGenerica_7(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_7, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 8",
            descrizione = "Notifica generica 8")
    IDocumentoIterabile notificaGenerica_8(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_8, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 9",
            descrizione = "Notifica generica 9")
    IDocumentoIterabile notificaGenerica_9(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_9, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Generica 10",
            descrizione = "Notifica generica 10")
    IDocumentoIterabile notificaGenerica_10(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_GENERICA_10, protocollo)
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Notifica Protocollo Emergenza",
            descrizione = "Notifica Protocollo Emergenza")
    IDocumentoIterabile notificaProtocolloEmergenza(Protocollo protocollo) {
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_PROTOCOLLO_EMERGENZA, protocollo)
        return protocollo
    }
}
