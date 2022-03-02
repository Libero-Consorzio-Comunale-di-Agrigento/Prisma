package it.finmatica.protocollo.documenti.storico
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gestionedocumenti.documenti.beans.FileDownloader
import it.finmatica.gestionedocumenti.storico.DatoStorico
import it.finmatica.gestionedocumenti.storico.DocumentoStoricoService
import it.finmatica.protocollo.documenti.Protocollo
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.GlobalCommand
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zul.DefaultTreeModel
import org.zkoss.zul.DefaultTreeNode
import org.zkoss.zul.TreeNode

import java.sql.Timestamp

@VariableResolver(DelegatingVariableResolver)
class StoricoProtocolloViewModel {

    @WireVariable private DocumentoStoricoService documentoStoricoService
    @WireVariable private FileDownloader fileDownloader

    Long idDocumento
    String prefissoLabel
    def filtri
    def filtroSelezionato

    DefaultTreeModel<DefaultTreeNode<DatoStorico>> datiStorici = null
    List<DatoStorico> risultatoStorico = []
    Date ricercaDal
    Date ricercaAl

    @Init
    void init(@ExecutionArgParam("idDocumento") Long idDocumento) {
        this.idDocumento = idDocumento
        this.prefissoLabel = "storico.protocollo."
        filtroSelezionato = [codice: "_TUTTI", titolo: "-- Tutti i Campi --", descrizione: "Mostra tutti i campi", filtri: ["oggetto.*", "movimento.*", "testoPrincipale.*", "allegati.*", "classificazione.*", "fascicolo.*", "destinatari.*"]]
        this.filtri = [filtroSelezionato]
        this.filtri.addAll([[codice: "DATI_DOCUMENTO", titolo: "Dati Documento", descrizione: "Dati principali del documento: oggetto, movimento, data", filtri: ["oggetto", "testoPrincipale\\..*"]]
                            , [codice: "DATI_FASCICOLAZIONE", titolo: "Dati Fascicolazione", descrizione: "Dati di classificazione e fascicolo", filtri: ["classificazione.*", "fascicolo.*"]]
                            , [codice: "DESTINATARI", titolo: "Destinatari", descrizione: "Dati dei destinatari", filtri: ["destinatari\\..*"]]])
    }

    @GlobalCommand("onRefreshStoricoProtocollo")
    @NotifyChange("idDocumento")
    void onRefreshStoricoProtocollo(@BindingParam("idDocumento") Long idDocumento) {
        this.idDocumento = idDocumento
    }

    @NotifyChange(["datiStorici", "risultatoStorico"])
    @Command
    void onRicerca() {
        Protocollo protocollo = Protocollo.get(idDocumento)
        if (ricercaDal == null || ricercaDal < protocollo?.data) {
            ricercaDal = protocollo?.data
        }

        risultatoStorico = documentoStoricoService.ricercaStorico(idDocumento, ricercaDal, ricercaAl)
        risultatoStorico = documentoStoricoService.filtraDatiStorici(risultatoStorico, filtroSelezionato.filtri)

        datiStorici = creaTreeNode(risultatoStorico)

        BindUtils.postNotifyChange(null, null, this, "datiStorici")
        BindUtils.postNotifyChange(null, null, this, "risultatoStorico")
    }

    @Command
    void onDownloadFileStorico(@BindingParam("nodo") DatoStoricoTreeNode nodo) {
        if (nodo.data.campo.equalsIgnoreCase("testoPrincipale._value")) {
            fileDownloader.downloadFileStorico(Long.parseLong(nodo.idDocumentoEsterno), nodo.parent.data.revisione, (String) nodo.data.valore)
        }
    }

    private DefaultTreeModel<DefaultTreeNode<DatoStorico>> creaTreeNode(List<DatoStorico> datiStorici) {
        List<DatoStoricoTreeNode> treeNodes = new ArrayList<>()
        for (DatoStorico datoStorico : datiStorici) {
            treeNodes << new DatoStoricoTreeNode(datoStorico, datoStorico.datiStorici.collect {
                new DatoStoricoTreeNode(it)
            })
        }
        return new DefaultTreeModel<DefaultTreeNode<DatoStorico>>(new DatoStoricoTreeNode(null, treeNodes), true)
    }

    static class DatoStoricoTreeNode extends DefaultTreeNode<DatoStorico> {

        private final String valore
        private final String idFileEsterno
        private final String idDocumentoEsterno

        DatoStoricoTreeNode(DatoStorico data, Collection<TreeNode<DatoStorico>> children) {
            super(data, children)

            if (data == null) {
                valore = ""
                idFileEsterno = null
                idDocumentoEsterno = null
            } else if (data.dati != null) {
                valore = data.dati._value
                idFileEsterno = data.dati._idFileEsterno
                idDocumentoEsterno = data.dati._idDocumentoEsterno
            } else if (data.valore instanceof Map) {
                valore = data.valore._value
                idFileEsterno = data.valore._idFileEsterno
                idDocumentoEsterno = data.valore._idDocumentoEsterno
            } else {
                valore = data.valore
                idFileEsterno = null
                idDocumentoEsterno = null
            }
        }

        DatoStoricoTreeNode(DatoStorico data) {
            this(data, [])
        }

        String getIdFileEsterno() {
            return idFileEsterno
        }

        String getValore() {
            return valore
        }
    }
}
