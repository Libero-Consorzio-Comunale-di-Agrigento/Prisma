package it.finmatica.protocollo.documenti

import groovy.sql.Sql
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.firmadigitale.utils.VerificatoreFirma
import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoService
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumentoFirmatario
import it.finmatica.gestionedocumenti.documenti.FileDocumentoService
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.documenti.TipoCollegamentoDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggettoDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoRegola
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.gestionedocumenti.storico.DatoStorico
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAttoreService
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.motore.WkfAttoreStep
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.gestioneiter.motore.WkfStep
import it.finmatica.gestionetesti.TipoFile
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggio
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.Indirizzo
import it.finmatica.protocollo.corrispondenti.IndirizzoDTO
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.TipoCollegamentoRepository
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivico
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamento
import it.finmatica.protocollo.documenti.annullamento.StatoAnnullamento
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.interoperabilita.ProtocolloDatiInteroperabilita
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.documenti.scarto.ProtocolloDatiScarto
import it.finmatica.protocollo.documenti.scarto.ProtocolloDatiScartoDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloService
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.viste.Riferimento
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.ProtocolloEsternoDTO
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloUtilService
import it.finmatica.protocollo.integrazioni.gdm.converters.MovimentoConverter
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.segreteria.jprotocollo.util.ZipUtil
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils
import org.apache.commons.lang.StringUtils
import org.hibernate.annotations.FetchMode
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.jdbc.datasource.DataSourceUtils
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionSynchronizationAdapter
import org.springframework.transaction.support.TransactionSynchronizationManager

import javax.persistence.EntityManager
import javax.persistence.TypedQuery
import javax.sql.DataSource
import java.nio.file.Files
import java.sql.Connection
import java.sql.SQLException
import java.util.zip.ZipOutputStream

@Slf4j
@Transactional
@Service
class ProtocolloService {

    // decisamente troppe dipendenze... come facciamo?
    @Autowired
    TipologiaSoggettoService tipologiaSoggettoService
    @Autowired
    PreferenzeUtenteService preferenzeUtenteService
    @Autowired
    ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    ProtocolloUtilService protocolloUtilService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    NotificheService notificheService
    @Autowired
    WkfAttoreService wkfAttoreService
    @Autowired
    DocumentoService documentoService
    @Autowired
    WkfIterService wkfIterService
    @Autowired
    SuccessHandler successHandler
    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    DataSource dataSource
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    StampaUnicaService stampaUnicaService
    @Autowired
    ProtocolloStoricoService protocolloStoricoService
    @Autowired
    DateService dateService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    ProtocolloRepository protocolloRepository
    @Autowired
    TipoCollegamentoRepository tipoCollegamentoRepository
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository
    @Autowired
    AllegatoProtocolloService allegatoProtocolloService
    @Autowired
    TipoProtocolloService tipoProtocolloService
    @Autowired
    AnnullamentoService annullamentoService
    @Autowired
    ProtocolloGestoreCompetenze protocolloGestoreCompetenze
    @Autowired
    AllegatoRepository allegatoRepository
    @Autowired
    DizionariRepository dizionariRepository
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService
    @Autowired
    DocumentoCollegatoService documentoCollegatoService
    @Autowired
    MailService mailService
    @Autowired
    EntityManager entityManager
    @Autowired
    FileDocumentoService fileDocumentoService

    void salva(Protocollo protocollo, ProtocolloDTO protocolloDto, validaProtocollo = true) {
        boolean aggiornaTask = protocollo.oggetto != protocolloDto.oggetto.toUpperCase()
        protocollo.oggetto = protocolloDto.oggetto?.toUpperCase()
        protocollo.tipoProtocollo = protocolloDto.tipoProtocollo?.domainObject
        protocollo.controlloFunzionario = protocolloDto.controlloFunzionario
        protocollo.controlloFirmatario = protocolloDto.controlloFirmatario
        protocollo.riservato = protocolloDto.riservato
        protocollo.note = protocolloDto.note
        protocollo.noteTrasmissione = protocolloDto.noteTrasmissione
        protocollo.tipoOggetto = protocolloDto.tipoOggetto?.domainObject
        protocollo.tipoRegistro = protocolloDto.tipoRegistro?.domainObject
        protocollo.movimento = protocolloDto.movimento
        protocollo.dataRedazione = protocolloDto.dataRedazione
        protocollo.dataComunicazione = protocolloDto.dataComunicazione
        protocollo.codiceRaccomandata = protocolloDto.codiceRaccomandata
        protocollo.dataDocumentoEsterno = protocolloDto.dataDocumentoEsterno
        protocollo.numeroDocumentoEsterno = protocolloDto.numeroDocumentoEsterno
        protocollo.classificazione = protocolloDto.classificazione?.domainObject
        protocollo.fascicolo = protocolloDto.fascicolo?.domainObject
        protocollo.schemaProtocollo = protocolloDto.schemaProtocollo?.domainObject
        protocollo.dataStatoArchivio = protocolloDto.dataStatoArchivio
        protocollo.statoArchivio = protocolloDto.statoArchivio
        protocollo.modalitaInvioRicezione = protocolloDto.modalitaInvioRicezione?.domainObject
        protocollo.save()
        // salvo il file principale se ancora non lo ho salvato
        if (protocolloDto.testoPrincipale != null) {
            FileDocumento fileDocumento = protocollo.filePrincipale
            if (!(protocolloDto.testoPrincipale.id > 0)) {
                if (fileDocumento == null) {
                    FileDocumentoDTO testo = protocolloDto.testoPrincipale
                    fileDocumento = new FileDocumento(codice: testo.codice, nome: testo.nome, contentType: testo.contentType, dimensione: testo.dimensione, idFileEsterno: testo.idFileEsterno, firmato: testo.firmato, modificabile: testo.modificabile)
                    protocollo.addToFileDocumenti(fileDocumento)
                }
            }
            fileDocumento.modelloTesto = protocolloDto.testoPrincipale.modelloTesto?.domainObject
            protocollo.save()
        }
        if (protocollo.tipoProtocollo.categoriaProtocollo.isMovimentoObbligatorio() && protocollo.movimento == null && validaProtocollo) {
            throw new ProtocolloRuntimeException('Non è possibile salvare un documento senza il movimento.')
        }
        ProtocolloDatiScartoDTO scartoDTO = protocolloDto.datiScarto
        if (scartoDTO != null) {
            ProtocolloDatiScarto scarto = new ProtocolloDatiScarto()
            scarto.dataStato = scartoDTO.dataStato
            scarto.stato = scartoDTO.stato?.domainObject
            scarto.dataNullaOsta = scartoDTO.dataNullaOsta
            scarto.nullaOsta = scartoDTO.nullaOsta
            scarto.save()
            protocollo.datiScarto = scarto
        }
        salva(protocollo, validaProtocollo)
        // se ho dei documenti collegati da salvare, li salvo:
        for (DocumentoCollegatoDTO documentoCollegato : protocolloDto.documentiCollegati.collect()) {
            if (!(documentoCollegato.id > 0)) {
                // ricarico la domain perchè potrebbe mancare l'idDocumentoEsterno utile per il salvataggio del collegamento
                protocollo = Protocollo.get(protocollo.id)
                if (documentoCollegato.tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE) {
                    salvaProtocolloPrecedente(protocollo, documentoCollegato.collegato.domainObject)
                    // elimino i documenti collegati senza id perché non voglio salvarli due volte su un salvataggio successivo
                    // FIXME: questo è il modo più rapido per gestire il protocollo precedente sarebbe da modificare e migliorare.
                    protocolloDto.removeFromDocumentiCollegati(documentoCollegato)
                }
                if (documentoCollegato.tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO) {
                    salvaRiferimentoDatiAccesso(protocollo, documentoCollegato.collegato.domainObject)
                    // elimino i documenti collegati senza id perché non voglio salvarli due volte su un salvataggio successivo
                    // FIXME: questo è il modo più rapido per gestire il protocollo precedente sarebbe da modificare e migliorare.
                    protocolloDto.removeFromDocumentiCollegati(documentoCollegato)
                }
            }
        }

        if (protocollo.idDocumentoEsterno > 0) {
            if (aggiornaTask) {
                notificheService.aggiorna(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, protocollo)
            }
        }
    }

    void salva(Protocollo protocollo, boolean validazioneProtocollo = true, boolean salvaDocumentale = true, boolean escludiControlloCompetenze = false, boolean escludiFascicolazione = false) {
        if (protocollo.numero > 0 && validazioneProtocollo) {
            validaProtocollo(protocollo)
        }
        // allineo la domain con il db
        protocollo.save()
        // alline il documento sul documentale
        if (salvaDocumentale) {
            protocolloGdmService.salvaProtocollo(protocollo, escludiControlloCompetenze, escludiFascicolazione)
        }
        // storicizzo il documento solo se è protocollato
        if (protocollo.numero > 0) {
            storicizzaProtocollo(protocollo)
        }
    }

    void cambioStepGdm(Protocollo protocollo) {
        protocolloGdmService.cambiaStep(protocollo)
    }

    void elimina(Protocollo protocollo, boolean escludiControlloCompetenze = false, boolean scartaMessaggioCollegato = true) {

        notificheService.eliminaNotifica(null, protocollo.idDocumentoEsterno.toString(), null)

        // storicizza gli smistamenti nel caso in cui il documento è di quelli che hanno gli smistamenti attivi in creazione
        if (protocollo.categoriaProtocollo?.isSmistamentoAttivoInCreazione()) {
            for (Smistamento s : protocollo.smistamenti) {
                smistamentoService.storicizzaSmistamento(s)
            }
        }

        //Controllo se il protocollo è collegato ad un messaggio in arrivo questo deve diventare scartato e cancello la relazione
        DocumentoCollegato documentoCollegato = messaggiRicevutiService.getCollegamentoMessaggioProtocollo(protocollo)
        if (documentoCollegato != null) {
            if (scartaMessaggioCollegato) {
                messaggiRicevutiService.scartaMessaggio(documentoCollegato.documento)
            }
            documentoCollegatoService.eliminaDocumentoCollegato(documentoCollegato.documento.toDTO(), protocollo.id)
        }

        // elimino eventuali documenti collegati
        eliminaCollegati(protocollo)

        // FIXME allineo il documento su gdm e tramite un trigger elimina anche su AGSPR
        protocolloGdmService.cancellaDocumento(protocollo.idDocumentoEsterno.toString(), escludiControlloCompetenze)
    }

    void ripristina(Protocollo protocollo) {

        protocollo.valido = false
        salva(protocollo, false)
    }

    /**
     * Elimina documenti collegati
     *
     * @param protocollo
     */
    private void eliminaCollegati(Protocollo protocollo) {
        //Lista dei collegati da eliminare alla seconda iterazione, non posso chiamare direttamente il metodo eliminaDocumentoCollegato
        //causa exception : java.util.ConcurrentModificationException: null
        List<DocumentoCollegato> collegatiDaEliminare = new ArrayList<DocumentoCollegato>()
        Iterator<DocumentoCollegato> it = protocollo.documentiCollegati.iterator()
        while (it.hasNext()) {
            DocumentoCollegato documentoCollegato = it.next()
            //Se è un allegato lo elimino direttamente con l'apposito metodo (sugli allegati non si presenta l'exceprion java.util.ConcurrentModificationException: null)
            if (documentoCollegato.tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_TIPO_ALLEGATO) {
                documentoService.eliminaAllegato(documentoCollegato.collegato)
            } else {
                collegatiDaEliminare.add(documentoCollegato)
                protocolloGdmService.eliminaDocumentoCollegato(protocollo, documentoCollegato.collegato, documentoCollegato.tipoCollegamento.codice)
            }
        }
        //elimino i collegati
        if (collegatiDaEliminare.size() > 0) {
            Iterator<DocumentoCollegato> itColl = collegatiDaEliminare.iterator()
            while (itColl.hasNext()) {
                DocumentoCollegato protCollegato = itColl.next()
                protocollo.removeDocumentoCollegato(protCollegato.collegato, protCollegato.tipoCollegamento.codice)
            }
            protocollo.save()
        }
    }

