package it.finmatica.protocollo.menu

import commons.PopupRifiutaSmistamentoViewModel
import commons.PopupScegliUnitaCaricoEseguiViewModel
import commons.menu.MenuItemFascicolo
import commons.menu.MenuItemProtocollo
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.dizionari.AbilitazioneSmistamentoService
import it.finmatica.protocollo.dizionari.AccessoCivicoService
import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematicoRepository
import it.finmatica.protocollo.documenti.viste.SchemaProtocolloService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloPkgService
import it.finmatica.protocollo.integrazioni.gdm.ProtocolloUtilService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events

@Transactional
@Service
public class MenuItemFasicolocoService {

    @Autowired
    ProtocolloPkgService protocolloPkgService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    GestioneDocumentiSpringSecurityService springSecurityService
    @Autowired
    ProtocolloUtilService protocolloUtilService
    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    ProtocolloService protocolloService
    @Autowired
    AbilitazioneSmistamentoService abilitazioneSmistamentoService
    @Autowired
    SchemaProtocolloService schemaProtocolloService
    @Autowired
    StrutturaOrganizzativaService strutturaOrganizzativaService
    @Autowired
    ProtocolloRiferimentoTelematicoRepository protocolloRiferimentoTelematicoRepository
    @Autowired
    AccessoCivicoService accessoCivicoService
    @Autowired
    MenuItemProtocolloService menuItemProtocolloService

    @Transactional(readOnly = true)
    List<String> getVociVisibiliMenu(FascicoloDTO fascicoloDTO, Map competenze, boolean onlyVisualizzazione) {
        List<String> abilitazioniMenuList = new ArrayList<String>()

        for (menuItem in MenuItemFascicolo.menuItems) {
            if (isAbilitatoMenu(fascicoloDTO, menuItem.codice, competenze, onlyVisualizzazione)) {
                abilitazioniMenuList.add(menuItem.codice)
            }
        }

        return abilitazioniMenuList
    }

    @Transactional(readOnly = true)
    boolean isAbilitatoMenu(FascicoloDTO fascicoloDTO, String voceMenu, Map competenze, boolean  onlyVisualizzazione) {
        boolean isAbilitato

        switch (voceMenu) {
            case MenuItemFascicolo.NUOVO_FASCICOLO: isAbilitato = (onlyVisualizzazione == false && fascicoloDTO.id != -1) ? true :false ; break;
            case MenuItemFascicolo.NUOVO_SUB_FASCICOLO: isAbilitato = (onlyVisualizzazione == false && fascicoloDTO.id != -1) ? true :false ; break;
            case MenuItemFascicolo.DUPLICA_FASCICOLO: isAbilitato = (onlyVisualizzazione == false && fascicoloDTO.id != -1) ? true :false ; break;
            case MenuItemFascicolo.DOCUMENTI_IN_FASCICOLO: isAbilitato = true; break;
            case MenuItemFascicolo.STAMPA_COPERTINA: isAbilitato = true; break;
            case MenuItemFascicolo.STAMPA_DOCUMENTI: isAbilitato = true; break;

            case MenuItemProtocollo.CARICO: isAbilitato = (fascicoloDTO.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCarico(fascicoloDTO.domainObject); break;
            case MenuItemProtocollo.APRI_CARICO_ASSEGNA: isAbilitato = (fascicoloDTO.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCaricoEdAssegna(fascicoloDTO.domainObject); break;
            case MenuItemProtocollo.APRI_CARICO_FLEX: isAbilitato = (fascicoloDTO.domainObject == null) ? false : isPrendiInCaricoEdInoltra(fascicoloDTO.domainObject); break;
            case MenuItemProtocollo.CARICO_ESEGUI: isAbilitato = (fascicoloDTO.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCaricoEdEsegui(fascicoloDTO.domainObject, false); break;
            case MenuItemProtocollo.APRI_ESEGUI_FLEX: isAbilitato = (fascicoloDTO.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCaricoEdEsegui(fascicoloDTO.domainObject, true); break;
            case MenuItemProtocollo.RIPUDIO: isAbilitato = (fascicoloDTO.domainObject == null) ? false : isRifiutaSmistamento(fascicoloDTO.domainObject); break;
            case MenuItemProtocollo.FATTO: isAbilitato = (fascicoloDTO.domainObject == null) ? false : (competenze.modifica) ? menuItemProtocolloService.isEsegui(fascicoloDTO.domainObject) : false; break;
            case MenuItemProtocollo.FATTO_IN_VISUALIZZA: isAbilitato = (fascicoloDTO.domainObject == null) ? false : (!competenze.modifica) ? menuItemProtocolloService.isEsegui(fascicoloDTO.domainObject) : false; break;
            case MenuItemProtocollo.APRI_ASSEGNA: isAbilitato = (fascicoloDTO.domainObject == null) ? false : menuItemProtocolloService.isAssegna(fascicoloDTO.domainObject); break;
            case MenuItemProtocollo.APRI_INOLTRA_FLEX: isAbilitato = (fascicoloDTO.domainObject == null) ? false : isInoltra(fascicoloDTO.domainObject); break;

            default: isAbilitato = false;
        }

        return isAbilitato
    }

    void onPrendiIncarico(FascicoloDTO fascicoloDTO, MenuItemFascicolo menuItemFascicolo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(fascicoloDTO, MenuItemProtocollo.CARICO).addEventListener(Events.ON_CLOSE) {
            menuItemFascicolo.fireOnAggiornaMaschera()
        }
    }

    void onPrendiIncaricoEsegui(FascicoloDTO fascicoloDTO, MenuItemFascicolo menuItemFascicolo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(fascicoloDTO, MenuItemProtocollo.CARICO_ESEGUI).addEventListener(Events.ON_CLOSE) {
            menuItemFascicolo.fireOnAggiornaMaschera()
        }
    }

    void onRifiutaSmistamento(FascicoloDTO fascicoloDTO, MenuItemFascicolo menuItemFascicolo) {
        PopupRifiutaSmistamentoViewModel.apriPopup(fascicoloDTO).addEventListener(Events.ON_CLOSE) { Event event ->
            menuItemFascicolo.fireOnAggiornaMaschera()
        }
    }

    void onEsegui(FascicoloDTO fascicoloDTO, MenuItemFascicolo menuItemFascicolo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(fascicoloDTO, MenuItemProtocollo.FATTO).addEventListener(Events.ON_CLOSE) {
            menuItemFascicolo.fireOnAggiornaMaschera()
        }
    }

    @Transactional(readOnly = true)
    public isRifiutaSmistamento(ISmistabile protocollo) {

        if ((!menuItemProtocolloService.isPrendiInCaricoIgnorandoTipo(protocollo))) {
            return false
        } else {
            true
        }
    }

    @Transactional(readOnly = true)
    public isInoltra(ISmistabile smistabile) {
        boolean abilitazione
        String privilegio, privilegioIsmiTot

        if (smistabile.idDocumentoEsterno == null) {
            return false
        }

        if (smistabile.isAnnullamentoInCorso()) {
            return false
        }

        List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile, [Smistamento.IN_CARICO, Smistamento.ESEGUITO])

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return false
        }

        if (!controllaPrivilegiSuUnita(smistabile, listaSmistamentiInCaricoPerUnitaAppartenenza)) {
            return false
        }

        privilegioIsmiTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, springSecurityService.currentUser)

        for (smistamento in listaSmistamentiInCaricoPerUnitaAppartenenza) {
            if ((smistamento.utenteAssegnatario == null || smistamento.utenteAssegnatario?.id == springSecurityService.currentUser.id) &&
                    (privilegioIsmiTot || privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamento, PrivilegioUtente.VISUALIZZA_COMPONENTI_UNITA)) &&
                    (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                            smistamento.statoSmistamento, "INOLTRA").size() > 0)
            ) {

                abilitazione = true
                break;
            }
        }

