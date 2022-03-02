package it.finmatica.protocollo.documenti

import groovy.transform.CompileDynamic
import it.finmatica.ad4.autenticazione.Ad4Utente
import it.finmatica.gestionedocumenti.documenti.Documento
import it.finmatica.gestionedocumenti.documenti.StatoDocumento
import it.finmatica.gestionedocumenti.registri.TipoRegistro
import it.finmatica.gestionedocumenti.soggetti.TipoSoggetto
import it.finmatica.protocollo.corrispondenti.Corrispondente
import it.finmatica.protocollo.corrispondenti.MessaggioProtocollo
import it.finmatica.protocollo.dizionari.Classificazione
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.dizionari.ModalitaInvioRicezione
import it.finmatica.protocollo.documenti.emergenza.ProtocolloDatiEmergenza
import it.finmatica.protocollo.documenti.interoperabilita.ProtocolloDatiInteroperabilita
import it.finmatica.protocollo.documenti.scarto.ProtocolloDatiScarto
import it.finmatica.protocollo.documenti.telematici.ProtocolloRiferimentoTelematico
import it.finmatica.protocollo.documenti.tipologie.TipoProtocollo
import it.finmatica.protocollo.documenti.titolario.DocumentoTitolario
import it.finmatica.protocollo.documenti.viste.SchemaProtocollo
import it.finmatica.protocollo.impostazioni.CategoriaProtocollo
import it.finmatica.protocollo.impostazioni.ImpostazioniProtocollo
import it.finmatica.protocollo.smistamenti.Smistamento
import it.finmatica.so4.strutturaPubblicazione.So4UnitaPubb
import org.apache.commons.lang3.StringUtils
import org.apache.commons.lang3.time.DateUtils
import org.hibernate.annotations.Type
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
import javax.persistence.ManyToOne
import javax.persistence.OneToMany
import javax.persistence.PrePersist
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType

@Audited
@Entity
@Table(name = "agp_protocolli")
class Protocollo extends Documento implements ISmistabile {

    enum StatoArchivio {
        CORRENTE, DEPOSITO, ARCHIVIO
    }

    public static final String TIPO_DOCUMENTO = 'PROTOCOLLO'

    // codice che identifica i FileDocumento importati dalla PEC e non ancora 'importati' su agspr come file principale e allegati
    public static final String FILE_DA_MAIL = 'FILE_DA_MAIL'

    public static final String CODICE_FILE_STAMPA_UNICA = 'STAMPA_UNICA'
    public static final String CATEGORIA_LETTERA = 'LETTERA'
    public static final String CATEGORIA_PROTOCOLLO = 'PROTOCOLLO'
    public static final String CATEGORIA_PEC = 'PEC'
    public static final String CATEGORIA_PROVVEDIMENTO = 'PROVVEDIMENTO'
    public static final String CATEGORIA_EMERGENZA = 'EMERGENZA'
    public static final String CATEGORIA_REGISTRO_GIORNALIERO = 'REGISTRO_GIORNALIERO'
    public static final String CATEGORIA_DA_NON_PROTOCOLLARE = 'DA_NON_PROTOCOLLARE'
    public static final String CATEGORIA_MEMO_PROTOCOLLO = 'MEMO_PROTOCOLLO'
    public static final String CATEGORIA_DOCUMENTO_ESTERNO = 'DOCUMENTO_ESTERNO'

    public static final String MOVIMENTO_ARRIVO = 'ARRIVO'
    public static final String MOVIMENTO_PARTENZA = 'PARTENZA'
    public static final String MOVIMENTO_INTERNO = 'INTERNO'

    public static final String STEP_DA_INVIARE = 'DA INVIARE'
    public static final String STEP_INTERMEDIO = 'INTERMEDIO'
    public static final String STEP_DIRIGENTE = 'DIRIGENTE'
    public static final String STEP_INVIATO = 'INVIATO'
    public static final String STEP_REVISORE = 'REVISORE'

    public static final String STEP_PROTOCOLLO = 'PROTOCOLLO'
    public static final String STEP_REDAZIONE = 'REDAZIONE'
    public static final String STEP_FUNZIONARIO = 'FUNZIONARIO'

    public static final String ESITO_VERIFICATO = 'V'
    public static final String ESITO_FALLITO = 'N'
    public static final String ESITO_NON_VERIFICATO = ''
    public static final String ESITO_FORZATO = 'F'


    Integer anno

    @Type(type = "yes_no")
    @Column(nullable = false)
    boolean annullato

