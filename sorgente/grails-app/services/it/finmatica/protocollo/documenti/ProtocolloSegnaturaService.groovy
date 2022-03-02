package it.finmatica.protocollo.documenti

import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.firmadigitale.utils.VerificatoreFirma
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumentoService
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.documentale.IntegrazioneDocumentaleService
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.jfc.utility.Base64
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggio
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggioService
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.SchemaProtocolloIntegrazione
import it.finmatica.protocollo.documenti.interoperabilita.ProtocolloDatiInteroperabilita
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematico
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematicoService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.AggiornamentoConferma
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.AnnullamentoProtocollazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Classifica
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.ConfermaRicezione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Documento
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.FascicoloArchi
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Identificativo
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Identificatore
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Intestazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.NotificaEccezione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Origine
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Persona
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Ruolo
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Segnatura
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.UnitaOrganizzativa
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiInviatiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioInviato
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.utils.StringUtils
import it.finmatica.segreteria.common.StringUtility
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.io.IOUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import java.security.DigestInputStream
import java.security.MessageDigest
import java.text.SimpleDateFormat
import java.util.regex.Pattern

@Slf4j
@Transactional
@Service
class ProtocolloSegnaturaService {
    @Autowired
    So4Repository so4Repository
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    ClassificazioneRepository classificazioneRepository
    @Autowired
    FascicoloRepository fascicoloRepository
    @Autowired
    SchemaProtocolloService schemaProtocolloService
    @Autowired
    AllegatoProtocolloService allegatoProtocolloService
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    DocumentoService documentoService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloRepository protocolloRepository
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService
    @Autowired
    MessaggiInviatiService messaggiInviatiService
    @Autowired
    CorrispondenteMessaggioService corrispondenteMessaggioService
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    IntegrazioneDocumentaleService integrazioneDocumentaleService
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository
    @Autowired
    FileDocumentoService fileDocumentoService
    @Autowired
    ProtocolloRiferimentoTelematicoService protocolloRiferimentoTelematicoService
    @Autowired
    ProtocolloGdmService protocolloGdmService

    static final String TIPO_RIFERIMENTO_MIME = "MIME"
    static final String TIPO_RIFERIMENTO_CARTACEO = "cartaceo"
    static final String TIPO_RIFERIMENTO_TELEMATICO = "telematico"

    static final String CONFERMA = "conferma"
    static final String AGGIORNAMENTO = "aggiornamento"
    static final String ECCEZIONE = "eccezione"
    static final String ANNULLAMENTO = "annullamento"

    Map<String, String> collegamentiMap = [conferma     : MessaggiRicevutiService.TIPO_COLLEGAMENTO_PROT_CONF,
                                           aggiornamento: MessaggiRicevutiService.TIPO_COLLEGAMENTO_PROT_AGG,
                                           eccezione    : MessaggiRicevutiService.TIPO_COLLEGAMENTO_PROT_ECC,
                                           annullamento : MessaggiRicevutiService.TIPO_COLLEGAMENTO_PROT_ANN]

