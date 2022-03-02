package it.finmatica.protocollo.scaricoipa

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface ScaricoIpaRepository extends JpaRepository<CriteriScaricoIpa, Long> {

    /**
     * Ritorna il tipo soggetto dato la descrizione.
     *
     * @param descrizione
     * @return
     */
    @Query('''select i
          from CriteriScaricoIpa i 
          where i.id = :id
        ''')
    CriteriScaricoIpa getCriterioScaricoIpa(@Param("id") Long id)
}


