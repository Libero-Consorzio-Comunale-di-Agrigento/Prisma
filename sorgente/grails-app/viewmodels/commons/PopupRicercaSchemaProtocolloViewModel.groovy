package commons

import it.finmatica.protocollo.documenti.viste.SchemaProtocolloCategoria
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.so4.login.detail.UnitaOrganizzativa
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupRicercaSchemaProtocolloViewModel {

    // servizi
    @WireVariable
    private SpringSecurityService springSecurityService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze
    @WireVariable
    private SchemaProtocolloService schemaProtocolloService


    // componenti
    Window self

    // dati
    String descrizione, codiceClassificazione, numeroFascicolo, oggettoFascicolo, oggetto
    String codice, annoFascicolo

    List<SchemaProtocolloDTO> listaTipiDocumento = new ArrayList<SchemaProtocolloDTO>()
    SchemaProtocolloDTO selected
    ProtocolloDTO protocollo

    @Init
    void init(
            @ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("protocollo") ProtocolloDTO protocollo) {
        this.self = w
        this.protocollo = protocollo
    }

    @NotifyChange(["listaTipiDocumento"])
    @Command
    void onRicerca() {
        boolean mtot = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.MODIFICA_TUTTI)
        List<String> codiciUo = new ArrayList<>()

        if (!mtot) {
            for (UnitaOrganizzativa u : springSecurityService.principal.uo()) {
                codiciUo.add(So4UnitaPubb.getUnita(u.id, u.ottica, u.dal).get()?.codice)
            }
        }

        List<SchemaProtocollo> listaSchemiProtocollo = schemaProtocolloService.ricercaAvanzataSchemiProtocollo(codice, descrizione, oggetto, protocollo.movimento, protocollo?.tipoProtocollo?.domainObject, mtot, codiciUo,
                                                                                                                numeroFascicolo, annoFascicolo, oggettoFascicolo,
                                                                                                                codiceClassificazione,true)

        listaTipiDocumento = listaSchemiProtocollo.sort {
            it.descrizione
        }.toDTO(["classificazione", "fascicolo", "tipoRegistro"])
    }

    @Command
    void onClickDetail(SchemaProtocolloDTO schemaProtocolloDto) {
        Window w = Executions.createComponents("/dizionari/schemaProtocolloDettaglio.zul", self, [tipo: "lettura", id: schemaProtocolloDto.id])
        w.doModal()
    }

    @Command
    void onSalvaTipoDocumento() {
        Events.postEvent(Events.ON_CLOSE, self, selected)
    }

    @Command
    void onChiudi() {
        Events.postEvent(Events.ON_CLOSE, self, null)
    }
}
