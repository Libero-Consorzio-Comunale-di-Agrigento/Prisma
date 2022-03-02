package it.finmatica.protocollo.hibernate;

import groovy.sql.GroovyRowResult;
import groovy.sql.Sql;
import it.finmatica.gestionedocumenti.Holders;
import it.finmatica.protocollo.integrazioni.EnversRevisionEntity;
import java.sql.SQLException;
import java.util.Date;
import javax.sql.DataSource;
import oracle.sql.TIMESTAMP;
import oracle.sql.TIMESTAMPTZ;
import org.hibernate.envers.RevisionListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SqlDateRevisionListener implements RevisionListener {

    private static final Logger log = LoggerFactory.getLogger(SqlDateRevisionListener.class);

    static Date getCurrentDate() {
        try {
            DataSource dataSource = Holders.getApplicationContext().getBean(DataSource.class);
            Sql sql = new Sql(dataSource);

            // Nota bene: uso la funzione "LOCALTIMESTAMP" perché ritorna un oracle.sql.TIMESTAMP che è convertibile in java.sql.Timestamp.
            // la funzione systimestamp invece ritornerebbe un oracle.sql.TIMESTAMPTZ che non è convertibile in java.sql.Timestamp.
            GroovyRowResult result = sql.firstRow("select LOCALTIMESTAMP as DATA from dual");
            // il driver oracle *non* segue lo standard JDBC e invece di ritornare un java.sql.Timestamp ritorna un
            // oracle.sql.TIMESTAMP. C'è modo di fargli ritornare un java.sql.Timestamp ma è una impostazione a livello di JVM, quindi
            // non la metto per evitare di spaccare qualcos'altro.
            // Grazie Oracle.
            TIMESTAMP timestamptz = (TIMESTAMP) result.get("DATA");
            return timestamptz.timestampValue();
        } catch (SQLException e) {
            log.error("Errore nel recuperare la data corrente dal db.", e);
            return new Date();
        }
    }

    @Override
    public void newRevision(Object revisionEntity) {
        EnversRevisionEntity rev = (EnversRevisionEntity) revisionEntity;
        rev.setRevtstmp(getCurrentDate());
    }
}
