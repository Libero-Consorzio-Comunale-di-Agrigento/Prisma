package it.finmatica.protocollo.documenti.mail

import groovy.sql.Sql
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.*
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.*
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloIntegrazioneService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloUtilService
import it.finmatica.protocollo.integrazioni.segnatura.interop.SegnaturaInteropService
import it.finmatica.protocollo.integrazioni.segnatura.interop.suap.ente.xsd.CooperazioneSuapEnte
import it.finmatica.protocollo.integrazioni.si4cs.*
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.segreteria.jprotocollo.interop.DocMemoInterop
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import oracle.jdbc.OracleTypes
import org.hibernate.criterion.CriteriaSpecification
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionSynchronizationAdapter
import org.springframework.transaction.support.TransactionSynchronizationManager

import javax.sql.DataSource
import java.text.SimpleDateFormat

@Slf4j
@Transactional
@Service
class MailService {
    public static final String TIPO_COLLEGAMENTO_PEC = 'PROT_PEC'

    @Autowired
    DataSource dataSource
    @Qualifier("dataSource_gdm")
    @Autowired
    DataSource dataSource_gdm
    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    CorrispondenteService corrispondenteService
    @Autowired
    SuccessHandler successHandler
    @Autowired
    MessaggiSi4CSService messaggiSi4CSService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    DocumentoCollegatoRepository documentoCollegatoRepository
    @Autowired
    MessaggiRicevutiService messaggiRicevutiService
    @Autowired
    So4Repository so4Repository
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    ConfigurazioniMailService configurazioniMailService
    @Autowired
    IGestoreFile gestoreFile
    @Autowired
    SegnaturaInteropService segnaturaInteropService
    @Autowired
    ProtocolloUtilService protocolloUtilService
    @Autowired
    SchemaProtocolloIntegrazioneService schemaProtocolloIntegrazioneService


    List<MailDTO> ricercaMittenti(Long idDocumento, String username) {
        Sql sql = new Sql(dataSource)
        List<CorrispondenteDTO> resultList = []
        MailDTO mail

        sql.call("""BEGIN 
					  ? := AGP_PROTOCOLLI_PKG.get_tag_email_mittente (?, ?);
					END; """,
                [Sql.resultSet(OracleTypes.CURSOR), idDocumento, username]) { cursorResults ->
            cursorResults.eachRow { result ->
                mail = buildMail(result)
                resultList << mail
            }
        }
        resultList = resultList.sort { it.ordine }
        return resultList
    }

    private MailDTO buildMail(mail) {
        MailDTO mailDTO = new MailDTO()

        mailDTO.nome = mail.getAt('NOME')
        mailDTO.tagMail = mail.getAt('TAG_MAIL')
        mailDTO.email = mail.getAt('EMAIL')?.trim()
        mailDTO.tipo = mail.getAt('TIPO')
        mailDTO.segnaturaCompleta = ("Y" == mail.getAt('SEGNATURA_COMPLETA'))
        mailDTO.segnatura = ("Y" == mail.getAt('SEGNATURA'))
        mailDTO.ordine = mail.getAt('ORDINE')
        mailDTO.codAmm = mail.getAt('AMMINISTRAZIONE')
        mailDTO.codAoo = mail.getAt('AOO')
        mailDTO.codUo = mail.getAt('CODICE_UO')

        return mailDTO
    }

