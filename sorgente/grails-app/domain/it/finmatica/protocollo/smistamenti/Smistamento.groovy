package it.finmatica.protocollo.smistamenti

import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.commons.AbstractDomain
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.integrazioni.si4cs.MessaggioRicevuto
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
@Table(name = "agp_documenti_smistamenti")
class Smistamento extends AbstractDomain {

    public static final String TIPO_DOCUMENTO = 'SMISTAMENTO'

    public static final String DA_RICEVERE = 'DA_RICEVERE'  // su gdm è: 'R'
    public static final String IN_CARICO = 'IN_CARICO'      // su gdm è: 'C'
    public static final String ESEGUITO = 'ESEGUITO'        // su gdm è: 'E'
    public static final String STORICO = 'STORICO'          // su gdm è: 'F'
    public static final String CREATO = 'CREATO'            // su gdm è: 'N'

    public static final String CONOSCENZA = 'CONOSCENZA'
    public static final String COMPETENZA = 'COMPETENZA'

    // Serve per indicare se lo smistamento è stato creato per assegnare una competenza esplicita. Questa stringa può essere scritta nelle note. Issue #30368
    public static final String COMPETENZA_ESPLICITA = 'COMPETENZA ESPLICITA'

    @GeneratedValue
    @Id
    @Column(name = "id_documento_smistamento")
    Long id

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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_documento")
    Documento documento

    // indica l'id dello smistamento sul documentale esterno (ad es. GDM)
    @Column(name = "id_documento_esterno")
    Long idDocumentoEsterno

    @Column(name = "motivo_rifiuto")
    String motivoRifiuto
    String note

    @Column(name = "note_utente")
    String noteUtente

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
        if (documento.class == Protocollo.class) {
            return Protocollo.get(documento.id)
        }

        if (documento.class == MessaggioRicevuto.class) {
            return MessaggioRicevuto.get(documento.id)
        }

        if (documento.class == Fascicolo.class) {
            return Fascicolo.get(documento.id)
        }

        return null
    }

    boolean isCompetenzaEsplicita() {
        return (note == COMPETENZA_ESPLICITA)
    }

    boolean isPerConoscenza() {
        return (tipoSmistamento == CONOSCENZA)
    }

    boolean isPerCompetenza() {
        return (tipoSmistamento == COMPETENZA)
    }

    boolean isAttivo() {
        return [CREATO, IN_CARICO, DA_RICEVERE].contains(statoSmistamento) || isCompetenzaEsplicita()
    }

    boolean isSmistamentoAdUnitaChiusa() {
        return (null != unitaSmistamento?.al && unitaSmistamento?.al.before(new Date().clearTime()) )
    }
}