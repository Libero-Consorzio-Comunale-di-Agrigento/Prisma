package it.finmatica.protocollo.documenti

import groovy.util.logging.Slf4j
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.DocumentoDTO
import it.finmatica.gestionedocumenti.documenti.DocumentoService
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.documenti.annullamento.ProtocolloAnnullamentoDTO
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@Slf4j
@VariableResolver(DelegatingVariableResolver)
class ProvvedimentoViewModel extends ProtocolloViewModel {

    @WireVariable
    private AnnullamentoService annullamentoService
    @WireVariable
    private ProtocolloService protocolloService
    @WireVariable
    private TitolarioService titolarioService
    @WireVariable
    private DocumentoService documentoService
    @WireVariable
    private ProtocolloGestoreCompetenze gestoreCompetenze

    List<ProtocolloDTO> listaDocumentiDaAnnullareDTO = new ArrayList<ProtocolloDTO>()
    List<ProtocolloAnnullamentoDTO> listaProtocolliAnnullamento = new ArrayList<ProtocolloAnnullamentoDTO>()

    static Window apriPopup(String categoria, List<DocumentoDTO> documento) {
        return apri([categoria: categoria, listaDocumentiSelected: documento])
    }


    private static Window apri(Map parametri) {
        Window window = (Window) Executions.createComponents("/protocollo/documenti/provvedimento.zul", null, parametri)
        window.doModal()
        return window
    }

    @Init
    void init(
            @ContextParam(ContextType.COMPONENT) Window w,
            @ExecutionArgParam("id") Long id,
            @ExecutionArgParam("movimento") String movimentoParam,
            @ExecutionArgParam("forzaCompetenzeInLettura") Boolean forzaCompetenzeInLettura,
            @ExecutionArgParam("apriInSolaLettura") Boolean apriInSolaLettura,
            @ExecutionArgParam("categoria") String categoria,
            @ExecutionArgParam("protocollo") ProtocolloDTO protocolloDTO,
            @ExecutionArgParam("ricercaCorrispondenti") String ricercaCorrispondenti,
            @ExecutionArgParam("idCartella") Long idCartella,
            @ExecutionArgParam("listaDocumentiSelected") List<ProtocolloDTO> documentiDaAnnullareDTO) {
        super.init(w, id, movimentoParam, forzaCompetenzeInLettura, apriInSolaLettura,categoria, protocolloDTO, ricercaCorrispondenti, idCartella )

        if(null != documentiDaAnnullareDTO) {
            //La lista viene passata tra i parametri come ArrayList di ArrayList, ciascuna contenente un solo elemento, ovvero il protocollo.
            //Scorro le liste e prendo sempre il primo elemento
            for(List protocolloList : documentiDaAnnullareDTO) {
                listaDocumentiDaAnnullareDTO.add(protocolloList.get(0))
            }
        }
        calcolaListaProtocolliDaAnnullare()
    }

    @AfterCompose
    void afterCompose() {
        super.afterCompose()
    }

