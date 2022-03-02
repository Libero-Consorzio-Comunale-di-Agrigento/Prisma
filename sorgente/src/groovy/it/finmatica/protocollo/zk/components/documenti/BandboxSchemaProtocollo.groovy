package it.finmatica.protocollo.zk.components.documenti

import it.finmatica.ad4.security.SpringSecurityService
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloCategoria
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.zk.utils.PaginationUtils
import it.finmatica.so4.login.So4UserDetail
import it.finmatica.so4.login.detail.UnitaOrganizzativa
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
@ComponentAnnotation(['tipoDocumento:@ZKBIND(ACCESS=load)', 'movimento:@ZKBIND(ACCESS=load)'])
class BandboxSchemaProtocollo<T> extends KeyboardSelectableBandbox<SchemaProtocolloDTO> {

    @WireVariable
    private SchemaProtocolloService schemaProtocolloService

    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze

    @WireVariable
    private SpringSecurityService springSecurityService

    private boolean mtot = false
    private List<String> codiciUo = []
    private boolean initialized = false
    private String movimento

    private TipoProtocolloDTO tipoProtocollo

    BandboxSchemaProtocollo() {
        super('/components/bandboxSchemiProtocollo.zul')
    }

    TipoProtocolloDTO getTipoProtocollo() {
        return tipoProtocollo
    }

    String getMovimento() {
        return movimento
    }

    void setMovimento(String movimento) {
        this.movimento = movimento
    }

    void setTipoProtocollo(TipoProtocolloDTO tipoProtocollo) {
        this.tipoProtocollo = tipoProtocollo
    }

    @CompileDynamic
    private void init() {
        if (initialized || gestoreCompetenze == null || springSecurityService == null) {
            return
        }

        initialized = true
        mtot = gestoreCompetenze.controllaPrivilegio(PrivilegioUtente.MODIFICA_TUTTI)
        if (!mtot) {
            for (UnitaOrganizzativa u : ((So4UserDetail) springSecurityService.principal).uo()) {
                codiciUo.add(So4UnitaPubb.getUnita(u.id, u.ottica, u.dal).get().codice)
            }
        }
    }

    @Override
    protected String getItemToString(SchemaProtocolloDTO o) {
        if (!o.codice) {
            return ''
        }
        return "${o.codice} - ${o.descrizione}"
    }

    @CompileDynamic
    @Override
    protected PagedList<SchemaProtocolloDTO> doSearch(String filtro, int offset, int max) {
        //se ho attivato il filtro devo resettare l'offset altrimenti se la ricerca parte da una pagina successiva alla prima il risultato
        //non viene mostrato
        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)

        init()

        List<SchemaProtocollo> listaSchemiProtocollo = schemaProtocolloService.ricercaSchemaProtocollo(filtro?:"", movimento, tipoProtocollo.domainObject, mtot, codiciUo,true)

        List list = (List) listaSchemiProtocollo.sort {
            it.descrizione
        }.toDTO("tipoRegistro")

        list.add(0, new SchemaProtocolloDTO(id: -1, descrizione: "Nessun Tipo di Documento selezionato"))

        return calcolaPaginazione(list, offset, max)

    }

    private PagedList calcolaPaginazione(List list, int offset, int max) {
        int totalCount = list.size()
        if (totalCount < offset) {
            offset = 0
        }
        if (totalCount > 0 && totalCount > max) {
            int endIndex = offset + max
            if (endIndex >= list.size()) {
                endIndex = list.size()
            }
            list = list.subList(offset, endIndex)
        }

        return new PagedList(list, totalCount)
    }
}
