package it.finmatica.protocollo.integrazioni.as4

import it.finmatica.ad4.dizionari.Ad4Comune
import it.finmatica.ad4.dizionari.Ad4Provincia
import it.finmatica.as4.As4SoggettoCorrente
import it.finmatica.as4.anagrafica.As4Anagrafica
import it.finmatica.as4.anagrafica.As4Contatto
import it.finmatica.as4.anagrafica.As4Recapito
import it.finmatica.as4.dizionari.As4TipoContatto
import it.finmatica.as4.dizionari.As4TipoRecapito
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface As4Repository extends JpaRepository<As4SoggettoCorrente, Long> {

    /**
     * Ritorna un soggettoCorrente dato il ni.
     *
     * @param ni
     * @return
     */
    @Query('''select s 
              from As4SoggettoCorrente s 
              where s.ni = :ni 
            ''')
    As4SoggettoCorrente getSoggettoCorrente(@Param("ni") Long ni)

    /**
     * Ritorna una lista di soggettoCorrente dato il codice fiscale.
     *
     * @param codiceFiscale
     * @return
     */
    @Query('''select s 
              from As4SoggettoCorrente s 
              where s.codiceFiscale = :codiceFiscale 
            ''')
    List<As4SoggettoCorrente> getListSoggettoCorrente(@Param("codiceFiscale") String codiceFiscale)

    /**
    * Ritorna una lista di Anagrafica se è stata modificata
    *
    * @param ni
    * @param cognome
    * @param codiceFiscale
    * @return
    */
    @Query('''select a 
              from As4Anagrafica a 
              where a.ni = :ni 
              and a.al is null
            ''')
    As4Anagrafica getAnagrafica(@Param("ni") Long ni)

    /**
     * Ritorna una lista di Anagrafica se è stata modificata
     *
     * @param ni
     * @param cognome
     * @param codiceFiscale
     * @return
     */
    @Query('''select a 
              from As4Anagrafica a 
              where a.ni = :ni 
              and a.al is null 
              and ( upper(a.cognome) <> upper(:cognome)
                   or coalesce(a.codFiscale,' ') <> coalesce(:codiceFiscale,' ')
              )
            ''')
    List<As4Anagrafica> isAnagraficaModificataIpa(@Param("ni") Long ni, @Param("cognome") String cognome, @Param("codiceFiscale") String codiceFiscale)

    /**
     * Ritorna un Tipo Recapito data la descrizione.
     *
     * @param descrizione
     * @return
     */
    @Query('''select t
              from As4TipoRecapito t 
              where t.descrizione = :descrizione 
            ''')
    As4TipoRecapito getTipoRecapito(@Param("descrizione") String descrizione)

    /**
     * Ritorna un Tipo Recapito data la descrizione.
     *
     * @param descrizione
     * @return
     */
    @Query('''select t
              from As4TipoContatto t 
              where t.descrizione = :descrizione 
            ''')
    As4TipoContatto getTipoContatto(@Param("descrizione") String descrizione)

    /**
     * Ritorna un Recapito data ni e tipoRecapito.
     *
     * @param ni
     * @param tipoRecapito
     * @return
     */
    @Query('''select r
              from As4Recapito r 
              where r.al is null
              and r.ni = :ni
              and r.tipoRecapito = :tipoRecapito  
            ''')
    As4Recapito getAs4Recapito(@Param("ni") Long ni,@Param("tipoRecapito") As4TipoRecapito tipoRecapito)

    /**
     * Ritorna un Contatto data Recapito e tipoContatto.
     *
     * @param recapito
     * @param tipoContatto
     * @return
     */
    @Query('''select c 
              from As4Contatto c 
              where c.al is null 
              and c.recapito = :recapito 
              and c.tipoContatto = :tipoContatto   
            ''')
    As4Contatto getAs4Contatto(@Param("recapito") As4Recapito recapito, @Param("tipoContatto") As4TipoContatto tipoContatto)

    /**
     * Ritorna una lista di Recapiti se è stato modificato
     *
     * @param ni
     * @param tipoRecapito
     * @param indirizzo
     * @param cap
     * @param provincia
     * @param comune
     * @return
     */
    @Query('''select r 
              from As4Recapito r 
              where r.al is null
              and r.ni = :ni
              and r.tipoRecapito = :tipoRecapito 
              and ( upper(r.indirizzo) <> upper(:indirizzo)
                   or upper(r.cap) <> upper(:cap)
                   or r.provincia <> :provincia
                   or r.comune <> :comune
              )
            ''')
    List<As4Recapito> isRecapitoModificatoIpa(@Param("ni") Long ni, @Param("tipoRecapito") As4TipoRecapito tipoRecapito, @Param("indirizzo") String indirizzo, @Param("cap") String cap, @Param("provincia") Ad4Provincia provincia, @Param("comune") Ad4Comune comune)

    /**
     * Ritorna una lista di Contatti se è stato modificato
     *
     * @param recapito
     * @param tipoContatto
     * @param valore
     * @return
     */
    @Query('''select c 
              from As4Contatto c 
              where c.recapito = :recapito
              and c.tipoContatto = :tipoContatto
              and upper(c.valore) <> upper(:valore)
            ''')
    List<As4Contatto> isContattoModificatoIpa(@Param("recapito") As4Recapito recapito, @Param("tipoContatto") As4TipoContatto tipoContatto, @Param("valore") String valore)


    /**
     * Ritorna la lista dei recapiti data un'anagrafica
     *
     * @param ni
     * @return
     */
    @Query('''select r
              from As4Recapito r 
              where r.al is null
              and r.ni = :ni  
            ''')
    List<As4Recapito> getAs4Recapiti(@Param("ni") Long ni)

    /**
     * Ritorna la lista dei recapiti data un'anagrafica
     *
     * @param ni
     * @return
     */
    @Query('''select c
              from As4Contatto c
              where c.al is null
              and c.recapito.id = :idRecapito  
            ''')
    List<As4Contatto> getAs4Contatti(@Param("idRecapito") Long idRecapito)


}
