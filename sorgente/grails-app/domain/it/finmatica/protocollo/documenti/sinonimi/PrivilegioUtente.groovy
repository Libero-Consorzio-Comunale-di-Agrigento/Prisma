package it.finmatica.protocollo.documenti.sinonimi

import it.finmatica.ad4.autenticazione.Ad4Utente

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.Id
import javax.persistence.IdClass
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType
import javax.persistence.UniqueConstraint

@Entity
@Table(name = "ag_priv_utente_tmp",
        uniqueConstraints = @UniqueConstraint(columnNames = ["utente", "privilegio", "dal", "progr_unita", "ruolo"]))
@IdClass(PrivilegioUtenteKey)
class PrivilegioUtente {

    /*
     * Privilegi sul Movimento
     */
    // Protocolla documenti in arrivo
    public static final String MOVIMENTO_ARRIVO = 'ARR'
    // Protocolla documenti interni
    public static final String MOVIMENTO_INTERNO = 'INT'
    // Protocolla documenti in partenza
    public static final String MOVIMENTO_PARTENZA = 'PAR'

    /*
     * Dati di protocollo
     */
    // Modifica Oggetto di Documenti di Protocollo
    public static final String MODIFICA_OGGETTO = 'MO'
    public static final String MODIFICA_FILE_ASSOCIATO = 'MD'
    public static final String ANNULLAMENTO_PROTOCOLLO = 'ANNPROT'
    public static final String VISUALIZZA_NOTE = 'VSMINOTE'
    public static final String MODIFICA_TUTTI = 'MTOT'
    // Modifica file associato a documenti di protocollo bloccati
    public static final String MODIFICA_DOCUMENTO_BLOCCO = 'MDBLC'
    public static final String MODIFICA_DOCUMENTO_ESTREMI_BLOCCO = 'MDOCESTBLC'
    public static final String MODIFICA_DOCUMENTO_DATAARRIVO_BLOCCO = 'MDATAARRBLC'

    /*
     * Rapporti
     */
    public static final String INSERIMENTO_RAPPORTI = 'IRAP'
    public static final String ELIMINAZIONE_RAPPORTI = 'ERAP'
    public static final String MODIFICA_RAPPORTI = 'MRAP'

    /*
     * Allegati
     */
    public static final String INSERIMENTO_ALLEGATI = 'IALL'
    public static final String ELIMINAZIONE_ALLEGATI = 'EALL'
    public static final String MODIFICA_ALLEGATI = 'MALL'

    /*
     * Titolario
     */
    public static final String MODIFICA_CLASSIFICAZIONE = 'MC'
    public static final String MODIFICA_FASCICOLO = 'MFD'
    public static final String INSERIMENTO_IN_FASCICOLI_CHIUSI = 'IFC'
    public static final String INSERIMENTO_IN_FASCICOLI_APERTI = 'IF'
    public static final String INSERIMENTO_IN_CLASSIFICAZIONI_APERTE = 'ICLA'
    public static final String INSERIMENTO_IN_CLASSIFICAZIONI_APERTE_TUTTE = 'ICLATOT'
    public static final String ELIMINA_DA_FASCICOLI_CHIUSI = 'EFC'
    public static final String ELIMINA_DA_FASCICOLI_APERTI = 'EF'
    public static final String ELIMINA_DA_CLASSIFICAZIONI_APERTE = 'ECLA'
    public static final String ELIMINA_DA_CLASSIFICAZIONI_APERTE_TUTTE = 'ECLATOT'
    public static final String MODIFICA_DATI_ARCHIVIO = 'MFARC'
    public static final String USA_FASCICOLI_PERSONALE = 'CLASPERS'

    /*
     * Smistamento
     */
    // consente la creazione di smistamenti con certe unità di trasmissione
    public static final String SMISTAMENTO_CREA = 'ISMI'
    // indica che l'utente può prendere in carico lo smistamento per la data unità
    public static final String SMISTAMENTO_CARICO = 'CARICO'
    // indica che l'utente può creare smistamenti con qualsiasi unità
    public static final String SMISTAMENTO_CREA_SEMPRE = 'ISMITOT'
    // indica che l'utente può vedere gli smistamenti di una certa unità
    public static final String SMISTAMENTO_VISUALIZZA = 'VS'
    // indica che l'utente può vedere gli smistamenti a documenti RISERVATI di una certa unità
    public static final String SMISTAMENTO_VISUALIZZA_RISERVATO = 'VSR'
    // indica che l'utente può vedere tutti i componenti di tutte le unità nell'albero di ricerca delle unità/componenti
    public static final String VISUALIZZA_COMPONENTI_TUTTE_UNITA = 'ASSTOT'
    // indica che l'utente può vedere tutti i componenti di tutte le unità
    public static final String VISUALIZZA_COMPONENTI_UNITA = 'ASS'
    // indica che l'utente può smistare a qualsiasi unita
    public static final String VISUALIZZA_TUTTE_UNITA = 'SMISTATUTTI'

