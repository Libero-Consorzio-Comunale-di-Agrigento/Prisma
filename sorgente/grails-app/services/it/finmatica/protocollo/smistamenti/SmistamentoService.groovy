package it.finmatica.protocollo.smistamenti

import commons.PopupSceltaSmistamentiViewModel
import commons.PopupSceltaSmistamentiViewModel.DatiSmistamento
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.JWorklistNotificheDispatcher
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.documenti.IterDocumentaleRepository
import it.finmatica.protocollo.documenti.IterFascicolareRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamento
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamentoDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloUtilService
import it.finmatica.protocollo.integrazioni.gdm.converters.StatoSmistamentoConverter
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.protocollo.integrazioni.smartdesktop.EsitoSmartDesktop
import it.finmatica.protocollo.integrazioni.smartdesktop.EsitoTask
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheSmistamentoRepository
import it.finmatica.segreteria.jprotocollo.struttura.IProfiloSmistabile
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Campo
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.text.DateFormat
import java.text.SimpleDateFormat

/**
 * Gestisce gli smistamenti.
 *
 * CREATO -> DA_RICEVERE -> IN_CARICO (se per COMPETENZA)
 *                                                          -> STORICO   (se inoltrato. Il nuovo smistamento assumerà il valore di DA_RICEVERE)
 *                                                          -> IN_CARICO (se assegnato, con assegnatario)
 *                                                          -> ESEGUITO
 *                                                                      -> STORICO  (se inoltrato. Il nuovo smistamento assumerà il valore di DA_RICEVERE)
 *                                                                      -> ESEGUITO (se assegnato, con assegnatario) FIXME: FORSE NO
 *                       -> ESEGUITO  (se per CONOSCENZA)
 *                                                          -> STORICO  (se inoltrato. Il nuovo smistamento assumerà il valore di DA_RICEVERE)
 *                                                          -> ESEGUITO (se assegnato, con assegnatario)
 *                       -> STORICO   (rifiutato, con motivazione)
 *
 */
@Slf4j
@Transactional
@Service
class SmistamentoService {

    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    ProtocolloUtilService protocolloUtilService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    JWorklistNotificheDispatcher jWorklistNotificheDispatcher
    @Autowired
    NotificheService notificheService
    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm
    @Autowired
    DataSource dataSource
    @Autowired
    DateService dateService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    StrutturaOrganizzativaService strutturaOrganizzativaService
    @Autowired
    SmistamentoRepository smistamentoRepository
    @Autowired
    IterDocumentaleRepository iterDocumentaleRepository
    @Autowired
    IterFascicolareRepository iterFascicolareRepository
    /*
     * Metodi richiamabili dal ViewModel
     */

    /**
     * Crea o Aggiorna gli smistamenti. Allinea anche GDM. Invia notifiche "DA_RICEVERE" in caso lo smistamento sia creato a documento già Protocollato.
     *
     */
    void salva(ISmistabileDTO smistabileDTO, List<SmistamentoDTO> smistamentiDTO) {
        ISmistabile smistabile = smistabileDTO.domainObject

        salva(smistabile, smistamentiDTO)

        smistabileDTO.version = smistabile.version
    }

    void salva(ISmistabile smistabile, List<SmistamentoDTO> smistamentiDTO) {

        for (SmistamentoDTO smistamentoDTO : smistamentiDTO) {
            Smistamento smistamento = smistamentoDTO?.domainObject
            if (smistamento == null) {
                if (smistamentoDTO.unitaTrasmissione == null && smistabile.numero == null) {
                    smistamentoDTO.unitaTrasmissione = smistabile.getUnita()?.toDTO()
                }
                smistamento = creaSmistamento(smistabile, smistamentoDTO.tipoSmistamento, smistamentoDTO.unitaTrasmissione?.domainObject, smistamentoDTO.utenteTrasmissione?.domainObject, smistamentoDTO.unitaSmistamento?.domainObject, smistamentoDTO.utenteAssegnatario?.domainObject, smistamentoDTO.note)

                if (smistabile.smistamentoAttivoInCreazione) {
                    creaSmistamento(smistamento, dateService.getCurrentDate())
                }
                smistamentoDTO.id = smistamento.id
                smistamentoDTO.idDocumentoEsterno = smistamento.idDocumentoEsterno
                continue
            }

            // allineo i campi modificabili da interfaccia una volta che lo smistamento è stato creato
            smistamento.note = smistamentoDTO.note
            smistamento.unitaTrasmissione = smistamentoDTO.unitaTrasmissione?.domainObject
            smistamento.save()
            protocolloGdmService.salvaSmistamento(smistamento)
        }
    }

    void salva(SchemaProtocolloDTO schemaProtocolloDTO, List<SchemaProtocolloSmistamentoDTO> smistamentiDTO) {
        SchemaProtocollo schemaProtocollo = schemaProtocolloDTO.domainObject

        for (SchemaProtocolloSmistamentoDTO smistamentoDTO : smistamentiDTO) {
            SchemaProtocolloSmistamento smistamento = smistamentoDTO.domainObject
            if (smistamento == null) {
                creaSmistamento(schemaProtocollo, smistamentoDTO.tipoSmistamento, smistamentoDTO.unitaSo4Smistamento?.domainObject, null, smistamentoDTO.unitaSo4Smistamento?.domainObject)
            }
        }
        schemaProtocolloDTO.version = schemaProtocollo.version
    }

    List<SmistamentoDTO> creaSmistamenti(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamenti) {
        for (PopupSceltaSmistamentiViewModel.DatiDestinatario destinatario : datiSmistamenti.destinatari) {
            SmistamentoDTO smistamento = new SmistamentoDTO()
            if (smistabileDTO.smistamentoAttivoInCreazione) {
                smistamento.statoSmistamento = Smistamento.DA_RICEVERE
                smistamento.dataSmistamento = dateService.getCurrentDate()
            } else {
                smistamento.statoSmistamento = Smistamento.CREATO
            }
            smistamento.tipoSmistamento = datiSmistamenti.tipoSmistamento
            smistamento.note = destinatario.note

            smistamento.unitaTrasmissione = datiSmistamenti.unitaTrasmissione
            smistamento.utenteTrasmissione = datiSmistamenti.utenteTrasmissione

            smistamento.unitaSmistamento = destinatario.unita
            if (destinatario.utente != null) {
                smistamento.dataAssegnazione = dateService.getCurrentDate()
                smistamento.utenteAssegnatario = destinatario.utente
                smistamento.utenteAssegnante = datiSmistamenti.utenteTrasmissione
                smistamento.note = destinatario.note
            }

            smistabileDTO.addToSmistamenti(smistamento)
        }
        return smistabileDTO.smistamenti?.toList() ?: []
    }

    List<SmistamentoDTO> creaSmistamenti(SchemaProtocolloDTO schemaProtocolloDTO, DatiSmistamento datiSmistamenti) {
        PopupSceltaSmistamentiViewModel.DatiDestinatario destinatario = datiSmistamenti.destinatari[0]
        SchemaProtocolloSmistamentoDTO schemaProtocolloSmistamento = new SchemaProtocolloSmistamentoDTO()
        schemaProtocolloSmistamento.tipoSmistamento = datiSmistamenti.tipoSmistamento
        schemaProtocolloSmistamento.unitaSo4Smistamento = datiSmistamenti.unitaTrasmissione
        schemaProtocolloSmistamento.unitaSo4Smistamento = destinatario.unita
        schemaProtocolloDTO.addToSmistamenti(schemaProtocolloSmistamento)
        return schemaProtocolloDTO.smistamenti?.toList() ?: []
    }

    List<SmistamentoDTO> creaSmistamenti(MessaggioRicevutoDTO messaggioRicevutoDTO, PopupSceltaSmistamentiViewModel.DatiSmistamento datiSmistamenti) {
        for (PopupSceltaSmistamentiViewModel.DatiDestinatario destinatario : datiSmistamenti.destinatari) {
            SmistamentoDTO smistamento = new SmistamentoDTO()
            smistamento.statoSmistamento = Smistamento.CREATO
            smistamento.tipoSmistamento = datiSmistamenti.tipoSmistamento
            smistamento.note = destinatario.note

            smistamento.unitaTrasmissione = datiSmistamenti.unitaTrasmissione
            smistamento.utenteTrasmissione = datiSmistamenti.utenteTrasmissione

            smistamento.unitaSmistamento = destinatario.unita
            if (destinatario.utente != null) {
                smistamento.dataAssegnazione = dateService.getCurrentDate()
                smistamento.utenteAssegnatario = destinatario.utente
                smistamento.utenteAssegnante = datiSmistamenti.utenteTrasmissione
                smistamento.note = destinatario.note
            }

            messaggioRicevutoDTO.addToSmistamenti(smistamento)
        }
        return messaggioRicevutoDTO.smistamenti?.toList() ?: []
    }

    /**
     * Ritorna l'elenco degli smistamenti "attivi" del protocollo.
     * @param smistabile
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSmistamentiAttivi(ISmistabile smistabile) {
        return Smistamento.documentoAndStato(smistabile?.id, [Smistamento.CREATO, Smistamento.DA_RICEVERE, Smistamento.IN_CARICO, Smistamento.ESEGUITO]).list()
    }

    /**
     * Ritorna l'elenco degli smistamenti storici
     * @param idDocumentoPrincipale
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSmistamentiStorici(long idDocumentoPrincipale) {
        return Smistamento.documentoAndStato(idDocumentoPrincipale, [Smistamento.STORICO]).list()
    }

    /**
     * Ritorna l'elenco degli smistamenti da ricevere per un'unità cui l'utente appartiene
     * @param smistabile
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSmistamentiPerUnitaAppartenenza(ISmistabile smistabile, List<String> statoSmistamento) {
        List<Smistamento> smistamentoList = new ArrayList<Smistamento>()
        List<So4UnitaPubb> listaUnitaUtente = strutturaOrganizzativaService.getUnitaUtente(springSecurityService.principal.id,
                springSecurityService.principal.ottica().codice)

        if (listaUnitaUtente != null) {
            for (smistamento in smistabile.getSmistamentiValidi()) {
                if (smistamento.getUnitaSmistamento() != null) {
                    if (statoSmistamento.contains(smistamento.statoSmistamento) &&
                            listaUnitaUtente.find { it.progr == smistamento.getUnitaSmistamento().progr }) {
                        smistamentoList.add(smistamento)
                    }
                }
            }
        }

        return smistamentoList
    }

    /**
     * Ritorna l'elenco degli smistamenti assegnati per gestire le competenze esplicite (Issue #30368)
     *
     * @param smistabile
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSmistamentiCompetenzeEsplicite(ISmistabile smistabile) {
        return smistabile.getSmistamentiCompetenzaEsplicita()
    }

    /*
     * Operazioni disponibili da interfaccia:
     * (RIPUDIO):                        "Rifiuta Smistamento"
     * (CARICO):                         "Prendi in carico"
     * (APRI_CARICO_FLEX):               "Prendi in carico ed inoltra"
     * (CARICO_ESEGUI):                  "Prendi in carico ed esegui"
     * (APRI_CARICO_ASSEGNA):            "Prendi in carico ed assegna"
     * (APRI_CARICO_ESEGUI_FLEX):        "Prendi in carico, smista ed esegui"

     * (APRI_ASSEGNA):                   "Assegna"
     * (APRI_INOLTRA_FLEX):              "Inoltra"
     * (FATTO):                          "Esegui"
     * (FATTO_IN_VISUALIZZA):            "Esegui"
     * (APRI_ESEGUI_FLEX):               "Prendi in carico, smista ed esegui"
     */

