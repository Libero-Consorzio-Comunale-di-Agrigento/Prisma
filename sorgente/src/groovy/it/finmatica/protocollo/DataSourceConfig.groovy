package it.finmatica.protocollo

import groovy.transform.CompileStatic
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.boot.autoconfigure.jdbc.DataSourceBuilder
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

import javax.sql.DataSource

/**
 * I bean definiti in questa classe servono in particolare per l'ambiente di sviluppo:
 * Vengono configurati leggendo le connessioni specificate nel file confapps/application.properties
 * Vengono sovrascritti (quando in presenza di un NamingContext, ad esempio in produzione su un tomcat) dai bean definiti in JndiDataSourceConfig.
 */
@CompileStatic
@Configuration
class DataSourceConfig {

    /**
     * Il dataSource principale non proxato. Punta alla connessione verso AGSPR. Serve per la connessione al db da usare in sviluppo
     * NON va usato nei service.
     * Questo bean viene usato da Hibernate e da JPA.
     * @return
     */
    @ConditionalOnMissingBean(name=TransactionManagerConfig.DATA_SOURCE_AGSPR)
    @ConfigurationProperties(prefix = "spring.datasource")
    @Bean(TransactionManagerConfig.DATA_SOURCE_AGSPR)
    DataSource unproxiedDataSource() {
        return DataSourceBuilder.create().build()
    }

    /**
     * Il DataSource che punta verso GDM NON collegato alla transazione.
     * Questo bean serve per configurare correttamente il transactionManager di gdm.
     * @return
     */
    @ConditionalOnMissingBean(name=TransactionManagerConfig.DATA_SOURCE_GDM)
    @Bean(TransactionManagerConfig.DATA_SOURCE_GDM)
    @ConfigurationProperties(prefix = "spring.datasources.gdm")
    DataSource unproxiedDataSourceGdm() {
        return DataSourceBuilder.create().build()
    }

    /**
     * Il DataSource che punta verso JWF NON collegato alla transazione.
     * Questo bean serve per configurare correttamente il transactionManager di jwf.
     * @return
     */
    @ConditionalOnMissingBean(name=TransactionManagerConfig.DATA_SOURCE_JWF)
    @Bean(TransactionManagerConfig.DATA_SOURCE_JWF)
    @ConfigurationProperties(prefix = "spring.datasources.jwf")
    DataSource unproxiedDataSourceJwf() {
        return DataSourceBuilder.create().build()
    }

    /**
     * Connessione verso AD4. Questo dataSource NON è collegato alla transazione corrente. Se si ottiene una connessione da questo dataSource, va chiusa manualmente, ad es:
     * try {*     connection = ad4DataSource.getConnection()
     *} finally {*     connection?.close()
     *}* @return
     */
    @ConditionalOnMissingBean(name=TransactionManagerConfig.DATA_SOURCE_AD4)
    @ConfigurationProperties(prefix = "spring.datasources.ad4")
    @Bean
    DataSource ad4DataSource() {
        return DataSourceBuilder.create().build()
    }
}
