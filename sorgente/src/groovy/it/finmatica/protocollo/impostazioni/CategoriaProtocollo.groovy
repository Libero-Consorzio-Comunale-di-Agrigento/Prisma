package it.finmatica.protocollo.impostazioni

import groovy.transform.CompileStatic
import it.finmatica.protocollo.dizionari.Fascicolo
import it.finmatica.protocollo.documenti.Protocollo
import it.finmatica.protocollo.documenti.sinonimi.PrivilegioUtente
import it.finmatica.protocollo.integrazioni.ad4.AssistenteVirtualeService

@CompileStatic
class CategoriaProtocollo {

    // queste che seguono sono le definizioni delle categorie
    public static final CategoriaProtocollo CATEGORIA_PROTOCOLLO = new CategoriaProtocollo(Protocollo.CATEGORIA_PROTOCOLLO
            , "Protocollo"
            , [Protocollo.MOVIMENTO_ARRIVO, Protocollo.MOVIMENTO_INTERNO, Protocollo.MOVIMENTO_PARTENZA]
            , true, false
            , "SEGRETERIA.PROTOCOLLO"
            , "M_PROTOCOLLO"
            , "P"
            , PrivilegioUtente.REDATTORE_PROTOCOLLO
            , "p_manuale.png"
            , ImpostazioniProtocollo.URL_CARICO_DESC
            , ImpostazioniProtocollo.URL_ASS_DESC
            , ImpostazioniProtocollo.URL_DA_RIC_CON_DESC
            , ImpostazioniProtocollo.URL_DA_RIC_COMP_DESC)

    public static final CategoriaProtocollo CATEGORIA_LETTERA = new CategoriaProtocollo(Protocollo.CATEGORIA_LETTERA
            , "Lettera"
            , [Protocollo.MOVIMENTO_INTERNO, Protocollo.MOVIMENTO_PARTENZA]
            , true, true
            , "SEGRETERIA.PROTOCOLLO"
            , "LETTERA_USCITA"
            , "P"
            , PrivilegioUtente.REDATTORE_LETTERA
            , "lettera.png")

    public static final CategoriaProtocollo CATEGORIA_PROVVEDIMENTO = new CategoriaProtocollo(Protocollo.CATEGORIA_PROVVEDIMENTO
            , "Provvedimento"
            , [Protocollo.MOVIMENTO_INTERNO]
            , true, true
            , "SEGRETERIA.PROTOCOLLO"
            , "M_PROVVEDIMENTO"
            , "P"
            , PrivilegioUtente.ANNULLAMENTO_PROTOCOLLO
            , "provvedimento.png")

    public static final CategoriaProtocollo CATEGORIA_PEC = new CategoriaProtocollo(Protocollo.CATEGORIA_PEC
            , "Pec"
            , [Protocollo.MOVIMENTO_ARRIVO]
            , true, false
            , "SEGRETERIA.PROTOCOLLO"
            , "M_PROTOCOLLO_INTEROPERABILITA"
            , "P"
            , PrivilegioUtente.REDATTORE_PROTOCOLLO
            , "pec.png"
            , ImpostazioniProtocollo.URL_CARICO_DESC
            , ImpostazioniProtocollo.URL_ASS_DESC
            , ImpostazioniProtocollo.URL_DA_RIC_CON_DESC
            , ImpostazioniProtocollo.URL_DA_RIC_COMP_DESC)

    public static final CategoriaProtocollo CATEGORIA_EMERGENZA = new CategoriaProtocollo(Protocollo.CATEGORIA_EMERGENZA
            , "Emergenza"
            , [Protocollo.MOVIMENTO_INTERNO]
            , true, false
            , "SEGRETERIA.PROTOCOLLO"
            , "M_PROTOCOLLO_EMERGENZA"
            , "P"
            , PrivilegioUtente.REDATTORE_PROTOCOLLO
            , "emergenza.png")

    public static final CategoriaProtocollo CATEGORIA_REGISTRO_GIORNALIERO = new CategoriaProtocollo(Protocollo.CATEGORIA_REGISTRO_GIORNALIERO
            , "Registro Giornaliero"
            , [Protocollo.MOVIMENTO_INTERNO]
            , true, true
            , "SEGRETERIA.PROTOCOLLO"
            , "M_REGISTRO_GIORNALIERO"
            , "P"
            , PrivilegioUtente.REDATTORE_PROTOCOLLO
            , "reg_giornaliero.png")

