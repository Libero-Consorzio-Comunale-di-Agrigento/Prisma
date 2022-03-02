package it.finmatica.protocollo

import groovy.transform.CompileStatic
import org.hibernate.SessionFactory
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Primary
import org.springframework.data.transaction.CustomChainedTransactionManager
import org.springframework.jdbc.datasource.DataSourceTransactionManager
import org.springframework.jdbc.datasource.TransactionAwareDataSourceProxy
import org.springframework.orm.jpa.JpaTransactionManager
import org.springframework.orm.jpa.support.OpenEntityManagerInViewFilter
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.annotation.EnableTransactionManagement

import javax.persistence.EntityManagerFactory
import javax.sql.DataSource

@CompileStatic
@EnableTransactionManagement(proxyTargetClass = true)
@Configuration
class TransactionManagerConfig {

    public static final String DATA_SOURCE_AGSPR = "unproxiedDataSource"
    public static final String DATA_SOURCE_GDM = "unproxiedDataSourceGdm"
    public static final String DATA_SOURCE_JWF = "unproxiedDataSourceJwf"
    public static final String DATA_SOURCE_AD4 = "ad4DataSource"

    /**
     * DataSource principale. Punta alla connessione verso AGSPR.
     * È un TransactionAwareDataSource in modo tale da essere legato alla transazione corrente.
     * È possibile utilizzarlo quindi direttamente nel codice ad es: dataSource.getConnection() -> restituirà la connessione legata alla transazione corrente.
     * @return
     */
    @Bean
    @Primary
    DataSource dataSource(@Qualifier(TransactionManagerConfig.DATA_SOURCE_AGSPR) DataSource dataSource) {
        return new TransactionAwareDataSourceProxy(dataSource)
    }

    /**
     * Il DataSource che punta verso GDM, collegato alla transazione corrente.
     * È un TransactionAwareDataSource in modo tale da essere legato alla transazione corrente.
     * È possibile utilizzarlo quindi direttamente nel codice ad es: dataSource_gdm.getConnection() -> restituirà la connessione legata alla transazione corrente.
     * @return
     */
    @Bean("dataSource_gdm")
    DataSource dataSource_gdm(@Qualifier(TransactionManagerConfig.DATA_SOURCE_GDM) DataSource dataSource) {
        return new TransactionAwareDataSourceProxy(dataSource)
    }

    /**
    * Il DataSource che punta verso JWF, collegato alla transazione corrente.
    * È un TransactionAwareDataSource in modo tale da essere legato alla transazione corrente.
    * È possibile utilizzarlo quindi direttamente nel codice ad es: dataSource_gdm.getConnection() -> restituirà la connessione legata alla transazione corrente.
    * @return
    */
    @Bean("dataSource_jwf")
    DataSource dataSource_jwf(@Qualifier(TransactionManagerConfig.DATA_SOURCE_JWF) DataSource dataSource) {
        return new TransactionAwareDataSourceProxy(dataSource)
    }

    /**
     * TransactionManager primario: è il chained-transaction-manager che implementa il BE2PC (Best Effort 2 Phase Commit) che significa
     * che a meno di errori molto strani (ad es: caduta della connessione) questo bean garantisce la sincronizzazione delle commit sulle due connessioni AGSPR e GDM.
     * Questa configurazione è fondamentale per non avere dati disallineati tra AGSPR e GDM.
     * @param jpaTransactionManager
     * @param gdmTransactionManager
     * @return
     */
    @Primary
    @Bean
    PlatformTransactionManager transactionManager(JpaTransactionManager jpaTransactionManager, @Qualifier("transactionManager_gdm") PlatformTransactionManager gdmTransactionManager) {
        new CustomChainedTransactionManager(gdmTransactionManager, jpaTransactionManager)
    }

    /**
     * TransactionManager per JPA (connessione verso AGSPR)
     * @param jpaTransactionManager
     * @param gdmTransactionManager
     * @return
     */
    @Bean
    JpaTransactionManager jpaTransactionManager(EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory)
    }

    /**
     * TransactionManager per la connessione verso GDM
     * @param jpaTransactionManager
     * @param gdmTransactionManager
     * @return
     */
    @Bean
    PlatformTransactionManager transactionManager_gdm(@Qualifier(TransactionManagerConfig.DATA_SOURCE_GDM) DataSource dataSourceGdm) {
        return new DataSourceTransactionManager(dataSourceGdm)
    }

    /**
     * TransactionManager per la connessione verso JWF
     * @param jpaTransactionManager
     * @param gdmTransactionManager
     * @return
     */
    @Bean
    PlatformTransactionManager transactionManager_jwf(@Qualifier(TransactionManagerConfig.DATA_SOURCE_JWF) DataSource dataSourceJwf) {
        return new DataSourceTransactionManager(dataSourceJwf)
    }

    /**
     * Alcuni bean richiedono la SessionFactory di Hibernate per funzionare e non sono ancora "puri JPA", quindi
     * devo "esporre" la SessionFactory che sta "nascosta" dietro al EntityManagerFactory
     * @param entityManagerFactory
     * @return
     */
    @Bean
    SessionFactory sessionFactory(EntityManagerFactory entityManagerFactory) {
        return entityManagerFactory.unwrap(SessionFactory)
    }

    /**
     * Filtro che apre l'entityManager per le servlet gestite da zk.
     * Necessario per poter utilizzare i vari metodi .save, .findBy, .createCriteria direttamente nei ViewModel
     * Nota che questa è considerata una "bad practice" e bisognerebbe eliminare tutte le chiamate alle domain dai ViewModel
     * @return
     */
    @Bean
    FilterRegistrationBean openEntityManagerInViewFilter() {
        FilterRegistrationBean reg = new FilterRegistrationBean(new OpenEntityManagerInViewFilter())
        reg.setEnabled(true)
        reg.setName("OpenEntityManagerInViewFilter")
        reg.setUrlPatterns(Arrays.asList("/zkau", "/zkau*", "/zkau/*", "*.zul", "*.zhtml", "/zkcomet/*"))
        return reg
    }
}
