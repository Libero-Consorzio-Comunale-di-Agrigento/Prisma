package it.finmatica.protocollo.documenti

import commons.PopupImportAllegatiEmailViewModel
import commons.PopupInserisciTitolarioViewModel
import commons.PopupSceltaTipologiaViewModel
import commons.PopupVisualizzaPecMotivoInteventoOperatore
import commons.menu.MenuItem
import commons.menu.MenuItemProtocollo
import groovy.util.logging.Slf4j
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.commons.AbstractViewModel
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.commons.Utils
import it.finmatica.gestionedocumenti.documenti.AllegatoDTO
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.FileDocumentoDTO
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.documenti.TipoCollegamentoDTO
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoRegola
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.gestionedocumenti.zk.BandboxSoggettiUtentiSo4
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.gestioneiter.motore.WkfIter
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.gestionetesti.TipoFile
import it.finmatica.gestionetesti.reporter.GestioneTestiModello
import it.finmatica.gestionetesti.reporter.GestioneTestiModelloDTO
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggio
import it.finmatica.protocollo.corrispondenti.CorrispondenteMessaggioDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.corrispondenti.MessaggioDTO
import it.finmatica.protocollo.dizionari.AccessoCivicoService
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.dizionari.StatoScarto
import it.finmatica.protocollo.dizionari.StatoScartoDTO
import it.finmatica.protocollo.dizionari.TipoAccessoCivicoDTO
import it.finmatica.protocollo.dizionari.TipoEsitoAccesso
import it.finmatica.protocollo.dizionari.TipoEsitoAccessoDTO
import it.finmatica.protocollo.dizionari.TipoRichiedenteAccessoDTO
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivico
import it.finmatica.protocollo.documenti.accessocivico.ProtocolloAccessoCivicoDTO
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamento
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamentoDTO
import it.finmatica.protocollo.documenti.annullamento.StatoAnnullamento
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.documenti.scarto.ProtocolloDatiScartoDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloService
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import it.finmatica.protocollo.documenti.viste.Riferimento
import it.finmatica.protocollo.documenti.viste.RiferimentoDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloCategoriaDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamento
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloSmistamentoDTO
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.FunzioniService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.ProtocolloEsternoDTO
import it.finmatica.protocollo.integrazioni.ad4.AssistenteVirtualeService
import it.finmatica.protocollo.integrazioni.gdm.DateService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiInviatiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggiRicevutiService
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioInviato
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioInviatoDTO
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.protocollo.jobs.ProtocolloJob
import it.finmatica.protocollo.menu.MenuItemProtocolloService
import it.finmatica.protocollo.notifiche.RegoleCalcoloNotificheProtocolloRepository
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.protocollo.titolario.ClassificazioneService
import it.finmatica.protocollo.titolario.FascicoloRepository
import it.finmatica.protocollo.titolario.FascicoloService
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.zk.ShortCutConstants
import it.finmatica.protocollo.zk.components.catenadocumentale.AlberoCatenaDocumentale
import it.finmatica.protocollo.zk.components.corrispondenti.CorrispondentiComponent
import it.finmatica.protocollo.zk.components.smistamenti.SmistamentiComponent
import it.finmatica.protocollo.zk.components.upload.CaricaFileEvent
import it.finmatica.protocollo.zk.utils.ClientsUtils
import it.finmatica.protocollo.zk.utils.PaginationUtils
import it.finmatica.so4.login.detail.UnitaOrganizzativa
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.springframework.transaction.support.TransactionTemplate
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
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
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.event.InputEvent
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Combobox
import org.zkoss.zul.Include
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Tab
import org.zkoss.zul.Tabbox
import org.zkoss.zul.Window

