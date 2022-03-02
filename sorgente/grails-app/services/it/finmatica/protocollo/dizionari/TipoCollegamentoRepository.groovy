package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface TipoCollegamentoRepository extends JpaRepository<TipoCollegamento, Long> {

    /**
     * Ritorna una lista di tipi di collegamento utilizzabili nell'interfaccia
     * @Param codiciNonUtilizzabili
     * @return
     */
    @Query('''select tc 
          from TipoCollegamento tc 
          where tc.codice not in :codiciNonUtilizzabili 
         ''')
    List<TipoCollegamento> utilizzabili(@Param("codiciNonUtilizzabili") List<String> codiciNonUtilizzabili)

    /**
     * Ritorna una lista di tipi di collegamento utilizzabili nell'interfaccia
     * @Param codiciNonUtilizzabili
     * @return
     */
    @Query('''select tc 
          from TipoCollegamento tc 
          where tc.codice in :codiciUtilizzabili 
         ''')
    List<TipoCollegamento> utilizzabiliPerFascicolo(@Param("codiciUtilizzabili") List<String> codiciUtilizzabili)
}