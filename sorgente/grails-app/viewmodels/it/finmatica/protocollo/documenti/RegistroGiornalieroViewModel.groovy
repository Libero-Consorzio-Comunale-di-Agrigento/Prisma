package it.finmatica.protocollo.documenti

import commons.PopupInserisciTitolarioViewModel
import it.finmatica.dto.DTO
import it.finmatica.gestionedocumenti.commons.AbstractViewModel
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.soggetti.TipologiaSoggettoService
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.protocollo.dizionari.ClassificazioneDTO

import it.finmatica.protocollo.dizionari.FascicoloDTO
import it.finmatica.protocollo.titolario.TitolarioService
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolarioDTO
import org.apache.commons.lang3.time.FastDateFormat
import org.apache.commons.lang3.tuple.Pair
import org.apache.log4j.Logger
import org.zkoss.bind.BindUtils
import org.zkoss.bind.annotation.BindingParam
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.ExecutionArgParam
import org.zkoss.bind.annotation.Init
import org.zkoss.zk.ui.event.Event
import org.zkoss.zk.ui.event.Events
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zk.ui.util.Clients
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Messagebox
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class RegistroGiornalieroViewModel extends AbstractViewModel<RegistroGiornaliero> {

	private static final Logger log = Logger.getLogger(RegistroGiornalieroViewModel.class)

    Window 		self

	// services
	@WireVariable private RegistroGiornalieroService registroGiornalieroService
	@WireVariable private TipologiaSoggettoService tipologiaSoggettoService
	@WireVariable private ProtocolloFileDownloader fileDownloader
	@WireVariable private ProtocolloService protocolloService
	@WireVariable private TitolarioService titolarioService

	// dati
	RegistroGiornaliero registro

	// mappa dei soggetti
	Map soggetti = [:]
	FileDocumento filePrincipale
	FileDocumento allegato
	Documento documentoAllegato
	List<DocumentoTitolarioDTO> listaTitolari
	boolean haTitolari = false
	Protocollo protocollo

	FastDateFormat fdf = FastDateFormat.getInstance('dd/MM/yyyy HH:mm:ss')
	FastDateFormat fdfSoloDate = FastDateFormat.getInstance('dd/MM/yyyy')

	@Init
	void init(@ContextParam(ContextType.COMPONENT) Window w, @ExecutionArgParam("id") Long idDocumento) {

		this.self = w
		protocollo = registroGiornalieroService.findByIdDocumento(idDocumento)
		this.registro 	= protocollo.registroGiornaliero
		this.registro.protocollo = protocollo

		caricaDettagli()
	}

    private void caricaDettagli(){
		soggetti = tipologiaSoggettoService.calcolaSoggettiDto(registro.protocollo)
		filePrincipale = registroGiornalieroService.getFilePrincipale(registro)
		Pair<Documento,FileDocumento> p = registroGiornalieroService.getAllegato(registro)
		documentoAllegato = p.left
		allegato = p.right
		listaTitolari = registroGiornalieroService.getTitolari(registro) ?: []
    }

	@Command void onChiudi () {
		Events.postEvent(Events.ON_CLOSE, self, null)
	}

	@Override
	Collection<String> validaMaschera() {
		return []
	}

	@Override
	RegistroGiornaliero getDocumentoIterabile(boolean controllaConcorrenza) {
		return null
	}

	@Override
	void aggiornaMaschera(RegistroGiornaliero documentoIterabile) {
	}

	@Override
	void aggiornaDocumentoIterabile(RegistroGiornaliero documentoIterabile) {
	}

	@Override
	WkfCfgIter getCfgIter() {
		return null
	}

	@Command
	void onDownloadFilePrincipale() {
		fileDownloader.downloadFileAllegato(registro.protocollo?.toDTO(), filePrincipale)
	}

	@Command
	void onDownloadFileAllegato() {
		fileDownloader.downloadFileAllegato(documentoAllegato?.toDTO(), allegato)
	}

	@Command
	void onInserisciTitolario() {
		ProtocolloDTO protocollo = registro.protocollo.toDTO()
		PopupInserisciTitolarioViewModel.apri(self, listaTitolari, protocollo).addEventListener(Events.ON_CLOSE) { Event event ->
			if (event.data != null) {
				List<DTO> selectedTitolari = event.data
				DocumentoTitolarioDTO documentoTitolarioDTO

				for (DTO titolario : selectedTitolari) {
					if (titolario instanceof FascicoloDTO) {
						FascicoloDTO fascicolo = titolario
						ClassificazioneDTO classificazione = titolario.classificazione
						documentoTitolarioDTO = new DocumentoTitolarioDTO(fascicolo: fascicolo, classificazione: classificazione, documento: protocollo)
					} else {
						documentoTitolarioDTO = new DocumentoTitolarioDTO(classificazione: titolario, documento: protocollo)
					}

					if (protocollo.id != null) {

						Protocollo p = protocollo.domainObject
						if (protocollo.fascicolo?.id != p.fascicolo?.id) {
							protocolloService.salva(p, protocollo)
						}
						titolarioService.salva(p, [documentoTitolarioDTO])
						protocollo.version = p.version
						aggiornaMaschera(registro)
					} else {
						listaTitolari.add(documentoTitolarioDTO)
					}
				}
				refreshListaTitolari()
			}
		}
	}

	@Command
	void onEliminaTitolario(@BindingParam("titolario") titolario) {
		ProtocolloDTO protocollo = registro.protocollo.toDTO()
		Messagebox.show("Sei sicuro di voler eliminare il titolario: " + titolario.classificazione.codice + " ?", "Attenzione", Messagebox.OK | Messagebox.CANCEL, Messagebox.QUESTION) { Event e ->
			if (Messagebox.ON_OK == e.getName()) {
				if (protocollo.id != null) {
					titolarioService.remove(protocollo, titolario)
					protocollo.version = protocollo.domainObject.version
				}
				listaTitolari.remove(titolario)
				refreshListaTitolari()
				Clients.showNotification("Titolario eliminato", Clients.NOTIFICATION_TYPE_INFO, null, "top_center", 3000, true)
			}
		}
	}

	public void refreshListaTitolari() {
		listaTitolari = registroGiornalieroService.getTitolari(registro) ?: []
		haTitolari = listaTitolari
		BindUtils.postNotifyChange(null, null, this, 'haTitolari')
		BindUtils.postNotifyChange(null, null, this, "listaTitolari")
	}

	List<Protocollo.StatoArchivio> getStatiArchivio() {
		List<Protocollo.StatoArchivio> stati = Protocollo.StatoArchivio.values()
		stati.add(0, null)
		return stati
	}

	String formatDate(Date date) {
		return date ? fdf.format(date) : ''
	}

	String formatSoloDate(Date date) {
		return date ? fdfSoloDate.format(date) : ''
	}

	String getRegistroVisibile() {
		"${protocollo.oggetto} - dal ${registro.primoNumero} al ${registro.ultimoNumero}"
	}
}
