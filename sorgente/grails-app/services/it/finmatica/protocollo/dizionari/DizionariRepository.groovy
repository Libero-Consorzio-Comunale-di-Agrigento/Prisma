package it.finmatica.protocollo.dizionari

import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.documenti.TipoAllegato
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestioneiter.configuratore.dizionari.WkfTipoOggetto
import it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter
import it.finmatica.protocollo.corrispondenti.TipoSoggetto
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface DizionariRepository extends JpaRepository<TipoSoggetto, Long> {

    /**
     * Ritorna il tipo soggetto dato la descrizione.
     *
     * @param descrizione
     * @return
     */
    @Query('''select t
          from TipoSoggetto t 
          where t.descrizione = :descrizione
        ''')
    TipoSoggetto getTipoSoggetto(@Param("descrizione") String descrizione)

    /**
     * Ritorna una lista di Modalità Invio Ricezione.
     *
     * @return
     */
    @Query('''select m 
              from ModalitaInvioRicezione m 
              ''')
    List<ModalitaInvioRicezione> getListModalitaInvioRicezione()

    /**
     * Ritorna la modalità invio ricezione dato codice e validita.
     *
     * @param codice
     * @return
     */
    @Query('''select m 
          from ModalitaInvioRicezione m 
          where m.codice = :codice 
        ''')
    ModalitaInvioRicezione getModalitaInvioRicezione(@Param("codice") String codice)

    /**
     * Ritorna la modalità invio ricezione dato l'id.
     *
     * @param idModalitaInvioRicezione
     * @return
     */
    @Query('''select m 
          from ModalitaInvioRicezione m 
          where m.id = :idModalitaInvioRicezione 
        ''')

    ModalitaInvioRicezione getModalitaInvioRicezioneFromId(@Param("idModalitaInvioRicezione") Long idModalitaInvioRicezione)

    /**
     * Ritorna la modalità invio ricezione dato l'id del protocollo.
     *
     * @param codice
     * @return
     */
    @Query('''select modalitaInvioRicezione 
          from Protocollo p 
          where p.id = :idProtocollo 
        ''')

    ModalitaInvioRicezione getModalitaInvioRicezioneFromIdProtocollo(@Param("idProtocollo") Long idProtocollo)

    /**
     * Ritorna il tipo collegamento dato il codice.
     *
     * @param codice
     * @return
     */
    @Query('''select t 
              from TipoCollegamento t 
              where t.codice = :codice
            ''')
    TipoCollegamento getTipoCollegamento(@Param("codice") String codice)

    /**
     * Ritorna il tipo protocollo dato la categoria.
     *
     * @param categoria
     * @return
     */
    @Query('''select t 
              from TipoProtocollo t 
              where t.categoria = :categoria
              and predefinito = true
            ''')
    TipoProtocollo getTipoProtocollo(@Param("categoria") String categoria)

    @Query('''select t 
              from TipoProtocollo t 
              where t.codice = :codice
            ''')
    TipoProtocollo getTipoProtocolloDefault(@Param("codice") String codice)

    /**
     * Ritorna lo schema protocollo dato il codice.
     *
     * @param codice
     * @return
     */
    @Query('''select s 
          from SchemaProtocollo s 
          where s.codice = :codice 
        ''')
    SchemaProtocollo getSchemaProtocollo(@Param("codice") String codice)

    /**
     * Ritorna il tipo registro dato il codice.
     *
     * @param codice
     * @return
     */
    @Query('''select t 
          from TipoRegistro t
          where t.codice = :codice 
        ''')
    TipoRegistro getTipoRegistro(@Param("codice") String codice)

    /**
     * FIXME non è univoco
     * @param codice
     * @return
     */
    @Query('''select t 
          from TipoAllegato t
          where t.codice = :codice 
        ''')
    TipoAllegato getTipoAllegato(@Param("codice") String codice)

    @Query('''select t 
          from TipoAllegato t
          where t.acronimo = :acronimo 
        ''')
    TipoAllegato getTipoAllegatoDaAcronimo(@Param("acronimo") String acronimo)

    @Query('''SELECT wk FROM WkfCfgIter wk JOIN FETCH wk.cfgStep stp JOIN FETCH stp.azioniIngresso WHERE wk.verificato = true AND wk.stato = it.finmatica.gestioneiter.configuratore.iter.WkfCfgIter.STATO_IN_USO 
        AND wk.progressivo = :progressivo ''')
    WkfCfgIter getIterIstanziabile(@Param("progressivo") Long progressivoCfgIter)

    @Query('''SELECT wk FROM WkfTipoOggetto wk WHERE wk.codice = :codice''')
    WkfTipoOggetto getTipoOggetto(@Param("codice") String codice)

    @Query(value = 'SELECT e FROM Ente e join e.amministrazione amm WHERE amm.codice = :codice')
    Ente findEnteByCodice(@Param('codice') String codice)

    @Query(value = 'SELECT e FROM Ente e join e.amministrazione amm WHERE amm.codice = :codice AND e.aoo = :aoo')
    Ente findEnteByCodiceAndAoo(@Param('codice') String codice, @Param('aoo') String aoo)

    @Query(value = 'SELECT e FROM Ente e join fetch e.amministrazione amm WHERE e.id = :id')
    Ente findEnteById(@Param('id') Long id)
}


