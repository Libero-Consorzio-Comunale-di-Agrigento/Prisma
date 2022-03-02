package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_tipi_accesso_civico")
@CompileStatic
class TipoAccessoCivico extends AbstractDomainMultiEnte {

    @GeneratedValue
    @Id
    @Column(name = "id_tipo_accesso_civico")
    Long id

    @Column(nullable = false)
    String codice
    String commento

    @Column(nullable = false)
    String descrizione

    @Version
    Long version
}