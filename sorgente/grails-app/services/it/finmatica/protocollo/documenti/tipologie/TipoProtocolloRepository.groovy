package it.finmatica.protocollo.documenti.tipologie

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param


interface TipoProtocolloRepository extends JpaRepository<TipoProtocollo, Long> {

    /**
     *
     * Ritorna una lista di TipoProtocollo validi, senza schema protocollo associato e con iter.
     *
     * @return
     */
    @Query('''select tp
              from TipoProtocollo tp
              where tp.schemaProtocollo is null
              and tp.valido = 'Y'
              and tp.progressivoCfgIter is not null
         ''')
    List<TipoProtocollo> findAllByValidoAndSchemaProtocolloAndProgressivoCfgIterIsNotNull()

    /**
     *
     * Ritorna una lista di TipoProtocollo validi, senza schema protocollo associato e senzaIter iter.
     *
     * @return
     */
    @Query('''select tp
              from TipoProtocollo tp
              where tp.categoria = :categoria
              and tp.valido = 'Y'
              and (tp.progressivoCfgIter is null
                    or tp.progressivoCfgIter = 0)
         ''')
    List<TipoProtocollo> findAllByCategoriaAndValidoAndProgressivoCfgIterIsNull(@Param("categoria") String categoria)
}