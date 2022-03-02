package it.finmatica.protocollo.documenti.viste

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.documenti.IFileDocumento
import it.finmatica.gestionedocumenti.documenti.TipoAllegato

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
@Table(name = "agp_schemi_prot_allegati")
@CompileStatic
class SchemaProtocolloFile extends AbstractDomain implements IFileDocumento {

    @GeneratedValue
    @Id
    @Column(name = "ID_SCHEMA_PROT_ALLEGATI")
    Long id
    @Column(name = "content_type", nullable = false)
    String contentType
    @Column(nullable = false)
    long dimensione
    @Column(name = "id_file_esterno")
    Long idFileEsterno
    @Column(nullable = false)
    String nome
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo
    @Column(nullable = false)
    int sequenza
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_allegato")
    TipoAllegato tipoAllegato
    @Version
    Long version

    @Override
    String getTesto() {
        return null
    }

    @Override
    boolean isPdf() {
        return false
    }

    @Override
    boolean isP7m() {
        return false
    }

    @Override
    boolean isFirmato() {
        return false
    }

    @Override
    boolean isModificabile() {
        return false
    }

    @Override
    String getNomeFileSbustato() {
        return null
    }

    @Override
    String getNomePdf() {
        return null
    }

    IDocumentoEsterno getDocumento() {
        return schemaProtocollo
    }

    @Override
    Date getDataVerifica() {
        return null
    }

    @Override
    String getEsitoVerifica() {
        return null
    }
}