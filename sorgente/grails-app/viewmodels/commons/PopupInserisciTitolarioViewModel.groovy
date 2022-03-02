package commons

import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.zk.utils.ClientsUtils
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindContext
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupInserisciTitolarioViewModel {

    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    private TitolarioService titolarioService

    Window self

    Integer anno
    String numero
    String oggetto
    String codice
    String descrizione

    boolean soloClassificazioniAperte = true
    boolean soloClassificazioni = false
    boolean soloFascicoliAperti = true
    boolean ricercaInAnd = true

    List<DTO> risultatiRicerca
    List<DTO> listaTitolari = []
    List<DTO> listaSelected = []
    DTO selectedSx
    DTO selectedDx
    DocumentoDTO documento

    static Window apri(Component parent, def listaTitolari, DocumentoDTO documento) {
        Window w = (Window) Executions.createComponents("/commons/popupInserisciTitolario.zul", parent, [listaTitolari: listaTitolari])
        w.doModal()
        return w
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("listaTitolari") listaTitolari, @ExecutionArgParam("documento") documento) {
        this.listaTitolari = listaTitolari
        this.documento = documento
        this.soloClassificazioni = !privilegioUtenteService.isInserimentoInFascicoliAperti()
        this.soloClassificazioniAperte = privilegioUtenteService.inserimentoInClassificheAperte
        this.soloFascicoliAperti = true
        this.self = w
    }

    @NotifyChange(["risultatiRicerca"])
    @Command
    void onRicerca() {
        risultatiRicerca = []
        int totalCount
        PagedResultList results
        boolean ricercaSoloFascicolo = false

        if (numero?.toString()?.length() > 0 || anno?.toString()?.length() > 0 || oggetto?.length() > 0) {
            ricercaSoloFascicolo = true
        }
        if (soloClassificazioni) {
            ricercaSoloFascicolo = false
        }

        if ((!ricercaSoloFascicolo)) {
            results = titolarioService.ricercaClassificazioni(new ClassificazioneDTO(codice: codice, descrizione: descrizione), 0, 100, soloClassificazioniAperte, true)
            risultatiRicerca = results.toDTO()
            totalCount = results.totalCount
        }

        if (!soloClassificazioni) {
            results = titolarioService.ricercaFascicoli(new ClassificazioneDTO(codice: codice, descrizione: descrizione), new FascicoloDTO(numero: numero, anno: anno, oggetto: oggetto),null,  0, 100, false)
            List<FascicoloDTO> fascicoliDto = titolarioService.verificaCompetenzeLetturaFascicolo(results.toDTO("classificazione"))
            risultatiRicerca.addAll(fascicoliDto)
            totalCount = Math.max(totalCount, results.totalCount)
        }

        // se ho trovato troppi record, lo segnalo
        if (totalCount > ImpostazioniProtocollo.CLASSFASC_RICERCA_MAX_NUM.valoreInt) {
            ClientsUtils.showWarning('Attenzione troppi risultati ricevuti, raffinare la ricerca')
        }
    }

    @Command
    void onSalvaTitolario() {
        Events.postEvent(Events.ON_CLOSE, self, listaSelected)
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    @NotifyChange(["listaSelected", "risultatiRicerca"])
    void dropToList2(@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx) {
        if (ctx.triggerEvent.dragged.value != null && !(listaSelected*.id).contains(ctx.triggerEvent.dragged.value.id)) {
            if (isTitolarioPresente(listaTitolari, ctx.triggerEvent.dragged.value)) {
                Clients.showNotification("Titolario " + ctx.triggerEvent.dragged.value?.getNome() + " già presente!", Clients.NOTIFICATION_TYPE_WARNING, self, "middle_center", 4000, true)
            } else {
                DTO selezionato = ctx.triggerEvent.dragged.value
                listaSelected.add(selezionato)
                risultatiRicerca.remove(selezionato)
            }
        }
    }

    @NotifyChange(["listaSelected", "risultatiRicerca"])
    @Command
    void dropToList1(@ContextParam(ContextType.BIND_CONTEXT) BindContext ctx) {
        if (ctx.triggerEvent.dragged.value != null && !(risultatiRicerca*.id).contains(ctx.triggerEvent.dragged.value.id)) {
            DTO selezionato = ctx.triggerEvent.dragged.value
            listaSelected.remove(selezionato)
            risultatiRicerca.add(selezionato)
        }
    }

    @NotifyChange(["listaSelected", "risultatiRicerca"])
    @Command
    void onSelTuttoADx() {
        String titolarioPresente = "";
        for (DTO sel : risultatiRicerca) {
            if (!(listaSelected*.id).contains(sel.id)) {
                if (isTitolarioPresente(listaTitolari, sel)) {
                    titolarioPresente = titolarioPresente + StringUtils.join(sel?.getNome(), "\n")
                } else {
                    listaSelected.add(sel)
                }
            }
        }
        if (titolarioPresente.length()>0) {
            Clients.showNotification(StringUtils.join("Titolari:", "\n") + titolarioPresente + " già presenti!", Clients.NOTIFICATION_TYPE_WARNING, self, "middle_center", 4000, true)
        }
        risultatiRicerca.clear()
    }

    @NotifyChange(["listaSelected", "risultatiRicerca"])
    @Command
    void onSelTuttoASx() {
        for (DTO sel : listaSelected) {
            if (!(risultatiRicerca*.id).contains(sel.id)) {
                risultatiRicerca.add(sel)
            }
        }
        listaSelected.clear()
    }

    @NotifyChange(["listaSelected", "risultatiRicerca", "selectedSx"])
    @Command
    void onSelADx() {
        if (selectedSx != null && !(listaSelected*.id).contains(selectedSx.id)) {
            if (isTitolarioPresente(listaTitolari, selectedSx)) {
                Clients.showNotification("Titolario " + selectedSx?.getNome() + " già presente!", Clients.NOTIFICATION_TYPE_WARNING, self, "middle_center", 4000, true)
            } else {
                risultatiRicerca.remove(selectedSx)
                listaSelected.add(selectedSx)
                selectedSx = null
            }
        }
    }

    @NotifyChange(["listaSelected", "risultatiRicerca", "selectedDx"])
    @Command
    void onSelASx() {
        if (selectedDx != null && !(risultatiRicerca*.id).contains(selectedDx.id)) {
            listaSelected.remove(selectedDx)
            risultatiRicerca.add(selectedDx)
            selectedDx = null
        }
    }

    boolean isTitolarioPresente(List<DocumentoTitolarioDTO> listaTitolari, DTO titolario) {

        DocumentoTitolarioDTO documentoTitolarioDTO

        if (titolario instanceof FascicoloDTO) {
            FascicoloDTO fascicolo = titolario
            ClassificazioneDTO classificazione = titolario.classificazione
            documentoTitolarioDTO = new DocumentoTitolarioDTO(fascicolo: fascicolo, classificazione: classificazione, documento: documento)
        } else {
            documentoTitolarioDTO = new DocumentoTitolarioDTO(classificazione: titolario, documento: documento)
        }

        boolean presenza = false

        int results = listaTitolari.findAll { item ->
            //item.documento.id == documento.id &&
            item.classificazione.id == documentoTitolarioDTO.classificazione.id &&
                    item.fascicolo?.id == documentoTitolarioDTO?.fascicolo?.id
        }.size()

        if (results > 0) {
            presenza = true
        }

        return presenza
    }
}
