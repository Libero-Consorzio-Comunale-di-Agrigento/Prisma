package it.finmatica.protocollo.jobs

import it.finmatica.jobscheduler.ScheduledJob
import it.finmatica.protocollo.integrazioni.JasperReportsService
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Transactional
@Service
class RegistroProtocolloJob implements ScheduledJob {
    private final JasperReportsService jasperReportsService

    RegistroProtocolloJob(JasperReportsService jasperReportsService) {
        this.jasperReportsService = jasperReportsService
    }

    @Override
    void run(long idJobLog) {
        // faccio login e scelgo l'ente

        // creo le stampe di registro
        Date oggi = new Date().clearTime()
        File registroGiornalieroModifiche = File.createTempFile("registro_giornaliero", "pdf")
        jasperReportsService.creaStampaRegistroGiornalieroModifiche(oggi, oggi, registroGiornalieroModifiche.newOutputStream())

        // creo il protocollo
    }
}
