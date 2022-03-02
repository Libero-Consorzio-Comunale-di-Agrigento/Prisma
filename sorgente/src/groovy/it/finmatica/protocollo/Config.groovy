package it.finmatica.protocollo

import com.jcabi.manifests.Manifests
import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.IGestoreFile
import it.finmatica.gestionedocumenti.impostazioni.Impostazioni
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioniMap
import it.finmatica.gestionedocumenti.integrazioni.documentale.IntegrazioneDocumentaleService
import it.finmatica.gestionedocumenti.notifiche.dispatcher.jworklist.NotificaJWorklistBuilder
import it.finmatica.gestionedocumenti.soggetti.IRegoleCalcoloSoggettiRepository
import it.finmatica.gestioneiter.configuratore.icone.IconePulsantiSource
import it.finmatica.protocollo.admin.AggiornamentoService
import it.finmatica.protocollo.documenti.beans.ProtocolloFileDownloader
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreCompetenze
import it.finmatica.protocollo.documenti.beans.ProtocolloGestoreEventiIter
import it.finmatica.protocollo.hibernate.RevisioneStoricoRegister
import it.finmatica.protocollo.impostazioni.ImpostazioniMapProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.integrazioni.firma.VerificaFirmaEventListener
import it.finmatica.protocollo.integrazioni.iter.ProtocolloIconeSource
import it.finmatica.protocollo.jobs.DocAreaCleanupJob
import it.finmatica.protocollo.jobs.ProtocolloJob
import it.finmatica.protocollo.jobs.ProtocolloJobExecutor
import it.finmatica.protocollo.jobs.RegistroGiornalieroJob
import it.finmatica.protocollo.jobs.RegistroGiornalieroJobExecutor
import it.finmatica.protocollo.jobs.ScaricoIpaJob
import it.finmatica.protocollo.jobs.ScaricoIpaJobExecutor
import it.finmatica.protocollo.notifiche.ProtocolloNotificaJWorklistBuilder
import it.finmatica.protocollo.security.InizializzaAgPrivUtenteTmpDopoLogin
import it.finmatica.protocollo.soggetti.RegoleCalcoloSoggettiConfig
import it.finmatica.protocollo.soggetti.RegoleCalcoloSoggettiProtocolloRespository
import it.finmatica.protocollo.startup.StartupApplicationListener
import it.finmatica.smartdoc.api.DocumentaleService
import org.hibernate.jpa.HibernateEntityManagerFactory
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Primary
import org.springframework.context.annotation.Profile
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.security.web.firewall.HttpFirewall
import org.springframework.security.web.firewall.StrictHttpFirewall
import org.springframework.web.multipart.commons.CommonsMultipartResolver

import javax.sql.DataSource

@CompileStatic
@Configuration
@EnableScheduling
class Config {

    @Bean
    RevisioneStoricoRegister revisioneStoricoRegister(HibernateEntityManagerFactory hibernateEntityManager, DataSource dataSource, DocumentaleService documentaleService) {
        return new RevisioneStoricoRegister(hibernateEntityManager, dataSource, documentaleService);
    }

    @Bean
    IconePulsantiSource iconePulsantiSource() {
        return new ProtocolloIconeSource()
    }

    @Bean
    RegoleCalcoloSoggettiConfig regoleDiCalcoloSoggettiConfig(List<IRegoleCalcoloSoggettiRepository> regoleCalcoloSoggettiRepositoryList) {
        return new RegoleCalcoloSoggettiConfig(regoleCalcoloSoggettiRepositoryList);
    }

    // configurazione dei job

    @Bean
    ProtocolloJob protocolloJob() {
        return new ProtocolloJob()
    }

    @Bean
    ProtocolloJobExecutor protocolloJobExecutor() {
        return new ProtocolloJobExecutor()
    }

    @Bean
    ScaricoIpaJob scaricoIpaJob() {
        return new ScaricoIpaJob()
    }

    @Bean
    ScaricoIpaJobExecutor scaricoIpaJobExecutor() {
        return new ScaricoIpaJobExecutor()
    }

    // configurazione dei vari bean del protocollo

    // questo bean si chiama così perché il DelegatinVariableResolver di ZK binda i bean per nome e non per tipo
    @Bean
    ProtocolloGestoreCompetenze gestoreCompetenze() {
        return new ProtocolloGestoreCompetenze()
    }

    // questo bean si chiama fileDownloader perché viene "bindato" con il nome nei viewmodel
    @Bean
    ProtocolloFileDownloader fileDownloader() {
        return new ProtocolloFileDownloader()
    }

    @Bean
    ProtocolloGestoreEventiIter protocolloGestoreEventiIter() {
        return new ProtocolloGestoreEventiIter()
    }

    @Bean
    ImpostazioniMapProtocollo impostazioniMapProtocollo(ImpostazioniMap impostazioniMap) {
        Impostazioni.map = impostazioniMap
        ImpostazioniProtocollo.map = impostazioniMap
        return new ImpostazioniMapProtocollo()
    }

    @Bean
    VerificaFirmaEventListener verificaFirmaEventListener() {
        return new VerificaFirmaEventListener()
    }

    @Bean
    RegoleCalcoloSoggettiProtocolloRespository regoleCalcoloSoggettiProtocolloRepository() {
        return new RegoleCalcoloSoggettiProtocolloRespository()
    }

    @Bean
    NotificaJWorklistBuilder protocolloNotificaJWorklistBuilder() {
        return new ProtocolloNotificaJWorklistBuilder()
    }

    // aggiungo il bean "gestoreFile" perché il DelegatingVariableResolver risolve i bean per nome e non per tipo
    @Primary
    @Bean
    IGestoreFile gestoreFile(IntegrazioneDocumentaleService integrazioneDocumentaleService) {
        return integrazioneDocumentaleService
    }

    @Bean
    InizializzaAgPrivUtenteTmpDopoLogin inizializzaAgPrivUtenteTmpDopoLogin(@Qualifier("dataSource_gdm") DataSource dataSource) {
        return new InizializzaAgPrivUtenteTmpDopoLogin(dataSource)
    }

    @Bean
    Manifests manifests() {
        return new Manifests()
    }

    @Profile("!test")
    @Bean
    StartupApplicationListener startupApplicationListener(AggiornamentoService aggiornamentoService) {
        return new StartupApplicationListener(aggiornamentoService);
    }

    @Bean
    RegistroGiornalieroJob registroGiornalieroJob() {
        return new RegistroGiornalieroJob()
    }

    @Bean
    RegistroGiornalieroJobExecutor registroGiornalieroJobExecutor() {
        return new RegistroGiornalieroJobExecutor()
    }

    //Questo bean andrebbe spostato sotto il file di config per spring security??
    //serve per includere come carattere valido nell'URL quello del %
    @Bean
    public HttpFirewall allowUrlEncodedPercentHttpFirewall() {
        StrictHttpFirewall firewall = new StrictHttpFirewall();
        firewall.setAllowUrlEncodedPercent(true);
        return firewall;
    }

    @Bean
    DocAreaCleanupJob docAreaCleanupJob() {
        return new DocAreaCleanupJob()
    }
}