    /**
     *
     * @param protocolloDto
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop prendiInCaricoEInoltra(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamento, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Prendi in carico e inoltra"
        String operazione = " - Inoltro a "

        IProfiloSmistabile pGdm = null
        if (idSmistamentoGdm != null) {
            pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)

            List<EsitoTask> esiti = controllaSmistamentiDuplicati(pGdm, idSmistamentoGdm, datiSmistamento.tipoSmistamento, datiSmistamento.unitaTrasmissione.codice, datiSmistamento.destinatari, " - Smistamento a ")
            esitoSmartDesktop.esitoTasks.addAll(esiti)
        }

        // Gestione SmartDesktop
        if (idSmistamentoGdm != null && smistabileDTO == null) {
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()

            Date now = dateService.getCurrentDate()

            try {
                protocolloGdmService.prendiInCaricoSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, false)
                protocolloGdmService.storicizzaSmistamento(idSmistamentoGdm)

                for (def destinatario : getDestinatariList(datiSmistamento.destinatari)) {
                    try {
                        boolean smistamentoConsentito = protocolloGdmService.inoltraSmistamento(idSmistamentoGdm, now, datiSmistamento.unitaTrasmissione?.domainObject, springSecurityService.currentUser, destinatario.unita, destinatario.utente, destinatario.note)
                        if (smistamentoConsentito) {
                            EsitoTask esitoTask = new EsitoTask()
                            esitoTask.messaggio = getDescrizioneOperazione(operazione, destinatario)
                            esitoSmartDesktop.esitoTasks.add(esitoTask)
                        } else {
                            EsitoTask esitoTask = new EsitoTask()
                            esitoTask.successo = false
                            esitoTask.messaggio = "Impossibile Smistare per competenza"
                            esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                            esitoSmartDesktop.esitoTasks.add(esitoTask)
                        }
                    } catch (ProtocolloRuntimeException e) {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.successo = false
                        if (e.cause) {
                            esitoTask.messaggio = e.cause.localizedMessage
                        }
                        esitoTask.messaggio = e.message
                        esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)

                        log.error(esitoTask.messaggio)
                    }
                }
            } catch (ProtocolloRuntimeException e) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            }

            return esitoSmartDesktop
        }

        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabileDTO)
        def destinatariList = getDestinatariList(datiSmistamento.destinatari)
        try {
            controllaFascicoloObbligatorio(smistabileDTO.domainObject)

            if (datiSmistamento.unitaTrasmissione == null) {
                throw new ProtocolloRuntimeException("Valorizzare l'unità di trasmissione")
            }

            boolean smistamentoConsentito = true

            if (smistamentoConsentito) {
                prendiInCaricoEInoltra(smistabileDTO.domainObject, datiSmistamento.tipoSmistamento, springSecurityService.currentUser, datiSmistamento.unitaTrasmissione.domainObject, datiSmistamento.utenteTrasmissione.domainObject, destinatariList, idSmistamentoGdm)
                for (def destinatario : destinatariList) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.messaggio = "Inoltrato a " + destinatario.unita.descrizione
                    if (destinatario.utente) {
                        esitoTask.messaggio += " assegnato a " + destinatario.utente.nominativoSoggetto
                    }
                    esitoSmartDesktop.esitoTasks.add(esitoTask)
                }
            } else {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                esitoTask.messaggio = "Impossibile Smistare per competenza"
                esitoSmartDesktop.esitoTasks.add(esitoTask)
            }
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }
        return esitoSmartDesktop
    }

    private String getDescrizioneProtocollo(ISmistabileDTO smistabileDTO) {
        return getDescrizioneProtocollo(smistabileDTO.domainObject)
    }

    private String getDescrizioneProtocollo(ISmistabile smistabile) {
        if (smistabile instanceof MessaggioRicevuto) {
            MessaggioRicevuto messaggioRicevuto = smistabile
            "Messaggio ${messaggioRicevuto.idMessaggioSi4Cs}"
        } else if (smistabile instanceof Fascicolo) {
            "${smistabile.classificazione.codice} -  ${smistabile.anno} / ${smistabile.numero} -  ${smistabile.oggetto}"
        }
        else {
            "PG ${smistabile.anno} / ${smistabile.numero} - ${smistabile.oggetto}"
        }
    }

    /**
     *
     * @param smistabileDTO
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop prendiInCaricoSmistaEdEsegui(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamento, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Prendi in carico, smista ed esegui"
        String operazione = " - Smistamento a "

        IProfiloSmistabile pGdm = null
        if (idSmistamentoGdm != null) {
            pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)

            List<EsitoTask> esiti = controllaSmistamentiDuplicati(pGdm, idSmistamentoGdm, datiSmistamento.tipoSmistamento, datiSmistamento.unitaTrasmissione.codice, datiSmistamento.destinatari, " - Smistamento a ")
            esitoSmartDesktop.esitoTasks.addAll(esiti)
        }

        if (datiSmistamento.unitaTrasmissione == null) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                esitoTask.messaggio = "Valorizzare l'unità di trasmissione"
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
                return esitoSmartDesktop
            } else {
                throw new ProtocolloRuntimeException("Valorizzare l'unità di trasmissione")
            }
        }

        // Gestione SmartDesktop
        if (idSmistamentoGdm != null && smistabileDTO == null) {
            boolean eliminaAttivita = false

            esitoSmartDesktop.descrizione = pGdm.getDescrizione()
            Date now = dateService.getCurrentDate()
            try {
                protocolloGdmService.prendiInCaricoSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, false)
                protocolloGdmService.eseguiSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, false)

                for (def destinatario : getDestinatariList(datiSmistamento.destinatari)) {
                    try {
                        boolean smistamentoConsentito = protocolloGdmService.inoltraSmistamento(idSmistamentoGdm, now, datiSmistamento.unitaTrasmissione?.domainObject, springSecurityService.currentUser, destinatario.unita, destinatario.utente, destinatario.note, datiSmistamento.tipoSmistamento)
                        if (smistamentoConsentito) {
                            EsitoTask esitoTask = new EsitoTask()
                            esitoTask.messaggio = getDescrizioneOperazione(operazione, destinatario)
                            esitoSmartDesktop.esitoTasks.add(esitoTask)
                            eliminaAttivita = true
                        } else {
                            EsitoTask esitoTask = new EsitoTask()
                            esitoTask.successo = false
                            esitoTask.messaggio = "Impossibile Smistare per competenza"
                            esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                            esitoSmartDesktop.esitoTasks.add(esitoTask)
                        }
                    } catch (ProtocolloRuntimeException e) {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.successo = false
                        if (e.cause) {
                            esitoTask.messaggio = e.cause.localizedMessage
                        }
                        esitoTask.messaggio = e.message
                        esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)

                        log.error(esitoTask.messaggio)
                    }
                }
            } catch (ProtocolloRuntimeException e) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            }

            if (eliminaAttivita) {
                notificheService.eliminaNotifica(null, idSmistamentoGdm.toString(), null)
            }

            return esitoSmartDesktop
        }

        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabileDTO)
        try {
            controllaFascicoloObbligatorio(smistabileDTO.domainObject)

            //tolto il controllo
            boolean smistamentoConsentito = true
            if (smistamentoConsentito) {
                List<Map> destinatariList = getDestinatariList(datiSmistamento.destinatari)
                prendiInCaricoSmistaEdEsegui(smistabileDTO.domainObject, datiSmistamento.tipoSmistamento, springSecurityService.currentUser, datiSmistamento.unitaTrasmissione.domainObject, datiSmistamento.utenteTrasmissione.domainObject, destinatariList, idSmistamentoGdm)
                for (def destinatario : destinatariList) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.messaggio = "Smistato a " + destinatario.unita.descrizione
                    if (destinatario.utente) {
                        esitoTask.messaggio += " assegnato a " + destinatario.utente.nominativoSoggetto
                    }
                    esitoSmartDesktop.esitoTasks.add(esitoTask)
                }
            } else {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                esitoTask.messaggio = "Impossibile Smistare per competenza"
                esitoSmartDesktop.esitoTasks.add(esitoTask)
            }
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)
                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }
        return esitoSmartDesktop
    }

    /**
     *
     * @param smistabileDTO
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop prendiInCaricoEdEsegui(ISmistabileDTO smistabileDTO, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Prendi in carico ed esegui"

        // Gestione SmartDesktop
        if (idSmistamentoGdm != null && smistabileDTO == null) {

            boolean eliminaAttivita = false

            IProfiloSmistabile pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()
            Date now = dateService.getCurrentDate()
            try {

                protocolloGdmService.prendiInCaricoSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, false)
                Documento smistamentoSmart = protocolloGdmService.eseguiSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, true)
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.messaggio = costruisciEsitoPerSmistamentiInCarico(smistamentoSmart) + " passato in ESEGUITO."
                esitoSmartDesktop.esitoTasks.add(esitoTask)
            } catch (ProtocolloRuntimeException e) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)
                log.error(esitoTask.messaggio)
            }

            if (eliminaAttivita) {
                notificheService.eliminaNotifica(null, idSmistamentoGdm.toString(), null)
            }

            return esitoSmartDesktop
        }

        // AGSPR
        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabileDTO)
        try {

            Documento smistamentoSmart = prendiInCaricoEdEsegui(smistabileDTO.domainObject, springSecurityService.currentUser, Smistamento.findByIdDocumentoEsterno(idSmistamentoGdm))
            EsitoTask esitoTask = new EsitoTask()
            if (smistamentoSmart) {
                esitoTask.messaggio = costruisciEsitoPerSmistamentiInCarico(smistamentoSmart) + " passato in ESEGUITO."
                esitoSmartDesktop.esitoTasks.add(esitoTask)
            }
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)
                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }
        return esitoSmartDesktop
    }

    /**
     *
     * @param smistabileDTO
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop esegui(ISmistabileDTO smistabileDTO, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Esegui"

        // Gestione SmartDesktop
        if (idSmistamentoGdm != null && smistabileDTO == null) {

            boolean eliminaAttivita = false

            IProfiloSmistabile pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()
            Date now = dateService.getCurrentDate()
            try {

                Documento smistamentoSmart = protocolloGdmService.eseguiSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, true)
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.messaggio = costruisciEsitoPerSmistamentiInCarico(smistamentoSmart) + " completato correttamente."
                esitoSmartDesktop.esitoTasks.add(esitoTask)
            } catch (ProtocolloRuntimeException e) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)
                log.error(esitoTask.messaggio)
            }

            if (eliminaAttivita) {
                notificheService.eliminaNotifica(null, idSmistamentoGdm.toString(), null)
            }

            return esitoSmartDesktop
        }

        // AGSPR
        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabileDTO)
        try {

            Documento smistamentoSmart = esegui(smistabileDTO.domainObject, springSecurityService.currentUser, Smistamento.findByIdDocumentoEsterno(idSmistamentoGdm))
            EsitoTask esitoTask = new EsitoTask()
            if (smistamentoSmart) {
                esitoTask.messaggio = costruisciEsitoPerSmistamentiInCarico(smistamentoSmart) + " completato correttamente."
                esitoSmartDesktop.esitoTasks.add(esitoTask)
            }
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)
                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }
        return esitoSmartDesktop
    }

    private String costruisciEsitoPerSmistamentiInCarico(Documento smistamentoSmart) {

        String dateString = ""
        Object valore = smistamentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_DAL")).valore
        if (valore instanceof String) {
            dateString = valore
        } else {
            DateFormat format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.ITALIAN)
            dateString = format.format(valore)
        }

        StringUtils.join("Smistamento per ", smistamentoSmart.trovaCampo(new Campo("TIPO_SMISTAMENTO")).valore
                , " da ", smistamentoSmart.trovaCampo(new Campo("DES_UFFICIO_TRASMISSIONE")).valore
                , " a ", smistamentoSmart.trovaCampo(new Campo("DES_UFFICIO_SMISTAMENTO")).valore
                , (smistamentoSmart.trovaCampo(new Campo("CODICE_ASSEGNATARIO"))?.valore == "") ? "" :
                StringUtils.join(" nella persona di ", Ad4Utente.get(smistamentoSmart.trovaCampo(new Campo("PRESA_IN_CARICO_UTENTE")).valore).nominativoSoggetto)
                , " del ", dateString)
    }

    /**
     *
     * @param smistabileDTO
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop prendiInCaricoEAssegna(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamento, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Prendi in Carico e Assegna"

        List<Map> destinatariList = getDestinatariList(datiSmistamento.destinatari)

        IProfiloSmistabile pGdm = null
        if (idSmistamentoGdm != null) {
            pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()
            Documento pSmistamento = buildDocumentoSmart(idSmistamentoGdm)
            String unitaTrasmissioneSmistamento = pSmistamento.trovaCampo("UFFICIO_TRASMISSIONE")?.valore

            List<EsitoTask> esiti = controllaSmistamentiDuplicati(pGdm, idSmistamentoGdm, datiSmistamento.tipoSmistamento, unitaTrasmissioneSmistamento, destinatariList, " - Smistamento a ")
            esitoSmartDesktop.esitoTasks.addAll(esiti)
        }

        if (destinatariList.size() > 0) {
            // Gestione SmartDesktop CASO DOCUMENTI NON GESTITI DA AGSPR
            if (idSmistamentoGdm != null && smistabileDTO == null) {
                Date now = dateService.getCurrentDate()
                esitoSmartDesktop.descrizione = pGdm.getDescrizione()

                try {
                    // prendo in carico lo smistamento
                    protocolloGdmService.prendiInCaricoSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, false)

                    // assegno lo smistamento ed eventualmente creo altri smistamenti
                    // da testare la modalita di assegnazione
                    protocolloGdmService.assegnaSmistamento(idSmistamentoGdm, springSecurityService.currentUser, DatiSmistamento.MODALITA_ASSEGNAZIONE_AGGIUNGI, destinatariList, now)

                    for (def destinatario : destinatariList) {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.messaggio = "Assegnato a " + destinatario?.utente?.nominativoSoggetto + " in unità " + destinatario?.unita.descrizione
                        esitoSmartDesktop.esitoTasks.add(esitoTask)
                    }
                } catch (ProtocolloRuntimeException e) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.successo = false
                    if (e.cause) {
                        esitoTask.messaggio = e.cause.localizedMessage
                    }
                    esitoTask.messaggio = e.message
                    esitoSmartDesktop.esitoTasks.add(esitoTask)
                    log.error(esitoTask.messaggio)
                }

                Documento profiloGdm = buildDocumentoSmart(idSmistamentoGdm)
                if (profiloGdm.trovaCampo("CODICE_ASSEGNATARIO")?.valore != null && profiloGdm.trovaCampo("CODICE_ASSEGNATARIO")?.valore != "") {
                    jWorklistNotificheDispatcher.elimina(null, idSmistamentoGdm.toString(), null)
                    protocolloGdmService.inviaNotifica(profiloGdm)
                }

                return esitoSmartDesktop
            }

            esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabileDTO)
            try {
                if (datiSmistamento.unitaTrasmissione == null) {
                    throw new ProtocolloRuntimeException("Valorizzare l'unità di trasmissione")
                }

                //CASO DOCUMENTI GESTITI DA AGSPR
                prendiInCaricoEAssegna(smistabileDTO.domainObject, datiSmistamento.unitaTrasmissione.domainObject, springSecurityService.currentUser, datiSmistamento.modalitaAssegnazione, destinatariList, idSmistamentoGdm)

                for (def destinatario : destinatariList) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.messaggio = "Assegnato a " + destinatario?.utente?.nominativoSoggetto + " in unità " + destinatario?.unita.descrizione
                    esitoSmartDesktop.esitoTasks.add(esitoTask)
                }
            } catch (ProtocolloRuntimeException e) {
                if (idSmistamentoGdm) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.successo = false
                    if (e.cause) {
                        esitoTask.messaggio = e.cause.localizedMessage
                    }
                    esitoTask.messaggio = e.message
                    esitoSmartDesktop.esitoTasks.add(esitoTask)

                    log.error(esitoTask.messaggio)
                } else {
                    throw e
                }
            }

            return esitoSmartDesktop
        }

        return esitoSmartDesktop
    }

    /**
     *
     * @param smistabileDTO
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop prendiInCarico(ISmistabileDTO smistabileDTO, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Prendi in Carico"

        IProfiloSmistabile pGdm = null
        pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)
        // Gestione SmartDesktop CASO DOCUMENTI NON GESTITI DA AGSPR
        if (idSmistamentoGdm != null && smistabileDTO == null) {
            Date now = dateService.getCurrentDate()
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()

            try {
                // prendo in carico lo smistamento
                Documento smistamentoSmart = protocolloGdmService.prendiInCaricoSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, true)
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.messaggio = costruisciEsitoPerSmistamentiInCarico(smistamentoSmart) + " preso in carico."
                esitoSmartDesktop.esitoTasks.add(esitoTask)
            } catch (ProtocolloRuntimeException e) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)
                log.error(esitoTask.messaggio)
            }

            return esitoSmartDesktop
        }

        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabileDTO)
        try {

            //CASO DOCUMENTI GESTITI DA AGSPR
            Documento smistamentoSmart = prendiInCaricoSmistamento(Smistamento.findByIdDocumentoEsterno(idSmistamentoGdm), springSecurityService.currentUser)
            EsitoTask esitoTask = new EsitoTask()
            esitoTask.messaggio = costruisciEsitoPerSmistamentiInCarico(smistamentoSmart) + " preso in carico."
            esitoSmartDesktop.esitoTasks.add(esitoTask)
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }

        return esitoSmartDesktop
    }

    private List<EsitoTask> controllaSmistamentiDuplicati(IProfiloSmistabile pGdm, long idSmistamentoGdm, String tipoSmistamento, String unitaTrasmissione, List<Map> destinatariList, String operazione, boolean isAssegnazione = false) {
        List<EsitoTask> esiti = new ArrayList<EsitoTask>()
        String idSmistamento = idSmistamentoGdm.toString()
        Vector<it.finmatica.segreteria.jprotocollo.struttura.Smistamento> smistamentiEsistenti = pGdm.getSmistamenti(false)
        for (it.finmatica.segreteria.jprotocollo.struttura.Smistamento s : smistamentiEsistenti) {
            if (idSmistamento != s.docNumber || isAssegnazione) {
                if (s.statoSmistamento == StatoSmistamentoConverter.newInstance().convert(Smistamento.DA_RICEVERE)
                        || s.statoSmistamento == StatoSmistamentoConverter.newInstance().convert(Smistamento.IN_CARICO)) {
                    if (s.tipoSmistamento == tipoSmistamento) {
                        if (s.ufficioTrasmissione == unitaTrasmissione) {
                            List<Map> destinatariListToClean = new ArrayList<Map>()

                            for (def destinatario : destinatariList) {
                                if (s.ufficioRicevente == destinatario.unita.codice) {
                                    if (destinatario.utente == null && s.assegnatario == null) {
                                        destinatariListToClean.add(destinatario)
                                        esiti.add(new EsitoTask(successo: false, messaggio: "Smistamento già presente" + getDescrizioneOperazione(operazione, destinatario)))
                                    } else if ((destinatario.utente == null && s.assegnatario != null) || ((destinatario.utente != null && s.assegnatario == null) && idSmistamento != s.docNumber)) {
                                        destinatariListToClean.add(destinatario)
                                        esiti.add(new EsitoTask(successo: false, messaggio: "Smistamento già presente" + getDescrizioneOperazione(operazione, destinatario)))
                                    } else if (destinatario.utente?.id == s.assegnatario) {
                                        destinatariListToClean.add(destinatario)
                                        esiti.add(new EsitoTask(successo: false, messaggio: "Smistamento già presente" + getDescrizioneOperazione(operazione, destinatario)))
                                    }
                                }
                            }

                            destinatariList.removeAll(destinatariListToClean)
                        }
                    }
                }
            }
        }
        return esiti
    }

    /**
     *
     * @param smistabileDTO
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop assegna(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamento, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Assegna"
        String operazione = " - Assegnazione in "

        IProfiloSmistabile pGdm = null
        if (idSmistamentoGdm != null) {
            pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)
            Documento pSmistamento = buildDocumentoSmart(idSmistamentoGdm)
            String unitaTrasmissioneSmistamento = pSmistamento.trovaCampo("UFFICIO_TRASMISSIONE")?.valore

            List<EsitoTask> esiti = controllaSmistamentiDuplicati(pGdm, idSmistamentoGdm, datiSmistamento.tipoSmistamento, unitaTrasmissioneSmistamento, datiSmistamento.destinatari, " - Smistamento a ", true)
            esitoSmartDesktop.esitoTasks.addAll(esiti)
        }

        def destinatariList = getDestinatariList(datiSmistamento.destinatari)
        //Continuo solo se ho dei destinatari a cui assegnare
        if (destinatariList?.size() > 0) {
            // Gestione SmartDesktop
            if (idSmistamentoGdm != null && smistabileDTO == null) {
                esitoSmartDesktop.descrizione = pGdm.getDescrizione()
                Date now = dateService.getCurrentDate()

                // assegno lo smistamento ed eventualmente creo altri smistamenti
                // da testare la modalita di assegnazione
                try {
                    protocolloGdmService.assegnaSmistamento(idSmistamentoGdm, springSecurityService.currentUser, DatiSmistamento.MODALITA_ASSEGNAZIONE_AGGIUNGI, destinatariList, now)
                    for (def destinatario : destinatariList) {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.messaggio = getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)
                    }
                } catch (ProtocolloRuntimeException e) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.successo = false
                    if (e.cause) {
                        esitoTask.messaggio = e.cause.localizedMessage
                    }
                    esitoTask.messaggio = e.message
                    esitoSmartDesktop.esitoTasks.add(esitoTask)

                    log.error(esitoTask.messaggio)
                }
                return esitoSmartDesktop
            }

            esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabileDTO)
            try {
                assegna(smistabileDTO.domainObject, datiSmistamento.tipoSmistamento, datiSmistamento.unitaTrasmissione.domainObject, datiSmistamento.utenteTrasmissione.domainObject, datiSmistamento.modalitaAssegnazione, destinatariList, idSmistamentoGdm)

                for (def destinatario : destinatariList) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.messaggio = "Assegnato a " + destinatario.utente.nominativoSoggetto + " in unità " + destinatario.unita.descrizione
                    esitoSmartDesktop.esitoTasks.add(esitoTask)
                }
            } catch (ProtocolloRuntimeException e) {
                if (idSmistamentoGdm) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.successo = false
                    if (e.cause) {
                        esitoTask.messaggio = e.cause.localizedMessage
                    }
                    esitoTask.messaggio = e.message
                    esitoSmartDesktop.esitoTasks.add(esitoTask)

                    log.error(esitoTask.messaggio)
                } else {
                    throw e
                }
            }
        }
        return esitoSmartDesktop
    }

    /**
     *
     * @param smistabileDTO
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop inoltra(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamento, Long idSmistamentoGdm = null) {
        ISmistabile smistabile = smistabileDTO?.domainObject
        return inoltra(smistabile, datiSmistamento.tipoSmistamento, springSecurityService.currentUser, datiSmistamento.unitaTrasmissione.domainObject, datiSmistamento.utenteTrasmissione.domainObject, getDestinatariList(datiSmistamento.destinatari), idSmistamentoGdm)
    }

    /**
     *
     * @param smistabileDTO
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop smista(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamento, Long idSmistamentoGdm = null) {
        return inoltraSmistamento(smistabileDTO?.domainObject, datiSmistamento?.tipoSmistamento, dateService.getCurrentDate(), datiSmistamento.unitaTrasmissione.domainObject, datiSmistamento.utenteTrasmissione.domainObject, getDestinatariList(datiSmistamento.destinatari), idSmistamentoGdm)
    }

    /**
     *
     * @param smistabileDTO
     * @param datiSmistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop smistaEdEsegui(ISmistabileDTO smistabileDTO, DatiSmistamento datiSmistamento, Long idSmistamentoGdm = null) {
        return smistaEdEsegui(smistabileDTO?.domainObject, datiSmistamento.tipoSmistamento, datiSmistamento.unitaTrasmissione.domainObject, datiSmistamento.utenteTrasmissione.domainObject, getDestinatariList(datiSmistamento.destinatari), idSmistamentoGdm)
    }

    /*
     * Operazioni combinate sul protocollo
     */