    /*
     * Soggetti
     */
    public static final String REDATTORE_LETTERA = 'REDLET'
    public static final String REDATTORE_PROTOCOLLO = 'CPROT'
    public static final String FIRMA = 'FIRMA'
    public static final String INSERISCI_ANAGRAFICA = 'IANA'
    public static final String MODIFICA_ANAGRAFICA = 'MANA'

    /*
     * Altri privilegi da categorizzare
     */

    // Consente di creare fascicoli in anni precedenti al corrente
    public static final String CFANYY = 'CFANYY'
    // Consente di creare fascicoli nell'anno successivo al corrente
    public static final String CFFUTURO = 'CFFUTURO'
    // Crea Classificazioni
    public static final String CRECLA = 'CRECLA'
    // Crea Fascicoli
    public static final String CREF = 'CREF'
    // Crea Registri
    public static final String CREREG = 'CREREG'
    // Crea Tipi Documento
    public static final String CRETIDO = 'CRETIDO'
    // Crea documenti da fascicolare
    public static final String DAFASC = 'DAFASC'
    // Estende tutti i privilegi del ruolo a tutte le unita' dell'area
    public static final String EPAREA = 'EPAREA'
    // Estende tutti i privilegi del ruolo alle unità dello stesso livello
    public static final String EPEQU = 'EPEQU'
    // Estende tutti i privilegi del ruolo alle unità inferiori
    public static final String EPSUB = 'EPSUB'
    // Estende tutti i privilegi del ruolo alle unità di tutti i livelli inferiori
    public static final String EPSUBTOT = 'EPSUBTOT'
    // Estende tutti i privilegi del ruolo all'unità superiore
    public static final String EPSUP = 'EPSUP'
    // Eliminazione Smistamenti di Documenti di Protocollo
    public static final String ESMI = 'ESMI'
    // Eliminazione Smistamenti in qualunque Documento di Protocollo
    public static final String ESMITOT = 'ESMITOT'
    // Elimina Tipi Documento
    public static final String ETIDO = 'ETIDO'
    // Inserisce cartelle e/o documenti in Classificazioni chiuse
    public static final String ICC = 'ICC'
    // Inserisce cartelle e/o documenti in tutte le Classificazioni chiuse
    public static final String ICCTOT = 'ICCTOT'
    // Gestisce le competenze sulle Classificazioni
    public static final String MANCLA = 'MANCLA'
    // Gestisce le competenze sui Fascicoli
    public static final String MANF = 'MANF'
    // Gestisce le competenze sui Movimenti
    public static final String MANMOV = 'MANMOV'
    // Gestisce le competenze sui Registri
    public static final String MANREG = 'MANREG'
    // Gestisce le competenze sui Tipi Documento
    public static final String MANTIDO = 'MANTIDO'
    // Modifica Classificazioni chiuse
    public static final String MCC = 'MCC'
    // Modifica tutte le Classificazioni chiuse
    public static final String MCCTOT = 'MCCTOT'
    // Modifica Classificazioni aperte
    public static final String MCLA = 'MCLA'
    // Modifica tutte le Classificazioni aperte
    public static final String MCLATOT = 'MCLATOT'
    // Modifica i Documenti inseriti in fascicoli che non sono piu' in stato corrente
    public static final String MDDEP = 'MDDEP'
    // Modifica i Documenti non riservati per i quali la propria unita' e' esibente
    public static final String ME = 'ME'
    // Modifica i Documenti riservati per i quali la propria unita' e' esibente
    public static final String MER = 'MER'
    // Modifica Fascicoli aperti
    public static final String MF = 'MF'
    // Modifica Fascicoli chiusi
    public static final String MFC = 'MFC'
    // Modifica fascicoli aperti riservati
    public static final String MFR = 'MFR'
    // Modifica fascicoli aperti riservati di competenza della propria unita'
    public static final String MFRU = 'MFRU'
    // Modifica fascicoli aperti riservati, creati dalla  propria unita'
    public static final String MFRUCRE = 'MFRUCRE'
    // Modifica Fascicoli aperti di competenza della propria unita', non riservati
    public static final String MFU = 'MFU'
    // Modifica Fascicoli aperti, creati dalla propria unita', non riservati
    public static final String MFUCRE = 'MFUCRE'
    // Modifica i Documenti non riservati Protocollati dalla propria unita'
    public static final String MPROT = 'MPROT'
    // Modifica i Documenti riservati Protocollati dalla propria unita'
    public static final String MPROTR = 'MPROTR'
    // Modifica documenti smistati alla propria unita', non riservati
    public static final String MS = 'MS'
    // Modifica i documenti riservati smistati alla propria unita'
    public static final String MSR = 'MSR'
    // Modifica Tipi Documento
    public static final String MTIDO = 'MTIDO'
    // Modifica tutti i documenti protocollati riservati
    public static final String MTOTR = 'MTOTR'
    // Consente di inviare tramite la casella di posta elettronica Istituzionale
    public static final String PINVIOI = 'PINVIOI'
    // Consente di visualizzare i messaggi della casella di posta elettronica Istituzionale
    public static final String PMAILI = 'PMAILI'
    // Consente di visualizzare i messaggi di tutte le casella di posta elettronica
    public static final String PMAILT = 'PMAILT'
    // Consente di visualizzare i messaggi della casella di posta elettronica di un'unita'
    public static final String PMAILU = 'PMAILU'
    // Consente di pubblicare un protocollo all' Albo Pretorio
    public static final String PUBALBO = 'PUBALBO'
    // Smista documenti all'interno dell'area
    public static final String SMISTAAREA = 'SMISTAAREA'
    // Visualizza Classificazioni chiuse di competenza
    public static final String VCC = 'VCC'
    // Visualizza tutte le Classificazioni chiuse
    public static final String VCCTOT = 'VCCTOT'
    // Visualizza Classificazioni aperte di competenza
    public static final String VCLA = 'VCLA'
    // Visualizza tutte le Classificazioni aperte
    public static final String VCLATOT = 'VCLATOT'
    // Visualizza documenti da ricevere delle unita' di competenza, non riservati
    public static final String VDDR = 'VDDR'
    // Visualizza documenti da ricevere riservati  delle unita' di competenza
    public static final String VDDRR = 'VDDRR'
    // Visualizza documenti per i quali la propria unita' e' esibente, non riservati
    public static final String VE = 'VE'
    // Visualizza documenti riservati, per i quali la propria unita' e' esibente
    public static final String VER = 'VER'
    // Visualizza Fascicoli aperti, non riservati
    public static final String VF = 'VF'
    // Visualizza Fascicoli chiusi, non riservati
    public static final String VFC = 'VFC'
    // Visualizza Fascicoli chiusi, non riservati di competenza della propria unita'
    public static final String VFCU = 'VFCU'
    // Visualizza Fascicoli chiusi, non riservati creati dalla propria unita'
    public static final String VFCUCRE = 'VFCUCRE'
    // Visualizza fascicoli aperti riservati
    public static final String VFR = 'VFR'
    // Visualizza Fascicoli chiusi, riservati
    public static final String VFRC = 'VFRC'
    // Visualizza Fascicoli chiusi, riservati alla propria unita'
    public static final String VFRCU = 'VFRCU'
    // Visualizza Fascicoli chiusi, riservati, creati dalla propria unita'
    public static final String VFRCUCRE = 'VFRCUCRE'
    // Visualizza fascicoli aperti riservati della propria unita'
    public static final String VFRU = 'VFRU'
    // Visualizza fascicoli aperti riservati, creati dalla  propria unita'
    public static final String VFRUCRE = 'VFRUCRE'
    // Visualizza fascicoli aperti di competenza della propria unita', non riservati
    public static final String VFU = 'VFU'
    // Visualizza fascicoli aperti, creati dalla  propria unita', non riservati
    public static final String VFUCRE = 'VFUCRE'
    // Visualizza documenti protocollati dalla propria unita', non riservati
    public static final String VP = 'VP'
    // Visualizza documenti riservati, protocollati dalla propria unita'
    public static final String VPR = 'VPR'
    // OBSOLETO Visualizza Tipi Documento
    public static final String VTIDO = 'VTIDO'
    // Visualizza tutti i documenti protocollati non riservati
    public static final String VTOT = 'VTOT'
    // Visualizza tutti i documenti protocollati riservati
    public static final String VTOTR = 'VTOTR'

