package it.finmatica.protocollo.documenti.titolario

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.Allegato
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface DocumentoTitolarioRepository extends JpaRepository<DocumentoTitolario,Long> {

    /**
     * Ritorna un DocumentoTitolario
     * @Param idDocumento
     * @Param idFasciolo
     * @Param idClassifica
     *
     * @return
     */
    @Query('''select dt
              from DocumentoTitolario dt
              where dt.documento.id = :idDocumento
              and dt.fascicolo.id = :idFasciolo
              and dt.classificazione.id = :idClassifica
              ''')
    DocumentoTitolario getDocumentoTitolario(@Param("idDocumento") Long idDocumento,@Param("idFasciolo") Long idFasciolo,@Param("idClassifica") Long idClassifica)



}