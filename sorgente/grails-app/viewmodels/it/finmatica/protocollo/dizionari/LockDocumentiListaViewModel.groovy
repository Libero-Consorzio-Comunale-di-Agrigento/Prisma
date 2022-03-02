package it.finmatica.protocollo.dizionari


import com.github.sardine.Sardine
import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.afc.AfcAbstractGrid
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.gestionetesti.lock.GestioneTestiDettaglioLock
import it.finmatica.gorm.criteria.PagedResultList
import org.apache.http.HttpStatus
import org.hibernate.FetchMode
import org.zkoss.bind.annotation.Command
import org.zkoss.bind.annotation.ContextParam
import org.zkoss.bind.annotation.ContextType
import org.zkoss.bind.annotation.Init
import org.zkoss.bind.annotation.NotifyChange
import org.zkoss.zk.ui.select.annotation.VariableResolver
import org.zkoss.zk.ui.select.annotation.WireVariable
import org.zkoss.zkplus.spring.DelegatingVariableResolver
import org.zkoss.zul.Window

@VariableResolver(DelegatingVariableResolver)
class LockDocumentiListaViewModel {

	// Paginazione
	int pageSize 	= AfcAbstractGrid.PAGE_SIZE_DEFAULT
	int activePage 	= 0
	int	totalSize	= 0

	// componenti
	Window self

	// dati
	it.finmatica.gestionetesti.lock.GestioneTestiDettaglioLockDTO selectedRecord
	List<it.finmatica.gestionetesti.lock.GestioneTestiDettaglioLockDTO> listaTestiLock = []

	// services
	@WireVariable
	private GestioneTestiService gestioneTestiService

	@Init init(@ContextParam(ContextType.COMPONENT) Window w) {
		activePage 	= 0
		totalSize	= 0
		this.self = w
		caricaListaLock()
	}

	@NotifyChange(["listaTestiLock", "totalSize"])
	private void caricaListaLock() {
		PagedResultList lista = GestioneTestiDettaglioLock.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
			isNull("dataFineLock")
			order ("dataInizioLock", "asc")
			fetchMode("utenteInizioLock", FetchMode.JOIN)
		}
		totalSize  = lista.totalCount
		listaTestiLock = lista.toDTO()
    }


	@NotifyChange(["listaTestiLock", "totalSize"])
	@Command onPagina() {
		caricaListaLock()
	}

	@NotifyChange(["listaTestiLock", "selectedRecord", "activePage", "totalSize"])
	@Command onRefresh () {
		selectedRecord = null
		activePage = 0
		caricaListaLock()
	}

	@NotifyChange(["listaTestiLock", "selectedRecord", "totalSize"])
	@Command onUnlock () {
		// sblocco il testo con l'utente che lo ha lockato.
		try {
			gestioneTestiService.unlock(selectedRecord.lock.idRiferimentoTesto, selectedRecord.utenteInizioLock.domainObject)
		} catch (RuntimeException e) {
			// se ricevo errore di testo non trovato, significa che il file non è presente su webdav, allora procedo con l'unlock normale.
			if (e.cause instanceof Sardine && e.cause.getStatusCode() == HttpStatus.SC_NOT_FOUND) {
				gestioneTestiService.eliminaLock(selectedRecord.lock.idRiferimentoTesto, selectedRecord.utenteInizioLock.domainObject)
			} else {
				throw e
			}
		}
		selectedRecord = null
		caricaListaLock()
	}

}
