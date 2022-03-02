package it.finmatica.protocollo.dizionari

import it.finmatica.protocollo.exceptions.ProtocolloRuntimeException
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource
import java.sql.SQLException



@Transactional
@Service
class OggettoRicorrenteDTOService {

    @Autowired DataSource dataSource
    @Autowired SessionFactory sessionFactory

    public OggettoRicorrenteDTO salva(OggettoRicorrenteDTO oggettoRicorrenteDto) {

        try {
            OggettoRicorrente oggettoRicorrente = OggettoRicorrente.get(oggettoRicorrenteDto.id) ?: new OggettoRicorrente()
            oggettoRicorrente.codice = oggettoRicorrenteDto.codice.toUpperCase()
            oggettoRicorrente.oggetto = oggettoRicorrenteDto.oggetto.toUpperCase()
            oggettoRicorrente.valido = oggettoRicorrenteDto.valido
            if (oggettoRicorrente.id == null) {
                oggettoRicorrente.id = 0
            }

            oggettoRicorrente = oggettoRicorrente.save()

            oggettoRicorrente = reloadFromDb(oggettoRicorrenteDto.codice.toUpperCase())

            return oggettoRicorrente.toDTO()
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    public void elimina(OggettoRicorrenteDTO oggettoRicorrenteDto) {
        try {
            OggettoRicorrente oggettoRicorrente = OggettoRicorrente.get(oggettoRicorrenteDto.id)
            /*controllo che la versione del DTO sia = a quella appena letta su db: se uguali ok, altrimenti errore*/
            if (oggettoRicorrente.version != oggettoRicorrenteDto.version) {
				throw new ProtocolloRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
			}
            oggettoRicorrente.delete(failOnError: true)
        } catch (SQLException e) {
            throw new ProtocolloRuntimeException(e)
        }
    }

    private OggettoRicorrente reloadFromDb(String codice) {
        OggettoRicorrente oggettoRicorrente = null
        sessionFactory.getCurrentSession().disableFilter("soloValidiFilter")
        try {
            oggettoRicorrente = OggettoRicorrente.findByCodice(codice)
        } finally {
            sessionFactory.getCurrentSession().enableFilter("soloValidiFilter")
        }
        return oggettoRicorrente
    }
}
