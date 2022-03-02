package it.finmatica.protocollo.integrazioni.ad4

import it.finmatica.ad4.autenticazione.Ad4Utente
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface Ad4Repository extends JpaRepository<Ad4Utente, String> {

    /**
     * Ritorna un utente dato il codice utente.
     *
     * @param utente
     * @return
     */
    @Query('''select u 
              from Ad4Utente u 
              where u.utente = :utente
            ''')
    Ad4Utente getUtente(@Param("utente") String utente)

    Ad4Utente findByNominativo (String nominativo)

}
