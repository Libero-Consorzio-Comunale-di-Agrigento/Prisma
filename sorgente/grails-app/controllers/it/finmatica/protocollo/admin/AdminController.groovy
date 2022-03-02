package it.finmatica.protocollo.admin

import it.finmatica.ad4.security.SpringSecurityService
import it.finmatica.gestionedocumenti.impostazioni.ImpostazioneService
import it.finmatica.gestioneiter.configuratore.dizionari.WkfAzione
import it.finmatica.protocollo.jobs.ProtocolloJob
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Controller

@Controller
class AdminController {

    @Autowired AggiornamentoService aggiornamentoService
    @Autowired SpringSecurityService springSecurityService
    @Autowired ImpostazioneService   impostazioneService
    @Autowired ProtocolloJob         protocolloJob

    def index() {
        render view: 'aggiornamento', model:[azioniVecchie:aggiornamentoService.getAzioniVecchie()]
    }

    def cercaAzioniNuove () {
        def azioniNuove = [[nome: "-- svuota azione --", id:-1]]
        azioniNuove.addAll(WkfAzione.createCriteria().list {
            eq ("valido", true)
            or {
                ilike ("nome", "%${params.filtroAzioniNuove}%")
                ilike ("descrizione", "%${params.filtroAzioniNuove}%")
            }

            order ("tipoOggetto.codice", "asc")
            order ("nomeBean", "asc")
            order ("nomeMetodo", "asc")
        }.collect {
            [nome: "${it.tipoOggetto.codice} | ${it.nomeBean}.${it.nomeMetodo}() >> ${it.nome}: ${it.descrizione}", id:it.id]
        })
        render view: 'aggiornamento', model: [azioniVecchie: aggiornamentoService.getAzioniVecchie(), azioniNuove: azioniNuove, filtroAzioniNuove: params.filtroAzioniNuove]
    }

    def sostituisciVecchioConNuovo () {
        aggiornamentoService.sostituisciVecchieAzioniConNuove(params)
        render view: 'aggiornamento', model: [azioniVecchie: aggiornamentoService.getAzioniVecchie(), filtroAzioniNuove: params.filtroAzioniNuove]
    }

    def eliminaAzioni () {
        aggiornamentoService.eliminaAzioni()
        render view: 'aggiornamento', model: [azioniVecchie: aggiornamentoService.getAzioniVecchie()]
    }

    def aggiornaAzioni () {
        aggiornamentoService.aggiornaAzioni()
        flash.message = "Azioni Aggiornate"
        forward (action:"index")
    }

//    def aggiornaTipiModelloTesto () {
//        aggiornamentoService.aggiornaTipiModelloTesto(session.servletContext.getRealPath("WEB-INF/configurazioneStandard/modelliTesto/xml"))
//        flash.message = "Tipi Modelli Testo Standard importati."
//        forward (action:"aggiornamento")
//    }
//
//    def installaConfigurazioniIter () {
//        aggiornamentoService.installaConfigurazioniIter(session.servletContext.getRealPath("WEB-INF/configurazioneStandard/flussi"))
//        flash.message = "Flussi Standard importati."
//        forward (action:"aggiornamento")
//    }

    public def attivaJob () {
        protocolloJob.job ()
        flash.message = "Job Attivato."
        forward (action:"aggiornamento")
    }

    def aggiornaImpostazioni () {
        impostazioneService.aggiornaImpostazioni();
        flash.message = "Impostazioni Aggiornate."
        if (springSecurityService.isLoggedIn()) {
            render (view: "aggiornamento")
        } else {
            render flash.message
        }
    }
}
