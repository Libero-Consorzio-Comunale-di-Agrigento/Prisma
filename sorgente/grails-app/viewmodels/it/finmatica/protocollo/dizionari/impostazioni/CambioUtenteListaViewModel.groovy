package it.finmatica.protocollo.dizionari.impostazioni
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.ricerca.MascheraRicercaDocumento
import org.hibernate.criterion.CriteriaSpecification
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.util.resource.Labels
import org.zkoss.zk.ui.Executions
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class CambioUtenteListaViewModel {

    Window self

    def documentiSelezionati

    def listaTipiSoggetto
    def tipoSoggetto

    def listaSoggetti
    def soggetto

    // ricerca
    MascheraRicercaDocumento ricerca

    private final String NO_VALUE = "- -"
    def tipoOggetto
    def tipiOggetto = [(Protocollo.CATEGORIA_LETTERA): [popup         : "/commons/popupRicercaDocumenti.zul",
                                                        nome          : Labels.getLabel("tipoOggetto.lettere"),
                                                        labelCategoria: Labels.getLabel("label.categoria.lettera"),
                                                        icona         : "/images/ags/22x22/lettera.png"]]

    int selectedIndexTipiSoggetto = -1
    int selectedIndexSoggetti = -1

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        onCambiaTipo()
        BindUtils.postNotifyChange(null, null, this, "ricerca")
    }

    @NotifyChange(["ricerca", "listaTipiSoggetto", "tipoSoggetto", "selectedIndexTipiSoggetto", "listaSoggetti", "soggetto", "selectedIndexSoggetti"])
    @Command
    void onCambiaTipo() {
        String tipoDocumento = ricerca?.tipoDocumento ?: Protocollo.CATEGORIA_LETTERA

        ricerca = new MascheraRicercaDocumento(tipoDocumento: tipoDocumento)
        ricerca.registro = null
        ricerca.filtroAggiuntivo = {
            createAlias('iter.stepCorrente', 'step', CriteriaSpecification.INNER_JOIN)
            createAlias('iter.stepCorrente.attori', 'attori', CriteriaSpecification.INNER_JOIN)
            createAlias('iter', 'iter', CriteriaSpecification.INNER_JOIN)
            createAlias('soggetti', 'ds', CriteriaSpecification.INNER_JOIN)

            isNull("iter.dataFine")
            isNotNull("step.id")

            if (tipoSoggetto?.codice == "UTENTE_IN_CARICO") {
                eq("attori.utenteAd4", soggetto)
            } else {
                eq("attori.utenteAd4.id", soggetto?.id)
                eqProperty("attori.utenteAd4", "ds.utenteAd4")
                eq("ds.tipoSoggetto", tipoSoggetto?.codice)
            }
        }
        tipoOggetto = tipiOggetto[tipoDocumento]
        ricerca.caricaListe()
        onCerca()
        caricaListaTipiSoggetto()
        caricaListaSoggetti()
    }

    @NotifyChange("ricerca")
    @Command
    void onRefresh() {
        ricerca.ricerca(null)
    }

    @NotifyChange("ricerca")
    @Command
    void onPagina() {
        ricerca.pagina(null)
    }

    @NotifyChange("ricerca")
    @Command
    void onCerca() {
        ricerca.ricerca(null)
    }

    private void caricaListaTipiSoggetto() {
        // se invece è un visto, un parere o un codice:
        listaTipiSoggetto = new ArrayList()
        listaTipiSoggetto.add(new TipoSoggetto(codice: TipoSoggetto.REDATTORE, descrizione: "Redattore"))
        listaTipiSoggetto.add(new TipoSoggetto(codice: TipoSoggetto.FIRMATARIO, descrizione: "Firmatario"))
        listaTipiSoggetto.add(new TipoSoggetto(codice: TipoSoggetto.FUNZIONARIO, descrizione: "Funzionario"))

        //listaTipiSoggetto.add(0, new TipoSoggetto(codice:"UTENTE_IN_CARICO", titolo: "Utente in Carico"))
        if (listaTipiSoggetto.size() > 0) {
            tipoSoggetto = listaTipiSoggetto[0]
            selectedIndexTipiSoggetto = 0
        } else {
            tipoSoggetto = null
            selectedIndexTipiSoggetto = -1
        }
    }

    private void caricaListaSoggetti() {
        listaSoggetti = []
        if (ricerca.tipoDocumento == Protocollo.CATEGORIA_LETTERA) {
            listaSoggetti = Documento.createCriteria().list() {
                createAlias('soggetti', 'ds', CriteriaSpecification.INNER_JOIN)
                createAlias('iter', 'it', CriteriaSpecification.INNER_JOIN)
                createAlias('iter.stepCorrente', 'step', CriteriaSpecification.INNER_JOIN)
                createAlias('iter.stepCorrente.attori', 'attori', CriteriaSpecification.INNER_JOIN)
                projections {
                    distinct("attori.utenteAd4")
                }
                eq("valido", true)
                isNull("it.dataFine")

                if ("UTENTE_IN_CARICO" == tipoSoggetto.codice) {
                    isNotNull("attori.utenteAd4")
                } else {
                    eqProperty("attori.utenteAd4", "ds.utenteAd4")
                    eq("ds.tipoSoggetto", tipoSoggetto.codice)
                }
            }.toDTO()
        }

        listaSoggetti.sort { it.nominativoSoggetto }
        listaSoggetti.add(0, (new Ad4Utente(id: "", nominativo: "")).toDTO())
        soggetto = listaSoggetti[0]
        selectedIndexSoggetti = 0
    }

    @NotifyChange(["ricerca", "tipoSoggetto"])
    @Command
    void onCambiaTipoOggetto() {
        // se sono in init, "ricerca" è null quindi imposto come default la ricerca su Determina.
        // altrimenti, l'utente ha cambiato il tipo documento da interfaccia, quindi me lo segno e reinizializzo la ricerca con quei valori.
        String tipoDocumento = ricerca?.tipoDocumento ?: Protocollo.CATEGORIA_LETTERA
        ricerca = new MascheraRicercaDocumento(tipoDocumento: tipoDocumento)
        ricerca.caricaListe()
        tipoSoggetto = null
    }

    @NotifyChange(["ricerca", "listaSoggetti", "soggetto", "selectedIndexSoggetti"])
    @Command
    void onCambiaTipoSoggetto() {
        caricaListaSoggetti()
    }

    @NotifyChange("ricerca")
    @Command
    void onCambiaSoggetto() {
        onCerca()
    }

    @Command
    void onApriDocumento(@BindingParam("documento") documento) {
        ProtocolloViewModel.apriPopup(documento.id)
    }

    @Command
    void onModificaUtente() {
        if (!documentiSelezionati.isEmpty()) {
            Window w = Executions.createComponents("/dizionari/impostazioni/cambioUtenteDettaglio.zul"
                    , self
                    , [listaOggetti: documentiSelezionati, tipoDoc: ricerca.tipoDocumento, tipoSoggetto: tipoSoggetto, utentePrecedente: soggetto])
            w.onClose {
                onCerca()
                caricaListaSoggetti()
                documentiSelezionati = null
                BindUtils.postNotifyChange(null, null, this, "ricerca")
                BindUtils.postNotifyChange(null, null, this, "documentiSelezionati")
            }
            w.doModal()
        }
    }
}
