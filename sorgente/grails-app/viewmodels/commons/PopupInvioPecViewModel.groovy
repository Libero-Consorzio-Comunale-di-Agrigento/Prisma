package commons

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumentoService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggio
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.documenti.mail.MailDTO
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloIntegrazioneService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

import javax.mail.internet.AddressException
import javax.mail.internet.InternetAddress

@VariableResolver(DelegatingVariableResolver)
class PopupInvioPecViewModel {

    Window self

    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private ProtocolloFileDownloader fileDownloader
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private MailService mailService
    @WireVariable
    private FileDocumentoService fileDocumentoService
    @WireVariable
    private SchemaProtocolloIntegrazioneService schemaProtocolloIntegrazioneService

    ProtocolloDTO protocollo
    String testo
    String oggetto
    String tipoConsegna
    String tipiConsegna
    List<String> tipiConsegnaList

    List<CorrispondenteDTO> destinatari
    List<AllegatoDTO> allegati = new ArrayList<AllegatoDTO>()
    List<CorrispondenteDTO> destinatariSelezionati
    List<FileDocumentoDTO> allegatiSelezionati = new ArrayList<FileDocumentoDTO>()

    List<MailDTO> mittenti
    MailDTO mittente

    boolean invioSingolo = false
    boolean segnaturaCompleta = true
    boolean segnatura = true
    boolean isAbilitataSceltaAllegati = false
    boolean isImpresaInUnGiorno = false

    boolean isInterpro = false

    static Window apriPopup(ProtocolloDTO protocollo) {
        Window w = (Window) Executions.createComponents("/commons/popupInvioPec.zul", null, [protocollo: protocollo])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") ProtocolloDTO protocollo) {
        this.self = w
        tipoConsegna = ImpostazioniProtocollo.TIPO_CONSEGNA.getValore() ?: ImpostazioniProtocollo.TIPO_CONSEGNA.valore
        tipiConsegna = ImpostazioniProtocollo.TIPI_CONSEGNA.getValore() ?: ImpostazioniProtocollo.TIPO_CONSEGNA.valore
        tipiConsegnaList = tipiConsegna?.split("#")

        Protocollo p = protocollo.domainObject
        protocolloService.validaFileObbligatorio(p)

        isImpresaInUnGiorno = schemaProtocolloIntegrazioneService.isSchemaImpresaInUnGiorno(p.schemaProtocollo)

        oggetto = mailService.getOggettoMailProtocollo(p)
        isAbilitataSceltaAllegati = ImpostazioniProtocollo.SCELTA_ALLEGATI_IN_INVIO.isAbilitato()

        isInterpro = ImpostazioniProtocollo.IS_ENTE_INTERPRO.abilitato

        this.protocollo = protocollo


        mittenti = mailService.ricercaMittenti(protocollo.id, springSecurityService.principal.id)
        if (mittenti.size() > 0) {
            mittente = mittenti.get(0)
            segnaturaCompleta = mittente.segnaturaCompleta
            segnatura = mittente.segnatura
        }

        def allegatiLista = p.getAllegati()
        AllegatoDTO allegatoPrincipale = new AllegatoDTO(descrizione: "Documento Principale")
        if (p.getFilePrincipale()) {
            allegatoPrincipale.addToFileDocumenti(p.getFilePrincipale().toDTO())
            allegati.add(allegatoPrincipale)
        }
        allegati.addAll(allegatiLista.toDTO(["fileDocumenti"]))

        for (AllegatoDTO a : allegati) {
            List<FileDocumentoDTO> fds = new ArrayList<FileDocumentoDTO>()
            for (FileDocumentoDTO fd : a.fileDocumenti) {
                if (fd.codice != FileDocumento.CODICE_FILE_ORIGINALE) {

                    fds.add(fd)
                }
            }
            a.fileDocumenti = fds
            allegatiSelezionati.addAll(fds)
        }

        destinatari = mailService.getDestinatariMailProtocollo(p)
        destinatariSelezionati = new ArrayList<CorrispondenteDTO>()
    }

