package it.finmatica.protocollo.integrazioni.si4cs

import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggettoDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggio
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.dizionari.DizionariRepository
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.dizionari.SchemaProtocolloIntegrazione
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloSegnaturaService
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.interoperabilita.ProtocolloDatiInteroperabilita
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloUtilService
import it.finmatica.protocollo.integrazioni.segnatura.interop.SegnaturaInteropService
import it.finmatica.protocollo.integrazioni.segnatura.interop.postacert.xsd.Postacert
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.AggiornamentoConferma
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.AnnullamentoProtocollazione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.ConfermaRicezione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.NotificaEccezione
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Segnatura
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionSynchronizationAdapter
import org.springframework.transaction.support.TransactionSynchronizationManager
import org.xml.sax.XMLReader
import org.zkoss.zk.ui.select.annotation.WireVariable

import javax.xml.bind.JAXBContext
import javax.xml.bind.Marshaller
import javax.xml.bind.Unmarshaller
import javax.xml.stream.XMLInputFactory
import javax.xml.stream.XMLStreamReader
import javax.xml.stream.util.StreamReaderDelegate
import java.text.SimpleDateFormat

@Slf4j
@Transactional
@Service
class MessaggiSi4CSService {

    @Autowired
    Si4CSService si4CSService
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService
    @Autowired
    SegnaturaInteropService segnaturaInteropService
    @Autowired
    ProtocolloSegnaturaService protocolloSegnaturaService
    @Autowired
    MessaggiInviatiService messaggiInviatiService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    ProtocolloUtilService protocolloUtilService
    @Autowired
    DizionariRepository dizionariRepository

