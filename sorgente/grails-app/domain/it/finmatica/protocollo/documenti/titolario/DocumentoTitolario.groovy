package it.finmatica.protocollo.documenti.titolario

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo

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
@Table(name = "agp_documenti_titolario")
@CompileStatic
class DocumentoTitolario extends AbstractDomain {

    @GeneratedValue
    @Id
    @Column(name = "id_documento_titolario")
    Long id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_documento")
    Documento documento
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_fascicolo")
    Fascicolo fascicolo

    @Version
    Long version
}