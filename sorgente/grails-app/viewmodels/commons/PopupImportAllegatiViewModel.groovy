package commons

import it.finmatica.gestionedocumenti.Holders
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.exception.ValidaDimensioneAllegatiRuntimeException
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.integrazioni.ricercadocumenti.AllegatoEsterno
import it.finmatica.protocollo.integrazioni.ricercadocumenti.CampiRicerca
import it.finmatica.protocollo.integrazioni.ricercadocumenti.RicercaAllegatiDocumentiEsterni
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.springframework.core.annotation.AnnotationAwareOrderComparator
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Include
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window
import org.zkoss.zul.event.PagingEvent

@VariableResolver(DelegatingVariableResolver)
class PopupImportAllegatiViewModel {

    Window self

    List<RicercaAllegatiDocumentiEsterni> ricercaAllegatiDocumentiEsterni

    PagedList<AllegatoEsterno> listaAllegatiDocumenti
    CampiRicerca campiRicerca

    AllegatoEsterno allegatoPrincipaleSelezionato
    List<AllegatoEsterno> listaAllegatiDocumentiSelezionati

    boolean sceltaDelFilePrincipale
    List tipiRicerca
    int tipoRicercaIndex
    AllegatoDTO allegato
    def documentoPadre
    @WireVariable
    private DocumentoService documentoService
    @WireVariable
    private ProtocolloFileDownloader fileDownloader
    @WireVariable
    private IGestoreFile gestoreFile
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    AllegatoProtocolloService allegatoProtocolloService

    @Wire("include")
    Include include

    static Window apriPopup(Component component,
                            DocumentoDTO documentoPadre,
                            AllegatoDTO allegato = null) {
        Window window = (Window) Executions.createComponents("/commons/popupImportAllegati.zul", component, [documento: documentoPadre,
                                                                                                             allegato : allegato])
        window.doModal()
        return window
    }

