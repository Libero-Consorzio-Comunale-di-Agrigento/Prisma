package it.finmatica.protocollo.dizionari

import groovy.transform.CompileStatic
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.documenti.ISmistabile
import it.finmatica.protocollo.documenti.scarto.DocumentoDatiScarto
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.hibernate.annotations.Type
import org.hibernate.envers.Audited
import org.hibernate.envers.NotAudited
import org.hibernate.envers.RelationTargetAuditMode

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

@Audited
@Entity
@Table(name = "ags_fascicoli")
@CompileStatic
class Fascicolo extends Documento implements ISmistabile {

    public static final String STATO_CORRENTE = 'CORRENTE'
    public static final String STATO_DEPOSITO = 'DEPOSITO'
    public static final String STATO_STORICO = 'STORICO'

    public static final String TIPO_DOCUMENTO = 'FASCICOLO'

    public static final String MOVIMENTO_INTERNO = 'INTERNO'

    @GeneratedValue
    @Id
    @Column(name = "id_fascicolo")
    Long id

    //@Column(name = "id_documento_esterno")
    //Long idDocumentoEsterno

    @Column(name = "id_fascicolo_padre")
    Long idFascicoloPadre

    @NotAudited
    @Column(name = "anno")
    Integer anno

    @NotAudited
    @Column(name = "numero")
    String numero

    @NotAudited
    @Column(name = "anno_numero")
    String annoNumero

    @NotAudited
    @Type(type = "yes_no")
    @Column(nullable = false, name = 'numero_prossimo_anno')
    boolean numeroProssimoAnno

    @Column(length = 2000, nullable = false)
    String oggetto

    @Column(name = "responsabile")
    String responsabile

    @Type(type = "yes_no")
    @Column(nullable = false, name = 'riservato')
    boolean riservato

    @Type(type = "yes_no")
    @Column(nullable = false, name = 'digitale')
    boolean digitale

    @Column(name = "anno_archiviazione")
    String annoArchiviazione

    @Column(name = "stato_fascicolo")
    String statoFascicolo

    @Column(length = 4000)
    String topografia

    @Column(length = 4000)
    String note

    @NotAudited
    @Column(name = "idrif")
    String idrif

    @Temporal(TemporalType.DATE)
    @Column(name = "data_creazione", nullable = false)
    Date dataCreazione

    @Temporal(TemporalType.DATE)
    @Column(name = "data_apertura")
    Date dataApertura

    @Temporal(TemporalType.DATE)
    @Column(name = "data_chiusura")
    Date dataChiusura

    @Temporal(TemporalType.DATE)
    @Column(name = "data_archiviazione")
    Date dataArchiviazione

    @NotAudited
    @Temporal(TemporalType.DATE)
    @Column(name = "data_stato")
    Date dataStato

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @Column(name = "ultimo_numero_sub")
    Integer ultimoNumeroSub

    @NotAudited
    @Column(name = "movimento")
    String movimento

    @NotAudited
    @Column(name = "numero_ord")
    String numeroOrd

    @NotAudited
    @Column(name = "nome", length = 2100)
    String nome

    @Column(name = "data_ultima_operazione")
    Date dataUltimaOperazione

    @Column(name = "sub")
    Integer sub

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_documento_dati_scarto")
    DocumentoDatiScarto datiScarto

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "documento", orphanRemoval = true)
    Set<Smistamento> smistamenti

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

    List<Smistamento> getSmistamentiCompetenza() {
        List<Smistamento> smistamentiValidi = []
        if (this.smistamenti == null) {
            return smistamentiValidi
        }
        for (Smistamento s : this.smistamenti) {
            if (s.valido && s.perCompetenza) {
                smistamentiValidi << s
            }
        }
        return smistamentiValidi
    }

    boolean isSmistamentoAttivoInCreazione() {
        return true
    }

    So4UnitaPubb getUnita() {
        return getSoggetto(TipoSoggetto.UO_COMPETENZA)?.unitaSo4
    }

    So4UnitaPubb getUnitaCreazione() {
        return getSoggetto(TipoSoggetto.UO_CREAZIONE)?.unitaSo4
    }

    Integer getAnno() {
        return anno
    }

    String getNumero() {
        return numero
    }

    SchemaProtocollo getSchemaProtocollo() {
        return null
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return CategoriaProtocollo.getInstance(TIPO_DOCUMENTO)
    }

    Fascicolo getFascicolo() {
        return null
    }

    boolean isAnnullamentoInCorso() {
        return false
    }

    String getNumerazione() {
        if (numero != null) {
            return anno + "/" + numero
        } else {
            return ''
        }
    }

    String getCodiceClassificazione() {
        return classificazione.codice
    }
}