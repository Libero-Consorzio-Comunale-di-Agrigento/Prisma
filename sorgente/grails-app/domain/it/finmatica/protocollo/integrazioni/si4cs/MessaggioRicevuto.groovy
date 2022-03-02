package it.finmatica.protocollo.integrazioni.si4cs

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.envers.Audited
import org.hibernate.envers.NotAudited
import org.hibernate.envers.RelationTargetAuditMode

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.EnumType
import javax.persistence.Enumerated
import javax.persistence.FetchType
import javax.persistence.JoinColumn
import javax.persistence.Lob
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.persistence.Table

@Audited
@Entity
@Table(name = "agp_msg_ricevuti_dati_prot")
@CompileStatic
class MessaggioRicevuto extends Documento implements ISmistabile {

    public static final String TIPO_DOCUMENTO = 'MESSAGGIO_ARRIVO'

    public static final String MESSAGGIO_EML = 'messaggio.eml'

    public static enum Stato {
        DA_GESTIRE("Da Gestire"),
        DA_PROTOCOLLARE_CON_SEGNATURA("Da Protocollare con Segnatura"),
        DA_PROTOCOLLARE_SENZA_SEGNATURA("Da Protocollare senza Segnatura"),
        GESTITO("Gestito"),
        GENERATA_ECCEZIONE("Generata Eccezione"),
        NON_PROTOCOLLATO("Non Protocollato"),
        PROTOCOLLATO("Protocollato"),
        SCARTATO("Scartato"),
        TUTTI("(Tutti)")

        private final String descrizione;

        private Stato(String descrizione) {
            this.descrizione = descrizione
        }

        public String getDescrizione() {
            return this.descrizione;
        }
    }

    @Column(name = "id_messaggio_si4cs", nullable = false)
    Long idMessaggioSi4Cs

    @Column(nullable = false, name = "stato")
    @Enumerated(EnumType.STRING)
    Stato statoMessaggio

    @Column(name = "data_ricezione")
    Date dataRicezione

    @Column(name = "data_spedizione")
    Date dataSpedizione

    @Column(name = "data_stato", nullable = false)
    Date dataStato

    @NotAudited
    @Column(length = 2000)
    String mittente

    @NotAudited
    @Lob
    String destinatari

    @NotAudited
    @Lob
    @Column(name = "destinatari_conoscenza")
    String destinatariConoscenza

    @NotAudited
    @Lob
    @Column(name = "destinatari_nascosti")
    String destinatariNascosti

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_fascicolo")
    Fascicolo fascicolo

    @NotAudited
    @Column(name = "mime_testo")
    String mimeTesto

    @NotAudited
    @Lob
    String testo

    @NotAudited
    @Column(length = 4000)
    String note

    @NotAudited
    @Column(length = 255)
    String tipo

    @NotAudited
    @Column(length = 2000)
    String oggetto

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "documento", orphanRemoval = true)
    Set<Smistamento> smistamenti

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "documento", orphanRemoval = true)
    Set<DocumentoTitolario> titolari

    @NotAudited
    @Column(name = "IDRIF")
    String idrif

    boolean isAnnullamentoInCorso() {
        return false
    }

    public static Enum getStatoMessaggio(String stato) {
        return Enum.valueOf(Stato.class, stato)
    }

    void addToSmistamenti(Smistamento value) {
        if (this.smistamenti == null) {
            this.smistamenti = new LinkedHashSet<Smistamento>()
        }
        this.smistamenti.add(value);
        value.documento = this
    }

    void removeFromSmistamenti(Smistamento value) {
        if (this.smistamenti == null) {
            this.smistamenti = new LinkedHashSet<Smistamento>()
        }
        this.smistamenti.remove((Object) value);
        value.documento = null
    }

    List<Smistamento> getSmistamentiValidi() {
        List<Smistamento> smistamentiValidi = []
        if (this.smistamenti == null) {
            return smistamentiValidi
        }
        for (Smistamento s : this.smistamenti) {
            if (s.valido && !s.competenzaEsplicita) {
                smistamentiValidi << s
            }
        }
        return smistamentiValidi
    }

    List<Smistamento> getSmistamentiCompetenzaEsplicita() {
        List<Smistamento> smistamentiValidi = []
        if (this.smistamenti == null) {
            return smistamentiValidi
        }
        for (Smistamento s : this.smistamenti) {
            if (s.valido && s.competenzaEsplicita) {
                smistamentiValidi << s
            }
        }
        return smistamentiValidi
    }

    void addToTitolari(DocumentoTitolario value) {
        if (this.titolari == null) {
            this.titolari = new LinkedHashSet<DocumentoTitolario>()
        }
        this.titolari.add(value);
        value.documento = this
    }

    void removeFromTitolari(DocumentoTitolario value) {
        if (this.titolari == null) {
            this.titolari = new LinkedHashSet<DocumentoTitolario>()
        }
        this.titolari.remove((Object) value);
        value.documento = null
    }

    boolean isSmistamentoAttivoInCreazione() {
        return true
    }

    So4UnitaPubb getUnita() {
        return getSoggetto(TipoSoggetto.UO_MESSAGGIO)?.unitaSo4
    }

    SchemaProtocollo getSchemaProtocollo() {
        return null
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return null
    }

    Integer getNumero() {
        return null
    }

    String getMovimento() {
        return null
    }
}