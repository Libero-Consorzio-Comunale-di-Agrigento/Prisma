package it.finmatica.protocollo.scaricoipa

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte
import it.finmatica.jobscheduler.JobConfig
import org.hibernate.annotations.Type

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "AGP_SCARICO_IPA")
@CompileStatic
class CriteriScaricoIpa extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "ID_SCARICO_IPA")
    Long id

    @Column(name = "nome_criterio")
    String nomeCriterio

    @Type(type = "yes_no")
    @Column(name = "import_tutte_amm", nullable = false)
    boolean importaTutteAmm

    @Type(type = "yes_no")
    @Column(name = "import_unita", nullable = false)
    boolean importaTutteUnita

    @Type(type = "yes_no")
    @Column(name = "import_tutte_aoo", nullable = false)
    boolean importaTutteAoo

    @Column(name = "codice_amm")
    String codAmm
    @Column(name = "descrizione_amm")
    String descrAmm

    @Column(name = "tipologia_ente")
    String tipologiaEnte

    @Column(name = "codice_regione_amm")
    Long regioneAmm
    @Column(name = "codice_provincia_amm")
    Long provinciaAmm

    @Column(name = "codice_aoo")
    String codAoo
    @Column(name = "descrizione_aoo")
    String descrAoo

    @Column(name = "codice_regione_aoo")
    Long regioneAoo
    @Column(name = "codice_provincia_aoo")
    Long provinciaAoo

    @Column(name = "id_job_config")
    Long jobConfig

    @Column(name = "stringa_cron")
    String stringaCron

    @Column(name = "numero_giorni")
    Long numeroGiorni

    @Column(name = "ora_esecuzione")
    String oraEsecuzione

    @Column(name = "minuti_esecuzione")
    String minutiEsecuzione

    @Version
    Long version
}
