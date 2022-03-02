package it.finmatica.protocollo.zk.components.iterdocumentale

import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.zk.KeyboardSelectableBandbox
import it.finmatica.gestionedocumenti.zk.PagedList
import it.finmatica.protocollo.preferenze.PreferenzeUtenteService
import it.finmatica.protocollo.so4.StrutturaOrganizzativaProtocolloService
import it.finmatica.protocollo.zk.utils.PaginationUtils
import it.finmatica.so4.login.So4SpringSecurityService
import groovy.transform.CompileDynamic
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.zkoss.zk.ui.event.EventListener
import org.zkoss.zk.ui.select.annotation.WireVariable

@CompileStatic
class BandboxUnitaIterDocumentale extends KeyboardSelectableBandbox<So4UnitaPubbDTO> implements EventListener {

    @WireVariable
    So4SpringSecurityService springSecurityService
    @WireVariable
    TipologiaSoggettoService tipologiaSoggettoService
    @WireVariable
    PreferenzeUtenteService preferenzeUtenteService
    @WireVariable
    StrutturaOrganizzativaService strutturaOrganizzativaService
    @WireVariable
    StrutturaOrganizzativaProtocolloService strutturaOrganizzativaProtocolloService


    BandboxUnitaIterDocumentale() {
        super("/components/bandboxUnitaIterDocumentale.zul")
    }

    @CompileDynamic
    @Override
    protected String getItemToString(So4UnitaPubbDTO so4UnitaPubb) {
        //Se ho abilitato l'impostazione UNITA_CONCAT_CODICE allora la descrizione è data dalla concatenazione codice + descrizione
        //Altrimenti ritorna la sola descrizione
        if(Impostazioni.UNITA_CONCAT_CODICE.abilitato) {
            String descrizioneUO = ""
            if( null != so4UnitaPubb?.codice) {
                descrizioneUO = descrizioneUO.concat(so4UnitaPubb.codice).concat(" - ")
            }
            if( null != so4UnitaPubb?.descrizione) {
                descrizioneUO = descrizioneUO.concat(so4UnitaPubb.descrizione)
            }
            return descrizioneUO
        } else {
            return so4UnitaPubb?.descrizione ?: ''
        }
    }

    @CompileDynamic
    @Override
    protected PagedList<So4UnitaPubbDTO> doSearch(String filtro, int offset, int max) {
        offset = PaginationUtils.resettaOffset(this.filtro, filtro, offset)
        List<So4UnitaPubbDTO> listaUo = strutturaOrganizzativaProtocolloService.ricercaUnitaIter(filtro, offset, max, springSecurityService.principal.id, springSecurityService.principal.ottica().codice)
        return new PagedList<So4UnitaPubbDTO>(listaUo.toDTO() as List<So4UnitaPubbDTO>, listaUo.size())
    }

 }
