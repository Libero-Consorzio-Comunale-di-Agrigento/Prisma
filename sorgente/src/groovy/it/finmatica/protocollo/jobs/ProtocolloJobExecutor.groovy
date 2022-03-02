package it.finmatica.protocollo.jobs

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.TokenIntegrazione
import it.finmatica.gestionedocumenti.commons.TokenIntegrazioneService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.firma.GestioneDocumentiFirmaService
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloEsternoRepository
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional

@Slf4j
@Transactional
class ProtocolloJobExecutor {

    public static final String UTENTE_AGGIORNAMENTO_TRASCODIFICHE = "TRASCO"

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
        TokenIntegrazione token = tokenIntegrazioneService.beginTokenTransaction("JOB_NOTTURNO", "PROTOCOLLO_JOB")
        if (!token.statoInCorso) {
            log.info("C'è già un job che sta girando per l'ente con codice: ${codiceAmmistrazione}, esco e non faccio nulla.")
            return false
        }

        return true
    }

    void unlock(String amministrazione) {
        Utils.setAmministrazioneOttica(amministrazione)
        tokenIntegrazioneService.endTokenTransaction("JOB_NOTTURNO", "PROTOCOLLO_JOB")
    }

    /**
     * Manda una mail ed una notifica jworklist di tipo ToDo
     * Cercare tutti i documenti di un certo tipo che devono avere il flusso concluso
     * e con una scadenza di 25 gg dall'avvio del flusso? (inviare la mail ogni giorno)
     * la data da cui partire è la data di protocollazione del documento precedente + 30 gg -5 gg (giorni prima della scadenza)
     *
     * @param codiceAmministrazione
     * @param id
     */
    void inviaAvviso(String codiceAmministrazione) {

        // Cercare tutti i documenti di tipo RCERT, analizzare il protocollo precedente:
        // verificare che abbia una scadenza di 25 gg dall'avvio del flusso (inviare la mail ogni giorno)
        // la data da cui partire è la data di protocollazione del documento precedente + 30 gg -5 gg (giorni prima della scadenza)

        List<Protocollo> documenti = protocolloService.getDocumentiNonInviatiConSchemiAssociatiConScadenza()
        for (Protocollo p : documenti) {
            Protocollo prec = protocolloService.getProtocolloPrecedente(p)

            if (prec != null && validaScadenza(prec)) {
                String utenteAggiornamento = ProtocolloEsterno.get(prec?.idDocumentoEsterno)?.utenteAggiornamento

                if (utenteAggiornamento != UTENTE_AGGIORNAMENTO_TRASCODIFICHE) {
                    log.info("Invia notifica TODO e mail di avviso per Protocollo Precedente: ${prec.tipoRegistro.commento} - ${prec.numero} - ${prec.anno}")
                    notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_TODO_SCADENZA, p, "Messaggio: Documento in scadenza")
                    notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_EMAIL_SCADENZA, p)
                }
            }
        }

        // controllare se ci sono dei documenti di tipo DCERT che non hanno un RCERT successivo
        // in questo caso controllare che ci siano degli smistamnenti correnti per competenza e inviare la notifica come nel caso precedente
        // in caso non ci siano smistamenti correnti inviarlo alla Unità Protocollante
        List<SchemaProtocollo> schemiDomanda = SchemaProtocollo.findAllByScadenzaIsNotNull()
        List<String> schemiDomandaCodici = schemiDomanda.collect {
            row -> row.codice
        }

        if(schemiDomandaCodici?.size() > 0){
            List<ProtocolloEsterno> documentiDomande = protocolloEsternoRepository.getProtocolloEsterniDomande(schemiDomandaCodici, UTENTE_AGGIORNAMENTO_TRASCODIFICHE)
            TipoCollegamento collegamento = TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
            for (ProtocolloEsterno protocolloEsterno : documentiDomande) {
                Protocollo protocolloDomanda = Protocollo.findByIdDocumentoEsterno(protocolloEsterno.idDocumentoEsterno)
                // se c'è vado a controllare che ci sia un collegamento come precedente ad un RCERT
                if (DocumentoCollegato.findByCollegatoAndTipoCollegamento(protocolloDomanda, collegamento) == null && validaScadenza(protocolloDomanda)) {
                    log.info("Invia notifica TODO e mail di avviso protocolli senza risposta dopo la scadenza: ${protocolloDomanda.tipoRegistro.commento} - ${protocolloDomanda.numero} - ${protocolloDomanda.anno}")
                    notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_SCADENZA_RISPOSTA_GDM, protocolloDomanda, "Messaggio TODO Smistamenti Correnti")
                    notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_EMAIL_GDM_SMISTAMENTI_CORRENTI, protocolloDomanda)
                }
            }
        }
    }

    void verificaFirma(String codiceAmministrazione) {
        if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
            log.info("Estrazione delle informazioni dei file firmati internamente al sistema")
            try {
                // imposto il filtro dell'ente per la sessione hibernate e seleziono l'amministrazione di login
                Utils.setAmministrazioneOttica(codiceAmministrazione)
                documentoService.estraiInformazioniFileFirmati()
            } catch (Throwable t) {
                log.error("Errore nell'estrazione delle informazioni dai file firmati internamente al sistema per l'ente: ${codiceAmministrazione}", t)
            }
        }
    }

    void eliminaTransazioniFirmaVecchie(String codiceAmministrazione) {

        Utils.setAmministrazioneOttica(codiceAmministrazione)
        gestioneDocumentiFirmaService.eliminaTransazioniVecchie()
    }

    private boolean validaScadenza(Protocollo prec) {
        if (prec?.data == null) {
            return false
        }
        Date scadenza = prec.data
        Calendar c = Calendar.getInstance()
        c.setTime(scadenza)
        if (prec.schemaProtocollo?.scadenza == null) {
            return false
        }
        c.add(Calendar.DATE, prec.schemaProtocollo.scadenza)
        scadenza = c.time
        return scadenza.before(new Date())
    }
}