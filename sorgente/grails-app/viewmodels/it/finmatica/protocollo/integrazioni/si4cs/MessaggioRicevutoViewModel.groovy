package it.finmatica.protocollo.integrazioni.si4cs

import commons.PopupInserisciTitolarioViewModel
import commons.menu.MenuItem
import commons.menu.MenuItemMessaggioArrivo
import commons.menu.MenuItemProtocollo
import groovy.util.logging.Slf4j
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.commons.AbstractViewModel
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggettoDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.MessaggioDTO
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.DocumentoCollegatoProtocolloService
import it.finmatica.protocollo.documenti.DocumentoCollegatoRepository
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.ProtocolloEsternoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.titolario.FascicoloService
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.zk.components.smistamenti.SmistamentiComponent
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang.StringUtils
import org.hibernate.FetchMode
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Filedownload
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class MessaggioRicevutoViewModel extends AbstractViewModel<MessaggioRicevuto> {

    @WireVariable
    private MessaggiRicevutiService messaggiRicevutiService
    @WireVariable
    private MessaggiRicevutiMenuItemService messaggiRicevutiMenuItemService
    @WireVariable
    private DocumentaleService documentaleService
    @WireVariable
    private TipologiaSoggettoService tipologiaSoggettoService
    @WireVariable
    private SmistamentoService smistamentoService
    @WireVariable
    private TitolarioService titolarioService
    @WireVariable
    private FascicoloService fascicoloService
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    private DocumentoCollegatoRepository documentoCollegatoRepository
    @WireVariable
    private DocumentoCollegatoProtocolloService documentoCollegatoProtocolloService

    // componenti
    Window self
    @Wire("#menuFunzionalita")
    MenuItemMessaggioArrivo menuFunzionalita
    @Wire("#smistamenti")
    SmistamentiComponent smistamentoComponent

    //dati
    MessaggioRicevutoDTO messaggioRicevuto
    MessaggioDTO messaggioDTO

    // mappa dei soggetti (usata solo per l'uo protocollante la prima volta che si salva)
    Map soggetti = [:]
    Map competenze

    List<SmistamentoDTO> listaSmistamentiDto = []
    List<SmistamentoDTO> listaSmistamentiStoriciDto

    List<DocumentoTitolarioDTO> listaTitolari
    Set<DocumentoCollegatoDTO> listaCollegamenti = [] as Set

    //Per i collegamenti
    Integer annoProtoCollegato
    Integer numeroProtoCollegato
    TipoRegistroDTO tipoRegistroProtoCollegato

    boolean riservatoDaFascicolo
    boolean abilitaRiservato
    boolean riservatoModificabile
    boolean haTitolari = false
    boolean haRicongiungiAFascicolo = false

    boolean unitaModificabilePrimaDiSalvataggio

    // privilegi
    boolean eliminaDaClassificheSecondarie = true
    boolean inserimentoInClassificheSecondarie = true
    boolean inserimentoInFascicoliAperti = true

    static Window apriPopup(Map parametri) {
        Window window
        window = (Window) Executions.createComponents("/protocollo/integrazioni/si4cs/messaggioRicevuto.zul", null, parametri)
        window.doModal()
        return window
    }

    @Init
    @NotifyChange(["messaggioDettaglio", "messaggioRicevuto"])
    void init(@ContextParam(ContextType.COMPONENT) Window w,
              @ExecutionArgParam("idMessaggio") String idMsg) {
        this.self = w

        MessaggioRicevuto messaggioRicevutoDomain = messaggiRicevutiService.getMessaggioRicevutoById(Long.parseLong(idMsg))

        if (ImpostazioniProtocollo.TIPO_REGISTRO.valore != "") {
            tipoRegistroProtoCollegato = TipoRegistro.findByCodice(ImpostazioniProtocollo.TIPO_REGISTRO.valore)?.toDTO()
        }

        abilitaRiservato = ImpostazioniProtocollo.RISERVATO.abilitato

        refreshMessaggio(messaggioRicevutoDomain)

        if (messaggioRicevuto == null) {
            Clients.showNotification("Il messaggio risulta cancellato o non esiste!", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
            onChiudi()
            return
        }

        refreshSmistamenti()
        refreshListaCollegamenti()
        soggetti = messaggioRicevuto.soggetti.collectEntries {
            [(it.tipoSoggetto): [modificato    : true
                                 , tipoSoggetto: it.tipoSoggetto
                                 , descrizione : (it.tipoSoggetto == 'REDATTORE' ? (it.utenteAd4?.nominativoSoggetto == null) ? it.utenteAd4?.nominativo : it.utenteAd4?.nominativoSoggetto : it.unitaSo4?.descrizione)
                                 , utente      : it.utenteAd4
                                 , unita       : it.unitaSo4]]
        }

        if (soggetti?.REDATTORE?.utente == null) {
            Ad4Utente utenteLogin = springSecurityService.principal.utente
            soggetti.REDATTORE.utente = utenteLogin.toDTO()
            soggetti.REDATTORE.modificato = true
            soggetti.REDATTORE.descrizione = (utenteLogin?.nominativoSoggetto == null) ? utenteLogin?.nominativo : utenteLogin?.nominativoSoggetto
        }
        List<So4UnitaPubb> listaUo
        if (soggetti?.UO_MESSAGGIO?.unita == null) {
            unitaModificabilePrimaDiSalvataggio = true
            listaUo = tipologiaSoggettoService.calcolaListaSoggetti(idTipologiaProtocollo, messaggioDTO.domainObject, null, TipoSoggetto.UO_MESSAGGIO, "")
            if (listaUo != null && listaUo?.size() > 0) {
                listaUo.sort { it.descrizione }
                soggetti.UO_MESSAGGIO.unita = listaUo.get(0).toDTO()
                soggetti.UO_MESSAGGIO.modificato = true
                soggetti.UO_MESSAGGIO.descrizione = listaUo.get(0).descrizione
            }
        } else {
            unitaModificabilePrimaDiSalvataggio = false
        }

        if (!competenze.lettura) {
            Clients.showNotification("Non si possiedono le competenze di lettura per il documento.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
            onChiudi()
            return
        }

        if (!messaggioRicevuto.valido) {
            Clients.showNotification("Il messaggio risulta cancellato!", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
            onChiudi()
            return
        }
    }

    @Command
    void onApriTestoMessaggio() {
        Window window = (Window) Executions.createComponents("/commons/popupTestoMessaggio.zul", null, [testo: messaggioRicevuto.testo?.replaceAll("\r\n", "<BR>")])
        window.doModal()
    }

    @Command
    void onSelectFascicolo() {

        if (messaggioRicevuto.fascicolo?.id == -1) {
            messaggioRicevuto.fascicolo = null
        }

        // se il protocollo è già riservato non c'è bisogno di controllare la riservatezza dal fascicolo
        MessaggioRicevuto object = messaggioRicevuto.domainObject
        if (!messaggioRicevuto.riservato) {
            // se cambia il valore aggiorno la maschera
            if (riservatoDaFascicolo != messaggioRicevuto.fascicolo?.riservato) {
                if (messaggioRicevuto.idDocumentoEsterno == null) {

                    if (!salvaRiservato()) {
                        messaggioRicevuto.fascicolo = null
                    }
                    return
                }
                // verifico che l'utente possa gestire il riservato:
                riservatoModificabile = (!(object.riservato && riservatoDaFascicolo) || gestoreCompetenze.utenteCorrenteVedeRiservato(object))
                BindUtils.postNotifyChange(null, null, this, "riservatoDaFascicolo")
                BindUtils.postNotifyChange(null, null, this, "riservatoModificabile")
            }
        }

        haRicongiungiAFascicolo = fascicoloService.verificaRicongiungiAFascicolo(object)
        BindUtils.postNotifyChange(null, null, this, "haRicongiungiAFascicolo")
    }

    String getStatoMessaggioRicevuto() {
        return messaggioRicevuto?.statoMessaggio?.descrizione
    }

    void onSalvaRiservato() {
        if (!salvaRiservato()) {
            messaggioRicevuto.riservato = false
            BindUtils.postNotifyChange(null, null, this, "messaggioRicevuto")
        }
    }

    @Command
    private boolean salvaRiservato() {
        if (messaggioRicevuto.idDocumentoEsterno == null) {
            Collection<String> messaggiValidazione = validaMaschera()
            if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
                ClientsUtils.showError(StringUtils.join(messaggiValidazione, "\n"))
                return false
            }
            onSalva(false)
            return true
        }
        return true
    }

    @Command
    void onSalva(@BindingParam("refresh") boolean refresh) {
        if (!competenze.modifica) {
            return
        }

        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            ClientsUtils.showError(StringUtils.join(messaggiValidazione, "\n"))
            return
        }

        if (refresh) {
            aggiornaMaschera(messaggioRicevuto.domainObject)
        }

        //if (messaggioRicevuto.id == null) {
        caricaDtoSoggetti()
        //}

        gestisciStatoMessaggio()
        messaggioRicevuto = messaggiRicevutiService.salva(messaggioRicevuto, listaTitolari)

        if (soggetti?.UO_MESSAGGIO?.unita != null) {
            unitaModificabilePrimaDiSalvataggio = false
        }

        ClientsUtils.showInfo("Documento salvato.")

        aggiornaMaschera(messaggioRicevuto.domainObject)
    }

    @Command
    void onElimina() {
        if (!competenze.cancellazione) {
            return
        }

        Messagebox.show("Sei veramente sicuro di voler eliminare il messaggio?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (e.getName() == Messagebox.ON_OK) {
                messaggiRicevutiService.eliminaMessaggio(messaggioRicevuto.domainObject)
                onChiudi()
            }
        }
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileDocumento") fileDocumento) {
        File file = new File()
        file.setId("" + fileDocumento.idFileEsterno)

        file = documentaleService.getFile(new Documento(), file)

        Filedownload.save(file.getInputStream(), file.getContentType(), file.getNome())
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onOpenInformazioniUtente() {
        Executions.createComponents("/commons/informazioniUtente.zul", null, null).doModal()
    }

    @Command
    void onInserisciTitolario() {
        if (messaggioRicevuto.id == null) {
            Clients.showNotification("Prima di aggiungere posizioni archivistiche secondarie è necessario registrare.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
            return
        }

        PopupInserisciTitolarioViewModel.apri(self, listaTitolari, messaggioRicevuto).addEventListener(Events.ON_CLOSE) { Event event ->
            if (event.data != null) {
                List<DTO> selectedTitolari = event.data
                DocumentoTitolarioDTO documentoTitolarioDTO

                for (DTO titolario : selectedTitolari) {
                    if (titolario instanceof FascicoloDTO) {
                        FascicoloDTO fascicolo = titolario
                        ClassificazioneDTO classificazione = titolario.classificazione
                        documentoTitolarioDTO = new DocumentoTitolarioDTO(fascicolo: fascicolo, classificazione: classificazione, documento: messaggioRicevuto)
                    } else {
                        documentoTitolarioDTO = new DocumentoTitolarioDTO(classificazione: titolario, documento: messaggioRicevuto)
                    }

                    listaTitolari.add(documentoTitolarioDTO)
                }

                onSalva(false)
            }
        }
    }

    @Command
    void onEliminaTitolario(@BindingParam("titolario") titolario) {
        titolarioService.remove(messaggioRicevuto, titolario)
        messaggioRicevuto.version = messaggioRicevuto.domainObject.version
        listaTitolari.remove(titolario)
        BindUtils.postNotifyChange(null, null, this, "listaTitolari")
    }

    @Command
    void onEliminaDocumentoCollegato(@BindingParam("documentoCollegato") DocumentoCollegatoDTO documentoCollegato) {
        Messagebox.show("Eliminare il collegamento selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (e.getName() == Messagebox.ON_OK) {
                messaggiRicevutiService.eliminaDocumentoCollegato(messaggioRicevuto.domainObject, documentoCollegato.collegato.domainObject, documentoCollegato.tipoCollegamento.codice)
                messaggioRicevuto.version = messaggioRicevuto.domainObject.version
                refreshListaCollegamenti()
                refreshMessaggio(messaggioRicevuto.domainObject)
                onSalva(false)
            }
        }
    }

    @Command
    void onRicercaCollegato(@BindingParam("annoSearch") String anno, @BindingParam("numeroSearch") String numero) {
        ricercaCollegato(anno, numero, tipoRegistroProtoCollegato)
    }

    @Command
    void onAggiornaMaschera() {
        aggiornaMaschera(messaggioRicevuto.domainObject)
    }

    @Command
    void onAggiornaSoggetti(@BindingParam("unita") unita) {
        if (unita != null) {
            soggetti?.UO_PROTOCOLLANTE?.unita = unita
        }
    }

    @Command
    void menu(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            ClientsUtils.showError(StringUtils.join(messaggiValidazione, "\n"))
            return
        }

        MenuItem menuitem = (MenuItem) event.data
        switch (menuitem.name) {
            case MenuItemMessaggioArrivo.CREA_PROTOCOLLO:
                if (messaggioRicevuto?.id == null) {
                    Clients.showNotification("Prima di creare il protocollo è necessario registrare.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
                    return
                }

                Protocollo protocollo = messaggiRicevutiService.creaProtocollo(messaggioRicevuto, Protocollo.MOVIMENTO_ARRIVO)
                aggiornaMaschera(messaggioRicevuto.domainObject)

                ProtocolloViewModel.apriPopup(protocollo.id).addEventListener(Events.ON_CLOSE) {
                    onChiudi()
                }

                break
            case MenuItemMessaggioArrivo.SCARTA_MESSAGGIO:
                if (messaggioRicevuto?.id == null) {
                    Clients.showNotification("Prima di scartare il messaggio è necessario registrare.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
                    return
                }

                Messagebox.show("Si procederà a scartare il messaggio. Continuare?", "Attenzione", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                    if (Messagebox.ON_OK == e.getName()) {
                        messaggiRicevutiService.scartaMessaggio(messaggioRicevuto.domainObject)
                        aggiornaMaschera(messaggioRicevuto.domainObject)
                    }
                }
                break
            case MenuItemMessaggioArrivo.CREA_PG_PARTENZA:
                if (messaggioRicevuto?.id == null) {
                    Clients.showNotification("Prima di creare il protocollo in partenza è necessario registrare.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
                    return
                }

                Protocollo protocollo = messaggiRicevutiService.creaProtocollo(messaggioRicevuto, Protocollo.MOVIMENTO_PARTENZA)
                aggiornaMaschera(messaggioRicevuto.domainObject)

                ProtocolloViewModel.apriPopup(protocollo.id).addEventListener(Events.ON_CLOSE) {
                    onChiudi()
                }

                break
            case MenuItemMessaggioArrivo.SCARICA_EML:
                FileDocumentoDTO fileDocumentoDTO = messaggioRicevuto.fileDocumenti?.find {
                    it.nome.toLowerCase() == MessaggioRicevuto.MESSAGGIO_EML
                }
                if (fileDocumentoDTO != null) {
                    onDownloadFileAllegato(fileDocumentoDTO)
                }

                break
            case MenuItemProtocollo.CARICO:
                messaggiRicevutiMenuItemService.onPrendiIncarico(messaggioRicevuto, menuFunzionalita)
                aggiornaMaschera(messaggioRicevuto.domainObject)
                break
            case MenuItemProtocollo.CARICO_ESEGUI:
                messaggiRicevutiMenuItemService.onPrendiIncaricoEsegui(messaggioRicevuto, menuFunzionalita)
                aggiornaMaschera(messaggioRicevuto.domainObject)
                break
            case MenuItemProtocollo.RIPUDIO:
                messaggiRicevutiMenuItemService.onRifiutaSmistamento(messaggioRicevuto, menuFunzionalita)
                aggiornaMaschera(messaggioRicevuto.domainObject)
                break
            case MenuItemProtocollo.FATTO_IN_VISUALIZZA:
            case MenuItemProtocollo.FATTO:
                messaggiRicevutiMenuItemService.onEsegui(messaggioRicevuto, menuFunzionalita)
                aggiornaMaschera(messaggioRicevuto.domainObject)
                break
            case MenuItemProtocollo.APRI_CARICO_ASSEGNA:
            case MenuItemProtocollo.APRI_CARICO_FLEX:
            case MenuItemProtocollo.APRI_ESEGUI_FLEX:
            case MenuItemProtocollo.APRI_ASSEGNA:
            case MenuItemProtocollo.APRI_INOLTRA_FLEX:
                smistamentoComponent.onEvent(new Event(SmistamentiComponent.ON_SELEZIONA_VOCE, smistamentoComponent, menuitem.name))
                aggiornaMaschera(messaggioRicevuto.domainObject)
                break
        }
    }

    @Command
    void onApriDocumentoCollegato(@BindingParam("documentoCollegato") DocumentoDTO documentoCollegato, @BindingParam("tipoCollegamento") String tipo) {
        if (documentoCollegato.class == ProtocolloDTO.class) {
            ProtocolloViewModel.apriPopup(((ProtocolloDTO) documentoCollegato).domainObject.categoriaProtocollo?.codice, documentoCollegato.id).addEventListener(Events.ON_CLOSE) {
                aggiornaMaschera(messaggioRicevuto.domainObject)
            }
        } else {
            documentoCollegatoProtocolloService.apriDocumentoCollegato(messaggioRicevuto.domainObject, documentoCollegato.domainObject, tipo)
        }
    }

    String getUtenteCollegato() {
        return springSecurityService.principal.cognomeNome
    }

    String getUtenteRedattore() {
        messaggioRicevuto.soggetti.find { it.tipoSoggetto == TipoSoggetto.REDATTORE }?.utenteAd4?.nominativoSoggetto
    }

    String getUnitaProtocollante() {
        messaggioRicevuto.soggetti.find { it.tipoSoggetto == TipoSoggetto.UO_PROTOCOLLANTE }?.unitaSo4?.descrizione
    }

    TipologiaSoggetto getTipologiaProtocollo() {
        return TipologiaSoggetto.findByTipoOggetto(WkfTipoOggetto.get(Protocollo.TIPO_DOCUMENTO))
    }

    Long getIdTipologiaProtocollo() {
        return getTipologiaProtocollo()?.id
    }

    boolean isVisibileAssociaProtocollo() {
        if (messaggioRicevuto == null) {
            return false
        }

        return (messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.SCARTATO ||
                messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_GESTIRE ||
                messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.NON_PROTOCOLLATO
        )
    }

    void ricercaCollegato(String anno, String numero, TipoRegistroDTO tipoRegistroProtocollo) {
        if (!verificaParametriDiRicercaProtocollo(anno, numero)) {
            return
        }

        if (messaggiRicevutiService.getProtocolloCollegatoMessaggio(messaggioRicevuto, MessaggiRicevutiService.TIPO_COLLEGAMENTO_PROT_RIFE) != null) {
            Messagebox.show("Attenzione: Esiste già un protocollo collegato al messaggio. Impossibile inserirne un altro")
            return
        }

        if (messaggioRicevuto.id == null) {
            onSalva(false)
        }

        ProtocolloEsternoDTO protocolloEsternoDTO = ProtocolloEsterno.createCriteria().get() {
            eq("anno", Integer.valueOf(anno))
            eq("numero", Integer.valueOf(numero))
            eq("tipoRegistro.codice", tipoRegistroProtocollo.codice)

            isNotNull("anno")
            isNotNull("numero")
            isNotNull("data")

            fetchMode("tipoRegistro", FetchMode.JOIN)
        }?.toDTO()

        if (protocolloEsternoDTO != null) {
            DocumentoCollegatoDTO documentoCollegatoDTO = new DocumentoCollegatoDTO()
            documentoCollegatoDTO.tipoCollegamento = TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_RIFERIMENTO).toDTO()
            TipoProtocollo tipoProcollo = TipoProtocollo.findByCategoria(protocolloEsternoDTO.categoria)
            if (tipoProcollo == null) {
                Messagebox.show("Attenzione: bisogna censire il tipo di Protocollo: " + protocolloEsternoDTO.categoria)
                return
            }
            ProtocolloDTO protocolloCollegatoDto = new ProtocolloDTO(idDocumentoEsterno: protocolloEsternoDTO.idDocumentoEsterno,
                    anno: protocolloEsternoDTO.anno,
                    numero: protocolloEsternoDTO.numero,
                    data: protocolloEsternoDTO.data,
                    oggetto: protocolloEsternoDTO.oggetto, //"Non si dispone dei diritti per visualizzare il documento",
                    tipoProtocollo: tipoProcollo.toDTO(),
                    tipoRegistro: protocolloEsternoDTO.tipoRegistro)

            documentoCollegatoDTO.collegato = protocolloCollegatoDto
            documentoCollegatoDTO.documento = messaggioRicevuto

            messaggiRicevutiService.collegaProtocollo(messaggioRicevuto, documentoCollegatoDTO)
            onSalva(false)
        } else {
            Clients.showNotification("Nessun documento trovato per anno: " + anno + " numero: " + numero + " registro " + tipoRegistroProtocollo.commento, Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return
        }
    }

    public boolean verificaParametriDiRicercaProtocollo(String anno, String numero) {
        try {
            if (anno != "") {
                Integer.parseInt(anno)
            }
            if (numero != "") {
                Integer.parseInt(numero)
            }
        }
        catch (NumberFormatException nfe) {
            Clients.showNotification("È possibile inserire solo numeri nei campi 'anno' e 'numero'", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return false
        }

        if (anno == "" || numero == "" || tipoRegistroProtoCollegato == null || tipoRegistroProtoCollegato?.codice == "") {
            Clients.showNotification("Valorizzare l'anno, il numero e il registro", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return false
        }
        return true
    }

    void refreshSmistamenti() {
        listaSmistamentiDto = smistamentoService.getSmistamentiAttivi(messaggioRicevuto.domainObject).toDTO(["utenteTrasmissione", "unitaTrasmissione", "utentePresaInCarico", "utenteEsecuzione", "utenteAssegnante", "utenteAssegnatario", "utenteRifiuto", "unitaSmistamento"])
        messaggioRicevuto.smistamenti = listaSmistamentiDto

        refreshMenu()

        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiDto")
        BindUtils.postNotifyChange(null, null, this, "messaggioRicevuto")
    }

    private void refreshMessaggio(MessaggioRicevuto messaggioRicevutoDomain) {
        messaggioRicevuto = messaggioRicevutoDomain?.toDTO(["documentiCollegati.*", "statoMessaggio.*", "classificazione.*", "fascicolo.*", "utente", "fileDocumenti", "soggetti", "soggetti.*", "smistamenti.*", "titolari.*"])

        if (messaggioRicevuto == null) {
            return
        }

        messaggioDTO = messaggiRicevutiService.getMessaggioDto(messaggioRicevuto.id)

        listaTitolari = messaggioRicevuto?.titolari?.toList() ?: []
        if (messaggioRicevuto?.titolari == null) {
            listaTitolari = []
        }
        haTitolari = listaTitolari

        if (messaggioRicevuto?.id != null) {
            listaSmistamentiStoriciDto = smistamentoService.getSmistamentiStorici(messaggioRicevuto.id).toDTO(["utenteTrasmissione", "unitaTrasmissione", "utentePresaInCarico", "utenteEsecuzione", "utenteAssegnante", "utenteAssegnatario", "utenteRifiuto", "unitaSmistamento"])
            if (listaSmistamentiStoriciDto == null) {
                listaSmistamentiStoriciDto = []
            }
        } else {
            listaSmistamentiStoriciDto = []
        }

        if (messaggioRicevuto?.classificazione == null) {
            messaggioRicevuto?.classificazione = new ClassificazioneDTO(id: -1)
        }

        if (messaggioRicevuto?.fascicolo == null) {
            messaggioRicevuto?.fascicolo = new FascicoloDTO(id: -1)
        }

        competenze = messaggiRicevutiService.getCompetenze(messaggioRicevutoDomain, TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROT_PEC))
    }

    boolean isUnitaMessaggioModificabile() {
        if (messaggioRicevuto?.id > 0 && (soggetti?.UO_MESSAGGIO?.unita != null) && !unitaModificabilePrimaDiSalvataggio) {
            return false
        }

        return (tipologiaSoggettoService.calcolaListaSoggetti(getIdTipologiaProtocollo(), messaggioRicevuto, null, TipoSoggetto.UO_MESSAGGIO, "").size() != 1)
    }

    @Command
    void onAggiorna(@BindingParam("unita") unita) {
        if (unita != null) {
            soggetti?.UO_MESSAGGIO?.unita = unita
        }
    }

    boolean isTitolarioModificabile() {
        if (messaggioRicevuto?.id == null) {
            return true
        }

        if (messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.SCARTATO ||
                messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.NON_PROTOCOLLATO ||
                messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_GESTIRE
        ) {
            return true
        }

        return false
    }

    int getNumeroAllegati() {
        if (messaggioRicevuto == null) {
            return 0
        } else {
            return messaggioRicevuto.fileDocumenti?.findAll { it.codice != 'FILE_EML' }?.size()
        }
    }

    String getOggettoRiferimento(DocumentoCollegatoDTO documentoCollegatoDTO) {
        if (documentoCollegatoDTO.documento.class == MessaggioInviatoDTO.class) {
            return documentoCollegatoDTO.documento.oggetto
        } else {
            return documentoCollegatoDTO.collegato.oggetto
        }
    }

    private void caricaDtoSoggetti() {

        DocumentoSoggettoDTO documentoSoggettoDTORedattore = new DocumentoSoggettoDTO(tipoSoggetto: TipoSoggetto.REDATTORE,
                attivo: true,
                documento: messaggioRicevuto,
                unitaSo4: null,
                utenteAd4: soggetti[TipoSoggetto.REDATTORE]?.utente
        )

        DocumentoSoggettoDTO documentoSoggettoDTOUoMessaggio = null
        if (soggetti[TipoSoggetto.UO_MESSAGGIO] != null) {
            documentoSoggettoDTOUoMessaggio = new DocumentoSoggettoDTO(tipoSoggetto: TipoSoggetto.UO_MESSAGGIO,
                    attivo: true,
                    documento: messaggioRicevuto,
                    unitaSo4: soggetti[TipoSoggetto.UO_MESSAGGIO]?.unita,
                    utenteAd4: null
            )
        }

        if (documentoSoggettoDTORedattore != null || documentoSoggettoDTOUoMessaggio != null) {
            messaggioRicevuto.soggetti?.clear()
            if (documentoSoggettoDTORedattore != null) {
                messaggioRicevuto.addToSoggetti(documentoSoggettoDTORedattore)
            }
            if (documentoSoggettoDTOUoMessaggio) {
                messaggioRicevuto.addToSoggetti(documentoSoggettoDTOUoMessaggio)
            }
        }
    }

    private void gestisciStatoMessaggio() {
        if (messaggioRicevuto?.id == null) {
            return
        }

        ProtocolloDTO protocolloCollegatoMessaggio = messaggiRicevutiService.getProtocolloCollegatoMessaggio(messaggioRicevuto)

        //Non cambio  mai stato se ho un protocollo collegato....lo stato è quello corretto
        if (protocolloCollegatoMessaggio != null) {
            return
        }

        boolean statoSuccessivo = (messaggioRicevuto.statoMessaggio != MessaggioRicevuto.Stato.DA_GESTIRE &&
                messaggioRicevuto.statoMessaggio != MessaggioRicevuto.Stato.SCARTATO &&
                messaggioRicevuto.statoMessaggio != MessaggioRicevuto.Stato.NON_PROTOCOLLATO &&
                messaggioRicevuto.statoMessaggio != MessaggioRicevuto.Stato.GENERATA_ECCEZIONE) &&
                protocolloCollegatoMessaggio == null

        if ((messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.DA_GESTIRE ||
                messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.SCARTATO ||
                statoSuccessivo) &&
                esisteClassificaFascicoloSmistamento()) {
            messaggioRicevuto.statoMessaggio = MessaggioRicevuto.Stato.NON_PROTOCOLLATO
        } else if ((messaggioRicevuto.statoMessaggio == MessaggioRicevuto.Stato.NON_PROTOCOLLATO ||
                statoSuccessivo) &&
                !esisteClassificaFascicoloSmistamento()) {
            messaggioRicevuto.statoMessaggio = MessaggioRicevuto.Stato.DA_GESTIRE
        }
    }

    private boolean esisteClassificaFascicoloSmistamento() {
        return ((messaggioRicevuto.classificazione != null && messaggioRicevuto.classificazione?.id != -1) ||
                (messaggioRicevuto.fascicolo != null && messaggioRicevuto.fascicolo.id != -1)
                || messaggioRicevuto?.smistamenti?.size() > 0)
    }

    private void refreshListaCollegamenti() {
        // filtro tutto tranne gli allegati
        listaCollegamenti = messaggioRicevuto.domainObject?.documentiCollegati?.toDTO("tipoCollegamento.*")
                ?.findAll { DocumentoCollegatoDTO dto -> dto.tipoCollegamento.codice != TipoCollegamentoConstants.CODICE_TIPO_ALLEGATO }

        DocumentoCollegato documentoCollegatoPadre = documentoCollegatoRepository.collegamentoPadre(messaggioRicevuto.domainObject)
        if (documentoCollegatoPadre != null) {
            listaCollegamenti.add(documentoCollegatoPadre.toDTO())
        }

        BindUtils.postNotifyChange(null, null, this, "listaCollegamenti")
    }

    private void aggiornaPrivilegi(MessaggioRicevutoDTO messaggio) {
        if (messaggio.id > 0) {

            eliminaDaClassificheSecondarie = privilegioUtenteService.eliminaDaClassificheSecondarie
            inserimentoInClassificheSecondarie = privilegioUtenteService.inserimentoInClassificheSecondarie
            inserimentoInFascicoliAperti = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.INSERIMENTO_IN_FASCICOLI_APERTI)

            BindUtils.postNotifyChange(null, null, this, 'eliminaDaClassificheSecondarie')
            BindUtils.postNotifyChange(null, null, this, 'inserimentoInClassificheSecondarie')
            BindUtils.postNotifyChange(null, null, this, 'inserimentoInFascicoliAperti')
        }
    }

    void aggiornaMaschera(MessaggioRicevuto d) {
        if (!d) {
            return
        }

        d = MessaggioRicevuto.get(d.id)
        // prendo il DTO con tutti i campi necessari
        /*this.messaggioRicevuto = d?.toDTO([
                'titolari.fascicolo',
                'titolari.classificazione',
                'smistamenti',
                'smistamenti.utenteAssegnatario',
                'classificazione',
                'fascicolo',
                'fileDocumenti'
        ])*/

        refreshMessaggio(d)

        refreshSmistamenti()

        refreshListaCollegamenti()

        // se il protocollo è già riservato non c'è bisogno di controllare la riservatezza dal fascicolo
        riservatoDaFascicolo = false
        if (messaggioRicevuto.fascicolo?.riservato && !messaggioRicevuto.riservato) {
            riservatoDaFascicolo = true
        } else {
            for (DocumentoTitolarioDTO t : messaggioRicevuto.titolari) {
                if (t.fascicolo?.riservato) {
                    riservatoDaFascicolo = true
                    break
                }
            }
        }

        // verifico che l'utente possa gestire il riservato:
        riservatoModificabile = (!(d.riservato && riservatoDaFascicolo) || gestoreCompetenze.utenteCorrenteVedeRiservato(d))

        soggetti = tipologiaSoggettoService.calcolaSoggettiDto(d)

        aggiornaPrivilegi(messaggioRicevuto)

        refreshMenu()

        BindUtils.postNotifyChange(null, null, this, "listaAllegati")
        BindUtils.postNotifyChange(null, null, this, "messaggioRicevuto")
        BindUtils.postNotifyChange(null, null, this, "messaggioRicevuto.statoMessaggio")
        BindUtils.postNotifyChange(null, null, this, "statoMessaggioRicevuto")
        BindUtils.postNotifyChange(null, null, this, "soggetti")
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiDto")
        BindUtils.postNotifyChange(null, null, this, "listaTitolari")
        BindUtils.postNotifyChange(null, null, this, "unitaMessaggioModificabile")
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiStoriciDto")
        BindUtils.postNotifyChange(null, null, this, "visibileAssociaProtocollo")
        BindUtils.postNotifyChange(null, null, this, "classificaModificabile")
        BindUtils.postNotifyChange(null, null, this, "fascicoloModificabile")
        BindUtils.postNotifyChange(null, null, this, "competenze")
    }

    Collection<String> validaMaschera() {
        List<String> messaggi = []

        if (soggetti[TipoSoggetto.UO_MESSAGGIO]?.unita == null && messaggioRicevuto?.smistamenti?.size() > 0) {
            messaggi << "E' necessario valorizzare l'unità se sul messaggio è presente almeno uno smistamento!"
        }

        if (messaggi.size() > 0) {
            messaggi.add(0, "Impossibile continuare:")
        }
        return messaggi
    }

    MessaggioRicevuto getDocumentoIterabile(boolean controllaConcorrenza) {
        if (messaggioRicevuto?.id > 0) {
            MessaggioRicevuto domainObject = messaggioRicevuto.domainObject
            if (domainObject == null) {
                messaggioRicevuto.id = null
                return new MessaggioRicevuto()
            }
            if (controllaConcorrenza && messaggioRicevuto?.version >= 0 && domainObject.version != messaggioRicevuto?.version) {
                throw new ProtocolloRuntimeException("Attenzione: un altro utente ha modificato il documento su cui si sta lavorando. Impossibile continuare. \n (dto.version=${messaggioRicevuto?.version}!=domain.version=${domainObject?.version})")
            }
            return domainObject
        }

        messaggioRicevuto.id = null
        return new MessaggioRicevuto()
    }

    void aggiornaDocumentoIterabile(MessaggioRicevuto m) {

        for (def s : soggetti) {
            if (s.value == null || s.value?.modificato) {
                m.setSoggetto(s.key, s.value?.utente?.domainObject, s.value?.unita?.domainObject)
            }
        }
    }

    @Override
    WkfCfgIter getCfgIter() {
        return null
    }

    @AfterCompose
    void afterCompose() {
        if (messaggioRicevuto == null) {
            return
        }

        if (!competenze.lettura) {
            return
        }

        Selectors.wireComponents(self, this, false)

        // aggiorno subito il menu funzionalità
        menuFunzionalita.setMessaggioRicevutoDTO(messaggioRicevuto)
        refreshMenu()
    }

    private void refreshMenu() {
        List<String> vociMenu = []

        menuFunzionalita?.refreshMenu(messaggiRicevutiMenuItemService.getVociVisibiliMenu(messaggioRicevuto, competenze))
    }
}