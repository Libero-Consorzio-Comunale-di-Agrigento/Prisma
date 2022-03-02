package it.finmatica.protocollo.zk.components.documenti

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.zk.utils.PaginationUtils
import org.zkoss.zk.ui.annotation.ComponentAnnotation

@CompileStatic
@ComponentAnnotation(['tipoDocumento:@ZKBIND(ACCESS=load)', 'movimento:@ZKBIND(ACCESS=load)'])
class BandboxSchemaProtocolloIntegrazioni extends BandboxSchemaProtocollo<SchemaProtocolloDTO> {

    BandboxSchemaProtocolloIntegrazioni() {
        super()
    }

    String getMovimento() {
        return movimento
    }

    void setMovimento(String movimento) {
        this.movimento = movimento
    }

    @CompileDynamic
    private void init() {

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

        List<SchemaProtocollo> listaSchemiProtocollo = schemaProtocolloService.ricerca(filtro?:"", movimento)

        List list = (List) listaSchemiProtocollo.sort {
            it.descrizione
        }

        list.add(0, new SchemaProtocolloDTO(id: -1, descrizione: "Nessun Tipo di Documento selezionato"))

        return calcolaPaginazione(list, offset, max)

    }
}
