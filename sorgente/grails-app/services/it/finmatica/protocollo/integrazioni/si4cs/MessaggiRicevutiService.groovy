package it.finmatica.protocollo.integrazioni.si4cs

import groovy.sql.GroovyRowResult
import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.corrispondenti.MessaggioDTO
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloSegnaturaService
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.interoperabilita.ProtocolloDatiInteroperabilita
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.segnatura.interop.xsd.Segnatura
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.so4.StrutturaOrganizzativaProtocolloService
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.segreteria.common.StringUtility
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Campo
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.text.SimpleDateFormat
import java.util.regex.Matcher
import java.util.regex.Pattern

@Slf4j
@Transactional
@Service
class MessaggiRicevutiService {
    public static final String TIPO_COLLEGAMENTO_PROT_RIFE = TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_RIFERIMENTO
    public static final String TIPO_COLLEGAMENTO_PROT_PEC = TipoCollegamentoConstants.CODICE_TIPO_PROT_PEC
    public static final String TIPO_COLLEGAMENTO_PROT_CONF = TipoCollegamentoConstants.CODICE_TIPO_COLLEGAMENTO_PROT_CONF
    public static final String TIPO_COLLEGAMENTO_PROT_AGG = TipoCollegamentoConstants.CODICE_TIPO_COLLEGAMENTO_PROT_AGG
    public static final String TIPO_COLLEGAMENTO_PROT_ANN = TipoCollegamentoConstants.CODICE_TIPO_COLLEGAMENTO_PROT_ANN
    public static final String TIPO_COLLEGAMENTO_PROT_ECC = TipoCollegamentoConstants.CODICE_TIPO_COLLEGAMENTO_PROT_ECC
    public static final String TIPO_COLLEGAMENTO_MAIL = TipoCollegamentoConstants.CODICE_TIPO_MAIL

    final static String _ITEM_TIPO_POSTA_CERTIFICATA = "Da posta elettronica certificata"
    final static String _ITEM_TIPO_POSTA_ORDINARIA = "Da posta elettronica ordinaria"
    final static String _ITEM_TIPO_POSTA_RICEVUTA = "Ricevuta"
    final static String _ITEM_TUTTI = "(Tutti)"

    final static Map<String, String> statiMessaggioGdm = ["DG" : MessaggioRicevuto.Stato.DA_GESTIRE,
                                                          "GE" : MessaggioRicevuto.Stato.GESTITO,
                                                          "PR" : MessaggioRicevuto.Stato.PROTOCOLLATO,
                                                          "NP" : MessaggioRicevuto.Stato.NON_PROTOCOLLATO,
                                                          "DPS": MessaggioRicevuto.Stato.DA_PROTOCOLLARE_CON_SEGNATURA,
                                                          "SC" : MessaggioRicevuto.Stato.SCARTATO,
                                                          "G"  : MessaggioRicevuto.Stato.GESTITO,
                                                          "DP" : MessaggioRicevuto.Stato.DA_PROTOCOLLARE_SENZA_SEGNATURA]

    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    DocumentaleService documentaleService
    @Autowired
    ProtocolloGdmService protocolloGdmService
    @Autowired
    TitolarioService titolarioService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @Autowired
    So4Repository so4Repository
    @Autowired
    StrutturaOrganizzativaProtocolloService strutturaOrganizzativaProtocolloService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    WkfIterService wkfIterService
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository
    @Autowired
    ProtocolloSegnaturaService protocolloSegnaturaService
    @Autowired
    MessaggiInviatiService messaggiInviatiService
    @Autowired
    private DataSource dataSource

    @Transactional(readOnly = true)
    MessaggioRicevuto getMessaggioRicevuto(Long idMessaggioSi4Cs) {
        return MessaggioRicevuto.findByIdMessaggioSi4Cs(idMessaggioSi4Cs)
    }

    @Transactional(readOnly = true)
    MessaggioRicevuto getMessaggioRicevutoById(Long id) {
        return MessaggioRicevuto.findById(id)
    }

    @Transactional(readOnly = true)
    MessaggioDTO getMessaggioDto(Long idMessaggio) {
        Messaggio messaggio = Messaggio.findById(idMessaggio)
        return messaggio?.toDTO()
    }

