package it.finmatica.protocollo.titolario

import it.finmatica.protocollo.dizionari.Classificazione
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.JpaSpecificationExecutor
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface ClassificazioneRepository extends JpaRepository<Classificazione, Long>, JpaSpecificationExecutor<Classificazione> {

/**
 * Ritorna una lista di classifiche non aperte.
 *
 * @return
 */
    @Query(value = '''select c 
              from Classificazione c 
              where c.numIllimitata = false
      ''')
    List<Classificazione> getListClassificheNonAperte()


    /**
     * Ritorna la classifica in uso
     *
     * @param codiceClassifica
     * @return
     */
    @Query(value = '''select c 
              from Classificazione c 
              where c.codice = :codiceClassifica
              and ( c.al is null or c.al >= sysdate)
      ''')
    Classificazione getClassificazioneInUso(@Param("codiceClassifica") String codiceClassifica)

    /**
     * Ritorna se la data di chiusura è modificabile
     *
     * @param codiceClassifica
     * @return
     */
    @Query(value = '''select count(1) 
              from Classificazione c 
              where c.codice = :codiceClassifica
              and (c.al > :al or c.al is null) 
      ''')
    Integer isModificaDataChiusura(@Param("codiceClassifica") String codiceClassifica, @Param("al") Date al)


    /**
     * Ritorna una Classifica
     *
     * @param id
     * @return
     */
    @Query(value = '''select c 
              from Classificazione c 
              where c.idDocumentoEsterno = :id_documento_esterno
      ''')
    Classificazione getClassificaFromDocEsterno(@Param("id_documento_esterno") long id_documento_esterno)

    /**
     * Ritorna una Classifica
     *
     * @param progressivo
     * @return
     */
    @Query(value = '''select c 
              from Classificazione c 
              where c.progressivo = :progressivo
      ''')
    List<Classificazione> listClassificazioniFromProgressivo(@Param("progressivo") long progressivo)

    /**
     * Ritorna un progessivo
     *
     * @param progressivo
     * @return
     */
    @Query(value = '''select distinct c.progressivoPadre 
              from Classificazione c 
              where c.progressivo = :progressivo
      ''')
    Long getProgressivoPadre(@Param("progressivo") Long progressivo)

    /**
     * Ritorna una lista di tutte le classifiche.
     *
     * @return
     */
    @Query(value = '''select c 
              from Classificazione c 
        ''')
    List<Classificazione> getListClassifiche()

    /**
     * Ritorna una lista di classifiche dato id con al is null.
     *
     * @param id
     * @return
     */
    @Query('''select c 
              from Classificazione c 
              where c.id = :id 
              and c.al is null )
            ''')
    List<Classificazione> getListClassificazioneValida(@Param("id") long id)

    /**
     * Ritorna la classificazione
     *
     * @param id
     * @return
     */
    @Query('''select TO_CHAR (c.dal, 'yyyy')
              from Classificazione c 
              where c.id = :id)
            ''')
    String getAnnoClassificazione(@Param("id") long id)

    /**
     * Ritorna una lista di classifiche dato id e data di validità.
     *
     * @param id
     * @param dataValidita
     * @return
     */
    @Query('''select c 
              from Classificazione c 
              where c.id = :id 
                     and coalesce(:dataValidita, current_date) >= c.dal
              and (  c.al is null or coalesce(c.al, current_date) <= coalesce(:dataValidita, current_date) )
            ''')
    List<Classificazione> getListClassificazioneValida(@Param("id") long id, @Param("dataValidita") Date dataValidita)

    /**
     * Ritorna la classifica dato id e data di validità.
     *
     * @param id
     * @param dataValidita
     * @return
     */
    @Query('''select c 
              from Classificazione c 
              where c.id = :id 
                     and coalesce(:dataValidita, current_date) >= c.dal
              and (  c.al is null or coalesce(c.al, current_date) <= coalesce(:dataValidita, current_date) )
            ''')
    Classificazione getClassificazioneValida(@Param("id") long id, @Param("dataValidita") Date dataValidita)

    @Query(value = '''select c 
              from Classificazione c 
              where c.codice = :codice
              ORDER BY coalesce(c.al, CURRENT_DATE) DESC
      ''')
    List<Classificazione> findTopByCodice(@Param("codice") String codice, Pageable pag)

    Classificazione findById(Long id)

    @Modifying
    @Query('update Classificazione set progressivo = :id where id = :id')
    void aggiornaProgressivo(@Param("id") Long id)

    /**
     * Ritorna una lista di classifiche dato id e data di validità.
     *
     * @param codice
     * @param dataValidita
     * @return
     */
    @Query('''select c 
              from Classificazione c 
              where c.codice = :codice
                     and  c.dal <= coalesce(:dataValidita, current_date)
              and (  c.al is null or coalesce(c.al, current_date) >= coalesce(:dataValidita, current_date) )
            ''')
    List<Classificazione> getListClassificazioneValidaByCodice(@Param("codice") String codice, @Param("dataValidita") Date dataValidita)
}
