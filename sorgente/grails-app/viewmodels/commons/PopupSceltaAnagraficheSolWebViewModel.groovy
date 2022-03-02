package commons
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.protocollo.corrispondenti.CorrispondenteDTO
import it.finmatica.protocollo.corrispondenti.TipoSoggettoDTO
import it.finmatica.protocollo.integrazioni.anagrafe.SolWebService
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupSceltaAnagraficheSolWebViewModel {

    Window self
    def listaAnagraficheSolWeb

    HashMap<String,String> mappaAnagraficaSelected

    String cognomeCodFiscSearch
    String nomeSearch

    @WireVariable private SolWebService solWebService

    @NotifyChange("listaAnagraficheSolWeb")
    @Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("search") String search) {

        this.self = w
    }

    @NotifyChange(["listaAnagraficheSolWeb","mappaAnagraficaSelected"])
    @Command onCerca () {
        if (cognomeCodFiscSearch==null) cognomeCodFiscSearch=""
        if (nomeSearch==null) nomeSearch=""

        if (cognomeCodFiscSearch.trim().equals("") && nomeSearch.trim().equals("")) {
            Messagebox.show("Inserire dei valori significativi per la ricerca" , "Errore!" , Messagebox.OK,Messagebox.ERROR)
            return

        }

        def mappaRet=solWebService.ricerca(cognomeCodFiscSearch,nomeSearch)

        if (mappaRet["esito"].equals("KO"))  {
            Messagebox.show(mappaRet["errore"] , "Errore!" , Messagebox.OK,Messagebox.ERROR)
        }
        if (mappaRet["esito"].equals("OK"))  {
            listaAnagraficheSolWeb=mappaRet["listaAnagrafiche"]
            mappaAnagraficaSelected=null
        }
    }

    @Command onScegliAnagrafica() {
        if (mappaAnagraficaSelected==null) return

        Events.postEvent(Events.ON_CLOSE, self, buildCorrispondente(mappaAnagraficaSelected))
    }

    @Command onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }

    private CorrispondenteDTO buildCorrispondente(def mappaAnagrafica) {
        CorrispondenteDTO corrispondenteDTO = new CorrispondenteDTO()

        corrispondenteDTO.tipoSoggetto = new TipoSoggettoDTO(id: 9)
        corrispondenteDTO.denominazione = mappaAnagrafica["cognome"] + " " + mappaAnagrafica["nome"]
        corrispondenteDTO.nome = mappaAnagrafica["nome"]
        corrispondenteDTO.cognome = mappaAnagrafica["cognome"]
        corrispondenteDTO.indirizzo = mappaAnagrafica["indirizzo"]
        corrispondenteDTO.codiceFiscale = mappaAnagrafica["codiceFiscale"]
        corrispondenteDTO.comune = mappaAnagrafica["comune"]
        corrispondenteDTO.cap = mappaAnagrafica["cap"]
        corrispondenteDTO.provinciaSigla = mappaAnagrafica["sigla"]
        corrispondenteDTO.anagrafica = "G"

        return corrispondenteDTO
    }
}
