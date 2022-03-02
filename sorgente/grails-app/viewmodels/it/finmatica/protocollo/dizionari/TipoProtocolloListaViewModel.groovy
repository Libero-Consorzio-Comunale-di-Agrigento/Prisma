package it.finmatica.protocollo.dizionari

import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.protocollo.documenti.Protocollo
import org.hibernate.SessionFactory
import org.zkoss.bind.annotation.QueryParam
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocolloService

import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.Executions
import org.zkoss.zk.ui.event.Event
import org.zkoss.zul.ListModelList
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class TipoProtocolloListaViewModel extends AfcAbstractGrid {

	// service
	@WireVariable private TipoProtocolloService tipoProtocolloService
	@WireVariable SessionFactory sessionFactory

	// componenti
	Window self
    String tipoProtocollo

	// dati
	ListModelList<TipoProtocolloDTO> listaTipologiaProtocollo

	def lista = []

    @Init void init(@ContextParam(ContextType.COMPONENT) Window w, @QueryParam("tipo") String tipo) {
        this.self = w
        tipoProtocollo = tipo
		caricaListaTipologiaProtocollo()
    }

	private void caricaListaTipologiaProtocollo (String filterCondition = filtro) {
       List<String> categorie = calcolaCategorieDaCaricare()
		if (visualizzaTutti) {
			sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
		} else {
			sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
		}
       PagedResultList lista = TipoProtocollo.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
			if (filterCondition?:"" != "" ) {
				or {
					 ilike("codice","%${filterCondition}%")
					 ilike("descrizione","%${filterCondition}%")
				}
			}
		  	order('codice', 'asc')
		}

		listaTipologiaProtocollo = new ListModelList<TipoProtocolloDTO>(lista.toDTO())
        //Filtro sulla categoria, la inList sembra non funzionare correttamente al momento uso questo filtro
		listaTipologiaProtocollo = listaTipologiaProtocollo.findAll({ it -> categorie.contains(it.categoria) })
		totalSize  = listaTipologiaProtocollo.size

		BindUtils.postNotifyChange(null, null, this, "totalSize")
		BindUtils.postNotifyChange(null, null, this, "listaTipologiaProtocollo")
	}

    /**
     *
     * @return
     */
    private List<String> calcolaCategorieDaCaricare() {
         if (tipoProtocollo == Protocollo.CATEGORIA_LETTERA) {
            return [Protocollo.CATEGORIA_LETTERA]
        } else if (tipoProtocollo == Protocollo.CATEGORIA_PROTOCOLLO) {
            return [Protocollo.CATEGORIA_PEC, Protocollo.CATEGORIA_EMERGENZA, Protocollo.CATEGORIA_PROTOCOLLO, Protocollo.CATEGORIA_PROVVEDIMENTO]
        } else if (tipoProtocollo == Protocollo.CATEGORIA_DA_NON_PROTOCOLLARE) {
            return [Protocollo.CATEGORIA_DA_NON_PROTOCOLLARE, Protocollo.CATEGORIA_MEMO_PROTOCOLLO, Protocollo.CATEGORIA_REGISTRO_GIORNALIERO]
        }
        return new ArrayList<String>()
    }

    /*
     * Implementazione dei metodi per AfcAbstractGrid
     */

	@NotifyChange(["listaTipologiaProtocollo", "totalSize"])
	@Command void onPagina() {
		caricaListaTipologiaProtocollo()
	}

	@Command void onModifica (@BindingParam("isNuovoRecord") boolean isNuovoRecord) {
		Window w = Executions.createComponents ("/dizionari/tipoProtocolloDettaglio.zul", self, [id: (isNuovoRecord?-1:selectedRecord.id)])
		w.onClose {
			caricaListaTipologiaProtocollo()
			BindUtils.postNotifyChange(null, null, this, "listaTipologiaProtocollo")
			BindUtils.postNotifyChange(null, null, this, "totalSize")
		}
		w.doModal()
	}

	@NotifyChange(["listaTipologiaProtocollo", "totalSize", "selectedRecord", "activePage", "filtro"])
	@Command void onRefresh () {
		filtro = null
		selectedRecord = null
		activePage = 0
		caricaListaTipologiaProtocollo()
	}

	@NotifyChange(["listaTipologiaProtocollo", "totalSize", "selectedRecord"])
	@Command void onElimina () {
		tipoProtocolloService.eliminaTipoProtocollo(selectedRecord)
		selectedRecord = null
		caricaListaTipologiaProtocollo()
	}

	@NotifyChange(["visualizzaTutti", "listaTipologiaProtocollo", "totalSize", "selectedRecord", "activePage"])
	@Command void onVisualizzaTutti() {
		visualizzaTutti = !visualizzaTutti
		selectedRecord = null
		activePage = 0
		caricaListaTipologiaProtocollo()
	}

	@NotifyChange(["listaTipologiaProtocollo", "totalSize", "selectedRecord", "activePage"])
	@Command void onFiltro(@ContextParam(ContextType.TRIGGER_EVENT)Event event) {
		selectedRecord = null
		activePage = 0
		caricaListaTipologiaProtocollo()
	}

	@NotifyChange(["listaTipologiaProtocollo", "totalSize", "selectedRecord", "activePage", "filtro"])
	@Command void onCancelFiltro() {
		onRefresh()
	}
}
