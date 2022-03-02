package it.finmatica.protocollo.smistamenti

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.protocollo.dizionari.AbilitazioneSmistamento
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface SmistamentoRepository extends JpaRepository<Smistamento, Long> {
    /**
     * Ritorna l'abilitazione smistamento dato il tipo lo stato e l'azione.
     *
     * @param tipoSmistamento
     * @param statoSmistamento
     * @param azione
     * @return
     */
    @Query('''select a
          from AbilitazioneSmistamento a
          where a.tipoSmistamento = :tipoSmistamento and
                a.statoSmistamento = :statoSmistamento and
                a.azione = :azione
        ''')
    List<AbilitazioneSmistamento> getAbilitazioneSmistamento(@Param("tipoSmistamento") String tipoSmistamento,
                                                             @Param("statoSmistamento") String statoSmistamento,
                                                             @Param("azione") String azione)

    @Query('''SELECT s 
          FROM Smistamento  as s
          WHERE s.idDocumentoEsterno = :id''')
    Smistamento findByIdDocumentoEsterno(@Param("id")Long idDocumentoEsterno)

}