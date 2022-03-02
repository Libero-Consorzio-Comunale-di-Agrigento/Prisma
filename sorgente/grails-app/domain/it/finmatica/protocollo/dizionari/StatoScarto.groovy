package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = "agp_stati_scarto")
@CompileStatic
class StatoScarto {

    @Id
    String codice

    @Column(name = "codice_gdm", nullable = false)
    String codiceGdm

    @Column(nullable = false)
    String descrizione

}