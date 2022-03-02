package commons

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.as4.anagrafica.As4AnagraficaDTO
import it.finmatica.as4.anagrafica.As4ContattoDTO
import it.finmatica.as4.anagrafica.As4RecapitoDTO
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.CorrispondenteService
import it.finmatica.protocollo.corrispondenti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import org.apache.commons.lang.StringUtils
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Bandbox
import org.zkoss.zul.Button
import org.zkoss.zul.Cell
import org.zkoss.zul.Row
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaCorrispondentiViewModel {

    @WireVariable
    private PreferenzeUtenteService preferenzeUtenteService
    @WireVariable
    private CorrispondenteService corrispondenteService
    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    private SpringSecurityService springSecurityService

    CorrispondenteDTO selectedCorrispondente
    String search
    String denominazione
    String indirizzo
    String codiceFiscale
    String codiceFiscaleEstero
    String partitaIva
    String email
    String tipoRicercaDenominazione = "LIBERA"
    boolean ricercaAvanzata = false
    TipoSoggettoDTO selectedTipoSoggetto
    ProtocolloDTO protocollo

    List<CorrispondenteDTO> listaCorrispondentiDto
    List<TipoSoggettoDTO> listaTipoSoggetto

    Window self

    def competenze
    boolean modificaRapporti
    boolean modificaAnagrafica = false
    boolean inserisciAnagrafica = false


    @NotifyChange("listaCorrispondentiDto")
    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("search") String search, @ExecutionArgParam("competenze") competenze, @ExecutionArgParam("modificaRapporti") modificaRapporti,@ExecutionArgParam("protocollo") ProtocolloDTO protocollo) {
        this.self = w
        boolean amministrazione = false
        this.search = search
        this.protocollo = protocollo
        listaCorrispondentiDto = corrispondenteService.ricercaDestinatari(search, false)
        Ad4Utente utente = springSecurityService.currentUser
        modificaAnagrafica = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.MODIFICA_ANAGRAFICA,utente)
        inserisciAnagrafica = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.INSERISCI_ANAGRAFICA,utente)

        if (listaCorrispondentiDto.size() == 1) {
            CorrispondenteDTO corrispondente = listaCorrispondentiDto.get(0)
            if (preferenzeUtenteService.isApriSoggettoUnivoco()) {

                if(corrispondente?.tipoSoggetto?.id == new Long(2)) {
                    corrispondente.indirizzi = corrispondenteService.getIndirizziAmministrazione(corrispondente.codiceAmministrazione, corrispondente.aoo, corrispondente.uo)
                    amministrazione = true
                }

                this.self.setWidth("0px")
                corrispondente.protocollo = protocollo
                Window w1 = Executions.createComponents("/protocollo/documenti/commons/corrispondente.zul", self, [corrispondente: corrispondente, competenze: competenze, modificaRapporti: modificaRapporti, modificaAnagrafe: modificaAnagrafica, amministrazione: amministrazione])
                w1.doModal()
                w1.onClose { event ->
                    if (event.data != null) {
                        corrispondente = event.data
                        Events.postEvent(Events.ON_CLOSE, self, corrispondente)
                        return
                    }
                    else{
                        Events.postEvent(Events.ON_CLOSE, self, null)
                    }
                }
            } else {
                Events.postEvent(Events.ON_CLOSE, self, corrispondente)
            }
        } else if (listaCorrispondentiDto.size() == 0) {
            Events.postEvent(Events.ON_CLOSE, self, null)
            Clients.showNotification(StringUtils.join("Nessun risultato trovato", "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 2000, true)
            return
        }

        selectedTipoSoggetto = new TipoSoggettoDTO(descrizione: "Tutti")

        listaTipoSoggetto = TipoSoggetto.createCriteria().list() {
            order('sequenza', 'asc')
        }.toDTO()
        listaTipoSoggetto.add(0, selectedTipoSoggetto)
    }

    @NotifyChange(["listaCorrispondentiDto"])
    @Command
    void onCerca(@BindingParam("search") String search, @BindingParam("selectedItem") TipoSoggettoDTO selectedItem) {

        if (ricercaAvanzata) {
            onRicercaAvanzata(selectedItem)
            return
        }

        this.search = search
        if (selectedItem) {
            selectedTipoSoggetto = selectedItem
        }

        if (search.length() < 3) {
            Clients.showNotification(StringUtils.join("Inserisci almeno 3 caratteri", "\n"), Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 2000, true)
            return
        }

        boolean isQuery = true
        if (!selectedTipoSoggetto.id) {
            isQuery = false
        }
        listaCorrispondentiDto = corrispondenteService.ricercaDestinatari(search,
                isQuery,
                null,
                null,
                null,
                null,
                null,
                null,
                selectedTipoSoggetto,
                null,
                tipoRicercaDenominazione)

        BindUtils.postNotifyChange(null, null, this, "listaCorrispondentiDto")
    }

    @Command
    void onModificaSoggetto(@BindingParam("corrispondente") CorrispondenteDTO corrispondente) {
        if(!modificaAnagrafica) {
            Clients.showNotification('Utente non autorizzato',Clients.NOTIFICATION_TYPE_ERROR,self,"middle_center",5000)
        } else {
            Window w = Executions.createComponents("/as4/anagrafica/dettaglio.zul", self, [tipo: "modifica", selectedSoggettoId: corrispondente.ni, codiceFiscalePartitaIvaObb: true, filtriSoggetto: null, progettoChiamante: "AGS", storico: false])
            w.onClose { event ->
                if (event.data != null) {
                    onCerca(search, selectedTipoSoggetto)
                }
            }
            w.doModal()
        }
    }

    @Command
    void onInserisciSoggetto() {
        if(!modificaAnagrafica) {
            Clients.showNotification('Utente non autorizzato', Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 5000)
        } else {
            Window w = Executions.createComponents("/as4/anagrafica/dettaglio.zul", self, [tipo: "inserimento", codiceFiscalePartitaIvaObb: true, selectedSoggettoId: null, filtriSoggetto: null, progettoChiamante: "AGS", storico: false])
            w.onClose { event ->
                if (event.data != null) {
                    List<As4ContattoDTO> listaContatti = event.data["listaContatti"]?.toDTO()
                    List<As4RecapitoDTO> listaRecapiti = event.data["listaRecapiti"]?.toDTO()
                    As4AnagraficaDTO soggetto = event.data["soggetto"]?.toDTO()

                    if (soggetto != null && soggetto.cognome != null) {
                        List<CorrispondenteDTO> corrispondenti = null

                        if (soggetto?.id != null) {
                            corrispondenti = corrispondenteService.ricercaDestinatari(soggetto?.id?.toString(),
                                                                                       false,
                                                                                        null, null, null, null, null, null, null, null, null, null, null, null,
                                                                                        soggetto.ni?.toString())
                        }

                        if (corrispondenti?.size() > 0) {
                            Events.postEvent(Events.ON_CLOSE, self, corrispondenti[0])
                        } else {

                            // se non esiste nell'ANAGRAFICA, lo creiamo solo associato al rapporto (documento)
                            // Caso 1: più contatti non salvati
                            List<CorrispondenteDTO> listaCorrispondentiDto = corrispondenteService.costruisciListaRecapiti(soggetto, listaRecapiti, listaContatti)

                            if (listaCorrispondentiDto?.size() > 1) {

                                // scelta del contatto scelto
                                Window w1 = Executions.createComponents("/commons/popupSceltaRecapiti.zul", self, [corrispondenti: listaCorrispondentiDto])
                                w1.doModal()
                                w1.onClose { event1 ->
                                    if (event1.data != null) {
                                        CorrispondenteDTO corrispondenteScelto = event1.data
                                        if (corrispondenteScelto) {
                                            Events.postEvent(Events.ON_CLOSE, self, corrispondenteScelto)
                                        }
                                    }
                                }
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
                                Events.postEvent(Events.ON_CLOSE, self, corrispondente)
                            }
                        }
                    }
                }
            }
            w.doModal()
        }
    }


    @Command
    void onRicercaAvanzata(@BindingParam("selectedItem") TipoSoggettoDTO selectedItem) {

        boolean isQuery = true

        if (selectedItem) {
            selectedTipoSoggetto = selectedItem
        }

        if (!selectedTipoSoggetto.id) {
            Clients.showNotification("Non è possibile effettuare questa ricerca per tutte le tipologie di soggetti", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 2000, true)
            return
        }

        listaCorrispondentiDto = corrispondenteService.ricercaDestinatari(null, isQuery,
                search ?  search.trim()  : null,
                indirizzo ? "%" + indirizzo.trim() + "%" : null,
                codiceFiscale ? "%" + codiceFiscale.trim() + "%" : null,
                partitaIva ? partitaIva.trim() + "%" : null,
                email ? "%" + email.trim() + "%" : null,
                null,
                selectedTipoSoggetto,
                codiceFiscaleEstero ? "%" + codiceFiscaleEstero.trim() + "%" : null,
                tipoRicercaDenominazione)

        BindUtils.postNotifyChange(null, null, this, "listaCorrispondentiDto")
    }

    @Command
    public void onVisualizzaFiltriDiRicerca(@BindingParam("cellA") Row cellA, @BindingParam("cellS") Cell cellS, @BindingParam("buttonSwitch") Button buttonSwitch,
                                            @BindingParam("cellTipo") Cell cellTipo) {
        if (!cellA.visible) {
           // cellS.visible = false
            cellA.visible = true
            buttonSwitch.tooltip = "Ricerca Semplice"
            buttonSwitch.tooltiptext = "Ricerca Semplice"
            ricercaAvanzata = true
            self.invalidate()
        } else {
           // cellS.visible = true
            cellA.visible = false
            buttonSwitch.tooltiptext = "Ricerca Avanzata"
            buttonSwitch.tooltip = "Ricerca Avanzata"
            ricercaAvanzata = false
            self.invalidate()
        }
        BindUtils.postNotifyChange(null, null, this, "ricercaAvanzata")
    }


    @Command
    void onSalva() {
        Events.postEvent(Events.ON_CLOSE, self, selectedCorrispondente)
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
