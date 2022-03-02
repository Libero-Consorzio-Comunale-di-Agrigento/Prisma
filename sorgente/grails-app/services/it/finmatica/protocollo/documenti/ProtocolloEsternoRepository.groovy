package it.finmatica.protocollo.documenti


import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.integrazioni.ProtocolloEsterno
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface ProtocolloEsternoRepository extends JpaRepository<ProtocolloEsterno, Long> {


    /**
     *
     *
     * @return
     */
    @Query('''select p
          from ProtocolloEsterno p 
          where p.schemaProtocollo in :schemiDomandaCodici  
          and p.numero is not null 
          and p.anno is not null 
          and p.data is not null
          and p.utenteAggiornamento = :utenteAggiornamento
        ''')
    List<ProtocolloEsterno> getProtocolloEsterniDomande(@Param("schemiDomandaCodici") List<String> schemiDomandaCodici, @Param("utenteAggiornamento") String utenteAggiornamento)

    /**
     *
     *
     * @return
     */
    @Query('''select p 
          from ProtocolloEsterno p 
          where p.idDocumentoEsterno = :idDocumentoEsterno  
         ''')
    ProtocolloEsterno getProtocolloEsterno(@Param("idDocumentoEsterno") Long idDocumentoEsterno)
}
