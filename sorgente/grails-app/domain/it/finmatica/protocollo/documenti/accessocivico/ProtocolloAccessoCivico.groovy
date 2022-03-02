package it.finmatica.protocollo.documenti.accessocivico

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.hibernate.UtenteIns
import it.finmatica.ad4.hibernate.UtenteUpd
import it.finmatica.protocollo.dizionari.TipoAccessoCivico
import it.finmatica.protocollo.dizionari.TipoEsitoAccesso
import it.finmatica.protocollo.dizionari.TipoRichiedenteAccesso
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.annotations.CreationTimestamp
import org.hibernate.annotations.Type
import org.hibernate.annotations.UpdateTimestamp

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinColumns
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.Version

@Entity
@Table(name = "AGP_PROTOCOLLI_DATI_ACCESSO")
@CompileStatic
class ProtocolloAccessoCivico {

    @GeneratedValue
    @Id
    @Column(name = "id_dati_accesso")
    Long id

    @Type(type = "yes_no")
    @Column(name = "pubblica_domanda", nullable = false)
    boolean attivaPubblicaDomanda

    @Type(type = "yes_no")
    @Column(name = "pubblica", nullable = false)
    boolean attivaPubblicazione

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_presentazione")
    Date dataPresentazione

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_provvedimento")
    Date dataProvvedimento

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ins", nullable = false)
    Date dateCreated

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_upd", nullable = false)
    Date lastUpdated

    @Column(name = "motivo_rifiuto", length = 4000)
    String motivoRifiuto

    @Column(length = 4000)
    String oggetto

    @Type(type = "yes_no")
    @Column(name = "controinteressati", nullable = false)
    boolean presenzaControinteressati

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_protocollo_domanda")
    Protocollo protocolloDomanda

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_protocollo_risposta")
    Protocollo protocolloRisposta

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_accesso_civico")
    TipoAccessoCivico tipoAccessoCivico

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_esito")
    TipoEsitoAccesso tipoEsitoAccesso

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_richiedente_accesso")
    TipoRichiedenteAccesso tipoRichiedenteAccesso

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_competente_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_competente_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_competente_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb ufficioCompetente

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_comp_riesame_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_comp_riesame_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_comp_riesame_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb ufficioCompetenteRiesame

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_ins")
    @UtenteIns
    Ad4Utente utenteIns

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_upd")
    @UtenteUpd
    Ad4Utente utenteUpd

    @Version
    Long version

    void setOggetto(String oggetto) {
        this.oggetto = oggetto?.toUpperCase()
    }
}