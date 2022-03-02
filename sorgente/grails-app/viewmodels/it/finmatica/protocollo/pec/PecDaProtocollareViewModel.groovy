package it.finmatica.protocollo.pec

import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.utils.ExportService
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.DocumentoStepDTOService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.mail.ConfigurazioniMailService
import it.finmatica.protocollo.documenti.viste.DocumentoStepDTO
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
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
import org.zkoss.zul.Menupopup
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PecDaProtocollareViewModel {
    // services
    @WireVariable
    private DocumentoStepDTOService documentoStepDTOService
    @WireVariable
    private ExportService exportService
    @WireVariable
    MessaggiRicevutiService messaggiRicevutiService
    @WireVariable
    ConfigurazioniMailService configurazioniMailService
    @WireVariable
    AllegatoProtocolloService allegatoProtocolloService

    // componenti
    Window self
    @Wire("#mpAllegatiPec")
    Menupopup popupAllegati

    // dati
    def lista
    DocumentoStepDTO selected
    def listaAllegati

    // paginazione
    int activePage = 0
    int pageSize = 30
    int totalSize = 100

    def orderMap = ['anno': 'desc', 'numero': 'desc']

    //par di ricerca
    def casella
    def listaCaselle = []
    Date dal, al
    def tipiPosta = [MessaggiRicevutiService._ITEM_TUTTI, MessaggiRicevutiService._ITEM_TIPO_POSTA_CERTIFICATA, MessaggiRicevutiService._ITEM_TIPO_POSTA_ORDINARIA]
    String tipoPostaCertificato = MessaggiRicevutiService._ITEM_TUTTI
    String mittente

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w

        dal = (new Date()).minus(30)
        al = new Date()

        listaCaselle = configurazioniMailService.getListaCaselle(false)
        if (listaCaselle.contains(configurazioniMailService.csTagTutte)) {
            casella = configurazioniMailService.csTagTutte
        } else {
            casella = listaCaselle?.get(0)
        }

        caricaLista()
    }

    @AfterCompose
    public void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false);
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

    private void caricaLista() {
        def documenti = documentoStepDTOService.inCaricoProtoPec(null, null, null, casella.casella, dal, al, tipoPostaCertificato, mittente, pageSize, activePage, orderMap, false)
        lista = documenti.result
        totalSize = documenti.total

        BindUtils.postNotifyChange(null, null, this, "lista")
        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
    }

    @Command
    void onFiltro() {
        caricaLista()
    }

    @Command
    void onModifica() {
        ProtocolloViewModel.apriPopup(selected.tipoOggetto, (long) selected.idDocumento).addEventListener(Events.ON_CLOSE) {
            caricaLista()
        }
    }

    @NotifyChange("listaAllegati")
    @Command
    void onCaricaListaAllegati(@BindingParam("documento") documento, @ContextParam(ContextType.COMPONENT) Component component) {
        Protocollo protocollo = Protocollo.findById((long) documento.idDocumento)
        listaAllegati = allegatoProtocolloService.getFileAllegatiProtocollo(protocollo)

        popupAllegati.open(component)
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
            def documenti = documentoStepDTOService.inCaricoProtoPec(null, null, null, casella.casella, dal, al, tipoPostaCertificato, mittente, pageSize, activePage, orderMap, false)
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
                 , mittentiProtocollo  : it.mittentiProtocollo
                 , dataSpedizione      : it.dataSpedizione
                 , mittenti            : it.messaggioRicevuto.mittente
                ]
            }
            exportService.downloadExcel(documenti.exportOptions, export)
        }
        finally {
            caricaLista()
        }
    }
}