    /**
     * Smista ed esegue il protocollo:
     * - lo smistamento su cui si ha competenza viene messo come ESEGUITO
     * - viene creato un nuovo smistamento per ogni destinatario selezionato
     *
     * @param protocollo il protocollo
     * @param tipoSmistamento il tipo di smistamento da creare
     * @param unitaTrasmissione l'unità di trasmissione per i nuovi smistamenti
     * @param utenteTrasmissione l'utente di trasmissione per i nuovi smistamenti
     * @param destinatari i destinatari a cui inviare lo smistamento.
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     */
    EsitoSmartDesktop smistaEdEsegui(ISmistabile smistabile, String tipoSmistamento, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteTrasmissione, List<Map> destinatari, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Smista ed esegui"
        String operazione = " - Smistamento a "

        IProfiloSmistabile pGdm = null
        if (idSmistamentoGdm != null) {
            pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)

            List<EsitoTask> esiti = controllaSmistamentiDuplicati(pGdm, idSmistamentoGdm, tipoSmistamento, unitaTrasmissione.codice, destinatari, " - Smistamento a ")
            esitoSmartDesktop.esitoTasks.addAll(esiti)
        }

        // Gestione SmartDesktop
        if (idSmistamentoGdm != null && smistabile == null) {
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()
            Date now = dateService.getCurrentDate()

            try {
                protocolloGdmService.eseguiSmistamento(idSmistamentoGdm, springSecurityService.currentUser, now, true)

                for (def destinatario : getDestinatariList(datiSmistamento.destinatari)) {
                    try {
                        boolean smistamentoConsentito = protocolloGdmService.inoltraSmistamento(idSmistamentoGdm, now, unitaTrasmissione, utenteTrasmissione, destinatario.unita, destinatario.utente, destinatario.note)
                        if (smistamentoConsentito) {
                            EsitoTask esitoTask = new EsitoTask()
                            esitoTask.messaggio = getDescrizioneOperazione(operazione, destinatario)
                            esitoSmartDesktop.esitoTasks.add(esitoTask)
                        } else {
                            EsitoTask esitoTask = new EsitoTask()
                            esitoTask.successo = false
                            esitoTask.messaggio = "Impossibile Smistare per competenza"
                            esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                            esitoSmartDesktop.esitoTasks.add(esitoTask)
                        }
                    } catch (ProtocolloRuntimeException e) {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.successo = false
                        if (e.cause) {
                            esitoTask.messaggio = e.cause.localizedMessage
                        }
                        esitoTask.messaggio = e.message
                        esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)

                        log.error(esitoTask.messaggio)
                    }
                }
            } catch (ProtocolloRuntimeException e) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            }

            notificheService.eliminaNotifica(null, idSmistamentoGdm.toString(), null)
            return esitoSmartDesktop
        }

        List<Long> idsSmistamenti = new ArrayList<Long>()
        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabile)
        try {
            controllaFascicoloObbligatorio(smistabile)

            List<Smistamento> smistamentiDaEseguire = getSmistamentiInCarico(smistabile, utenteTrasmissione)
            Date dataSmistamento = dateService.getCurrentDate()

            for (Smistamento smistamento : smistamentiDaEseguire) {
                if (idSmistamentoGdm == null || smistamento.idDocumentoEsterno == idSmistamentoGdm) {
                    eseguiSmistamento(smistamento, utenteTrasmissione, dataSmistamento, false)
                    idsSmistamenti.add(smistamento.idDocumentoEsterno)
                }
            }

            esitoSmartDesktop = inoltraSmistamento(smistabile, tipoSmistamento, dataSmistamento, unitaTrasmissione, utenteTrasmissione, destinatari, idSmistamentoGdm)
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }

        for (Long idSmistamento : idsSmistamenti) {
            notificheService.eliminaNotifica(null, idSmistamento.toString(), null)
        }

        return esitoSmartDesktop
    }

    /**
     * Prende in carico gli smistamenti del protocollo e inoltra un nuovo smistamento.
     *
     * @param smistabile
     * @param unitaTrasmissione
     * @param destinatari è una lista di mappe nella forma: [unita:So4UnitaPubb, utente:Ad4Utente, note:String]
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     */
    void prendiInCaricoEInoltra(ISmistabile smistabile, String tipoSmistamento, Ad4Utente utentePresaInCarico, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteTrasmissione, destinatari, Long idSmistamentoGdm = null) {
        controllaFascicoloObbligatorio(smistabile)

        Date dataPresaInCarico = dateService.getCurrentDate()

        // prendo in carico gli smistamenti che posso
        List<Smistamento> smistamentiDaPrendereInCarico = getSmistamentiDaPrendereInCarico(smistabile, utentePresaInCarico)
        for (Smistamento smistamento : smistamentiDaPrendereInCarico) {
            if (idSmistamentoGdm == null || smistamento.idDocumentoEsterno == idSmistamentoGdm) {
                prendiInCaricoSmistamento(smistamento, utentePresaInCarico, dataPresaInCarico, false)
                if (smistamento.unitaSmistamento.progr == unitaTrasmissione.progr) {
                    storicizzaSmistamento(smistamento)
                }
            }
        }

        inoltraSmistamento(smistabile, tipoSmistamento, dataPresaInCarico, unitaTrasmissione, utenteTrasmissione, destinatari)
    }

    /**
     * Prende in carico gli smistamenti del protocollo e inoltra un nuovo smistamento.
     *
     * @param smistabile
     * @param unitaTrasmissione
     * @param destinatari è una lista di mappe nella forma: [unita:So4UnitaPubb, utente:Ad4Utente, note:String]
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)*
     */
    void prendiInCaricoSmistaEdEsegui(ISmistabile smistabile, String tipoSmistamento, Ad4Utente utentePresaInCarico, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteTrasmissione, List<Map> destinatari, Long idSmistamentoGdm = null) {
        controllaFascicoloObbligatorio(smistabile)

        Date dataPresaInCarico = dateService.getCurrentDate()

        List<Long> idS = new ArrayList<Long>()

        // prendo in carico gli smistamenti che posso
        List<Smistamento> smistamentiDaPrendereInCarico = getSmistamentiDaPrendereInCarico(smistabile, utentePresaInCarico)
        for (Smistamento smistamento : smistamentiDaPrendereInCarico) {
            if (idSmistamentoGdm == null || smistamento.idDocumentoEsterno == idSmistamentoGdm) {
                prendiInCaricoSmistamento(smistamento, utentePresaInCarico, dataPresaInCarico, false)
                eseguiSmistamento(smistamento, utentePresaInCarico, dataPresaInCarico, false)
                idS.add(smistamento.idDocumentoEsterno)
            }
        }

        // per ogni destinatario, creo il relativo smistamento:
        inoltraSmistamento(smistabile, tipoSmistamento, dataPresaInCarico, unitaTrasmissione, utenteTrasmissione, destinatari)

        for (Long id : idS) {
            notificheService.eliminaNotifica(null, id.toString(), null)
        }
    }

    /**
     * Prende in carico gli smistamenti del protocollo e li assegna all'utente richiesto
     *
     * @param smistabile
     * @param unitaTrasmissione
     * @param destinatari è una lista di mappe nella forma: [unita:So4UnitaPubb, utente:Ad4Utente, note:String]
     * @param idSmistamentoGdm è not null se arrivo da SmartDesktop, in tal caso devo gestire solo quello smistamento
     */
    void prendiInCaricoEAssegna(ISmistabile smistabile, So4UnitaPubb unitaTrasmissione, Ad4Utente utentePresaInCarico, String modalitaAssegnazione, List<Map> destinatari, Long idSmistamentoGdm = null) {
        Date dataPresaInCarico = dateService.getCurrentDate()

        // prendo in carico gli smistamenti che posso
        List<Smistamento> smistamentiDaPrendereInCarico = getSmistamentiDaPrendereInCarico(smistabile, utentePresaInCarico)
        for (Smistamento smistamento : smistamentiDaPrendereInCarico) {
            if (idSmistamentoGdm == null || smistamento.idDocumentoEsterno == idSmistamentoGdm) {

                // prendo in carico lo smistamento
                prendiInCaricoSmistamento(smistamento, utentePresaInCarico, dataPresaInCarico, false)

                if (modalitaAssegnazione == DatiSmistamento.MODALITA_ASSEGNAZIONE_SOSTITUISCI) {

                    Smistamento copia = duplicaSmistamento(smistabile, smistamento)
                    storicizzaSmistamento(smistamento)
                    assegnaSmistamento(copia, utentePresaInCarico, modalitaAssegnazione, destinatari, dataPresaInCarico)
                } else {
                    // assegno lo smistamento ed eventualmente creo altri smistamenti
                    assegnaSmistamento(smistamento, utentePresaInCarico, modalitaAssegnazione, destinatari, dataPresaInCarico)
                }
            }
        }

        if (modalitaAssegnazione == DatiSmistamento.MODALITA_ASSEGNAZIONE_AGGIUNGI) {
            for (Smistamento smistamento : smistamentiDaPrendereInCarico) {
                if (smistamento.utenteAssegnatario != null) {
                    notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), null)
                    inviaNotifica(smistamento)
                }
            }
        }
    }

    /*
    * Funzioni di base che agiscono sul protocollo
    * - creazione
    * - invia
    * - duplica
    * - prendi in carico
    * - rifiuta
    * - esegui
    * - assegna
    * - storicizza
    * - elimina
    */

    /**
     * Invia gli smistamenti: imposta gli smistamenti CREATI come DA_RICEVERE
     *
     * @param smistabile il protocollo di cui inviare gli smistamenti
     */
    void inviaSmistamenti(ISmistabile smistabile, escludiControlloCompetenze = false) {
        So4UnitaPubb unitaProtocollante = smistabile?.getUnita()
        So4UnitaPubb unitaSmistamentoTmp = null

        for (Smistamento smistamento : smistabile.smistamentiValidi) {
            if (unitaProtocollante.codice != smistamento.unitaTrasmissione?.codice) {
                smistamento.unitaTrasmissione = unitaProtocollante
            }
            if (smistamento.utenteAssegnante == null) {
                if (unitaSmistamentoTmp?.codice == smistamento.unitaSmistamento?.codice) {
                    throw new ProtocolloRuntimeException("Non è possibile creare più smistamenti alla stessa unità:" + unitaSmistamentoTmp.descrizione)
                }
                unitaSmistamentoTmp = smistamento.unitaSmistamento
            }
            creaSmistamentoInProtocollazione(smistamento, smistabile.data, escludiControlloCompetenze)
        }
    }

    /**
     * Prende in carico gli smistamenti del protocollo su cui l'utente passato ha i diritti.
     *
     * @param smistabile il protocollo
     * @param utentePresaInCarico l'utente che prende in carico
     */
    void prendiInCarico(ISmistabile smistabile, Ad4Utente utentePresaInCarico, List<Smistamento> smistamentiSelezionati = null) {

        List<Smistamento> smistamentiDaPrendereInCarico = new ArrayList<Smistamento>()
        if (smistamentiSelezionati?.size() > 0) {
            smistamentiDaPrendereInCarico = smistamentiSelezionati
        } else {
            smistamentiDaPrendereInCarico = getSmistamentiDaPrendereInCarico(smistabile, utentePresaInCarico)
        }

        Date dataPresaInCarico = dateService.getCurrentDate()

        for (Smistamento smistamento : smistamentiDaPrendereInCarico) {
            prendiInCaricoSmistamento(smistamento, utentePresaInCarico, dataPresaInCarico)
        }
    }

    /**
     * Rifiuta gli smistamenti che l'utente passato può prendere in carico.
     *
     * @param smistabile il protocollo
     * @param utenteRifiuto l'utente che rifiuta lo smistamento
     * @param motivazione la motivazione del rifiuto
     */
    void rifiuta(ISmistabile smistabile, Ad4Utente utenteRifiuto, String motivazione) {
        List<Smistamento> smistamentiDaRifiutare = getSmistamentiDaPrendereInCarico(smistabile, utenteRifiuto)

        if (smistamentiDaRifiutare.size() == 0) {
            throw new ProtocolloRuntimeException("Non esistono smistamenti gestibili dall'utente")
        }

        Date dataRifiuto = dateService.getCurrentDate()
        for (Smistamento smistamento : smistamentiDaRifiutare) {
            rifiutaSmistamento(smistamento, utenteRifiuto, motivazione, dataRifiuto)
        }
    }

    /**
     * Prende in carico ed esegue il protocollo.
     *
     * @param documentoDTO
     */
    void prendiInCaricoEdEsegui(ISmistabile documento, Ad4Utente utentePresaInCarico, List<Smistamento> smistamentiSelezionati = null) {

        controllaFascicoloObbligatorio(documento)

        List<Smistamento> smistamentiDaPrendereInCarico = new ArrayList<Smistamento>()
        if (smistamentiSelezionati?.size() > 0) {
            smistamentiDaPrendereInCarico = smistamentiSelezionati
        } else {
            smistamentiDaPrendereInCarico = getSmistamentiDaPrendereInCarico(documento, utentePresaInCarico)
        }

        Date data = dateService.getCurrentDate()
        for (Smistamento smistamento : smistamentiDaPrendereInCarico) {
            prendiInCaricoSmistamento(smistamento, utentePresaInCarico, data, false)
            eseguiSmistamento(smistamento, utentePresaInCarico, data)
        }
    }

    /**
     * Prende in carico ed esegue lo smistamento singolo
     *
     * @param documentoDTO
     */
    Documento prendiInCaricoEdEsegui(ISmistabile documento, Ad4Utente utentePresaInCarico, Smistamento smistamento) {

        controllaFascicoloObbligatorio(documento)
        prendiInCaricoSmistamento(smistamento, utentePresaInCarico, dateService.currentDate, false)
        return eseguiSmistamento(smistamento, utentePresaInCarico)
    }

    /**
     * esegui lo smistamento singolo
     *
     * @param documentoDTO
     */
    Documento esegui(ISmistabile documento, Ad4Utente utentePresaInCarico, Smistamento smistamento) {
        controllaFascicoloObbligatorio(documento)
        return eseguiSmistamento(smistamento, utentePresaInCarico)
    }

    /**
     * Assegna un protocollo
     *
     * @param smistabile il protocollo da assegnare
     * @param tipoSmistamento il tipo di smistamento da creare
     * @param utenteAssegnante l'utente che assegna lo smistamento
     * @param destinatari i destinatari a cui inviare lo smistamento
     */
    void assegna(ISmistabile smistabile, String tipoSmistamento, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteAssegnante, String modalitaAssegnazione, List<Map> destinatari, Long idSmistamentoGdm = null) {
        List<Smistamento> smistamentiDaAssegnare = getSmistamentiInCarico(smistabile, utenteAssegnante)
        Date dataAssegnazione = dateService.getCurrentDate()

        boolean assegnato = false

        if (DatiSmistamento.MODALITA_ASSEGNAZIONE_AGGIUNGI) {
            assegnaSmistamento(smistamentiDaAssegnare.last(), utenteAssegnante, modalitaAssegnazione, destinatari, dataAssegnazione)
        } else {
            for (Smistamento smistamento : smistamentiDaAssegnare) {
                if (idSmistamentoGdm == null || idSmistamentoGdm == smistamento.idDocumentoEsterno) {

                    // assegno lo smistamento
                    if (smistamento.unitaSmistamento.progr == unitaTrasmissione.progr) {
                        if (modalitaAssegnazione == DatiSmistamento.MODALITA_ASSEGNAZIONE_SOSTITUISCI) {

                            Smistamento copia = duplicaSmistamento(smistabile, smistamento)

                            storicizzaSmistamento(smistamento)

                            if (!assegnato) {
                                assegnaSmistamento(copia, utenteAssegnante, modalitaAssegnazione, destinatari, dataAssegnazione)
                            }
                            assegnato = true
                        } else {
                            assegnaSmistamento(smistamento, utenteAssegnante, modalitaAssegnazione, destinatari, dataAssegnazione)
                        }
                    }
                }
            }
        }
    }

    /**
     *
     * @param smistabile
     * @param tipoSmistamento
     * @param utentePresaInCarico
     * @param unitaTrasmissione
     * @param utenteTrasmissione
     * @param destinatari
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     * @return
     */
    EsitoSmartDesktop inoltra(ISmistabile smistabile, String tipoSmistamento, Ad4Utente utentePresaInCarico, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteTrasmissione, List<Map> destinatari, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Inoltra"
        String operazione = " - Inoltrato a "

        IProfiloSmistabile pGdm = null
        if (idSmistamentoGdm != null) {
            pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)

            List<EsitoTask> esiti = controllaSmistamentiDuplicati(pGdm, idSmistamentoGdm, tipoSmistamento, unitaTrasmissione?.codice, destinatari, " - Smistamento a ")
            esitoSmartDesktop.esitoTasks.addAll(esiti)
        }

        // Gestione SmartDesktop
        if (idSmistamentoGdm != null && smistabile == null) {
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()
            Date now = dateService.getCurrentDate()
            try {
                if (destinatari.size() > 0) {
                    protocolloGdmService.storicizzaSmistamento(idSmistamentoGdm, false)

                    for (def destinatario : destinatari) {
                        try {
                            boolean smistamentoConsentito = protocolloGdmService.inoltraSmistamento(idSmistamentoGdm, now, unitaTrasmissione, utenteTrasmissione, destinatario.unita, destinatario.utente, destinatario.note, tipoSmistamento)
                            if (smistamentoConsentito) {
                                jWorklistNotificheDispatcher.elimina(null, idSmistamentoGdm.toString(), null)
                                EsitoTask esitoTask = new EsitoTask()
                                esitoTask.messaggio = getDescrizioneOperazione(operazione, destinatario)
                                esitoSmartDesktop.esitoTasks.add(esitoTask)
                            } else {
                                EsitoTask esitoTask = new EsitoTask()
                                esitoTask.successo = false
                                esitoTask.messaggio = "Impossibile Smistare per competenza"
                                esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                                esitoSmartDesktop.esitoTasks.add(esitoTask)
                            }
                        } catch (ProtocolloRuntimeException e) {
                            EsitoTask esitoTask = new EsitoTask()
                            if (e.cause) {
                                esitoTask.messaggio = e.cause.localizedMessage
                            }
                            esitoTask.messaggio = e.message
                            esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                            esitoTask.successo = false
                            esitoSmartDesktop.esitoTasks.add(esitoTask)

                            log.error(esitoTask.messaggio)
                        }
                    }
                }
            } catch (ProtocolloRuntimeException e) {
                EsitoTask esitoTask = new EsitoTask()
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoTask.successo = false
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            }
            return esitoSmartDesktop
        }

        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabile)

        try {
            controllaFascicoloObbligatorio(smistabile)

            List<Smistamento> smistamentiDaInoltrare = getSmistamentiInCaricoEdEseguiti(smistabile, utentePresaInCarico)
            Date dataAssegnazione = dateService.getCurrentDate()
            String tipoSmistamentoInoltro = Smistamento.CONOSCENZA

            for (Smistamento smistamento : smistamentiDaInoltrare) {
                if (idSmistamentoGdm == null || smistamento.idDocumentoEsterno == idSmistamentoGdm) {
                    if (idSmistamentoGdm == null && smistamento.tipoSmistamento == Smistamento.COMPETENZA && smistamento.unitaSmistamento.progr == unitaTrasmissione.progr) {
                        tipoSmistamentoInoltro = Smistamento.COMPETENZA
                    }
                    if (idSmistamentoGdm) {
                        tipoSmistamentoInoltro = tipoSmistamento
                    }
                    if (smistamento.unitaSmistamento.progr == unitaTrasmissione.progr) {
                        storicizzaSmistamento(smistamento)
                    }
                }
            }

            esitoSmartDesktop = inoltraSmistamento(smistabile, tipoSmistamentoInoltro, dataAssegnazione, unitaTrasmissione, utenteTrasmissione, destinatari, idSmistamentoGdm)
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoTask.successo = false
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }

        return esitoSmartDesktop
    }

    /**
     * Inoltra un protocollo creando gli smistamenti richiesti.
     *
     * @param smistabile il protocollo da inoltrare
     * @param tipoSmistamento il tipo di smistamenti da creare
     * @param dataInoltro la data di inoltro
     * @param unitaTrasmissione l'unità di trasmissione
     * @param utenteTrasmissione l'utente di trasmissione
     * @param destinatari i destinatari a cui inviare lo smistamento
     * @param idSmistamentoGdm Se non nullo, gestione da multiselezione (si gestisce solo quello smistamento).
     *                          Se nullo gestione da documento singolo (si gestiscono tutti gli smistamenti del documento)
     */
    EsitoSmartDesktop inoltraSmistamento(ISmistabile smistabile, String tipoSmistamento, Date dataInoltro, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteTrasmissione, List<Map> destinatari, Long idSmistamentoGdm = null) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.richiesta = "Smista"
        String operazione = " - Smistamento a "

        IProfiloSmistabile pGdm = null
        if (idSmistamentoGdm != null) {
            pGdm = protocolloGdmService.istanziaSmistabileGdmDaSmistamento(idSmistamentoGdm)

            List<EsitoTask> esiti = controllaSmistamentiDuplicati(pGdm, idSmistamentoGdm, tipoSmistamento, unitaTrasmissione?.codice, destinatari, " - Smistamento a ")
            esitoSmartDesktop.esitoTasks.addAll(esiti)
        }

        // Gestione SmartDesktop
        if (idSmistamentoGdm != null && smistabile == null) {
            esitoSmartDesktop.descrizione = pGdm.getDescrizione()
            for (def destinatario : destinatari) {

                try {
                    boolean smistamentoConsentito = protocolloGdmService.inoltraSmistamento(idSmistamentoGdm, dataInoltro, unitaTrasmissione, utenteTrasmissione, destinatario.unita, destinatario.utente, destinatario.note, tipoSmistamento)
                    if (smistamentoConsentito) {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.messaggio = getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)
                    } else {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.successo = false
                        esitoTask.messaggio = "Impossibile Smistare per competenza"
                        esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)
                    }
                } catch (ProtocolloRuntimeException e) {
                    EsitoTask esitoTask = new EsitoTask()
                    esitoTask.successo = false
                    if (e.cause) {
                        esitoTask.messaggio = e.cause.localizedMessage
                    }
                    esitoTask.messaggio = e.message
                    esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                    log.error(esitoTask.messaggio)
                    esitoSmartDesktop.esitoTasks.add(esitoTask)
                }
            }

            return esitoSmartDesktop
        }

        esitoSmartDesktop.descrizione = getDescrizioneProtocollo(smistabile)
        try {
            controllaFascicoloObbligatorio(smistabile)

            // per ogni destinatario, creo il relativo smistamento:
            for (def destinatario : destinatari) {
                try {

                    boolean smistamentoConsentito = true
                    if (idSmistamentoGdm != null) {
                        smistamentoConsentito = verificaSePossibileSmistare(idSmistamentoGdm, tipoSmistamento)
                    }

                    if (smistamentoConsentito) {
                        Smistamento s = creaSmistamento(smistabile, tipoSmistamento, unitaTrasmissione, utenteTrasmissione, destinatario.unita, destinatario.utente, destinatario.note)
                        creaSmistamento(s, dataInoltro)
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.messaggio = getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)
                    } else {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.successo = false
                        esitoTask.messaggio = "Impossibile Smistare per competenza"
                        esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)
                    }
                } catch (ProtocolloRuntimeException e) {
                    if (idSmistamentoGdm) {
                        EsitoTask esitoTask = new EsitoTask()
                        esitoTask.successo = false
                        if (e.cause) {
                            esitoTask.messaggio = e.cause.localizedMessage
                        }
                        esitoTask.messaggio = e.message
                        esitoTask.messaggio += getDescrizioneOperazione(operazione, destinatario)
                        esitoSmartDesktop.esitoTasks.add(esitoTask)

                        log.error(esitoTask.messaggio)
                    } else {
                        throw e
                    }
                }
            }
        } catch (ProtocolloRuntimeException e) {
            if (idSmistamentoGdm) {
                EsitoTask esitoTask = new EsitoTask()
                esitoTask.successo = false
                if (e.cause) {
                    esitoTask.messaggio = e.cause.localizedMessage
                }
                esitoTask.messaggio = e.message
                esitoSmartDesktop.esitoTasks.add(esitoTask)

                log.error(esitoTask.messaggio)
            } else {
                throw e
            }
        }
        return esitoSmartDesktop
    }

    private String getDescrizioneOperazione(String operazione, destinatario) {
        String messaggio = operazione + destinatario.unita?.descrizione
        if (destinatario.utente) {
            messaggio += " - assegnatario: " + destinatario.utente?.nominativoSoggetto
        }
        return messaggio
    }

    private boolean verificaSePossibileSmistare(Long idSmistamentoGdm, String tipoSmistamento) {

        if (tipoSmistamento == Smistamento.CONOSCENZA) {
            return true
        }

        // COMPETENZA
        Smistamento smistamentoPrecedente = Smistamento.findByIdDocumentoEsterno(idSmistamentoGdm)
        if (smistamentoPrecedente.statoSmistamento == Smistamento.DA_RICEVERE) {
            return false
        }
        if (smistamentoPrecedente.statoSmistamento == Smistamento.DA_RICEVERE && smistamentoPrecedente.tipoSmistamento == Smistamento.CONOSCENZA) {
            return false
        }
        return true
    }

    /**
     * Esegue gli smistamenti in carico all'utente richiesto
     *
     * @param smistabile il protocollo da eseguire
     * @param utenteEsecuzione l'utente di esecuzione
     */
    void eseguiSmistamenti(ISmistabile smistabile, Ad4Utente utenteEsecuzione, Date dataEsecuzione = dateService.getCurrentDate(), List<Smistamento> smistamentiSelezionati = null) {
        controllaFascicoloObbligatorio(smistabile)

        List<Smistamento> smistamenti = new ArrayList<Smistamento>()
        if (smistamentiSelezionati?.size() > 0) {
            smistamenti = smistamentiSelezionati
        } else {
            smistamenti = getSmistamentiInCarico(smistabile, utenteEsecuzione)
        }

        for (Smistamento smistamento : smistamenti) {
            eseguiSmistamento(smistamento, utenteEsecuzione, dataEsecuzione)
        }
    }

    /*
     * Funzioni di base sul singolo smistamento:
     * - creazione
     * - invia
     * - duplica
     * - prendi in carico
     * - rifiuta
     * - esegui
     * - assegna
     * - storicizza
     * - elimina
     */

    /**
     * Crea un nuovo smistamento.
     * Se è presente l'utente assegnatario,
     *
     * @param smistabile il protocollo a cui aggiungere lo smistamento
     * @param tipoSmistamento il tipo di smistamento "CONOSCENZA / COMPETENZA"
     * @param unitaTrasmissione unità che crea lo smistamento
     * @param utenteTrasmissione utente che crea lo smistamento
     * @param unitaSmistamento unità a cui viene smistato
     * @param utenteAssegnatario utente a cui viene assegnato lo smistamento.
     */
    Smistamento creaSmistamento(ISmistabile smistabile, String tipoSmistamento, So4UnitaPubb unitaTrasmissione, Ad4Utente utenteTrasmissione, So4UnitaPubb unitaSmistamento, Ad4Utente utenteAssegnatario = null, String noteSmistamento = null) {
        Smistamento smistamento = new Smistamento(tipoSmistamento: tipoSmistamento, unitaTrasmissione: unitaTrasmissione, utenteTrasmissione: utenteTrasmissione, unitaSmistamento: unitaSmistamento)
        smistamento.statoSmistamento = Smistamento.CREATO
        smistamento.dataSmistamento = dateService.getCurrentDate()
        smistamento.note = noteSmistamento

        if (utenteAssegnatario != null) {
            smistamento.utenteAssegnante = utenteTrasmissione
            smistamento.utenteAssegnatario = utenteAssegnatario
            smistamento.dataAssegnazione = smistamento.dataSmistamento
        }

        smistabile.addToSmistamenti(smistamento)
        smistamento.save()
        smistabile.save()

        // allineo su GDM
        protocolloGdmService.salvaSmistamento(smistamento)

        return smistamento
    }

    /**
     * Crea un nuovo smistamento per tipo documento
     *
     * @param schemaProtocollo lo schema protocollo a cui aggiungere lo smistamento
     */
    SchemaProtocolloSmistamento creaSmistamento(SchemaProtocollo schemaProtocollo, String tipoSmistamento, So4UnitaPubb unitaTrasmissione, So4UnitaPubb unitaSmistamento, String email, boolean fascicoloObbligatorio, Integer sequenza) {
        SchemaProtocolloSmistamento sc = SchemaProtocolloSmistamento.findBySequenzaAndSchemaProtocolloAndTipoSmistamento(sequenza, schemaProtocollo, Smistamento.COMPETENZA)
        if (schemaProtocollo.isSequenza() && sc != null && tipoSmistamento == Smistamento.COMPETENZA) {
            throw new ProtocolloRuntimeException("Il numero di sequenza è già stata inserito")
        }

        SchemaProtocolloSmistamento smistamento = new SchemaProtocolloSmistamento(schemaProtocollo: schemaProtocollo,
                tipoSmistamento: tipoSmistamento,
                unitaSo4Smistamento: unitaSmistamento,
                email: email,
                fascicoloObbligatorio: fascicoloObbligatorio,
                sequenza: sequenza)

        smistamento.id = 0
        return smistamento.save()
    }

    /**
     * Duplica uno smistamento esistente
     *
     * @param smistabile il protocollo a cui aggiungere il nuovo smistamento
     * @param smistamento lo smistamento da duplicare
     * @return lo smistamento creato
     */
    Smistamento duplicaSmistamento(ISmistabile smistabile, Smistamento smistamento) {
        Smistamento duplica = new Smistamento()

        duplica.tipoSmistamento = smistamento.tipoSmistamento
        duplica.dataAssegnazione = smistamento.dataAssegnazione
        duplica.dataEsecuzione = smistamento.dataEsecuzione
        duplica.dataPresaInCarico = smistamento.dataPresaInCarico
        duplica.dataSmistamento = smistamento.dataSmistamento
        duplica.dataRifiuto = smistamento.dataRifiuto
        duplica.note = smistamento.note
        duplica.noteUtente = smistamento.noteUtente
        duplica.motivoRifiuto = smistamento.motivoRifiuto
        duplica.statoSmistamento = smistamento.statoSmistamento
        duplica.tipoSmistamento = smistamento.tipoSmistamento
        duplica.utenteAssegnatario = smistamento.utenteAssegnatario
        duplica.utenteAssegnante = smistamento.utenteAssegnante
        duplica.utenteEsecuzione = smistamento.utenteEsecuzione
        duplica.utentePresaInCarico = smistamento.utentePresaInCarico
        duplica.utenteTrasmissione = smistamento.utenteTrasmissione
        duplica.utenteRifiuto = smistamento.utenteRifiuto
        duplica.unitaSmistamento = smistamento.unitaSmistamento
        duplica.unitaTrasmissione = smistamento.unitaTrasmissione

        smistabile.addToSmistamenti(duplica)
        duplica.save()
        smistabile.save()

        return duplica
    }

    /**
     * Invia uno smistamento e lo mette in stato DA_RICEVERE.
     * Invia la notifica DA_RICEVERE se lo smistamento è solo per unità
     * Invia la notifica ASSEGNAZIONE se lo smistamento è assegnato ad un utente
     *
     * @param smistamento
     * @param dataSmistamento
     */
    void creaSmistamento(Smistamento smistamento, Date dataSmistamento = dateService.getCurrentDate(), boolean escludiControlloCompetenze = false) {
        smistamento.statoSmistamento = Smistamento.DA_RICEVERE
        smistamento.dataSmistamento = dataSmistamento
        smistamento.save()

        // allineo su gdm
        protocolloGdmService.salvaSmistamento(smistamento, escludiControlloCompetenze)

        // elimino tutte le notifiche esistenti di questo smistamento
        if (smistamento.idDocumentoEsterno) {
            notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), null)
        }

        // invio la relativa notifica
        inviaNotifica(smistamento)
    }

    /**
     * Invia uno smistamento e lo mette in stato DA_RICEVERE; Se la  UO protocollante è la stessa dello smistamento
     * lo stato deve essere direttamente "IN_CARICO" alla stessa data/ora della protocollazione
     * Invia la notifica DA_RICEVERE se lo smistamento è solo per unità
     * Invia la notifica ASSEGNAZIONE se lo smistamento è assegnato ad un utente
     *
     * @param smistamento
     * @param dataSmistamento
     */
    void creaSmistamentoInProtocollazione(Smistamento smistamento, Date dataSmistamento = dateService.getCurrentDate(), boolean escludiControlloCompetenze = false) {
        So4UnitaPubb unitaProtocollante = smistamento.documento?.getUnita()
        smistamento.dataSmistamento = dataSmistamento
        if (smistamento.unitaSmistamento?.codice == unitaProtocollante?.codice) {

            prendiInCaricoSmistamento(smistamento, springSecurityService.currentUser, dataSmistamento, true, escludiControlloCompetenze)
            String sNota = "Smistamento preso in carico automaticamente in fase di protocollazione."
            if (smistamento.statoSmistamento == Smistamento.ESEGUITO) {
                sNota = "Smistamento preso in carico ed eseguito automaticamente in fase di protocollazione."
            }
            if (smistamento.note == null || smistamento.note == "") {
                smistamento.note = sNota
            } else {
                smistamento.note = smistamento.note + "\n" + sNota
            }
        } else {
            creaSmistamento(smistamento, dataSmistamento, escludiControlloCompetenze)
        }
    }

    /**
     * Prende in carico lo smistamento richiesto.
     * Se lo smistamento è di tipo CONOSCENZA, lo statoSmistamento diventa ESEGUITO, altrimenti diventa IN_CARICO.
     *
     * @param smistamento
     * @param utentePresaInCarico
     * @param dataPresaInCarico
     */
    Documento prendiInCaricoSmistamento(Smistamento smistamento, Ad4Utente utentePresaInCarico, Date dataPresaInCarico = dateService.getCurrentDate(), boolean inviaNotifiche = true, boolean escludiControlloCompetenze = false) {

        // faccio prima l'eliminaNotifica per non perdere l'id dello smistamento originario
        if (inviaNotifiche) {
            notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), null)
        }

        smistamento.statoSmistamento = Smistamento.IN_CARICO
        smistamento.utentePresaInCarico = utentePresaInCarico
        smistamento.dataPresaInCarico = dataPresaInCarico
        smistamento.save()

        // se lo smistamento è per conoscenza e l'utente di presa in carico è lo stesso dell'utente di assegnazione oppure se l'utente di assegnazione è null, allora deve diventare anche ESEGUITO
        // il succo è che non deve diventare subito eseguito quando è assegnato ad un utente diverso da chi prende in carico. Questo
        // serve per poter richiamare questa funzione dalla prendiInCaricoEAssegna
        if (smistamento.tipoSmistamento == Smistamento.CONOSCENZA && (smistamento.utenteAssegnatario == null || smistamento.utenteAssegnatario.id == smistamento.utentePresaInCarico.id)) {
            return eseguiSmistamento(smistamento, utentePresaInCarico, dataPresaInCarico)
        }

        // allineo su gdm
        Documento smistamentoSmart = protocolloGdmService.salvaSmistamento(smistamento, escludiControlloCompetenze)

        if (inviaNotifiche) {

            // invio la notifica di presa in carico
            inviaNotifica(smistamento)
        }

        return smistamentoSmart
    }

    /**
     * Rifiuta lo smistamento.
     * Imposta la motivazione del rifiuto e statoSmistamento = STORICO
     *
     * @param smistamento
     * @param utenteRifiuto
     * @param motivazione
     * @param dataRifiuto
     */
    void rifiutaSmistamento(Smistamento smistamento, Ad4Utente utenteRifiuto, String motivazione, Date dataRifiuto = dateService.getCurrentDate()) {
        if (smistamento.isPerConoscenza()) {
            salvaRifiuto(smistamento, motivazione, dataRifiuto, utenteRifiuto)
            return
        }

        // Questo è lo smistamento (ad esempio è il 3)
        // Se lo schema protocollo ha la sequenza bisogna eliminare (invalidare) lo smistamento con sequenza precedente (es.2) e
        // crearne uno con la sequenza precedente (es.:2)
        SchemaProtocollo sp = smistamento.documento.schemaProtocollo

        if (sp?.isSequenza()) {
            SchemaProtocolloSmistamento smistamentoRifiutato =
                    SchemaProtocolloSmistamento.findBySchemaProtocolloAndUnitaSo4SmistamentoAndTipoSmistamento(sp, smistamento.unitaSmistamento, Smistamento.COMPETENZA)

            SchemaProtocolloSmistamento smistamentoPrecedente = null
            List<SchemaProtocolloSmistamento> smistamentiPrecedente = SchemaProtocolloSmistamento.createCriteria().list {
                eq("schemaProtocollo", sp)
                order("sequenza", "desc")
                isNotNull("unitaSo4Smistamento")
                lt("sequenza", smistamentoRifiutato.sequenza)
            }

            if (smistamentiPrecedente != null && smistamentiPrecedente.size() > 0) {
                smistamentoPrecedente = smistamentiPrecedente.get(0)

                ISmistabile d = smistamento.protocollo
                Smistamento s = Smistamento.findByDocumentoAndUnitaSmistamento(d, smistamentoPrecedente.unitaSo4Smistamento)
                if (s != null) {
                    eliminaSmistamento(d, s)
                }
                smistamento.unitaTrasmissione = smistamento.unitaSmistamento
                smistamento.unitaSmistamento = smistamentoPrecedente.unitaSo4Smistamento
                creaSmistamentoInProtocollazione(smistamento)
            }
        } else {
            salvaRifiuto(smistamento, motivazione, dataRifiuto, utenteRifiuto)
        }
    }

    private void salvaRifiuto(Smistamento smistamento, String motivazione, Date dataRifiuto, Ad4Utente utenteRifiuto) {

        // faccio prima l'eliminaNotifica per non perdere l'id dello smistamento originario
        notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), null)

        smistamento.statoSmistamento = Smistamento.STORICO
        smistamento.motivoRifiuto = motivazione
        smistamento.dataRifiuto = dataRifiuto
        smistamento.utenteRifiuto = utenteRifiuto
        smistamento.save()

        // allineo su gdm
        protocolloGdmService.salvaSmistamento(smistamento)

        // invio la relativa notifica di rifiuto
        String datiRicevente = smistamento.unitaSmistamento?.descrizione +
                " in data " +
                smistamento.dataSmistamento?.format("dd/MM/yyyy HH:mm:ss") + " per " +
                smistamento.tipoSmistamento

        String messaggioTODO = utenteRifiuto.nominativoSoggetto + " in data " + (dataRifiuto?.format("dd/MM/yyyy HH:mm:ss") ?: "") +
                " ha rifiutato il documento smistato da " + (smistamento.unitaTrasmissione?.descrizione ?: "") +
                " a " + datiRicevente + " per il seguente motivo: " + motivazione
        if (smistamento.protocollo.categoriaProtocollo == null) {
            inviaNotifica(smistamento, RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_RIFIUTO_NP, messaggioTODO)
        } else {
            if (!smistamento.protocollo.categoriaProtocollo.isDaNonProtocollare()) {
                inviaNotifica(smistamento, RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_RIFIUTO, messaggioTODO)
            } else {
                inviaNotifica(smistamento, RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_RIFIUTO_NP, messaggioTODO)
            }
        }
    }

    /**
     * Esegue lo smistamento richiesto
     * Imposta utente e data esecuzione, stato smistamento = ESEGUITO
     *
     * @param smistamento
     * @param utenteEsecuzione
     * @param dataEsecuzione
     */
    Documento eseguiSmistamento(Smistamento smistamento, Ad4Utente utenteEsecuzione, Date dataEsecuzione = dateService.getCurrentDate(), boolean cancellaNotifiche = true) {
        controllaFascicoloObbligatorio(smistamento.protocollo)
        Documento smistamentoSmart = null
        if (smistamento.utenteAssegnatario == null || utenteEsecuzione == smistamento.utenteAssegnatario) {
            smistamento.statoSmistamento = Smistamento.ESEGUITO
            smistamento.utenteEsecuzione = utenteEsecuzione
            smistamento.dataEsecuzione = dataEsecuzione
            smistamento.save()

            // allineo su gdm
            smistamentoSmart = protocolloGdmService.salvaSmistamento(smistamento)

            // elimino tutte le notifiche esistenti di questo smistamento per l'utente a cui è stato assegnato lo smistamento.
            // se lo smistamento non è assegnato a nessuno, allora vengono eliminate tutte le notifiche
            if (cancellaNotifiche) {
                notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), smistamento.utenteAssegnatario)
            }
        }
        return smistamentoSmart
    }

    /**
     * Imposta lo smistamento in stato STORICO
     * @param smistamento
     */
    void storicizzaSmistamento(Smistamento smistamento) {
        smistamento.statoSmistamento = Smistamento.STORICO
        smistamento.save()

        // allineo su gdm
        protocolloGdmService.salvaSmistamento(smistamento)

        // elimino qualsiasi notifica per qualsiasi utente per questo smistamento:
        notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), null)
    }

    /**
     * Assegna uno smistamento ed eventualmente ne crea di nuovi in base alla modalità di assegnazione:
     * - se lo smistamento richiesto non ha un assegnatario, verrà assegnato al nuovo destinatario (il primo della lista), indipendentemente dalla modalità di assegnazione scelta
     * - se lo smistamento richiesto ha un assegnatario, se la modalità di assegnazione è "SOSTITUISCI", allora quest'ultimo verrà sostituito, altrimenti verrà creato un nuovo smistamento
     *
     * @param smistamento lo smistamento da assegnare
     * @param unitaTrasmissione l'unità di trasmissione dell'eventuale nuovo smistamento
     * @param utenteAssegnante l'utente che sta assegnando lo smistamento
     * @param modalitaAssegnazione la modalità di assegnazione: SOSTITUISCI o AGGIUNGI. Se null, verrà usato SOSTITUISCI
     * @param destinatari il destinatari dello smistamento (si considerano solo gli utenti)
     * @param dataAssegnazione la data di assegnazione
     */
    void assegnaSmistamento(Smistamento smistamento, Ad4Utente utenteAssegnante, String modalitaAssegnazione, List<Map> destinatari, Date dataAssegnazione = dateService.getCurrentDate(), String idSmistamentoGdm = null) {
        def destinatariSmistamento = destinatari
        if (modalitaAssegnazione == null) {
            modalitaAssegnazione = DatiSmistamento.MODALITA_ASSEGNAZIONE_SOSTITUISCI
        }

        // indipendentemente dalla modalità di assegnazione, se lo smistamento non ha già un assegnatario, viene assegnato
        if (smistamento.utenteAssegnatario == null || modalitaAssegnazione == DatiSmistamento.MODALITA_ASSEGNAZIONE_SOSTITUISCI) {

            // elimino eventuali notifiche per l'utente precedente
            if (smistamento.idDocumentoEsterno != null) {
                notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), smistamento.utenteAssegnatario)
            }

            // prendo il primo destinatario:
            Map destinatario = destinatari[0]
            assegnaSmistamento(smistamento, utenteAssegnante, (Ad4Utente) destinatario.utente, (String) destinatario.note, dataAssegnazione)

            if (smistamento.idDocumentoEsterno != null) {
                notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), null)
            }

            // invio le relative notifiche
            inviaNotifica(smistamento)

            // elimino il primo destinatario:
            destinatariSmistamento = destinatari.takeRight(destinatari.size() - 1)
        }

        // per ogni destinatario (che in questo caso sono solo soggetti a cui assegnare), creo il relativo smistamento:
        for (Map destinatario : destinatariSmistamento) {
            Smistamento duplicato = duplicaSmistamento(smistamento.protocollo, smistamento)
            assegnaSmistamento(duplicato, utenteAssegnante, (Ad4Utente) destinatario.utente, (String) destinatario.note, dataAssegnazione)
            inviaNotifica(duplicato)
        }
    }

    /**
     * Assegna un utente ad uno smistamento ed invia la relativa notifica.
     *
     * @param smistamento
     * @param utenteAssegnante
     * @param utenteAssegnatario
     * @param dataAssegnazione
     */
    void assegnaSmistamento(Smistamento smistamento, Ad4Utente utenteAssegnante, Ad4Utente utenteAssegnatario, String note, Date dataAssegnazione = dateService.getCurrentDate()) {
        smistamento.utenteAssegnante = utenteAssegnante
        smistamento.utenteAssegnatario = utenteAssegnatario
        smistamento.dataAssegnazione = dataAssegnazione
        smistamento.dataSmistamento = smistamento.dataSmistamento ?: dataAssegnazione
        smistamento.note = note

        smistamento.save()

        // allineo su gdm
        protocolloGdmService.salvaSmistamento(smistamento)
    }

    /**
     * Elimina lo smistamento richiesto
     * @param documentoDTO
     * @param smistamentoDTO
     */
    void eliminaSmistamento(ISmistabile documento, Smistamento smistamento, competenzeEsplicite = false) {
        if (documento.smistamentoAttivoInCreazione && !competenzeEsplicite) {
            boolean smistamentoArrivoObbligatorio = (ImpostazioniProtocollo.SMIST_ARR_OB.abilitato)
            boolean smistamentoPartenzaObbligatorio = (ImpostazioniProtocollo.SMIST_PAR_OB.abilitato)
            boolean smistamentoInternoObbligatorio = (ImpostazioniProtocollo.SMIST_INT_OB.abilitato)

            if ((smistamentoArrivoObbligatorio && documento.movimento == Protocollo.MOVIMENTO_ARRIVO) ||
                    (smistamentoPartenzaObbligatorio && documento.movimento == Protocollo.MOVIMENTO_PARTENZA) ||
                    (smistamentoInternoObbligatorio && documento.movimento == Protocollo.MOVIMENTO_INTERNO)) {
                if (documento.smistamentiValidi.size() == 1) {
                    throw new ProtocolloRuntimeException("Deve esistere almeno uno smistamento")
                }
            }
        }

        notificheService.eliminaNotifica(null, smistamento.idDocumentoEsterno.toString(), null)

        documento.removeFromSmistamenti(smistamento)
        smistamento.delete()
        documento.save()

        if (smistamento.idDocumentoEsterno != null && !competenzeEsplicite) {
            protocolloGdmService.cancellaDocumento(smistamento.idDocumentoEsterno?.toString())
        }
    }

    /*
     * Funzioni di utilità
     */

    void inviaNotifica(Smistamento smistamento, String tipoNotifica = null, String messaggioTodo = null) {

        if (tipoNotifica != null) {
            notificheService.invia(tipoNotifica, smistamento, messaggioTodo)
            return
        }

        if (Smistamento.IN_CARICO.equals(smistamento.statoSmistamento)) {
            if (smistamento.utenteAssegnatario != null) {
                if (smistamento.protocollo instanceof MessaggioRicevuto) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_ASSEGNAZIONE_MEMO, smistamento, messaggioTodo)
                } else if (smistamento.protocollo instanceof Fascicolo) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_ASSEGNAZIONE_FASCICOLO, smistamento, messaggioTodo)
                } else if (!smistamento.protocollo.categoriaProtocollo?.isDaNonProtocollare()) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_ASSEGNAZIONE, smistamento, messaggioTodo)
                } else {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_ASSEGNAZIONE_NP, smistamento, messaggioTodo)
                }
                return
            } else {
                if (smistamento.protocollo instanceof MessaggioRicevuto) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_MEMO, smistamento, messaggioTodo)
                } else if (smistamento.protocollo instanceof Fascicolo) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_FASCICOLO, smistamento, messaggioTodo)
                } else if (!smistamento.protocollo.categoriaProtocollo?.isDaNonProtocollare()) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO, smistamento, messaggioTodo)
                } else {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_IN_CARICO_NP, smistamento, messaggioTodo)
                }
                return
            }
        }

        if (Smistamento.DA_RICEVERE.equals(smistamento.statoSmistamento)) {
            if (smistamento.isPerCompetenza()) {
                if (smistamento.protocollo instanceof MessaggioRicevuto) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_COMPETENZA_MEMO, smistamento, messaggioTodo)
                } else if (smistamento.protocollo instanceof Fascicolo) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_COMPETENZA_FASCICOLO, smistamento, messaggioTodo)
                } else if (!smistamento.protocollo.categoriaProtocollo.isDaNonProtocollare()) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_COMPETENZA, smistamento, messaggioTodo)
                } else {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_COMPETENZA_NP, smistamento, messaggioTodo)
                }
                return
            } else {
                if (smistamento.protocollo instanceof MessaggioRicevuto) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_CONOSCENZA_MEMO, smistamento, messaggioTodo)
                } else if (smistamento.protocollo instanceof Fascicolo) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_CONOSCENZA_FASCICOLO, smistamento, messaggioTodo)
                } else if (!smistamento.protocollo.categoriaProtocollo.isDaNonProtocollare()) {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_CONOSCENZA, smistamento, messaggioTodo)
                } else {
                    notificheService.invia(RegoleCalcoloNotificheSmistamentoRepository.NOTIFICA_DA_RICEVERE_CONOSCENZA_NP, smistamento, messaggioTodo)
                }
                return
            }
        }
    }

    /**
     * Ritorna l'unità di trasmissione di default per i nuovi smistamenti.
     *
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    So4UnitaPubb getUnitaTrasmissioneDefault(ISmistabile protocollo, Ad4Utente utenteSmistamento) {
        List<So4UnitaPubb> unitaList = getUnitaTrasmissione(protocollo, utenteSmistamento)
        if (unitaList?.size() > 0) {
            return unitaList?.get(0)
        } else {
            return null
        }
    }

    /**
     * Ritorna l'unità di trasmissione di default per smistamenti in carico.
     *
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    So4UnitaPubb getUnitaTrasmissioneCaricoDefault(ISmistabile protocollo, Ad4Utente utenteSmistamento) {
        /* todo il parametro protocollo (e tutte le chiamate interne)  deve diventare Documento generico non appena nella
           gestione documenti si saranno spostati i metodi relativi agli smistamenti dal ISmistabile al Documento
         */
        List<Smistamento> smistamentoList = getSmistamentiInCarico(protocollo, utenteSmistamento)
        String unitaTrasmissione = null
        for (smistamento in smistamentoList) {
            unitaTrasmissione = smistamento.getUnitaTrasmissione()

            if (unitaTrasmissione != null) {
                break
            }
        }

        if (unitaTrasmissione == null) {
            unitaTrasmissione = privilegioUtenteService.getPrimaUnitaTrasmissioneDefault();
        }

        return protocolloService.getUnitaPerCodice(unitaTrasmissione)
    }

    /**
     * Ritorna l' unità di trasmissione di default per smistamenti da prendere in carico e inoltrare.
     *
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    So4UnitaPubb getUnitaTrasmissioneCaricoInoltroDefault(ISmistabile protocollo, Ad4Utente utenteSmistamento) {
        List<So4UnitaPubb> unitaList = getUnitaTrasmissionePerCaricoInoltro(protocollo, utenteSmistamento)
        if (unitaList?.size() > 0) {
            return unitaList?.get(0)
        } else {
            return null
        }
    }

    /**
     * Ritorna l' unità di trasmissione di default per smistamenti da prendere in carico e inoltrare.
     *
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    So4UnitaPubb getUnitaTrasmissioneCaricoAssegnaDefault(ISmistabile protocollo, Ad4Utente utenteSmistamento) {
        List<So4UnitaPubb> unitaList = getUnitaTrasmissionePerCaricoAssegna(protocollo, utenteSmistamento)
        if (unitaList?.size() > 0) {
            return unitaList?.get(0)
        } else {
            return null
        }
    }

    /**
     * Ritorna le unità di trasmissione possibili per i nuovi smistamenti.
     *
     * @param documento
     * @param utentePresaInCarico
     * @return
     */
    @Transactional(readOnly = true)
    List<So4UnitaPubb> getUnitaTrasmissione(ISmistabile smistabile, Ad4Utente utentePresaInCarico) {
        /* todo il parametro protocollo (e tutte le chiamate interne)  deve diventare Documento generico non appena nella
           gestione documenti si saranno spostati i metodi relativi agli smistamenti dal Protocollo al Documento
         */
        List<So4UnitaPubb> listaUnitaTrasmissione = new ArrayList<So4UnitaPubb>()

        List<So4UnitaPubb> listaUnitaUtenteProtocollatore = privilegioUtenteService.getUnitaPerPrivilegi(utentePresaInCarico, PrivilegioUtente.REDATTORE_PROTOCOLLO, false)
        List<So4UnitaPubb> listaUnitaUtenteSmistatore = privilegioUtenteService.getUnitaPerPrivilegi(utentePresaInCarico, PrivilegioUtente.SMISTAMENTO_VISUALIZZA, false)

        So4UnitaPubb unitaProtocollante = smistabile.getUnita()
        Ad4Utente utenteRedattore = smistabile.getSoggetto(TipoSoggetto.REDATTORE)?.utenteAd4

        if (smistabile.smistamentoAttivoInCreazione) {
            if ((utenteRedattore != null && utenteRedattore.id.equals(utentePresaInCarico.id)) || listaUnitaUtenteProtocollatore?.find {
                it.codice == unitaProtocollante.codice
            }) {
                listaUnitaTrasmissione.add(unitaProtocollante)
            }
        }

        if (utenteRedattore != null && utentePresaInCarico.id == utenteRedattore.id && (smistabile instanceof Protocollo || smistabile instanceof MessaggioRicevuto) && listaUnitaUtenteSmistatore != null) {
            for (unita in listaUnitaUtenteSmistatore) {
                if (!listaUnitaTrasmissione.contains(unita)) {
                    listaUnitaTrasmissione.add(unita)
                }
            }
        }

        List<Smistamento> smistamentoList = getSmistamentiInCarico(smistabile, utentePresaInCarico);
        for (smistamento in smistamentoList) {
            if (smistamento.unitaSmistamento != null && !listaUnitaTrasmissione.contains(smistamento.unitaSmistamento)) {
                listaUnitaTrasmissione.add(smistamento.unitaSmistamento)
            }
        }

        smistamentoList = getSistamentiPerTipo(getSmistamentiDaPrendereInCarico(smistabile, utentePresaInCarico), [Smistamento.CONOSCENZA])
        for (smistamento in smistamentoList) {
            if (smistamento.unitaSmistamento != null && !listaUnitaTrasmissione.contains(smistamento.unitaSmistamento)) {
                listaUnitaTrasmissione.add(smistamento.unitaSmistamento)
            }
        }

        if (listaUnitaTrasmissione.size() == 0) {
            So4UnitaPubb unitaDefault = getUnitaTrasmissioneCaricoDefault(smistabile, utentePresaInCarico)
            if (unitaDefault != null) {
                listaUnitaTrasmissione = [unitaDefault]
            }
        }

        if (listaUnitaTrasmissione.size() == 0) {
            listaUnitaTrasmissione = privilegioUtenteService.getUnitaPerPrivilegi(utentePresaInCarico, PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, true)
            if (listaUnitaTrasmissione.size() == 0) {
                listaUnitaTrasmissione = privilegioUtenteService.getUnitaPerPrivilegi(utentePresaInCarico, PrivilegioUtente.SMISTAMENTO_CREA, true)
            }
        }

        return listaUnitaTrasmissione
    }

    /**
     * Ritorna le unità di trasmissione possibili per l'inoltro.
     *
     * @param protocollo
     * @return
     */
    @Transactional(readOnly = true)
    List<So4UnitaPubb> getUnitaTrasmissioneInoltro(ISmistabile protocollo, Ad4Utente utentePresaInCarico) {
        /* todo il parametro protocollo (e tutte le chiamate interne)  deve diventare Documento generico non appena nella
           gestione documenti si saranno spostati i metodi relativi agli smistamenti dal Protocollo al Documento
         */
        List<So4UnitaPubb> listaUnitaTrasmissione = new ArrayList<So4UnitaPubb>()
        List<So4UnitaPubb> listaUnitaUtenteCreaSmistamenti = privilegioUtenteService.getUnitaPerPrivilegi(utentePresaInCarico, PrivilegioUtente.SMISTAMENTO_CREA, false)

        if (protocollo.smistamentoAttivoInCreazione) {
            List<Smistamento> smistamentoList = getSmistamentiInCarico(protocollo, utentePresaInCarico);
            for (smistamento in smistamentoList) {
                if (smistamento.unitaSmistamento != null && listaUnitaUtenteCreaSmistamenti != null &&
                        listaUnitaUtenteCreaSmistamenti.find { it.codice == smistamento.unitaSmistamento.codice } &&
                        !listaUnitaTrasmissione.contains(smistamento.unitaSmistamento)) {
                    listaUnitaTrasmissione.add(smistamento.unitaSmistamento)
                }
            }
        }

        if (listaUnitaTrasmissione.size() == 0) {
            throw new ProtocolloRuntimeException("Impossibile determinare l'Unità di Trasmissione")
        }

        return listaUnitaTrasmissione
    }

    /**
     * Ritorna le unità di trasmissione possibili per prendi in carico e inoltra.
     *
     * @param protocollo
     * @param utentePresaInCarico
     * @return
     */
    @Transactional(readOnly = true)
    List<So4UnitaPubb> getUnitaTrasmissionePerCaricoInoltro(ISmistabile protocollo, Ad4Utente utentePresaInCarico) {
        /* todo il parametro protocollo (e tutte le chiamate interne)  deve diventare Documento generico non appena nella
           gestione documenti si saranno spostati i metodi relativi agli smistamenti dal Protocollo al Documento        */
        List<So4UnitaPubb> listaUnitaTrasmissione = new ArrayList<So4UnitaPubb>()

        List<Smistamento> smistamentoList = getSistamentiPerTipo(getSmistamentiDaPrendereInCarico(protocollo, utentePresaInCarico), [Smistamento.COMPETENZA])
        for (smistamento in smistamentoList) {
            if (smistamento.unitaSmistamento != null && !listaUnitaTrasmissione.contains(smistamento.unitaSmistamento)) {
                listaUnitaTrasmissione.add(smistamento.unitaSmistamento)
            }
        }

        if (listaUnitaTrasmissione.size() == 0) {
            So4UnitaPubb unitaDefault = getUnitaTrasmissioneCaricoDefault(protocollo, utentePresaInCarico)
            if (unitaDefault != null) {
                listaUnitaTrasmissione = [unitaDefault]
            }
        }

        if (listaUnitaTrasmissione.size() == 0) {
            throw new ProtocolloRuntimeException("Impossibile determinare l'Unità di Trasmissione")
        }

        return listaUnitaTrasmissione
    }

    /**
     * Ritorna le unità di trasmissione possibili per gli smistamenti in assegnazione.
     *
     * @param smistabile
     * @return
     */
    @Transactional(readOnly = true)
    List<So4UnitaPubb> getUnitaTrasmissionePerCaricoAssegna(ISmistabile smistabile, Ad4Utente utenteTrasmissione) {
        /* todo il parametro protocollo  (e tutte le chiamate interne)  deve diventare Documento generico non appena nella
        gestione documenti si saranno spostati i metodi relativi agli smistamenti dal Protocollo al Documento        */
        List<So4UnitaPubb> listaUnitaTrasmissione = new ArrayList<So4UnitaPubb>()

        List<Smistamento> smistamentoList = getSmistamentiDaPrendereInCarico(smistabile, utenteTrasmissione)
        for (smistamento in smistamentoList) {
            if (smistamento.unitaSmistamento != null && !listaUnitaTrasmissione.contains(smistamento.unitaSmistamento)) {
                listaUnitaTrasmissione.add(smistamento.unitaSmistamento)
            }
        }

        if (listaUnitaTrasmissione.size() == 0) {
            throw new ProtocolloRuntimeException("Impossibile determinare l'Unità di Trasmissione")
        }

        return listaUnitaTrasmissione
    }

    /**
     * Ritorna il tipo di smistamento (CONOSCENZA o COMPETENZA) per cui l'utente può inoltrare
     *
     * @param smistabile
     * @return
     */
    @Transactional(readOnly = true)
    String getTipoSmistamentoPerInoltro(ISmistabile smistabile, Ad4Utente utentePresaInCarico, So4UnitaPubb unitaTrasmissione = null) {
        return getTipoSmistamentoPerSmista(smistabile, getSmistamentiInCarico(smistabile, utentePresaInCarico), unitaTrasmissione)
    }

    /**
     * Ritorna il tipo di smistamento (CONOSCENZA o COMPETENZA) per cui l'utente può inoltrare
     * Essendo un'operazione di prendi in carico e inoltra, gli smistamenti da prendere
     * in considerazione sono quelli da ricevere.
     * @param smistabile
     * @return
     */
    @Transactional(readOnly = true)
    String getTipoSmistamentoPerCarico(ISmistabile smistabile, Ad4Utente utentePresaInCarico, So4UnitaPubb unitaTrasmissione = null) {
        return getTipoSmistamentoPerSmista(smistabile, getSmistamentiDaPrendereInCarico(smistabile, utentePresaInCarico), unitaTrasmissione)
    }

    @Transactional(readOnly = true)
    String getTipoSmistamentoPerSmista(ISmistabile smistabile, Ad4Utente utentePresaInCarico, So4UnitaPubb unitaTrasmissione = null) {
        return getTipoSmistamentoPerSmista(smistabile, smistabile.smistamentiValidi, unitaTrasmissione)
    }

    /**
     * Ritorna il tipo di smistamento (CONOSCENZA o COMPETENZA) per cui l'utente può smistare.
     *
     * Ritorna null se l'utente ha anche solo uno smistamento per competenza: significa che l'utente può decidere se smistare per competenza o conoscenza.
     * Se l'utente ha solo smistamenti per conoscenza invece, può smistare solo per conoscenza.
     *
     * @param smistamenti
     * @return
     */
    @Transactional(readOnly = true)
    String getTipoSmistamentoPerSmista(ISmistabile smistabile, List<Smistamento> smistamenti, So4UnitaPubb unitaTrasmissione) {
        // se esiste almeno uno smistamento per competenza, allora posso smistare sia per competenza che per comnoscenza, altrimenti conoscenza.
        if ((smistamenti*.tipoSmistamento).contains(Smistamento.COMPETENZA)) {
            return null // cioè l'utente può scegliere tra competenza / conoscenza
        } else {

            // Controllo che l'utente abbia comunque compentente per smistare per conoscenza e per compentenza

            //1) Controllare che l'utente appartenga all'unita protocollante
            if (smistabile) {
                So4UnitaPubb unitaProtocollante = smistabile.unita
                if (unitaProtocollante) {
                    List<So4UnitaPubb> listaUnitaUtente = strutturaOrganizzativaService.getUnitaUtente(springSecurityService.principal.id,
                            springSecurityService.principal.ottica().codice)
                    if (listaUnitaUtente != null && listaUnitaUtente.find {
                        it.id == unitaProtocollante.id
                    }) {
                        return null
                    }
                }
            }

            //1) L'utente ha privilegio ISMITOT sull'unita di trasmissione
            if (unitaTrasmissione && privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, unitaTrasmissione.codice)) {
                return null
            }

            return Smistamento.CONOSCENZA
        }
    }

    /**
     * Ritorna la lista filtrata degli smistamenti per tipo
     *
     * @param smistamenti
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSistamentiPerTipo(List<Smistamento> smistamenti, List<String> tipiSmistamento) {
        List<Smistamento> smistamentoList = new ArrayList<String>()

        for (smistamento in smistamenti) {
            if (tipiSmistamento.contains(smistamento.tipoSmistamento)) {
                smistamentoList.add(smistamento)
            }
        }

        return smistamentoList
    }

    /**
     * Crea uno smistamento per assegnare una competenza esplicita (Issue #30368)
     *
     */
    void creaSmistamentoCompetenzaEsplicita(ISmistabile protocollo, Ad4Utente utente) {
        Smistamento smistamento = creaSmistamento(protocollo, Smistamento.CONOSCENZA, protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE).unitaSo4, springSecurityService.currentUser, null, utente, Smistamento.COMPETENZA_ESPLICITA)
        esegui(protocollo, utente, smistamento)
    }

    /**
     * Ritorna l'elenco degli smistamenti in carico sul protocollo.
     *
     * @param protocollo il protocollo di cui ottenere gli smistamenti
     * @return gli smistamenti in carico per il protocollo
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSmistamentiInCarico(ISmistabile protocollo, Ad4Utente utenteInCarico) {
        List<Smistamento> smistamentiInCarico = []
        for (Smistamento smistamento : protocollo.smistamentiValidi) {
            if (smistamento.statoSmistamento != Smistamento.IN_CARICO && smistamento.statoSmistamento != Smistamento.ESEGUITO) {
                continue
            }

            if (smistamento.utenteAssegnatario?.id == utenteInCarico.id) {
                smistamentiInCarico << smistamento
                continue
            }

            if (smistamento.documento.riservato && gestoreCompetenze.utenteHaPrivilegio(utenteInCarico, PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO) ||
                    !smistamento.documento.riservato && gestoreCompetenze.utenteHaPrivilegio(utenteInCarico, PrivilegioUtente.SMISTAMENTO_VISUALIZZA)) {
                if (gestoreCompetenze.utenteHaPrivilegio(utenteInCarico, PrivilegioUtente.SMISTAMENTO_CARICO, smistamento.unitaSmistamento.codice)) {
                    smistamentiInCarico << smistamento
                }
            }
        }
        return smistamentiInCarico
    }

    /**
     * Ritorna l'elenco degli smistamenti in carico ed eseguito sul protocollo.
     *
     * @param protocollo il protocollo di cui ottenere gli smistamenti
     * @return gli smistamenti in carico ed eseguiti per il protocollo
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSmistamentiInCaricoEdEseguiti(ISmistabile protocollo, Ad4Utente utenteInCarico) {
        List<Smistamento> smistamentiInCaricoEdEseguito = []
        for (Smistamento smistamento : protocollo.smistamentiValidi) {
            if (smistamento.statoSmistamento != Smistamento.IN_CARICO && smistamento.statoSmistamento != Smistamento.ESEGUITO) {
                continue
            }

            if (smistamento.utenteAssegnatario?.id == utenteInCarico.id) {
                smistamentiInCaricoEdEseguito << smistamento
                continue
            }

            if (smistamento.documento.riservato && gestoreCompetenze.utenteHaPrivilegio(utenteInCarico, PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO) ||
                    !smistamento.documento.riservato && gestoreCompetenze.utenteHaPrivilegio(utenteInCarico, PrivilegioUtente.SMISTAMENTO_VISUALIZZA)) {
                if (gestoreCompetenze.utenteHaPrivilegio(utenteInCarico, PrivilegioUtente.SMISTAMENTO_CREA, smistamento.unitaSmistamento.codice)) {
                    smistamentiInCaricoEdEseguito << smistamento
                }
            }
        }
        return smistamentiInCaricoEdEseguito
    }

    /**
     * Ritorna l'elenco degli smistamenti che l'utente può prendere in carico.
     *
     * @param smistabile il protocollo con gli smistamenti
     * @param utente l'utente
     * @return l'elenco degli smistamenti che l'utente può prendere in carico
     */
    @Transactional(readOnly = true)
    List<Smistamento> getSmistamentiDaPrendereInCarico(ISmistabile smistabile, Ad4Utente utente) {
        List<Smistamento> daPrendereInCarico = new ArrayList<Smistamento>()
        for (Smistamento smistamento : smistabile.smistamentiValidi) {
            if (smistamento.statoSmistamento == Smistamento.DA_RICEVERE && isPossibilePrendereInCarico(smistamento, utente, smistabile.riservato)) {
                daPrendereInCarico.add(smistamento)
            }
        }
        return daPrendereInCarico
    }

    /**
     * Ritorna true o false se l'utente può prendere in carico uno smistamento.
     * Un utente può prendere in carico uno smistamento solo se:
     * - il documento non è riservato e l'utente ha entrambi i privilegi VS e CARICO per l'unità a cui è stato smistato lo smistamento
     * - oppure è l'assegnatario dello smistamento indipendentemente dai privilegi -> laura dice di si
     * - oppure il documento è riservato e l'utente ha entrambi i privilegi VSR e CARICO per l'unità a cui è stato smistato lo smistamento
     *
     * @param idSmistamento l'id dello smistamento su AGSPR.
     * @param utente il codice dell'utente ad4
     * @return true se l'utente può prendere in carico lo smistamento
     */
    private boolean isPossibilePrendereInCarico(Smistamento smistamento, Ad4Utente utente, boolean riservato) {
        if (smistamento.utenteAssegnatario?.id == utente.id) {
            return true
        }

        String privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        if (riservato) {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        }

        return gestoreCompetenze.utenteHaPrivilegio(utente, privilegio, smistamento.unitaSmistamento?.codice)
    }

    /**
     * Ritorna true o false se l'utente può uno smistamento da ricevere.
     * @param smistamento
     * @param utente
     * @param riservato
     * @return
     */
    private boolean isPossibileDaRicevereInIter(String codiceUnita, Ad4Utente utente, boolean riservato) {

        String privilegio = PrivilegioUtente.VDDR
        if (riservato) {
            privilegio = PrivilegioUtente.VDDRR
        }

        return gestoreCompetenze.utenteHaPrivilegio(utente, privilegio, codiceUnita)
    }

    /**
     * Ritorna true o false se l'utente può  prendere in carico uno smistamento
     * @param smistamento
     * @param utente
     * @param riservato
     * @return
     */
    private boolean isPossibilePrendereInCaricoInIter(String codiceUnita, Ad4Utente utente, boolean riservato) {

        String privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        if (riservato) {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        }

        return gestoreCompetenze.utenteHaPrivilegio(utente, privilegio, codiceUnita)
    }

    /**
     * Trasforma i DatiDestinatari da DTO ad una List<Map> di domainObject nella forma: [unita:So4UnitaPubb, utente:Ad4Utente, note:String]
     * @param datiDestinatari i dati dei destinatari come arrivano dall'interfaccia
     * @return una List<Map> di domainObject nella forma: [unita:So4UnitaPubb, utente:Ad4Utente, note:String]
     */
    private List<Map> getDestinatariList(List<PopupSceltaSmistamentiViewModel.DatiDestinatario> datiDestinatari) {
        def destinatari = []
        for (PopupSceltaSmistamentiViewModel.DatiDestinatario dati : datiDestinatari) {
            destinatari << [unita: dati.unita?.domainObject, utente: dati.utente?.domainObject, note: dati.note]
        }
        return destinatari
    }

    private void controllaFascicoloObbligatorio(ISmistabile smistabile) {
        List<SchemaProtocolloSmistamento> schemaProtocolloSmistamenti = smistabile.schemaProtocollo?.smistamenti?.toList()
        boolean fascicoloObb = false
        for (SchemaProtocolloSmistamento schemaProtocolloSmistamento : schemaProtocolloSmistamenti) {
            if (schemaProtocolloSmistamento.fascicoloObbligatorio) {
                fascicoloObb = true
                break
            }
        }
        if (fascicoloObb && smistabile.fascicolo == null) {
            throw new ProtocolloRuntimeException("E' obbligatorio specificare un fascicolo")
        }
    }

    private Documento buildDocumentoSmart(Long idDocumentoEsterno) {

        Documento documentoSmart = new Documento(id: String.valueOf(idDocumentoEsterno))
        documentoSmart = documentaleService.getDocumento(documentoSmart, new ArrayList<Documento.COMPONENTI>())
        return documentoSmart
    }

    /**
     *
     * @param testoRicerca
     * @param orderMap
     * @param unitaOrganizzativa
     * @param statiSmistamento
     * @param tipoOggettiDaEscludere
     * @param daRicevere
     * @param assegnati
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> getDocumentiIterDaSmistamentoByStatoSmistamento(String testoRicerca, So4UnitaPubbDTO unitaOrganizzativa,
                                                                      List<String> statiSmistamento, List<String> tipoOggettiDaEscludere, boolean daRicevere, boolean assegnati, boolean inCarico) {

        List<Smistamento> documentiIterResult = new ArrayList<Smistamento>()

        testoRicerca = "%" + testoRicerca + "%"
        // numeri contenuti nella stringa di ricerca
        Integer numeroRicerca = testoRicerca.replaceAll("\\D+", "") != "" ? new Integer(testoRicerca.replaceAll("\\D+", "")) : 0

        //Hibernate JPQL non supporta la UNION eseguo due query separatamente ed unisco la lista dei risultati
        String queryDocumentiIterFromProtocollo = iterDocumentaleRepository.getQueryStringIterDocumentaleFromProtocollo(daRicevere, assegnati, inCarico)
        String queryDocumentiIterFromMessaggioRicevuto = iterDocumentaleRepository.getQueryStringIterDocumentaleFromMessaggioRicevuto(daRicevere, assegnati, inCarico)
        //Devo prendere anche messaggi vecchi creati in flex...quindi vado a interrogare delle viste ad Hoc
        //devo accorpare i vecchi e i nuovi sotto l'entita Smistamento
        String queryDocumentiIterFromMemoRicevutoGDM = iterDocumentaleRepository.getQueryStringIterDocumentaleFromMemoRicevutoGDM(daRicevere, assegnati, inCarico)

        List<SmistamentoMemoRicevuti> documentiIterMemoRicevutiGDM = iterDocumentaleRepository.getDocumentiIterFromMemoRicevuto(queryDocumentiIterFromMemoRicevutoGDM, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, testoRicerca, springSecurityService.currentUser.id)

        ArrayList<Smistamento> smistamentoMemoRicevutiGDM = toSmistamento(documentiIterMemoRicevutiGDM)

        List<Smistamento> documentiIterMsg = iterDocumentaleRepository.getDocumentiIterFromMessaggioRicevuto(queryDocumentiIterFromMessaggioRicevuto, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, testoRicerca, springSecurityService.currentUser.id)

        //Unisco le liste dei messaggi ricevuti
        documentiIterMsg.addAll(smistamentoMemoRicevutiGDM)

        //se da ricevere ordinmaneto per data smista desc altrimenti data aggiornamento desc
        if(daRicevere){
            documentiIterMsg.sort { a, b -> b.dataSmistamento <=> a.dataSmistamento }
        } else {
            documentiIterMsg.sort { a, b -> b.lastUpdated <=> a.lastUpdated }
        }

        List<Smistamento> documentiIter = iterDocumentaleRepository.getDocumentiIterFromProtocollo(queryDocumentiIterFromProtocollo, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, tipoOggettiDaEscludere, testoRicerca, numeroRicerca, springSecurityService.currentUser.id)

        //Devo scindere i doc da non protocollare dagli altri perchè devono comparire subito dopo i messaggi
        List<Smistamento> documentiIterDaFascicolare = new ArrayList<Smistamento>()
        List<Smistamento> documentiIterProtocollo = new ArrayList<Smistamento>()
        for (Smistamento smistamento : documentiIter) {
            if (smistamento.documento.categoriaProtocollo?.isDaNonProtocollare()) {
                documentiIterDaFascicolare.add(smistamento)
            } else {
                documentiIterProtocollo.add(smistamento)
            }
        }

        //se da ricevere ordinmaneto per data smista desc altrimenti data aggiornamento desc
        if(daRicevere){
            documentiIterDaFascicolare?.sort { a, b -> b.dataSmistamento <=> a.dataSmistamento }
            documentiIterProtocollo?.sort { a, b -> b.dataSmistamento <=> a.dataSmistamento }
        } else {
            documentiIterDaFascicolare?.sort { a, b -> b.lastUpdated <=> a.lastUpdated }
            documentiIterProtocollo?.sort { a, b -> b.lastUpdated <=> a.lastUpdated }
        }

        //Eventuali messaggi e Da Fascicolare devono comparire in testa
        documentiIterResult.addAll(documentiIterMsg)
        documentiIterResult.addAll(documentiIterDaFascicolare)
        documentiIterResult.addAll(documentiIterProtocollo)

        return documentiIterResult
    }


    private ArrayList<Smistamento> toSmistamento(List<SmistamentoMemoRicevuti> documentiIterMemoRicevutiGDM) {

        List<Smistamento> smistamentoMemoRicevutiGDM = new ArrayList<Smistamento>()
        for (SmistamentoMemoRicevuti smr : documentiIterMemoRicevutiGDM) {

            Smistamento smistamentoMemo = new Smistamento()
            MessaggioRicevuto messaggioRicevutoMemo = new MessaggioRicevuto()
            //Converto il messaggio in messaggio ricevuto
            messaggioRicevutoMemo.classificazione = smr.documento.classificazione
            messaggioRicevutoMemo.fascicolo = smr.documento.fascicolo
            messaggioRicevutoMemo.id = smr.documento.id
            messaggioRicevutoMemo.oggetto = smr.documento.oggetto
            messaggioRicevutoMemo.idMessaggioSi4Cs = smr.documento.idMessaggioSi4Cs
            messaggioRicevutoMemo.idrif = smr.documento.idrif
            messaggioRicevutoMemo.titolari = smr.documento.titolari
            messaggioRicevutoMemo.dataRicezione = smr.documento.dataRicezione
            //Uso questo campo stringa per avere la data di spedizione (string) dei vecchi
            messaggioRicevutoMemo.mimeTesto = smr.documento.dataSpedizione
            messaggioRicevutoMemo.statoMessaggio = smr.documento.statoMessaggio
            messaggioRicevutoMemo.dataStato = smr.documento.dataStato
            messaggioRicevutoMemo.mittente = smr.documento.mittente
            messaggioRicevutoMemo.destinatari = smr.documento.destinatari
            messaggioRicevutoMemo.destinatariNascosti = smr.documento.destinatariNascosti
            messaggioRicevutoMemo.destinatariConoscenza = smr.documento.destinatariConoscenza
            messaggioRicevutoMemo.testo = smr.documento.testo
            messaggioRicevutoMemo.note = smr.documento.note
            messaggioRicevutoMemo.tipo = smr.documento.tipo
            //Aggancio il messaggio allo smistamento come documento e converto in smistamento
            smistamentoMemo.documento = messaggioRicevutoMemo
            smistamentoMemo.note = smr.note
            smistamentoMemo.id = smr.id
            smistamentoMemo.unitaSmistamento = smr.unitaSmistamento
            smistamentoMemo.unitaTrasmissione = smr.unitaTrasmissione
            smistamentoMemo.idDocumentoEsterno = smr.idDocumentoEsterno
            smistamentoMemo.dataAssegnazione = smr.dataAssegnazione
            smistamentoMemo.dataEsecuzione = smr.dataEsecuzione
            smistamentoMemo.dateCreated = smr.dateCreated
            smistamentoMemo.dataPresaInCarico = smr.dataPresaInCarico
            smistamentoMemo.dataRifiuto = smr.dataRifiuto
            smistamentoMemo.dataSmistamento = smr.dataSmistamento
            smistamentoMemo.dataAssegnazione = smr.dataAssegnazione
            smistamentoMemo.lastUpdated = smr.lastUpdated
            smistamentoMemo.noteUtente = smr.noteUtente
            smistamentoMemo.tipoSmistamento = smr.tipoSmistamento
            smistamentoMemo.statoSmistamento = smr.statoSmistamento
            smistamentoMemo.motivoRifiuto = smr.motivoRifiuto
            smistamentoMemo.utenteAssegnante = smr.utenteAssegnante
            smistamentoMemo.utenteAssegnatario = smr.utenteAssegnatario
            smistamentoMemo.utenteEsecuzione = smr.utenteEsecuzione
            smistamentoMemo.utentePresaInCarico = smr.utentePresaInCarico
            smistamentoMemo.utenteRifiuto = smr.utenteRifiuto
            smistamentoMemo.utenteTrasmissione = smr.utenteTrasmissione
            smistamentoMemo.version = smr.version

            smistamentoMemoRicevutiGDM.add(smistamentoMemo)
        }

        return smistamentoMemoRicevutiGDM
    }

    @Transactional(readOnly = true)
    List<Smistamento> getDocumentiPerCodiceABarre(So4UnitaPubbDTO unitaOrganizzativa, List<String> statiSmistamento, List<String> tipoOggettiDaEscludereIncludere, boolean daRicevere, boolean assegnati, boolean inCarico, Long codiceABarre) {

        //Setto valori di default per parametri di ricerca
        String testoRicerca = "%%"
        Integer numeroRicerca = 0

        //Hibernate JPQL non supporta la UNION eseguo due query separatamente ed unisco la lista dei risultati
        String queryDocumentiIterFromProtocollo = iterDocumentaleRepository.getQueryStringIterDocumentaleFromProtocollo(daRicevere, assegnati, inCarico, true)
        String queryDocumentiIterFromMessaggioRicevuto = iterDocumentaleRepository.getQueryStringIterDocumentaleFromMessaggioRicevuto(daRicevere, assegnati, inCarico, true)
        String queryDocumentiIterFromMemoRicevutoGdm = iterDocumentaleRepository.getQueryStringIterDocumentaleFromMemoRicevutoGDM(daRicevere, assegnati, inCarico, true)

        List<Smistamento> documentiIter = iterDocumentaleRepository.getDocumentiIterFromProtocolloByCodiceABarre(queryDocumentiIterFromProtocollo, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, tipoOggettiDaEscludereIncludere, testoRicerca, numeroRicerca, springSecurityService.currentUser.id, codiceABarre)

        List<Smistamento> documentiMemoRicevutiGdm = iterDocumentaleRepository.getDocumentiIterFromMemoRicevutoByCodiceABarre(queryDocumentiIterFromMemoRicevutoGdm, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, tipoOggettiDaEscludereIncludere, testoRicerca, numeroRicerca, springSecurityService.currentUser.id, codiceABarre)

        documentiIter.addAll(documentiMemoRicevutiGdm)

        documentiIter.addAll(iterDocumentaleRepository.getDocumentiIterFromMessaggioRicevutoByCodiceABarre(queryDocumentiIterFromMessaggioRicevuto, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, testoRicerca, springSecurityService.currentUser.id, codiceABarre))

        return documentiIter
    }

    /**
     *
     * @param testoRicerca
     * @param orderMap
     * @param unitaOrganizzativa
     * @param statiSmistamento
     * @param tipoOggettiDaEscludere
     * @param daRicevere
     * @param assegnati
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> getFascicoliIterDaSmistamentoByStatoSmistamento(String testoRicerca, So4UnitaPubbDTO unitaOrganizzativa,
                                                                      List<String> statiSmistamento, List<String> tipoOggettiDaEscludere, boolean daRicevere, boolean assegnati, boolean inCarico) {

        testoRicerca = "%" + testoRicerca + "%"
        //Per i fascicoli il numero è una String quindi passo testoRicerca così come è
        String numeroRicerca = testoRicerca

        String queryFascicoliIterFromProtocollo = iterFascicolareRepository.getQueryStringIterFascicolareFromFascicolo(daRicevere, assegnati, inCarico)
        List<Smistamento> fascicoliIter = iterFascicolareRepository.getFascicoliIterFromFascicolo(queryFascicoliIterFromProtocollo, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, tipoOggettiDaEscludere, testoRicerca, numeroRicerca, springSecurityService.currentUser.id)

        return fascicoliIter
    }

    @Transactional(readOnly = true)
    List<Smistamento> getFascicoliPerCodiceABarre(So4UnitaPubbDTO unitaOrganizzativa, List<String> statiSmistamento, List<String> tipoOggettiDaEscludereIncludere, boolean daRicevere, boolean assegnati, boolean inCarico, Long codiceABarre) {

        //Setto valori di default per parametri di ricerca
        String testoRicerca = "%%"
        String numeroRicerca = testoRicerca

        String queryDocumentiIterFromProtocollo = iterFascicolareRepository.getQueryStringIterFascicolareFromFascicolo(daRicevere, assegnati, inCarico, true)
        List<Smistamento> fascicoliIter = iterFascicolareRepository.getFascicoliIterFromFascicoloByCodiceABarre(queryDocumentiIterFromProtocollo, unitaOrganizzativa.progr, unitaOrganizzativa.ottica.codice, unitaOrganizzativa.dal,
                statiSmistamento, tipoOggettiDaEscludereIncludere, testoRicerca, numeroRicerca, springSecurityService.currentUser.id, codiceABarre)

        return fascicoliIter
    }

    /**
     *
     * @param documentiIter
     * @param utente
     * @param unitaOrganizzativa
     * @param daRicevere
     * @return
     */
    @Transactional(readOnly = true)
    List<Smistamento> verificaPrivilegiSmistamentiIter(List<Smistamento> documentiIter, Ad4Utente utente, So4UnitaPubbDTO unitaOrganizzativa, boolean daRicevere) {
        List<Smistamento> documentiIterResult = new ArrayList<>()
        for (Smistamento smistamento : documentiIter) {
            if (daRicevere) {
                if (isPossibilePrendereInCaricoInIter(unitaOrganizzativa.codice, utente, smistamento.documento.riservato) || isPossibileDaRicevereInIter(unitaOrganizzativa.codice, utente, smistamento.documento.riservato)) {
                    documentiIterResult.add(smistamento)
                }
            } else {
                if (isPossibilePrendereInCaricoInIter(unitaOrganizzativa.codice, utente, smistamento.documento.riservato)) {
                    documentiIterResult.add(smistamento)
                }
            }
        }
        return documentiIterResult
    }

    @Transactional(readOnly = true)
    So4UnitaPubbDTO getUnitaTrasmissioneDefault(String unita) {

        So4UnitaPubbDTO unitaTrasmissioneDefault = So4UnitaPubb.createCriteria().get {
            eq("codice", unita)

            le("dal", new Date())
            or {
                isNull("al")
                ge("al", new Date())
            }
        }?.toDTO()

        if (unitaTrasmissioneDefault == null) {
            unitaTrasmissioneDefault = So4UnitaPubb.createCriteria().get {
                eq("codice", unita)
                order("al", "desc")
            }?.toDTO()
        }
        return unitaTrasmissioneDefault
    }
}