    MessaggioRicevutoDTO salva(MessaggioRicevutoDTO messaggioRicevutoDTO, List<DocumentoTitolarioDTO> listaTitolari = null) {
        MessaggioRicevuto messaggioRicevuto

        boolean primoSalvataggio = (messaggioRicevutoDTO.id == null)
        messaggioRicevuto = primoSalvataggio ? (new MessaggioRicevuto(id: messaggioRicevutoDTO.id)) : (MessaggioRicevuto.get(messaggioRicevutoDTO.id))

        messaggioRicevuto.dataStato = messaggioRicevutoDTO.dataStato
        messaggioRicevuto.dataSpedizione = messaggioRicevutoDTO.dataSpedizione
        messaggioRicevuto.idMessaggioSi4Cs = messaggioRicevutoDTO.idMessaggioSi4Cs
        messaggioRicevuto.classificazione = messaggioRicevutoDTO.classificazione?.domainObject
        messaggioRicevuto.fascicolo = messaggioRicevutoDTO.fascicolo?.domainObject
        messaggioRicevuto.tipo = messaggioRicevutoDTO.tipo
        messaggioRicevuto.riservato = messaggioRicevutoDTO.riservato
        messaggioRicevuto.statoMessaggio = messaggioRicevutoDTO.statoMessaggio
        messaggioRicevuto.dataRicezione = messaggioRicevutoDTO.dataRicezione
        messaggioRicevuto.mittente = messaggioRicevutoDTO.mittente
        messaggioRicevuto.destinatari = messaggioRicevutoDTO.destinatari
        messaggioRicevuto.destinatariConoscenza = messaggioRicevutoDTO.destinatariConoscenza
        messaggioRicevuto.testo = messaggioRicevutoDTO.testo
        messaggioRicevuto.mimeTesto = messaggioRicevutoDTO.mimeTesto
        messaggioRicevuto.tipo = messaggioRicevutoDTO.tipo
        messaggioRicevuto.oggetto = messaggioRicevutoDTO.oggetto
        messaggioRicevuto.tipoOggetto = WkfTipoOggetto.get(MessaggioRicevuto.TIPO_DOCUMENTO)

        if (primoSalvataggio) {
            for (fileDocumentoDto in messaggioRicevutoDTO?.fileDocumenti) {
                FileDocumento fileDocumentoDomain = new FileDocumento()
                fileDocumentoDomain.contentType = fileDocumentoDto.contentType
                fileDocumentoDomain.idFileEsterno = fileDocumentoDto.idFileEsterno
                fileDocumentoDomain.nome = fileDocumentoDto.nome
                fileDocumentoDomain.documento = messaggioRicevuto
                fileDocumentoDomain.codice = fileDocumentoDto.codice

                messaggioRicevuto.addToFileDocumenti(fileDocumentoDomain)
            }

            for (soggettiDto in messaggioRicevutoDTO?.soggetti) {
                DocumentoSoggetto documentoSoggetto = new DocumentoSoggetto()
                documentoSoggetto.documento = soggettiDto.documento?.domainObject
                documentoSoggetto.utenteAd4 = soggettiDto.utenteAd4?.domainObject
                documentoSoggetto.tipoSoggetto = soggettiDto.tipoSoggetto
                documentoSoggetto.unitaSo4 = soggettiDto.unitaSo4?.domainObject

                messaggioRicevuto.addToSoggetti(documentoSoggetto)
            }
        } else {
            for (soggettiDto in messaggioRicevutoDTO?.soggetti) {
                if (soggettiDto.utenteAd4 != null || soggettiDto.unitaSo4 != null) {
                    messaggioRicevuto.setSoggetto(soggettiDto.tipoSoggetto, soggettiDto.utenteAd4?.domainObject, soggettiDto.unitaSo4?.domainObject)
                }
            }
        }

        //Salvo gli eventuali documenti collegati aggiunti (es nel completa protocollo)
        for (documentoCollegato in messaggioRicevutoDTO.documentiCollegati) {
            if (documentoCollegato.id == null) {
                messaggioRicevuto.addDocumentoCollegato(documentoCollegato.collegato?.domainObject, documentoCollegato.tipoCollegamento?.domainObject)
            }
        }

        messaggioRicevuto.save()

        salvaMessaggioRicevutoDocumentale(messaggioRicevuto)

        //Salvo i titolari (classifiche e fascicoli secondari)
        if (listaTitolari != null) {
            titolarioService.salva(messaggioRicevuto, listaTitolari)
        }

        return messaggioRicevuto.toDTO("fileDocumenti")
    }

    void salvaMessaggioRicevutoDocumentale(MessaggioRicevuto messaggioRicevuto, boolean elimina = false) {
        Documento documentoGdm = new Documento()
        documentoGdm.addChiaveExtra("ESCLUDI_CONTROLLO_COMPETENZE", "Y")
        boolean aggiornamento = false

        if (messaggioRicevuto.idDocumentoEsterno > 0) {
            aggiornamento = true
            documentoGdm.setId(String.valueOf(messaggioRicevuto.idDocumentoEsterno))
            documentoGdm = documentaleService.getDocumento(documentoGdm, new ArrayList<Documento.COMPONENTI>())
            if (elimina) {
                documentoGdm.addChiaveExtra("STATO_DOCUMENTO", "CA")
            } else {
                documentoGdm.addChiaveExtra("STATO_DOCUMENTO", "BO")
            }
        } else {
            documentoGdm.addChiaveExtra("AREA", "SEGRETERIA")
            documentoGdm.addChiaveExtra("MODELLO", "MEMO_PROTOCOLLO")
        }

        if (!aggiornamento) {
            messaggioRicevuto.idrif = protocolloGdmService.calcolaIdrif()
            documentoGdm.addCampo(new Campo("IDRIF", messaggioRicevuto.idrif))
        }

        documentoGdm.addCampo(new Campo("OGGETTO", messaggioRicevuto.oggetto))
        documentoGdm.addCampo(new Campo("CORPO", messaggioRicevuto.testo))
        documentoGdm.addCampo(new Campo("DATA_RICEZIONE", protocolloGdmService.getDateSql(messaggioRicevuto.dataRicezione)))

        if (messaggioRicevuto.mittente?.size() > 200) {
            documentoGdm.addCampo(new Campo("MITTENTE", messaggioRicevuto.mittente?.substring(0, 199)))
        } else {
            documentoGdm.addCampo(new Campo("MITTENTE", messaggioRicevuto.mittente))
        }
        if (messaggioRicevuto.destinatari?.size() > 4000) {
            documentoGdm.addCampo(new Campo("DESTINATARI", messaggioRicevuto.destinatari?.substring(0, 3999)))
        } else {
            documentoGdm.addCampo(new Campo("DESTINATARI", messaggioRicevuto.destinatari))
        }
        if (messaggioRicevuto.destinatariConoscenza?.size() > 4000) {
            documentoGdm.addCampo(new Campo("DESTINATARI_CONOSCENZA", messaggioRicevuto.destinatariConoscenza?.substring(0, 3999)))
        } else {
            documentoGdm.addCampo(new Campo("DESTINATARI_CONOSCENZA", messaggioRicevuto.destinatariConoscenza))
        }
        if (messaggioRicevuto.destinatariNascosti?.size() > 4000) {
            documentoGdm.addCampo(new Campo("DESTINATARI_NASCOSTI", messaggioRicevuto.destinatariNascosti?.substring(0, 3999)))
        } else {
            documentoGdm.addCampo(new Campo("DESTINATARI_NASCOSTI", messaggioRicevuto.destinatariNascosti))
        }
        documentoGdm.addCampo(new Campo("STATO_MEMO", statiMessaggioGdm.get(messaggioRicevuto.statoMessaggio)))
        documentoGdm.addCampo(new Campo("DATA_STATO_MEMO", protocolloGdmService.getDateSql(messaggioRicevuto.dataStato)))

        if (messaggioRicevuto.dataSpedizione != null) {
            documentoGdm.addCampo(new Campo("DATA_SPEDIZIONE_MEMO", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(messaggioRicevuto.dataSpedizione)))
        }

        documentoGdm = documentaleService.salvaDocumento(documentoGdm)

        protocolloGdmService.fascicola(messaggioRicevuto, true)

        if (!aggiornamento) {
            messaggioRicevuto.idDocumentoEsterno = Long.parseLong(documentoGdm.getId())
            messaggioRicevuto.save()
        }
    }

