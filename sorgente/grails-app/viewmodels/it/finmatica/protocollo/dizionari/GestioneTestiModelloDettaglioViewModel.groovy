package it.finmatica.protocollo.dizionari

import groovy.xml.StreamingMarkupBuilder
import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.afc.AfcAbstractRecord
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionetesti.GestioneTestiModelloCompetenzaDTOService
import it.finmatica.gestionetesti.GestioneTestiModelloDTOService
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.gestionetesti.competenze.GestioneTestiModelloCompetenza
import it.finmatica.gestionetesti.competenze.GestioneTestiModelloCompetenzaDTO
import it.finmatica.gestionetesti.reporter.CorrettoreTesto
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.gestionetesti.reporter.GestioneTestiModelloDTO
import it.finmatica.gestionetesti.reporter.GestioneTestiTipoModello
import it.finmatica.gestionetesti.reporter.GestioneTestiTipoModelloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.apache.commons.io.IOUtils
import org.apache.commons.lang.StringUtils
import org.hibernate.FetchMode
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.util.media.Media
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Filedownload
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class GestioneTestiModelloDettaglioViewModel extends AfcAbstractRecord {

    // services
    @WireVariable
    private GestioneTestiService gestioneTestiService
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private GestioneTestiModelloDTOService gestioneTestiModelloDTOService
    @WireVariable
    private GestioneTestiModelloCompetenzaDTOService gestioneTestiModelloCompetenzaDTOService

    GestioneTestiModelloDTO selectedRecord
    boolean fileGiaInserito

    List<GestioneTestiTipoModelloDTO> listaGestioneTestiTipoModelloDTO
    List<GestioneTestiModelloCompetenzaDTO> listaGestioneTestiModelloCompetenza

    def campiDisponibili

    @NotifyChange(["selectedRecord", "fileGiaInserito"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") Long id) {
        this.self = w
        fileGiaInserito = false

        if (id != null) {
            selectedRecord = caricaGestioneTestiModelloDto(id)
            aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
            aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
            caricaListaGestioneTestiModelloCompetenza()
        } else {
            selectedRecord = new GestioneTestiModelloDTO(valido: true)
        }

        caricaListaGestioneTestiTipoModello()
        caricaCampiDisponibili()
    }

    @Command
    void onSelectTipoModello() {
        caricaCampiDisponibili()
    }

    private void caricaCampiDisponibili() {
        GestioneTestiTipoModello tipoModello = selectedRecord.tipoModello?.domainObject
        campiDisponibili = []
        if (tipoModello == null) {
            BindUtils.postNotifyChange(null, null, this, "campiDisponibili")
            return
        }
        def xml = new XmlSlurper().parseText(new String(tipoModello.query))

        // per ogni query, prendo l'id e il suo alias:
        xml.queryes.'**'.findAll { it.name() == 'query' }.each { q ->
            def campi = q.@help_field_aliases.text().split(",")*.trim()

            campiDisponibili << [nome         : q.@id.text()
                                 , descrizione: q.@help_descrizione.text()
                                 , istruzione : "[#list documentRoot.${q.@id.text()} as ${q.@help_query_alias.text()}]\n[/#list]"]

            def campiQuery = []
            // per ogni campo, cerco il corrispondente e lo metto nei campi possibili:
            for (String campo : campi) {
                def c = xml.definitions.metaDato.find { it.nomeSimbolico.text() == campo }
                if (c != null) {
                    campiQuery << [nome         : c.nomeSimbolico.text()
                                   , descrizione: c.descrizione.text()
                                   , istruzione : "\${documentRoot." + q.@id.text() + "." + c.nomeSimbolico.text() + "}\n\${" + q.@help_query_alias.text() + "." + c.nomeSimbolico.text() + "}"]
                }
            }
            campiDisponibili.addAll(campiQuery.sort { it.nome })
        }

        BindUtils.postNotifyChange(null, null, this, "campiDisponibili")
    }

    private GestioneTestiModelloDTO caricaGestioneTestiModelloDto(Long id) {
        GestioneTestiModello gestioneTestiModello = GestioneTestiModello.createCriteria().get {
            eq("id", id)
        }
        GestioneTestiModelloDTO result = gestioneTestiModello.toDTO()
        if (result.fileTemplate != null) {
            fileGiaInserito = true
            result.fileTemplate = null
        } else {
            fileGiaInserito = false
        }
        return result
    }

    private void caricaListaGestioneTestiTipoModello() {

        listaGestioneTestiTipoModelloDTO = GestioneTestiTipoModello.createCriteria().list() {
            eq("valido", true)
            order("codice", "asc")
        }.toDTO()
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica", "fileGiaInserito"])
    @Command
    void onUpload(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        Media media = event.media
        selectedRecord = gestioneTestiModelloDTOService.salva(selectedRecord, media.byteData, media.name)
        aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
        aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)

        if (fileGiaInserito == false) {
            aggiungiCompetenzaDefault(selectedRecord)
        }
        fileGiaInserito = true
    }

    @Command
    void onDownload(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        Filedownload.save(gestioneTestiModelloDTOService.getFileAllegato(selectedRecord.id), selectedRecord.contentType, selectedRecord.nomeFile)
    }

    // metodi che gestiscono l'assegnazione delle competenze ai modelli testo

    private void caricaListaGestioneTestiModelloCompetenza() {
        List<GestioneTestiModelloCompetenza> lista = GestioneTestiModelloCompetenza.createCriteria().list() {
            eq("gestioneTestiModello.id", selectedRecord.id)
            fetchMode("utenteAd4", FetchMode.JOIN)
            fetchMode("ruoloAd4", FetchMode.JOIN)
            fetchMode("unitaSo4", FetchMode.JOIN)
        }
        listaGestioneTestiModelloCompetenza = lista.toDTO()
        BindUtils.postNotifyChange(null, null, this, "listaGestioneTestiModelloCompetenza")
    }

    @Command
    void onEliminaGestioneTestiModelloCompetenza(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("gestioneTestiModelloCompetenza") GestioneTestiModelloCompetenzaDTO tipoProtCompetenza) {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        Messagebox.show("Eliminare la competenza selezionata?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
                new org.zkoss.zk.ui.event.EventListener() {
                    void onEvent(Event e) {
                        if (Messagebox.ON_OK.equals(e.getName())) {
                            gestioneTestiModelloCompetenzaDTOService.elimina(tipoProtCompetenza)
                            GestioneTestiModelloDettaglioViewModel.this.caricaListaGestioneTestiModelloCompetenza()
                        }
                    }
                }
        )
    }

    @Command
    void onAggiungiGestioneTestiModelloCompetenza() {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        Window w = Executions.createComponents("/commons/popupCompetenzaDettaglio.zul", self, [documento: selectedRecord, tipoDocumento: "modelloCompetenza"])
        w.onClose {
            caricaListaGestioneTestiModelloCompetenza()
        }
        w.doModal()
    }

    private void aggiungiCompetenzaDefault(GestioneTestiModelloDTO gestioneTestiModello) {
        GestioneTestiModelloCompetenzaDTO defaultCompetenza = new GestioneTestiModelloCompetenzaDTO()
        String codiceRuolo = ImpostazioniProtocollo.RUOLO_ACCESSO_APPLICATIVO.valore
        Ad4Ruolo ruolo = Ad4Ruolo.createCriteria().get() {
            eq("ruolo", codiceRuolo)
        }
        if (ruolo == null) {
            Clients.showNotification("Ruolo di accesso applicativo non censito:" + codiceRuolo, Clients.NOTIFICATION_TYPE_WARNING, self, "before_center", 3000, true)
        } else {
            defaultCompetenza.ruoloAd4 = ruolo.toDTO()
        }
        defaultCompetenza.descrizione = "Visibile a tutti"
        defaultCompetenza.gestioneTestiModello = gestioneTestiModello
        defaultCompetenza.lettura = true
        gestioneTestiModelloCompetenzaDTOService.salva(defaultCompetenza)
        caricaListaGestioneTestiModelloCompetenza()
    }

    // Estendo i metodi abstract di AfcAbstractRecord

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalva() {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        selectedRecord = gestioneTestiModelloDTOService.salva(selectedRecord)
        aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
        aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalvaChiudi() {
        onSalva()
        onChiudi()
    }

    @Command
    void onSettaValido(@BindingParam("valido") boolean valido) {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        // se voglio disattivare il modello testo, prima verifico che non sia usato da nessuna tipologia di determina/delibera ancora valida.
        if (selectedRecord.valido && valido == false) {
            List<TipoProtocollo> tipologie = TipoProtocollo.inUsoPerModelloTesto(selectedRecord.id).list()

            if (tipologie?.size() > 0) {
                Clients.showNotification("Non è possibile disattivare il modello testo perché è usato da altre tipologie ancora attive:\n" +
                        (tipologie.descrizione.join("\n")), Clients.NOTIFICATION_TYPE_WARNING, self, "before_center", tipologie.size() * 3000, true)
                return
            }
        }

        Messagebox.show(Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTesto", [valido ? "valido" : "non valido"].toArray()), Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTitolo"),
                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
                new org.zkoss.zk.ui.event.EventListener() {
                    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
                    void onEvent(Event e) {
                        if (Messagebox.ON_OK.equals(e.getName())) {
                            GestioneTestiModelloDettaglioViewModel.this.selectedRecord.valido = valido
                            onSalva()
                            BindUtils.postNotifyChange(null, null, GestioneTestiModelloDettaglioViewModel.this, "selectedRecord")
                            BindUtils.postNotifyChange(null, null, GestioneTestiModelloDettaglioViewModel.this, "datiCreazione")
                            BindUtils.postNotifyChange(null, null, GestioneTestiModelloDettaglioViewModel.this, "datiModifica")
                        }
                    }
                }
        )
    }

    @Command
    void onCorreggiModello() {
        GestioneTestiModello m = selectedRecord.domainObject
        if (m?.tipoModello == null) {
            Clients.showNotification("Operazione non possibile. Il tipo modello deve essere prima creato.", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 3000, true)
            return
        }
        CorrettoreTesto correttore = new CorrettoreTesto()
        InputStream is = correttore.correggiTesto(new ByteArrayInputStream(m.fileTemplate), m.tipo)
        m.fileTemplate = IOUtils.toByteArray(is)
        m.save()

        Clients.showNotification("Il modello è stato corretto, cliccare Prova Modello per verificarlo.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    @Command
    void onProvaModello() {

        GestioneTestiModello m = selectedRecord.domainObject
        String staticData = staticData(m)
        InputStream testo = gestioneTestiService.stampaUnione(new ByteArrayInputStream(m.fileTemplate), staticData, m.tipo)
        Filedownload.save(testo, m.contentType, "${m.nome}.${m.tipo}")
    }

    @Command
    onProvaModelloPdf() {

        GestioneTestiModello m = selectedRecord.domainObject
        String staticData = staticData(m)
        InputStream testo = gestioneTestiService.stampaUnione(new ByteArrayInputStream(m.fileTemplate), staticData, GestioneTestiService.FORMATO_PDF)
        Filedownload.save(testo, GestioneTestiService.getContentType(GestioneTestiService.FORMATO_PDF), "${m.nome}.${GestioneTestiService.FORMATO_PDF}");
    }

    private String staticData(GestioneTestiModello m) {

        if (m?.tipoModello == null) {
            Clients.showNotification("Operazione non possibile. Il tipo modello deve essere prima creato.", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 3000, true)
            return
        }
        String query = new String(m.tipoModello.query)
        def xml = new XmlSlurper().parseText(query)
        def outputBuilder = new StreamingMarkupBuilder()
        if (xml.testStaticData.documentRoot.text() == "") {
            Clients.showNotification("Non è possibile testare il modello perché nell'XML della query non ci sono i dati di prova nel tag <testStaticData>", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 3000, true)
            return
        }

        return outputBuilder.bind { mkp.yield xml.testStaticData.documentRoot }
    }


    @Command
    onDownloadOrigineDati() {
        GestioneTestiModello m = selectedRecord.domainObject;
        if (m?.tipoModello == null) {
            Clients.showNotification("Operazione non possibile. Il tipo modello deve essere prima creato.", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 3000, true)
            return
        }
        GestioneTestiTipoModello tipoModello = selectedRecord.tipoModello?.domainObject
        String origineDati = gestioneTestiService.creaOrigineDati(new String(tipoModello.query))
        Filedownload.save(origineDati.getBytes("UTF-8"), "text/plain", tipoModello.codice + ".txt")
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onDuplica() {

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        selectedRecord = gestioneTestiModelloDTOService.duplica(selectedRecord)
        Clients.showNotification("Tipologia duplicata.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    Collection<String> validaMaschera() {
        Collection<String> messaggi = []

        boolean dizProtocolloVisible = Utils.isUtenteAmministratore() ||
                springSecurityService.principal.hasRuolo(ImpostazioniProtocollo.RUOLO_MODELLI_TESTO.valore) ||
                springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_PROTOCOLLO.valore)

        if (!dizProtocolloVisible) {
            messaggi << "L'utente ${springSecurityService.principal.username} non puo' accedere a quest'area"
        }

        return messaggi
    }
}