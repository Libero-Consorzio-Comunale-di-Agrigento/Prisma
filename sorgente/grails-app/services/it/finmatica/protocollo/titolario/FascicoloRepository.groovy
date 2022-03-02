package it.finmatica.protocollo.titolario

import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

import javax.persistence.LockModeType

interface FascicoloRepository extends JpaRepository<Fascicolo, Long> {

    /**
     * Ritorna una lista di fascicoli dato id_classifica, anno e numero fascicolo.
     *
     * @param classifica
     * @param fascicoloAnno
     * @param fascicoloNumero
     * @return
     */
    @Query('''select f 
          from Fascicolo f 
          where f.anno = :fascicoloAnno and f.numero=:fascicoloNumero
          and classificazione.id =:classifica 
         ''')
    List<Fascicolo> getListFascicolo(@Param("classifica") long classifica, @Param("fascicoloAnno") int fascicoloAnno, @Param("fascicoloNumero") String fascicoloNumero)

    /**
     * Ritorna una lista di fascicoli da numerare.
     *
     * @return
     */
    @Query('''select f 
          from Fascicolo f 
          where f.numeroProssimoAnno = true
          and f.dataChiusura is null
         ''')
    List<Fascicolo> listFascicoliDaNumerare()

    /**
     * Ritorna una fascicolo dato id_classifica, anno e numero fascicolo.
     *
     * @param classifica
     * @param fascicoloAnno
     * @param fascicoloNumero
     * @return
     */
    @Query('''select f 
          from Fascicolo f 
          where f.anno = :fascicoloAnno and f.numero=:fascicoloNumero
          and classificazione.id =:classifica 
         ''')
    Fascicolo getFascicolo(@Param("classifica") long classifica, @Param("fascicoloAnno") int fascicoloAnno, @Param("fascicoloNumero") String fascicoloNumero)

    /**
     * Restituisce il fascicolo indicato dall'id esterno fornito
     * @param idDocumentoEsterno l'id documento esterno
     * @return il fascicolo, se presente, con classficazione
     */
    @Query('''select f 
          from Fascicolo f JOIN FETCH f.classificazione
          where f.idDocumentoEsterno = :idDocumentoEsterno
         ''')
    Fascicolo getFascicolo(@Param("idDocumentoEsterno") Long idDocumentoEsterno)

    /**
     * Restituisce il fascicolo indicato dall'id
     * @param id l'id documento
     * @return il fascicolo, se presente
     */
    @Query('''select f 
          from Fascicolo f
          where f.id = :id
         ''')
    Fascicolo getFascicoloFromId(@Param("id") Long id)

    /**
     * Restituisce il fascicolo indicato dall'idDocumentoEsterno
     * @param id l'idDocumentoEsterno
     * @return il fascicolo, se presente
     */
    @Query('''select f 
          from Fascicolo f
          where f.idDocumentoEsterno = :id
         ''')
    Fascicolo getFascicoloFromIdDocumentoEsterno(@Param("id") Long id)

    /**
     * Ritorna la ultimoNumeroSub dato fascicolo
     *
     * @param fascicolo
     * @return
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query('''select f.ultimoNumeroSub 
              from Fascicolo f 
              where f = :fascicolo   
            ''')
    Integer getUltimoNumeroSub(@Param("fascicolo") Fascicolo fascicolo)

    @Modifying
    @Query('''update Fascicolo f
              set f.ultimoNumeroSub = :numero 
              where f.id = :idFascicolo ''')
    void modificaUltimoNumeroFascicolo(@Param("numero") Integer numero, @Param("idFascicolo") Long idFascicolo)

    @Query('''select f.anno
          from Fascicolo f 
          where f.id = :idDocumento
         ''')
    Integer getAnnoFascicolo(@Param("idDocumento") Long idDocumento)

    /**
     * Ritorna una lista di sotto fascicoli dato un id fascicolo.
     *
     * @param fascicolo
     * @return
     */
    @Query('''select f 
          from Fascicolo f 
          where f.idFascicoloPadre = :fascicolo 
         ''')
    List<Fascicolo> listSottoFascicoli(@Param("fascicolo") Long fascicolo)

    /**
     * Ritorna 0 se il protocollo non è smistato in una unità diversa da quella del fascicolo, altrimenti trona 1
     *
     * @param fascicolo
     * @param protocollo
     * @return
     */
    /*@Query('''select distinct count(1)
                from Smistamento s, Documento d
                where d.idDocumentoEsterno = :documento   
                and s.documento.id=d.id         
                and s.statoSmistamento != 'STORICO'
                and s.unitaSmistamento.progr  !=
                (
                    SELECT sm.unitaSmistamento.progr
                      FROM Smistamento sm, Fascicolo  f
                      WHERE f.id = :fascicolo
                    AND sm.documento.id = f.id
                    AND sm.tipoSmistamento = 'COMPETENZA'
                    AND sm.statoSmistamento != 'STORICO'
                   )
         ''')*/

