package it.finmatica.protocollo.zk.components.corrispondenti

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.as4.anagrafica.As4AnagraficaDTO
import it.finmatica.as4.anagrafica.As4ContattoDTO
import it.finmatica.as4.anagrafica.As4RecapitoDTO
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.apache.commons.lang.StringUtils
import org.zkoss.zhtml.Br
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
import org.zkoss.zul.Bandbox
import org.zkoss.zul.Checkbox
import org.zkoss.zul.Div
import org.zkoss.zul.Image
import org.zkoss.zul.Label
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Listbox
import org.zkoss.zul.Listcell
import org.zkoss.zul.Listitem
import org.zkoss.zul.ListitemRenderer
import org.zkoss.zul.Toolbarbutton
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
@ComponentAnnotation(['corrispondenti:@ZKBIND(ACCESS=both, SAVE_EVENT=onChangeCorrispondenti)', 'protocollo:@ZKBIND(ACCESS=load, SAVE_EVENT=onChangeProtocollo)'])
class CorrispondentiComponent extends Div {

    private final static String SRC_IMG_SENT = "/images/afc/16x16/sent.png"
    private final static String SRC_IMG_DELETE = "/images/afc/16x16/delete.png"

    public static final String ON_CHANGE_CORRISPONDENTI = 'onChangeCorrispondenti'
    public static final String ON_CHANGE_PROTOCOLLO = 'onChangeProtocollo'

    @WireVariable
    private CorrispondenteService corrispondenteService
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    private SpringSecurityService springSecurityService

    @Wire("listbox")
    private Listbox listbox
    @Wire("bandbox")
    private Bandbox bandbox
    @Wire("#tbAddSoggetto")
    private Toolbarbutton tbAddSoggetto
    @Wire("#tbListe")
    private Toolbarbutton tbListe
    @Wire("#tbAdrier")
    private Toolbarbutton tbAdrier
    @Wire("#tbModena")
    private Toolbarbutton tbModena

    private List<CorrispondenteDTO> corrispondenti = []
    private final boolean abilitaAnagraficheAdrier
    private final boolean abilitaAnagraficheSolWeb

    ProtocolloDTO protocollo

    boolean modificaRapporti
    boolean inserimentoRapporti
    boolean eliminazioneRapporti

    boolean tramiteCC

    String searchSoggetti

    Map competenze
    boolean puoInserireAnagrafica = false

    void setInserimentoRapporti(boolean inserimentoRapporti){
        this.inserimentoRapporti = inserimentoRapporti
    }

    CorrispondentiComponent() {
        Executions.createComponents("/components/corrispondenti.zul", this, null)
        Selectors.wireVariables(this, this, Selectors.newVariableResolvers(getClass(), Div))
        Selectors.wireComponents(this, this, false)
        Selectors.wireEventListeners(this, this)

        abilitaAnagraficheAdrier = ImpostazioniProtocollo.ADRIER_WS.abilitato
        abilitaAnagraficheSolWeb = (ImpostazioniProtocollo.ANAG_POPOLAZIONE_WS_URL.getValore() != null)
        Ad4Utente utente = springSecurityService.currentUser
        puoInserireAnagrafica = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.INSERISCI_ANAGRAFICA, utente)