        return abilitazione
    }

    @Transactional(readOnly = true)
    public isPrendiInCaricoEdInoltra(ISmistabile smistabile) {

        if (!menuItemProtocolloService.isPrendiInCaricoIgnorandoTipo(smistabile)) {
            return false
        }

        boolean abilitazione, privilegioIsmiTot

        privilegioIsmiTot = privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.SMISTAMENTO_CREA_SEMPRE, springSecurityService.currentUser)

        List<Smistamento> listaSmistamentiDaRiceverePerUnitaAppartenenza = smistamentoService.getSmistamentiPerUnitaAppartenenza(smistabile,
                [Smistamento.DA_RICEVERE])

        for (smistamento in listaSmistamentiDaRiceverePerUnitaAppartenenza) {
            if (smistamento.getUnitaSmistamento().al == null &&
                    (privilegioIsmiTot || privilegioUtenteService.utenteHaprivilegioPerUfficioSmistamento(smistamento, PrivilegioUtente.SMISTAMENTO_CREA)) &&
                    (abilitazioneSmistamentoService.getAbilitazioneSmistamento(smistamento.tipoSmistamento,
                            smistamento.statoSmistamento, "INOLTRA").size() > 0)) {

                return true
            }
        }

        return abilitazione
    }

    private boolean controllaPrivilegiSuUnita(ISmistabile smistabile, List<Smistamento> listaSmistamentiInCaricoPerUnitaAppartenenza) {

        if (listaSmistamentiInCaricoPerUnitaAppartenenza.size() == 0) {
            return false
        }

        String privilegio
        if (smistabile.riservato) {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA_RISERVATO
        } else {
            privilegio = PrivilegioUtente.SMISTAMENTO_VISUALIZZA
        }

        int numeroDiUnitaConPrivilegio = 0

        for (Smistamento s : listaSmistamentiInCaricoPerUnitaAppartenenza)
            if (privilegioUtenteService.utenteHaPrivilegioPerUnita(privilegio, s.unitaSmistamento.codice, springSecurityService.currentUser)) {
                numeroDiUnitaConPrivilegio = numeroDiUnitaConPrivilegio + 1
            }

        return (numeroDiUnitaConPrivilegio > 0)
    }
}