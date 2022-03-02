import commons.PopupSceltaSmistamentiViewModel
import commons.menu.MenuItemProtocollo
import groovy.util.logging.Slf4j
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.protocollo.IterDocumentaleViewModel
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.ListaDistribuzione
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.viste.RiferimentoService
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloGdmService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioInviatoViewModel
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoViewModel
import it.finmatica.protocollo.integrazioni.smartdesktop.EsitoSmartDesktop
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.titolario.ClassificazioneDettaglioViewModel
import it.finmatica.protocollo.titolario.ClassificazioneListaViewModel
import it.finmatica.protocollo.titolario.FascicoloDettaglioViewModel
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.QueryParam
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

/**
 * Questa pagina sottostà al filtro DocumentoGdmFilter che serve per redirigere le chiamate a GDM quando si tenta di aprire
 * un documento che non esiste sul nuovo Protocollo ma esiste sul documentale (ad esempio vecchie Lettere)
 */
@Slf4j
@VariableResolver(DelegatingVariableResolver)
class StandaloneViewModel {

    // services
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private SmistamentoService smistamentoService
    @WireVariable
    private RiferimentoService riferimentoService
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private ProtocolloGdmService protocolloGdmService
    @WireVariable
    private CorrispondenteService corrispondenteService
    @WireVariable
    SessionFactory sessionFactory

    // componenti
    Window self

