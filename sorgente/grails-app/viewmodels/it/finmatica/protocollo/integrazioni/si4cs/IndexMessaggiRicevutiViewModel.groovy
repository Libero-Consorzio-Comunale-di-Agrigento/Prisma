package it.finmatica.protocollo.integrazioni.si4cs

import commons.menu.MenuItemMessaggioArrivo
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.commons.StrutturaOrganizzativaService
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.protocollo.competenze.PrivilegioUtenteService
import it.finmatica.protocollo.corrispondenti.Messaggio
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import it.finmatica.protocollo.documenti.mail.ConfigurazioniMailService
import it.finmatica.protocollo.documenti.mail.MailService
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.segnatura.interop.SegnaturaInteropService
import it.finmatica.protocollo.integrazioni.so4.So4Repository
import it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.NotificaRicezioneServiceImpl
import it.finmatica.protocollo.integrazioni.ws.si4cs.ricezione.SendMessaggioRicevuto
import it.finmatica.protocollo.so4.StrutturaOrganizzativaProtocolloService
import it.finmatica.segreteria.common.StringUtility
import it.finmatica.smartdoc.api.DocumentaleService
import it.finmatica.smartdoc.api.struct.Documento
import it.finmatica.smartdoc.api.struct.File
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.poi.util.StringUtil
import org.springframework.beans.factory.annotation.Autowired
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.Selectors
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.Wire
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Button
import org.zkoss.zul.Filedownload
import org.zkoss.zul.Grid
import org.zkoss.zul.Listbox
import org.zkoss.zul.Menupopup
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

import java.text.SimpleDateFormat

@VariableResolver(DelegatingVariableResolver)
class IndexMessaggiRicevutiViewModel {

    @WireVariable
    Si4CSService si4CSService
    @WireVariable
    DocumentaleService documentaleService
    @WireVariable
    MessaggiRicevutiService messaggiRicevutiService
    @WireVariable
    PrivilegioUtenteService privilegioUtenteService
    @WireVariable
    SpringSecurityService springSecurityService
    @WireVariable
    MessaggiRicevutiMenuItemService messaggiRicevutiMenuItemService
    @WireVariable
    ConfigurazioniMailService configurazioniMailService
    @WireVariable
    StrutturaOrganizzativaProtocolloService strutturaOrganizzativaProtocolloService
    @WireVariable
    So4Repository so4Repository
    @WireVariable
    ProtocolloService protocolloService

    // componenti
    Window self
    @Wire("#mpAllegati")
    Menupopup popupAllegati
    @Wire("#listaMessaggi")
    Listbox listbox

    // paginazione
    int activePage = 0
    int pageSize = 30
    int totalSize = 100

    //Campi di ricerca
    String destinatari
    String mittente
    boolean messaggiAuto

    def casella
    def esitoScelto = [descrizione: MessaggiRicevutiService._ITEM_TUTTI, valore: MessaggioRicevuto.Stato.TUTTI]
    String tipoPostaCertificato = MessaggiRicevutiService._ITEM_TUTTI
    String oggetto
    Date dal, al

    LinkedHashMap selected

    List<LinkedHashMap> lista = [], listaCompleta = []
    def tipiPosta = [MessaggiRicevutiService._ITEM_TUTTI, MessaggiRicevutiService._ITEM_TIPO_POSTA_CERTIFICATA, MessaggiRicevutiService._ITEM_TIPO_POSTA_ORDINARIA, MessaggiRicevutiService._ITEM_TIPO_POSTA_RICEVUTA]
    def listaCaselle = []
    def mappaEsiti = []
    def listaAllegati = []

