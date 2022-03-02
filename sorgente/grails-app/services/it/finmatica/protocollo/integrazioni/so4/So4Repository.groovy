package it.finmatica.protocollo.integrazioni.so4

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.so4.struttura.So4AOO
import it.finmatica.so4.struttura.So4Amministrazione
import it.finmatica.so4.struttura.So4IndirizzoTelematico
import it.finmatica.so4.struttura.So4Ottica
import it.finmatica.so4.struttura.So4UnitaId
import it.finmatica.so4.strutturaPubblicazione.So4ComponentePubb
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface So4Repository extends JpaRepository<So4UnitaPubb, So4UnitaId> {

    /**
     * Ritorna una lista di So4UnitaPubb dato il codice dell'ottica e la data di validità.
     *
     * @param codiceOttica
     * @param dataValidita
     * @return
     */

    @Query('''select u 
              from So4UnitaPubb u 
              where u.ottica.codice = :codiceOttica
              and coalesce(:dataValidita, current_date) >= u.dal
              and (u.al is null or coalesce(u.al, current_date) >= coalesce(:dataValidita, current_date))
              order by u.descrizione asc
            ''')
    List<So4UnitaPubb> getUnitaValide(@Param("codiceOttica") String codiceOttica, @Param("dataValidita") Date dataValidita)

    /**
     * Ritorna una lista di So4UnitaPubb dato il codice dell'ottica e la data di validità.
     *
     * @param codiceOttica
     * @param dataValidita
     * @return
     */

    @Query('''select u 
              from So4UnitaPubb u 
              where u.ottica.codice = :codiceOttica
              and coalesce(:dataValidita, current_date) >= u.dal
              and (u.al is null or coalesce(u.al, current_date) >= coalesce(:dataValidita, current_date))
              and ( ( upper(u.descrizione) like upper(:filtro) )  or ( upper(u.codice) like upper(:filtro)) ) 
              order by u.descrizione asc
            ''')
    List<So4UnitaPubb> getUnitaValideConFiltro(@Param("codiceOttica") String codiceOttica, @Param("dataValidita") Date dataValidita, @Param("filtro") String filtro)


    /**
     * Ritorna una So4UnitaPubb dato il progressivo, il codice dell'ottica e la data di validità.
     *
     * @param progressivo
     * @param codiceOttica
     * @param dataValidita
     * @return
     */

    @Query('''select u 
              from So4UnitaPubb u 
              where u.progr = :progressivo 
              and u.ottica.codice = :codiceOttica
              and coalesce(:dataValidita, current_date) >= u.dal
              and (u.al is null or coalesce(u.al, current_date) >= coalesce(:dataValidita, current_date))
            ''')
    So4UnitaPubb getUnita(@Param("progressivo") long progressivo, @Param("codiceOttica") String codiceOttica, @Param("dataValidita") Date dataValidita)

    /**
     * Ritorna una lista di So4UnitaPubb dato il progressivo io, il codice dell'ottica e la data di validità.
     *
     * @param progressivo
     * @param codiceOttica
     * @param dataValidita
     * @return
     */
    @Query('''select u 
              from So4UnitaPubb u 
              where u.progr = :progressivo 
              and u.ottica.codice = :codiceOttica
              and coalesce(:dataValidita, current_date) >= u.dal
              and (u.al is null or coalesce(u.al, current_date) >= coalesce(:dataValidita, current_date))
            ''')
    List<So4UnitaPubb> getListUnita(@Param("progressivo") long progressivo, @Param("codiceOttica") String codiceOttica, @Param("dataValidita") Date dataValidita)

    /**
     * Ritorna una lista di So4UnitaPubb valide dato un utente ed un privilegio
     *
     * @param utente
     * @param privilegio
     * @return
     */
    @Query('''select u 
              from So4UnitaPubb u , PrivilegioUtente p
              where p.utente = :utente and
                p.privilegio = :privilegio and
                p.progrUnita = u.progr and
                (p.dal <= current_date and coalesce( p.al , current_date) >= current_date) and
                (u.dal <= current_date and coalesce( u.al , current_date) >= current_date)  
            ''')
    List<So4UnitaPubb> getListUnita(@Param("utente") Ad4Utente utente, @Param("privilegio") String privilegio)

    /**
     * Ritorna una lista di So4UnitaPubb valide dato un utente ed un privilegio
     *
     * @param utente
     * @param privilegio
     * @return
     */
    @Query('''select distinct u 
              from So4UnitaPubb u , PrivilegioUtente p
              where p.utente = :utente and
                p.privilegio = :privilegio and
                p.progrUnita = u.progr 
                and (p.al is null or coalesce(p.al, current_date) >= coalesce(current_date, current_date)) 
                and (u.al is null or coalesce(u.al, current_date) >= coalesce(current_date, current_date))
                and ( ( upper(u.descrizione) like upper(:filtro) )  or ( upper(u.codice) like upper(:filtro)) )
                order by u.descrizione asc  
            ''')
    List<So4UnitaPubb> getListUnita(@Param("utente") Ad4Utente utente, @Param("privilegio") String privilegio, @Param("filtro") String filtro)

    /**
     * Ritorna un'ottica dato il codice.
     *
     * @param codice
     * @return
     */
    @Query('''select o 
              from So4Ottica o
              where o.codice = :codice 
            ''')
    So4Ottica getOttica(@Param("codice") String codice)

    /**
     * Ritorna una lista di So4ComponentePubb dato un soggettoCorrento, un ottica e una data di validità.
     *
     * @param soggettoCorrente
     * @param ottica
     * @param dataValidita
     * @return
     */
    @Query('''select c
              from So4ComponentePubb c
              where c.soggetto = :soggettoCorrente
              and c.ottica = :ottica
              and coalesce(:dataValidita, current_date) >= c.dal
              and (c.al is null or coalesce(c.al, current_date) <= coalesce(:dataValidita, current_date) )
             ''')
    List<So4ComponentePubb> getListComponente(@Param("soggettoCorrente") As4SoggettoCorrente soggettoCorrente, @Param("ottica") So4Ottica ottica, @Param("dataValidita") Date dataValidita)

    /**
     * Ritorna una lista di AOO dato il codice aoo e codice amm.
     *
     * @param aoo
     * @param amm
     * @return
     */
    @Query('''select a 
              from So4AOO a 
              where a.codice = :aoo 
              and a.amministrazione.codice = :amm
              and a.al is null 
            ''')
    List<So4AOO> getListAoo(@Param("aoo") String aoo, @Param("amm") String amm)

    /**
     * Ritorna una AOO dato il codice aoo e codice amm.
     *
     * @param aoo
     * @param amm
     * @return
     */
    @Query('''select a 
              from So4AOO a 
              where upper(a.codice) = upper(:aoo) 
              and upper(a.amministrazione.codice) = upper(:amm)
              and a.al is null 
            ''')
    So4AOO getAoo(@Param("aoo") String aoo, @Param("amm") String amm)

    /**
     * Ritorna una AOO dato il codice amm e la descrizione dell'AOO
     *
     * @param aoo
     * @param amm
     * @return
     */
    @Query('''select a 
              from So4AOO a 
              where upper(a.descrizione) = upper(:descrAoo) 
              and upper(a.amministrazione.codice) = upper(:amm)
              and a.al is null 
            ''')
    So4AOO getAooPerDescrizione(@Param("descrAoo") String descrAoo, @Param("amm") String amm)

    /**
     * Ritorna una AOO dato il codice aoo.
     *
     * @param aoo
     * @return
     */
    @Query('''select a 
              from So4AOO a 
              where upper(a.codice) = upper(:codice_aoo) 
              and a.al is null
            ''')
    So4AOO getAoo(@Param("codice_aoo") String codice_aoo)

    /**
     * Ritorna una AOO dato il codice aoo.
     *
     * @param aoo
     * @return
     */
    @Query('''select a 
              from So4AOO a 
              where upper(a.amministrazione.codice) = upper(:codice_amm) 
              and a.al is null
            ''')
    So4AOO getAooDefault(@Param("codice_amm") String codice_amm)

    /**
     * Ritorna una AOO dato il progressivo aoo
     *
     * @param progr_aoo
     * @return
     */
    @Query('''select a 
              from So4AOO a 
              where a.progr_aoo = :progr_aoo 
              and a.al is null 
            ''')
    So4AOO getAoo(@Param("progr_aoo") long progr_aoo)

    /**
     * Ritorna una lista di AOO se è stata modificata
     *
     * @param progr_aoo
     * @param d_dal
     * @param descrizione
     * @param indirizzo
     * @param cap
     * @param provincia
     * @param comune
     * @param telefono
     * @param fax
     * @return
     */
    @Query('''select a 
              from So4AOO a 
              where a.progr_aoo = :progr_aoo 
              and a.dal = :d_dal
              and ( a.descrizione <> :descrizione
                   or coalesce(a.indirizzo,' ') <> coalesce(:indirizzo,' ')
                   or coalesce(a.cap,'0') <> coalesce(:cap,'0')
                   or coalesce(a.provincia.provincia,0) <> coalesce(:provincia,0)
                   or coalesce(a.comune.id,0) <> coalesce(:comune,0)
                   or coalesce(a.telefono,' ') <> coalesce(:telefono,' ')
                   or coalesce(a.fax,' ') <> coalesce(:fax,' ')
              )
            ''')
    List<So4AOO> isAooModificataIpa(@Param("progr_aoo") Long progr_aoo, @Param("d_dal") Date d_dal, @Param("descrizione") String descrizione, @Param("indirizzo") String indirizzo, @Param("cap") String cap, @Param("provincia") Long provincia, @Param("comune") int comune, @Param("telefono") String telefono, @Param("fax") String fax)

    /**
     * Ritorna una lista di amministrazioni dato un codice.
     *
     * @param codice
     * @return
     */
    @Query('''select a 
              from So4Amministrazione a 
              where a.codice = :codice 
              and a.dataSoppressione is null
            ''')
    List<So4Amministrazione> getListAmministrazione(@Param("codice") String codice)

    /**
     * Ritorna un amministrazione dato un codice.
     *
     * @param codice
     * @return
     */
    @Query('''select a 
              from So4Amministrazione a 
              where a.codice = :codice 
              and a.dataSoppressione is null
            ''')
    So4Amministrazione getAmministrazione(@Param("codice") String codice)

    /**
     * Ritorna un soggettoCorrente dato il codice dell'amministrazione.
     *
     * @param codice
     * @return
     */
    @Query('''select a.soggetto 
              from So4Amministrazione a 
              where a.codice = :codice 
              and a.dataSoppressione is null
            ''')
    As4SoggettoCorrente getSoggettoAoo(@Param("codice") String codice)

    /**
     * Ritorna l'indirizzo dell'aoo
     *
     * @param progrAoo
     * @param delAoo
     * @param tipoIndirizzo
     * @return
     */
    @Query('''select i 
              from So4IndirizzoTelematico i   
              where i.tipoIndirizzo = :tipoIndirizzo
                and i.aoo.progr_aoo = :progrAoo 
                and i.aoo.dal = :dalAoo
                and i.tipoIndirizzo <> 'F'
                and tipo_entita='AO'
            ''')
    So4IndirizzoTelematico getIndirizzoAoo(@Param("tipoIndirizzo") String tipoIndirizzo,
                                           @Param("progrAoo") long progrAoo,
                                           @Param("dalAoo") Date dalAoo)

    /**
     * Ritorna l'indirizzo dell'uo
     *
     * @param unita
     * @param tipoIndirizzo
     * @return
     */
    @Query('''select i 
              from So4IndirizzoTelematico i   
              where ( i.tipoIndirizzo = :tipoIndirizzo or :tipoIndirizzo is null) and i.tipoIndirizzo <> 'F'
                and i.unita = :unita           
                and tipoEntita = 'UO'
            ''')
    List<So4IndirizzoTelematico> getListaIndirizzoUo(@Param("tipoIndirizzo") String tipoIndirizzo,
                                                     @Param("unita") So4UnitaPubb unita)

    /**
     * Ritorna l'indirizzo dell'uo
     *
     * @param unita
     * @param tipoIndirizzo
     * @return
     */
    @Query('''select i 
              from So4IndirizzoTelematico i,  So4UnitaPubb u
              where i.tipoIndirizzo <> 'F'
                and i.unita = u      
                and u.amministrazione = :amministrazione
                and u.codiceAoo = :codAoo    
                and tipo_entita='UO'    
                and u.dal <= current_date and coalesce( u.al , current_date) >= current_date
            ''')
    List<So4IndirizzoTelematico> getListaIndirizziUo(@Param("amministrazione") So4Amministrazione amministrazione,
                                                     @Param("codAoo") String codAoo)

    /**
     * Ritorna la lista di tutte le UO con un dato indirizzo per l'amm/aoo passati
     *
     * @param indirizzo
     * @param amministrazione
     * @param codAoo
     * @return
     */
    @Query('''select u 
              from So4IndirizzoTelematico i, So4UnitaPubb u
              where i.tipoIndirizzo <> 'F'
                and i.unita.progr = u.progr      
                and i.indirizzo = :indirizzo
                and u.amministrazione = :amministrazione
                and u.codiceAoo = :codAoo    
                and tipo_entita='UO'    
            ''')
    List<So4UnitaPubb> getListaUnitaIndirizzo(@Param("indirizzo") String indirizzo,
                                              @Param("amministrazione") So4Amministrazione amministrazione,
                                              @Param("codAoo") String codAoo)

    /**
     * Ritorna l'indirizzo telematico di una AOO
     *
     * @param tipoIndirizzo
     * @param ni
     * @return
     */
    @Query('''select i 
              from So4IndirizzoTelematico i   
              where i.tipoIndirizzo = :tipoIndirizzo
                and i.amministrazione.soggetto.ni = :ni 
                and tipo_entita='AO'
            ''')
    List<So4IndirizzoTelematico> getIndirizziAoo(@Param("tipoIndirizzo") String tipoIndirizzo,
                                                 @Param("ni") long ni)

    /**
     * Ritorna l'indirizzo telematico di una AMM
     *
     * @param tipoIndirizzo
     * @param ni
     * @return
     */
    @Query('''select i 
              from So4IndirizzoTelematico i   
              where i.tipoIndirizzo = :tipoIndirizzo
                and i.amministrazione.soggetto.ni = :ni 
                and tipo_entita='AM'
            ''')
    List<So4IndirizzoTelematico> getIndirizziAmm(@Param("tipoIndirizzo") String tipoIndirizzo,
                                                 @Param("ni") long ni)

    /**
     * Ritorna l'indirizzo telematico di una UO
     *
     * @param tipoIndirizzo
     * @param ni
     * @return
     */
    @Query('''select i 
              from So4IndirizzoTelematico i   
              where i.tipoIndirizzo = :tipoIndirizzo
                and i.unita.progr = :ni 
                and tipo_entita='UO'
            ''')
    List<So4IndirizzoTelematico> getIndirizziUo(@Param("tipoIndirizzo") String tipoIndirizzo,
                                                @Param("ni") long ni)

    @Query('''select u 
              from So4UnitaPubb u 
              where u.codice = :codice 
              and (u.al is null or coalesce(u.al, current_date) >=  current_date)
            ''')
    So4UnitaPubb getUnitaByCodiceSo4(@Param("codice") String codice)

    /**
     * Ritorna l'unità corrispondente al codice passato come paramtro SENZA controllo sulla validità
     *
     * @param codice
     * @return
     */
    @Query('''select u 
              from So4UnitaPubb u 
              where u.codice = :codice 
            ''')
    So4UnitaPubb getUnitaByCodiceSenzaControlloValiditaSo4(@Param("codice") String codice)
}