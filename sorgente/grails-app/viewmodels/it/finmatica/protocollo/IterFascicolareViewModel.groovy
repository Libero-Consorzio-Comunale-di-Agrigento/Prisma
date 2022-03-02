package it.finmatica.protocollo

import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.ISmistabileDTO
import it.finmatica.protocollo.integrazioni.smartdesktop.EsitoSmartDesktop
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.protocollo.smistamenti.SmistamentoDTO
import it.finmatica.protocollo.zk.AlberoFascicoliNodo
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.AfterCompose
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.Component
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class IterFascicolareViewModel extends IterDocumentaleViewModel{

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("codiceTab") String codiceTab,
              @ExecutionArgParam("codiceUO") String codiceUO,  @ExecutionArgParam("smartDesktop") Boolean smartDesktop) {
       super.init(w, codiceTab, codiceUO, smartDesktop)
    }

    @AfterCompose
    void afterCompose(@ContextParam(ContextType.VIEW) Component view) {
       super.afterCompose(view)
    }

    @Override
    @Command
    void caricaLista(@BindingParam("codiceTab") String codiceTab) {

        settaTab(codiceTab)

        //carico solo se ho selezionato un'unita' organizzativa
        if(unitaOrganizzativa != null && unitaOrganizzativa.codice != null) {

            List<Smistamento> fascicoliIter = new ArrayList<Smistamento>()
            List<Smistamento> fascicoliIterTmp = new ArrayList<Smistamento>()
            List<String> statoSmistamento = new ArrayList<String>()

            //verifica privilegi e assegnatari a seconda dello stato in cui mi trovo
            if (daRicevere) {
                statoSmistamento = [Smistamento.DA_RICEVERE]
            } else if (inCarico || assegnati) {
                statoSmistamento = [Smistamento.IN_CARICO]
            }

            fascicoliIter = smistamentoService.getFascicoliIterDaSmistamentoByStatoSmistamento(testoCerca, unitaOrganizzativa, statoSmistamento, tipoOggettoDaEscludereIncludere, daRicevere, assegnati, inCarico)

            //Paginazione del risultato
            PageRequest pageable = new PageRequest(activePage, pageSize);
            int max = (pageSize * (activePage + 1) > fascicoliIter?.size()) ? fascicoliIter?.size() : pageSize * (activePage + 1);

            List<SmistamentoDTO> documentiIterDTOFinal = fascicoliIter?.toDTO()
            lista = new PageImpl<SmistamentoDTO>(documentiIterDTOFinal.subList(activePage * pageSize, max), pageable, documentiIterDTOFinal.size())
            //Carico i dati del dto documento solo per i 30 mostrati (altrimenti l'operazione richiede un tempo elevato)
            for(SmistamentoDTO smistamentoDTO : lista.content) {
                smistamentoDTO.documento = iterDocumentaleService.getDocumentoPerSmistamento(smistamentoDTO?.documento?.id)?.toDTO("classificazione")
            }
            totalSize = documentiIterDTOFinal.size()

            BindUtils.postNotifyChange(null, null, this, "selected")
            BindUtils.postNotifyChange(null, null, this, "lista")
            BindUtils.postNotifyChange(null, null, this, "totalSize")
            BindUtils.postNotifyChange(null, null, this, "activePage")
        }
        else {
            return
        }

    }

    @Override
    void ricercaPerCodiceABarre(String codiceABarre) {

        if( ! validaCodiceABarre(codiceABarre) ) {
            return
        }

        List<EsitoSmartDesktop> esitoSmartDesktopList = []

        List<Smistamento> fascicoliIter = new ArrayList<Smistamento>()

        //verifica privilegi e assegnatari a seconda dello stato in cui mi trovo
        List<String> statoSmistamento = [Smistamento.DA_RICEVERE]

        fascicoliIter = smistamentoService.getFascicoliPerCodiceABarre(unitaOrganizzativa, statoSmistamento, tipoOggettoDaEscludereIncludere, daRicevere, assegnati, inCarico, Long.valueOf(codiceABarre))

        List<SmistamentoDTO> fascicoliIterDto = fascicoliIter?.toDTO()

        for(SmistamentoDTO smistamento : fascicoliIterDto){
            ISmistabileDTO fascicolo = Documento.get(smistamento?.documento?.id)?.toDTO()
            EsitoSmartDesktop esitoSmartDesktop = smistamentoService.prendiInCarico(fascicolo, smistamento.idDocumentoEsterno)
            esitoSmartDesktopList.add(esitoSmartDesktop)
        }

        if (esitoSmartDesktopList.size() > 0) {
            String descrizioneTipoDocumento = getDescrizioneTipoDocumento(fascicoliIterDto?.get(0))
            Window wEsito = Executions.createComponents(ESITO_POPUP, self, [esitoSmartDesktopList: esitoSmartDesktopList, descrizioneTipoDocumento: descrizioneTipoDocumento])
            wEsito.onClose {
                onRefresh()
            }
            wEsito.doModal()
        }
    }

    String getIconaFascicolo(SmistamentoDTO smistamento) {
        Fascicolo fascicolo = smistamento.documento.domainObject
        return fascicoloService.iconcaFascicolo(fascicolo, true)
    }
}
