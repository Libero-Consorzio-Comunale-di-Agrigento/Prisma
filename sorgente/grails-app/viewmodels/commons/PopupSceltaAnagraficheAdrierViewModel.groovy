package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.integrazioni.anagrafe.AdrierService
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
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window


@VariableResolver(DelegatingVariableResolver)
class PopupSceltaAnagraficheAdrierViewModel {

    Window self
    def listaAnagraficheAdrier
    def listaDettaglioAnagraficheAdrier
    HashMap<String, String> mappaAnagraficaScelta

    HashMap<String, String> mappaAnagraficaDettaglioSelected

    String descrizioneAnagraficaScelta = "    "
    String codiceFiscale
    String partitaIva

    @WireVariable private AdrierService adrierService

    @NotifyChange("listaAnagraficheAdrier")
    @Init
    init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("search") String search) {

        this.self = w
    }

    @NotifyChange(["listaAnagraficheAdrier", "listaDettaglioAnagraficheAdrier", "descrizioneAnagraficaScelta"])
    @Command
    onCerca(@BindingParam("search") String search) {

        def mappaRet = adrierService.ricerca(search)

        if (mappaRet["esito"].equals("KO")) {
            Messagebox.show(mappaRet["errore"], "Errore!", Messagebox.OK, Messagebox.ERROR)

        }
        if (mappaRet["esito"].equals("OK")) {
            listaAnagraficheAdrier = mappaRet["listaImprese"]

            if (listaAnagraficheAdrier.size() > 0) {
                mappaAnagraficaScelta = listaAnagraficheAdrier.get(0)

                onCaricaDettaglio(mappaAnagraficaScelta)
            } else {
                mappaAnagraficaScelta = null
            }
        }

        aggiornaDescrizioneAnagraficaScelta()
    }

    @NotifyChange(["listaDettaglioAnagraficheAdrier", "descrizioneAnagraficaScelta", "mappaAnagraficaDettaglioSelected"])
    @Command
    onCaricaDettaglio(@BindingParam("mappa") def mappa) {
        mappaAnagraficaDettaglioSelected = null
        mappaAnagraficaScelta = mappa
        aggiornaDescrizioneAnagraficaScelta()

        def mappaRet = adrierService.ricercaDettagli(mappaAnagraficaScelta["sigla"], mappaAnagraficaScelta["numRea"])

        if (mappaRet["esito"].equals("KO")) {
            Messagebox.show(mappaRet["errore"], "Errore!", Messagebox.OK, Messagebox.ERROR)
        }
        if (mappaRet["esito"].equals("OK")) {
            codiceFiscale = mappaRet.impresa["codiceFiscale"]
            partitaIva = mappaRet.impresa["partitaIva"]
            BindUtils.postNotifyChange(null, null, this, "codiceFiscale")
            BindUtils.postNotifyChange(null, null, this, "partitaIva")
            listaDettaglioAnagraficheAdrier = mappaRet["listaDettagli"]
        }
    }

    @Command
    onScegliAnagrafica() {
        if (mappaAnagraficaDettaglioSelected == null) return
        Events.postEvent(Events.ON_CLOSE, self, buildCorrispondente(mappaAnagraficaScelta, mappaAnagraficaDettaglioSelected))
    }

    @Command
    onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }


    private void aggiornaDescrizioneAnagraficaScelta() {
        if (mappaAnagraficaScelta == null)
            descrizioneAnagraficaScelta = "    "
        else
            descrizioneAnagraficaScelta = "Lista Sedi per " + mappaAnagraficaScelta["denominazione"]

    }


    private CorrispondenteDTO buildCorrispondente(def mappaAnagrafica, def mappaDettaglioAnagrafica) {
        CorrispondenteDTO corrispondenteDTO = new CorrispondenteDTO()

        corrispondenteDTO.tipoSoggetto = new TipoSoggettoDTO(id: 3)
        corrispondenteDTO.denominazione = mappaAnagrafica["denominazione"]
        corrispondenteDTO.indirizzo = mappaDettaglioAnagrafica["indirizzo"]
        corrispondenteDTO.email = mappaDettaglioAnagrafica["mail"]
        corrispondenteDTO.partitaIva = partitaIva
        corrispondenteDTO.codiceFiscale = codiceFiscale
        corrispondenteDTO.comune = mappaDettaglioAnagrafica["comune"]
        corrispondenteDTO.cap = mappaDettaglioAnagrafica["cap"]
        corrispondenteDTO.provinciaSigla = mappaAnagrafica["sigla"]
        corrispondenteDTO.anagrafica = "I"
        corrispondenteDTO.cognome = corrispondenteDTO.denominazione

        return corrispondenteDTO
    }
}
