package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomain

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_messaggi_protocolli")
@CompileStatic
class MessaggioProtocollo extends AbstractDomain {

    @GeneratedValue
    @Id
    @Column(name = "id_messaggio_protocollo")
    Long id
    @Column(name = "id_protocollo", nullable = false)
    Long idDocumentoEsterno
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_messaggio")
    Messaggio messaggio
    @Version
    Long version
}