    void eliminaIter(ProtocolloDTO protocollo) {
        if (protocollo.iter) {
            wkfIterService.terminaIter(protocollo.iter.domainObject)
        }
        notificheService.eliminaNotifica(null, protocollo.idDocumentoEsterno.toString(), null)
    }

    void inviaNotificaEccezione(Protocollo protocollo, String motivazioneEccezione) {
        protocollo.datiInteroperabilita.motivoInterventoOperatore = motivazioneEccezione
        salva(protocollo)
//        if (!ImpostazioniProtocollo.PROTOCOLLA_NOT_ECC.abilitato) {
//            protocollo.valido = false
//            salva(protocollo)
//        }

        if (ImpostazioniProtocollo.PEC_USA_SI4CS_WS.valore == "N") {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
                @Override
                void afterCommit() {
                    try {
                        protocolloUtilService.spedisciNotificaEccezione(protocollo)
                    } catch (RuntimeException e) {
//                    protocollo.valido = true
//                    salva(protocollo)
                        log.error("Errore in spedisci notifica eccezione", e)
                        successHandler.addWarn("ATTENZIONE: errore in spedisci notifica eccezione")
                    }
                }
            })
        } else {
            mailService.spedisciNotificaEccezione(protocollo)
        }
    }

    Protocollo annullamentoDiretto(Protocollo protocollo, String testo, String tipoProvvedimento) {
        ProtocolloAnnullamento pa = new ProtocolloAnnullamento(protocollo: protocollo, motivo: testo, stato: StatoAnnullamento.ANNULLATO)
        pa.save()
        protocollo.provvedimentoAnnullamento = tipoProvvedimento
        protocollo.dataAnnullamento = dateService.getCurrentDate()
        protocollo.utenteAnnullamento = springSecurityService.currentUser
        protocollo.annullato = true
        protocollo.stato = StatoDocumento.ANNULLATO
        for (Smistamento smistamento : protocollo.smistamentiValidi) {
            if (smistamento.statoSmistamento != Smistamento.STORICO) {
                smistamentoService.storicizzaSmistamento(smistamento)
            }
        }
        notificheService.eliminaNotifica(null, protocollo.idDocumentoEsterno.toString(), null)
        return salva(protocollo)
    }

    Protocollo richiestaAnnullamento(Protocollo protocollo, String testo, So4UnitaPubbDTO unita) {
        ProtocolloAnnullamento pa = new ProtocolloAnnullamento(protocollo: protocollo,
                motivo: testo,
                unita: unita.domainObject,
                stato: StatoAnnullamento.RICHIESTO)
        pa.save()
        protocollo.stato = StatoDocumento.RICHIESTO_ANNULLAMENTO
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_RICHIESTA_ANNULLAMENTO, protocollo)
        return salva(protocollo)
    }

    Protocollo accettaRichiestaAnnullamento(Protocollo protocollo) {
        protocollo.stato = StatoDocumento.DA_ANNULLARE
        ProtocolloAnnullamento pa = ProtocolloAnnullamento.findByProtocolloAndStato(protocollo, StatoAnnullamento.RICHIESTO)
        pa.stato = StatoAnnullamento.ACCETTATO
        pa.utenteAccettazioneRifiuto = springSecurityService.currentUser
        pa.dataAccettazioneRifiuto = dateService.getCurrentDate()
        pa.save()
        salva(protocollo)
        notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_RICHIESTA_ANNULLAMENTO, protocollo.idDocumentoEsterno.toString(), null)
        String messaggioTODO = "La richiesta di Annullamento del documento n. " + protocollo.numero + "/" + protocollo.anno + " e' stata accettata. L'annullamento avverra' con successivo Provvedimento"
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_RICHIESTA_ANNULLAMENTO_APPROVATA, protocollo, messaggioTODO)
        return protocollo
    }

    Protocollo rifiutaRichiestaAnnullamento(Protocollo protocollo, String motivoRifiuto) {
        protocollo.stato = null
        ProtocolloAnnullamento pa = ProtocolloAnnullamento.findByProtocolloAndStato(protocollo, StatoAnnullamento.RICHIESTO)
        pa.stato = StatoAnnullamento.RIFIUTATO
        pa.utenteAccettazioneRifiuto = springSecurityService.currentUser
        pa.dataAccettazioneRifiuto = dateService.getCurrentDate()
        pa.motivoRifiuto = motivoRifiuto
        pa.save()
        salva(protocollo)
        notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_RICHIESTA_ANNULLAMENTO, protocollo.idDocumentoEsterno.toString(), null)
        String messaggioTODO = "La richiesta di annullamento del documento n. " + protocollo.numero + "/" + protocollo.anno + " e' stata rifiutata con la seguente motivazione: " + motivoRifiuto
        notificheService.invia(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_RICHIESTA_ANNULLAMENTO_RIFIUTATA, protocollo, messaggioTODO)
        return protocollo
    }

    Protocollo salvaCollegamentoUnico(Protocollo protocolloPrincipale, Protocollo collegato, String codiceTipoCollegamento) {
        if (protocolloPrincipale == null) {
            return null
        }
        // se ho già un protocollo precedente, lo elimino
        if (TipoCollegamentoConstants.univoci.contains(codiceTipoCollegamento)) {
            List<Documento> collegati = protocolloPrincipale.getDocumentiCollegati(codiceTipoCollegamento)
            if (collegati != null && collegati.size() > 0) {
                protocolloGdmService.eliminaDocumentoCollegato(protocolloPrincipale, collegato, codiceTipoCollegamento)
                protocolloPrincipale.removeDocumentoCollegato(collegati.get(0), codiceTipoCollegamento)
            }
        }
        DocumentoCollegato dc = new DocumentoCollegato(documento: protocolloPrincipale, collegato: collegato, tipoCollegamento: TipoCollegamento.findByCodice(codiceTipoCollegamento))
        protocolloPrincipale.addToDocumentiCollegati(dc)
        protocolloPrincipale.save()
        protocolloGdmService.salvaDocumentoCollegamento(protocolloPrincipale, collegato, codiceTipoCollegamento)
        return protocolloPrincipale
    }

    Protocollo salvaProtocolloPrecedente(Protocollo protocolloPrincipale, Protocollo protocolloPrecedente) {
        return salvaCollegamentoUnico(protocolloPrincipale, protocolloPrecedente, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
    }

    Protocollo salvaRiferimentoDatiAccesso(Protocollo protocolloDiRisposta, Protocollo protocolloDiDomanda) {
        return salvaCollegamentoUnico(protocolloDiRisposta, protocolloDiDomanda, TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO)
    }

    void eliminaDocumentoCollegato(Protocollo protocollo, Protocollo collegato, String codiceTipoCollegamento) {
        protocolloGdmService.eliminaDocumentoCollegato(protocollo, collegato, codiceTipoCollegamento)
        protocollo.removeDocumentoCollegato(collegato, codiceTipoCollegamento)
        protocollo.save()
    }

    void eliminaRiferimento(Protocollo protocollo, Riferimento riferimento) {
        protocolloGdmService.eliminaDocumentoCollegato(protocollo, new Protocollo(idDocumentoEsterno: riferimento.idRiferimento), TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_RIFERIMENTO)
    }

    @Transactional(readOnly = true)
    List<Map<String, Object>> getStoricoFlusso(Protocollo protocollo, boolean tutti = false) {
        return protocolloStoricoService.getStoricoFlusso(protocollo, tutti)
    }

    @Transactional(readOnly = true)
    Map getNoteTrasmissionePrecedenti(Protocollo protocollo) {
        // se il protocollo è già numerato, allora nascondo le note di trasmissione
        if (protocollo.numero > 0) {
            return [noteTrasmissionePrecedenti: null, attorePrecedente: null, mostraNoteTrasmissionePrecedenti: false]
        }
        // cerco l'ultima riga nello storico:
        DatoStorico dati = protocolloStoricoService.getUltimaVersione(protocollo)
        if (dati == null) {
            return [noteTrasmissionePrecedenti: null, attorePrecedente: null, mostraNoteTrasmissionePrecedenti: false]
        }
        // verifico che l'utente corrente sia un attore del nodo corrente:
        boolean mostraNoteTrasmissionePrecedenti = isUtenteCorrenteAttoreNodo(protocollo.iter.stepCorrente)
        // se l'utente non è un attore del nodo corrente, verifico che sia un utente del nodo in cui sono state scritte le note:
        if (!mostraNoteTrasmissionePrecedenti) {
            String idStep = dati.datiStorici.find { it.campo == "step" }?.dati?._key
            if (idStep?.length() > 0) {
                mostraNoteTrasmissionePrecedenti = isUtenteCorrenteAttoreNodo(WkfStep.get(Long.parseLong(idStep)))
            }
        }
        // se l'utente corrente non è un utente del nodo corrente in cui si trova il flusso, non mostro note di trasmissione
        if (!mostraNoteTrasmissionePrecedenti) {
            return [noteTrasmissionePrecedenti: null, attorePrecedente: null, mostraNoteTrasmissionePrecedenti: mostraNoteTrasmissionePrecedenti]
        }
        String noteTrasmissione = dati.datiStorici.find { it.campo == "noteTrasmissione" }?.valore
        if (!(noteTrasmissione?.length() > 0)) {
            return [noteTrasmissionePrecedenti: null, attorePrecedente: null, mostraNoteTrasmissionePrecedenti: mostraNoteTrasmissionePrecedenti]
        }
        return [noteTrasmissionePrecedenti: noteTrasmissione, attorePrecedente: dati.nominativoUtente, mostraNoteTrasmissionePrecedenti: mostraNoteTrasmissionePrecedenti]
    }

    @Transactional(readOnly = true)
    boolean isUtenteCorrenteAttoreNodo(WkfStep step) {
        for (WkfAttoreStep attoreStep : step.attori) {
            if (wkfAttoreService.utenteCorrenteCorrispondeAttore(attoreStep.utenteAd4?.id, attoreStep.ruoloAd4?.ruolo, attoreStep.unitaSo4?.progr, attoreStep.unitaSo4?.ottica?.codice)) {
                return true
            }
        }
        return false
    }

    /*
        restituisce

        N=Nessun messaggio consegnato
        T=Tutti i messaggi consegnati
        Y=Almeno un messaggio consegnato
    * */

    @Transactional(readOnly = true)
    String getProtocolloMessaggiConsegnati(Protocollo protocollo) {
        String messaggiConsegnati = "N"

        if (protocollo == null) {
            return messaggiConsegnati
        }

        if (protocollo.movimento != Protocollo.MOVIMENTO_PARTENZA) {
            return messaggiConsegnati
        }

        List<Corrispondente> corrispondentiList = protocollo.corrispondenti.findAll().toList()

        int contaMessaggiConsegnati = 0
        int contaTuttiMessaggi = 0
        for (Corrispondente dest : corrispondentiList) {
            List<CorrispondenteMessaggio> corrispondenteMessaggi = CorrispondenteMessaggio.findAllByCorrispondente(dest)

            for (CorrispondenteMessaggio c : corrispondenteMessaggi) {
                contaTuttiMessaggi++
                if (c.registrataConsegna) {
                    contaMessaggiConsegnati++
                }
            }
        }

        if (contaMessaggiConsegnati > 0) {
            if (contaMessaggiConsegnati == contaTuttiMessaggi) {
                messaggiConsegnati = "T"
            } else {
                messaggiConsegnati = "Y"
            }
        }

        return messaggiConsegnati
    }

    void storicizzaProtocollo(Protocollo protocollo, WkfStep stepCorrente = null, boolean logSoloModificati = true, Date dataAggiornamento = null) {
        protocolloStoricoService.storicizza(protocollo, stepCorrente, logSoloModificati, dataAggiornamento)
    }

    void protocolla(Protocollo protocollo, boolean verificaFirma = true, boolean escludiControlloCompentenze = false, Ad4Utente utente = springSecurityService.currentUser) {
        // ottengo il lock pessimistico per evitare doppie protocollazioni.
        protocollo.lock()
        // controllo che il documento non sia già protocollato
        if (protocollo.numero > 0) {
            throw new ProtocolloRuntimeException("Il documento è già protocollato!")
        }
        // se non ho già il tipo di registro impostato, tento di recuperarlo dallo schema
        if (protocollo.tipoRegistro == null) {
            protocollo.tipoRegistro = protocollo.schemaProtocollo?.tipoRegistro
        }
        // se anche lo schema non l'ha, tento dalla tipologia
        if (protocollo.tipoRegistro == null) {
            protocollo.tipoRegistro = protocollo.tipoProtocollo?.tipoRegistro
        }
        // se ancora non l'ho trovato, uso le impostazioni
        if (protocollo.tipoRegistro == null) {
            protocollo.tipoRegistro = TipoRegistro.findByCodice(ImpostazioniProtocollo.TIPO_REGISTRO.valore)
        }
        // infine, se ancora il tipoRegistro è null, do' errore perché non posso protocollare.
        if (protocollo.tipoRegistro == null) {
            throw new ProtocolloRuntimeException("Non è possibile protocollare il documento senza specificare il registro di protocollazione. Il codice registro di default ha valore: ${ImpostazioniProtocollo.TIPO_REGISTRO.valore} ma non è stato trovato un registro corrispondente.")
        }

        if (protocollo.categoriaProtocollo.sovrascriviProtocollatore()) {
            protocollo.getSoggetto(TipoSoggetto.REDATTORE).utenteAd4 = utente
        }

        // per prima cosa allineo il documento gdm:
        protocolloGdmService.salvaProtocollo(protocollo, escludiControlloCompentenze)
        // eseguo la protocollazione
        protocolloUtilService.protocolla(protocollo, verificaFirma)
        // salvo il numero su agspr
        protocolloGdmService.salvaProtocollo(protocollo, escludiControlloCompentenze)
        if (protocollo.filePrincipale?.modelloTesto) {
            protocolloGdmService.rinominaFileProtocollato(protocollo)
        }
        // aggiorno la data di presentazione dell'accesso civico se presente
        // (data di comunicazione o data di protocollo se non c'è la prima)
        ProtocolloAccessoCivico protocolloAccessoCivico = ProtocolloAccessoCivico.findByProtocolloDomanda(protocollo)
        if (protocolloAccessoCivico && protocolloAccessoCivico.dataPresentazione == null) {
            protocolloAccessoCivico.dataPresentazione = protocollo.dataComunicazione
            if (protocolloAccessoCivico.dataPresentazione == null) {
                protocolloAccessoCivico.dataPresentazione = protocollo.data
            }
        }

        if (protocollo.categoriaProtocollo.isPec() && ImpostazioniProtocollo.PEC_USA_SI4CS_WS.valore == "Y") {
            //Cerco il messaggio ricevuto associato al protocollo e cambio lo stato in protocollato
            Messaggio messaggio = mailService.caricaMessaggioRicevuto(protocollo)
            MessaggioRicevuto messaggioRicevuto = messaggiRicevutiService.getMessaggioRicevutoById(messaggio.id)
            if (messaggioRicevuto != null) {
                messaggiRicevutiService.protocollaMessaggio(messaggioRicevuto)
            }

            boolean conSegnatura = protocolloUtilService.isConSegnatura(protocollo)
            try {
                if (conSegnatura) {
                    mailService.spedisciConfermaRicezione(protocollo)
                } else {
                    if (ImpostazioniProtocollo.RICEVUTA_PROT_AUTO.valore == "Y") {
                        mailService.inviaRicevuta(protocollo)
                    }
                }
            } catch (Exception e) {
                if (conSegnatura) {
                    log.error("Errore in invio conferma di ricezione", e)
                    successHandler.addMessage("ATTENZIONE: errore in invio della conferma di ricezione")
                } else {
                    log.error("Errore in invio della ricevuta", e)
                    successHandler.addMessage("ATTENZIONE: errore in invio della ricevuta")
                }
            }
        }

        // aggiungo l'handler per inviare la ricevuta:
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
            @Override
            void afterCommit() {
                try {
                    if (protocollo.categoriaProtocollo.isPec() && ImpostazioniProtocollo.PEC_USA_SI4CS_WS.valore == "N") {
                        boolean conSegnatura = protocolloUtilService.isConSegnatura(protocollo)
                        try {
                            if (conSegnatura) {
                                protocolloUtilService.spedisciConfermaRicezione(protocollo.idDocumentoEsterno)
                            } else {
                                protocolloUtilService.inviaRicevuta(protocollo.idDocumentoEsterno)
                            }
                        } catch (RuntimeException e) {
                            if (conSegnatura) {
                                log.error("Errore in invio conferma di ricezione", e)
                                successHandler.addMessage("ATTENZIONE: errore in invio della conferma di ricezione")
                            } else {
                                log.error("Errore in invio della ricevuta", e)
                                successHandler.addMessage("ATTENZIONE: errore in invio della ricevuta")
                            }
                        }
                    }

                    aggiornaTimbroPdf(Protocollo.get(protocollo.id))
                } catch (RuntimeException e) {
                    log.error("Errore in nella generazione della stampa conforme", e)
                    successHandler.addMessage("ATTENZIONE: Errore in nella generazione della stampa conforme")
                }

                // segnalo la protocollazione effettuata
                successHandler.addMessage("Protocollazione effettuata con n. ${protocollo.numero} / ${protocollo.anno}")
            }
        })
        // invio gli smistamenti di questo protocollo gestito come azione
        //smistamentoService.inviaSmistamenti(protocollo)
        inviaSmistamentoAutomatico(protocollo, utente)
        //Elimino le competenze di cancellazione
        rimuoviCompetenzeCancellazioneDaDocumentoCompetenze(protocollo)
        // salvo una riga di storico per avere la foto del documento nel momento del protocollo
        boolean logSoloModifiche = false

        storicizzaProtocollo(protocollo, null, logSoloModifiche, protocollo.data)

        // gestisco le notifiche in caso si protocollo proveniente da emergenza
        eliminaTaskSmartDesktopEmergenza(protocollo)
    }

    private rimuoviCompetenzeCancellazioneDaDocumentoCompetenze(Protocollo protocollo) {
        gestoreCompetenze.rimuoviCompetenzeCancellazioneDaDocumentoCompetenze(protocollo)
    }

    void eliminaTaskSmartDesktopEmergenza(Protocollo protocollo) {
        Protocollo emergenza = null
        if (protocollo.datiEmergenza) {
            emergenza = protocollo
        } else {
            emergenza = protocolloRepository.getProtocolloEmergenzaFromFiglio(protocollo)
        }

        if (protocolloRepository.getListaCollegatiNonProtocollati(emergenza).size() == 0 && emergenza?.numero) {
            notificheService.eliminaNotifica(null, emergenza.idDocumentoEsterno.toString(), null)
        }
    }

    FileDocumento caricaFilePrincipale(Protocollo protocollo, InputStream inputStream, String contentType, String nome, boolean escludiControlloCompetenze = false) {
        // se c'è già un file principale, lo sostituisco, altrimenti lo creo
        FileDocumento filePrincipale = protocollo.filePrincipale
        if (filePrincipale == null) {
            filePrincipale = new FileDocumento(contentType: contentType, nome: nome, codice: FileDocumento.CODICE_FILE_PRINCIPALE)
            protocollo.addToFileDocumenti(filePrincipale)
            protocollo.save()
        } else {
            filePrincipale.nome = nome
            filePrincipale.contentType = contentType
        }
        gestoreFile.addFile(protocollo, protocollo.filePrincipale, inputStream, escludiControlloCompetenze)
        List<VerificatoreFirma.RisultatoVerifica> risultatiVerifica = documentoService.estraiInformazioneFileFirmato(protocollo.filePrincipale)
        verificaFirmaFilePrincipale(risultatiVerifica, protocollo)
        aggiornaTimbroPdf(protocollo)
        return protocollo.filePrincipale
    }

    void verificaFirma(Protocollo protocollo) {
        List<VerificatoreFirma.RisultatoVerifica> risultatiVerifica = new VerificatoreFirma(gestoreFile.getFile(protocollo, protocollo.filePrincipale, true)).verificaFirma()
        verificaFirmaFilePrincipale(risultatiVerifica, protocollo)
    }

    void aggiornaTimbroPdf(Protocollo protocollo) {
        if (!protocollo.categoriaProtocollo.creaTimbroPdf) {
            return
        }
        // se il protocollo non è  numerato, non devo fare niente
        if (!(protocollo.numero > 0)) {
            return
        }
        FileDocumento filePrincipale = protocollo.filePrincipale

        if (!filePrincipale) {
            return
        }

        if (!filePrincipale.isPdf() && !filePrincipale.isP7m() && !filePrincipale.isConvertibilePdf()) {
            return
        }

        boolean firmato = filePrincipale.firmato

        if (ImpostazioniProtocollo.TIMBRA_PDF_FIRMATI.abilitato && firmato) {
            // se non è pdf e il file senza p7m non è ne' pdf e ne' convertibile -> non fare la copia conforme
            if (!filePrincipale.isPdf()) {
                String nomeFile = filePrincipale.nome.substring(0, filePrincipale.nome.toLowerCase().lastIndexOf(".p7m"))
                if (!nomeFile.endsWith(".pdf") && !Impostazioni.ALLEGATO_CONVERTI_PDF_FORMATO.valori.contains(FilenameUtils.getExtension(nomeFile).toLowerCase())) {
                    return
                }
            }
            stampaUnicaService.creaAllegatoCopiaConforme(protocollo)
            storicizzaProtocollo(protocollo)
        }

        if (ImpostazioniProtocollo.TIMBRA_PDF.abilitato && !firmato) {
            stampaUnicaService.creaAllegatoCopiaConforme(protocollo)
            storicizzaProtocollo(protocollo)
            return
        }

        return
    }

    private void inviaSmistamentoAutomatico(Protocollo protocollo, Ad4Utente utente = springSecurityService.currentUser) {
        So4UnitaPubb unitaDestinataria = protocollo.tipoProtocollo.unitaDestinataria
        if (unitaDestinataria != null) {
            Smistamento smistamento = smistamentoService.creaSmistamento(protocollo, Smistamento.COMPETENZA,
                    protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4,
                    utente,
                    unitaDestinataria, null, "Smistamento creato automaticamente per assegnazione competenze iter.")
            smistamentoService.eseguiSmistamento(smistamento, utente)
        }
    }

    String pubblicaAlbo(Protocollo p) {
        return protocolloGdmService.pubblicaAlbo(p.idDocumentoEsterno)
    }

    @Transactional(readOnly = true)
    void validaProtocollo(Protocollo documento) {
        validaFileAllegatoObbligatorio(documento)
        validaOggetto(documento)
        validaFileObbligatorio(documento)
        validaNomiFile(documento)
        if (isModificabilitaTesto(documento, springSecurityService.currentUser)) {
            validaNomiFileCaratteriSpeciali(documento)
        }
        validaMovimento(documento)
        validaDataComunicazione(documento)
        validaTramite(documento)
        validaFascicoloEClassifica(documento)
        validaFirmaVerificata(documento)
        validaFirmaAllegatiVerificata(documento)
        if (documento.tipoProtocollo.categoriaProtocollo.codice != CategoriaProtocollo.CATEGORIA_PROVVEDIMENTO.codice &&
                documento.tipoProtocollo.categoriaProtocollo.codice != CategoriaProtocollo.CATEGORIA_EMERGENZA.codice) {
            validaSchemaProtocollo(documento)
            validaCorrispondenti(documento)
            validaSmistamenti(documento)
        }
    }

    @Transactional(readOnly = true)
    void validaMovimento(Protocollo documento) {
        if (documento.movimento == null) {
            throw new ProtocolloRuntimeException("Definire il movimento del documento")
        }
    }

    @Transactional(readOnly = true)
    void validaFirmaVerificata(Protocollo documento) {
        if (documento.filePrincipale?.isFirmato() && !documento.isFirmaVerificata() && !documento.isProtocollato()) {
            throw new ProtocolloRuntimeException("Il Documento Principale è firmato ma non verificato")
        }
    }

    @Transactional(readOnly = true)
    void validaFirmaAllegatiVerificata(Protocollo documento) {
        if (documento.isProtocollato()) {
            return
        }

        List<FileDocumento> fileDocumenti = allegatoProtocolloService.getFileDocumentiAllegati(documento)
        for (FileDocumento file in fileDocumenti) {
            if (file.firmato && file.esitoVerifica != Protocollo.ESITO_VERIFICATO && file.esitoVerifica != Protocollo.ESITO_FORZATO) {
                throw new ProtocolloRuntimeException("L'allegato " + file.nome + " risulta firmato ma non verificato")
            }
        }
    }

    @Transactional(readOnly = true)
    void validaFileObbligatorio(Protocollo documento) {
        boolean valida = false
        //il controllo deve scattare solo se il doucumento è ancora da protocollare issue 43122
        if (!documento.isProtocollato()) {

            if (documento.tipoProtocollo?.categoriaProtocollo?.isPec()) {
                if (documento.filePrincipale?.idFileEsterno == null) {
                    // if (allegatoProtocolloService.getFileDaPec(documento)?.size() <= 0) {
                    throw new ProtocolloRuntimeException("Il file principale è obbligatorio")
                    // }
                }
            }

            if (ImpostazioniProtocollo.FILE_OB.valore.equals("Y") && !documento.numeroEmergenza) {
                valida = true
            } else if (ImpostazioniProtocollo.FILE_OB.valore.equals("PAR") && Protocollo.MOVIMENTO_PARTENZA.equals(documento.movimento)) {
                valida = true
            } else if (ImpostazioniProtocollo.FILE_OB.valore.equals("PAR_INT") &&
                    (Protocollo.MOVIMENTO_PARTENZA.equals(documento.movimento) || Protocollo.MOVIMENTO_INTERNO.equals(documento.movimento))) {
                valida = true
            }
        }

        if (valida && documento.filePrincipale?.idFileEsterno == null) {
            throw new ProtocolloRuntimeException("Il file principale è obbligatorio")
        }
    }

    @Transactional(readOnly = true)
    void validaFileAllegatoObbligatorio(Protocollo documento) {
        boolean valida = true
        if (ImpostazioniProtocollo.FILE_ALLEGATO_OB.isAbilitato() && !documento.numeroEmergenza) {
            for (Allegato allegato : documento.allegati) {
                if (allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO).size() == 0) {
                    valida = false
                }
            }
            if (!valida) {
                throw new ProtocolloRuntimeException("Deve esistere almeno un file su ogni allegato.")
            }
        }
    }

    @Transactional(readOnly = true)
    void validaDataComunicazione(Protocollo documento) {
        if (ImpostazioniProtocollo.DATA_ARRIVO_OB.abilitato &&
                documento.movimento == Protocollo.MOVIMENTO_ARRIVO &&
                documento.dataComunicazione == null) {
            throw new ProtocolloRuntimeException("Definire la data di arrivo")
        }
    }

    @Transactional(readOnly = true)
    void validaTramite(Protocollo documento) {
        if (ImpostazioniProtocollo.TRAMITE_ARR_OB.abilitato &&
                documento.movimento == Protocollo.MOVIMENTO_ARRIVO &&
                documento.modalitaInvioRicezione == null) {
            throw new ProtocolloRuntimeException("Definire il tramite")
        }
    }

    @Transactional(readOnly = true)
    void validaOggetto(Protocollo documento) {
        if (/*ImpostazioniProtocollo.OGG_OB.abilitato &&*/ (documento.oggetto == null || documento.oggetto.trim().length() == 0)) {
            throw new ProtocolloRuntimeException("L'Oggetto è obbligatorio.")
        }
    }

    @Transactional(readOnly = true)
    void validaSchemaProtocollo(Protocollo documento) {
        if (ImpostazioniProtocollo.TIPO_DOC_OB.abilitato && documento.schemaProtocollo == null) {
            throw new ProtocolloRuntimeException("Il Tipo Documento è obbligatorio.")
        }
    }

    @Transactional(readOnly = true)
    void validaFascicoloEClassifica(Protocollo documento) {
        boolean fascicoloObbligatorio = false
        String fascicoloParametro = ImpostazioniProtocollo.FASC_OB.valore
        if ("PAR" == fascicoloParametro) {
            if (documento.movimento == Protocollo.MOVIMENTO_PARTENZA || documento.movimento == Protocollo.MOVIMENTO_INTERNO) {
                fascicoloObbligatorio = true
            } else {
                fascicoloObbligatorio = false
            }
        } else {
            fascicoloObbligatorio = ImpostazioniProtocollo.FASC_OB.abilitato
        }
        boolean classificaObbligatoria = (ImpostazioniProtocollo.CLASS_OB.abilitato)
        if (classificaObbligatoria && documento.classificazione == null && fascicoloObbligatorio && documento.fascicolo == null) {
            throw new ProtocolloRuntimeException("Non è possibile procedere: Classifica e Fascicolo sono obbligatori")
        } else if (classificaObbligatoria && documento.classificazione == null) {
            throw new ProtocolloRuntimeException("Non è possibile procedere: la Classifica è obbligatoria")
        } else if (fascicoloObbligatorio && documento.fascicolo == null) {
            throw new ProtocolloRuntimeException("Non è possibile procedere: il Fascicolo è obbligatorio")
        }

        if(documento.classificazione.contenitoreDocumenti == false && documento.fascicolo == null){
            throw new ProtocolloRuntimeException("Non è possibile procedere: La Classifica selezionata non può contenere documenti")
        }
    }

    @Transactional(readOnly = true)
    void validaCorrispondenti(Protocollo documento) {
        boolean corrispondenteObbligatorio = (ImpostazioniProtocollo.RAPP_OB.abilitato)
        if (documento.movimento == Protocollo.MOVIMENTO_ARRIVO && corrispondenteObbligatorio) {
            if (documento.corrispondenti == null || documento.corrispondenti.isEmpty()) {
                throw new ProtocolloRuntimeException("Inserire almeno un mittente")
            }
        } else if (documento.movimento == Protocollo.MOVIMENTO_PARTENZA) {
            if (documento.corrispondenti == null || documento.corrispondenti.isEmpty()) {
                throw new ProtocolloRuntimeException("Inserire almeno un destinatario")
            }
        }
        validaDenominazioneCorrispondenti(documento)
    }

    @Transactional(readOnly = true)
    void validaDenominazioneCorrispondenti(Protocollo documento) {
        if (documento.corrispondenti != null && !documento.corrispondenti.isEmpty()) {
            for (Corrispondente corrispondente : documento.corrispondenti) {
                if (StringUtils.isEmpty(corrispondente.denominazione?.trim())) {
                    throw new ProtocolloRuntimeException("Attenzione. Sono presenti corrispondenti senza denominazione")
                }
            }
        }
    }

    @Transactional(readOnly = true)
    void validaSmistamenti(Protocollo documento) {
        boolean smistamentoArrivoObbligatorio = (ImpostazioniProtocollo.SMIST_ARR_OB.abilitato)
        boolean smistamentoPartenzaObbligatorio = (ImpostazioniProtocollo.SMIST_PAR_OB.abilitato)
        boolean smistamentoInternoObbligatorio = (ImpostazioniProtocollo.SMIST_INT_OB.abilitato)
        if ((smistamentoArrivoObbligatorio && documento.movimento == Protocollo.MOVIMENTO_ARRIVO) ||
                (smistamentoPartenzaObbligatorio && documento.movimento == Protocollo.MOVIMENTO_PARTENZA) ||
                (smistamentoInternoObbligatorio && documento.movimento == Protocollo.MOVIMENTO_INTERNO && documento.categoriaProtocollo != CategoriaProtocollo.CATEGORIA_REGISTRO_GIORNALIERO)) {
            if (documento.smistamentiValidi.size() == 0) {
                throw new ProtocolloRuntimeException("Inserire almeno uno smistamento")
            }
        }
    }

    /**
     * Valida dimensioni degli allegati
     *
     * @param documento
     */
    @Transactional(readOnly = true)
    void validaDimensioneAllegati(Documento documento, boolean duranteFirma = false) {
        documentoService.validaDimensioneAllegati(documento, duranteFirma)
    }

    /**
     * Valida dimensioni degli allegati
     *
     * @param documento
     */
    @Transactional(readOnly = true)
    void validaNomiFile(Documento documento) {
        allegatoProtocolloService.validaNomiFile(documento)
    }

