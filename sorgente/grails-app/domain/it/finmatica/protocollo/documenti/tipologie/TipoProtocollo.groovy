package it.finmatica.protocollo.documenti.tipologie

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.gestionedocumenti.documenti.TipoDocumento
import it.finmatica.gestionedocumenti.documenti.TipoDocumentoModello
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.annotations.Type

import javax.persistence.AttributeOverride
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinColumns
import javax.persistence.ManyToOne
import javax.persistence.PrimaryKeyJoinColumn
import javax.persistence.Table

@Entity
@Table(name = "agp_tipi_protocollo")
@CompileStatic
@PrimaryKeyJoinColumn(name = "id_tipo_protocollo")
class TipoProtocollo extends TipoDocumento {

    @Column(nullable = false)
    String categoria

    @Type(type = "yes_no")
    @Column(name = "firm_obbligatorio", nullable = false)
    boolean firmatarioObbligatorio

    @Type(type = "yes_no")
    @Column(name = "firm_visibile", nullable = false)
    boolean firmatarioVisibile

    @Type(type = "yes_no")
    @Column(name = "funz_obbligatorio", nullable = false)
    boolean funzionarioObbligatorio

    @Type(type = "yes_no")
    @Column(name = "funz_visibile", nullable = false)
    boolean funzionarioVisibile

    @Type(type = "yes_no")
    @Column(name = "predefinito", nullable = false)
    boolean predefinito = false

    String movimento

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ruolo_unita_dest")
    Ad4Ruolo ruoloUoDestinataria

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_registro")
    TipoRegistro tipoRegistro

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_dest_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_dest_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_dest_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unitaDestinataria

    void addToModelliAssociati(TipoDocumentoModello value) {
        if (this.modelliAssociati == null) {
            this.modelliAssociati = new HashSet<TipoDocumentoModello>()
        }
        this.modelliAssociati.add(value);
        value.tipoDocumento = this
    }

    void removeFromModelliAssociati(TipoDocumentoModello value) {
        if (this.modelliAssociati == null) {
            this.modelliAssociati = new HashSet<TipoDocumentoModello>()
        }
        this.modelliAssociati.remove((Object) value);
        value.tipoDocumento = null
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return CategoriaProtocollo.getInstance(categoria)
    }
}