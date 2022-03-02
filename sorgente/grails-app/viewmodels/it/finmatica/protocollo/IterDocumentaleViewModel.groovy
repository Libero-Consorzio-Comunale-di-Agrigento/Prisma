package it.finmatica.protocollo

import commons.PopupSceltaSmistamentiViewModel
import commons.menu.MenuItemProtocollo
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.AllegatoProtocolloService
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.documenti.IterDocumentaleService
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoViewModel
import it.finmatica.protocollo.integrazioni.smartdesktop.EsitoSmartDesktop
import it.finmatica.protocollo.integrazioni.smartdesktop.EsitoTask
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.so4.StrutturaOrganizzativaProtocolloService
import it.finmatica.protocollo.titolario.FascicoloService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang3.time.FastDateFormat
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
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
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Listbox
import org.zkoss.zul.Listitem
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class IterDocumentaleViewModel {

    // services
    @WireVariable
    SpringSecurityService springSecurityService
    @WireVariable
    SmistamentoService smistamentoService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    FascicoloService fascicoloService
    @WireVariable
    ProtocolloGdmService protocolloGdmService
    @WireVariable
    DocumentoTitolarioService documentoTitolarioService
    @WireVariable
    PreferenzeUtenteService preferenzeUtenteService
    @WireVariable
    ProtocolloFileDownloader fileDownloader
    @WireVariable
    AllegatoProtocolloService allegatoProtocolloService
    @WireVariable
    StrutturaOrganizzativaProtocolloService strutturaOrganizzativaProtocolloService
    @WireVariable
    IterDocumentaleService iterDocumentaleService

    // componenti
    Window self
    @Wire("#listaDocumentiIter")
    Listbox listbox

    // dati
    Page<SmistamentoDTO> lista
    SmistamentoDTO selected
    List<SmistamentoDTO> selectedItems
    List<AllegatoDTO> listaAllegati
    List<FileDocumento> listaFilesAllegato

    List<So4UnitaPubbDTO> listaUnita
    So4UnitaPubbDTO unitaOrganizzativa
    int selectedIndexUnita = -1

    Integer codiceABarre
    boolean visualizzaCodiceABarre

    // stato
    boolean abilitaPulsantiOperazioni = false
    boolean abilitaPrendiInCaricoCodiceABarre = false
    boolean abilitaCreaFascicolo = false

    boolean inCarico = false
    boolean daRicevere = false
    boolean assegnati = false

    String msgNoDocumentiPerTab

    boolean smartDesktop

    // ricerca
    String testoCerca = ""

    // paginazione
    int activePage = 0
    int pageSize = 30
    int totalSize = 0

    FastDateFormat fdfData = FastDateFormat.getInstance('dd/MM/yyyy')
    FastDateFormat fdfDataOra = FastDateFormat.getInstance('dd/MM/yyyy HH:mm:ss')

    final List<String> tipoOggettoDaEscludereIncludere = ["FASCICOLO"]
    final String ZUL_POPUP_SMISTAMENTI = "/commons/popupSceltaSmistamenti.zul"
    final String ZUL_POPUP_ASSEGNATARI = "/commons/popupSceltaAssegnatari.zul"
    final String ESITO_POPUP = "/iterdocumentale/esitoIter.zul"
    final String POPUP_DESTINATARI = "/commons/popupDestinatari.zul"

    static final String CODICE_TAB_DA_RICEVERE = "da_ricevere"
    static final String CODICE_TAB_IN_CARICO = "in_carico"
    static final String CODICE_TAB_ASSEGNATI = "assegnati"

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("codiceTab") String codiceTab,
              @ExecutionArgParam("codiceUO") String codiceUO, @ExecutionArgParam("smartDesktop") Boolean smartDesktop) {
        this.self = w
        settaTab(codiceTab ?: CODICE_TAB_DA_RICEVERE)
        if (!smartDesktop) {
            caricaUnitaOrganizzativa()
        } else {
            unitaOrganizzativa = iterDocumentaleService.getUnitaByCodice(codiceUO).toDTO()
            this.smartDesktop = true
        }
        abilitaPulsanti()
        caricaLista(codiceTab ?: CODICE_TAB_DA_RICEVERE)
        visualizzaCodiceABarre = ImpostazioniProtocollo.CODICE_A_BARRE_ITER.abilitato
    }

    @AfterCompose
    void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false)
    }

    @NotifyChange(["abilitaPulsantiOperazioni"])
    @Command
    void onSelectDocumento() {
        abilitaPulsantiOperazioni = tipoOggettoDocumentiSelezionati()
    }

    private String tipoOggettoDocumentiSelezionati() {
        return listbox.getSelectedItems().size() > 0
    }

    @NotifyChange("selectedRecord")
    @Command
    void onItemDoubleClick(@ContextParam(ContextType.COMPONENT) Listitem l) {
        selected = l.value
        //Se è un messaggio del nuovo protocollo
        if (selected.isMessaggioRicevuto() && selected.documento.idMessaggioSi4Cs) {
            onApriMessaggioRicevuto()
        }
        //Se è un messaggio del vecchio applicativo
        else if (selected.isMessaggioRicevuto() && !selected.documento.idMessaggioSi4Cs) {
            onApriMessaggioOld()
        }
        //Se è un fascicolo
        else if (selected.isFascicolo()) {
            onApriFascicolo()
        }
        //Se è un protocollo o altro documento
        else {
            onApriDocumento()
        }
    }

    @Command
    void onApriDocumento() {
        if (selected.documento.categoriaProtocollo?.isDaNonProtocollare()) {
            ProtocolloViewModel.apriPopup(selected.documento.categoriaProtocollo.codice, (long) selected.documento.id).addEventListener(Events.ON_CLOSE) {
                onRefresh()
            }
        } else {
            ProtocolloViewModel.apriPopup((long) selected.documento.id).addEventListener(Events.ON_CLOSE) {
                onRefresh()
            }
        }
    }


    @Command
    void onApriFascicolo() {
        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", null, [id: selected.documento.id, isNuovoRecord: false, standalone: false, titolario: null])
        w.onClose {
            onRefresh()
        }
        w.doModal()
    }

    @Command
    void onApriMessaggioRicevuto() {
        Window w = MessaggioRicevutoViewModel.apriPopup([idMessaggio: "" + selected.documento.id])
        w.onClose {
            onRefresh()
        }
        w.doModal()
    }

    @Command
    void onApriMessaggioOld() {
        //recupera la url del vecchio dalla view
        String linkOldMsg = iterDocumentaleService.getLinkOldMsg(selected.documento.id)
        Clients.evalJavaScript(" window.open('" + linkOldMsg + "'); ")
    }


    @Command
    void onModifica() {
        if (selected.isMessaggioRicevuto() && selected.documento.idMessaggioSi4Cs) {
            onApriMessaggioRicevuto()
        } else if (selected.isMessaggioRicevuto() && !selected.documento.idMessaggioSi4Cs) {
            onApriMessaggioOld()
        } else if (selected.isFascicolo()) {
            onApriFascicolo()
        } else {
            onApriDocumento()
        }
    }

    @Command
    void onRefresh() {
        caricaLista()
        selected = null
        codiceABarre = null
        BindUtils.postNotifyChange(null, null, this, "codiceABarre")
    }

    @Command
    void onCambiaTab(@BindingParam("codiceTab") String codiceTab) {
        activePage = 0
        totalSize = 0
        selected = null
        codiceABarre = null
        caricaLista(codiceTab)
        BindUtils.postNotifyChange(null, null, this, "codiceABarre")
    }

    @Command
    void onCerca() {
        activePage = 0
        totalSize = 0
        caricaLista()
    }

    @Command
    void onAssegna() {
        effettuaOperazione(MenuItemProtocollo.APRI_ASSEGNA)
    }

    @Command
    void onCaricoAssegna() {
        effettuaOperazione(MenuItemProtocollo.APRI_CARICO_ASSEGNA)
    }

    @Command
    void onSmista() {
        effettuaOperazione(MenuItemProtocollo.APRI_SMISTA_FLEX)
    }

    @Command
    void onSmistaEsegui() {
        effettuaOperazione(MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX)
    }

    @Command
    void onInoltra() {
        effettuaOperazione(MenuItemProtocollo.APRI_INOLTRA_FLEX)
    }

    @Command
    void onCaricoInoltra() {
        effettuaOperazione(MenuItemProtocollo.APRI_CARICO_FLEX)
    }


    void effettuaOperazione(String operazione) {

        List<EsitoSmartDesktop> esitoSmartDesktopList = []

        List<SmistamentoDTO> listaSmistamentiSelezionati = estraiSmistamentiSelezionati()

        // il controllo se uno smistamento esiste è fatto nel servizio, quindi gli smistamenti correnti non servono in questo caso
        List<SmistamentoDTO> listaSmistamentiDto = new ArrayList<SmistamentoDTO>()

        So4UnitaPubbDTO unitaTrasmissioneDefault = smistamentoService.getUnitaTrasmissioneDefault(unitaOrganizzativa.codice)

        boolean tipoSmistamentoVisibile = false

        if (operazione == MenuItemProtocollo.APRI_SMISTA_FLEX || operazione == MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX) {
            tipoSmistamentoVisibile = true
        }

        String zulPopup = ZUL_POPUP_SMISTAMENTI
        if (operazione == MenuItemProtocollo.APRI_ASSEGNA || operazione == MenuItemProtocollo.APRI_CARICO_ASSEGNA) {
            zulPopup = ZUL_POPUP_ASSEGNATARI
        }

        Window w

        if (daRicevere) {
            w = Executions.createComponents(zulPopup, self, [operazione: operazione, smistamenti: listaSmistamentiDto, listaUnitaTrasmissione: new ArrayList([unitaTrasmissioneDefault]), tipoSmistamento: Smistamento.CONOSCENZA, unitaTrasmissione: unitaTrasmissioneDefault, tipoSmistamentoVisibile: tipoSmistamentoVisibile, unitaTrasmissioneModificabile: false, isSequenza: false, smartDesktop: false])
        } else {
            w = Executions.createComponents(zulPopup, self, [operazione: operazione, smistamenti: listaSmistamentiDto, listaUnitaTrasmissione: new ArrayList([unitaTrasmissioneDefault]), tipoSmistamento: null, unitaTrasmissione: unitaTrasmissioneDefault, tipoSmistamentoVisibile: tipoSmistamentoVisibile, unitaTrasmissioneModificabile: false, isSequenza: false, smartDesktop: false])
        }
        w.onClose { Event event ->
            PopupSceltaSmistamentiViewModel.DatiSmistamento datiSmistamenti = event.data

            if (datiSmistamenti == null) {
                // l'utente ha annullato le operazione
                return
            }

            try {
                switch (operazione) {

                    case MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX:

                        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
                            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
                            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoSmistaEdEsegui(documento, datiSmistamenti, smistamento.idDocumentoEsterno)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }
                        break

                    case MenuItemProtocollo.APRI_ASSEGNA:

                        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
                            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
                            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.assegna(documento, datiSmistamenti, smistamento.idDocumentoEsterno)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }
                        break

                    case MenuItemProtocollo.APRI_CARICO_ASSEGNA:

                        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
                            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
                            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoEAssegna(documento, datiSmistamenti, smistamento.idDocumentoEsterno)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }
                        break

                    case MenuItemProtocollo.APRI_SMISTA_FLEX:

                        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
                            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
                            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.smista(documento, datiSmistamenti, smistamento.idDocumentoEsterno)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }
                        break

                    case MenuItemProtocollo.APRI_CARICO_FLEX:

                        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
                            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
                            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoEInoltra(documento, datiSmistamenti, smistamento.idDocumentoEsterno)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }
                        break

                    case MenuItemProtocollo.APRI_INOLTRA_FLEX:

                        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
                            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
                            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.inoltra(documento, datiSmistamenti, smistamento.idDocumentoEsterno)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }
                        break

                    default:
                        Clients.showNotification("Operazione " + operazione + " non gestita.", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 2000, true)
                        break
                }

                if (esitoSmartDesktopList.size() > 0) {
                    //Verifico sul primo elemento della lista se sto operando su Documenti o Fascicoli
                    String descrizioneTipoDocumento = getDescrizioneTipoDocumento(listaSmistamentiSelezionati?.get(0))
                    Window wEsito = Executions.createComponents(ESITO_POPUP, self, [esitoSmartDesktopList: esitoSmartDesktopList, descrizioneTipoDocumento: descrizioneTipoDocumento])
                    wEsito.onClose {
                        onRefresh()
                    }
                    wEsito.doModal()
                }

            } catch (Exception e) {
                // impedisco la chiusura della popup e segnalo l'errore che è avvenuto
                event.stopPropagation()
                throw e
            }

        }
        w.doModal()
    }

    @Command
    void onInCarico() {
        List<EsitoSmartDesktop> esitoSmartDesktopList = []

        List<SmistamentoDTO> listaSmistamentiSelezionati = estraiSmistamentiSelezionati()

        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCarico(documento, smistamento.idDocumentoEsterno)
            esitoSmartDesktopList.add(esitoSmartDesktop)
        }

        if (esitoSmartDesktopList.size() > 0) {
            String descrizioneTipoDocumento = getDescrizioneTipoDocumento(listaSmistamentiSelezionati?.get(0))
            Window wEsito = Executions.createComponents(ESITO_POPUP, self, [esitoSmartDesktopList: esitoSmartDesktopList, descrizioneTipoDocumento: descrizioneTipoDocumento])
            wEsito.onClose {
                onRefresh()
            }
            wEsito.doModal()
        }

    }

    @Command
    void onEsegui() {
        List<EsitoSmartDesktop> esitoSmartDesktopList = []

        List<SmistamentoDTO> listaSmistamentiSelezionati = estraiSmistamentiSelezionati()

        for (SmistamentoDTO smistamento : listaSmistamentiSelezionati) {
            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoEdEsegui(documento, smistamento.idDocumentoEsterno)
            esitoSmartDesktopList.add(esitoSmartDesktop)
        }

        if (esitoSmartDesktopList.size() > 0) {
            String descrizioneTipoDocumento = getDescrizioneTipoDocumento(listaSmistamentiSelezionati?.get(0))
            Window wEsito = Executions.createComponents(ESITO_POPUP, self, [esitoSmartDesktopList: esitoSmartDesktopList, descrizioneTipoDocumento: descrizioneTipoDocumento])
            wEsito.onClose {
                onRefresh()
            }
            wEsito.doModal()
        }

    }

    @Command
    void onCreaFascicolo() {
        if (!privilegioUtenteService.isCreaFascicolo()) {
            Clients.showNotification("Non è possibile creare un fascicolo. Utente non abilitato.", Clients.NOTIFICATION_TYPE_WARNING, null, "top_center", 3000, true)
            return
        }

        Window w = Executions.createComponents("/titolario/fascicoloDettaglio.zul", self, [id: -1, isNuovoRecord: true, standalone: false, titolario: null, duplica: false])
        w.onClose {
            onRefresh()
        }
        w.doModal()
    }

    @Command
    void onAggiungiFascicoloClassifica() {
        String richiesta = "Aggiungi in Fascicolo"
        List<EsitoSmartDesktop> esitoSmartDesktopList = []

        List<SmistamentoDTO> listaSmistamentiSelezionati = estraiSmistamentiSelezionati()

        Window w = (Window) Executions.createComponents("/commons/popupRicercaFascicolo.zul", null, [classificazione: null, fascicolo: null])
        w.doModal()
        w.onClose { Event event ->
            if (event.data != null) {
                listaSmistamentiSelezionati.each {
                    Documento documento = it.documento.domainObject
                    if (documento) {
                        try {

                            if (documento.classificazione == null) {
                                try {
                                    Fascicolo fascicolo = event.data.fascicolo?.domainObject
                                    fascicoloService.associaClassificaEFascicoloAProtocollo(documento.id, fascicolo.classificazione, fascicolo)
                                    String messaggio = "Aggiunta in fascicolo terminata con successo"
                                    EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, true)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                                catch (RuntimeException e) {
                                    String messaggio = ""
                                    if (e.cause) {
                                        messaggio = e.cause.localizedMessage
                                    }
                                    messaggio = e.message
                                    EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, false)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                            } else {
                                Fascicolo fascicolo = event.data.fascicolo?.domainObject
                                DocumentoTitolario dt = documentoTitolarioService.getDocumentoTitolario(documento?.id, fascicolo?.id, fascicolo.classificazione?.id)
                                if (!dt) {
                                    DocumentoTitolario dts = fascicoloService.salvaFascicoloSecondario(documento, fascicolo, fascicolo.classificazione)
                                    // allineo i dati su GDM
                                    protocolloGdmService.fascicolaTitolarioSecondario(dts)
                                    String messaggio = "Inserimento in Fascicolo terminato con successo"
                                    EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, true)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                            }

                        } catch (Exception e) {
                            String messaggio = ""
                            if (e.cause) {
                                messaggio = e.cause.localizedMessage
                            }
                            messaggio = e.message
                            EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, false)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }

                    } else {
                        String messaggio = "Non presente in archivio Agspr"
                        EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, false)
                        esitoSmartDesktopList.add(esitoSmartDesktop)
                    }
                }
                if (esitoSmartDesktopList.size() > 0) {
                    String descizioneTipoDocumento = "Documento"
                    Window wEsito = Executions.createComponents(ESITO_POPUP, self, [esitoSmartDesktopList: esitoSmartDesktopList, descrizioneTipoDocumento: descizioneTipoDocumento])
                    wEsito.onClose {
                        onRefresh()
                    }
                    wEsito.doModal()
                }
                onRefresh()
            }
        }
    }

    @Command
    void onModificaFascicoloClassifica() {
        String richiesta = "Modifica Fascicolo/Classificazione"
        List<EsitoSmartDesktop> esitoSmartDesktopList = []
        List<SmistamentoDTO> listaSmistamentiSelezionati = estraiSmistamentiSelezionati()

        Window w = (Window) Executions.createComponents("/commons/popupRicercaFascicolo.zul", null, [classificazione: null, fascicolo: null])
        w.doModal()
        w.onClose { Event event ->
            if (event.data != null) {
                listaSmistamentiSelezionati.each {
                    Documento documento = it.documento.domainObject
                    if (documento) {
                        if (documento.fascicolo != null) {
                            try {
                                Fascicolo fascicolo = event.data.fascicolo?.domainObject
                                fascicoloService.associaClassificaEFascicoloAProtocollo(documento.id, fascicolo.classificazione, fascicolo)
                                String messaggio = "Modifica in fascicolo terminata con successo"
                                EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, true)
                                esitoSmartDesktopList.add(esitoSmartDesktop)
                            }
                            catch (RuntimeException e) {
                                String messaggio = ""
                                if (e.cause) {
                                    messaggio = e.cause.localizedMessage
                                }
                                messaggio = e.message
                                EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, false)
                                esitoSmartDesktopList.add(esitoSmartDesktop)
                            }
                        } else {
                            String messaggio = "Impossibile modificare fascicolo: Fascicolo originario non presente. Provare con Aggiungi in Fascicolo."
                            EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, false)
                            esitoSmartDesktopList.add(esitoSmartDesktop)
                        }
                    } else {
                        String messaggio = "Non presente in archivio Agspr"
                        EsitoSmartDesktop esitoSmartDesktop = costruisciEsito(richiesta, descrizioneEsitoIterDoc(it), messaggio, false)
                        esitoSmartDesktopList.add(esitoSmartDesktop)
                    }
                }

                if (esitoSmartDesktopList.size() > 0) {
                    String descizioneTipoDocumento = "Documento"
                    Window wEsito = Executions.createComponents(ESITO_POPUP, self, [esitoSmartDesktopList: esitoSmartDesktopList, descrizioneTipoDocumento: descizioneTipoDocumento])
                    wEsito.onClose {
                        onRefresh()
                    }
                    wEsito.doModal()
                }
                onRefresh()
            }
        }
    }

    private EsitoSmartDesktop costruisciEsito(String richiesta, String descrizione, String messaggio, boolean success) {
        EsitoSmartDesktop esitoSmartDesktop = new EsitoSmartDesktop()
        esitoSmartDesktop.setRichiesta(richiesta)
        EsitoTask esitoTask = new EsitoTask()
        esitoTask.successo = success
        esitoSmartDesktop.setDescrizione(descrizione)
        esitoTask.messaggio = messaggio
        esitoSmartDesktop.esitoTasks.add(esitoTask)
        return esitoSmartDesktop
    }

    private String descrizioneEsitoIterDoc(SmistamentoDTO smistamento) {
        String descrizione = ""
        if (smistamento.isMessaggioRicevuto()) {
            descrizione = "Messaggio del: " + smistamento.documento.dataRicezione + " - " + smistamento.documento.oggetto
        } else if (smistamento.isProtocollo() && smistamento.documento.numero > 0) {
            descrizione = "PG: " + smistamento.documento.annoNumeroProtocollo + " - " + smistamento.documento.oggetto
        } else if (smistamento.isFascicolo()) {
            descrizione = "Fascicolo: " + smistamento.documento.classificazione?.codice + " - " + smistamento.documento.anno + "/" + smistamento.documento.numero
        } else {
            descrizione = "Documento del: " + smistamento.documento.dateCreated + " - " + smistamento.documento.oggetto
        }
        return descrizione
    }

    private List<SmistamentoDTO> estraiSmistamentiSelezionati() {
        List<SmistamentoDTO> listaSmistamentiSelezionati = new ArrayList<SmistamentoDTO>()
        for (Listitem item : listbox.getSelectedItems()) {
            listaSmistamentiSelezionati.add(item.value)
        }
        return listaSmistamentiSelezionati
    }


    @Command
    void onVisualizzaTuttiDestinatari(@BindingParam("destinatari") List<String> destinatari, @BindingParam("descr") String descr) {
        Window popupDestinatari = Executions.createComponents(POPUP_DESTINATARI, self, [destinatari: destinatari, descr: descr])
        popupDestinatari.doModal()
    }

    @Command
    void caricaLista(@BindingParam("codiceTab") String codiceTab) {

        settaTab(codiceTab)

        //carico solo se ho selezionato un'unita' organizzativa
        if (unitaOrganizzativa != null && unitaOrganizzativa.codice != null) {

            List<Smistamento> documentiIter = new ArrayList<Smistamento>()
            List<String> statoSmistamento = new ArrayList<String>()

            //verifica privilegi e assegnatari a seconda dello stato in cui mi trovo
            if (daRicevere) {
                statoSmistamento = [Smistamento.DA_RICEVERE]
            } else if (inCarico || assegnati) {
                statoSmistamento = [Smistamento.IN_CARICO]
            }

            documentiIter = smistamentoService.getDocumentiIterDaSmistamentoByStatoSmistamento(testoCerca, unitaOrganizzativa, statoSmistamento, tipoOggettoDaEscludereIncludere, daRicevere, assegnati, inCarico)

            //Paginazione del risultato
            PageRequest pageable = new PageRequest(activePage, pageSize)
            int max = (pageSize * (activePage + 1) > documentiIter?.size()) ? documentiIter?.size() : pageSize * (activePage + 1)
            //Nota: La prossima istruzione genera il seguente warning HHH000179: Narrowing proxy to class it.finmatica.protocollo.documenti.Protocollo - this operation breaks ==
            //dovuto al fatto che documento è un polimorfismo. Il warning lo ignoro in quanto queste info mi servono solo nel dto per visualizzarle.
            //Valutare una strategia altenativa qualora servissero per altre logiche in quanto puo' parte al non corretto funzionamento dei metodi equals() e hashCode().
            //Rif (https://marcin-chwedczuk.github.io/HHH000179-narrowing-proxy-to-class-this-operation-breaks-equality)
            List<SmistamentoDTO> documentiIterDTOFinal = documentiIter?.toDTO()
            lista = new PageImpl<SmistamentoDTO>(documentiIterDTOFinal.subList(activePage * pageSize, max), pageable, documentiIterDTOFinal.size())
            for (SmistamentoDTO smistamentoDTO : lista.content) {
                //NON aggiorno i messeggi vecchi (la conversione in dto perde le info)
                if (!smistamentoDTO.isMessaggioRicevuto() || (smistamentoDTO.isMessaggioRicevuto() && (smistamentoDTO.documento?.idMessaggioSi4Cs != null || smistamentoDTO.documento?.idMessaggioSi4Cs > 0))) {
                    smistamentoDTO.documento = iterDocumentaleService.getDocumentoPerSmistamento(smistamentoDTO?.documento?.id)?.toDTO("classificazione", "fascicolo", "corrispondenti", "tipoProtocollo")
                }
            }
            totalSize = documentiIterDTOFinal.size()

            BindUtils.postNotifyChange(null, null, this, "selected")
            BindUtils.postNotifyChange(null, null, this, "lista")
            BindUtils.postNotifyChange(null, null, this, "totalSize")
            BindUtils.postNotifyChange(null, null, this, "activePage")
        } else {
            return
        }

    }

    private void caricaUnitaOrganizzativa() {
        listaUnita = []
        So4UnitaPubbDTO unitaIter = preferenzeUtenteService.getUnitaIter()?.toDTO()

        listaUnita = strutturaOrganizzativaProtocolloService.ricercaUnitaIter("", 0, 0, springSecurityService.principal.id, springSecurityService.principal.ottica().codice).toDTO()
        //se ne ho una sola metto quella
        if (listaUnita.size() == 1) {
            unitaOrganizzativa = listaUnita[0]
            selectedIndexUnita = 0
        }
        //In caso ne ho più di una seleziono quella scelta nelle preferenze UnitaIter
        else if (listaUnita.size() > 1) {
            if (unitaIter != null) {
                int indexSelezione = 0
                boolean unitaPresente = false
                for (So4UnitaPubbDTO unita : listaUnita) {
                    if (unita.progr == unitaIter.progr) {
                        unitaOrganizzativa = unita
                        selectedIndexUnita = indexSelezione + 1
                        unitaPresente = true
                        listaUnita.add(0, (new So4UnitaPubb(progr: -1, descrizione: "")).toDTO())
                        break
                    }
                    indexSelezione++
                }
                //se la preferenze non è tra quelle in lista (puo' succedere ? ) nel caso lo gestisco senza valorizzare il default
                if (!unitaPresente) {
                    generaPrimaRigaComboUO()
                }
            }
            //se non ho scelto nessuna preferenza allora non seleziono nulla
            else {
                generaPrimaRigaComboUO()
            }
        }
    }

    private void generaPrimaRigaComboUO() {
        listaUnita.add(0, (new So4UnitaPubb(progr: -1, descrizione: "")).toDTO())
        unitaOrganizzativa = listaUnita[0]
        selectedIndexUnita = 0
    }

    void settaTab(String codiceTab) {
        switch (codiceTab) {
            case CODICE_TAB_DA_RICEVERE:
                daRicevere = true
                inCarico = false
                assegnati = false
                msgNoDocumentiPerTab = "Da Ricevere"
                break
            case CODICE_TAB_IN_CARICO:
                inCarico = true
                daRicevere = false
                assegnati = false
                msgNoDocumentiPerTab = "In Carico"
                break
            case CODICE_TAB_ASSEGNATI:
                assegnati = true
                daRicevere = false
                inCarico = false
                msgNoDocumentiPerTab = "Assegnati"
                break
            default:
                break
        }

        BindUtils.postNotifyChange(null, null, this, "assegnati")
        BindUtils.postNotifyChange(null, null, this, "daRicevere")
        BindUtils.postNotifyChange(null, null, this, "inCarico")
        BindUtils.postNotifyChange(null, null, this, "msgNoDocumentiPerTab")
    }

    @Command
    void onCodiceABarre(@BindingParam("codiceABarre") String codiceABarre) {
        ricercaPerCodiceABarre(codiceABarre)
    }

    void ricercaPerCodiceABarre(String codiceABarre) {
        if (!validaCodiceABarre(codiceABarre)) {
            return
        }

        List<EsitoSmartDesktop> esitoSmartDesktopList = []

        List<Smistamento> documentiIter = new ArrayList<Smistamento>()

        //verifica privilegi e assegnatari a seconda dello stato in cui mi trovo
        List<String> statoSmistamento = [Smistamento.DA_RICEVERE]

        documentiIter = smistamentoService.getDocumentiPerCodiceABarre(unitaOrganizzativa, statoSmistamento, tipoOggettoDaEscludereIncludere, daRicevere, assegnati, inCarico, Long.valueOf(codiceABarre))

        List<SmistamentoDTO> documentiIterDto = documentiIter?.toDTO("documento.classificazione", "documento.corrispondenti")

        for (SmistamentoDTO smistamento : documentiIterDto) {
            ISmistabileDTO documento = Documento.get(smistamento?.documento?.id)?.toDTO()
            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCarico(documento, smistamento.idDocumentoEsterno)
            esitoSmartDesktopList.add(esitoSmartDesktop)
        }

        if (esitoSmartDesktopList.size() > 0) {
            String descrizioneTipoDocumento = getDescrizioneTipoDocumento(documentiIterDto?.get(0))
            Window wEsito = Executions.createComponents(ESITO_POPUP, self, [esitoSmartDesktopList: esitoSmartDesktopList, descrizioneTipoDocumento: descrizioneTipoDocumento])
            wEsito.onClose {
                onRefresh()
            }
            wEsito.doModal()
        }
    }

    @Command
    @NotifyChange(["abilitaPrendiInCaricoCodiceABarre", "abilitaCreaFascicolo"])
    void abilitaPulsanti() {
        abilitaPrendiInCaricoCodiceABarre = unitaOrganizzativa?.progr != -1
        //verifica ed eventualmente abilita la crezione fascicoli solo se ho selezionato una unita'
        abilitaCreaFascicolo = unitaOrganizzativa?.progr != -1 ? privilegioUtenteService.isCreaFascicolo() : false
        //resetto la lista
        lista = null
        selected = null
        activePage = 0
        totalSize = 0

        BindUtils.postNotifyChange(null, null, this, "selected")
        BindUtils.postNotifyChange(null, null, this, "lista")
        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
        BindUtils.postNotifyChange(null, null, this, "abilitaPrendiInCaricoCodiceABarre")
        BindUtils.postNotifyChange(null, null, this, "abilitaCreaFascicolo")

    }


    boolean validaCodiceABarre(String codiceABarre) {

        if (codiceABarre == "") {
            Clients.showNotification("Inserire un codice a barre per la ricerca", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return false
        }

        try {
            if (codiceABarre != "") {
                Integer.parseInt(codiceABarre)
            }
        }
        catch (NumberFormatException nfe) {
            Clients.showNotification("È possibile inserire solo numeri nel campo 'Codice a Barre'", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return false
        }

        return true
    }

    String getDescrizioneTipoDocumento(SmistamentoDTO smistamentoDTO) {
        String descrizioneTipoDocumento = "Documento"
        if (smistamentoDTO?.isFascicolo()) {
            descrizioneTipoDocumento = "Fascicolo"
        }
        return descrizioneTipoDocumento
    }


    String dateToString(Date date) {
        return date ? fdfData.format(date) : ''
    }

    String dateTimeToString(Date date) {
        return date ? fdfDataOra.format(date) : ''
    }

    /* GESTIONE MENU ALLEGATO */

    boolean visGraffettaDownloadAllegato(DocumentoDTO documento) {
        caricaListaFileAllegati(documento)
        if (listaFilesAllegato.size() > 0) {
            return true
        } else {
            return false
        }
    }

    @Command
    void onMostraAllegati(@BindingParam("documento") documento) {
        caricaListaFileAllegati(documento)
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileAllegato") value) {
        fileDownloader.downloadFileAllegato(value.documento?.toDTO(), FileDocumento.get(value.id), false)
    }

    void caricaListaFileAllegati(DocumentoDTO documento) {
        listaFilesAllegato = []
        listaAllegati = []

        listaFilesAllegato = allegatoProtocolloService.getAllegatiByIdAndCodice(documento.id, FileDocumento.CODICE_FILE_PRINCIPALE)
        Documento documentoDomain = documento.domainObject
        if (documentoDomain) {
            listaAllegati = documento.domainObject?.allegati?.toDTO(["tipoAllegato"]).sort { it.sequenza }
        }
        for (AllegatoDTO allegato : listaAllegati) {
            listaFilesAllegato.addAll(allegatoProtocolloService.getAllegatiByIdAndCodice(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO))
        }
        BindUtils.postNotifyChange(null, null, this, "listaFilesAllegato")
    }
}
