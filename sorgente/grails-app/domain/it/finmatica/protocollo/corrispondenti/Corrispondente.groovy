package it.finmatica.protocollo.corrispondenti

import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.Protocollo
import org.hibernate.annotations.Type
import org.hibernate.envers.AuditTable
import org.hibernate.envers.Audited
import org.hibernate.envers.NotAudited

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.Version

@AuditTable("agp_protocolli_corr_log")
@Audited
@Entity
@Table(name = "agp_protocolli_corrispondenti")
class Corrispondente extends AbstractDomain {

    public static final String MITTENTE = "MITT"
    public static final String DESTINATARIO = "DEST"

    @GeneratedValue
    @Id
    @Column(name = "id_protocollo_corrispondente")
    Long id

    @Column(name = "bc_spedizione")
    String barcodeSpedizione
    String cap

    @Column(name = "codice_fiscale")
    String codiceFiscale
    @Column(name = "id_fiscale_estero")
    String idFiscaleEstero
    String cognome
    String comune

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean conoscenza

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean suap

    @Column(name = "costo_spedizione")
    BigDecimal costoSpedizione

    @Column(name = "quantita")
    Long quantita

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_spedizione")
    Date dataSpedizione
    @Column(length = 4000)
    String denominazione
    String email
    String fax

    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "corrispondente", orphanRemoval = true)
    Set<Indirizzo> indirizzi

    @Column(length = 4000)
    String indirizzo

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "corrispondente", orphanRemoval = true)
    Set<CorrispondenteMessaggio> messaggi

    @NotAudited
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_modalita_invio_ricezione")
    ModalitaInvioRicezione modalitaInvioRicezione

    String nome

    @Column(name = "partita_iva")
    String partitaIva

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_documento")
    Protocollo protocollo

    @Column(name = "provincia_sigla")
    String provinciaSigla

    @Column(name = "tipo_corrispondente")
    String tipoCorrispondente

    @Column(name = "tipo_indirizzo")
    String tipoIndirizzo

    @NotAudited
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_soggetto")
    TipoSoggetto tipoSoggetto

    @Version
    Long version

    void addToIndirizzi(Indirizzo value) {
        if (this.indirizzi == null) {
            this.indirizzi = new HashSet<Indirizzo>()
        }
        this.indirizzi.add(value);
        value.corrispondente = this
    }

    void removeFromIndirizzi(Indirizzo value) {
        if (this.indirizzi == null) {
            this.indirizzi = new HashSet<Indirizzo>()
        }
        this.indirizzi.remove((Object) value);
        value.corrispondente = null
    }

    void addToMessaggi(CorrispondenteMessaggio value) {
        if (this.messaggi == null) {
            this.messaggi = new HashSet<CorrispondenteMessaggio>()
        }
        this.messaggi.add(value);
        value.corrispondente = this
    }

    void removeFromMessaggi(CorrispondenteMessaggio value) {
        if (this.messaggi == null) {
            this.messaggi = new HashSet<CorrispondenteMessaggio>()
        }
        this.messaggi.remove((Object) value);
        value.corrispondente = null
    }
}