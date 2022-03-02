package it.finmatica.protocollo.zk.components.ufficioCompetente

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.dizionari.AccessoCivicoService
import it.finmatica.protocollo.zk.utils.PaginationUtils
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
class BandboxUfficioCompetente extends KeyboardSelectableBandbox<So4UnitaPubbDTO> {

    @WireVariable
    private AccessoCivicoService accessoCivicoService

    BandboxUfficioCompetente() {
        super('/components/bandboxUfficioCompetente.zul')
    }

    @Override
    protected String getItemToString(So4UnitaPubbDTO ufficioCompetenteDTO) {
        return ufficioCompetenteDTO.codice != null ? ufficioCompetenteDTO.getDescrizione() : ""
    }

    @CompileDynamic
    @Override
    protected PagedList<So4UnitaPubbDTO> doSearch(String filtro, int offset, int max) {
        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)
        PagedResultList list = accessoCivicoService.ricercaUfficioCompetente(filtro?:"", offset, max)
        List listDTO = (List) list.toDTO()
        listDTO.add(0, new So4UnitaPubbDTO(progr: -1, descrizione: "Nessun ufficio competente selezionato"))
        return new PagedList<So4UnitaPubbDTO>(listDTO, (int) list.totalCount + 1)
    }

}
