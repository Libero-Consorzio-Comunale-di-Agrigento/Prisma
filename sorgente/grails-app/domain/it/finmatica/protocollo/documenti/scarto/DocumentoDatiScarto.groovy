package it.finmatica.protocollo.documenti.scarto

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.hibernate.UtenteIns
import it.finmatica.ad4.hibernate.UtenteUpd
import it.finmatica.protocollo.dizionari.StatoScarto
import org.hibernate.annotations.CreationTimestamp
import org.hibernate.annotations.UpdateTimestamp
import org.hibernate.envers.Audited
import org.hibernate.envers.RelationTargetAuditMode

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.Version

@Audited
@Entity
@Table(name = "agp_documenti_dati_scarto")
@CompileStatic
class DocumentoDatiScarto {

    @GeneratedValue
    @Id
    @Column(name = "id_documento_dati_scarto")
    Long id

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_nulla_osta")
    Date dataNullaOsta

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_stato", nullable = false)
    Date dataStato

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ins", nullable = false)
    Date dateCreated

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_upd", nullable = false)
    Date lastUpdated

    @Column(name = "nulla_osta")
    String nullaOsta

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stato")
    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    StatoScarto stato

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_ins")
    @UtenteIns
    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    Ad4Utente utenteIns

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_upd")
    @UtenteUpd
    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    Ad4Utente utenteUpd

    @Version
    Long version
}