    @Query('''select distinct count(1)
                    from Smistamento sm, Fascicolo  f
                    where f.id = :fascicolo
                    and sm.documento.id = f.id
                    and sm.tipoSmistamento = 'COMPETENZA'
                    and sm.statoSmistamento != 'STORICO'
                    and sm.unitaSmistamento.progr not in
                    (
                        select s.unitaSmistamento.progr
                        from Smistamento s, Documento d
                        where d.idDocumentoEsterno = :documento   
                        and s.documento.id=d.id         
                        and s.statoSmistamento != 'STORICO'
                    )  and exists (
                        select s.unitaSmistamento.progr
                        from Smistamento s, Documento d
                        where d.idDocumentoEsterno = :documento   
                        and s.documento.id=d.id         
                        and s.statoSmistamento != 'STORICO'                  
                    )      
         ''')
    Integer checkUbicazioneVsFascicolo(@Param("fascicolo") Long fascicolo, @Param("documento") Long documento)
    /**
     * Ritorna una lista di fascicoli con numerazione maggiore dato numero, anno, classifica.
     *
     * @param fascicolo
     * @return
     */
    @Query('''select f 
          from Fascicolo f 
          where f.classificazione=:classificazione
            and f.anno=:anno
            and f.numeroOrd > :numero
         ''')
    List<Fascicolo> listFascicoliAfterNumero(@Param("classificazione") Classificazione classificazione, @Param("anno") Integer anno, @Param("numero") String numero)

    /**
     * Verifica esistenza fascicolo per il ws aggiungi fascicoli secondari
     * Se esiste ritrona un fascicolo in base ai parametri ricevuti in input dal ws
     *
     * @param fascicolo
     * @return
     */
    @Query('''select f 
          from Fascicolo f 
          where f.classificazione.codice = :codiceClassifica
           and f.anno = :anno
           and f.numero = :numero      
           and f.ente.id = :idEnte      
         ''')
    Fascicolo getFascicoloPerWsFascicoliSecondari(@Param("codiceClassifica") String codiceClassifica, @Param("anno") Integer anno, @Param("numero") String numero, @Param("idEnte") Long idEnte)

    @Query('''select count(s.id)
          from Smistamento s 
          where s.documento.id = :idFascicolo
           and s.unitaSmistamento.progr = :progrUnita
           and s.tipoSmistamento = :tipoSmistamento
           and s.statoSmistamento in :statiSmistamento
           and ( exists ( select 1
                          from Protocollo p, Smistamento s2
                          where p.fascicolo.id = :idFascicolo
                                and  p.annullato <> 'Y'
                                and  s2.documento.id = p.id
                                and  s2.statoSmistamento in :statiSmistamento
                                and  s2.tipoSmistamento = :tipoSmistamento
                                and  s2.unitaSmistamento.progr <> :progrUnita )    
                     or exists (select 1
                             from MessaggioRicevuto mr, Smistamento s3
                             where mr.fascicolo.id = :idFascicolo
                              and  s3.documento.id = mr.id
                              and  s3.statoSmistamento in :statiSmistamento
                              and  s3.tipoSmistamento = :tipoSmistamento
                              and  s3.unitaSmistamento.progr <> :progrUnita )
                     or exists (select 1
                            from DocumentoTitolario dt, Smistamento s4
                            where dt.fascicolo.id = :idFascicolo
                            and  s4.documento.id = dt.id
                            and  s4.statoSmistamento in :statiSmistamento
                            and  s4.tipoSmistamento = :tipoSmistamento
                            and  s4.unitaSmistamento.progr <> :progrUnita) 
                  )   
         ''')
    Integer getSmistamentoFascicoloDocumentoInUnitaDiverse(@Param("idFascicolo") Long idFascicolo, @Param("progrUnita") Long progrUnita, @Param("tipoSmistamento") String tipoSmistamento, @Param("statiSmistamento") List<String> statiSmistamento)

    /**
     * Ritorna l'ubicazione con codice del fascicolo
     *
     * @param id
     * @return
     */
    @Query('''  select u.codice || ' - ' || u.descrizione
                from Smistamento s, Fascicolo f, So4UnitaPubb u
                where f.id = s.documento.id
                and f.id = :id
                and s.tipoSmistamento = 'COMPETENZA'
                and s.statoSmistamento in ('IN_CARICO', 'ESEGUITO', 'DA_RICEVERE') 
                and u.progr = s.unitaSmistamento.progr  
                and rownum = 1   
         ''')
    String getUbicazioneCodice(@Param("id") Long id)

    /**
     * Ritorna l'ubicazione del fascicolo
     *
     * @param id
     * @return
     */
    @Query('''  select u.descrizione
                from Smistamento s, Fascicolo f, So4UnitaPubb u
                where f.id = s.documento.id
                and f.id = :id
                and s.tipoSmistamento = 'COMPETENZA'
                and s.statoSmistamento in ('IN_CARICO', 'ESEGUITO', 'DA_RICEVERE') 
                and u.progr = s.unitaSmistamento.progr  
                and rownum = 1   
         ''')
    String getUbicazione(@Param("id") Long id)
}
