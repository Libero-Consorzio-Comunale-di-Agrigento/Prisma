package it.finmatica.protocollo.integrazioni


import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioneDTO
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioneService
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.multiente.Ente
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.integrazioni.gdm.DateService
import org.apache.commons.lang3.time.FastDateFormat
import org.springframework.beans.factory.annotation.Autowired

@Action
@Slf4j
class AggiornaDataBloccoPG {
    @Autowired SpringSecurityService springSecurityService
    @Autowired DateService dateService
    @Autowired ImpostazioneService impostazioneService
    private final FastDateFormat df = FastDateFormat.getInstance('dd/MM/yyyy')
    private static final String CODICE_IMPOSTAZIONE = 'DATA_BLOCCO'

    @Action(tipo = Action.TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Aggiorna la data blocco PG al giorno precedente alla data odierna ",
            descrizione = "Prende la data attuale dal database e aggiorna l'impostazione DATA_BLOCCO al giorno prima")
    Protocollo aggiornaDataBloccoPG(Protocollo documento) {
        Ente ente = springSecurityService.principal.ente
        ImpostazioneDTO dto = new ImpostazioneDTO(ente: ente.toDTO(),codice: CODICE_IMPOSTAZIONE)
        dto.valore = df.format(dateService.currentDate - 1)
        impostazioneService.salva(dto)
        log.info("Aggiornata data blocco PG per ente {} a {}","${ente.id} - ${ente.descrizione}",dto.valore)
        return documento
    }
}
