package it.finmatica.protocollo.zk.components.titolario

import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.zk.utils.PaginationUtils
import org.zkoss.zk.ui.annotation.ComponentAnnotation
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
@ComponentAnnotation(['classificazione: @ZKBIND(ACCESS=load)'])
class BandboxFascicolo extends KeyboardSelectableBandbox<FascicoloDTO> {

    @WireVariable
    private TitolarioService titolarioService

    @WireVariable
    private PrivilegioUtenteService privilegioUtenteService

    private ClassificazioneDTO classificazione
    private FascicoloDTO fascicolo
    private boolean fascicoliChiusi = false

    BandboxFascicolo() {
        super('/components/bandboxFascicolo.zul')
    }

    boolean isFascicoliChiusi() {
        return fascicoliChiusi
    }

    void setFascicoliChiusi(boolean fascicoliChiusi) {
        this.fascicoliChiusi = fascicoliChiusi
    }

    ClassificazioneDTO getClassificazione() {
        return classificazione
    }

    void setClassificazione(ClassificazioneDTO classificazione) {

        if (classificazione?.id == -1) {
            classificazione = null
            setDisabled(true)
        }

        // se cambia la classificazione devo resettare il fascicolo, ma solo se non sto settando la classificazione in fase
        // di inizializzazione
        if (this.classificazione && (this.classificazione.id != classificazione?.id)) {
            this.value = null
            setSelectedItem(null)
        }
        this.classificazione = classificazione
    }

    @Override
    protected String getItemToString(FascicoloDTO fascicoloDTO) {
        return fascicoloDTO.estremiFascicolo
    }

    @CompileDynamic
    @Override
    protected PagedList<FascicoloDTO> doSearch(String filtro, int offset, int max) {
        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)
        if (classificazione == null) {
            return new PagedList<FascicoloDTO>([], 0)
        }

        if (filtro == null || filtro.trim().length() == 0) {
            filtro = "%"
        }

        PagedResultList list = titolarioService.ricercaFascicoli(classificazione.id, filtro, offset, max, false)
        List<FascicoloDTO> listDTO = titolarioService.verificaCompetenzeLetturaFascicolo((List) list.toDTO("classificazione"))
        listDTO.add(0, new FascicoloDTO(id: -1, oggetto: "Nessun Fascicolo selezionato"))

        int total = (int) list.totalCount

        if(total != offset){
            total + 1
        }

        return new PagedList<FascicoloDTO>(listDTO, total)
    }
}

