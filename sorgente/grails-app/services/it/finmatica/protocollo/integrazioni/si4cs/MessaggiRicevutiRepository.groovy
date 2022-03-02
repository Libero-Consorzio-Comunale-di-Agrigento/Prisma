package it.finmatica.protocollo.integrazioni.si4cs

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface MessaggiRicevutiRepository extends JpaRepository<MessaggioRicevuto, Long> {
    /**
     * Ritorna una lista di messaggi ricevuti in base ai parametri impostati
     *
     * @param destinatari
     * @return
     */
    @Query('''select m
              from MessaggioRicevuto m
              where (destinatari like CONCAT('%',:destinatari,'%') or :destinatari is null) and
                    (mittente like CONCAT('%',:mittente,'%') or :mittente is null) and
                    trunc(dataRicezione) between trunc(:dal) and trunc(:al) and
                    (tipo = :tipoPosta or :tipoPosta = 'TUTTI') and
                    (oggetto like CONCAT('%',:oggetto,'%') or :oggetto is null) and
                    (statoMessaggio = :stato or :statoTutti='Y') 
              order by dataRicezione desc                    
            ''')
    List<MessaggioRicevuto> getListMessaggi(@Param("destinatari") String destinatari, @Param("mittente") String mittente,
                                            @Param("oggetto") String oggetto, @Param("dal") Date dal, @Param("al") Date al,
                                            @Param("tipoPosta") String tipoPosta,@Param("stato") MessaggioRicevuto.Stato stato,
                                            @Param("statoTutti") String statoTutti)
}