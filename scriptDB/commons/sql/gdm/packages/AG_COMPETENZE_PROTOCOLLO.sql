--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_COMPETENZE_PROTOCOLLO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_COMPETENZE_PROTOCOLLO
IS
   /******************************************************************************
    NOME:        Ag_Competenze_protocollo
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui protocolli.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
    Rev. Data        Autore   Descrizione.
    00   02/01/2007  SC       Prima emissione.
    01   16/05/2012  MM       Modifiche versione 2.1.
    03   20/08/2015  MM       Modificata funzione lettura.
                              Creata funzione lettura_testo e modifica_testo.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT VARCHAR2 (40) := 'V1.02';
   -- variabile globale per contenere il ritorno del lancio delle funzioni di protocollo
   -- che viene fatto via sqlexecute perche' esistono solo se c'è l'integrazione.
   g_diritto              NUMBER (1);

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   PROCEDURE set_true;

   PROCEDURE set_false;

   PROCEDURE resetta;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
   INPUT  p_area                    VARCHAR2
    ,     p_modello                 VARCHAR2
    ,     p_codice_richiesta        VARCHAR2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (p_area                VARCHAR2,
                     p_modello             VARCHAR2,
                     p_codice_richiesta    VARCHAR2,
                     p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
    - ha ruolo con privilegio MTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
   - è membro dell'unita esibente  e ha ruolo con privilegio ME
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
   Un utente ha i diritti in modifica su un protocollo RISERVATO se:
    - ha ruolo con privilegio MTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
   - è membro dell'unita esibente  e ha ruolo con privilegio MER
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION modifica (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro dell'unita esibente  e ha ruolo con privilegio VE
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS e CARICO
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - è membro dell'unita esibenre  e ha ruolo con privilegio VER
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR e  CARICO
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_verifica_esistenza_attivita NUMBER: 0 o 1: se 1 verifica se c'è in attesa
           un'attivita' JSUITE per lo smistamento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          01/09/2008  SC  A28345.12.0
   ********************************************************************************/
   FUNCTION lettura (p_id_documento      VARCHAR2,
                     p_utente            VARCHAR2,
                     p_apri_dettaglio    NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION lettura_testo (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
    - ha ruolo con privilegio MTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
   - è membro dell'unita esibente  e ha ruolo con privilegio ME
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
   Un utente ha i diritti in modifica su un protocollo RISERVATO se:
    - ha ruolo con privilegio MTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
   - è membro dell'unita esibente  e ha ruolo con privilegio MER
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          03/07/2007 SC A21081 Anche se l'utente generalmente avrebbe diritto a modificare il documento,
          se il documento appartiene ad un fascicolo in deposito, lo potra' modificare
          solo se ha privilegio MDDEP.
          07/09/2009 SC A30956.0.1 D878 Il documento deve essere in stato C o E per p_utente.
   ********************************************************************************/
   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION modifica_testo (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_PROTOCOLLO.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo.
    I criteri di verifica sono i seguenti:
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   - se l'utente è membro di un'unita' cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento.
   Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   Gli smistamenti che vengono coltrollati dipendono dal valore dei parametri
   verifica_smistamenti_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C o R.
   verifica_carico_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C.
   verifica_smistamenti_storici - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento F.
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      , verifica_smistamenti_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali, che siano in carico o da ricevere. 1 = fa il test, 0 non lo fa.
      verifica_carico_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali in carico. 1 = fa il test, 0 non lo fa.
      verifica_smistamenti_storici NUMBER indice se va fatto il test anche sui record di
      smistamenti storici. 1 = fa il test, 0 non lo fa.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_privilegio_protocollo (p_area                VARCHAR2,
                                            p_modello             VARCHAR2,
                                            p_codice_richiesta    VARCHAR2,
                                            p_privilegio          VARCHAR2,
                                            p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_PROTOCOLLO.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo.
    I criteri di verifica sono i seguenti:
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   - se l'utente è membro di un'unita' cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento.
   Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   Gli smistamenti che vengono coltrollati dipendono dal valore dei parametri
   verifica_smistamenti_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C o R.
   verifica_carico_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C.
   verifica_smistamenti_storici - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento F.
   INPUT  p_id_documento varchar2 id del documento
         p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      , verifica_smistamenti_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali, che siano in carico o da ricevere. 1 = fa il test, 0 non lo fa.
      verifica_carico_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali in carico. 1 = fa il test, 0 non lo fa.
      verifica_smistamenti_storici NUMBER indice se va fatto il test anche sui record di
      smistamenti storici. 1 = fa il test, 0 non lo fa.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_privilegio_protocollo (p_id_documento    VARCHAR2,
                                            p_privilegio      VARCHAR2,
                                            p_utente          VARCHAR2)
      RETURN NUMBER;

   -------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        creazione
    DESCRIZIONE: Un utente ha i diritti in creazione di protocolli se:
   - ha ruolo con privilegio CPROT.
   INPUT  p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2, p_unita VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        eseguito
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in eseguito per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION eseguito (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    00    20/05/2009  SC  A32603.0.0 Verifica l'esistenza dell'attivita jsuite.
   ********************************************************************************/
   FUNCTION in_carico (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_verifica_esistenza_attivita indica se va verificato che esista attività jsuite
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    20/05/2009  SC  A32603.0.0
   ********************************************************************************/
   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER)
      RETURN NUMBER;

   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER,
                       p_verifica_assegnazione          NUMBER)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER)
      RETURN NUMBER;

   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER,
                         p_verifica_assegnazione          NUMBER)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere privilegio VS/VSR o essere assegnatario
    del documento.
    Se tra tutti gli smistamenti in stato R relativi a p_utente, ce n'e' anche uno solo il cui relativo flusso
    non è arrivato ad attivare l'attivita' sul cruscotto, la funzione restituisce 0 per evitare
    disallineamenti tra lo stato dello smistamento e l'effettivo stato del flusso.
    la funzione restituisce 1 se l'utente appartiene all'unita ricevente e ha i diritti di vedere il documento,
    inoltre lo smistamento e il flusso collegato devono essere coerenti: cioe' deve essere attiva
    l'attivita' jsuite sul cruscotto come documento da ricevere per ogni smistamento.
    Se il documento è assegnato  la funzione restituisce 1 se l'utente è l'assegnatario.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
         16/01/2008  SC  Prima emissione. A25157.0.0
   ********************************************************************************/
   FUNCTION da_ricevere (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION da_ricevere (p_area                VARCHAR2,
                         p_modello             VARCHAR2,
                         p_codice_richiesta    VARCHAR2,
                         p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        eseguito
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato eseguito per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION eseguito (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION in_carico (p_area                VARCHAR2,
                       p_modello             VARCHAR2,
                       p_codice_richiesta    VARCHAR2,
                       p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        DEFAULT_TIPO_SMISTAMENTO
    DESCRIZIONE: Calcola il tipo di smistamento di default da assegnare a nuovi smistamenti
      creati tramite azione SMISTA, ESEGUISMISTA, INOLTRA.
      Se è possibile creare smistamenti di piu' tipi propone quello con valore minore
      del campo importanza di AG_TIPI_SMISTAMENTO. (Valore minore significa predominanza).
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_azione ('SMISTA', 'INOLTRA', 'ESEGUISMISTA'...)
   RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    24/01/2008  SC  Prima emissione. A25457.
   ********************************************************************************/
   FUNCTION default_tipo_smistamento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_azione          VARCHAR2)
      RETURN VARCHAR2;

   /*****************************************************************************
    NOME:        DEFAULT_TIPO_SMISTAMENTO
    DESCRIZIONE: Calcola il tipo di smistamento di default da assegnare a nuovi smistamenti
      creati tramite azione SMISTA, ESEGUISMISTA, INOLTRA.
      Se è possibile creare smistamenti di piu' tipi propone quello con valore minore
      del campo importanza di AG_TIPI_SMISTAMENTO. (Valore minore significa predominanza).
   INPUT  p_idrif varchar2: campo IDRIF identificativo del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_azione ('SMISTA', 'INOLTRA', 'ESEGUISMISTA'...)
   RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    24/01/2008  SC  Prima emissione. A25457.
   ********************************************************************************/
   FUNCTION default_tipo_smistamento (p_idrif                     VARCHAR2,
                                      p_codice_amministrazione    VARCHAR2,
                                      p_codice_aoo                VARCHAR2,
                                      p_area_modello_origine      VARCHAR2,
                                      p_cm_modello_origine        VARCHAR2,
                                      p_utente                    VARCHAR2,
                                      p_azione                    VARCHAR2)
      RETURN VARCHAR2;

   /*****************************************************************************
    NOME:        abilita_azione_smistamento
    DESCRIZIONE: Verifica se è possibile abilitare l'azione richiesta (SMISTA, INOLTRA)
    in base a:
    utente, per quale ragione vede il documento (protocollante, esibente, smistamento)
    se vede il documento a seguito di uno smistamento (l'abilitazione
    varia a seconda dello stato dello smistamento).
    Per SMISTA si restituisce 1 se
    l'utente è l'utente protocollante,
    l'utente è un protocollante o esibente con privilegio ISMI + CPROT;
    l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
    tabella AG_ABILITAZIONI_SMISTAMENTO
    Per INOLTRA e per ASSEGNA si restituisce 1 se:
    l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
    tabella AG_ABILITAZIONI_SMISTAMENTO.
    --A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
    Per CARICO, si verifica che l'utente abbia privilegio CARICO e non privilegio ISMI.
    In tutti gli altri casi si restituisce 0.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_azione ('SMISTA', 'INOLTRA')
   RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    20/06/2007  SC  Prima emissione.
          20/05/2009  SC  A32601.0.0 Per smistare documenti protocollati
                                       a nome dell'unita protocollante ci vuole ISMI + CPROT.
          20/05/2009  SC A32603.0.0 SC Per tutte le azioni, tranne CARICO, si verifica se
                                       l'utente ha privilegio ISMI, ma per abilitare
                                       la presa in carico si verifica il privilegio CARICO.
          01/06/2009  SC A33037.0.0 L'utente protocollante può sempre inserire smistamenti.
          17/08/2009  SC A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
   ********************************************************************************/
   FUNCTION abilita_azione_smistamento (
      p_id_documento         VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER;

   FUNCTION abilita_azione_smistamento (
      p_cr                   VARCHAR2,
      p_area                 VARCHAR2,
      p_cm                   VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        get_tipo_smistamento
    DESCRIZIONE: Dati in protocollo e un'unita di trasmissione, stabilisce quale
    tipo smistamento è possibile per quell'unita.
    Il tipo smistamento possibile dipende da
    lo stato in cui l'unita' di trasmissione ha il documento (da ricevere, in carico.)
    il tipo di smistamento con cui l'unita ha ricevuto il documento.
    L'azione che si sta compiendo (SMISTA, INOLTRA).
    In base ad essi si vede nella tabella AG_ABILITAZIONI_SMISTAMENTO quali tipi di smistamento sono generabili,
    se sono piu' di uno viene selezionato quello del tipo smistamento piu' importante
    (che è nella tabella ag_tipi_smistamento).


   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_unita_trasmissione VARCHAR2 codice dell'unita che sta creando un nuovo smistamento.
         p_azione ('SMISTA', 'INOLTRA')
   RITORNO:  TIPO_SMISTAMENTO possibile, null se non ce n'è nessuno.
    Rev.  Data       Autore  Descrizione.
    00    20/06/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_tipo_smistamento (p_id_documento          VARCHAR2,
                                  p_utente                VARCHAR2,
                                  p_unita_trasmissione    VARCHAR2,
                                  p_azione                VARCHAR2)
      RETURN VARCHAR2;

   /*****************************************************************************
    NOME:        eliminazione.
    DESCRIZIONE: Un utente ha i diritti in eliminazione se il documento non è protocollato
    e se ne ha le competenze esplicite in si4_competenze.
   Quindi se il documento è protocollato restituisce sempre 0,
   se non è protocollato restituisce null.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  se il documento è protocollato restituisce sempre 0,
   se non è protocollato restituisce null.
    Rev.  Data       Autore  Descrizione.
    00    29/08/2007 SC A21487.2.0 difetto 56
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   --FUNCTION lettura_light (p_id_documento VARCHAR2, p_utente VARCHAR2)
   --      RETURN NUMBER;

   /*****************************************************************************
    NOME:        check_abilita_ripudio
    DESCRIZIONE: Verifica se l'utente ha possibilita di ripudiare lo smistamento da ricevere

   INPUT p_area               varchar2, area del documento
         p_modello            varchar2, modello
         p_codice_richiesta   varchar2, codice richiesta
         p_utente             varchar2
   RITORNO:  1 se l'utente ha diritti di ripudio , 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    28/01/2009  AM  Prima emissione.
   ********************************************************************************/
   FUNCTION check_abilita_ripudio (p_area                VARCHAR2,
                                   p_modello             VARCHAR2,
                                   p_codice_richiesta    VARCHAR2,
                                   p_utente              VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
   NOME:        get_componenti_unita_azione
   DESCRIZIONE: ritorna la lista dei componenti di una data unita che
              hanno la possibilita' di compiere una azione in particolare

  INPUT  p_area               VARCHAR2,
        p_codice_modello     VARCHAR2,
        p_codice_richiesta   VARCHAR2, codice richiesta del protocollo
        p_codice_unita       VARCHAR2, codice unita della unita' da cui ottenere i componenti
        p_azione             VARCHAR2  azione da valutare per ogni utente dell'unita
  RITORNO:  lista dei componenti di una unita che hanno diritti su una azione in particolare
   Rev.  Data       Autore  Descrizione.
   00    20302/2009  AM  Prima emissione.
  ********************************************************************************/
   FUNCTION get_componenti_unita_azione (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2)
      RETURN VARCHAR;

   FUNCTION get_utenti_notifica_ripudio (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2,
                                         id_smistamenti        VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION is_riservato (p_id_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER,
                         p_verifica_assegnazione          NUMBER,
                         p_unita_ricevente                VARCHAR2)
      RETURN NUMBER;

   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER,
                       p_verifica_assegnazione          NUMBER,
                       p_unita_ricevente                VARCHAR2)
      RETURN NUMBER;

   FUNCTION eseguito (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2,
                      p_unita_ricevente     VARCHAR2)
      RETURN NUMBER;

   FUNCTION eseguito (p_id_documento             VARCHAR2,
                      p_utente                   VARCHAR2,
                      p_unita_ricevente          VARCHAR2 := NULL,
                      p_verifica_assegnazione    NUMBER := 1)
      RETURN NUMBER;

   FUNCTION f_valore_campo (p_id_documento        NUMBER,
                            p_campo_protocollo    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_smistamenti_da_ricevere (
      p_idrif     VARCHAR2,
      p_utente    VARCHAR2,
      p_unita     VARCHAR2 DEFAULT NULL,
      p_azione    VARCHAR2 DEFAULT 'ESEGUI')
      RETURN afc.t_ref_cursor;

   FUNCTION get_smistamenti_in_carico (p_idrif     VARCHAR2,
                                       p_utente    VARCHAR2,
                                       p_unita     VARCHAR2 DEFAULT NULL,
                                       p_azione    VARCHAR2 DEFAULT 'ESEGUI')
      RETURN afc.t_ref_cursor;

   FUNCTION is_da_ricevere_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_in_carico_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   FUNCTION vis_button_erase_fasc (p_area      VARCHAR2,
                                   p_cm        VARCHAR2,
                                   p_cr        VARCHAR2,
                                   p_utente    VARCHAR2,
                                   p_rw        VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_stato_scarto (p_id_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_data_stato_scarto (p_id_documento VARCHAR2)
      RETURN DATE;

   FUNCTION lettura_protocollo (
      p_id_documento            VARCHAR2,
      p_utente                  VARCHAR2,
      p_suffissoprivilegio      VARCHAR2,
      p_riservato_causa_fasc    VARCHAR2 DEFAULT 'N',
      p_check_smist_fasc        NUMBER DEFAULT 1)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY ag_competenze_protocollo
IS
   /******************************************************************************
    NOME:        ag_competenze_protocollo
    DESCRIZIONE: Package di funzioni specifiche del progetto AFFARI_GENERALI per verificare
              i diritti degli utenti sui protocolli.
    ANNOTAZIONI: .
    REVISIONI:   .
    <CODE>
   Rev. Data       Autore Descrizione.
   000  02/01/2007 SC     Prima emissione.
   001  16/05/2012 MM     Modifiche versione 2.1.
   002  14/01/2013 MM     Modifica funzioni test_attivita_in_attesa e lettura.
   003  20/08/2015 MM     Modifica funzione lettura: eliminato parametro
                           p_verifica_esistenza_attivita non più utilizzato ed
                           aggiunto p_check_privs_riservato per gestione doc
                           riservati.
                           Creata funzione lettura_testo e modifica_testo.
   004  01/12/2015 MM     Modificata abilita_azione_smistamento
   005  01/03/2016 MM     Modificata  funzione lettura per gestione parametro
                          VIS_PROT_IN_ELENCO_.
   006  08/09/2016 MM     Modificata  funzione eliminazione
        16/06/2017 SC     ALLINEATO ALLO STANDARD
   007  25/09/2017 MM     Modificate funzioni check_abilita_ripudio,
                          abilita_azione_smistamento, get_tipo_smistamento
        05/12/2017 SC     ACCESSO NEGATO A PROTOCOLLO IN CARICO,
                          ASSEGNATO AD UTENTE NON PIU' NELL'UNITà DI SMISTAMENTO.
   008  17/01/2018 MM     Modificata abilita_azione_smistamento in modo che ritorni
                          0 se l'utente non ha privilegio per l'unita' di smistamento
   009  03/04/2019 MM     Modificata is_riservato in modo che, come ultima possibilita'
                          controlli la riservatezza del fascicolo principale tramite
                          la sua chiave contenuta nel documento.
   010  31/07/2019 MM     Modificata verifica_privilegio_protocollo per gestione
                          privilegio quando UNITA_PROTOCOLLANTE è vuota (per es.
                          lettere create via ws).
   011  25/09/2019        Bug #36615 Gestione smistamento per conoscenza
                          Modificata default_tipo_smistamento
                          Se utente ha privilegio CARICO e VS su smistamento per conoscenza
                          e VDDR su quello per competenza, non puo' smistare per
                          competenza.
    012  27/09/2019 SC    Bug #37160 Modifiche per migliorare performance query.
    013  21/10/2019 MM    Modificata verifica_privilegio_utente per gestione firmatario
    014  12/12/2019 MM    Modificata lettura per eliminare competenza di lettura
                          al redattore della lettera.
    015  06/10/2020 MM    Modificata abilita_azione_smistamento per inibire indice
                          su unita.
   ******************************************************************************/
   TYPE ag_refcursor IS REF CURSOR;

   campo_idrif                  VARCHAR2 (5) := 'IDRIF';
   campo_riservato              VARCHAR2 (20) := 'RISERVATO';
   campo_unita_protocollante    VARCHAR2 (30) := 'UNITA_PROTOCOLLANTE';
   campo_utente_protocollante   VARCHAR2 (30) := 'UTENTE_PROTOCOLLANTE';
   campo_unita_esibente         VARCHAR2 (30) := 'UNITA_ESIBENTE';
   campo_stato_protocollo       VARCHAR2 (30) := 'STATO_PR';
   campo_tipo_documento         VARCHAR2 (30) := 'TIPO_DOCUMENTO';
   campo_modalita               VARCHAR2 (30) := 'MODALITA';

   s_revisione_body    CONSTANT afc.t_revision := '015';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilità del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, NVL (s_revisione_body, '000'));
   END;

   FUNCTION vis_button_erase_fasc (p_area      VARCHAR2,
                                   p_cm        VARCHAR2,
                                   p_cr        VARCHAR2,
                                   p_utente    VARCHAR2,
                                   p_rw        VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_documento       NUMBER;
      dep_conservazione      documenti.conservazione%TYPE;
      dep_stato_pr           spr_protocolli.stato_pr%TYPE;
      dep_class_cod          spr_protocolli.class_cod%TYPE;
      dep_class_dal          spr_protocolli.class_dal%TYPE;
      dep_fascicolo_anno     spr_protocolli.fascicolo_anno%TYPE;
      dep_fascicolo_numero   spr_protocolli.fascicolo_numero%TYPE;
      dep_stato_scarto       spr_protocolli.stato_scarto%TYPE;
   BEGIN
      DBMS_OUTPUT.put_line ('1');

      IF UPPER (p_rw) != 'W'
      THEN
         RETURN 0;
      END IF;

      DBMS_OUTPUT.put_line ('2');

      BEGIN
         SELECT id_documento, conservazione
           INTO dep_id_documento, dep_conservazione
           FROM documenti docu, tipi_documento tido
          WHERE     tido.area_modello = p_area
                AND tido.nome = p_cm
                AND tido.id_tipodoc = docu.id_tipodoc
                AND docu.codice_richiesta = p_cr;

         DBMS_OUTPUT.put_line (' Dep_id_documento ' || dep_id_documento);

         SELECT NVL (stato_pr, 'DP'),
                class_cod,
                class_dal,
                fascicolo_anno,
                fascicolo_numero,
                DECODE (stato_scarto, 'RR', '**', stato_scarto)
           INTO dep_stato_pr,
                dep_class_cod,
                dep_class_dal,
                dep_fascicolo_anno,
                dep_fascicolo_numero,
                dep_stato_scarto
           FROM proto_view
          WHERE id_documento = dep_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            dep_id_documento := NULL;
      END;

      DBMS_OUTPUT.put_line ('stato_scarto ' || dep_stato_scarto);

      IF dep_id_documento IS NULL
      THEN
         RETURN 1;
      ELSE
         IF dep_stato_pr = 'DP'
         THEN
            RETURN 1;
         END IF;

         IF    NVL (dep_conservazione, '**') IN ('CC', 'DC', 'IC')
            OR dep_fascicolo_numero IS NULL
         THEN
            DBMS_OUTPUT.put_line ('3');

            IF     verifica_privilegio_protocollo (p_area,
                                                   p_cm,
                                                   p_cr,
                                                   'MFD',
                                                   p_utente) = 1
               AND dep_stato_pr != 'AN'
            THEN
               RETURN 1;
            ELSE
               RETURN 0;
            END IF;
         ELSE
            DBMS_OUTPUT.put_line ('4');

            DECLARE
               dep_stato_scarto_fasc   seg_fascicoli.stato_scarto%TYPE;
            BEGIN
               BEGIN
                  SELECT DECODE (stato_scarto, 'RR', '**', stato_scarto)
                    INTO dep_stato_scarto_fasc
                    FROM seg_fascicoli, documenti
                   WHERE     seg_fascicoli.class_cod = dep_class_cod
                         AND class_dal = dep_class_dal
                         AND fascicolo_anno = dep_fascicolo_anno
                         AND fascicolo_numero = dep_fascicolo_numero
                         AND seg_fascicoli.id_documento =
                                documenti.id_documento
                         AND documenti.stato_documento NOT IN ('CA',
                                                               'RE',
                                                               'PB');
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     dep_stato_scarto_fasc := '**';
               END;

               IF (dep_stato_scarto_fasc != '**' AND dep_stato_scarto = '**')
               THEN
                  DBMS_OUTPUT.put_line ('5');
                  RETURN AG_UTILITIES.verifica_privilegio_utente (
                            NULL,
                            'MFARC',
                            p_utente,
                            TRUNC (SYSDATE));
               ELSE
                  DBMS_OUTPUT.put_line ('6');

                  IF     verifica_privilegio_protocollo (p_area,
                                                         p_cm,
                                                         p_cr,
                                                         'MFD',
                                                         p_utente) = 1
                     AND dep_stato_pr != 'AN'
                  THEN
                     RETURN 1;
                  ELSE
                     RETURN 0;
                  END IF;
               END IF;
            END;
         END IF;
      END IF;
   END vis_button_erase_fasc;

   FUNCTION is_riservato (p_id_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (1) := 'N';
   BEGIN
      BEGIN
         SELECT NVL (riservato, 'N')
           INTO retval
           FROM proto_view
          WHERE id_documento = p_id_documento AND NVL (riservato, 'N') = 'Y';

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT NVL (f.riservato, 'N')
                 INTO retval
                 FROM links l,
                      seg_fascicoli f,
                      cartelle c,
                      documenti d
                WHERE     l.id_oggetto = p_id_documento
                      AND l.tipo_oggetto = 'D'
                      AND l.id_cartella = c.id_cartella
                      AND c.id_documento_profilo = f.id_documento
                      AND f.id_documento = d.id_documento
                      AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND NVL (c.stato, 'BO') != 'CA'
                      AND NVL (f.riservato, 'N') = 'Y'
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  -- se si procede alla protocollazione senza prima salvare il documento,
                  -- la creazione delle notifiche in scrivania avviene quando ancora
                  -- il documento non e' nella links, percio' controlla la riservatezza
                  -- del solo fascicolo principale tramite la sua chiave contenuta nel
                  -- documento.
                  BEGIN
                     SELECT NVL (f.riservato, 'N')
                       INTO retval
                       FROM proto_view p,
                            seg_fascicoli f,
                            cartelle c,
                            documenti d
                      WHERE     p.id_documento = p_id_documento
                            AND f.class_cod = p.class_cod
                            AND f.class_dal = p.class_dal
                            AND f.fascicolo_anno = p.fascicolo_anno
                            AND f.fascicolo_numero = p.fascicolo_numero
                            AND c.id_documento_profilo = f.id_documento
                            AND f.id_documento = d.id_documento
                            AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                            AND NVL (c.stato, 'BO') != 'CA'
                            AND NVL (f.riservato, 'N') = 'Y'
                            AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        retval := 'N';
                  END;
            END;
      END;

      RETURN retval;
   END is_riservato;

   FUNCTION get_stato_scarto (p_id_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      retval                 ag_stati_scarto.stato%TYPE;
      dep_scarto_doc         ag_stati_scarto.stato%TYPE;
      dep_conservazione      documenti.conservazione%TYPE;
      dep_class_cod          seg_fascicoli.class_cod%TYPE;
      dep_class_dal          seg_fascicoli.class_dal%TYPE;
      dep_fascicolo_anno     seg_fascicoli.fascicolo_anno%TYPE;
      dep_fascicolo_numero   seg_fascicoli.fascicolo_numero%TYPE;
   BEGIN
      BEGIN
         SELECT stato_scarto,
                conservazione,
                class_cod,
                class_dal,
                fascicolo_anno,
                fascicolo_numero
           INTO dep_scarto_doc,
                dep_conservazione,
                dep_class_cod,
                dep_class_dal,
                dep_fascicolo_anno,
                dep_fascicolo_numero
           FROM proto_view, documenti
          WHERE     documenti.id_documento = proto_view.id_documento
                AND proto_view.id_documento = p_id_documento;

         IF dep_conservazione IN ('CC', 'DC', 'IC')
         THEN
            retval := dep_scarto_doc;
         ELSE
            IF dep_scarto_doc != '**' OR dep_fascicolo_anno IS NULL
            THEN
               retval := dep_scarto_doc;
            ELSE
               BEGIN
                  SELECT stato_scarto
                    INTO retval
                    FROM seg_fascicoli
                   WHERE     class_cod = dep_class_cod
                         AND class_dal = dep_class_dal
                         AND fascicolo_anno = dep_fascicolo_anno
                         AND fascicolo_numero = dep_fascicolo_numero;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := dep_scarto_doc;
               END;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END get_stato_scarto;

   FUNCTION get_data_stato_scarto (p_id_documento VARCHAR2)
      RETURN DATE
   IS
      retval                 seg_fascicoli.data_stato_scarto%TYPE;
      dep_scarto_doc         seg_fascicoli.stato_scarto%TYPE;
      dep_data_scarto_doc    seg_fascicoli.data_stato_scarto%TYPE;
      dep_conservazione      documenti.conservazione%TYPE;
      dep_class_cod          seg_fascicoli.class_cod%TYPE;
      dep_class_dal          seg_fascicoli.class_dal%TYPE;
      dep_fascicolo_anno     seg_fascicoli.fascicolo_anno%TYPE;
      dep_fascicolo_numero   seg_fascicoli.fascicolo_numero%TYPE;
   BEGIN
      BEGIN
         SELECT stato_scarto,
                data_stato_scarto,
                conservazione,
                class_cod,
                class_dal,
                fascicolo_anno,
                fascicolo_numero
           INTO dep_scarto_doc,
                dep_data_scarto_doc,
                dep_conservazione,
                dep_class_cod,
                dep_class_dal,
                dep_fascicolo_anno,
                dep_fascicolo_numero
           FROM proto_view, documenti
          WHERE     documenti.id_documento = proto_view.id_documento
                AND proto_view.id_documento = p_id_documento;

         IF dep_conservazione IN ('CC', 'DC', 'IC')
         THEN
            retval := dep_data_scarto_doc;
         ELSE
            IF dep_scarto_doc != '**' OR dep_fascicolo_anno IS NULL
            THEN
               retval := dep_data_scarto_doc;
            ELSE
               BEGIN
                  SELECT data_stato_scarto
                    INTO retval
                    FROM seg_fascicoli
                   WHERE     class_cod = dep_class_cod
                         AND class_dal = dep_class_dal
                         AND fascicolo_anno = dep_fascicolo_anno
                         AND fascicolo_numero = dep_fascicolo_numero;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := dep_data_scarto_doc;
               END;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END get_data_stato_scarto;

   FUNCTION is_categoriamodello (p_id_documento NUMBER, p_categoria VARCHAR2)
      RETURN NUMBER
   IS
      d_categoria   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO d_categoria
           FROM categorie_modello camo, tipi_documento tido, documenti docu
          WHERE     docu.id_documento = p_id_documento
                AND tido.id_tipodoc = docu.id_tipodoc
                AND camo.codice_modello = tido.nome
                AND camo.categoria = p_categoria;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_categoria := 0;
      END;

      RETURN d_categoria;
   END;

   FUNCTION get_tabella (p_id_documento NUMBER, p_campo VARCHAR2)
      RETURN VARCHAR2
   IS
      d_tabella   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT UPPER (
                   NVL (a.acronimo, '-') || '_' || NVL (t.alias_modello, '-'))
           INTO d_tabella
           FROM documenti d, tipi_documento t, aree a
          WHERE     d.id_documento = p_id_documento
                AND d.id_tipodoc = t.id_tipodoc
                AND a.area = t.area_modello;

         DECLARE
            d_esiste   NUMBER;
         BEGIN
            SELECT 1
              INTO d_esiste
              FROM user_tab_columns
             WHERE table_name = d_tabella AND column_name = p_campo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_tabella := 'PROTO_VIEW';
         END;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_tabella := 'PROTO_VIEW';
      END;

      RETURN d_tabella;
   END;

   FUNCTION f_valore_campo (p_id_documento        NUMBER,
                            p_campo_protocollo    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return    VARCHAR2 (32767);
      d_tabella   VARCHAR2 (100);
   BEGIN
      d_tabella := get_tabella (p_id_documento, p_campo_protocollo);

      EXECUTE IMMEDIATE
            'select '
         || p_campo_protocollo
         || ' from '
         || d_tabella
         || ' where id_documento = :id_documento'
         INTO d_return
         USING p_id_documento;

      RETURN d_return;
   END;

   /******************************************************************************
    NOME:        test_attivita_in_attesa
    DESCRIZIONE: Verifica se esiste un'attivita in attesa di esecuzione
                   con execType p_execType, collegata
                 al documento identificato da p_triade (area@codiceModello@codiceRichiesta).
    INPUT  p_triade area@codiceModello@codiceRichiesta del documento che dovrebbe
               avere un flusso collegato
       p_exectype tipo di esecuzione che deve essere collegato all'eventuale attivita'
       in attesa di esecuzione
    RITORNA:     1 se esiste un'attivita' in attesa di esecuzione
               0 se non esiste e in caso di errore.
    Rev.  Data       Autore  Descrizione.
    000   16/01/2008  SC  Prima emissione. A25157.0.0
          02/11/2008  SC  A34963.0.0 Modifica degli indici in JWF ci obbliga a fare una
                           modifica sulla query su syncactivity.
    002   14/01/2013 MM     Modificata select aggiungendo area in modo che usi indice.
   ******************************************************************************/
   FUNCTION test_attivita_in_attesa (p_triade VARCHAR2, p_exectype VARCHAR2)
      RETURN NUMBER
   IS
      retval      VARCHAR2 (1999) := 0;
      checksmis   seg_smistamenti.key_iter_smistamento%TYPE;
      cr          documenti.codice_richiesta%TYPE;
   BEGIN
      BEGIN
         --      02/11/2008  SC  A34963.0.0 Modifica degli indici in JWF ci obbliga a fare una
         --                        modifica sulla query su syncactivity
         --                       a.id_attivita = s.id_attivita diventa
         --                      a.id_attivita + 0 = s.id_attivita;
         IF INSTR (p_triade, 'SEGRETERIA@M_SMISTAMENTO@') > 0
         THEN
            cr := SUBSTR (p_triade, LENGTH ('SEGRETERIA@M_SMISTAMENTO@') + 1);

            SELECT NVL (key_iter_smistamento, 0)
              INTO checksmis
              FROM seg_smistamenti, documenti
             WHERE     documenti.area = 'SEGRETERIA'
                   AND documenti.codice_richiesta = cr
                   AND documenti.id_documento = seg_smistamenti.id_documento;

            IF checksmis = -1
            THEN
               RETURN 1;
            END IF;
         END IF;

         SELECT 1
           INTO retval
           FROM syncactivity a, sync_cruscotto s
          WHERE     a.exectype = p_exectype
                AND a.oggetto = p_triade
                AND a.esecuzione = 0
                AND a.id_attivita + 0 = s.id_attivita;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN                                     --se non ci sono smistamenti
            --con il nodo del cruscotto in attesa
            -- restituisco 0.
            retval := 0;
         WHEN OTHERS
         THEN
            -- in caso di errore non posso che dare 0, ma lo voglio distinguere dal caso del no_data_found.
            retval := 0;
      END;

      RETURN retval;
   END test_attivita_in_attesa;

   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON protocollato se il documento
    è in arrivo e collegato ad una mail e se ha un privilegio che gli consente di gestire
    il tag_mail presente sulla mail stessa, altrimenti il controllo è demandato al
    documentale.

   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, null altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    26/06/2007  SC  Prima emissione.
    13/05/2010        SC   A24015.0.0 I diritti in lettura sono subordinati ai diritti sul
                           tag_mail associato al messaggio collegato al protocollo.
   ********************************************************************************/
   FUNCTION lettura_non_protocollati (p_id_documento    VARCHAR2,
                                      p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval    NUMBER;
   BEGIN
      BEGIN
         SELECT DISTINCT 1
           INTO retval
           FROM documenti docu,
                proto_view,
                riferimenti,
                parametri,
                seg_memo_protocollo mepr,
                documenti docu_memo
          WHERE     docu.id_documento = p_id_documento
                AND proto_view.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE')
                AND proto_view.modalita = 'ARR'
                AND riferimenti.tipo_relazione = parametri.valore
                AND docu.id_documento = riferimenti.id_documento
                AND parametri.codice =
                       'COD_RIF_MESSAGGIO_' || AG_UTILITIES.indiceaoo
                AND parametri.tipo_modello = '@agVar@'
                AND mepr.id_documento = riferimenti.id_documento_rif
                AND mepr.id_documento = docu_memo.id_documento
                AND docu_memo.stato_documento NOT IN ('CA', 'RE')
                AND AG_UTILITIES.verifica_privilegio_casella (
                          mepr.destinatari
                       || ','
                       || mepr.destinatari_conoscenza
                       || ','
                       || mepr.destinatari_nascosti,
                       p_utente,
                       TRUNC (SYSDATE)) = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      IF retval IS NULL
      THEN
         DECLARE
            d_utente   VARCHAR2 (8);
            d_isprot   NUMBER := 0;
         BEGIN
            SELECT utente_aggiornamento, prot.is_prot
              INTO d_utente, d_isprot
              FROM documenti d,
                   (SELECT SUM (conta) is_prot
                      FROM (SELECT COUNT (1) conta
                              FROM spr_protocolli
                             WHERE id_documento = p_id_documento
                            UNION
                            SELECT COUNT (1)
                              FROM spr_protocolli_emergenza
                             WHERE id_documento = p_id_documento
                            UNION
                            SELECT COUNT (1)
                              FROM spr_protocolli_docesterni
                             WHERE id_documento = p_id_documento)) prot
             WHERE id_documento = p_id_documento;

            IF d_isprot = 1
            THEN
               IF d_utente = p_utente
               THEN
                  retval := 1;
               ELSE
                  retval := 0;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := NULL;
         END;
      END IF;

      RETURN retval;
   END lettura_non_protocollati;

   -------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   Inoltre si acquistano i diritti su un protocollo se si ha il privilegio di leggere i protocolli di una certa unita
   e uno dei privilegi che stendono i diritti ad altre unita EPSUP, EPSUB, EPEQU.
   Se si ha EPSUP e si hanno diritti in lettura sui protocolli della propria unita allora si possono vedere
   anche quelli dell'unita' padre.
   Se si ha EPSUB e si hanno diritti in lettura sui protocolli della propria unita allora si possono vedere
   anche quelli delle unita' discendenti.
   Se si ha EPEQU e si hanno diritti in lettura sui protocolli della propria unita allora si possono vedere
   anche quelli delle unita del medesimo livello.
   INPUT  p_area                    VARCHAR2
    ,     p_modello                 VARCHAR2
    ,     p_codice_richiesta        VARCHAR2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION lettura (p_area                VARCHAR2,
                     p_modello             VARCHAR2,
                     p_codice_richiesta    VARCHAR2,
                     p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;
      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            AG_UTILITIES.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval := lettura (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END lettura;

   -------------------------------------------------------------------------------
   /*****************************************************************************
    NOME:        creazione
    DESCRIZIONE: Un utente ha i diritti in creazione di protocolli se:
   - ha ruolo con privilegio CPROT.
   INPUT  p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION creazione (p_utente VARCHAR2, p_unita VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      retval   NUMBER := NULL;
   BEGIN
      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF AG_UTILITIES.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = AG_UTILITIES.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;

      BEGIN
         retval :=
            AG_UTILITIES.verifica_privilegio_utente (
               p_unita        => p_unita,
               p_privilegio   => 'CPROT',
               p_utente       => p_utente,
               p_data         => TRUNC (SYSDATE));
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END creazione;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
    - ha ruolo con privilegio MTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
   - è membro dell'unita esibente  e ha ruolo con privilegio ME
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
   Un utente ha i diritti in modifica su un protocollo RISERVATO se:
    - ha ruolo con privilegio MTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
   - è membro dell'unita esibente  e ha ruolo con privilegio MER
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION modifica (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;
      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            AG_UTILITIES.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval := modifica (iddocumento, p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END modifica;

   /*****************************************************************************
    NOME:        VERIFICA_PER_PROTOCOLLANTE.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo come membro dell'unita' protocollante.
    I criteri di verifica sono i seguenti:
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   INPUT  p_id_documento varchar2 id del documento
         p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      , UnitaUtente         AG_UTILITIES.UnitaUtenteTab Table di unita e ruoli di p_utente
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    05/04/2017  SC  Gestione date per privilegi
   ********************************************************************************/
   FUNCTION verifica_per_protocollante (p_id_documento    VARCHAR2,
                                        p_privilegio      VARCHAR2,
                                        p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      unitaprotocollante   seg_unita.unita%TYPE;
      d_data_rif           DATE;
   BEGIN
      unitaprotocollante :=
         f_valore_campo (p_id_documento, 'UNITA_PROTOCOLLANTE');
      d_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

      --verifico se l'utente fa parte dell'unita protocollante con privilegio p_privilegio.
      BEGIN
         SELECT 1
           INTO retval
           FROM ag_priv_utente_tmp
          WHERE     utente = p_utente
                AND privilegio = p_privilegio
                AND unita = unitaprotocollante
                AND d_data_rif <= NVL (al, TO_DATE (3333333, 'j'))
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      RETURN retval;
   END verifica_per_protocollante;

   /*****************************************************************************
    NOME:        VERIFICA_PER_ESIBENTE.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo come membro dell'unita' esibente.
    I criteri di verifica sono i seguenti:
   - se l'utente è membro dell'unità esibente, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   INPUT  p_id_documento varchar2 id del documento
         p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      , UnitaUtente         AG_UTILITIES.UnitaUtenteTab Table di unita e ruoli di p_utente
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_per_esibente (p_id_documento    VARCHAR2,
                                   p_privilegio      VARCHAR2,
                                   p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval          NUMBER := 0;
      unitaesibente   seg_unita.unita%TYPE;
      d_data_rif      DATE;
   BEGIN
      unitaesibente := f_valore_campo (p_id_documento, 'UNITA_ESIBENTE');
      d_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

      BEGIN
         SELECT 1
           INTO retval
           FROM ag_priv_utente_tmp
          WHERE     utente = p_utente
                AND privilegio = p_privilegio
                AND unita = unitaesibente
                AND d_data_rif <= NVL (al, TO_DATE (3333333, 'j'))
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      RETURN retval;
   END verifica_per_esibente;

   /*****************************************************************************
    NOME:        MODIFICA.
    DESCRIZIONE: Un utente ha i diritti in modifica su un protocollo NON riservato se:
    - ha ruolo con privilegio MTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROT
   - è membro dell'unita esibente  e ha ruolo con privilegio ME
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MS
   Un utente ha i diritti in modifica su un protocollo RISERVATO se:
    - ha ruolo con privilegio MTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio MPROTR
   - è membro dell'unita esibente  e ha ruolo con privilegio MER
   - è membro di un'unità cui è stato smistato il documento e ha ruolo con privilegio MSR

   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di modificare il documento.
   RITORNO:  1 se l'utente ha diritti in modifica, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          03/07/2007 SC A21081 Anche se l'utente generalmente avrebbe diritto a modificare il documento,
          se il documento appartiene ad un fascicolo in deposito, lo potra' modificare
          solo se ha privilegio MDDEP.
          07/09/2009 SC A30956.0.1 D878 Il documento deve essere in stato C o E per p_utente.
   ********************************************************************************/
   FUNCTION modifica (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := NULL;
      riservato              VARCHAR2 (1) := 'N';
      riservato_causa_fasc   VARCHAR2 (1) := 'N';
      continua               NUMBER := 0;
      suffissoprivilegio     VARCHAR2 (1);
      idrifprotocollo        VARCHAR2 (100);
      classcod               VARCHAR2 (100);
      classdal               DATE;
      dep_data_rif           DATE;
      annofasc               NUMBER;
      numerofasc             VARCHAR2 (100);
   BEGIN
      -- DBMS_OUTPUT.put_line ('inizio ' || retval);

      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF AG_UTILITIES.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = AG_UTILITIES.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;

      -- DBMS_OUTPUT.put_line ('dopo inizializza utente ' || retval);

      -- VERIFICA CHE IL DOCUMENTO SIA UN PROTOCOLLO (categoria PROTO)
      BEGIN
         continua :=
            AG_UTILITIES.verifica_categoria_documento (
               p_id_documento   => p_id_documento,
               p_categoria      => AG_UTILITIES.categoriaprotocollo);
      EXCEPTION
         WHEN OTHERS
         THEN
            continua := 0;
      END;

      --DBMS_OUTPUT.put_line ('dopo verifica categoria ' || retval);
      IF continua = 1
      THEN
         -- SE il documento non è protocollato
         --normalmente la verifica è demandata al documentale, quindi si restituisce null.
         -- Fanno eccezione i documenti da protocollare provenienti da interoperabilita
         --che vengono resi accessibili a chi ha privilegio PROTMAIL.
         IF NVL (f_valore_campo (p_id_documento, campo_stato_protocollo),
                 'DP') = 'DP'
         THEN
            retval := lettura_non_protocollati (p_id_documento, p_utente);

            IF retval IS NULL
            THEN
               DECLARE
                  d_idrif   VARCHAR2 (100);
               BEGIN
                  SELECT idrif
                    INTO d_idrif
                    FROM proto_view
                   WHERE id_documento = p_id_documento;
               END;
            END IF;
         ELSE
            IF continua = 1
            THEN
               riservato := is_riservato (p_id_documento);

               --f_valore_campo (p_id_documento, campo_riservato);

               --  DBMS_OUTPUT.put_line ('stato pr <> dp');
               IF riservato = 'Y'
               THEN
                  suffissoprivilegio := 'R';

                  IF NVL (f_valore_campo (p_id_documento, campo_riservato),
                          'N') = 'N'
                  THEN
                     riservato_causa_fasc := 'Y';
                  END IF;
               END IF;

               -- se ha privilegio MTOT vede tutti i protocolli NON riservati.
               -- se ha privilegio MTOTR vede tutti i protocolli riservati.
               retval :=
                  AG_UTILITIES.verifica_privilegio_utente (
                     p_unita        => NULL,
                     p_privilegio   => 'MTOT' || suffissoprivilegio,
                     p_utente       => p_utente,
                     p_data         => TRUNC (SYSDATE));


               --  DBMS_OUTPUT.put_line ('dopo verifica privilegio MTOT ' || retval);
               IF retval = 0
               THEN
                  dep_data_rif :=
                     AG_UTILITIES.get_Data_rif_privilegi (p_id_documento);
                  --VERIFICA SE P_UTENTE FA PARTE DELL'UITA PROTOCOLLANTE CON PRIVILEGIO MPROTR
                  -- per i documenti riservati, MPROT per i NON riservati.
                  retval :=
                     verifica_per_protocollante (
                        p_id_documento   => p_id_documento,
                        p_privilegio     => 'MPROT' || suffissoprivilegio,
                        p_utente         => p_utente);


                  IF     AG_UTILITIES.IS_LETTERA (TO_NUMBER (p_id_documento)) =
                            1
                     AND f_valore_campo (p_id_documento, 'SO4_DIRIGENTE') =
                            p_utente
                     AND f_valore_campo (p_id_documento, 'POSIZIONE_FLUSSO') =
                            'DIRIGENTE'
                  THEN
                     retval := 1;
                  END IF;

                  --   DBMS_OUTPUT.put_line (   'dopo verifica privilegio MPROT '
                  --                         || retval
                  --                        );
                  IF retval = 0
                  THEN
                     --VERIFICA SE P_UTENTE FA PARTE DELL'UITA ESIBENTE CON PRIVILEGIO MER
                     -- per i documenti riservati, ME per i NON riservati.
                     retval :=
                        verifica_per_esibente (
                           p_id_documento   => p_id_documento,
                           p_privilegio     => 'ME' || suffissoprivilegio,
                           p_utente         => p_utente);
                  END IF;
               -- DBMS_OUTPUT.put_line ('dopo verifica privilegio ME ' || retval);
               END IF;

               -- se il documento e' riservato ma e' stato smistato personalmente a p_utente
               -- o al suo ruolo, p_utente lo puo' cmq modificare.
               -- A30956.0.1 D878 Il documento deve essere in stato C o E per p_utente.
               IF retval = 0
               THEN
                  IF ag_parametro.get_valore (
                        'ITER_FASCICOLI_' || AG_UTILITIES.indiceaoo,
                        '@agVar@',
                        'N') = 'Y'
                  THEN
                     BEGIN
                        SELECT 1
                          INTO retval
                          FROM seg_smistamenti,
                               documenti docu_smis,
                               ag_priv_utente_tmp,
                               ag_privilegi_smistamento,
                               links,
                               seg_fascicoli fasc,
                               documenti docu_fasc,
                               cartelle cart
                         WHERE     seg_smistamenti.id_documento =
                                      docu_smis.id_documento
                               AND docu_smis.stato_documento NOT IN ('CA',
                                                                     'RE')
                               AND seg_smistamenti.idrif = fasc.idrif
                               AND seg_smistamenti.ufficio_smistamento =
                                      ag_priv_utente_tmp.unita
                               AND seg_smistamenti.stato_smistamento IN (AG_UTILITIES.smistamento_in_carico,
                                                                         AG_UTILITIES.smistamento_eseguito)
                               AND seg_smistamenti.tipo_smistamento =
                                      ag_privilegi_smistamento.tipo_smistamento
                               AND ag_utilities.get_Data_rif_privilegi (
                                      fasc.id_documento) <=
                                      NVL (ag_priv_utente_tmp.al,
                                           TO_DATE (3333333, 'j'))
                               AND ag_priv_utente_tmp.utente = p_utente
                               AND ag_priv_utente_tmp.privilegio =
                                      'MS' || suffissoprivilegio
                               AND ag_privilegi_smistamento.privilegio =
                                      ag_priv_utente_tmp.privilegio
                               AND ag_privilegi_smistamento.aoo =
                                      AG_UTILITIES.indiceaoo
                               AND links.id_oggetto = p_id_documento
                               AND links.tipo_oggetto = 'D'
                               AND links.id_cartella = cart.id_cartella
                               AND NVL (cart.stato, 'BO') != 'CA'
                               AND cart.id_documento_profilo =
                                      fasc.id_documento
                               AND fasc.id_documento = docu_fasc.id_documento
                               AND docu_fasc.stato_documento NOT IN ('CA',
                                                                     'RE')
                               AND DECODE (
                                      riservato_causa_fasc,
                                      'N', 1,
                                      DECODE (NVL (fasc.riservato, 'N'),
                                              'Y', 1,
                                              0)) = 1
                               AND ROWNUM = 1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           retval := 0;
                     END;

                     IF riservato = 'Y' AND retval = 0
                     THEN
                        BEGIN
                           SELECT 1
                             INTO retval
                             FROM seg_smistamenti,
                                  documenti docu_smis,
                                  links,
                                  seg_fascicoli fasc,
                                  documenti docu_fasc,
                                  cartelle cart
                            WHERE     docu_smis.stato_documento NOT IN ('CA',
                                                                        'RE')
                                  AND docu_smis.id_documento =
                                         seg_smistamenti.id_documento
                                  AND seg_smistamenti.idrif = fasc.idrif
                                  AND seg_smistamenti.stato_smistamento IN (AG_UTILITIES.smistamento_in_carico,
                                                                            AG_UTILITIES.smistamento_eseguito)
                                  AND seg_smistamenti.codice_assegnatario =
                                         p_utente
                                  AND links.id_oggetto = p_id_documento
                                  AND links.tipo_oggetto = 'D'
                                  AND links.id_cartella = cart.id_cartella
                                  AND NVL (cart.stato, 'BO') != 'CA'
                                  AND cart.id_documento_profilo =
                                         fasc.id_documento
                                  AND fasc.id_documento =
                                         docu_fasc.id_documento
                                  AND docu_fasc.stato_documento NOT IN ('CA',
                                                                        'RE')
                                  AND DECODE (
                                         riservato_causa_fasc,
                                         'N', 1,
                                         DECODE (NVL (fasc.riservato, 'N'),
                                                 'Y', 1,
                                                 0)) = 1
                                  AND ROWNUM = 1;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              retval := 0;
                        END;
                     END IF;
                  END IF;

                  IF retval = 0
                  THEN
                     idrifprotocollo :=
                        f_valore_campo (p_id_documento, campo_idrif);

                     --VERIFICA SE P_UTENTE FA PARTE DI UN'UNITA di carico CON PRIVILEGIO MSR MPROTR
                     -- per i documenti riservati, MS per i NON riservati..
                     BEGIN
                        SELECT 1
                          INTO retval
                          FROM seg_smistamenti,
                               documenti docu,
                               ag_priv_utente_tmp,
                               ag_privilegi_smistamento
                         WHERE     seg_smistamenti.id_documento =
                                      docu.id_documento
                               AND docu.stato_documento NOT IN ('CA', 'RE')
                               AND seg_smistamenti.idrif = idrifprotocollo
                               AND seg_smistamenti.ufficio_smistamento =
                                      ag_priv_utente_tmp.unita
                               AND seg_smistamenti.stato_smistamento IN (AG_UTILITIES.smistamento_in_carico,
                                                                         AG_UTILITIES.smistamento_eseguito)
                               AND dep_data_rif <=
                                      NVL (ag_priv_utente_tmp.al,
                                           TO_DATE (3333333, 'j'))
                               AND seg_smistamenti.tipo_smistamento =
                                      ag_privilegi_smistamento.tipo_smistamento
                               AND ag_priv_utente_tmp.utente = p_utente
                               AND ag_priv_utente_tmp.privilegio =
                                      'MS' || suffissoprivilegio
                               AND ag_privilegi_smistamento.privilegio =
                                      ag_priv_utente_tmp.privilegio
                               AND ag_privilegi_smistamento.aoo =
                                      AG_UTILITIES.indiceaoo
                               AND ROWNUM = 1;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           retval := 0;
                     END;

                     IF riservato = 'Y' AND retval = 0
                     THEN
                        BEGIN
                           SELECT 1
                             INTO retval
                             FROM seg_smistamenti,
                                  documenti docu,
                                  ag_priv_utente_tmp
                            WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                                  AND docu.id_documento =
                                         seg_smistamenti.id_documento
                                  AND seg_smistamenti.idrif = idrifprotocollo
                                  AND seg_smistamenti.ufficio_smistamento =
                                         ag_priv_utente_tmp.unita
                                  AND seg_smistamenti.stato_smistamento IN (AG_UTILITIES.smistamento_in_carico,
                                                                            AG_UTILITIES.smistamento_eseguito)
                                  AND seg_smistamenti.codice_assegnatario =
                                         ag_priv_utente_tmp.utente
                                  AND ag_priv_utente_tmp.utente = p_utente
                                  AND ROWNUM = 1;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              retval := 0;
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      --     DBMS_OUTPUT.put_line ('prima di verificare il fascicolo ' || retval);

      -- A21081 Anche se l'utente generalmente avrebbe diritto a modificare il documento,
      -- se il documento appartiene ad un fascicolo in deposito, lo potra' modificare
      -- solo se ha privilegio MDDEP.
      IF retval = 1
      THEN
         BEGIN
            SELECT proto_view.class_cod,
                   proto_view.class_dal,
                   proto_view.fascicolo_anno,
                   proto_view.fascicolo_numero
              INTO classcod,
                   classdal,
                   annofasc,
                   numerofasc
              FROM documenti docu, proto_view
             WHERE     docu.id_documento = p_id_documento
                   AND proto_view.id_documento = docu.id_documento
                   AND docu.stato_documento NOT IN ('CA', 'RE');

            IF annofasc IS NOT NULL AND numerofasc IS NOT NULL
            THEN
               IF AG_UTILITIES.get_stato_fascicolo (
                     p_class_cod    => classcod,
                     p_class_dal    => classdal,
                     p_anno         => annofasc,
                     p_numero       => numerofasc,
                     p_indice_aoo   => AG_UTILITIES.indiceaoo) !=
                     AG_UTILITIES.stato_corrente
               THEN
                  --                  DBMS_OUTPUT.put_line
                  --                                    ('fascicolo in stato diverso da corrente');
                  retval :=
                     AG_UTILITIES.verifica_privilegio_utente (
                        NULL,
                        'MDDEP',
                        p_utente,
                        TRUNC (SYSDATE));
               --                  DBMS_OUTPUT.put_line (   'dopo verifica privilegio MDDEP '
               --                                        || retval
               --                                       );
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- DBMS_OUTPUT.put_line ('dopo ndf ' || retval);
               NULL;
            WHEN OTHERS
            THEN
               retval := 0;
         --  DBMS_OUTPUT.put_line ('dopo others ' || retval);
         END;
      END IF;

      --DBMS_OUTPUT.put_line ('alla fine ' || retval);
      RETURN retval;
   END modifica;

   /*******************************************************************************
      NOME:          MODIFICA_TESTO.
      DESCRIZIONE:   Verifica la possibilita' dell'utente di modificare il testo
                     dell'allegato.
      INPUT:         p_idDocumento  varchar2: chiave identificativa del documento.
                     p_utente       varchar2: utente che richiede di leggere il
                                              documento.
      RITORNO:       Un testo è modificabile se è leggibile.

    Rev. Data       Autore   Descrizione.
    003  20/08/2015 MM       Prima emissione.
   *******************************************************************************/
   FUNCTION modifica_testo (p_idDocumento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_ret     NUMBER;
      d_idrif   VARCHAR2 (100);
   BEGIN
      IF p_utente IN ('GDM', 'RPI')
      THEN
         RETURN 1;
      END IF;

      IF p_idDocumento = 'PARNONINTERPRETATO'
      THEN
         d_ret := 1;
      ELSE
         d_ret := lettura_testo (p_idDocumento, p_utente);
      END IF;











      RETURN d_ret;
   END;

   /*****************************************************************************
    NOME:        eliminazione.
    DESCRIZIONE: Un utente ha i diritti in eliminazione se il documento non è
                 protocollato e se ne ha le competenze esplicite in si4_competenze
                 oppure, è un documento di interoperabilità e l'utente ha le
                 competenze in modifica.

   INPUT  p_id_documento    varchar2: chiave identificativa del documento.
          p_utente          varchar2: utente che vuole eliminare il documento
   RITORNO:  se il documento è protocollato restituisce sempre 0, altrimenti
             restituisce null.

    Rev.  Data       Autore Descrizione.
    000   29/08/2007 SC     A21487.2.0 difetto 56
    006   08/09/2016 MM     Modificata  funzione in modo che, per i protocolli
                            M_PROTOCOLLO_INTEROPERABILITA, possa eliminare un
                            documento chi può modificarlo.
   ********************************************************************************/
   FUNCTION eliminazione (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval     NUMBER := NULL;
      continua   NUMBER := 0;
      d_idrif    VARCHAR2 (100);
   BEGIN
      BEGIN
         continua :=
            AG_UTILITIES.verifica_categoria_documento (
               p_id_documento   => p_id_documento,
               p_categoria      => AG_UTILITIES.categoriaprotocollo);
      EXCEPTION
         WHEN OTHERS
         THEN
            continua := 0;
      END;

      -- DBMS_OUTPUT.put_line ('dopo verifica categoria ' || retval);
      IF continua = 1
      THEN
         -- SE il documento non è protocollato
         --normalmente la verifica è demandata al documentale, quindi si restituisce null.
         IF NVL (f_valore_campo (p_id_documento, campo_stato_protocollo),
                 'DP') <> 'DP'
         THEN
            retval := 0;
         ELSE
            IF AG_UTILITIES.IS_PROT_INTEROP (p_id_documento) = 1
            THEN
               retval :=
                  gdm_competenza.si4_verifica ('DOCUMENTI',
                                               p_id_documento,
                                               'U',
                                               p_utente,
                                               'GDM');
            END IF;
         END IF;
      END IF;

      /*     IF AG_UTILITIES.IS_PROT_INTEROP (p_id_documento) = 1
           THEN
              retval :=
                 gdm_competenza.si4_verifica ('DOCUMENTI',
                                              p_id_documento,
                                              'U',
                                              p_utente,
                                              'GDM');
           END IF;

           IF retval IS NULL
           THEN
              SELECT idrif
                INTO d_idrif
                FROM proto_view
               WHERE id_documento = p_id_documento;

           END IF;*/
      RETURN retval;
   END eliminazione;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_PROTOCOLLO.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo.
    I criteri di verifica sono i seguenti:
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   - se l'utente è membro di un'unita' cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento.
   Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   Gli smistamenti che vengono coltrollati dipendono dal valore dei parametri
   verifica_smistamenti_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C o R.
   verifica_carico_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C.
   verifica_smistamenti_storici - fa la verifica su smistamenti di unita' dell'utente cons stato_smistamento F.
   INPUT  p_id_documento varchar2 id del documento
         p_privilegio: codice del privilegio da verificare.
         verifica_smistamenti_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali, che siano in carico o da ricevere. 1 = fa il test, 0 non lo fa.
      verifica_carico_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali in carico. 1 = fa il test, 0 non lo fa.
      verifica_smistamenti_storici NUMBER indice se va fatto il test anche sui record di
      smistamenti storici. 1 = fa il test, 0 non lo fa.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    000   02/01/2007  SC  Prima emissione.
    001   27/03/2017  SC  Verifico anche per unita esibente
    010   31/07/2019  MM  Gestione documenti senza unita' protocollante.
   ********************************************************************************/
   FUNCTION verifica_privilegio_protocollo (p_id_documento    VARCHAR2,
                                            p_privilegio      VARCHAR2,
                                            p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      riservato            VARCHAR2 (1);
      utenteinstruttura    NUMBER := 0;
      dep_data_rif         DATE;
      unitaprotocollante   seg_unita.unita%TYPE;
      numero               NUMBER;
   BEGIN
      utenteinstruttura :=
         AG_UTILITIES.inizializza_utente (p_utente => p_utente);
      riservato := is_riservato (p_id_documento);
      dep_data_rif := AG_UTILITIES.get_Data_rif_privilegi (p_id_documento);

      --f_valore_campo (p_id_documento, campo_riservato);

      --verifica prima di tutto che esista almeno un'unita' per cui l'utente ha p_privilegio
      -- se cmq non ha il privilegio e' inutile proseguire.
      IF     utenteinstruttura = 1
         AND (   AG_UTILITIES.verifica_privilegio_utente (
                    p_unita        => NULL,
                    p_privilegio   => p_privilegio,
                    p_utente       => p_utente,
                    p_data         => dep_data_rif) = 1
              OR AG_UTILITIES.verifica_privilegio_utente (
                    p_unita        => NULL,
                    p_privilegio   => p_privilegio,
                    p_utente       => p_utente,
                    p_data         => TRUNC (SYSDATE)) = 1)
      THEN
         -- se il campo UNITA_PROTOCOLLANTE non è valorizzato (questo accade ad es nelle lettere create via ws)
         -- e il documento non è protocollato, basta che l'utente abbia p_privilegio per almeno un'unita'
         unitaprotocollante :=
            f_valore_campo (p_id_documento, 'UNITA_PROTOCOLLANTE');
         numero := f_valore_campo (p_id_documento, 'NUMERO');

         IF numero IS NULL
         THEN
            IF unitaprotocollante IS NULL
            THEN
               retval := 1;
            ELSE
               -- SE è una lettera il firmatario avra' sempre il privilegio.
               BEGIN
                  SELECT 1
                    INTO retval
                    FROM spr_lettere_uscita
                   WHERE     id_documento = p_id_documento
                         AND so4_dirigente = p_utente;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     retval:=0;
               END;
            END IF;
         END IF;

         IF retval = 0
         THEN
            -- se p_utente ha il privilegio ed e' un superuser, ho finito.
            IF riservato = 'Y'
            THEN
               retval :=
                  AG_UTILITIES.verifica_privilegio_utente (
                     p_unita        => NULL,
                     p_privilegio   => 'MTOTR',
                     p_utente       => p_utente,
                     p_data         => TRUNC (SYSDATE));
            ELSE
               retval :=
                  AG_UTILITIES.verifica_privilegio_utente (
                     p_unita        => NULL,
                     p_privilegio   => 'MTOT',
                     p_utente       => p_utente,
                     p_data         => TRUNC (SYSDATE));
            END IF;
         END IF;

         -- p_utente ha il privilegio ma non e' superuser, verifico se ha il privilegio come membro
         -- dell'unita protocollante o come membro di un'unita di carico attuale.
         IF retval = 0
         THEN
            retval :=
               verifica_per_protocollante (p_id_documento   => p_id_documento,
                                           p_privilegio     => p_privilegio,
                                           p_utente         => p_utente);

            IF retval = 0
            THEN
               retval :=
                  verifica_per_esibente (p_id_documento   => p_id_documento,
                                         p_privilegio     => p_privilegio,
                                         p_utente         => p_utente);
            END IF;

            IF retval = 0
            THEN
               idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);

               BEGIN
                  SELECT 1
                    INTO retval
                    FROM seg_smistamenti, documenti docu, ag_priv_utente_tmp
                   WHERE     docu.id_documento = seg_smistamenti.id_documento
                         AND docu.stato_documento NOT IN ('CA', 'RE')
                         AND seg_smistamenti.idrif = idrifprotocollo
                         AND (   seg_smistamenti.stato_smistamento IN (AG_UTILITIES.smistamento_in_carico,
                                                                       AG_UTILITIES.smistamento_eseguito)
                              OR seg_smistamenti.stato_smistamento =
                                    AG_UTILITIES.smistamento_da_ricevere)
                         AND seg_smistamenti.ufficio_smistamento =
                                ag_priv_utente_tmp.unita
                         AND ag_priv_utente_tmp.utente = p_utente
                         AND ag_priv_utente_tmp.privilegio = p_privilegio
                         AND dep_data_rif <=
                                NVL (ag_priv_utente_tmp.AL,
                                     TO_DATE (3333333, 'J'))
                         AND ROWNUM = 1;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;

            IF retval = 0 AND AG_UTILITIES.is_iter_fascicoli_attivo = 1
            THEN
               -- Se c'e' iter_fascicoli, controlla anche l'unita' di smistamento
               -- del fascicolo
               DECLARE
                  dep_idrif_fascicolo        VARCHAR2 (100);
                  dep_ubicazione_fascicolo   VARCHAR2 (100);
               BEGIN
                  SELECT fasc.idrif
                    INTO dep_idrif_fascicolo
                    FROM seg_fascicoli fasc, proto_view prot
                   WHERE     prot.id_documento = p_id_documento
                         AND fasc.class_cod = prot.class_cod
                         AND fasc.class_dal = prot.class_dal
                         AND fasc.fascicolo_anno = prot.fascicolo_anno
                         AND fasc.fascicolo_numero = prot.fascicolo_numero;

                  dep_ubicazione_fascicolo :=
                     ag_fascicolo_utility.get_unita_comp_attuale (
                        dep_idrif_fascicolo);

                  BEGIN
                     SELECT 1
                       INTO retval
                       FROM ag_priv_utente_tmp
                      WHERE     ag_priv_utente_tmp.unita =
                                   dep_ubicazione_fascicolo
                            AND ag_priv_utente_tmp.utente = p_utente
                            AND ag_priv_utente_tmp.privilegio = p_privilegio
                            AND dep_data_rif <=
                                   NVL (al, TO_DATE (3333333, 'j'))
                            AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        retval := 0;
                  END;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END verifica_privilegio_protocollo;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_PROTOCOLLO.
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio sul protocollo.
    Serve a verificare i privilegi di modifica sui singoli campi/ dettagli del protocollo,
    quuindi si da per scontato che l'utente abbia diritti generici in modifica sul documento.
    L'utente puo' avere tali diritti perche' membro dell'unita' protocollante, perche' membro
    di un'unita' di carico o di una sua supoeriore, perche' super user; quindi si cerchera' di verificare
    il privilegio specifico (p_privilegio) in tutti questi casi.
    Il super user viene riconosciuto in quanto possessore del privilegio MTOT o MTOTR (documento pubblico o riservato);
    i membri di unita protocollante o unita di carico devono avere tale privilegio associato al ruolo che hanno nell'unita stessa,
    i memebri di unita ascendenti lo devono avere nell'unita' ascendente.
    Inoltre, sempre per membri diunita di carico o ascendenti, il privilegio deve essere previsto dallo smistamento.
    I criteri di verifica sono i seguenti:
   - se l'utente ha privilegio MTOT o MTOTR, si verifica che abbia anche p_privilegio
   - se l'utente è membro dell'unità protocollante, ha il privilegio se ce l'ha il suo ruolo all'interno dell'unita' protocollante.
   - se l'utente è membro di un'unita' cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento. Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   - se l'utente è membro di un'unita' ascendente di una cui è stato smistato il documento, si verifica sulla tabella AG_PRIVILEGI_SMISTAMENTO se il privilegio è previsto
   per il tipo smistamento con cui l'utente riceve il documento. Se tale verifica è positiva, si verifica che il ruolo dell'utente all'interno di tale unita'
   abbia il privilegio richiesto.
   Gli smistamenti che vengono coltrollati dipendono dal valore dei parametri
   verifica_smistamenti_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C o R.
   verifica_carico_attuali - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento C.
   verifica_smistamenti_storici - fa la verifica su smistamenti di unita' dell'utente cons tato_smistamento F.
   INPUT  p_area varchar2
         p_modello varchar2
         p_codice_richiesta varchar2: chiave identificativa del documento.
         p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      , verifica_smistamenti_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali, che siano in carico o da ricevere. 1 = fa il test, 0 non lo fa.
      verifica_carico_attuali NUMBER indice se va fatto il test anche sui record di
      smistamenti attuali in carico. 1 = fa il test, 0 non lo fa.
      verifica_smistamenti_storici NUMBER indice se va fatto il test anche sui record di
      smistamenti storici. 1 = fa il test, 0 non lo fa.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_privilegio_protocollo (p_area                VARCHAR2,
                                            p_modello             VARCHAR2,
                                            p_codice_richiesta    VARCHAR2,
                                            p_privilegio          VARCHAR2,
                                            p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;
      retval        NUMBER := 0;
   BEGIN
      BEGIN
         iddocumento :=
            AG_UTILITIES.get_id_documento (p_area,
                                           p_modello,
                                           p_codice_richiesta);
         retval :=
            verifica_privilegio_protocollo (iddocumento,
                                            p_privilegio,
                                            p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END verifica_privilegio_protocollo;

   /******************************************************************************
      NAME:       CHECK_COMPETENZE_LETTURA_ATTI
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        06/06/2008    SC         1. Created this package. A27764.0.0
   ******************************************************************************/
   FUNCTION check_competenze_lettura_atti (p_id_documento   IN NUMBER,
                                           p_utente            VARCHAR2)
      RETURN NUMBER
   IS
      d_new_testo   VARCHAR2 (32000);
      retval        NUMBER;
   BEGIN
      -- se non c'è integrazione con jatti esco subito
      IF     is_categoriamodello (p_id_documento,
                                  AG_UTILITIES.categoriadelibere) = 1
         AND AG_UTILITIES.esiste_categoria (AG_UTILITIES.categoriadelibere) =
                1
      THEN
         -- se c'è jatti ed esistono le delibere, lancio la verifica delle comp funzionali
         d_new_testo :=
               'DECLARE d_ritorno number(1);'
            || 'BEGIN '
            || ' d_ritorno := ag_competenze_delibere.lettura('
            || p_id_documento
            || ', '''
            || p_utente
            || ''');'
            || 'if d_ritorno = 1 then ag_competenze_protocollo.set_true; '
            || ' elsif d_ritorno = 0 then ag_competenze_protocollo.set_false; '
            || 'end if; END;';
         --   DBMS_OUTPUT.put_line (d_new_testo);
         resetta;

         EXECUTE IMMEDIATE d_new_testo;

         retval := g_diritto;
      END IF;

      IF retval IS NULL OR retval = 0
      THEN
         -- se non c'è integrazione col protocollo esco subito


         IF     is_categoriamodello (p_id_documento,
                                     AG_UTILITIES.categoriadetermine) = 1
            AND AG_UTILITIES.esiste_categoria (
                   AG_UTILITIES.categoriadetermine) = 1
         THEN
            -- se c'è jatti ed esistono le determine, lancio la verifica delle comp funzionali
            d_new_testo :=
                  'DECLARE d_ritorno number(1);'
               || 'BEGIN '
               || ' d_ritorno := ag_competenze_determine.lettura('
               || p_id_documento
               || ', '''
               || p_utente
               || ''');'
               || 'if d_ritorno = 1 then ag_competenze_protocollo.set_true; '
               || ' elsif d_ritorno = 0 then ag_competenze_protocollo.set_false; '
               || 'end if; END;';
            --   DBMS_OUTPUT.put_line (d_new_testo);
            resetta;

            EXECUTE IMMEDIATE d_new_testo;

            retval := g_diritto;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('retval ' || retval);
      RETURN retval;
   END;


   FUNCTION lettura_protocollo (
      p_id_documento            VARCHAR2,
      p_utente                  VARCHAR2,
      p_suffissoprivilegio      VARCHAR2,
      p_riservato_causa_fasc    VARCHAR2 DEFAULT 'N',
      p_check_smist_fasc        NUMBER DEFAULT 1)
      RETURN NUMBER
   IS
      idrifprotocollo   VARCHAR2 (100);
      retval            NUMBER := NULL;
      dep_Data_rif      DATE;
   BEGIN
      -- se ha privilegio VTOT vede tutti i protocolli NON riservati.
      -- se ha privilegio VTOTR vede tutti i protocolli riservati.
      retval :=
         AG_UTILITIES.verifica_privilegio_utente (
            p_unita        => NULL,
            p_privilegio   => 'VTOT' || p_suffissoprivilegio,
            p_utente       => p_utente,
            p_data         => TRUNC (SYSDATE));

      IF retval = 0
      THEN
         dep_Data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);
         --per documenti NON riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VP.
         --per documenti riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VPR.
         retval :=
            verifica_per_protocollante (
               p_id_documento   => p_id_documento,
               p_privilegio     => 'VP' || p_suffissoprivilegio,
               p_utente         => p_utente);

         --per documenti NON riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VE.
         --per documenti riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VER.
         IF retval = 0
         THEN
            retval :=
               verifica_per_esibente (
                  p_id_documento   => p_id_documento,
                  p_privilegio     => 'VE' || p_suffissoprivilegio,
                  p_utente         => p_utente);
         END IF;

         IF retval = 0
         THEN
            --VERIFICA SE P_UTENTE FA PARTE DI UN'UNITA RICEVENTE (ATTUALE O STORICA) CON PRIVILEGIO
            --VS per documenti NON riservati
            --VSR per documenti riservati .
            IF     ag_parametro.get_valore (
                      'ITER_FASCICOLI_' || AG_UTILITIES.indiceaoo,
                      '@agVar@',
                      'N') = 'Y'
               AND p_check_smist_fasc = 1
            THEN
               BEGIN
                  SELECT NVL (MIN (1), 0)
                    INTO retval
                    FROM (SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu_smis,
                                 seg_fascicoli fasc,
                                 links,
                                 cartelle cart,
                                 documenti docu_fasc
                           WHERE     docu_smis.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND docu_smis.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = fasc.idrif
                                 AND seg_smistamenti.codice_assegnatario =
                                        p_utente
                                 AND seg_smistamenti.stato_smistamento IN ('R',
                                                                           'C')
                                 AND links.id_oggetto = p_id_documento
                                 AND links.tipo_oggetto = 'D'
                                 AND links.id_cartella = cart.id_cartella
                                 AND NVL (cart.stato, 'BO') != 'CA'
                                 AND cart.id_documento_profilo =
                                        fasc.id_documento
                                 AND fasc.id_documento =
                                        docu_fasc.id_documento
                                 AND docu_fasc.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND DECODE (
                                        p_riservato_causa_fasc,
                                        'N', 1,
                                        DECODE (NVL (fasc.riservato, 'N'),
                                                'Y', 1,
                                                0)) = 1
                          UNION ALL
                          SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu_smis,
                                 ag_priv_utente_tmp priv_vs,
                                 ag_privilegi_smistamento,
                                 seg_fascicoli fasc,
                                 links,
                                 cartelle cart,
                                 documenti docu_fasc
                           WHERE     docu_smis.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND docu_smis.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = fasc.idrif
                                 AND seg_smistamenti.tipo_smistamento =
                                        ag_privilegi_smistamento.tipo_smistamento
                                 AND priv_vs.utente = p_utente
                                 AND priv_vs.privilegio =
                                        'VS' || p_suffissoprivilegio
                                 AND ag_privilegi_smistamento.privilegio =
                                        priv_vs.privilegio
                                 AND seg_smistamenti.ufficio_smistamento =
                                        priv_vs.unita
                                 AND ag_privilegi_smistamento.aoo =
                                        AG_UTILITIES.indiceaoo
                                 AND links.id_oggetto = p_id_documento
                                 AND links.tipo_oggetto = 'D'
                                 AND links.id_cartella = cart.id_cartella
                                 AND NVL (cart.stato, 'BO') != 'CA'
                                 AND cart.id_documento_profilo =
                                        fasc.id_documento
                                 AND fasc.id_documento =
                                        docu_fasc.id_documento
                                 AND docu_fasc.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND ag_utilities.get_Data_rif_privilegi (
                                        fasc.id_documento) <=
                                        NVL (priv_vs.al,
                                             TO_DATE (3333333, 'J'))
                                 AND DECODE (
                                        p_riservato_causa_fasc,
                                        'N', 1,
                                        DECODE (NVL (fasc.riservato, 'N'),
                                                'Y', 1,
                                                0)) = 1
                          UNION ALL
                          SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu_smis,
                                 ag_priv_utente_tmp priv,
                                 seg_fascicoli fasc,
                                 links,
                                 cartelle cart,
                                 documenti docu_fasc
                           WHERE     docu_smis.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND docu_smis.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = fasc.idrif
                                 AND priv.utente = p_utente
                                 AND priv.privilegio =
                                        'VDDR' || p_suffissoprivilegio
                                 AND seg_smistamenti.ufficio_smistamento =
                                        priv.unita
                                 AND links.id_oggetto = p_id_documento
                                 AND links.tipo_oggetto = 'D'
                                 AND links.id_cartella = cart.id_cartella
                                 AND NVL (cart.stato, 'BO') != 'CA'
                                 AND cart.id_documento_profilo =
                                        fasc.id_documento
                                 AND fasc.id_documento =
                                        docu_fasc.id_documento
                                 AND docu_fasc.stato_documento NOT IN ('CA',
                                                                       'RE')
                                 AND ag_utilities.get_Data_rif_privilegi (
                                        fasc.id_documento) <=
                                        NVL (priv.al, TO_DATE (3333333, 'J'))
                                 AND DECODE (
                                        p_riservato_causa_fasc,
                                        'N', 1,
                                        DECODE (NVL (fasc.riservato, 'N'),
                                                'Y', 1,
                                                0)) = 1);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;

            IF retval = 0
            THEN
               BEGIN
                  idrifprotocollo :=
                     f_valore_campo (p_id_documento, campo_idrif);

                  --        05/12/2017 SC     ACCESSO NEGATO A PROTOCOLLO IN CARICO,
                  --                          ASSEGNATO AD UTENTE NON PIU' NELL'UNITà DI SMISTAMENTO.
                  --                          Per gli assegnati tolgo condizione su unità
                  SELECT NVL (MIN (1), 0)
                    INTO retval
                    FROM (SELECT 1
                            FROM seg_smistamenti, documenti docu
                           WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                                 AND docu.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = idrifprotocollo
                                 AND seg_smistamenti.codice_assegnatario =
                                        p_utente
                          /*AND EXISTS
                                 (SELECT 1
                                    FROM ag_priv_utente_tmp
                                   WHERE     utente = p_utente
                                         AND unita =
                                                seg_smistamenti.ufficio_smistamento)*/
                          UNION ALL
                          SELECT 1
                            FROM seg_smistamenti,
                                 documenti docu,
                                 ag_priv_utente_tmp priv_vs,
                                 ag_privilegi_smistamento
                           WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                                 AND docu.id_documento =
                                        seg_smistamenti.id_documento
                                 AND seg_smistamenti.idrif = idrifprotocollo
                                 AND seg_smistamenti.tipo_smistamento =
                                        ag_privilegi_smistamento.tipo_smistamento
                                 AND dep_data_rif <=
                                        NVL (priv_vs.al,
                                             TO_DATE (3333333, 'j'))
                                 AND priv_vs.utente = p_utente
                                 AND priv_vs.privilegio IN (   'VS'
                                                            || p_suffissoprivilegio,
                                                               'VDDR'
                                                            || p_suffissoprivilegio)
                                 AND ag_privilegi_smistamento.privilegio =
                                        priv_vs.privilegio
                                 AND seg_smistamenti.ufficio_smistamento =
                                        priv_vs.unita
                                 AND ag_privilegi_smistamento.aoo =
                                        AG_UTILITIES.indiceaoo);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END;



   /*****************************************************************************
    NOME:        LETTURA
    DESCRIZIONE: Un utente ha i diritti in lettura su un protocollo NON riservato se:
   - ha ruolo con privilegio VTOT
   - è membro dell'unita protocollante  e ha ruolo con privilegio VP
   - è membro dell'unita esibente  e ha ruolo con privilegio VE
   - è membro di un'unita che ha smistato il documento con privilegio VS
   - è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VS e CARICO
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUB
   Un utente ha i diritti in lettura su un protocollo RISERVATO se:
   - ha ruolo con privilegio VTOTR
   - è membro dell'unita protocollante  e ha ruolo con privilegio VPR
   - è membro dell'unita esibenre  e ha ruolo con privilegio VER
   - se NON è stato indicato un ASSEGNATARIO: l'utente è membro di un'unita che è unita ricevente di smistamento del documento con privilegio VSR e  CARICO
   - se è stato indicato un ASSEGNATARIO: l'utente deve essere proprio l'utente assegnatario
   - se è stato indicato un RUOLO ASSEGNATARIO: l'utente deve avere quel ruolo all'interno dell'unità ricevente di smistamento del documento
   - è membro di un'unita superiore a una di quelle di cui sopra e ha ruolo con privilegio VSUBR.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    000   02/01/2007  SC  Prima emissione.
          01/09/2008  SC  A28345.12.0
    002   14/01/2013  MM Introduzione variaile d_comp_da_ric per velocizzare la select.
   ********************************************************************************/
   FUNCTION lettura (p_id_documento      VARCHAR2,
                     p_utente            VARCHAR2,
                     p_apri_dettaglio    NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      retval                 NUMBER := NULL;
      riservato              VARCHAR2 (1);
      riservato_causa_fasc   VARCHAR2 (1) := 'N';
      continua               NUMBER := 0;
      suffissoprivilegio     VARCHAR2 (1);
      idrifprotocollo        VARCHAR2 (100);
   BEGIN
      --  DBMS_OUTPUT.put_line ('1VALORE DI RETVAL ' || retval);

      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF AG_UTILITIES.inizializza_utente (p_utente) = 0
      THEN
         IF p_utente = AG_UTILITIES.utente_superuser_segreteria
         THEN
            RETURN 1;
         ELSE
            RETURN NULL;
         END IF;
      END IF;

      -- VERIFICA CHE IL DOCUMENTO SIA UN PROTOCOLLO (categoria PROTO)
      BEGIN
         continua :=
            AG_UTILITIES.verifica_categoria_documento (
               p_id_documento   => p_id_documento,
               p_categoria      => AG_UTILITIES.categoriaprotocollo);
      EXCEPTION
         WHEN OTHERS
         THEN
            continua := 0;
      END;

      IF continua = 1
      THEN
         -- verifica se il documento è una delibere o una determina
         -- e se ha i diritti in lettura, se questa funzione restituisce 0
         -- verifica se
         -- ha i diritti in lettura grazie ad uno smistamento
         retval :=
            check_competenze_lettura_atti (p_id_documento   => p_id_documento,
                                           p_utente         => p_utente);

         DBMS_OUTPUT.put_line ('retva atti ' || retval);

         IF retval IS NULL OR retval = 0
         THEN
            retval := NULL;

            -- SE il documento non è protocollato
            --normalmente la verifica è demandata al documentale, quindi si restituisce null.
            -- Fanno eccezione i documenti da protocollare provenienti da interoperabilita
            --che vengono resi accessibili a chi ha privilegio PROTMAIL.
            DBMS_OUTPUT.put_line (
                  'DOCUMENTO DA PROTOCOLLARE '
               || f_valore_campo (p_id_documento, campo_stato_protocollo));

            IF NVL (f_valore_campo (p_id_documento, campo_stato_protocollo),
                    'DP') = 'DP'
            THEN
               DBMS_OUTPUT.put_line ('DOCUMENTO DA PROTOCOLLARE');
               retval := lettura_non_protocollati (p_id_documento, p_utente);
               DBMS_OUTPUT.put_line ('2VALORE DI RETVAL: ' || retval);
            ELSE
               -- SE è una lettera il redattore la vedra' sempre.
               BEGIN
                  SELECT 1
                    INTO retval
                    FROM spr_lettere_uscita
                   WHERE     id_documento = p_id_documento
                         AND (   (    utente_protocollante = p_utente
                                  AND NVL (riservato, 'N') = 'N')
                              OR so4_dirigente = p_utente);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END;

               IF retval IS NULL OR retval = 0
               THEN
                  -- verifica se tutti i protocolli si devono vedere in elenco
                  IF     ag_parametro.get_valore (
                            'VIS_PROT_IN_ELENCO_' || AG_UTILITIES.indiceaoo,
                            '@agVar@',
                            'N') <> 'N'
                     AND p_apri_dettaglio IS NULL
                  THEN
                     retval := 1;
                  END IF;

                  IF retval IS NULL OR retval = 0
                  THEN
                     riservato := is_riservato (p_id_documento);

                     --f_valore_campo (p_id_documento, campo_riservato);
                     IF riservato = 'Y'
                     THEN
                        -- se i doc riservati si devono vedere in elenco, i privilegi
                        -- di lettura rimangono quelli dei doc non riservati
                        IF    ag_parametro.get_valore (
                                 'VIS_RIS_IN_ELENCO_' || AG_UTILITIES.indiceaoo,
                                 '@agVar@',
                                 'N') = 'N'
                           OR p_apri_dettaglio = 1
                        THEN
                           suffissoprivilegio := 'R';
                        END IF;


                        IF NVL (
                              f_valore_campo (p_id_documento,
                                              campo_riservato),
                              'N') = 'N'
                        THEN
                           riservato_causa_fasc := 'Y';
                        END IF;
                     END IF;


                     DBMS_OUTPUT.put_line (
                           'lettura_protocollo('
                        || p_id_documento
                        || ''', '''
                        || p_utente
                        || ''', '''
                        || suffissoprivilegio
                        || ''', '''
                        || riservato_causa_fasc
                        || ''', 1)');


                     retval :=
                        lettura_protocollo (p_id_documento,
                                            p_utente,
                                            suffissoprivilegio,
                                            riservato_causa_fasc,
                                            1);
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN retval;
   END lettura;

   /*****************************************************************************
    NOME:        lettura_testo.
    DESCRIZIONE: Un utente ha i diritti di lettura sul testo di un documento se
                 ha diritti di lettura sul documento oppure se l'utente è GDM o
                 RPI oppure se ha ruolo AGPCONS (per parare problema del documentale
                 sull'esclusione delle competenze).

   INPUT  p_id_documento    varchar2: chiave identificativa del documento.
          p_utente          varchar2: utente che vuole leggere il testo del documento
   RITORNO:  se il documento è protocollato restituisce sempre 0, altrimenti
             restituisce null.

    Rev.  Data       Autore Descrizione.
    000   29/08/2007 SC     A21487.2.0 difetto 56
    006   08/09/2016 MM     Modificata  funzione in modo chetesti anche il ruolo
                            AGPCONS.
   ********************************************************************************/
   FUNCTION lettura_testo (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      d_ret          NUMBER;
      d_is_agpcons   NUMBER := 0;
      d_idrif        VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT 1
           INTO d_is_agpcons
           FROM ad4_utenti_gruppo utgr, ad4_utenti ruol
          WHERE     UTGR.utente = p_utente
                AND utgr.gruppo = ruol.utente
                AND ruol.gruppo_lavoro = 'AGPCONS';
      EXCEPTION
         WHEN OTHERS
         THEN
            d_is_agpcons := 0;
      END;

      IF p_utente IN ('GDM', 'RPI') OR d_is_agpcons = 1
      THEN
         RETURN 1;
      END IF;

      IF p_id_documento = 'PARNONINTERPRETATO'
      THEN
         d_ret := 1;
      ELSE
         d_ret := lettura (p_id_documento, p_utente, 1);
      END IF;

      IF d_ret IS NULL
      THEN
         SELECT idrif
           INTO d_idrif
           FROM proto_view
          WHERE id_documento = p_id_documento;
      END IF;


      RETURN d_ret;
   END lettura_testo;

   FUNCTION lettura_light (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := NULL;
      riservato            VARCHAR2 (1);
      continua             NUMBER := 0;
      suffissoprivilegio   VARCHAR2 (1);
      idrifprotocollo      VARCHAR2 (100);
      dep_data_rif         DATE;
   BEGIN
      --DBMS_OUTPUT.put_line ('1VALORE DI RETVAL ' || retval);

      -- se l'utente non fa parte di alcuna unita esco subito con null
      IF AG_UTILITIES.inizializza_utente (p_utente) = 0
      THEN
         RETURN NULL;
      END IF;

      -- VERIFICA CHE IL DOCUMENTO SIA UN PROTOCOLLO (categoria PROTO)
      BEGIN
         continua :=
            AG_UTILITIES.verifica_categoria_documento (
               p_id_documento   => p_id_documento,
               p_categoria      => AG_UTILITIES.categoriaprotocollo);
      EXCEPTION
         WHEN OTHERS
         THEN
            continua := 0;
      END;

      IF continua = 1
      THEN
         retval := NULL;

         -- SE il documento non è protocollato
         --normalmente la verifica è demandata al documentale, quindi si restituisce null.
         -- Fanno eccezione i documenti da protocollare provenienti da interoperabilita
         --che vengono resi accessibili a chi ha privilegio PROTMAIL.
         --DBMS_OUTPUT.put_line (   'DOCUMENTO DA PROTOCOLLARE '
         --                               || f_valore_campo (p_id_documento,
         --                                                  campo_stato_protocollo
         --                                                 )
         --                              );
         IF NVL (f_valore_campo (p_id_documento, campo_stato_protocollo),
                 'DP') = 'DP'
         THEN
            RETURN NULL;
         ELSE
            riservato := is_riservato (p_id_documento);

            --f_valore_campo (p_id_documento, campo_riservato);
            IF riservato = 'N'
            THEN
               RETURN 1;
            ELSE
               -- se i doc riservati si devono vedere in elenco, i privilegi
               -- di lettura rimangono quelli dei doc non riservati
               IF ag_parametro.get_valore (
                     'VIS_RIS_IN_ELENCO_' || AG_UTILITIES.indiceaoo,
                     '@agVar@',
                     'N') = 'N'
               THEN
                  suffissoprivilegio := 'R';
               END IF;
            END IF;

            -- se ha privilegio VTOT vede tutti i protocolli NON riservati.
            -- se ha privilegio VTOTR vede tutti i protocolli riservati.
            retval :=
               AG_UTILITIES.verifica_privilegio_utente (
                  p_unita        => NULL,
                  p_privilegio   => 'VTOT' || suffissoprivilegio,
                  p_utente       => p_utente,
                  p_data         => TRUNC (SYSDATE));

            IF retval = 0
            THEN
               dep_data_rif :=
                  ag_utilities.get_Data_rif_privilegi (p_id_documento);
               --per documenti NON riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VP.
               --per documenti riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VPR.
               retval :=
                  verifica_per_protocollante (
                     p_id_documento   => p_id_documento,
                     p_privilegio     => 'VP' || suffissoprivilegio,
                     p_utente         => p_utente);

               --per documenti NON riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VE.
               --per documenti riservati verifico se l'utente fa parte dell'unita protocollante con privilegio VER.
               IF retval = 0
               THEN
                  retval :=
                     verifica_per_esibente (
                        p_id_documento   => p_id_documento,
                        p_privilegio     => 'VE' || suffissoprivilegio,
                        p_utente         => p_utente);
               END IF;

               IF retval = 0
               THEN
                  --VERIFICA SE P_UTENTE FA PARTE DI UN'UNITA RICEVENTE (ATTUALE O STORICA) CON PRIVILEGIO
                  --VS per documenti NON riservati
                  --VSR per documenti riservati .
                  idrifprotocollo :=
                     f_valore_campo (p_id_documento, campo_idrif);

                  DECLARE
                     d_da_ricevere   NUMBER
                        := da_ricevere (p_id_documento, p_utente);
                  BEGIN
                     SELECT 1
                       INTO retval
                       FROM seg_smistamenti,
                            documenti docu,
                            ag_priv_utente_tmp,
                            ag_privilegi_smistamento
                      WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                            AND docu.id_documento =
                                   seg_smistamenti.id_documento
                            AND seg_smistamenti.idrif = idrifprotocollo
                            AND seg_smistamenti.ufficio_smistamento =
                                   ag_priv_utente_tmp.unita
                            AND seg_smistamenti.tipo_smistamento =
                                   ag_privilegi_smistamento.tipo_smistamento
                            AND dep_Data_rif <=
                                   NVL (ag_priv_utente_tmp.al,
                                        TO_DATE (3333333, 'j'))
                            AND ag_priv_utente_tmp.utente = p_utente
                            AND ag_priv_utente_tmp.privilegio =
                                   'VS' || suffissoprivilegio
                            AND ag_privilegi_smistamento.privilegio =
                                   ag_priv_utente_tmp.privilegio
                            AND ag_privilegi_smistamento.aoo =
                                   AG_UTILITIES.indiceaoo
                            AND DECODE (seg_smistamenti.stato_smistamento,
                                        'R', d_da_ricevere,
                                        1) = 1
                            AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        retval := 0;
                  END;
               END IF;
            END IF;

            -- se il documento e' riservato ma e' stato smistato personalmente a p_utente
            -- o al suo ruolo, p_utente lo puo' cmq vedere.
            IF riservato = 'Y' AND retval = 0
            THEN
               BEGIN
                  SELECT 1
                    INTO retval
                    FROM seg_smistamenti, documenti docu, ag_priv_utente_tmp
                   WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                         AND docu.id_documento = seg_smistamenti.id_documento
                         AND seg_smistamenti.idrif = idrifprotocollo
                         AND seg_smistamenti.ufficio_smistamento =
                                ag_priv_utente_tmp.unita
                         AND seg_smistamenti.codice_assegnatario =
                                ag_priv_utente_tmp.utente
                         AND ag_priv_utente_tmp.utente = p_utente;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     retval := 0;
               END;
            END IF;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('3VALORE DI RETVAL ' || retval);
      RETURN retval;
   END lettura_light;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere privilegio VS/VSR o essere assegnatario
    del documento.
    Se tra tutti gli smistamenti in stato R relativi a p_utente, ce n'e' anche uno solo il cui relativo flusso
    non è arrivato ad attivare l'attivita' sul cruscotto, la funzione restituisce 0 per evitare
    disallineamenti tra lo stato dello smistamento e l'effettivo stato del flusso.
    la funzione restituisce 1 se l'utente appartiene all'unita ricevente e ha i diritti di vedere il documento,
    inoltre lo smistamento e il flusso collegato devono essere coerenti: cioe' deve essere attiva
    l'attivita' jsuite sul cruscotto come documento da ricevere per ogni smistamento.
    Se il documento è assegnato  la funzione restituisce 1 se l'utente è l'assegnatario.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
         16/01/2008  SC  Prima emissione. A25157.0.0
   ********************************************************************************/
   FUNCTION da_ricevere (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN da_ricevere (p_id_documento                  => p_id_documento,
                          p_utente                        => p_utente,
                          p_verifica_esistenza_attivita   => 1);
   END;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE:  Verifica se il documento ha uno smistamento in stato da ricevere
                  per unita cui p_utente appartiene.
                  Inoltre p_utente deve avere diritti in lettura sul documento,
                  cioè deve avere privilegio VDDR/VDDRR oppure VS/VSR e CARICO e il
                  documento non deve essere assegnato oppure essere assegnatario
                  del documento.
                  Se tra tutti gli smistamenti in stato R relativi a p_utente, ce
                  n'e' anche uno solo il cui relativo flusso non è arrivato ad
                  attivare l'attivita' sul cruscotto, la funzione restituisce 0 per
                  evitare disallineamenti tra lo stato dello smistamento e
                  l'effettivo stato del flusso.
                  La funzione restituisce 1 se l'utente appartiene all'unita
                  ricevente e ha i diritti di vedere il documento, inoltre lo
                  smistamento e il flusso collegato devono essere coerenti: cioe'
                  deve essere attiva l'attivita' jsuite sul cruscotto come documento
                  da ricevere per ogni smistamento.
                  Se il documento è assegnato, la funzione restituisce 1 se l'utente
                  è l'assegnatario.
   INPUT    p_id_documento varchar2: chiave identificativa del documento.
            p_utente varchar2: utente che richiede di leggere il documento.
            p_verifica_esistenza_attivita 0 o 1 se si vuole verificare se c'è
            un'attivita' jsuite in attesa.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore   Descrizione.
    00   02/01/2007  SC       Prima emissione.
         15/01/2008  SC       Faccio in modo che risulti da ricevere per
                              p_utente solo se non assegnato o assegnato a p_utente.
         16/01/2008  SC       A25157.0.0
         01/06/2011  MM       A33879.0.0: Aggiungere due ulteriori privilegi
                              (VDDR - VDDRR per i doc. riservati) che consentono di
                              vedere i documenti da ricevere senza poterci fare
                              nulla, è come l'attuale VS ma fa sì che il documento
                              da prendere in carico sia visibile a chi ha i
                              privilegi attuali (CARICO e VS) e a chi ha il nuovo
                              privilegio.
   ********************************************************************************/
   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER,
                         p_verifica_assegnazione          NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN da_ricevere (p_id_documento,
                          p_utente,
                          p_verifica_esistenza_attivita,
                          p_verifica_assegnazione,
                          NULL);
   END da_ricevere;

   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER,
                         p_verifica_assegnazione          NUMBER,
                         p_unita_ricevente                VARCHAR2)
      RETURN NUMBER
   IS
      retval                 NUMBER := 0;
      idrifprotocollo        VARCHAR2 (100);
      riservato              VARCHAR2 (1) := 'N';
      suffissoprivilegio     VARCHAR2 (1);
      continua               NUMBER := 0;
      exectype_ricevimento   VARCHAR2 (100) := 'VISIONE';
      stato_pr               VARCHAR2 (10);
      dep_data_rif           DATE;
   BEGIN
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := AG_UTILITIES.inizializza_utente (p_utente => p_utente);
      stato_pr :=
         NVL (f_valore_campo (p_id_documento, campo_stato_protocollo), 'DP');
      dep_data_rif := ag_utilities.get_Data_rif_privilegi (p_id_documento);

      IF continua = 1 AND stato_pr NOT IN ('AN')
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
         riservato := is_riservato (p_id_documento);

         --f_valore_campo (p_id_documento, campo_riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            FOR s
               IN (SELECT    docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido /*,
                           ag_priv_utente_tmp*/
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.stato_smistamento = 'R'
                          AND seg_smistamenti.codice_assegnatario = p_utente
                          AND p_verifica_assegnazione = 1
                          AND ROWNUM = 1
                   UNION
                   SELECT    docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido,
                          ag_priv_utente_tmp priv_visu,
                          ag_priv_utente_tmp priv_carico
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.ufficio_smistamento =
                                 priv_visu.unita
                          AND seg_smistamenti.ufficio_smistamento =
                                 priv_carico.unita
                          AND seg_smistamenti.stato_smistamento = 'R'
                          AND seg_smistamenti.ufficio_smistamento || '' =
                                 NVL (p_unita_ricevente,
                                      seg_smistamenti.ufficio_smistamento)
                          AND priv_visu.utente = p_utente
                          AND priv_carico.utente = p_utente
                          AND NVL (seg_smistamenti.codice_assegnatario,
                                   p_utente) = p_utente
                          AND priv_visu.privilegio =
                                 'VS' || suffissoprivilegio
                          AND priv_carico.privilegio = 'CARICO'
                          AND dep_data_rif <=
                                 NVL (priv_visu.al, TO_DATE (3333333, 'j'))
                          AND dep_data_rif <=
                                 NVL (priv_carico.al, TO_DATE (3333333, 'j'))
                   UNION
                   SELECT    docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido,
                          ag_priv_utente_tmp priv_visu
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.ufficio_smistamento =
                                 priv_visu.unita
                          AND seg_smistamenti.stato_smistamento = 'R'
                          AND priv_visu.utente = p_utente
                          AND dep_data_rif <=
                                 NVL (priv_visu.al, TO_DATE (3333333, 'j'))
                          AND priv_visu.privilegio =
                                 'VDDR' || suffissoprivilegio)
            LOOP
               DBMS_OUTPUT.put_line ('sono nel loop con ' || s.triade);
               DBMS_OUTPUT.put_line (
                     'p_verifica_esistenza_attivita '
                  || p_verifica_esistenza_attivita);

               --se non ci sono smistamenti da ricevere
               --con il nodo del cruscotto in attesa
               -- considero che il doc non è da ricevere.
               --DBMS_OUTPUT.put_line (s.triade);
               IF p_verifica_esistenza_attivita = 1
               THEN
                  retval :=
                     test_attivita_in_attesa (s.triade, exectype_ricevimento);
                  DBMS_OUTPUT.put_line (
                     'test_attivita_in_attesa retval ' || retval);

                  IF retval = 0
                  THEN
                     EXIT;
                  END IF;
               ELSE
                  retval := 1;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         IF riservato = 'Y' AND retval = 0
         THEN
            BEGIN
               FOR sriservati
                  IN (SELECT DISTINCT
                                docu.area
                             || '@'
                             || tido.nome
                             || '@'
                             || docu.codice_richiesta
                                triade
                        FROM seg_smistamenti,
                             documenti docu,
                             tipi_documento tido,
                             ag_priv_utente_tmp
                       WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                             AND docu.id_documento =
                                    seg_smistamenti.id_documento
                             AND docu.id_tipodoc = tido.id_tipodoc
                             AND seg_smistamenti.idrif = idrifprotocollo
                             AND seg_smistamenti.ufficio_smistamento =
                                    ag_priv_utente_tmp.unita
                             AND seg_smistamenti.stato_smistamento = 'R'
                             AND seg_smistamenti.codice_assegnatario =
                                    ag_priv_utente_tmp.utente
                             AND dep_data_rif <=
                                    NVL (ag_priv_utente_tmp.al,
                                         TO_DATE (3333333, 'j'))
                             AND ag_priv_utente_tmp.utente = p_utente)
               LOOP
                  IF p_verifica_esistenza_attivita = 1
                  THEN
                     retval :=
                        test_attivita_in_attesa (sriservati.triade,
                                                 exectype_ricevimento);

                     IF retval = 0
                     THEN
                        EXIT;
                     END IF;
                  ELSE
                     retval := 1;
                  END IF;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      RETURN retval;
   END da_ricevere;

   FUNCTION da_ricevere (p_id_documento                   VARCHAR2,
                         p_utente                         VARCHAR2,
                         p_verifica_esistenza_attivita    NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN da_ricevere (
                p_id_documento                  => p_id_documento,
                p_utente                        => p_utente,
                p_verifica_esistenza_attivita   => p_verifica_esistenza_attivita,
                p_verifica_assegnazione         => 1);
   END da_ricevere;

   /*****************************************************************************
    NOME:        DEFAULT_TIPO_SMISTAMENTO
    DESCRIZIONE: Calcola il tipo di smistamento di default da assegnare a nuovi smistamenti
      creati tramite azione SMISTA, ESEGUISMISTA, INOLTRA.
      Se è possibile creare smistamenti di piu' tipi propone quello con valore minore
      del campo importanza di AG_TIPI_SMISTAMENTO. (Valore minore significa predominanza).
   INPUT  p_idrif varchar2: campo IDRIF identificativo del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_azione ('SMISTA', 'INOLTRA', 'ESEGUISMISTA'...)
   RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    24/01/2008  SC  Prima emissione. A25457.
   011  25/09/2019    SC  Bug #36615 Gestione smistamento per conoscenza
                          Modificata default_tipo_smistamento
                          Se utente ha privilegio CARICO e VS su smistamento per conoscenza
                          e VDDR su quello per competenza, non puo' smistare per
                          competenza.
   ********************************************************************************/
   FUNCTION default_tipo_smistamento (p_idrif                     VARCHAR2,
                                      p_codice_amministrazione    VARCHAR2,
                                      p_codice_aoo                VARCHAR2,
                                      p_area_modello_origine      VARCHAR2,
                                      p_cm_modello_origine        VARCHAR2,
                                      p_utente                    VARCHAR2,
                                      p_azione                    VARCHAR2)
      RETURN VARCHAR2
   IS
      retval               ag_tipi_smistamento.tipo_smistamento%TYPE;
      importanza           NUMBER;
      tutti                VARCHAR2 (100) := 'GENERALE';
      utenteinstruttura    NUMBER := 0;
      dep_id_documento     NUMBER;
      dep_data_rif         DATE;
      dep_tipo_documento   VARCHAR2 (100);
   BEGIN
      utenteinstruttura :=
         AG_UTILITIES.inizializza_utente (p_utente => p_utente);
      dep_id_documento := AG_UTILITIES.get_documento_per_idrif (p_idrif);

      -- se il protocollo ha un tipo doc con associati smistamenti e se l'azione
      -- è %SMISTA%, allora solo smistamenti per CONOSCENZA sono ammessi
      dep_tipo_documento :=
         f_valore_campo (dep_id_documento, 'TIPO_DOCUMENTO');

      IF     p_azione LIKE '%SMISTA%'
         AND AG_TIPI_DOCUMENTO_UTILITY.HAS_SEQUENZA_SMISTAMENTI (
                dep_tipo_documento) = 1
      THEN
         retval := 'CONOSCENZA';
      END IF;

      IF retval IS NULL
      THEN
         dep_data_rif :=
            AG_UTILITIES.get_Data_rif_privilegi (dep_id_documento);

         --DBMS_OUTPUT.put_line ('utenteinstruttura ' || utenteinstruttura);
         IF utenteinstruttura = 1
         THEN
            BEGIN
               FOR tipi
                  IN (SELECT DISTINCT
                             DECODE (
                                ag_abilitazioni_smistamento.tipo_smistamento_generabile,
                                tutti, 'COMPETENZA',
                                ag_abilitazioni_smistamento.tipo_smistamento_generabile)
                                tipo,
                             ag_tipi_smistamento.importanza
                        FROM ag_priv_utente_tmp,
                             ag_abilitazioni_smistamento,
                             ag_tipi_smistamento,
                             seg_smistamenti,
                             documenti docu,
                             ag_tipi_smistamento_modello,
                             proto_view prot
                       WHERE     ag_tipi_smistamento_modello.area =
                                    p_area_modello_origine
                             AND ag_tipi_smistamento_modello.codice_modello =
                                    p_cm_modello_origine
                             AND ag_tipi_smistamento_modello.aoo =
                                    AG_UTILITIES.indiceaoo
                             AND ag_tipi_smistamento_modello.tipo_smistamento =
                                    ag_abilitazioni_smistamento.tipo_smistamento_generabile
                             AND docu.stato_documento NOT IN ('CA', 'RE')
                             AND docu.id_documento =
                                    seg_smistamenti.id_documento
                             AND seg_smistamenti.idrif = p_idrif
                             AND prot.idrif = seg_smistamenti.idrif
                             AND seg_smistamenti.ufficio_smistamento =
                                    ag_priv_utente_tmp.unita
                             AND dep_data_rif <=
                                    NVL (ag_priv_utente_tmp.al,
                                         TO_DATE (3333333, 'j'))
                             AND seg_smistamenti.stato_smistamento =
                                    ag_abilitazioni_smistamento.stato_smistamento
                             AND seg_smistamenti.tipo_smistamento =
                                    ag_abilitazioni_smistamento.tipo_smistamento
                             AND ag_priv_utente_tmp.utente = p_utente
                             AND (   ag_priv_utente_tmp.privilegio IN (SELECT DECODE (
                                                                                 prot.riservato,
                                                                                 'Y', 'VSR',
                                                                                 'VS')
                                                                         FROM DUAL
                                                                       UNION
                                                                       SELECT 'CARICO'
                                                                         FROM DUAL
                                                                        WHERE SEG_SMISTAMENTI.STATO_SMISTAMENTO =
                                                                                 'R')
                                  OR SEG_SMISTAMENTI.CODICE_ASSEGNATARIO =
                                        p_utente)
                             AND ag_abilitazioni_smistamento.azione =
                                    p_azione
                             AND ag_abilitazioni_smistamento.aoo =
                                    AG_UTILITIES.indiceaoo
                             AND ag_tipi_smistamento.tipo_smistamento =
                                    ag_abilitazioni_smistamento.tipo_smistamento_generabile
                             AND ag_tipi_smistamento.aoo =
                                    ag_abilitazioni_smistamento.aoo)
               LOOP
                  IF (retval IS NULL)
                  THEN
                     retval := tipi.tipo;
                     importanza := tipi.importanza;
                  ELSE
                     IF (tipi.importanza < importanza)
                     THEN
                        retval := tipi.tipo;
                        importanza := tipi.importanza;
                     END IF;
                  END IF;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      RETURN retval;
   END default_tipo_smistamento;

   /*****************************************************************************
    NOME:        DEFAULT_TIPO_SMISTAMENTO
    DESCRIZIONE: Calcola il tipo di smistamento di default da assegnare a nuovi smistamenti
      creati tramite azione SMISTA, ESEGUISMISTA, INOLTRA.
      Se è possibile creare smistamenti di piu' tipi propone quello con valore minore
      del campo importanza di AG_TIPI_SMISTAMENTO. (Valore minore significa predominanza).
   INPUT  p_id_documento varchar2: chiave identificativa del documento di protocollo.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_azione ('SMISTA', 'INOLTRA', 'ESEGUISMISTA'...)
   RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    24/01/2008  SC  Prima emissione. A25457.
   ********************************************************************************/
   FUNCTION default_tipo_smistamento (p_id_documento    NUMBER,
                                      p_utente          VARCHAR2,
                                      p_azione          VARCHAR2)
      RETURN VARCHAR2
   IS
      retval                ag_tipi_smistamento.tipo_smistamento%TYPE;
      importanza            NUMBER;
      idrifprotocollo       VARCHAR2 (100);
      unita_protocollante   seg_unita.unita%TYPE;
      unita_esibente        seg_unita.unita%TYPE;
      tutti                 VARCHAR2 (100) := 'GENERALE';
      utenteinstruttura     NUMBER := 0;
      codiceammprotocollo   VARCHAR2 (100);
      codiceaooprotocollo   VARCHAR2 (100);
      areaprotocollo        VARCHAR2 (100);
      cmprotocollo          VARCHAR2 (100);
   BEGIN
      idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
      codiceammprotocollo :=
         f_valore_campo (p_id_documento, 'CODICE_AMMINISTRAZIONE');
      codiceaooprotocollo := f_valore_campo (p_id_documento, 'CODICE_AOO');

      SELECT tido.nome, docu.area
        INTO cmprotocollo, areaprotocollo
        FROM documenti docu, tipi_documento tido
       WHERE     docu.id_documento = p_id_documento
             AND docu.id_tipodoc = tido.id_tipodoc;

      retval :=
         default_tipo_smistamento (
            p_idrif                    => idrifprotocollo,
            p_codice_amministrazione   => codiceammprotocollo,
            p_codice_aoo               => codiceaooprotocollo,
            p_area_modello_origine     => areaprotocollo,
            p_cm_modello_origine       => cmprotocollo,
            p_utente                   => p_utente,
            p_azione                   => p_azione);
      RETURN retval;
   END default_tipo_smistamento;

   FUNCTION abilita_smist_per_fasc (p_id_documento    VARCHAR2,
                                    p_utente          VARCHAR2)
      RETURN NUMBER
   IS
      retval             NUMBER := 0;
      dep_idrif          VARCHAR2 (4000);
      dep_iter_fasc      parametri.valore%TYPE;
      dep_id_fascicolo   NUMBER;
      dep_data_rif       DATE;
   BEGIN
      IF ag_parametro.get_valore (
            'ITER_FASCICOLI_' || ag_utilities.indiceaoo,
            '@agVar@',
            'N') = 'Y'
      THEN
         BEGIN
            SELECT fasc.idrif, fasc.id_documento
              INTO dep_idrif, dep_id_fascicolo
              FROM seg_fascicoli fasc, proto_view prot
             WHERE     prot.id_documento = p_id_documento
                   AND fasc.class_cod = prot.class_cod
                   AND fasc.class_dal = prot.class_dal
                   AND fasc.fascicolo_anno = prot.fascicolo_anno
                   AND fasc.fascicolo_numero = prot.fascicolo_numero;

            -- DBMS_OUTPUT.put_line (dep_idrif);
            dep_data_rif :=
               ag_utilities.get_Data_rif_privilegi (dep_id_fascicolo);

            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp, seg_smistamenti, documenti dosm
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = dep_idrif
                   AND seg_smistamenti.ufficio_smistamento =
                          ag_priv_utente_tmp.unita
                   AND seg_smistamenti.stato_smistamento IN ('C', 'R')
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND (   ag_priv_utente_tmp.privilegio = 'ISMI'
                        OR NVL (seg_smistamenti.codice_assegnatario, '*') =
                              p_utente)
                   AND dep_data_rif <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;
      END IF;

      RETURN retval;
   END;

   /*****************************************************************************
    NOME:        abilita_azione_smistamento
    DESCRIZIONE: Verifica se è possibile abilitare l'azione richiesta (SMISTA, INOLTRA)
    in base a:
    utente, per quale ragione vede il documento (protocollante, esibente, smistamento)
    se vede il documento a seguito di uno smistamento (l'abilitazione
    varia a seconda dello stato dello smistamento).
    Per SMISTA si restituisce 1 se
    l'utente è l'utente protocollante,
    l'utente è un protocollante o esibente con privilegio ISMI + CPROT;
    l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
    tabella AG_ABILITAZIONI_SMISTAMENTO
    Per INOLTRA e per ASSEGNA si restituisce 1 se:
    l'utente è un ricevente e tipo_smistamento, stato_smistamento e azione sono presenti nella
    tabella AG_ABILITAZIONI_SMISTAMENTO.
    --A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
    Per CARICO, si verifica che l'utente abbia privilegio CARICO e non privilegio ISMI.
    In tutti gli altri casi si restituisce 0.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_azione (''CARICO', 'ESEGUI', 'ASSEGNA', SMISTA', 'INOLTRA')
         p_stato_smistamento Se è rilevante verificare lo stato dello smistamento,
                           va specificato tramite questo parametro. Default null.
   RITORNO:  1 se l'utente ha diritti di smistare, 0 altrimenti.
    Rev. Data       Autore  Descrizione.
    000  20/06/2007 SC  Prima emissione.
         20/05/2009 SC  A32601.0.0 Per smistare documenti protocollati
                                       a nome dell'unita protocollante ci vuole ISMI + CPROT.
         20/05/2009 SC  A32603.0.0 SC Per tutte le azioni, tranne CARICO, si verifica se
                                       l'utente ha privilegio ISMI, ma per abilitare
                                       la presa in carico si verifica il privilegio CARICO.
         01/06/2009 SC  A33037.0.0 L'utente protocollante può sempre inserire smistamenti.
         17/08/2009 SC  A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
         18/08/2009 SC  A33906.0.0 Per il carico e assegna, diventa rilevante verificare
                                   se ci sono unità aperte in smistamenti da ricevere.
                                   Altrimenti si abilita il bottone, ma poi
                                   non ha unità di assegnazione da proporre.
    004  01/12/2015 MM  Modificata abilita_azione_smistamento per gestione
                        possibilita' di inoltro agli utenti con privilegio
                        ISMITOT.
    005  05/04/2017 SC  Gestione date privilegi
    006  19/04/2017 SC  Il privilegio ASS viene verificato sempre in data odierna
                        perchè il package che costruisce l'interfaccia fa vedere
                        i componenti cui assegnare solo se privilegio ASS è valido OGGI.
    007  06/10/2017 MM  Gestione disabilitazione dell'inoltro se il tipo documento ha
                        sequenza di smistamenti e si è arrivati già all'ultimo passo
                        della sequenza.
    012  27/09/2019 SC  Bug #37160 Modifiche per migliorare performance query.
   ********************************************************************************/
   FUNCTION abilita_azione_smistamento (
      p_id_documento         VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER
   IS
      retval              NUMBER := 0;
      idrifprotocollo     VARCHAR2 (100);
      stato_protocollo    VARCHAR2 (100);
      tipoDocumento       VARCHAR2 (100);
      hasSeqSmistamenti   NUMBER := 0;
      ultimoSmistamento   VARCHAR2 (255) := ' ';

      dep_privilegio      VARCHAR2 (100) := 'ISMI';
      utenteinstruttura   NUMBER := 0;
      dep_data_rif        DATE;
   BEGIN
      utenteinstruttura :=
         AG_UTILITIES.inizializza_utente (p_utente => p_utente);
      stato_protocollo :=
         NVL (f_valore_campo (p_id_documento, campo_stato_protocollo), 'DP');

      IF utenteinstruttura = 1 AND p_azione = 'SMISTA'
      THEN
         -- A32601.0.0 SC Non verifico se l'unità protocollante è valorizzata,
         -- ma se il documento è protocollato. Fino a quando non è protocollato,
         -- i nuovi smistamenti vengono inseriti da chiuinque abbia ISMI.
         IF stato_protocollo != 'DP'
         THEN
            --A33037.0.0 Se si tratta dell'utente protocollante, può smistare il documento.
            IF p_utente =
                  f_valore_campo (p_id_documento, campo_utente_protocollante)
            THEN
               retval := 1;
            END IF;

            IF retval = 0
            THEN
               dep_data_rif :=
                  NVL (ag_utilities.get_Data_rif_privilegi (p_id_documento),
                       TRUNC (SYSDATE));
               retval :=
                  verifica_per_protocollante (
                     p_id_documento   => p_id_documento,
                     p_privilegio     => dep_privilegio,
                     p_utente         => p_utente);

               -- A32601.0.0 SC Per poter smistare per l'unita protocollante bisogna avere ISMI e CPROT,
               -- coerentemente a come calcola le possibili unita di trasmissione lato java.
               IF retval = 1
               THEN
                  retval :=
                     verifica_per_protocollante (
                        p_id_documento   => p_id_documento,
                        p_privilegio     => 'CPROT',
                        p_utente         => p_utente);
               END IF;
            /*DBMS_OUTPUT.put_line (   'retval dopo verifica_per_protocollante '
                                              || retval
                                             );*/
            END IF;
         ELSE
            -- se non c'è l'unita protocollante il documento non è mai stato salvato quindi basta verifica se l'utente
            -- puo' smistare
            retval :=
               AG_UTILITIES.verifica_privilegio_utente (NULL,
                                                        'ISMITOT',
                                                        p_utente,
                                                        TRUNC (SYSDATE));


            IF retval = 0
            THEN
               retval :=
                  AG_UTILITIES.verifica_privilegio_utente (NULL,
                                                           'ISMI',
                                                           p_utente,
                                                           TRUNC (SYSDATE));
            END IF;
         END IF;
      END IF;

      IF utenteinstruttura = 1 AND retval = 0
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);

         IF p_azione = 'CARICO'
         THEN
            -- A32603.0.0 SC PER LE AZIONI DI CARICO L'UTENTE DEVE AVERE PRIVILEGIO CARICO
            dep_privilegio := 'CARICO';
         END IF;

         IF p_azione = 'INOLTRA'
         THEN
            /* se al protocollo è associata una tipologia di documento con sequenza
               di smistamenti, l'azione inoltra è permessa solo se non si è già
               arrivati all'ultimo ufficio */
            tipoDocumento :=
               f_valore_campo (p_id_documento, campo_tipo_documento);
            --DBMS_OUTPUT.PUT_LINE(' tipoDocumento '||tipoDocumento);
            hasSeqSmistamenti :=
               AG_TIPI_DOCUMENTO_UTILITY.has_sequenza_smistamenti (
                  tipoDocumento);

            --DBMS_OUTPUT.PUT_LINE(' hasSeqSmistamenti '||hasSeqSmistamenti);
            IF hasSeqSmistamenti = 1
            THEN
               ultimoSmistamento :=
                  NVL (
                     AG_TIPI_DOCUMENTO_UTILITY.get_max_uo_smistamento (
                        tipoDocumento),
                     ' ');
            --DBMS_OUTPUT.PUT_LINE(' ultimoSmistamento '||ultimoSmistamento);
            END IF;
         END IF;

         BEGIN
            --A33906.0.0 PER POTER ASSEGNARE CI DEVE ESSERE ALMENO UNA UNITA RICEVENTE APERTA.
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp,
                   ag_abilitazioni_smistamento,
                   seg_smistamenti,
                   documenti dosm,
                   seg_unita
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_unita.progr_unita_organizzativa+0 =
                          ag_priv_utente_tmp.progr_unita
                   AND p_stato_smistamento IS NULL
                   AND seg_smistamenti.stato_smistamento =
                          ag_abilitazioni_smistamento.stato_smistamento
                   AND seg_smistamenti.tipo_smistamento =
                          ag_abilitazioni_smistamento.tipo_smistamento
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND (   ag_priv_utente_tmp.privilegio = dep_privilegio
                        OR NVL (seg_smistamenti.codice_assegnatario, '*') =
                              p_utente)
                   AND ag_abilitazioni_smistamento.azione = p_azione
                   AND ag_abilitazioni_smistamento.aoo =
                          AG_UTILITIES.indiceaoo
                   AND seg_unita.unita =
                          seg_smistamenti.ufficio_smistamento || ''
                   AND seg_unita.codice_amministrazione || '' =
                          seg_smistamenti.codice_amministrazione
                   AND DECODE (p_azione, 'ASSEGNA', seg_unita.al, NULL)
                          IS NULL
                   AND DECODE (
                          p_azione,
                          'INOLTRA', DECODE (
                                        hasSeqSmistamenti,
                                        0, 'OK',
                                        DECODE (
                                           seg_smistamenti.ufficio_smistamento,
                                           ultimoSmistamento, 'KO',
                                           'OK')),
                          'OK') = 'OK'
                   AND NVL (dep_Data_rif, TRUNC (SYSDATE)) <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND (   NVL (p_azione, 'x') <> 'ASSEGNA'
                        OR (    p_azione = 'ASSEGNA'
                            AND (SELECT   AG_UTILITIES.verifica_privilegio_utente (
                                             seg_smistamenti.ufficio_smistamento,
                                             'ASS',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                        + AG_UTILITIES.verifica_privilegio_utente (
                                             NULL,
                                             'ASSTOT',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                   FROM DUAL) > 0))
                   AND ROWNUM = 1
            UNION ALL
            SELECT 1
              FROM ag_priv_utente_tmp,
                   ag_abilitazioni_smistamento,
                   seg_smistamenti,
                   documenti dosm,
                   seg_unita
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_unita.progr_unita_organizzativa+0 =
                          ag_priv_utente_tmp.progr_unita
                   AND p_stato_smistamento =
                          seg_smistamenti.stato_smistamento
                   AND seg_smistamenti.stato_smistamento =
                          ag_abilitazioni_smistamento.stato_smistamento
                   AND seg_smistamenti.tipo_smistamento =
                          ag_abilitazioni_smistamento.tipo_smistamento
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND (   ag_priv_utente_tmp.privilegio = dep_privilegio
                        OR NVL (seg_smistamenti.codice_assegnatario, '*') =
                              p_utente)
                   AND ag_abilitazioni_smistamento.azione = p_azione
                   AND ag_abilitazioni_smistamento.aoo =
                          AG_UTILITIES.indiceaoo
                   AND seg_unita.unita =
                          seg_smistamenti.ufficio_smistamento || ''
                   AND seg_unita.codice_amministrazione || '' =
                          seg_smistamenti.codice_amministrazione
                   AND DECODE (p_azione, 'ASSEGNA', seg_unita.al, NULL)
                          IS NULL
                   AND DECODE (
                          p_azione,
                          'INOLTRA', DECODE (
                                        hasSeqSmistamenti,
                                        0, 'OK',
                                        DECODE (
                                           seg_smistamenti.ufficio_smistamento,
                                           ultimoSmistamento, 'KO',
                                           'OK')),
                          'OK') = 'OK'
                   AND NVL (dep_Data_rif, TRUNC (SYSDATE)) <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND (   NVL (p_azione, 'x') <> 'ASSEGNA'
                        OR (    p_azione = 'ASSEGNA'
                            AND (SELECT   AG_UTILITIES.verifica_privilegio_utente (
                                             seg_smistamenti.ufficio_smistamento,
                                             'ASS',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                        + AG_UTILITIES.verifica_privilegio_utente (
                                             NULL,
                                             'ASSTOT',
                                             p_utente,
                                             TRUNC (SYSDATE))
                                   FROM DUAL) > 0))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         END;

         integritypackage.LOG ('retval dopo query su smist ' || retval);

         -- Se esiste iter fascicoli, verifica se esiste smistamento attivo per il
         -- fascicolo e il documento non è ubicato altrove
         IF retval = 0
         THEN
            retval := abilita_smist_per_fasc (P_ID_DOCUMENTO, P_UTENTE);
         END IF;

         -- se l'azione è INOLTRA e p_utente ha privilegio ISMITOT valido ad
         -- oggi, consento l'abilitazione.
         IF retval = 0 AND p_azione = 'INOLTRA' AND hasSeqSmistamenti = 0
         THEN
            BEGIN
               SELECT 1
                 INTO retval
                 FROM ag_abilitazioni_smistamento,
                      documenti dosm,
                      seg_smistamenti
                WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                      AND dosm.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = idrifprotocollo
                      AND DECODE (p_stato_smistamento,
                                  NULL, seg_smistamenti.stato_smistamento,
                                  p_stato_smistamento) =
                             seg_smistamenti.stato_smistamento
                      AND seg_smistamenti.stato_smistamento =
                             ag_abilitazioni_smistamento.stato_smistamento
                      AND seg_smistamenti.tipo_smistamento =
                             ag_abilitazioni_smistamento.tipo_smistamento
                      AND ag_abilitazioni_smistamento.azione = p_azione
                      AND ag_abilitazioni_smistamento.aoo = 1
                      AND AG_UTILITIES.verifica_privilegio_utente (
                             NULL,
                             'ISMITOT',
                             p_utente,
                             TRUNC (SYSDATE)) > 0
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;

         --se l'azione è esegui e il documento è assegnato a p_utente,
         -- da ricevere o in carico
         -- consento l'abilitazione.
         IF retval = 0 AND p_azione = 'ESEGUI'
         THEN
            SELECT 1
              INTO retval
              FROM seg_smistamenti, documenti dosm
             WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                   AND dosm.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_smistamenti.stato_smistamento IN ('R', 'C')
                   AND NVL (seg_smistamenti.codice_assegnatario, '*') =
                          p_utente
                   AND ROWNUM = 1;
         END IF;


         --se l'azione è SMISTA e il documento è assegnato a p_utente,
         -- in carico
         -- consento l'abilitazione.
         IF retval = 0 AND p_azione = 'SMISTA'
         THEN
            BEGIN
               SELECT 1
                 INTO retval
                 FROM seg_smistamenti, documenti dosm
                WHERE     dosm.stato_documento NOT IN ('CA', 'RE')
                      AND dosm.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = idrifprotocollo
                      AND seg_smistamenti.stato_smistamento = 'C'
                      AND NVL (seg_smistamenti.codice_assegnatario, '*') =
                             p_utente
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      RETURN retval;
   END abilita_azione_smistamento;

   FUNCTION abilita_azione_smistamento (
      p_cr                   VARCHAR2,
      p_area                 VARCHAR2,
      p_cm                   VARCHAR2,
      p_utente               VARCHAR2,
      p_azione               VARCHAR2,
      p_stato_smistamento    VARCHAR2 := NULL)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER;
   BEGIN
      d_id_documento := gdm_profilo.getdocumento (p_cm, p_area, p_cr);
      RETURN abilita_azione_smistamento (d_id_documento,
                                         p_utente,
                                         p_azione,
                                         p_stato_smistamento);
   EXCEPTION
      WHEN OTHERS
      THEN
         --se non trovo il documento...
         RETURN 0;
   END;

   /*****************************************************************************
    NOME:        get_tipo_smistamento
    DESCRIZIONE: Dati un protocollo e un'unita di trasmissione, stabilisce quale
    tipo smistamento è possibile per quell'unita.
    Il tipo smistamento possibile dipende da
    - lo stato in cui l'unita' di trasmissione ha il documento (da ricevere, in carico.)
    - il tipo di smistamento con cui l'unita ha ricevuto il documento.
    - l'azione che si sta compiendo (SMISTA, INOLTRA)
    - il tipo di documento associato al protocollo (se ha sequenza di smistamenti associata
      oopure no).
    In base ad essi si vede nella tabella AG_ABILITAZIONI_SMISTAMENTO quali tipi di smistamento sono generabili,
    se sono piu' di uno viene selezionato quello del tipo smistamento piu' importante
    (che è nella tabella ag_tipi_smistamento).


   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_unita_trasmissione VARCHAR2 codice dell'unita che sta creando un nuovo smistamento.
         p_azione ('SMISTA', 'INOLTRA')
   RITORNO:  TIPO_SMISTAMENTO possibile, null se non ce n'è nessuno.
    Rev.  Data       Autore  Descrizione.
    00    20/06/2007  SC  Prima emissione.
    01    05/04/2017  SC  Gestione date privilegi
    007   25/09/2017  MM      Disabilitazione ripudio smistamento se il tipo documento ha
                            sequenza di smistamenti e si è al primo passo della sequenza.
   ********************************************************************************/
   FUNCTION get_tipo_smistamento (p_id_documento          VARCHAR2,
                                  p_utente                VARCHAR2,
                                  p_unita_trasmissione    VARCHAR2,
                                  p_azione                VARCHAR2)
      RETURN VARCHAR2
   IS
      retval                VARCHAR2 (100);
      idrifprotocollo       VARCHAR2 (100);
      tipoDocumento         VARCHAR2 (100);
      hasSeqSmistamenti     NUMBER := 0;
      tipoSmistGenerabile   VARCHAR2 (100);
   BEGIN
      retval := AG_UTILITIES.inizializza_utente (p_utente => p_utente);
      idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
      tipoDocumento := f_valore_campo (p_id_documento, campo_tipo_documento);
      hasSeqSmistamenti :=
         AG_TIPI_DOCUMENTO_UTILITY.has_sequenza_smistamenti (tipoDocumento);

      /*Dato che in casi particolari ci potrebbe essere piu' di uno smistamento
      per l'utente e l'unita di trasmissione passati, il tipo_smistamento possibile
      è quello associato al tipo_smistamento di partenza piu' importante
      (l'importanza è in AG_TIPI_SMISTAMENTO).
      */
      FOR tipi_smistamento
         IN (  SELECT ag_abilitazioni_smistamento.tipo_smistamento_generabile
                 FROM seg_smistamenti,
                      documenti docu,
                      ag_priv_utente_tmp,
                      ag_abilitazioni_smistamento,
                      ag_tipi_smistamento
                WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                      AND docu.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = idrifprotocollo
                      AND seg_smistamenti.ufficio_smistamento =
                             ag_priv_utente_tmp.unita
                      AND seg_smistamenti.stato_smistamento =
                             ag_abilitazioni_smistamento.stato_smistamento
                      AND seg_smistamenti.tipo_smistamento =
                             ag_abilitazioni_smistamento.tipo_smistamento
                      AND ag_priv_utente_tmp.utente = p_utente
                      AND ag_utilities.get_Data_rif_privilegi (p_id_documento) <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND ag_abilitazioni_smistamento.azione = p_azione
                      AND ag_abilitazioni_smistamento.aoo =
                             AG_UTILITIES.indiceaoo
                      AND ag_tipi_smistamento.aoo =
                             ag_abilitazioni_smistamento.aoo
                      AND ag_tipi_smistamento.tipo_smistamento =
                             ag_abilitazioni_smistamento.tipo_smistamento
             ORDER BY ag_tipi_smistamento.importanza)
      LOOP
         tipoSmistGenerabile := tipi_smistamento.tipo_smistamento_generabile;

         IF hasSeqSmistamenti = 0 OR tipoSmistGenerabile <> 'COMPETENZA'
         THEN
            retval := tipoSmistGenerabile;
            EXIT;
         END IF;
      END LOOP;

      RETURN retval;
   END get_tipo_smistamento;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per
    unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere un ruolo con privilegio
    VS / VSR o, per documenti riservati, deve essere assegnatario del documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
         p_verifica_esistenza_attivita indica se va verificato che esista attività jsuite.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
           15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
    00    20/05/2009  SC  A32603.0.0 Verifica l'esistenza dell'attivita jsuite solo se richiesto.
    01    05/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER,
                       p_verifica_assegnazione          NUMBER,
                       p_unita_ricevente                VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
      exectype_carico      VARCHAR2 (100) := 'ESECUZIONE';
      stato_pr             VARCHAR2 (10);
      dep_Data_rif         DATE;
   BEGIN
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := AG_UTILITIES.inizializza_utente (p_utente => p_utente);
      stato_pr :=
         NVL (f_valore_campo (p_id_documento, campo_stato_protocollo), 'DP');

      IF continua = 1 AND stato_pr NOT IN ('AN')
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
         riservato := is_riservato (p_id_documento);
         dep_Data_rif := AG_UTILITIES.get_Data_rif_privilegi (p_id_documento);

         --f_valore_campo (p_id_documento, campo_riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            FOR s
               IN (SELECT DISTINCT
                             docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido,
                          ag_priv_utente_tmp
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.ufficio_smistamento =
                                 ag_priv_utente_tmp.unita
                          AND seg_smistamenti.ufficio_smistamento || '' =
                                 NVL (p_unita_ricevente,
                                      seg_smistamenti.ufficio_smistamento)
                          AND seg_smistamenti.stato_smistamento =
                                 AG_UTILITIES.smistamento_in_carico
                          AND (   p_verifica_assegnazione = 0
                               OR seg_smistamenti.codice_assegnatario IS NULL
                               OR seg_smistamenti.codice_assegnatario =
                                     p_utente)
                          AND ag_priv_utente_tmp.utente = p_utente
                          AND ag_priv_utente_tmp.privilegio =
                                 'VS' || suffissoprivilegio
                          AND dep_Data_rif <=
                                 NVL (ag_priv_utente_tmp.al,
                                      TO_DATE (3333333, 'j'))
                   UNION ALL
                   SELECT DISTINCT
                             docu.area
                          || '@'
                          || tido.nome
                          || '@'
                          || docu.codice_richiesta
                             triade
                     FROM seg_smistamenti,
                          documenti docu,
                          tipi_documento tido /*,
                           ag_priv_utente_tmp*/
                    WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                          AND docu.id_documento =
                                 seg_smistamenti.id_documento
                          AND docu.id_tipodoc = tido.id_tipodoc
                          AND seg_smistamenti.idrif = idrifprotocollo
                          AND seg_smistamenti.stato_smistamento =
                                 AG_UTILITIES.smistamento_in_carico
                          AND seg_smistamenti.codice_assegnatario = p_utente
                          AND p_verifica_assegnazione = 1)
            LOOP
               IF p_verifica_esistenza_attivita = 1
               THEN
                  retval :=
                     test_attivita_in_attesa (s.triade, exectype_carico);

                  IF retval = 0
                  THEN
                     EXIT;
                  END IF;
               ELSE
                  retval := 1;
               END IF;
            END LOOP;
         --  DBMS_OUTPUT.put_line ('FINE SELECT ' || retval);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         --  DBMS_OUTPUT.put_line ('EXCEPTION ' || retval);
         END;

         IF riservato = 'Y' AND retval = 0
         THEN
            BEGIN
               FOR sriservati
                  IN (SELECT DISTINCT
                                docu.area
                             || '@'
                             || tido.nome
                             || '@'
                             || docu.codice_richiesta
                                triade
                        FROM seg_smistamenti,
                             documenti docu,
                             tipi_documento tido,
                             ag_priv_utente_tmp
                       WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                             AND docu.id_documento =
                                    seg_smistamenti.id_documento
                             AND docu.id_tipodoc = tido.id_tipodoc
                             AND seg_smistamenti.idrif = idrifprotocollo
                             AND seg_smistamenti.stato_smistamento = 'C'
                             AND seg_smistamenti.ufficio_smistamento =
                                    ag_priv_utente_tmp.unita
                             AND seg_smistamenti.codice_assegnatario =
                                    ag_priv_utente_tmp.utente
                             AND ag_priv_utente_tmp.utente = p_utente
                             AND dep_Data_rif <=
                                    NVL (ag_priv_utente_tmp.al,
                                         TO_DATE (3333333, 'j')))
               LOOP
                  IF p_verifica_esistenza_attivita = 1
                  THEN
                     retval :=
                        test_attivita_in_attesa (sriservati.triade,
                                                 exectype_carico);

                     IF retval = 0
                     THEN
                        EXIT;
                     END IF;
                  ELSE
                     retval := 1;
                  END IF;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('FINE METODO ' || retval);
      RETURN retval;
   END in_carico;

   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER,
                       p_verifica_assegnazione          NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN in_carico (p_id_documento,
                        p_utente,
                        p_verifica_esistenza_attivita,
                        p_verifica_assegnazione,
                        NULL);
   END in_carico;

   FUNCTION in_carico (p_id_documento                   VARCHAR2,
                       p_utente                         VARCHAR2,
                       p_verifica_esistenza_attivita    NUMBER)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
      exectype_carico      VARCHAR2 (100) := 'ESECUZIONE';
      stato_pr             VARCHAR2 (10);
   BEGIN
      RETURN in_carico (
                p_id_documento                  => p_id_documento,
                p_utente                        => p_utente,
                p_verifica_esistenza_attivita   => p_verifica_esistenza_attivita,
                p_verifica_assegnazione         => 1);
   END in_carico;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere un ruolo con privilegio
    VS / VSR o, per documenti riservati, deve essere assegnatario del documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
           15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
    00    20/05/2009  SC  A32603.0.0 Verifica l'esistenza dell'attivita jsuite.
   ********************************************************************************/
   FUNCTION in_carico (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      RETURN in_carico (p_id_documento, p_utente, 1);
   END in_carico;

   /*****************************************************************************
    NOME:        in_carico
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato in carico per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION in_carico (p_area                VARCHAR2,
                       p_modello             VARCHAR2,
                       p_codice_richiesta    VARCHAR2,
                       p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;
      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         AG_UTILITIES.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval := in_carico (iddocumento, p_utente);
      END IF;

      RETURN retval;
   END in_carico;

   /*****************************************************************************
    NOME:        eseguito
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato eseguito per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION eseguito (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;
      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         AG_UTILITIES.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval :=
            eseguito (p_id_documento            => TO_CHAR (iddocumento),
                      p_utente                  => p_utente,
                      p_unita_ricevente         => NULL,
                      p_verifica_assegnazione   => 1);
      END IF;

      RETURN retval;
   END eseguito;

   FUNCTION eseguito (p_area                VARCHAR2,
                      p_modello             VARCHAR2,
                      p_codice_richiesta    VARCHAR2,
                      p_utente              VARCHAR2,
                      p_unita_ricevente     VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;
      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         AG_UTILITIES.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval := eseguito (iddocumento, p_utente, p_unita_ricevente);
      END IF;

      RETURN retval;
   END eseguito;

   /*****************************************************************************
    NOME:        eseguito
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato eseguito per unita cui p_utente appartiene.
    Inoltre p_utente deve avere diritti in lettura sul documento, cioè deve avere un ruolo con privilegio
    VS / VSR o, per documenti riservati, deve essere assegnatario del documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
            15/01/2008 SC Faccio in modo che risulti da ricevere
          per p_utente solo se non assegnato o assegnato a p_utente.
    01    05/04/2017  SC  Gestione date privilegi
   ********************************************************************************/
   FUNCTION eseguito (p_id_documento             VARCHAR2,
                      p_utente                   VARCHAR2,
                      p_unita_ricevente          VARCHAR2 := NULL,
                      p_verifica_assegnazione    NUMBER := 1)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
      dep_data_rif         DATE;
   BEGIN
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := AG_UTILITIES.inizializza_utente (p_utente => p_utente);

      IF continua = 1
      THEN
         idrifprotocollo := f_valore_campo (p_id_documento, campo_idrif);
         riservato := is_riservato (p_id_documento);
         dep_data_rif := AG_UTILITIES.get_Data_rif_privilegi (p_id_documento);

         --f_valore_campo (p_id_documento, campo_riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            SELECT 1
              INTO retval
              FROM seg_smistamenti, documenti docu, ag_priv_utente_tmp
             WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                   AND docu.id_documento = seg_smistamenti.id_documento
                   AND seg_smistamenti.idrif = idrifprotocollo
                   AND seg_smistamenti.ufficio_smistamento =
                          ag_priv_utente_tmp.unita
                   AND seg_smistamenti.ufficio_smistamento || '' =
                          NVL (p_unita_ricevente,
                               seg_smistamenti.ufficio_smistamento)
                   AND seg_smistamenti.stato_smistamento =
                          AG_UTILITIES.smistamento_eseguito
                   AND (   seg_smistamenti.codice_assegnatario IS NULL
                        OR seg_smistamenti.codice_assegnatario = p_utente)
                   AND ag_priv_utente_tmp.utente = p_utente
                   AND ag_priv_utente_tmp.privilegio =
                          'VS' || suffissoprivilegio
                   AND dep_data_rif <=
                          NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         --DBMS_OUTPUT.put_line ('FINE SELECT ' || retval);
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         --DBMS_OUTPUT.put_line ('EXCEPTION ' || retval);
         END;

         IF riservato = 'Y' AND retval = 0
         THEN
            BEGIN
               SELECT 1
                 INTO retval
                 FROM seg_smistamenti, documenti docu, ag_priv_utente_tmp
                WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                      AND docu.id_documento = seg_smistamenti.id_documento
                      AND seg_smistamenti.idrif = idrifprotocollo
                      AND seg_smistamenti.stato_smistamento =
                             AG_UTILITIES.smistamento_eseguito
                      AND seg_smistamenti.ufficio_smistamento =
                             ag_priv_utente_tmp.unita
                      AND seg_smistamenti.codice_assegnatario =
                             ag_priv_utente_tmp.utente
                      AND ag_priv_utente_tmp.utente = p_utente
                      AND dep_data_rif <=
                             NVL (ag_priv_utente_tmp.al,
                                  TO_DATE (3333333, 'j'))
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  retval := 0;
            END;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line ('FINE METODO ' || retval);
      RETURN retval;
   END eseguito;

   FUNCTION eseguito (p_id_documento VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval               NUMBER := 0;
      idrifprotocollo      VARCHAR2 (100);
      continua             NUMBER;
      riservato            VARCHAR2 (1) := 'N';
      suffissoprivilegio   VARCHAR2 (1) := '';
   BEGIN
      RETURN eseguito (p_id_documento            => p_id_documento,
                       p_utente                  => p_utente,
                       p_unita_ricevente         => NULL,
                       p_verifica_assegnazione   => 1);
   END eseguito;

   /*****************************************************************************
    NOME:        da_ricevere
    DESCRIZIONE: Verifica se il documento ha uno smistamento in stato da ricevere
                 per unita cui p_utente appartiene.
                 Inoltre p_utente deve avere diritti in lettura sul documento.
   INPUT  p_id_documento varchar2: chiave identificativa del documento.
         p_utente varchar2: utente che richiede di leggere il documento.
   RITORNO:  1 se l'utente ha diritti in lettura, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION da_ricevere (p_area                VARCHAR2,
                         p_modello             VARCHAR2,
                         p_codice_richiesta    VARCHAR2,
                         p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      iddocumento   documenti.id_documento%TYPE;
      retval        NUMBER := 0;
   BEGIN
      iddocumento :=
         AG_UTILITIES.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);

      IF iddocumento IS NOT NULL
      THEN
         retval :=
            da_ricevere (p_id_documento => iddocumento, p_utente => p_utente);
      END IF;

      RETURN retval;
   END da_ricevere;

   /*****************************************************************************
 NOME:        RESETTA
 DESCRIZIONE: Annulla la variabile globale g_diritto utilizzata per verificare le
 competenze su jatti
INPUT

 Rev.  Data       Autore  Descrizione.
 00    06/06/2008  SC  Prima emissione. A27764.0.0
********************************************************************************/
   PROCEDURE resetta
   IS
   BEGIN
      g_diritto := NULL;
   END resetta;

   /*****************************************************************************
 NOME:        SET_TRUE
 DESCRIZIONE: Mette a 1 variabile globale g_diritto utilizzata per verificare le
 competenze su jatti
INPUT

 Rev.  Data       Autore  Descrizione.
 00    06/06/2008  SC  Prima emissione. A27764.0.0
********************************************************************************/
   PROCEDURE set_true
   IS
   BEGIN
      g_diritto := 1;
   END set_true;

   /*****************************************************************************
 NOME:        SET_FALSE
 DESCRIZIONE: Mette a 0 variabile globale g_diritto utilizzata per verificare le
 competenze su jatti
INPUT

 Rev.  Data       Autore  Descrizione.
 00    06/06/2008  SC  Prima emissione. A27764.0.0
********************************************************************************/
   PROCEDURE set_false
   IS
   BEGIN
      g_diritto := 0;
   END set_false;

   /*****************************************************************************
  NOME:        check_abilita_ripudio
  DESCRIZIONE: Verifica se l'utente ha possibilita di ripudiare lo smistamento da ricevere.
  ci deve essere un solo smistamento da ricevere per l'utente che sta aprendo il documento
  o più smistamenti da ricevere ma tutti con la stessa unità di trasmissione.

 INPUT  p_id_documento varchar2: chiave identificativa del documento.
       p_utente varchar2: utente che richiede di leggere il documento.
 RITORNO:  1 se l'utente ha diritti di ripudio , 0 altrimenti.
  Rev.  Data       Autore  Descrizione.
  00    28/01/2009  AM      Prima emissione.
  01    05/04/2017  SC      Gestione date privilegi
  007   25/09/2017  MM      Disabilitazione ripudio smistamento se il tipo documento ha
                            sequenza di smistamenti e si è al primo passo della sequenza.
 ********************************************************************************/
   FUNCTION check_abilita_ripudio (p_area                VARCHAR2,
                                   p_modello             VARCHAR2,
                                   p_codice_richiesta    VARCHAR2,
                                   p_utente              VARCHAR2)
      RETURN NUMBER
   IS
      retval                     NUMBER := 0;
      idrifprotocollo            VARCHAR2 (100);
      tipoDocumento              VARCHAR2 (100);
      riservato                  VARCHAR2 (1) := 'N';
      suffissoprivilegio         VARCHAR2 (1);
      continua                   NUMBER := 0;
      exectype_ricevimento       VARCHAR2 (100) := 'VISIONE';
      ufficio_trasmissione       seg_unita.unita%TYPE := '';
      iddocumento                documenti.id_documento%TYPE;
      dep_Data_rif               DATE;
      has_sequenza_smistamenti   NUMBER := 0;
   BEGIN
      iddocumento :=
         AG_UTILITIES.get_id_documento (p_area,
                                        p_modello,
                                        p_codice_richiesta);
      --VERIFICA SE L'UTENTE FA PARTE DI QUALCHE UNITA
      continua := AG_UTILITIES.inizializza_utente (p_utente => p_utente);

      IF continua = 1
      THEN
         -- se al protocollo è associata una tipologia di documento con sequenza
         -- di smistamenti e trattasi dello smistamento con sequenza minore, il
         -- ripudio non deve essere permesso
         tipoDocumento := f_valore_campo (iddocumento, campo_tipo_documento);

         has_sequenza_smistamenti :=
            AG_TIPI_DOCUMENTO_UTILITY.has_sequenza_smistamenti (
               tipoDocumento);

         idrifprotocollo := f_valore_campo (iddocumento, campo_idrif);
         riservato := is_riservato (iddocumento);
         dep_Data_rif := AG_UTILITIES.get_Data_rif_privilegi (iddocumento);

         --f_valore_campo (iddocumento, campo_riservato);

         --DBMS_OUTPUT.put_line ('IDRIF ' || idrifprotocollo || ' riservato ' || riservato);
         IF riservato = 'Y'
         THEN
            suffissoprivilegio := 'R';
         END IF;

         BEGIN
            FOR unita
               IN (SELECT a.uftr ufficio_smistamento, a.tipo_smistamento
                     FROM (SELECT DISTINCT
                                  seg_smistamenti.ufficio_smistamento AS uftr,
                                  seg_smistamenti.tipo_smistamento
                             FROM seg_smistamenti,
                                  documenti docu,
                                  tipi_documento tido,
                                  ag_priv_utente_tmp
                            WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                                  AND docu.id_documento =
                                         seg_smistamenti.id_documento
                                  AND docu.id_tipodoc = tido.id_tipodoc
                                  AND seg_smistamenti.idrif = idrifprotocollo
                                  AND seg_smistamenti.ufficio_smistamento =
                                         ag_priv_utente_tmp.unita
                                  AND ag_priv_utente_tmp.utente = p_utente
                                  AND dep_Data_rif <=
                                         NVL (ag_priv_utente_tmp.al,
                                              TO_DATE (3333333, 'j'))
                                  AND seg_smistamenti.stato_smistamento = 'R'
                                  AND (   seg_smistamenti.codice_assegnatario =
                                             p_utente
                                       OR seg_smistamenti.codice_assegnatario
                                             IS NULL)
                           UNION
                           SELECT DISTINCT
                                  seg_smistamenti.ufficio_smistamento AS uftr,
                                  seg_smistamenti.tipo_smistamento
                             FROM seg_smistamenti,
                                  documenti docu,
                                  tipi_documento tido,
                                  ag_priv_utente_tmp priv_visu,
                                  ag_priv_utente_tmp priv_carico
                            WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                                  AND docu.id_documento =
                                         seg_smistamenti.id_documento
                                  AND docu.id_tipodoc = tido.id_tipodoc
                                  AND seg_smistamenti.idrif = idrifprotocollo
                                  AND seg_smistamenti.ufficio_smistamento =
                                         priv_visu.unita
                                  AND seg_smistamenti.ufficio_smistamento =
                                         priv_carico.unita
                                  AND seg_smistamenti.stato_smistamento = 'R'
                                  AND priv_visu.utente = p_utente
                                  AND priv_carico.utente = p_utente
                                  AND (   seg_smistamenti.codice_assegnatario =
                                             p_utente
                                       OR seg_smistamenti.codice_assegnatario
                                             IS NULL)
                                  AND priv_visu.privilegio =
                                         'VS' || suffissoprivilegio
                                  AND priv_carico.privilegio = 'CARICO'
                                  AND dep_Data_rif <=
                                         NVL (priv_visu.al,
                                              TO_DATE (3333333, 'j'))
                                  AND dep_Data_rif <=
                                         NVL (priv_carico.al,
                                              TO_DATE (3333333, 'j'))) a)
            LOOP
               IF    has_sequenza_smistamenti = 0
                  OR unita.tipo_smistamento = 'CONOSCENZA'
               THEN
                  retval := 1;
                  EXIT;
               ELSE
                  IF NVL (
                        AG_TIPI_DOCUMENTO_UTILITY.get_min_uo_smistamento (
                           tipoDocumento),
                        ' ') <> unita.ufficio_smistamento
                  THEN
                     retval := 1;
                     EXIT;
                  END IF;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               retval := 0;
         --DBMS_OUTPUT.put_line ('EXCEPTION ' || retval);
         END;
      END IF;

      RETURN retval;
   --DBMS_OUTPUT.put_line ('FINE METODO ' || retval);
   END;

   FUNCTION get_utenti_notifica_ripudio (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2,
                                         id_smistamenti        VARCHAR2)
      RETURN VARCHAR2
   IS
      d_componenti         VARCHAR2 (4000) := '@';
      dep_id_smistamenti   VARCHAR2 (32000);
      dep_id_smistamento   VARCHAR2 (4000);
      dep_id_documento     NUMBER;
      dep_utente           ad4_utenti.utente%TYPE;
   BEGIN
      d_componenti :=
         get_componenti_unita_azione (p_area,
                                      p_codice_modello,
                                      p_codice_richiesta,
                                      p_codice_unita,
                                      p_azione);



      dep_id_smistamenti := id_smistamenti;

      --id_smistamenti: lista id_doc smistamenti separati da virgola
      WHILE NVL (dep_id_smistamenti, ',') <> ','
      LOOP
         dep_id_smistamento :=
            TO_NUMBER (afc.get_substr (dep_id_smistamenti, ','));

         IF NVL (dep_id_smistamento, 0) != 0
         THEN
            dep_utente :=
               f_valore_campo (dep_id_smistamento, 'UTENTE_TRASMISSIONE');

            IF INSTR (d_componenti, '@' || dep_utente || '@') = 0
            THEN
               d_componenti := d_componenti || dep_utente || '@';

               --DEVO RIABILITARE LO SMISTAMENTO PER CONSENTIRE DI SMISTARE NUOVAMENTE
               DECLARE
                  dep_da_riesumare        NUMBER;
                  dep_dal                 DATE;
                  dep_idrif               VARCHAR2 (32000);
                  dep_descrizione_unita   seg_unita.nome%TYPE;
               BEGIN
                  SELECT smistamento_dal, idrif, des_ufficio_smistamento
                    INTO dep_dal, dep_idrif, dep_descrizione_unita
                    FROM seg_smistamenti
                   WHERE id_documento = dep_id_smistamento;

                  SELECT MAX (id_documento)
                    INTO dep_da_riesumare
                    FROM seg_smistamenti s1
                   WHERE     ufficio_smistamento = p_codice_unita
                         AND stato_smistamento = 'F'
                         AND idrif = dep_idrif
                         AND smistamento_dal < dep_dal
                         AND NOT EXISTS
                                (SELECT 1
                                   FROM seg_smistamenti s2
                                  WHERE     s2.ufficio_trasmissione =
                                               s1.ufficio_smistamento
                                        AND s2.stato_smistamento =
                                               s1.stato_smistamento
                                        AND s1.smistamento_dal >
                                               s2.smistamento_dal
                                        AND s1.idrif = s2.idrif
                                        AND s2.smistamento_dal < dep_dal);

                  UPDATE seg_smistamenti
                     SET stato_smistamento = 'E',
                         note =
                               DECODE (note, NULL, '', note || CHR (10))
                            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                            || ' Smistamento riattivato automaticamente per gestione rifiuto da parte di '
                            || dep_descrizione_unita
                   WHERE id_documento = dep_da_riesumare;

                  COMMIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END IF;
      END LOOP;

      RETURN d_componenti;
   END;

   /*****************************************************************************
   NOME:        get_componenti_unita_per_azione
   DESCRIZIONE: ritorna la lista dei componenti di una data unita che
              hanno la possibilita' di compiere una azione in particolare

  INPUT  p_area               VARCHAR2,
        p_codice_modello     VARCHAR2,
        p_codice_richiesta   VARCHAR2, codice richiesta del protocollo
        p_codice_unita       VARCHAR2, codice unita della unita' da cui ottenere i componenti
        p_azione             VARCHAR2  azione da valutare per ogni utente dell'unita
  RITORNO:  lista dei componenti di una unita che hanno diritti su una azione in particolare
   Rev.  Data       Autore  Descrizione.
   00    20302/2009  AM  Prima emissione.
  ********************************************************************************/
   FUNCTION get_componenti_unita_azione (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2)
      RETURN VARCHAR
   IS
      componentiunita   afc.t_ref_cursor;
      retval            NUMBER := 0;
      d_componenti      VARCHAR2 (4000) := '@';
      d_ni              NUMBER;
      d_descr           VARCHAR2 (50);
      d_utente          ag_priv_utente_tmp.utente%TYPE;
      dep_aoo_index     NUMBER;
      dep_ottica        VARCHAR2 (1000);
   BEGIN
      dep_aoo_index := AG_UTILITIES.get_defaultaooindex ();
      dep_ottica := AG_UTILITIES.get_ottica_aoo (dep_aoo_index);
      componentiunita :=
         so4_ags_pkg.unita_get_componenti_ord (
            p_codice_uo   => p_codice_unita,
            p_ottica      => dep_ottica);

      IF componentiunita%ISOPEN
      THEN
         LOOP
            FETCH componentiunita INTO d_ni, d_descr, d_utente;

            EXIT WHEN componentiunita%NOTFOUND;
            retval :=
               abilita_azione_smistamento (p_codice_richiesta,
                                           p_area,
                                           p_codice_modello,
                                           d_utente,
                                           p_azione);

            IF (retval = 1)
            THEN
               d_componenti := d_componenti || d_utente || '@';
            END IF;
         END LOOP;

         CLOSE componentiunita;
      END IF;

      RETURN d_componenti;
   END;

   FUNCTION get_smistamenti_in_carico (p_idrif     VARCHAR2,
                                       p_utente    VARCHAR2,
                                       p_unita     VARCHAR2 DEFAULT NULL,
                                       p_azione    VARCHAR2 DEFAULT 'ESEGUI')
      RETURN afc.t_ref_cursor
   IS
      dep_id_documento   documenti.id_documento%TYPE;
      suffisso_r         VARCHAR2 (1) := '';
      smis               afc.t_ref_cursor;
      dep_data_rif       DATE;
   BEGIN
      dep_id_documento := AG_UTILITIES.get_documento_per_idrif (p_idrif);
      dep_data_rif := ag_utilities.get_Data_rif_privilegi (dep_id_documento);

      IF is_riservato (dep_id_documento) = 'Y'
      THEN
         suffisso_r := 'R';
      END IF;

      OPEN smis FOR
         SELECT smis.id_documento, 'VALIDA'
           FROM seg_smistamenti smis, documenti docu    --, ag_priv_utente_tmp
          WHERE     docu.id_documento = smis.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.idrif = p_idrif
                AND smis.codice_assegnatario = p_utente
                --AND smis.ufficio_smistamento = ag_priv_utente_tmp.unita
                --AND utente = smis.codice_assegnatario
                --AND ag_priv_utente_tmp.al IS NULL
                AND smis.ufficio_smistamento =
                       NVL (p_unita, smis.ufficio_smistamento)
                AND smis.stato_smistamento = 'C'
         /*UNION

         SELECT smis.id_documento, 'SCADUTA'
           FROM seg_smistamenti smis, documenti docu, ag_priv_utente_tmp
          WHERE     docu.id_documento = smis.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.idrif = p_idrif
                AND smis.codice_assegnatario = p_utente
                AND smis.ufficio_smistamento = ag_priv_utente_tmp.unita
                AND smis.codice_assegnatario = ag_priv_utente_tmp.utente
                AND ag_priv_utente_tmp.al IS NOT NULL
                AND smis.ufficio_smistamento =
                       NVL (p_unita, smis.ufficio_smistamento)
                AND smis.stato_smistamento = 'C'*/
         UNION
         SELECT smis.id_documento, 'VALIDA'
           FROM seg_smistamenti smis, documenti docu, ag_priv_utente_tmp
          WHERE     docu.id_documento = smis.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.idrif = p_idrif
                AND smis.codice_assegnatario IS NULL
                AND smis.ufficio_smistamento = ag_priv_utente_tmp.unita
                AND dep_data_rif <=
                       NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j'))
                AND ag_priv_utente_tmp.privilegio = 'VS' || suffisso_r
                AND smis.ufficio_smistamento =
                       NVL (p_unita, smis.ufficio_smistamento)
                AND smis.stato_smistamento = 'C' /*UNION

                                                 SELECT smis.id_documento, 'SCADUTA'
                                                   FROM seg_smistamenti smis, documenti docu, ag_priv_utente_tmp
                                                  WHERE     docu.id_documento = smis.id_documento
                                                        AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                                                        AND smis.idrif = p_idrif

                                                        AND smis.codice_assegnatario IS NULL
                                                        AND smis.ufficio_smistamento = ag_priv_utente_tmp.unita
                                                        AND ag_priv_utente_tmp.al IS NOT NULL
                                                        AND ag_priv_utente_tmp.privilegio = 'VS' || suffisso_r
                                                        AND smis.ufficio_smistamento =

                                                               NVL (p_unita, smis.ufficio_smistamento)
                                                        AND smis.stato_smistamento = 'C'*/
                                                ;


      RETURN smis;
   END;

   FUNCTION get_smistamenti_da_ricevere (
      p_idrif     VARCHAR2,
      p_utente    VARCHAR2,
      p_unita     VARCHAR2 DEFAULT NULL,
      p_azione    VARCHAR2 DEFAULT 'ESEGUI')
      RETURN afc.t_ref_cursor
   IS
      dep_id_documento   documenti.id_documento%TYPE;
      suffisso_r         VARCHAR2 (1) := '';
      smis               afc.t_ref_cursor;
      dep_data_rif       DATE;
   BEGIN
      dep_id_documento := AG_UTILITIES.get_protocollo_per_idrif (p_idrif);
      dep_data_rif := ag_utilities.get_Data_rif_privilegi (dep_id_documento);

      IF is_riservato (dep_id_documento) = 'Y'
      THEN
         suffisso_r := 'R';
      END IF;

      OPEN smis FOR
         SELECT smis.id_documento, 'VALIDA'
           FROM seg_smistamenti smis, documenti docu
          --, ag_priv_utente_tmp
          WHERE     docu.id_documento = smis.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.idrif = p_idrif
                AND smis.codice_assegnatario = p_utente
                --AND smis.ufficio_smistamento = ag_priv_utente_tmp.unita
                --AND utente = smis.codice_assegnatario
                --AND ag_priv_utente_tmp.al IS NULL
                AND smis.ufficio_smistamento =
                       NVL (p_unita, smis.ufficio_smistamento)
                AND smis.stato_smistamento = 'R'
         /*UNION

         SELECT smis.id_documento, 'SCADUTA'

           FROM seg_smistamenti smis
              , documenti docu
              --, ag_priv_utente_tmp
          WHERE     docu.id_documento = smis.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.idrif = p_idrif
                AND smis.codice_assegnatario = p_utente
                --AND smis.ufficio_smistamento = ag_priv_utente_tmp.unita
                --AND smis.codice_assegnatario = ag_priv_utente_tmp.utente
                --AND ag_priv_utente_tmp.al IS NOT NULL
                AND smis.ufficio_smistamento =
                       NVL (p_unita, smis.ufficio_smistamento)
                AND smis.stato_smistamento = 'R'*/
         UNION
         SELECT smis.id_documento, 'VALIDA'
           FROM seg_smistamenti smis,
                documenti docu,
                ag_priv_utente_tmp priv_vs,
                ag_priv_utente_tmp priv_carico
          WHERE     docu.id_documento = smis.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND smis.idrif = p_idrif
                AND smis.codice_assegnatario IS NULL
                AND smis.ufficio_smistamento = priv_vs.unita
                AND dep_data_rif <= NVL (priv_vs.al, TO_DATE (3333333, 'j')) -- IS NULL
                AND priv_vs.privilegio = 'VS' || suffisso_r
                AND priv_vs.utente = p_utente
                AND smis.ufficio_smistamento = priv_carico.unita
                AND dep_data_rif <=
                       NVL (priv_carico.al, TO_DATE (3333333, 'j'))
                --AND priv_carico.al IS NULL

                AND priv_carico.privilegio = 'CARICO'
                AND priv_carico.utente = p_utente
                AND smis.ufficio_smistamento =
                       NVL (p_unita, smis.ufficio_smistamento)
                AND smis.stato_smistamento = 'R' /*UNION

                                                 SELECT smis.id_documento, 'SCADUTA'
                                                   FROM seg_smistamenti smis
                                                      , documenti docu
                                                      , ag_priv_utente_tmp priv_vs



                                                      , ag_priv_utente_tmp priv_carico
                                                  WHERE     docu.id_documento = smis.id_documento
                                                        AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                                                        AND smis.idrif = p_idrif

                                                        AND smis.codice_assegnatario IS NULL
                                                        AND smis.ufficio_smistamento = priv_vs.progr_unita
                                                        AND priv_vs.al IS NOT NULL

                                                        AND priv_vs.privilegio = 'VS' || suffisso_r
                                                        AND priv_vs.utente = p_utente

                                                        AND smis.ufficio_smistamento = priv_carico.unita
                                                        AND priv_carico.al IS NULL

                                                        AND priv_carico.privilegio = 'CARICO'
                                                        AND priv_carico.utente = p_utente
                                                        AND smis.ufficio_smistamento =

                                                               NVL (p_unita, smis.ufficio_smistamento)
                                                        AND smis.stato_smistamento = 'R'*/
                                                ;


      RETURN smis;
   END;

   FUNCTION is_da_ricevere_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      p_id_documento   NUMBER;
   BEGIN
      p_id_documento := AG_UTILITIES.get_protocollo_per_idrif (p_idrif);

      IF     da_ricevere (p_id_documento                  => p_id_documento,
                          p_utente                        => p_utente,
                          p_verifica_esistenza_attivita   => 0,
                          p_verifica_assegnazione         => 0) = 0
         AND da_ricevere (p_id_documento                  => p_id_documento,
                          p_utente                        => p_utente,
                          p_verifica_esistenza_attivita   => 0,
                          p_verifica_assegnazione         => 1) = 1
      THEN
         DECLARE
            retval   NUMBER;
         BEGIN
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM ag_priv_utente_tmp
                        WHERE     unita IN (SELECT ufficio_smistamento
                                              FROM seg_smistamenti
                                             WHERE     stato_smistamento =
                                                          'R'
                                                   AND idrif = p_idrif)
                              AND al IS NOT NULL
                              AND utente = p_utente);

            RETURN 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 0;
         END;
      ELSE
         RETURN 0;
      END IF;
   END;

   FUNCTION is_in_carico_solo_per_ass (p_idrif VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      p_id_documento   NUMBER;
   BEGIN
      p_id_documento := AG_UTILITIES.get_protocollo_per_idrif (p_idrif);

      IF     in_carico (p_id_documento                  => p_id_documento,
                        p_utente                        => p_utente,
                        p_verifica_esistenza_attivita   => 0,
                        p_verifica_assegnazione         => 0) = 0
         AND in_carico (p_id_documento                  => p_id_documento,
                        p_utente                        => p_utente,
                        p_verifica_esistenza_attivita   => 0,
                        p_verifica_assegnazione         => 1) = 1
      THEN
         DECLARE
            retval   NUMBER;
         BEGIN
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE EXISTS
                      (SELECT 1
                         FROM ag_priv_utente_tmp
                        WHERE     unita IN (SELECT ufficio_smistamento
                                              FROM seg_smistamenti
                                             WHERE     stato_smistamento =
                                                          'C'
                                                   AND idrif = p_idrif)
                              AND al IS NOT NULL
                              AND utente = p_utente);

            RETURN 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               RETURN 0;
         END;
      ELSE
         RETURN 0;
      END IF;
   END;
END;
/
