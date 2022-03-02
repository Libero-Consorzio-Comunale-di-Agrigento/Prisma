package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = "ags_modalita_invio_ricezione")
@CompileStatic
class MezzoTrasmissivo extends AbstractDomainMultiEnte {

    public static final String CODICE_EMAIL           = "EMAI"
    public static final String CODICE_PEC             = "PEC"
    public static final String CODICE_POSTA_ORDINARIA = "POR"

    @GeneratedValue
    @Id
    @Column(name = "id_modalita_invio_ricezione")
    Long id
    @Column(nullable = false)
    String codice
    @Column(nullable = false)
    String descrizione
}