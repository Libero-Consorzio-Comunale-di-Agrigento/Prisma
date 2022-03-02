package it.finmatica.protocollo.documenti

import it.finmatica.gestionedocumenti.documenti.DocumentoCollegato
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.Indirizzo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.interoperabilita.ProtocolloDatiInteroperabilita
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.JpaSpecificationExecutor
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface ProtocolloRepository extends JpaRepository<Protocollo, Long>, JpaSpecificationExecutor<Protocollo> {

    /**
     * Ritorna tutti i protocolli modificati entro un certo range di date.
     *
     * @param dal
     * @param al
     * @return
     */
    @Query('''select ds.documento 
             from DocumentoStorico ds 
             join ds.documento p 
             join fetch p.tipoRegistro
             where treat(p as Protocollo).numero > 0 and ds.dateCreated >= :dal and ds.dateCreated <= :al 
             order by p.anno asc, p.numero asc
            ''')
    List<Protocollo> getProtocolliModificati(@Param("dal") Date dal, @Param("al") Date al);

    /**
     * Ritorna un protocollo passando numero, anno e registro emergenza.
     *
     * @param numeroEmergenza
     * @param annoEmergenza
     * @param registroEmergenza
     * @return
     */
    @Query('''select p 
          from Protocollo p 
          where p.numeroEmergenza = :numeroEmergenza  
          and p.annoEmergenza = :annoEmergenza 
          and p.registroEmergenza = :registroEmergenza 
        ''')
    Protocollo getProtocolloEmergenza(@Param("numeroEmergenza") int numeroEmergenza, @Param("annoEmergenza") int annoEmergenza, @Param("registroEmergenza") String registroEmergenza)

    /**
     * Ritorno un protocollo passando inizio e fine emergenza.
     *
     * @param dataInizioEmergenza
     * @param dataFineEmergenza
     * @return
     */
    @Query('''select p 
          from Protocollo p 
          where p.datiEmergenza.dataInizioEmergenza = :dataInizioEmergenza
          and p.datiEmergenza.dataFineEmergenza = :dataFineEmergenza
          and p.numero is not null and p.anno is not null
        ''')
    Protocollo getProtocolloDatiEmergenza(@Param("dataInizioEmergenza") Date dataInizioEmergenza, @Param("dataFineEmergenza") Date dataFineEmergenza)

    /**
     * Ritorna il protocollo precedente rispetto a quello passato come parametro tramite identificativo
     *
     * @param id
     * @param tipoCollegamento
     * @return
     */
    @Query('''select dc.collegato 
              from DocumentoCollegato dc 
              where dc.documento.id = :id  
              and dc.tipoCollegamento.codice = :tipoCollegamento
              and dc.valido = 'Y'
           ''')
    Protocollo getProtocolloPrecedente(@Param("id") Long id, @Param("tipoCollegamento") String tipoCollegamento)

    /**
     * Ritorna il protocollo successivo rispetto a quello passato come parametro tramite identificativo
     *
     * @param id
     * @param tipoCollegamento
     * @return
     */
    @Query('''select dc.documento
              from DocumentoCollegato dc 
              where
              dc.collegato.id = :id 
              and dc.tipoCollegamento.codice = :tipoCollegamento
              and dc.valido='Y'
              ''')
    List<Protocollo> getProtocolliSuccessivi(@Param("id") Long id, @Param("tipoCollegamento") String tipoCollegamento)

    /**
     * Ritorna un protocollo dato l'identificativo
     *
     * @param id
     * @return
     */
    @Query('''select p
                  from Protocollo p 
                  where id = :id  
               ''')
    Protocollo getProtocolloFromId(@Param("id") Long id)

    /**
     * Ritorna un protocollo dato l'identificativo
     *
     * @param id
     * @return
     */
    @Query('''select p
                  from Protocollo p 
                  where idDocumentoEsterno = :id  
               ''')
    Protocollo getProtocolloFromIdDocumentoEsterno(@Param("id") Long id)

    /**
     * Ritorna un protocollo di emergenza dato un protocollo figlio
     *
     * @param protocollo
     * @return
     */
    @Query('''select p
                  from Protocollo p, DocumentoCollegato dc 
                  where dc.collegato = :protocollo
                  and p.id=dc.documento.id
                  and p.datiEmergenza is not null
               ''')

    Protocollo getProtocolloEmergenzaFromFiglio(@Param("protocollo") Protocollo protocollo)

    /**
     * Ritorna una lista di doc protocolli collegati ad un doc protocollo privi di numerazione
     *
     * @param protocollo
     * @return
     */
    @Query('''select p
                  from Protocollo p, DocumentoCollegato dc 
                  where dc.documento = :protocollo
                  and p.id=dc.collegato.id
                  and p.numero is null
               ''')

    List<Protocollo> getListaCollegatiNonProtocollati(@Param("protocollo") Protocollo protocollo)

    /**
     * Ritorna il protocollo successivo rispetto a quello passato come parametro tramite identificativo
     *
     * @param id
     * @return
     */
    @Query('''select dc
              from DocumentoCollegato dc 
              where
              dc.collegato.id = :id 
              and dc.valido='Y'
              ''')
    List<DocumentoCollegato> getProtocolliSuccessivi(@Param("id") Long id)

    @Query('''select p
              from Protocollo p 
              where 
              p.id in :ids
              ''')
    List<Protocollo> findAllByIdInList(@Param("ids") List<Long> ids)

    @Query('''select p
              from Protocollo p 
              where 
              p.numero = :numero
              and p.anno = :anno
              and p.tipoRegistro.codice = :tipoRegistro
              ''')
    Protocollo findByAnnoAndNumeroAndTipoRegistro(@Param("anno") Integer anno, @Param("numero") Integer numero, @Param("tipoRegistro") String tipoRegistro)

    @Query('''select p
              from Protocollo p 
              where 
              p.numero = :numero
              and p.data = :data
              and p.tipoRegistro.codice = :tipoRegistro
              ''')
    Protocollo findByDataAndNumeroAndTipoRegistro(@Param("data") Date data, @Param("numero") Integer numero, @Param("tipoRegistro") String tipoRegistro)

    @Query('''select p
              from ProtocolloDatiInteroperabilita pIntero, Protocollo p
              where 
              pIntero.codiceAmmPrimaRegistrazione = :codAmmPrimaReg
              and pIntero.codiceAooPrimaRegistrazione = :codAooPrimaReg
              and pIntero.dataPrimaRegistrazione = :dataPrimaReg
              and pIntero.numeroPrimaRegistrazione = :numeroPrimaReg
              and pIntero.codiceRegistroPrimaRegistrazione = :codiceRegPrimaReg
              and p.datiInteroperabilita = pIntero.id
              ''')
    Protocollo fingByPrimaRegistrazione(@Param("codAmmPrimaReg") String codAmmPrimaReg,
                                        @Param("codAooPrimaReg") String codAooPrimaReg,
                                        @Param("dataPrimaReg") Date dataPrimaReg,
                                        @Param("numeroPrimaReg") String numeroPrimaReg,
                                        @Param("codiceRegPrimaReg") String codiceRegPrimaReg)

    /**
     * Dato l'id di un protocollo ed il tipo corrispondente restituisce l'indirizzo di tipo AMM del corrispondente filtrati
     * per tipo indirizzo AMM/AOO
     *
     * @param dal
     * @param al
     * @return
     */
    @Query('''select corr from Corrispondente corr, Indirizzo iAmm, Indirizzo iAoo
              where corr.protocollo.id = :idProtocollo and
                    corr.tipoCorrispondente = :tipoCorrispondente and
                    iAmm.corrispondente = corr and                    
                    iAoo.corrispondente = corr and
                    iAmm.tipoIndirizzo = 'AMM' and iAmm.codice = :codiceAmm and
                    iAoo.tipoIndirizzo = 'AOO' and iAoo.codice = :codiceAoo
     ''')
    Corrispondente getCorrispondenteDaIndirizzoAmmAoo(@Param("idProtocollo") Long idProtocollo,
                                                      @Param("tipoCorrispondente") String tipoCorrispondente,
                                                      @Param("codiceAmm") String codiceAmm,
                                                      @Param("codiceAoo") String codiceAoo);

    /**
     * Dato l'id di un protocollo ed il tipo corrispondente restituisce l'indirizzo di tipo AMM del corrispondente filtrati
     * per tipo indirizzo AMM
     *
     * @param dal
     * @param al
     * @return
     */
    @Query('''select corr from Corrispondente corr, Indirizzo i
              where corr.protocollo.id = :idProtocollo and
                    corr.tipoCorrispondente = :tipoCorrispondente and
                    i.corrispondente = corr and                    
                    i.tipoIndirizzo = 'AMM' and codice = :codiceAmm
     ''')
    Corrispondente getCorrispondenteDaIndirizzoAmm(@Param("idProtocollo") Long idProtocollo,
                                                   @Param("tipoCorrispondente") String tipoCorrispondente,
                                                   @Param("codiceAmm") String codiceAmm);

    /**
     * verifica se il dato schema protocollo è utilizzato da almeno un protocollo
     * @param idSchemaProtocollo l'id dello schema da controllare
     * @return <code>          true</code> se lo schema è usato, <code>false</code> altrimenti
     */
    boolean existsProtocolloBySchemaProtocolloId(Long idSchemaProtocollo)

    /**
     * trovo il protocollo corripondente all'id esterno indicato
     * @param id l'id esterno del protocollo desiderato
     * @return il protocollo, se esiste
     */
    Protocollo findByIdDocumentoEsterno(Long id)
}
