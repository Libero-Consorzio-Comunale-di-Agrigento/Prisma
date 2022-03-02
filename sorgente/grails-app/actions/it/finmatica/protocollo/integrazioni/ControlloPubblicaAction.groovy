package it.finmatica.protocollo.integrazioni


import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioneDTO
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioneService
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.multiente.Ente
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.integrazioni.gdm.DateService
import org.apache.commons.lang3.time.FastDateFormat
import org.springframework.beans.factory.annotation.Autowired

@Action
@Slf4j
class ControlloPubblicaAction {
    @Autowired SpringSecurityService springSecurityService
    @Autowired PrivilegioUtenteService privilegioUtenteService

    @Action(tipo = Action.TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "L'utente può pubblicare all'albo?",
            descrizione = "Verifica se l'utente ha il privilegio di pubblicare all'albo")
    boolean controllaVisibilita(Protocollo documento) {
        Ad4Utente utente = springSecurityService.currentUser
        documento.protocollato && privilegioUtenteService.getPrivilegi(utente, PrivilegioUtente.PUBALBO)
    }
}
