package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = "agp_tipi_soggetto")
@CompileStatic
class TipoSoggetto {

    @GeneratedValue
    @Id
    @Column(name = "tipo_soggetto")
    Long id

    @Column(nullable = false)
    String descrizione

    @Column(nullable = false)
    Long sequenza
}