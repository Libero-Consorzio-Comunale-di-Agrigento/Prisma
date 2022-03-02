package it.finmatica.protocollo.zk.components.movimento

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezioneDTO
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezioneService
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloDTO
import it.finmatica.protocollo.zk.utils.PaginationUtils
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
class BandboxModalitaInvioRicezione extends KeyboardSelectableBandbox<ModalitaInvioRicezioneDTO> {

    @WireVariable
    ModalitaInvioRicezioneService modalitaInvioRicezioneService

    BandboxModalitaInvioRicezione() {
        super('components/bandboxModalita.zul')
    }

    @Override
    protected String getItemToString(ModalitaInvioRicezioneDTO modalitaInvioRicezioneDTO) {
        if (!modalitaInvioRicezioneDTO.codice) {
            return ''
        }
        return modalitaInvioRicezioneDTO.descrizione
    }

    @Override
    @CompileDynamic
    protected PagedList<ModalitaInvioRicezioneDTO> doSearch(String filtro, int offset, int max) {
        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)
        PagedResultList list = modalitaInvioRicezioneService.ricercaModalitaInvioRicezione(filtro?:"", offset, max)
        List<ModalitaInvioRicezioneDTO> listDTO = (List<ModalitaInvioRicezioneDTO>) list.toDTO()
        listDTO.add(0, new ModalitaInvioRicezioneDTO(id: -1, descrizione: "Nessun Tramite selezionato"))
        return new PagedList<ModalitaInvioRicezioneDTO>(listDTO, (int) list.totalCount + 1)

    }
}
