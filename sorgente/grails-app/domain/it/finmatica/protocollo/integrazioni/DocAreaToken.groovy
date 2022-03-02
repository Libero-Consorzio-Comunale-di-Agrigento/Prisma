package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.Version

@CompileStatic
@Table(name = 'WSD_TOKEN')
@Entity
class DocAreaToken extends AbstractDomainMultiEnte {
    @GeneratedValue
    @Id
    @Column(name = "ID_WSD_TOKEN")
    Long id

    @Column(nullable = false)
    String token


    @Version
    Long version
}