    void collegaProtocollo(MessaggioRicevutoDTO messaggioRicevutoDto, DocumentoCollegatoDTO documentoCollegatoDto) {
        DocumentoCollegato documentoCollegato = new DocumentoCollegato()

        Protocollo collegato = Protocollo.findByIdDocumentoEsterno(documentoCollegatoDto.collegato.idDocumentoEsterno)

        documentoCollegato.documento = documentoCollegatoDto.documento.domainObject
        documentoCollegato.collegato = collegato
        documentoCollegato.tipoCollegamento = documentoCollegatoDto.tipoCollegamento.domainObject

        documentoCollegato.save()

        messaggioRicevutoDto.domainObject.statoMessaggio = MessaggioRicevuto.Stato.GESTITO
        messaggioRicevutoDto.domainObject.save()
    }

    void eliminaDocumentoCollegato(MessaggioRicevuto messaggioRicevuto, it.finmatica.gestionedocumenti.documenti.Documento documento, String codiceTipoCollegamento) {
        messaggioRicevuto.removeDocumentoCollegato(documento, codiceTipoCollegamento)
        messaggioRicevuto.save()
    }

    void eliminaMessaggio(MessaggioRicevuto messaggioRicevuto) {
        // FIXME allineo il documento su gdm e tramite un trigger elimina anche su AGSPR
        salvaMessaggioRicevutoDocumentale(messaggioRicevuto, true)
    }

    @Transactional(readOnly = true)
    ProtocolloDTO getProtocolloCollegatoMessaggio(MessaggioRicevutoDTO messaggioRicevutoDto, String filtroTipoCollegamento = null) {
        ProtocolloDTO protocolloMessaggio = null
        if (filtroTipoCollegamento == null) {
            protocolloMessaggio = (ProtocolloDTO) (messaggioRicevutoDto?.documentiCollegati?.find {
                it.tipoCollegamento.codice == TIPO_COLLEGAMENTO_PROT_RIFE ||
                        it.tipoCollegamento.codice == TIPO_COLLEGAMENTO_MAIL
            }?.collegato)
        } else {
            protocolloMessaggio = (ProtocolloDTO) (messaggioRicevutoDto?.documentiCollegati?.find {
                it.tipoCollegamento.codice == filtroTipoCollegamento
            }?.collegato)
        }

        return protocolloMessaggio
    }

    @Transactional(readOnly = true)
    Protocollo getProtocolloCollegatoMessaggio(MessaggioRicevuto messaggioRicevuto) {
        Protocollo protocolloMessaggio = (messaggioRicevuto?.documentiCollegati?.find {
            it.tipoCollegamento.codice == TIPO_COLLEGAMENTO_PROT_RIFE ||
                    it.tipoCollegamento.codice == TIPO_COLLEGAMENTO_MAIL
        }?.collegato)

        return protocolloMessaggio
    }

    @Transactional(readOnly = true)
    public DocumentoCollegato getCollegamentoMessaggioProtocollo(Protocollo protocollo, String filtroTipologia = "") {
        DocumentoCollegato documentoCollegato

        if (filtroTipologia == TIPO_COLLEGAMENTO_MAIL || filtroTipologia == "") {
            documentoCollegato = documentoCollegatoRepository.collegamentoPadrePerTipologia(protocollo,
                    TipoCollegamento.findByCodice(TIPO_COLLEGAMENTO_MAIL))

            if (documentoCollegato != null && documentoCollegato.documento instanceof MessaggioRicevuto) {
                return documentoCollegato
            }
        }

        if (filtroTipologia == TIPO_COLLEGAMENTO_PROT_RIFE || filtroTipologia == "") {
            documentoCollegato = documentoCollegatoRepository.collegamentoPadrePerTipologia(protocollo,
                    TipoCollegamento.findByCodice(TIPO_COLLEGAMENTO_PROT_RIFE))

            if (documentoCollegato != null && documentoCollegato.documento instanceof MessaggioRicevuto) {
                return documentoCollegato
            }
        }
    }

    /*
    * Metodo che restituisce la mappa delle competenze (lettura, scrittura, modifica)
    * di un messaggio ricevuto
    * */

    @Transactional(readOnly = true)
    boolean getCompetenzaLettura(MessaggioRicevuto messaggioRicevuto, TipoCollegamento tipoCollegamentoPec) {
        return getCompetenze(messaggioRicevuto, tipoCollegamentoPec, true).lettura
    }