    @Column(name = "campi_protetti", length = 4000)
    String campiProtetti

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_classificazione")
    Classificazione classificazione

    @Column(name = "codice_raccomandata")
    String codiceRaccomandata

    @Type(type = "yes_no")
    @Column(name = "controllo_firmatario", nullable = false)
    boolean controlloFirmatario

    @Type(type = "yes_no")
    @Column(name = "controllo_funzionario", nullable = false)
    boolean controlloFunzionario

    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "protocollo", orphanRemoval = true)
    Set<Corrispondente> corrispondenti

    @Temporal(TemporalType.TIMESTAMP)
    Date data

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_annullamento")
    Date dataAnnullamento

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_comunicazione")
    Date dataComunicazione

    @Temporal(TemporalType.TIMESTAMP)\
    @Column(name = "data_documento_esterno")
    Date dataDocumentoEsterno

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_redazione")
    Date dataRedazione

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_stato_archivio")
    Date dataStatoArchivio

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_protocollo_dati_interop")
    ProtocolloDatiInteroperabilita datiInteroperabilita

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_protocollo_dati_scarto")
    ProtocolloDatiScarto datiScarto

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_protocollo_dati_emergenza")
    ProtocolloDatiEmergenza datiEmergenza

    @Column(name = "anno_emergenza")
    Integer annoEmergenza

    @Column(name = "numero_emergenza")
    Integer numeroEmergenza

    @Column(name = "registro_emergenza")
    String registroEmergenza

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_fascicolo")
    Fascicolo fascicolo

    String idrif

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "id_modalita_invio_ricezione")
    ModalitaInvioRicezione modalitaInvioRicezione

    String movimento

    @Column(length = 4000)
    String note

    @Column(name = "note_trasmissione", length = 4000)
    String noteTrasmissione

    Integer numero

    @Column(name = "numero_documento_esterno")
    String numeroDocumentoEsterno

    @Column(length = 4000)
    String oggetto

    @Column(name = "provvedimento_annullamento")
    String provvedimentoAnnullamento

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_schema_protocollo")
    SchemaProtocollo schemaProtocollo

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "documento", orphanRemoval = true)
    Set<Smistamento> smistamenti

    @Column(name = "stato_archivio")
    @Enumerated(EnumType.STRING)
    StatoArchivio statoArchivio

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tipo_protocollo")
    TipoProtocollo tipoProtocollo

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_registro")
    TipoRegistro tipoRegistro

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "documento", orphanRemoval = true)
    Set<DocumentoTitolario> titolari

    @NotAudited
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy = "protocollo", orphanRemoval = true)
    Set<ProtocolloRiferimentoTelematico> riferimentiTelematici

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente_annullamento")
    Ad4Utente utenteAnnullamento

    @Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
    @ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "ID_PROTOCOLLO_DATI_REG_GIORN", nullable = true)
    RegistroGiornaliero registroGiornaliero

    void setEsitoVerifica(String esitoVerifica) {
        this.getFilePrincipale()?.esitoVerifica = esitoVerifica
    }

    String getEsitoVerifica() {
        return this.getFilePrincipale()?.esitoVerifica
    }

    Date getDataVerifica() {
        return this.getFilePrincipale()?.dataVerifica
    }

    void setDataVerifica(Date dataVerifica) {
        this.getFilePrincipale()?.dataVerifica = dataVerifica
    }

    void addToCorrispondenti(Corrispondente value) {
        if (this.corrispondenti == null) {
            this.corrispondenti = new LinkedHashSet<Corrispondente>()
        }
        this.corrispondenti.add(value);
        value.protocollo = this
    }

    void removeFromCorrispondenti(Corrispondente value) {
        if (this.corrispondenti == null) {
            this.corrispondenti = new LinkedHashSet<Corrispondente>()
        }
        this.corrispondenti.remove((Object) value);
        value.protocollo = null
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

    void addToRiferimentiTelematici(ProtocolloRiferimentoTelematico value) {
        if (this.riferimentiTelematici == null) {
            this.riferimentiTelematici = new LinkedHashSet<ProtocolloRiferimentoTelematico>()
        }
        this.riferimentiTelematici.add(value);
        value.protocollo = this
    }

    void removeFromRiferimentiTelematici(ProtocolloRiferimentoTelematico value) {
        if (this.riferimentiTelematici == null) {
            this.riferimentiTelematici = new LinkedHashSet<ProtocolloRiferimentoTelematico>()
        }
        this.riferimentiTelematici.remove((Object) value);
        value.protocollo = null
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

    transient String getNomeFileStampaUnica() {
        if (isProtocollato()) {
            return "SU_${numero}_${anno}_${tipoRegistro.codice}.pdf"
        } else {
            return "SU_${id}.pdf"
        }
    }

    CategoriaProtocollo getCategoriaProtocollo() {
        return tipoProtocollo?.getCategoriaProtocollo()
    }

    List<String> getListaCampiProtetti() {
        return campiProtetti?.tokenize(',') ?: []
    }

    void proteggiCampo(String campo) {
        List<String> listaCampi = getListaCampiProtetti()
        if (!listaCampi.contains(campo)) {
            listaCampi << campo
            campiProtetti = listaCampi.join(',')
        }
    }

    void abilitaCampo(String campo) {
        List<String> listaCampi = getListaCampiProtetti()
        if (listaCampi.contains(campo)) {
            listaCampi.remove(campo)
            campiProtetti = listaCampi.join(',')
        }
    }

    Map<String, Boolean> getMappaCampiProtetti() {
        Map<String, Boolean> map = [:]
        List<String> lista = getListaCampiProtetti()
        for (String campo : lista) {
            map[campo] = true
        }
        return map
    }

    transient boolean isProtocollato() {
        return isProtocollato(numero, anno, data)
    }

    transient boolean isBloccato() {
        return isBloccato(data)
    }

    static boolean isBloccato(Date dataProtocollo) {
        // se il documento non è protocollato, ritorno sempre false (cioè il documento non è bloccato)
        if (dataProtocollo == null) {
            return false
        }

        Date dataBlocco = ImpostazioniProtocollo.DATA_BLOCCO.valoreData
        if (dataBlocco == null) {
            return false
        }
        // se la data di protocollazione è antecedente la data di blocco, allora il documento è bloccato.
        // (anche il giorno stesso è compreso nel blocco)
        return (DateUtils.isSameDay(dataProtocollo, dataBlocco) || dataProtocollo.before(dataBlocco))
    }

    static boolean isProtocollato(Integer numero, Integer anno, Date data) {
        return numero > 0 && data != null && anno > 0
    }

    boolean isFirmaVerificata() {
        return esitoVerifica == ESITO_VERIFICATO || esitoVerifica == ESITO_FORZATO
    }

    /**
     * Ottiene tutti gli smistamenti che siano in stato "valido = Y" ed
     * esclude gli smistamenti aggiunti per creare le competenze esplicite.
     *
     * Se si vuole "ciclare" su tutti gli smistamenti, è necessario utilizzare questa
     * funzione anziché la proprietà "smistamenti" che potrebbe contenere anche smistamenti "non validi".
     *
     * @return tutti gli smistamenti validi associati al documento
     */
    List<Smistamento> getSmistamentiValidi() {
        List<Smistamento> smistamentiValidi = []
        for (Smistamento s : this.smistamenti) {
            if (s.valido && !s.competenzaEsplicita) {
                smistamentiValidi << s
            }
        }
        return smistamentiValidi
    }

    List<Smistamento> getSmistamentiCompetenzaEsplicita() {
        List<Smistamento> smistamentiValidi = []
        for (Smistamento s : this.smistamenti) {
            if (s.valido && s.competenzaEsplicita) {
                smistamentiValidi << s
            }
        }
        return smistamentiValidi
    }

    Documento getProtocolloPrecedente() {
        List<Documento> documenti = getDocumentiCollegati(TipoCollegamentoConstants.CODICE_TIPO_PROTOCOLLO_PRECEDENTE)
        if (documenti.size() == 0) {
            return null
        }

        return documenti[0]
    }

    boolean isSmistamentoAttivoInCreazione() {
        return (numero > 0) || categoriaProtocollo.isSmistamentoAttivoInCreazione()
    }

    boolean isAnnullamentoInCorso() {
        return (stato == StatoDocumento.ANNULLATO) || (stato == StatoDocumento.DA_ANNULLARE) || (stato == StatoDocumento.RICHIESTO_ANNULLAMENTO)
    }

    So4UnitaPubb getUnita() {
        return getSoggetto(TipoSoggetto.UO_PROTOCOLLANTE)?.unitaSo4
    }

    SchemaProtocollo getSchemaProtocollo() {
        return schemaProtocollo
    }

    //TODO: questa variabile sarà eliminata quando le competenze funzionali saranno implementate e sarà possibile controllare
    //TODO  se l'utente può vedere i documenti riservati dopo la protocollazione
    transient boolean controlloRiservatoDopoProtocollazione = false
}