        bandbox.setValue(searchSoggetti)
        bandbox.addEventListener(Events.ON_OK, new EventListener<Event>() {
            void onEvent(Event event) {
                onRicercaCorrispondenti(event.target.value)
            }
        })
        bandbox.addEventListener(Events.ON_OPEN, new EventListener<Event>() {
            void onEvent(Event event) {
                onRicercaCorrispondenti(event.value)
            }
        })
        if(tbAddSoggetto) {
            tbAddSoggetto.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
                void onEvent(Event event) {
                    onInserisciSoggetto()
                }
            })
        }
        tbListe.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            void onEvent(Event event) {
                onRicercaListeDistribuzione()
            }
        })
        tbAdrier.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            void onEvent(Event event) {
                onInserisciSoggettoAdrierSolWeb("Adrier")
            }
        })
        tbModena.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
            void onEvent(Event event) {
                onInserisciSoggettoAdrierSolWeb("SolWeb")
            }
        })
    }

    void setCorrispondenti(List<CorrispondenteDTO> corrispondenti) {
        this.corrispondenti = corrispondenti

        if (corrispondenti?.size() > 0) {
            listbox.setModel(new ListModelList<?>(corrispondenti))
            listbox.setItemRenderer(new ListitemRenderer<CorrispondenteDTO>() {
                @Override
                void render(Listitem listitem, CorrispondenteDTO corrispondenteDTO, int i) throws Exception {
                    boolean isAmministrazione = isAmministrazione(corrispondenteDTO)
                    String conoscenzaStyle = corrispondenteDTO.conoscenza && protocollo?.movimento != Protocollo.MOVIMENTO_ARRIVO ? "opacity:0.7; font-style:italic;" : ""
                    listitem.addEventListener(Events.ON_DOUBLE_CLICK, new EventListener<Event>() {
                        void onEvent(Event event) {
                            dettaglioCorrispondente(corrispondenteDTO)
                        }
                    })

                    Image sent = new Image(src: SRC_IMG_SENT, visible: (corrispondenteDTO?.protocollo?.movimento == "PARTENZA" && ImpostazioniProtocollo.MOD_SPED_ATTIVO.getValore() == 'Y'))
                    sent.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
                        @Override
                        void onEvent(Event event) throws Exception {
                            assegnaDatiSpedizione(corrispondenteDTO)
                        }
                    })

                    Image delete = new Image(src: SRC_IMG_DELETE, visible: competenze.modifica && eliminazioneRapporti, tooltiptext: "Elimina")
                    delete.addEventListener(Events.ON_CLICK, new EventListener<Event>() {
                        @Override
                        void onEvent(Event event) throws Exception {
                            removeCorrispondente(corrispondenteDTO)
                        }
                    })

                    Checkbox conoscenza = new Checkbox(checked: corrispondenteDTO.conoscenza, disabled: !competenze.modifica || !modificaRapporti, visible: protocollo?.movimento != Protocollo.MOVIMENTO_ARRIVO, label: "CC", tooltiptext: "per conoscenza")
                    conoscenza.addEventListener(Events.ON_CHECK, new EventListener<Event>() {
                        @Override
                        void onEvent(Event event) throws Exception {
                            refreshCorrispondente(corrispondenteDTO)
                        }
                    })

                    Listcell listcellSent = new Listcell(style: "text-align: center;")
                    listcellSent.appendChild(sent)
                    listitem.appendChild(listcellSent)
                    listitem.appendChild(new Listcell(label: corrispondenteDTO.denominazione,
                            visible: !isAmministrazione,
                            style: conoscenzaStyle))


                    if (isAmministrazione) {
                        String[] labels = []
//se il corrispondente ha dei sottoindirizzi è un amm/aoo/uo
                        labels = corrispondenteDTO.denominazione.split(":UO:")
                        if (labels?.size() == 1) {
                            labels = corrispondenteDTO.denominazione.split(":AOO:")
                        }
//                        if (corrispondenteDTO.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_UO) {
//                            labels = corrispondenteDTO.denominazione.split(":UO:")
//                        } else if (corrispondenteDTO.tipoIndirizzo == Indirizzo.TIPO_INDIRIZZO_AOO) {
//                            labels = corrispondenteDTO.denominazione.split(":AOO:")
//                        }
                        if (labels?.size() > 0) {
                            Listcell listcell = new Listcell(visible: isAmministrazione,
                                    tooltiptext: corrispondenteDTO.denominazione,
                                    style: conoscenzaStyle)
                            listcell.appendChild(new Label(labels[0]))
                            if (labels?.size() > 1) {
                                Label label = new Label(labels[1])
                                label.setStyle("font-size:smaller;")
                                listcell.appendChild(new Br())
                                listcell.appendChild(label)
                            }
                            listitem.appendChild(listcell)
                        } else {
                            listitem.appendChild(new Listcell(label: corrispondenteDTO.cognome,
                                    visible: isAmministrazione,
                                    tooltiptext: corrispondenteDTO.denominazione,
                                    style: conoscenzaStyle))
                        }
                    }

                    Listcell listcell = new Listcell(style: conoscenzaStyle)
                    Label label = new Label(corrispondenteDTO.indirizzoCompleto)
                    Label label1 = new Label(corrispondenteDTO.email)
                    label1.setStyle("font-size:smaller;")
                    listcell.appendChild(label)
                    listcell.appendChild(new Br())
                    listcell.appendChild(label1)
                    listitem.appendChild(listcell)
                    Listcell listcellDel
                    if(protocollo?.movimento != "PARTENZA") {
                        listcellDel =  new Listcell(style: listcellSent.style, span: 2)
                    } else {
                        listcellDel =  new Listcell(style: listcellSent.style)
                    }
                    listcellDel.appendChild(delete)
                    listitem.appendChild(listcellDel)
                    if(protocollo?.movimento == "PARTENZA") {
                        Listcell listcellCC = new Listcell()
                        listcellCC.appendChild(conoscenza)
                        listitem.appendChild(listcellCC)
                    }
                }

                boolean isAmministrazione(CorrispondenteDTO corrispondenteDTO) {
//                    corrispondenteDTO.tipoIndirizzo != "UO" && corrispondenteDTO.tipoIndirizzo != "AOO"
                    corrispondenteDTO.tipoSoggetto?.id == 2
                }
            })
        } else {
            listbox.setVisible(false)
        }
    }

    List<CorrispondenteDTO> getCorrispondenti() {
        return this.corrispondenti
    }

    ProtocolloDTO getProtocollo() {
        return protocollo
    }

    void setProtocollo(ProtocolloDTO protocollo) {
        this.protocollo = protocollo
        boolean disabled = isDisabled()

        tbAddSoggetto.setDisabled(disabled || !puoInserireAnagrafica)
        tbListe.setDisabled(disabled)
        tbAdrier.setVisible(!(disabled || !abilitaAnagraficheAdrier))
        tbModena.setVisible(!(disabled || !abilitaAnagraficheSolWeb))
        bandbox.setDisabled(disabled)
        listbox.setVisible(corrispondenti?.size() > 0)
    }

    void setCompetenze(Map competenze) {
        this.competenze = competenze
        setProtocollo(protocollo)
    }

    boolean isDisabled() {
        return /*protocollo?.movimento == Protocollo.MOVIMENTO_INTERNO ||*/ protocollo?.movimento == null || (!competenze?.modifica) || (!inserimentoRapporti) || (!modificaRapporti)
    }

    void assegnaDatiSpedizione(CorrispondenteDTO corrispondente) {
        if (protocollo.id < 0) {
            Clients.showNotification("Operazione disponibile dopo il salvataggio del documento", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }
        Window w = (Window) Executions.createComponents("/protocollo/documenti/commons/popupAssegnaDatiSpedizione.zul", null, [corrispondente: corrispondente, protocollo: protocollo])
        w.addEventListener(Events.ON_CLOSE, new EventListener<Event>() {
            void onEvent(Event event) {
                if (protocollo.id != null) {
                    // vedere se è evitabile
                    corrispondenti = findAllByProtocollo(protocollo.domainObject)
                    corrispondenti = corrispondenti?.sort { it.id }
                    protocollo.version = protocollo.domainObject?.version
                }
            }
        })
        w.doModal()
    }

    void dettaglioCorrispondente(CorrispondenteDTO corrispondente) {
        if (protocollo.id < 0) {
            Clients.showNotification("Dettaglio disponibile dopo il salvataggio del documento", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }
        Window w = (Window) Executions.createComponents("/protocollo/documenti/commons/corrispondente.zul", null, [corrispondente: corrispondente, competenze: competenze, modificaRapporti: modificaRapporti, modificaAnagrafe: false])
        w.addEventListener(Events.ON_CLOSE, new EventListener<Event>() {
            void onEvent(Event event) {
                if (protocollo.id != null) {
                    // vedere se è evitabile
                    corrispondenti = findAllByProtocollo(protocollo.domainObject)
                    corrispondenti = corrispondenti?.sort { it.id }
                    protocollo.version = protocollo.domainObject?.version
                }
            }
        })
        w.doModal()
    }

    void removeCorrispondente(CorrispondenteDTO corrispondente) {
        Protocollo protocolloDomain = protocollo.domainObject
        if (protocollo.id != null) {
            corrispondenteService.remove(protocolloDomain, corrispondente.domainObject)
            protocollo.version = protocolloDomain.version
            corrispondenti = findAllByProtocollo(protocolloDomain)
        } else {
            corrispondenti.remove(corrispondente)
        }
        corrispondenti?.sort { it.id }
        Events.postEvent(ON_CHANGE_CORRISPONDENTI, this, corrispondenti)
        setCorrispondenti(corrispondenti)
    }

    void refreshCorrispondente(CorrispondenteDTO corrispondente) {
        corrispondente.conoscenza = !corrispondente.conoscenza
        Corrispondente c = corrispondente.domainObject
        if (c) {
            corrispondenteService.aggiorna(corrispondente)
        }
        Events.postEvent(ON_CHANGE_CORRISPONDENTI, this, corrispondenti)
    }

    void onInserisciSoggetto() {
        Window w = Executions.createComponents("/as4/anagrafica/dettaglio.zul", null, [tipo: "inserimento", codiceFiscalePartitaIvaObb: true, selectedSoggettoId: null, filtriSoggetto: null, progettoChiamante: "AGS", storico: false])
        w.onClose { event ->
            if (event.data == null) {
                return
            }
            List<As4ContattoDTO> listaContatti = event.data["listaContatti"]?.toDTO()
            List<As4RecapitoDTO> listaRecapiti = event.data["listaRecapiti"]?.toDTO()
            As4AnagraficaDTO soggetto = event.data["soggetto"]?.toDTO()

            if (soggetto?.cognome == null) {
                return
            }

            List<CorrispondenteDTO> corrispondenti = null
            if (soggetto?.id != null) {
                corrispondenti = corrispondenteService.ricercaDestinatari(soggetto?.id?.toString(),
                                                                          false,
                                                                          null, null, null, null, null, null, null, null, null, null, null, null,
                                                                          soggetto.ni?.toString())
            }
            if (corrispondenti?.size() > 0) {
                inserisciCorrispondente(corrispondenti.get(0))
            } else {
                // se non esiste nell'ANAGRAFICA, lo creiamo solo associato al rapporto (documento)
                // Caso 1: più contatti non salvati
                List<CorrispondenteDTO> listaCorrispondentiDto = corrispondenteService.costruisciListaRecapiti(soggetto, listaRecapiti, listaContatti)

                if (listaCorrispondentiDto?.size() > 1) {
                    // scelta del contatto scelto
                    sceltaContattoOmonimo(listaCorrispondentiDto)
                }
                // caso 2: Un contatto non salvato
                else {
                    // c'è un solo contatto con un recapito associato
                    CorrispondenteDTO corrispondente = corrispondenteService.costruisciCorrispondente(soggetto)
                    if (listaContatti && listaContatti.size() == 1) {
                        for (As4ContattoDTO contatto : listaContatti) {
                            corrispondenteService.aggiungiContatto(contatto, corrispondente)
                        }
                    }
                    // c'è un solo recapito senza contatti
                    else if (listaRecapiti) {
                        for (As4RecapitoDTO recapito : listaRecapiti) {
                            corrispondenteService.aggiungiRecapito(recapito, corrispondente)
                        }
                    }
                    inserisciCorrispondente(corrispondente)
                }
            }
        }
        w.doModal()
    }

    void onRicercaCorrispondenti(String search, Window window = null) {
        if (search.length() < 3) {
            Clients.showNotification("Inserisci almeno 3 caratteri", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }

        Window w = Executions.createComponents("/commons/popupSceltaCorrispondenti.zul", window, [search: search, competenze: competenze, modificaRapporti: modificaRapporti,protocollo: protocollo])
        w.onClose { event ->
            if (event.data != null) {
                CorrispondenteDTO selectedCorrispondente = event.data
                impostaTramiteCC(selectedCorrispondente)
                inserisciCorrispondente(selectedCorrispondente)
            }
        }
        w.doModal()
    }

    void onRicercaListeDistribuzione() {
        Window w = Executions.createComponents("/commons/popupSceltaListeDistribuzione.zul", null, [:])
        w.onClose { event ->
            if (event.data != null) {
                List<CorrispondenteDTO> selectedCorrispondenti = event.data

                for (CorrispondenteDTO selectedCorrispondente : selectedCorrispondenti) {
                    if (corrispondenti.find { it ->
                        confrontaCorrispondenti(it, selectedCorrispondente)
                    }) {
                        continue
                    }
                    impostaTramiteCC(selectedCorrispondente)
                    if (protocollo.id != null) {
                        corrispondenteService.salva(protocollo.domainObject, [selectedCorrispondente], true)
                        corrispondenti = findAllByProtocollo(protocollo.domainObject)
                        protocollo.version = protocollo.domainObject.version
                    } else {
                        corrispondenti.add(selectedCorrispondente)
                    }
                }
                corrispondenti?.sort { it.id }
                Events.postEvent(ON_CHANGE_CORRISPONDENTI, this, corrispondenti)
                if (corrispondenti?.size() > 0) {
                    listbox.setVisible(true)
                }
            }
        }
        w.doModal()
    }

    void onInserisciSoggettoAdrierSolWeb(String tipo) {
        Window w = Executions.createComponents("/commons/popupSceltaAnagrafiche" + tipo + ".zul", null, [:])
        w.onClose { event ->
            if (event.data != null) {
                CorrispondenteDTO selectedCorrispondente = event.data
                if (corrispondenti.find { it ->
                    confrontaCorrispondenti(it, selectedCorrispondente)
                }) {
                    return
                }
                impostaTramiteCC(selectedCorrispondente)
                if (protocollo.id != null) {
                    corrispondenteService.salva(protocollo.domainObject, [selectedCorrispondente])
                    corrispondenti = findAllByProtocollo(protocollo.domainObject)
                    protocollo.version = protocollo.domainObject.version
                } else {
                    corrispondenti.add(selectedCorrispondente)
                }

                corrispondenti?.sort { it.id }
                Events.postEvent(ON_CHANGE_CORRISPONDENTI, this, corrispondenti)
                if (corrispondenti?.size() > 0) {
                    listbox.setVisible(true)
                }
            }
        }
        w.doModal()
    }

    private void inserisciCorrispondente(CorrispondenteDTO selectedCorrispondente) {
        if (corrispondenti.find { it ->
            confrontaCorrispondenti(it, selectedCorrispondente)
        }) {
            searchSoggetti = ""
            bandbox.setValue(searchSoggetti)
            return
        }
        Protocollo p = protocollo.domainObject
        if(!inserimentoRapporti){
            Clients.showNotification("L'utente non può inserire rapporti", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 3000, true)
            return
        }
        impostaTramiteCC(selectedCorrispondente)
        if (p) {

            if(p.movimento == null && protocollo.movimento != null){
                p.movimento = protocollo.movimento
            }
            corrispondenteService.salva(p, [selectedCorrispondente])
            corrispondenti = findAllByProtocollo(p)
            protocollo.version = protocollo.domainObject?.version
        } else {
            corrispondenti.add(selectedCorrispondente)
        }
        corrispondenti = corrispondenti?.sort { it.id }
        Events.postEvent(ON_CHANGE_CORRISPONDENTI, this, corrispondenti)
        if (corrispondenti?.size() > 0) {
            listbox.setVisible(true)
        }

        searchSoggetti = ""
        bandbox.setValue(searchSoggetti)
    }

    /**
     *
     * @param corrispondenteDTO
     * @param selectedCorrispondente
     * @return se i due corrispondenti sono uguali
     */
    private boolean confrontaCorrispondenti(CorrispondenteDTO corrispondenteDTO, CorrispondenteDTO selectedCorrispondente) {
        // Caso Amministrazione / UO / AOO
        if (corrispondenteDTO.codiceAmministrazione && selectedCorrispondente.codiceAmministrazione
        && corrispondenteDTO.codiceAmministrazione == selectedCorrispondente.codiceAmministrazione) {
            return corrispondenteDTO.denominazione == selectedCorrispondente.denominazione &&
                    corrispondenteDTO.indirizzoCompleto?.replaceAll(" ", "").equals(selectedCorrispondente.indirizzoCompleto?.replaceAll(" ", "")) &&
                    (corrispondenteDTO.email?:"").equals(selectedCorrispondente.email?:"")

        }
//        if ((corrispondenteDTO.tipoIndirizzo == it.finmatica.protocollo.corrispondenti.Indirizzo.TIPO_INDIRIZZO_UO ||
//                corrispondenteDTO.tipoIndirizzo == it.finmatica.protocollo.corrispondenti.Indirizzo.TIPO_INDIRIZZO_AOO ||
//                corrispondenteDTO.tipoIndirizzo == it.finmatica.protocollo.corrispondenti.Indirizzo.TIPO_INDIRIZZO_AMMINISTRAZIONE)) {
//            return corrispondenteDTO.denominazione == selectedCorrispondente.denominazione
//        }

        // Caso Soggetti
        if (StringUtils.isEmpty(corrispondenteDTO.codiceFiscale) && StringUtils.isEmpty(selectedCorrispondente.codiceFiscale)) {
            if (corrispondenteDTO.denominazione != selectedCorrispondente.denominazione) {
                return false
            }
        }

        if (corrispondenteDTO.codiceFiscale == selectedCorrispondente.codiceFiscale) {
            if (corrispondenteDTO.indirizzoCompleto == selectedCorrispondente.indirizzoCompleto) {
                if (corrispondenteDTO.email == selectedCorrispondente.email) {
                    return true
                }
            }
        }
        return false
    }

    private void sceltaContattoOmonimo(List<CorrispondenteDTO> listaCorrispondentiDto) {
        Window w1 = Executions.createComponents("/commons/popupSceltaRecapiti.zul", null, [corrispondenti: listaCorrispondentiDto])
        w1.doModal()
        w1.onClose { event1 ->
            if (event1.data != null) {
                CorrispondenteDTO corrispondenteScelto = event1.data
                if (corrispondenteScelto) {
                    inserisciCorrispondente(corrispondenteScelto)
                }
            }
        }
    }

    private List<CorrispondenteDTO> findAllByProtocollo(Protocollo protocolloDomain) {
        return Corrispondente.findAllByProtocollo((Protocollo) protocolloDomain)?.toDTO(["messaggi", "indirizzi"])
    }

    private void impostaTramiteCC(CorrispondenteDTO selectedCorrispondente) {
        if (protocollo?.movimento != Protocollo.MOVIMENTO_PARTENZA) {
            selectedCorrispondente.conoscenza = tramiteCC
        }
    }
}
