package it.finmatica.protocollo.integrazioni.ad4

import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.ad4.dizionari.Ad4Regione
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface Ad4ComuniProvincieRegioniRepository extends JpaRepository<Ad4Provincia, String> {

    /**
     * Ritorna una Comune dato la denominazione
     *
     * @param sigla
     * @return
     */
    @Query('''select c 
              from Ad4Comune c 
              where c.denominazione = :denominazione
              and c.dataSoppressione is null
              and c.provincia is not null
            ''')
    Ad4Comune getComune(@Param("denominazione") String denominazione)

    /**
     * Ritorna una Comune dato la denominazione e la provincia
     *
     * @param sigla
     * @return
     */
    //@Query('''select c
    //          from Ad4Comune c
    //          where c.denominazione = :denominazione
    //          and c.dataSoppressione is null
    //          and c.provincia = :provincia
    //        ''')
    //Ad4Comune getComune(@Param("denominazione") String denominazione, @Param("provincia") Ad4Provincia provincia)

    /**
     * Ritorna una Comune dato la denominazione e la regione
     * utilizzato per scarico ipa
     *
     * @param sigla
     * @return
     */
    @Query('''select c 
              from Ad4Comune c 
              where c.denominazione = :denominazione
              and c.dataSoppressione is null
              and c.provincia.regione = :regione
              order by c.id desc
            ''')
    List<Ad4Comune> getComune(@Param("denominazione") String denominazione, @Param("regione") Ad4Regione regione)

    /**
     * Ritorna una Provincia dato la sigla
     *
     * @param sigla
     * @return
     */
    @Query('''select p 
              from Ad4Provincia p 
              where p.sigla = :sigla
            ''')
    Ad4Provincia getProvincia(@Param("sigla") String sigla)

    /**
     * Ritorna una Regione dato la denominazione
     *
     * @param sigla
     * @return
     */
    @Query('''select r 
              from Ad4Regione r 
              where r.denominazione = :denominazione
            ''')
    Ad4Regione getRegione(@Param("denominazione") String denominazione)
}