import java.text.SimpleDateFormat

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class ProtocolloViewModel extends AbstractViewModel<Protocollo> {

    public static final String NOCHECK = ".NOCHECK"

    // services
    @WireVariable
    private StrutturaOrganizzativaService strutturaOrganizzativaService
    @WireVariable
    private MenuItemProtocolloService menuItemProtocolloService
    @WireVariable
    private AllegatoProtocolloService allegatoProtocolloService
    @WireVariable
    private TipologiaSoggettoService tipologiaSoggettoService
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    private TipoProtocolloService tipoProtocolloService
    @WireVariable
    private CorrispondenteService corrispondenteService
    @WireVariable
    private AccessoCivicoService accessoCivicoService
    @WireVariable
    private ProtocolloFileDownloader fileDownloader
    @WireVariable
    private TransactionTemplate transactionTemplate
    @WireVariable
    private SmistamentoService smistamentoService
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private TitolarioService titolarioService
    @WireVariable
    private DocumentoService documentoService
    @WireVariable
    private FunzioniService funzioniService
    @WireVariable
    private ProtocolloEsternoService protocolloEsternoService
    @WireVariable
    private MailService mailService
    @WireVariable
    private ProtocolloJob protocolloJob
    @WireVariable
    private DateService dateService
    @WireVariable
    private ProtocolloRepository protocolloRepository
    @WireVariable
    private ProtocolloAccessoCivicoRepository protocolloAccessoCivicoRepository
    @WireVariable
    private AllegatoRepository allegatoRepository
    @WireVariable
    private DocumentoCollegatoRepository documentoCollegatoRepository
    @WireVariable
    RegoleCalcoloNotificheProtocolloRepository regoleCalcoloNotificheProtocolloRepository
    @WireVariable
    private ClassificazioneService classificazioneService
    @WireVariable
    private FascicoloRepository fascicoloRepository
    @WireVariable
    private ProtocolloPkgService protocolloPkgService
    @WireVariable
    private SchemaProtocolloService schemaProtocolloService
    @WireVariable
    private AssistenteVirtualeService assistenteVirtualeService
    @WireVariable
    private MessaggiRicevutiService messaggiRicevutiService
    @WireVariable
    private MessaggiInviatiService messaggiInviatiService
    @WireVariable
    private FascicoloService fascicoloService
    @WireVariable
    private DocumentoCollegatoProtocolloService documentoCollegatoProtocolloService

    @Wire("#smistamenti")
    SmistamentiComponent smistamentoComponent

    @Wire("#corrispondenti")
    CorrispondentiComponent corrispondentiComponent

    @Wire("#protocolloStandard")
    Include protocolloStandard

    // dati
    ProtocolloDTO protocollo
    String categoria
    String registroVisibile = null

    List<DocumentoDTO> listaDocumentiCollegati
    List<RiferimentoDTO> listaRiferimenti
    Set<DocumentoCollegatoDTO> listaCollegamenti = [] as Set
    List<AllegatoDTO> listaAllegati
    List<CorrispondenteDTO> listaCorrispondentiDto = []
    List<MessaggioDTO> messaggi
    List<FileDocumento> listaFilesAllegato

    List<CorrispondenteMessaggioDTO> listaCorrispondentiMessaggi = []
    int activePageListaCorrispondentiMessaggi = 0
    int totalSizeListaCorrispondentiMessaggi = 0
    int pageSizeListaCorrispondentiMessaggi = 7

    boolean pec = false

    String search
    boolean richiestaAnnullamento = false

    List<ProtocolloAnnullamentoDTO> listaAnnullamentiRifiutati
    ProtocolloAnnullamentoDTO annullamentoAccettato
    ProtocolloAnnullamentoDTO annullamentoDiretto
    ProtocolloAnnullamentoDTO annullamentoRichiesto
    boolean annullamentoVisibile

    List<SmistamentoDTO> listaSmistamentiStoriciDto = []
    List<SmistamentoDTO> listaSmistamentiDto = []

    List<DocumentoTitolarioDTO> listaTitolari

    boolean datoAggiuntivoAbilitato
    boolean isNotificaPresente

    // campi dello storico del flusso
    List listaStoricoFlusso

    boolean oggettoObbligatorio
    boolean tipoDocumentoObbligatorio

    boolean ufficioEsibenteModificabile = true

    // indica se il documento deve essere comunque aperto in lettura (delegato)
    private boolean forzaCompetenzeLettura = false

    boolean visualizzaNote

    boolean ubicazioneVisibile
    String ubicazione

    boolean oggettoAccessoCivicoModificabile = true

    boolean funzionarioModificabile = true
    boolean funzionarioValorizzabile = true
    boolean firmatarioModificabile = true
    boolean firmatarioValorizzabile = true

    boolean schemaProtocolloModificabile = true
    boolean isSequenza = false
    boolean stampaUnicaInCorso = false

    boolean forzaModificabilitaUnitaProtocollante = false

    ProtocolloAccessoCivicoDTO protocolloAccessoCivico
    ProtocolloDTO domanda
    ProtocolloDTO risposta
    List<TipoEsitoAccessoDTO> listaEsitiAccesso
    List<TipoRichiedenteAccessoDTO> listaTipoRichiedenteAccesso
    List<TipoAccessoCivicoDTO> listaTipoAccesso
    List<So4UnitaPubbDTO> listaUnita

    List<StatoScartoDTO> listaStatiScarto

    boolean esitoPositivo = false
    boolean rispostaAccessoCivico = false
    boolean domandaAccessoCivico = false
    boolean creaSmistamentiAbilitato = true
    boolean abilitaCercaDocumenti = false
    boolean forzaDocumentoEsterno = false

    int colspanTesto = 1
    boolean pulsanteModificaVisibile = false

    @Wire("#menuFunzionalita")
    MenuItemProtocollo menuFunzionalita

    // mappa dei soggetti
    Map soggetti = [:]

    // stato
    Map<String, Boolean> campiProtetti
    Map competenze
    String posizioneFlusso

    boolean firmaRemotaAbilitata
    boolean abilitaRiservato
    boolean riservatoModificabile
    boolean riservatoDaFascicolo

    boolean editaTesto

    int pageSizeMessaggi = 5
    int activePageMessaggi = 0
    int totalSizeMessaggi = 0

    // gestione delle note di trasmissione
    String noteTrasmissionePrecedenti
    String attorePrecedente
    boolean mostraNoteTrasmissionePrecedenti

    So4UnitaPubb unitaVertice = null

    Integer annoPrecedente
    Integer numeroPrecedente
    TipoRegistroDTO tipoRegistroPrecedente

    //Proprietà per precedente fissato in alto alla pagina
    Integer annoPrecedenteFix
    Integer numeroPrecedenteFix
    TipoRegistroDTO tipoRegistroPrecedenteFix
    ProtocolloDTO protocolloPrecendeteDTO

    Integer annoEmergenza
    Integer numeroEmergenza
    String registroEmergenza

    boolean isNumerazioneEmergenza = false
    boolean isEmergeza = false

    List<TipoCollegamentoDTO> listaTipiCollegamento
    TipoCollegamentoDTO tipoCollegamento

    // privilegi
    boolean eliminaDaClassificheSecondarie = true
    boolean inserimentoInClassificheSecondarie = true
    boolean inserimentoInFascicoliAperti = true
    boolean eliminaAllegati = true
    boolean eliminaRapporti = true
    boolean inserimentoAllegati = true
    boolean inserimentoRapporti = true
    boolean modificaClassifica = true
    boolean modificaDatiArchivio = true
    boolean modificaFilePrincipale = true
    boolean eliminaFilePrincipale = false
    boolean modificaOggetto = true
    boolean modificaRapporti = true

    boolean haTitolari = false
    boolean haRicongiungiAFascicolo = false

    String ricercaCorrispondenti = null

    //livello albero catena documentale
    int livelloApertura = 1
    AlberoCatenaDocumentale catenaDocumentale

    boolean tramiteCC = false

    boolean concatenaCodiceDescrizioneUO = false
    boolean stampaBarcode = false

    boolean hasListaModelliTesto = false
    boolean hasPrincipaleFirmato = false
    boolean modificaUnitaProtocollante = false

    String urlAssistenteVirtuale

    static Window apriPopup(String categoria) {
        return apri([categoria: categoria])
    }

    static Window apriPopup(ProtocolloDTO copia) {
        return apri([protocollo: copia])
    }

    static Window apriPopup(ProtocolloDTO copia, String categoria) {
        return apri([protocollo: copia, categoria: categoria])
    }

    static Window apriPopup(long idDocumento) {
        return apri([id: idDocumento])
    }

    static Window apriPopup(String categoria, long idDocumento) {
        return apri([categoria: categoria, id: idDocumento])
    }

    static Window apriPopup(long idCartella, String categoria) {
        return apri([categoria: categoria, idCartella: idCartella])
    }

    static Window apriPopup(long idDocumento, String categoria, String movimento, boolean apriInSolaLettura, Long idCartella) {
        return apri([id: idDocumento, categoria: categoria, movimento: movimento, apriInSolaLettura: apriInSolaLettura, idCartella: idCartella])
    }

    static Window apriPopup(long idDocumento, boolean forzaCompetenzeInLettura) {
        return apri([id: idDocumento, forzaCompetenzeInLettura: forzaCompetenzeInLettura])
    }

    private static Window apri(Map parametri) {
        Window window
        if (parametri.categoria == CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice) {
            window = (Window) Executions.createComponents("/protocollo/documenti/documentoDaClassificare.zul", null, parametri)
        } else if (parametri.categoria == CategoriaProtocollo.CATEGORIA_PROVVEDIMENTO.codice) {
            window = (Window) Executions.createComponents("/protocollo/documenti/provvedimento.zul", null, parametri)
        } else if (parametri.categoria == CategoriaProtocollo.CATEGORIA_REGISTRO_GIORNALIERO.codice) {
            window = (Window) Executions.createComponents("/protocollo/documenti/registroGiornaliero.zul", null, parametri)
        } else {
            window = (Window) Executions.createComponents("/protocollo/documenti/protocollo.zul", null, parametri)
        }
        window.doModal()
        return window
    }

    @NotifyChange([
            "protocollo",
            "competenze",
            "datoAggiuntivoAbilitato"
    ])
    @Init
    void init(
            @ContextParam(ContextType.COMPONENT) Window w,
            @ExecutionArgParam("id") Long id,
            @ExecutionArgParam("movimento") String movimentoParam,
            @ExecutionArgParam("forzaCompetenzeInLettura") Boolean forzaCompetenzeInLettura,
            @ExecutionArgParam("apriInSolaLettura") Boolean apriInSolaLettura,
            @ExecutionArgParam("categoria") String categoria,
            @ExecutionArgParam("protocollo") ProtocolloDTO protocolloDTO,
            @ExecutionArgParam("ricercaCorrispondenti") String ricercaCorrispondenti,
            @ExecutionArgParam("idCartella") Long idCartella) {
        this.self = w

        firmaRemotaAbilitata = Impostazioni.FIRMA_REMOTA.abilitato
        abilitaRiservato = ImpostazioniProtocollo.RISERVATO.abilitato
        datoAggiuntivoAbilitato = Impostazioni.DATO_AGGIUNTIVO.abilitato
        oggettoObbligatorio = true//ImpostazioniProtocollo.OGG_OB.abilitato
        tipoDocumentoObbligatorio = ImpostazioniProtocollo.TIPO_DOC_OB.abilitato
        abilitaCercaDocumenti = (Impostazioni.DOCER.abilitato || Impostazioni.IMPORT_ALLEGATO_GDM.abilitato)
        tipoRegistroPrecedente = TipoRegistro.findByCodice(ImpostazioniProtocollo.TIPO_REGISTRO.valore).toDTO()
        tipoRegistroPrecedenteFix = tipoRegistroPrecedente
        tipoCollegamento = TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)?.toDTO()
        concatenaCodiceDescrizioneUO = Impostazioni.UNITA_CONCAT_CODICE.abilitato

        if (forzaCompetenzeInLettura != null) {
            this.forzaCompetenzeLettura = forzaCompetenzeInLettura.booleanValue()
        }

        if (apriInSolaLettura != null) {
            this.apriInSolaLettura = apriInSolaLettura.booleanValue()
        }

        if (!StringUtils.isEmpty(ricercaCorrispondenti)) {
            this.ricercaCorrispondenti = ricercaCorrispondenti
        }

        if (protocolloDTO != null) {
            protocollo = protocolloDTO
            competenze = [lettura: true, modifica: true, cancellazione: true]
            riservatoModificabile = true
            this.categoria = protocollo.categoriaProtocollo.codice

            if (protocollo.idDocumentoEsterno > 0) {
                refreshListaAllegati()
            } else {

                protocollo.dataRedazione = dateService.currentDate
                List<DocumentoCollegatoDTO> collegati = protocollo.getDocumentiCollegati()?.toList()
                if (collegati?.size() > 0) {
                    DocumentoCollegatoDTO precedente = collegati[0]
                    numeroPrecedenteFix = precedente.collegato.numero
                    annoPrecedenteFix = precedente.collegato.anno
                    BindUtils.postNotifyChange(null, null, this, "annoPrecedenteFix")
                    BindUtils.postNotifyChange(null, null, this, "numeroPrecedenteFix")
                }
            }

            if (protocolloDTO.tipoProtocollo) {
                listaSmistamentiDto = protocolloDTO.smistamenti?.toList() ?: []
                inizializzaConTipoProtocollo(protocolloDTO.tipoProtocollo)
            } else {
                soggetti = protocolloDTO.soggetti.collectEntries {
                    [(it.tipoSoggetto): [modificato    : true
                                         , tipoSoggetto: it.tipoSoggetto
                                         , descrizione : (it.unitaSo4 == null ? it.utenteAd4.nominativoSoggetto : it.unitaSo4.descrizione)
                                         , utente      : it.utenteAd4
                                         , unita       : it.unitaSo4]]
                }
                calcolaSoggetti(TipoSoggetto.REDATTORE)
                refreshSchemaProtocollo()
            }
            if (!protocollo.categoriaProtocollo.isDaNonProtocollare()) {
                if (protocollo.schemaProtocollo?.isRisposta()) {
                    // provo prima a vedere se ho il dato in memoria (per esempio se il protocollo ancora non è stato salvato)
                    DocumentoCollegatoDTO domandaAcc = protocollo?.documentiCollegati?.find {
                        it.tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO
                    }
                    if (domandaAcc) {
                        // se è una riposta di accesso civico manuale devo legarla
                        ProtocolloAccessoCivico datiAcc = protocolloAccessoCivicoRepository.findByProtocolloDomanda(domandaAcc.collegato.domainObject)
                        if (datiAcc) {
                            rispostaAccessoCivico = true
                            protocolloAccessoCivico = datiAcc.toDTO()
                            domanda = datiAcc.protocolloDomanda.toDTO()
                        }
                    }
                }
            }
            aggiornaMaschera(protocollo.domainObject)
        } else if (id <= 0) {
            protocollo = new ProtocolloDTO()
            protocollo.tipoOggetto = WkfTipoOggetto.get(Protocollo.TIPO_DOCUMENTO).toDTO()
            competenze = [lettura: true, modifica: true, cancellazione: true]
            riservatoModificabile = true
            protocollo.dataRedazione = dateService.currentDate

            protocollo.movimento = movimentoParam
            this.categoria = categoria
            if (idCartella) {
                Long idDocumentoEsterno = protocolloPkgService.getIdDocumentoProfilo(idCartella)
                if (idDocumentoEsterno) {
                    ClassificazioneDTO classificazione = classificazioneService.findByIdEsterno(idDocumentoEsterno)
                    if (classificazione) {
                        protocollo.classificazione = classificazione
                    } else {
                        FascicoloDTO fascicolo = fascicoloRepository.getFascicolo(idDocumentoEsterno)?.toDTO()
                        if (fascicolo) {
                            protocollo.fascicolo = fascicolo
                            protocollo.classificazione = fascicolo.classificazione
                        }
                    }
                }
            }

            registroVisibile()
        } else {
            protocollo = new ProtocolloDTO(id: id)
            aggiornaMaschera(protocollo.domainObject)
            if (!competenze.lettura) {
                return
            }
            if (isProtocolloPec() &&
                    protocollo.numero == null &&
                    protocollo.datiInteroperabilita?.motivoInterventoOperatore != null &&
                    ImpostazioniProtocollo.PEC_APRI_POPUP_MOTIVO_INT_OPERATORE.isAbilitato()) {
                PopupVisualizzaPecMotivoInteventoOperatore.apriPopup(self, protocollo.datiInteroperabilita.motivoInterventoOperatore).addEventListener(Events.ON_CLOSE) { Event event ->
                }
            }
        }

        aggiornaPulsanti()

        inizializzaAssistenteVirtuale()

        modificaUnitaProtocollante = isUnitaProtocollanteModificabile()

        // carica i titolari secondari
        listaTitolari = protocollo?.titolari?.toList() ?: []
        if (protocollo?.titolari == null) {
            listaTitolari = []
        }
        haTitolari = listaTitolari

        // carica corrispondenti
        listaCorrispondentiDto = protocollo?.corrispondenti?.toList()?.sort { it.id }?.each {
            it.protocollo = protocollo
        } ?: []
        //verifica check Tramite CC. Se ho almeno un corrispondente in conoscenza lo spunto (true) altrimenti no (false)
        //nota: il check CC in tramite seleziona tutti o nessuno dei mittenti, pertanto per la verifica mi baso sul primo della lista
        if (listaCorrispondentiDto.size() > 0) {
            tramiteCC = listaCorrispondentiDto.get(0).conoscenza
        }
        // carica smistamenti
        listaSmistamentiDto = protocollo?.smistamenti?.toList() ?: []

        if (protocollo.statoArchivio == null) {
            protocollo.dataStatoArchivio = null
        }

        listaTipiCollegamento = protocolloService.getTipiCollegamentoUtilizzabili()?.toDTO()

        annoEmergenza = protocollo.annoEmergenza
        numeroEmergenza = protocollo.numeroEmergenza
        registroEmergenza = protocollo.registroEmergenza

        if (annoEmergenza && numeroEmergenza) {
            isNumerazioneEmergenza = true
        }

        if (protocollo.tipoProtocollo?.categoria == Protocollo.CATEGORIA_EMERGENZA) {
            isEmergeza = true
        }

        editaTesto = presenteEditaTesto()
        boolean caricaApplet = false
        if (!StringUtils.isEmpty(categoria)) {
            if (CategoriaProtocollo.getInstance(categoria).isModelloTestoObbligatorio()) {
                caricaApplet = true
            }
        } else {
            caricaApplet = editaTesto
        }
        if (caricaApplet) {
            // Gestito il NOCHECK (controllo in chiusura dell'editor di testo) -> usato un parametro in più per mantenere invariato il parametro della vecchia lettera
            String tipoEditor = Impostazioni.EDITOR_DEFAULT.valore
            if (ImpostazioniProtocollo.EDITOR_DEFAULT_NOCHECK.abilitato) {
                tipoEditor = tipoEditor + NOCHECK
            }
            gestioneTestiService.setDefaultEditor(tipoEditor, Impostazioni.EDITOR_DEFAULT_PATH.valore)
        }
    }

    @AfterCompose
    void afterCompose() {

        if (!competenze.lettura) {
            return
        }

        Selectors.wireComponents(self, this, false)

        if (!StringUtils.isEmpty(this.ricercaCorrispondenti)) {

            corrispondentiComponent.searchSoggetti = this.ricercaCorrispondenti
            corrispondentiComponent.onRicercaCorrispondenti(ricercaCorrispondenti, self)
            return
        }

        // aggiorno subito il menu funzionalità siccome pilota anche alcune parti di interfaccia (ad es: l'aggiunta di un nuovo smistamento)
        refreshMenu()

        if (protocollo.tipoProtocollo == null) {

            List<TipoProtocolloDTO> tipiProtocollo = tipoProtocolloService.tipologiePerCompetenza(categoria)

            if (categoria != CategoriaProtocollo.CATEGORIA_LETTERA.codice && categoria != CategoriaProtocollo.CATEGORIA_PROVVEDIMENTO.codice) {
                for (TipoProtocolloDTO tipo : tipiProtocollo) {
                    if (tipo.predefinito) {
                        inizializzaConTipoProtocollo(tipo)
                        return
                    }
                }
                throw new ProtocolloRuntimeException("Attenzione bisogna definire un tipo di protocollo predefinito per ogni categoria")
            }

            if (tipiProtocollo.size() == 1) {
                inizializzaConTipoProtocollo(tipiProtocollo[0])
                return
            }

            PopupSceltaTipologiaViewModel.apriPopup(self, categoria, tipiProtocollo).addEventListener(Events.ON_CLOSE) { Event event ->
                // se ho cliccato su "annulla", chiudo la maschera
                if (event.data == null) {
                    onChiudi()
                    return
                }
                inizializzaConTipoProtocollo((TipoProtocolloDTO) event.data)
            }
        }
    }

    /**
     * L'unità protocollante non è modificabile se:
     * - Se il documento è una LETTERA:
     *   - il documento è stato salvato e l'unità protocollante è diversa da NULL.
     *   - il documento non è ancora stato salvato ed è possibile selezionare solo una unità protocollante
     * - Per tutti gli altri documenti:
     *   - il documento è protocollato
     *   - il documento non è ancora stato salvato ed è possibile selezionare solo una unità protocollante
     *
     * @return
     */
    boolean isUnitaProtocollanteModificabile() {
        if (protocollo?.tipoProtocollo?.tipologiaSoggetto == null) {
            return false
        }

        List<So4UnitaPubb> unitaDiCompentenza = null

        if (soggetti[TipoSoggetto.UO_PROTOCOLLANTE] == null) {
            unitaDiCompentenza = tipologiaSoggettoService.calcolaListaSoggetti(protocollo.tipoProtocollo.tipologiaSoggetto.id, protocollo, null, TipoSoggetto.UO_PROTOCOLLANTE, "")
            return (unitaDiCompentenza.size() != 1)
        }

        if (protocollo.categoriaProtocollo.lettera || protocollo.categoriaProtocollo.isSmistamentoAttivoInCreazione()) {
            if (protocollo.id > 0) {
                if (forzaModificabilitaUnitaProtocollante) {
                    return true
                }
                return false
            }
        } else {
            if (protocollo.numero > 0) {
                return false
            }
        }

        if (unitaDiCompentenza == null) {
            unitaDiCompentenza = tipologiaSoggettoService.calcolaListaSoggetti(protocollo.tipoProtocollo.tipologiaSoggetto.id, protocollo, null, TipoSoggetto.UO_PROTOCOLLANTE, "")
        }

        return (unitaDiCompentenza?.size() != 1)
    }

    void inizializzaConTipoProtocollo(TipoProtocolloDTO tipoProtocolloDTO, boolean aggiornaPulsantiEnabled = true) {
        protocollo.tipoProtocollo = tipoProtocolloDTO
        if (protocollo.movimento == null && protocollo.tipoProtocollo.movimento != null) {
            protocollo.movimento = protocollo.tipoProtocollo.movimento
        }

        TipoProtocollo tipoProtocollo = protocollo.tipoProtocollo.domainObject

        if (tipoProtocollo.categoriaProtocollo.modelloTestoObbligatorio) {
            GestioneTestiModello modelloTesto = TipoProtocollo.modelloTestoPredefinito(protocollo.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
            if (modelloTesto == null) {
                throw new ProtocolloRuntimeException("Valorizzare il modello testo per la tipologia di protocollo scelta")
            } else {
                protocollo.addToFileDocumenti(new FileDocumentoDTO(codice: FileDocumento.CODICE_FILE_PRINCIPALE, nome: protocollo.tipoProtocollo.categoria + "." + modelloTesto.tipo, contentType: GestioneTestiService.getContentType(modelloTesto.tipo), valido: true, modificabile: true, firmato: false))
            }
        }

        protocollo.controlloFunzionario = protocollo.tipoProtocollo.funzionarioObbligatorio
        protocollo.controlloFirmatario = protocollo.tipoProtocollo.firmatarioObbligatorio

        // commentato perchè c'è una unique key che permette il salvataggio di registro, anno e numero solo in protocollazione
        //protocollo.tipoRegistro  = protocollo.tipoProtocollo?.tipoRegistro
        boolean mtot = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.MODIFICA_TUTTI)
        List<String> codiciUo = []

        if (!mtot) {
            for (UnitaOrganizzativa u : springSecurityService.principal.uo()) {
                codiciUo.add(So4UnitaPubb.getUnita(u.id, u.ottica, u.dal).get()?.codice)
            }
        }

        aggiornaSchemaProtocollo()
        inizializzaUfficioEsibente()

        soggetti = tipologiaSoggettoService.calcolaSoggetti(protocollo, tipoProtocollo.tipologiaSoggetto)
        onAggiornaSoggetti(soggetti?.UO_PROTOCOLLANTE?.unita)

        hasListaModelliTesto = getListaModelliTesto()?.size() > 0

        if (!protocollo.isProtocollato() && protocollo.tipoProtocollo.domainObject.categoriaProtocollo.modelloTestoObbligatorio && !hasListaModelliTesto) {
            throw new ProtocolloRuntimeException("Attenzione. Non sono associati dei modelli testo alla tipologia scelta, oppure non si dispone delle competenze necessarie")
        }

        modificaUnitaProtocollante = isUnitaProtocollanteModificabile()

        if (!protocollo.tipoProtocollo.firmatarioVisibile) {
            soggetti.remove(TipoSoggetto.FIRMATARIO)
            firmatarioValorizzabile = false
        }

        if (!protocollo.tipoProtocollo.funzionarioVisibile) {
            soggetti.remove(TipoSoggetto.FUNZIONARIO)
            funzionarioValorizzabile = false
        }

        if (aggiornaPulsantiEnabled) {
            aggiornaPulsanti()
        }

        if (tipoProtocollo.categoriaProtocollo.modelloTestoObbligatorio) {
            caricaListaModelloTesto()
        }

        hasPrincipaleFirmato = protocollo.testoPrincipale?.firmato

        editaTesto = presenteEditaTesto()

        inizializzaAssistenteVirtuale()

        BindUtils.postNotifyChange(null, null, this, "listaModelliTesto")
        BindUtils.postNotifyChange(null, null, this, "soggetti")
        BindUtils.postNotifyChange(null, null, this, "protocollo")
        BindUtils.postNotifyChange(null, null, this, "protocollo.schemaProtocollo")
        BindUtils.postNotifyChange(null, null, this, "schemaProtocolloModificabile")
        BindUtils.postNotifyChange(null, null, this, "protocollo.schemaProtocollo.tipoRegistro")
        BindUtils.postNotifyChange(null, null, this, "protocollo.schemaProtocollo.ufficioEsibente")
        BindUtils.postNotifyChange(null, null, this, "protocollo.tipoProtocollo.tipologiaSoggetto")
        BindUtils.postNotifyChange(null, null, this, "colspanTesto")
        BindUtils.postNotifyChange(null, null, this, "editaTesto")
        BindUtils.postNotifyChange(null, null, this, "modificaUnitaProtocollante")
        BindUtils.postNotifyChange(null, null, this, "urlAssistenteVirtuale")
        BindUtils.postNotifyChange(null, null, this, "assistenteVirtuale")
    }

    @Command
    void onNuovoProtocolloShortCut(@BindingParam("categoria") String categoria) {
        if (categoria == CategoriaProtocollo.CATEGORIA_PROTOCOLLO.codice) {
            if (protocollo.domainObject && (menuItemProtocolloService.isAbilitatoNuovo(protocollo.domainObject) || menuItemProtocolloService.isAbilitatoNuovoIns(protocollo.domainObject))) {
                funzioniService.onNuovo(menuFunzionalita, protocollo)
            } else {
                Clients.showNotification("Attenzione: non è possibile creare un nuovo protocollo", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
                return
            }
        } else if (categoria == CategoriaProtocollo.CATEGORIA_LETTERA.codice) {
            if (protocollo.domainObject && (menuItemProtocolloService.isAbilitatoNuovaLettera(protocollo.domainObject) || menuItemProtocolloService.isAbilitatoNuovaLetteraIns(protocollo.domainObject))) {
                funzioniService.onNuovaLettera(menuFunzionalita, protocollo)
            } else {
                Clients.showNotification("Attenzione: non è possibile creare una nuova lettera", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
                return
            }
        } else if (categoria == CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice) {
            if (protocollo.domainObject && menuItemProtocolloService.isAbilitatoNuovoDaFascicolareIns(protocollo.domainObject)) {
                funzioniService.onNuovoDaFascicolare(menuFunzionalita, protocollo)
            } else {
                Clients.showNotification("Attenzione: non è possibile creare un nuovo documento da fascicolare", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
                return
            }
        } else {
            Clients.showNotification("Attenzione: non è possibile creare un nuovo documento", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
            return
        }
    }

    @Command
    public void doSomething(@BindingParam("code") String ctrlKeyCode, @BindingParam("categoria") String categoria) {
        int keyCode = Integer.parseInt(ctrlKeyCode);
        switch (keyCode) {
            case ShortCutConstants.ALT_B:
                if (stampaBarcode) {
                    onStampaBarcode()
                }
                break
            case ShortCutConstants.ALT_S:
                if (!apriInSolaLettura && competenze.modifica) {
                    salva()
                }
                break
            case ShortCutConstants.INS:
                onNuovoProtocolloShortCut(categoria)
                break
            default:
                Clients.showNotification("Shortcut non disponibile", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
                return
        }
    }

    @Command
    void onStampaBarcode() {
        MenuItemProtocollo menu = new MenuItemProtocollo()
        menu.setProtocollo(protocollo)
        menu.setId(MenuItemProtocollo.STAMPA_BC)
        funzioniService.onStampaBc(menu, protocollo)
    }

    @Command
    void onAggiornaSoggetti(@BindingParam("unita") unita) {
        if (unita != null) {
            As4SoggettoCorrente s = springSecurityService.principal.soggetto
            soggetti[TipoSoggetto.REDATTORE] = [modificato: true, descrizione: s.utenteAd4.nominativoSoggetto, utente: s.utenteAd4.toDTO(), unita: soggetti?.UO_PROTOCOLLANTE?.unita]
            calcolaSoggetti(TipoSoggetto.REDATTORE)
            soggetti?.UO_PROTOCOLLANTE?.unita = unita

            if (!funzionarioValorizzabile) {
                soggetti.remove(TipoSoggetto.FUNZIONARIO)
            }

            if (!firmatarioValorizzabile) {
                soggetti.remove(TipoSoggetto.FIRMATARIO)
            }

            modificabilitaFirmatarioFunzionario()

            //dipendono dalla unita protocollante
            refreshSmistamentiECompetenze(protocollo, unita)

            //aggiorno la lista modelli testi per la nuova unità
            BindUtils.postNotifyChange(null, null, this, "listaModelliTesto")
        }
    }

    /*
     * Gestione dello storico del flusso
     */

    private void caricaStoricoFlusso(Protocollo protocollo) {
        // lo storico del flusso è contemplato solo fino alla data di protocollazione.
        listaStoricoFlusso = protocolloService.getStoricoFlusso(protocollo, true)
        BindUtils.postNotifyChange(null, null, this, "listaStoricoFlusso")
    }

    @Command
    void onDownloadTestoStorico(@BindingParam("file") fileStorico, @BindingParam("revisione") long revisione) {
        fileDownloader.downloadFileStorico(fileStorico._idDocumentoEsterno, revisione, fileStorico._value)
    }

    @Command
    void onSelectSchemaProtocollo() {

        if (protocollo.schemaProtocollo?.id == -1) {
            protocollo.schemaProtocollo = null
            BindUtils.postNotifyChange(null, null, this, "protocollo.schemaProtocollo")
        }

        if (protocollo.schemaProtocollo != null) {
            SchemaProtocolloDTO schemaProtocollo = protocollo.schemaProtocollo.domainObject.toDTO([
                    "classificazione",
                    "fascicolo",
                    "tipoRegistro",
                    "ufficioEsibente",
                    "files",
                    "categorie.tipoProtocollo"
            ])

            if (!protocollo.tipoProtocollo.categoriaProtocollo.isLettera() && !protocollo.isProtocollato()) {
                if (cambioIter(schemaProtocollo)) {
                    return
                }
            }

            riempiCampiSchemaProtocollo(schemaProtocollo)
            inizializzaUfficioEsibente()
        }

        colspanTesto()
    }

    void cambioIter(SchemaProtocolloDTO schemaProtocollo) {

        boolean primostep = controllaPrimoStep()
        if (protocollo.id == null || protocollo?.iter == null || primostep) {
            if (primostep && protocollo.idDocumentoEsterno != null) {
                protocolloService.eliminaIter(protocollo)
                TipoProtocollo tipoProtocolloPredefinito = tipoProtocolloService.getPredefinitoPerCategoria(protocollo.tipoProtocollo.categoria)
                if (tipoProtocolloPredefinito) {
                    protocollo.tipoProtocollo = tipoProtocolloPredefinito.toDTO()
                }
            }

            if (schemaProtocollo.categorie) {
                categoria = protocollo.tipoProtocollo.categoria
                for (SchemaProtocolloCategoriaDTO cat : schemaProtocollo.categorie) {
                    if (cat.categoria == categoria) {
                        if (cat.tipoProtocollo) {
                            protocollo.tipoProtocollo = cat.tipoProtocollo
                            break
                        }
                    }
                }
            }

            inizializzaConTipoProtocollo(protocollo.tipoProtocollo, protocollo.idDocumentoEsterno == null)

            if (primostep && protocollo.idDocumentoEsterno != null) {
                Protocollo p = protocollo.domainObject
                if (p) {
                    wkfIterService.istanziaIter(p.tipoProtocollo.getCfgIter(), p)
                    protocollo.version = protocollo.domainObject.version
                    salva()
                }
            }
        }
    }

    boolean controllaPrimoStep() {
        if (protocollo.iter == null) {
            return true
        }
        WkfIter iter = WkfIter.get(protocollo.iter.id)
        Long idCorrente = iter.stepCorrente.cfgStep.id
        Long idPrimoStep = iter.cfgIter.cfgStep.sort { it.sequenza }?.get(0).id
        return idCorrente == idPrimoStep
    }

    @Command
    void onRicercaSchemaProtocollo() {
        Window w = Executions.createComponents("/commons/popupRicercaSchemaProtocollo.zul", self, [protocollo: protocollo])
        w.onClose { event ->
            if (event.data != null) {
                SchemaProtocolloDTO schemaProtocollo = event.data.domainObject?.toDTO([
                        "classificazione",
                        "fascicolo",
                        "tipoRegistro",
                        "ufficioEsibente",
                        "files"
                ])
                protocollo.schemaProtocollo = schemaProtocollo
                onSelectSchemaProtocollo()
            }
        }
        w.doModal()
    }

    private void riempiCampiSchemaProtocollo(SchemaProtocolloDTO schemaProtocollo) {
        // controllo che lo schema protocollo abbia degli smistamenti con sequenza
        // (solo quelli per COMPETENZA possono avere la sequenza)
        // il primo lo inserisco e poi tutti gli altri senza sequenza
        List<SchemaProtocolloSmistamentoDTO> smistamentiSchema = SchemaProtocolloSmistamento.createCriteria().list {
            eq("schemaProtocollo.id", schemaProtocollo?.id)
            isNotNull("sequenza")
            order("sequenza")
        }.toDTO()

        isSequenza = smistamentiSchema?.size() > 0

        if (isSequenza) {
            List<SchemaProtocolloSmistamentoDTO> smistamentiSchemaRestanti = SchemaProtocolloSmistamento.createCriteria().list {
                eq("schemaProtocollo.id", schemaProtocollo?.id)
                isNull("sequenza")
                eq("tipoSmistamento", Smistamento.CONOSCENZA)
            }.toDTO()
            schemaProtocollo?.smistamenti = [smistamentiSchema.get(0)]
            schemaProtocollo?.smistamenti.addAll(smistamentiSchemaRestanti)
        } else {
            schemaProtocollo?.smistamenti = SchemaProtocolloSmistamento.createCriteria().list {
                eq("schemaProtocollo.id", schemaProtocollo?.id)
            }.toDTO()
        }

        if (isSequenza && !listaSmistamentiDto.isEmpty()) {
            Messagebox.show("Il tipo di documento scelto contiene degli smistamenti in sequenza, l'eventuale scelta causerà la cancellazione dei precedenti smistamenti. Vuoi continuare?", "Avvertenza",
                    Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                if (Messagebox.ON_OK == e.getName()) {
                    protocollo.schemaProtocollo = schemaProtocollo
                    if (protocollo.id > 0) {
                        for (SmistamentoDTO daElimare : listaSmistamentiDto) {
                            smistamentoService.eliminaSmistamento(protocollo.domainObject, daElimare.domainObject)
                        }
                    }
                    listaSmistamentiDto.clear()
                    creaSchemaProtocolloSmistamenti()
                    refreshSchemaProtocollo()
                } else if (Messagebox.ON_CANCEL == e.getName()) {
                    refreshSchemaProtocollo()
                }
            }
        } else if (listaSmistamentiDto.isEmpty()) {
            protocollo.schemaProtocollo = schemaProtocollo
            refreshSchemaProtocollo()
            creaSchemaProtocolloSmistamenti()
        } else {
            protocollo.schemaProtocollo = schemaProtocollo
            refreshSchemaProtocollo()
        }
    }

    private void refreshSchemaProtocollo() {

        if (protocollo.classificazione == null) {
            protocollo.classificazione = protocollo.schemaProtocollo?.classificazione
            protocollo.fascicolo = null

            if (protocollo.fascicolo == null && protocollo.classificazione != null) {
                protocollo.fascicolo = protocollo.schemaProtocollo?.fascicolo
            }
        }

        //isssue #40812 if (ImpostazioniProtocollo.ACCESSO_CIVICO_OGGETTO_DEFAULT.valore != ProtocolloAccessoCivicoDTO.OGGETTO_DEFAULT_TIPO_ACCESSO && (protocollo.oggetto == null || StringUtils.isEmpty(protocollo.oggetto))) {
        if (protocollo.oggetto == null || StringUtils.isEmpty(protocollo.oggetto)) {
            protocollo.oggetto = protocollo.schemaProtocollo?.oggetto
        }

        if (protocollo.riservato != true) {
            protocollo.riservato = protocollo.schemaProtocollo?.riservato
        }

        if (protocollo.schemaProtocollo?.ufficioEsibente != null && soggetti?.UO_ESIBENTE?.unita == null) {
            soggetti[TipoSoggetto.UO_ESIBENTE] = [modificato: true, descrizione: protocollo.schemaProtocollo.ufficioEsibente.descrizione, utente: null, unita: protocollo.schemaProtocollo.ufficioEsibente]
            BindUtils.postNotifyChange(null, null, this, "soggetti")
        }

        // controllare che già siano stati associati degli allegati
        if ((listaAllegati == null || listaAllegati.size() == 0) && protocollo.schemaProtocollo.files?.size() > 0) {

            if (protocollo.idDocumentoEsterno == null) {
                // salvato e istanziato l'iter per salvare il file associati allo schema protocollo ad un documento che ancora non esiste
                Protocollo p = getDocumentoIterabile(true)
                aggiornaDocumentoIterabile(p)
                // creo l'iter se non l'ho:
                if (protocollo.iter == null) {
                    this.wkfIterService.istanziaIter(getCfgIter(), p)
                }
                protocollo.id = p.id
                refreshCorrispondenti()
            } else {
                salva()
            }
            allegatoProtocolloService.importaAllegatoSchemaProtocollo(protocollo.domainObject, protocollo.schemaProtocollo?.domainObject)
            refreshListaAllegati()
            protocollo.version = protocollo.domainObject.version
        } else {
            aggiornaSchemaProtocollo()
        }

        BindUtils.postNotifyChange(null, null, this, "protocollo")
        BindUtils.postNotifyChange(null, null, this, "protocollo.schemaProtocollo.tipoRegistro")
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiDto")
        BindUtils.postNotifyChange(null, null, this, "isSequenza")
    }

    private void creaSchemaProtocolloSmistamenti() {
        for (SchemaProtocolloSmistamentoDTO smistamentoSchema : protocollo.schemaProtocollo?.smistamenti) {
            SmistamentoDTO smistamentoDTO = new SmistamentoDTO()

            So4UnitaPubb unita = smistamentoSchema.unitaSo4Smistamento?.domainObject
            smistamentoDTO.unitaSmistamento = unita?.toDTO()

            if (smistamentoDTO.unitaSmistamento != null) {
                smistamentoDTO.tipoSmistamento = smistamentoSchema.tipoSmistamento
                smistamentoDTO.utenteTrasmissione = springSecurityService.currentUser.toDTO()
                smistamentoDTO.statoSmistamento = Smistamento.CREATO
                smistamentoDTO.dataSmistamento = new Date()
                listaSmistamentiDto.add(smistamentoDTO)
                if (protocollo.id > 0) {
                    smistamentoService.creaSmistamento(protocollo?.domainObject, smistamentoDTO.tipoSmistamento, null, springSecurityService.currentUser, smistamentoDTO.unitaSmistamento?.domainObject, null, null)
                    protocollo.version = protocollo.domainObject?.version
                } else {
                    protocollo.addToSmistamenti(smistamentoDTO)
                }
            }
        }
        if (protocollo.idDocumentoEsterno > 0) {
            salva()
        }
    }

    /*
     * Gestione degli smistamenti
     */

    @Command
    void onApriTabSmistamenti() {
        listaSmistamentiStoriciDto = smistamentoService.getSmistamentiStorici(protocollo.id).toDTO(["utenteTrasmissione", "unitaTrasmissione", "utentePresaInCarico", "utenteEsecuzione", "utenteAssegnante", "utenteAssegnatario", "utenteRifiuto", "unitaSmistamento"])
        if (listaSmistamentiStoriciDto == null) {
            listaSmistamentiStoriciDto = []
        }
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiStoriciDto")
    }

    /*
     * Gestione dei titolari aggiuntivi
     */

    @Command
    void onInserisciTitolario() {
        PopupInserisciTitolarioViewModel.apri(self, listaTitolari, protocollo).addEventListener(Events.ON_CLOSE) { Event event ->
            if (event.data != null) {
                List<DTO> selectedTitolari = event.data
                DocumentoTitolarioDTO documentoTitolarioDTO

                for (DTO titolario : selectedTitolari) {
                    if (titolario instanceof FascicoloDTO) {
                        FascicoloDTO fascicolo = titolario
                        ClassificazioneDTO classificazione = titolario.classificazione
                        documentoTitolarioDTO = new DocumentoTitolarioDTO(fascicolo: fascicolo, classificazione: classificazione, documento: protocollo)
                    } else {
                        documentoTitolarioDTO = new DocumentoTitolarioDTO(classificazione: titolario, documento: protocollo)
                    }

                    if (protocollo.id != null) {

                        Protocollo p = protocollo.domainObject
                        if (protocollo.fascicolo?.id != p.fascicolo?.id) {
                            protocolloService.salva(p, protocollo)
                        }
                        titolarioService.salva(p, [documentoTitolarioDTO])
                        protocollo.version = p.version
                        aggiornaMaschera(p)
                    } else {
                        listaTitolari.add(documentoTitolarioDTO)
                    }
                }

                refreshListaTitolari()
            }
        }
    }

    @Command
    void onEliminaTitolario(@BindingParam("titolario") titolario) {
        Messagebox.show("Sei sicuro di voler eliminare la classifica secondaria: " + titolario.classificazione.codice + " ?", "Attenzione", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                if (protocollo.id != null) {
                    titolarioService.remove(protocollo, titolario)
                    protocollo.version = protocollo.domainObject.version
                }
                listaTitolari.remove(titolario)
                refreshListaTitolari()
                Clients.showNotification("Classifica secondaria eliminata", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
            }
        }
    }

    @Command
    void onApriTabRiferimenti() {
        if (protocollo.id > 0) {
            refreshListaDocumentiCollegati()
            refreshListaCollegamenti()
            refreshRiferimenti()
        }
    }

    private void refreshListaCollegamenti() {
        // filtro tutto tranne gli allegati
        String s = "Non si dispone dei diritti per visualizzare il documento"
        listaCollegamenti = protocolloService.getCollegamentiVisibili(protocollo.domainObject)?.toDTO(["collegato.tipoRegistro", "tipoCollegamento"])
        for (DocumentoCollegatoDTO collegato : listaCollegamenti) {
            if (!(collegato.documento.class == MessaggioRicevutoDTO.class) &&
                    !(collegato.collegato.class == MessaggioInviatoDTO.class)) {
                //Devo verificare le competenze sia sul collegato che sul documento in collegato
                Map competenzeCollegato = gestoreCompetenze.getCompetenze(collegato.collegato.domainObject)
                if (!competenzeCollegato || !competenzeCollegato?.lettura) {
                    collegato.collegato.oggetto = s
                }
                Map competenzeDocumento = gestoreCompetenze.getCompetenze(collegato.documento.domainObject)
                if (!competenzeDocumento || !competenzeDocumento?.lettura) {
                    collegato.documento.oggetto = s
                }
            }
        }
        BindUtils.postNotifyChange(null, null, this, "listaCollegamenti")
    }

    @Command
    void onApriCatenaDocumentale() {
        if (protocollo.id > 0) {
            //carico e aggiorno la catena solo la prima volta (altrimenti perderei lo stato di apertura)
            //posso fare questo perchè i nodi sono caricati on demand
            if (null == catenaDocumentale) {
                catenaDocumentale = new AlberoCatenaDocumentale(protocollo)
                BindUtils.postNotifyChange(null, null, this, "catenaDocumentale")
            }
        }
    }

    @Command
    void onSelectStatoArchivistico() {
        protocollo.dataStatoArchivio = new Date()
        BindUtils.postNotifyChange(null, null, this, "protocollo")
    }

    List<Protocollo.StatoArchivio> getStatiArchivio() {
        List<Protocollo.StatoArchivio> stati = Protocollo.StatoArchivio.values()
        stati.add(0, null)
        return stati
    }

    @Command
    void onApriTabMessaggi() {
        refreshMessaggi()
        refreshCorrispondentiMessaggi()
    }

    @Command
    void onApriTabAnnullamenti() {
        Protocollo p = protocollo.domainObject
        refreshAnnullamenti(p)
    }

    @Command
    void refreshCorrispondente() {
        //listaCorrispondentiDto =  Corrispondente.findAllByProtocollo(protocollo.domainObject)?.toDTO()
        for (CorrispondenteDTO corrispondenteInConoscenza : listaCorrispondentiDto) {
            corrispondenteInConoscenza.conoscenza = tramiteCC
            Corrispondente c = corrispondenteInConoscenza.domainObject
            if (c) {
                corrispondenteService.aggiorna(corrispondenteInConoscenza)
            }
        }
        BindUtils.postNotifyChange(null, null, this, "listaCorrispondentiDto")
    }

    @Command
    void onTestoEliminato() {
        Protocollo p = (Protocollo) protocollo.domainObject
        protocolloService.eliminaTesto(p)

        // Utile quando carico un file già firmato esternamente: quando si elimina il testo resetto i dati di firma
        p.esitoVerifica = Protocollo.ESITO_NON_VERIFICATO
        p.dataVerifica = null

        aggiornaMaschera(p)
        protocollo.version = protocollo.domainObject.version
    }

    /*
     * Gestione del Modello Testo
     */

    private void caricaListaModelloTesto() {
        FileDocumentoDTO testoPrincipale = protocollo.testoPrincipale
        if (testoPrincipale?.modelloTesto == null) {
            GestioneTestiModello modelloTestoPredefinito = TipoProtocollo.modelloTestoPredefinito(protocollo.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
            if (modelloTestoPredefinito) {
                testoPrincipale.modelloTesto = modelloTestoPredefinito.toDTO()
            } else if (protocollo.tipoProtocollo.domainObject.categoriaProtocollo.modelloTestoObbligatorio) {
                throw new ProtocolloRuntimeException("Attenzione: Non è stato definito un modello di testo principale per questa tipologia")
            }
        }
    }

    List<GestioneTestiModelloDTO> getListaModelliTesto() {
        if (protocollo?.tipoProtocollo?.id == null) {
            return []
        }

        List<GestioneTestiModelloDTO> modelli = tipoProtocolloService.listaModelliTestoConCompetenza(protocollo.tipoProtocollo, soggetti.UO_PROTOCOLLANTE?.unita).unique {
            it.id
        }

        return modelli
    }

    private List<Long> getlistaModelliTestoAssociati() {

        if (protocollo?.tipoProtocollo?.id == null) {
            return []
        }

        return tipoProtocolloService.listaModelliTesto(protocollo.tipoProtocollo.id)
    }

    /**
     * Scelta dell'oggetto della documento
     */
    @Command
    void onSceltaOggettoRicorrente() {
        Window w = Executions.createComponents("/documenti/popupSceltaOggettoRicorrente.zul", self, null)
        w.onClose { event ->
            if (event.data != null) {
                protocollo.oggetto = event.data.toUpperCase()
                BindUtils.postNotifyChange(null, null, this, "protocollo")
            }
        }
        w.doModal()
    }

    /*
     * Gestisce le note di trasmissioni
     */

    private void aggiornaNoteTrasmissionePrecedenti(Protocollo protocollo) {
        Map result = protocolloService.getNoteTrasmissionePrecedenti(protocollo)
        noteTrasmissionePrecedenti = result.noteTrasmissionePrecedenti
        attorePrecedente = result.attorePrecedente
        mostraNoteTrasmissionePrecedenti = result.mostraNoteTrasmissionePrecedenti

        BindUtils.postNotifyChange(null, null, this, "mostraNoteTrasmissionePrecedenti")
        BindUtils.postNotifyChange(null, null, this, "noteTrasmissionePrecedenti")
        BindUtils.postNotifyChange(null, null, this, "attorePrecedente")
    }

    /*
     * Metodi per il calcolo dei Soggetti della documento
     */

    @Command
    void onSceltaSoggetto(
            @BindingParam("tipoSoggetto") String tipoSoggetto,
            @BindingParam("categoriaSoggetto") String categoriaSoggetto) {
        Window w = Executions.createComponents("/documenti/popupSceltaSoggetto.zul", self, [idTipologiaSoggetto: protocollo.tipoProtocollo.tipologiaSoggetto.id
                                                                                            , documento        : protocollo
                                                                                            , soggetti         : soggetti
                                                                                            , tipoSoggetto     : tipoSoggetto
                                                                                            , categoriaSoggetto: categoriaSoggetto])
        w.onClose { event ->
            // se ho annullato la modifica, non faccio niente:
            if (event.data == null) {
                return
            }

            // altrimenti aggiorno i soggetti.
            BindUtils.postNotifyChange(null, null, this, "soggetti")
        }
        w.doModal()
    }

    private void calcolaSoggetti(@BindingParam("tipoSoggetto") String tipoSoggetto) {
        tipologiaSoggettoService.aggiornaSoggetti(protocollo.tipoProtocollo.tipologiaSoggetto.id, protocollo.domainObject ?: protocollo, soggetti, tipoSoggetto)
        BindUtils.postNotifyChange(null, null, this, "soggetti")
    }

    /*
     * Gestione allegati
     */

    @Command
    void onModificaAllegato(@ContextParam(ContextType.TRIGGER_EVENT) Event event, @BindingParam("nuovo") boolean nuovo, @BindingParam("allegato") AllegatoDTO allegato) {
        long idAllegato
        boolean modificaAll = competenze.modifica && privilegioUtenteService.isInserimentoAllegati(protocollo) && privilegioUtenteService.isModificaAllegati(protocollo) && privilegioUtenteService.isEliminaAllegati(protocollo)

        if (nuovo == false) {
            if (allegato) {
                idAllegato = allegato.id
            } else {
                idAllegato = event.target.selectedItem.value.id
            }
        }

        AllegatoViewModel.apri(self, (nuovo ? -1 : idAllegato), protocollo, modificaAll).addEventListener(Events.ON_CLOSE) { Event e ->
            // potrei aver aggiornato il documento, quindi ne riprendo i numeri di versione e idDocumentoEsterno.
            Documento d = protocollo.domainObject
            protocollo.version = d.version
            protocollo.idDocumentoEsterno = d.idDocumentoEsterno
            refreshListaAllegati()
        }
    }

    @Command
    void onEliminaAllegato(@BindingParam("allegato") AllegatoDTO allegato) {
        Messagebox.show("Eliminare l'allegato selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                documentoService.eliminaAllegato(allegato.domainObject)
                protocollo.version = protocollo.domainObject.version
                this.refreshListaAllegati()
                if (protocollo.numero > 0) {
                    protocolloService.storicizzaProtocollo(protocollo.domainObject)
                }
            }
        }
    }

    public void refreshListaAllegati() {
        listaAllegati = protocollo.domainObject.allegati.toDTO(["tipoAllegato"]).sort { it.sequenza }
        BindUtils.postNotifyChange(null, null, this, "listaAllegati")
    }

    private void refreshDatiScarto() {
        listaStatiScarto = StatoScarto.list([sort: "descrizione", order: "asc"]).toDTO()
        StatoScartoDTO vuoto = listaStatiScarto.find { it.descrizione == null }
        listaStatiScarto.remove(vuoto)
        listaStatiScarto.add(0, vuoto)
        BindUtils.postNotifyChange(null, null, this, "listaStatiScarto")
    }

    @Command
    void cambiaStatoScarto(@BindingParam("statoScarto") Combobox target) {
        protocollo.datiScarto = new ProtocolloDatiScartoDTO(stato: target.selectedItem.value, dataStato: dateService.getCurrentDate())
        BindUtils.postNotifyChange(null, null, this, "protocollo")
        BindUtils.postNotifyChange(null, null, this, "protocollo.datiScarto")
    }

    private void refreshMessaggi() {
        if (protocollo.numero == null) {
            return
        }

        onPagingMessaggi()
    }

    @Command
    void onPagingMessaggi() {
        Protocollo p = protocollo.domainObject

        messaggi = mailService.caricaMessaggiInviati(p, pageSizeMessaggi, 0)
        totalSizeMessaggi = messaggi.size()
        messaggi = PaginationUtils.getPaginationObject(messaggi, pageSizeMessaggi, activePageMessaggi)

        pec = totalSizeMessaggi > 0

        refreshCorrispondenti()

        BindUtils.postNotifyChange(null, null, this, "messaggi")
        BindUtils.postNotifyChange(null, null, this, "activePageMessaggi")
        BindUtils.postNotifyChange(null, null, this, "totalSizeMessaggi")
    }

    private void refreshCorrispondenti() {

        Protocollo protocolloDomain = protocollo.domainObject
        if (protocolloDomain) {
            listaCorrispondentiDto = Corrispondente.findAllByProtocollo(protocolloDomain)?.toDTO(["messaggi"])
            listaCorrispondentiDto?.sort { it.id }?.each { it.protocollo = protocollo }
        }
        BindUtils.postNotifyChange(null, null, this, "listaCorrispondentiDto")
    }

    @Command
    void onPagingCorrispondentiMessaggi() {
        Protocollo p = protocollo.domainObject
        listaCorrispondentiMessaggi = []

        List<Corrispondente> corrispondentiList = p.corrispondenti.findAll {
            it.messaggi.size() > 0
        }.toList().sort { it.id }

        totalSizeListaCorrispondentiMessaggi = corrispondentiList.size()
        int offset = pageSizeListaCorrispondentiMessaggi * (activePageListaCorrispondentiMessaggi + 1)
        if (offset >= totalSizeListaCorrispondentiMessaggi) {
            offset = totalSizeListaCorrispondentiMessaggi
        }

        List<Corrispondente> corrispondenti = corrispondentiList.subList(activePageListaCorrispondentiMessaggi * pageSizeListaCorrispondentiMessaggi, offset)

        for (Corrispondente dest : corrispondenti) {
            List<CorrispondenteMessaggioDTO> corrispondenteMessaggi = CorrispondenteMessaggio.findAllByCorrispondente(dest, [sort: "denominazione", order: "asc"]).toDTO()

            CorrispondenteMessaggioDTO corr = new CorrispondenteMessaggioDTO()
            for (CorrispondenteMessaggioDTO c : corrispondenteMessaggi) {
                if (c.registrataConsegna) {
                    corr.registrataConsegna = true
                    corr.ricevutaMancataConsegna = false
                }
                if (!corr.registrataConsegna && c.ricevutaMancataConsegna) {
                    corr.ricevutaMancataConsegna = true
                }
                if (c.ricevutaEccezione) {
                    corr.ricevutaEccezione = true
                }
                if (c.ricevutaConferma) {
                    corr.ricevutaConferma = true
                }
            }

            if (corrispondenteMessaggi.size() > 0) {
                corr.denominazione = dest.denominazione
                corr.email = dest.email
                corr.corrispondente = dest.toDTO()
                listaCorrispondentiMessaggi.add(corr)
            }
        }

        BindUtils.postNotifyChange(null, null, this, "listaCorrispondentiMessaggi")
        BindUtils.postNotifyChange(null, null, this, "activePageListaCorrispondentiMessaggi")
        BindUtils.postNotifyChange(null, null, this, "totalSizeListaCorrispondentiMessaggi")
    }

    @Command
    void dettaglioCorrispondente(@BindingParam("corrispondente") CorrispondenteDTO corrispondente) {
        Window w = (Window) Executions.createComponents("/protocollo/documenti/commons/corrispondente.zul", null, [corrispondente: corrispondente, competenze: competenze, modificaRapporti: false, modificaAnagrafe: false])
        w.doModal()
    }

    String getInfoConsegnaCorrispondente(CorrispondenteMessaggioDTO corrispondente, String tipo) {
        String ret = ""
        Date dataConsegna
        if (tipo == "CONSEGNA") {
            dataConsegna = corrispondente.dataConsegna

            if (corrispondente.registrataConsegna) {
                ret = "Sì"
            } else {
                ret = "No"
            }
        } else {
            dataConsegna = corrispondente.dataMancataConsegna

            if (corrispondente.ricevutaMancataConsegna) {
                ret = "Sì"
            } else {
                ret = "No"
            }
        }

        if (dataConsegna != null && ret == "Sì") {
            ret += " il " + (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(dataConsegna))
        }

        return ret
    }

    Date getDataAccettazioneMessaggio(MessaggioDTO messaggioDTO) {
        //Torno la prima piena perché so che tanto sono mutuamente esclusive
        MessaggioInviato messaggioInviato = messaggiInviatiService.getMessaggio(messaggioDTO.id)
        if (messaggioInviato != null) {
            if (messaggioInviato?.dataAccettazione) {
                return messaggioInviato?.dataAccettazione
            }
            if (messaggioInviato?.dataNonAccettazione) {
                return messaggioInviato?.dataNonAccettazione
            }
        }

        return null
    }

    String getInfoSpedizioneMessaggio(MessaggioDTO messaggioDTO) {
        String spedizione
        spedizione = messaggioDTO.oggetto + ((messaggioDTO.statoMemo != null) ? " " + messaggioDTO.statoMemo : "")

        if (messaggioDTO.utenteIns?.nominativo != null) {
            spedizione += " - Spedito da " + messaggioDTO.utenteIns?.nominativo
        }

        if (messaggioDTO.dataSpedizioneMemo != null) {
            spedizione += ((messaggioDTO.utenteIns?.nominativo == null) ? " Spedito il " : " il ") + messaggioDTO.dataSpedizioneMemo
        }

        return spedizione
    }

    private void refreshCorrispondentiMessaggi() {
        onPagingCorrispondentiMessaggi()
    }

    private void refreshAnnullamenti(Protocollo protocolloD) {
        if (protocolloD.numero == null) {
            return
        }
        listaAnnullamentiRifiutati = ProtocolloAnnullamento.findAllByProtocolloAndStato(protocolloD, StatoAnnullamento.RIFIUTATO,
                [sort: "dataAccettazioneRifiuto", order: "desc"])?.toDTO(["utenteAccettazioneRifiuto", "utenteIns"])

        annullamentoAccettato = ProtocolloAnnullamento.findByProtocolloAndStato(protocolloD, StatoAnnullamento.ACCETTATO)?.toDTO(["unita", "utenteIns", "utenteAccettazioneRifiuto"])

        if (protocolloD.annullato && protocolloD.stato == StatoDocumento.ANNULLATO) {
            annullamentoDiretto = ProtocolloAnnullamento.findByProtocolloAndStato(protocolloD, StatoAnnullamento.ANNULLATO)?.toDTO(["dateCreated", "utenteIns"])
        }

        annullamentoRichiesto = ProtocolloAnnullamento.findByProtocolloAndStato(protocolloD, StatoAnnullamento.RICHIESTO)?.toDTO(["unita", "utenteIns"])

        annullamentoVisibile = ProtocolloAnnullamento.countByProtocollo(protocolloD) > 0
        if (protocolloD.stato == StatoDocumento.RICHIESTO_ANNULLAMENTO) {
            if (gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO)) {
                richiestaAnnullamento = true
            }
        } else {
            richiestaAnnullamento = false
        }

        protocollo.utenteAnnullamento = protocolloD.utenteAnnullamento?.toDTO()
        protocollo.dataAnnullamento = protocolloD.dataAnnullamento
        protocollo.provvedimentoAnnullamento = protocolloD.provvedimentoAnnullamento

        BindUtils.postNotifyChange(null, null, this, "protocollo")
        BindUtils.postNotifyChange(null, null, this, "listaAnnullamentiRifiutati")
        BindUtils.postNotifyChange(null, null, this, "annullamentoDiretto")
        BindUtils.postNotifyChange(null, null, this, "annullamentoAccettato")
        BindUtils.postNotifyChange(null, null, this, "annullamentoRichiesto")
        BindUtils.postNotifyChange(null, null, this, "annullamentoVisibile")
        BindUtils.postNotifyChange(null, null, this, "richiestaAnnullamento")
    }

    /*
     * Gestione Documenti collegati
     */

    @Command
    void onAggiungiRiferimento() {
        Window w = Executions.createComponents("/commons/popupImportAllegatiIntegrazione.zul", self, [documento: protocollo])
        w.onClose { event ->
            if (event != null && event?.data != null) {
                refreshRiferimenti()
            }
        }
        w.doModal()
    }

    private void salvaProtocolloPrecedente(DocumentoCollegatoDTO documentoCollegatoDTO, DocumentoDTO target = protocollo) {
        ProtocolloDTO protPrec = documentoCollegatoDTO.collegato
        Protocollo prot = Protocollo.findByIdDocumentoEsterno(protPrec.idDocumentoEsterno)
        if (prot == null) {
            prot = protocolloService.salvaDto(protPrec)
        }
        documentoCollegatoDTO.collegato = prot.toDTO(["tipoRegistro"])
        Protocollo protocolloDomain = target.domainObject
        ProtocolloDTO salvato
        //Se il protocollo è stato già salvato inserisco a DB altrimenti in listaCollegamenti
        if (protocolloDomain) {
            salvato = protocolloService.salvaProtocolloPrecedente(protocolloDomain, prot).toDTO()
            if (protocollo.id == target.id) {
                //protocollo = salvato
                //annoPrecedente = documentoCollegatoDTO.collegato.anno
                //numeroPrecedente = documentoCollegatoDTO.collegato.numero
                tipoRegistroPrecedente = documentoCollegatoDTO.collegato.tipoRegistro
                refreshListaDocumentiCollegati()
                refreshProtocolloPrecedenteFix(documentoCollegatoDTO)
            }
        } else {
            //Rimuovo tutto, ovvero il solo collegamento se già inserito, e reinserisco
            listaCollegamenti.removeAll(listaCollegamenti)
            listaCollegamenti.add(documentoCollegatoDTO)
            refreshProtocolloPrecedenteFix(documentoCollegatoDTO)
        }
    }

    /**
     * Refresho i campi del protocollo precedente sempre visibili in pagina
     *
     * @param documentoCollegatoDTO
     */
    private void refreshProtocolloPrecedenteFix(DocumentoCollegatoDTO documentoCollegatoDTO) {
        protocolloPrecendeteDTO = documentoCollegatoDTO?.collegato
        BindUtils.postNotifyChange(null, null, this, "protocolloPrecendeteDTO")
    }

    private void salvaRiferimentoDatiAccesso(DocumentoCollegatoDTO documentoCollegatoDTO, DocumentoDTO target = protocollo) {
        ProtocolloDTO protPrec = documentoCollegatoDTO.collegato
        Protocollo prot = Protocollo.findByIdDocumentoEsterno(protPrec.idDocumentoEsterno)
        if (prot == null) {
            prot = protocolloService.salvaDto(protPrec)
        }
        documentoCollegatoDTO.collegato = prot.toDTO(["tipoRegistro"])
        protocolloService.salvaRiferimentoDatiAccesso(prot, target.domainObject)
    }

    private void salvaCollegamento(String tipoCollegamento, DocumentoCollegatoDTO documentoCollegatoDTO) {
        ProtocolloDTO collegatoDTO = documentoCollegatoDTO.collegato
        Protocollo collegato = Protocollo.findByIdDocumentoEsterno(collegatoDTO.idDocumentoEsterno)
        if (collegato == null) {
            collegato = protocolloService.salvaDto(collegatoDTO)
        }
        documentoCollegatoDTO.collegato = collegato.toDTO(["tipoRegistro"])
        protocolloService.salvaCollegamentoUnico(protocollo.domainObject, collegato, tipoCollegamento)
        refreshListaDocumentiCollegati()
    }

    @Command
    void onRicercaCollegato(@BindingParam("annoSearch") String anno, @BindingParam("numeroSearch") String numero) {
        ricercaCollegato(anno, numero, tipoRegistroPrecedente)
    }

    @Command
    void onRicercaCollegatoFix(@BindingParam("annoSearch") String anno, @BindingParam("numeroSearch") String numero) {
        ricercaCollegato(anno, numero, tipoRegistroPrecedenteFix)
    }

    void ricercaCollegato(String anno, String numero, TipoRegistroDTO tipoRegistroPrecedente) {
        if (!verificaParametriDiRicercaProtocollo(anno, numero)) {
            return
        }

        ProtocolloEsternoDTO protocolloEsternoDTO = protocolloEsternoService.findProtocolloEsterno(anno, numero, tipoRegistroPrecedente.codice)?.toDTO()

        if (protocolloEsternoDTO != null) {
            DocumentoCollegatoDTO documentoCollegatoDTO = new DocumentoCollegatoDTO()
            documentoCollegatoDTO.tipoCollegamento = TipoCollegamento.findByCodice(tipoCollegamento?.codice ?: TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE).toDTO()
            TipoProtocollo tipoProcollo = TipoProtocollo.findByCategoria(protocolloEsternoDTO.categoria)
            if (tipoProcollo == null) {
                Messagebox.show("Attenzione: bisogna censire il tipo di Protocollo: " + protocolloEsternoDTO.categoria)
                return
            }
            Protocollo protocolloRichiesto
            if (tipoCollegamento?.codice == TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO) {
                protocolloRichiesto = protocolloRepository.getProtocolloFromIdDocumentoEsterno(protocolloEsternoDTO.idDocumentoEsterno)
                Protocollo protocolloRisposta = protocolloRepository.getProtocolloPrecedente(protocolloEsternoDTO.idDocumentoEsterno, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
                if (!protocolloRichiesto || !protocolloRichiesto.schemaProtocollo?.domandaAccesso || !protocolloRichiesto.valido || protocolloRisposta) {
                    Messagebox.show("Attenzione: il protocollo selezionato non esiste o ha uno schema senza domanda accesso o ha una risposta")
                    return
                }

                //Il controllo deve essere fatto sul protocollo che sto cercando di collegare se questo ha una risposta allora non posso collegarlo
                ProtocolloDTO protDaCollegare = protocolloRepository.findByAnnoAndNumeroAndTipoRegistro(protocolloEsternoDTO.anno, protocolloEsternoDTO.numero, protocolloEsternoDTO.tipoRegistro.codice).toDTO()
                ProtocolloAccessoCivicoDTO protocolloAccessoCivico = accessoCivicoService.recuperaDatiAccessoDallaDomanda(protDaCollegare)
                Protocollo risposta = protocolloAccessoCivico?.protocolloRisposta?.domainObject
                if (risposta && !risposta.annullato) {
                    Messagebox.show("Attenzione: la domanda di accesso ha già associata una risposta non annullata")
                    return
                }
            }

            ProtocolloDTO protocolloPrecedenteDto = protocolloEsternoService.salvaProtocolloTrascodificato(protocolloEsternoDTO.idDocumentoEsterno)?.toDTO()
            if (null == protocolloPrecedenteDto) {
                Protocollo prot = protocolloEsternoService.creaProtocolloDaProtocolloEsterno(protocolloEsternoDTO)
                protocolloPrecedenteDto = prot.toDTO()
            }

            documentoCollegatoDTO.collegato = protocolloPrecedenteDto
            documentoCollegatoDTO.documento = protocollo

            if (tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE) {

                if (protocollo.isProtocollato()) {

                    if (protocolloPrecedenteDto.anno == protocollo.anno && protocolloPrecedenteDto.numero == protocollo.numero && protocollo.tipoRegistro?.codice == protocolloPrecedenteDto.tipoRegistro?.codice) {
                        Clients.showNotification("Impossibile associare come precedente il protocollo stesso", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
                        return
                    }

                    if (protocolloPrecedenteDto.data.after(protocollo.data)) {
                        Clients.showNotification("Il precedente non può essere un protocollo successivo a quello che sto modificando", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
                        return
                    }
                }

                if (documentoCollegatoRepository.collegamentiPerTipologia(protocollo.domainObject, TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)).size() > 0) {
                    Messagebox.show("Sostituire il precedente con il documento \n" + protocolloPrecedenteDto.anno + "/" + protocolloPrecedenteDto.numero + " - " + protocolloPrecedenteDto.tipoRegistro.commento + "?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
                        if (e.getName() == Messagebox.ON_OK) {
                            salvaProtocolloPrecedente(documentoCollegatoDTO)
                            ClientsUtils.showInfo("Protocollo precedente inserito")
                        }
                    }
                } else {
                    salvaProtocolloPrecedente(documentoCollegatoDTO)
                    ClientsUtils.showInfo("Protocollo precedente inserito")
                }
            }
            // se domanda accesso fare altre operazioni (GDO)- se hai il tipo DATI_ACCESSO salvo in protocollo accesso civico
            else if (tipoCollegamento?.codice == TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO) {
                ProtocolloAccessoCivico pac = protocolloAccessoCivicoRepository.findByProtocolloDomanda(protocolloRichiesto)
                if (pac) {
                    pac.protocolloRisposta = protocolloService.getProtocollo(protocollo.id)
                    pac.save()
                }
                DocumentoCollegatoDTO documentoCollegatoRisposta = new DocumentoCollegatoDTO()
                documentoCollegatoRisposta.tipoCollegamento = tipoCollegamento
                documentoCollegatoRisposta.documento = protocolloRichiesto.toDTO()
                documentoCollegatoRisposta.collegato = protocollo
                salvaRiferimentoDatiAccesso(documentoCollegatoRisposta, documentoCollegatoRisposta.documento)
                aggiornaMaschera(protocollo.domainObject)
            } else {
                salvaCollegamento(tipoCollegamento.codice, documentoCollegatoDTO)
            }
        } else {
            Clients.showNotification("Nessun documento trovato per anno: " + anno + " numero: " + numero + " registro " + tipoRegistroPrecedente.commento, Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
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

        if (anno == "" || numero == "" || tipoRegistroPrecedente == null || tipoRegistroPrecedente?.codice == "") {
            Clients.showNotification("Valorizzare l'anno, il numero e il registro", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return false
        }
        return true
    }

    public boolean isProtocolloPec() {
        return protocolloService.isProtocolloPec(protocollo)
    }

    String getDataSpedizioneMail() {
        String dataSpedizioneMemo = ""
        if (isProtocolloPec()) {
            Messaggio messaggio = mailService.caricaMessaggioRicevuto(protocollo.domainObject)
            if (messaggio != null) {
                dataSpedizioneMemo = messaggio.dataSpedizioneMemo
            }
        }

        return dataSpedizioneMemo
    }

    /**
     Per ora si vedono solo i protocolli precedenti
     */
    private void refreshListaDocumentiCollegati() {
        listaDocumentiCollegati = protocollo.domainObject?.getDocumentiCollegati(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)?.toDTO(["tipoRegistro"])

        if (listaDocumentiCollegati != null && listaDocumentiCollegati.size() > 0) {
            protocolloPrecendeteDTO = listaDocumentiCollegati.get(0)
            Protocollo protocolloPrecedente = protocolloPrecendeteDTO.domainObject;
            Map competenzePrecedente = gestoreCompetenze.getCompetenze(protocolloPrecedente)
            if (!competenzePrecedente || !competenzePrecedente?.lettura) {
                protocolloPrecendeteDTO.oggetto = "Non si dispone dei diritti per visualizzare il documento"
            }
            //annoPrecedente = protocolloPrecendeteDTO.anno
            //numeroPrecedente = protocolloPrecendeteDTO.numero
            //Aggiorno i campi sempre visibili del Protocollo precedente
            annoPrecedenteFix = protocolloPrecendeteDTO.anno
            numeroPrecedenteFix = protocolloPrecendeteDTO.numero
            tipoRegistroPrecedenteFix = protocolloPrecedente.tipoRegistro.toDTO()
            tipoRegistroPrecedente = protocolloPrecedente.tipoRegistro.toDTO()
        } else {
            //Se non ho nulla in lista devo resettare i campi sempre visibili in pagina
            resetProtocolloPrecedenteFix()
            refreshProtocolloPrecedenteFix(null)
        }
        //al termine resetto la catenaDocumentale per ricaricarla aggiornata
        resetCatenaDocumentale()
        refreshListaCollegamenti()
        BindUtils.postNotifyChange(null, null, this, "listaDocumentiCollegati")
        BindUtils.postNotifyChange(null, null, this, "annoPrecedente")
        BindUtils.postNotifyChange(null, null, this, "numeroPrecedente")
        BindUtils.postNotifyChange(null, null, this, "tipoRegistroPrecedente")
        BindUtils.postNotifyChange(null, null, this, "annoPrecedenteFix")
        BindUtils.postNotifyChange(null, null, this, "numeroPrecedenteFix")
        BindUtils.postNotifyChange(null, null, this, "tipoRegistroPrecedenteFix")
    }

    /**
     * Resetto i campi del protocollo precedente sempre visibili in pagina
     */
    private void resetProtocolloPrecedenteFix() {
        annoPrecedenteFix = null
        numeroPrecedenteFix = null
        tipoRegistroPrecedente = TipoRegistro.findByCodice(ImpostazioniProtocollo.TIPO_REGISTRO.valore).toDTO()
        tipoRegistroPrecedenteFix = tipoRegistroPrecedente
        protocolloPrecendeteDTO = null
    }

    @Command
    void onEliminaDocumentoCollegato(@BindingParam("documentoCollegato") DocumentoCollegatoDTO documentoCollegato) {
        Messagebox.show("Eliminare il collegamento selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (e.getName() == Messagebox.ON_OK) {
                protocolloService.eliminaDocumentoCollegato(protocollo.domainObject, documentoCollegato.collegato.domainObject, documentoCollegato.tipoCollegamento.codice)
                protocollo.version = protocollo.domainObject.version
                refreshListaDocumentiCollegati()
            }
        }
    }

    @Command
    void onEliminaRiferimento(@BindingParam("riferimento") riferimento) {
        Messagebox.show("Eliminare il riferimento selezionato?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                protocolloService.eliminaRiferimento(protocollo.domainObject, riferimento.domainObject)
                refreshRiferimenti()
            }
        }
    }

    private void refreshRiferimenti() {
        listaRiferimenti = Riferimento.findAllByIdDocumento(protocollo.idDocumentoEsterno).toDTO()
        for (RiferimentoDTO riferimento : listaRiferimenti) {
            Protocollo protocolloCollegato = Protocollo.findByIdDocumentoEsterno(riferimento.getIdRiferimento())
            if (protocolloCollegato) {
                Map competenzeCollegato = gestoreCompetenze.getCompetenze(protocolloCollegato)
                if (!competenzeCollegato || !competenzeCollegato?.lettura) {
                    String s = "Non si dispone dei diritti per visualizzare il documento"
                    riferimento.oggettoRiferimento = s
                    riferimento.urlRiferimento = null
                }
            }
        }
        BindUtils.postNotifyChange(null, null, this, "listaRiferimenti")
    }

    @Command
    void apriDocumentoCollegato(@BindingParam("documentoCollegato") DocumentoDTO documentoCollegato, @BindingParam("tipoCollegamento") String tipo) {
        documentoCollegatoProtocolloService.apriDocumentoCollegato(protocollo.domainObject, documentoCollegato.domainObject, tipo, competenze.modifica.asBoolean())
    }

    @Command
    void apriRiferimento(@BindingParam("riferimento") riferimento) {
        String link = riferimento.urlRiferimento
        Clients.evalJavaScript(" window.open('" + link + "'); ")
    }

    @Command
    void apriMessaggio(@BindingParam("messaggio") messaggio) {
        if (messaggio.linkDocumento == null) {
            if (messaggio.inPartenza) {
                Clients.evalJavaScript(" window.open('/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_INVIATO&id=" + messaggio.id + "');")
            } else {
                MessaggioDTO messaggioDTO = messaggiRicevutiService.getMessaggioDto(messaggio.id)
                Clients.evalJavaScript(" window.open('/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_RICEVUTO&id=" + messaggioDTO.id + "');")
            }
        } else {
            String link = messaggio.linkDocumento
            Clients.evalJavaScript(" window.open('" + link + "'); ")
        }
    }

    @Command
    void apriMessaggioConsegna(@BindingParam("messaggio") messaggio, @BindingParam("tipoRicevuta") tipoRicevuta) {
        Long idMessaggio
        idMessaggio = messaggio.id
        List<DocumentoCollegato> documentoCollegati = documentoCollegatoRepository.collegamentiPerTipologia(messaggiInviatiService.getMessaggio(idMessaggio), TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_PROT_PEC))
        if (documentoCollegati?.size() > 0) {

            for (documentoCollegato in documentoCollegati) {
                if (documentoCollegato.collegato.class == MessaggioRicevuto.class) {
                    MessaggioRicevuto messaggioRicevuto = documentoCollegato.collegato

                    if (messaggioRicevuto.tipo == tipoRicevuta) {
                        Clients.evalJavaScript(" window.open('/Protocollo/standalone.zul?operazione=APRI_MESSAGGIO_RICEVUTO&id=" + messaggioRicevuto.id + "');")
                        return
                    }
                }
            }
        }
    }

    @Command
    void onAccettaRichiestaAnnullamento() {
        Protocollo p = protocollo.domainObject
        protocolloService.accettaRichiestaAnnullamento(p)
        protocollo.version = p.version
        richiestaAnnullamento = false

        refreshAnnullamenti(p)
        aggiornaMaschera(p)
    }

    @Command
    void onRifiutaRichiestaAnnullamento() {
        Window w = Executions.createComponents("/commons/popupRifiutaRichiestaAnnullamento.zul", self, [protocollo: protocollo])
        w.onClose { event ->
            Protocollo p = protocollo.domainObject
            protocollo.version = p.version
            refreshAnnullamenti(p)
            aggiornaMaschera(p)
        }
        w.doModal()
    }

    /*
     *  Gestione Chiusura Maschera
     */

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    @Command
    void onNascondi() {
        self.setVisible(false)
    }

    @Command
    void onElimina() {
        Messagebox.show(Labels.getLabel("protocollo.cancellaRecordMessageBoxTesto"), Labels.getLabel("protocollo.cancellaRecordMessageBoxTitolo"),
                Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                Protocollo p = protocollo.domainObject
                if (rispostaAccessoCivico || domandaAccessoCivico) {
                    accessoCivicoService.eliminaAccessoCivico(p)
                }

                Protocollo protocolloDaFascicolare = null
                for (DocumentoCollegatoDTO it : listaCollegamenti) {
                    if (it.tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_PROT_DA_FASCICOLARE) {
                        protocolloDaFascicolare = it.collegato.domainObject
                        break;
                    }
                }

                protocolloService.elimina(p)
                onChiudi()
                if (protocolloDaFascicolare) {
                    protocolloService.ripristina(protocolloDaFascicolare)
                    if (protocolloDaFascicolare) {
                        apriPopup(CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codice, protocolloDaFascicolare.id)
                    }
                }
            }
        }
    }

/*
 *  Presa Visione
 */

    @Command
    void onPresaVisione() {
        isNotificaPresente = false
        BindUtils.postNotifyChange(null, null, this, "isNotificaPresente")
    }

    @Command
    void creaStampaUnica() {
        protocolloJob.creaStampaUnicaProtocollo(protocollo.id, springSecurityService.principal.username, springSecurityService.principal.idEnte, {
            this.protocollo.version = protocollo.domainObject.version
        })
        stampaUnicaInCorso = true
        ClientsUtils.showInfo("Stampa unica in creazione.")
    }

/*
 * Implementazione dei Metodi per AbstractViewModel
 */

    @Override
    WkfCfgIter getCfgIter() {
        return WkfCfgIter.getIterIstanziabile(protocollo.tipoProtocollo?.progressivoCfgIter ?: ((long) -1)).get()
    }

    Protocollo getDocumentoIterabile(boolean controllaConcorrenza) {
        if (protocollo?.id > 0) {
            Protocollo domainObject = protocollo.getDomainObject()
            if (domainObject == null) {
                protocollo.id = null
                return new Protocollo()
            }
            if (!stampaUnicaInCorso && controllaConcorrenza && protocollo?.version >= 0 && domainObject.version != protocollo?.version) {
                throw new ProtocolloRuntimeException("Attenzione: un altro utente ha modificato il documento su cui si sta lavorando. Impossibile continuare. \n (dto.version=${protocollo?.version}!=domain.version=${domainObject?.version})")
            }
            return domainObject
        }

        protocollo.id = null
        return new Protocollo()
    }

    Collection<String> validaMaschera() {
        List<String> messaggi = []

        if (protocollo.tipoProtocollo.categoriaProtocollo.isMovimentoObbligatorio() && protocollo.movimento == null) {
            messaggi << "Valorizzare il movimento."
        }

        if (!allegatoProtocolloService.isValidaFileAllegatoObbligatorio(protocollo) && protocollo?.numero) {
            messaggi << "Deve esistere almeno un file su ogni allegato."
        }

        if (protocollo.oggetto == null || protocollo.oggetto?.trim().size() == 0) {
            messaggi << "Valorizzare l'oggetto."
        }

        if (protocollo.oggetto != null && !Utils.controllaCharset(protocollo.oggetto)) {
            messaggi << "L'Oggetto contiene dei caratteri non supportati."
        }

        if (protocollo.oggetto != null && protocollo.oggetto.size() > Impostazioni.LUNGHEZZA_OGGETTO.valoreInt) {
            messaggi << "La lunghezza dell'oggetto inserito è superiore a " + Impostazioni.LUNGHEZZA_OGGETTO.valore + " caratteri"
        }

        if (protocollo.controlloFunzionario && soggetti[TipoSoggetto.FUNZIONARIO]?.utente == null) {
            messaggi << "Valorizzare il Funzionario."
        }

        if (funzionarioValorizzabile && soggetti[TipoSoggetto.FUNZIONARIO]?.utente == null) {
            messaggi << "Valorizzare il Funzionario"
        }

        if (protocollo.controlloFirmatario && soggetti[TipoSoggetto.FIRMATARIO]?.utente == null) {
            messaggi << "Valorizzare il Firmatario."
        }

        if (soggetti[TipoSoggetto.UO_PROTOCOLLANTE]?.unita == null) {
            messaggi << "Valorizzare l'Unità Protocollante."
        }

        if (protocollo.tipoProtocollo.categoriaProtocollo.isSmistamentoAttivoInCreazione()) {
            if (listaSmistamentiDto?.size() <= 0 && protocollo.classificazione?.codice == null) {
                messaggi << "Il documento deve avere una Classificazione o uno Smistamento"
            }
        }
        if (protocollo.tipoProtocollo.categoriaProtocollo.isLettera()) {
            if (protocollo.dataRedazione == null) {
                messaggi << "Valorizzare la data di Redazione"
            }
        }

        if (protocollo.numeroDocumentoEsterno != null && protocollo.dataDocumentoEsterno != null) {
            String errore = null
            Protocollo d = protocollo.domainObject
            if (d != null) {
                // questo controllo è bypassato per la pec perchè il valore portebbe arrivarmi da una precedente procedura
                boolean valoriDiversi = d.dataDocumentoEsterno != protocollo.dataDocumentoEsterno || d.numeroDocumentoEsterno != protocollo.numeroDocumentoEsterno
                if (valoriDiversi || protocollo.tipoProtocollo.categoriaProtocollo.isPec()) {
                    errore = validaEstremiDocumentoEsterno()
                    if (errore) {
                        messaggi << errore
                    }
                }
            } else {
                errore = validaEstremiDocumentoEsterno()
                if (errore) {
                    messaggi << errore
                }
            }
        }

        if (messaggi.size() > 0) {
            messaggi.add(0, "Impossibile continuare:")
        }

        return messaggi
    }

    void flagFunzionario() {
        if (!funzionarioValorizzabile) {
            ((BandboxSoggettiUtentiSo4) protocolloStandard.getFellow("funzionarioBandbox")).resetSelectItem()
            soggetti.remove(TipoSoggetto.FUNZIONARIO)
            ((BandboxSoggettiUtentiSo4) protocolloStandard.getFellow("funzionarioBandbox")).resetSelectItem()
            BindUtils.postNotifyChange(null, null, this, "soggetti")
        } else {
            if (soggetti[TipoSoggetto.FUNZIONARIO]?.utente == null) {
                defaultSoggetto(TipoSoggetto.FUNZIONARIO)
            }
        }
    }

    void flagFirmatario() {
        if (!firmatarioValorizzabile) {
            ((BandboxSoggettiUtentiSo4) protocolloStandard.getFellow("firmatarioBandbox")).resetSelectItem()
            soggetti.remove(TipoSoggetto.FIRMATARIO)
            ((BandboxSoggettiUtentiSo4) protocolloStandard.getFellow("firmatarioBandbox")).resetSelectItem()
            BindUtils.postNotifyChange(null, null, this, "soggetti")
        } else {
            if (soggetti[TipoSoggetto.FIRMATARIO]?.utente == null) {
                defaultSoggetto(TipoSoggetto.FIRMATARIO)
            }
        }
    }

    private void defaultSoggetto(String tipoSoggetto) {
        Map sogg = [:]
        As4SoggettoCorrente s = springSecurityService.principal.soggetto
        sogg[TipoSoggetto.REDATTORE] = [modificato: true, descrizione: s.utenteAd4.nominativoSoggetto, utente: s.utenteAd4.toDTO(), unita: soggetti?.UO_PROTOCOLLANTE?.unita]
        tipologiaSoggettoService.aggiornaSoggetti(protocollo.tipoProtocollo.tipologiaSoggetto.id, protocollo.domainObject ?: protocollo, sogg, TipoSoggetto.REDATTORE)
        soggetti[tipoSoggetto] = sogg[tipoSoggetto]
        BindUtils.postNotifyChange(null, null, this, "soggetti")
    }

    void aggiornaDocumentoIterabile(Protocollo p) {
        funzionarioValorizzabile = soggetti.get(TipoSoggetto.FUNZIONARIO)?.utente != null
        if (!funzionarioValorizzabile) {
            soggetti.remove(TipoSoggetto.FUNZIONARIO)
            p.setSoggetto(TipoSoggetto.FUNZIONARIO, null, null)
        }

        firmatarioValorizzabile = soggetti.get(TipoSoggetto.FIRMATARIO)?.utente != null
        if (!firmatarioValorizzabile) {
            soggetti.remove(TipoSoggetto.FIRMATARIO)
            p.setSoggetto(TipoSoggetto.FIRMATARIO, null, null)
        }

        for (def s : soggetti) {
            if (s.value == null || s.value?.modificato) {
                p.setSoggetto(s.key, s.value?.utente?.domainObject, s.value?.unita?.domainObject)
            }
        }

        if (ImpostazioniProtocollo.EDITOR_DEFAULT_NOCHECK.abilitato && p.getFilePrincipale()?.id > 0) {
            documentoService.uploadEUnlockTesto(p, p.getFilePrincipale())
        }

        // salvo il protocollo
        protocolloService.salva(p, protocollo)

        if (rispostaAccessoCivico && protocolloAccessoCivico?.id != null) {
            protocolloAccessoCivico.protocolloRisposta = p.toDTO()
            protocolloAccessoCivico = accessoCivicoService.salvaRispostaAccesso(protocolloAccessoCivico)
        }

        if (domandaAccessoCivico && protocolloAccessoCivico != null) {
            protocolloAccessoCivico.protocolloDomanda = p.toDTO()
            protocolloAccessoCivico = accessoCivicoService.salvaDomandaAccesso(protocolloAccessoCivico)
        }

        // salvo i dto temporanei in caso abbia salvato il protocollo per la prima volta
        if (protocollo.id != p.id) {

            BindUtils.postGlobalCommand(null, null, 'onRefreshStoricoProtocollo', [idDocumento: p.id])
            titolarioService.salva(p, listaTitolari)
            smistamentoService.salva(p, listaSmistamentiDto)
            if (modificaRapporti) {
                corrispondenteService.salva(p, listaCorrispondentiDto)
                refreshCorrispondenti()
            }
            if (listaCollegamenti.size() > 0) {
                ProtocolloDTO protPrec = listaCollegamenti?.getAt(0).collegato
                Protocollo prot = Protocollo.findByIdDocumentoEsterno(protPrec.idDocumentoEsterno)
                if (prot) {
                    protocolloService.salvaProtocolloPrecedente(p, prot)
                }
            }
        }
    }

    @Command
    void cambiaTipoEsitoAccessoCivico() {
        if (protocolloAccessoCivico.tipoEsitoAccesso.tipo != TipoEsitoAccesso.NEGATIVO) {
            esitoPositivo = true
            protocolloAccessoCivico.ufficioCompetenteRiesame = null
            protocolloAccessoCivico.motivoRifiuto = ""
        } else {
            esitoPositivo = false
        }
        BindUtils.postNotifyChange(null, null, this, "protocolloAccessoCivico")
        BindUtils.postNotifyChange(null, null, this, "protocolloAccessoCivico.motivoRifiuto")
        BindUtils.postNotifyChange(null, null, this, "protocolloAccessoCivico.ufficioCompetenteRiesame")
        BindUtils.postNotifyChange(null, null, this, "esitoPositivo")
    }

    @Command
    void cambiaMovimento(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        if (protocollo.id > 0 && (protocollo.movimento != Protocollo.MOVIMENTO_INTERNO)) {
            if (protocollo.idDocumentoEsterno > 0) {
                //Al cambio movimento devo aggiornare il campo conoscenza in base al campo tramiteCC se movimento ARRIVO
                if (protocollo.movimento == Protocollo.MOVIMENTO_ARRIVO) {
                    listaCorrispondentiDto?.each { it.conoscenza = tramiteCC }
                }
                Protocollo p = protocollo.domainObject
                p.movimento = protocollo.movimento
                corrispondenteService.salva(p, listaCorrispondentiDto)
                protocollo.version = protocollo.domainObject.version
                protocolloService.salva(p, false)
                refreshCorrispondenti()
                aggiornaPrivilegi(protocollo)
            }
        }
        //Aggiorno sempre la view corrispondenti per far comparire il flag CC al cambio movimento (es: da Arrivo a Interno)
        //verificare se su Interno CC non ha senso questo va ripristinato nell'if sopra.
        BindUtils.postNotifyChange(null, null, this, "listaCorrispondentiDto")
        self.invalidate()
    }

    @Command
    void onAggiornaMaschera() {
        aggiornaMaschera(protocollo.domainObject)
    }

    void aggiornaMaschera(Protocollo d) {

        if (!d) {
            return
        }
        // la prima cosa da controllare è lo stato del documento
        if (d.statoFirma?.firmaInterrotta) {
            competenze = [lettura: true, modifica: false, cancellazione: true]
        } else {
            // controllo le competenze funzionali e non (se ho le competenze in modifica ignoro le altre, legate al flusso)
            competenze = gestoreCompetenze.getCompetenze(d)
            campiProtetti = d.mappaCampiProtetti

            competenze.lettura = competenze.lettura ?: forzaCompetenzeLettura

            log.debug("Competenze: $competenze")

            if (d.controlloRiservatoDopoProtocollazione && d.isProtocollato() && protocolloService.isRiservato(d) && !competenze.lettura) {

                Messagebox.show("Cliccando OK la pagina verrà aperta in sola lettura.\nL'utente ${springSecurityService.principal.username} non avrà più diritti sul documento con id ${d.id} dopo la chiusura della stessa", "Attenzione", Messagebox.OK, Messagebox.ERROR) { Event e1 ->
                    if (Messagebox.ON_OK.equals(e1.getName())) {
                        Window w = apriPopup(d.id, true)
                        w.onClose { event ->
                            Events.postEvent(Events.ON_CLOSE, self, null)
                        }
                        d.controlloRiservatoDopoProtocollazione = false
                        return
                    }
                }
            } else if (!competenze.lettura) {
                this.protocollo = new ProtocolloDTO()
                Messagebox.show("L'utente ${springSecurityService.principal.username} non ha i diritti di lettura sul documento con id ${d.id}", "Attenzione", Messagebox.OK, Messagebox.ERROR) { Event e1 ->
                    if (Messagebox.ON_OK.equals(e1.getName())) {
                        Events.postEvent(Events.ON_CLOSE, self, null)
                    }
                }
            }
        }

        if (d.numero > 0 && d.fascicolo != null) {
            ubicazioneVisibile = ImpostazioniProtocollo.ITER_FASCICOLI.abilitato
            if (ubicazioneVisibile) {
                if (ImpostazioniProtocollo.CONCAT_RADICE_UO_PROT.abilitato) {
                    ubicazione = fascicoloService.getUbicazione(d.fascicolo.toDTO(), true)
                } else {
                    ubicazione = fascicoloService.getUbicazione(d.fascicolo.toDTO(), false)
                }
            }
        }

        // calcolo la posizione del flusso (può essere nullo per i documenti trascodificati)
        posizioneFlusso = d.iter?.stepCorrente?.cfgStep?.nome

        d = Protocollo.get(d.id)
        // prendo il DTO con tutti i campi necessari
        this.protocollo = d?.toDTO([
                'tipoProtocollo.tipologiaSoggetto',
                'testo',
                'tipoRegistro',
                'corrispondenti.messaggi',
                'corrispondenti.modalitaInvioRicezione',
                'titolari.fascicolo',
                'titolari.classificazione',
                'smistamenti',
                'smistamenti.utenteAssegnatario',
                'classificazione',
                'schemaProtocollo',
                'tipoProtocollo',
                'schemaProtocollo.tipoRegistro',
                'schemaProtocollo.ufficioEsibente',
                'fascicolo',
                'fileDocumenti',
                'modalitaInvioRicezione',
                'utenteAnnullamento',
                'datiScarto',
                'datiEmergenza',
                'datiScarto.stato',
                'datiInteroperabilita',
                'annoEmergenza',
                'numeroEmergenza',
                'registroEmergenza'
        ])

        // se il protocollo è già riservato non c'è bisogno di controllare la riservatezza dal fascicolo
        riservatoDaFascicolo = false
        if (protocollo.fascicolo?.riservato && !protocollo.riservato) {
            riservatoDaFascicolo = true
        } else {
            for (DocumentoTitolarioDTO t : protocollo.titolari) {
                if (t.fascicolo?.riservato) {
                    riservatoDaFascicolo = true
                    break
                }
            }
        }

        // verifico che l'utente possa gestire il riservato:
        riservatoModificabile = (!(d.riservato && riservatoDaFascicolo) || gestoreCompetenze.utenteCorrenteVedeRiservato(d))

        if (protocollo.testoPrincipale == null) {
            GestioneTestiModello modelloTesto = TipoProtocollo.modelloTestoPredefinito(protocollo.tipoProtocollo.id, FileDocumento.CODICE_FILE_PRINCIPALE).get()
            if (modelloTesto != null) {
                protocollo.addToFileDocumenti(new FileDocumentoDTO(codice: FileDocumento.CODICE_FILE_PRINCIPALE
                        , nome: protocollo.tipoProtocollo.categoria + "." + modelloTesto.tipo
                        , modelloTesto: modelloTesto.toDTO()
                        , contentType: TipoFile.getInstanceByEstensione(modelloTesto.tipo).contentType
                        , valido: true
                        , modificabile: true
                        , firmato: false))
            }
        }

        // aggiorno i privilegi
        aggiornaPrivilegi(protocollo)
        aggiornaPulsanti(d)

        // verifico se ci sono note di trasmissione:
        aggiornaNoteTrasmissionePrecedenti(d)

        // ricarico lo storico del flusso
        caricaStoricoFlusso(d)

        // carico la lista di allegati:
        refreshListaAllegati()

        refreshDatiScarto()

        // carica lista dei documenti collegate
        refreshListaDocumentiCollegati()
        refreshAnnullamenti(d)
        listaCorrispondentiDto = Corrispondente.findAllByProtocollo(d)?.toDTO(["messaggi"])
        listaCorrispondentiDto?.sort {
            it.id
        }?.each { it.protocollo = protocollo }
        listaTitolari = protocollo.titolari as List

        refreshSmistamentiECompetenze(protocollo)

        //verifica se l'utente ha competenze di lettura su fascicoli riserverti
        if (null != protocollo.fascicolo) {
            titolarioService.verificaCompetenzeLetturaECambiaOggettoFascicoloRiservato(protocollo.fascicolo)
        }
        //verifico le competenze sui fascicoli della lista titolari
        for (DocumentoTitolarioDTO documentoTitolarioDTO : listaTitolari) {
            if (null != documentoTitolarioDTO.fascicolo) {
                titolarioService.verificaCompetenzeLetturaECambiaOggettoFascicoloRiservato(documentoTitolarioDTO.fascicolo)
            }
        }

        // calcolo i vari soggetti del documento
        this.protocollo.tipoProtocollo = tipoProtocolloService.findByIdConSoggetti(this.protocollo.tipoProtocollo.id)?.toDTO()

        soggetti = tipologiaSoggettoService.calcolaSoggettiDto(d)

        // se non ho alcuni soggetti, tento di calcolarli.
        // faccio questo perché alcuni protocolli potrebbero essere senza REDATTORE (ad esempio quelli 'importati' da JProtocollo)
        // Questo codice fa un po' schifo. bisognerebbe fare un bel refactor del calcolo dei soggetti.
        // rdestasio: aggiunta condizione perchè altrimenti, in caso di cancellazione di un soggetto, viene riproposto quello di default
        if (soggetti[TipoSoggetto.REDATTORE] == null) {
            def sogg = null
            for (TipologiaSoggettoRegola regolaCalcoloSoggetto : d.tipoProtocollo.tipologiaSoggetto.regole) {
                if (soggetti[regolaCalcoloSoggetto.tipoSoggetto] == null) {
                    if (sogg == null) {
                        sogg = tipologiaSoggettoService.calcolaSoggetti(d, d.tipoProtocollo.tipologiaSoggetto)
                    }

                    if (sogg[regolaCalcoloSoggetto.tipoSoggetto] != null) {
                        soggetti[regolaCalcoloSoggetto.tipoSoggetto] = sogg[regolaCalcoloSoggetto.tipoSoggetto]
                    }
                }
            }
        }

        modificabilitaFirmatarioFunzionario()

        if (posizioneFlusso == Protocollo.STEP_INVIATO) {
            ufficioEsibenteModificabile = true
        }

        if (ImpostazioniProtocollo.CONCAT_RADICE_UO_PROT.abilitato && d.data != null) {
            So4UnitaPubbDTO unita = soggetti[TipoSoggetto.UO_PROTOCOLLANTE]?.unita
            if (unita != null) {
                unitaVertice = strutturaOrganizzativaService.getUnitaVerticeAllaData(unita.domainObject, d.data.clone(), -1)
                // se è la stessa non la faccio vedere
                if (unitaVertice?.codice == unita.codice) {
                    unitaVertice = null
                }
            }
        }

        if (protocollo.numero > 0 && protocollo.movimento != Protocollo.MOVIMENTO_INTERNO) {
            pec = protocolloService.isSpedito(d)
        }

        aggiornaDatiAccessoCivico()
        schemaProtocolloModificabile = modificabilitaSchemaProtocollo()
        BindUtils.postNotifyChange(null, null, this, "schemaProtocolloModificabile")

        refreshMenu()

        // #39571 : Pec Gestione dell'unita protocollante proposta dal paramentro deve essere resettata se l'utente non ha compentenza su di essa
        if (!protocollo.isProtocollato() && protocollo.categoriaProtocollo.isPec() && soggetti[TipoSoggetto.UO_PROTOCOLLANTE] != null) {
            if (!protocolloService.utenteHaUnita(protocollo, soggetti[TipoSoggetto.UO_PROTOCOLLANTE].unita.domainObject)) {
                soggetti[TipoSoggetto.UO_PROTOCOLLANTE] = null
            }
        }

        // se esiste il protocollo e non ho settato la Uo protocollante è modificabile
        if (protocollo.id > 0 && soggetti[TipoSoggetto.UO_PROTOCOLLANTE] == null) {

            // gestione della creazione dal WS
            forzaModificabilitaUnitaProtocollante = true

            soggetti = tipologiaSoggettoService.calcolaSoggetti(d, d.tipoProtocollo.tipologiaSoggetto)
            onAggiornaSoggetti(soggetti?.UO_PROTOCOLLANTE?.unita)

            funzionarioValorizzabile = protocollo.tipoProtocollo.funzionarioObbligatorio
            firmatarioValorizzabile = protocollo.tipoProtocollo.firmatarioObbligatorio
            if (!funzionarioValorizzabile) {
                soggetti.remove(TipoSoggetto.FUNZIONARIO)
            }
            if (!firmatarioValorizzabile) {
                soggetti.remove(TipoSoggetto.FIRMATARIO)
            }
        } else {
            forzaModificabilitaUnitaProtocollante = false
        }

        hasListaModelliTesto = getListaModelliTesto()?.size() > 0

        hasPrincipaleFirmato = protocollo.testoPrincipale?.firmato

        modificaUnitaProtocollante = isUnitaProtocollanteModificabile()

        registroVisibile()

        colspanTesto()

        BindUtils.postNotifyChange(null, null, this, "listaAllegati")
        BindUtils.postNotifyChange(null, null, this, "listaTitolari")
        BindUtils.postNotifyChange(null, null, this, "protocollo")
        BindUtils.postNotifyChange(null, null, this, "protocollo.testoPrincipale")
        BindUtils.postNotifyChange(null, null, this, "competenze")
        BindUtils.postNotifyChange(null, null, this, "posizioneFlusso")
        BindUtils.postNotifyChange(null, null, this, "soggetti")
        BindUtils.postNotifyChange(null, null, this, "isNotificaPresente")
        BindUtils.postNotifyChange(null, null, this, "listaCorrispondentiDto")
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiDto")
        BindUtils.postNotifyChange(null, null, this, "richiestaAnnullamento")
        BindUtils.postNotifyChange(null, null, this, "pec")
        BindUtils.postNotifyChange(null, null, this, "campiProtetti")
        BindUtils.postNotifyChange(null, null, this, "ubicazioneVisibile")
        BindUtils.postNotifyChange(null, null, this, "ubicazione")
        BindUtils.postNotifyChange(null, null, this, "riservatoDaFascicolo")
        BindUtils.postNotifyChange(null, null, this, "colspanTesto")
        BindUtils.postNotifyChange(null, null, this, "zipFilePrincipale")
        BindUtils.postNotifyChange(null, null, this, "modificabileEstremiDocumentoEsterno")
        BindUtils.postNotifyChange(null, null, this, "modificabileDataComunicazione")
        BindUtils.postNotifyChange(null, null, this, "modificaUnitaProtocollante")
    }

    private void modificabilitaFirmatarioFunzionario() {

        firmatarioModificabile = true
        funzionarioModificabile = true

        if (!posizioneFlusso) {
            posizioneFlusso = Protocollo.STEP_REDAZIONE
        }

        if (soggetti[TipoSoggetto.UO_PROTOCOLLANTE] == null) {
            firmatarioModificabile = false
            funzionarioModificabile = false
        }

        // QUESTI IF SONO TERRIBILI: SI BASANO SUL NOME DELLO STEP!
        if ((posizioneFlusso != Protocollo.STEP_REDAZIONE) && (posizioneFlusso != Protocollo.STEP_REVISORE)) {
            funzionarioModificabile = false
            funzionarioValorizzabile = false
        }

        if (posizioneFlusso == Protocollo.STEP_PROTOCOLLO || posizioneFlusso == Protocollo.STEP_DIRIGENTE ||
                posizioneFlusso == Protocollo.STEP_INVIATO || posizioneFlusso == Protocollo.STEP_DA_INVIARE || posizioneFlusso ==
                Protocollo.STEP_INTERMEDIO) {
            firmatarioModificabile = false
            funzionarioModificabile = false
        }

        if (funzionarioValorizzabile) {
            funzionarioValorizzabile = soggetti.get(TipoSoggetto.FUNZIONARIO)?.utente != null
            if (!funzionarioValorizzabile && protocollo.tipoProtocollo.funzionarioObbligatorio) {
                funzionarioValorizzabile = true
            }
        }

        if (firmatarioValorizzabile) {
            firmatarioValorizzabile = soggetti.get(TipoSoggetto.FIRMATARIO)?.utente != null
            if (!firmatarioValorizzabile && protocollo.tipoProtocollo.firmatarioObbligatorio) {
                firmatarioValorizzabile = true
            }
        }

        BindUtils.postNotifyChange(null, null, this, "funzionarioModificabile")
        BindUtils.postNotifyChange(null, null, this, "firmatarioModificabile")
    }

    @Command
    onApriInModifica() {
        pulsanteModificaVisibile = false
        apriInSolaLettura = false
        onAggiornaMaschera()
        BindUtils.postNotifyChange(null, null, this, "pulsanteModificaVisibile")
    }

    private void aggiornaSchemaProtocollo() {

        aggiornaDatiAccessoCivico()

        schemaProtocolloModificabile = modificabilitaSchemaProtocollo()
        BindUtils.postNotifyChange(null, null, this, "schemaProtocolloModificabile")

        String movimento = protocollo.schemaProtocollo?.movimento
        if (movimento && !protocollo.categoriaProtocollo.isSmistamentoAttivoInCreazione()) {
            protocollo.movimento = movimento
        }

        registroVisibile()
    }

    private boolean modificabilitaSchemaProtocollo() {

        boolean schemaProtocolloMod = competenze.modifica

        if (!schemaProtocolloMod) {
            BindUtils.postNotifyChange(null, null, this, "schemaProtocolloModificabile")
            return schemaProtocolloMod
        }

        if (protocollo.schemaProtocollo?.risposta) {
            schemaProtocolloMod = false
            return schemaProtocolloMod
        }

        if (protocollo.tipoProtocollo != null) {
            SchemaProtocollo schemaBloccato = schemaProtocolloService.schemaBloccatoPerTipoProtocollo(protocollo.tipoProtocollo.domainObject)
            if (schemaBloccato != null) {
                protocollo.schemaProtocollo = schemaBloccato.toDTO((["classificazione", "fascicolo", "ufficioEsibente", "tipoRegistro", "files"]))
                schemaProtocolloMod = false
                return schemaProtocolloMod
            }
        }

        //Se DOMAC o DOMACM sono in pubblicazione (anche se non esiste risposta) bloccare il tipo documento
        ProtocolloAccessoCivico protocolloAccessoCivico = ProtocolloAccessoCivico.findByProtocolloDomanda(protocollo.domainObject)
        if (protocolloAccessoCivico && protocolloAccessoCivico.attivaPubblicaDomanda) {
            schemaProtocolloMod = false
            return schemaProtocolloMod
        }

        if (protocollo.numero > 0) {
            schemaProtocolloMod = !protocollo.domainObject.schemaProtocollo?.isSequenza()

            if (schemaProtocolloMod) {
                if (DocumentoCollegato.countByCollegatoAndTipoCollegamento(protocollo.domainObject, TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)) > 0) {
                    schemaProtocolloMod = SchemaProtocollo.createCriteria().get {
                        eq("id", protocollo.schemaProtocollo?.id)
                        isNull("schemaProtocolloRisposta")
                    }
                }
            }
        }
        return schemaProtocolloMod
    }

    private void aggiornaDatiAccessoCivico() {
        if (!ImpostazioniProtocollo.ACCESSO_CIVICO_OGGETTO_MOD.abilitato) {
            oggettoAccessoCivicoModificabile = false
        }

        // questo caso è stato considerato per la creazione del documento di risposta tramite tasto RISPONDI:
        // in questo caso il documento di risposta ancora non è salvato sul DB, la domanda sì
        // Va esteso anche in caso si aggiunga come riferimento, senza schema di protocollo associato
        domanda = protocollo.documentiCollegati?.find() {
            it.tipoCollegamento.codice == TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO
        }?.collegato

        if (protocollo.schemaProtocollo?.isRisposta() || domanda) {
            // cercare se lo schema del protocollo è una risposta ad una domanda di accesso civico
            rispostaAccessoCivico = accessoCivicoService.isSchemaProtocolloRisposta(protocollo.schemaProtocollo?.id)

            if (rispostaAccessoCivico || domanda) {
                rispostaAccessoCivico = documentoCollegatoRepository.collegamentiPerTipologia(protocollo.domainObject, TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO))?.size() > 0
                if (!rispostaAccessoCivico) {
                    if (domanda) {
                        protocolloAccessoCivico = protocolloAccessoCivicoRepository.findByProtocolloDomanda(domanda.domainObject)?.toDTO(['tipoAccessoCivico', 'tipoRichiedenteAccesso', 'ufficioCompetente'])
                        BindUtils.postNotifyChange(null, null, this, 'protocolloAccessoCivico')
                        rispostaAccessoCivico = true
                    }
                }
                listaEsitiAccesso = accessoCivicoService.listTipoEsitoAccessoValidi()
                listaEsitiAccesso.add(0, new TipoEsitoAccessoDTO(id: -1, codice: "", descrizione: "", valido: true))
                BindUtils.postNotifyChange(null, null, this, "listaEsitiAccesso")
            }
        }

        // può essere risposta anche se ha come doc collegato un doc di tipo accesso civico
        Protocollo protPrec = protocolloRepository.getProtocolloPrecedente(protocollo.id, TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
        if (!protPrec) {
            protPrec = protocolloRepository.getProtocolloPrecedente(protocollo.id, TipoCollegamentoConstants.CODICE_TIPO_DATI_ACCESSO)
        }
        boolean rispostaAccessoCivicoPrecedente = protPrec?.schemaProtocollo?.domandaAccesso
        if (!rispostaAccessoCivico) {
            rispostaAccessoCivico = rispostaAccessoCivicoPrecedente
        }

        if (rispostaAccessoCivico) {

            protocolloAccessoCivico = accessoCivicoService.recuperaDatiAccesso(protocollo)

            if (protocolloAccessoCivico != null) {
                // data del provvedimento,
                // che sarà valorizzata con la data di protocollazione se non già riempita
                // e comunque modificabile anche dopo la protocollazione se il flag pubblicazione non è attivo
                if (protocolloAccessoCivico?.dataProvvedimento == null) {
                    protocolloAccessoCivico?.dataProvvedimento = protocollo.data
                }

                domanda = Protocollo.get(protocolloAccessoCivico.protocolloDomanda.id)?.toDTO(["tipoRegistro"])
                BindUtils.postNotifyChange(null, null, this, "protocolloAccessoCivico")
                BindUtils.postNotifyChange(null, null, this, "domanda")
                BindUtils.postNotifyChange(null, null, this, "rispostaAccessoCivico")
            } else {
                if (!rispostaAccessoCivicoPrecedente) {
                    rispostaAccessoCivico = false
                    BindUtils.postNotifyChange(null, null, this, "rispostaAccessoCivico")
                }
            }
        }

        if (protocollo.schemaProtocollo?.isDomandaAccesso()) {
            domandaAccessoCivico = !rispostaAccessoCivico
            protocolloAccessoCivico = accessoCivicoService.recuperaDatiAccessoDallaDomanda(protocollo)
            if (protocolloAccessoCivico == null) {
                protocolloAccessoCivico = new ProtocolloAccessoCivicoDTO()
            }

            if (protocollo.numero == null && !protocolloAccessoCivico.oggetto) {
                if (ImpostazioniProtocollo.ACCESSO_CIVICO_OGGETTO_DEFAULT.valore == ProtocolloAccessoCivicoDTO.OGGETTO_DEFAULT_OGGETTO) {
                    protocolloAccessoCivico.oggetto = protocollo.oggetto
                } else {
                    protocolloAccessoCivico.oggetto = ''
                }
            }

            // data di presentazione, valorizzata con la data di comunicazione (data di arrivo) nel caso in cui non sia
            // già riempita o con la data di protocollazione se è vuota la data di comuncazione;
            // modificabile anche dopo la protocollazione se il flag presentazione non è attivo
            if (protocolloAccessoCivico.dataPresentazione == null) {
                if (protocollo.dataComunicazione != null) {
                    protocolloAccessoCivico.dataPresentazione = protocollo.dataComunicazione
                } else {
                    protocolloAccessoCivico.dataPresentazione = protocollo.data
                }
            }

            if (protocolloAccessoCivico.protocolloRisposta?.id == null) {
                protocolloAccessoCivico.protocolloRisposta = risposta
            } else {
                risposta = protocolloAccessoCivico.protocolloRisposta
            }

            listaTipoRichiedenteAccesso = accessoCivicoService.listTipoRichiedenteAccessoValidi()
            listaTipoRichiedenteAccesso.add(0, new TipoRichiedenteAccessoDTO(id: -1, codice: "", descrizione: "", valido: true))
            listaTipoAccesso = accessoCivicoService.listTipoAccessoValidi()
            listaTipoAccesso.add(0, new TipoAccessoCivicoDTO(id: -1, codice: "", descrizione: "", valido: true))

            if (risposta) {
                schemaProtocolloModificabile = false
            }

            BindUtils.postNotifyChange(null, null, this, "risposta")
            BindUtils.postNotifyChange(null, null, this, "domandaAccessoCivico")
            BindUtils.postNotifyChange(null, null, this, "listaTipoRichiedenteAccesso")
            BindUtils.postNotifyChange(null, null, this, "listaTipoAccesso")
            BindUtils.postNotifyChange(null, null, this, "protocolloAccessoCivico")
        }

        if ((rispostaAccessoCivico || domandaAccessoCivico) && !protocollo.schemaProtocollo?.isDomandaAccesso() && !protocollo.schemaProtocollo?.isRisposta() && !rispostaAccessoCivicoPrecedente) {
            accessoCivicoService.eliminaAccessoCivico(protocollo?.domainObject)
            rispostaAccessoCivico = false
            domandaAccessoCivico = false

            BindUtils.postNotifyChange(null, null, this, "rispostaAccessoCivico")
            BindUtils.postNotifyChange(null, null, this, "domandaAccessoCivico")
        }
    }

    @Command
    void onAttivaPubblicazione() {
        BindUtils.postNotifyChange(null, null, this, "protocolloAccessoCivico")
    }

    @Command
    void abilitaDisabilitaTipoDocumento() {
        schemaProtocolloModificabile = !protocolloAccessoCivico?.attivaPubblicaDomanda
        BindUtils.postNotifyChange(null, null, this, "schemaProtocolloModificabile")
    }

    @Command
    void onRicercaUnita(@BindingParam("cercaUfficio") String search) {
        if (search == "") {
            BindUtils.postNotifyChange(null, null, this, "protocolloAccessoCivico")
            return
        }

        listaUnita = So4UnitaPubb.createCriteria().list {
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
            order("codice", "asc")
        }.toDTO()

        BindUtils.postNotifyChange(null, null, this, "listaUnita")
    }

    boolean isModificabilePrecedente() {
        boolean isModificabile = competenze.modifica
        if (isModificabile) {
            if (protocollo.schemaProtocollo?.isRisposta()) {
                return false
            }
        }
        return isModificabile
    }

    boolean isModificabileEstremiDocumentoEsterno() {
        if (!competenze.modifica) {
            return false
        }

        // questo controllo è bypassato per la pec perchè il valore portebbe arrivarmi da una precedente procedura
//        if (protocollo.tipoProtocollo?.categoriaProtocollo?.isPec() && protocollo.isProtocollato()) {
//            return false
//        }

        if (protocollo.isBloccato()) {
            return privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.MODIFICA_DOCUMENTO_ESTREMI_BLOCCO)
        } else {
            return true
        }
    }

    boolean isModificabileDataComunicazione() {
        if (!competenze.modifica) {
            return false
        }

        if (protocollo.isBloccato()) {
            return privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.MODIFICA_DOCUMENTO_DATAARRIVO_BLOCCO)
        } else {
            return true
        }
    }

    boolean isProtocolloPartenzaCollegatoMail() {
        if (protocollo.domainObject == null) {
            return false
        }

        return (documentoCollegatoRepository.collegamentoPadrePerTipologia(protocollo.domainObject,
                TipoCollegamento.findByCodice(MessaggiRicevutiService.TIPO_COLLEGAMENTO_MAIL)) != null &&
                protocollo.movimento == Protocollo.MOVIMENTO_PARTENZA)
    }

    private String validaEstremiDocumentoEsterno() {

        if (protocollo.movimento != Protocollo.MOVIMENTO_ARRIVO) {
            return null
        }

        boolean valoreCambiato = false
        if ((protocollo.dataDocumentoEsterno != Protocollo.get(protocollo.id)?.dataDocumentoEsterno)
                || (protocollo.numeroDocumentoEsterno != Protocollo.get(protocollo.id)?.numeroDocumentoEsterno)) {
            valoreCambiato = true
        }

        if (!valoreCambiato || forzaDocumentoEsterno || !modificabileEstremiDocumentoEsterno) {
            return null
        }

        /*
        - se il numero è valorizzato e la data è vuota, la coppia è valida
        - se il numero è vuoto e la data valorizzata, la coppia è valida se la data non è futura
        - se il numero e la data sono valorizzati,
                se il documento è stato protocollato, allora la data del documento esterno deve essere precedente od uguale a quella di protocollazione,
                altrimenti deve essere precedente od uguale ad oggi;
        */

        if (protocollo.dataDocumentoEsterno != null && protocollo.numeroDocumentoEsterno == null) {
            if (protocollo.dataDocumentoEsterno.after(new Date().clearTime())) {
                return "Fallito salvataggio perchè la data del documento esterno non può essere futura"
            }
        }

        if (protocollo.dataDocumentoEsterno != null && protocollo.numeroDocumentoEsterno != null) {
            if (protocollo.isProtocollato()) {
                if (protocollo.dataDocumentoEsterno.after(protocollo.data)) {
                    return "Fallito salvataggio perchè la data del documento esterno deve essere precedente od uguale a quella di protocollazione."
                }
            } else if (protocollo.dataDocumentoEsterno.after(new Date().clearTime())) {
                return "Fallito salvataggio perchè la data del documento esterno deve essere precedente od uguale ad oggi."
            }
        }

        List<ProtocolloEsterno> documentiEsterni = ProtocolloEsterno.createCriteria().list {
            eq("dataDocumento", protocollo.dataDocumentoEsterno)
            eq("numeroDocumento", protocollo.numeroDocumentoEsterno)
            if (protocollo.idDocumentoEsterno) {
                ne("idDocumentoEsterno", protocollo.idDocumentoEsterno)
            }
            isNotNull("numero")
            isNotNull("data")
        }?.toDTO("tipoRegistro")

        if (documentiEsterni.size() > 0) {
            Window estremiW = Executions.createComponents("/protocollo/documenti/popupDocumentiEsterni.zul", self, [documentiEsterni: documentiEsterni])
            estremiW.doModal()
            return "Fallito salvataggio perchè esiste già un protocollo con gli stessi estremi."
        }
        return null
    }

    @Command
    boolean validaEstremiDocumentoEsternoOnBlur() {

        String errore = validaEstremiDocumentoEsterno()
        if (!StringUtils.isEmpty(errore)) {
            Clients.showNotification(errore, Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return false
        }
        return true
    }

    private void refreshMenu() {
        if (menuFunzionalita) {
            menuFunzionalita.refreshMenu()
            menuFunzionalita.setProtocollo(protocollo)
            creaSmistamentiAbilitato = menuFunzionalita.isVoceMenuVisibile(MenuItemProtocollo.APRI_SMISTA_FLEX)
            stampaBarcode = menuFunzionalita.isVoceMenuVisibile(MenuItemProtocollo.STAMPA_BC)
            BindUtils.postNotifyChange(null, null, this, "creaSmistamentiAbilitato")
            BindUtils.postNotifyChange(null, null, this, "stampaBarcode")
        }
    }

    void inizializzaAssistenteVirtuale() {
        if (protocollo.categoriaProtocollo?.isCategoriaPerAssistenteVirtuale()) {
            urlAssistenteVirtuale = assistenteVirtualeService.getUrlAssistenteViruale(protocollo.categoriaProtocollo?.getPaginaCategoriaAssistenteVirtuale())
        }
    }

    String getProtocolloMessaggiConsegnati() {
        return protocolloService.getProtocolloMessaggiConsegnati(protocollo?.domainObject)
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone()
    }

    void refreshSmistamentiECompetenze(ProtocolloDTO protocollo, So4UnitaPubbDTO unitaProtocollante = null) {

        Protocollo documentoProtocollo = null
        if (protocollo.idDocumentoEsterno != null) {
            documentoProtocollo = Protocollo.get(protocollo.id)
        }

        if (documentoProtocollo != null) {
            listaSmistamentiDto = smistamentoService.getSmistamentiAttivi(documentoProtocollo).toDTO(["utenteTrasmissione", "unitaTrasmissione", "utentePresaInCarico", "utenteEsecuzione", "utenteAssegnante", "utenteAssegnatario", "utenteRifiuto", "unitaSmistamento"])
        }

        if (unitaProtocollante != null) {
            for (SmistamentoDTO s : listaSmistamentiDto) {
                s.unitaTrasmissione = unitaProtocollante
            }
            if (documentoProtocollo != null) {
                smistamentoService.salva(protocollo, listaSmistamentiDto)
            }
        }

        protocollo.smistamenti = listaSmistamentiDto

        visualizzaNote = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.VISUALIZZA_NOTE)
        if (documentoProtocollo != null) {
            isSequenza = documentoProtocollo.schemaProtocollo?.isSequenza()
        }

        haRicongiungiAFascicolo = fascicoloService.verificaRicongiungiAFascicolo(protocollo.domainObject)

        BindUtils.postNotifyChange(null, null, this, "haRicongiungiAFascicolo")
        BindUtils.postNotifyChange(null, null, this, "listaSmistamentiDto")
        BindUtils.postNotifyChange(null, null, this, "protocollo")
        BindUtils.postNotifyChange(null, null, this, "visualizzaNote")
        BindUtils.postNotifyChange(null, null, this, "isSequenza")

        if (protocollo.idDocumentoEsterno > 0) {
            competenze = gestoreCompetenze.getCompetenze(documentoProtocollo)
            competenze.lettura = competenze.lettura ?: forzaCompetenzeLettura
            if (apriInSolaLettura) {
                pulsanteModificaVisibile = competenze.modifica
                competenze.modifica = false
                competenze.cancellazione = false
            }
            aggiornaPulsanti(documentoProtocollo)
            aggiornaPrivilegi(protocollo)
            BindUtils.postNotifyChange(null, null, this, "competenze")
            BindUtils.postNotifyChange(null, null, this, "pulsanteModificaVisibile")
        }

        refreshMenu()
    }

    @Command
    void salva() {
        Collection<String> messaggiValidazione = validaMaschera()
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            ClientsUtils.showError(StringUtils.join(messaggiValidazione, "\n"))
            return
        }

        Protocollo documento = salvaProtocollo()

        // aggiorno l'interfaccia:
        aggiornaMaschera(documento)
        ClientsUtils.showInfo("Documento salvato.")
    }

    private Protocollo salvaProtocollo() {
        Protocollo documento = protocollo.domainObject
        transactionTemplate.execute {
            documento = getDocumentoIterabile(true)
            aggiornaDocumentoIterabile(documento)
            documento.save()
            if (documento.iter == null) {
                wkfIterService.istanziaIter(documento.tipoProtocollo?.getCfgIter(), documento)
            }
        }
        return documento
    }

    @Command
    void onSalvaTesto(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        Collection<String> messaggiValidazione = validaMaschera()
        CaricaFileEvent fileEvent = event.data
        if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
            ClientsUtils.showError(StringUtils.join(messaggiValidazione, "\n"))
            return
        }

        Protocollo documento = protocollo.domainObject
        transactionTemplate.execute {
            documento = getDocumentoIterabile(true)
            aggiornaDocumentoIterabile(documento)
            documento.save()
            protocolloService.caricaFilePrincipale(documento, fileEvent.inputStream, fileEvent.contentType, fileEvent.filename)
            if (documento.iter == null) {
                wkfIterService.istanziaIter(documento.tipoProtocollo?.getCfgIter(), documento)
                protocollo.id = documento.id
                aggiornaDocumentoIterabile(documento)
            }
        }
        // aggiorno l'interfaccia:
        aggiornaMaschera(documento)

        ClientsUtils.showInfo("Documento salvato.")
    }

    void onSalvaRiservato() {
        if (!salvaRiservato()) {
            protocollo.riservato = false
            BindUtils.postNotifyChange(null, null, this, "protocollo")
        }
    }

    //TODO: questo metodo sarà eliminato quando le competenze funzionali saranno implementate e sarà possibile controllare
    //TODO  se l'utente può vedere i documenti riservati dopo la protocollazione
    @Command
    private boolean salvaRiservato() {
        if (protocollo.idDocumentoEsterno == null) {
            Collection<String> messaggiValidazione = validaMaschera()
            if (messaggiValidazione != null && messaggiValidazione.size() > 0) {
                ClientsUtils.showError(StringUtils.join(messaggiValidazione, "\n"))
                return false
            }
            Protocollo documento = salvaProtocollo()
            // aggiorno l'interfaccia:
            aggiornaMaschera(documento)
            return true
        }
        return true
    }

    @Command
    void onMostraInfoBox(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        String info = event.target.value
        Clients.showNotification(info, Clients.NOTIFICATION_TYPE_INFO, event.target, "after_center", 10000, true)
    }

    @Command
    void onAggiornaUfficioEsibente(@BindingParam("ufficioEsibente") unita) {
        soggetti[TipoSoggetto.UO_ESIBENTE] = [modificato: true, descrizione: unita?.descrizione, utente: null, unita: unita]
        BindUtils.postNotifyChange(null, null, this, "soggetti")
    }

    @Command
    void menu(@ContextParam(ContextType.TRIGGER_EVENT) Event event) {
        MenuItem menuitem = (MenuItem) event.data
        switch (menuitem.name) {
            case MenuItemProtocollo.APRI_CARICO_FLEX:
            case MenuItemProtocollo.APRI_INOLTRA_FLEX:

                boolean inoltroInSequenza = false

                Protocollo p = protocollo.domainObject
                List<SchemaProtocolloSmistamento> smistamenti = smistamentiConSequenza(p)

                // il primo è gia stato inoltrato (STORICO) con la UO Protocollante ... verificare
                // il prossimo (ancora non esiste) devo farne l'inoltro (creazione) con la UO del precedente
                // (quindi devo cercare il primo che non sia storico con il numero di sequenza minore ed inoltrarlo)
                // tipoSmistamento prendere dallo sistamento associato allo schema
                // se è il primo della sequenza si prende l'UO Protocollante, altrimenti la unità di trasmissione del precedente
                // datiSmistamento.destinatari = unita dello schemaSmistamento
                Smistamento smistamentoPrecedente = null
                if (smistamenti) {
                    for (int i = 0; i < smistamenti.size(); i++) {
                        SchemaProtocolloSmistamento smistamentoSchema = smistamenti.get(i)
                        Smistamento smistamento = Smistamento.findByDocumentoAndUnitaSmistamento(p, smistamentoSchema.unitaSo4Smistamento)

                        if (smistamento == null) {
                            smistamento = smistamentoService.creaSmistamento(p, smistamentoSchema.tipoSmistamento, smistamentoPrecedente?.unitaSmistamento, springSecurityService.currentUser, smistamentoSchema.unitaSo4Smistamento)
                            smistamentoService.creaSmistamento(smistamento)
                        }

                        if (smistamento != null && smistamento.statoSmistamento != Smistamento.STORICO) {
                            inoltroInSequenza = true
                            List destinatari = []

                            SchemaProtocolloSmistamento successivo = null
                            if (i < smistamenti.size() - 1) {
                                successivo = smistamenti.get(i + 1)
                            }

                            if (successivo != null) {
                                destinatari << [unita: successivo.unitaSo4Smistamento]
                                if (MenuItemProtocollo.APRI_INOLTRA_FLEX == menuitem.name) {
                                    smistamentoService.inoltra(p, smistamentoSchema.tipoSmistamento, springSecurityService.currentUser, smistamento.unitaSmistamento, null, destinatari)
                                } else {
                                    smistamentoService.prendiInCaricoEInoltra(p, smistamentoSchema.tipoSmistamento, springSecurityService.currentUser, smistamento.unitaSmistamento, null, destinatari)
                                }
                                break
                            }
                        }
                        smistamentoPrecedente = smistamento
                    }
                }

                if (inoltroInSequenza) {
                    Events.postEvent(Events.ON_CLOSE, self, null)
                } else {
                    smistamentoComponent.onEvent(new Event(SmistamentiComponent.ON_SELEZIONA_VOCE, smistamentoComponent, menuitem.name))
                }

                break
            case MenuItemProtocollo.APRI_ESEGUI_FLEX:
            case MenuItemProtocollo.APRI_CARICO_ESEGUI_FLEX:
            case MenuItemProtocollo.APRI_ASSEGNA:
            case MenuItemProtocollo.APRI_CARICO_ASSEGNA:
            case MenuItemProtocollo.APRI_SMISTA_FLEX:
            case MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX:
                smistamentoComponent.onEvent(new Event(SmistamentiComponent.ON_SELEZIONA_VOCE, smistamentoComponent, menuitem.name))
                break
            case MenuItemProtocollo.GESTIONE_ANAGRAFICA:
                String url = ImpostazioniProtocollo.URL_ANAGRAFICA.valore
                Clients.evalJavaScript(" window.open('${url}'); ")
                break
            default:
                ClientsUtils.showError("Operazione ${menuitem.name} non gestita.")
                break
        }
    }

    private List<SchemaProtocolloSmistamento> smistamentiConSequenza(Protocollo p) {
        SchemaProtocollo schemaProtocollo = p.schemaProtocollo
        if (schemaProtocollo == null) {
            return []
        }
        List<SchemaProtocolloSmistamento> smistamenti = SchemaProtocolloSmistamento.createCriteria().list {
            eq("schemaProtocollo.id", schemaProtocollo.id)
            eq("tipoSmistamento", Smistamento.COMPETENZA)
            isNotNull("sequenza")
            order("sequenza")
        }
        return smistamenti
    }

    @Command
    void onOpenInformazioniUtente() {
        Executions.createComponents("/commons/informazioniUtente.zul", null, null).doModal()
    }

    @Command
    public void onSelectedTabDatiInteroperabilita(@BindingParam("tab") Tab tab, @BindingParam("tabbox") Tabbox tabbox) {
        tabbox.setSelectedTab(tab);
    }

    String getUtenteCollegato() {
        return springSecurityService.principal.cognomeNome
    }

    @Command
    void onScegliUfficioEsibente() {

        String ottica = springSecurityService.principal.ottica()?.codice
        if (ottica == null) {
            ottica = Impostazioni.OTTICA_SO4.valore
        }

        List<So4UnitaPubb> unitaUtente = strutturaOrganizzativaService.getUnitaUtente(springSecurityService.principal.id, ottica)
        List<Long> radiciUnitaUtente = new ArrayList<Long>()
        for (So4UnitaPubb unita : unitaUtente) {
            if (unita.progrPadre != null) {
                List<So4UnitaPubb> unitaPadri = strutturaOrganizzativaService.getUnitaPadri(unita.progrPadre, ottica)
                for (So4UnitaPubb unitaPadre : unitaPadri) {
                    if (unitaPadre.progrPadre == null) {
                        radiciUnitaUtente.add(unitaPadre.progr)
                    }
                }
            } else {
                radiciUnitaUtente.add(unita.progr)
            }
        }

        List<Long> radici = new ArrayList<Long>()
        for (Long radice : radiciUnitaUtente) {
            if (radice != null && !radici.contains(radice)) {
                radici.add(radice)
            }
        }

        Window w = Executions.createComponents("/commons/popupSceltaUnita.zul", self, [radici: radici])
        w.onClose { Event event ->
            try {
                if (event.data != null) {
                    soggetti[TipoSoggetto.UO_ESIBENTE] = [modificato: true, descrizione: event.data.descrizione, utente: null, unita: event.data]
                    BindUtils.postNotifyChange(null, null, this, "soggetti")
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
    void onSelectFascicolo() {

        if (protocollo.fascicolo?.id == -1) {
            protocollo.fascicolo = null
        } else {
            protocollo.classificazione = protocollo.fascicolo.classificazione
        }

        // se il protocollo è già riservato non c'è bisogno di controllare la riservatezza dal fascicolo
        if (!protocollo.riservato) {
            // se cambia il valore aggiorno la maschera
            if (riservatoDaFascicolo != protocollo.fascicolo?.riservato) {
                if (protocollo.idDocumentoEsterno == null) {

                    if (!salvaRiservato()) {
                        protocollo.fascicolo = null
                    }
                    return
                }
                Protocollo protocolloDomain = protocollo.domainObject
                // verifico che l'utente possa gestire il riservato:
                riservatoModificabile = (!(protocolloDomain.riservato && riservatoDaFascicolo) || gestoreCompetenze.utenteCorrenteVedeRiservato(protocolloDomain))
                BindUtils.postNotifyChange(null, null, this, "riservatoDaFascicolo")
                BindUtils.postNotifyChange(null, null, this, "riservatoModificabile")
                BindUtils.postNotifyChange(null, null, this, "ubicazioneVisibile")
                BindUtils.postNotifyChange(null, null, this, "ubicazione")
            }
        }

        haRicongiungiAFascicolo = fascicoloService.verificaRicongiungiAFascicolo(protocollo.domainObject)
        BindUtils.postNotifyChange(null, null, this, "haRicongiungiAFascicolo")
        BindUtils.postNotifyChange(null, null, this, "protocollo.classificazione")
        BindUtils.postNotifyChange(null, null, this, "protocollo.fascicolo")
    }

    private void inizializzaUfficioEsibente() {
        if (protocollo.schemaProtocollo?.ufficioEsibente != null && soggetti?.UO_ESIBENTE?.unita == null) {
            soggetti[TipoSoggetto.UO_ESIBENTE] = [modificato: true, descrizione: soggetti?.UO_ESIBENTE?.unita?.descrizione, utente: null, unita: protocollo.schemaProtocollo.ufficioEsibente]
            BindUtils.postNotifyChange(null, null, this, "soggetti")
        }
    }

    boolean presenteEditaTesto() {

        if (protocollo?.categoriaProtocollo == null) {
            return false
        }

        if (!protocollo.categoriaProtocollo.modelloTestoObbligatorio) {
            return false
        }

        return getlistaModelliTestoAssociati()?.size() > 0
    }

    @Command
    void onApriPopupUnzipFilePrincipale() {
        PopupImportAllegatiEmailViewModel.apriPopup(null, protocollo, false, false, true).addEventListener(Events.ON_CLOSE) {
            aggiornaMaschera(protocollo.domainObject)
        }
    }

    boolean isZipFilePrincipale() {
        if (protocollo?.testoPrincipale == null) {
            return false
        }

        return (protocollo.testoPrincipale.nome?.indexOf(".zip") != -1)
    }

    @Command
    @NotifyChange('protocolloAccessoCivico')
    void onModificaOggetto(@ContextParam(ContextType.TRIGGER_EVENT) InputEvent ev) {
        if (!protocollo.id && domandaAccessoCivico && protocolloAccessoCivico && ImpostazioniProtocollo.ACCESSO_CIVICO_OGGETTO_DEFAULT.valore == ProtocolloAccessoCivicoDTO.OGGETTO_DEFAULT_OGGETTO) {
            protocolloAccessoCivico.oggetto = ev.value
        }
    }

    @Command
    @NotifyChange('protocolloAccessoCivico')
    void copiaOggetto() {
        protocolloAccessoCivico.oggetto = protocollo.oggetto
    }

    @Command
    @NotifyChange('protocolloAccessoCivico')
    void aggiornaOggettoAccessoCivicoDaTipo() {
        if (protocollo.numero == null || (protocollo.numero != null && protocolloAccessoCivico.oggetto == null) || ImpostazioniProtocollo.ACCESSO_CIVICO_OGGETTO_MOD.isAbilitato()) {
            if (ImpostazioniProtocollo.ACCESSO_CIVICO_OGGETTO_DEFAULT.valore == ProtocolloAccessoCivicoDTO.OGGETTO_DEFAULT_TIPO_ACCESSO) {
                protocolloAccessoCivico.oggetto = protocolloAccessoCivico.tipoAccessoCivico.descrizione
            }
        }
    }

    boolean isAssistenteVirtuale() {
        return !(urlAssistenteVirtuale?.equals("") || urlAssistenteVirtuale == null)
    }

    @Command
    void apriAssistenteVirtuale() {
        Clients.evalJavaScript(" window.open('${urlAssistenteVirtuale}'); ")
    }

/*
 * Questa funzione "registroVisibile" deve rimanere così perché:
 *
 * 1. Non posso salvare il registro senza anno e numero (perché poi fallirebbe la chiave univoca anno/numero/registro trovando più righe con solo tipo_registro/null/null)
 * 2. C'è un trigger su agp_protocolli che svuota il campo registro. Questo tecnicamente non dovrebbe servire. è solo una "difesa" in più.
 * 3. Su GDM registro/anno/numero sono chiave
 * 4. C'è il timore che modificando uno schema di protocollo quando un protocollo è già creato poi non "propaghi" la modifica del tipo registro dallo schema al tipo protocollo.
 */

    private void registroVisibile() {
        registroVisibile = protocollo?.tipoRegistro?.commento
        // se non ho già il tipo di registro impostato, tento di recuperarlo dallo schema
        if (registroVisibile == null) {
            registroVisibile = protocollo.schemaProtocollo?.tipoRegistro?.commento
        }

        // se anche lo schema non l'ha, tento dalla tipologia
        if (registroVisibile == null) {
            registroVisibile = protocollo.tipoProtocollo?.tipoRegistro?.commento
        }

        // se ancora non l'ho trovato, uso le impostazioni
        if (registroVisibile == null) {
            registroVisibile = TipoRegistro.findByCodice(ImpostazioniProtocollo.TIPO_REGISTRO.valore).commento
        }
        BindUtils.postNotifyChange(null, null, this, "registroVisibile")
    }

    private void colspanTesto() {
        colspanTesto = 1
        if (protocollo?.statoFirma?.isFirmaInterrotta() && !presenteEditaTesto()) {
            colspanTesto = colspanTesto + 2
        } else if (protocollo?.statoFirma?.isFirmaInterrotta() && presenteEditaTesto()) {
            colspanTesto = colspanTesto + 2
        } else if (presenteEditaTesto() && protocollo.testoPrincipale?.firmato) {
            colspanTesto = colspanTesto + 2
        } else if (protocollo.testoPrincipale?.firmato) {
            colspanTesto = colspanTesto + 2
        } else if (!presenteEditaTesto()) {
            colspanTesto = colspanTesto + 2
        } else if (presenteEditaTesto() && competenze.modifica == false) {
            colspanTesto = colspanTesto + 2
        } else if (presenteEditaTesto() && !protocollo.testoPrincipale?.firmato) {
            colspanTesto = colspanTesto
        } else {
            colspanTesto = colspanTesto + 2
        }
        BindUtils.postNotifyChange(null, null, this, "colspanTesto")
    }

    private void aggiornaPrivilegi(ProtocolloDTO protocollo) {
        if (protocollo.id > 0) {
            eliminaDaClassificheSecondarie = privilegioUtenteService.eliminaDaClassificheSecondarie
            inserimentoInClassificheSecondarie = privilegioUtenteService.inserimentoInClassificheSecondarie
            inserimentoInFascicoliAperti = privilegioUtenteService.isInserimentoInFascicoliAperti(protocollo)
            eliminaAllegati = privilegioUtenteService.isEliminaAllegati(protocollo)
            eliminaRapporti = privilegioUtenteService.isEliminaRapporti(protocollo)
            inserimentoAllegati = privilegioUtenteService.isInserimentoAllegati(protocollo)
            inserimentoRapporti = privilegioUtenteService.isInserimentoRapporti(protocollo)
            modificaClassifica = privilegioUtenteService.isModificaClassifica(protocollo)
            modificaDatiArchivio = privilegioUtenteService.isModificaDatiArchivio(protocollo)
            modificaFilePrincipale = privilegioUtenteService.isModificaFilePrincipale(protocollo)
            eliminaFilePrincipale = privilegioUtenteService.isEliminaFilePrincipale(protocollo)
            modificaRapporti = privilegioUtenteService.isModificaRapporti(protocollo)
            modificaOggetto = privilegioUtenteService.isModificaOggetto(protocollo)

            BindUtils.postNotifyChange(null, null, this, 'eliminaDaClassificheSecondarie')
            BindUtils.postNotifyChange(null, null, this, 'inserimentoInClassificheSecondarie')
            BindUtils.postNotifyChange(null, null, this, 'inserimentoInFascicoliAperti')
            BindUtils.postNotifyChange(null, null, this, 'eliminaAllegati')
            BindUtils.postNotifyChange(null, null, this, 'eliminaRapporti')
            BindUtils.postNotifyChange(null, null, this, 'inserimentoAllegati')
            BindUtils.postNotifyChange(null, null, this, 'inserimentoRapporti')
            BindUtils.postNotifyChange(null, null, this, 'modificaClassifica')
            BindUtils.postNotifyChange(null, null, this, 'eliminaFilePrincipale')
            BindUtils.postNotifyChange(null, null, this, 'modificaDatiArchivio')
            BindUtils.postNotifyChange(null, null, this, 'modificaFilePrincipale')
            BindUtils.postNotifyChange(null, null, this, 'modificaRapporti')
            BindUtils.postNotifyChange(null, null, this, 'modificaOggetto')
            BindUtils.postNotifyChange(null, null, this, 'colspanTesto')
        }
    }

/**
 * metodo di reset della catena documentale
 */
    private void resetCatenaDocumentale() {
        catenaDocumentale = null
    }

    public void refreshListaTitolari() {
        haTitolari = listaTitolari
        BindUtils.postNotifyChange(null, null, this, 'haTitolari')
        BindUtils.postNotifyChange(null, null, this, "listaTitolari")
    }

    @Command
    void onMostraAllegati(@BindingParam("allegato") allegato) {
        listaFilesAllegato = allegatoRepository.getFileDocumenti(allegato.id, FileDocumento.CODICE_FILE_ALLEGATO)
        BindUtils.postNotifyChange(null, null, this, "listaFilesAllegato")
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileAllegato") value) {
        fileDownloader.downloadFileAllegato(value.documento?.toDTO(), FileDocumento.get(value.id), false)
    }

    void aggiornaPulsanti(Documento documento) {
        if (documento.idDocumentoEsterno) {
            super.aggiornaPulsanti(Protocollo.get(documento.id))
        } else {
            super.aggiornaPulsanti(documento)
        }
    }

    boolean visGraffettaDownloadAllegato(AllegatoDTO allegatoDTO) {
        if (allegatoRepository.getFileDocumenti(allegatoDTO.id, FileDocumento.CODICE_FILE_ALLEGATO).size() == 0) {
            return false
        } else {
            return true
        }
    }

    @Command
    void ricongiungiAFascicolo() {
        fascicoloService.ricongiungiAFascicolo(protocollo.domainObject)
        aggiornaMaschera(protocollo.domainObject)
        onApriTabSmistamenti()
    }
}
