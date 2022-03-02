package it.finmatica.protocollo.titolario

import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface TitolarioRepository extends JpaRepository<DocumentoTitolario, Long> {

      /**
     * Ritorna un DocumentoTitolario dato documento, classifica e fascicolo.
     *
     * @param documento
     * @param classifica
     * @param fascicolo
     * @return
     */
    @Query('''select dt
          from DocumentoTitolario dt 
          where dt.documento = :documento and dt.classificazione=:classificazione
          and dt.fascicolo =:fascicolo 
         ''')
    Fascicolo getDocumentoTitolario(@Param("documento") Documento documento, @Param("classificazione") Classificazione classificazione, @Param("fascicolo") Fascicolo fascicolo)

}
