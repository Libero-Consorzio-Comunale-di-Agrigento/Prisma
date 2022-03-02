package it.finmatica.protocollo.documenti.viste

import it.finmatica.gorm.criteria.PagedResultList
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.transaction.annotation.Transactional
import org.springframework.stereotype.Service

import it.finmatica.gestionedocumenti.exception.GestioneDocumentiRuntimeException

import javax.sql.DataSource

@Service
@Transactional
class BottoneNotificaService {
	@Autowired
	DataSource dataSource
	@Autowired
	SessionFactory sessionFactory

	BottoneNotificaDTO salva(BottoneNotificaDTO bottoneNotificaDto) {

		BottoneNotifica bottoneNotifica = BottoneNotifica.get(bottoneNotificaDto.id) ?: new BottoneNotifica()
		bottoneNotifica.valido = bottoneNotificaDto.valido
		bottoneNotifica.tipo = bottoneNotificaDto.tipo
		bottoneNotifica.stato = bottoneNotificaDto.stato
		bottoneNotifica.azione = bottoneNotificaDto.azione
		bottoneNotifica.label = bottoneNotificaDto.label
		bottoneNotifica.tooltip = bottoneNotificaDto.tooltip
		bottoneNotifica.iconaShort = bottoneNotificaDto.iconaShort
		bottoneNotifica.modello = bottoneNotificaDto.modello
		bottoneNotifica.tipoAzione = bottoneNotificaDto.tipoAzione
		bottoneNotifica.azioneMultipla = bottoneNotificaDto.azioneMultipla
		bottoneNotifica.modelloAzione = bottoneNotificaDto.modelloAzione
		bottoneNotifica.assegnazione = bottoneNotificaDto.assegnazione
		bottoneNotifica.tipoSmistamento = bottoneNotificaDto.tipoSmistamento
		bottoneNotifica.sequenza = bottoneNotificaDto.sequenza

/*		if(bottoneNotifica.id == null){
			bottoneNotifica.id = 0
		}*/

		bottoneNotifica = bottoneNotifica.save()

		return bottoneNotifica.toDTO()
	}

	void elimina(BottoneNotificaDTO bottoneNotificaDto) {

		BottoneNotifica bottoneNotifica = BottoneNotifica.get(bottoneNotificaDto.id)
		/*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
		if (bottoneNotifica.version != bottoneNotificaDto.version) throw new GestioneDocumentiRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
		bottoneNotifica.delete()
	}

	PagedResultList list(int pageSize, int activePage, String filterCondition, boolean visualizzaTutti) {
		if (visualizzaTutti) {
			sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
		}
		try {
			PagedResultList lista = BottoneNotifica.createCriteria().list(max: pageSize, offset: pageSize * activePage) {
				if (!visualizzaTutti) {
					eq("valido", true)
				}
				if (filterCondition ?: "" != "") {
					or {
						ilike("tipo", "%${filterCondition}%")
						ilike("label", "%${filterCondition}%")
						ilike("tooltip", "%${filterCondition}%")
					}
				}
				order('tipo', 'asc')
				order('sequenza', 'asc')
			}
			return lista
		} finally {
			sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
		}
	}
}