    void completaProtocolloDaSegnatura(String mittenteMessaggio, Protocollo protocollo, Segnatura segnatura, boolean segnaturaCittadino, MessaggioRicevutoDTO messaggioRicevutoDTO = null) {
        log.info("#completaProtocolloDaSegnatura con mittenteMessaggio: " + mittenteMessaggio + ", protocollo: " + protocollo.id + ", messaggioRicevutoDTO: " + messaggioRicevutoDTO?.id)

        ProtocolloDatiInteroperabilita protocolloDatiInteroperabilita
        List<String> segnalazioni = new ArrayList<String>()
        List<CorrispondenteDTO> corrispondentiProtocollo = new ArrayList<CorrispondenteDTO>()
        boolean isGlobo, isStarch, esistonoRiferimentiTelematici
        So4UnitaPubb unitaProtocollante
        Protocollo protocolloPrecedente = null
        CorrispondenteDTO corrispondenteMittente = null

        protocolloDatiInteroperabilita = (protocollo.datiInteroperabilita == null) ? new ProtocolloDatiInteroperabilita() : protocollo.datiInteroperabilita
        unitaProtocollante = protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4

        isGlobo = (mittenteMessaggio != null && ImpostazioniProtocollo.GLOBO_MITTENTE.valore != null && mittenteMessaggio == ImpostazioniProtocollo.GLOBO_MITTENTE.valore)
        isStarch = (segnatura.piuInfo?.metadatiInterni?.content?.toLowerCase()?.indexOf("starch") > 0)

        log.debug("isGlobo: " + isGlobo)
        log.debug("isStarch: " + isStarch)

        //*****INTESTAZIONE
        if (segnatura.intestazione != null) {
            log.debug(" ** INTESTAZIONE **")

            //Intervento operatore
            if (segnatura.intestazione.interventoOperatore != null) {
                log.debug("intestazione.interventoOperatore: " + segnatura.intestazione.interventoOperatore?.content)
                if (segnatura.intestazione.interventoOperatore.content?.size() > 0) {
                    segnalazioni.add(segnatura.intestazione.interventoOperatore.content)
                } else {
                    log.debug("interventoOperatore: " + segnatura.intestazione.interventoOperatore.content)
                    segnalazioni.add("Intervento operatore richiesto dal mittente.")
                }
            }

            //Identificatore
            if (segnatura.intestazione.identificatore != null && !isStarch) {
                String dataRegEsterno
                dataRegEsterno = segnatura.intestazione.identificatore.dataRegistrazione.content

                protocollo.numeroDocumentoEsterno = segnatura.intestazione.identificatore.numeroRegistrazione?.content?.trim()?.replaceFirst("0*", "")
                if (dataRegEsterno != null && !dataRegEsterno?.equals("")) {
                    protocollo.dataDocumentoEsterno = new SimpleDateFormat("yyyy-MM-dd").parse(dataRegEsterno)
                }

                log.debug("intestazione.identificatore.numeroRegistrazione: " + protocollo.numeroDocumentoEsterno)
                log.debug("intestazione.identificatore.dataRegistrazione: " + protocollo.dataDocumentoEsterno)
            }

            //PrimaRegistrazione
            if (segnatura.intestazione.primaRegistrazione?.identificatore != null) {
                String dataReg
                dataReg = segnatura.intestazione.primaRegistrazione.identificatore.dataRegistrazione?.content

                if (!segnaturaCittadino) {
                    protocolloDatiInteroperabilita.codiceAmmPrimaRegistrazione = segnatura.intestazione.primaRegistrazione.identificatore.codiceAmministrazione?.content
                    protocolloDatiInteroperabilita.codiceAooPrimaRegistrazione = segnatura.intestazione.primaRegistrazione.identificatore.codiceAOO?.content
                }

                protocolloDatiInteroperabilita.numeroPrimaRegistrazione = segnatura.intestazione.primaRegistrazione.identificatore.numeroRegistrazione?.content
                if (dataReg != null && !dataReg?.equals("")) {
                    protocolloDatiInteroperabilita.dataPrimaRegistrazione = new SimpleDateFormat("yyyy-MM-dd").parse(dataReg)
                }

                log.debug("intestazione.primaRegistrazione.identificatore.codiceAmministrazione: " + protocolloDatiInteroperabilita.codiceAmmPrimaRegistrazione)
                log.debug("intestazione.primaRegistrazione.identificatore.codiceAOO: " + protocolloDatiInteroperabilita.codiceAooPrimaRegistrazione)
                log.debug("intestazione.primaRegistrazione.identificatore.dataRegistrazione: " + protocolloDatiInteroperabilita.dataPrimaRegistrazione)
            }

            //Origine - Definizione del mittente
            if (segnatura.intestazione.origine != null) {
                boolean nessunAltraSegnalazione = false

                if (isGlobo || isStarch) {
                    log.debug("intestazione.origine di tipo Globo/Starch")

                    //Origine - Definizione del mittente GLOBO STARCH
                    corrispondenteMittente = parseOrigineGloboStarch(segnatura.intestazione.origine)
                } else if (segnaturaCittadino) {
                    log.debug("intestazione.origine di tipo Segnatura Cittadino")

                    //Origine - Definizione del mittente CITTADINO
                    if (segnatura.intestazione.origine.indirizzoTelematico == null ||
                            segnatura.intestazione.origine.indirizzoTelematico?.content?.length() == 0) {
                        nessunAltraSegnalazione = true

                        log.debug("intestazione.origine Manca tag IndirizzoTelematico del mittente")

                        segnalazioni.add("Impossibile identificare il mittente, manca il tag "
                                + " IndirizzoTelematico "
                                + " del mittente.")
                    } else {
                        Persona persona = esisteTagPersona(segnatura.intestazione.origine)

                        if (persona != null) {
                            log.debug("intestazione.origine Trovato tag Persona")

                            if (persona.identificativo == null || persona.identificativo?.content == null) {
                                nessunAltraSegnalazione = true
                                if (persona.identificativo == null) {
                                    log.debug("intestazione.origine Manca tag Identificativo")
                                    segnalazioni.add("Impossibile identificare il mittente, manca il tag Identificativo")
                                } else {
                                    log.debug("intestazione.origine Manca tag codice fiscale")
                                    segnalazioni.add("Impossibile identificare il mittente, manca il tag codice fiscale")
                                }
                            } else {
                                corrispondenteMittente = parseOrigineCittadino(segnatura.intestazione.origine, persona)
                            }
                        } else {
                            nessunAltraSegnalazione = true

                            log.debug("intestazione.origine Non ho trovato tag Persona")

                            segnalazioni.add("Impossibile identificare il mittente, manca il tag Persona")
                        }
                    }
                } else {
                    //Origine - Definizione del mittente GENERICO
                    log.debug("intestazione.origine di tipo Standard")

                    corrispondenteMittente = parseOrigine(segnatura.intestazione.origine)
                }

                if (corrispondenteMittente == null && !nessunAltraSegnalazione) {
                    log.debug("intestazione.origine  Nessun mittente individuato")
                    segnalazioni.add("Non è stato possibile individuare il mittente.")
                }
            }

            //Intestazione - Rif doc cartacei
            if (segnatura.intestazione.riferimentoDocumentiCartacei != null) {
                log.debug("intestazione.riferimentoDocumentiCartacei ESISTONO")
                segnalazioni.add("Esistono riferimenti cartacei")
            }

            //Intestazione - Presenza Rif telematici
            esistonoRiferimentiTelematici = (segnatura.intestazione.riferimentiTelematici != null)

            //Intestazione - Oggetto
            log.debug("intestazione.oggetto " + segnatura.intestazione?.oggetto?.content)
            protocollo.oggetto = (segnatura.intestazione?.oggetto?.content == null) ? "." : segnatura.intestazione?.oggetto?.content

            //Intestazione - Note
            log.debug("intestazione.note " + segnatura.intestazione?.note?.content)
            protocollo.note = segnatura.intestazione?.note?.content

            //Intestazione - Riservato
            if (segnaturaCittadino) {
                if (segnatura.intestazione.riservato != null) {
                    String sRiservato = "Richiesta riservatezza"
                    String motivoRiservato = segnatura.intestazione.riservato.content
                    if (!StringUtility.nvl(motivoRiservato, "").equals("")) {
                        sRiservato += ": " + motivoRiservato;
                    } else {
                        sRiservato += "."
                    }
                    if (protocollo.note != null && !protocollo.note?.equals("")) {
                        protocollo.note = protocollo.note + " " + sRiservato
                    } else {
                        protocollo.note = sRiservato
                    }

                    log.debug("intestazione.note Caso riservato cittadino, le note di protocollo diventano " + protocollo.note)
                }
            }

            //Intestazione - Classifica (CASO GLOBO)
            if (isGlobo) {
                parseClassificaGlobo(segnatura.intestazione, protocollo, segnalazioni)
            }
            //Intestazione - Classifica (CASO SEGNATURA CITTADINO)
            else if (segnaturaCittadino) {
                parseClassificaFascicoloCittadino(segnatura.intestazione, protocollo, segnalazioni)
            }

            //Destinazione - Destinatario - Conferma Ricezione e Smistamento
            // oppure PerConoscenza - Destinatario - Conferma Ricezione e Smistamento
            log.debug("intestazione.destinazione")
            List<Smistamento> smistamentoList = null
            boolean smistamentoSuNodoPerConoscenza = false
            for (int i = 0; i <= 1; i++) {
                String tipo = (i == 0) ? "DESTINAZIONE" : "CONOSCENZA"

                log.debug("intestazione.destinazione caso " + tipo)

                if (!protocolloDatiInteroperabilita.richiestaConferma) {
                    log.debug("intestazione.destinazione cerco la richiestaConferma")
                    //Cerco di prenderla per conoscenza solo se non avevo messo SI per il primo giro della destinazione
                    protocolloDatiInteroperabilita.setRichiestaConferma(isConfermaRicezioneDestinazione(segnatura.intestazione, tipo))
                }

                if (smistamentoList == null || smistamentoList?.size() == 0) {
                    //Cerco di smistare per conoscenza soloAGP_PROTOCOLLI_DATI_INTEROP se non avevo smistato per il primo giro della destinazione
                    if (tipo == "CONOSCENZA") {
                        smistamentoSuNodoPerConoscenza = true
                    }

                    smistamentoList = getSmistamentiUnitaOrganizzativaDestinazione(segnatura.intestazione, unitaProtocollante, tipo)
                    for (smistamento in smistamentoList) {
                        protocollo.addToSmistamenti(smistamento)
                    }
                }
            }
            if (smistamentoList?.size() > 0) {
                corrispondenteMittente?.conoscenza = (smistamentoSuNodoPerConoscenza && corrispondenteMittente != null)

                segnalazioni.add("Non è stato possibile identificare l'unità cui smistare")
            }
        }

        //*****RIFERIMENTI
        if (segnatura.riferimenti != null) {
            //PER ADESSO NON LI GESTIAMO PERCHE NON SONO PROT PREC MA MESSAGGI COLLEGATI....POI SI VEDRA'
            /*for (messaggio in segnatura.riferimenti.messaggioOrContestoProceduraleOrProcedimento) {
                if (messaggio instanceof Messaggio) {
                    Messaggio messaggioRiferimento = (Messaggio) messaggio
                    if (messaggioRiferimento.identificatore != null) {

                        String dataReg
                        dataReg = messaggioRiferimento.identificatore.dataRegistrazione?.content
                        Date dataRegistrazione = null
                        if (dataReg != null && !dataReg?.equals("")) {
                            dataRegistrazione = new SimpleDateFormat("yyyy-MM-dd").parse(dataReg)
                        }

                        //qui andrebbe una lista...
                        protocolloPrecedente = protocolloRepository.fingByPrimaRegistrazione(messaggioRiferimento.identificatore.codiceAmministrazione?.content,
                                messaggioRiferimento.identificatore.codiceAOO?.content,
                                dataRegistrazione,
                                messaggioRiferimento.identificatore.numeroRegistrazione?.content,
                                messaggioRiferimento.identificatore.codiceRegistro?.content)
                    }
                }
            }*/
        }

        //*****DESCRIZIONE
        if (segnatura.descrizione != null) {
            log.debug(" ** DESCRIZIONE **")

            parseDescrizione(segnatura, protocollo, messaggioRicevutoDTO, segnalazioni)
        }

        //*****3DEL
        if (ImpostazioniProtocollo.PEC_3DELETTRONICO.valore?.equalsIgnoreCase("Y")) {
            log.debug("segnatura CASO 3DEL")

            tratta3Del(protocollo, messaggioRicevutoDTO)
        }

        //Salvataggi FINALI
        log.debug("segnatura Aggiungo le segnalazioni ai dati interoperabilità")
        protocolloDatiInteroperabilita = protocolloService.aggiungiSegnalazioniProtocolloDatiIterop(protocolloDatiInteroperabilita, segnalazioni)
        //PER ORA NON GESTITO
        /*if (protocolloPrecedente != null) {
            protocolloService.salvaProtocolloPrecedente(protocollo, protocolloPrecedente)
        }*/
        protocolloDatiInteroperabilita.save()
        protocollo.datiInteroperabilita = protocolloDatiInteroperabilita

        if (corrispondenteMittente != null) {
            corrispondentiProtocollo.add(corrispondenteMittente)
        }
        if (corrispondentiProtocollo.size() > 0) {
            log.debug("segnatura Salvo i corrispondenti")
            corrispondenteService.salva(protocollo, corrispondentiProtocollo)
        }

        log.info("segnatura importata - Salvo il protocollo")
        protocollo.save()
    }

    void salvaConfermaRicezione(MessaggioRicevutoDTO messaggioRicevutoDTO, ConfermaRicezione confermaRicezione) {
        log.info("## salvaConfermaRicezione per messaggioRicevuto: " + messaggioRicevutoDTO.id)
        trattaMessaggio(messaggioRicevutoDTO, confermaRicezione.messaggioRicevuto?.identificatore, confermaRicezione.identificatore, CONFERMA);
    }

    void salvaNotificaEccezione(MessaggioRicevutoDTO messaggioRicevutoDTO, NotificaEccezione notificaEccezione) {
        log.info("## salvaNotificaEccezione per messaggioRicevuto: " + messaggioRicevutoDTO.id)
        trattaMessaggio(messaggioRicevutoDTO, notificaEccezione.messaggioRicevuto?.identificatore, notificaEccezione.identificatore, ECCEZIONE);
    }

    void salvaAggiornamentoConferma(MessaggioRicevutoDTO messaggioRicevutoDTO, AggiornamentoConferma aggiornamentoConferma) {
        log.info("## salvaAggiornamentoConferma per messaggioRicevuto: " + messaggioRicevutoDTO.id)
        trattaMessaggio(messaggioRicevutoDTO, aggiornamentoConferma.messaggioRicevuto?.identificatore, aggiornamentoConferma.identificatore, AGGIORNAMENTO);
    }

    void salvaAnnullamentoProtocollazione(MessaggioRicevutoDTO messaggioRicevutoDTO, AnnullamentoProtocollazione annullamentoProtocollazione) {
        log.info("## salvaAnnullamentoProtocollazione per messaggioRicevuto: " + messaggioRicevutoDTO.id)
        trattaMessaggio(messaggioRicevutoDTO, annullamentoProtocollazione.identificatore, annullamentoProtocollazione.identificatore, ANNULLAMENTO);
    }

