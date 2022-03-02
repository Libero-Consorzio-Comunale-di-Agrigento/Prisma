package it.finmatica.protocollo.titolario

import groovy.transform.CompileStatic
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.ClassificazioneNumero
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional
import javax.persistence.LockModeType

@CompileStatic
@Repository
@Transactional
interface ClassificazioneNumeroRepository extends JpaRepository<ClassificazioneNumero, Long> {

    List<ClassificazioneNumero> findByClassificazioneOrderByAnnoDesc(Classificazione classificazione)

    /**
     * Ritorna una ClassificazioneNumero
     *
     * @param classificazione
     * @param anno
     * @return
     */

    @Query('''select c
          from ClassificazioneNumero c 
              where c.classificazione = :classificazione 
              and c.anno = :anno  
         ''')
    ClassificazioneNumero getClassificaNumero(@Param("classificazione") Classificazione classificazione, @Param("anno") Integer anno)

    /**
     * Ritorna una lista di anni per la numerazione del fascicolo
     *
     * @param classificazione
     * @return
     */

    @Query('''select c.anno
          from ClassificazioneNumero c 
          where c.classificazione = :classificazione
          and c.anno = TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
         ''')
    List<Integer> getListAnnoNumerazioneFascicolo(@Param("classificazione") Classificazione classificazione)

    @Query('''select c.anno
          from ClassificazioneNumero c 
          where c.classificazione = :classificazione
          and c.classificazione.numIllimitata = false
          and c.anno > TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
         ''')
    List<Integer> getListAnnoNumerazioneFascicoloCFFUTURO(@Param("classificazione") Classificazione classificazione)

    @Query('''select c.anno
          from ClassificazioneNumero c 
          where c.classificazione = :classificazione
          and c.classificazione.numIllimitata = false
          and c.anno < TO_NUMBER (TO_CHAR (SYSDATE, 'yyyy'))
         ''')
    List<Integer> getListAnnoNumerazioneFascicoloCFANYY(@Param("classificazione") Classificazione classificazione)

    /**
     * Ritorna la ultimoNumeroFascicolo dato classificazione e numero
     *
     * @param classificazione
     * @param anno
     * @return
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query('''select c.ultimoNumeroFascicolo 
              from ClassificazioneNumero c 
              where c.classificazione = :classificazione 
              and c.anno = :anno            
            ''')
    Integer getUltimoNumeroSub(@Param("classificazione") Classificazione classificazione, @Param("anno") Integer anno)

    @Modifying
    @Query('''update ClassificazioneNumero c
              set c.ultimoNumeroFascicolo = :numero 
              where c.classificazione = :classificazione 
              and c.anno = :anno ''')
    void modificaUltimoNumeroFascicolo(@Param("numero") Integer numero, @Param("classificazione") Classificazione classificazione, @Param("anno") Integer anno)


    @Modifying
    @Query('''update ClassificazioneNumero c
              set c.ultimoNumeroFascicolo = c.ultimoNumeroFascicolo - 1 
              where c.classificazione = :classificazione 
              and c.anno = :anno ''')
    void modificaUltimoNumeroFascicolo(@Param("classificazione") Classificazione classificazione, @Param("anno") Integer anno)
}