package it.finmatica.protocollo.corrispondenti

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import org.hibernate.annotations.Type

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
@Table(name = "agp_messaggi_corrispondenti")
@CompileStatic
class CorrispondenteMessaggio extends AbstractDomain {

    @GeneratedValue
    @Id
    @Column(name = "id_messaggio_corrispondente")
    Long id
    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean conoscenza
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_protocollo_corrispondente")
    Corrispondente corrispondente
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ric_aggiornamento")
    Date dataRicezioneAggiornamento
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ric_annullamento")
    Date dataRicezioneAnnullamento
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ric_conferma")
    Date dataRicezioneConferma
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_ric_eccezione")
    Date dataRicezioneEccezione
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_spedizione")
    Date dataSpedizione
    @Column(nullable = false)
    String denominazione
    @Column(nullable = false)
    String email
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_messaggio")
    Messaggio messaggio
    @Type(type = "yes_no")
    @Column(name = "registrata_consegna", nullable = false)
    boolean registrataConsegna
    @Type(type = "yes_no")
    @Column(name = "reg_consegna_aggiornamento", nullable = false)
    boolean registrazioneConsegnaAggiornamento
    @Type(type = "yes_no")
    @Column(name = "reg_consegna_annullamento", nullable = false)
    boolean registrazioneConsegnaAnnullamento
    @Type(type = "yes_no")
    @Column(name = "reg_consegna_conferma", nullable = false)
    boolean registrazioneConsegnaConferma
    @Type(type = "yes_no")
    @Column(name = "ricevuta_conferma", nullable = false)
    boolean ricevutaConferma
    @Type(type = "yes_no")
    @Column(name = "ricevuta_eccezione", nullable = false)
    boolean ricevutaEccezione
    @Type(type = "yes_no")
    @Column(name = "ric_mancata_consegna", nullable = false)
    boolean ricevutaMancataConsegna
    @Type(type = "yes_no")
    @Column(name = "ric_mancata_consegna_agg", nullable = false)
    boolean ricevutaMancataConsegnaAggiornamento
    @Type(type = "yes_no")
    @Column(name = "ric_mancata_consegna_ann", nullable = false)
    boolean ricevutaMancataConsegnaAnnullamento
    @Type(type = "yes_no")
    @Column(name = "ric_mancata_consegna_conf", nullable = false)
    boolean ricevutaMancataConsegnaConferma
    @Type(type = "yes_no")
    @Column(name = "ricevuto_aggiornamento", nullable = false)
    boolean ricevutoAggiornamento
    @Type(type = "yes_no")
    @Column(name = "ricevuto_annullamento", nullable = false)
    boolean ricevutoAnnullamento

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_consegna")
    Date dataConsegna

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_mancata_consegna")
    Date dataMancataConsegna

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_consegna_conferma")
    Date dataConsegnaConferma

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_mancata_consegna_conferma")
    Date dataMancataConsegnaConferma

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_consegna_agg")
    Date dataConsegnaAggiornamento

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_mancata_consegna_agg")
    Date dataMancataConsegnaAggiornamento

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_consegna_ann")
    Date dataConsegnaAnnullamento

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_mancata_consegna_ann")
    Date dataMancataConsegnaAnnullamento

    @Version
    Long version
}