package it.finmatica.protocollo.zk.components.collegamenti

import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.gorm.criteria.PagedResultList
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.dizionari.TipoRegistroService
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.zk.utils.PaginationUtils
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
class BandboxRegistro extends KeyboardSelectableBandbox<TipoRegistroDTO> {

    @WireVariable
    private TipoRegistroService tipoRegistroService

    BandboxRegistro() {
        super('/components/bandboxTipoRegistro.zul')
    }

    @Override
    protected String getItemToString(TipoRegistroDTO tipoRegistroDTO) {
        return tipoRegistroDTO.commento
    }

    @CompileDynamic
    @Override
    protected PagedList<TipoRegistroDTO> doSearch(String filtro, int offset, int max) {
        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)
        PagedResultList list = tipoRegistroService.ricercaTipoRegistro(filtro?:"", offset, max)
        List<TipoRegistroDTO> listDTO = (List<TipoRegistroDTO>) list.toDTO()
        TipoRegistroDTO pick = listDTO.find { it.codice == ImpostazioniProtocollo.TIPO_REGISTRO.getValore()}
        List<TipoRegistroDTO>  newList = listDTO.minus(pick)
        newList.add(0, pick)
        return new PagedList<TipoRegistroDTO>(newList, (int) list.totalCount + 1)
    }

    @Override
    protected Map<String, Object> getBandboxParams() {
        Map<String, Object> map = [:]
        return map
    }
}
