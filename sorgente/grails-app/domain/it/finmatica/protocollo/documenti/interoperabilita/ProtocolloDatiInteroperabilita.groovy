package it.finmatica.protocollo.documenti.interoperabilita

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.ad4.hibernate.UtenteIns
import it.finmatica.ad4.hibernate.UtenteUpd
import org.hibernate.annotations.CreationTimestamp
import org.hibernate.annotations.Type
import org.hibernate.annotations.UpdateTimestamp

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.Lob
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.Version

@Entity
@Table(name = "AGP_PROTOCOLLI_DATI_INTEROP")
@CompileStatic
class ProtocolloDatiInteroperabilita {

    @GeneratedValue
    @Id
    @Column(name = "ID_PROTOCOLLO_DATI_INTEROP")
    Long id

    @Column(name = "codice_amm_prima_registrazione")
    String codiceAmmPrimaRegistrazione

    @Column(name = "codice_aoo_prima_registrazione")
    String codiceAooPrimaRegistrazione

    @Column(name = "codice_reg_prima_registrazione")
    String codiceRegistroPrimaRegistrazione

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_prima_registrazione")
    Date dataPrimaRegistrazione

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ins", nullable = false)
    Date dateCreated

    @Type(type = "yes_no")
    @Column(name = "inviata_conferma", nullable = false)
    boolean inviataConferma

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_upd", nullable = false)
    Date lastUpdated

    @Lob
    @Column(name = "motivo_intervento_operatore")
    String motivoInterventoOperatore

    @Column(name = "numero_prima_registrazione")
    String numeroPrimaRegistrazione

    @Type(type = "yes_no")
    @Column(name = "ricevuta_accettazione_conferma", nullable = false)
    boolean ricevutaAccettazioneConferma

    @Type(type = "yes_no")
    @Column(name = "richiesta_conferma", nullable = false)
    boolean richiestaConferma

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
}