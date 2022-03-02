package it.finmatica.protocollo

import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gestionedocumenti.utils.ExportService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.DocumentoStepDTOService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.viste.DocumentoStepDTO
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.SortEvent
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class DocumentiMieiViewModel {

    // services
    @WireVariable
    private DocumentoStepDTOService documentoStepDTOService
    @WireVariable
    private ExportService exportService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService

    // componenti
    Window self

    // dati
    def lista
    DocumentoStepDTO selected
    def listaAllegati

    List<TipoRegistroDTO> listaTipiRegistro
    TipoRegistroDTO tipoRegistro

    def tipoOggetto
    def tipiOggetto = [[oggetti: null, nome: Labels.getLabel("tipoOggetto.tutti")]
                       , [oggetti: [Protocollo.CATEGORIA_LETTERA], nome: Labels.getLabel("tipoOggetto.lettere")]
                       , [oggetti: [Protocollo.CATEGORIA_PROTOCOLLO], nome: Labels.getLabel("tipoOggetto.protocollo")]
                       , [oggetti: [Protocollo.CATEGORIA_DA_NON_PROTOCOLLARE], nome: Labels.getLabel("tipoOggetto.documentoDaClassificare")]
    ]

    // ricerca
    String testoCerca = ""

    // paginazione
    int activePage = 0
    int pageSize = 30
    int totalSize = 100

    def orderMap = ['anno': 'desc', 'numero': 'desc']
    // autorizzazioni creazione documenti
    boolean creaLettera = false;
    boolean creaProtocollo = false;
    boolean creaDocFascicolo = false;
    boolean creaNuovo = false;

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        tipoOggetto = tipiOggetto[0]
        caricaLista()
        caricaRegistri()
        inizializzaAutorizzazioni()
    }

    @Command
    void onRefresh() {
        caricaLista()
    }

    @Command
    void onCerca() {
        activePage = 0
        caricaLista()
    }

    @Command
    void onNuovoProtocollo(@BindingParam("categoria") String categoria) {
        ProtocolloViewModel.apriPopup(categoria).addEventListener(Events.ON_CLOSE) {
            caricaLista()
        }
    }

    @Command
    void onModifica() {
        ProtocolloViewModel.apriPopup(selected.tipoOggetto, (long) selected.idDocumento).addEventListener(Events.ON_CLOSE) {
            caricaLista()
        }
    }

    @Command
    void onNuovoDocumentoDaClassificare(@BindingParam("categoria") String categoria) {
        ProtocolloViewModel.apriPopup(categoria).addEventListener(Events.ON_CLOSE) {
            caricaLista()
        }
    }

    @Command
    void onCambiaTipo() {
        caricaRegistri()
        onCerca()
    }

    private void caricaRegistri() {
        listaTipiRegistro = TipoRegistro.createCriteria().list() {
            eq("valido", true)
        }.toDTO()
        listaTipiRegistro.add(0, new TipoRegistroDTO(codice: null, commento: Labels.getLabel("tipoOggetto.tutti")))
        BindUtils.postNotifyChange(null, null, this, "listaTipiRegistro")
        BindUtils.postNotifyChange(null, null, this, "tipoRegistro")
    }

    private void caricaLista() {
        def documenti = documentoStepDTOService.inCarico(testoCerca, tipoOggetto?.oggetti, tipoRegistro?.codice, null, null, null, pageSize, activePage, orderMap, false)
        lista = documenti.result
        totalSize = documenti.total

        BindUtils.postNotifyChange(null, null, this, "lista")
        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
    }

    private void creaPopup(String zul, parametri) {
        Window w = Executions.createComponents(zul, self, parametri)
        w.doModal()
        w.onClose {
            caricaLista()
        }
    }

    /* GESTIONE MENU ALLEGATO */

    @Command
    void onMostraAllegati(@BindingParam("documento") documento) {
        listaAllegati = documentoStepDTOService.caricaAllegatiDocumento(documento.idDocumento, documento.tipoOggetto)

        BindUtils.postNotifyChange(null, null, this, "listaAllegati")
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileAllegato") value) {
        documentoStepDTOService.downloadFileAllegato(value)
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
    void onExportExcel() {
        if (totalSize > Impostazioni.ESPORTAZIONE_NUMERO_MASSIMO.valoreInt) {
            Messagebox.show("Attenzione: il numero dei documenti da esportare supera il massimo consentito.", "Esportazione interrotta.", Messagebox.OK, Messagebox.EXCLAMATION, null)
            return
        }
        try {
            def documenti = documentoStepDTOService.inCarico(testoCerca, tipoOggetto?.oggetti, tipoRegistro?.codice, null, null, null, pageSize, activePage, orderMap, false, true)
            def export = documenti.result.collect { [   idDocumento              :it.idDocumento
                                                        , stato                  :it.stato
                                                        , statoFirma             :it.statoFirma
                                                        , stepTitolo             :it.stepTitolo
                                                        , tipoOggetto            :it.tipoOggetto
                                                        , tipoRegistro           :it.tipoRegistro
                                                        , riservato              :it.riservato
                                                        , oggetto                :it.oggetto
                                                        , anno                   :it.anno
                                                        , numero                 :it.numero
                                                        , titoloTipologia        :it.titoloTipologia
                                                        , descrizioneTipologia   :it.descrizioneTipologia
                                                        , lastUpdated		     :it.lastUpdated
            ]}
            exportService.downloadExcel(documenti.exportOptions, export)
        }
        finally {
            caricaLista()
        }
    }

    void inizializzaAutorizzazioni() {
        creaLettera = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.REDATTORE_LETTERA)
        creaProtocollo = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.REDATTORE_PROTOCOLLO)
        creaDocFascicolo = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.DAFASC)
        creaNuovo = creaLettera || creaProtocollo || creaDocFascicolo;
    }
}