    private static final EventListener<Event> onCloseEventListener = { Event ->
        Clients.evalJavaScript('''jq(window).unbind(\'beforeunload\');    
                                            var wopener = window.opener;                                                                                                                           
                                            window.open('', '_self', '');                                            
                                            window.close();
                                            if (wopener) {
                                                if (wopener.refreshAPP) {                                                   
                                                    wopener.refreshAPP();
                                                } else {     
                                                    //per evitare l'alert di ricarimento pagina
                                                    //ref: http://stackoverflow.com/questions/4869721/reload-browser-window-after-post-without-prompting-user-to-resend-post-data
                                                    wopener.location.href = wopener.location.pathname+wopener.location.search;        
                                                }
                                            }''')
    }

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w,
              @QueryParam("operazione") String operazione,
              @QueryParam("id") String id,
              @QueryParam("CODICE_LISTA") String codiceLista,
              @QueryParam("tipoDocumento") String categoria,
              @QueryParam("idDoc") String idDocumentoEsterno,
              @QueryParam("idFolder") String idFolder,
              @QueryParam("movimento") String movimento,
              @QueryParam("modalita") String modalita,
              @QueryParam("LISTA_ID") String listaId,
              @QueryParam("PAR_AGSPR_UNITA") String unita,
              @QueryParam("rw") String rw,
              @QueryParam("memo") String memo,
              @QueryParam("file") String pathFile,
              @QueryParam("oggetto") String oggetto,
              @QueryParam("class") String classificazione,
              @QueryParam("numeroFasc") String numeroFascicolo,
              @QueryParam("annoFasc") String annoFascicolo,
              @QueryParam("numeroPrec") String numeroPrecedente,
              @QueryParam("annoPrec") String annoPrecedente,
              @QueryParam("tipoDoc") String schemaProtocollo,
              @QueryParam("mittDest") String corrispondente,
              @QueryParam("anno") String anno,
              @QueryParam("numero") String numero,
              @QueryParam("registro") String registro,
              @QueryParam("idCartProveninez") String idCartProveninez) {

        this.self = w

        Long idDocEsterno = null
        if (idDocumentoEsterno != null && idDocumentoEsterno != "") {
            idDocEsterno = Long.parseLong(idDocumentoEsterno)
        }

        Long idDocFolder = null
        if (idFolder != null && idFolder != "") {
            idDocFolder = Long.parseLong(idFolder)
        }

        // se il documento è un "memo", devo calcolare l'id documento del protocollo "vero"
        // questa cosa serve quando da JDMS viene aperto l'url dalla sezione dei "MEMO", in tal caso, l'url avrà un parametro in più MEMO=Y e il suo idDocumentoEsterno punterà
        // ad un MEMO da cui bisogna risalire al protocollo
        if ('Y'.equalsIgnoreCase(memo)) {
            idDocEsterno = riferimentoService.getIdProtocolloDaMemo(idDocEsterno) ?: idDocEsterno
        }

        log.info("${id ?: ""} ${idDocEsterno} ${categoria} ${operazione} ${movimento ?: ""}")
        log.debug("[Utente loggato] " + springSecurityService.principal.id)

        log.debug("[operazione]: ${operazione}")
        Long idCartella = idCartella(idCartProveninez)
        // switch case di selezione dell'operazione
        switch (operazione) {
            case "APRI_MEMO":
                Messaggio messaggio = Messaggio.findById(Long.parseLong(id))
                if (messaggio.inPartenza) {
                    MessaggioInviatoViewModel.apriPopup([idMessaggio: "" + id]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                }
                else {
                    MessaggioRicevutoViewModel.apriPopup([idMessaggio: "" + id]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                }
                break
            case "APRI_MESSAGGIO_RICEVUTO":
                MessaggioRicevutoViewModel.apriPopup([idMessaggio: "" + id]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                break
            case "APRI_FASCICOLO":
                FascicoloDettaglioViewModel.apriPopup([id: id, isNuovoRecord: false, standalone: true, titolario: null]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                break
            case "APRI_MESSAGGIO_INVIATO":
                MessaggioInviatoViewModel.apriPopup([idMessaggio: "" + id]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                break
            case "APRI_DOCUMENTO":
                Long idDoc = id?.trim()?.length() > 0 ? Long.parseLong(id) : -1
                if (idDocEsterno > 0 && idDoc < 0) {
                    sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
                    Documento documento = Documento.findByIdDocumentoEsterno(idDocEsterno)
                    sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
                    if(!documento.valido){
                        log.error("Documento non esistente")
                        throw new ProtocolloRuntimeException("Documento non esistente")
                    }
                    idDoc = documento?.id ?: -1
                }

                ProtocolloViewModel.apriPopup(idDoc, categoria, movimento, 'R'.equalsIgnoreCase(rw), idCartella).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                break
            case "APRI_PROTOCOLLO_DA_ESTERNO":

                if (!StringUtils.isEmpty(anno) && !StringUtils.isEmpty(numero)) {

                    TipoRegistro tipoRegistro = null
                    if (!StringUtils.isEmpty(registro)) {
                        tipoRegistro = TipoRegistro.get(registro)
                    } else {
                        tipoRegistro = TipoRegistro.get(ImpostazioniProtocollo.TIPO_REGISTRO.valore)
                    }
                    Protocollo pEsterno = protocolloService.findByAnnoAndNumeroAndTipoRegistro(Integer.valueOf(anno), Integer.valueOf(numero), tipoRegistro?.codice)
                    if (pEsterno) {
                        ProtocolloViewModel.apriPopup(pEsterno.id).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                    }
                    return
                }

                List<CorrispondenteDTO> listaCorrispondenti = null
                String ricercaCorrispondenti = null

                if (corrispondente?.size() >= 3) {
                    List<CorrispondenteDTO> listaCorrispondentiDto = corrispondenteService.ricercaDestinatari(corrispondente, false)
                    if (listaCorrispondentiDto?.size() == 1) {
                        listaCorrispondenti = listaCorrispondentiDto
                    } else if (listaCorrispondentiDto?.size() > 1) {
                        ricercaCorrispondenti = corrispondente
                    }
                }

                ProtocolloDTO protocolloEsternoDTO = protocolloService.buildProtocolloFromUrl(listaCorrispondenti, pathFile, oggetto, modalita,
                        classificazione, numeroFascicolo, annoFascicolo,
                        schemaProtocollo,
                        numeroPrecedente, annoPrecedente)

                if (protocolloEsternoDTO.idDocumentoEsterno) {
                    ProtocolloViewModel.apri([id: protocolloEsternoDTO.id, ricercaCorrispondenti: ricercaCorrispondenti]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                    return
                } else {
                    ProtocolloViewModel.apri([protocollo: protocolloEsternoDTO, ricercaCorrispondenti: ricercaCorrispondenti]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                    return
                }
                break
            case "DA_FIRMARE":
                Window window = creaPopup("/protocollo/index.zul", [codiceTab: 'da_firmare']).doModal()
                break

            case "DA_ANNULLARE":
                Window window = creaPopup("/protocollo/index.zul", [codiceTab: 'da_annullare']).doModal()
                break
            case "PEC":
                Window window = creaPopup("/protocollo/index.zul", [codiceTab: 'pec']).doModal()
                break
            case "ITER_DOCUMENTALE":
                Window window = creaPopup("/protocollo/index.zul", [codiceTab: 'iter_documentale']).doModal()
                break
            case "ITER_FASCICOLARE":
                Window window = creaPopup("/protocollo/index.zul", [codiceTab: 'iter_fascicolare']).doModal()
                break
            case "P_DA_RICEVERE":
                Window window = creaPopup("/iterdocumentale/iterDocumentaleIndex.zul", [codiceTab: IterDocumentaleViewModel.CODICE_TAB_DA_RICEVERE, codiceUO: unita, smartDesktop: true]).doModal()
                break
            case "P_IN_CARICO":
                Window window = creaPopup("/iterdocumentale/iterDocumentaleIndex.zul", [codiceTab: IterDocumentaleViewModel.CODICE_TAB_IN_CARICO, codiceUO:unita, smartDesktop: true]).doModal()
                break
            case "P_ASSEGNATI":
                Window window = creaPopup("/iterdocumentale/iterDocumentaleIndex.zul", [codiceTab: IterDocumentaleViewModel.CODICE_TAB_ASSEGNATI, codiceUO:unita, smartDesktop: true]).doModal()
                break
            case "F_DA_RICEVERE":
                Window window = creaPopup("/iterfascicolare/iterFascicolareIndex.zul", [codiceTab: IterDocumentaleViewModel.CODICE_TAB_DA_RICEVERE, codiceUO: unita, smartDesktop: true]).doModal()
                break
            case "F_IN_CARICO":
                Window window = creaPopup("/iterfascicolare/iterFascicolareIndex.zul", [codiceTab: IterDocumentaleViewModel.CODICE_TAB_IN_CARICO, codiceUO: unita, smartDesktop: true]).doModal()
                break
            case "F_ASSEGNATI":
                Window window = creaPopup("/iterfascicolare/iterFascicolareIndex.zul", [codiceTab: IterDocumentaleViewModel.CODICE_TAB_ASSEGNATI,codiceUO: unita, smartDesktop: true]).doModal()
                break
            case "DIZIONARI":
                boolean dizProtocolloVisible = Utils.isUtenteAmministratore() || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_PROTOCOLLO.valore)
                if (!dizProtocolloVisible) {
                    Messagebox.show("L'utente ${springSecurityService.principal.username} non puo' accedere a quest'area", "Attenzione", Messagebox.OK, Messagebox.ERROR)
                    Events.postEvent(Events.ON_CLOSE, self, null)
                    return
                }
                Window window = creaPopup("/dizionari/index.zul", null).doModal()
                break
            case "LISTA_DISTRIBUZIONE":
                Long idLista = ListaDistribuzione.findByCodice(codiceLista)?.id
                Window window = creaPopup("/dizionari/listaDistribuzioneDettaglio.zul", [id: idLista, modificabile: false]).doModal()
                break

            case "LISTE_DISTRIBUZIONE":
                boolean dizProtocolloVisible = Utils.isUtenteAmministratore() || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_PROTOCOLLO.valore) || springSecurityService.principal.hasRuolo("AGPANAG")
                if (!dizProtocolloVisible) {
                    Messagebox.show("L'utente ${springSecurityService.principal.username} non puo' accedere a quest'area", "Attenzione", Messagebox.OK, Messagebox.ERROR)
                    Events.postEvent(Events.ON_CLOSE, self, null)
                    return
                }
                Window window = creaPopup("/dizionari/listaDistribuzioneLista.zul", null).doModal()
                break

            case "MODELLI_TESTO":
                boolean dizProtocolloVisible = Utils.isUtenteAmministratore() || springSecurityService.principal.hasRuolo(ImpostazioniProtocollo.RUOLO_MODELLI_TESTO.valore) || springSecurityService.principal.hasRuolo(Impostazioni.RUOLO_SO4_DIZIONARI_PROTOCOLLO.valore)
                if (!dizProtocolloVisible) {
                    Messagebox.show("L'utente ${springSecurityService.principal.username} non può accedere a quest'area", "Attenzione", Messagebox.OK, Messagebox.ERROR)
                    Events.postEvent(Events.ON_CLOSE, self, null)
                    return
                }
                Window window = creaPopup("/dizionari/gestioneTestiModelloLista.zul", null).doModal()
                break

            case "FASCICOLO":
                String idEsterno = protocolloGdmService.calcolaIdDocFromCartella(idDocFolder) ?: -1
                Long idDocumento = Documento.findByIdDocumentoEsterno(idEsterno)?.id ?: -1
                FascicoloDettaglioViewModel.apriPopup([id: idDocumento, isNuovoRecord: false, standalone: true, titolario: null]).addEventListener(Events.ON_CLOSE, onCloseEventListener)
                break

            case "TITOLARIO":
                ClassificazioneListaViewModel.apriPopup()
                break

            case MenuItemProtocollo.CARICO:

                List<String> idsSmistamenti = listaId?.split("#")
                List<EsitoSmartDesktop> esitoSmartDesktopList = []

                for (String idS : idsSmistamenti) {
                    Long idSmistamentoEsterno = new Long(idS)
                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCarico(documento, idSmistamentoEsterno)
                    esitoSmartDesktopList.add(esitoSmartDesktop)
                }

                if (esitoSmartDesktopList.size() > 0) {
                    Window wEsito = Executions.createComponents("/protocollo/integrazioni/smartDesktop/esitoSmistamenti.zul", self, [esitoSmartDesktopList: esitoSmartDesktopList])
                }
                break;

            case MenuItemProtocollo.CARICO_ESEGUI:

                List<String> idsSmistamenti = listaId?.split("#")
                List<EsitoSmartDesktop> esitoSmartDesktopList = []

                for (String idS : idsSmistamenti) {
                    Long idSmistamentoEsterno = new Long(idS)
                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoEdEsegui(documento, idSmistamentoEsterno)
                    esitoSmartDesktopList.add(esitoSmartDesktop)
                }

                if (esitoSmartDesktopList.size() > 0) {
                    Window wEsito = Executions.createComponents("/protocollo/integrazioni/smartDesktop/esitoSmistamenti.zul", self, [esitoSmartDesktopList: esitoSmartDesktopList])
                }
                break;

            case MenuItemProtocollo.ESEGUI:

                List<String> idsSmistamenti = listaId?.split("#")
                List<EsitoSmartDesktop> esitoSmartDesktopList = []

                for (String idS : idsSmistamenti) {
                    Long idSmistamentoEsterno = new Long(idS)
                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.esegui(documento, idSmistamentoEsterno)
                    esitoSmartDesktopList.add(esitoSmartDesktop)
                }

                if (esitoSmartDesktopList.size() > 0) {
                    Window wEsito = Executions.createComponents("/protocollo/integrazioni/smartDesktop/esitoSmistamenti.zul", self, [esitoSmartDesktopList: esitoSmartDesktopList])
                }
                break;

        /*
        Smistamenti multipli della SmartDesktop
            APRI_CARICO_ASSEGNA
            APRI_ESEGUI_FLEX
            APRI_CARICO_FLEX
            APRI_SMISTA_FLEX
            APRI_ASSEGNA
            APRI_INOLTRA_FLEX
        */

            case MenuItemProtocollo.APRI_CARICO_ASSEGNA:
            case MenuItemProtocollo.APRI_ESEGUI_FLEX:
            case MenuItemProtocollo.APRI_CARICO_FLEX:
            case MenuItemProtocollo.APRI_SMISTA_FLEX:
            case MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX:
            case MenuItemProtocollo.APRI_ASSEGNA:
            case MenuItemProtocollo.APRI_INOLTRA_FLEX:

                List<String> idsSmistamenti = listaId?.split("#")

                String zulPopup = "/commons/popupSceltaSmistamenti.zul"
                if (operazione == MenuItemProtocollo.APRI_ASSEGNA || operazione == MenuItemProtocollo.APRI_CARICO_ASSEGNA) {
                    zulPopup = "/commons/popupSceltaAssegnatari.zul"
                }

                // il controllo se uno smistamento esiste è fatto nel servizio, quindi gli smistamenti correnti non servono in questo caso
                List<SmistamentoDTO> listaSmistamentiDto = new ArrayList<SmistamentoDTO>()

                So4UnitaPubbDTO unitaTrasmissioneDefault = So4UnitaPubb.createCriteria().get {
                    eq("codice", unita)

                    le("dal", new Date())
                    or {
                        isNull("al")
                        ge("al", new Date())
                    }
                }?.toDTO()

                if (unitaTrasmissioneDefault == null) {
                    unitaTrasmissioneDefault = So4UnitaPubb.createCriteria().get {
                        eq("codice", unita)
                        order("al", "desc")
                    }?.toDTO()
                }

                // TODO: controllare se si può smistare o meno per questo tipo nel servizio
                boolean tipoSmistamentoVisibile = false
                boolean smartDesktop = true

                if (operazione == MenuItemProtocollo.APRI_SMISTA_FLEX || operazione == MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX) {
                    tipoSmistamentoVisibile = true
                }

                w = Executions.createComponents(zulPopup, self, [operazione: operazione, smistamenti: listaSmistamentiDto, listaUnitaTrasmissione: new ArrayList([unitaTrasmissioneDefault]), tipoSmistamento: null, unitaTrasmissione: unitaTrasmissioneDefault, tipoSmistamentoVisibile: tipoSmistamentoVisibile, unitaTrasmissioneModificabile: false, isSequenza: false, smartDesktop: smartDesktop])
                w.onClose { Event event ->
                    PopupSceltaSmistamentiViewModel.DatiSmistamento datiSmistamenti = event.data

                    if (datiSmistamenti == null) {
                        // l'utente ha annullato le operazione
                        return
                    }

                    List<EsitoSmartDesktop> esitoSmartDesktopList = []

                    try {
                        switch (operazione) {
                            case MenuItemProtocollo.APRI_CARICO_ASSEGNA:
                                //portare su i casi e poi gestirli dentro

                                for (String idS : idsSmistamenti) {

                                    Long idSmistamentoEsterno = new Long(idS)
                                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()

                                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoEAssegna(documento, datiSmistamenti, idSmistamentoEsterno)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }

                                break

                            case MenuItemProtocollo.APRI_SMISTA_FLEX:

                                for (String idS : idsSmistamenti) {
                                    Long idSmistamentoEsterno = new Long(idS)
                                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.smista(documento, datiSmistamenti, idSmistamentoEsterno)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                                break

                            case MenuItemProtocollo.APRI_ASSEGNA:

                                for (String idS : idsSmistamenti) {
                                    Long idSmistamentoEsterno = new Long(idS)
                                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.assegna(documento, datiSmistamenti, idSmistamentoEsterno)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                                break

                            case MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX:

                                for (String idS : idsSmistamenti) {
                                    Long idSmistamentoEsterno = new Long(idS)
                                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoSmistaEdEsegui(documento, datiSmistamenti, idSmistamentoEsterno)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                                break

                            case MenuItemProtocollo.APRI_ESEGUI_FLEX:

                                for (String idS : idsSmistamenti) {
                                    Long idSmistamentoEsterno = new Long(idS)
                                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.smistaEdEsegui(documento, datiSmistamenti, idSmistamentoEsterno)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                                break

                            case MenuItemProtocollo.APRI_CARICO_FLEX:

                                for (String idS : idsSmistamenti) {
                                    Long idSmistamentoEsterno = new Long(idS)
                                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCaricoEInoltra(documento, datiSmistamenti, idSmistamentoEsterno)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                                break

                            case MenuItemProtocollo.APRI_INOLTRA_FLEX:

                                for (String idS : idsSmistamenti) {
                                    Long idSmistamentoEsterno = new Long(idS)
                                    Smistamento s = Smistamento.findByIdDocumentoEsterno(idSmistamentoEsterno)
                                    ISmistabileDTO documento = Documento.get(s?.documento?.id)?.toDTO()
                                    EsitoSmartDesktop esitoSmartDesktop = smistamentoService.inoltra(documento, datiSmistamenti, idSmistamentoEsterno)
                                    esitoSmartDesktopList.add(esitoSmartDesktop)
                                }
                                break

                            default:
                                Clients.showNotification("Operazione ${tipoAzione} non gestita.", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 2000, true)
                                break
                        }

                        if (esitoSmartDesktopList.size() > 0) {
                            Window wEsito = Executions.createComponents("/protocollo/integrazioni/smartDesktop/esitoSmistamenti.zul", self, [esitoSmartDesktopList: esitoSmartDesktopList])
                        }
                    } catch (Exception e) {
                        // impedisco la chiusura della popup e segnalo l'errore che è avvenuto
                        event.stopPropagation()
                        throw e
                    }
                }
                break
            case 'APRI_CLASSIFICAZIONE':
                ClassificazioneDTO dto = new ClassificazioneDTO(idDocumentoEsterno: id ? Long.valueOf(id) : null)
                ClassificazioneDettaglioViewModel.apriPopup(self, dto, idCartella ? new ClassificazioneDTO(idDocumentoEsterno: idCartella) : null).
                        addEventListener(Events.ON_CLOSE, onCloseEventListener)
                break

            case 'REGISTRO_GIORNALIERO':
                Window window = creaPopup("/protocollo/index.zul", [codiceTab: 'registro_giornaliero']).doModal()
                break

            default:
                break
        }
    }


    private Long idCartella(String idCartProveninez) {
        Long idDocumentoEsterno = null
        try {
            if (!idCartProveninez || idCartProveninez == 'null') {
                return null
            } else if (idCartProveninez.startsWith('C')) {
                def idSenzaC = idCartProveninez.substring(1)
                if (idSenzaC != 'null') {
                    idDocumentoEsterno = Long.valueOf(idSenzaC)
                }
            } else {
                idDocumentoEsterno = Long.valueOf(idCartProveninez)
            }
        } catch (Exception e) {
            log.warn("Parametro idCartProveninez in formato non riconosciuto: {} - {}", idCartProveninez, e.getMessage())
        }
        return idDocumentoEsterno
    }

    private Window creaPopup(String zul, Map parametri) {
        Window window = Executions.createComponents(zul, self, parametri) as Window
        window.addEventListener(Events.ON_CLOSE, onCloseEventListener)
        return window
    }

}