    @Command
    void onDownloadFileAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("fileAllegato") value) {
        def doc = value.documento
        if (doc == null) {
            doc = protocollo
        }
        fileDownloader.downloadFileAllegato(doc, FileDocumento.get(value.id), false)
    }

    private boolean onInviaMail() {
        List<FileDocumentoDTO> allegatiPrincipali = allegatiSelezionati?.findAll {
            it.codice == it.finmatica.gestionedocumenti.documenti.FileDocumento.CODICE_FILE_PRINCIPALE
        }

        if (mittente == null) {
            Clients.showNotification("Scegliere il mittente", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
            return false
        }

        /**
         * Devono essere valorizzati o il testo o almeno un allegato
         */
        if (StringUtils.isEmpty(testo) && (allegatiSelezionati == null || allegatiSelezionati.size() == 0)) {
            Clients.showNotification("Volorizzare il testo della Mail o allegare almeno un file", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
            return false
        }

        if (destinatariSelezionati == null || destinatariSelezionati.size() == 0) {
            Clients.showNotification("Scegliere almeno un destinatario", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
            return false
        }

        for (CorrispondenteDTO d : destinatariSelezionati) {
            if (d.email == null || d.email == "") {
                Clients.showNotification("Esiste un destinatario senza mail", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
                return false
            }

            //devo anche effettuare il controllo di validità della mail
            InternetAddress ia;

            try {
                ia = new InternetAddress(d.email);
                ia.validate();
            } catch (AddressException e) {
                Clients.showNotification("La mail " + d.email + " non è una indirizzo di posta elettronica valido", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
                return false
            }
        }

        if (ImpostazioniProtocollo.BLOCCA_MAIL_SOLO_CC.abilitato) {
            // #29160 non deve essere possibile spedire una mail con invio singolo se esiste anche un solo destinatario per conoscenza selezionato
            if (!invioSingolo) {
                boolean soloCC = true
                for (CorrispondenteDTO corr : destinatariSelezionati) {
                    if (!corr.conoscenza) {
                        soloCC = false
                        break
                    }
                }

                if (soloCC) {
                    Clients.showNotification("Tutti i destinatari sono per Conoscenza. Impossibile procedere con l'invio", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
                    return false
                }
            }

            if (invioSingolo) {
                boolean esisteCC = false
                for (CorrispondenteDTO corr : destinatariSelezionati) {
                    if (corr.conoscenza) {
                        esisteCC = true
                        break
                    }
                }

                if (esisteCC) {
                    Clients.showNotification("Occorre selezionare solo destinatari diretti. Impossibile procedere con l'invio", Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
                    return false
                }
            }
        }

        String listaAllegatiConFirmaNonVerificata
        listaAllegatiConFirmaNonVerificata = controlloAllegatiFirmati(allegatiSelezionati)
        if (listaAllegatiConFirmaNonVerificata != "") {
            Clients.showNotification("Alcuni file allegati al protocollo hanno una firma non valida.\n" +
                    "E' necessario sostituire i file o forzarne la validità prima di procedere all'invio.\n"+
                    "Lista dei file con firma non valida:\n"+listaAllegatiConFirmaNonVerificata,
                    Clients.NOTIFICATION_TYPE_ERROR, self, "before_center", 5000, true)
            return false
        }

        mailService.invioPec(protocollo, mittente, testo, oggetto, invioSingolo, segnatura, segnaturaCompleta, allegatiSelezionati, destinatariSelezionati, tipoConsegna)

        return true
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onInviaEChiudi() {
        if (onInviaMail()) {
            Messagebox.show("Mail passata correttamente al sistema di spedizione. Verificare l'esito dell'invio consultando le ricevute PEC", "", Messagebox.OK, Messagebox.INFORMATION, new org.zkoss.zk.ui.event.EventListener() {
                void onEvent(Event evt) throws InterruptedException {
                    if (evt.getName().equals("onOK")) {
                        Events.postEvent(Events.ON_CLOSE, self, null)
                    }
                }
            })
        }
    }

    @Command
    void onInvia() {
        if (onInviaMail()) {
            Messagebox.show("Mail passata correttamente al sistema di spedizione. Verificare l'esito dell'invio consultando le ricevute PEC", "", Messagebox.OK, Messagebox.INFORMATION)
            destinatari = protocollo.domainObject.corrispondenti.toDTO(["messaggi"]).toList()
            destinatari = destinatari.sort { it.id }
            destinatariSelezionati = new ArrayList<CorrispondenteDTO>()
            BindUtils.postNotifyChange(null, null, this, "destinatari")
            BindUtils.postNotifyChange(null, null, this, "destinatariSelezionati")
        }
    }

    private String controlloAllegatiFirmati(List<FileDocumentoDTO> allegati) {
        String listaAllegatiConFirmaNonVerificata = ""
        for (allegato in allegati) {
            FileDocumento fileDocumento = FileDocumento.findById(allegato.id)

            if (fileDocumento.firmato && fileDocumento.esitoVerifica == null) {
                fileDocumentoService.aggiornaVerificaFirma(fileDocumento)
            }

            if (fileDocumento.esitoVerifica == "N" && fileDocumento.firmato) {
                if (listaAllegatiConFirmaNonVerificata != "") {
                    listaAllegatiConFirmaNonVerificata += "\n"
                }
                listaAllegatiConFirmaNonVerificata += fileDocumento.nome
            }
        }

        return listaAllegatiConFirmaNonVerificata
    }
}
