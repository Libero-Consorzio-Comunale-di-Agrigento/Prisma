package it.finmatica.protocollo.zk.components.titolario

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.ClassificazioneDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.zk.utils.PaginationUtils
import org.springframework.beans.factory.annotation.Autowired
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
class BandboxClassificazioneInsFascicolo extends KeyboardSelectableBandbox<ClassificazioneDTO> {

    @WireVariable
    private TitolarioService titolarioService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService

    private boolean classificheChiuse = false
    private boolean ricercaSoloClassificheAperte = true

    BandboxClassificazioneInsFascicolo() {
        super('/components/bandboxClassificazioneInsFascicolo.zul')
    }

    boolean isClassificheChiuse() {
        return classificheChiuse
    }

    void setClassificheChiuse(boolean classificheChiuse) {
        this.classificheChiuse = classificheChiuse
    }

    @Override
    protected String getItemToString(ClassificazioneDTO classificazioneDTO) {
        return classificazioneDTO.getNome()
    }

    @CompileDynamic
    @Override
    protected PagedList<ClassificazioneDTO> doSearch(String filtro, int offset, int max) {

        if (privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.ICC) || privilegioUtenteService.utenteHaPrivilegioGenerico(PrivilegioUtente.ICCTOT)) {
            ricercaSoloClassificheAperte = false
        }

        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)
        PagedResultList list = titolarioService.ricercaClassificazioni(filtro?:"", offset, max, ricercaSoloClassificheAperte)
        List listDTO = (List) list.toDTO()
        listDTO.add(0, new ClassificazioneDTO(id: -1, descrizione: "Nessuna Classificazione selezionata"))
        return new PagedList<ClassificazioneDTO>(listDTO, (int) list.totalCount + 1)
    }

    @Override
    protected Map<String, Object> getBandboxParams() {
        Map<String, Object> map = [:]
        map.classificheChiuse = classificheChiuse
        return map
    }
}
