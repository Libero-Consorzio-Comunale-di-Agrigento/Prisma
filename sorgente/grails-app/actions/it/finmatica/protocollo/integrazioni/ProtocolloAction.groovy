package it.finmatica.protocollo.integrazioni

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.AbstractViewModel
import it.finmatica.gestionedocumenti.deleghe.DelegaService
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.notifiche.Notifica
import it.finmatica.gestionedocumenti.notifiche.NotificheService
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.gestioneiter.IDocumentoIterabile
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.gestioneiter.annotations.Action.TipoAzione
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.AnnullamentoService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.StampaUnicaService
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import it.finmatica.protocollo.smistamenti.SmistamentoService
import org.jfree.util.Log
import org.springframework.beans.factory.annotation.Autowired
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients

@Action
class ProtocolloAction {

    @Autowired
    SpringSecurityService springSecurityService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    StampaUnicaService stampaUnicaService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    AnnullamentoService annullamentoService
    @Autowired
    DocumentoService documentoService
    @Autowired
    NotificheService notificheService
    @Autowired
    SuccessHandler successHandler
    @Autowired
    WkfIterService wkfIterService
    @Autowired
    DelegaService delegaService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    private ProtocolloGestoreCompetenze gestoreCompetenze

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla che l'Editor di testo sia aperto e che il testo sia lokato",
            descrizione = "Controlla che l'Editor di testo sia aperto e che il testo sia lokato (utile come controllo nell'azione protocolla e firma")
    Protocollo controllaEditorApertoETestoLockato(Protocollo documento) {
        if (documentoService.isEditorAperto()) {
            throw new ProtocolloRuntimeException("Non è possibile proseguire con la firma del testo: il documento è ancora aperto nell'editor di testo. Chiudere l'editor di testo.")
        }

        if (documento.filePrincipale != null && documentoService.uploadEUnlockTesto(documento, documento.filePrincipale)) {
            throw new ProtocolloRuntimeException("Non è possibile proseguire: il documento è ancora aperto da un altro utente.")
        }
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Protocolla il documento",
            descrizione = "Protocollo il documento. Protocolla solo se sono soddisfatti i criteri (cioè se il documento no è già protocollato e se sono presenti classifica e fascicolo quando richiesti)")
    Protocollo protocolla(Protocollo documento) {

        // se il documento è già protocollato, esco:
        if (documento.isProtocollato()) {
            return documento
        }

        boolean escludiControlloCompentenze = false

        Ad4Utente firmatario = documento.getSoggetto(it.finmatica.gestionedocumenti.soggetti.TipoSoggetto.FIRMATARIO)?.utenteAd4
        if (firmatario) {
            if (delegaService.hasDelega(springSecurityService.currentUser, firmatario)) {
                escludiControlloCompentenze = true
            }
        }

        // eseguo la protocollazione
        protocolloService.protocolla(documento, true, escludiControlloCompentenze)

        if (protocolloService.isRiservato(documento)) {
            documento.controlloRiservatoDopoProtocollazione = true
        }

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Protocolla il documento prima della firma",
            descrizione = "Protocollo il documento sul protocollo definito dalle impostazioni. Protocolla solo se sono soddisfatti i criteri (cioè se il documento no è già protocollato e se sono presenti classifica e fascicolo quando richiesti)")
    Protocollo protocollaPreFirma(Protocollo documento) {

        if (documento.isProtocollato()) {
            return documento
        }

        protocolloService.storicizzaProtocollo(documento, documento.iter?.stepCorrente, false)

        boolean escludiControlloCompentenze = false

        Ad4Utente firmatario = documento.getSoggetto(it.finmatica.gestionedocumenti.soggetti.TipoSoggetto.FIRMATARIO)?.utenteAd4
        if (firmatario) {
            if (delegaService.hasDelega(springSecurityService.currentUser, firmatario)) {
                escludiControlloCompentenze = true
            }
        }

        // eseguo la protocollazione
        protocolloService.protocolla(documento, false, escludiControlloCompentenze)

        // segnalo la protocollazione effettuata
        successHandler.addMessage("Protocollazione effettuata con n. ${documento.numero} / ${documento.anno}")

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Invio Smistamenti",
            descrizione = "Invio degli smistamenti di un protocollo")
    Protocollo invioSmistamenti(Protocollo documento) {

        if (documento.numero > 0) {
            try {

                // se ho appena protocollato (nelle action diamo per scontato che sia sempre così)
                if (documento.isRiservato() && !gestoreCompetenze.verificaCompetenzeLettura(documento)) {
                    smistamentoService.inviaSmistamenti(documento, true)
                } else {
                    smistamentoService.inviaSmistamenti(documento)
                }
            } catch (java.lang.RuntimeException e) {
                Log.error("Errore durante l'invio degli smistamenti: " + e.getMessage())
                Notifica notifica = Notifica.findByTipoNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_TODO_SMISTAMENTI_IN_ERRORE)
                notificheService.invia(notifica, documento, notifica?.oggetto)
            }
            return documento
        }
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Crea o Rigenera la stampa unica",
            descrizione = "Crea o rigenera la stampa unica del documento aggiungendo tutti i file allegati ai documenti allegati con il flag stampaUnica = true")
    Protocollo creaStampaUnica(Protocollo documento) {
        stampaUnicaService.creaAllegatoStampaUnica(documento, ImpostazioniProtocollo.STAMPA_UNICA_FRASE_FOOTER.valore, documento.nomeFileStampaUnica)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Valida la Protocollazione",
            descrizione = "Controlla Fascicolo, Classifica, Destinatari e Smistamenti prima della protocollazione.")
    Protocollo validaProtocollazione(Protocollo documento) {
        protocolloService.validaProtocollo(documento)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla Fascicolo, Classifica in base ai parametri",
            descrizione = "Controlla la presenza di Fascicolo, Classifica considerando i parametri FASC_OB e CLASS_OB.")
    Protocollo validaFascicoloECLassifica(Protocollo documento) {
        protocolloService.validaFascicoloEClassifica(documento)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla che Fascicolo, Classifica siano valorizzati",
            descrizione = "Verifica che Classifica e Fascicolo siano valorizzati. In caso negativo interrompe il flusso.")
    Protocollo validaFascicoloECLassificaObbligatori(Protocollo documento) {
        if (documento.classificazione == null) {
            throw new ProtocolloRuntimeException('La Classificazione è obbligatoria')
        }

        if (documento.fascicolo == null) {
            throw new ProtocolloRuntimeException('Il Fascicolo è obbligatorio')
        }

        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla Movimento",
            descrizione = "Controlla se il Movimento è valorizzato.")
    Protocollo validaMovimento(Protocollo documento) {
        protocolloService.validaMovimento(documento)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla Oggetto",
            descrizione = "Controlla se l'Oggetto è valorizzato.")
    Protocollo validaOggetto(Protocollo documento) {
        protocolloService.validaOggetto(documento)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla TipoDocumento",
            descrizione = "Controlla se il il Tipo di Documento (Schema di Protocollo) è valorizzato.")
    Protocollo validaSchemaProtocollo(Protocollo documento) {
        protocolloService.validaSchemaProtocollo(documento)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla Smistamenti",
            descrizione = "Controlla Smistamenti prima della protocollazione.")
    Protocollo validaSmistamenti(Protocollo documento) {
        protocolloService.validaSmistamenti(documento)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla la dimensione degli allegati",
            descrizione = "Controlla la dimensione degli allegati.")
    Protocollo validaDimensioneAllegati(Protocollo documento) {
        protocolloService.validaDimensioneAllegati(documento)
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla Destinatari",
            descrizione = "Controlla Destinatari prima della protocollazione.")
    Protocollo validaCorrispondenti(Protocollo documento) {
        protocolloService.validaCorrispondenti(documento)
        return documento
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il documento esiste?",
            descrizione = "Controlla documento esiste")
    boolean esisteDocumento(Protocollo documento) {
        return documento.id != null
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il file principale (testo) esiste?",
            descrizione = "Controlla se il file principale (testo) esiste")
    boolean esisteFilePrincipale(Protocollo documento) {
        return documento?.filePrincipale?.idFileEsterno != null
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "La conclusione del flusso è manuale?",
            descrizione = "Test del paramentro per la conclusione automatica del flusso dopo l'invio di una PEC")
    boolean conclusioneAutomaticaFlusso(Protocollo documento) {
        boolean concludi = "MANUALE" == ImpostazioniProtocollo.LETTERA_CONCLUDI_FLUSSO.valore
        return concludi
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Eliminazione notifiche dopo Invio Pec",
            descrizione = "Eliminazione notifiche dopo Invio Pec e cambio di nodo")
    boolean eliminazioneNotificaInvioPec(Protocollo documento) {
        notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO, documento.idDocumentoEsterno.toString(), null)
        notificheService.eliminaNotifica(RegoleCalcoloNotificheProtocolloRepository.NOTIFICA_CAMBIO_NODO_FIRMATARIO, documento.idDocumentoEsterno.toString(), null)
    }

    @Action(tipo = Action.TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna TRUE se la conclusione del flusso è automatica dopo l'INVIO della PEC",
            descrizione = "Ritorna TRUE se la conclusione del flusso è automatica dopo l'INVIO della PEC")
    boolean sbloccaFlussoInvioPec(Protocollo documento) {
        if ("INVIO" == ImpostazioniProtocollo.LETTERA_CONCLUDI_FLUSSO.valore) {
            return protocolloService.isSpedito(documento)
        } else {
            return false
        }
    }

    @Action(tipo = Action.TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna TRUE se il documento non è protocollato",
            descrizione = "Ritorna TRUE se il documento non è protocollato")
    boolean isNonProtocollato(Protocollo documento) {
        return !(isProtocollato(documento))
    }

    @Action(tipo = Action.TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Ritorna TRUE se il documento è protocollato",
            descrizione = "Ritorna TRUE se il documento è protocollato")
    boolean isProtocollato(Protocollo documento) {
        return documento.numero > 0
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Disabilita il controllo del testo",
            descrizione = "Disabilita il controllo del testo")
    Protocollo disabilitaControlloTesto(Protocollo documento) {
        successHandler.idIterSaltaControlloTesto = documento.iter.id
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla che Protocollo sia stato inviato via posta elettronica",
            descrizione = "Controlla che Protocollo sia stato inviato via posta elettronica almento una volta")
    Protocollo controllaInvioMail(Protocollo documento) {
        if (!protocolloService.isSpedito(documento)) {
            throw new ProtocolloRuntimeException("Prima di concludere è necessario inviare via PEC il documento ")
        }
        return documento
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Converti in pdf tutti gli allegati",
            descrizione = "Converti in pdf tutti gli allegati")
    public IDocumentoIterabile convertiAllegatiPdf(Protocollo d) {
        documentoService.convertiAllegatiPdf(d)
        d.save()
        successHandler.addMessage("Conversione terminata correttamente")
        return d
    }

    @Action(tipo = TipoAzione.CLIENT,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = 'Apre la pubblicazione dell\'albo jmessi',
            descrizione = 'Apre una popup con la pubblicazione all\'albo jmessi.')
    void pubblicaAlbo(AbstractViewModel<? extends IDocumentoIterabile> viewModel, long idCfgPulsante, long idAzioneClient) {
        Protocollo protocollo = viewModel.getDocumentoIterabile(false)
        String returnUrl = protocolloService.pubblicaAlbo(protocollo)
        wkfIterService.eseguiPulsante(protocollo, idCfgPulsante, viewModel, idAzioneClient)

        // questo serve per evitare che la notifica "Documento Salvato" riporti la maschera del protocollo in primo piano
        successHandler.saltaInvalidate()

        // deve aprire una nuova popup "in primo piano"
        Clients.evalJavaScript(" window.open('${returnUrl}', '_blank', 'menubar=no,toolbar=no,location=no').focus() ")
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Controlla che non esistano allegati da firmare di formati consentiti ma di cui non è prevista la conversione in PDF",
            descrizione = "Controlla che non esistano allegati da firmare di formati consentiti ma di cui non è prevista la conversione in PDF")
    void controllaAllegatiNonPdfPresenti(IDocumentoIterabile doc) {
        // conto quanti allegati ci sono da firmare di formati consetiti ma di cui non è prevista la conversione in PDF
        //considero solo allegati da firmare
        if (documentoService.esistonoAllegatiDaFirmareNonConvertibili(doc)) {
            throw new ProtocolloRuntimeException("Esistono allegati da firmare di formati consentiti ma di cui non è prevista la conversione in PDF.")
        }
    }

    @Action(tipo = TipoAzione.PULSANTE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Apre protocollo.",
            descrizione = "Apre la pagina di protocollo.")
    public Protocollo apriProtocollo(Protocollo documento, AbstractViewModel<? extends IDocumentoIterabile> v) {

        Protocollo protocollo = protocolloService.creaProtocollo(documento)

        ProtocolloViewModel.apriPopup(protocollo.toDTO(["tipoProtocollo", "classificazione", "fascicolo"])).addEventListener(Events.ON_CLOSE) { Event e ->
            Events.postEvent(new Event(Events.ON_CLOSE, null))
        }

        // salto l'invalidate della maschera perché altrimenti viene nascosta la popup che ho appena creato
        successHandler.saltaInvalidate()
        return protocollo
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Annulla protocolli provvedimento",
            descrizione = "Annulla protocolli: alla protocollazione (se il documento è già firmato) oppure alla firma (se il documento è già protocollato)")
    void annullaProtocolli(Protocollo documento) {
        annullamentoService.annullaProtocollo(documento)
    }

    @Action(tipo = TipoAzione.AUTOMATICA,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Crea il testo in automatico",
            descrizione = "Crea il testo in automatico solo se l'utente non lo ha già redatto")
    void creaTestoAutomatico(Protocollo documento) {
        if (!documento.filePrincipale?.idFileEsterno) {
            documentoService.generaTestoFilePrincipale(documento, Impostazioni.FORMATO_DEFAULT.valore, true)
            documento.save()
        }
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Il documento è da firmare?",
            descrizione = "Verifica se il documento è non finalizzato e se l'utente ha i privilegi per firmarlo")
    boolean verificaPulsanteFirma(Protocollo documento) {
        def daFirmare = (esisteFilePrincipale(documento) && documentoNonFirmato(documento) && !documento.protocollato && !movimentoArrivo(documento)
                && utenteHaPrivilegioFirma())
        return daFirmare
    }

    @Action(tipo = TipoAzione.CONDIZIONE,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "L'utente può predisporre il protocollo?",
            descrizione = "Indica se l'utente ha la possibilità di predisporre il protocollo")
    boolean utentePuoPredisporre(Protocollo documento) {
        esisteDocumento(documento) && utenteHaPrivilegioProtocollazione()
    }

    private boolean movimentoArrivo(Protocollo documento) {
        def res = documento.movimento == Protocollo.MOVIMENTO_ARRIVO
        res
    }

    private boolean documentoNonFirmato(Protocollo documento) {
        def res = documento.statoFirma != StatoFirma.FIRMATO
        res
    }

    private boolean utenteHaPrivilegioFirma() {
        utenteHaPrivilegio(PrivilegioUtente.FIRMA)
    }

    private boolean utenteHaPrivilegioProtocollazione() {
        utenteHaPrivilegio(PrivilegioUtente.REDATTORE_PROTOCOLLO)
    }

    private boolean utenteHaPrivilegio(String privilegio) {
        List res = privilegioUtenteService.getPrivilegi(springSecurityService.currentUser, privilegio)
        return res
    }

    //TODO action invio mail annullamento per protocolli ricevuti tramite interopertabilità. Usare i nuovi WS
//    @Action(tipo = TipoAzione.AUTOMATICA,
//            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
//            nome = "Invia Mail Annullamento",
//            descrizione = "Invia una mail per ogni protocollo annullato se questo è stato ricevuto tramite interopoerabilità")
//    void inviaMailAnnullamento(Protocollo documento) {
//        annullamentoService.inviaMailAnnullamento(documento)
//    }
}
