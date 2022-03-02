package commons

import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.titolario.TitolarioService
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.apache.commons.lang.StringUtils
import org.hibernate.FetchMode
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupRicercaFascicoloPerSchemaProtocolloViewModel {

    @WireVariable
    TitolarioService titolarioService

    def springSecurityService

    Window self

    Integer anno
    Integer numero
    String  oggetto
    String  note
    String  codice

    boolean inserimentoInFascicoliChiusi = false

    List<FascicoloDTO> listaFascicoli = new ArrayList<FascicoloDTO>()
    FascicoloDTO selected

    List<So4UnitaPubbDTO> listaUnita = new ArrayList<So4UnitaPubbDTO>()
    So4UnitaPubbDTO unita = null

    @Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("schemaProtocollo") SchemaProtocolloDTO schemaProtocollo, @ExecutionArgParam("inserimentoInFascicoliChiusi") Boolean inserimentoInFascicoliChiusi) {

        this.self = w

        this.inserimentoInFascicoliChiusi = inserimentoInFascicoliChiusi

        listaUnita = So4UnitaPubb.createCriteria().list() {

            isNull("al")
            order("descrizione")
            eq("ottica.codice", springSecurityService.principal.ottica().codice)
        }.toDTO()

        listaUnita.add(0, new So4UnitaPubbDTO(codice: "", descrizione: ""))

        oggetto = schemaProtocollo.fascicolo?.oggetto
        numero  = schemaProtocollo.fascicolo?.numero?.toInteger()
        note    = schemaProtocollo.fascicolo?.note
        anno    = schemaProtocollo.fascicolo?.anno
        codice  = schemaProtocollo.classificazione?.codice
    }

    @NotifyChange(["listaFascicoli"])
    @Command onRicerca() {

        List<Fascicolo> fascicoli = new ArrayList<Fascicolo>()

        fascicoli = Fascicolo.createCriteria().list() {

            if (!StringUtils.isEmpty(numero)) {
                eq("numero", numero)
            }
            if (!StringUtils.isEmpty(oggetto)) {
                like("oggetto", "%" +oggetto + "%")
            }
            if (!StringUtils.isEmpty(note)) {
                ilike("note", "%" + note + "%")
            }
            if (anno > 0) {
                eq("anno", anno)
            }

            fetchMode("classificazione", FetchMode.JOIN)

            classificazione {
                and {
                    if (!StringUtils.isEmpty(codice)) {
                        like("codice", codice + "%")
                    }
                }
            }

            fetchMode("unitaCompetenza", FetchMode.JOIN)

            unitaCompetenza {
                if(unita != null && unita.codice != "") {
                    eq("progr", unita.progr)
                }
            }

            order("anno", "desc")
            order("numeroOrd", "asc")

            if(!inserimentoInFascicoliChiusi){

                Date d = new Date()
                le ("dataApertura", d)
                or {ge ("dataChiusura", d)
                    isNull ("dataChiusura")
                }
            }

        }

        listaFascicoli =  titolarioService.verificaCompetenzeLetturaFascicolo(fascicoli.toDTO("classificazione"))

    }

    @Command onSalvaFascicolo () {
        Events.postEvent(Events.ON_CLOSE, self, selected)
    }

    @Command onChiudi () {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
