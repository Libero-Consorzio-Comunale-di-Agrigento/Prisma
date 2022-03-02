package it.finmatica.protocollo.dizionari.impostazioni
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.ProtocolloViewModel
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubbDTO
import org.hibernate.criterion.CriteriaSpecification
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class CambioUnitaListaViewModel {

    // Componenti
    Window self

    // Dati
    List<Documento> documentiSelezionati
    List<Protocollo> listaDocumenti

    // Lista delle unità chiuse di documenti ancora attivi
    List<So4UnitaPubbDTO> listaSoggetti

    // unità chiusa scelta
    So4UnitaPubbDTO soggetto

    int selectedIndexTipiSoggetto = -1
    int selectedIndexSoggetti = -1
    def tipoOggetto
    List tipiOggetto = [
            [codice: 'LETTERA', nome: "Lettere"]
    ]

    @Init
    void init(@ContextParam(ContextType.COMPONENT) Window w) {
        this.self = w
        caricaListaSoggetti()
    }

    @NotifyChange(["listaSoggetti"])
    private void caricaListaSoggetti() {
        listaSoggetti = DocumentoSoggetto.createCriteria().list {
            projections {
                distinct("unitaSo4")
            }
            unitaSo4 {
                lt("al", new Date().clearTime())
            }
        }.toDTO()
    }

    @Command
    void onCambiaSoggetto() {
        caricaListaDocumenti()
    }

    @Command
    void onCambiaTipoDocumento() {
        caricaListaDocumenti()
    }

    @Command
    void onCambiaTipoOggetto() {
        self.invalidate()
        caricaListaDocumenti()
    }

    private void caricaListaDocumenti() {
        listaDocumenti = Protocollo.createCriteria().listDistinct {
            createAlias('soggetti', 'ds', CriteriaSpecification.INNER_JOIN)
            if (soggetto != null) {
                eq("ds.unitaSo4", soggetto.domainObject)
            }

            if (tipoOggetto != null) {
                eq("tipoOggetto.codice", tipoOggetto.codice)
            }

            order("anno", "desc")
            order("numero", "desc")
        }

        BindUtils.postNotifyChange(null, null, this, "listaDocumenti")
    }

    @Command
    void onApriDocumento(@BindingParam("documento") Documento documento) {
        ProtocolloViewModel.apriPopup(documento.id).addEventListener(Events.ON_CLOSE) {
            caricaListaDocumenti()
        }
    }

    @Command
    void onModificaUnita() {
        if (!documentiSelezionati.isEmpty()) {
            List<Long> listaIdOggetti = documentiSelezionati.collect { it.id }
            Window w = Executions.createComponents("/dizionari/impostazioni/cambioUnitaDettaglio.zul", self, [listaDocumenti: documentiSelezionati, unitaSo4Vecchia: soggetto])
            w.onClose {
                caricaListaDocumenti()
                BindUtils.postNotifyChange(null, null, this, "listaDocumenti")
            }
            w.doModal()
        }
    }
}
