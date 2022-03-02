package it.finmatica.protocollo.integrazioni.gdm

import groovy.sql.Sql
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource

@Service
@Transactional(readOnly = true)
class DateService {

    private final DataSource dataSource

    DateService(DataSource dataSource) {
        this.dataSource = dataSource
    }

    /**
     * In diversi punti del codice devo ottenere la data del server Oracle perché può succedere che il tomcat e l'oracle non siano
     * allineati con la data. Siccome le librerie JProtocollo esistenti utilizzano la data di Oracle, con questa funzione ci adeguiamo
     * a questo meccanismo.
     *
     * @return
     */
    Date getCurrentDate() {
        return new Date(new Sql(dataSource).firstRow('select sysdate as DATA from dual').DATA.getTime())
    }
}
