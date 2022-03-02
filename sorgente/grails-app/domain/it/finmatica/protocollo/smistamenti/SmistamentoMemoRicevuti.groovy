package it.finmatica.protocollo.smistamenti

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.protocollo.integrazioni.si4cs.MemoRicevutiGDM
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb

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
@Table(name = "agp_memo_ricevuti_smistamenti")
class SmistamentoMemoRicevuti extends AbstractDomain {

    @GeneratedValue
    @Id
    @Column(name = "id_documento_smistamento")
    Long id

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_documento")
    MemoRicevutiGDM documento

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_assegnazione")
    Date dataAssegnazione

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_esecuzione")
    Date dataEsecuzione

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_presa_in_carico")
    Date dataPresaInCarico

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_rifiuto")
    Date dataRifiuto

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_smistamento")
    Date dataSmistamento

    // indica l'id dello smistamento sul documentale esterno (ad es. GDM)
    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno

    @Column(name = "motivo_rifiuto")
    String motivoRifiuto
    String note

    @Column(name = "note_utente")
    String noteUtente

    @Column(name = "IDRIF")
    String idrif

    @Column(name = "stato_smistamento", nullable = false)
    String statoSmistamento

    @Column(name = "tipo_smistamento", nullable = false)
    String tipoSmistamento

    // unità scelta o nel caso di componente è l'unità di appartenenza
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumns([@JoinColumn(name = "unita_smistamento_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_smistamento_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_smistamento_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unitaSmistamento

    // creazione: unità protocollante
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns([@JoinColumn(name = "unita_trasmissione_progr", referencedColumnName = "progr"),
            @JoinColumn(name = "unita_trasmissione_dal", referencedColumnName = "dal"),
            @JoinColumn(name = "unita_trasmissione_ottica", referencedColumnName = "ottica")])
    So4UnitaPubb unitaTrasmissione

    // utente di sessione nella fase di assegnazione
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_assegnante")
    Ad4Utente utenteAssegnante

    // utente scelto all'inizio o in fase di assegnazione
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_assegnatario")
    Ad4Utente utenteAssegnatario

    // utente che esegue lo smistamento
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_esecuzione")
    Ad4Utente utenteEsecuzione

    // che prende in carico lo smistamento
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_presa_in_carico")
    Ad4Utente utentePresaInCarico

    // utente che rifiuta lo smistamento
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_rifiuto")
    Ad4Utente utenteRifiuto

    // utente di sessione
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_trasmissione")
    Ad4Utente utenteTrasmissione

    @Version
    Long version

    static namedQueries = {
        documentoAndStato { Long idDocumento, List<String> stati ->
            or {
                isNull('note')
                ne('note', Smistamento.COMPETENZA_ESPLICITA)
            }

            eq('documento.id', idDocumento)
            'in'('statoSmistamento', stati)

            order('dataSmistamento', 'desc')
        }
    }

    // TODO[SPRINGBOOT], da verificare: "deve ritornare "def" perché se ritorna Protocollo fallisce la validazione del db."
    def getProtocollo() {

        if (documento.class == MemoRicevutiGDM.class) {
            return MemoRicevutiGDM.get(documento.id)
        }

        return null
    }

    boolean isCompetenzaEsplicita() {
        return (note == Smistamento.COMPETENZA_ESPLICITA)
    }

    boolean isPerConoscenza() {
        return (tipoSmistamento == Smistamento.CONOSCENZA)
    }

    boolean isPerCompetenza() {
        return (tipoSmistamento == Smistamento.COMPETENZA)
    }

    boolean isAttivo() {
        return [Smistamento.CREATO, Smistamento.IN_CARICO, Smistamento.DA_RICEVERE].contains(statoSmistamento) || isCompetenzaEsplicita()
    }

    boolean isSmistamentoAdUnitaChiusa() {
        return (null != unitaSmistamento?.al && unitaSmistamento?.al.before(new Date().clearTime()) )
    }


}