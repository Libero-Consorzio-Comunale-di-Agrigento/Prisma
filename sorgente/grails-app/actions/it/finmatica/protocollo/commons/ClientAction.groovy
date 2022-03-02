package it.finmatica.protocollo.commons

import commons.PopupCompetenzeEspliciteViewModel
import it.finmatica.gestionedocumenti.commons.AbstractViewModel
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.zkutils.SuccessHandler
import it.finmatica.gestioneiter.IDocumentoIterabile
import it.finmatica.gestioneiter.annotations.Action
import it.finmatica.gestioneiter.annotations.Action.TipoAzione
import it.finmatica.gestioneiter.motore.WkfIterService
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import org.springframework.beans.factory.annotation.Autowired
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zul.Messagebox

/**
 * Contiene le azioni client comuni a tutti i documenti
 */
@Action
class ClientAction {

    @Autowired
    WkfIterService wkfIterService
    @Autowired
    SuccessHandler successHandler
    @Autowired
    DocumentoService documentoService

    @Action(tipo = TipoAzione.CLIENT,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Apre popup assegnazione competenze",
            descrizione = "Apre la popup per assegnare le competenze esplicite")
    void apriPopupAssegnaCompetenze(AbstractViewModel<? extends IDocumentoIterabile> viewModel, long idCfgPulsante, long idAzioneClient) {
        PopupCompetenzeEspliciteViewModel.apriPopup(viewModel.getDocumentoIterabile(false).toDTO()).addEventListener(Events.ON_CLOSE) { Event e ->
            viewModel.aggiornaMaschera(viewModel.getDocumentoIterabile(false))
            wkfIterService.eseguiPulsante(viewModel.getDocumentoIterabile(false), idCfgPulsante, viewModel, idAzioneClient)
        }

        // salto l'invalidate della maschera perché altrimenti viene nascosta la popup che ho appena creato
        successHandler.saltaInvalidate()
    }

    @Action(tipo = TipoAzione.CLIENT,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Apre popup Firma",
            descrizione = "Apre la popup di firma")
    void apriPopupFirma(AbstractViewModel<? extends IDocumentoIterabile> viewModel, long idCfgPulsante, long idAzioneClient) {
        // Attenzione! Il nome di questo metodo è importante! Viene usato come stringa nell'AbstractViewModel!
        // se lo si modifica, va modificato anche quel riferimento!
        viewModel.apriPopupFirma()
    }

    @Action(tipo = TipoAzione.CLIENT,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Apre la pagina GDM per l'inserimento dei dati aggiuntivi",
            descrizione = "Apre la pagina GDM per l'inserimento dei dati aggiuntivi")
    void apriDatiAggiuntiviGDM(AbstractViewModel<? extends IDocumentoIterabile> viewModel, long idCfgPulsante, long idAzioneClient) {

        //esempio di chiamata: http://svi-ora03:8080/appsjsuite/datiaggiuntivi/jsp/datiAggiuntivi.jsp?appl=PROT&tipoDoc=LETTERA&id=100
        //appl = PROTOCOLLO (nome dell'applicativo chiamante)
        //tipoDoc = codice presente in tipologia (usato come chiave)
        //id = id del documento esterno (gdm)
        Protocollo doc = viewModel.getDocumentoIterabile(false)

        String url = ImpostazioniProtocollo.URL_DATI_AGGIUNTIVI_GDM.valore + "?appl=PROT&tipoDoc=" + doc?.schemaProtocollo?.codice + "&id=" + doc.id

        if (url == null) {
            throw new ProtocolloRuntimeException("Nessun url configurato per essere aperto.")
        }

        // salto l'invalidate della maschera:
        successHandler.saltaInvalidate()

        // apro l'url
        //Executions.getCurrent().sendRedirect(url, "_blank");
        Clients.evalJavaScript(" window.open('" + url + "'); ")
    }

    @Action(tipo = TipoAzione.CLIENT,
            tipiOggetto = [Protocollo.TIPO_DOCUMENTO],
            nome = "Mostra popup di conferma in caso ci siano allegati non convertiti in pdf",
            descrizione = "")
    void controllaAllegatiNonPdfPresenti(AbstractViewModel<? extends IDocumentoIterabile> viewModel, long idCfgPulsante, long idAzioneClient) {

        IDocumentoIterabile doc = viewModel.getDocumentoIterabile(false);
        viewModel.protocollo.version = doc.version
        // conto quanti allegati ci sono
        if (documentoService.esistonoAllegatiNonPdf(doc)) {
            //successHandler.saltaInvalidate() serve perchè altrimenti la popup viene chiusa automaticamente
            successHandler.saltaInvalidate()
            Messagebox.show("Attenzione: sono presenti allegati sul documento non convertiti in Pdf. Si è sicuri di voler proseguire?", "Attenzione: ci sono allegati non in formato Pdf",
                    Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION,
                    new org.zkoss.zk.ui.event.EventListener() {
                        void onEvent(Event e) {
                            if (Messagebox.ON_OK.equals(e.getName())) {
                                viewModel.eseguiPulsante(idCfgPulsante, idAzioneClient);
                            }
                        }
                    }
            )
        } else {
            successHandler.saltaInvalidate()
            viewModel.aggiornaMaschera(viewModel.getDocumentoIterabile(false))
            viewModel.eseguiPulsante(idCfgPulsante, idAzioneClient);
        }
    }
}
