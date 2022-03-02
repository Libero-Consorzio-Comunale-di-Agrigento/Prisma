package it.finmatica.protocollo.dizionari

import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.autenticazione.Ad4RuoloDTO
import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenza
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoCompetenzaDTO
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoModelloDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoDTO
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIterDTO
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.tipologie.ParametroTipologiaService
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.hibernate.FetchMode
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.event.OpenEvent
import org.zkoss.zk.ui.event.SelectEvent
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Bandbox
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class TipoProtocolloDettaglioViewModel extends DizionariDettaglioViewModel {

    // services
    @WireVariable
    private StrutturaOrganizzativaService strutturaOrganizzativaService
    @WireVariable
    private ParametroTipologiaService parametroTipologiaService
    @WireVariable
    private TipoProtocolloService tipoProtocolloService
    @WireVariable
    private SuccessHandler successHandler

    // dati
    List<WkfCfgIterDTO> listaCfgIter
    List<TipoRegistroDTO> listaTipiRegistro
    List<TipologiaSoggettoDTO> listaTipologie
    List<TipoDocumentoCompetenzaDTO> listaTipoDocumentoCompetenza
    // questo viene usato dal viewmodel
    List<CategoriaProtocollo> listaCategorie = CategoriaProtocollo.categorie

    List listaParametri
    List<TipoDocumentoModelloDTO> listaModelloTestoAssocs
    List<Ad4UtenteDTO> listaFirmatari

    List<String> movimenti

    boolean arrivo = true

    // stato
    Date data

    List<So4UnitaPubbDTO> listaUnita
    List<Ad4RuoloDTO> listaRuoloAd4Dto

    int activePageRuoloAd4 = 0
    int totalSizeRuoloAd4 = 0
    String filtroRuoloAd4 = ""
    String valoreRuoloAd4
    String prefissoRuoli = ""
    int pageSize = 10
    boolean ufficioInvioPec = false
    String CODICE_FILE_FRONTESPIZIO = 'FILE_FRONTESPIZIO'

    @NotifyChange(["selectedRecord", "listaRuoloAd4Dto"])
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") long id) {
        this.self = w

        if (ImpostazioniProtocollo.SCEGLI_UFFICIO_INVIO_PEC.abilitato) {
            ufficioInvioPec = true
        }

        if (id > 0 && ufficioInvioPec) {
            selectedRecord = TipoProtocollo.get(id)?.toDTO(["unitaDestinataria", "ruoloUoDestinataria", "schemaProtocollo"])
        }

        listaCfgIter = new ArrayList<WkfCfgIterDTO>()
        listaCfgIter = WkfCfgIter.iterValidi().list([sort: "nome", order: "asc"]).toDTO()
        listaCfgIter.add(0, new WkfCfgIterDTO(id: -1, nome: "", descrizione: ""))
        listaTipiRegistro = TipoRegistro.findAllByValido(true, [sort: "commento", order: "asc"]).toDTO()
        listaTipologie = TipologiaSoggetto.list([sort: "descrizione", order: "asc"]).toDTO()

        String codiceOttica = springSecurityService.principal.ottica()?.codice
        if (codiceOttica == null) {
            codiceOttica = Impostazioni.OTTICA_SO4.valore
        }
        listaFirmatari = strutturaOrganizzativaService.getComponentiConRuoloInOttica(Impostazioni.RUOLO_SO4_FIRMATARIO_CERT_PUBB.valore
                , codiceOttica).toDTO(["soggetto.utenteAd4"]).soggetto.utenteAd4.unique()

        // leggo il prefisso dei ruoli da visualizzare
        prefissoRuoli = ImpostazioniProtocollo.PREFISSO_RUOLO_AD4.valore

        if (ufficioInvioPec) {
            listaRuoloAd4Dto = caricaListaRuoliAd4()
            valoreRuoloAd4 = selectedRecord?.ruoloUoDestinataria?.descrizione
        }

        caricaTipoProtocollo(id)

        if (id > 0) {
            aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
            aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
        }

        // se non ho nessuna categoria selezionata, ne preseleziono una:
        if (selectedRecord.categoria == null) {
            selectedRecord.categoria = CategoriaProtocollo.getInstance(Protocollo.CATEGORIA_PROTOCOLLO).codice
        }

        // se ho solo una tipologia di soggetto e questa non è presente sul record, la preseleziono.
        if (listaTipologie.size() == 1 && selectedRecord.tipologiaSoggetto == null) {
            selectedRecord.tipologiaSoggetto = listaTipologie.first()
        }

        // se ho solo un tipo di movimento possibile e non ho ancora selezionato nel record, lo preseleziono.
        if (selectedRecord.categoriaProtocollo?.movimentiTipoDocumento?.size() == 1) {
            selectedRecord.movimento = selectedRecord.categoriaProtocollo.movimentiTipoDocumento.first()
        }

        movimenti = [""] +selectedRecord.categoriaProtocollo?.movimenti

    }

    @NotifyChange(["selectedRecord"])
    @Command
    void onSelectCategoria() {
        // se ho solo un tipo di movimento possibile e non ho ancora selezionato nel record, lo preseleziono.
        selectedRecord.movimento = selectedRecord.categoriaProtocollo.movimentiTipoDocumento.first()
        selectedRecord.predefinito = false
    }

    private List<Ad4RuoloDTO> caricaListaRuoliAd4() {
        PagedResultList ruoli = Ad4Ruolo.createCriteria().list(max: pageSize, offset: pageSize * activePageRuoloAd4) {
            ilike("ruolo", prefissoRuoli + "%")
            or {
                ilike("ruolo", "%" + filtroRuoloAd4 + "%")
                ilike("descrizione", "%" + filtroRuoloAd4 + "%")
            }

            order("ruolo", "asc")
        }
        totalSizeRuoloAd4 = ruoli.totalCount
        return ruoli.toDTO()
    }

    @NotifyChange(["listaRuoloAd4Dto", "totalSizeRuoloAd4"])
    @Command
    void onPaginaRuoloAd4() {
        listaRuoloAd4Dto = caricaListaRuoliAd4()
    }

    @NotifyChange(["listaRuoloAd4Dto", "totalSizeRuoloAd4", "activePageRuoloAd4"])
    @Command
    void onOpenRuoloAd4(@ContextParam(ContextType.TRIGGER_EVENT) OpenEvent event) {
        if (event.open) {
            activePageRuoloAd4 = 0
            listaRuoloAd4Dto = caricaListaRuoliAd4()
        }
    }

    @Command
    void onCheckPredefinito() {
        if(selectedRecord.predefinito){
           TipoProtocollo predefinito = tipoProtocolloService.getPredefinitoPerCategoria(selectedRecord.categoria)
            if(predefinito && predefinito.id != selectedRecord.id){

                Messagebox.show("Esiste già un tipo di procollo predefinito ('${predefinito.descrizione}) per la categoria scelta; confermando il tipo di protocollo diventerà il nuovo predefinito", "Attenzione",
                        Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                    if (Messagebox.ON_OK == e.getName()) {

                        TipoProtocolloDTO predefinitoDTO = predefinito.toDTO()
                        predefinitoDTO.predefinito = false
                        tipoProtocolloService.salva(predefinitoDTO)

                        onSalva()
                        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
                    }
                    else {
                        selectedRecord.predefinito = false
                        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
                    }
                }
            }
        }
    }

    @NotifyChange(["listaRuoloAd4Dto", "totalSizeRuoloAd4", "activePageRuoloAd4"])
    @Command
    void onChangingRuoloAd4(@ContextParam(ContextType.TRIGGER_EVENT) InputEvent event) {
        selectedRecord.ruoloUoDestinataria = null
        activePageRuoloAd4 = 0
        filtroRuoloAd4 = event.getValue()
        listaRuoloAd4Dto = caricaListaRuoliAd4()
    }

    //METODI PER BANDBOX RUOLO AD4
    @NotifyChange(["selectedRecord", "valoreRuoloAd4"])
    @Command
    void onSelectRuoloAd4(@ContextParam(ContextType.TRIGGER_EVENT) SelectEvent event, @BindingParam("target") Component target) {
        // SOLO se ho selezionato un solo item
        if (event.getSelectedItems()?.size() == 1) {
            filtroRuoloAd4 = ""
            selectedRecord.ruoloUoDestinataria = event.getSelectedItems().toArray()[0].value
            valoreRuoloAd4 = selectedRecord.ruoloUoDestinataria.descrizione
            target?.close()
        }
    }

    private void caricaTipoProtocollo(long id) {
        if (id > 0) {
            selectedRecord = TipoProtocollo.get(id).toDTO(["parametri"])

            caricaListaParametri()
            caricaListaTipoDocumentoCompetenza()
            caricaListaModelloTesto()
        } else {
            selectedRecord = new TipoProtocolloDTO(id: -1, valido: true)
            selectedRecord.firmatarioObbligatorio = true
        }

        if (selectedRecord.firmatarioObbligatorio) {
            selectedRecord.firmatarioVisibile = true
        }

        if (selectedRecord.funzionarioObbligatorio) {
            selectedRecord.funzionarioVisibile = true
        }
    }

    @NotifyChange("selectedRecord")
    @Command
    void onChangeFunzionarioObbligatorio() {
        if (selectedRecord.funzionarioObbligatorio) {
            selectedRecord.funzionarioVisibile = true
        }
    }

    @NotifyChange("selectedRecord")
    @Command
    void onChangeFirmatarioObbligatorio() {
        if (selectedRecord.firmatarioObbligatorio) {
            selectedRecord.firmatarioVisibile = true
        }
    }

    @NotifyChange("listaParametri")
    @Command
    void caricaListaParametri() {
        listaParametri = parametroTipologiaService.getListaParametri("tipoProtocollo", selectedRecord.id, selectedRecord.progressivoCfgIter ?: -1)
    }

    @NotifyChange("listaParametri")
    @Command
    void svuotaParametro(@BindingParam("parametro") p) {
        p.valore = null
    }

    /*
     * Gestione Modello testo
     */

    @Command
    void onAggiungiModelloTesto() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        //verifica se modello testo obbligatorio per la categoria selezionata
        boolean modelloTestoObbligatorio =  CategoriaProtocollo.getInstance(selectedRecord?.categoria).isModelloTestoObbligatorio()

        // i tipo modello possono essere N (lista)
        Window w = Executions.createComponents("/commons/popupSceltaModelloTesto.zul", self, [tipoModello: null,  modelloTestoObbligatorio : modelloTestoObbligatorio])
        w.onClose { Event event ->
            boolean stop = false
            if (event?.data != null) {
                if (event.data.predefinito) {
                    for (TipoDocumentoModelloDTO assoc : listaModelloTestoAssocs)
                        if (assoc.predefinito) {
                            throw new ProtocolloRuntimeException("Esiste già un Modello testo predefinito")
                        }
                }

                if(event.data.codice == CODICE_FILE_FRONTESPIZIO) {
                    boolean presenteFrontespizio = listaModelloTestoAssocs.find {it.codice == CODICE_FILE_FRONTESPIZIO}
                    if(presenteFrontespizio) {
                        Clients.showNotification("E' possibile inserire un solo file frontespizio. Eliminare il vecchio riferimento prima di procedere", Clients.NOTIFICATION_TYPE_ERROR, null, 'middle_center', 5000, true)
                        stop = true
                    }
                }
                if(!stop) {
                    event.data.tipoDocumento = selectedRecord
                    tipoProtocolloService.aggiungiModelloTesto(event.data)
                    caricaListaModelloTesto()
                }
            }
        }
        w.doModal()
    }

    @Command
    void onEliminaModelloTesto(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("modelloTestoAssoc") TipoDocumentoModelloDTO tipoDocumentoModelliDTO) {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        if (tipoDocumentoModelliDTO.predefinito) {
            Messagebox.show("Il Modello testo selezionato è testo predefinito: eliminare comunque?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (Messagebox.ON_OK.equals(e.getName())) {
                    tipoProtocolloService.eliminaModelloTesto(tipoDocumentoModelliDTO)
                    caricaListaModelloTesto()
                }
            }
        } else {
            Messagebox.show("Eliminare il Modello testo selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (Messagebox.ON_OK.equals(e.getName())) {
                    tipoProtocolloService.eliminaModelloTesto(tipoDocumentoModelliDTO)
                    caricaListaModelloTesto()
                }
            }
        }
    }

    private void caricaListaModelloTesto() {
        listaModelloTestoAssocs = selectedRecord?.domainObject?.modelliAssociati?.toDTO() as List
        for (TipoDocumentoModelloDTO assoc : listaModelloTestoAssocs) {
            assoc.modelloTesto = assoc.domainObject.modelloTesto.toDTO()
        }
        BindUtils.postNotifyChange(null, null, this, "listaModelloTestoAssocs")
    }

    /*
     * Gestione Competenze
     */

    private void caricaListaTipoDocumentoCompetenza() {
        List<TipoDocumentoCompetenza> lista = TipoDocumentoCompetenza.createCriteria().list {
            eq("tipoDocumento.id", selectedRecord.id)
            fetchMode("utenteAd4", FetchMode.JOIN)
            fetchMode("ruoloAd4", FetchMode.JOIN)
            fetchMode("unitaSo4", FetchMode.JOIN)
        }
        listaTipoDocumentoCompetenza = lista.toDTO()
        BindUtils.postNotifyChange(null, null, this, "listaTipoDocumentoCompetenza")
    }

    @Command
    void onEliminaTipoDocumentoCompetenza(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("tipoDocumentoCompetenza") TipoDocumentoCompetenzaDTO tipoDocCompetenza) {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        Messagebox.show("Eliminare la competenza selezionata?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK.equals(e.getName())) {
                tipoProtocolloService.elimina(tipoDocCompetenza)
                caricaListaTipoDocumentoCompetenza()
            }
        }
    }

    @Command
    void onAggiungiTipoDocumentoCompetenza() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        Window w = Executions.createComponents("/commons/popupCompetenzaDettaglio.zul", self, [documento: selectedRecord, tipoDocumento: "tipoProtocollo"])
        w.onClose {
            caricaListaTipoDocumentoCompetenza()
        }
        w.doModal()
    }

    List<String> getListaMovimenti() {
        return selectedRecord.categoriaProtocollo.movimentiTipoDocumento
    }

    /*
     * Implementazione dei metodi per AfcAbstractRecord
     */

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalva() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        boolean isNuovoTipoProtocollo = !(selectedRecord.id > 0)

        selectedRecord = tipoProtocolloService.salva(selectedRecord)

        if (isNuovoTipoProtocollo) {
            caricaListaTipoDocumentoCompetenza()
        }

        Clients.showNotification("Tipo Protocollo salvato.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    @Command
    void onRicercaUnita(@BindingParam("cercaUfficio") String search) {
        listaUnita = So4UnitaPubb.createCriteria().list() {
            if (search != null) {
                or {
                    ilike("codice", "%" + search + "%")
                    ilike("descrizione", "%" + search + "%")
                }
            }
            Date d = new Date()
            le("dal", d)
            or {
                ge("al", d)
                isNull("al")
            }
            eq("ottica.codice", springSecurityService.principal.ottica().codice)
            order("codice", "asc")
        }.toDTO()

        BindUtils.postNotifyChange(null, null, this, "listaUnita")
    }

    @Command
    void onSelectUnitaDestinataria(@BindingParam("target") Bandbox target) {
        target.close()
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onSalvaChiudi() {
        onSalva()
        onChiudi()
    }

    @Command
    void onSettaValido(@BindingParam("valido") boolean valido) {
        Messagebox.show(Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTesto", [valido ? "valido" : "non valido"].toArray()), Labels.getLabel("dizionario.cambiaValiditaRecordMessageBoxTitolo"),
                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK.equals(e.getName())) {
                this.selectedRecord.valido = valido
                onSalva()
                BindUtils.postNotifyChange(null, null, this, "selectedRecord")
                BindUtils.postNotifyChange(null, null, this, "datiCreazione")
                BindUtils.postNotifyChange(null, null, this, "datiModifica")
            }
        }
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onDuplica() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        selectedRecord = tipoProtocolloService.duplica(selectedRecord)
        Clients.showNotification("Tipologia duplicata.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    Collection<String> validaMaschera() {
        Collection<String> messaggi = super.validaMaschera()
        if (StringUtils.isEmpty(selectedRecord.codice)) {
            messaggi << "Codice Obbligatorio"
        }
        if (!selectedRecord.tipologiaSoggetto) {
            messaggi << "Tipologia Soggetto Obbligatoria"
        }
        if (StringUtils.isEmpty(selectedRecord.descrizione)) {
            messaggi << "Descrizione Obbligatoria"
        }

        return messaggi
    }
}
