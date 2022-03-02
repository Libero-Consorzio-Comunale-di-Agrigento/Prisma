package it.finmatica.protocollo.scaricoipa

import groovy.util.logging.Slf4j
import it.finmatica.ad4.dizionari.Ad4ProvinciaDTO
import it.finmatica.ad4.dizionari.Ad4RegioneDTO
import it.finmatica.gestionedocumenti.exception.GestioneDocumentiRuntimeException
import it.finmatica.jobscheduler.JobConfig
import it.finmatica.jobscheduler.JobLog
import it.finmatica.jobscheduler.JobSchedulerRepository
import it.finmatica.protocollo.integrazioni.ad4.ProvinceAd4Service
import it.finmatica.protocollo.integrazioni.ad4.RegioniAd4Service
import it.finmatica.so4.login.So4SpringSecurityService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import javax.sql.DataSource

@Transactional
@Service
@Slf4j
class CriteriScaricoIpaService {
    @Autowired
    DataSource dataSource
    @Autowired
    ScaricoIpaService scaricoIpaService
    @Autowired
    RegioniAd4Service regioniAd4Service
    @Autowired
    ProvinceAd4Service provinceAd4Service
    @Autowired
    JobSchedulerRepository jobSchedulerRepository
    @Autowired
    So4SpringSecurityService springSecurityService
    @Autowired
    ScaricoIpaRepository scaricoIpaRepository

    CriteriScaricoIpa getCriterio(long id) {
        return scaricoIpaRepository.getCriterioScaricoIpa(id)
    }

    void elimina(CriteriScaricoIpaDTO criteriScaricoIpaDTO) {
        CriteriScaricoIpa criteriScaricoIpa = CriteriScaricoIpa.get(criteriScaricoIpaDTO.id)
        if (criteriScaricoIpa.version != criteriScaricoIpa.version) {
            throw new GestioneDocumentiRuntimeException("Un altro utente ha modificato il dato sottostante, operazione annullata!")
        }
        // cancella il job associato se presente
        if (criteriScaricoIpa.jobConfig) {
            JobConfig jobConfig = JobConfig.get(criteriScaricoIpa.jobConfig)
            jobConfig.delete(failOnError: true)
        }
        criteriScaricoIpa.delete(failOnError: true)
    }

    CriteriScaricoIpaDTO salva(CriteriScaricoIpaDTO criteriScaricoIpaDTO) {
        CriteriScaricoIpa criteriScaricoIpa = CriteriScaricoIpa.get(criteriScaricoIpaDTO.id) ?: new CriteriScaricoIpa()
        criteriScaricoIpa.nomeCriterio = criteriScaricoIpaDTO.nomeCriterio.toUpperCase()
        criteriScaricoIpa.importaTutteAmm = criteriScaricoIpaDTO.importaTutteAmm
        criteriScaricoIpa.importaTutteUnita = criteriScaricoIpaDTO.importaTutteUnita
        criteriScaricoIpa.codAmm = criteriScaricoIpaDTO.codAmm
        criteriScaricoIpa.descrAmm = criteriScaricoIpaDTO.descrAmm
        criteriScaricoIpa.tipologiaEnte = criteriScaricoIpaDTO.tipologiaEnte
        criteriScaricoIpa.regioneAmm = (criteriScaricoIpaDTO.regioneAmm == null) ? new Long("-1") : criteriScaricoIpaDTO.regioneAmm
        criteriScaricoIpa.provinciaAmm = (criteriScaricoIpaDTO.provinciaAmm == null) ? new Long("-1") : criteriScaricoIpaDTO.provinciaAmm
        criteriScaricoIpa.importaTutteAoo = criteriScaricoIpaDTO.importaTutteAoo
        criteriScaricoIpa.codAoo = criteriScaricoIpaDTO.codAoo
        criteriScaricoIpa.descrAoo = criteriScaricoIpaDTO.descrAoo
        criteriScaricoIpa.regioneAoo = (criteriScaricoIpaDTO.regioneAoo == null) ? new Long("-1") : criteriScaricoIpaDTO.regioneAoo
        criteriScaricoIpa.provinciaAoo = (criteriScaricoIpaDTO.provinciaAoo == null) ? new Long("-1") : criteriScaricoIpaDTO.provinciaAoo

        criteriScaricoIpa.numeroGiorni = criteriScaricoIpaDTO.numeroGiorni
        criteriScaricoIpa.oraEsecuzione = criteriScaricoIpaDTO.oraEsecuzione
        criteriScaricoIpa.minutiEsecuzione = criteriScaricoIpaDTO.minutiEsecuzione
        criteriScaricoIpa.stringaCron = criteriScaricoIpaDTO.stringaCron

        if (criteriScaricoIpaDTO.stringaCron != null) {
            JobConfig jobConfig

            if (criteriScaricoIpaDTO.jobConfig != null) {
                jobConfig = JobConfig.get(criteriScaricoIpaDTO.jobConfig)
                if (!jobConfig) {
                    jobConfig = new JobConfig()
                    jobConfig.stato = JobConfig.Stato.IN_ATTESA
                }
            } else {
                jobConfig = new JobConfig()
                jobConfig.stato = JobConfig.Stato.IN_ATTESA
            }

            jobConfig.cron = criteriScaricoIpaDTO.stringaCron
            jobConfig.valido = true
            jobConfig.esclusivo = true
            jobConfig.nomeBean = "scaricoIpaJob"
            jobConfig.parametri = criteriScaricoIpaDTO.id.toString()
            jobConfig.titolo = "Scarico Ipa"
            jobConfig.save()
            criteriScaricoIpa.jobConfig = jobConfig.id
        }

        criteriScaricoIpa.save()
        return criteriScaricoIpa.toDTO()
    }

