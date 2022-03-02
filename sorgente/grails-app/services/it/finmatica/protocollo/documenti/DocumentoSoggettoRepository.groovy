package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.soggetti.DocumentoSoggetto
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
interface DocumentoSoggettoRepository extends JpaRepository<DocumentoSoggetto, Long> {

    /**
     * Ritorna una So4UnitaPubb
     * @Param documento id
     * @Param tipoSoggetto
     *  @return
     */
    @Query('''select ds.unitaSo4
          from DocumentoSoggetto ds 
          where ds.documento.id = :documento
          and ds.tipoSoggetto = :tipoSoggetto 
         ''')
    So4UnitaPubb getUnita (@Param("documento") Long idDocumento, @Param("tipoSoggetto") String tipoSoggetto)


}