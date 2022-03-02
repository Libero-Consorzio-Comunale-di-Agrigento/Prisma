package commons

import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.titolario.ClassificazioneRepository
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
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
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Paging
import org.zkoss.zul.Window
import org.zkoss.zul.event.PagingEvent

@VariableResolver(DelegatingVariableResolver)
class PopupRicercaFascicoloViewModel {

    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    private TitolarioService titolarioService
    @WireVariable
    ClassificazioneRepository classificazioneRepository

    @Wire("paging")
    Paging paging

    def selectedRecord

    Window self

    List<FascicoloDTO> listaFascicoli = []
    FascicoloDTO selected
    ClassificazioneDTO classificazione
    FascicoloDTO fascicolo
    List<So4UnitaPubbDTO> listaUnita = []
    So4UnitaPubbDTO unitaCompetenza

    // dati
    List<FascicoloDTO> listaZul = []

    boolean creaFascicolo

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("classificazione") ClassificazioneDTO classificazione, @ExecutionArgParam("fascicolo") FascicoloDTO fascicolo) {
        this.self = w

        if (classificazione != null && classificazione?.codice == null) {
            classificazione.descrizione = ""
        }
        this.classificazione = new ClassificazioneDTO(id: classificazione?.id, codice: classificazione?.codice, descrizione: classificazione?.descrizione)
        this.fascicolo = fascicolo?.id != -1 ? new FascicoloDTO(id: fascicolo?.id, numero: fascicolo?.numero, anno: fascicolo?.anno, oggetto: fascicolo?.oggetto, note: fascicolo?.note, classificazione: this.classificazione) : new FascicoloDTO(classificazione: this.classificazione)

        listaUnita = So4UnitaPubb.findAllByAlIsNull(sort: "descrizione", order: "asc").toDTO()
        listaUnita.add(0, new So4UnitaPubbDTO(codice: "", descrizione: "", progr: null))

        creaFascicolo = privilegioUtenteService.isCreaFascicolo()
        BindUtils.postNotifyChange(null, null, this, 'creaFascicolo')
    }

    @AfterCompose
    void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false)
    }

    @NotifyChange(["listaFascicoli"])
    @Command
    void onRicerca() {
        paging.setActivePage(0)
        listaFascicoli = caricaListaFascicoli()
        generaListaZul(listaFascicoli)
    }

    void generaListaZul(List<FascicoloDTO> listaFascicoli) {
        listaZul = []
        for (item in listaFascicoli) {

            Fascicolo fascicoloItem = Fascicolo.get(item.id)
            listaZul << [classificazione: Classificazione.get(item.classificazione?.id).codice,
                         anno           : item.anno,
                         numero         : item.numero,
                         unitaCompetenza: fascicoloItem.getUnita().toString().toUpperCase(),
                         oggetto        : item.oggetto,
                         note           : item.note,
                         id             : item.id]
        }
        BindUtils.postNotifyChange(null, null, this, 'listaZul')
    }

    @Command
    void onSelezionaFascicolo() {
        FascicoloDTO fascicolo = Fascicolo.get(selectedRecord?.id).toDTO("classificazione")
        Events.postEvent(Events.ON_CLOSE, self, [fascicolo: fascicolo])
    }

    @Command
    void onCreaFascicolo(@BindingParam("codiceClassifica") codiceClassifica) {
        ClassificazioneDTO classificazioneDTO
        if (codiceClassifica) {
            classificazioneDTO = classificazioneRepository.getClassificazioneInUso(codiceClassifica)?.toDTO()
        }

        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", null, [id: -1, isNuovoRecord: true, standalone: false, titolario: classificazioneDTO, forzaChiusura: true])
        w.onClose {  e ->
            if (e.data && e.data["fascicolo"]?.id) {
                FascicoloDTO fascicolo = Fascicolo.get( e.data["fascicolo"]?.id).toDTO("classificazione")
                Events.postEvent(Events.ON_CLOSE, self, [fascicolo: fascicolo])
            }
        }
        w.doModal()
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @NotifyChange(["listaFascicoli"])
    @Command
    void onPagina(@ContextParam(ContextType.TRIGGER_EVENT) PagingEvent pagingEvent) {
        listaFascicoli = caricaListaFascicoli()
        generaListaZul(listaFascicoli)
    }

    private List<FascicoloDTO> caricaListaFascicoli() {
        classificazione.id = null
        PagedResultList fascicoli = titolarioService.ricercaFascicoli(classificazione, fascicolo, unitaCompetenza, paging.pageSize * paging.activePage, paging.getPageSize(), false)

        if (fascicoli.totalCount > ImpostazioniProtocollo.CLASSFASC_RICERCA_MAX_NUM.valoreInt) {
            ClientsUtils.showWarning('Attenzione troppi risultati ricevuti, raffinare la ricerca')
            return new ArrayList<FascicoloDTO>()
        }

        paging.setTotalSize(fascicoli.totalCount)
        paging.setActivePage(paging.activePage)
        List<FascicoloDTO> fascicoliDto = titolarioService.verificaCompetenzeLetturaFascicolo(fascicoli.toDTO("classificazione"))

        return fascicoliDto
    }
}