    @Command
    void onRicercaDocumentoDaAnnullare(@BindingParam("annoSearch") String anno, @BindingParam("numeroSearch") String numero) {

        if(!verificaParametriDiRicercaProtocollo(anno, numero)){
            return
        }
        ProtocolloAnnullamentoDTO protocolloDaAnnullare = annullamentoService.getProtocolloDaAnnullare(anno.toInteger(), numero.toInteger(), tipoRegistroPrecedente.codice)?.toDTO("protocollo.tipoRegistro", "unita")

        if (protocolloDaAnnullare != null) {
            //inserisci in lista solo se non è già presente
             if(! annullamentoService.isPresenteInListaDaAnnullare(protocolloDaAnnullare,listaProtocolliAnnullamento)) {
                 //Inserisci in lista o sul db
                 if(protocollo.id > 0) {
                    TipoCollegamento tipoCollegamento = protocolloService.getTipoCollegamento(TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_PROVVEDIMENTO)
                    protocolloService.salvaCollegamentoProvvedimento(protocollo.domainObject, protocolloDaAnnullare.protocollo.domainObject, tipoCollegamento.codice )
                 }
                 listaProtocolliAnnullamento.add(0, protocolloDaAnnullare)
                 refreshDaAnnullare()
             } else {
                Clients.showNotification("Il documento numero: " + numero + " anno: " + anno + " registro " + tipoRegistroPrecedente.commento + " è già presente tra i documenti da annullare", Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
                return
             }
        } else {
            Clients.showNotification("Nessun documento da annullare trovato per anno: " + anno + " numero: " + numero + " registro " + tipoRegistroPrecedente.commento, Clients.NOTIFICATION_TYPE_ERROR, self, "middle_center", 4000, true)
            return
        }
    }

    @Command
    void onEliminaDocumentoDaAnnullare(@BindingParam("protocolloDaAnnullare") ProtocolloAnnullamentoDTO protocolloDaAnnullare) {
        Messagebox.show("Sei sicuro di voler eliminare il documento " + protocolloDaAnnullare.protocollo.numero + " / " + protocolloDaAnnullare.protocollo.anno + " ?", "Attenzione", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
            if (Messagebox.ON_OK == e.getName()) {
                //Se ho salvata cancello da db
                if (protocollo.id > 0 && protocolloDaAnnullare.id != null) {
                    protocolloService.eliminaDocumentoCollegatoProvvedimento(protocollo.domainObject, protocolloDaAnnullare.protocollo.domainObject, TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_PROVVEDIMENTO )
                    protocollo.version = protocollo.domainObject.version
                }
                //rimuovo sempre (sia se salvato a db che meno) dalla lista e aggiorno
                listaProtocolliAnnullamento.remove(protocolloDaAnnullare)
                refreshDaAnnullare()
                Clients.showNotification("Documento eliminato", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
            }
        }
    }

    /**
     * Refresh lista documenti da annullare
     */
    private void refreshDaAnnullare() {
         BindUtils.postNotifyChange(null, null, this, "listaProtocolliAnnullamento")
    }

    /**
     * crea lista documenti da annullare
     */
    private calcolaListaProtocolliDaAnnullare(){
        if(protocollo.id > 0) {
                listaDocumentiCollegati = protocollo.domainObject?.getDocumentiCollegati(TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_PROVVEDIMENTO)?.toDTO(["tipoRegistro"])
                for(DocumentoDTO collegato : listaDocumentiCollegati){
                    listaProtocolliAnnullamento.add(annullamentoService.getProtocolloAnnullamentoByProtocollo(collegato.domainObject)?.toDTO(["unita", "utenteIns"]))
                }
        } else {
            for(Protocollo protocollo : listaDocumentiDaAnnullareDTO) {
                listaProtocolliAnnullamento.add(annullamentoService.getProtocolloAnnullamentoByProtocollo(protocollo)?.toDTO(["unita", "utenteIns"]))
            }
        }
    }

    @Override
    void aggiornaDocumentoIterabile(Protocollo p) {
         for(ProtocolloAnnullamentoDTO protocolloAnnullamento : listaProtocolliAnnullamento) {
                if(! annullamentoService.collegatoPresenteInLista(protocolloAnnullamento, p)) {
                    TipoCollegamento tipoCollegamento = protocolloService.getTipoCollegamento(TipoCollegamentoConstants.CODICE_TIPO_REGISTRO_PROVVEDIMENTO)
                    DocumentoCollegato documentoCollegato = new DocumentoCollegato()
                    documentoCollegato.documento = p
                    documentoCollegato.collegato = protocolloAnnullamento.protocollo.domainObject
                    documentoCollegato.tipoCollegamento = tipoCollegamento
                    p.addToDocumentiCollegati(documentoCollegato)
                }
         }
         super.aggiornaDocumentoIterabile(p)
    }

}