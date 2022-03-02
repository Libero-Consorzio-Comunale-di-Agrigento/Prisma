package it.finmatica.protocollo.integrazioni

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.Lob
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Version

@CompileStatic
@Table(name = 'WSD_FILE')
@Entity
class DocAreaFile {
    @GeneratedValue
    @Id
    @Column(name = "ID_WSD_FILE")
    Long id

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = 'ID_WSD_TOKEN')
    DocAreaToken token

    @Lob
    @Column(nullable = false)
    byte[] content

    @Column(nullable = true, name = 'content_type')
    String contentType


}
