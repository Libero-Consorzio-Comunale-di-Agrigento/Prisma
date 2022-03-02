package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import it.finmatica.protocollo.dizionari.Fascicolo
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface DocumentoCollegatoRepository extends JpaRepository<DocumentoCollegato, Long> {

    /**
     * Ritorna una lista di collegamenti
     * @Param tipiUtilizzabili* @Param protocollo* @return
     */
    @Query('''select dc 
          from DocumentoCollegato dc 
          where dc.tipoCollegamento not in :tipiNonVisibili and (dc.documento = :protocollo or dc.collegato = :protocollo) 
         ''')
    List<DocumentoCollegato> collegamentiVisibili(@Param("protocollo") Protocollo protocollo, @Param("tipiNonVisibili") List<TipoCollegamento> tipiNonVisibili)

    /**
     * Ritorna una lista di collegamenti
     * @Param tipiUtilizzabili* @Param fascicolo* @return
     */
    @Query('''select dc 
          from DocumentoCollegato dc 
          where dc.tipoCollegamento.codice in :tipiVisibili and (dc.documento = :fascicolo or dc.collegato = :fascicolo)
          order by dc.id desc 
         ''')
    List<DocumentoCollegato> collegamentiVisibiliFascicolo(@Param("fascicolo") Fascicolo fascicolo, @Param("tipiVisibili") List<String> tipiVisibili)

    /**
     * Ritorna una lista di collegamenti
     * @Param tipoCollegamento
     * @Param documento
     * @return
     */
    @Query('''select dc 
          from DocumentoCollegato dc 
          where dc.tipoCollegamento = :tipoCollegamento and dc.documento = :documento
         ''')
    List<DocumentoCollegato> collegamentiPerTipologia(@Param("documento") Documento documento, @Param("tipoCollegamento") TipoCollegamento tipoCollegamento)

/**
 * Ritorna una lista di collegamenti
 * @Param tipoCollegamento* @Param protocollo* @return
 */
    @Query('''select dc 
          from DocumentoCollegato dc 
          where dc.documento = :protocollo
         ''')
    List<DocumentoCollegato> collegamenti(@Param("protocollo") Documento documento)

    /**
     * Dato un collegato ed una tipologia di collegamento, restituisce il documento padre
     * @Param tipoCollegamento* @Param protocollo* @return
     */
    @Query('''select dc 
          from DocumentoCollegato dc 
          where dc.tipoCollegamento = :tipoCollegamento and dc.collegato = :collegato
         ''')
    DocumentoCollegato collegamentoPadrePerTipologia(@Param("collegato") Documento collegato, @Param("tipoCollegamento") TipoCollegamento tipoCollegamento)

    /**
     * Dato un collegato ed una tipologia di collegamento, restituisce il documento padre
     * @Param tipoCollegamento* @Param protocollo* @return
     */
    @Query('''select dc 
          from DocumentoCollegato dc 
          where dc.collegato = :collegato
         ''')
    DocumentoCollegato collegamentoPadre(@Param("collegato") Documento collegato)

    /**
     * Dato un documento, collegato ed una tipologia di collegamento, restituisce il documentoCollegato
     * @Param documento* @Param collegato* @Param tipologia* @return
     */
    @Query('''select dc 
          from DocumentoCollegato dc 
          where dc.tipoCollegamento = :tipoCollegamento 
          and (
          (dc.collegato = :collegato and dc.documento = :documento)
          or
          (dc.collegato = :documento and dc.documento = :collegato)
          )
         ''')
    DocumentoCollegato getVerificaCollegamento(@Param("documento") Documento documento, @Param("collegato") Documento collegato, @Param("tipoCollegamento") TipoCollegamento tipoCollegamento)
}