    public static final CategoriaProtocollo CATEGORIA_DA_NON_PROTOCOLLARE = new CategoriaProtocollo(Protocollo.CATEGORIA_DA_NON_PROTOCOLLARE
            , "Da Non Protocollare"
            , []
            , false, false
            , "SEGRETERIA.PROTOCOLLO"
            , "DOC_DA_FASCICOLARE"
            , "D"
            , PrivilegioUtente.DAFASC
            , "doc.png"
            , ImpostazioniProtocollo.URL_CARICO_DESC_NP
            , ImpostazioniProtocollo.URL_ASS_DESC_NP
            , ImpostazioniProtocollo.URL_DA_RIC_CON_DESC_NP
            , ImpostazioniProtocollo.URL_DA_RIC_COMP_DESC_NP)

    private static final CategoriaProtocollo CATEGORIA_MEMO_PROTOCOLLO = new CategoriaProtocollo(Protocollo.CATEGORIA_MEMO_PROTOCOLLO
            , "Memo Protocollo"
            , []
            , false, false
            , "SEGRETERIA"
            , "MEMO_PROTOCOLLO"
            , "D"
            , ""
            , PrivilegioUtente.REDATTORE_PROTOCOLLO
            , ImpostazioniProtocollo.URL_CARICO_DESC_MEMO
            , ImpostazioniProtocollo.URL_ASS_DESC_MEMO
            , ImpostazioniProtocollo.URL_DA_RIC_CON_DESC_MEMO
            , ImpostazioniProtocollo.URL_DA_RIC_COMP_DESC_MEMO)

    public static final CategoriaProtocollo CATEGORIA_FASCICOLO = new CategoriaProtocollo(Fascicolo.TIPO_DOCUMENTO
            , "Fascicolo"
            , []
            , false, false
            , "SEGRETERIA"
            , "FASCICOLO"
            , "D"
            , PrivilegioUtente.DAFASC
            , "doc.png"
            , ImpostazioniProtocollo.URL_CARICO_DESC_NP
            , ImpostazioniProtocollo.URL_ASS_DESC_NP
            , ImpostazioniProtocollo.URL_DA_RIC_CON_DESC_NP
            , ImpostazioniProtocollo.URL_DA_RIC_COMP_DESC_NP)

    public static final CategoriaProtocollo CATEGORIA_DOCUMENTO_ESTERNO = new CategoriaProtocollo(Protocollo.CATEGORIA_DOCUMENTO_ESTERNO
            , "Documento Esterno"
            , [Protocollo.MOVIMENTO_INTERNO, Protocollo.MOVIMENTO_ARRIVO, Protocollo.MOVIMENTO_PARTENZA]
            , false, false
            , null
            , null
            , "P"
            , PrivilegioUtente.REDATTORE_PROTOCOLLO
            , "doc.png")

    // questo è il "repository" delle categorie disponibili
    private static final Map<String, CategoriaProtocollo> categorie = [(CATEGORIA_PROTOCOLLO.codice)            : CATEGORIA_PROTOCOLLO
                                                                       , (CATEGORIA_LETTERA.codice)             : CATEGORIA_LETTERA
                                                                       , (CATEGORIA_PROVVEDIMENTO.codice)       : CATEGORIA_PROVVEDIMENTO
                                                                       , (CATEGORIA_PEC.codice)                 : CATEGORIA_PEC
                                                                       , (CATEGORIA_EMERGENZA.codice)           : CATEGORIA_EMERGENZA
                                                                       , (CATEGORIA_REGISTRO_GIORNALIERO.codice): CATEGORIA_REGISTRO_GIORNALIERO
                                                                       , (CATEGORIA_DA_NON_PROTOCOLLARE.codice) : CATEGORIA_DA_NON_PROTOCOLLARE
                                                                       , (CATEGORIA_FASCICOLO.codice)           : CATEGORIA_FASCICOLO
                                                                       , (CATEGORIA_MEMO_PROTOCOLLO.codice)     : CATEGORIA_MEMO_PROTOCOLLO
                                                                       , (CATEGORIA_DOCUMENTO_ESTERNO.codice)     : CATEGORIA_DOCUMENTO_ESTERNO]