    TipoCollegamento codiceTipoCollegamentoPec = TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROT_PEC)

    Map<String, Protocollo> idMessaggiConProtocollo = [:]

    @Init
    @NotifyChange("mappaEsiti")
    init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        dal = new Date()
        al = new Date()

        listaCaselle = configurazioniMailService.getListaCaselle()
        if (listaCaselle.contains(configurazioniMailService.csTagTutte)) {
            casella = configurazioniMailService.csTagTutte
        } else {
            if (listaCaselle.contains(configurazioniMailService.csTagNessuna)) {
                casella = configurazioniMailService.csTagNessuna
            } else {
                casella = listaCaselle?.get(0)
            }
        }

        BindUtils.postNotifyChange(null, null, this, "listaCaselle")

        for (stato in MessaggioRicevuto.Stato.values()) {
            mappaEsiti << [descrizione: stato.descrizione, valore: stato]
        }

        onFiltro()
    }

    @AfterCompose
    public void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
        Selectors.wireComponents(view, this, false);
    }

    @Command
    void onPaging() {
        int indexFrom, indexTo
        indexFrom = (activePage) * pageSize
        indexTo = ((activePage + 1) * pageSize)

        if (totalSize == 0) {
            lista = []
        } else {
            lista = listaCompleta.subList(Math.max(0, indexFrom), Math.min(totalSize, indexTo))
        }

        BindUtils.postNotifyChange(null, null, this, "lista")
        BindUtils.postNotifyChange(null, null, this, "totalSize")
        BindUtils.postNotifyChange(null, null, this, "activePage")
    }

    @Command
    void onFiltro() {
        if (StringUtility.nvl(ImpostazioniProtocollo.URL_SI4CS_SERVICE.valore, "").equals("")) {
            Clients.showNotification("Attenzione: non è stato specificato l'impostazione per il servizio di scarico dei messaggi (URL_SI4CS_SERVICE)", Clients.NOTIFICATION_TYPE_ERROR, null, "middle_center", 5000)
            return
        }

        if (casella.casella == "X") {
            return
        }

        lista = []
        String tipoPosta = ""
        if (tipoPostaCertificato.equals(MessaggiRicevutiService._ITEM_TUTTI)) {
            tipoPosta = "TUTTI"
        } else if (tipoPostaCertificato.equals(MessaggiRicevutiService._ITEM_TIPO_POSTA_CERTIFICATA)) {
            tipoPosta = "PEC"
        } else if (tipoPostaCertificato.equals(MessaggiRicevutiService._ITEM_TIPO_POSTA_ORDINARIA)) {
            tipoPosta = "NONPEC"
        } else {
            tipoPosta = "RICEVUTA"
        }

        /*listaCompleta = messaggiRicevutiRepository.getListMessaggi(casella.casella, mittente, oggetto, dal, al, tipoPosta, esitoScelto.valore,
                (esitoScelto.valore.descrizione == '(Tutti)') ? "Y" : "N")

        listaCompleta = filtraLista(listaCompleta)*/

        listaCompleta = messaggiRicevutiService.getListaMessaggi(casella.casella, mittente, oggetto, dal, al, tipoPosta, "" + esitoScelto.valore, springSecurityService.currentUser.utente, messaggiAuto)
        for (item in listaCompleta) {
            idMessaggiConProtocollo["" + item.messaggio] = Protocollo.findById(item.idProtocollo)
        }

        totalSize = listaCompleta.size()
        activePage = 0

        onPaging()
    }

    @NotifyChange("listaAllegati")
    @Command
    void onCaricaListaAllegatiMessaggio(@BindingParam("messaggio") messaggio, @ContextParam(ContextType.COMPONENT) Component component) {
        listaAllegati = []
        MessaggioRicevuto messaggioRicevuto = messaggiRicevutiService.getMessaggioRicevuto(Long.parseLong(messaggio.messaggio))
        for (file in messaggioRicevuto.fileDocumenti) {
            if (file.nome.trim().toLowerCase().equals(MessaggioRicevuto.MESSAGGIO_EML)) {
                continue
            }

            listaAllegati << [idAllegato: file.idFileEsterno, nomeAllegato: file.getNome()]
        }

        popupAllegati.open(component)
    }

    @Command
    void onDownloadFileAllegato(@BindingParam("fileAllegato") fileAllegato) {
        File file = new File()
        file.setId("" + fileAllegato.idAllegato)

        file = documentaleService.getFile(new Documento(), file)

        Filedownload.save(file.getInputStream(), file.getContentType(), file.getNome())
    }

    @Command
    void onModificaMessaggio(@BindingParam("messaggio") messaggio) {
        MessaggioRicevutoViewModel.apriPopup([idMessaggio: messaggio.idMessaggioAgspr]).addEventListener(Events.ON_CLOSE) {
            onFiltro()
        }
    }

    @Command
    void onApriProtocollo(@BindingParam("protocollo") protocollo) {
        ProtocolloViewModel.apriPopup(protocollo.id).addEventListener(Events.ON_CLOSE) {
            onFiltro()
        }
    }

    @Command
    void onRicercaAvanzata(@BindingParam("gridAvanzata") Grid grid, @BindingParam("buttonSwitch") Button buttonSwitch) {
        if (grid.visible) {
            grid.visible = false
            buttonSwitch.tooltip = "Ricerca Semplice"
            buttonSwitch.tooltiptext = "Ricerca Semplice"
            self.invalidate()
        } else {
            grid.visible = true
            buttonSwitch.tooltiptext = "Ricerca Avanzata"
            buttonSwitch.tooltip = "Ricerca Avanzata"
            self.invalidate()
        }
        BindUtils.postNotifyChange(null, null, this, "ricercaAvanzata")
    }

    Protocollo getProtocolloMessaggio(@BindingParam("messaggio") messaggio) {
        return idMessaggiConProtocollo[messaggio.messaggio]
    }

    @Command
    void onScarta() {
        Messagebox.show("Sei sicuro di voler scartare i record selezionati?", "Attenzione!", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (e.getName() == Messagebox.ON_OK) {
                scarta()
            }
        }
    }

    private void scarta() {
        List<LinkedHashMap> listaItemSelezionati = new ArrayList<LinkedHashMap>()
        if (listbox.getSelectedItems()?.size() > 0) {
            for (item in listbox.getSelectedItems()) {
                listaItemSelezionati.add(item.value)
            }
        } else if (selected != null) {
            listaItemSelezionati = [selected]
        }

        int scartati = 0
        for (item in listaItemSelezionati) {
            MessaggioRicevuto messaggioRicevuto = messaggiRicevutiService.getMessaggioRicevuto(Long.parseLong("" + item.messaggio))
            Map competenze = messaggiRicevutiService.getCompetenze(messaggioRicevuto, TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROT_PEC))
            if (!messaggiRicevutiMenuItemService.isAbilitatoMenu(messaggioRicevuto.toDTO("smistamenti.*"), MenuItemMessaggioArrivo.SCARTA_MESSAGGIO, competenze)) {
                messaggiRicevutiService.scartaMessaggio(messaggioRicevuto)
                scartati++
            }
        }

        if (listaItemSelezionati.size() > 0) {
            Messagebox.show("sono stati scartati n° " + scartati + " messaggi su tot. " + listaItemSelezionati.size() + " selezionati", "Messaggi Scartati", Messagebox.OK, Messagebox.INFORMATION)
        }

        onFiltro()
    }

    //Per ora commentata...è troppo lenta
    /*boolean isToolbarButtonScartaEnable() {
        return isToolbarButtonEnable(MenuItemMessaggioArrivo.SCARTA_MESSAGGIO)
    }

    boolean isToolbarButtonEnable(@BindingParam("voce") String voce) {
        List<LinkedHashMap> listaItemSelezionati = new ArrayList<LinkedHashMap>()
        if (listbox.getSelectedItems()?.size() > 0) {
            for (item in listbox.getSelectedItems()) {
                listaItemSelezionati.add(item.value)
            }
        } else if (selected != null) {
            listaItemSelezionati = [selected]
        }

        for (item in listaItemSelezionati) {
            MessaggioRicevutoDTO messaggioRicevutoDTO = messaggiRicevutiService.getMessaggioRicevuto(Long.parseLong("" + item.messaggio)).toDTO("smistamenti.*")
            Map competenze = messaggiRicevutiService.getCompetenze(messaggioRicevutoDTO.domainObject, TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROT_PEC))
            switch (voce) {
                case MenuItemMessaggioArrivo.SCARTA_MESSAGGIO:
                    if (!messaggiRicevutiMenuItemService.isAbilitatoMenu(messaggioRicevutoDTO, MenuItemMessaggioArrivo.SCARTA_MESSAGGIO, competenze)) {
                        return false
                    }
                    break
            }
        }

        return (listaItemSelezionati.size() > 0)
    }*/

    boolean isProtocolloMessaggio(@BindingParam("messaggio") messaggio) {
        return (getProtocolloMessaggio(messaggio) != null)
    }

    private def filtraLista(List<MessaggioRicevuto> lista) {
        def listaRet = []

        Map<String, String> privilegiUtente = new HashMap<String, String>()

        Ad4Utente utente = springSecurityService.currentUser

        privilegiUtente.put(PrivilegioUtente.VTOT, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.VTOT, utente) ? "Y" : "N")
        privilegiUtente.put(PrivilegioUtente.PMAILT, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILT, utente) ? "Y" : "N")
        privilegiUtente.put(PrivilegioUtente.PMAILI, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILI, utente) ? "Y" : "N")
        privilegiUtente.put(PrivilegioUtente.PMAILU, privilegioUtenteService.utenteHaPrivilegio(PrivilegioUtente.PMAILU, utente) ? "Y" : "N")
        List<So4IndirizzoTelematico> listaIndirizziEnte = strutturaOrganizzativaProtocolloService.getListaIndirizziEnte()
        List<So4UnitaPubb> listaUnita = []

        if (privilegiUtente[PrivilegioUtente.PMAILU] == "Y") {
            listaUnita = so4Repository.getListUnita(utente, PrivilegioUtente.PMAILU)
        }

        //Ciclo la lista da restituire per vedere lo statoMessaggio su AGP_MSG_RICEVUTI_DATI_PROT
        for (item in lista) {
            MessaggioRicevuto.Stato statoMessaggio
            MessaggioRicevuto messaggiRicevuto = item
            Classificazione classificazioneMessaggio

            statoMessaggio = messaggiRicevuto.statoMessaggio
            classificazioneMessaggio = messaggiRicevuto.classificazione
            idMessaggiConProtocollo["" + item.idMessaggioSi4Cs] = messaggiRicevutiService.getProtocolloCollegatoMessaggio(messaggiRicevuto)

            String descrizioneClassifica = ""
            if (classificazioneMessaggio != null) {
                descrizioneClassifica = classificazioneMessaggio.codice
            }

            boolean lettura
            lettura = messaggiRicevutiService.isCompetenzaLettura(messaggiRicevuto, idMessaggiConProtocollo["" + item.idMessaggioSi4Cs], privilegiUtente,
                    listaIndirizziEnte, codiceTipoCollegamentoPec, utente, listaUnita)
            if (!lettura) {
                continue
            }

            listaRet << [messaggio       : "" + item.idMessaggioSi4Cs,
                         oggetto         : item.oggetto,
                         mittenti        : item.mittente,
                         destinatari     : item.destinatari,
                         data            : new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(item.dataRicezione),
                         certificata     : (item.tipo == 'RICEVUTA') ? 'Ricevuta' : (item.tipo == 'PEC') ? 'Pec' : 'Ordinario',
                         allegatiPresenti: (item.fileDocumenti.size() > 0) ? "Y" : "N",
                         stato           : mappaEsiti.find { it.valore == statoMessaggio }.descrizione,
                         classificazione : descrizioneClassifica,
                         idMessaggioAgspr: item.id
            ]
        }

        return listaRet
    }
}