/**
 * Valida se il nome del file principale o degli allegati contiene caratteri non ammissibili
 *
 * @param documento
 */
    void validaNomiFileCaratteriSpeciali(Documento documento) {
        allegatoProtocolloService.validaNomiFileCaratteriSpeciali(documento)
    }

/**
 * 	Recupera l'ubicazione del documento in base a fascicolo e classificazione
 *
 * @param Protocollo protocollo
 * @return
 */
    @Transactional(readOnly = true)
    String getUbicazione(Protocollo protocollo) {
        try {
            Connection conn = DataSourceUtils.getConnection(dataSource)
            Sql sql = new Sql(conn)
            String ubicazione = ""
            sql.call("""BEGIN 
						  ? := AGP_PROTOCOLLI_PKG.GET_UBICAZIONE_FASCICOLO (?);
						END; """,
                    [Sql.VARCHAR, protocollo.id]) { row ->
                ubicazione = row
            }
            return ubicazione
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

/**
 * Crea un file .zip con tutti gli allegati del protocollo.
 */
    File creaFileZipAllegati(Protocollo protocollo) {
        String nomeZip;
        if (protocollo.isProtocollato()) {
            nomeZip = protocollo.getTipoRegistro().getCodice() + "_" + protocollo.getAnno() + "_" + protocollo.getNumero();
        } else {
            nomeZip = protocollo.idDocumentoEsterno.toString();
        }
        String outDir = ZipUtil.prepareOutputDirectory(nomeZip + "_")
        String fout = outDir + "/" + nomeZip + ".zip"
        FileOutputStream fos = new FileOutputStream(fout)
        ZipOutputStream zos = new ZipOutputStream(fos)
        ArrayList<Long> listaIdFileNonUnivoci = getListaIdFileNonUnivoci(protocollo)
        for (fileDocumento in (listaFileZip(protocollo))) {
            if ("LETTERAUNIONE.RTFHIDDEN".equals(fileDocumento.getNome())) {
                continue
            }
            if (listaIdFileNonUnivoci.contains(fileDocumento.getId())) {
                continue
            }
            InputStream is = gestoreFile.getFile(protocollo, fileDocumento)
            ZipUtil.addToZipFile(fileDocumento.getNome(), is, zos)
        }
        for (allegato in protocollo.getAllegati()) {
            for (fileDocumento in listaFileZip(allegato)) {
                if ("LETTERAUNIONE.RTFHIDDEN".equals(fileDocumento.getNome())) {
                    continue
                }
                if (listaIdFileNonUnivoci.contains(fileDocumento.getId())) {
                    continue
                }
                InputStream is = gestoreFile.getFile(allegato, fileDocumento)
                ZipUtil.addToZipFile(fileDocumento.getNome(), is, zos)
            }
        }
        zos.close();
        fos.close();
        return new java.io.File(fout);
    }

    Protocollo salvaDto(ProtocolloDTO protocolloDTO) {
        Protocollo prot = new Protocollo(idDocumentoEsterno: protocolloDTO.idDocumentoEsterno,
                anno: protocolloDTO.anno,
                oggetto: protocolloDTO.oggetto,
                tipoRegistro: protocolloDTO.tipoRegistro?.domainObject,
                tipoProtocollo: protocolloDTO.tipoProtocollo?.domainObject,
                numero: protocolloDTO.numero)
        return prot.save()
    }

    Protocollo salvaDto(ProtocolloEsternoDTO protocolloDTO, TipoProtocollo tipoProtocollo) {
        Protocollo prot = new Protocollo(idDocumentoEsterno: protocolloDTO.idDocumentoEsterno,
                anno: protocolloDTO.anno,
                oggetto: protocolloDTO.oggetto,
                tipoRegistro: protocolloDTO.tipoRegistro?.domainObject,
                tipoProtocollo: tipoProtocollo,
                numero: protocolloDTO.numero)
        return prot.save()
    }

    private List<FileDocumento> listaFileZip(Documento doc) {
        doc.fileDocumenti?.findAll { it.codice != FileDocumento.CODICE_FILE_ORIGINALE }
    }

    @Transactional(readOnly = true)
    boolean isFileDoppiPresenti(Protocollo protocollo) {
        return (getListaIdFileNonUnivoci(protocollo).size() > 0)
    }

    ProtocolloDTO copia(Protocollo protocollo) {
        return duplica(protocollo, PreferenzeUtenteService.DUPLICA_PROTOCOLLO_COPIA_RAPPORTI, PreferenzeUtenteService.DUPLICA_PROTOCOLLO_COPIA_SMISTAMENTI)
    }

    ProtocolloDTO duplica(Protocollo protocollo, String privilegioCopiaRapporti, String privilegioCopiaSmistamenti) {
        ProtocolloDTO copiaProtocollo = new ProtocolloDTO()
        Ad4UtenteDTO utenteCorrente = springSecurityService.currentUser.toDTO()
        copiaProtocollo.tipoOggetto = protocollo.tipoOggetto?.toDTO()
        copiaProtocollo.oggetto = protocollo.oggetto
        copiaProtocollo.movimento = protocollo.movimento
        copiaProtocollo.riservato = protocollo.riservato

        copiaProtocollo.classificazione = protocollo.classificazione?.toDTO()
        copiaProtocollo.tipoProtocollo = protocollo.tipoProtocollo?.toDTO("tipologiaSoggetto.layoutSoggetti")
        copiaProtocollo.tipoRegistro = protocollo.tipoProtocollo.tipoRegistro?.toDTO()

        if (!protocollo.categoriaProtocollo.equals(CategoriaProtocollo.CATEGORIA_LETTERA)) {
            GestioneTestiModello modelloTesto = protocollo.filePrincipale?.modelloTesto
            if (modelloTesto == null) {
                modelloTesto = TipoProtocollo.modelloTestoPredefinito(protocollo.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
            }
            if (modelloTesto != null) {
                copiaProtocollo.addToFileDocumenti(new FileDocumentoDTO(modelloTesto: modelloTesto.toDTO(), codice: FileDocumento.CODICE_FILE_PRINCIPALE, nome: protocollo.tipoProtocollo.categoria + "." + modelloTesto.tipo, contentType: TipoFile.getInstanceByEstensione(modelloTesto.tipo).contentType, valido: true, modificabile: true, firmato: false))
            }
        }

        if (protocollo.schemaProtocollo != null && !protocollo.schemaProtocollo.risposta && protocollo.schemaProtocollo.valido) {
            copiaProtocollo.schemaProtocollo = protocollo.schemaProtocollo?.toDTO()
        }
        copiaProtocollo.addToSoggetti(new DocumentoSoggettoDTO(tipoSoggetto: TipoSoggetto.REDATTORE, utenteAd4: utenteCorrente))
        So4UnitaPubb unitaProtocollante = protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE).unitaSo4

        boolean privilegioRedattore = true
        if (protocollo.categoriaProtocollo == CategoriaProtocollo.CATEGORIA_LETTERA) {
            privilegioRedattore = privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.REDATTORE_LETTERA, unitaProtocollante?.codice, utenteCorrente.domainObject)
        }else{
            copiaProtocollo.modalitaInvioRicezione = protocollo.modalitaInvioRicezione?.toDTO()
        }

        if (utenteHaUnita(copiaProtocollo, unitaProtocollante) && privilegioRedattore) {
            copiaProtocollo.addToSoggetti(new DocumentoSoggettoDTO(tipoSoggetto: TipoSoggetto.UO_PROTOCOLLANTE, unitaSo4: unitaProtocollante.toDTO()))
        }

        if (preferenzeUtenteService.duplicaProtocolloCopiaFascicolo) {
            copiaProtocollo.fascicolo = protocollo.fascicolo?.toDTO()
        }
        if (preferenzeUtenteService.getPreferenzaYN(privilegioCopiaRapporti)) {
            for (Corrispondente corrispondente : protocollo.corrispondenti) {
                CorrispondenteDTO copiaCorrispondente = new CorrispondenteDTO()
                copiaProtocollo.addToCorrispondenti(copiaCorrispondente)
                copiaCorrispondente.barcodeSpedizione = corrispondente.barcodeSpedizione
                copiaCorrispondente.cap = corrispondente.cap
                copiaCorrispondente.codiceFiscale = corrispondente.codiceFiscale
                copiaCorrispondente.idFiscaleEstero = corrispondente.idFiscaleEstero
                copiaCorrispondente.cognome = corrispondente.cognome
                copiaCorrispondente.comune = corrispondente.comune
                copiaCorrispondente.conoscenza = corrispondente.conoscenza
                copiaCorrispondente.tipoCorrispondente = corrispondente.tipoCorrispondente
                copiaCorrispondente.dataSpedizione = corrispondente.dataSpedizione
                copiaCorrispondente.denominazione = corrispondente.denominazione
                copiaCorrispondente.email = corrispondente.email
                copiaCorrispondente.fax = corrispondente.fax
                copiaCorrispondente.indirizzo = corrispondente.indirizzo
                copiaCorrispondente.tipoIndirizzo = corrispondente.tipoIndirizzo
                copiaCorrispondente.nome = corrispondente.nome
                copiaCorrispondente.partitaIva = corrispondente.partitaIva
                copiaCorrispondente.provinciaSigla = corrispondente.provinciaSigla
                copiaCorrispondente.tipoSoggetto = corrispondente.tipoSoggetto?.toDTO()
                copiaCorrispondente.modalitaInvioRicezione = corrispondente.modalitaInvioRicezione?.toDTO()
                for (Indirizzo indirizzo : corrispondente.indirizzi) {
                    IndirizzoDTO copiaIndirizzo = new IndirizzoDTO()
                    copiaCorrispondente.addToIndirizzi(copiaIndirizzo)
                    copiaIndirizzo.codice = indirizzo.codice
                    copiaIndirizzo.denominazione = indirizzo.denominazione
                    copiaIndirizzo.cap = indirizzo.cap
                    copiaIndirizzo.comune = indirizzo.comune
                    copiaIndirizzo.email = indirizzo.email
                    copiaIndirizzo.fax = indirizzo.fax
                    copiaIndirizzo.indirizzo = indirizzo.indirizzo
                    copiaIndirizzo.tipoIndirizzo = indirizzo.tipoIndirizzo
                    copiaIndirizzo.provinciaSigla = indirizzo.provinciaSigla
                }
            }
        }

        if (preferenzeUtenteService.getPreferenzaYN(privilegioCopiaSmistamenti)) {
            So4UnitaPubbDTO unitaPubbDTO = unitaProtocollante?.toDTO()
            for (Smistamento smistamento : protocollo.smistamentiValidi) {
                if (!smistamento.attivo || smistamento.isSmistamentoAdUnitaChiusa()) {
                    continue
                }
                SmistamentoDTO copiaSmistamento = new SmistamentoDTO()
                copiaProtocollo.addToSmistamenti(copiaSmistamento)
                copiaSmistamento.tipoSmistamento = smistamento.tipoSmistamento
                copiaSmistamento.unitaSmistamento = smistamento.unitaSmistamento.toDTO()
                copiaSmistamento.dataSmistamento = dateService.getCurrentDate()
                copiaSmistamento.statoSmistamento = Smistamento.CREATO
                copiaSmistamento.utenteTrasmissione = utenteCorrente
                copiaSmistamento.unitaTrasmissione = unitaPubbDTO
            }
        }
        return copiaProtocollo
    }

    ProtocolloDTO rispondi(Protocollo protocollo, TipoProtocollo tipoProtocollo = null
                           , String privilegioCopiaRapportiRisposta = PreferenzeUtenteService.DUPLICA_PROTOCOLLO_COPIA_RAPPORTI_RISPOSTA
                           , String privilegioCopiaSmistamentiRisposta = PreferenzeUtenteService.DUPLICA_PROTOCOLLO_COPIA_SMISTAMENTI_RISPOSTA) {
        ProtocolloDTO risposta = duplica(protocollo, privilegioCopiaRapportiRisposta, privilegioCopiaSmistamentiRisposta)

        // setto a null il tipoProtocollo del documento duplicato per calcolarlo successivamente
        risposta.tipoProtocollo = null
        risposta.modalitaInvioRicezione = null

        // quando faccio una risposta, devo invertire i movimenti
        if (protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) {
            risposta.movimento = Protocollo.MOVIMENTO_ARRIVO
        } else if (protocollo.movimento == Protocollo.MOVIMENTO_ARRIVO) {
            risposta.movimento = Protocollo.MOVIMENTO_PARTENZA
        }
        // se mi viene passato un tipo protocollo, uso direttamente quello
        if (tipoProtocollo != null) {
            risposta.tipoProtocollo = tipoProtocollo.toDTO("tipologiaSoggetto.layoutSoggetti")
        }
        // rimuovo il file principale proveniente dalla copia
        FileDocumentoDTO principale = risposta.testoPrincipale
        if (principale != null) {
            risposta.removeFromFileDocumenti(principale)
        }
        // schema di protocollo: se si risponde a un documento con schema di protocollo con associato uno schema di risposta,
        // assume quest'ultimo valore, altrimenti viene copiato lo schema del documento a cui si risponde se quello di partenza
        // non è uno schema di risposta, nullo altrimenti
        if (protocollo.schemaProtocollo != null && protocollo.schemaProtocollo.valido) {
            if (protocollo.schemaProtocollo.schemaProtocolloRisposta) {
                risposta.schemaProtocollo = protocollo.schemaProtocollo.schemaProtocolloRisposta?.toDTO(["tipoProtocollo.tipologiaSoggetto.layoutSoggetti"])
            }
            if (risposta.schemaProtocollo == null && !protocollo.schemaProtocollo.risposta) {
                risposta.schemaProtocollo = protocollo.schemaProtocollo.toDTO()
            }
            // lo schema di protocollo deve avere il movimento "concorde" con la risposta
            if (risposta.schemaProtocollo?.movimento != null && risposta.schemaProtocollo.movimento != risposta.movimento) {
                risposta.schemaProtocollo = null
            }
        }

        if (protocollo.tipoProtocollo.categoriaProtocollo.isPec()) {
            if (protocollo.schemaProtocollo?.schemaProtocolloRisposta) {
                if (protocollo.schemaProtocollo.schemaProtocolloRisposta.tipoProtocollo == null) {
                    risposta.tipoProtocollo = TipoProtocollo.findByCodice(Protocollo.TIPO_DOCUMENTO)?.toDTO("tipologiaSoggetto.layoutSoggetti")
                } else if (protocollo.schemaProtocollo.schemaProtocolloRisposta.tipoProtocollo.categoriaProtocollo?.isLettera() ||
                        protocollo.schemaProtocollo.schemaProtocolloRisposta.tipoProtocollo.categoriaProtocollo?.isProtocollo()) {
                    risposta.tipoProtocollo = protocollo.schemaProtocollo.schemaProtocolloRisposta.tipoProtocollo.toDTO()
                } else {
                    throw new ProtocolloRuntimeException("Categoria associata al flusso dello schema di risposta non corretta")
                }
            } else {
                if (risposta.tipoProtocollo == null && risposta.schemaProtocollo != null) {
                    risposta.tipoProtocollo = risposta.schemaProtocollo.tipoProtocollo
                }
            }
        } else {
            if (risposta.tipoProtocollo == null && risposta.schemaProtocollo != null) {
                risposta.tipoProtocollo = risposta.schemaProtocollo.tipoProtocollo
            }
        }

        if (risposta.tipoProtocollo == null) {
            // FIXME: bisognerebbe impostare un parametro per il tipo di protocollo manuale di default
            risposta.tipoProtocollo = TipoProtocollo.findByCodice(Protocollo.TIPO_DOCUMENTO)?.toDTO("tipologiaSoggetto.layoutSoggetti")
        }

        So4UnitaPubb unitaProtocollante = protocollo.getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE).unitaSo4
        Ad4UtenteDTO utenteCorrente = springSecurityService.currentUser.toDTO()
        boolean privilegiCreazione = privilegioUtenteService.utenteHaPrivilegioPerUnita(risposta.categoriaProtocollo?.privilegioCreazione, unitaProtocollante?.codice, utenteCorrente.domainObject)
        if (privilegiCreazione) {
            risposta.addToSoggetti(new DocumentoSoggettoDTO(tipoSoggetto: TipoSoggetto.UO_PROTOCOLLANTE, unitaSo4: unitaProtocollante.toDTO()))
        }
        risposta.addToDocumentiCollegati(new DocumentoCollegatoDTO(tipoCollegamento: new TipoCollegamentoDTO(codice: TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE), collegato: protocollo.toDTO()))
        // se sto facendo rispondi di una lettera, non devo copiare la modalità di invio ricezione
        if (risposta.categoriaProtocollo?.lettera) {
            risposta.modalitaInvioRicezione = null
        }
        // se ho dei dati di accesso civico, li collego.
        ProtocolloAccessoCivico protocolloAccessoCivico = ProtocolloAccessoCivico.findByProtocolloDomanda(protocollo)
        if (protocolloAccessoCivico != null) {
            risposta.addToDocumentiCollegati(new DocumentoCollegatoDTO(tipoCollegamento: new TipoCollegamentoDTO(codice: TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO), collegato: protocollo.toDTO()))
        }
        return risposta
    }

    ProtocolloDTO rispondiConLettera(Protocollo protocollo, TipoProtocollo tipoProtocollo = null
                                     , String privilegioCopiaRapportiRisposta = PreferenzeUtenteService.DUPLICA_PROTOCOLLO_COPIA_RAPPORTI_RISPOSTA
                                     , String privilegioCopiaSmistamentiRisposta = PreferenzeUtenteService.DUPLICA_PROTOCOLLO_COPIA_SMISTAMENTI_RISPOSTA) {
        //Chiamo rispondi
        ProtocolloDTO risposta = rispondi(protocollo, tipoProtocollo)
        return risposta
    }

    ProtocolloDTO creaInoltro(Protocollo protocollo, TipoProtocollo tipoProtocollo = null) {
        ProtocolloDTO inoltroDto = rispondi(protocollo, tipoProtocollo, "-- non copiare rapporti --", "-- non copiare smistamenti --")
        inoltroDto.movimento = Protocollo.MOVIMENTO_PARTENZA
        // se sto creando un inoltro per una pec, devo gestire in maniera diversa il tipo-protocollo
        if (protocollo.categoriaProtocollo.pec && tipoProtocollo == null) {
            // FIXME: cerco il tipo di protocollo manuale di "default", di solito ce ne è uno solo.
            inoltroDto.tipoProtocollo = TipoProtocollo.findByCodice(Protocollo.TIPO_DOCUMENTO).toDTO()
        }
        if (protocollo.schemaProtocollo != null && !protocollo.schemaProtocollo.risposta) {
            inoltroDto.schemaProtocollo = protocollo.schemaProtocollo.toDTO()
        }
        inoltroDto.addToDocumentiCollegati(new DocumentoCollegatoDTO(tipoCollegamento: new TipoCollegamentoDTO(codice: TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE), collegato: protocollo.toDTO()))
        Protocollo inoltro = new Protocollo()

        // se la categoria scelta è una lettera i soggetti vengono calcolati in base alle regole di calcolo dei default
        if (inoltroDto.tipoProtocollo.categoriaProtocollo.isLettera()) {
            inoltro.tipoProtocollo = inoltroDto.tipoProtocollo?.domainObject
            inoltroDto.controlloFunzionario = inoltroDto.tipoProtocollo?.getFunzionarioObbligatorio()
            inoltroDto.controlloFirmatario = inoltroDto.tipoProtocollo?.getFirmatarioObbligatorio()

            Map soggetti = tipologiaSoggettoService.calcolaSoggetti(inoltro, inoltro.tipoProtocollo.tipologiaSoggetto)
            creaSoggettoDefault(inoltro, TipoSoggetto.REDATTORE, soggetti)
            creaSoggettoDefault(inoltro, TipoSoggetto.UO_PROTOCOLLANTE, soggetti)
            creaSoggettoDefault(inoltro, TipoSoggetto.FIRMATARIO, soggetti)
            creaSoggettoDefault(inoltro, TipoSoggetto.FUNZIONARIO, soggetti)

            inoltroDto.dataRedazione = dateService.currentDate
        } else {
            // la "salva" non crea i soggetti perché purtroppo questi vengono creati nel ProtocolloViewModel leggendo dalla mappa "soggetti"
            // per questa ragione, copio i soggetti del dto:
            for (DocumentoSoggettoDTO documentoSoggettoDTO : inoltroDto.soggetti) {
                inoltro.setSoggetto(documentoSoggettoDTO.tipoSoggetto, documentoSoggettoDTO.utenteAd4?.domainObject, documentoSoggettoDTO.unitaSo4?.domainObject)
            }
        }

        salva(inoltro, inoltroDto)
        // aggiungo il file principale al nuovo protocollo:
        if (protocollo.filePrincipale != null) {
            Allegato allegato = new Allegato(tipoAllegato: TipoAllegato.findByAcronimo(TipoAllegato.ACRONIMO_DEFAULT)
                    , descrizione: "file principale"
                    , commento: "file principale"
                    , sequenza: 1
                    , quantita: 1, stampaUnica: false).save()
            FileDocumento file = protocollo.filePrincipale
            FileDocumento copiaFile = new FileDocumento(codice: FileDocumento.CODICE_FILE_ALLEGATO
                    , nome: file.nome
                    , contentType: file.contentType
                    , dimensione: file.dimensione
                    , modificabile: false
                    , modelloTesto: file.modelloTesto
                    , firmato: file.firmato)
            inoltro.addDocumentoAllegato(allegato)
            inoltro.save()
            gestoreFile.addFile(allegato, copiaFile, gestoreFile.getFile(protocollo, file))
            if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                verificaFirmaFileDocumentoCopiato(copiaFile, file)
                allegato.addToFileDocumenti(copiaFile)
            }
        }
        // copio gli allegati nel nuovo allegato
        copiaAllegati(protocollo, inoltro)
        // istanzio l'iter
        wkfIterService.istanziaIter(inoltro.tipoProtocollo.cfgIter, inoltro)

        return inoltro.toDTO([
                'tipoProtocollo',
                'tipoProtocollo.tipologiaSoggetto',
                'testo',
                'tipoRegistro',
                'titolari.fascicolo',
                'titolari.classificazione',
                'smistamenti',
                'corrispondenti',
                'classificazione',
                'schemaProtocollo',
                'tipoProtocollo.schemaProtocollo',
                'schemaProtocollo.tipoRegistro',
                'schemaProtocollo.ufficioEsibente',
                'fascicolo',
                'fileDocumenti'
        ])
    }

    @Transactional(readOnly = true)
    Protocollo getProtocolloPrecedente(long id) {
        return protocolloRepository.getProtocolloPrecedente(id, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
    }

    @Transactional(readOnly = true)
    Protocollo getProtocollo(long id) {
        return protocolloRepository.getProtocolloFromId(id)
    }

    @Transactional(readOnly = true)
    List<Protocollo> findAllByIdInList(List<Long> ids) {
        return protocolloRepository.findAllByIdInList(ids)
    }

    @Transactional(readOnly = true)
    List<Protocollo> getProtocolliSuccessivi(long id) {
        return protocolloRepository.getProtocolliSuccessivi(id, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
    }

    @Transactional(readOnly = true)
    List<TipoCollegamento> getTipiCollegamentoUtilizzabili() {
        return tipoCollegamentoRepository.utilizzabili(TipoCollegamentoConstants.nonUtilizzabili)
    }

    @Transactional(readOnly = true)
    List<DocumentoCollegato> getCollegamentiVisibili(Protocollo protocollo) {
        return documentoCollegatoRepository.collegamentiVisibili(protocollo, [TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_ALLEGATO)])
    }

    @Transactional(readOnly = true)
    public boolean isProtocolloPec(ProtocolloDTO protocollo) {
        if (protocollo == null) {
            return false
        }
        if (protocollo.tipoProtocollo == null) {
            return false
        }
        return protocollo.tipoProtocollo.categoriaProtocollo.isPec()
    }

    private void verificaFirmaFileDocumentoCopiato(FileDocumento copiaFile, FileDocumento file) {
        if (copiaFile.firmato) {
            for (FileDocumentoFirmatario firmatario : file.firmatari) {
                FileDocumentoFirmatario fileDocumentoFirmatario = new FileDocumentoFirmatario()
                fileDocumentoFirmatario.stato = FileDocumentoFirmatario.VERIFICATO
                fileDocumentoFirmatario.dataFirma = firmatario.dataFirma
                fileDocumentoFirmatario.nominativo = firmatario.nominativo
                fileDocumentoFirmatario.dataVerifica = firmatario.dataVerifica
                copiaFile.addToFirmatari(fileDocumentoFirmatario)
                fileDocumentoFirmatario.save()
            }
            copiaFile.save()
        } else {
            documentoService.estraiInformazioneFileFirmato(copiaFile)
        }
    }

    private void creaSoggettoDefault(it.finmatica.protocollo.documenti.Protocollo protocollo, String soggetto, Map soggetti) {

        TipologiaSoggettoRegola regola = TipologiaSoggettoRegola.createCriteria().get {
            eq("tipologiaSoggetto.id", protocollo.tipoProtocollo.tipologiaSoggetto.id)
            eq("tipoSoggetto", soggetto)

            fetchMode("tipoSoggetto", FetchMode.JOIN)
            fetchMode("tipoSoggettoPartenza", FetchMode.JOIN)
            fetchMode("regolaDefault", FetchMode.JOIN)
        }

        Map soggettoResult = tipologiaSoggettoService.creaSoggetto(protocollo, regola, soggetti)
        protocollo.setSoggetto(soggetto, soggettoResult?.utente?.domainObject, soggettoResult?.unita?.domainObject)
    }

    ProtocolloDTO creaInoltroConLettera(Protocollo protocollo, TipoProtocollo tipoProtocollo) {

        ProtocolloDTO inoltro = creaInoltro(protocollo, tipoProtocollo)
        return inoltro
    }

    @CompileDynamic
    private So4UnitaPubb getUnitaPerCodice(String codiceUnita) {
        if (codiceUnita?.trim()?.length() > 0) {
            return So4UnitaPubb.allaData().perOttica(Impostazioni.OTTICA_SO4.valore).findByCodice(codiceUnita)
        }
        return null
    }

/**
 * Controlla che il protocollo sia riservato o inserito in fascicoli riservati
 * (il controllo include anche le posizioni archivistiche secondarie)
 *
 * @param protocollo
 * @return
 */
    @Transactional(readOnly = true)
    boolean isRiservato(Object protocollo) {
        if (!(protocollo instanceof Protocollo)) {
            return false
        }
        if (protocollo.riservato) {
            return true
        }
        if (protocollo.fascicolo?.riservato) {
            return true
        }
        for (DocumentoTitolario t : protocollo.titolari) {
            if (t.fascicolo?.riservato) {
                return true
            }
        }
        return false
    }

    private void copiaAllegati(Protocollo src, Protocollo dest) {
        // aggiungo tutti gli allegati al nuovo protocollo:
        for (Allegato allegato : src.allegati) {
            if (allegato.tipoAllegato.codice == TipoAllegato.CODICE_TIPO_ALLEGATO) {
                Allegato copia = new Allegato()
                copia.tipoAllegato = allegato.tipoAllegato
                copia.quantita = allegato.quantita
                copia.tipoOggetto = allegato.tipoOggetto
                copia.descrizione = allegato.descrizione
                copia.commento = allegato.commento
                copia.ubicazione = allegato.ubicazione
                copia.origine = allegato.origine
                copia.sequenza = documentoService.getSequenzaNuovoAllegato(dest.toDTO())
                copia.stampaUnica = allegato.stampaUnica
                copia.numPagine = allegato.numPagine
                copia.save()
                dest.addDocumentoAllegato(copia)
                dest.save()
                for (FileDocumento file : allegato.fileDocumenti) {
                    // TODO da testare bug MODENA
                    if (file.codice != FileDocumento.CODICE_FILE_ORIGINALE) {
                        FileDocumento copiaFile = new FileDocumento(codice: FileDocumento.CODICE_FILE_ALLEGATO
                                , nome: file.nome
                                , contentType: file.contentType
                                , dimensione: file.dimensione
                                , modificabile: file.modificabile
                                , modelloTesto: file.modelloTesto
                                , firmato: file.firmato)
                        gestoreFile.addFile(copia, copiaFile, gestoreFile.getFile(allegato, file))
                        if (Impostazioni.ALLEGATO_VERIFICA_FIRMA.abilitato) {
                            verificaFirmaFileDocumentoCopiato(copiaFile, file)
                            copia.addToFileDocumenti(copiaFile)
                        }
                    }
                }
            }
        }
    }

    boolean utenteHaUnita(ProtocolloDTO protocollo, So4UnitaPubb unitaPubb) {
        List<So4UnitaPubb> listaUo = tipologiaSoggettoService.calcolaListaSoggetti(protocollo.tipoProtocollo.tipologiaSoggetto.id, protocollo, null, TipoSoggetto.UO_PROTOCOLLANTE, "")
        for (So4UnitaPubb uo : listaUo) {
            if (uo.progr == unitaPubb.progr &&
                    uo.dal == unitaPubb.dal &&
                    uo.ottica.codice == unitaPubb.ottica.codice) {
                return true
            }
        }
        return false
    }

    private void verificaFirmaFilePrincipale(List<VerificatoreFirma.RisultatoVerifica> risultatiVerifica, Protocollo protocollo) {
        if (risultatiVerifica?.size() > 0) {
            fileDocumentoService.aggiornaVerificaFirma(protocollo.getFilePrincipale())
            protocolloGdmService.salvaProtocollo(protocollo, true)
        }
    }

    /** Metodo che dato un protocollo
     * restituisce la lista dei FileDocumento contenuti compresi i suoi allegati
     *  */
    private ArrayList<FileDocumento> getListaFile(Protocollo protocollo) {
        ArrayList<FileDocumento> listaFile = new ArrayList<FileDocumento>()
        for (fileDocumento in protocollo.fileDocumenti) {
            listaFile.add(fileDocumento)
        }
        for (allegato in protocollo.getAllegati()) {
            for (fileDocumento in allegato.fileDocumenti) {
                listaFile.add(fileDocumento)
            }
        }
        return listaFile
    }

/** Metodo che dato un protocollo
 * restituisce una lista di id File che hanno i nomi
 * duplicati. Viene escluso dalla lista solo il primo file utile
 * non unicovo
 *  */
    private ArrayList<Long> getListaIdFileNonUnivoci(Protocollo protocollo) {
        ArrayList<Long> listaIdFileNonUnicoci = new ArrayList<Long>()
        ArrayList<String> listaNomiFile = new ArrayList<String>()
        for (fileDocumento in getListaFile(protocollo)) {
            if ("LETTERAUNIONE.RTFHIDDEN".equals(fileDocumento.getNome())) {
                continue
            }
            if (listaNomiFile.contains(fileDocumento.getNome())) {
                listaIdFileNonUnicoci.add(fileDocumento.getId())
            }
            listaNomiFile.add(fileDocumento.getNome())
        }
        return listaIdFileNonUnicoci
    }

/**
 * Dato un protocollo (categoria : DA_NON_PROTOCOLLARE)
 * Prepara la predisposizione alla protocollazione
 *
 * @param protocollo
 * @return
 */
    Protocollo creaProtocollo(Protocollo protocollo) {

        eliminaIter(protocollo.toDTO())

        for (Smistamento smistamento : protocollo.smistamenti) {
            smistamentoService.storicizzaSmistamento(smistamento)
        }

        ProtocolloDTO protocolloDaCreare = copia(protocollo)

        TipoProtocollo tipoProtocollo = TipoProtocollo.findByCodice(Protocollo.TIPO_DOCUMENTO)
        protocolloDaCreare.tipoProtocollo = tipoProtocollo.toDTO()
        protocolloDaCreare.smistamenti?.clear()
        protocolloDaCreare.dataRedazione = null
        protocolloDaCreare.datiScarto = null
        protocolloDaCreare.schemaProtocollo = null
        protocolloDaCreare.movimento = tipoProtocollo.movimento
        Protocollo protocolloD = new Protocollo()
        salva(protocolloD, protocolloDaCreare, false)

        copiaAllegati(protocollo, protocolloD)
        salvaCollegamentoUnico(protocolloD, protocollo, TipoCollegamentoConstants.CODICE_PROT_DA_FASCICOLARE)

        wkfIterService.istanziaIter(tipoProtocollo.getCfgIter(), protocolloD)

        elimina(Protocollo.get(protocollo.id))

        return protocolloD
    }

    @Transactional(readOnly = true)
    boolean isModificabilitaTesto(Protocollo protocollo, Ad4Utente utenteAd4, boolean isAllegato = false) {

        if (protocollo?.categoriaProtocollo?.modelloTestoObbligatorio && !isAllegato) {
            return false
        }

        // 1. doc non protocollato
        if (!protocollo?.numero) {
            return true
        }
        // 2. doc protocollato - non bloccato - non inviato - privilegi MD
        if (protocollo?.numero && protocollo.isBloccato() == false && !(isSpedito(protocollo) && protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) && privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.MODIFICA_FILE_ASSOCIATO, utenteAd4)) {
            return true
        }
        // 3. doc protocollato - bloccato -- non inviato - privilegi MDBLC
        if (protocollo?.numero && protocollo.isBloccato() && !(isSpedito(protocollo) && protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA) && privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.MODIFICA_DOCUMENTO_BLOCCO, utenteAd4)) {
            return true
        }

        return false
    }

    public void eliminaTesto(Protocollo p) {
        GestioneTestiModello modelloTesto = TipoProtocollo.modelloTestoPredefinito(p.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
        if (modelloTesto) {
            FileDocumentoDTO testo = new FileDocumentoDTO(codice: FileDocumento.CODICE_FILE_PRINCIPALE, nome: p.tipoProtocollo.categoria + "." + modelloTesto.tipo, contentType: TipoFile.getInstanceByEstensione(modelloTesto.tipo), valido: true, modificabile: true, firmato: false)
            FileDocumento fileDocumento = new FileDocumento(codice: testo.codice,
                    nome: testo.nome,
                    contentType: testo.contentType,
                    dimensione: testo.dimensione,
                    idFileEsterno: testo.idFileEsterno,
                    firmato: testo.firmato,
                    modificabile: testo.modificabile,
                    documento: p,
                    modelloTesto: modelloTesto)

            p.addToFileDocumenti(fileDocumento)
            fileDocumento.save()
        }
    }

    @Transactional(readOnly = true)
    List<Protocollo> trovaNuoviInserimenti(Date dataPartenza = new Date() - 1, Date dataFine = new Date(), TipoRegistro tipoRegistro, Long enteId) {
        return trovaPerData('data', dataPartenza, dataFine, tipoRegistro, enteId)
    }

    @Transactional(readOnly = true)
    List<Protocollo> trovaCandidatiModificati(Date dataPartenza = new Date() - 1, Date dataFine = new Date(), TipoRegistro tipoRegistro, Long enteId) {
        return trovaPerData('lastUpdated', dataPartenza, dataFine, tipoRegistro, enteId)
    }

    @Transactional(readOnly = true)
    List<Protocollo> trovaAnnullati(Date dataPartenza = new Date() - 1, Date dataFine = new Date(), TipoRegistro tipoRegistro, Long enteId) {
        return trovaPerData('dataAnnullamento', dataPartenza, dataFine, tipoRegistro, enteId)
    }

    private List<Protocollo> trovaPerData(String proprieta, Date dataPartenza, Date dataFine, TipoRegistro tipoRegistro, Long enteId) {
        // setto a mezzanotte per non sbagliarmi
        Protocollo.createCriteria().list {
            between(proprieta, dataPartenza, dataFine)
            order(proprieta, 'desc')
            isNotNull('numero')
            isNotNull('data')
            eq('tipoRegistro', tipoRegistro)
            ente {
                eq('id', enteId)
            }
        }
    }

    Protocollo salvaCollegamentoProvvedimento(Protocollo protocolloPrincipale, Protocollo collegato, String codiceTipoCollegamento) {
        if (protocolloPrincipale == null) {
            return null
        }
        DocumentoCollegato dc = new DocumentoCollegato(documento: protocolloPrincipale, collegato: collegato, tipoCollegamento: TipoCollegamento.findByCodice(codiceTipoCollegamento))
        protocolloPrincipale.addToDocumentiCollegati(dc)
        protocolloPrincipale.save()
        protocolloGdmService.salvaDocumentiCollegatiProvvedimento(protocolloPrincipale)
        return protocolloPrincipale
    }

    void eliminaDocumentoCollegatoProvvedimento(Protocollo protocollo, Protocollo collegato, String codiceTipoCollegamento) {
        protocollo.removeDocumentoCollegato(collegato, codiceTipoCollegamento)
        protocollo.save()
        //richiamo il savataggio su gdm che salva la nuova lista di elenco_annullandi
        protocolloGdmService.salvaDocumentiCollegatiProvvedimento(protocollo)
    }

    @Transactional(readOnly = true)
    public TipoCollegamento getTipoCollegamento(String codiceCollegamento) {
        return dizionariRepository.getTipoCollegamento(codiceCollegamento)
    }

    @Transactional(readOnly = true)
    public Protocollo getProtocolloPrecedente(Protocollo p) {
        return protocolloRepository.getProtocolloPrecedente(p.id, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
    }

/**
 * Ritorna i protocolli a cui sono associati una lista di schemi che hanno una risposta ed una scadenza valorizzata
 * ed un stato del flusso prima dell'INVIO
 * @return
 */
    @Transactional(readOnly = true)
    List<Protocollo> getDocumentiNonInviatiConSchemiAssociatiConScadenza() {

        List<SchemaProtocollo> schemiRispostaConScadenza = SchemaProtocollo.createCriteria().list {
            isNotNull("schemaProtocolloRisposta")
            isNotNull("scadenza")
        }

        if (schemiRispostaConScadenza?.size() > 0) {
            return Protocollo.executeQuery("""	
				SELECT  prot
				FROM   Protocollo prot
				WHERE 
				    prot.tipoProtocollo.categoria = :categoria 
					AND prot.iter.stepCorrente.cfgStep.nome != :stato
					AND prot.schemaProtocollo in :schemi
			""", [schemi: schemiRispostaConScadenza, stato: Protocollo.STEP_INVIATO, categoria: CategoriaProtocollo.CATEGORIA_LETTERA.codice])
        } else {
            return null
        }
    }

/**
 *   File: percorso del file principale da importare (esempio: http://APPSTEST/sta_GSDSVI/anava01GS.pdf )
 *   oggetto: potrebbero arrivare anche codice html Elenco%20Immigrati%20dal%2001-01-2012%20al%2031-12-2012
 *   tipoDoc: codice del tipo documento (schema di protocollo)
 *   modalita: ARR/PAR/INT
 *   class: codice della classifica (01/01)
 *   annoFasc: anno del fascicolo
 *   numeroFasc: numero fascicolo
 *   mittDest: denominazione / mail /ni del mittente destinatario
 *   annoPrec: anno del precedente
 *   numeroPrec: numero del precedente
 *   es.:http://localhost:8080/Protocollo/standalone.zul?operazione=APRI_PROTOCOLLO_DA_ESTERNO&modalita=ARR&file=http://homepages.inf.ed.ac.uk/neilb/TestWordDoc.doc&oggetto=X%20vvXX&annoFasc=2018&numeroFasc=1&numeroPrec=1&annoPrec=2018&mittDest=mia
 *   http://localhost:8080/Protocollo/standalone.zul?operazione=APRI_PROTOCOLLO_DA_ESTERNO&tipoDoc=DOCU&file=http://homepages.inf.ed.ac.uk/neilb/TestWordDoc.doc&oggetto=X%20vvXX&annoFasc=2018&numeroFasc=1&mittDest=mia&numeroPrec=1&annoPrec=2018&mittDest=mia
 *   http://localhost:8080/Protocollo/standalone.zul?operazione=APRI_PROTOCOLLO_DA_ESTERNO&idDoc=&tipoDoc=CPRO&oggetto=Elenco Immigrati dal 01-10-2019 al 31-10-2019&modalita=PAR&file=
 *   http://localhost:8080/Protocollo/standalone.zul?operazione=APRI_PROTOCOLLO_DA_ESTERNO&anno=2019&numero=1
 *   http://localhost:8080/Protocollo/standalone.zul?operazione=APRI_PROTOCOLLO_DA_ESTERNO&idDoc=&tipoDoc=CPRO&oggetto=Elenco%20Immigrati%20dal%2001-10-2019%20al%2031-10-2019&modalita=PAR&file=&class=01/01&mittDest=ROSSI
 **/
    it.finmatica.protocollo.documenti.ProtocolloDTO buildProtocolloFromUrl(List<CorrispondenteDTO> listaCorrispondentiDto,
                                                                           String pathFile, String oggetto, String movimento,
                                                                           String classificazione, String numeroFascicolo, String annoFascicolo,
                                                                           String schemaProtocollo,
                                                                           String numeroPrecedente, String annoPrecedente) {

        it.finmatica.protocollo.documenti.ProtocolloDTO protocollo = new it.finmatica.protocollo.documenti.ProtocolloDTO()
        protocollo.tipoOggetto = WkfTipoOggetto.get(it.finmatica.protocollo.documenti.Protocollo.TIPO_DOCUMENTO)?.toDTO()
        if (!StringUtils.isEmpty(schemaProtocollo)) {
            protocollo.schemaProtocollo = SchemaProtocollo.findByCodiceAndValido(schemaProtocollo, true)?.toDTO(["classificazione", "fascicolo", "files", "tipoProtocollo"])
        }

        protocollo.tipoProtocollo = TipoProtocollo.findByCodiceAndValido(Protocollo.TIPO_DOCUMENTO, true)?.toDTO()

        if (!StringUtils.isEmpty(movimento)) {
            protocollo.movimento = MovimentoConverter.INSTANCE.convertFromOld(movimento)
        } else {
            protocollo.movimento = protocollo.schemaProtocollo?.movimento
        }

        if (StringUtils.isEmpty(protocollo.movimento)) {
            String preferenzaModalita = preferenzeUtenteService.getModalita()
            if (!StringUtils.isEmpty(preferenzaModalita)) {
                protocollo.movimento = preferenzaModalita
            }
        }

        if (!StringUtils.isEmpty(classificazione)) {
            protocollo.classificazione = Classificazione.findByCodiceAndValidoAndAlIsNull(classificazione, true)?.toDTO()
        } else if (protocollo.schemaProtocollo != null) {
            protocollo.classificazione = protocollo.schemaProtocollo.classificazione
        }

        if (!StringUtils.isEmpty(numeroFascicolo) && !StringUtils.isEmpty(annoFascicolo)) {
            Classificazione classifica = null
            if (protocollo.classificazione) {
                classifica = Classificazione.get(protocollo.classificazione.id)
            }
            protocollo.fascicolo = Fascicolo.findByClassificazioneAndAnnoAndNumero(classifica, annoFascicolo, numeroFascicolo)?.toDTO("classificazione")
        } else if (protocollo.schemaProtocollo != null && protocollo.classificazione == null) {
            protocollo.fascicolo = protocollo.schemaProtocollo.fascicolo
            protocollo.classificazione = protocollo.fascicolo?.classificazione
        }

        if (!StringUtils.isEmpty(oggetto)) {

            protocollo.oggetto = oggetto
        } else if (protocollo.schemaProtocollo != null) {
            protocollo.oggetto = protocollo.schemaProtocollo.oggetto
        }

        if (!StringUtils.isEmpty(numeroPrecedente) && !StringUtils.isEmpty(annoPrecedente)) {
            try {
                if (annoPrecedente != "") {
                    Integer.parseInt(annoPrecedente)
                }
                if (numeroPrecedente != "") {
                    Integer.parseInt(numeroPrecedente)
                }
            }
            catch (NumberFormatException nfe) {
                log.error("È possibile inserire solo numeri nei campi 'annoPrec' e 'numeroPrec'")
            }

            ProtocolloEsternoDTO protocolloPrecedenteDTO = ProtocolloEsterno.createCriteria().get() {
                eq("anno", Integer.valueOf(annoPrecedente))
                eq("numero", Integer.valueOf(numeroPrecedente))
                eq("tipoRegistro.codice", ImpostazioniProtocollo.TIPO_REGISTRO.valore)

                isNotNull("anno")
                isNotNull("numero")
                isNotNull("data")

                fetchMode("tipoRegistro", org.hibernate.FetchMode.JOIN)
            }?.toDTO()

            if (protocolloPrecedenteDTO) {
                ProtocolloDTO prot = Protocollo.findByIdDocumentoEsterno(protocolloPrecedenteDTO.idDocumentoEsterno)?.toDTO()
                if (prot == null) {
                    Protocollo protDomain = new Protocollo(idDocumentoEsterno: protocolloPrecedenteDTO.idDocumentoEsterno,
                            anno: protocolloPrecedenteDTO.anno,
                            oggetto: protocolloPrecedenteDTO.oggetto,
                            tipoRegistro: protocolloPrecedenteDTO.tipoRegistro?.domainObject,
                            tipoProtocollo: TipoProtocollo.findByCategoria(protocolloPrecedenteDTO.categoria),
                            numero: protocolloPrecedenteDTO.numero)
                    prot = protDomain.save()?.toDTO()
                }

                if (protocolloPrecedenteDTO) {
                    DocumentoCollegatoDTO documentoCollegatoDTO = new DocumentoCollegatoDTO()
                    documentoCollegatoDTO.collegato = prot
                    documentoCollegatoDTO.documento = protocollo
                    documentoCollegatoDTO.tipoCollegamento = TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)?.toDTO()
                    protocollo.addToDocumentiCollegati(documentoCollegatoDTO)
                }
            }
        }

        Protocollo p = new Protocollo()

        if (listaCorrispondentiDto?.size() == 1) {
            protocollo.corrispondenti = listaCorrispondentiDto
        }

        if (!StringUtils.isEmpty(pathFile)) {

            URL url = new URL(pathFile);
            File file = new File(FilenameUtils.getName(url.getPath()));
            FileUtils.copyURLToFile(url, file);

            //File file = Paths.get(new java.net.URI(pathFile))?.toFile()
            if (file?.exists()) {

                salva(p, protocollo, false)
                wkfIterService.istanziaIter(p.tipoProtocollo.cfgIter, p)

                FileInputStream fileStream
                try {
                    fileStream = new FileInputStream(file)
                } catch (Exception e) {
                    throw new RuntimeException(e)
                }

                // creare il protocollo e salvare il file su gdm
                FileDocumento fileAllegato = new FileDocumento(codice: FileDocumento.CODICE_FILE_PRINCIPALE
                        , nome: file.name
                        , contentType: Files.probeContentType(file.toPath())
                        , valido: true
                        , modificabile: true
                        , firmato: false)
                p.addToFileDocumenti(fileAllegato)
                fileAllegato.save()
                gestoreFile.addFile(p, fileAllegato, fileStream)
                protocollo = p.toDTO()
            } else {
                log.error("File passato in nel parametro 'pathFile' non esiste:" + pathFile)
            }
        }

        // salvataggio degli allegati (files) allo schema protocollo se ci sono
        if (protocollo.schemaProtocollo?.files?.size() > 0) {

            if (p.idDocumentoEsterno == null) {
                salva(p, protocollo, false)
                wkfIterService.istanziaIter(p.tipoProtocollo.cfgIter, p)
            }

            allegatoProtocolloService.importaAllegatoSchemaProtocollo(p, p.schemaProtocollo)
            protocollo = p.toDTO()
        }

        if (listaCorrispondentiDto?.size() == 1 && p?.idDocumentoEsterno > 0) {

            corrispondenteService.salva(p, listaCorrispondentiDto)
            protocollo = p.toDTO()
        }

        return protocollo
    }

    @Transactional(readOnly = true)
    Protocollo findByAnnoAndNumeroAndTipoRegistro(Integer anno, Integer numero, String tipoRegistro = ImpostazioniProtocollo.TIPO_REGISTRO.valore) {
        return protocolloRepository.findByAnnoAndNumeroAndTipoRegistro(anno, numero, tipoRegistro)
    }

    @Transactional(readOnly = true)
    Corrispondente getCorrispondenteAmmAoo(Long idProtocollo, String tipoCorrispondente, String codAmm, String codAoo) {
        return protocolloRepository.getCorrispondenteDaIndirizzoAmmAoo(idProtocollo, tipoCorrispondente, codAmm, codAoo)
    }

    @Transactional(readOnly = true)
    Corrispondente getCorrispondenteAmm(Long idProtocollo, String tipoCorrispondente, String codAmm) {
        return protocolloRepository.getCorrispondenteDaIndirizzoAmm(idProtocollo, tipoCorrispondente, codAmm)
    }

    @Transactional(readOnly = true)
    boolean isSchemaProtocolloUsed(Long idSchemaProtocollo) {
        protocolloRepository.existsProtocolloBySchemaProtocolloId(idSchemaProtocollo)
    }

    @CompileStatic
    @Transactional(readOnly = true)
    Protocollo findById(Long id) {
        protocolloRepository.findOne(id)
    }

    @Transactional(readOnly = true)
    Protocollo findByIdEsterno(Long id) {
        protocolloRepository.findByIdDocumentoEsterno(id)
    }

    @Transactional(readOnly = true)
    List<Long> findExternalIdsByFilter(ProtocolloJPQLFilter filter) {
        def query = filter.toSinglePropertyJPQL('idDocumentoEsterno')
        TypedQuery<Long> q = entityManager.createQuery(query, Long)
        for (Map.Entry<String, Object> entry in filter.params) {
            q.setParameter(entry.key, entry.value)
        }
        return q.resultList
    }

    @Transactional(readOnly = true)
    boolean isSpedito(Protocollo protocollo) {
        return (mailService.caricaMessaggiInviati(protocollo)?.size() > 0)
    }

    ProtocolloDatiInteroperabilita aggiungiSegnalazioniProtocolloDatiIterop(ProtocolloDatiInteroperabilita protocolloDatiInteroperabilita, List<String> segnalazioni) {
        String segnalazioniStr = ""
        for (int i = 0; i < segnalazioni.size(); i++) {
            if (i > 0) {
                segnalazioniStr += "\n"
            }

            segnalazioniStr += segnalazioni.get(i)
        }

        if (segnalazioniStr != "") {
            protocolloDatiInteroperabilita.motivoInterventoOperatore = segnalazioniStr + ((protocolloDatiInteroperabilita.motivoInterventoOperatore != null &&
                    !protocolloDatiInteroperabilita.motivoInterventoOperatore?.equals("")) ? "\n" + protocolloDatiInteroperabilita.motivoInterventoOperatore : "")
        }

        return protocolloDatiInteroperabilita
    }

    @Transactional(readOnly = true)
    String getFormatoDataProtocollo(Protocollo protocollo) {
        String formato = ImpostazioniProtocollo.FORMATO_DATAORA.valore
        if (formato == null || formato?.equals("")) {
            formato = "dd/MM/yyyy H:mm:ss";
        }

        return formato
    }
}