    private static final List<String> codiciModelloGDM =  [ CategoriaProtocollo.CATEGORIA_LETTERA.codiceModelloGdm,
                                                            CategoriaProtocollo.CATEGORIA_PROVVEDIMENTO.codiceModelloGdm,
                                                            CategoriaProtocollo.CATEGORIA_DA_NON_PROTOCOLLARE.codiceModelloGdm,
                                                            CategoriaProtocollo.CATEGORIA_PROTOCOLLO.codiceModelloGdm,
                                                            CategoriaProtocollo.CATEGORIA_REGISTRO_GIORNALIERO.codiceModelloGdm,
                                                            CategoriaProtocollo.CATEGORIA_MEMO_PROTOCOLLO.codiceModelloGdm]

    private final String codice
    private final String descrizione
    private final List<String> movimenti
    // indica se il movimento è obbligatorio nel dizionario tipo-protocollo
    private final boolean movimentoObbligatorio
    // indica se il modello testo è obbligatorio nel dizionario tipo-protocollo
    private final boolean modelloTestoObbligatorio
    private final String privilegioCreazione
    private final String icona

    // dati per il salvataggio su gdm
    private final String codiceAreaGdm
    private final String codiceModelloGdm

    // dati per la jworklist
    private final String tipoDocumentoJWorklist
    private final ImpostazioniProtocollo oggettoNotificaInCarico
    private final ImpostazioniProtocollo oggettoNotificaInCaricoAssegnata
    private final ImpostazioniProtocollo oggettoNotificaDaRiceverePerConoscenza
    private final ImpostazioniProtocollo oggettoNotificaDaRiceverePerCompetenza

    CategoriaProtocollo(String codice, String descrizione, List<String> movimenti, boolean movimentoObbligatorio, boolean modelloTestoObbligatorio
                        , String codiceAreaGdm, String codiceModelloGdm, String tipoDocumentoJWorklist, String privilegioCreazione, String icona
                        , ImpostazioniProtocollo oggettoNotificaInCarico, ImpostazioniProtocollo oggettoNotificaInCaricoAssegnata
                        , ImpostazioniProtocollo oggettoNotificaDaRiceverePerConoscenza, ImpostazioniProtocollo oggettoNotificaDaRiceverePerCompetenza) {
        this.codice = codice
        this.descrizione = descrizione
        this.movimenti = movimenti
        this.movimentoObbligatorio = movimentoObbligatorio
        this.codiceAreaGdm = codiceAreaGdm
        this.codiceModelloGdm = codiceModelloGdm
        this.tipoDocumentoJWorklist = tipoDocumentoJWorklist
        this.oggettoNotificaInCarico = oggettoNotificaInCarico
        this.oggettoNotificaInCaricoAssegnata = oggettoNotificaInCaricoAssegnata
        this.oggettoNotificaDaRiceverePerConoscenza = oggettoNotificaDaRiceverePerConoscenza
        this.oggettoNotificaDaRiceverePerCompetenza = oggettoNotificaDaRiceverePerCompetenza
        this.modelloTestoObbligatorio = modelloTestoObbligatorio
        this.privilegioCreazione = privilegioCreazione
        this.icona = icona
    }

    CategoriaProtocollo(String codice, String descrizione, List<String> movimenti
                        , boolean movimentoObbligatorio, boolean modelloTestoObbligatorio
                        , String codiceAreaGdm, String codiceModelloGdm
                        , String tipoDocumentoJWorklist, String privilegioCreazione, String icona) {
        this(codice, descrizione, movimenti, movimentoObbligatorio, modelloTestoObbligatorio, codiceAreaGdm
                , codiceModelloGdm, tipoDocumentoJWorklist, privilegioCreazione, icona, null
                , null, null, null)
    }

    String getCodice() {
        return codice
    }

    String getDescrizione() {
        return descrizione
    }

    List<String> getMovimenti() {
        // ritorno un clone della lista perché voglio essere sicuro che nessuno modifichi l'istanza interna siccome è un "sigleton" per tutta l'applicazione.
        return new ArrayList<>(movimenti)
    }

    List<String> getMovimentiTipoDocumento() {
        if (movimentoObbligatorio) {
            // ritorno un clone della lista perché voglio essere sicuro che nessuno modifichi l'istanza interna siccome è un "sigleton" per tutta l'applicazione.
            return getMovimenti()
        } else {
            // nota: uso stringa vuota come "nessun movimento" perché così zk riesce a selezionarlo nella combo e comunque su oracle viene registrato come "null"
            return [""] + getMovimenti()
        }
    }

