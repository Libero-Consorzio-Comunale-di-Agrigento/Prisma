package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo

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
@Table(name = "agp_schemi_prot_integrazioni")
@CompileStatic
class SchemaProtocolloIntegrazione extends AbstractDomainMultiEnte {

    final static String GLOBO = "GLOBO"
    final static String IMPRESA_IN_UN_GIORNO = "IMPRESA_IN_UN_GIORNO"

    @GeneratedValue
    @Id
    @Column(name = "id_schema_prot_integrazioni")
    Long id

    @Version
    Long version

    @Column(name = "applicativo", nullable = false)
    String applicativo
    String tipoPratica

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo
}