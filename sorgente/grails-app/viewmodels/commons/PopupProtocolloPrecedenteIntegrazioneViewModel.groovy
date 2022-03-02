package commons

import it.finmatica.protocollo.documenti.TipoCollegamentoConstants
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zkplus.spring.DelegatingVariableResolver

import it.finmatica.gorm.criteria.PagedResultList
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegatoDTO
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.registri.TipoRegistroDTO
import it.finmatica.protocollo.documenti.ProtocolloDTO
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import it.finmatica.protocollo.integrazioni.ProtocolloEsternoDTO
import org.hibernate.FetchMode
import org.zkoss.bind.annotation.*
import org.zkoss.zk.ui.event.Events
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class PopupProtocolloPrecedenteIntegrazioneViewModel {

	def springSecurityService

	Window self

	List<TipoRegistroDTO> listaRegistro
	Integer anno
	Integer numero
	String oggetto
	TipoRegistroDTO selectedTipoRegistro

	def risultatiRicerca
	ProtocolloEsternoDTO selectedDocumento

	int pageSize 	= 10
	int activePage 	= 0
	int	totalSize	= 0

	def utente

	@NotifyChange(["listaRegistro","selectedTipoRegistro"])
	@Init init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("anno") String anno, @ExecutionArgParam("numero") String numero) {
		this.self 				= w
		utente 					= springSecurityService.principal

		if (anno != "") {
			this.anno = anno.toInteger()
		}
		else this.anno = null

		if (numero != "") {
			this.numero = numero.toInteger()
		}
		else this.numero = null

		caricaListaRegistro()
		onRicerca()
	}

	@NotifyChange(["selectedDocumento", "listaRegistro", "selectedTipoRegistro"])
	@Command
    void caricaListaRegistro () {
		selectedDocumento = null
        selectedTipoRegistro = null

        listaRegistro = TipoRegistro.list().toDTO()
	}


	@NotifyChange(["risultatiRicerca", "totalSize"])
	@Command onRicerca() {

		// controlla se esiste almeno un parametro inserito altrimenti azzera la lista
		if (this.anno == null && this.numero == null && selectedTipoRegistro == null && (oggetto == null || oggetto == "")) {
			risultatiRicerca = null
			totalSize = 0
			return
		}

		onRicercaProtocolloPrecedente()
	}

	private void onRicercaProtocolloPrecedente() {
		// restituisce la lista contenente le determine che fanno match
		PagedResultList lista  = ProtocolloEsterno.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
				if (anno != null) {
					eq("anno", anno)
				}
				if (numero != null) {
					eq("numero", numero)
				}
				if (selectedTipoRegistro != null) {
					eq("tipoRegistro.codice", selectedTipoRegistro.codice)
				}
				if (oggetto != null) {
					ilike("oggetto", "%"+oggetto+"%")
				}

				isNotNull ("anno")
				isNotNull ("numero")
				isNotNull ("data")

				fetchMode("tipoRegistro", FetchMode.JOIN)
		}

		totalSize = lista.totalCount
		risultatiRicerca = lista.toDTO()
	}

	@Command onCollegaDocumento () {

		if(selectedDocumento == null) {
			Messagebox.show("Attenzione: bisogna prima selezionare un tipo di documento da cercare")
			return
		}

		DocumentoCollegatoDTO documentoCollegato = new DocumentoCollegatoDTO ()
		documentoCollegato.tipoCollegamento = TipoCollegamento.findByCodice(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE).toDTO()

		def tipoProcollo = TipoProtocollo.findByCategoria(selectedDocumento.categoria)
		if(tipoProcollo == null){

			Messagebox.show("Attenzione: bisogna censire il tipo di Protocollo: " + selectedDocumento.categoria)
			return
		}
		ProtocolloDTO protocolloPrecedenteDto = new ProtocolloDTO(idDocumentoEsterno: selectedDocumento.idDocumentoEsterno,
				                                                  anno: selectedDocumento.anno,
				                                                  numero: selectedDocumento.numero,
				                                                  data: selectedDocumento.data,
															      oggetto: selectedDocumento.oggetto,
                                                                  tipoProtocollo: tipoProcollo.toDTO(),
                                                                  tipoRegistro: selectedDocumento.tipoRegistro)

        documentoCollegato.collegato = protocolloPrecedenteDto

		Events.postEvent(Events.ON_CLOSE, self, documentoCollegato)
	}

	@Command onChiudi () {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}

	@NotifyChange(["risultatiRicerca", "totalSize"])
	@Command onPagina() {
		onRicerca()
	}
}