    boolean isMovimentoObbligatorio() {
        return movimentoObbligatorio
    }

    String getCodiceAreaGdm() {
        return codiceAreaGdm
    }

    String getCodiceModelloGdm() {
        return codiceModelloGdm
    }

    String getTipoDocumentoJWorklist() {
        return tipoDocumentoJWorklist
    }

    String getOggettoNotificaInCarico(boolean assegnato) {
        if (assegnato) {
            return this.oggettoNotificaInCaricoAssegnata?.valore
        } else {
            return this.oggettoNotificaInCarico?.valore
        }
    }

    String getOggettoNotificaDaRicevere(boolean perCompetenza) {
        if (perCompetenza) {
            return this.oggettoNotificaDaRiceverePerCompetenza?.valore
        } else {
            return this.oggettoNotificaDaRiceverePerConoscenza?.valore
        }
    }

    boolean isModelloTestoObbligatorio() {
        return modelloTestoObbligatorio
    }

    String getPrivilegioCreazione() {
        return privilegioCreazione
    }

    String getIcona() {
        return icona
    }

    boolean isCreaTimbroPdf() {
        return isLettera() || isPec() || isProtocollo()
    }

    boolean isStatoArchivisticoVisibile() {
        return !isPec()
    }

    boolean sovrascriviProtocollatore() {
        return isPec() || isProtocollo()
    }

    boolean isDatiScartoVisibili() {
        return !isPec()
    }

    boolean isImportaFileDaMail() {
        return isPec()
    }

    boolean isDatiInteroperabilitaVisibili() {
        return isPec()
    }

    boolean isPec() {
        return (codice == CATEGORIA_PEC.codice)
    }

    boolean isLettera() {
        return (codice == CATEGORIA_LETTERA.codice)
    }

    boolean isProtocollo() {
        return (codice == CATEGORIA_PROTOCOLLO.codice)
    }

    boolean isProvvedimento() {
        return (codice == CATEGORIA_PROVVEDIMENTO.codice)
    }

    //TODO aggiungere categoria FASCICOLO
    boolean isSmistamentoAttivoInCreazione() {
        return (codice == CATEGORIA_DA_NON_PROTOCOLLARE.codice || codice == CATEGORIA_MEMO_PROTOCOLLO.codice || codice == CATEGORIA_FASCICOLO.codice)
    }

    boolean isCategoriaPerAssistenteVirtuale() {
        return (codice == CATEGORIA_LETTERA.codice || codice == CATEGORIA_PROTOCOLLO.codice || codice == CATEGORIA_PROVVEDIMENTO.codice)
    }

    String getPaginaCategoriaAssistenteVirtuale() {
        return (codice == CATEGORIA_PROVVEDIMENTO.codice) ? AssistenteVirtualeService.PAGINA_APPLICATICA_PROVVEDIMENTO :
                (codice == CATEGORIA_LETTERA.codice) ?
                        AssistenteVirtualeService.PAGINA_APPLICATICA_LETTERA : AssistenteVirtualeService.PAGINA_APPLICATICA_PROTOCOLLAZIONE
    }

    boolean isDaNonProtocollare() {
        return (codice == CATEGORIA_DA_NON_PROTOCOLLARE.codice)
    }

    String getCodiceCampoKeyIter() {
        return (codice == CATEGORIA_LETTERA.codice) ? 'KEY_ITER_LETTERA' : 'KEY_ITER_PROTOCOLLO'
    }

    static CategoriaProtocollo getInstance(String codiceCategoria) {
        CategoriaProtocollo categoria = categorie[codiceCategoria]

        if (categoria == null) {
            throw new IllegalArgumentException("La categoria di protocollo con codice ${codiceCategoria} non esiste.")
        }

        return categoria
    }

    static List<CategoriaProtocollo> getCategorie() {
        // la categoria "MEMO PROTOCOLLO" non è "istanziabile" come documento di protocollo.
        return categorie.values().findAll { it.codice != CATEGORIA_MEMO_PROTOCOLLO.codice } as List
    }

    static List<String> getCodiciCategorie() {
        return getCategorie()*.codice as List<String>
    }

    static List<String> getCodiciModelloGDM() {
        return codiciModelloGDM
    }
}
