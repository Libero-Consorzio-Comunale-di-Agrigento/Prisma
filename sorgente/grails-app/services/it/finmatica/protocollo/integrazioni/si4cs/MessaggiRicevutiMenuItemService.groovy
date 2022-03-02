package it.finmatica.protocollo.integrazioni.si4cs

import commons.PopupRifiutaSmistamentoViewModel
import commons.PopupScegliUnitaCaricoEseguiViewModel
import commons.menu.MenuItemMessaggioArrivo
import commons.menu.MenuItemProtocollo
import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.menu.MenuItemProtocolloService
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events

@Slf4j
@Service
@Transactional
class MessaggiRicevutiMenuItemService {

    @Autowired
    SmistamentoService smistamentoService
    @Autowired
    PrivilegioUtenteService privilegioUtenteService
    @Autowired
    GestioneDocumentiSpringSecurityService springSecurityService
    @Autowired
    MenuItemProtocolloService menuItemProtocolloService

    @Transactional(readOnly = true)
    List<String> getVociVisibiliMenu(MessaggioRicevutoDTO messaggioRicevutoDto, Map competenze) {
        List<String> abilitazioniMenuList = new ArrayList<String>()

        for (menuItem in MenuItemMessaggioArrivo.menuItems) {
            if (isAbilitatoMenu(messaggioRicevutoDto, menuItem.codice, competenze)) {
                abilitazioniMenuList.add(menuItem.codice)
            }
        }

        return abilitazioniMenuList
    }

    @Transactional(readOnly = true)
    public boolean isAbilitatoMenu(MessaggioRicevutoDTO messaggioRicevutoDto, String voceMenu, Map competenze) {
        boolean isAbilitato
        switch (voceMenu) {
            case MenuItemMessaggioArrivo.CREA_PROTOCOLLO: isAbilitato = isAbilitatoCreaProtocollo(messaggioRicevutoDto, competenze); break;
            case MenuItemMessaggioArrivo.SCARTA_MESSAGGIO: isAbilitato = isAbilitatoScartaMessaggio(messaggioRicevutoDto, competenze); break;
            case MenuItemMessaggioArrivo.CREA_PG_PARTENZA: isAbilitato = isAbilitatoCreaPgPartenza(messaggioRicevutoDto, competenze); break;
            case MenuItemProtocollo.CARICO: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCarico(messaggioRicevutoDto.domainObject); break;
            case MenuItemProtocollo.APRI_CARICO_ASSEGNA: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCaricoEdAssegna(messaggioRicevutoDto.domainObject); break;
            case MenuItemProtocollo.APRI_CARICO_FLEX: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCaricoEdInoltra(messaggioRicevutoDto.domainObject); break;
            case MenuItemProtocollo.CARICO_ESEGUI: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCaricoEdEsegui(messaggioRicevutoDto.domainObject, false); break;
            case MenuItemProtocollo.APRI_ESEGUI_FLEX: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isPrendiInCaricoEdEsegui(messaggioRicevutoDto.domainObject, true); break;
            case MenuItemProtocollo.RIPUDIO: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isRifiutaSmistamento(messaggioRicevutoDto.domainObject); break;
            case MenuItemProtocollo.FATTO: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : (competenze.modifica) ? menuItemProtocolloService.isEsegui(messaggioRicevutoDto.domainObject) : false; break;
            case MenuItemProtocollo.FATTO_IN_VISUALIZZA: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : (!competenze.modifica) ? menuItemProtocolloService.isEsegui(messaggioRicevutoDto.domainObject) : false; break;
            case MenuItemProtocollo.APRI_ASSEGNA: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isAssegna(messaggioRicevutoDto.domainObject); break;
            case MenuItemProtocollo.APRI_INOLTRA_FLEX: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : menuItemProtocolloService.isInoltra(messaggioRicevutoDto.domainObject); break;
            case MenuItemMessaggioArrivo.SCARICA_EML: isAbilitato = (messaggioRicevutoDto.domainObject == null) ? false : isAbilitatoScaricaEml(messaggioRicevutoDto); break;

            default: isAbilitato = false;
        }

        return isAbilitato
    }

    private boolean isAbilitatoCreaProtocollo(MessaggioRicevutoDTO messaggioRicevutoDto, Map competenze) {
        return ((messaggioRicevutoDto.statoMessaggio == MessaggioRicevuto.Stato.SCARTATO ||
                messaggioRicevutoDto.statoMessaggio == MessaggioRicevuto.Stato.DA_GESTIRE ||
                messaggioRicevutoDto.statoMessaggio == MessaggioRicevuto.Stato.NON_PROTOCOLLATO) &&
                (!messaggioRicevutoDto.tipo?.startsWith("RICEVUTA")) &&
                competenze.modifica)
    }

    private boolean isAbilitatoScartaMessaggio(MessaggioRicevutoDTO messaggioRicevutoDto, Map competenze) {
        return ((messaggioRicevutoDto.statoMessaggio == MessaggioRicevuto.Stato.DA_GESTIRE ||
                messaggioRicevutoDto.statoMessaggio == MessaggioRicevuto.Stato.NON_PROTOCOLLATO) &&
                (messaggioRicevutoDto?.smistamenti == null || messaggioRicevutoDto.smistamenti?.size() == 0) &&
                competenze.modifica)
    }

    private boolean isAbilitatoScaricaEml(MessaggioRicevutoDTO messaggioRicevutoDto) {
        return (messaggioRicevutoDto.fileDocumenti?.find {it.nome.toLowerCase() == MessaggioRicevuto.MESSAGGIO_EML})
    }

    private boolean isAbilitatoCreaPgPartenza(MessaggioRicevutoDTO messaggioRicevutoDto, Map competenze) {
        return (isAbilitatoCreaProtocollo(messaggioRicevutoDto, competenze) &&
                ImpostazioniProtocollo.CREA_PG_IN_PARTENZA_DA_MAIL.valore == "Y")
    }

    void onPrendiIncarico(MessaggioRicevutoDTO messaggioRicevutoDto, MenuItemMessaggioArrivo menuItemMessaggioArrivo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(messaggioRicevutoDto, MenuItemProtocollo.CARICO).addEventListener(Events.ON_CLOSE) {
            menuItemMessaggioArrivo.fireOnAggiornaMaschera()
        }
    }

    void onPrendiIncaricoEsegui(MessaggioRicevutoDTO messaggioRicevutoDto, MenuItemMessaggioArrivo menuItemMessaggioArrivo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(messaggioRicevutoDto, MenuItemProtocollo.CARICO_ESEGUI).addEventListener(Events.ON_CLOSE) {
            menuItemMessaggioArrivo.fireOnAggiornaMaschera()
        }
    }

    void onRifiutaSmistamento(MessaggioRicevutoDTO messaggioRicevutoDto, MenuItemMessaggioArrivo menuItemMessaggioArrivo) {
        PopupRifiutaSmistamentoViewModel.apriPopup(messaggioRicevutoDto).addEventListener(Events.ON_CLOSE) { Event event ->
            menuItemMessaggioArrivo.fireOnAggiornaMaschera()
        }
    }

    void onEsegui(MessaggioRicevutoDTO messaggioRicevutoDto, MenuItemMessaggioArrivo menuItemMessaggioArrivo) {
        PopupScegliUnitaCaricoEseguiViewModel.apriPopup(messaggioRicevutoDto, MenuItemProtocollo.FATTO).addEventListener(Events.ON_CLOSE) {
            menuItemMessaggioArrivo.fireOnAggiornaMaschera()
        }
    }
}