    // suffisso del privilegio di blocco
    public static final String PRIVILEGIO_BLOCCO = 'BLC'

    // privilegi per visualizzazione massimario di scarto
    public static final String AGPPRALL = 'AGPPRALL'
    public static final String AGPSUP = 'AGPSUP'

    public static final List<String> blocchi = [MODIFICA_OGGETTO, MODIFICA_FILE_ASSOCIATO, INSERIMENTO_RAPPORTI, ELIMINAZIONE_RAPPORTI, MODIFICA_RAPPORTI, INSERIMENTO_ALLEGATI, ELIMINAZIONE_ALLEGATI, MODIFICA_ALLEGATI, 'PROT' /* da ignorare */]

    // il codice ed il progressivo dell'unità di so4.
    @Id
    @Column(name = "unita")
    String codiceUnita

    // il progressivo dell'unità di so4.
    @Column(name = "progr_unita")
    Long progrUnita

    // il codice del privilegio
    @Id
    String privilegio

    // l'utente che ha il privilegio
    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utente")
    Ad4Utente utente

    // il ruolo per l'utente
    @Column(nullable = false)
    String ruolo

    @Temporal(TemporalType.TIMESTAMP)
    Date al

    @Temporal(TemporalType.TIMESTAMP)
    @Column(nullable = false)
    Date dal

    @Column(nullable = false)
    String appartenenza

    transient boolean isConBlocco() {
        return isConBlocco(this.privilegio)
    }

    transient String getPrivilegioBlocco() {
        return getPrivilegioBlocco(privilegio)
    }

    static boolean isConBlocco(String privilegio) {
        return blocchi.contains(privilegio)
    }

    static String getPrivilegioBlocco(String privilegio) {
        if (isConBlocco(privilegio)) {
            return privilegio + PRIVILEGIO_BLOCCO
        }

        return privilegio
    }
}