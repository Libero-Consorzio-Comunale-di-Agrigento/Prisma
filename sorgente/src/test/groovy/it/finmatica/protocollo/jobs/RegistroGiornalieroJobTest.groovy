package it.finmatica.protocollo.jobs

import it.finmatica.gestionedocumenti.storico.DocumentoStoricoService
import it.finmatica.gestionetesti.GestioneTestiService
import it.finmatica.jobscheduler.JobConfigDTO
import it.finmatica.multiente.Ente
import it.finmatica.multiente.MultiEnteHolder
import it.finmatica.protocollo.documenti.ProtocolloService
import it.finmatica.protocollo.documenti.RegistroGiornalieroService
import it.finmatica.protocollo.job.JobService
import spock.lang.Specification

class RegistroGiornalieroJobTest extends Specification {
    def "test run"() {
        given:
        ProtocolloService protocolloService = Mock(ProtocolloService)
        DocumentoStoricoService documentoStoricoService = Mock(DocumentoStoricoService)
        RegistroGiornalieroService registroGiornalieroService = Mock(RegistroGiornalieroService)
        JobService jobService = Mock(JobService)
        GestioneTestiService gestioneTestiService = Mock(GestioneTestiService)
        MultiEnteHolder multiEnteHolder = Mock(MultiEnteHolder)
        Ente ente = Mock(Ente)
        RegistroGiornalieroJob job = new RegistroGiornalieroJob(protocolloService,documentoStoricoService,gestioneTestiService,
                registroGiornalieroService,jobService,multiEnteHolder   )
        when:
            job.run(1l)
        then:
        1 * jobService.cercaConfig(1l) >> new JobConfigDTO(parametri:"""{"idTipoProtocollo": 157, "dataUltimaEsecuzione": "11/09/2018 15:45:00"}""")
        1 * multiEnteHolder.getEnte() >> ente
        1 * ente.getId() >> 1l
        1 * protocolloService.trovaNuoviInserimenti(1l,_,_) >> []
        1 * protocolloService.trovaCandidatiModificati(1l,_ ,_ ) >> []
        1 * protocolloService.trovaAnnullati(1l,_,_) >> []
        2 * gestioneTestiService.stampaUnione(_,'<documentRoot />','pdf')
        1 * registroGiornalieroService.salva(_,_,_,157 as Long)
    }
}
