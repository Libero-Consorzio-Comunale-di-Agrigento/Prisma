package commons

import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gestionedocumenti.Holders
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.protocollo.documenti.viste.Riferimento
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.ricercadocumenti.CampiRicerca
import it.finmatica.protocollo.integrazioni.ricercadocumenti.DocumentoEsterno
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.integrazioni.ricercadocumenti.RicercaDocumentiEsterni
import org.springframework.core.annotation.AnnotationAwareOrderComparator
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zul.Include
import org.zkoss.zul.Window
import org.zkoss.zul.event.PagingEvent

@VariableResolver(DelegatingVariableResolver)
class PopupImportAllegatiIntegrazioneViewModel {

    Window self

    List<RicercaDocumentiEsterni> ricercaDocumentiEsterni

    PagedList<DocumentoEsterno> listaAllegatiDocumenti
    CampiRicerca campiRicerca

    List<DocumentoEsterno> listaAllegatiDocumentiSelezionati

    List tipiRicerca
    int tipoRicercaIndex
    @WireVariable private ProtocolloGdmService protocolloGdmService
    DocumentoDTO documento
    List<Riferimento> riferimenti

    @Wire("include")
    Include include

    @Init
    @NotifyChange(["selectedRicerca", "campiRicerca"])
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("documento") DocumentoDTO documento) {
        this.self = w
        this.documento = documento
        this.riferimenti = Riferimento.findAllByIdDocumento(documento.idDocumentoEsterno)

        // siccome il plugin zk non supporta il binding delle variabili a liste di bean, lo faccio a mano
        ricercaDocumentiEsterni = Holders.getApplicationContext().getBeansOfType(RicercaDocumentiEsterni)
                .findAll { it.value.abilitato }.collect { it.value }.sort(true, new AnnotationAwareOrderComparator())
        tipiRicerca = ricercaDocumentiEsterni.collect { [id: it.class.name, titolo: it.titolo] }
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
        listaAllegatiDocumenti = new PagedList<>([], 0)
        listaAllegatiDocumentiSelezionati = []
    }

    String getZulCampiRicerca() {
        return getSelectedRicerca().getZulCampiRicerca()
    }

    RicercaDocumentiEsterni getSelectedRicerca() {
        return ricercaDocumentiEsterni[tipoRicercaIndex]
    }

    @Command
    void onChiudi() {
        BindUtils.postNotifyChange(null, null, this, "documento")
        Events.postEvent(Events.ON_CLOSE, self, documento)
    }

    @NotifyChange(["campiRicerca", "listaAllegatiDocumenti"])
    @Command
    void onPagina(@ContextParam(ContextType.TRIGGER_EVENT) PagingEvent pagingEvent) {
        campiRicerca.startFrom = pagingEvent.activePage * campiRicerca.maxResults
        listaAllegatiDocumenti = selectedRicerca.ricerca(campiRicerca)
    }

    @NotifyChange(["documento"])
    @Command
    void onImportaDocumenti() {
        boolean presente = false
        for (DocumentoEsterno doc : listaAllegatiDocumentiSelezionati) {
            presente = false
            for (Riferimento r : riferimenti) {
                if (r.idRiferimento == doc.idDocumentoEsterno) {
                    presente = true
                    break
                }
            }

            if (!presente) {
                protocolloGdmService.salvaDocumentoCollegamento(documento.domainObject, doc, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_RIFERIMENTO)
            }
        }
        onChiudi()
    }
}
