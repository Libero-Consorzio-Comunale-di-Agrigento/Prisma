package it.finmatica.protocollo.documenti.viste

import it.finmatica.gestionedocumenti.commons.AbstractDomainMultiEnte
import it.finmatica.gestionedocumenti.documenti.IDocumentoEsterno
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.annotations.Type

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinColumns
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.persistence.Table
import javax.persistence.Version

@Entity
@Table(name = "agp_schemi_protocollo")
class SchemaProtocollo extends AbstractDomainMultiEnte implements IDocumentoEsterno {

    @Id
    @Column(name = "id_schema_protocollo")
    Long id

    @Column(name = "anni_conservazione")
    Integer anniConservazione

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @Column(nullable = false)
    String codice

    @Type(type = "yes_no")
    @Column(name = "conservazione_illimitata", nullable = false)
    boolean conservazioneIllimitata

    @Column(nullable = false)
    String descrizione

    @Type(type = "yes_no")
    @Column(name = "domanda_accesso")
    boolean domandaAccesso

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_fascicolo")
    Fascicolo fascicolo

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "schemaProtocollo", orphanRemoval = true)
    Set<SchemaProtocolloFile> files

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "schemaProtocollo", orphanRemoval = true)
    Set<SchemaProtocolloCategoria> categorie

    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno

    String movimento

    String note

    String oggetto

    @Type(type = "yes_no")
    boolean risposta

    Integer scadenza

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean riservato = "N"

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo_risposta")
    SchemaProtocollo schemaProtocolloRisposta

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean segnatura

    @Type(type = "yes_no")
    @Column(name = "segnatura_completa", nullable = false)
    boolean segnaturaCompleta

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "schemaProtocollo", orphanRemoval = true)
    Set<SchemaProtocolloSmistamento> smistamenti

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_protocollo")
    TipoProtocollo tipoProtocollo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_registro")
    TipoRegistro tipoRegistro

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "ufficio_esibente_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "ufficio_esibente_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "ufficio_esibente_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb ufficioEsibente

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "schemaProtocollo", orphanRemoval = true)
    Set<SchemaProtocolloUnita> unitaSet

    @Version
    Long version

    void addToFiles(SchemaProtocolloFile value) {
        if (this.files == null) {
            this.files = new HashSet<SchemaProtocolloFile>()
        }
        this.files.add(value);
        value.schemaProtocollo = this
    }

    void removeFromFiles(SchemaProtocolloFile value) {
        if (this.files == null) {
            this.files = new HashSet<SchemaProtocolloFile>()
        }
        this.files.remove((Object) value);
        value.schemaProtocollo = null
    }

    void addToSmistamenti(SchemaProtocolloSmistamento value) {
        if (this.smistamenti == null) {
            this.smistamenti = new HashSet<SchemaProtocolloSmistamento>()
        }
        this.smistamenti.add(value);
        value.schemaProtocollo = this
    }

    void removeFromSmistamenti(SchemaProtocolloSmistamento value) {
        if (this.smistamenti == null) {
            this.smistamenti = new HashSet<SchemaProtocolloSmistamento>()
        }
        this.smistamenti.remove((Object) value);
        value.schemaProtocollo = null
    }

    void addToUnitaSet(SchemaProtocolloUnita value) {
        if (this.unitaSet == null) {
            this.unitaSet = new HashSet<SchemaProtocolloUnita>()
        }
        this.unitaSet.add(value);
        value.schemaProtocollo = this
    }

    void removeFromUnitaSet(SchemaProtocolloUnita value) {
        if (this.unitaSet == null) {
            this.unitaSet = new HashSet<SchemaProtocolloUnita>()
        }
        this.unitaSet.remove((Object) value);
        value.schemaProtocollo = null
    }

    void addToCategorie(SchemaProtocolloCategoria value) {
        if (this.categorie == null) {
            this.categorie = new HashSet<SchemaProtocolloCategoria>()
        }
        this.categorie.add(value);
        value.schemaProtocollo = this
    }

    void removeFromCategorie(SchemaProtocolloCategoria value) {
        if (this.categorie == null) {
            this.categorie = new HashSet<SchemaProtocolloFile>()
        }
        this.categorie.remove((Object) value);
        value.schemaProtocollo = null
    }

    boolean isSequenza() {
        return SchemaProtocolloSmistamento.createCriteria().count {
            eq("schemaProtocollo.id", this.id)
            eq("tipoSmistamento", Smistamento.COMPETENZA)
            isNotNull("sequenza")
        } > 0
    }

    static namedQueries = {
        numeroFilePerNome { Long idSchema, String nomeFile ->
            projections {
                count("id")
            }

            eq("id", idSchema)

            files {
                eq("nome", nomeFile)
            }
        }
    }
}