    void creaMessaggioInviatoAgsprDaSi4CS(String tag, String mittente, String emailMittente, String testo, String oggetto,
                                          Protocollo protocollo, List<FileDocumentoDTO> fileAllegati,
                                          String mittenteAmm, String mittenteAoo, String mittenteUo,
                                          TipoCollegamento collegamentoProtoMail,
                                          List<CorrispondenteDTO> corrispondenti, boolean segnatura, boolean segnaturaCompleta,
                                          String testoFileAllegato, String nomeFileTestoAllegato, String tipoRicevutaConsegna = "completa",
                                          MessaggioRicevuto messaggioRicevuto = null, boolean isImpresaInUnGiorno = false) {
        List<String> destinatari = new ArrayList<String>()
        List<String> destinatariCC = new ArrayList<String>()
        List<String> destinatariBCC = new ArrayList<String>()
        List<String> idAllegati = new ArrayList<String>()

        for (CorrispondenteDTO c : corrispondenti) {
            if (c.conoscenza) {
                destinatariCC.add(c.email?.toString())
            } else {
                destinatari.add(c.email?.toString())
            }
        }

        for (fileAllegato in fileAllegati) {
            idAllegati.add("" + fileAllegato.idFileEsterno)
        }

        log.info("## creaMessaggioInviatoAgsprDaSi4CS per protocollo con id: " + protocollo.id + ", mittente:" + mittente +
                ", destinatari " + destinatari + ", destinatariCC: " + destinatariCC)

        MessaggioInviato messaggioInviato = new MessaggioInviato(
                accettazione: false, nonAccettazione: false, oggetto: oggetto, testo: testo, mittente: emailMittente,
                destinatari: destinatari.join(","), destinatariConoscenza: destinatariCC.join(","), destinatariNascosti: destinatariBCC.join(","),
                tagmail: tag, mittenteAmministrazione: mittenteAmm, mittenteAoo: mittenteAoo, mittenteUo: mittenteUo
        )

        messaggioInviato = messaggiInviatiService.salva(messaggioInviato)

        log.debug("Salvato in AGP_MSG_INVIATI_DATI_PROT con id" + messaggioInviato.id)

        Messaggio messaggio = Messaggio.findById(messaggioInviato.id)

        if (messaggio == null) {
            log.error("Attenzione! non trovo il messaggio nella agp_messaggi con id: " + messaggioInviato.id)
            throw new ProtocolloRuntimeException("Attenzione! non trovo il messaggio nella agp_messaggi con id: " + messaggioInviato.id)
        }

        //Creo i corrispondenti messaggio (tranne per l'eccezione, li non servono)
        if (!nomeFileTestoAllegato?.equals("eccezione.xml") || nomeFileTestoAllegato==null) {
            for (CorrispondenteDTO c : corrispondenti) {
                log.debug("Salvo il corrispondente messaggio: " + c.denominazione)
                CorrispondenteMessaggio corrispondenteMessaggio = new CorrispondenteMessaggio()
                corrispondenteMessaggio.conoscenza = c.conoscenza
                corrispondenteMessaggio.denominazione = c.denominazione
                corrispondenteMessaggio.email = c.email?.trim()
                corrispondenteMessaggio.corrispondente = c.domainObject
                corrispondenteMessaggio.messaggio = messaggio
                corrispondenteMessaggio.save()
            }
        }

        String idAllegatoSegnaturaOrAltro = null
        if (segnatura) {
            log.debug("Genero la segnatura")
            String segnaturaString = segnaturaInteropService.produciSegnatura(protocollo, messaggio, segnaturaCompleta, true, false, isImpresaInUnGiorno)

            log.debug("Allego la segnatura al messaggio")

            String nomeFileSegnatura
            if (isImpresaInUnGiorno) {
                nomeFileSegnatura = "entesuap.xml"
            } else {
                nomeFileSegnatura = "segnatura.xml"
            }
            idAllegatoSegnaturaOrAltro = messaggiInviatiService.aggiungiFile(messaggioInviato, segnaturaString, nomeFileSegnatura)

            log.debug("IdFileEsterno segnatura: " + idAllegatoSegnaturaOrAltro)
        } else {
            if (nomeFileTestoAllegato != null) {
                log.debug("Allego alla mail il file " + nomeFileTestoAllegato)

                idAllegatoSegnaturaOrAltro = messaggiInviatiService.aggiungiFile(messaggioInviato, testoFileAllegato, nomeFileTestoAllegato)

                log.debug("IdFileEsterno alla mail: " + idAllegatoSegnaturaOrAltro)
            }
        }

        log.debug("Aggiungo gli altri allegati selezionati dal protocollo")
        messaggiInviatiService.aggiungiAllegati(messaggioInviato, fileAllegati, (idAllegatoSegnaturaOrAltro == null) ? 0 : 1)

        if (idAllegatoSegnaturaOrAltro != null) {
            idAllegati.add(idAllegatoSegnaturaOrAltro)
        }

        if (protocollo.modalitaInvioRicezione == null) {
            protocollo.modalitaInvioRicezione = dizionariRepository.getModalitaInvioRicezione(ModalitaInvioRicezione.CODICE_PEC)
            protocolloService.salva(protocollo, true, false, true)
        }

        log.debug("Collego il messaggio inviato al protocollo")
        messaggiInviatiService.collegaMessaggioInviatoAProtocollo(messaggioInviato, protocollo, collegamentoProtoMail)

        // aggiungo l'handler per inviare al si4cs:
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
            @Override
            void afterCommit() {
                String idSi4Cs
                try {
                    log.info("In afterCommit invio il messaggio al si4cs")
                    idSi4Cs = si4CSService.inviaMessaggio(tag, mittente, emailMittente, testo, oggetto, idAllegati, destinatari, destinatariCC, destinatariBCC, tipoRicevutaConsegna)
                    log.info("idSi4Cs: " + idSi4Cs)
                }
                catch (Exception e) {
                    if (nomeFileTestoAllegato.equals("conferma.xml")) {
                        protocollo.datiInteroperabilita.inviataConferma = false
                        protocollo.datiInteroperabilita.save()
                        protocolloService.salva(protocollo)
                    }

                    log.error("Errore in creaMessaggioInviatoAgsprDaSi4CS - invio al si4cs", e)
                    throw new ProtocolloRuntimeException("Errore in creaMessaggioInviatoAgsprDaSi4CS - invio al si4cs", e)
                }

                if (nomeFileTestoAllegato.equals("conferma.xml")) {
                    protocollo.datiInteroperabilita.inviataConferma = true
                    protocollo.datiInteroperabilita.save()
                    protocolloService.salva(protocollo)
                }

                messaggioInviato.idMessaggioSi4Cs = Long.parseLong(idSi4Cs)
                messaggiInviatiService.salva(messaggioInviato)

                if (nomeFileTestoAllegato.equals("eccezione.xml") && messaggioRicevuto!=null) {
                    messaggioRicevuto.statoMessaggio = MessaggioRicevuto.Stato.GENERATA_ECCEZIONE
                    messaggiRicevutiService.salva(messaggioRicevuto.toDTO())

                    if (!ImpostazioniProtocollo.PROTOCOLLA_NOT_ECC.abilitato) {
                        protocolloService.elimina(protocollo, false, false)
                    }
                }
            }
        })
    }

    void aggiornaMessaggioInviatoASi4Cs(String idMessaggio, String statoSpedizione, Date dataSpedizione) {
        log.info("## aggiornaMessaggioInviatoASi4Cs con idMessaggio: " + idMessaggio)

        MessaggioInviato messaggioInviato = messaggiInviatiService.getMessaggioInviatoByIdSi4Cs(Long.parseLong(idMessaggio))

        if (messaggioInviato == null) {
            log.error("Attenzione! non trovo il messaggio nella AGP_MSG_INVIATI_DATI_PROT con idSi4Cs: " + idMessaggio)
            throw new ProtocolloRuntimeException("Attenzione! non trovo il messaggio nella AGP_MSG_INVIATI_DATI_PROT con idSi4Cs: " + idMessaggio)
        }

        log.info("aggiorno lo statoSpedizione: " + statoSpedizione + " e la dataSpedizione " + dataSpedizione)
        messaggioInviato.statoSpedizione = statoSpedizione
        messaggioInviato.dataSpedizione = dataSpedizione
        messaggiInviatiService.salva(messaggioInviato)
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    Protocollo creaMessaggioRicevutoAgsprDaSi4CS(String idMessaggio) {
        log.info("## creaMessaggioRicevutoAgsprDaSi4CS con idMessaggio: " + idMessaggio)

        if (messaggiRicevutiService.getMessaggioRicevuto(Long.parseLong(idMessaggio)) != null) {
            //Se il messaggio esiste già non lo devo di certo ricreare
            log.info("Messaggio già scaricato su AGSPR! Fine Elaborazione")
            return
        }

        Segnatura segnatura = null
        AggiornamentoConferma aggiornamentoConferma = null
        ConfermaRicezione confermaRicezione = null
        NotificaEccezione notificaEccezione = null
        AnnullamentoProtocollazione annullamentoProtocollazione = null
        Postacert postacert = null

        Long idAllegatoSegnatura
        Long idAllegatoAggiornamento, idAllegatoConferma, idAllegatoEccezione, idAllegatoAnnullamento
        Long idAllegatoDatiCertRicevuta
        boolean segnaturaCittadino = false

        log.debug("Richiamo servizio si4cs dettagli?messaggio")
        Map messaggioDettaglio = si4CSService.getMessaggioDettaglio(idMessaggio)
        log.debug("Risultato = " + messaggioDettaglio)

        Date dataSpedizione
        dataSpedizione = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse("" + messaggioDettaglio.data)
        Date dataDatiCertXmlRicevuta = null

        //TESTATA
        MessaggioRicevutoDTO messaggioRicevutoDTO = new MessaggioRicevutoDTO(idMessaggioSi4Cs: Long.parseLong(idMessaggio),
                riservato: false,
                statoMessaggio: MessaggioRicevuto.Stato.DA_GESTIRE,
                dataStato: new Date(),
                dataRicezione: new Date(),
                dataSpedizione: dataSpedizione,
                mittente: messaggioDettaglio.mittente,
                destinatari: messaggioDettaglio.destinatari,
                destinatariConoscenza: messaggioDettaglio.destinatari_conoscenza,
                destinatariNascosti: messaggioDettaglio.destinatari_nascosti,
                testo: messaggioDettaglio.testo,
                tipo: messaggioDettaglio.certificata,
                oggetto: messaggioDettaglio.oggetto
        )

        //ALLEGATI
        if (messaggioDettaglio.allegati != null && messaggioDettaglio.idDocumento != 0) {
            log.debug("Recupero i file dal documentale con idDocumento = " + messaggioDettaglio.idDocumento)
            //Recupero i file
            Documento documento = new Documento()
            documento.setId("" + messaggioDettaglio.idDocumento)
            documento = documentaleService.getDocumento(documento, [Documento.COMPONENTI.FILE])

            for (idAllegato in messaggioDettaglio.allegati) {
                File file = documento.getFiles()?.find { it.id == "" + idAllegato }

                if (file != null) {
                    log.debug("Aggiungo file <" + file.nome + "> ad AGP_MSG_RICEVUTI_DATI_PROT di AGSPR (solo come collegamento, non lo duplico su GDM)")

                    FileDocumentoDTO fileDocumentoDTO = new FileDocumentoDTO()
                    fileDocumentoDTO.nome = file.nome

                    if (file.nome.toLowerCase().equals("segnatura.xml") ||
                            file.nome.toLowerCase().equals("segnatura_cittadino.xml")) {
                        idAllegatoSegnatura = idAllegato
                        if (file.nome.toLowerCase().equals("segnatura_cittadino.xml")) {
                            segnaturaCittadino = true
                        }
                    } else if (file.nome.toLowerCase().equals("conferma.xml")) {
                        idAllegatoConferma = idAllegato
                    } else if (file.nome.toLowerCase().equals("aggiornamento.xml")) {
                        idAllegatoAggiornamento = idAllegato
                    } else if (file.nome.toLowerCase().equals("eccezione.xml")) {
                        idAllegatoEccezione = idAllegato
                    } else if (file.nome.toLowerCase().equals("annullamento.xml")) {
                        idAllegatoAnnullamento = idAllegato
                    } else if (file.nome.toLowerCase().equals("daticert.xml") && messaggioDettaglio.certified_type == "RICEVUTA") {
                        idAllegatoDatiCertRicevuta = idAllegato
                    }

                    fileDocumentoDTO.idFileEsterno = idAllegato
                    fileDocumentoDTO.contentType = (file.getContentType() == null) ? "application/octet-stream" : file.getContentType()
                    fileDocumentoDTO.dimensione = file.getDimensione()
                    messaggioRicevutoDTO.addToFileDocumenti(fileDocumentoDTO)
                }
            }
        }

        //EML
        if (messaggioDettaglio.messaggio_blob != 0) {
            log.debug("Aggiungo file fisico messaggio.eml ad AGP_MSG_RICEVUTI_DATI_PROT di AGSPR con il messaggio_blob di si4cs")
            Documento documentoFake = new Documento()
            File fileBlob = new File()
            fileBlob.setId("" + messaggioDettaglio.messaggio_blob)
            fileBlob = documentaleService.getFile(documentoFake, fileBlob)
            if (fileBlob != null) {
                FileDocumentoDTO fileDocumentoDTO = new FileDocumentoDTO()
                fileDocumentoDTO.nome = MessaggioRicevuto.MESSAGGIO_EML
                fileDocumentoDTO.idFileEsterno = messaggioDettaglio.messaggio_blob
                fileDocumentoDTO.contentType = (fileBlob.getContentType() == null) ? "application/octet-stream" : fileBlob.getContentType()
                fileDocumentoDTO.dimensione = fileBlob.getDimensione()
                fileDocumentoDTO.codice = FileDocumento.CODICE_FILE_EML
                messaggioRicevutoDTO.addToFileDocumenti(fileDocumentoDTO)
                try {
                    fileBlob.getInputStream().close()
                }
                catch (RuntimeException e) {
                    throw new Exception("errore nella lettura deil file in 'creaMessaggioRicevutoAgsprDaSi4CS'" + e.message, e)
                }
            }
        }

        if (idAllegatoSegnatura != null) {
            try {
                log.info("Parso la segnatura")
                segnatura = getSegnaturaFromFile("" + idAllegatoSegnatura)
            }
            catch (Exception e) {
                log.debug("Errore nel parse della segnatura: " + e.getMessage())
                messaggioRicevutoDTO.note = "Non è stato possibile trattare la segnatura per un errore: " + e.getMessage();
            }
        } else if (idAllegatoAggiornamento != null) {
            try {
                log.info("Parso la segnatura - aggiornamento.xml")
                aggiornamentoConferma = getSegnaturaAggiornamentoFromFile("" + idAllegatoAggiornamento)
            }
            catch (Exception e) {
                log.debug("Errore nel parse della segnatura - aggiornamento.xml: " + e.getMessage())
                messaggioRicevutoDTO.note = "Non è stato possibile trattare la segnatura/aggiornamento.xml per un errore: " + e.getMessage();
            }
        } else if (idAllegatoConferma != null) {
            try {
                log.info("Parso la segnatura - conferma.xml")
                confermaRicezione = getSegnaturaConfermaFromFile("" + idAllegatoConferma)
            }
            catch (Exception e) {
                log.debug("Errore nel parse della segnatura - conferma.xml: " + e.getMessage())
                messaggioRicevutoDTO.note = "Non è stato possibile trattare la segnatura/conferma.xml per un errore: " + e.getMessage();
            }
        } else if (idAllegatoEccezione != null) {
            try {
                log.info("Parso la segnatura - eccezione.xml")
                notificaEccezione = getSegnaturaEccezioneFromFile("" + idAllegatoEccezione)
            }
            catch (Exception e) {
                log.debug("Errore nel parse della segnatura - eccezione.xml: " + e.getMessage())
                messaggioRicevutoDTO.note = "Non è stato possibile trattare la segnatura/eccezione.xml per un errore: " + e.getMessage();
            }
        } else if (idAllegatoAnnullamento != null) {
            try {
                log.info("Parso la segnatura - annullamento.xml")
                annullamentoProtocollazione = getSegnaturaAnnullamentoFromFile("" + idAllegatoAnnullamento)
            }
            catch (Exception e) {
                log.debug("Errore nel parse della segnatura - annullamento.xml: " + e.getMessage())
                messaggioRicevutoDTO.note = "Non è stato possibile trattare la segnatura/annullamento.xml per un errore: " + e.getMessage();
            }
        } else if (idAllegatoDatiCertRicevuta != null) {
            try {
                log.info("Parso il file - daticert.xml")
                postacert = getPostaCertFromFile("" + idAllegatoDatiCertRicevuta)
            }
            catch (Exception e) {
                postacert = null
                log.debug("Errore nel parse della segnatura - daticert.xml: " + e.getMessage())
            }
        }

        if (postacert != null) {
            String dataDatiCertStringa
            try {
                dataDatiCertStringa = postacert.dati?.data?.giorno?.trim()

                if (dataDatiCertStringa?.size() > 0) {
                    Date time = postacert.dati?.data?.ora?.toGregorianCalendar()?.getTime()
                    if (time != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS");
                        String timeString = sdf.format(time)

                        if (timeString?.size() > 0) {
                            dataDatiCertStringa += " " + timeString

                            sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss.SSS")
                            dataDatiCertXmlRicevuta = sdf.parse(dataDatiCertStringa)
                        }
                    }
                }
            }
            catch (Exception e) {
                log.debug("Errore nel recupero/parse della data da - daticert.xml: " + e.getMessage())
            }
        }

        Ad4Utente utenteRedattore = (idAllegatoSegnatura != null) ? Ad4Utente.get(ImpostazioniProtocollo.UTENTI_PROTOCOLLO.valore) : null
        So4UnitaPubb so4UnitaPubb = (idAllegatoSegnatura != null) ? So4UnitaPubb.findByCodiceAndAlIsNull(ImpostazioniProtocollo.UNITA_PROTOCOLLO.valore) : null

        //UO_MESSAGGIO E REDATTORE (verranno creati ma con valori vuoti, poi ci pensa la maschera a riempirli a prima apertura)
        //Se invece viene dalla segnatura allora tento di mettere quelli standard
        log.debug("Aggiungo i soggetti UO_MESSAGGIO E REDATTORE ad AGP_MSG_RICEVUTI_DATI_PROT di AGSPR")
        DocumentoSoggettoDTO documentoSoggettoDTORedattore = new DocumentoSoggettoDTO(tipoSoggetto: TipoSoggetto.REDATTORE,
                attivo: true,
                documento: messaggioRicevutoDTO,
                utenteAd4: utenteRedattore?.toDTO()
        )

        messaggioRicevutoDTO.addToSoggetti(documentoSoggettoDTORedattore)

        DocumentoSoggettoDTO documentoSoggettoDTOUoMessaggio = new DocumentoSoggettoDTO(tipoSoggetto: TipoSoggetto.UO_MESSAGGIO,
                attivo: true,
                documento: messaggioRicevutoDTO,
                unitaSo4: so4UnitaPubb?.toDTO()
        )

        messaggioRicevutoDTO.addToSoggetti(documentoSoggettoDTOUoMessaggio)

        //SALVO TUTTO
        log.debug("Salvo la riga in AGP_MSG_RICEVUTI_DATI_PROT di AGSPR")
        messaggioRicevutoDTO = messaggiRicevutiService.salva(messaggioRicevutoDTO, null)

        Protocollo protocolloRet = null
        //TRATTO LA RICEVUTA O GLI EVENTUALI XML DI SEGNATURA/CONFERMA/....
        if (messaggioDettaglio.certified_type == "RICEVUTA" && messaggioDettaglio.id_msg_inviato != "0") {
            log.debug("Tratto la la ricevuta con id_msg_inviato: " + messaggioDettaglio.id_msg_inviato)
            protocolloSegnaturaService.gestisciNotificheAutomatiche(messaggioRicevutoDTO, "" + messaggioDettaglio.id_msg_inviato, "" + messaggioDettaglio.destinatario_consegna,
                    "" + messaggioDettaglio.tipo_ricevuta, dataDatiCertXmlRicevuta)
        } else if (segnatura != null) {
            log.debug("Tratto la segnatura")
            protocolloRet = messaggiRicevutiService.creaProtocolloDaSegnatura(messaggioRicevutoDTO, segnatura, segnaturaCittadino)
        } else if (confermaRicezione != null) {
            log.debug("Tratto la conferma ricezione")
            protocolloSegnaturaService.salvaConfermaRicezione(messaggioRicevutoDTO, confermaRicezione)
        } else if (aggiornamentoConferma != null) {
            log.debug("Tratto l'aggiornamemto conferma")
            protocolloSegnaturaService.salvaAggiornamentoConferma(messaggioRicevutoDTO, aggiornamentoConferma)
        } else if (notificaEccezione != null) {
            log.debug("Tratto la notifica eccezione")
            protocolloSegnaturaService.salvaNotificaEccezione(messaggioRicevutoDTO, notificaEccezione)
        } else if (annullamentoProtocollazione != null) {
            log.debug("Tratto l'annullamento protocollazione")
            protocolloSegnaturaService.salvaAnnullamentoProtocollazione(messaggioRicevutoDTO, annullamentoProtocollazione)
        }

        return protocolloRet
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    String protocollaMessaggioRicevutoSi4CS(Protocollo protocollo) {
        if ((ImpostazioniProtocollo.PROT_AUTO_CITT.valore?.equalsIgnoreCase("Y") && protocolloUtilService.isConSegnaturaCittadino(protocollo)) ||
                (ImpostazioniProtocollo.PEC_3DELETTRONICO.valore?.equalsIgnoreCase("Y") && protocollo.schemaProtocollo.codice == "3del") ||
                SchemaProtocolloIntegrazione.findBySchemaProtocolloAndApplicativo(protocollo.schemaProtocollo, SchemaProtocolloIntegrazione.GLOBO)) {
            try {
                log.debug("segnatura Gestione protocollazione automatica. Lancio la protocollazione")
                Protocollo protocolloAuth = Protocollo.findById(protocollo.id)
                protocolloService.protocolla(protocolloAuth, false)

                return null
            }
            catch (Exception e) {
                log.debug("segnatura Gestione protocollazione automatica. Errore in protocollazione: " + e.getMessage())

                return "Errore in protocollazione: " + e.getMessage()
            }
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    void salvaMessaggioErroreprotocollazioneMessaggioRicevutoSi4CS(Protocollo protocollo, String messaggio) {
        ProtocolloDatiInteroperabilita protocolloDatiInteroperabilita = ProtocolloDatiInteroperabilita.findById(protocollo.datiInteroperabilita.id)
        protocolloDatiInteroperabilita = protocolloService.aggiungiSegnalazioniProtocolloDatiIterop(protocolloDatiInteroperabilita, [messaggio])
        protocolloDatiInteroperabilita.save()
    }

    Segnatura getSegnaturaFromFile(String idAllegatoSegnatura) {
        File file = new File()
        file.setId(idAllegatoSegnatura)
        file = documentaleService.getFile(new Documento(), file)

        Segnatura segnatura = segnaturaInteropService.getSegnaturaFromStream(file.getInputStream())

        return segnatura
    }

    private AggiornamentoConferma getSegnaturaAggiornamentoFromFile(String idAllegato) {
        File file = new File()
        file.setId(idAllegato)
        file = documentaleService.getFile(new Documento(), file)

        AggiornamentoConferma aggiornamentoConferma = segnaturaInteropService.getAggiornamentoConfermaFromStream(file.getInputStream())

        return aggiornamentoConferma
    }

    ConfermaRicezione getSegnaturaConfermaFromFile(String idAllegato) {
        File file = new File()
        file.setId(idAllegato)
        file = documentaleService.getFile(new Documento(), file)

        ConfermaRicezione confermaRicezione = segnaturaInteropService.getConfermaRicezioneFromStream(file.getInputStream())

        return confermaRicezione
    }

    NotificaEccezione getSegnaturaEccezioneFromFile(String idAllegato) {
        File file = new File()
        file.setId(idAllegato)
        file = documentaleService.getFile(new Documento(), file)

        NotificaEccezione notificaEccezione = segnaturaInteropService.getNotificaEccezioneFromStream(file.getInputStream())

        return notificaEccezione
    }

    AnnullamentoProtocollazione getSegnaturaAnnullamentoFromFile(String idAllegato) {
        File file = new File()
        file.setId(idAllegato)
        file = documentaleService.getFile(new Documento(), file)

        AnnullamentoProtocollazione annullamentoProtocollazione = segnaturaInteropService.getAnnullamentoProtocollazioneFromStream(file.getInputStream())

        return annullamentoProtocollazione
    }

    Postacert getPostaCertFromFile(String idAllegato) {
        File file = new File()
        file.setId(idAllegato)
        file = documentaleService.getFile(new Documento(), file)

        Postacert postacert = segnaturaInteropService.getPostaCertFromStream(file.getInputStream())

        return postacert
    }
}
