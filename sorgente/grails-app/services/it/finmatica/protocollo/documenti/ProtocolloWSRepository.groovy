package it.finmatica.protocollo.documenti

import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.documenti.Protocollo
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.JpaSpecificationExecutor
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface ProtocolloWSRepository extends JpaRepository<ProtocolloWS, Long> {


    /**
     * Ritorno un protocolloWS passando anno, numero e tipoRegistro
     *
     * @param anno
     * @param numero
     * @param tipoRegistro
     * @return
     */
    @Query('''select pws
              from ProtocolloWS pws
              where pws.anno = :anno
              and pws.numero = :numero
              and pws.tipoRegistro = :tipoRegistro              
        ''')
    ProtocolloWS findByAnnoAndNumeroAndTipoRegistro(@Param("anno") Integer anno, @Param("numero") Integer numero, @Param("tipoRegistro") String tipoRegistro)



}
