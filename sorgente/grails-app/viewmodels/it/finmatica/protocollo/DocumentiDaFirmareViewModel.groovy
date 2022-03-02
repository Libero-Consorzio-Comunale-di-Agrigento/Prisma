package it.finmatica.protocollo

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.deleghe.DelegaService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.StatoFirma
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.integrazioni.firma.GestioneDocumentiFirmaService
import it.finmatica.gestionedocumenti.utils.ExportService
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.DocumentoStepDTOService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.SortEvent
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Filedownload
import org.zkoss.zul.Listbox
import org.zkoss.zul.Listitem
import org.zkoss.zul.Menupopup
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class DocumentiDaFirmareViewModel {

    // services
    @WireVariable
    private GestioneDocumentiFirmaService gestioneDocumentiFirmaService
    @WireVariable
    private DocumentoStepDTOService documentoStepDTOService
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private ExportService exportService
    @WireVariable
    private DelegaService delegaService
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    AllegatoProtocolloService allegatoProtocolloService

    // componenti
    Window self
    @Wire("#listaDocumentiDaFirmare")
    Listbox listbox

    @Wire("#mpAllegatiDaFirmare")
    Menupopup popupAllegati

    // dati
    def lista
    def selected
    def selectedItems
    def listaAllegati

    So4UnitaPubbDTO unitaProtocollante

    def soggettoDelegante
    def listaSoggetti
    int selectedIndexSoggetti = -1

    // stato
    boolean abilitaFirma = false
    boolean abilitaSblocca = false
    def tipoOggetto

    def gruppiOggetto

    // ricerca
    String testoCerca = ""

    // paginazione
    int activePage = 0
    int pageSize = 30
    int totalSize = 100

    def orderMap = [anno: 'desc', numero: 'desc']

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w

        gruppiOggetto = new ArrayList()
        def schemiProtocollo = delegaService.getTipologie(springSecurityService.currentUser, null)

        if (schemiProtocollo != null && schemiProtocollo.size() > 0) {
            gruppiOggetto = SchemaProtocollo.createCriteria().list() {
                inList("codice", schemiProtocollo)
                order("descrizione")
            }?.toDTO()
        }

        gruppiOggetto.add(0, new SchemaProtocolloDTO(codice: "", descrizione: ""))
        tipoOggetto = gruppiOggetto[0]

        caricaListaSoggetti()
        caricaLista()
    }

    @AfterCompose
    void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false)
    }

    @NotifyChange(["abilitaFirma", "abilitaSblocca"])
    @Command
    void onSelectDocumento() {
        abilitaFirma = (tipoOggettoDocumentiSelezionati(false) != null)
        abilitaSblocca = (tipoOggettoDocumentiSelezionati(true) != null)
    }

    private String tipoOggettoDocumentiSelezionati(boolean firmatiDaSbloccare) {
        String firstTipoOggetto = null
        for (Listitem item : listbox.getSelectedItems()) {
            String tipoOggetto = item.value.tipoOggetto

            if (firstTipoOggetto == null) {
                firstTipoOggetto = tipoOggetto
            }

            if (tipoOggetto != firstTipoOggetto) {
                return null
            }

            if (firmatiDaSbloccare && item.value.statoFirma != StatoFirma.FIRMATO_DA_SBLOCCARE.toString()) {
                return null
            } else if (!firmatiDaSbloccare && item.value.statoFirma == StatoFirma.FIRMATO_DA_SBLOCCARE.toString()) {
                return null
            }
        }

        return firstTipoOggetto
    }

    @Command
    void onFirmaDocumenti() {
        activePage = 0

        // giusto per essere sicuri di aver cliccato bene:
        String tipoOggetto = tipoOggettoDocumentiSelezionati(false)

        if (tipoOggetto == null) {
            Messagebox.show("Attenzione: non è possibile firmare documenti di tipo diverso. Selezionare documenti omogenei")
            return
        }

        List<Protocollo> listDocumenti = protocolloService.findAllByIdInList(listbox.getSelectedItems()*.value.idDocumento)

        String urlFirma = gestioneDocumentiFirmaService.multiFirma(listDocumenti)
        Window w = Executions.createComponents("/commons/popupFirma.zul", self, [urlPopupFirma: urlFirma])
        w.onClose { event ->
            caricaLista()
        }
        w.doModal()
    }

    @Command
    void onSbloccaDocumenti() {
        activePage = 0

        // giusto per essere sicuri di aver cliccato bene:
        String tipoOggetto = tipoOggettoDocumentiSelezionati(true)

        if (tipoOggetto == null) {
            Messagebox.show("Attenzione: non è possibile sbloccare documenti di tipo diverso. Selezionare documenti omogenei")
            return
        }

        List<Protocollo> listDocumenti = protocolloRepository.findAllByIdInList(listbox.getSelectedItems()*.value.idDocumento)
        if (soggettoDelegante?.domainObject?.id != null) {
            gestioneDocumentiFirmaService.sbloccaDocumentiFirmati(listDocumenti, soggettoDelegante.domainObject)
        } else {
            gestioneDocumentiFirmaService.sbloccaDocumentiFirmati(listDocumenti, springSecurityService.currentUser)
        }


        caricaLista()
    }

    @NotifyChange("selectedRecord")
    @Command
    void onItemDoubleClick(@ContextParam(ContextType.COMPONENT) Listitem l) {
        selected = l.value
        onApriDocumento()
    }

    @Command
    void onApriDocumento() {
        ProtocolloViewModel.apriPopup((long) selected.idDocumento, true).addEventListener(Events.ON_CLOSE) {
            caricaLista()
        }
    }

    /*
     * Metodi per la ricerca
     */

    @Command
    void onRefresh() {
        caricaLista()
        selected = null
    }

    private void caricaListaSoggetti() {
        listaSoggetti = []

        listaSoggetti = delegaService.getDeleganti(springSecurityService.currentUser)?.toDTO()

        listaSoggetti.add(0, (new Ad4Utente(id: "", nominativo: "")).toDTO())
        soggettoDelegante = listaSoggetti[0]
        selectedIndexSoggetti = 0
    }

    @Command
    void onCerca() {
        activePage = 0
        caricaLista()
    }

    private void caricaLista() {
        if (soggettoDelegante.nominativo == null || soggettoDelegante.nominativo == "") {
            tipoOggetto = new SchemaProtocolloDTO(codice: "", descrizione: "")
        }

        def documenti = documentoStepDTOService.inCarico(testoCerca, [Protocollo.CATEGORIA_LETTERA, Protocollo.CATEGORIA_PROVVEDIMENTO], null, tipoOggetto, soggettoDelegante, [StatoFirma.DA_FIRMARE, StatoFirma.IN_FIRMA, StatoFirma.FIRMATO_DA_SBLOCCARE], pageSize, activePage, orderMap, true, false)
        lista = documenti.result
        totalSize = documenti.total

        BindUtils.postNotifyChange(null, null, this, "selected")
        BindUtils.postNotifyChange(null, null, this, "tipoOggetto")
        BindUtils.postNotifyChange(null, null, this, "lista")
        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
    }

    @NotifyChange("listaAllegati")
    @Command
    void onCaricaListaAllegati(@BindingParam("protocollo") id, @ContextParam(ContextType.COMPONENT) Component component) {
        listaAllegati = []
        Protocollo protocollo = protocolloService.findById(id)
        FileDocumento principale = protocollo?.filePrincipale
        if (principale) {
            listaAllegati.add([idAllegato: principale.idFileEsterno, nomeAllegato: principale.nome])
        }
        List<FileDocumento> allegatiProtocollo = allegatoProtocolloService.getFileDocumentiAllegati(protocollo)
        for (file in allegatiProtocollo) {
            listaAllegati << [idAllegato: file.idFileEsterno, nomeAllegato: file.nome]
        }
        popupAllegati.open(component)
    }

    boolean visibileAllegati(@BindingParam("id") id) {
        return allegatoProtocolloService.presenzaAllegati(id)
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileAllegato") fileAllegato) {
        File file = allegatoProtocolloService.getFile(fileAllegato.idAllegato)
        Filedownload.save(file.getInputStream(), file.getContentType(), file.getNome())
    }

    @Command
    void onEseguiOrdinamento(@BindingParam("campi") String campi, @ContextParam(ContextType.TRIGGER_EVENT) SortEvent event) {
        for (String campo : campi?.split(",")?.reverse()) {
            orderMap.remove(campo)
            orderMap = [(campo): event?.isAscending() ? 'asc' : 'desc'] + orderMap
        }
        onCerca()
    }

    @Command
    void onCambiaSoggetto() {
        onCerca()
    }

    @Command
    void onExportExcel() {
        if (totalSize > Impostazioni.ESPORTAZIONE_NUMERO_MASSIMO.valoreInt) {
            Messagebox.show("Attenzione: il numero dei documenti da esportare supera il massimo consentito.", "Esportazione interrotta.", Messagebox.OK, Messagebox.EXCLAMATION, null)
            return
        }

        try {
            def documenti = documentoStepDTOService.inCarico(testoCerca, [Protocollo.CATEGORIA_LETTERA, Protocollo.CATEGORIA_PROVVEDIMENTO], null, tipoOggetto, soggettoDelegante, [StatoFirma.DA_FIRMARE, StatoFirma.IN_FIRMA, StatoFirma.FIRMATO_DA_SBLOCCARE], pageSize, activePage, orderMap, true, false)
            def export = documenti.result.collect {
                [idDocumento           : it.idDocumento
                 , stato               : it.stato
                 , statoFirma          : it.statoFirma
                 , stepTitolo          : it.stepTitolo
                 , tipoOggetto         : it.tipoOggetto
                 , tipoRegistro        : it.tipoRegistro
                 , riservato           : it.riservato
                 , oggetto             : it.oggetto
                 , anno                : it.anno
                 , numero              : it.numero
                 , titoloTipologia     : it.titoloTipologia
                 , descrizioneTipologia: it.descrizioneTipologia
                 , lastUpdated         : it.lastUpdated
                ]
            }
            exportService.downloadExcel(documenti.exportOptions, export)
        } finally {
            caricaLista()
        }
    }
}
