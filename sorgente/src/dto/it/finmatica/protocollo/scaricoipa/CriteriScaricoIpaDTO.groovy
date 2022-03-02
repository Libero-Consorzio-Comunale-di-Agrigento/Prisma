package it.finmatica.protocollo.scaricoipa

import it.finmatica.ad4.autenticazione.Ad4UtenteDTO
import it.finmatica.dto.DTO
import it.finmatica.dto.DtoUtils
import it.finmatica.gestionedocumenti.commons.EnteDTO
import it.finmatica.jobscheduler.JobConfig

class CriteriScaricoIpaDTO implements DTO<CriteriScaricoIpa> {

    private static final long serialVersionUID = 1L

    Long id
    Long version

    String nomeCriterio
    boolean importaTutteAmm
    boolean importaTutteUnita
    boolean importaTutteAoo

    String codAmm
    String descrAmm
    String tipologiaEnte
    Long regioneAmm
    Long provinciaAmm

    String codAoo
    String descrAoo
    Long regioneAoo
    Long provinciaAoo

    boolean valido
    EnteDTO ente
    Date lastUpdated
    Date dateCreated
    Ad4UtenteDTO utenteIns
    Ad4UtenteDTO utenteUpd

    Long jobConfig

    String stringaCron
    Long numeroGiorni
    String oraEsecuzione
    String minutiEsecuzione

    CriteriScaricoIpa getDomainObject() {
        return CriteriScaricoIpa.get(this.id)
    }

    CriteriScaricoIpa copyToDomainObject() {
        return DtoUtils.copyToDomainObject(this)
    }
}
