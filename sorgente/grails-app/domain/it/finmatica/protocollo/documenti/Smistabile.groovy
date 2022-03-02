package it.finmatica.protocollo.documenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.Holders
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiSpringSecurityService
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import org.hibernate.annotations.Type

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.PrePersist
import javax.persistence.PreUpdate
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType

@Entity
@Table(name = "agp_smistabile_view")
@CompileStatic
class Smistabile {

    public static final String TIPO_DOCUMENTO = "SMISTABILE"

    @GeneratedValue
    @Id
    @Column(name = "id_documento")
    Long id
    Integer anno

    @Column(nullable = false)
    String categoria

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @Temporal(TemporalType.TIMESTAMP)
    Date data

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_ente")
    Ente ente

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_fascicolo")
    Fascicolo fascicolo

    @Type(type = "yes_no")
    boolean firmato

    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno
    String idrif
    String movimento
    Integer numero

    @Column(name = "numero_7", nullable = false)
    String numero7
    String oggetto

    @Type(type = "yes_no")
    boolean riservato

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_registro")
    TipoRegistro tipoRegistro

    CategoriaProtocollo getCategoriaProtocollo() {
        return CategoriaProtocollo.getInstance(categoria)
    }

    @PrePersist
    void beforeInsert() {
        ente = ente ?: (Ente) Holders.getApplicationContext().getBean(GestioneDocumentiSpringSecurityService).getPrincipal().getEnte()
    }

    @PreUpdate
    void beforeUpdate() {
        ente = ente ?: (Ente) Holders.getApplicationContext().getBean(GestioneDocumentiSpringSecurityService).getPrincipal().getEnte()
    }
}