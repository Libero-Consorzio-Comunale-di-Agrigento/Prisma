package it.finmatica.protocollo.zk.components.smistamenti

import commons.PopupSceltaSmistamentiViewModel
import commons.menu.MenuItemProtocollo
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevutoDTO
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.smistamenti.SmistamentoService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang3.StringUtils
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Div
import org.zkoss.zul.Hlayout
import org.zkoss.zul.Image
import org.zkoss.zul.Label
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Listbox
import org.zkoss.zul.Listcell
import org.zkoss.zul.Listheader
import org.zkoss.zul.Listitem
import org.zkoss.zul.ListitemRenderer
import org.zkoss.zul.Toolbarbutton
import org.zkoss.zul.Vlayout
import org.zkoss.zul.Window

import java.text.SimpleDateFormat

@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation(['smistamenti:@ZKBIND(ACCESS=both, SAVE_EVENT=onChangeSmistamenti)'])
class SmistamentiComponent extends Div implements EventListener<Event> {

    @Wire("listbox")
    protected Listbox listbox
    Image imageAddSmistamento = new Image()

    List<SmistamentoDTO> smistamenti = []

    Map competenze
    Map soggetti
    boolean creaSmistamentiAbilitato
    boolean visualizzaNote
    boolean isSequenza
    boolean gridCorta

    ISmistabileDTO documento

    public static final String ON_CHANGE_SMISTAMENTI = 'onChangeSmistamenti'
    public final static String ON_SELEZIONA_VOCE = "onSelezionaVoce"

    @WireVariable
    private SmistamentoService smistamentoService
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    private StrutturaOrganizzativaService strutturaOrganizzativaService

