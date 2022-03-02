package it.finmatica.protocollo.dizionari

import commons.PopupSceltaSmistamentiViewModel
import commons.menu.MenuItemProtocollo
import it.finmatica.gestionedocumenti.dizionari.commons.DizionariDettaglioViewModel
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoAllegatoDTO
import it.finmatica.gestionedocumenti.registri.RegistroService
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloCategoria
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloCategoriaDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloUnitaDTOService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloFile
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloFileDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamento
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamentoDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloUnita
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloUnitaDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.zk.components.upload.CaricaFileEvent
import it.finmatica.protocollo.zk.utils.ClientsUtils
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
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Bandbox
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class SchemaProtocolloDettaglioViewModel extends DizionariDettaglioViewModel {

    // services
    @WireVariable
    private SchemaProtocolloService schemaProtocolloService
    @WireVariable
    private SchemaProtocolloUnitaDTOService schemaProtocolloUnitaDTOService
    @WireVariable
    private SmistamentoService smistamentoService
    @WireVariable
    private TitolarioService titolarioService
    @WireVariable
    private RegistroService registroService
    @WireVariable
    private TipoProtocolloService tipoProtocolloService
    @WireVariable
    private ProtocolloFileDownloader fileDownloader
    @WireVariable
    private TipoRegistroService tipoRegistroService

    List<ClassificazioneDTO> listaClassificazioni
    List<FascicoloDTO> listaFascicoli
    List<TipoProtocolloDTO> listaTipiProtocollo
    List<TipoAllegatoDTO> listaTipoAllegato

    boolean inserimentoInFascicoliChiusi = false

    List<TipoRegistroDTO> listaTipiRegistro

    List<SchemaProtocolloDTO> listaSchemiPrincipali
    List<SchemaProtocolloDTO> listaSchemiRisposta

    List<SchemaProtocolloSmistamentoDTO> listaSchemaProtocolloSmistamenti
    List<SchemaProtocolloUnitaDTO> listaSchemaProtocolloUnita
    List<So4UnitaPubbDTO> listaUnitaCompetenti

    List<So4UnitaPubbDTO> listaUnita

    List<SchemaProtocolloFileDTO> fileAllegati

    List<String> categorieCombo = [SchemaProtocolloCategoria.CATEGORIA_TUTTE] + CategoriaProtocollo.codiciCategorie
    boolean visibileAddCategorie = true

    // mappa dei soggetti (unità di competenza)
    Map soggetti = [:]
    So4UnitaPubbDTO test
    SchemaProtocolloDTO selectedRecord

    boolean arrivo = true
    String tipo = "modifica"
    String titolo = "Tipo Documento "
    boolean modifica = true, lettura = false

    // stato
    Date data
    List<SchemaProtocolloSmistamento> smistamenti

    @NotifyChange("selectedRecord")
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") long id, @ExecutionArgParam("tipo") String tipo) {
        this.self = w
        tipo = (tipo == null ? "modifica" : tipo)
        modifica = tipo.equals("modifica")
        lettura = tipo.equals("lettura")
        caricaSchemaProtocollo(id)

        listaTipiRegistro = tipoRegistroService.ricercaTipoRegistro(null as String, 0, 1000, Boolean.TRUE)?.toDTO()

        listaSchemiRisposta = SchemaProtocollo.findAllByValidoAndRisposta(true, true, [sort: "descrizione", order: "asc"]).toDTO()
        listaSchemiRisposta.add(0, new SchemaProtocolloDTO(codice: "", descrizione: "", valido: true))
        listaTipiProtocollo = tipoProtocolloService.findAllByValidoAndSchemaProtocolloAndProgressivoCfgIterIsNotNull().toDTO()
        listaTipiProtocollo.add(0, new TipoProtocolloDTO(codice: "", descrizione: "", commento: ""))
        listaSchemiPrincipali = SchemaProtocollo.createCriteria().list {
            eq("schemaProtocolloRisposta.id", selectedRecord.id)
        }.toDTO()

        listaTipoAllegato = TipoAllegato.findAllByValidoAndCodiceNotInList(true, [TipoAllegato.CODICE_TIPO_STAMPA_UNICA], [sort: "descrizione", order: "asc"]).toDTO()

        caricaListaSmistamenti()
        caricaListaSchemaProtocolloUnita()
        caricaListaSchemaProtocolloCategorie()
        ricaricaFileAllegati()
        verificaCompetenzeFascicolo()

        BindUtils.postNotifyChange(null, null, this, "listaTipoAllegato")
        BindUtils.postNotifyChange(null, null, this, "lettura")
        BindUtils.postNotifyChange(null, null, this, "modifica")
    }

    private void caricaListaSmistamenti() {
        smistamenti = SchemaProtocolloSmistamento.createCriteria().list {
            createAlias("unitaSo4Smistamento", "unit")
            eq("schemaProtocollo", selectedRecord.getDomainObject())
            fetchMode("unitaSo4Smistamento", FetchMode.JOIN)

            order('tipoSmistamento', 'asc')
            order('sequenza', 'asc')
            order('unit.descrizione', 'asc')
        }

        listaSchemaProtocolloSmistamenti = smistamenti.toDTO()
        BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocolloSmistamenti")
    }

    private void caricaListaSchemaProtocolloUnita() {
           List<SchemaProtocolloUnita> lista = SchemaProtocolloUnita.createCriteria().list() {
                eq("schemaProtocollo.id", selectedRecord.id)
                fetchMode("utenteAd4", FetchMode.JOIN)
                fetchMode("ruoloAd4", FetchMode.JOIN)
                fetchMode("unita", FetchMode.JOIN)
            }
            listaSchemaProtocolloUnita = lista.toDTO()

            BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocolloUnita")
    }

    @NotifyChange("selectedRecord")
    private void caricaListaSchemaProtocolloCategorie() {
        selectedRecord.categorie = schemaProtocolloService.categoriePerSchema(selectedRecord.getDomainObject())?.toDTO()
        visibileAddCategorie = canAddCategorie()
        BindUtils.postNotifyChange(null, null, this, "visibileAddCategorie")
    }

    List<TipoProtocolloDTO> tipiProtocolloPerCategoria(String categoria) {
        if (!StringUtils.isEmpty(categoria)) {
            List<TipoProtocolloDTO> tipi = schemaProtocolloService.getTipiProtocolloPerCategoria(categoria)?.toDTO()
            tipi.add(0, new TipoProtocolloDTO(id: -1, valido: true))
            return tipi
        } else {
            return []
        }
    }

    private boolean canAddCategorie() {
        for (SchemaProtocolloCategoriaDTO c : selectedRecord.categorie) {
            if (c.categoria == SchemaProtocolloCategoria.CATEGORIA_TUTTE) {
                return false
            }
        }
        return true
    }

    @Command
    void onEliminaCategoria(@BindingParam("categoria") SchemaProtocolloCategoriaDTO categoria) {
        Messagebox.show("Sei sicuro di voler eliminare la categoria", "Attenzione", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                selectedRecord.categorie.remove(categoria)
                if (categoria.id) {
                    SchemaProtocolloCategoria.get(categoria.id).delete()
                }
                visibileAddCategorie = canAddCategorie()
                Clients.showNotification("Categoria eliminata", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
                BindUtils.postNotifyChange(null, null, this, "selectedRecord")
            }
        }
    }

    private void caricaSchemaProtocollo(long id) {
        if (id != -1) {
            selectedRecord = SchemaProtocollo.get(id).toDTO(["classificazione", "fascicolo", "ufficioEsibente", "schemaProtocolloRisposta", "tipoProtocollo", "tipoRegistro", "files", "categorie"])
            aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
            aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
        } else {
            selectedRecord = new SchemaProtocolloDTO(id: -1, valido: true)
            selectedRecord.segnaturaCompleta = true
            selectedRecord.segnatura = true
            selectedRecord.conservazioneIllimitata = false
        }
    }

    @Command
    void onAggiungiSchemaProtocolloUnita() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        Window w = Executions.createComponents("/commons/popupCompetenzaDettaglio.zul", self, [documento: selectedRecord, tipoDocumento: "schemaProtocollo"])
        w.onClose {
            caricaListaSchemaProtocolloUnita()
        }
        w.doModal()
    }

    @Command
    void onAggiungiSchemaProtocolloCategoria() {
        SchemaProtocolloCategoriaDTO schemaProtocolloCategoriaDTO = new SchemaProtocolloCategoriaDTO()
        schemaProtocolloCategoriaDTO.categoria = SchemaProtocolloCategoria.CATEGORIA_TUTTE
        schemaProtocolloCategoriaDTO.modificabile = true
        selectedRecord.categorie.add(schemaProtocolloCategoriaDTO)
        visibileAddCategorie = false
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
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

        if (selectedRecord.risposta && selectedRecord.movimento == null) {
            Clients.showNotification("Indicare il movimento.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }
        if (selectedRecord.domandaAccesso && selectedRecord.movimento != Protocollo.MOVIMENTO_ARRIVO) {
            Clients.showNotification("Il movimento deve essere " + Protocollo.MOVIMENTO_ARRIVO, Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }

        selectedRecord.files = fileAllegati
        boolean isNuovoSchemaProtocollo = !(selectedRecord.id < 0)

        if (selectedRecord.categorie.size() > 1) {
            for (SchemaProtocolloCategoriaDTO c : selectedRecord.categorie) {
                if (c.id == null) {
                    if (c.categoria == SchemaProtocolloCategoria.CATEGORIA_TUTTE) {
                        Clients.showNotification("Attenzione: per inserire tutte le categorie è necessario rimuovere le altre", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
                        return
                    }

                    for (SchemaProtocolloCategoriaDTO duplicato : selectedRecord.categorie) {
                        if (c.id != duplicato.id && c.categoria == duplicato.categoria) {
                            Clients.showNotification("Attenzione: non è possibile inserire la stessa categoria '${c.categoria}'", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
                            return
                        }
                    }
                }
            }
        }

        selectedRecord = schemaProtocolloService.salva(selectedRecord)

        if (isNuovoSchemaProtocollo) {
            aggiornaDatiCreazione(selectedRecord.utenteIns.id, selectedRecord.dateCreated)
        }

        caricaListaSchemaProtocolloCategorie()
        aggiornaDatiModifica(selectedRecord.utenteUpd.id, selectedRecord.lastUpdated)
        verificaCompetenzeFascicolo()
        ClientsUtils.showInfo("Tipo documento salvato")
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
            if (Messagebox.ON_OK == e.getName()) {
                this.selectedRecord.valido = valido
                onSalva()
                BindUtils.postNotifyChange(null, null, this, "selectedRecord")
                BindUtils.postNotifyChange(null, null, this, "datiCreazione")
                BindUtils.postNotifyChange(null, null, this, "datiModifica")
            }
        }
    }

    @Command
    void onChangeCategoria(@BindingParam("categoria") SchemaProtocolloCategoriaDTO categoria) {
        List<TipoProtocolloDTO> tipiProtocolloPerCategoria = tipiProtocolloPerCategoria(categoria.categoria)
        if (tipiProtocolloPerCategoria?.size() > 0) {
            categoria.tipoProtocollo = tipiProtocolloPerCategoria?.get(0)
        }
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }

    @NotifyChange(["selectedRecord", "datiCreazione", "datiModifica"])
    @Command
    void onDuplica() {
        selectedRecord = schemaProtocolloService.duplica(selectedRecord)
        Clients.showNotification("Tipo documento duplicato.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    @Command
    void onRicercaClassificazioni(@BindingParam("search") String search) {
        if (search == "") {
            selectedRecord.classificazione = null
            selectedRecord.fascicolo = null
            BindUtils.postNotifyChange(null, null, this, "selectedRecord")
            return
        }

        listaClassificazioni = Classificazione.createCriteria().list() {
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

            order("codice", "asc")
        }.toDTO()

        BindUtils.postNotifyChange(null, null, this, "listaClassificazioni")
    }

    @Command
    void onBlurClassificazioni() {
        if (selectedRecord.classificazione?.id != null) {
            BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        }
    }

    @Command
    void onSelectClassificazione(@BindingParam("target") Bandbox target) {
        selectedRecord.fascicolo = null
        target.close()
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }

    @Command
    void onSelectUfficioEsibente(@BindingParam("target") Bandbox target) {
        target.close()
        BindUtils.postNotifyChange(null, null, this, "selectedRecord")
    }

    @Command
    void onSelectDomandaAccesso() {
        if (selectedRecord.domandaAccesso) {
            selectedRecord.risposta = false
            BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        }
    }

    @Command
    void onRicercaFascicoli(@BindingParam("search") String search, @BindingParam("open") boolean open) {
        if (open != null && !open && search == "") {
            selectedRecord.fascicolo = null
            return
        }

        listaFascicoli = Fascicolo.createCriteria().list() {
            eq("classificazione.id", selectedRecord.classificazione?.id)
            if (search != null) {
                or {
                    ilike("annoNumero", "%" + search + "%")
                    ilike("oggetto", "%" + search + "%")
                }
            }
            order("anno", "desc")
            order("numeroOrd", "asc")

            if (!inserimentoInFascicoliChiusi) {
                Date d = new Date()
                le("dataApertura", d)
                or {
                    ge("dataChiusura", d)
                    isNull("dataChiusura")
                }
            }
        }.toDTO()

        BindUtils.postNotifyChange(null, null, this, "listaFascicoli")
    }

    @Command
    void onBlurFascicoli() {
        if (selectedRecord.fascicolo?.id != null) {
            selectedRecord.fascicolo = Fascicolo.get(selectedRecord.fascicolo?.id).toDTO()
            BindUtils.postNotifyChange(null, null, this, "selectedRecord")
        }
    }

    @Command
    void onRicercaFascicolo() {
        Window w = Executions.createComponents("/commons/popupRicercaFascicoloPerSchemaProtocollo.zul", self, [schemaProtocollo: selectedRecord, inserimentoInFascicoliChiusi: inserimentoInFascicoliChiusi])
        w.onClose { event ->
            if (event.data != null) {
                selectedRecord.fascicolo = event.data
                selectedRecord.classificazione = selectedRecord.fascicolo?.classificazione
                BindUtils.postNotifyChange(null, null, this, "selectedRecord")
            }
        }
        w.doModal()
    }

    @Command
    void onRicercaUnitaCompetenti(@BindingParam("search") String search) {
        listaUnitaCompetenti = So4UnitaPubb.createCriteria().list() {
            if (search != null) {
                or {
                    ilike("codice", "%" + search + "%")
                    ilike("descrizione", "%" + search + "%")
                }
            }
            eq("ottica.codice", springSecurityService.principal.ottica().codice)
            Date d = new Date()
            le("dal", d)
            or {
                ge("al", d)
                isNull("al")
            }
            order("descrizione", "asc")
        }.toDTO()

        BindUtils.postNotifyChange(null, null, this, "listaUnitaCompetenti")
    }

    @Command
    void onRicercaUnita(@BindingParam("cercaUfficio") String search) {
        if (!search) {
            selectedRecord.ufficioEsibente = null
            BindUtils.postNotifyChange(null, null, selectedRecord, "ufficioEsibente")
        }
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
            order("descrizione", "asc")
        }.toDTO()

        BindUtils.postNotifyChange(null, null, this, "listaUnita")
    }

    @Command
    void onAggiungiSmistamenti() {
        String zulPopup = "/commons/popupSceltaSmistamenti.zul"
        Window w = Executions.createComponents(zulPopup, self, [operazione: MenuItemProtocollo.CREA_SMISTAMENTO_SCHEMA, smistamenti: selectedRecord.smistamenti?.toList() ?: [], listaUnitaTrasmissione: new ArrayList<>(), tipoSmistamento: null, unitaTrasmissione: null, tipoSmistamentoVisibile: true, unitaTrasmissioneModificabile: false, isSequenza: false, smartDesktop: false])
        w.onClose { Event event ->
            PopupSceltaSmistamentiViewModel.DatiSmistamento datiSmistamenti = event.data
            if (datiSmistamenti == null) {
                // l'utente ha annullato le operazione
                return
            }
            try {
                if (datiSmistamenti.tipoSmistamento == Smistamento.COMPETENZA && selectedRecord.domainObject.isSequenza() && (datiSmistamenti.sequenza == null || datiSmistamenti.sequenza <= 0)) {
                    throw new ProtocolloRuntimeException("E' obbligatorio inserire una Sequenza per uno smistamento per COMPETENZA.")
                }

                smistamentoService.creaSmistamento(selectedRecord.domainObject, datiSmistamenti.tipoSmistamento, datiSmistamenti.unitaTrasmissione, datiSmistamenti.destinatari[0].unita?.domainObject, datiSmistamenti.indirizzoEmail, datiSmistamenti.fascicoloObbligatorio, datiSmistamenti.sequenza)
                if (selectedRecord.domainObject.isSequenza()) {
                    Integer maxInteger = listaSchemaProtocolloSmistamenti?.sequenza.max()
                    int max = 0
                    if (maxInteger != null) {
                        max = maxInteger?.intValue()
                    }

                    caricaListaSmistamenti()
                    for (SchemaProtocolloSmistamento sps : smistamenti) {
                        if (sps.tipoSmistamento == Smistamento.COMPETENZA && sps.sequenza == null) {
                            max = max + 10
                            sps.sequenza = max
                            sps.save()
                        }
                    }
                }

                refreshSmistamenti()
                Clients.showNotification("Smistamento aggiunto", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
            } catch (Exception e) {
                // impedisco la chiusura della popup e segnalo l'errore che è avvenuto
                event.stopPropagation()
                throw e
            }
        }
        w.doModal()
    }

    @Command
    void onModificaSequenza(@BindingParam("smistamento") SchemaProtocolloSmistamentoDTO smistamento) {
        if (selectedRecord.domainObject.isSequenza() && (smistamento.sequenza == null || smistamento.sequenza <= 0)) {
            refreshSmistamenti()
            throw new ProtocolloRuntimeException("E' obbligatorio inserire una Sequenza per uno smistamento per COMPETENZA.")
        }

        SchemaProtocolloSmistamento sc = SchemaProtocolloSmistamento.findBySequenzaAndSchemaProtocollo(smistamento.sequenza, selectedRecord.domainObject)
        if (sc != null) {
            refreshSmistamenti()
            throw new ProtocolloRuntimeException("Il numero di sequenza è già stata inserito")
        }

        smistamento.domainObject.sequenza = smistamento.sequenza
        smistamento = smistamento.domainObject.save()?.toDTO()
        refreshSmistamenti()
        Clients.showNotification("Smistamento modificato", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    @Command
    void onModificaEmail(@BindingParam("smistamento") SchemaProtocolloSmistamentoDTO smistamento) {
        smistamento.domainObject.email = smistamento.email
        smistamento = smistamento.domainObject.save()?.toDTO()
        BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocolloSmistamenti")
        Clients.showNotification("Smistamento modificato", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    @Command
    void onModificaFascicoloObb(@BindingParam("smistamento") SchemaProtocolloSmistamentoDTO smistamento) {
        smistamento.domainObject.fascicoloObbligatorio = smistamento.fascicoloObbligatorio
        smistamento = smistamento.domainObject.save()?.toDTO()
        BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocolloSmistamenti")
        Clients.showNotification("Smistamento modificato", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
    }

    @Command
    void onSelectUnitaCompetente(@BindingParam("target") Bandbox target, @BindingParam("schemaProtocolloUnita") SchemaProtocolloUnitaDTO schemaProtocolloUnita) {
        target.close()

        if (schemaProtocolloUnita.id != null) {
            schemaProtocolloUnita.domainObject?.delete()
        }

        if (listaSchemaProtocolloUnita.count { it.unita.codice.contains(schemaProtocolloUnita.unita.codice) } > 1) {
            Clients.showNotification("Unità competente già presente.", Clients.NOTIFICATION_TYPE_ERROR, null, "top_center", 3000, true)
        } else {
            SchemaProtocolloUnita schemaProtocolloUnitaD = new SchemaProtocolloUnita(schemaProtocollo: selectedRecord.domainObject, unita: schemaProtocolloUnita.unita?.domainObject)
            schemaProtocolloUnitaD.id = 0
            schemaProtocolloUnitaD.save()
            selectedRecord.domainObject.save()
        }

        refreshUnita()
    }

    @Command
    void onEliminaSchemaProtocolloUnita(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("schemaProtocolloUnita") SchemaProtocolloUnitaDTO schemaProtocolloUnita) {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            Clients.showNotification(StringUtils.join(messaggiValidazione, "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 3000, true)
            return
        }

        Messagebox.show("Eliminare la competenza selezionata?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
                new org.zkoss.zk.ui.event.EventListener() {
                    void onEvent(Event e) {
                        if (Messagebox.ON_OK.equals(e.getName())) {
                            schemaProtocolloUnitaDTOService.elimina(schemaProtocolloUnita)
                            SchemaProtocolloDettaglioViewModel.this.caricaListaSchemaProtocolloUnita()
                        }
                    }
                }
        )
    }

    @Command
    void onEliminaSchemaProtocolloSmistamento(@BindingParam("schemaProtocolloSmistamento") SchemaProtocolloSmistamentoDTO schemaProtocolloSmistamento) {
        Messagebox.show("Sei sicuro di voler eliminare lo smistamento", "Attenzione",
                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                schemaProtocolloSmistamento.domainObject?.delete()
                selectedRecord.domainObject.save()
                refreshSmistamenti()
                Clients.showNotification("Smistamento eliminato.", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
                BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocolloSmistamenti")
            }
        }
    }

    @Command
    void onDownloadFileAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("fileAllegato") value) {
        fileDownloader.downloadFileAllegato(selectedRecord, SchemaProtocolloFile.get(value.id), false)
    }

    @Command
    void onCaricaFile(@ContextParam(ContextType.TRIGGER_EVENT) CaricaFileEvent event) {

        schemaProtocolloService.uploadFile(selectedRecord.domainObject, event.filename, event.contentType, event.inputStream)
        if (event.last) {
            ricaricaFileAllegati()
            ClientsUtils.showInfo('File salvato')
        }
    }

    private refreshSmistamenti() {
        listaSchemaProtocolloSmistamenti = SchemaProtocolloSmistamento.findAllBySchemaProtocollo(selectedRecord.domainObject).toDTO(["unitaSo4Smistamento"])
        BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocolloSmistamenti")
    }

    private refreshUnita() {
        listaSchemaProtocolloUnita = schemaProtocolloService.trovaUnita(selectedRecord.domainObject).toDTO(["unita"])
        BindUtils.postNotifyChange(null, null, this, "listaSchemaProtocolloUnita")
    }

    private void ricaricaFileAllegati() {
        fileAllegati = SchemaProtocollo.createCriteria().list {
            projections {
                files {
                    property "nome"           // 0
                    property "id"             // 1
                    property "contentType"    // 2
                    property "dimensione"     // 3
                    property "tipoAllegato"     // 4
                }
            }
            eq("id", selectedRecord.id)
            files {
                eq("valido", true)
                ge("idFileEsterno", (long) 0)
            }
            files {
                order("nome", "asc")
            }
        }.collect { row -> new SchemaProtocolloFileDTO(nome: row[0], id: row[1], contentType: row[2], dimensione: row[3], tipoAllegato: row[4].toDTO()) }
        BindUtils.postNotifyChange(null, null, this, "fileAllegati")
    }

    @Command
    void onEliminaFileAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("fileAllegato") value) {
        Messagebox.show("Eliminare il file selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK.equals(e.getName())) {
                schemaProtocolloService.eliminaFileDocumento(selectedRecord.domainObject, value.domainObject)
                ricaricaFileAllegati()
            }
        }
    }

    @Command
    void controllaFlagModificabile(@BindingParam("categoria") SchemaProtocolloCategoriaDTO categoria) {

        if (categoria.tipoProtocollo == null) {
            categoria.modificabile = true
            return
        }

        if (!categoria.modificabile) {
            SchemaProtocollo schema = schemaProtocolloService.schemaBloccatoPerTipoProtocollo(categoria.tipoProtocollo.domainObject)
            if (schema != null && schema.id != selectedRecord.id) {
                categoria.modificabile = true
                ClientsUtils.showError("Attenzione non è possibile rendere questo Tipo di Documento non modificabile perchè risulta non modificabile il Tipo: " + schema.descrizione)
            }
        }
    }

    void verificaCompetenzeFascicolo() {
        if (null != selectedRecord?.fascicolo) {
            titolarioService.verificaCompetenzeLetturaECambiaOggettoFascicoloRiservato(selectedRecord.fascicolo)
        }
    }
}