    void elaboraCriterio(CriteriScaricoIpaDTO criteriScaricoIpaDTO) {
        elaboraAmm(criteriScaricoIpaDTO)
        if (criteriScaricoIpaDTO.importaTutteAoo) {
            elaboraAoo(criteriScaricoIpaDTO)
        }
        if (criteriScaricoIpaDTO.importaTutteUnita) {
            elaboraUo(criteriScaricoIpaDTO)
        }
    }

    private void elaboraAmm(CriteriScaricoIpaDTO criteriScaricoIpaDTO) throws Exception {
        ScaricoIpaFilter scaricoIpaFilterAmm = new ScaricoIpaFilter()
        scaricoIpaFilterAmm.utenteAggiornamento = springSecurityService.getPrincipal().utente.utente
        scaricoIpaFilterAmm.dataAggiornamento = new Date().format('dd/MM/yyyy')

        scaricoIpaFilterAmm.importaTutteAmm = criteriScaricoIpaDTO.importaTutteAmm
        scaricoIpaFilterAmm.codiceAmministrazione = criteriScaricoIpaDTO.codAmm
        scaricoIpaFilterAmm.descrizioneAmministrazione = criteriScaricoIpaDTO.descrAmm
        if (!criteriScaricoIpaDTO.tipologiaEnte.equals("(Tutti)")) {
            scaricoIpaFilterAmm.tipologiaEnte = criteriScaricoIpaDTO.tipologiaEnte
        }
        if (!(criteriScaricoIpaDTO.regioneAmm.toString().equals("-1"))) {
            Ad4RegioneDTO regioneDTO = regioniAd4Service.ricerca(criteriScaricoIpaDTO.regioneAmm.toLong(), "")?.get(0)
            if (regioneDTO != null) {
                scaricoIpaFilterAmm.regione = regioneDTO.denominazione
            }
        }

        if ("-1" != criteriScaricoIpaDTO.provinciaAmm.toString()) {
            Ad4ProvinciaDTO provinciaDTO = provinceAd4Service.ricerca(criteriScaricoIpaDTO.provinciaAmm.toLong(), criteriScaricoIpaDTO.regioneAmm.toLong())?.get(0)
            if (provinciaDTO != null) {
                scaricoIpaFilterAmm.provincia = provinciaDTO.sigla
            }
        }

        try {
            scaricoIpaService.scaricoIpa(ScaricoIpaService.URLAMM, scaricoIpaFilterAmm)
        }
        catch (Exception e) {
            throw new Exception("Errore in import amministrazioni! Errore: " + e.getMessage())
        }
    }