    SmistamentiComponent() {
        Executions.createComponents("/components/smistamenti.zul", this, null)
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Div))
        Selectors.wireComponents(this, this, false)
        Selectors.wireEventListeners(this, this)
    }

    void setCompetenze(Map competenze) {
        this.competenze = competenze
        visibilitaImageAddSmistamento()
    }

    void setSoggetti(Map soggetti) {
        this.soggetti = soggetti
    }

    void setCreaSmistamentiAbilitato(boolean creaSmistamentiAbilitato) {
        this.creaSmistamentiAbilitato = creaSmistamentiAbilitato
        visibilitaImageAddSmistamento()
    }

    void setVisualizzaNote(boolean visualizzaNote) {
        this.visualizzaNote = visualizzaNote
    }

    void setIsSequenza(boolean isSequenza) {
        this.isSequenza = isSequenza
    }

    void setGridCorta(boolean gridCorta) {
        this.gridCorta = gridCorta
        creaHeader()
    }

    void setSmistamenti(List<SmistamentoDTO> smistamenti) {
        this.smistamenti = smistamenti
        if (smistamenti?.size() > 0) {
            listbox.setModel(new ListModelList<?>(smistamenti))
            listbox.setItemRenderer(new ListitemRenderer<SmistamentoDTO>() {
                @Override
                void render(Listitem listitem, SmistamentoDTO smistamentoDTO, int i) throws Exception {
                    if (gridCorta) {
                        /* COLONNA TRASMESSO */
                        Listcell listCellColonnaTrasmesso = new Listcell()
                        Vlayout vlayoutColonnaTrasmesso = creaColonnaVuota(listCellColonnaTrasmesso)
                        riempiColonnaTrasmesso(vlayoutColonnaTrasmesso, smistamentoDTO)

                        /* COLONNA UFFICIO/ASSEGNATARIO */
                        Listcell listCellColonnaUfficioAssegnatario = new Listcell()
                        Vlayout vlayoutColonnaUfficioAssegnatario = creaColonnaVuota(listCellColonnaUfficioAssegnatario)
                        riempiColonnaUfficioAssegnatario(vlayoutColonnaUfficioAssegnatario, smistamentoDTO)

                        /* COLONNA ESEGUITO */
                        Listcell listCellColonnaEseguito = new Listcell()
                        Vlayout vlayoutColonnaEseguito = creaColonnaVuota(listCellColonnaEseguito)
                        riempiColonnaEseguito(vlayoutColonnaEseguito, smistamentoDTO)

                        listitem.appendChild(listCellColonnaTrasmesso)
                        listitem.appendChild(listCellColonnaUfficioAssegnatario)
                        listitem.appendChild(listCellColonnaEseguito)
                    } else {
                        /* COLONNA TIPO */
                        Listcell listCellColonnaTipo = new Listcell()
                        riempiColonnaTipo(listCellColonnaTipo, smistamentoDTO)

                        /* COLONNA TRASMESSO */
                        Listcell listCellColonnaTrasmesso = new Listcell()
                        Vlayout vlayoutColonnaTrasmesso = creaColonnaVuota(listCellColonnaTrasmesso)
                        riempiColonnaTrasmesso(vlayoutColonnaTrasmesso, smistamentoDTO)

                        /* COLONNA UFFICIO/ASSEGNANTE */
                        Listcell listCellColonnaUfficioAssegnante = new Listcell()
                        Vlayout vlayoutColonnaUfficioAssegnante = creaColonnaVuota(listCellColonnaUfficioAssegnante)
                        riempiColonnaUfficioAssegnante(vlayoutColonnaUfficioAssegnante, smistamentoDTO)

                        /* COLONNA UTENTE PRESA IN CARICO */
                        Listcell listCellColonnaUtentePresaInCarico = new Listcell()
                        Vlayout vlayoutColonnaUtentePresaInCarico = creaColonnaVuota(listCellColonnaUtentePresaInCarico)
                        riempiColonnaUtentePresaInCarico(vlayoutColonnaUtentePresaInCarico, smistamentoDTO)

                        /* COLONNA UTENTE ASSEGNATARIO */
                        Listcell listCellColonnaUtenteAssegnatario = new Listcell()
                        Vlayout vlayoutColonnaUtenteAssegnatario = creaColonnaVuota(listCellColonnaUtenteAssegnatario)
                        riempiColonnaUtenteAssegnatario(vlayoutColonnaUtenteAssegnatario, smistamentoDTO)

                        /* COLONNA UTENTE ESECUZIONE */
                        Listcell listCellColonnaUtenteEsecuzione = new Listcell()
                        Vlayout vlayoutColonnaUtenteEsecuzione = creaColonnaVuota(listCellColonnaUtenteEsecuzione)
                        riempiColonnaUtenteEsecuzione(vlayoutColonnaUtenteEsecuzione, smistamentoDTO)

                        listitem.appendChild(listCellColonnaTipo)
                        listitem.appendChild(listCellColonnaTrasmesso)
                        listitem.appendChild(listCellColonnaUfficioAssegnante)
                        listitem.appendChild(listCellColonnaUtentePresaInCarico)
                        listitem.appendChild(listCellColonnaUtenteAssegnatario)
                        listitem.appendChild(listCellColonnaUtenteEsecuzione)
                    }

                    /* COLONNA PULSANTI */
                    Listcell listCellColonnaPulsanti = new Listcell()
                    riempiColonnaPulsanti(listCellColonnaPulsanti, smistamentoDTO)
                    listitem.appendChild(listCellColonnaPulsanti)
                }
            })
        } else {
            listbox.setModel(new ListModelList<?>(smistamenti))
        }
    }

    protected void creaHeader() {
        imageAddSmistamento.setId("AddSmistamento-" + gridCorta)
        if (listbox.listhead.getChildren()?.size() == 0) {
            if (gridCorta) {
                listbox.listhead.appendChild(new Listheader(label: "Trasmesso", width: "33%"))
                listbox.listhead.appendChild(new Listheader(label: "Ufficio/Assegnatario", width: "33%"))
                listbox.listhead.appendChild(new Listheader(label: "Eseguito", width: "32%"))
                Listheader headerAggiungi = new Listheader(width: "30px", style: "text-align:center;")

                imageAddSmistamento.src = "/images/afc/16x16/add.png"
                imageAddSmistamento.style = "cursor: pointer;text-align: center;"
                imageAddSmistamento.tooltiptext = "Aggiungi smistamento"
                imageAddSmistamento.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
                    @Override
                    void onEvent(Event event) throws Exception {
                        onAggiungiSmistamenti()
                    }
                })
                headerAggiungi.appendChild(imageAddSmistamento)
                listbox.listhead.appendChild(headerAggiungi)
            } else {
                listbox.listhead.appendChild(new Listheader(label: "Tipo", width: "10%"))
                listbox.listhead.appendChild(new Listheader(label: "Trasmesso", width: "18%"))
                listbox.listhead.appendChild(new Listheader(label: "Ufficio/Assegnante", width: "18%"))
                listbox.listhead.appendChild(new Listheader(label: "Preso in carico", width: "18%"))
                listbox.listhead.appendChild(new Listheader(label: "Assegnato", width: "18%"))
                listbox.listhead.appendChild(new Listheader(label: "Eseguito", width: "18%"))
                Listheader headerAggiungi = new Listheader(width: "30px", style: "text-align:center;")

                imageAddSmistamento.src = "/images/afc/16x16/add.png"
                imageAddSmistamento.style = "cursor: pointer;text-align: center;"
                imageAddSmistamento.tooltiptext = "Aggiungi smistamento"
                imageAddSmistamento.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
                    @Override
                    void onEvent(Event event) throws Exception {
                        onAggiungiSmistamenti()
                    }
                })
                headerAggiungi.appendChild(imageAddSmistamento)
                listbox.listhead.appendChild(headerAggiungi)
            }
        }
    }

    protected Vlayout creaColonnaVuota(Listcell listCellColonna) {
        Hlayout hlayout = new Hlayout()
        Vlayout vlayout = new Vlayout()
        hlayout.appendChild(vlayout)
        listCellColonna.appendChild(hlayout)
        return vlayout
    }

    protected void riempiColonnaTipo(Listcell cell, SmistamentoDTO smistamentoDTO) {
        cell.label = smistamentoDTO.tipoSmistamento
        cell.style = (smistamentoDTO.tipoSmistamento == Smistamento.CONOSCENZA) ? "opacity:0.7; font-style:italic;" : "font-weight:bold;"
    }

    protected void riempiColonnaTrasmesso(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* descrizione unità */
        Hlayout hlayoutDescrizioneUnita = new Hlayout()
        Label labelDescrizioneUnita = new Label()
        hlayoutDescrizioneUnita.appendChild(labelDescrizioneUnita)
        vlayout.appendChild(hlayoutDescrizioneUnita)
        String descrizioneUO = getDescrizioneUO(smistamentoDTO.unitaTrasmissione)
        labelDescrizioneUnita.value = descrizioneUO

        /* Nominativo soggetto */
        Hlayout hlayoutNominativoSoggetto = new Hlayout()
        Label labelNominativoSoggetto = new Label()
        hlayoutNominativoSoggetto.appendChild(labelNominativoSoggetto)
        vlayout.appendChild(hlayoutNominativoSoggetto)
        labelNominativoSoggetto.value = smistamentoDTO.utenteTrasmissione?.nominativoSoggetto
        if (StringUtils.isEmpty(labelNominativoSoggetto.value)) {
            labelNominativoSoggetto.value = smistamentoDTO.utenteTrasmissione?.nominativo
        }
        /* Data smistamento */
        Hlayout hlayoutDataSmistamento = new Hlayout()
        Label labelDataSmistamento = new Label()
        hlayoutDataSmistamento.appendChild(labelDataSmistamento)
        vlayout.appendChild(hlayoutDataSmistamento)
        if (smistamentoDTO.dataSmistamento == null) {
            labelDataSmistamento.value = ""
        } else {
            labelDataSmistamento.value = (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataSmistamento))
        }
    }

    protected void riempiColonnaUfficioAssegnatario(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Nominativo */
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        String descrizioneUO = getDescrizioneUO(smistamentoDTO.unitaSmistamento)
        labelNominativo.value = ((smistamentoDTO.utenteAssegnatario == null) ? descrizioneUO : smistamentoDTO.utenteAssegnatario.nominativoSoggetto)
        labelNominativo.style = (smistamentoDTO.tipoSmistamento == Smistamento.CONOSCENZA) ? "opacity:0.7; font-style:italic;" : ""

        /* Descrizione */
        Hlayout hlayoutDescrizione = new Hlayout()
        Label labelDescrizione = new Label()
        hlayoutDescrizione.appendChild(labelDescrizione)
        vlayout.appendChild(hlayoutDescrizione)
        labelDescrizione.value = ((smistamentoDTO.utenteAssegnatario == null) ? "" : descrizioneUO)
        labelDescrizione.style = (smistamentoDTO.tipoSmistamento == Smistamento.CONOSCENZA) ? "opacity:0.7; font-style:italic;" : ""

        /* Data presa in carico */
        Hlayout hlayoutDataPresaCarico = new Hlayout()
        Label labelPresaCarico = new Label()
        hlayoutDataPresaCarico.appendChild(labelPresaCarico)
        vlayout.appendChild(hlayoutDataPresaCarico)
        labelPresaCarico.value = (smistamentoDTO.dataPresaInCarico == null) ? "" : (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataPresaInCarico))
        labelPresaCarico.style = (smistamentoDTO.tipoSmistamento == Smistamento.CONOSCENZA) ? "opacity:0.7; font-style:italic;" : ""
    }

    protected void riempiColonnaUfficioAssegnante(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Descrizione */
        Hlayout hlayoutDescrizione = new Hlayout()
        Label labelDescrizione = new Label()
        hlayoutDescrizione.appendChild(labelDescrizione)
        vlayout.appendChild(hlayoutDescrizione)
        String descrizioneUO = getDescrizioneUO(smistamentoDTO.unitaSmistamento)
        labelDescrizione.value = ((smistamentoDTO.utenteAssegnatario == null) ? "" : descrizioneUO)

        /* Nominativo */
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        labelNominativo.value = ((smistamentoDTO.utenteAssegnante == null) ? descrizioneUO : smistamentoDTO.utenteAssegnante.nominativoSoggetto)
    }

    protected void riempiColonnaUtenteAssegnante(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        labelNominativo.value = ((smistamentoDTO.utenteAssegnante == null) ? "" : smistamentoDTO.utenteAssegnante.nominativoSoggetto)
    }

    protected void riempiColonnaEseguito(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Nominativo esecutore */
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        labelNominativo.value = smistamentoDTO.utenteEsecuzione?.nominativoSoggetto
        if (StringUtils.isEmpty(labelNominativo.value)) {
            labelNominativo.value = smistamentoDTO.utenteEsecuzione?.nominativo
        }

        /* Data Esecuzione */
        Hlayout hlayoutDataEsecuzione = new Hlayout()
        Label labelDataEsecuzione = new Label()
        hlayoutDataEsecuzione.appendChild(labelDataEsecuzione)
        vlayout.appendChild(hlayoutDataEsecuzione)
        labelDataEsecuzione.value = (smistamentoDTO.dataEsecuzione == null) ? "" : (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataEsecuzione))
    }

    protected void riempiColonnaUtentePresaInCarico(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Nominativo */
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        labelNominativo.value = smistamentoDTO.utentePresaInCarico?.nominativoSoggetto
        if (StringUtils.isEmpty(labelNominativo.value)) {
            labelNominativo.value = smistamentoDTO.utentePresaInCarico?.nominativo
        }

        /* Data presa in carico */
        Hlayout hlayoutDataEsecuzione = new Hlayout()
        Label labelDataEsecuzione = new Label()
        hlayoutDataEsecuzione.appendChild(labelDataEsecuzione)
        vlayout.appendChild(hlayoutDataEsecuzione)
        labelDataEsecuzione.value = (smistamentoDTO.dataPresaInCarico == null) ? "" : (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataPresaInCarico))
    }

    protected void riempiColonnaUtenteAssegnatario(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Nominativo */
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        labelNominativo.value = smistamentoDTO.utenteAssegnatario?.nominativoSoggetto
        if (StringUtils.isEmpty(labelNominativo.value)) {
            labelNominativo.value = smistamentoDTO.utenteAssegnatario?.nominativo
        }

        /* Descrizione */
        Hlayout hlayoutDescrizione = new Hlayout()
        Label labelDescrizione = new Label()
        hlayoutDescrizione.appendChild(labelDescrizione)
        vlayout.appendChild(hlayoutDescrizione)
        String descrizioneUO = ""
        if (smistamentoDTO.utenteAssegnatario?.nominativoSoggetto) {
            descrizioneUO = getDescrizioneUO(smistamentoDTO.unitaSmistamento)
        }
        labelDescrizione.value = descrizioneUO

        /* Data assegnazione */
        Hlayout hlayoutDataEsecuzione = new Hlayout()
        Label labelDataEsecuzione = new Label()
        hlayoutDataEsecuzione.appendChild(labelDataEsecuzione)
        vlayout.appendChild(hlayoutDataEsecuzione)
        labelDataEsecuzione.value = (smistamentoDTO.dataAssegnazione == null) ? "" : (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataAssegnazione))
    }

    protected void riempiColonnaUtenteEsecuzione(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Nominativo */
        Hlayout hlayoutNominativo = new Hlayout()
        Label labelNominativo = new Label()
        hlayoutNominativo.appendChild(labelNominativo)
        vlayout.appendChild(hlayoutNominativo)
        labelNominativo.value = smistamentoDTO.utenteEsecuzione?.nominativoSoggetto
        if (StringUtils.isEmpty(labelNominativo.value)) {
            labelNominativo.value = smistamentoDTO.utenteEsecuzione?.nominativo
        }

        /* Data assegnazione */
        Hlayout hlayoutDataEsecuzione = new Hlayout()
        Label labelDataEsecuzione = new Label()
        hlayoutDataEsecuzione.appendChild(labelDataEsecuzione)
        vlayout.appendChild(hlayoutDataEsecuzione)
        labelDataEsecuzione.value = (smistamentoDTO.dataEsecuzione == null) ? "" : (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataEsecuzione))
    }

    protected void riempiColonnaUtenteRifiuto(Vlayout vlayout, SmistamentoDTO smistamentoDTO) {
        /* Nominativo */
        Label labelNominativo = new Label()
        vlayout.appendChild(labelNominativo)
        labelNominativo.value = smistamentoDTO.utenteRifiuto?.nominativoSoggetto
        if (StringUtils.isEmpty(labelNominativo.value)) {
            labelNominativo.value = smistamentoDTO.utenteRifiuto?.nominativo
        }

        /* Data rifiuto */
        Label labelDataEsecuzione = new Label()
        vlayout.appendChild(labelDataEsecuzione)
        labelDataEsecuzione.value = (smistamentoDTO.dataRifiuto == null) ? "" : (new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(smistamentoDTO.dataRifiuto))

        /* Motivo rifiuto */
        Label labelMotivo = new Label()
        vlayout.appendChild(labelMotivo)
        labelMotivo.value = smistamentoDTO?.motivoRifiuto
    }

    protected void riempiColonnaPulsanti(Listcell listcell, SmistamentoDTO smistamentoDTO) {
        Ad4Utente utenteSessione = springSecurityService.currentUser
        boolean visualizzaNoteRecord = false

        /* Pulsante Note */
        Toolbarbutton toolbarbuttonNote = new Toolbarbutton()
        toolbarbuttonNote.image = "/images/ags/16x16/note.png"
        toolbarbuttonNote.tooltiptext = "Nota"
        //toolbarbuttonNote.disabled = !competenze.modifica

        /* visualizzazione pulsante note */
        if (smistamentoDTO.note != null) {

            // se utente sessione è uguale a utente che ha trasmesso il documento (che ha scritto la nota);
            if (!visualizzaNoteRecord && utenteSessione.id == smistamentoDTO?.utenteTrasmissione?.id) {
                visualizzaNoteRecord = true
            }
            // se utente sessione è uguale a utente assegnatario (a prescindere da privilegio);
            if (!visualizzaNoteRecord && utenteSessione.id == smistamentoDTO?.utenteAssegnatario?.id) {
                visualizzaNoteRecord = true
            }
            // se utente sessione fa parte dell’unità ricevente (se non c’è assegnatario) e ha per l'ufficio privilego VS e VSMINOTE;
            if (!visualizzaNoteRecord && !smistamentoDTO?.utenteAssegnatario) {
                List<So4UnitaPubb> uoPubbRiceventi = strutturaOrganizzativaService.ricercaUnitaUtente(utenteSessione.utente, springSecurityService.principal.ottica().codice, new Date(), "")
                uoPubbRiceventi.each {
                    if (smistamentoDTO.unitaSmistamento.codice == it.codice) {
                        if (privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.VISUALIZZA_NOTE, smistamentoDTO.unitaSmistamento.codice, utenteSessione) == privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.SMISTAMENTO_VISUALIZZA, smistamentoDTO.unitaSmistamento.codice, utenteSessione)) {
                            visualizzaNoteRecord = true
                        }
                    }
                }
            }
            if (!visualizzaNoteRecord) {
                // se utente sessione fa parte dell’ufficio di trasmissione che hanno, per l'ufficio di trasmissione, privilegio VSMINOTE.
                List<So4UnitaPubb> uoPubbTrasmissione = strutturaOrganizzativaService.ricercaUnitaUtente(utenteSessione.utente, springSecurityService.principal.ottica().codice, new Date(), "")
                uoPubbTrasmissione.each {
                    if (smistamentoDTO.unitaTrasmissione.codice == it.codice) {
                        if (privilegioUtenteService.utenteHaPrivilegioPerUnita(PrivilegioUtente.VISUALIZZA_NOTE, smistamentoDTO.unitaTrasmissione.codice, utenteSessione)) {
                            visualizzaNoteRecord = true
                        }
                    }
                }
            }

            if (visualizzaNoteRecord) {
                listcell.appendChild(toolbarbuttonNote)
            }
        }

        toolbarbuttonNote.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            @Override
            void onEvent(Event event) throws Exception {
                onInserisciNotaSmistamento(smistamentoDTO)
            }
        })

        /* Pulsante Elimina */
        Toolbarbutton toolbarbuttonElimina = new Toolbarbutton()
        toolbarbuttonElimina.image = "/images/afc/16x16/delete.png"
        toolbarbuttonElimina.tooltiptext = "Elimina"
        toolbarbuttonElimina.disabled = !competenze.lettura
        toolbarbuttonElimina.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            @Override
            void onEvent(Event event) throws Exception {
                onEliminaSmistamento(smistamentoDTO)
            }
        })

        if (smistamentoDTO.isCancellabile(isSequenza, competenze, springSecurityService.currentUser)) {
            listcell.appendChild(toolbarbuttonElimina)
        }
    }

    private void visibilitaImageAddSmistamento() {
        imageAddSmistamento.visible = (this.competenze?.lettura && creaSmistamentiAbilitato)
    }

    void onAggiungiSmistamenti() {
        onSelezionaSmistamenti(MenuItemProtocollo.CREA_SMISTAMENTO)
    }

    ISmistabileDTO getDocumento() {
        return documento
    }

    void setDocumento(ISmistabileDTO documento) {
        this.documento = documento
    }

    void onSelezionaSmistamenti(String tipoAzione) {
        ISmistabile smistabile = documento.domainObject
        List<So4UnitaPubbDTO> listaUnitaTrasmissione
        So4UnitaPubbDTO unitaTrasmissioneDefault
        So4UnitaPubb unitaTrasmissioneDefaultDomain
        String tipoSmistamento
        boolean tipoSmistamentoVisibile = true
        boolean unitaTrasmissioneModificabile = true

        if (documento instanceof MessaggioRicevutoDTO && smistabile == null) {
            Clients.showNotification("Prima di aggiungere smistamenti è necessario salvare.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
            return
        }

        switch (tipoAzione) {
            case MenuItemProtocollo.CREA_SMISTAMENTO:

                // se non ho ancora creato il protocollo, le unità di trasmissione possibili sono solo quella già selezionata.
                if (smistabile == null || smistabile.numero == null) {
                    // se non l'ho ancora selezionata, allora segnalo un errore e non faccio nulla:
                    if (getUnitaSoggetto() == null) {
                        Clients.showNotification("Prima di aggiungere smistamenti è necessario scegliere l'unità.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
                        return
                    }

                    listaUnitaTrasmissione = [getUnitaSoggetto()]
                    unitaTrasmissioneDefault = listaUnitaTrasmissione[0]
                    tipoSmistamento = null
                    unitaTrasmissioneModificabile = false
                } else {
                    listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissione(smistabile, springSecurityService.currentUser)?.toDTO()
                    unitaTrasmissioneDefaultDomain = smistamentoService.getUnitaTrasmissioneDefault(smistabile, springSecurityService.currentUser)
                    unitaTrasmissioneDefault = unitaTrasmissioneDefaultDomain?.toDTO()
                    tipoSmistamento = smistamentoService.getTipoSmistamentoPerInoltro(smistabile, springSecurityService.currentUser, unitaTrasmissioneDefaultDomain)
                }
                break
            case MenuItemProtocollo.APRI_CARICO_ESEGUI_FLEX:
                listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissione(smistabile, springSecurityService.currentUser).toDTO()
                unitaTrasmissioneDefaultDomain = smistamentoService.getUnitaTrasmissioneCaricoDefault(smistabile, springSecurityService.currentUser)
                unitaTrasmissioneDefault = unitaTrasmissioneDefaultDomain?.toDTO()
                tipoSmistamento = smistamentoService.getTipoSmistamentoPerCarico(smistabile, springSecurityService.currentUser, unitaTrasmissioneDefaultDomain)
                break
            case MenuItemProtocollo.APRI_CARICO_FLEX:
                listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissionePerCaricoInoltro(smistabile, springSecurityService.currentUser)?.toDTO()
                unitaTrasmissioneDefaultDomain = smistamentoService.getUnitaTrasmissioneCaricoInoltroDefault(smistabile, springSecurityService.currentUser)
                unitaTrasmissioneDefault = unitaTrasmissioneDefaultDomain?.toDTO()
                tipoSmistamento = smistamentoService.getTipoSmistamentoPerCarico(smistabile, springSecurityService.currentUser, unitaTrasmissioneDefaultDomain)
                tipoSmistamentoVisibile = false
                break
            case MenuItemProtocollo.APRI_CARICO_ASSEGNA:
                listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissionePerCaricoAssegna(smistabile, springSecurityService.currentUser).toDTO()
                unitaTrasmissioneDefaultDomain = smistamentoService.getUnitaTrasmissioneCaricoAssegnaDefault(smistabile, springSecurityService.currentUser)
                unitaTrasmissioneDefault = unitaTrasmissioneDefaultDomain?.toDTO()
                tipoSmistamento = smistamentoService.getTipoSmistamentoPerInoltro(smistabile, springSecurityService.currentUser, unitaTrasmissioneDefaultDomain)
                tipoSmistamentoVisibile = false
                break
            case MenuItemProtocollo.APRI_ASSEGNA:
                listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissione(smistabile, springSecurityService.currentUser).toDTO()
                unitaTrasmissioneDefault = null
                tipoSmistamento = smistamentoService.getTipoSmistamentoPerInoltro(smistabile, springSecurityService.currentUser)
                tipoSmistamentoVisibile = false
                break
            case MenuItemProtocollo.APRI_INOLTRA_FLEX:
                listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissioneInoltro(smistabile, springSecurityService.currentUser).toDTO()
                unitaTrasmissioneDefault = null
                tipoSmistamento = smistamentoService.getTipoSmistamentoPerInoltro(smistabile, springSecurityService.currentUser)
                tipoSmistamentoVisibile = false
                break
            case MenuItemProtocollo.APRI_ESEGUI_FLEX:
                //in caso di prendi in carico smista ed esegui le unita di trasmissione devono essere estratte come per carico assegna
                listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissionePerCaricoAssegna(smistabile, springSecurityService.currentUser).toDTO()
                unitaTrasmissioneDefault = null
                tipoSmistamento = smistamentoService.getTipoSmistamentoPerCarico(smistabile, springSecurityService.currentUser)
                tipoSmistamentoVisibile = true
                break
            case MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX:
                listaUnitaTrasmissione = smistamentoService.getUnitaTrasmissione(smistabile, springSecurityService.currentUser).toDTO()
                unitaTrasmissioneDefault = null
                tipoSmistamento = smistamentoService.getTipoSmistamentoPerCarico(smistabile, springSecurityService.currentUser)
                break
            default:
                Clients.showNotification("Operazione ${tipoAzione} non gestita.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
                break
        }

        if (unitaTrasmissioneDefault == null && listaUnitaTrasmissione.size() > 0) {
            unitaTrasmissioneDefault = listaUnitaTrasmissione[0]
        }

        String zulPopup = "/commons/popupSceltaSmistamenti.zul"
        if (tipoAzione == MenuItemProtocollo.APRI_ASSEGNA || tipoAzione == MenuItemProtocollo.APRI_CARICO_ASSEGNA) {
            zulPopup = "/commons/popupSceltaAssegnatari.zul"
        }

        if (smistabile == null || smistabile.schemaProtocollo != null) {
            isSequenza = false
        } else {
            isSequenza = smistabile.schemaProtocollo?.isSequenza()
        }

        boolean smartDesktop = false

        Window w = Executions.createComponents(zulPopup, null, [operazione: tipoAzione, smistamenti: smistamenti, listaUnitaTrasmissione: listaUnitaTrasmissione, tipoSmistamento: tipoSmistamento, unitaTrasmissione: unitaTrasmissioneDefault, tipoSmistamentoVisibile: tipoSmistamentoVisibile, unitaTrasmissioneModificabile: unitaTrasmissioneModificabile, isSequenza: isSequenza, smartDesktop: smartDesktop])
        w.onClose { Event event ->
            PopupSceltaSmistamentiViewModel.DatiSmistamento datiSmistamenti = event.data

            if (datiSmistamenti == null) {
                // l'utente ha annullato le operazione: serve un evento perchè posso venire da un popup successivo adl un salvaEChiudi
                Events.postEvent(ON_CHANGE_SMISTAMENTI, this, smistamenti)
                return
            }

            if (datiSmistamenti.salvaENuovo && tipoAzione == MenuItemProtocollo.CREA_SMISTAMENTO) {
                if (documento.id > 0) {
                    if (documento.domainObject instanceof Fascicolo) {
                        smistamenti = smistamentoService.creaSmistamenti(documento, datiSmistamenti)
                    } else {
                        smistamenti = smistamentoService.creaSmistamenti(documento, datiSmistamenti)
                        smistamentoService.salva(documento, smistamenti)
                    }

                    if (!datiSmistamenti.salvaENuovo) {
                        Events.postEvent(ON_CHANGE_SMISTAMENTI, this, smistamenti)
                    }
                    setSmistamenti(smistamenti)
                } else {
                    // se non ho ancora salvato il protocollo, calcolo solo la lista degli smistamenti:
                    smistamenti = smistamentoService.creaSmistamenti(documento, datiSmistamenti)
                    if (!datiSmistamenti.salvaENuovo) {
                        Events.postEvent(ON_CHANGE_SMISTAMENTI, this, smistamenti)
                    }
                    setSmistamenti(smistamenti)
                }
                onSelezionaSmistamenti(tipoAzione)
                return
            }

            try {
                switch (tipoAzione) {
                    case MenuItemProtocollo.CREA_SMISTAMENTO:
                        // se ho già salvato il protocollo, allora salvo anche gli smistamenti
                        if (documento.domainObject) {
                            if (documento.domainObject instanceof Fascicolo) {
                                smistamenti = smistamentoService.creaSmistamenti(documento, datiSmistamenti)
                            } else {
                                smistamentoService.salva(documento, smistamentoService.creaSmistamenti(documento, datiSmistamenti))
                            }
                        } else {
                            // se non ho ancora salvato il protocollo, calcolo solo la lista degli smistamenti:
                            smistamenti = smistamentoService.creaSmistamenti(documento, datiSmistamenti)
                            break
                        }
                        break
                    case MenuItemProtocollo.APRI_CARICO_ESEGUI_FLEX:
                        Events.postEvent(Events.ON_CLOSE, null, null)
                        break
                    case MenuItemProtocollo.APRI_CARICO_FLEX:
                        smistamentoService.prendiInCaricoEInoltra(documento, datiSmistamenti)
                        break
                    case MenuItemProtocollo.APRI_CARICO_ASSEGNA:
                        smistamentoService.prendiInCaricoEAssegna(documento, datiSmistamenti)
                        break
                    case MenuItemProtocollo.APRI_ASSEGNA:
                        smistamentoService.assegna(documento, datiSmistamenti)
                        break
                    case MenuItemProtocollo.APRI_INOLTRA_FLEX:
                        smistamentoService.inoltra(documento, datiSmistamenti)
                        Events.postEvent(Events.ON_CLOSE, this, null)
                        break
                    case MenuItemProtocollo.APRI_SMISTA_FLEX:
                        smistamentoService.smista(documento, datiSmistamenti)
                        break
                    case MenuItemProtocollo.APRI_ESEGUI_FLEX:
                        smistamentoService.prendiInCaricoSmistaEdEsegui(documento, datiSmistamenti)
                        break
                    case MenuItemProtocollo.APRI_SMISTA_ESEGUI_FLEX:
                        smistamentoService.prendiInCaricoSmistaEdEsegui(documento, datiSmistamenti)
                        break
                    default:
                        Clients.showNotification("Operazione ${tipoAzione} non gestita.", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 2000, true)
                        break
                }

                Events.postEvent(ON_CHANGE_SMISTAMENTI, this, smistamenti)
                setSmistamenti(smistamenti)
            } catch (Exception e) {
                // impedisco la chiusura della popup e segnalo l'errore che è avvenuto
                event.stopPropagation()
                throw e
            }
        }
        w.doModal()
    }

    void onEliminaSmistamento(SmistamentoDTO smistamento) {
        if (documento.id > 0 && smistamento.id != null) {
            ISmistabile smistabile = documento.domainObject
            smistamentoService.eliminaSmistamento(smistabile, smistamento.domainObject)
            smistamenti.remove(smistamento)
            documento.version = smistabile.version
            Events.postEvent(ON_CHANGE_SMISTAMENTI, this, smistamenti)
            setSmistamenti(smistamenti)
        } else {
            smistamenti.remove(smistamento)
            documento.smistamenti = smistamenti
            Events.postEvent(ON_CHANGE_SMISTAMENTI, this, smistamenti)
            setDocumento(documento)
        }
    }

    void onInserisciNotaSmistamento(SmistamentoDTO smistamento) {
        Window w = Executions.createComponents("/commons/popupInserimentoNota.zul", null, [nota: smistamento.note, modifica: false])
        w.onClose { event ->
            if (event.data != null) {
                Smistamento s = smistamento?.domainObject
                if (s) {
                    s.note = event.data
                    s.save()
                } else {
                    smistamento.note = event.data
                }
                Events.postEvent(ON_CHANGE_SMISTAMENTI, this, smistamenti)
                setSmistamenti(smistamenti)
            }
        }
        w.doModal()
    }

    @Override
    void onEvent(Event event) throws Exception {
        String voce = event.data
        onSelezionaSmistamenti(voce)
    }

    /**
     * Se l'impostazione UNITA_CONCAT_CODICE è abilitata ritorna la concatenazione di codice + descrizione della UO
     * Altrimenti solo la descrizione
     *
     * @param unitaPubbDTO
     * @return
     */
    protected String getDescrizioneUO(So4UnitaPubbDTO unitaPubbDTO) {
        if (Impostazioni.UNITA_CONCAT_CODICE.abilitato) {
            if (unitaPubbDTO) {
                return unitaPubbDTO?.codice.concat(" - ").concat(unitaPubbDTO?.descrizione)
            } else {
                return null
            }
        } else {
            return unitaPubbDTO?.descrizione
        }
    }

    private So4UnitaPubbDTO getUnitaSoggetto() {
        if (soggetti.UO_CREAZIONE?.unita) {
            return soggetti.UO_CREAZIONE?.unita
        }
        return (soggetti.UO_PROTOCOLLANTE?.unita == null) ? soggetti.UO_MESSAGGIO?.unita : soggetti.UO_PROTOCOLLANTE?.unita
    }
}
