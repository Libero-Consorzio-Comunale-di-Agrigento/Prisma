package it.finmatica.protocollo.documenti.viste

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import org.hibernate.annotations.Type

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
@Table(name = "agp_schemi_prot_categorie")
@CompileStatic
class SchemaProtocolloCategoria extends AbstractDomain {

    public static final String CATEGORIA_TUTTE = "TUTTE"

    @GeneratedValue
    @Id
    @Column(name = "ID_SCHEMA_PROT_CATEGORIA")
    Long id

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_protocollo")
    TipoProtocollo tipoProtocollo

    @Column(nullable = false)
    String categoria = "TUTTE"

    @Type(type = "yes_no")
    @Column(name = "modificabile")
    boolean modificabile = "Y"

    @Version
    Long version
}