    @Transactional(readOnly = true)
    Map getCompetenze(MessaggioRicevuto messaggioRicevuto, tipoCollegamentoPEC, boolean controllaLettura = true, boolean controllaModifica = true, boolean controllaCancellazione = true) {
        Map competenze = [lettura: false, modifica: false, cancellazione: false]

        Protocollo protocolloMessaggio = getProtocolloCollegatoMessaggio(messaggioRicevuto)

        Ad4Utente utente = springSecurityService.currentUser

        Map<String, String> privilegiUtente = new HashMap<String, String>()

        privilegiUtente.put(PrivilegioUtente.VTOT, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.VTOT, utente) ? "Y" : "N")
        privilegiUtente.put(PrivilegioUtente.PMAILT, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILT, utente) ? "Y" : "N")
        privilegiUtente.put(PrivilegioUtente.PMAILI, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILI, utente) ? "Y" : "N")
        privilegiUtente.put(PrivilegioUtente.PMAILU, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILU, utente) ? "Y" : "N")

        List<So4UnitaPubb> listaUnita = []

        if (privilegiUtente[PrivilegioUtente.PMAILU] == "Y") {
            listaUnita = so4Repository.getListUnita(utente, PrivilegioUtente.PMAILU)
        }

        if (controllaLettura) {
            List<So4IndirizzoTelematico> listaIndirizziEnte = strutturaOrganizzativaProtocolloService.getListaIndirizziEnte()
            competenze.lettura = isCompetenzaLettura(messaggioRicevuto, protocolloMessaggio, privilegiUtente, listaIndirizziEnte, tipoCollegamentoPEC, utente, listaUnita)
        }
        if (controllaModifica) {
            competenze.modifica = isCompetenzaModifica(messaggioRicevuto, protocolloMessaggio, utente)
        }

        if (controllaCancellazione) {
            competenze.cancellazione = isCompetenzaCancellazione(messaggioRicevuto, protocolloMessaggio, utente)
        }

        return competenze
    }

    void scartaMessaggio(MessaggioRicevuto messaggioRicevuto) {
        messaggioRicevuto.statoMessaggio = MessaggioRicevuto.Stato.SCARTATO
        messaggioRicevuto.classificazione = null
        messaggioRicevuto.fascicolo = null
        messaggioRicevuto.save()
    }

    void protocollaMessaggio(MessaggioRicevuto messaggioRicevuto) {
        messaggioRicevuto.statoMessaggio = MessaggioRicevuto.Stato.PROTOCOLLATO
        messaggioRicevuto.save()
    }

    @Transactional(readOnly = true)
    FileDocumento getFileDocumentoEml(MessaggioRicevuto messaggioRicevuto) {
        return messaggioRicevuto.fileDocumenti?.find {
            it.nome.trim().toLowerCase().equals(MessaggioRicevuto.MESSAGGIO_EML)
        }
    }

    Protocollo creaProtocolloDaSegnatura(MessaggioRicevutoDTO messaggioRicevutoDTO, Segnatura segnatura, boolean segnaturaCittadino) {
        log.debug("## completaProtocolloDaSegnatura su AGP_MSG_RICEVUTI_DATI_PROT con id = " + messaggioRicevutoDTO.id)

        List<String> segnalazioni = new ArrayList<String>()
        ProtocolloDTO protocolloDTO = new ProtocolloDTO()
        Protocollo protocollo = new Protocollo()
        ProtocolloDatiInteroperabilita protocolloDatiInteroperabilita = new ProtocolloDatiInteroperabilita()

        protocolloDTO.oggetto = messaggioRicevutoDTO.oggetto
        protocolloDTO.movimento = Protocollo.MOVIMENTO_ARRIVO
        protocolloDTO.tipoOggetto = WkfTipoOggetto.get(Protocollo.TIPO_DOCUMENTO).toDTO()
        protocolloDTO.dataComunicazione = messaggioRicevutoDTO.dataRicezione
        protocolloDTO.tipoProtocollo = TipoProtocollo.findByCategoriaAndMovimentoAndPredefinito(
                CategoriaProtocollo.CATEGORIA_PEC.codice,
                Protocollo.MOVIMENTO_ARRIVO, true)?.toDTO()

        /* PRIMO SALVATAGGIO PROTOCOLLO */
        log.debug("Primo salvataggio del protocollo con dati minimali (oggetto, movimento...)")
        protocolloService.salva(protocollo, protocolloDTO)

        /* AGGIUNTA DEI SOGGETTI */
        So4UnitaPubbDTO unitaProtocollante = messaggioRicevutoDTO.soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_MESSAGGIO
        }?.unitaSo4
        Ad4UtenteDTO utenteRedattore = messaggioRicevutoDTO.soggetti.find {
            it.tipoSoggetto == TipoSoggetto.REDATTORE
        }?.utenteAd4
        if (unitaProtocollante != null) {
            log.debug("Aggiungo al protocolo unità protocollante " + unitaProtocollante.descrizione)
            protocollo.addToSoggetti(new DocumentoSoggetto(tipoSoggetto: TipoSoggetto.UO_PROTOCOLLANTE, utenteAd4: null, unitaSo4: unitaProtocollante.domainObject))
        } else {
            segnalazioni.add("Il codice di unità protocollante letto impostazione UNITA_PROTOCOLLO non esiste")
        }
        if (utenteRedattore != null) {
            log.debug("Aggiungo al protocolo redattore " + utenteRedattore.utente)
            protocollo.addToSoggetti(new DocumentoSoggetto(tipoSoggetto: TipoSoggetto.REDATTORE, utenteAd4: utenteRedattore.domainObject, unitaSo4: null))
        } else {
            segnalazioni.add("Il codice di unità protocollante letto impostazione REDATTORE non esiste")
        }

        /* GESTIONE IMPOSTAZIONE SMIST_AUTO_PEC */
        if (ImpostazioniProtocollo.SMIST_AUTO_PEC.valore == "Y") {
            log.debug("Impostazione SMIST_AUTO_PEC vale Y. Per tutti i destinatari cerco gli uffici corrispondenti alle " +
                    " UO dell'ente e creo uno smistamento per conoscenza all'ufficio stesso da parte dell'unità protocollante ")

            //Per tutti i destinatari cerco gli uffici corrispondenti alle UO dell'ente e creo uno smistamento per conoscenza all'ufficio stesso da parte dell'unità protocollante
            List<String> listaMailDestinatari = getListaEmailDaIndirizzi(messaggioRicevutoDTO.destinatari) + getListaEmailDaIndirizzi(messaggioRicevutoDTO.destinatariConoscenza)

            List<So4IndirizzoTelematico> listaIndirizziEnte = strutturaOrganizzativaProtocolloService.getListaIndirizziEnte()
            List<So4IndirizzoTelematico> listaIndizizziUo = listaIndirizziEnte.findAll {
                it.tipoEntita == "UO"
            }

            List<So4UnitaPubb> listaUnitaSmistate = new ArrayList<So4UnitaPubb>()
            if (listaIndizizziUo?.size() > 0) {
                for (indirizzioUo in listaIndizizziUo) {
                    if (listaMailDestinatari.contains(indirizzioUo.indirizzo) && !listaUnitaSmistate.contains(indirizzioUo.unita)) {
                        log.debug("Creo smistamento per competenza verso " + indirizzioUo.unita.descrizione)

                        protocollo.addToSmistamenti(new Smistamento(tipoSmistamento: Smistamento.COMPETENZA, dataSmistamento: new Date(),
                                documento: protocollo, statoSmistamento: Smistamento.CREATO, unitaTrasmissione: unitaProtocollante.domainObject,
                                unitaSmistamento: indirizzioUo.unita))

                        listaUnitaSmistate.add(indirizzioUo.unita)
                    }
                }
            }
        }

        /* AGGIUNTA DATI INTERPOERABILITA */
        log.debug("Aggiungo le segnalazioni e salvo la riga su AGP_PROTOCOLLI_DATI_INTEROP di AGSPR legata al protocollo")
        protocolloService.aggiungiSegnalazioniProtocolloDatiIterop(protocolloDatiInteroperabilita, segnalazioni)
        protocolloDatiInteroperabilita.save()
        protocollo.datiInteroperabilita = protocolloDatiInteroperabilita

        /* SALVATAGGIO FINALE DEL PROTOCOLLO */
        log.debug("Salvataggo finale del protocollo prima di trattare la segnatura")
        protocollo.save()

        /* GESTIONE PARSE SEGNATURA */
        log.debug("Leggo e memorizzo di dati di segnatura")
        List<String> listaMailMittenti = getListaEmailDaIndirizzi(messaggioRicevutoDTO.mittente)
        String mittente = (listaMailMittenti.size() > 0) ? listaMailMittenti.get(0) : null
        protocolloSegnaturaService.completaProtocolloDaSegnatura(mittente, protocollo, segnatura, segnaturaCittadino, messaggioRicevutoDTO)

        protocolloDTO = protocollo.toDTO()

        /* COLLEGAMENTO FINALE FRA MESSAGGIO E PROTOCOLLO */
        log.debug("Collego la AGP_MSG_RICEVUTI_DATI_PROT di AGSPR al protocollo")
        DocumentoCollegatoDTO documentoCollegatoDTO = new DocumentoCollegatoDTO()
        documentoCollegatoDTO.tipoCollegamento = TipoCollegamento.findByCodice(TIPO_COLLEGAMENTO_MAIL)?.toDTO()
        documentoCollegatoDTO.collegato = protocolloDTO
        messaggioRicevutoDTO.addToDocumentiCollegati(documentoCollegatoDTO)
        protocolloGdmService.salvaDocumentoCollegamento(messaggioRicevutoDTO.domainObject, protocollo, TIPO_COLLEGAMENTO_MAIL)

        //Cambio di stato sul messaggio
        log.debug("Cambio lo stato del messaggio in DA_PROTOCOLLARE_CON_SEGNATURA")
        messaggioRicevutoDTO.setStatoMessaggio(MessaggioRicevuto.Stato.DA_PROTOCOLLARE_CON_SEGNATURA)

        /* SALVATAGGIO FINALE DEL MESSAGGIO */
        salva(messaggioRicevutoDTO, null)

        log.debug("Istanzio l'iter finale di protocollo")
        wkfIterService.istanziaIter(protocollo.tipoProtocollo.getCfgIter(), protocollo)

        return protocollo
    }

    Protocollo creaProtocollo(MessaggioRicevutoDTO messaggioRicevutoDto, String movimento) {
        if (!isPossoCreareProtocollo(messaggioRicevutoDto)) {
            return
        }

        ProtocolloDTO protocollo = new ProtocolloDTO()
        String oggettoProtocollo = messaggioRicevutoDto.oggetto
        if (oggettoProtocollo?.startsWith("ANOMALIA MESSAGGIO:")) {
            oggettoProtocollo = oggettoProtocollo.replaceAll("ANOMALIA MESSAGGIO:", "")
        }
        protocollo.oggetto = oggettoProtocollo
        protocollo.dataComunicazione = messaggioRicevutoDto.dataRicezione
        protocollo.movimento = movimento
        protocollo.tipoOggetto = WkfTipoOggetto.get(Protocollo.TIPO_DOCUMENTO).toDTO()
        if (movimento == Protocollo.MOVIMENTO_ARRIVO) {
            protocollo.riservato = messaggioRicevutoDto.riservato
            protocollo.modalitaInvioRicezione = ModalitaInvioRicezione.findByCodice(ModalitaInvioRicezione.CODICE_PEC)?.toDTO()
            protocollo.classificazione = messaggioRicevutoDto.classificazione
            protocollo.fascicolo = messaggioRicevutoDto.fascicolo
        }

        if (movimento == Protocollo.MOVIMENTO_ARRIVO) {
            protocollo.tipoProtocollo = TipoProtocollo.findByCategoriaAndMovimentoAndPredefinito(
                    CategoriaProtocollo.CATEGORIA_PEC.codice,
                    Protocollo.MOVIMENTO_ARRIVO, true)?.toDTO()
        } else {
            protocollo.tipoProtocollo = TipoProtocollo.findByCategoriaAndPredefinito(CategoriaProtocollo.CATEGORIA_PROTOCOLLO.codice, true)?.toDTO()
        }

        So4UnitaPubbDTO unitaProtocollante = messaggioRicevutoDto.soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_MESSAGGIO
        }?.unitaSo4

        //Creazione dati interop
        ProtocolloDatiInteroperabilita protocolloDatiInteroperabilita = new ProtocolloDatiInteroperabilita()
        List<CorrispondenteDTO> corrispondentiSearch = null
        if (movimento == Protocollo.MOVIMENTO_ARRIVO) {
            protocolloDatiInteroperabilita.motivoInterventoOperatore = messaggioRicevutoDto.note

            //Gestione corrispondenti
            corrispondentiSearch = corrispondenteService.ricercaDestinatari(null, true, null, null,
                    null, null, messaggioRicevutoDto.mittente, null, null, null)

            if (corrispondentiSearch?.size() == 1) {
                protocollo.addToCorrispondenti(corrispondentiSearch.get(0))
            } else {
                if (ImpostazioniProtocollo.MAIL_NO_SEGN_CREA_RAPPORTO.valore == "Y") {
                    protocollo.addToCorrispondenti(new CorrispondenteDTO(email: messaggioRicevutoDto.mittente))
                    corrispondentiSearch = new ArrayList<CorrispondenteDTO>()
                    corrispondentiSearch.add(new CorrispondenteDTO(email: messaggioRicevutoDto.mittente))
                } else {
                    corrispondentiSearch = null
                    String indirizzoMailAggiunto = "Indirizzo mittente: " + messaggioRicevutoDto.mittente
                    protocolloDatiInteroperabilita.motivoInterventoOperatore = (StringUtility.nvl(protocolloDatiInteroperabilita.motivoInterventoOperatore, "") == "") ?
                            indirizzoMailAggiunto : protocolloDatiInteroperabilita.motivoInterventoOperatore + "\n" + indirizzoMailAggiunto
                }
            }
        }

        //Cambio di stato sul messaggio
        messaggioRicevutoDto.setStatoMessaggio(MessaggioRicevuto.Stato.DA_PROTOCOLLARE_SENZA_SEGNATURA)

        //Salvo il dato interop
        if (movimento == Protocollo.MOVIMENTO_ARRIVO) {
            protocolloDatiInteroperabilita.save()
        }
        //Salvo il protocollo
        Protocollo protocolloDomain = new Protocollo()
        protocolloService.salva(protocolloDomain, protocollo)

        //Aggiungo i soggetti
        protocolloDomain.addToSoggetti(new DocumentoSoggetto(tipoSoggetto: TipoSoggetto.REDATTORE, utenteAd4: springSecurityService.currentUser))
        if (unitaProtocollante != null) {
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.REDATTORE_PROTOCOLLO, unitaProtocollante.codice, springSecurityService.currentUser)) {
                protocolloDomain.addToSoggetti(new DocumentoSoggetto(tipoSoggetto: TipoSoggetto.UO_PROTOCOLLANTE, utenteAd4: null, unitaSo4: unitaProtocollante.domainObject))
            }
        }

        //Creazione degli allegati
        if (movimento == Protocollo.MOVIMENTO_ARRIVO) {
            for (fileDocumentoMessaggio in messaggioRicevutoDto.fileDocumenti) {
                FileDocumento fileDocumentoProtocollo = new FileDocumento()
                fileDocumentoProtocollo.contentType = fileDocumentoMessaggio.contentType
                fileDocumentoProtocollo.idFileEsterno = fileDocumentoMessaggio.idFileEsterno
                fileDocumentoProtocollo.nome = fileDocumentoMessaggio.nome
                fileDocumentoProtocollo.documento = protocolloDomain
                fileDocumentoProtocollo.codice = Protocollo.FILE_DA_MAIL

                protocolloDomain.addToFileDocumenti(fileDocumentoProtocollo)
            }
        }

        if (movimento == Protocollo.MOVIMENTO_ARRIVO) {
            protocolloDomain.datiInteroperabilita = protocolloDatiInteroperabilita
        }
        //Risalvo il protocollo per aggiungere i soggetti e gli allegati
        protocolloDomain.save()
        //Salvo il corrispondente se esiste
        if (corrispondentiSearch != null && corrispondentiSearch?.size() == 1) {
            corrispondenteService.salva(protocolloDomain, corrispondentiSearch)
        }
        protocollo = protocolloDomain.toDTO()

        //Salvo il messaggio
        //1.Collegamento fra protocollo e messaggio
        DocumentoCollegatoDTO documentoCollegatoDTO = new DocumentoCollegatoDTO()
        documentoCollegatoDTO.tipoCollegamento = TipoCollegamento.findByCodice(TIPO_COLLEGAMENTO_MAIL)?.toDTO()
        documentoCollegatoDTO.collegato = protocollo
        messaggioRicevutoDto.addToDocumentiCollegati(documentoCollegatoDTO)
        //2.Salvataggio del messaggio
        salva(messaggioRicevutoDto, null)

        wkfIterService.istanziaIter(protocolloDomain.tipoProtocollo.getCfgIter(), protocolloDomain)

        //Storicizzo gli smistamenti del messaggio
        for (smistamento in messaggioRicevutoDto.smistamenti) {
            smistamentoService.storicizzaSmistamento(smistamento.domainObject)
        }

        //Aggiungo il file con contenuto il messaggio della PEC
        if (movimento == Protocollo.MOVIMENTO_ARRIVO) {
            FileDocumento fileDocumentoTestoMessaggio = new FileDocumento()
            String nomeFile, mimeTesto, contentType = null
            mimeTesto = messaggioRicevutoDto.mimeTesto
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

            gestoreFile.addFile(protocollo.domainObject, fileDocumentoTestoMessaggio, new ByteArrayInputStream(StringUtility.nvl(messaggioRicevutoDto.testo, "").getBytes()))
        } else {
            //Nel caso della partenza, se c'è 1 solo deve diventare il principale, altrimenti non metto niente e poi ci pensa il protocollo
            //dove farà vedere la BUSTA stile PEC per scegliere fra gli allegati
            if (messaggioRicevutoDto.fileDocumenti.size() == 1) {
                FileDocumentoDTO fileDocumentoMessaggio = messaggioRicevutoDto.fileDocumenti.get(0)
                File file = new File()
                file.setId("" + fileDocumentoMessaggio.idFileEsterno)

                file = documentaleService.getFile(new Documento(), file)
                protocolloService.caricaFilePrincipale(protocollo.domainObject, file.getInputStream(),
                        fileDocumentoMessaggio.contentType, fileDocumentoMessaggio.nome)
            }
        }

        return protocollo.domainObject
    }

    @Transactional(readOnly = true)
    List<String> getListaEmailDaIndirizzi(String listaIndirizzi) {
        List<String> listaMail = []

        if (listaIndirizzi != null) {
            Pattern p = Pattern.compile("\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}\\b", Pattern.CASE_INSENSITIVE);

            Matcher m = p.matcher(listaIndirizzi);
            while (m.find()) {
                listaMail << m.group()
            }
        }

        return listaMail
    }

    @Transactional(readOnly = true)
    List<LinkedHashMap> getListaMessaggi(String destinatari, String mittente,
                                         String oggetto, Date dal, Date al,
                                         String tipoPosta, String stato, String utente,
                                         boolean messaggiAuto) {

        String msgAuto
        msgAuto = ""
        if (!messaggiAuto) {
            msgAuto = " and instr(m.tipo ,'RICEVUTA')=0 "
        }

        return new Sql(dataSource).rows("" +
                "Select  M.ID_MESSAGGIO_SI4CS, " +
                "        M.OGGETTO, " +
                "        M.mittente," +
                "        to_char(m.destinatari) destinatariMail, " +
                "        to_char(m.DATA_SPEDIZIONE,'dd/MM/yyyy HH24:mi:ss') dataSpedizione," +
                "        to_char(m.data_Ricezione,'dd/MM/yyyy HH24:mi:ss') dataRicezione," +
                "        decode(m.tipo , 'RICEVUTA','Ricevuta',decode(m.tipo ,'PEC','Pec','Ordinario' ) ) certificata," +
                "        (select count(*) from gdo_file_documento fd where fd.id_documento=m.id_documento)  allegatiPresenti," +
                "        decode(m.stato,'DA_GESTIRE','Da Gestire','DA_PROTOCOLLARE_CON_SEGNATURA','Da Protocollare con Segnatura'," +
                "                       'DA_PROTOCOLLARE_SENZA_SEGNATURA','Da Protocollare senza Segnatura'," +
                "                       'GESTITO','Gestito','GENERATA_ECCEZIONE','Generata Eccezione'," +
                "                       'NON_PROTOCOLLATO','Non Protocollato','PROTOCOLLATO','Protocollato'," +
                "                       'SCARTATO','Scartato') descrStato, " +
                "        m.id_documento," +
                "        (select max(dc.id_collegato) from gdo_documenti_collegati dc, gdo_tipi_collegamento tc " +
                "           where m.id_documento = dc.id_documento " +
                "             and dc.id_tipo_collegamento =  tc.id_tipo_collegamento  " +
                "             and tc.tipo_collegamento = 'MAIL') id_collegato " +
                "  from agp_msg_ricevuti_dati_prot m, ags_classificazioni clas, ags_fascicoli fasc, gdo_documenti doc" +
                " where (m.destinatari like '%'||:p_destinatari||'%' or m.destinatari is null) and" +
                "       (m.mittente like '%'||:p_mittente||'%' or m.mittente is null) and" +
                "       (lower(m.oggetto) like '%'||lower(:p_oggetto)||'%' or m.oggetto is null) and" +
                "       trunc(m.data_Ricezione) between to_date(:p_dal,'dd/mm/yyyy') and to_date(:p_al,'dd/mm/yyyy') and" +
                "       (m.tipo = :p_tipoPosta or :p_tipoPosta = 'TUTTI') and" +
                "       (m.stato = :p_stato or :p_stato='TUTTI') and" +
                "       m.id_classificazione = clas.id_classificazione (+) and" +
                "       m.id_fascicolo = fasc.id_documento (+) and" +
                "       doc.id_documento = m.id_documento and" +
                "       nvl(doc.valido,'Y')='Y' and" +
                "       agp_competenze_messaggio.lettura_messaggio_arrivo(m.id_documento,:p_utente)=1" + msgAuto +
                " order by m.DATA_SPEDIZIONE asc ", [p_destinatari: destinatari,
                                                     p_mittente   : mittente,
                                                     p_oggetto    : oggetto,
                                                     p_dal        : new SimpleDateFormat("dd/MM/yyyy").format(dal),
                                                     p_al         : new SimpleDateFormat("dd/MM/yyyy").format(al),
                                                     p_tipoPosta  : tipoPosta,
                                                     p_stato      : stato,
                                                     p_utente     : utente]).
                collect { GroovyRowResult row ->
                    [messaggio       : "" + row.ID_MESSAGGIO_SI4CS,
                     oggetto         : row.oggetto,
                     mittenti        : row.mittente,
                     destinatari     : row.destinatariMail,
                     data            : row.dataSpedizione,
                     dataRic         : row.dataRicezione,
                     certificata     : row.certificata,
                     allegatiPresenti: (row.allegatiPresenti > 0) ? "Y" : "N",
                     stato           : row.descrStato,
                     idMessaggioAgspr: row.id_documento,
                     idProtocollo    : row.id_collegato
                    ]
                }
    }

    private boolean isPossoCreareProtocollo(MessaggioRicevutoDTO messaggioRicevutoDto) {
        if (messaggioRicevutoDto == null) {
            return false
        }

        //Controllo per sicurezza che lo stato sia SCARTATO o DA_GESTIRE o NON_PROTOCOLLATO
        if (messaggioRicevutoDto.statoMessaggio != MessaggioRicevuto.Stato.SCARTATO &&
                messaggioRicevutoDto.statoMessaggio != MessaggioRicevuto.Stato.DA_GESTIRE &&
                messaggioRicevutoDto.statoMessaggio != MessaggioRicevuto.Stato.NON_PROTOCOLLATO) {
            return false
        }

        //Controllo per sicurezza che non sia già presente un protocollo associato
        ProtocolloDTO protocolloMessaggio = getProtocolloCollegatoMessaggio(messaggioRicevutoDto)
        if (protocolloMessaggio != null) {
            return false
        }

        return true
    }

    @Transactional(readOnly = true)
    public boolean isCompetenzaLettura(MessaggioRicevuto messaggioRicevuto, Protocollo protocolloMessaggio, Map privilegiUtente,
                                       List<So4IndirizzoTelematico> listaIndirizziEnte, tipoCollegamentoPEC, Ad4Utente utente,
                                       List<So4UnitaPubb> listaUnita) {
        boolean competenza = false

        if (messaggioRicevuto != null) {
            String codiceUnita = messaggioRicevuto.getUnita()?.codice

            if (protocolloMessaggio != null &&
                    (messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.PROTOCOLLATO ||
                            messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.GESTITO)) {
                //Esiste il protocollo collegato al messaggio
                Map competenzePrecedente = gestoreCompetenze.getCompetenze(protocolloMessaggio)

                if (competenzePrecedente?.lettura) {
                    competenza = true
                } else {
                    competenza = false
                }

                return competenza
            }

            if (!competenza) {
                if (messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.GESTITO) {
                    //E' il caso di messaggi di tipo PROT_PEC, PROT_CONF....ETC...

                    //1. cerco un collegamento di tipi PROT_PEC (messaggio inviato -> messaggio ricevuto) per trovare appunto
                    //   il messaggio inviato a partire dal ricevuto... se lo trovo, la competenza sarà di codello (che poi a sua volta
                    //   controlla la competenza sul protocollo padre collegato)
                    DocumentoCollegato documentoCollegato =
                            documentoCollegatoRepository.collegamentoPadrePerTipologia(messaggioRicevuto, tipoCollegamentoPEC)

                    if (documentoCollegato != null) {
                        if (documentoCollegato.documento.class == MessaggioInviato.class) {
                            competenza = messaggiInviatiService.isCompetenzaLettura((MessaggioInviato) documentoCollegato.documento)
                        }
                    } else {
                        //2. cerco uno dei possibili collegamenti rimasti (gli altri possibili sono PROT_CONF....ETC... ) direttamente con il protocollo
                        //   se lo trovo, la competenza sarà di codello
                        documentoCollegato =
                                documentoCollegatoRepository.collegamentoPadre(messaggioRicevuto)

                        if (documentoCollegato != null) {
                            if (documentoCollegato.documento.class == Protocollo.class) {
                                Map competenzeProtocollo = gestoreCompetenze.getCompetenze(documentoCollegato.documento)
                                if (competenzeProtocollo?.lettura) {
                                    competenza = true
                                }
                            }
                        }
                    }
                }

                if (!competenza) {
                    if (messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_GESTIRE) {
                        competenza = true
                    } else if (((messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.NON_PROTOCOLLATO) ||
                            (messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_PROTOCOLLARE_CON_SEGNATURA ||
                                    messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_PROTOCOLLARE_SENZA_SEGNATURA))
                    ) {
                        if (privilegiUtente[PrivilegioUtente.VTOT] == "Y") {
                            competenza = true
                        } else {
                            competenza = (privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.VP, codiceUnita, utente) ||
                                    utenteAssegnatarioSmistamentoDaRicevereCarico(messaggioRicevuto.smistamenti, utente) ||
                                    utenteMembroUnitaRiceventeSmistamentoVSVDDR(messaggioRicevuto.smistamenti, utente))
                        }
                    }
                }

                if (!competenza) {
                    if ((messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_PROTOCOLLARE_CON_SEGNATURA ||
                            messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_PROTOCOLLARE_SENZA_SEGNATURA ||
                            messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.GENERATA_ECCEZIONE ||
                            messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.SCARTATO
                    )
                    ) {
                        String indirizzoIstituzionale = listaIndirizziEnte?.find { it.tipoEntita == "AO" }?.indirizzo
                        List<So4IndirizzoTelematico> listaIndirizziUo = listaIndirizziEnte?.findAll {
                            it.tipoEntita == "UO"
                        }
                        List<String> listaMailDestinatari = getListaEmailDaIndirizzi(messaggioRicevuto.destinatari) + getListaEmailDaIndirizzi(messaggioRicevuto.destinatariConoscenza)

                        if (privilegiUtente[PrivilegioUtente.PMAILT] == "Y") {
                            competenza = true
                        } else if (privilegiUtente[PrivilegioUtente.PMAILI] == "Y") {

                            //il messaggio non ha destinatari nè diretti nè in cc
                            if (listaMailDestinatari.size() == 0) {
                                competenza = true
                            }

                            // la casella istituzionale è tra i destinatari diretti o in cc del messaggio
                            if (listaMailDestinatari.contains(indirizzoIstituzionale)) {
                                competenza = true
                            }

                            // nessuno dei destinatari diretti e in cc corrisponde alla mail associata ad un'unità
                            if (listaIndirizziUo?.size() > 0) {
                                boolean nessunDestinatarioNellaListaUo
                                nessunDestinatarioNellaListaUo = true
                                for (indirizzioUo in listaIndirizziUo) {
                                    if (listaMailDestinatari.contains(indirizzioUo.indirizzo)) {
                                        nessunDestinatarioNellaListaUo = false
                                        break;
                                    }
                                }

                                competenza = nessunDestinatarioNellaListaUo
                            }
                        } else if (privilegiUtente[PrivilegioUtente.PMAILU] == "Y") {
                            //ha ruolo con privilegio PMAILU valido ad oggi per un'unità il cui indirizzo è tra i destinatari diretti o in cc
                            if (listaUnita != null) {
                                for (unita in listaUnita) {
                                    String indirizzoUo = listaIndirizziUo.find { it.unita == unita }?.indirizzo
                                    if (indirizzoUo != null) {
                                        if (listaMailDestinatari.contains(indirizzoUo)) {
                                            competenza = true
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            competenza = true
        }

        return competenza
    }

    @Transactional(readOnly = true)
    public boolean isCompetenzaModifica(MessaggioRicevuto messaggioRicevuto, Protocollo protocolloMessaggio, Ad4Utente utente) {
        boolean competenza = false

        if (messaggioRicevuto != null) {
            String privilegioMTOT, privilegioMS, privilegioMPROT

            String codiceUnita = messaggioRicevuto.getUnita()?.codice

            if (messaggioRicevuto.riservato) {
                privilegioMTOT = PrivilegioUtente.MTOTR
                privilegioMS = PrivilegioUtente.MSR
                privilegioMPROT = PrivilegioUtente.MPROTR
            } else {
                privilegioMTOT = PrivilegioUtente.MODIFICA_TUTTI
                privilegioMS = PrivilegioUtente.MS
                privilegioMPROT = PrivilegioUtente.MPROT
            }

            if (messaggioRicevuto.statoMessaggio != MessaggioRicevuto.Stato.GESTITO ||
                    messaggioRicevuto.statoMessaggio != MessaggioRicevuto.Stato.GENERATA_ECCEZIONE) {
                if (privilegioUtenteService.utenteHaPrivilegio(privilegioMTOT, utente) ||
                        privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegioMPROT, codiceUnita, utente) ||
                        utenteMembroUnitaSmistamentoCaricoEseguitoPrivilegioMS(messaggioRicevuto, messaggioRicevuto.smistamenti, privilegioMS, utente)
                ) {
                    if (messaggioRicevuto.fascicolo?.stato == Fascicolo.STATO_DEPOSITO) {
                        if (privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.MDDEP, utente)) {
                            competenza = true
                        }
                    } else {
                        competenza = true
                    }
                }
            }
        } else {
            competenza = true
        }

        return competenza
    }

    @Transactional(readOnly = true)
    public boolean isCompetenzaCancellazione(MessaggioRicevuto messaggioRicevuto, Protocollo protocolloMessaggio, Ad4Utente utente) {
        if (isCompetenzaModifica(messaggioRicevuto, protocolloMessaggio, utente) &&
                (messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_GESTIRE ||
                        messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.SCARTATO ||
                        messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.NON_PROTOCOLLATO)
                &&
                (messaggioRicevuto.documentiCollegati?.size() == 0)
                &&
                (documentoCollegatoRepository.collegamentoPadre(messaggioRicevuto) == null)
        ) {
            return true
        }

        return false
    }

    private boolean utenteAssegnatarioSmistamentoDaRicevereCarico(Set<Smistamento> smistamenti, Ad4Utente utente) {
        smistamenti?.find {
            it.utenteAssegnatario == utente &&
                    (it.statoSmistamento == Smistamento.DA_RICEVERE || it.statoSmistamento == Smistamento.IN_CARICO)
        }
    }

    private boolean utenteMembroUnitaRiceventeSmistamentoVSVDDR(Set<Smistamento> smistamenti, Ad4Utente utente) {
        for (smistamento in smistamenti) {
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.SMISTAMENTO_VISUALIZZA, smistamento.unitaSmistamento?.codice, utente) ||
                    privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.VDDR, smistamento.unitaSmistamento?.codice, utente)
            ) {
                return true
            }
        }

        return false
    }

    private boolean utenteMembroUnitaSmistamentoCaricoEseguitoPrivilegioMS(MessaggioRicevuto messaggioRicevuto, Set<Smistamento> smistamenti, String privilegioMS, Ad4Utente utente) {
        for (smistamento in smistamenti) {
            if (smistamento.statoSmistamento == Smistamento.ESEGUITO || smistamento.statoSmistamento == Smistamento.IN_CARICO) {
                if (privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegioMS, smistamento.unitaSmistamento?.codice, utente, messaggioRicevuto.getDateCreated()) ||
                        smistamento.utenteAssegnatario == utente) {
                    return true
                }
            }
        }

        return false
    }
}
