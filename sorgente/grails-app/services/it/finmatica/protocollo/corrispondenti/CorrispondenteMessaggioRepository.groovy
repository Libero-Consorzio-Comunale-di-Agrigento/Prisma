package it.finmatica.protocollo.corrispondenti

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface CorrispondenteMessaggioRepository extends JpaRepository<CorrispondenteMessaggio, Long> {

    @Query('''select cm
              from CorrispondenteMessaggio cm 
              where TRIM(LOWER(cm.email)) = TRIM(LOWER(:email)) and
                    messaggio=:messaggio
            ''')
    List<CorrispondenteMessaggio> getCorrispondentiMessaggio(@Param("messaggio") Messaggio messaggio,
                                                             @Param("email") String eMail)
}