package it.finmatica.protocollo

import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.beans.FileDownloader
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.dizionari.TipoRegistroService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.RegistroGiornaliero
import it.finmatica.protocollo.documenti.RegistroGiornalieroService
import it.finmatica.protocollo.integrazioni.ricercadocumenti.FiltriRegistroGiornaliero
import org.apache.commons.lang3.time.FastDateFormat
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class RegistroGiornalieroListaViewModel {

    // services
    @WireVariable
    private RegistroGiornalieroService registroGiornalieroService

    @WireVariable FileDownloader fileDownloader

    @WireVariable TipoRegistroService tipoRegistroService
    // componenti
    Window self

    List<RegistroGiornaliero> lista
    RegistroGiornaliero selected
    FiltriRegistroGiornaliero filtro

    // paginazione
    int totalSize = 100
    String testoCerca
    boolean mostraFiltri = false

    def orderMap = ['anno': 'desc', 'numero': 'desc']

    FastDateFormat fdfData = FastDateFormat.getInstance('dd/MM/yyyy')
    FastDateFormat fdfDataOra = FastDateFormat.getInstance('dd/MM/yyyy HH:mm:ss')
    List<TipoRegistroDTO> tipiRegistro

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        filtro = new FiltriRegistroGiornaliero()
        tipiRegistro = tipoRegistroService.ricercaTipoRegistro(null as String,0,1000)
        caricaLista()
    }

    @Command
    void onRefresh() {
        caricaLista()
    }

    @Command
    void onCerca(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        if(event instanceof InputEvent) {
            filtro.testoCerca = event.value
        }
        filtro.activePage = 0
        caricaLista()
    }

    @Command
    void onModifica() {
        ProtocolloViewModel.apriPopup(Protocollo.CATEGORIA_REGISTRO_GIORNALIERO, (long) selected.protocollo.id).addEventListener(Events.ON_CLOSE) {
            caricaLista()
        }
    }

    @Command
    @NotifyChange('mostraFiltri')
    void onToggleFiltri() {
        this.mostraFiltri = !this.mostraFiltri
    }

    @Command
    @NotifyChange('filtro')
    void onCancellaFiltri() {
        filtro.reset()
    }

    @Command
    @NotifyChange('mostraFiltri')
    void onChiudiFiltri() {
        this.mostraFiltri = false
    }

    private void caricaLista() {
        PagedResultList<RegistroGiornaliero> registri = registroGiornalieroService.list(filtro)
        lista = registri
        totalSize = registri.totalCount

        BindUtils.postNotifyChange(null, null, this, "lista")
        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "filtro")
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
    void onDownloadFileAllegato() {
        FileDocumento fAllegato = registroGiornalieroService.getFilePrincipale(selected)
        fileDownloader.downloadFileAllegato(selected.protocollo?.toDTO(), fAllegato)
    }

    String dateToString(Date date) {
        return date ? fdfData.format(date) : ''
    }

    String dateTimeToString(Date date) {
        return date ? fdfDataOra.format(date) : ''
    }
}
