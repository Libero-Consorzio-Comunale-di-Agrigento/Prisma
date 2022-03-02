package it.finmatica.protocollo.zk.components.utenti

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.so4.StrutturaOrganizzativaProtocolloService
import it.finmatica.protocollo.zk.utils.PaginationUtils
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubbDTO
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
class BandboxUtenteProtocollo extends KeyboardSelectableBandbox<So4ComponentePubbDTO> {

    @WireVariable
    private StrutturaOrganizzativaProtocolloService strutturaOrganizzativaProtocolloService

    BandboxUtenteProtocollo() {
        super('/components/bandboxUtenteProtocollo.zul')
    }

    @Override
    protected String getItemToString(So4ComponentePubbDTO componentePubbDTO) {
        return componentePubbDTO.nominativoSoggetto
    }

    @CompileDynamic
    @Override
    protected PagedList<So4ComponentePubbDTO> doSearch(String filtro, int offset, int max) {
        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)
        List<So4ComponentePubb> listaUtenti = strutturaOrganizzativaProtocolloService.ricercaComponentiProtocollo(filtro, offset, max)
        return new PagedList<So4ComponentePubbDTO>(listaUtenti.toDTO() as List<So4ComponentePubbDTO>, strutturaOrganizzativaProtocolloService.countComponentiProtocollo(filtro))
    }
}