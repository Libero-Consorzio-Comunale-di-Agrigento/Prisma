package it.finmatica.protocollo.documenti.viste

import groovy.transform.CompileStatic
import it.finmatica.ad4.autenticazione.Ad4Ruolo
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.commons.Ente
import it.finmatica.gestionedocumenti.multiente.GestioneDocumentiFilter
import it.finmatica.gestioneiter.motore.WkfStep
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.annotations.Filter
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

@Entity
@Table(name = "documenti_step")
@CompileStatic
@Filter(name = GestioneDocumentiFilter.FILTER_NAME)
class DocumentoStep {

    @Id
    @Column(name = "id_documento")
    Long idDocumento

    @Column(nullable = false)
    Integer anno

    @Column(name = "descrizione_tipologia", nullable = false)
    String descrizioneTipologia

    @Column(name = "id_tipologia", nullable = false)
    Long idTipologia

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "last_updated", nullable = false)
    Date lastUpdated

    @Column(nullable = false)
    Integer numero

    @Column(nullable = false)
    String oggetto

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_protocollo")
    Protocollo protocollo

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean riservato

    @Column(nullable = false)
    String stato

    @Column(name = "stato_conservazione", nullable = false)
    String statoConservazione

    @Column(name = "stato_firma", nullable = false)
    String statoFirma

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_step")
    WkfStep step

    @Column(name = "step_descrizione", nullable = false)
    String stepDescrizione

    @Column(name = "step_nome", nullable = false)
    String stepNome

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "step_ruolo")
    Ad4Ruolo stepRuolo

    @Column(name = "step_titolo", nullable = false)
    String stepTitolo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "step_unita_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "step_unita_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "step_unita_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb stepUnita

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "step_utente")
    Ad4Utente stepUtente

    @Column(name = "tipo_oggetto", nullable = false)
    String tipoOggetto

    @Column(name = "tipo_registro", nullable = false)
    String tipoRegistro

    @Column(name = "titolo_tipologia", nullable = false)
    String titoloTipologia

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unitaProtocollante

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_ente", nullable = false)
    Ente ente

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_documento_msg_ricevuto")
    MessaggioRicevuto messaggioRicevuto
}