    private void elaboraAoo(CriteriScaricoIpaDTO criteriScaricoIpaDTO) throws Exception {
        ScaricoIpaFilter scaricoIpaFilterAoo = new ScaricoIpaFilter()
        scaricoIpaFilterAoo.utenteAggiornamento = springSecurityService.getPrincipal().utente.utente
        scaricoIpaFilterAoo.dataAggiornamento = new Date().format('dd/MM/yyyy')

        scaricoIpaFilterAoo.importaTutteAoo = criteriScaricoIpaDTO.importaTutteAoo
        scaricoIpaFilterAoo.codiceAoo = criteriScaricoIpaDTO.codAoo
        scaricoIpaFilterAoo.descrizioneAoo = criteriScaricoIpaDTO.descrAoo

        if (!(criteriScaricoIpaDTO.regioneAoo.toString().equals("-1"))) {
            Ad4RegioneDTO regioneDTO = regioniAd4Service.ricerca(criteriScaricoIpaDTO.regioneAoo.toLong(), "")?.get(0)
            if (regioneDTO != null) {
                scaricoIpaFilterAoo.regione = regioneDTO.denominazione
            }
        }

        if (!(criteriScaricoIpaDTO.provinciaAoo.toString().equals("-1"))) {
            Ad4ProvinciaDTO provinciaDTO = provinceAd4Service.ricerca(criteriScaricoIpaDTO.provinciaAoo.toLong(), criteriScaricoIpaDTO.regioneAoo.toLong())?.get(0)
            if (provinciaDTO != null) {
                scaricoIpaFilterAoo.provincia = provinciaDTO.sigla
            }
        }

        try {
            scaricoIpaService.scaricoIpa(ScaricoIpaService.URLAOO, scaricoIpaFilterAoo)
        }
        catch (Exception e) {
            throw new Exception("Errore in import aoo! Errore: " + e.getMessage())
        }
    }

    private void elaboraUo(CriteriScaricoIpaDTO criteriScaricoIpaDTO) throws Exception {
        ScaricoIpaFilter scaricoIpaFilterUo = new ScaricoIpaFilter()
        scaricoIpaFilterUo.utenteAggiornamento = springSecurityService.getPrincipal().utente.utente
        scaricoIpaFilterUo.dataAggiornamento = new Date().format('dd/MM/yyyy')

        scaricoIpaFilterUo.importaTutteUnita = criteriScaricoIpaDTO.importaTutteUnita
        scaricoIpaFilterUo.importaTutteAmm = criteriScaricoIpaDTO.importaTutteAmm
        scaricoIpaFilterUo.codiceAmministrazione = criteriScaricoIpaDTO.codAmm
        scaricoIpaFilterUo.descrizioneAmministrazione = criteriScaricoIpaDTO.descrAmm
        if (!criteriScaricoIpaDTO.tipologiaEnte.equals("(Tutti)")) {
            scaricoIpaFilterUo.tipologiaEnte = criteriScaricoIpaDTO.tipologiaEnte
        }
        if (!(criteriScaricoIpaDTO.regioneAmm.toString().equals("-1"))) {
            Ad4RegioneDTO regioneDTO = regioniAd4Service.ricerca(criteriScaricoIpaDTO.regioneAmm.toLong(), "")?.get(0)
            if (regioneDTO != null) {
                scaricoIpaFilterUo.regione = regioneDTO.denominazione
            }
        }

        if (!(criteriScaricoIpaDTO.provinciaAmm.toString().equals("-1"))) {
            Ad4ProvinciaDTO provinciaDTO = provinceAd4Service.ricerca(criteriScaricoIpaDTO.provinciaAmm.toLong(), criteriScaricoIpaDTO.regioneAmm.toLong())?.get(0)
            if (provinciaDTO != null) {
                scaricoIpaFilterUo.provincia = provinciaDTO.sigla
            }
        }

        if (criteriScaricoIpaDTO.importaTutteUnita) {
            try {
                scaricoIpaService.scaricoIpa(ScaricoIpaService.URLUO, scaricoIpaFilterUo)
            }
            catch (Exception e) {
                throw new Exception("Errore in import UO! Errore: " + e.getMessage())
            }
        }
    }

    JobConfig getConfigForLogId(Long idJobLog) {
        JobLog jl = jobSchedulerRepository.getJobLog(idJobLog)
        def config = JobConfig.get(jl.jobConfig.id)
        return config
    }
}