    void invioPec(DocumentoDTO documento, MailDTO mail, String testo, String oggetto, boolean invioSingolo, boolean segnatura, boolean segnaturaCompleta, List<FileDocumentoDTO> allegati, List<CorrispondenteDTO> corrispondenti, String tipoConsegna) {
        String tipoRicevutaConsegna = tipoConsegna ? tipoConsegna : ImpostazioniProtocollo.TIPO_CONSEGNA.valore
        boolean usaSi4CsWs = (ImpostazioniProtocollo.PEC_USA_SI4CS_WS.valore == "Y")

        log.info("##invioPec usaSi4CsWs=" + usaSi4CsWs + " - Documento=" + documento.id + " - invioSingolo=" + invioSingolo + " - segnatura=" + segnatura + " - segnaturaCompleta=" + segnaturaCompleta + " - tipoConsegna=" + tipoConsegna)

        Vector<String> vAllegatiFile = new Vector<String>()
        List<FileDocumentoDTO> allegatiFile = new ArrayList<FileDocumentoDTO>()
        if (!usaSi4CsWs) {
            for (FileDocumentoDTO a : allegati) {
                vAllegatiFile.add(a.nome)
            }
        } else {
            for (FileDocumentoDTO a : allegati) {
                allegatiFile.add(a)
            }
        }

        Vector<String> destinatari = new Vector<String>()
        Vector<String> destinatariCC = new Vector<String>()

        for (CorrispondenteDTO c : corrispondenti) {
            if (!usaSi4CsWs) {
                if (c.conoscenza) {
                    destinatariCC.add(c.idDocumentoEsterno?.toString())
                } else {
                    destinatari.add(c.idDocumentoEsterno?.toString())
                }
            }
            c.modalitaInvioRicezione = ModalitaInvioRicezione.findByCodice(ModalitaInvioRicezione.CODICE_PEC).toDTO()
        }

        Protocollo documentoDomain = documento.domainObject
        List<Corrispondente> corrispondenteList = corrispondenteService.salvaPerInvio(documentoDomain, corrispondenti, false, true)
        corrispondenti = corrispondenteList?.toDTO() as List<CorrispondenteDTO>

        if (testo == null) {
            testo = ""
        }

        /*if (!ImpostazioniProtocollo.SCELTA_ALLEGATI_IN_INVIO.isAbilitato()) {
            if (!usaSi4CsWs) {
                vAllegatiFile = null
            } else {
                allegatiFile = new ArrayList<FileDocumentoDTO>()
            }
        }*/

        if (!usaSi4CsWs) {
            Vector<DocMemoInterop> vMemo = protocolloUtilService.spedisciConSegnatura(documentoDomain, mail, segnaturaCompleta, testo, segnatura, invioSingolo, vAllegatiFile, destinatari, destinatariCC, tipoRicevutaConsegna)

            // aggiungo l'handler per inviare la ricevuta:
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
                @Override
                void afterCommit() {
                    salvaCorrispondentiMessaggio(corrispondenti, vMemo)
                }
            })
        } else {
            spedisciConSegnatura(documentoDomain, mail, segnaturaCompleta, testo, oggetto, segnatura, invioSingolo, allegatiFile, tipoRicevutaConsegna, corrispondenti)
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    void salvaCorrispondentiMessaggio(List<CorrispondenteDTO> corrispondenti, Vector<DocMemoInterop> vMemo) {
        for (int i = 0; i < vMemo.size(); i++) {
            DocMemoInterop memo = vMemo.get(i)
            Messaggio messaggio = Messaggio.findByIdDocumentoEsterno(Long.parseLong(memo.idDocumento))
            if (messaggio != null) {
                for (CorrispondenteDTO c : corrispondenti) {

                    CorrispondenteMessaggio corrispondenteMessaggio = new CorrispondenteMessaggio()
                    corrispondenteMessaggio.conoscenza = c.conoscenza
                    corrispondenteMessaggio.denominazione = c.denominazione
                    corrispondenteMessaggio.email = c.email?.trim()
                    corrispondenteMessaggio.corrispondente = c.domainObject
                    corrispondenteMessaggio.messaggio = messaggio

                    List<String> destinatariMemo = memo.destinatari?.split(",|;") ?: []
                    destinatariMemo.addAll(memo.cc?.split(",|;") ?: [])
                    destinatariMemo.addAll(memo.bcc?.split(",|;") ?: [])
                    if (destinatariMemo.contains(corrispondenteMessaggio.email?.toLowerCase())) {
                        corrispondenteMessaggio.save()
                    }
                }
            } else {
                successHandler.addWarn(memo.erroreSped ?: "Errore in spedizione email")
            }
            successHandler.showMessages()
        }
    }

    void spedisciNotificaEccezione(Protocollo protocollo) throws Exception {
        log.debug("MailService.spedisciNotificaEccezione con protocollo " + protocollo.id)

        if (!protocollo.categoriaProtocollo.isPec()) {
            log.debug("MailService.spedisciNotificaEccezione il protocollo passato non è un protocollo di tipo PEC. Esco")
            return
        }

        String mittente, tag, nomeMittente, destinatario
        String ammMittente = null, aooMittente = null, uoMittente

        log.debug("MailService.spedisciNotificaEccezione Mi calcolo le informazioni come mittente per inviare il messaggio in uscita")
        Map infoMittente = getInfoMittenteMessaggioRicevutoProtocollo(protocollo)
        mittente = infoMittente.mittente
        tag = infoMittente.tagMail
        nomeMittente = mittente

        Ente ente = springSecurityService.getPrincipal().getEnte()

        ammMittente = ente?.amministrazione?.codice
        aooMittente = ente?.aoo
        uoMittente = infoMittente.codUo

        log.debug("MailService.spedisciNotificaEccezione mittente: " + mittente + " tag: " + tag +
                " nomeMittente: " + nomeMittente + " ammMittente: " + ammMittente + " aooMittente: " + aooMittente + " uoMittente: " + uoMittente)

        if (mittente?.equals("") || tag?.equals("")) {
            log.debug("MailService.spedisciNotificaEccezione Errore in spedizione del messaggio di posta: " +
                    "non trovo il mittente o il suo tag mail da cui spedire")
            throw new Exception(
                    "Errore spedizione del messaggio di eccezione: non ad individuare la casella mittente da cui spedire");
        }

        log.debug("MailService.spedisciConfermaRicezioneTransAuth mittente: Calcolo i destinatari del messaggio in uscita recuperandoli dal mittente del messaggio in arrivo")
        DocumentoCollegato documentoCollegato = messaggiRicevutiService.getCollegamentoMessaggioProtocollo(protocollo, MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL)
        MessaggioRicevuto messaggioRicevuto = (MessaggioRicevuto) documentoCollegato.documento

        destinatario = messaggioRicevuto.mittente
        List<String> destinatari = messaggiRicevutiService.getListaEmailDaIndirizzi(destinatario)
        List<CorrispondenteDTO> corrispondenti = new ArrayList<CorrispondenteDTO>()
        for (Emaildestinatario in destinatari) {
            corrispondenti.add(new CorrispondenteDTO(email: Emaildestinatario))
        }
        log.debug("MailService.spedisciNotificaEccezione mittente: Calcolati, valgono " + destinatari)

        try {
            String eccezioneXML
            try {
                log.debug("MailService.spedisciNotificaEccezione Produco l'eccezione.xml")
                eccezioneXML = segnaturaInteropService.produciEccezione(protocollo)
            }
            catch (Exception e) {
                log.debug("MailService.spedisciNotificaEccezione Errore in spedizione eccezione: " +
                        "non riesco a costruire l'xml di eccezione. Errore=" + e.getMessage())
                throw new Exception(
                        "Errore in spedizione eccezione: non riesco a costruire l'xml di conferma", e);
            }

            String oggetto
            oggetto = protocollo.oggetto + " ECCEZIONE.XML"

            log.debug("MailService.spedisciNotificaEccezione Invio il messaggio")
            messaggiSi4CSService.creaMessaggioInviatoAgsprDaSi4CS(tag, nomeMittente, mittente, null, oggetto,
                    protocollo, new ArrayList<FileDocumentoDTO>(), ammMittente, aooMittente, uoMittente,
                    TipoCollegamento.findByCodice(MessaggiInviatiService.TIPO_COLLEGAMENTO_ECCEZIONE),
                    corrispondenti, false, false, eccezioneXML, "eccezione.xml", "completa",
                    messaggioRicevuto)
        } catch (Exception e) {
            throw new Exception("MailService::spedisciNotificaEccezione", e)
        }
    }

    void spedisciConfermaRicezione(Protocollo protocollo) throws Exception {
        log.debug("MailService.spedisciConfermaRicezioneTransAuth con protocollo " + protocollo.id)

        if (!protocollo.categoriaProtocollo.isPec()) {
            log.debug("MailService.spedisciConfermaRicezioneTransAuth il protocollo passato non è un protocollo di tipo PEC. Esco")
            return
        }

        try {
            String confermaXML
            try {
                log.debug("MailService.spedisciConfermaRicezioneTransAuth Produco la conferma di segnatura")
                confermaXML = segnaturaInteropService.produciConferma(protocollo, (ImpostazioniProtocollo.IS_ENTE_INTERPRO.valore == "Y"))
            }
            catch (Exception e) {
                log.debug("MailService.spedisciConfermaRicezioneTransAuth Errore in spedizione conferma di ricezione del messaggio di posta: " +
                        "non riesco a costruire l'xml di conferma. Errore=" + e.getMessage())
                throw new Exception(
                        "Errore in spedizione conferma di ricezione del messaggio di posta: non riesco a costruire l'xml di conferma", e);
            }

            if (confermaXML == "") {
                log.debug("MailService.spedisciConfermaRicezioneTransAuth Non è stata richiesta alcuna conferma dal messaggio in arrivo. Esco")
                return
            }

            String mittente, tag, nomeMittente
            String ammMittente = null, aooMittente = null, uoMittente

            log.debug("MailService.spedisciConfermaRicezioneTransAuth Mi calcolo le informazioni come mittente per inviare il messaggio in uscita")
            Map infoMittente = getInfoMittenteMessaggioRicevutoProtocollo(protocollo)
            mittente = infoMittente.mittente
            tag = infoMittente.tagMail
            nomeMittente = mittente

            Ente ente = springSecurityService.getPrincipal().getEnte()

            ammMittente = ente?.amministrazione?.codice
            aooMittente = ente?.aoo
            uoMittente = infoMittente.codUo

            log.debug("MailService.spedisciConfermaRicezioneTransAuth mittente: " + mittente + " tag: " + tag +
                    " nomeMittente: " + nomeMittente + " ammMittente: " + ammMittente + " aooMittente: " + aooMittente + " uoMittente: " + uoMittente)

            if (mittente?.equals("") || tag?.equals("")) {
                log.debug("MailService.spedisciConfermaRicezioneTransAuth Errore in spedizione del messaggio di posta: " +
                        "non trovo il mittente o il suo tag mail da cui spedire")
                throw new Exception(
                        "Errore in spedizione del messaggio di posta: non trovo il mittente o il suo tag mail da cui spedire");
            }

            log.debug("MailService.spedisciConfermaRicezioneTransAuth Calcolo i corrispondenti al messaggio in uscita che devo creare")
            List<CorrispondenteDTO> corrispondenti = new ArrayList<CorrispondenteDTO>()
            for (corrispondente in protocollo.corrispondenti) {
                if (corrispondente.tipoCorrispondente == Corrispondente.MITTENTE &&
                        corrispondente.email != null && !corrispondente.email?.equals("")) {
                    corrispondenti.add(corrispondente.toDTO())
                    log.debug("MailService.spedisciConfermaRicezioneTransAuth Trovato corrispondente: " + corrispondente.email)
                }
            }
            if (corrispondenti.size() == 0) {
                log.debug("MailService.spedisciConfermaRicezioneTransAuth Errore in spedizione conferma di ricezione " +
                        "del messaggio di posta: non ci sono indirizzi cui spedire")
                throw new ProtocolloRuntimeException(
                        "Errore in spedizione conferma di ricezione del messaggio di posta: non ci sono indirizzi cui spedire");
            }

            String oggetto
            oggetto = "(Rif: " + protocollo.getAnno() +
                    "/" + protocollo.getNumero() + " " + protocollo.getTipoRegistro()?.codice + ") " + protocollo.oggetto +
                    " CONFERMA.XML"

            log.debug("MailService.spedisciConfermaRicezioneTransAuth Calcolo l'oggetto del messaggio " + oggetto)

            log.debug("MailService.spedisciConfermaRicezioneTransAuth Invio il messaggio")
            messaggiSi4CSService.creaMessaggioInviatoAgsprDaSi4CS(tag, nomeMittente, mittente, null, oggetto,
                    protocollo, new ArrayList<FileDocumentoDTO>(), ammMittente, aooMittente, uoMittente,
                    TipoCollegamento.findByCodice(MessaggiInviatiService.TIPO_COLLEGAMENTO_CONFERMA),
                    corrispondenti, false, false, confermaXML, "conferma.xml")
        } catch (Exception e) {
            throw new Exception("MailService::spedisciConfermaRicezioneTransAuth", e)
        }
    }

    void inviaRicevuta(Protocollo protocollo) throws Exception {
        if (!protocollo.categoriaProtocollo.isPec()) {
            return
        }

        try {
            String mittente, tag, nomeMittente
            String ammMittente = null, aooMittente = null, uoMittente

            log.debug("MailService.inviaRicevutaTransAuth Mi calcolo le informazioni come mittente per inviare il messaggio in uscita")
            Map infoMittente = getInfoMittenteMessaggioRicevutoProtocollo(protocollo)
            mittente = infoMittente.mittente
            tag = infoMittente.tagMail
            nomeMittente = mittente

            Ente ente = springSecurityService.getPrincipal().getEnte()

            ammMittente = ente?.amministrazione?.codice
            aooMittente = ente?.aoo
            uoMittente = infoMittente.codUo

            log.debug("MailService.inviaRicevutaTransAuth mittente: " + mittente + " tag: " + tag +
                    " nomeMittente: " + nomeMittente + " ammMittente: " + ammMittente + " aooMittente: " + aooMittente + " uoMittente: " + uoMittente)

            if (mittente?.equals("") || tag?.equals("")) {
                throw new Exception(
                        "Errore in spedizione del messaggio di posta: non trovo il mittente o il suo tag mail da cui spedire");
            }

            log.debug("MailService.inviaRicevutaTransAuth Calcolo i corrispondenti al messaggio in uscita che devo creare")
            List<CorrispondenteDTO> corrispondenti = new ArrayList<CorrispondenteDTO>()
            for (corrispondente in protocollo.corrispondenti) {
                if (corrispondente.tipoCorrispondente == Corrispondente.MITTENTE &&
                        corrispondente.email != null && !corrispondente.email?.equals("")) {
                    corrispondenti.add(corrispondente.toDTO())
                }
            }

            if (corrispondenti.size() == 0) {
                log.debug("MailService.inviaRicevutaTransAuth Errore in spedizione conferma di ricezione " +
                        "del messaggio di posta: non ci sono indirizzi cui spedire")
                throw new Exception(
                        "Errore in spedizione del messaggio di posta: non ci sono indirizzi cui spedire");
            }

            //Cerco il messaggioRicevuto collegato (e che ha generato) il protocollo
            log.debug("MailService.inviaRicevutaTransAuth Cerco il messaggio ricevuto collegato che ha generato in precedenza il protocollo")
            String oggettoMessaggioRicevuto = ""
            DocumentoCollegato documentoMailRicevuto
            documentoMailRicevuto = documentoCollegatoRepository.collegamentoPadrePerTipologia(protocollo,
                    TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL))
            if (documentoMailRicevuto == null || !(documentoMailRicevuto?.documento instanceof MessaggioRicevuto)) {
                log.debug("MailService.inviaRicevutaTransAuth Errore in spedizione " +
                        "del messaggio di posta: non trovo il messaggio ricevuto collegato al protocollo")
                throw new Exception(
                        "Errore in spedizione del messaggio di posta: non trovo il messaggio ricevuto collegato al protocollo");
            }

            oggettoMessaggioRicevuto = ((MessaggioRicevuto) documentoMailRicevuto.documento).oggetto
            oggettoMessaggioRicevuto = "[Ricevuta_AUTO]" + " (Rif: " + protocollo.getAnno() +
                    "/" + protocollo.getNumero() + " " + protocollo.getTipoRegistro()?.codice + ") " + oggettoMessaggioRicevuto

            log.debug("MailService.inviaRicevutaTransAuth Costruito l'oggetto della mail da inviare, vale: " + oggettoMessaggioRicevuto)

            String testoMail
            testoMail = (ImpostazioniProtocollo.RICEVUTA_PROT.valore == null) ? "" : ImpostazioniProtocollo.RICEVUTA_PROT.valore
            testoMail = testoMail.replace("\$numero", String.valueOf(protocollo.getNumero()))
            //protocollo.data = new Date()
            testoMail = testoMail.replace("\$data", new SimpleDateFormat(protocolloService.getFormatoDataProtocollo()).format(protocollo.data))

            log.debug("MailService.inviaRicevutaTransAuth Costruito il testo della mail da inviare, vale: " + testoMail)

            boolean isTestoRicevutaAttachment = false
            String nomeFileAllegato = null
            if (ImpostazioniProtocollo.IS_ENTE_INTERPRO.valore == "Y") {
                isTestoRicevutaAttachment = true
                nomeFileAllegato = "ricevuta.txt"
            }

            log.debug("MailService.inviaRicevutaTransAuth Invio il messaggio")
            messaggiSi4CSService.creaMessaggioInviatoAgsprDaSi4CS(tag, nomeMittente, mittente, (isTestoRicevutaAttachment) ? null : testoMail, oggettoMessaggioRicevuto,
                    protocollo, new ArrayList<FileDocumentoDTO>(), ammMittente, aooMittente, uoMittente,
                    TipoCollegamento.findByCodice(MessaggiInviatiService.TIPO_COLLEGAMENTO_RICEVUTA),
                    corrispondenti, false, false, (isTestoRicevutaAttachment) ? testoMail : null, nomeFileAllegato)
        } catch (Exception e) {
            throw new Exception("MailService::inviaRicevutaTransAuth", e)
        }
    }

    List<MessaggioDTO> caricaMessaggiInviati(Protocollo protocollo) {
        return caricaMessaggiInviati(protocollo, 1000, 0)
    }

    List<MessaggioDTO> caricaMessaggiInviati(Protocollo protocollo, int max, int offset) {
        List<MessaggioDTO> messaggi = new ArrayList<MessaggioDTO>()

        List<DocumentoCollegato> documentoMailInviate
        documentoMailInviate = documentoCollegatoRepository.collegamentiPerTipologia(protocollo,
                TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL))

        for (documentoCollegato in documentoMailInviate) {
            if (documentoCollegato.collegato.class == MessaggioInviato.class) {
                messaggi.add(Messaggio.get(documentoCollegato.collegato.id)?.toDTO(["corrispondenti", "utenteIns"]))
            }
        }

        //Carico anche quelli generati nel vecchio modo (JPROTOCOLLO)
        MessaggioProtocollo.executeQuery("""
				SELECT messaggio.id, messaggio.dataSpedizioneMemo
				FROM   MessaggioProtocollo messaggioProtocollo, Messaggio messaggio
				WHERE   messaggioProtocollo.messaggio.id = messaggio.id
				AND    messaggioProtocollo.idDocumentoEsterno = :idProtocollo
				AND   messaggio.id<0
				group by messaggio.id, messaggio.dataSpedizioneMemo
				order by messaggio.dataSpedizioneMemo DESC
			""", [idProtocollo: protocollo.idDocumentoEsterno], [max: max, offset: offset])
                .each { m ->
                    MessaggioDTO mm = Messaggio.createCriteria().get {
                        eq("idDocumentoEsterno", -m[0])
                    }.toDTO()
                    // recuperati così per evitare di andare sull'id del messaggio (lento)
                    List<CorrispondenteMessaggio> corrispondentiMessaggio = CorrispondenteMessaggio.createCriteria().list {
                        createAlias("messaggio", "mess", CriteriaSpecification.LEFT_JOIN)
                        eq("mess.idDocumentoEsterno", -m[0])
                    }.toDTO()

                    mm.corrispondenti = corrispondentiMessaggio
                    messaggi.add(mm)
                }

        return messaggi
    }

    Messaggio caricaMessaggioRicevuto(Protocollo protocollo) {
        DocumentoCollegato documentoMailRicevuta
        documentoMailRicevuta = documentoCollegatoRepository.collegamentoPadrePerTipologia(protocollo,
                TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL))

        if (documentoMailRicevuta != null) {
            if (documentoMailRicevuta.documento.class == MessaggioRicevuto.class) {
                return Messaggio.get(documentoMailRicevuta.documento.id)
            }
        } else {
            MessaggioProtocollo messaggioProtocollo = MessaggioProtocollo.findByIdDocumentoEsterno(protocollo.idDocumentoEsterno)
            return messaggioProtocollo?.messaggio
        }
    }

    /**
     * Restituisce la lista dei destinatari della mail in partenza da un protocollo
     * sotto forma di corrispondenti
     */
    List<CorrispondenteDTO> getDestinatariMailProtocollo(Protocollo p) {
        List<CorrispondenteDTO> destinatari

        boolean isImpresaInUnGiorno = schemaProtocolloIntegrazioneService.isSchemaImpresaInUnGiorno(p.schemaProtocollo)
        if (isImpresaInUnGiorno) {
            Corrispondente corrispondente = Corrispondente.findByProtocolloAndSuap(p, true)
            //se pur avendo tipo doc di impresa in un giorno, non trovo il protocollo precedente
            // o se questo non ha messaggio in arrivo associato, torno nel giro standard
            if (!corrispondente) {
                Protocollo precedente = p.getProtocolloPrecedente()
                Messaggio messaggioRicevuto = caricaMessaggioRicevuto(precedente)
                corrispondente = new Corrispondente()
                corrispondente.email = messaggioRicevuto?.mittente
                corrispondente.denominazione = "SUAP Impresa in un giorno"
                corrispondente.suap = true
            }
            if (corrispondente) {
                destinatari = new ArrayList<CorrispondenteDTO>()
                destinatari.add(corrispondente.toDTO(["messaggi"]))
            }
        }

        if (!destinatari) {
            destinatari = p.corrispondenti.toDTO(["messaggi"]).toList()
            destinatari = destinatari.sort { it.id }
        }
        return destinatari
    }

    /**
     * Restituisce l'oggetto di default della mail in partenza da un protocollo
     */
    String getOggettoMailProtocollo(Protocollo p) {
        String oggetto

        boolean isImpresaInUnGiorno = schemaProtocolloIntegrazioneService.isSchemaImpresaInUnGiorno(p.schemaProtocollo)
        if (isImpresaInUnGiorno) {
            //se pur avendo tipo doc di impresa in un giorno, non trovo il protocollo precedente
            // o se questo non ha messaggio in arrivo associato, torno nel giro standard
            Protocollo precedente = p.getProtocolloPrecedente()
            Messaggio messaggioRicevuto = caricaMessaggioRicevuto(precedente)
            if (messaggioRicevuto) {
                oggetto = "Re: "+messaggioRicevuto.oggetto
            }
        }

        if (!oggetto) {
            oggetto = "(Rif: " + p.anno + "/" + p.numero + " " + p.tipoRegistro.codice + ") " + p.oggetto
        }
        return oggetto
    }

    CooperazioneSuapEnte getCooperazioneSuapEnte(Protocollo p) {
        CooperazioneSuapEnte cooperazioneSuapEnte = null
        Messaggio messaggioRicevuto = caricaMessaggioRicevuto(p)
        messaggioRicevuto.get
    }

    private spedisciConSegnatura(Protocollo documento, MailDTO mail, boolean segnaturaCompleta, String testo, String oggetto, boolean segnatura, boolean invioSingolo,
                                 List<FileDocumentoDTO> allegatiFile, String tipoRicevutaConsegna,
                                 List<CorrispondenteDTO> corrispondenti) {

        log.info("##MailService.spedisciConSegnatura invioSingolo:" + invioSingolo)

        boolean isImpresaInUnGiorno = isImpresaInUnGiorno(documento)

        oggetto = (oggetto == null || oggetto?.equals("")) ? oggetto = documento.oggetto : oggetto

        try {
            if (!invioSingolo) {
                messaggiSi4CSService.creaMessaggioInviatoAgsprDaSi4CS(mail.tagMail, mail.nome, mail.email?.trim(), testo, oggetto,
                        documento, allegatiFile, mail.codAmm, mail.codAoo, mail.codUo,
                        TipoCollegamento.findByCodice(MessaggiInviatiService.TIPO_COLLEGAMENTO_MAIL), corrispondenti, segnatura, segnaturaCompleta,
                        null, null, tipoRicevutaConsegna, null, isImpresaInUnGiorno)
            } else {
                for (corrispondente in corrispondenti) {
                    List<CorrispondenteDTO> corrispondenteSingolo = new ArrayList<CorrispondenteDTO>()
                    corrispondenteSingolo.add(corrispondente)

                    messaggiSi4CSService.creaMessaggioInviatoAgsprDaSi4CS(mail.tagMail, mail.nome, mail.email?.trim(), testo, oggetto,
                            documento, allegatiFile, mail.codAmm, mail.codAoo, mail.codUo,
                            TipoCollegamento.findByCodice(MessaggiInviatiService.TIPO_COLLEGAMENTO_MAIL), corrispondenteSingolo, segnatura, segnaturaCompleta,
                            null, null, tipoRicevutaConsegna, null, isImpresaInUnGiorno)
                }
            }
        } catch (Exception e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    private boolean isImpresaInUnGiorno(Protocollo documento) {
        boolean isImpresaInUnGiorno = schemaProtocolloIntegrazioneService.isSchemaImpresaInUnGiorno(documento.schemaProtocollo)
        if (isImpresaInUnGiorno) {
            //se pur avendo tipo doc di impresa in un giorno, non trovo il protocollo precedente
            // o se questo non ha messaggio in arrivo associato, torno nel giro standard
            Protocollo precedente = documento.getProtocolloPrecedente()
            Messaggio messaggioRicevuto = caricaMessaggioRicevuto(precedente)
            if (messaggioRicevuto != null) {
                isImpresaInUnGiorno = true
            } else {
                isImpresaInUnGiorno = false
            }
        }
        return isImpresaInUnGiorno
    }

    /* Sostituisce la gdm.ag_documento_utility.get_tagmail_indirizzo
    * Dato un protocollo restituisce le informazioni (mittente e tag)
    * del mittente del messaggioRicevuto legato al protocollo
    *  */

    private Map getInfoMittenteMessaggioRicevutoProtocollo(Protocollo protocollo) {
        Map ret = [tagMail: "", mittente: "", codUo: ""]

        DocumentoCollegato documentoCollegato = messaggiRicevutiService.getCollegamentoMessaggioProtocollo(protocollo, MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL)
        MessaggioRicevuto messaggioRicevuto = (MessaggioRicevuto) documentoCollegato.documento
        So4UnitaPubb unitaEsibenteProtocollo = protocollo.soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_ESIBENTE
        }?.unitaSo4
        So4UnitaPubb unitaProtocollante = protocollo.soggetti.find {
            it.tipoSoggetto == TipoSoggetto.UO_PROTOCOLLANTE
        }?.unitaSo4
        List<String> listaMailDestinatari = []

        if (messaggioRicevuto != null) {
            listaMailDestinatari = messaggiRicevutiService.getListaEmailDaIndirizzi(messaggioRicevuto.destinatari) +
                    messaggiRicevutiService.getListaEmailDaIndirizzi(messaggioRicevuto.destinatariConoscenza) +
                    messaggiRicevutiService.getListaEmailDaIndirizzi(messaggioRicevuto.destinatariNascosti)
        }

        //1. Se esiste un messaggio Ricevuto collegato ed il proto
        // ha unità esibente e il suo indirizzo è tra i destinatari della mail ricevuta,
        // allora si ritornano tagmail e indirizzo istituzionale dell'unità esibente
        if (messaggioRicevuto != null && unitaEsibenteProtocollo != null) {
            List<So4IndirizzoTelematico> indirizziUoEsibente = so4Repository.getListaIndirizzoUo("I", unitaEsibenteProtocollo)
            if (indirizziUoEsibente?.size() > 0) {
                for (indirizzoUoEsibente in indirizziUoEsibente) {
                    if (listaMailDestinatari.contains(indirizzoUoEsibente.indirizzo?.trim())) {
                        ret.tagMail = unitaEsibenteProtocollo.tagMail
                        ret.mittente = indirizzoUoEsibente.indirizzo?.trim()
                        break
                    }
                }
            }
        }

        if (ret.mittente == null || ret.mittente?.equals("")) {
            //2. verifica se l'indirizzo dell'unità protocollante è tra i destinatari della mail ricevuta,
            // se così è si ritornano tagmail e indirizzo istituzionale dell'unità protocollante
            if (messaggioRicevuto != null && unitaProtocollante != null) {
                List<So4IndirizzoTelematico> indirizziUoProtocollante = so4Repository.getListaIndirizzoUo("I", unitaProtocollante)
                if (indirizziUoProtocollante?.size() > 0) {
                    for (indirizzoUoProtocollante in indirizziUoProtocollante) {
                        if (listaMailDestinatari.contains(indirizzoUoProtocollante.indirizzo?.trim())) {
                            ret.tagMail = unitaProtocollante.tagMail
                            ret.mittente = indirizzoUoProtocollante.indirizzo?.trim()
                            break
                        }
                    }
                }
            }
        }

        List<HashMap<String, String>> caselleUtente = null
        boolean privilegioPMAILT, privilegioPMAILI, privilegioPMAILU
        if (ret.mittente == null || ret.mittente?.equals("")) {
            caselleUtente = configurazioniMailService.getListaCaselle(false)
            privilegioPMAILT = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILT, springSecurityService.currentUser)
            privilegioPMAILI = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILI, springSecurityService.currentUser)
            privilegioPMAILU = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILU, springSecurityService.currentUser)
        }

        if (ret.mittente == null || ret.mittente?.equals("")) {
            //3. se l'utente ha privilegio PMAILT o PMAILI valido ad oggi e l'indirizzo istituzionale è tra i destinatari,
            // si ritornano tagmail e indirizzo della casella istituzionale
            if (privilegioPMAILT || privilegioPMAILI
            ) {
                Map casella = caselleUtente?.find { it.tipo == configurazioniMailService.TIPO_CASELLA_ISTITUZIONALE }
                if (casella != null && listaMailDestinatari.find {
                    it.trim().toLowerCase() == casella?.casella?.trim()?.toLowerCase()
                } != null) {
                    ret.mittente = casella.casella
                    ret.tagMail = casella.tag
                }
            }
        }

        if (ret.mittente == null || ret.mittente?.equals("")) {
            //4. se l'indirizzo istituzionale non è tra i destinatari e l'utente ha privilegio PMAILT o PMAILU ,
            // allora si cerca tra i destinatari quello corrispondente ad una unità organizzativa dell'ente
            // che abbia un tagmail con cui inviare
            if (privilegioPMAILT || privilegioPMAILU
            ) {
                List<Map<String, String>> caselle = caselleUtente?.findAll {
                    it.tipo == configurazioniMailService.TIPO_CASELLA_UNITA
                }
                for (casella in caselle) {
                    if (listaMailDestinatari.find {
                        it.trim().toLowerCase() == casella?.casella?.trim()?.toLowerCase()
                    } != null && casella.tag != null && !casella?.tag?.equals("")) {
                        ret.mittente = casella.casella
                        ret.tagMail = casella.tag
                        ret.codUo = casella.codiceEnte
                    }
                }
            }
        }

        if (ret.mittente == null || ret.mittente?.equals("")) {
            Map casella = caselleUtente?.find { it.tipo == configurazioniMailService.TIPO_CASELLA_ISTITUZIONALE }
            if (casella != null && listaMailDestinatari.find {
                it.trim().toLowerCase() == casella?.casella?.trim()?.toLowerCase()
            } != null) {
                ret.mittente = casella.casella
                ret.tagMail = casella.tag
            }
        }

        return ret
    }
}
