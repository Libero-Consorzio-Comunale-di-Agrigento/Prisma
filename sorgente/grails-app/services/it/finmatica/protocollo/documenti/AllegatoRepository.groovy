package it.finmatica.protocollo.documenti

import it.finmatica.gestionedocumenti.documenti.Allegato
import it.finmatica.gestionedocumenti.documenti.FileDocumento
import it.finmatica.gestionedocumenti.documenti.TipoCollegamento
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface AllegatoRepository extends JpaRepository<Allegato, Long> {

    /**
     * Ritorna un Allegato dato l'id.
     *
     * @return
     */
    @Query('''select a
              from Allegato a
              where id = :id
              ''')
    Allegato getAllegatoFromId(@Param("id") Long id)

    /**
     * Ritorna una lista di FileDocumento passanto id documento e codice.
     *
     * @return
     */
    @Query('''select fd
              from FileDocumento fd
              where documento.id = :idDocumento
              and codice = :codice
              order by id
              ''')
    List<FileDocumento> getFileDocumenti (@Param("idDocumento") Long idDocumento, @Param("codice") String codice)

    /**
     * Ritorna una lista di FileDocumento passanto id documento .
     *
     * @return
     */
    @Query('''select fd
              from FileDocumento fd
              where documento.id = :idDocumento
              order by id
              ''')
    List<FileDocumento> getFileDocumentiValidi (@Param("idDocumento") Long idDocumento)

    /**
     * Ritorna una lista di FileDocumento passanto id documento e codice.
     *
     * @return
     */
    @Query('''select fd
              from FileDocumento fd
              where documento.id = :idDocumento
              and codice in :codici
              order by id
              ''')
    List<FileDocumento> getFileDocumenti (@Param("idDocumento") Long idDocumento, @Param("codici") List<String> codici)

}