    @Init
    @NotifyChange(["selectedRicerca", "campiRicerca", "sceltaDelFilePrincipale"])
    init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("documento") DocumentoDTO documentoPadre, @ExecutionArgParam("allegato") AllegatoDTO allegato) {

        this.self = w
        this.documentoPadre = documentoPadre
        this.allegato = allegato
        sceltaDelFilePrincipale = (allegato == null &&
                documentoPadre instanceof ProtocolloDTO &&
                ((ProtocolloDTO) documentoPadre).categoriaProtocollo == CategoriaProtocollo.CATEGORIA_PROTOCOLLO)
        allegatoPrincipaleSelezionato = null

        // siccome il plugin zk non supporta il binding delle variabili a liste di bean, lo faccio a mano
        ricercaAllegatiDocumentiEsterni = Holders.getApplicationContext().getBeansOfType(RicercaAllegatiDocumentiEsterni)
                .findAll { it.value.abilitato }.collect { it.value }.sort(true, new AnnotationAwareOrderComparator())
        tipiRicerca = ricercaAllegatiDocumentiEsterni.collect { [id: it.class.name, titolo: it.titolo] }
        if (tipiRicerca.size() > 0) {
            tipoRicercaIndex = 0
            onSelect()
        }
    }

    @AfterCompose
    void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false)
    }

    @Command
    @NotifyChange(["listaAllegatiDocumenti"])
    void onRicerca() {
        campiRicerca.startFrom = 0
        listaAllegatiDocumenti = selectedRicerca.ricerca(campiRicerca)
    }

    @Command
    @NotifyChange(["*"])
    void onSelect() {
        campiRicerca = getSelectedRicerca().getCampiRicerca()
        campiRicerca.filtri.ANNO = Calendar.getInstance().get(Calendar.YEAR)
        listaAllegatiDocumenti = new PagedList<>([], 0)
        listaAllegatiDocumentiSelezionati = []
    }

    @Command
    @NotifyChange(["allegatoPrincipaleSelezionato"])
    onImpostaPrincipaleFileAllegato(@BindingParam("allegatoEsterno") AllegatoEsterno allegatoEsterno) {
        if (allegatoPrincipaleSelezionato != null && allegatoPrincipaleSelezionato.idFileEsterno == allegatoEsterno?.idFileEsterno) {
            allegatoPrincipaleSelezionato = null
        } else {
            allegatoPrincipaleSelezionato = allegatoEsterno
        }
    }

    String getZulCampiRicerca() {
        return getSelectedRicerca().getZulCampiRicerca()
    }

    RicercaAllegatiDocumentiEsterni getSelectedRicerca() {
        return ricercaAllegatiDocumentiEsterni[tipoRicercaIndex]
    }

    @Command
    void onChiudi() {
        BindUtils.postNotifyChange(null, null, this, "allegato")
        Events.postEvent(Events.ON_CLOSE, self, allegato)
    }

    @NotifyChange(["campiRicerca", "listaAllegatiDocumenti"])
    @Command
    void onPagina(@ContextParam(ContextType.TRIGGER_EVENT) PagingEvent pagingEvent) {
        campiRicerca.startFrom = pagingEvent.activePage * campiRicerca.maxResults
        listaAllegatiDocumenti = selectedRicerca.ricerca(campiRicerca)
    }

    @NotifyChange(["allegato"])
    @Command
    onImportaDocumenti() {
        //Prima di procedere verifica se i nomi dei file selezionati contengono caratteri non validi
        allegatoProtocolloService.validaNomeAllegatiImport(listaAllegatiDocumentiSelezionati)

        //Prima di procedere verifica univocità nomi
        if (!checkUnivocitaNomiFile()) {
            return
        }

        try {
            if (allegatoPrincipaleSelezionato != null) {
                protocolloService.caricaFilePrincipale(((ProtocolloDTO) documentoPadre).domainObject,
                        gestoreFile.getFile(allegatoPrincipaleSelezionato.getDocumento(), allegatoPrincipaleSelezionato), allegatoPrincipaleSelezionato.contentType,
                        allegatoPrincipaleSelezionato.nome)

                listaAllegatiDocumentiSelezionati.remove(allegatoPrincipaleSelezionato)
            }
            this.allegato = documentoService.importaAllegatiEsterni(documentoPadre, allegato, listaAllegatiDocumentiSelezionati, false)
            onChiudi()
        }
        catch (ValidaDimensioneAllegatiRuntimeException exception) {

            Messagebox.show("Attenzione: La dimensione dei file allegati e il documento principale superano la dimensione massima consentita: ${Impostazioni.MAXDIM_ATTACH.valore} bytes. Continuare?", "Attenzione!",
                    Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
                    new org.zkoss.zk.ui.event.EventListener() {
                        void onEvent(Event e) {
                            if (Messagebox.ON_OK.equals(e.getName())) {
                                if (allegatoPrincipaleSelezionato != null) {
                                    protocolloService.caricaFilePrincipale(((ProtocolloDTO) documentoPadre).domainObject,
                                            gestoreFile.getFile(allegatoPrincipaleSelezionato.getDocumento(), allegatoPrincipaleSelezionato), allegatoPrincipaleSelezionato.contentType,
                                            allegatoPrincipaleSelezionato.nome)
                                }
                                this.allegato = documentoService.importaAllegatiEsterni(documentoPadre, allegato, listaAllegatiDocumentiSelezionati, true)
                                onChiudi()
                            }
                        }
                    }
            )
        }
    }

    @Command
    onDownloadFileAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("allegatoEsterno") AllegatoEsterno allegatoEsterno) {
        fileDownloader.downloadFileAllegato(allegatoEsterno.getDocumento(), allegatoEsterno)
    }

    @Command
    void onCambiaNome() {
        BindUtils.postNotifyChange(null, null, this, "listaAllegatiDocumenti")
    }

    private boolean checkUnivocitaNomiFile() {
        for (allegatoI in listaAllegatiDocumentiSelezionati) {
            AllegatoProtocolloService.UNIVOCITA_NOMI_FILE univocitaNomiFile
            univocitaNomiFile = allegatoProtocolloService.isNomeFileUnivoco(((ProtocolloDTO) documentoPadre).domainObject, null, allegatoI.nome)
            if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_PRINCIPALE)) {
                ClientsUtils.showError("Impossibile caricare il file: il file ${allegatoI.nome} ha lo stesso nome dei file principale del documento.")
                return false
            }
            if (univocitaNomiFile.equals(AllegatoProtocolloService.UNIVOCITA_NOMI_FILE.KO_ALLEGATO)) {
                ClientsUtils.showError("Non è possibile caricare due volte un file con lo stesso nome: ${allegatoI.nome}.")
                return false
            }
        }

        return true
    }
}
