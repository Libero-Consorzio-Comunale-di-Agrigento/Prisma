package it.finmatica.protocollo.oracle;

import java.sql.Types;
import org.hibernate.dialect.Oracle10gDialect;

/**
 * Estendo l'oracle10g dialect perché non sempre dal cliente ho i driver giusti (ojdbc6) ma gli ojdbc4. Per questi
 * ultimi è necessario rimappare come il driver interpreta le colonne di tipo "Date"
 */
public class OracleDialect extends Oracle10gDialect {

    public OracleDialect() {
        super();
    }

    @Override
    protected void registerDateTimeTypeMappings() {
        registerColumnType(Types.DATE, "date");
        registerColumnType(Types.TIME, "date");
        registerColumnType(Types.TIMESTAMP, "date");
    }
}
