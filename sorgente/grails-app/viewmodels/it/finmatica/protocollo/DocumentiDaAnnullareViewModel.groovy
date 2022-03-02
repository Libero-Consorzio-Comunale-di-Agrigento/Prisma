package it.finmatica.protocollo

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.utils.ExportService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.AnnullamentoService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.ProvvedimentoViewModel
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.smartdoc.api.struct.File
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
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
class DocumentiDaAnnullareViewModel {

    // services
    @WireVariable
    private ExportService exportService
    @WireVariable
    private AnnullamentoService annullamentoService
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    AllegatoProtocolloService allegatoProtocolloService

    // componenti
    Window self
    @Wire("#listaDocumentiDaAnnullare")
    Listbox listbox

    @Wire("#mpAllegatiAnnull")
    Menupopup popupAllegati

    // dati
    Page<ProtocolloDTO> lista
    ProtocolloDTO selected
    List<Documento> selectedItems
    List<AllegatoDTO> listaAllegati

    // stato
    boolean creaProvvedimento = false

    // ricerca
    String testoCerca = ""

    HashMap<String, String> orderMap = ['anno': 'desc', 'numero': 'desc']

    // paginazione
    int activePage = 0
    int pageSize = 30
    int totalSize = 100

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        caricaLista()
    }

    @AfterCompose
    void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false)
    }

    @NotifyChange(["abilitaAnnullamento"])
    @Command
    void onSelectDocumento() {
        creaProvvedimento = Utils.isUtenteAmministratore() || privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO, springSecurityService.currentUser)
        if (creaProvvedimento) {
            creaProvvedimento = tipoOggettoDocumentiSelezionati()
        }
    }

    private boolean tipoOggettoDocumentiSelezionati() {
        return listbox.getSelectedItems().size() > 0
    }

    @Command
    void onCreaProvvedimento() {
        activePage = 0

        List<Documento> listDocumenti = new ArrayList<Documento>()

        for (Listitem item : listbox.getSelectedItems()) {
            listDocumenti.add(Documento.findAllById(item.value.id))
        }

        ProvvedimentoViewModel.apriPopup(Protocollo.CATEGORIA_PROVVEDIMENTO, listDocumenti).addEventListener(Events.ON_CLOSE) {
            caricaLista()
        }
    }

    @NotifyChange("selectedRecord")
    @Command
    void onItemDoubleClick(@ContextParam(ContextType.COMPONENT) Listitem l) {
        selected = l.value
        onApriDocumento()
    }

    @Command
    void onApriDocumento() {
        ProtocolloViewModel.apriPopup((long) selected.id, true).addEventListener(Events.ON_CLOSE) {
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


    @Command
    void onCerca() {
        activePage = 0
        caricaLista()
    }

    private void caricaLista() {

        List<Protocollo> protocolliDaAnnullare = annullamentoService.caricaProtocolliDaAnnnullare(testoCerca, orderMap)

        //FIXME Eseguo la paginazione dopo aver filtrato i risultati (vedere se è possibile generalizzare questa parte)
        PageRequest pageable = new PageRequest(activePage, pageSize);
        int max = (pageSize * (activePage + 1) > protocolliDaAnnullare.size()) ? protocolliDaAnnullare.size() : pageSize * (activePage + 1);
        List<ProtocolloDTO> protocolliDaAnnullareFinalDTO = protocolliDaAnnullare.toDTO("tipoProtocollo.commento")
        lista = new PageImpl<ProtocolloDTO>(protocolliDaAnnullareFinalDTO.subList(activePage * pageSize, max), pageable, protocolliDaAnnullareFinalDTO.size())
        totalSize = protocolliDaAnnullareFinalDTO.size()

        BindUtils.postNotifyChange(null, null, this, "selected")
        BindUtils.postNotifyChange(null, null, this, "lista")
        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
    }

    @Command
    void onEseguiOrdinamento(@BindingParam("campi") String campi, @ContextParam(ContextType.TRIGGER_EVENT) SortEvent event) {
        for (String campo : campi?.split(",")?.reverse()) {
            orderMap.remove(campo)
            orderMap = [(campo): event?.isAscending() ? 'asc' : 'desc'] + orderMap
        }
        onCerca()
    }

    @NotifyChange("listaAllegati")
    @Command
    void onCaricaListaAllegati(@BindingParam("protocollo") ProtocolloDTO documento, @ContextParam(ContextType.COMPONENT) Component component) {
        listaAllegati = []
        Protocollo p = documento.domainObject
        FileDocumento principale = p?.filePrincipale
        if (principale) {
            listaAllegati.add([idAllegato: principale.idFileEsterno, nomeAllegato: principale.nome])
        }
        List<FileDocumento> allegatiProtocollo = allegatoProtocolloService.getFileDocumentiAllegati(p)
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
    void onExportExcel() {
        if (totalSize > Impostazioni.ESPORTAZIONE_NUMERO_MASSIMO.valoreInt) {
            Messagebox.show("Attenzione: il numero dei documenti da esportare supera il massimo consentito.", "Esportazione interrotta.", Messagebox.OK, Messagebox.EXCLAMATION, null)
            return
        }

        try {

            List<Protocollo> protocolliDaAnnullare = annullamentoService.caricaProtocolliDaAnnnullare(testoCerca, orderMap)
            LinkedHashMap<String, LinkedHashMap<String, Serializable>> exportOptions = getExportOptions()
            List<LinkedHashMap<String, Object>> export = getExportObject(protocolliDaAnnullare)

            exportService.downloadExcel(exportOptions, export)

        } finally {
            caricaLista()
        }
    }

    /**
     * Metodo che mappa le property dell'oggetto da esportare
     *
     * @param protocolliDaAnnullare
     * @return
     */
    private List<LinkedHashMap<String, Object>> getExportObject(List<Protocollo> protocolliDaAnnullare) {

        List<LinkedHashMap<String, Object>> export = protocolliDaAnnullare.collect {
            [idDocumento           : it.idDocumento
             , stato               : it.stato
             , statoFirma          : it.statoFirma
             , tipoOggetto         : it.tipoOggetto
             , tipoRegistro        : it.tipoRegistro
             , riservato           : it.riservato
             , oggetto             : it.oggetto
             , anno                : it.anno
             , numero              : it.numero
             , titoloTipologia     : it.tipoProtocollo.commento
             , descrizioneTipologia: it.tipoProtocollo.commento
             , lastUpdated         : it.lastUpdated
            ]
        }
        export
    }

    /**
     * Metodo che definisce, in una mappa, le proprietà di esportazione in excel
     *
     * @return
     */
    private LinkedHashMap<String, LinkedHashMap<String, Serializable>> getExportOptions() {

        LinkedHashMap<String, LinkedHashMap<String, Serializable>> exportOptions = [idDocumento           : [esportabile: false, label: 'ID', index: -1, columnType: 'NUMBER']
                                                                                    , stato               : [esportabile: false, label: 'Stato', index: -1, columnType: 'TEXT']
                                                                                    , statoFirma          : [esportabile: false, label: 'Stato Firma', index: -1, columnType: 'TEXT']
                                                                                    , tipoOggetto         : [esportabile: false, label: 'Tipo Oggetto', index: -1, columnType: 'TEXT']
                                                                                    , tipoRegistro        : [esportabile: false, label: 'Tipo Registro', index: -1, columnType: 'TEXT']
                                                                                    , riservato           : [esportabile: false, label: 'Riservato', index: -1, columnType: 'TEXT']
                                                                                    , oggetto             : [esportabile: true, label: 'Oggetto', index: 3, columnType: 'TEXT']
                                                                                    , anno                : [esportabile: true, label: 'Anno', index: 2, columnType: 'NUMBER']
                                                                                    , numero              : [esportabile: true, label: 'Numero', index: 1, columnType: 'NUMBER']
                                                                                    , titoloTipologia     : [esportabile: true, label: 'Tipologia', index: 0, columnType: 'TEXT']
                                                                                    , descrizioneTipologia: [esportabile: false, label: 'Tipologia', index: -1, columnType: 'TEXT']
                                                                                    , lastUpdated         : [esportabile: false, label: 'Ultima Modifica', index: -1, columnType: 'DATE']
        ]
        exportOptions
    }
}
