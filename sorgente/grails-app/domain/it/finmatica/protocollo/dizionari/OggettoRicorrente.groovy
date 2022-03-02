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
@Table(name = "agp_oggetti_ricorrenti")
@CompileStatic
class OggettoRicorrente extends AbstractDomainMultiEnte {

    @Id
    @Column(name = "id_oggetto_ricorrente")
    Long id

    @Column(nullable = false)
    String codice

    @Column(nullable = false)
    String oggetto

    @Version
    Long version
}