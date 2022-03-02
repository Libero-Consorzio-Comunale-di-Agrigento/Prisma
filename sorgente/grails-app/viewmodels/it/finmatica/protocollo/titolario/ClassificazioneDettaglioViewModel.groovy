package it.finmatica.protocollo.titolario

import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.ClassificazioneNumeroDTO
import it.finmatica.protocollo.dizionari.ClassificazioneUnitaDTO
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.zk.AlberoClassificazioni
import it.finmatica.protocollo.zk.AlberoClassificazioniNodo
import it.finmatica.protocollo.zk.AlberoClassificazioniNodoInMemoria
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class ClassificazioneDettaglioViewModel extends DizionariDettaglioViewModel {
    static final String EVT_SCELTA_UNITA = 'onSceltaUnita'

    @WireVariable
    SuccessHandler successHandler
    // services
    @WireVariable
    ClassificazioneService classificazioneService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService

    boolean nonUsata = true
    Date now = new Date()
    String datePattern = 'dd/MM/yyyy'

    ClassificazioneDettaglioViewModel that
    boolean nuovo = false

    AlberoClassificazioniNodo nodo
    List<ClassificazioneUnitaDTO> listaUnita = []
    ClassificazioneUnitaDTO unitaSelezionata
    List<ClassificazioneNumeroDTO> numeri
    List<ClassificazioneDTO> storico
    ClassificazioneDTO classificazionePadre
    String descrizionePadre
    Boolean standalone
    private String separatore = ImpostazioniProtocollo.SEP_CLASSIFICA.valore
    boolean chiusa = false
    String codiceFisso = ''
    String codice

    boolean competenzaModifica = true
    boolean modificaDataChiusura = true
    boolean visButtonSalva = true

    static Window apriPopup(Window parent, ClassificazioneDTO classificazione, ClassificazioneDTO padre) {
        Window w = Executions.createComponents("/titolario/classificazioneDettaglio.zul", parent, [classificazione: classificazione, padre: padre, standalone: Boolean.TRUE])
        w.doModal()
        return w
    }

    @NotifyChange(["selectedRecord"])
    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("nodo") AlberoClassificazioniNodo nodo,
         @ExecutionArgParam('padre') ClassificazioneDTO padre,
         @ExecutionArgParam('classificazione') ClassificazioneDTO classificazione, @ExecutionArgParam('standalone') Boolean standalone) {
        this.self = w
        this.that = this
        this.nodo = nodo
        this.standalone = standalone ?: Boolean.FALSE

        if (nodo?.classificazione?.id) {
            selectedRecord = classificazioneService.get(nodo.classificazione.id, false)
            initDettaglio(selectedRecord)
        } else if (classificazione && (classificazione.id || classificazione.idDocumentoEsterno)) {
            selectedRecord = classificazione.id ? classificazioneService.get(classificazione.id, false) : classificazioneService.findByIdCartella(classificazione.idDocumentoEsterno)
            initDettaglio(selectedRecord)
        } else {
            selectedRecord = new ClassificazioneDTO(valido: true, progressivoPadre: padre?.progressivo, dal: new Date())
            if (padre) {
                classificazionePadre = padre.id ? classificazioneService.get(padre.id, false) : classificazioneService.findByIdCartella(padre.idDocumentoEsterno)
            }
            codiceFisso = classificazionePadre ? classificazionePadre.codice + separatore : ''
            nuovo = true
        }
        if (selectedRecord.codice) {
            codice = selectedRecord.codice - codiceFisso
        }
        if (!nodo) {
            this.nodo = new AlberoClassificazioniNodoInMemoria(selectedRecord)
        }
        chiusa = classificazioneChiusa(selectedRecord as ClassificazioneDTO)
        w.addEventListener(EVT_SCELTA_UNITA, { Event event ->
            BindUtils.postNotifyChange(null, null, that, 'listaUnita')
        })

        if (selectedRecord?.domainObject) {
            competenzaModifica = privilegioUtenteService.isCompetenzaModificaClassificazione(selectedRecord?.domainObject)
            modificaDataChiusura = classificazioneService.isModificaDataChiusura(selectedRecord)
            if (chiusa && !modificaDataChiusura) {
                visButtonSalva = false
            }

            if (!competenzaModifica) {
                chiusa = true
            }

            BindUtils.postNotifyChange(null, null, that, 'modificaDataChiusura')
            BindUtils.postNotifyChange(null, null, that, 'visButtonSalva')
        }
    }

    private void initDettaglio(ClassificazioneDTO selectedRecord) {
        numeri = classificazioneService.getNumeriPerClassificazione(selectedRecord as ClassificazioneDTO)
        nonUsata = !classificazioneService.classificaUsata(selectedRecord.id)
        listaUnita = classificazioneService.getUnitaPerClassificazione(selectedRecord as ClassificazioneDTO)
        storico = classificazioneService.getStoricoPerClassificazione(selectedRecord as ClassificazioneDTO)
        if (selectedRecord.progressivoPadre) {
            classificazionePadre = classificazioneService.getByProgressivo(selectedRecord.progressivoPadre)
            descrizionePadre = "${classificazionePadre?.codice ?: ''} ${separatore} ${classificazionePadre?.descrizione ?: ''}"
            codiceFisso = classificazionePadre ? classificazionePadre.codice + separatore : ''
        }
    }

    //Estendo i metodi abstract di AfcAbstractRecord
    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica", 'nuovo'])
    @Command
    void onSalva() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }
        selectedRecord.codice = codiceFisso + codice
        if (classificazionePadre) {
            selectedRecord.progressivoPadre = classificazionePadre.progressivo
        }
        selectedRecord = classificazioneService.salva(selectedRecord)
        if (nuovo) {
            // devo fare così se no hibernate si mette in mezzo e mi va a cancellare l'id esterno (effetti del trigger lato db)
            classificazioneService.aggiornaProgressivo(selectedRecord.id)

            selectedRecord.progressivo = selectedRecord.id
        }
        nuovo = false
        if (nodo) {
            nodo.classificazione = classificazioneService.get(selectedRecord.id, false)
            Events.sendEvent(AlberoClassificazioni.EVT_SAVED, self.parent, null)
        }

        successHandler.showMessage("Classificazioni salvate")
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalvaChiudi() {
        onSalva()
        onChiudi()
    }

    Collection<String> validaMaschera() {

        def messaggi = super.validaMaschera()
        boolean dataInizioOk = true
        boolean dataFineOk = true
        // questo controllo lo faccio solo se il record è nuovo, se no lascio alla verifica dello storico
        if (selectedRecord.id == null && selectedRecord.dal != null && (selectedRecord.dal - now) < 0) {
            dataInizioOk = false
        }

        if (selectedRecord.dal != null && selectedRecord.al != null && (selectedRecord.dal > selectedRecord.al)) {
            dataInizioOk = false
        }
        if (!codice) {
            messaggi << 'Il codice è obbligatorio'
        }
        if (!selectedRecord?.descrizione) {
            messaggi << 'La descrizione è obbligatoria'
        }
        if (dataInizioOk) {
            def storico = classificazioneService.getStoricoPerClassificazione(selectedRecord as ClassificazioneDTO)
            Date dal = selectedRecord.dal ?: new Date(0)
            Date al = selectedRecord.al ?: new Date() + 100
            for (st in storico) {
                // salto me stesso
                if (st.id != selectedRecord.id) {

                    if (st.al != null && st.al - dal >= 0) {
                        dataInizioOk = false
                    }
                    if (st.dal != null && st.dal - al >= 0) {
                        dataFineOk = false
                    }
                }
            }
        }
        if (modificaDataChiusura)  {
            if (!dataInizioOk) {
                messaggi << 'La data di inizio è precedente ad oggi o sovrapposta ad una storicizzazione esistente'
            }
            if (!dataFineOk) {
                messaggi << 'La data di fine è sovrapposta ad una storicizzazione esistente'
            }
        }

        return messaggi
    }

    String getDescrizione(ClassificazioneDTO dto) {
        return "${dto ? "${dto.codice} " : ''}"
    }

    @NotifyChange(['listaUnita'])
    @Command
    void aggiungiUnita() {
        Window w = Executions.createComponents("/commons/popupSceltaUnita.zul", self, [:])
        w.doModal()
        w.onClose { Event event ->
            So4UnitaPubbDTO us = event.data
            if (us) {
                listaUnita.add(classificazioneService.aggiungiUnita(selectedRecord as ClassificazioneDTO, us))
                Events.sendEvent(EVT_SCELTA_UNITA, self, null)
            }
        }
    }

    @NotifyChange(['unitaSelezionata', 'listaUnita'])
    @Command
    void rimuoviUnita() {
        //TODO conferma
        if (unitaSelezionata) {
            classificazioneService.rimuoviUnita(unitaSelezionata)
            listaUnita.remove(unitaSelezionata)
            unitaSelezionata = null
        }
    }

    @Command
    void onStoricizza() {
        Window w = Executions.createComponents("/titolario/classificazioneStoricizza.zul", self, [nodi: [nodo]])
        w.onClose { event ->
            aggiornaMaschera(selectedRecord?.domainObject)
        }
        w.doModal()
    }

    @Command
    void onChiudiClassificazione() {
        Window w = Executions.createComponents("/titolario/classificazioneChiudi.zul", self, [nodi: [nodo]])
        w.onClose { event ->
            aggiornaMaschera(selectedRecord?.domainObject)
        }
        w.doModal()
    }

    @Command
    void onSelectPadre(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        ClassificazioneDTO padre = event.data
        codiceFisso = (padre && padre.id != -1) ? padre.codice + separatore : ''
        BindUtils.postNotifyChange(null, null, this, 'codiceFisso')
    }

    boolean classificazioneChiusa(ClassificazioneDTO classificazione) {
        return (classificazione.al != null && now - classificazione.al > 0)
    }

    void aggiornaMaschera(def c) {
        selectedRecord = classificazioneService.get(c.id, false)
        modificaDataChiusura = classificazioneService.isModificaDataChiusura(selectedRecord)
        storico = classificazioneService.getStoricoPerClassificazione(selectedRecord as ClassificazioneDTO)
        BindUtils.postNotifyChange(null, null, this, 'modificaDataChiusura')
        BindUtils.postNotifyChange(null, null, this, 'storico')
        BindUtils.postNotifyChange(null, null, this, 'codiceFisso')
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }
}