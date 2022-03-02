package it.finmatica.protocollo.documenti.emergenza

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.hibernate.UtenteIns
import it.finmatica.ad4.hibernate.UtenteUpd
import org.hibernate.annotations.CreationTimestamp
import org.hibernate.annotations.UpdateTimestamp

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

@Entity
@Table(name = "agp_protocolli_dati_emergenza")
@CompileStatic
class ProtocolloDatiEmergenza {

    @GeneratedValue
    @Id
    @Column(name = "id_protocollo_dati_emergenza")
    Long id

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_inizio_emergenza")
    Date dataInizioEmergenza

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_fine_emergenza", nullable = false)
    Date dataFineEmergenza

    @Column(name = "motivo_emergenza")
    String motivoEmergenza

    @Column(name = "provvedimento_emergenza")
    String provvedimentoEmergenza

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_ins")
    @UtenteIns
    Ad4Utente utenteIns

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_upd")
    @UtenteUpd
    Ad4Utente utenteUpd

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_upd", nullable = false)
    Date lastUpdated

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ins", nullable = false)
    Date dateCreated

    @Version
    Long version
}