    void gestisciNotificheAutomatiche(MessaggioRicevutoDTO messaggioRicevutoDTO, String idMessaggioInviato, String destinatarioConsegna, String tipoRicevuta, Date dataDatiCertXmlRicevuta) {
        log.info("## gestisciNotificheAutomatiche con idSi4Cs: " + idMessaggioInviato + " e destinatarioConsegna=" + destinatarioConsegna)
        boolean collegaMessaggi = false
        MessaggioInviato messaggioInviato = null

        if (messaggioRicevutoDTO.oggetto?.contains("[Ricevuta_AUTO]")) {
            log.debug("gestisciNotificheAutomatiche - Oggetto del messaggio ricevuto contiene [Ricevuta_AUTO]: metto lo stato del messaggio ricevuto a SCARTATO")
            messaggioRicevutoDTO.statoMessaggio = it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto.Stato.SCARTATO
        } else {
            log.debug("gestisciNotificheAutomatiche - Oggetto del messaggio ricevuto NON contiene [Ricevuta_AUTO]: metto lo stato del messaggio ricevuto a GESTITO" +
                    " e cerco di aggiornare i flag su AGP_MSG_INVIATI_DATI_PROT e RELATIVI CORRISPONDENTI per il messaggio inviato")
            messaggioRicevutoDTO.statoMessaggio = it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto.Stato.GESTITO

            messaggioInviato = messaggiInviatiService.getMessaggioInviatoByIdSi4Cs(Long.parseLong(idMessaggioInviato))

            if (messaggioInviato == null) {
                log.error("Non riesco a trovare il messaggio inviato nella AGP_MSG_INVIATI_DATI_PROT per idSi4Cs=" + idMessaggioInviato)
                throw new ProtocolloRuntimeException("Non riesco a trovare il messaggio inviato nella AGP_MSG_INVIATI_DATI_PROT per idSi4Cs=" + idMessaggioInviato)
            }

            Protocollo protocolloInPartenza = (Protocollo) documentoCollegatoRepository.collegamentoPadre(messaggioInviato)?.documento

            if (tipoRicevuta == "accettazione") {
                log.debug("registro accettazione su messaggio inviato")
                messaggioInviato.accettazione = true
                messaggioInviato.dataAccettazione = dataDatiCertXmlRicevuta
                messaggioRicevutoDTO.tipo = "RICEVUTA_ACCETTAZIONE"
                messaggiInviatiService.salva(messaggioInviato)

                if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("conferma.xml") && protocolloInPartenza != null) {
                    if (protocolloInPartenza.datiInteroperabilita == null) {
                        protocolloInPartenza.datiInteroperabilita = new ProtocolloDatiInteroperabilita()
                    }
                    protocolloInPartenza.datiInteroperabilita.ricevutaAccettazioneConferma = true
                    protocolloInPartenza.datiInteroperabilita.save()
                }
                collegaMessaggi = true
            } else if (tipoRicevuta == "non-accettazione") {
                log.debug("registro non accettazione su messaggio inviato")
                messaggioInviato.nonAccettazione = false
                messaggioInviato.dataNonAccettazione = dataDatiCertXmlRicevuta
                messaggioRicevutoDTO.tipo = "RICEVUTA_NONACCETTAZIONE"
                messaggiInviatiService.salva(messaggioInviato)
                collegaMessaggi = true
            } else {
                log.debug("Cerco il corrispondente messaggio per " + destinatarioConsegna)
                collegaMessaggi = true
                Messaggio messaggio = Messaggio.findById(messaggioInviato.id)

                if (messaggio == null) {
                    log.error("Attenzione! non trovo il messaggio nella agp_messaggi con id: " + messaggioInviato.id)
                    throw new ProtocolloRuntimeException("Attenzione! non trovo il messaggio nella agp_messaggi con id: " + messaggioInviato.id)
                }

                List<CorrispondenteMessaggio> corrispondenteMessaggioList = corrispondenteMessaggioService.getCorrispondenteMessaggio(messaggio, destinatarioConsegna)

                if (corrispondenteMessaggioList != null) {
                    for (corrispondenteMessaggio in corrispondenteMessaggioList) {
                        if (tipoRicevuta == "avvenuta-consegna") {
                            if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("conferma.xml")) {
                                corrispondenteMessaggio.registrazioneConsegnaConferma = true
                                corrispondenteMessaggio.dataConsegnaConferma = dataDatiCertXmlRicevuta
                                messaggioRicevutoDTO.tipo = "RICEVUTA_AVVENUTA_CONSEGNA_CONFERMA"
                            } else if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("aggiornamento.xml")) {
                                corrispondenteMessaggio.registrazioneConsegnaAggiornamento = true
                                messaggioRicevutoDTO.tipo = "RICEVUTA_AVVENUTA_CONSEGNA_AGGIORNAMENTO"
                                corrispondenteMessaggio.dataConsegnaAggiornamento = dataDatiCertXmlRicevuta
                            } else if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("annullamento.xml")) {
                                corrispondenteMessaggio.registrazioneConsegnaAnnullamento = true
                                corrispondenteMessaggio.dataConsegnaAnnullamento = dataDatiCertXmlRicevuta
                                messaggioRicevutoDTO.tipo = "RICEVUTA_AVVENUTA_CONSEGNA_ANNULLAMENTO"
                            } else if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("eccezione.xml")) {
                                messaggioRicevutoDTO.tipo = "RICEVUTA_AVVENUTA_CONSEGNA_ECCEZIONE"
                                //Non setto nulla
                            } else {
                                corrispondenteMessaggio.registrataConsegna = true
                                corrispondenteMessaggio.dataConsegna = dataDatiCertXmlRicevuta
                            }
                        } else if (tipoRicevuta == "errore-consegna") {
                            if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("conferma.xml")) {
                                corrispondenteMessaggio.ricevutaMancataConsegnaConferma = true
                                corrispondenteMessaggio.dataMancataConsegnaConferma = dataDatiCertXmlRicevuta
                                messaggioRicevutoDTO.tipo = "RICEVUTA_ERRORE_CONSEGNA_CONFERMA"
                            } else if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("aggiornamento.xml")) {
                                corrispondenteMessaggio.ricevutaMancataConsegnaAggiornamento = true
                                corrispondenteMessaggio.dataMancataConsegnaAggiornamento = dataDatiCertXmlRicevuta
                                messaggioRicevutoDTO.tipo = "RICEVUTA_ERRORE_CONSEGNA_AGGIORNAMENTO"
                            } else if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("annullamento.xml")) {
                                corrispondenteMessaggio.ricevutaMancataConsegnaAnnullamento = true
                                corrispondenteMessaggio.dataMancataConsegnaAnnullamento = dataDatiCertXmlRicevuta
                                messaggioRicevutoDTO.tipo = "RICEVUTA_ERRORE_CONSEGNA_ANNULLAMENTO"
                            } else if (messaggioRicevutoDTO?.oggetto?.toLowerCase()?.endsWith("eccezione.xml")) {
                                messaggioRicevutoDTO.tipo = "RICEVUTA_ERRORE_CONSEGNA_ECCEZIONE"
                                //Non setto nulla
                            } else {
                                corrispondenteMessaggio.ricevutaMancataConsegna = true
                                corrispondenteMessaggio.dataMancataConsegna = dataDatiCertXmlRicevuta
                            }
                        }
                        corrispondenteMessaggio.save()
                    }
                } else {
                    log.debug("Corrispondente non trovato!")
                }
            }
        }

        messaggiRicevutiService.salva(messaggioRicevutoDTO, null)
        if (collegaMessaggi) {
            messaggiInviatiService.collegaMessaggioInviatoAMessaggioRicevuto(messaggioInviato, messaggioRicevutoDTO.domainObject)
        }
    }

    private CorrispondenteDTO parseOrigine(Origine origine) {
        log.debug("intestazione.origine parseOrigine")

        CorrispondenteDTO corrispondenteRet = null
        List<CorrispondenteDTO> corrispondenteDTOList = null

        if (ImpostazioniProtocollo.IS_ENTE_INTERPRO.valore == "Y" && origine.mittente?.privato != null) {
            log.debug("intestazione.origine caso interpro")

            corrispondenteDTOList = corrispondenteService.ricercaDestinatari(null, false, null, null, null,
                    null, null, null, it.finmatica.protocollo.corrispondenti.TipoSoggetto.get(10).toDTO(), null, null,
                    null,
                    null,
                    null,
                    origine.mittente.privato.identificativo, true)
        } else {
            corrispondenteDTOList = corrispondenteService.ricercaDestinatari(null, false, null, null, null,
                    null, null, null, null, null, null,
                    origine.mittente?.amministrazione?.codiceAmministrazione?.content,
                    origine.mittente?.AOO?.codiceAOO?.content,
                    origine.mittente.amministrazione?.unitaOrganizzativa?.identificativo?.content, null, true)
        }

        log.debug("intestazione.origine Trovati corrispondenti n. " + corrispondenteDTOList?.size())

        if (corrispondenteDTOList?.size() == 1) {
            corrispondenteRet = corrispondenteDTOList.get(0)
        }

        return corrispondenteRet
    }

    private CorrispondenteDTO parseOrigineCittadino(Origine origine, Persona persona) {
        CorrispondenteDTO corrispondenteRet = null
        List<CorrispondenteDTO> corrispondenteDTOList = null

        log.debug("intestazione.origine parseOrigineCittadino")

        String indirizzoTelematico = origine.indirizzoTelematico.content.trim().toUpperCase()

        corrispondenteDTOList = corrispondenteService.ricercaPiDenom(persona.identificativo.content,
                persona?.denominazione?.content, true)

        log.debug("intestazione.origine Trovati corrispondenti n. " + corrispondenteDTOList?.size())

        if (corrispondenteDTOList?.size() == 1) {
            corrispondenteRet = corrispondenteDTOList.get(0)
        }

        if (corrispondenteRet == null) {
            log.debug("intestazione.origine Cerco di creare il corrispondente dai dati dell'xml")

            //Se non ho trovato nulla lo creo con i dati che ho a disposizione
            corrispondenteRet = creaCorrispondenteCittadino(origine, persona)
        }

        return corrispondenteRet
    }

    private CorrispondenteDTO parseOrigineGloboStarch(Origine origine) {
        CorrispondenteDTO corrispondenteRet = null

        if (origine.mittente?.amministrazione?.unitaOrganizzativa?.denominazione != null) {
            String codfiscOrPiva, denomimazione

            codfiscOrPiva = origine.mittente?.amministrazione?.codiceAmministrazione?.content?.trim()
            denomimazione = origine.mittente?.amministrazione?.denominazione?.content?.trim()

            log.debug("intestazione.origine codfiscOrPiva: " + codfiscOrPiva)
            log.debug("intestazione.origine denomimazione: " + denomimazione)

            if (codfiscOrPiva?.length() > 0) {
                //Cerco per Piva/CodFisc
                List<CorrispondenteDTO> corrispondenteDTOList =
                        corrispondenteService.ricercaDestinatari(codfiscOrPiva, true, null, null, null,
                                null, null, null, null, null, null,
                                null, null, null, null, true)

                log.debug("intestazione.origine Trovati numero corrispondenti: " + corrispondenteDTOList?.size())

                if (corrispondenteDTOList?.size() == 1) {
                    corrispondenteRet = corrispondenteDTOList.get(0)
                }
            }

            if (denomimazione?.length() > 0 && corrispondenteRet == null) {
                //Cerco per Denominazione
                List<CorrispondenteDTO> corrispondenteDTOList =
                        corrispondenteService.ricercaDestinatari(denomimazione, true, null, null, null,
                                null, null, null, null, null, null,
                                null, null, null, null, true)

                log.debug("intestazione.origine Trovati numero corrispondenti: " + corrispondenteDTOList?.size())

                if (corrispondenteDTOList?.size() == 1) {
                    corrispondenteRet = corrispondenteDTOList.get(0)
                }
            }

            if (corrispondenteRet == null) {
                log.debug("intestazione.origine Cerco di creare il corrispondente dai dati dell'xml")

                //Se non ho trovato nulla lo creo con i dati che ho a disposizione
                corrispondenteRet = creaCorrispondenteGloboStarch(origine)
            }
        }

        return corrispondenteRet
    }

    private CorrispondenteDTO creaCorrispondenteGloboStarch(Origine origine) {
        CorrispondenteDTO corrispondenteRet = null
        boolean isPersonaFisica

        String codfiscOrPiva, denomimazione
        UnitaOrganizzativa uo = origine.mittente?.amministrazione?.unitaOrganizzativa

        if (uo?.denominazione?.content != null) {
            corrispondenteRet = new CorrispondenteDTO()

            codfiscOrPiva = origine.mittente?.amministrazione?.codiceAmministrazione?.content?.trim()
            denomimazione = origine.mittente?.amministrazione?.denominazione?.content?.trim()
            isPersonaFisica = (uo?.denominazione?.content?.toString()?.trim()?.toLowerCase()?.equals("Persona Fisica"))

            //COGNOME E NOME
            if (isPersonaFisica) {
                if (uo?.ruoloOrPersona?.size() > 0) {
                    Persona persona = (Persona) uo.ruoloOrPersona.get(0)

                    if (persona != null) {
                        corrispondenteRet.cognome = persona.cognome
                        corrispondenteRet.nome = persona.nome
                    } else {
                        corrispondenteRet.cognome = denomimazione
                    }
                } else {
                    corrispondenteRet.cognome = denomimazione
                }
            } else {
                corrispondenteRet.cognome = denomimazione
            }

            //INDIRIZZO
            if (uo.indirizzoPostale != null) {
                String indirizzo = null, cap = null, comune = null, provincia = null
                if (uo.indirizzoPostale.denominazione != null) {
                    indirizzo = uo.indirizzoPostale.denominazione?.content?.trim()
                } else {
                    if (uo.indirizzoPostale.indirizzo != null) {
                        if (uo.indirizzoPostale.indirizzo.toponimo != null) {
                            String dug, toponimo, civico
                            dug = uo.indirizzoPostale.indirizzo.toponimo.dug?.trim()
                            toponimo = uo.indirizzoPostale.indirizzo.toponimo.content?.trim()
                            civico = uo.indirizzoPostale.indirizzo.civico?.content?.trim()

                            indirizzo = ((dug == null) ? "" : dug) + ((toponimo == null) ? "" : " " + toponimo) +
                                    ((civico == null) ? "" : " " + civico)
                        }

                        cap = uo.indirizzoPostale.indirizzo.CAP?.content?.trim()
                        comune = uo.indirizzoPostale.indirizzo.comune?.content?.trim()
                        provincia = uo.indirizzoPostale.indirizzo.provincia?.content?.trim()
                    }
                }

                corrispondenteRet.indirizzo = indirizzo
                corrispondenteRet.cap = cap
                corrispondenteRet.comune = comune
                corrispondenteRet.provinciaSigla = provincia
            }

            //TELEFONO??? MANCA NEI CORRISPONDENTI....todo parla con mia

            corrispondenteRet.fax = uo.fax?.get(0)?.content?.trim()
            corrispondenteRet.email = origine.indirizzoTelematico?.content?.trim()

            if (codfiscOrPiva != null) {
                if (codfiscOrPiva.length() == 16) {
                    corrispondenteRet.codiceFiscale = codfiscOrPiva
                } else {
                    corrispondenteRet.partitaIva = codfiscOrPiva
                }
            }
            corrispondenteRet.denominazione = denomimazione
        }

        return corrispondenteRet
    }

    private CorrispondenteDTO creaCorrispondenteCittadino(Origine origine, Persona persona) {
        CorrispondenteDTO corrispondenteRet = new CorrispondenteDTO()

        if (persona.denominazione != null) {
            corrispondenteRet.denominazione = persona.denominazione?.content?.trim()
        } else {
            corrispondenteRet.cognome = persona.cognome?.content?.trim()
            corrispondenteRet.nome = persona.nome?.content?.trim()
        }

        corrispondenteRet.codiceFiscale = persona.identificativo?.content?.trim()?.substring(3)

        String indirizzo = origine.mittente.amministrazione?.indirizzoPostale?.denominazione?.content?.trim()
        if (indirizzo == null) {
            indirizzo = origine.mittente.amministrazione?.indirizzoPostale?.indirizzo?.toponimo?.content?.trim()?.toUpperCase()

            if (indirizzo != null) {
                String civico = origine.mittente.amministrazione?.indirizzoPostale?.indirizzo?.civico?.content?.trim()?.toUpperCase()

                if (civico != null) {
                    indirizzo += " " + civico
                }
            }
        }
        corrispondenteRet.indirizzo = indirizzo

        corrispondenteRet.comune = origine.mittente.amministrazione?.indirizzoPostale?.indirizzo?.comune?.content?.trim()?.toUpperCase()

        corrispondenteRet.provinciaSigla = origine.mittente.amministrazione?.indirizzoPostale?.indirizzo?.provincia?.content?.trim()?.toUpperCase()

        corrispondenteRet.cap = origine.mittente.amministrazione?.indirizzoPostale?.indirizzo?.CAP?.content?.trim()

        corrispondenteRet.fax = origine.mittente.amministrazione?.fax?.get(0)?.content?.trim()

        corrispondenteRet.email = origine.indirizzoTelematico?.content?.trim()

        return corrispondenteRet
    }

    private void parseClassificaGlobo(Intestazione intestazione, Protocollo protocollo, List<String> segnalazioni) {
        log.debug("intestazione.classifica Caso Globo")

        String classificaStr = null
        if (intestazione.classifica != null && intestazione.classifica?.size() > 0) {
            for (classifica in intestazione.classifica) {
                if (classifica.livello != null && classifica.livello?.size() > 0) {
                    for (livello in classifica.livello) {
                        if (livello.content?.length() > 0) {
                            classificaStr = livello.content
                            //Prendo la prima che trovo
                            break;
                        }
                    }
                }

                if (classificaStr != null) {
                    //Prendo la prima che trovo
                    break;
                }
            }
        }

        log.debug("intestazione.classifica Classifica trovata in xml " + classificaStr)

        if (classificaStr != null) {
            Classificazione classificazione = classificazioneRepository.findTopByCodice(classificaStr, new PageRequest(0, 1)).first()
            if (classificazione == null) {
                log.debug("intestazione.classifica Classifica non presente sul database")
                segnalazioni.add("La classificazione non è presente nel Titolario corrente oppure risulta non in uso")
            } else {
                protocollo.classificazione = classificazione
            }
        } else {
            if (ImpostazioniProtocollo.CLASS_OB.valore == "Y") {
                segnalazioni.add("E' Obbligatorio indicare una Classificazione.")
            }
            if (ImpostazioniProtocollo.FASC_OB.valore == "Y") {
                segnalazioni.add("E' Obbligatorio indicare un Fascicolo.")
            }
        }
    }

    private void parseClassificaFascicoloCittadino(Intestazione intestazione, Protocollo protocollo, List<String> segnalazioni) {
        log.debug("intestazione.classifica Caso Cittadino")

        String sClassificazione = null
        if (intestazione.classifica != null && intestazione.classifica?.size() > 0) {
            Classifica classificaAmmAoo = intestazione.classifica?.find {
                it.codiceAOO != null && it.codiceAmministrazione != null
            }
            if (classificaAmmAoo != null) {
                // se l'aoo non è stata indicata o è quella che sta eseguendo lo scarico
                // vado avanti con la lettura dei dati di titolario
                if (!classificaAmmAoo.codiceAmministrazione.content?.equals("") &&
                        !classificaAmmAoo.codiceAOO.content?.equals("")) {
                    it.finmatica.gestionedocumenti.commons.Ente ente = springSecurityService.getPrincipal().getEnte()

                    if (!classificaAmmAoo.codiceAmministrazione.content.equals(ente.amministrazione?.codice) &&
                            !classificaAmmAoo.codiceAOO.content.equals(ente.aoo)) {
                        return
                    }
                }
            }

            for (classifica in intestazione.classifica) {
                if (classifica.livello != null && classifica.livello?.size() > 0) {
                    for (livello in classifica.livello) {
                        if (livello.content?.length() > 0) {
                            if (sClassificazione == null) {
                                sClassificazione = livello.content.trim();
                            } else {
                                sClassificazione += ImpostazioniProtocollo.SEP_CLASSIFICA.valore + livello.content.trim();
                            }
                        }
                    }
                }
            }
        }

        log.debug("intestazione.classifica Classifica trovata in xml " + sClassificazione)

        if (sClassificazione != null) {
            Classificazione classificazione = classificazioneRepository.findTopByCodice(sClassificazione, new PageRequest(0, 1)).first()
            if (classificazione == null) {
                log.debug("intestazione.classifica Classifica non presente sul database")

                segnalazioni.add("La classificazione non è presente nel Titolario corrente oppure risulta non in uso")
            } else {
                protocollo.classificazione = classificazione

                log.debug("intestazione.classifica Cerco il fascicoloArchi")

                //Cerco adesso il fascicolo visto che ho trovato la classificazione
                FascicoloArchi fascicoloArchi = intestazione.classifica.find {
                    it.fascicoloArchi != null
                }?.fascicoloArchi

                if (fascicoloArchi != null && !fascicoloArchi?.annoFascicolo?.equals("")) {
                    log.debug("intestazione.classifica Trovato fascicoloArchi in xml - anno " +
                            fascicoloArchi.annoFascicolo + " numero " + fascicoloArchi.numeroFascicolo)

                    Fascicolo fascicolo = fascicoloRepository.getFascicolo(classificazione.id,
                            Integer.parseInt(fascicoloArchi.annoFascicolo), fascicoloArchi.numeroFascicolo)

                    if (fascicolo != null) {
                        protocollo.fascicolo = fascicolo

                        log.debug("intestazione.classifica Trovato fascicolo sul database")

                        if (fascicolo.dataChiusura != null) {
                            log.debug("intestazione.classifica il fascicolo sul database è chiuso con data " + fascicolo.dataChiusura)

                            if (ImpostazioniProtocollo.FASC_OB.valore == "Y") {
                                segnalazioni.add("E' Obbligatorio indicare un Fascicolo aperto.")
                            }
                        }
                    } else {
                        log.debug("intestazione.classifica Fascicolo non presente sul database")

                        segnalazioni.add("Il Fascicolo non è presente nel Titolario corrente")
                    }
                } else {
                    if (ImpostazioniProtocollo.FASC_OB.valore == "Y") {
                        segnalazioni.add("E' Obbligatorio indicare un Fascicolo.")
                    }
                }
            }
        } else {
            if (ImpostazioniProtocollo.CLASS_OB.valore == "Y") {
                segnalazioni.add("E' Obbligatorio indicare una Classificazione.")
            }
            if (ImpostazioniProtocollo.FASC_OB.valore == "Y") {
                segnalazioni.add("E' Obbligatorio indicare un Fascicolo.")
            }
        }
    }

    private boolean isConfermaRicezioneDestinazione(Intestazione intestazione, String tipo) {
        boolean confermaRicezione = false
        boolean bEsisteNodo = false

        bEsisteNodo = (tipo == "DESTINAZIONE") ? (intestazione?.destinazione?.size() > 0) : (intestazione?.perConoscenza?.size() > 0)

        if (bEsisteNodo) {
            for (destinazione in ((tipo == "DESTINAZIONE") ? intestazione.destinazione : intestazione.perConoscenza)) {
                if (destinazione.confermaRicezione?.toLowerCase()?.equals("si")) {
                    for (destinatario in destinazione.destinatario) {
                        String codAoo = destinatario?.aoo?.codiceAOO?.content
                        String codAmm = destinatario?.amministrazione?.codiceAmministrazione?.content

                        if (codAoo?.length() > 0 && codAmm?.length() > 0) {
                            if (it.finmatica.gestionedocumenti.commons.Ente.perAmministrazioneOtticaAoo(codAmm.toUpperCase(), Impostazioni.OTTICA_SO4.valore, codAoo?.toUpperCase())?.get() != null) {
                                confermaRicezione = true
                                break;
                            }
                        }
                    }
                }

                if (confermaRicezione) {
                    break;
                }
            }
        }

        return confermaRicezione
    }

    private List<Smistamento> getSmistamentiUnitaOrganizzativaDestinazione(Intestazione intestazione, So4UnitaPubb unitaProtocollante, String tipo) {
        List<Smistamento> smistamentoList = new ArrayList<Smistamento>()
        boolean bEsisteNodo = false

        bEsisteNodo = (tipo == "DESTINAZIONE") ? (intestazione?.destinazione?.size() > 0) : (intestazione?.perConoscenza?.size() > 0)

        if (bEsisteNodo) {
            log.debug("intestazione.destinazione esiste il nodo " + tipo)

            for (destinazione in ((tipo == "DESTINAZIONE") ? intestazione.destinazione : intestazione.perConoscenza)) {
                for (destinatario in destinazione.destinatario) {
                    if (destinatario.amministrazione?.unitaOrganizzativa != null) {
                        String codUo = destinatario.amministrazione?.unitaOrganizzativa?.identificativo?.content
                        String denominazioneAoo = destinatario.amministrazione?.unitaOrganizzativa?.denominazione?.content
                        String codAmm = destinatario?.amministrazione?.codiceAmministrazione?.content

                        log.debug("intestazione.destinazione codUo " + codUo)
                        log.debug("intestazione.destinazione denominazioneAoo " + denominazioneAoo)
                        log.debug("intestazione.destinazione codAmm " + codAmm)

                        So4Amministrazione amministrazione = So4Amministrazione.findByCodice(codAmm)
                        So4UnitaPubb unitaSmistamento
                        if (amministrazione != null) {
                            if (codUo != null) {
                                unitaSmistamento = So4UnitaPubb.allaData().findByCodiceAndAmministrazione(codUo, amministrazione)
                            }
                            if (unitaSmistamento == null && denominazioneAoo != null) {
                                unitaSmistamento = So4UnitaPubb.allaData().findByDescrizioneAndAmministrazione(denominazioneAoo, amministrazione)
                            }
                        }

                        log.debug("intestazione.destinazione unitaSmistamento " + unitaSmistamento)

                        if (unitaSmistamento != null) {
                            log.debug("intestazione.destinazione Effettuo smistamento per COMPETENZA ad unità trovata")

                            smistamentoList.add(new Smistamento(tipoSmistamento: Smistamento.COMPETENZA, dataSmistamento: new Date(),
                                    statoSmistamento: Smistamento.CREATO, unitaTrasmissione: unitaProtocollante,
                                    unitaSmistamento: unitaSmistamento))
                        }
                    }
                }
            }
        }

        return smistamentoList
    }

    private void parseDescrizione(Segnatura segnatura, Protocollo protocollo, MessaggioRicevutoDTO messaggioRicevutoDTO, List<String> segnalazioni) {
        List<String> listaNomiFileMimeSegnatura = new ArrayList<String>()
        String nomeFileMimeTrovatoInSegnatura

        if (segnatura.descrizione.documento != null) {
            log.debug("segnatura.descrizione.documento")

            try {
                nomeFileMimeTrovatoInSegnatura = parseDocumento(segnatura, segnatura.descrizione.documento, protocollo, messaggioRicevutoDTO, segnalazioni, true)
                if (nomeFileMimeTrovatoInSegnatura != null) {
                    listaNomiFileMimeSegnatura.add(nomeFileMimeTrovatoInSegnatura.replaceAll("\\s+", "").toLowerCase())
                }
            }
            catch (Exception e) {
                segnalazioni.add("Errore in parse documento principale. Errore :" + e.getMessage())
            }
        } else {
            try {
                if (segnatura.descrizione.testoDelMessaggio != null) {
                    log.debug("segnatura.descrizione.testoDelMessaggio")

                    FileDocumento fileDocumentoTestoMessaggio = new FileDocumento()
                    String nomeFile, mimeTesto, contentType = null
                    mimeTesto = messaggioRicevutoDTO.mimeTesto
                    if (mimeTesto == null || mimeTesto != "text/plain" || mimeTesto != "text/html") {
                        nomeFile = StringUtility.nvl(ImpostazioniProtocollo.NOME_FILE_TESTO_MESSAGGIO.valore, "TestodelMessaggioParametri.html")
                        contentType = "text/html"
                    } else {
                        if (mimeTesto == "text/plain") {
                            nomeFile = "TestodelMessaggioParametri.txt"
                            contentType = "text/plain"
                        } else {
                            nomeFile = "TestodelMessaggioParametri.html"
                            contentType = "text/html"
                        }
                    }

                    fileDocumentoTestoMessaggio.contentType = contentType
                    fileDocumentoTestoMessaggio.nome = nomeFile
                    fileDocumentoTestoMessaggio.codice = Protocollo.FILE_DA_MAIL

                    gestoreFile.addFile(protocollo, fileDocumentoTestoMessaggio, new ByteArrayInputStream(StringUtility.nvl(messaggioRicevutoDTO.testo, "").getBytes()))
                }
            }
            catch (Exception e) {
                segnalazioni.add("Errore in parse testoDelMessaggio. Errore :" + e.getMessage())
            }
        }
        if (segnatura.descrizione.allegati != null) {
            log.debug("segnatura.descrizione.allegati")

            for (documentoOrFascicolo in segnatura.descrizione.allegati?.documentoOrFascicolo) {
                if (documentoOrFascicolo instanceof Documento) {
                    int numAllegato = 1
                    try {
                        nomeFileMimeTrovatoInSegnatura = parseDocumento(segnatura, documentoOrFascicolo, protocollo, messaggioRicevutoDTO, segnalazioni, false)

                        if (nomeFileMimeTrovatoInSegnatura != null) {
                            listaNomiFileMimeSegnatura.add(nomeFileMimeTrovatoInSegnatura.replaceAll("\\s+", "").toLowerCase())
                        }

                        numAllegato++
                    }
                    catch (Exception e) {
                        segnalazioni.add("Errore in parse documento allegato numero " + numAllegato + ". Errore :" + e.getMessage())
                    }
                }
            }
        }

        //Controllo finale: verifica che tutti i file presenti (ad eccezione del file di segnatura stesso)
        // nella mail siano presenti in segnatura e viceversa, se così non è lo aggiunge alle segnalazioni
        log.debug("segnatura.descrizione Controllo finale: verifica che tutti i file presenti (ad eccezione del file di segnatura stesso) " +
                "nella mail siano presenti in segnatura e viceversa, se così non è lo aggiunge alle segnalazioni.\n" +
                "        Lista file segnatura con cui confrontare: " + listaNomiFileMimeSegnatura)

        for (fileMessaggio in messaggioRicevutoDTO.getFileDocumenti()) {
            if (fileMessaggio.nome.equalsIgnoreCase("segnatura.xml") ||
                    fileMessaggio.nome.equalsIgnoreCase("segnatura_cittadino.xml") ||
                    fileMessaggio.codice == FileDocumento.CODICE_FILE_EML) {
                continue
            }

            String nomeFileInMessaggio
            nomeFileInMessaggio = fileMessaggio.nome.replaceAll("\\s+", "").toLowerCase()
            if (!listaNomiFileMimeSegnatura.contains(nomeFileInMessaggio)) {
                log.debug("segnatura.descrizione Controllo finale. File Messaggio: " + fileMessaggio.nome + " NON PRESENTE in segnatura")
                segnalazioni.add("Il messaggio di posta contiene l'allegato " + fileMessaggio.nome + " non presente in segnatura.")
            } else {
                log.debug("segnatura.descrizione Controllo finale. File Messaggio: " + fileMessaggio.nome + " PRESENTE in segnatura")
            }
        }
    }

    private String parseDocumento(Segnatura segnatura, Documento documento, Protocollo protocollo, MessaggioRicevutoDTO messaggioRicevutoDTO, List<String> segnalazioni, boolean isPrincipale) {
        String nodoDebug
        if (isPrincipale) {
            nodoDebug = "segnatura.descrizione.documento"
        } else {
            nodoDebug = "segnatura.descrizione.allegati"
        }
        log.debug(nodoDebug + " parseDocumento")

        String nomeFileMimeTrovatoInSegnatura = null

        Allegato allegato = null
        if (!isPrincipale) {
            allegato = new Allegato()
            allegato.tipoAllegato = TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)
        }

        //TipoDocumento
        if (documento.tipoDocumento?.content != null) {
            log.debug(nodoDebug + " TipoDocumento: " + documento.tipoDocumento?.content)

            if (isPrincipale) {
                List<SchemaProtocollo> schemaProtocolloList = schemaProtocolloService.ricerca(documento.tipoDocumento.content, Protocollo.MOVIMENTO_ARRIVO)
                if (schemaProtocolloList.size() > 0) {
                    protocollo.schemaProtocollo = schemaProtocolloList.get(0)
                } else {
                    log.debug(nodoDebug + " TipoDocumento non trovato sul database")
                    segnalazioni.add("Non è stato possibile identificare il tipo documento " + documento.tipoDocumento.content)
                }
            } else {
                TipoAllegato tipoAllegato = TipoAllegato.findByAcronimo(documento.tipoDocumento.content)
                if (tipoAllegato == null) {
                    tipoAllegato = TipoAllegato.findByDescrizione(documento.tipoDocumento.content)
                }

                if (tipoAllegato != null) {
                    allegato.tipoAllegato = tipoAllegato
                }
            }
        }

        //TipoRiferimento e FILE
        String tipoRiferimento
        tipoRiferimento = (documento?.tipoRiferimento == null) ? ProtocolloSegnaturaService.TIPO_RIFERIMENTO_MIME : documento?.tipoRiferimento

        log.debug(nodoDebug + " tipoRiferimento: " + tipoRiferimento)

        if (tipoRiferimento.equalsIgnoreCase(ProtocolloSegnaturaService.TIPO_RIFERIMENTO_MIME) && messaggioRicevutoDTO != null) {
            //GESTIONE DOCUMENTO FISICO + FIRMA
            if (documento.nome != null) {
                nomeFileMimeTrovatoInSegnatura = documento.nome

                log.debug(nodoDebug + ".nome: " + nomeFileMimeTrovatoInSegnatura)

                String nomeFileTrim = documento.nome.replaceAll("\\s+", "")
                FileDocumentoDTO fileDocumentoDTOMessaggio = messaggioRicevutoDTO.fileDocumenti?.find {
                    it.nome?.replaceAll("\\s+", "")?.equalsIgnoreCase(nomeFileTrim)
                }

                if (fileDocumentoDTOMessaggio != null) {
                    log.debug(nodoDebug + ".nome Trovato il file nel messaggio")

                    if (isPrincipale) {
                        //CASO FILE PRINCIPALE
                        boolean firmato = false
                        boolean verificato = false
                        String erroreFirma
                        List<VerificatoreFirma.RisultatoVerifica> listaRisultati

                        log.debug(nodoDebug + ".nome Verifica della firma")

                        if (allegatoProtocolloService.isFirmato(messaggioRicevutoDTO.domainObject, fileDocumentoDTOMessaggio.domainObject)) {
                            try {
                                listaRisultati = allegatoProtocolloService.getFirmatari(messaggioRicevutoDTO.domainObject, fileDocumentoDTOMessaggio.domainObject)
                                firmato = (listaRisultati?.size() > 0)
                                verificato = (listaRisultati?.size() == 0) ? false : !listaRisultati?.find {
                                    !it.valida
                                }
                            }
                            catch (Exception e) {
                                erroreFirma = e.getMessage()
                            }
                        }

                        log.debug(nodoDebug + ".nome firmato: " + firmato)
                        log.debug(nodoDebug + ".nome verificato: " + verificato)
                        log.debug(nodoDebug + ".nome erroreFirma: " + erroreFirma)
                        log.debug(nodoDebug + ".nome idFileEsterno: " + idFileEsterno)

                        FileDocumento fileDocumentoProtocollo = new FileDocumento()
                        fileDocumentoProtocollo.contentType = fileDocumentoDTOMessaggio.contentType
                        fileDocumentoProtocollo.idFileEsterno = fileDocumentoDTOMessaggio.idFileEsterno
                        fileDocumentoProtocollo.nome = fileDocumentoDTOMessaggio.nome
                        fileDocumentoProtocollo.documento = protocollo
                        fileDocumentoProtocollo.firmato = firmato
                        fileDocumentoProtocollo.codice = FileDocumento.CODICE_FILE_PRINCIPALE

                        log.debug(nodoDebug + ".nome Aggiungo il file (principale) al protocollo")
                        protocollo.addToFileDocumenti(fileDocumentoProtocollo)

                        if (erroreFirma != null) {
                            protocollo.esitoVerifica = Protocollo.ESITO_NON_VERIFICATO
                            segnalazioni.add("Fallita verifica firma documento principale: " + erroreFirma)
                        } else {
                            if (!firmato) {
                                // Se l'impostazione FIRMA_RIC_AMM vale Y oppure fra i destinatari esiste almeno
                                // un soggetto non amministrazione ed il parametro FIRMA_RIC_SOG vale Y, aggiunge la segnalazione
                                // "Documento principale non firmato"
                                if ((ImpostazioniProtocollo.FIRMA_RIC_AMM.valore == "Y" && segnatura.intestazione?.destinazione?.find {
                                    it.destinatario?.find { it.amministrazione != null }
                                }) ||
                                        (ImpostazioniProtocollo.FIRMA_RIC_SOG.valore == "Y" && segnatura.intestazione?.destinazione?.find {
                                            !it.destinatario?.find { it.amministrazione != null }
                                        })) {
                                    segnalazioni.add("Documento principale non firmato")
                                }
                            } else {
                                protocollo.esitoVerifica = (verificato) ? Protocollo.ESITO_VERIFICATO : Protocollo.ESITO_NON_VERIFICATO
                                if (verificato) {
                                    protocollo.dataVerifica = new Date()
                                }
                            }
                        }
                    } else {
                        //CASO FILE ALLEGATO
                        FileDocumento fileDocumentoAllegato = new FileDocumento()
                        fileDocumentoAllegato.contentType = fileDocumentoDTOMessaggio.contentType
                        fileDocumentoAllegato.idFileEsterno = fileDocumentoDTOMessaggio.idFileEsterno
                        fileDocumentoAllegato.nome = fileDocumentoDTOMessaggio.nome
                        fileDocumentoAllegato.documento = protocollo
                        fileDocumentoAllegato.codice = FileDocumento.CODICE_FILE_ALLEGATO
                        fileDocumentoAllegato.sequenza = 0

                        log.debug(nodoDebug + ".nome idFileEsterno: " + idFileEsterno)

                        allegato.descrizione = fileDocumentoDTOMessaggio.nome
                        allegato.statoFirma = (fileDocumentoDTOMessaggio.nome.toLowerCase().indexOf(".p7m") != -1) ? StatoFirma.FIRMATO : StatoFirma.DA_NON_FIRMARE
                        allegato.sequenza = documentoService.getSequenzaNuovoAllegato(protocollo.toDTO())
                        allegato.addToFileDocumenti(fileDocumentoAllegato)
                        allegato.save()
                        protocollo.addDocumentoAllegato(allegato)

                        it.finmatica.smartdoc.api.struct.Documento documentoSmart = integrazioneDocumentaleService.salva(allegato)

                        allegato.idDocumentoEsterno = Long.parseLong(documentoSmart.id)
                        allegato.save()

                        if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                            fileDocumentoService.aggiornaVerificaFirma(fileDocumentoAllegato)
                            allegato.addToFileDocumenti(fileDocumentoAllegato)
                        }

                        log.debug(nodoDebug + ".nome Aggiungo l'allegato al protocollo")
                    }
                }
            }
        } else if (tipoRiferimento.equalsIgnoreCase(ProtocolloSegnaturaService.TIPO_RIFERIMENTO_TELEMATICO)) {
            //GESTIONE DOCUMENTO TELEMATICO
            String collocazioneTelematica
            collocazioneTelematica = documento.collocazioneTelematica?.content
            if (collocazioneTelematica != null) {
                log.debug(nodoDebug + ".collocazioneTelematica: " + collocazioneTelematica)

                if (collocazioneTelematica.toLowerCase().indexOf("http:") != -1 || collocazioneTelematica.toLowerCase().indexOf("https:") != -1
                        || collocazioneTelematica.toLowerCase().indexOf("ftp:") != -1 || collocazioneTelematica.toLowerCase().indexOf("file:") != -1) {
                    ProtocolloRiferimentoTelematico protocolloRiferimentoTelematico = new ProtocolloRiferimentoTelematico()
                    protocolloRiferimentoTelematico.uri = documento.collocazioneTelematica.content
                    try {
                        protocolloRiferimentoTelematico.dimensione = allegatoProtocolloService.getFileSizeFromUrl(new URL(documento.collocazioneTelematica.content))
                        if (protocolloRiferimentoTelematico.dimensione == -1) {
                            protocolloRiferimentoTelematico.dimensione = 0
                            throw new Exception("Dimensione restituita -1")
                        }
                    }
                    catch (Exception e) {
                        segnalazioni.add("Impossibile ricavare la dimensione del file da URL " + protocolloRiferimentoTelematico.uri + ". Errore= " + e.getMessage())
                    }
                    protocolloRiferimentoTelematico.impronta = documento.impronta?.content
                    protocolloRiferimentoTelematico.improntaAlgoritmo = documento.impronta?.algoritmo
                    protocolloRiferimentoTelematico.improntaCodifica = documento.impronta?.codifica
                    protocolloRiferimentoTelematico.tipo = (isPrincipale) ? "PRINCIPALE" : "ALLEGATO"
                    protocolloRiferimentoTelematico.scaricato = false
                    protocolloRiferimentoTelematico.protocollo = protocollo
                    protocolloRiferimentoTelematico.save()
                    if (!segnalazioni.contains("Esistono riferimenti telematici")) {
                        segnalazioni.add("Esistono riferimenti telematici")
                    }

                    log.debug(nodoDebug + ".collocazioneTelematica Aggiungo rif telematico")
                    protocollo.addToRiferimentiTelematici(protocolloRiferimentoTelematico)

                    if (SchemaProtocolloIntegrazione.findBySchemaProtocolloAndApplicativo(protocollo.schemaProtocollo, SchemaProtocolloIntegrazione.GLOBO)) {
                        log.debug(nodoDebug + ".collocazioneTelematica - Integrazione Globo V2 - cerco di scaricare il riferimento telematico " +
                                protocolloRiferimentoTelematico.uri + " e allegarlo al protocollo")

                        BufferedInputStream bufferedInputStream = null
                        String improntaCalcolata = ""
                        try {
                            protocolloRiferimentoTelematico.correttezzaImpronta = "N"

                            log.debug(nodoDebug + ".collocazioneTelematica Integrazione Globo V2 - calcolo impronta")
                            bufferedInputStream = new BufferedInputStream(new URL(protocolloRiferimentoTelematico.uri).openStream())
                            ByteArrayInputStream bais = new ByteArrayInputStream(IOUtils.toByteArray(bufferedInputStream))
                            if (protocolloRiferimentoTelematico.improntaCodifica?.equalsIgnoreCase("base64")) {
                                improntaCalcolata = getHashCodeBase64(bais, protocolloRiferimentoTelematico.improntaAlgoritmo, 1000)
                            } else {
                                improntaCalcolata = getHashCodeHex(bais, protocolloRiferimentoTelematico.improntaAlgoritmo)
                            }
                            bais.reset();
                            log.debug(nodoDebug + ".collocazioneTelematica Integrazione Globo V2 - Impronta calcolata: " + improntaCalcolata)

                            if (protocolloRiferimentoTelematico.impronta != improntaCalcolata) {
                                log.debug(nodoDebug + ".collocazioneTelematica Integrazione Globo V2 - Impronta calcolata diversa da quella specificata nell'xml: "
                                        + protocolloRiferimentoTelematico.impronta + ". Segnalo e non scarico il file")
                                segnalazioni.add("File con impronta errata rispetto a quella specificata \n" +
                                        "<a target='_blank' rel='noopener' style='color:blue' href='" + protocolloRiferimentoTelematico.uri + "'>"
                                        + protocolloRiferimentoTelematico.uri + "</a>")
                            } else {
                                protocolloRiferimentoTelematico.correttezzaImpronta = "Y"

                                protocolloRiferimentoTelematicoService.salvaRiferimentoFileSulProtocollo(protocollo, protocolloRiferimentoTelematico, bais,
                                        "application/octet-stream",
                                        (documento.titoloDocumento?.content == null) ? documento.nome : documento.titoloDocumento?.content)

                                protocolloRiferimentoTelematico.scaricato = true
                            }
                        }
                        catch (FileNotFoundException fnf) {
                            protocolloRiferimentoTelematico.scaricato = false
                            log.debug(nodoDebug + ".collocazioneTelematica Integrazione Globo V2 - File non trovato: " + fnf.getMessage())
                            segnalazioni.add("File non trovato " +
                                    "<a target='_blank' rel='noopener' style='color:blue' href='" + protocolloRiferimentoTelematico.uri + "'>"
                                    + protocolloRiferimentoTelematico.uri + "</a>")
                        }
                        catch (Exception exp) {
                            protocolloRiferimentoTelematico.scaricato = false
                            log.debug(nodoDebug + ".collocazioneTelematica Integrazione Globo V2 - Errore generico: " + exp.getMessage())
                            segnalazioni.add("File " +
                                    "<a target='_blank' rel='noopener' style='color:blue' href='" + protocolloRiferimentoTelematico.uri + "'>"
                                    + protocolloRiferimentoTelematico.uri + "</a> - Errore nel tentativo di scaricarlo " + exp.getMessage())
                        }

                        protocolloRiferimentoTelematico.save()
                    }
                }
            }
        } else if (tipoRiferimento.equalsIgnoreCase(ProtocolloSegnaturaService.TIPO_RIFERIMENTO_CARTACEO)) {
            if (!segnalazioni.contains("Esistono riferimenti cartacei")) {
                segnalazioni.add("Esistono riferimenti cartacei")
            }
        } else {
            segnalazioni.add("Tipo riferimento non previsto in segnatura.dtd (MIME | telematico | cartaceo)")
        }

        return nomeFileMimeTrovatoInSegnatura
    }

    void tratta3Del(Protocollo protocollo, MessaggioRicevutoDTO messaggioRicevutoDTO) {
        if (messaggioRicevutoDTO == null) {
            return
        }

        String keys, nokeys
        keys = (ImpostazioniProtocollo.PEC_3DELETTRONICO_KEYS.valore == null) ? "" : ImpostazioniProtocollo.PEC_3DELETTRONICO_KEYS.valore
        nokeys = (ImpostazioniProtocollo.PEC_3DELETTRONICO_NOKEYS.valore == null) ? "" : ImpostazioniProtocollo.PEC_3DELETTRONICO_NOKEYS.valore

        log.debug("segnatura CASO 3DEL keys: " + keys)
        log.debug("segnatura CASO 3DEL nokeys: " + nokeys)

        if (messaggioRicevutoDTO.getFileDocumenti()?.find {
            (it.nome.indexOf(".xml") > -1 ||
                    it.nome.indexOf(".xml.p7m") > -1 || it.nome.indexOf(".zip") > -1
                    || it.nome.indexOf(".rar") > -1 || it.nome.indexOf(".gz") > -1
                    || it.nome.indexOf(".7z") > -1) && !it.nome.equalsIgnoreCase("segnatura.xml") && !it.nome.equalsIgnoreCase("segnatura_cittadino.xml")
        } != null && messaggioRicevutoDTO.oggetto != null) {
            if (StringUtils.checkWords(messaggioRicevutoDTO.oggetto, keys.toLowerCase(), "#") &&
                    !StringUtils.checkWords(messaggioRicevutoDTO.oggetto, nokeys.toLowerCase(), "#")) {
                SchemaProtocollo schemaProtocollo3del = SchemaProtocollo.findByCodice("3del")
                if (schemaProtocollo3del != null) {
                    log.debug("segnatura CASO 3DEL trovato SchemaProtocollo 3DEL - lo associo")
                    schemaProtocolloService.associaSchemaProtocollo(schemaProtocollo3del, protocollo)
                }
            }
        }
    }

    Persona esisteTagPersona(Origine origine) {
        Persona persona = null
        List<Object> ruoloOrPersona = origine.mittente?.amministrazione?.ruoloOrPersona

        if (ruoloOrPersona != null) {
            persona = (Persona) ruoloOrPersona.find { it instanceof Persona }
        }

        if (persona == null) {
            persona = ((Ruolo) ruoloOrPersona.find { it instanceof Ruolo })?.persona
        }

        return persona
    }

    private Protocollo trovaProtocollo(Identificatore identificatore) {

        Date dataProtocollo = null
        Integer numeroProtocollo = null
        String codiceRegistro = ImpostazioniProtocollo.TIPO_REGISTRO.valore
        if (identificatore.dataRegistrazione?.content != null && !identificatore.dataRegistrazione?.content?.equals("")) {
            dataProtocollo = new SimpleDateFormat("yyyy-MM-dd").parse(identificatore.dataRegistrazione?.content)
        }
        if (identificatore.numeroRegistrazione?.content != null && !identificatore.numeroRegistrazione?.content?.equals("")) {
            numeroProtocollo = new Integer(identificatore.numeroRegistrazione?.content).intValue()
        }
        if (identificatore.codiceRegistro?.content != null && !identificatore.codiceRegistro?.content?.equals("")) {
            codiceRegistro = identificatore.codiceRegistro?.content
        }

        log.debug("trovaProtocollo da identificatore con  data: " + dataProtocollo +
                ", numero: " + numeroProtocollo + ", registro: " + codiceRegistro)

        Protocollo protocollo = protocolloRepository.findByDataAndNumeroAndTipoRegistro(dataProtocollo, numeroProtocollo, codiceRegistro)

        if (protocollo == null) {
            log.debug("trovaProtocollo da identificatore: Non ho trovato il protocollo con data: " + dataProtocollo +
                    ", numero: " + numeroProtocollo + ", registro: " + codiceRegistro)

            if (codiceRegistro != ImpostazioniProtocollo.TIPO_REGISTRO.valore) {
                //Provo con quello standard
                protocollo = protocolloRepository.findByDataAndNumeroAndTipoRegistro(dataProtocollo, numeroProtocollo, ImpostazioniProtocollo.TIPO_REGISTRO.valore)

                if (protocollo == null) {
                    log.debug("trovaProtocollo da identificatore: Non ho trovato il protocollo con data: " + dataProtocollo +
                            ", numero: " + numeroProtocollo + ", registro: " + ImpostazioniProtocollo.TIPO_REGISTRO.valore)
                }
            }
        }

        return protocollo
    }

    private void trattaMessaggio(MessaggioRicevutoDTO messaggioRicevutoDTO, Identificatore identificatoreMessaggioRicevuto, Identificatore identificatore, String tipoMessaggio) {
        log.debug("trovaProtocollo da identificatoreMessaggioRicevuto e identificatore")

        Protocollo protocollo = null

        if (identificatoreMessaggioRicevuto != null) {
            if (!tipoMessaggio.equals(ANNULLAMENTO)) {
                log.debug("trovaProtocollo da messaggioRicevuto e identificatore: lo cerco dal nodo messaggioRicevuto")
            } else {
                log.debug("trovaProtocollo da nodo identificatore")
            }
            protocollo = trovaProtocollo(identificatoreMessaggioRicevuto)
        }

        if (protocollo != null) {
            log.debug("Trovato il protocollo , adesso filtro con il tag identificatore usando i destinatari " +
                    "indirizzo per codamm/codAoo")

            String codAmm = identificatore.codiceAmministrazione?.content
            String codAoo = identificatore.codiceAOO?.content

            log.debug("Cerco il corrispondente per codAmm " + codAmm + " e codAoo " + codAoo)

            Corrispondente corrispondenteProtocollo
            corrispondenteProtocollo = protocolloService.getCorrispondenteAmmAoo(protocollo.id, Corrispondente.DESTINATARIO, codAmm, codAoo)

            if (corrispondenteProtocollo == null) {
                corrispondenteProtocollo = protocolloService.getCorrispondenteAmm(protocollo.id, Corrispondente.DESTINATARIO, codAmm)

                if (corrispondenteProtocollo == null) {

                    //Ricerca per indirizzo
                    Pattern pattern = Pattern.compile("[<>]");
                    String[] result = pattern.split(messaggioRicevutoDTO.mittente);
                    String indirizzoMail = null;
                    if (result.length > 1) {
                        indirizzoMail = result[1];
                    } else {
                        indirizzoMail = result[0];
                    }
                    if (indirizzoMail != null) {
                        indirizzoMail = indirizzoMail.trim().toUpperCase();
                    }

                    log.debug("Cerco il corrispondente per indirizzo " + indirizzoMail)

                    corrispondenteProtocollo = protocollo.getCorrispondenti()?.find {
                        it.tipoSoggetto.descrizione == Corrispondente.DESTINATARIO && it.email == indirizzoMail
                    }
                }
            }

            log.debug("Aggiungo collegamento di tipo " + collegamentiMap[tipoMessaggio] + " fra protocollo id: " + protocollo.id + " e messaggio id: "
                    + messaggioRicevutoDTO.id + " della AGP_MSG_RICEVUTI_DATI_PROT")
            DocumentoCollegato documentoCollegato = new DocumentoCollegato()
            documentoCollegato.tipoCollegamento = TipoCollegamento.findByCodice(collegamentiMap[tipoMessaggio])
            documentoCollegato.collegato = messaggioRicevutoDTO.domainObject
            protocollo.addToDocumentiCollegati(documentoCollegato)
            protocollo.save()
            protocolloGdmService.salvaDocumentoCollegamento(protocollo, messaggioRicevutoDTO.domainObject, collegamentiMap[tipoMessaggio])

            if (corrispondenteProtocollo != null) {
                log.debug("Cerco di aggiungere il flag sul corrispondente " + corrispondenteProtocollo.id)
                it.finmatica.gestionedocumenti.documenti.Documento documentoMailInPartenza =
                        protocollo.getDocumentoCollegato(TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL))

                if (documentoMailInPartenza != null) {

                    log.debug("Trovato id documento di tipo MAIL collegato al protocollo. Id documento Messaggio: " + documentoMailInPartenza.id)

                    Messaggio messaggio = Messaggio.get(documentoMailInPartenza.id)
                    if (messaggio != null) {
                        CorrispondenteMessaggio corrispondenteMessaggio = messaggio?.corrispondenti?.find {
                            it.corrispondente == corrispondenteProtocollo
                        }

                        if (corrispondenteMessaggio != null) {
                            if (tipoMessaggio.equals(CONFERMA)) {
                                corrispondenteMessaggio.ricevutaConferma = true
                                corrispondenteMessaggio.dataRicezioneConferma = (messaggioRicevutoDTO.dataRicezione == null) ?
                                        new Date() : messaggioRicevutoDTO.dataRicezione
                            } else if (tipoMessaggio.equals(AGGIORNAMENTO)) {
                                corrispondenteMessaggio.ricevutoAggiornamento = true
                                corrispondenteMessaggio.dataRicezioneAggiornamento = (messaggioRicevutoDTO.dataRicezione == null) ?
                                        new Date() : messaggioRicevutoDTO.dataRicezione
                            } else if (tipoMessaggio.equals(ECCEZIONE)) {
                                corrispondenteMessaggio.ricevutaEccezione = true
                                corrispondenteMessaggio.dataRicezioneEccezione = (messaggioRicevutoDTO.dataRicezione == null) ?
                                        new Date() : messaggioRicevutoDTO.dataRicezione
                            } else if (tipoMessaggio.equals(ANNULLAMENTO)) {
                                corrispondenteMessaggio.ricevutoAnnullamento = true
                                corrispondenteMessaggio.dataRicezioneAnnullamento = (messaggioRicevutoDTO.dataRicezione == null) ?
                                        new Date() : messaggioRicevutoDTO.dataRicezione
                            }

                            log.debug("Aggiungo flag e data su corrispondenteMessaggio " + corrispondenteMessaggio.id)
                            corrispondenteMessaggio.save()
                        } else {
                            log.debug("Non ho trovato il corrispondente sul messaggio in partenza " + messaggio.id + " collegato al protocollo")
                        }
                    } else {
                        log.debug("Attenzione! quell'id non si riferisce ad un documento di tipo Messaggio")
                    }
                } else {
                    log.debug("Non ho trovato il messaggio in partenza collegato al protocollo")
                }
            }
        } else {
            throw new ProtocolloRuntimeException("Non riesco a trovare il protocollo collegato a idSi4Cs: " + messaggioRicevutoDTO.idMessaggioSi4Cs + " per messaggio di tipo " + tipoMessaggio)
        }
    }

    private String getHashCodeBase64(InputStream is, String algoritmo, int length) throws Exception {
        MessageDigest md = null;
        try {
            md = MessageDigest.getInstance(algoritmo);
            md.reset();
            DigestInputStream digestInputStream = new DigestInputStream(is, md);

            while ((digestInputStream.read()) != -1);
        } catch (Exception e) {
            log.info("Errore in calcolo hash 64: " + e.getMessage())
            throw new Exception("Hashing::getHashCode\n" + e.getMessage());
        }
        Base64 b64 = new Base64();
        b64.setLineLength(length);
        return Base64.f_encode(md.digest());
    }

    private String getHashCodeHex(InputStream is, String hash) throws Exception {
        try {
            log.info("calcolo hash: " + hash.toUpperCase())
            MessageDigest md = MessageDigest.getInstance(hash.toUpperCase())
            DigestInputStream digestInputStream = new DigestInputStream(is, md)

            byte[] buffer = new byte[2048]
            while ((digestInputStream.read(buffer)) != -1) {
                digestInputStream.close()
            }
            is.close()
            return md.digest()?.encodeHex()?.toString()
        } catch (Exception e) {
            log.info("Errore in calcolo hash: " + e.getMessage())
            throw new Exception(e)
        }
    }
}