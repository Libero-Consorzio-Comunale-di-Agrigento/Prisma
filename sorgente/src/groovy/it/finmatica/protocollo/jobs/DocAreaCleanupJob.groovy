package it.finmatica.protocollo.jobs

import groovy.transform.CompileStatic
import groovy.util.logging.Slf4j
import it.finmatica.protocollo.integrazioni.DocAreaFileService
import it.finmatica.protocollo.integrazioni.DocAreaTokenService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.scheduling.annotation.Scheduled

@CompileStatic
@Slf4j
class DocAreaCleanupJob {

    @Autowired DocAreaFileService docAreaFileService
    @Autowired DocAreaTokenService docAreaTokenService

    @Value("\${finmatica.protocollo.DocAreaCleanupJob.oreObsolescenza:6}")
    Integer oreObsolescenza

    @Scheduled(cron = "\${it.finmatica.protocollo.jobs.ProtocolloJob.DocAreaCleanupJob.cron:0 0 4 * * *}")
    void job() {
        docAreaFileService.deleteObsolete(oreObsolescenza)
        docAreaTokenService.deleteObsolete(oreObsolescenza)
    }
}
