--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_PRE20_CON_SO4_AGG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_UTILITIES_PRE20_CON_SO4_AGG
AS
/******************************************************************************
   NAME:       AG_UTILITIES
   PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/10/2006             1. Created this package.
******************************************************************************/
   campo_data_protocollo         VARCHAR2 (50) := 'DATA';
   campo_idrif                   VARCHAR2 (5)  := 'IDRIF';
   campo_tipo_smistamento        VARCHAR2 (50) := 'TIPO_SMISTAMENTO';
   campo_stato_smistamento       VARCHAR2 (50) := 'STATO_SMISTAMENTO';
   campo_stato_protocollo        VARCHAR2 (50) := 'STATO_PR';
   campo_data_carico             VARCHAR2 (50) := 'PRESA_IN_CARICO_DAL';
   campo_unita_carico            VARCHAR2 (50) := 'UFFICIO_SMISTAMENTO';
   campo_unita_trasmissione      VARCHAR2 (50) := 'UFFICIO_TRASMISSIONE';
   campo_assegnatario            VARCHAR2 (50) := 'CODICE_ASSEGNATARIO';
   campo_riservato               VARCHAR2 (50) := 'RISERVATO';
   campo_unita_protocollante     VARCHAR2 (50) := 'UNITA_PROTOCOLLANTE';
   campo_blocco_modifiche        VARCHAR2 (50) := 'BLOCCO_MODIFICHE';
   smistamento_storico           VARCHAR2 (1)  := 'F';
   smistamento_in_carico         VARCHAR2 (1)  := 'C';
   smistamento_eseguito          VARCHAR2 (1)  := 'E';
   smistamento_da_ricevere       VARCHAR2 (1)  := 'R';
   indiceaoo                     VARCHAR2 (10);
   ottica                        VARCHAR2 (18);
   categoriaprotocollo           VARCHAR2 (5)  := 'PROTO';
   categoriadelibere             VARCHAR2 (5)  := 'DELI';
   categoriadetermine            VARCHAR2 (5)  := 'DETE';
   campo_class_cod               VARCHAR2 (50) := 'CLASS_COD';
   campo_class_dal               VARCHAR2 (50) := 'CLASS_DAL';
   campo_anno_fascicolo          VARCHAR2 (50) := 'FASCICOLO_ANNO';
   campo_numero_fascicolo        VARCHAR2 (50) := 'FASCICOLO_NUMERO';
   campo_stato_fascicolo         VARCHAR2 (50) := 'STATO_FASCICOLO';
   stato_corrente                VARCHAR2 (50) := '1';
   stato_deposito                VARCHAR2 (50) := '2';
   stato_storico                 VARCHAR2 (50) := '3';
   utente_superuser_segreteria   VARCHAR2 (8)  := 'RPI';
   privilegio_smistaarea         VARCHAR2 (20) := 'SMISTAAREA';

--   TYPE smistamentorec IS RECORD (
--      id_documento         NUMBER,
--      unita_trasmissione   VARCHAR2 (100),
--      unita_ricevente      VARCHAR2 (100),
--      tipo_smistamento     VARCHAR2 (100),
--      assegnatario         VARCHAR2 (100),
--      ruolo_assegnatario   VARCHAR2 (100)
--   );

   --   TYPE smistamentotab IS TABLE OF smistamentorec
--      INDEX BY BINARY_INTEGER;
   TYPE t_ref_cursor IS REF CURSOR;

--   TYPE unitautenterec IS RECORD (
--      unita   VARCHAR2 (16),
--      ruolo   VARCHAR2 (8)
--   );

   --   TYPE unitautentetab IS TABLE OF unitautenterec
--      INDEX BY BINARY_INTEGER;

   --   TYPE ruolorec IS RECORD (
--      ruolo   VARCHAR2 (8)
--   );

   --   unitaesteseutente           unitautentetab;
   bodyutente                    VARCHAR2 (8);

--   TYPE ruolotab IS TABLE OF ruolorec
--      INDEX BY BINARY_INTEGER;
   FUNCTION ad4_utgr_get_livello (p_utente IN VARCHAR2, p_gruppo IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_indice_aoo (p_codice_amm VARCHAR2, p_codice_aoo VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        GET_PROTOCOLLO_PER_IDRIF.
       DESCRIZIONE: Individua il protocollo con idRif dato.
       INPUT  p_idRif varchar2 idRif del protocollo .
      RITORNO:  id_documento del protocollo con p_idrif.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_protocollo_per_idrif (p_idrif VARCHAR2)
      RETURN NUMBER;

      /*****************************************************************************
       NOME:        get_smistamenti_carico_attuali.
       DESCRIZIONE: Individua i documenti M_SMISTAMENTO per i quali sono unita' riceventi le unita'
       di appartenenza di un utente e non sono smistamenti storici, ma attuali cioe'
    con STATO_SMISTAMENTO = C.
      INPUT  p_idRif varchar2 idRif del protocollo di cui si devono trovare gli smistamenti
            TabUnitaUtente   IN    UnitaUtenteTab   unita alle quali appartien l'utente, se vuota le prende tutte.
   TabSmistamento   IN OUT   smistamentotab   tabella con il risultato della query.
      RITORNO:  SmistamentoTab con i record interessati.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
--   PROCEDURE get_smistamenti_carico_attuali (
--      p_idrif                   VARCHAR2,
--      p_utente         IN       VARCHAR2,
--      tabsmistamento   IN OUT   smistamentotab
--   );

   /*****************************************************************************
       NOME:        GET_ID_DOCUMENTO.
       DESCRIZIONE: Individua il protocollo con idRif dato.
       INPUT  p_idRif varchar2 idRif del protocollo di cui si devono trovare gli smistamenti
            p_utente varchar2   utente per il quale si cercano gli smistamenti
      RITORNO:  SmistamentoTab con i record interessati.
       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_id_documento (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2
   )
      RETURN NUMBER;

   FUNCTION get_ottica_utente (
      p_utente       VARCHAR2,
      p_codice_amm   VARCHAR2,
      p_codice_aoo   VARCHAR2
   )
      RETURN VARCHAR2;

      /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_UTENTE
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio:
   Se specificata l'unita' verifica se l'utente ha un ruolo con il privilegio richiesto nell'unita'.
   INPUT  p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      p_untia  varchar2 codice dell'unita' per la quale p_utente deve avere un ruolo
      con p_privilegio.
   p_unita_ascendenti        NUMBER indica se verificare il privilegio anche sulle unita ascendenti
                                    di p_unita. Se 1 verifica le ascendenti, se 0 no.
            Ha senso solo se p_Unita non e' nulla.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.
    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_privilegio_utente (
      p_unita        VARCHAR2,
      p_privilegio   VARCHAR2,
      p_utente       VARCHAR2
   )
      RETURN NUMBER;

      /*****************************************************************************
    NOME:        ABILITA
    DESCRIZIONE: Funzione per abilitare tutti gli utenti ad una fase.
   INPUT
   RITORNO:  1.
    Rev.  Data       Autore  Descrizione.
    00    05/03/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION abilita
      RETURN NUMBER;

/*****************************************************************************
 NOME:        GET_ID_PROFILO.
 DESCRIZIONE: Dato l'id di view_cartella calcola l'id del profilo associato.

INPUT  p_id_viewcartella varchar2: chiave identificativa nella tabella VIEW_CARTELLA.
RITORNO: number id del profilo associato al fascicolo

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_id_profilo (p_id_viewcartella VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
    NOME:        VERIFICA_UNITA_UTENTE
    DESCRIZIONE: Verifica se l'utente appartiene all'unita specificata:

   INPUT  p_utente varchar2: utente che di cui verificare l'appartenenza.
      p_unita  varchar2 codice dell'unita' cui p_utente deve appartenere.
   RITORNO:  1 se l'utente appartiene a p_untia, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_unita_utente (p_unita VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
    NOME:        VERIFICA_RAMO_UTENTE
    DESCRIZIONE: Verifica se l'utente appartiene ad un'unita dello stesso ramo di p_unita,
    cioè p_unita stessa o un'ascendente o una discendente.

   INPUT  p_utente varchar2: utente che di cui verificare l'appartenenza.
      p_unita  varchar2 codice dell'unita' al cui ramo p_utente deve appartenere.
   RITORNO:  1 se l'utente appartiene ad un'unita del ramo di p_unita, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_ramo_utente (p_unita VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        VERIFICA_CATEGORIA_DOCUMENTO
    DESCRIZIONE: Verifica se il tipo documento del documento identificato da p_id_documento
    è di catagoria p_categoria.

   INPUT  p_id_documento: identificativo del documento di cui verificare la categoria.
         p_categoria varchar2: codice della categoria di cui si vuole vedere se p_id_documento fa parte.
   RITORNO:  1 se p_id_documento è di categoria p_categoria, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    30/05/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_categoria_documento (
      p_id_documento   VARCHAR2,
      p_categoria      VARCHAR2
   )
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        inizializza_utente
    DESCRIZIONE: Aggiorna ag_priv_utente_tmp per p_utente.
    La funzione viene lanciata ad ogni login dell'utente.

   INPUT  p_utente: codice utente.

    Rev.  Data       Autore  Descrizione.
    00    30/05/2007  SC  Prima emissione.
   ********************************************************************************/
   PROCEDURE inizializza_ag_priv_utente_tmp (p_utente VARCHAR2);

   /*****************************************************************************
       NOME:        get_unita_privilegio.
       DESCRIZIONE: Dato il codice di un utente e un privilegio restituisce un cursore con le unita
       per le quali l'utente ha il privilegio.

       INPUT  p_utente varchar2 CODICE UTENTE .
       p_privilegio varchar2 codice del privilegio da cercare.
      RITORNO:  cursore con tutte le unita su ci p_utente ha p_privilegio.

       Rev.  Data       Autore  Descrizione.
       00    31/05/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_unita_privilegio (p_utente VARCHAR2, p_privilegio VARCHAR2)
      RETURN t_ref_cursor;

/*****************************************************************************
    NOME:        inizializza_utente.
    DESCRIZIONE: Riempi la plsql table con utente, unita di cui fa parte, ruoli che ha
                 nelle unita'.

   INPUT  p_utente varchar2: utente che di cui si vogliono conoscere unita di appartenenza e ruoli.
          p_ret_tab Tabella completa dei dati dell'utente.

   OUTPUT 0 se p_utente nn è presente su ag_priv_utente_tmp (cioè se non ha nessun ruolo nella
            struttura organizzativa)
          1 se presente


    Rev.  Data       Autore  Descrizione.
    00    26/06/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION inizializza_utente (p_utente VARCHAR2)
      RETURN NUMBER;

/*****************************************************************************
    NOME:        GET_STATO_FASCICOLO.
    DESCRIZIONE: Individua l'id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    INPUT  p_class_cod                    VARCHAR2
    , p_class_dal                 DATE
    , p_anno        NUMBER
    , p_numero  VARCHAR2
    , p_indice_aoo number indice dell'aoo nella tabella parametri
   RITORNO:  Id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    Rev.  Data       Autore  Descrizione.
    00    03/07/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_stato_fascicolo (
      p_class_cod    VARCHAR2,
      p_class_dal    DATE,
      p_anno         NUMBER,
      p_numero       VARCHAR2,
      p_indice_aoo   NUMBER
   )
      RETURN VARCHAR2;

/*****************************************************************************
    NOME:        GET_ID_DOCUMENTO_FASCICOLO.
    DESCRIZIONE: Individua l'id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    INPUT  p_class_cod                    VARCHAR2
    , p_class_dal                 DATE
    , p_anno        NUMBER
    , p_numero  VARCHAR2
    , p_indice_aoo number indice dell'aoo nella tabella parametri
   RITORNO:  Id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    Rev.  Data       Autore  Descrizione.
    00    03/07/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_id_documento_fascicolo (
      p_class_cod    VARCHAR2,
      p_class_dal    DATE,
      p_anno         NUMBER,
      p_numero       VARCHAR2,
      p_indice_aoo   NUMBER
   )
      RETURN NUMBER;

/*****************************************************************************
 NOME:        GET_ID_VIEW_CLASSIFICA.
 DESCRIZIONE: Individua l'id della cartella classificazione identificata da codice e data
 di inizio validita, da esso trova il corrispondente id_view_cartella e lo restituisce.

INPUT  p_class_cod VARCHAR2, p_class_dal date: codice e data di inizio validita della
classifica
RITORNO: IDENTIFICATIVO DELLA CLASS DI CUI IL FASCICOLO FA PARTE IN VIEW_CARTELLA

 Rev.  Data       Autore  Descrizione.
 00    04/06/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_id_view_classifica (p_class_cod VARCHAR2, p_class_dal DATE)
      RETURN NUMBER;

      /*****************************************************************************
    NOME:        GET_DATA_BLOCCO.
    DESCRIZIONE: Restituisce il valore di PARAMETRI DATA_BLOCCO_n dove n è l'indice dell'aoo
    indicata.
    Se non presente o null restiscuire 01/01/1900.
    In caso di errore restiscuire 31/12/2999.

   INPUT  p_CODICE_AMMINISTRAZIONE VARCHAR2, p_CODICE_AOO VARCHAR2
   RITORNO:valore di PARAMETRI DATA_BLOCCO_n

    Rev.  Data       Autore  Descrizione.
    00    04/06/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_data_blocco (
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   )
      RETURN DATE;

/******************************************************************************
   NAME:       VALORIZZA_AOO
   PURPOSE: Valorizzare i campi codice_Amministrazione e codice_aoo in p_table_name
   se nulli. I valori che verranno messi sono p_codice_amministrazione e p_codice_aoo.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/02/2008          1. Created this procedure. A25801.

******************************************************************************/
   PROCEDURE valorizza_aoo (
      p_table_name               VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   );

      /*****************************************************************************
    NOME:        GET_DEFAULT_TIPO_SMISTAMENTO.
    DESCRIZIONE: Dato un modello, restituisce il tipo smistamento di default
    tra quelli possibili per il modello.
    Il tipo smistamento di default è quello con predominanza maggiore,
    cioè col valore minore in AG_TIPI_SMISTAMENTO.IMPORTANZA.


   INPUT  p_CODICE_AMMINISTRAZIONE VARCHAR2, p_CODICE_AOO VARCHAR2 chiave dell'aoo attiva
            p_area , p_codice_modello chiave identificativa del modello
   RITORNO:valore di PARAMETRI DATA_BLOCCO_n

    Rev.  Data       Autore  Descrizione.
    00    10/03/2008  SC  Prima emissione. A
   ********************************************************************************/
   FUNCTION get_default_tipo_smistamento (
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2,
      p_area                     VARCHAR2,
      p_codice_modello           VARCHAR2
   )
      RETURN VARCHAR2;

      /*****************************************************************************
    NOME:        ESISTE_CATEGORIA.
    DESCRIZIONE: Verifica se esiste P_CATEGORIA e se ha almeno un modello associato.


   INPUT  P_CATEGORIA VARCHAR2 codice della categoria
   RITORNO:1 se la categoria esiste e ha almeno un modello associato,
           0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    23/05/2008  SC  Prima emissione. A27569.0.0
   ********************************************************************************/
   FUNCTION esiste_categoria (p_categoria VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        DOCUMENTO_IS_IN_CATEGORIA.
    DESCRIZIONE: Verifica se p_id_documento appartiene a P_CATEGORIA.


   INPUT    P_ID_DOCUMENTO id del documento di cui si deve verificare l'appartenenza
            a P_CATEGORIA
            P_CATEGORIA VARCHAR2 codice della categoria
   RITORNO:1 se p_id_documento appartiene a p_categoria,
           0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    09/06/2008  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION documento_is_in_categoria (
      p_id_documento   NUMBER,
      p_categoria      VARCHAR2
   )
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        GET_CATEGORIA_DELIBERE.
    DESCRIZIONE: Restituisce il codice della categoria delle delibere


   INPUT
   RITORNO:ag_utilities.categoriadelibere

    Rev.  Data       Autore  Descrizione.
    00    09/06/2008  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_categoria_delibere
      RETURN VARCHAR2;

   /*****************************************************************************
    NOME:        GET_CATEGORIA_DETERMINE.
    DESCRIZIONE: Restituisce il codice della categoria delle determine


   INPUT
   RITORNO:ag_utilities.categoriadetermine

    Rev.  Data       Autore  Descrizione.
    00    09/06/2008  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_categoria_determine
      RETURN VARCHAR2;

   /*****************************************************************************
       NOME:        GET_UNITA_RADICE.
       DESCRIZIONE: Dati utente e privilegio, restituisce il cursore dei codici
       delle unita per cui l'utente ha il privilegio.

       INPUT  p_utente varchar2 CODICE UTENTE .
       p_privilegio codice privilegio.
      RITORNO:  cursore delle unita per le quali p_utente ha p_privilegio.

       Rev.  Data       Autore  Descrizione.
       00    04/09/2008  SC  Prima emissione. A28345.2.0.
   ********************************************************************************/
   FUNCTION get_unita_priviegio_utente (
      p_utente       VARCHAR2,
      p_privilegio   VARCHAR2
   )
      RETURN afc.t_ref_cursor;

   /*****************************************************************************
       NOME:        GET_UNITA_RADICE.
       DESCRIZIONE: Dato il codice di un'unita, data di riferimento e ottica,
        cerca tra le unita ascendenti quella che non ha padre.

       INPUT  p_codice_unita varchar2 CODICE UNITA DI CUI CERCARE LA RADICE .
       p_data_riferimento data di validita delle unita.
       p_ottica OTTICA DI SO4 DA UTILIZZARE.
      RITORNO:  codice dell'unita tra le unita ascendenti di p_codice_unita
      quella che non ha padre.

       Rev.  Data       Autore  Descrizione.
       00    04/09/2008  SC  Prima emissione. A28345.2.0.
   ********************************************************************************/
   FUNCTION get_unita_radice (
      p_codice_unita       VARCHAR2,
      p_data_riferimento   DATE,
      p_ottica             VARCHAR2
   )
      RETURN VARCHAR2;

   /*****************************************************************************
       NOME:        GET_UNITA_RADICE_AREA.
       DESCRIZIONE: Dato il codice di un'unita, data di riferimento e ottica,
        cerca tra le unita ascendenti quella che rappresenta la radice dell'area
        di p_codice_unita.

        Per radice di area, se ag_suddivisioni non contiene righe si considera
        l'unità che non ha padre.
        Se ag_suddivisioni contiene righe, l'unità di area è la prima
        ascendente di p_codice_unita (lei compresa) la cui suddivisione
        è presente in ag_suddivisioni.

       INPUT  p_codice_unita varchar2 CODICE UNITA DI CUI CERCARE LA RADICE .
       p_data_riferimento data di validita delle unita.
       p_ottica OTTICA DI SO4 DA UTILIZZARE.
      RITORNO:  codice dell'unita tra le unita ascendenti di p_codice_unita
      quella che non ha padre.

       Rev.  Data       Autore  Descrizione.
       00    15/02/2010  SC  Prima emissione. A34954.2.0
   ********************************************************************************/
   FUNCTION get_unita_radice_area (
      p_codice_unita             VARCHAR2,
      p_data_riferimento         DATE,
      p_ottica                   VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   )
      RETURN VARCHAR2;

   FUNCTION documento_get_descrizione (p_id_documento IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_defaultaooindex
      RETURN VARCHAR2;

   FUNCTION get_default_ammaoo
      RETURN afc.t_ref_cursor;

/******************************************************************************
   NAME:       GET_OTTICA_AOO
   PURPOSE:    Dato l'indice dell'aoo in tabella PARAMETRI, restituisce il codice
                dell'ottiva istituzionale usato dalla AOO
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/01/2007          1. Created this function.

   NOTES:

******************************************************************************/
   FUNCTION get_ottica_aoo (p_indice_aoo VARCHAR2)
      RETURN VARCHAR2;

/*****************************************************************************
    NOME:        GET_RESPONSABILE_PRIVILEGIO
    DESCRIZIONE: Resituisce il primo responsabile (se esiste) di una unita
                    che gode di uno specifico privilegio.

   INPUT
   p_codice_uo      VARCHAR2
   p_privilegio     VARCHAR2
   p_cod_amm        VARCHAR2
   p_cod_aoo        VARCHAR2

    Rev.  Data       Autore  Descrizione.
    00    22/10/2008  AM  Prima emissione Creazione installanti.
   ********************************************************************************/
   FUNCTION get_responsabile_privilegio (
      p_codice_uo    VARCHAR2,
      p_privilegio   VARCHAR2,
      p_cod_amm      VARCHAR2,
      p_cod_aoo      VARCHAR2
   )
      RETURN VARCHAR2;

/*****************************************************************************
 NOME:        GET_ACRONIMO_TABELLA.
 DESCRIZIONE: dati area e codice modello, riceva l'acronimo della tabella orizzontale
                associata al modello.

INPUT   p_area varchar2: area.
        p_codice_modello varchar2: codice modello
RITORNO: '' se il modello non ha tabella orizzontale o non ha acronimo
         l'acronimo del modello registrato nella tabella TIPI_DOCUMENTO

 Rev.  Data       Autore  Descrizione.
 00    21/01/2009  SC  A30787.0.0.
********************************************************************************/
   FUNCTION get_acronimo_tabella (p_area VARCHAR2, p_codice_modello VARCHAR2)
      RETURN VARCHAR2;

/*****************************************************************************
    NOME:        RiPRISTINA_ULTIMO
    DESCRIZIONE:  quando si cancella una cartella parte un trigger che richiama questa funzione
    per decrementare l'ultimo numero sub nella tabella seg_fascicoli o nella seg_numerazioni_classifica

   INPUT
   new_id_documento_profilo      VARCHAR2

   output
   NUMBER   1 se va a buon fine 0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    17/02/2009  AM  Prima emissione Creazione installanti.
   ********************************************************************************/
   FUNCTION ripristina_ultimo (new_id_documento_profilo VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        INIT_AG_PRIV_UTENTE_LOGIN
    DESCRIZIONE:  quando si cancella una cartella parte un trigger che richiama questa funzione
    per decrementare l'ultimo numero sub nella tabella seg_fascicoli o nella seg_numerazioni_classifica

   INPUT
   p_utente     VARCHAR2
   p_db_user    VARCHAR2
   p_tipo       VARCHAR2

   output
   NUMBER   1 se va a buon fine 0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    22/05/2009  AM  Prima emissione A25616.0.0.
   ********************************************************************************/
   PROCEDURE init_ag_priv_utente_login (
      p_utente    VARCHAR2,
      p_db_user   VARCHAR2,
      p_tipo      VARCHAR2
   );

   /*****************************************************************************
    NOME:        IS_UNITA_IN_AREA
    DESCRIZIONE:  Verifica se p_codice_unita è discendente di p_codice_area.

   INPUT
   p_codice_area     VARCHAR2 codice unità radice di area
   p_codice_unita    VARCHAR2 codice unità di cui si deve verificare se sta nell'
                            area di p_codice_area.
   p_data            DATE   Data di riferimento in cui viene chiesta la struttura.
   p_ottica          VARCHAR2 ottica delle unità.
   output
   NUMBER   1 se va a buon fine 0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    09/03/2010  SC  Prima emissione A34954.5.1 D1039.
   ********************************************************************************/
   FUNCTION is_unita_in_area (
      p_codice_area    VARCHAR2,
      p_codice_unita   VARCHAR2,
      p_data           DATE,
      p_ottica         VARCHAR2
   )
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_UTILITIES_PRE20_CON_SO4_AGG
AS
/********************************************************
VARIABILI GLOBALI
*********************************************************/
   privilegioarea     ag_privilegi.privilegio%TYPE   := 'EPAREA';
   privilegiosup      ag_privilegi.privilegio%TYPE   := 'EPSUP';
   privilegioequ      ag_privilegi.privilegio%TYPE   := 'EPEQU';
   privilegiosub      ag_privilegi.privilegio%TYPE   := 'EPSUB';
   privilegiosubtot   ag_privilegi.privilegio%TYPE   := 'EPSUBTOT';

   /*****************************************************************************
       NOME:        get_default_ammAoo

       DESCRIZIONE: Restituisce un cursore con i codici ed i valori dell'amministrazione
                    e dell'aoo di default.

       INPUT

      RITORNO:

       Rev.  Data        Autore  Descrizione.
       00    29/09/2008  SN      Prima emissione.
   ********************************************************************************/
   FUNCTION get_default_ammaoo
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT pamm.valore codice_amministrazione, paoo.valore codice_aoo
           FROM parametri paoo, parametri pamm
          WHERE paoo.tipo_modello = '@agVar@'
            AND pamm.tipo_modello = '@agVar@'
            AND SUBSTR (pamm.codice, -1) = SUBSTR (paoo.codice, -1)
            AND SUBSTR (pamm.codice, 0, LENGTH (pamm.codice) - 1) =
                                                                 'CODICE_AMM_'
            AND SUBSTR (paoo.codice, 0, LENGTH (paoo.codice) - 1) =
                                                                 'CODICE_AOO_'
            AND SUBSTR (paoo.codice, -1) = get_defaultaooindex;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20999,
                                     'ag_utilities.get_default_ammAoo: '
                                  || SQLERRM
                                 );
   END;

   /*****************************************************************************
       NOME:        set_radici_area_per_privilegio.
       DESCRIZIONE: Dato utente e privilegio, per tutte le unità
        per cui l'utente ha il privilegio calcola l'unità radice
        dell'area e la inserisce in AG_RADICI_AREA_UTENTE_TMP.

        Per radice di area, se ag_suddivisioni non contiene righe si considera
        l'unità che non ha padre.
        Se ag_suddivisioni contiene righe, l'unità di area è la prima
        ascendente di p_codice_unita (lei compresa) la cui suddivisione
        è presente in ag_suddivisioni.

       INPUT  p_utente varchar2 CODICE UNTENTE.
       p_privilegio PRIVILEGIO che deve avere l'uitente
       p_ottica OTTICA DI SO4 DA UTILIZZARE.


       Rev.  Data       Autore  Descrizione.
       00    15/02/2010  SC  Prima emissione. A34954.2.0
       01    09/03/2010  SC A34954.3.1 D1037
   ********************************************************************************/
   PROCEDURE set_radici_area_per_privilegio (
      p_utente                   VARCHAR2,
      p_privilegio               VARCHAR2,
      p_ottica                   VARCHAR2 DEFAULT NULL,
      p_codice_amministrazione   VARCHAR2 DEFAULT NULL,
      p_codice_aoo               VARCHAR2 DEFAULT NULL
   )
   IS
      v_unitasmistaarea          afc.t_ref_cursor;
      cascendenti                afc.t_ref_cursor;
      v_ammaoo                   afc.t_ref_cursor;
      depprogr                   NUMBER;
      dep_codice_unita           seg_unita.unita%TYPE;
      d_unita_radice             seg_unita.unita%TYPE;
      dep_dal_unita              DATE;
      dep_al_unita               DATE;
      depdescrizioneunita        VARCHAR2 (1000);
      suddivisione_presente      NUMBER                 := 0;
      dep_suddivisione           NUMBER;
      d_codice_amministrazione   VARCHAR2 (1000);
      d_codice_aoo               VARCHAR2 (1000);
      d_ottica                   VARCHAR2 (1000);
   BEGIN
      d_codice_amministrazione := p_codice_amministrazione;
      d_codice_aoo := p_codice_aoo;
      d_ottica := p_ottica;

      IF d_codice_aoo IS NULL OR d_codice_amministrazione IS NULL
      THEN
         v_ammaoo := ag_utilities.get_default_ammaoo ();

         IF v_ammaoo%ISOPEN
         THEN
            FETCH v_ammaoo
             INTO d_codice_amministrazione, d_codice_aoo;

            CLOSE v_ammaoo;
         END IF;
      END IF;

      IF d_ottica IS NULL
      THEN
         d_ottica :=
            ag_utilities.get_ottica_utente (p_utente,
                                            d_codice_amministrazione,
                                            d_codice_aoo
                                           );
      END IF;

      DELETE      ag_radici_area_utente_tmp
            WHERE utente = p_utente AND privilegio = p_privilegio;

      v_unitasmistaarea :=
              ag_utilities.get_unita_priviegio_utente (p_utente, p_privilegio);

      IF v_unitasmistaarea%ISOPEN
      THEN
         -- verifica se l'utente ha privilegio per assegnare a componenti di qualunque unita
         LOOP
            -- costruisce una stringa delle unita di livello 0 dell'area per cui l'utente
            -- ha privilegio SMISTAAREA, i codici sono separati da @.
            FETCH v_unitasmistaarea
             INTO dep_codice_unita, dep_dal_unita, dep_al_unita;

            EXIT WHEN v_unitasmistaarea%NOTFOUND;
            DBMS_OUTPUT.put_line ('dep_codice_unita ' || dep_codice_unita);

            IF (dep_al_unita IS NULL)
            THEN
               -- SC A34954.3.1 D1037
               DECLARE
                  d_data_rif   DATE := NULL;
               BEGIN
                  IF ag_parametro.get_valore
                                         (   'STORICO_RUOLI_'
                                          || ag_utilities.get_indice_aoo
                                                                        (NULL,
                                                                         NULL
                                                                        ),
                                          '@agVar@'
                                         ) = 'Y'
                  THEN
                     d_data_rif := dep_dal_unita;
                  END IF;

                  d_unita_radice :=
                     ag_utilities.get_unita_radice_area
                                                    (dep_codice_unita,
                                                     d_data_rif,
                                                     d_ottica,
                                                     d_codice_amministrazione,
                                                     d_codice_aoo
                                                    );
               END;

               DBMS_OUTPUT.put_line ('d_unita_radice ' || d_unita_radice);

               INSERT INTO ag_radici_area_utente_tmp
                           (utente, unita_radice_area, privilegio)
                  SELECT p_utente, d_unita_radice, p_privilegio
                    FROM DUAL
                   WHERE NOT EXISTS (
                            SELECT 1
                              FROM ag_radici_area_utente_tmp
                             WHERE utente = p_utente
                               AND unita_radice_area = d_unita_radice
                               AND privilegio = p_privilegio);
            END IF;
         END LOOP;

         --tolgo le unità radice che hanno a loro volta ascendenti presenti in tabella
         FOR unita_radici_area IN (SELECT unita_radice_area, utente,
                                          privilegio
                                     FROM ag_radici_area_utente_tmp
                                    WHERE utente = p_utente
                                      AND privilegio = p_privilegio)
         LOOP
            DBMS_OUTPUT.put_line (   'CALCOLO DELETE PER  '
                                  || unita_radici_area.unita_radice_area
                                 );

            DELETE      ag_radici_area_utente_tmp
                  WHERE utente = unita_radici_area.utente
                    AND privilegio = unita_radici_area.privilegio
                    AND unita_radice_area =
                                           unita_radici_area.unita_radice_area
                    AND EXISTS (
                           SELECT 1
                             FROM ag_radici_area_utente_tmp
                            WHERE utente = unita_radici_area.utente
                              AND privilegio = unita_radici_area.privilegio
                              AND unita_radice_area !=
                                           unita_radici_area.unita_radice_area
                              AND INSTR
                                     (so4_util.unita_get_ascendenza
                                          (unita_radici_area.unita_radice_area),
                                      'O#' || unita_radice_area || '#',
                                      1
                                     ) > 0);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END set_radici_area_per_privilegio;

   /*****************************************************************************
       NOME:        GET_UNITA_PADRE.
       DESCRIZIONE: Dato il codice di un'unita restituisce i dati dell'unita padre.

       INPUT  p_codice_unita varchar2 CODICE UNITA DI CUI CERCARE IL PADRE .
       p_ottica OTTICA DI SO4 DA UTILIZZARE.
       p_data DATA ALLA QUALE L'UNITA' DEVE ESSERE VALIDA
       p_codice_unita_padre OUT VARCHAR2 codice dell'unita padre di p_codice_unita,
      p_dal_padre OUT DATE data di inizio validita dell'unita padre,
      p_al_padre OUT date data di chiusura dell'unita padre


       Rev.  Data       Autore  Descrizione.
       00    19/05/2007  SC  Prima emissione.
             14/01/2008 trasfomata in procedure per restituisce anche data di inizio e fine
             validita dell' unita padre.
   ********************************************************************************/
   PROCEDURE get_unita_padre (
      p_codice_unita               VARCHAR2,
      p_ottica                     VARCHAR2,
      p_data                       DATE,
      p_codice_unita_padre   OUT   VARCHAR2,
      p_dal_padre            OUT   DATE,
      p_al_padre             OUT   DATE
   )
   IS
      retval                seg_unita.unita%TYPE;
      unitaascendenti       afc.t_ref_cursor;
      depdescrizioneunita   VARCHAR2 (32000);
      depprogr              NUMBER;
      depdal                DATE;
      conta                 NUMBER                 := 0;
   BEGIN
      BEGIN
         unitaascendenti :=
            so4_util.unita_get_ascendenti (p_codice_uo      => p_codice_unita,
                                           p_data           => p_data,
                                           p_ottica         => p_ottica
                                          );
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

--il cursore restituisce come prima riga p_codice_uo, poi l'unita padre.
      IF unitaascendenti%ISOPEN
      THEN
         LOOP
            FETCH unitaascendenti
             INTO depprogr, p_codice_unita_padre, depdescrizioneunita,
                  p_dal_padre, p_al_padre;

--alla prima fetch ottendo l'unita stessa, alla seconda l'unita padre.
            EXIT WHEN unitaascendenti%NOTFOUND;
            conta := conta + 1;

            IF conta = 2
            THEN
               EXIT;
            END IF;
         END LOOP;

         CLOSE unitaascendenti;
      END IF;
   END get_unita_padre;

   /*****************************************************************************
       NOME:        get_unita_privilegio.
       DESCRIZIONE: Dato il codice di un utente e un privilegio restituisce un cursore con le unita
       per le quali l'utente ha il privilegio.

       INPUT  p_utente varchar2 CODICE UTENTE .
       p_privilegio varchar2 codice del privilegio da cercare.
      RITORNO:  cursore con tutte le unita su ci p_utente ha p_privilegio.

       Rev.  Data       Autore  Descrizione.
       00    31/05/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_unita_privilegio (p_utente VARCHAR2, p_privilegio VARCHAR2)
      RETURN t_ref_cursor
   IS
      retval   t_ref_cursor;
   BEGIN
      OPEN retval FOR
         SELECT DISTINCT unita
                    FROM ag_priv_utente_tmp
                   WHERE utente = p_utente AND privilegio = p_privilegio;

      RETURN retval;
      RETURN retval;
   END get_unita_privilegio;

/*****************************************************************************
    NOME:        riempi_unita_utente_tab.
    DESCRIZIONE: Riempie una table con utente, unita di cui fa parte, privilegi che ha
                 nelle unita'.

   INPUT  p_utente varchar2: utente che di cui si vogliono conoscere unita di appartenenza e privilegi.


    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          04/06/2009  SC  A30334.0.0 Richiede lo storico dei ruoli solo se previsto
                                     dal parametro STORICO_RUOLI_1. Per ora l'amministrazione/aoo
                                     associata all'utente non è individualbile, quindi passo null
                                     ad ag_utilities.get_indice_aoo.
   ********************************************************************************/
   PROCEDURE riempi_unita_utente_tab (p_utente VARCHAR2)
   IS
      unitautente           afc.t_ref_cursor;
      ruoli                 t_ref_cursor;
      privilegi             t_ref_cursor;
      depunita              seg_unita.unita%TYPE;
      depdescrizioneunita   VARCHAR2 (1000);
      depruolo              VARCHAR2 (8);
      depprivilegio         ag_privilegi.privilegio%TYPE;
      depdescrizioneruolo   VARCHAR2 (1000);
      indice                NUMBER                         := 0;
      indicevecchio         NUMBER                         := 0;
      depdal                DATE;
      depal                 DATE;
      depprogrunita         NUMBER;
   BEGIN
      -- A30334.0.0 SC richiede lo storico dei ruoli solo se previsto
      -- dal parametro STORICO_RUOLI_1. Per ora l'amministrazione/aoo
      -- associata all'utente non è individualbile, quindi passo null
      -- ad ag_utilities.get_indice_aoo.
         --DBMS_OUTPUT.put_line ('inizio');
      unitautente :=
         so4_util.ad4_utente_get_storico_unita
            (p_utente          => p_utente,
             p_ottica          => ottica,
             p_se_storico      => ag_parametro.get_valore
                                          (   'STORICO_RUOLI_'
                                           || ag_utilities.get_indice_aoo
                                                                        (NULL,
                                                                         NULL
                                                                        ),
                                           '@agVar@'
                                          )
            );

      IF unitautente%ISOPEN
      THEN
         --DBMS_OUTPUT.put_line ('unita utente open');
         LOOP
            FETCH unitautente
             INTO depprogrunita, depunita, depdescrizioneunita, depdal,
                  depal, depruolo, depdescrizioneruolo;

            EXIT WHEN unitautente%NOTFOUND;
            privilegi :=
                      ag_privilegio_ruolo.get_privilegi (indiceaoo, depruolo);

            IF privilegi%ISOPEN
            THEN
               LOOP
                  FETCH privilegi
                   INTO depprivilegio;

                  EXIT WHEN privilegi%NOTFOUND;

                  --DBMS_OUTPUT.put_line (   'inserisco privilegio '
--                                        || depprivilegio
--                                        || ' per ruolo '
--                                        || depruolo
--                                        || ' unita '
--                                        || depunita
--                                        || ' dal '
--                                        || depdal
--                                        || ' al '
--                                        || depal
--                                       );
                  BEGIN
                     INSERT INTO ag_priv_utente_tmp
                                 (utente, unita, ruolo,
                                  privilegio, appartenenza, dal, al
                                 )
                          VALUES (p_utente, depunita, depruolo,
                                  depprivilegio, 'D', depdal, depal
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                     WHEN OTHERS
                     THEN
                        RAISE;
                  END;
               END LOOP;
            END IF;

            indicevecchio := indice;
         END LOOP;

         CLOSE unitautente;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         --DBMS_OUTPUT.put_line (SQLERRM);
         NULL;
   END riempi_unita_utente_tab;

/*****************************************************************************
    NOME:        add_fratelli_per_privilegio.
    DESCRIZIONE: Aggiunge alla temporary table delle unita/privilegi dell'utente
    le unita DI PARI LIVELLO
    di quelle unita di cui l'utente fa parte con ruolo che possiede il privilegio
    p_privilegio. Ad ogni unita associa il ruolo che l'utente ha nell'unita di effettiva
    appartenenza.
    Per esempio se p_utente appartiene all'unita X con ruolo che ha privilegio
    VEQU, puo' vedere anche i documenti delle unita di stesso livello,
    quindi tutte le unita con lo stesso padre di X
    devono essere aggiunte alla plsql table p_tab.
    Se p_utente appartiene anche all'unita Y ma con un ruolo che non ha VEQU
    , non puo' vedere i documenti delle unita di stesso livello,
    quindi NESSUNA unita con lo stesso padre di Y
    deve essere aggiunta alla plsql table p_tab.

   INPUT  p_utente                  VARCHAR2 di cui si deve verificare se ha privilegio
    , p_privilegio riguardante le unita di pari livello.
    , UnitaUtenteTab            IN      UnitaUtenteTab unita cui l'utente appartiene
    , UnitaFratelliTab       OUT UnitaUtenteTab plsql table da restituire.


    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   PROCEDURE add_fratelli_per_privilegio (p_utente VARCHAR2)
   IS
      depfratello           VARCHAR2 (100);
      depdescrizioneunita   VARCHAR2 (32000);
      fratelli              t_ref_cursor;
      depprogr              NUMBER;
      depdatadal            DATE;
      depdataal             DATE;
      datachiusuraunita     DATE;
   BEGIN
      FOR unitautente IN (SELECT DISTINCT unita, ruolo, dal
                                     FROM ag_priv_utente_tmp prut1
                                    WHERE utente = p_utente
                                      AND privilegio = privilegioequ)
      LOOP
         BEGIN
            fratelli :=
               so4_util.unita_get_storico_pari_livello
                                           (p_codice_uo      => unitautente.unita,
                                            p_ottica         => ottica
                                           );
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         IF fratelli%ISOPEN
         THEN
            LOOP
               FETCH fratelli
                INTO depprogr, depfratello, depdescrizioneunita, depdatadal,
                     depdataal;

               EXIT WHEN fratelli%NOTFOUND;

               FOR privilegi IN (SELECT privilegio
                                   FROM ag_privilegi_ruolo
                                  WHERE aoo = indiceaoo
                                    AND ruolo = unitautente.ruolo
                                    AND privilegio NOT IN
                                           (privilegiosub,
                                            privilegiosup,
                                            privilegioequ,
                                            privilegioarea,
                                            privilegiosubtot
                                           ))
               LOOP
                  BEGIN
                     INSERT INTO ag_priv_utente_tmp
                                 (utente, unita, ruolo,
                                  privilegio, dal, al
                                 )
                          VALUES (p_utente, depfratello, unitautente.ruolo,
                                  privilegi.privilegio, depdatadal, depdataal
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                     WHEN OTHERS
                     THEN
                        RAISE;
                  END;
               END LOOP;
            END LOOP;

            CLOSE fratelli;
         END IF;
      END LOOP;
   END add_fratelli_per_privilegio;

/*****************************************************************************
    NOME:        get_unita_pari_area.
    DESCRIZIONE: Calcola il cursore delle unita che fanno parte della stessa area di
    p_codice_unita.


   INPUT  p_codice_unita                  VARCHAR2 codice unita di cui si cerca
                                        l'area e le unita dell'area


    Rev.  Data       Autore  Descrizione.
    00    06/05/2008  SC  A27282.1.0  Prima emissione.
          15/02/2010  SC  A34954.2.0 Gestione suddivisioni per riconoscere l'area.
   ********************************************************************************/
   FUNCTION get_unita_pari_area (
      p_codice_unita       VARCHAR2,
      p_data_riferimento   DATE
   )
      RETURN t_ref_cursor
   IS
      cascendenti              t_ref_cursor;
      cdiscendentiradice       t_ref_cursor;
      depprogr                 NUMBER;
      dep_codice_unita_padre   seg_unita.unita%TYPE;
      depdescrizioneunita      VARCHAR2 (1000);
      dep_dal_padre            DATE;
      dep_al_padre             DATE;
      suddivisione_presente    NUMBER                 := 0;
      dep_suddivisione         NUMBER;
   BEGIN
      NULL;
      cascendenti :=
         so4_util.unita_get_ascendenti_sudd (p_codice_unita,
                                             p_data_riferimento,
                                             ottica
                                            );

      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
             INTO depprogr, dep_codice_unita_padre, depdescrizioneunita,
                  dep_dal_padre, dep_al_padre, dep_suddivisione;

            BEGIN
               SELECT 1
                 INTO suddivisione_presente
                 FROM ag_suddivisioni
                WHERE dep_suddivisione = id_suddivisione
                  AND indice_aoo = ag_utilities.get_indice_aoo (NULL, NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            EXIT WHEN cascendenti%NOTFOUND OR suddivisione_presente = 1;
--dbms_output.put_line(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
--                  p_dal_padre||', '||p_al_padre);
         END LOOP;

         CLOSE cascendenti;
      END IF;

--dbms_output.put_line('-----------------------------------');
      cdiscendentiradice :=
         so4_util.unita_get_storico_discendenti (dep_codice_unita_padre,
                                                 ottica
                                                );
      RETURN cdiscendentiradice;
   END get_unita_pari_area;

/*****************************************************************************
    NOME:        add_area_per_privilegio.
    DESCRIZIONE: Aggiunge alla temporary table delle unita/privilegi dell'utente
    le unita dell'area dell'unita di appartenenza di p_utente.
    Questo accade solo per le unita cui p_utente appartiene e per cui ha privilegio
    EPAREA.


   INPUT  p_utente                  VARCHAR2 di cui si deve verificare se ha privilegio


    Rev.  Data       Autore  Descrizione.
    00    06/05/2008  SC  A27282.1.0  Prima emissione.
    01    09/03/2010  SC A34954.3.1 D1037
   ********************************************************************************/
   PROCEDURE add_area_per_privilegio (p_utente VARCHAR2)
   IS
      depparente            VARCHAR2 (100);
      depdescrizioneunita   VARCHAR2 (32000);
      parenti               t_ref_cursor;
      depprogr              NUMBER;
      depdatadal            DATE;
      depdataal             DATE;
      datachiusuraunita     DATE;
      dloop                 NUMBER           := 0;
      depesistenew          BOOLEAN          := TRUE;
   BEGIN
      FOR unitautente IN (SELECT DISTINCT unita, ruolo, dal
                                     FROM ag_priv_utente_tmp
                                    WHERE utente = p_utente
                                      AND privilegio = privilegioarea)
      LOOP
         -- SC A34954.3.1 D1037
         DECLARE
            d_data_rif   DATE := NULL;
         BEGIN
            IF ag_parametro.get_valore (   'STORICO_RUOLI_'
                                        || ag_utilities.get_indice_aoo (NULL,
                                                                        NULL
                                                                       ),
                                        '@agVar@'
                                       ) = 'Y'
            THEN
               d_data_rif := unitautente.dal;
            END IF;

            parenti :=
               get_unita_pari_area (p_codice_unita          => unitautente.unita,
                                    p_data_riferimento      => d_data_rif
                                   );
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         IF parenti%ISOPEN
         THEN
            LOOP
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH parenti
                      INTO depprogr, depparente, depdescrizioneunita,
                           depdatadal, depdataal;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        -- Gestisce l'errore
                        -- ORA-06504: PL/SQL: Return types of Result Set variables or query do not match
                        -- perche' la funzione
                        IF SQLCODE = -6504
                        THEN
                           depesistenew := FALSE;

                           FETCH parenti
                            INTO depprogr, depparente, depdescrizioneunita,
                                 depdatadal;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH parenti
                      INTO depprogr, depparente, depdescrizioneunita,
                           depdatadal, depdataal;
                  ELSE
                     FETCH parenti
                      INTO depprogr, depparente, depdescrizioneunita,
                           depdatadal;
                  END IF;
               END IF;

               EXIT WHEN parenti%NOTFOUND;

               FOR privilegi IN (SELECT privilegio
                                   FROM ag_privilegi_ruolo
                                  WHERE aoo = indiceaoo
                                    AND ruolo = unitautente.ruolo
                                    AND privilegio NOT IN
                                           (privilegioarea,
                                            privilegiosub,
                                            privilegiosup,
                                            privilegioequ,
                                            privilegiosubtot
                                           ))
               LOOP
                  BEGIN
                     INSERT INTO ag_priv_utente_tmp
                                 (utente, unita, ruolo,
                                  privilegio, dal, al
                                 )
                          VALUES (p_utente, depparente, unitautente.ruolo,
                                  privilegi.privilegio, depdatadal, depdataal
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                     WHEN OTHERS
                     THEN
                        RAISE;
                  END;
               END LOOP;
            END LOOP;

            CLOSE parenti;
         END IF;
      END LOOP;
   END add_area_per_privilegio;

/*****************************************************************************
    NOME:        add_discendenti_per_privilegio.
    DESCRIZIONE: Aggiunge alla temporary table delle unita dell'utente le unita figlie
    di quelle unita di cui l'utente fa parte con ruolo che possiede il privilegio
    p_privilegio.



   INPUT  p_utente                  VARCHAR2 di cui si deve verificare se ha privilegio.


    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
          23/09/2008  SC  A28345.25.0 GESTIONE EPSUBTOT
   ********************************************************************************/
   PROCEDURE add_discendenti_per_privilegio (p_utente VARCHAR2)
   IS
      indice                NUMBER           := 0;
      depfiglia             VARCHAR2 (100);
      depdescrizioneunita   VARCHAR2 (32000);
      discendenti           t_ref_cursor;
      depprogr              NUMBER;
      depdatadal            DATE;
      depdataal             DATE;
      dloop                 NUMBER           := 0;
      depesistenew          BOOLEAN          := TRUE;
   BEGIN
      -- INSERISCE PRIVILEGI ESTESI PER EPSUB
      FOR unitautente IN (SELECT DISTINCT unita, ruolo, dal
                                     FROM ag_priv_utente_tmp prut1
                                    WHERE utente = p_utente
                                      AND privilegio = privilegiosub)
      LOOP
         --DBMS_OUTPUT.put_line (   'so4_util.unita_get_unita_figlie '
--                               || unitautente.unita
--                              );
         BEGIN
            discendenti :=
               so4_util.unita_get_storico_figlie
                                           (p_codice_uo      => unitautente.unita,
                                            p_ottica         => ottica
                                           );
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         IF discendenti%ISOPEN
         THEN
            LOOP
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH discendenti
                      INTO depprogr, depfiglia, depdescrizioneunita,
                           depdatadal, depdataal;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        -- Gestisce l'errore
                        -- ORA-06504: PL/SQL: Return types of Result Set variables or query do not match
                        -- perche' la funzione
                        IF SQLCODE = -6504
                        THEN
                           depesistenew := FALSE;

                           FETCH discendenti
                            INTO depprogr, depfiglia, depdescrizioneunita,
                                 depdatadal;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH discendenti
                      INTO depprogr, depfiglia, depdescrizioneunita,
                           depdatadal, depdataal;
                  ELSE
                     FETCH discendenti
                      INTO depprogr, depfiglia, depdescrizioneunita,
                           depdatadal;
                  END IF;
               END IF;
               EXIT WHEN discendenti%NOTFOUND;

               FOR privilegi IN (SELECT privilegio
                                   FROM ag_privilegi_ruolo
                                  WHERE aoo = indiceaoo
                                    AND ruolo = unitautente.ruolo
                                    AND privilegio NOT IN
                                           (privilegiosub,
                                            privilegiosup,
                                            privilegioequ,
                                            privilegioarea,
                                            privilegiosubtot
                                           ))
               LOOP
                  BEGIN
                     INSERT INTO ag_priv_utente_tmp
                                 (utente, unita, ruolo,
                                  privilegio, dal, al
                                 )
                          VALUES (p_utente, depfiglia, unitautente.ruolo,
                                  privilegi.privilegio, depdatadal, depdataal
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                     WHEN OTHERS
                     THEN
                        RAISE;
                  END;
               END LOOP;
            END LOOP;

            CLOSE discendenti;
         END IF;
      END LOOP;

-- INSERISCE PRIVILEGI ESTESI PER EPSUBTOT, ESCLUDE I RUOLI CHE HANNO ANCHE EPAREA
      FOR unitautente IN (SELECT DISTINCT unita, ruolo, dal
                                     FROM ag_priv_utente_tmp prut1
                                    WHERE utente = p_utente
                                      AND privilegio = privilegiosubtot)
      LOOP
          --DBMS_OUTPUT.put_line ('UNITA CON PRIV EPSUBTOT ' || unitautente.unita
         --                      );
         BEGIN
            discendenti :=
               so4_util.unita_get_storico_discendenti (unitautente.unita,
                                                       ottica
                                                      );
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         IF discendenti%ISOPEN
         THEN
            LOOP
               FETCH discendenti
                INTO depprogr, depfiglia, depdescrizioneunita, depdatadal,
                     depdataal;

               --DBMS_OUTPUT.put_line (   depprogr
--                                     || ', '
--                                     || depfiglia
--                                     || ', '
--                                     || depdescrizioneunita
--                                     || ', '
--                                     || depdatadal
--                                     || ', '
--                                     || depdataal
--                                    );
               EXIT WHEN discendenti%NOTFOUND;

               FOR privilegi IN (SELECT privilegio
                                   FROM ag_privilegi_ruolo
                                  WHERE aoo = indiceaoo
                                    AND ruolo = unitautente.ruolo
                                    AND privilegio NOT IN
                                           (privilegiosub,
                                            privilegiosup,
                                            privilegioequ,
                                            privilegioarea,
                                            privilegiosubtot
                                           ))
               LOOP
                  BEGIN
                     --DBMS_OUTPUT.put_line (   'UNITA PRIVILEGIO DA INSERIRE '
--                                           || depfiglia
--                                           || ' '
--                                           || privilegi.privilegio
--                                          );
                     INSERT INTO ag_priv_utente_tmp
                                 (utente, unita, ruolo,
                                  privilegio, dal, al
                                 )
                          VALUES (p_utente, depfiglia, unitautente.ruolo,
                                  privilegi.privilegio, depdatadal, depdataal
                                 );
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX
                     THEN
                        NULL;
                     WHEN OTHERS
                     THEN
                        RAISE;
                  END;
               END LOOP;
            END LOOP;

            CLOSE discendenti;
         END IF;
      END LOOP;
   END add_discendenti_per_privilegio;

/*****************************************************************************
    NOME:        add_padri_per_privilegio.
    DESCRIZIONE: Aggiunge alla temporary table delle unita dell'utente le unita padri
    di quelle unita di cui l'utente fa parte con ruolo che possiede il privilegio
    p_privilegio.
    Per esempio se p_utente appartiene all'unita X con ruolo che ha privilegio
    VEQU, puo' vedere anche i documenti delle unita di stesso livello,
    quindi tutte le unita con lo stesso padre di X
    devono essere aggiunte alla plsql table p_tab.
    Se p_utente appartiene anche all'unita Y ma con un ruolo che non ha VEQU
    , non puo' vedere i documenti delle unita di stesso livello,
    quindi NESSUNA unita con lo stesso padre di Y
    deve essere aggiunta alla plsql table p_tab.


   INPUT  p_utente                  VARCHAR2 di cui si deve verificare se ha privilegio.


    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    09/03/2010  SC A34954.3.1 D1037
   ********************************************************************************/
   PROCEDURE add_padri_per_privilegio (p_utente VARCHAR2)
   IS
      indice        NUMBER         := 0;
      deppadre      VARCHAR2 (100);
      depdalpadre   DATE;
      depalpadre    DATE;
   BEGIN
      FOR unitautente IN (SELECT DISTINCT unita, ruolo, dal
                                     FROM ag_priv_utente_tmp prut1
                                    WHERE utente = p_utente
                                      AND privilegio = privilegiosup)
      LOOP
         --DBMS_OUTPUT.put_line (   'UNITA PER CUI SI HA EPSUP '
--                               || unitautente.unita
--                              );
--SC A34954.3.1 D1037. Se non è richiesto storico ruoli, la data in cui
-- ricostruire la struttura è  quella di default di so4.
         DECLARE
            d_data_rif   DATE := NULL;
         BEGIN
            IF ag_parametro.get_valore (   'STORICO_RUOLI_'
                                        || ag_utilities.get_indice_aoo (NULL,
                                                                        NULL
                                                                       ),
                                        '@agVar@'
                                       ) = 'Y'
            THEN
               d_data_rif := unitautente.dal;
            END IF;

            get_unita_padre (p_codice_unita            => unitautente.unita,
                             p_ottica                  => ottica,
                             p_data                    => d_data_rif,
                             p_codice_unita_padre      => deppadre,
                             p_dal_padre               => depdalpadre,
                             p_al_padre                => depalpadre
                            );
         END;

         --DBMS_OUTPUT.put_line ('UNITA PADRE ' || deppadre);
         IF deppadre IS NOT NULL
         THEN
            FOR privilegi IN (SELECT privilegio
                                FROM ag_privilegi_ruolo
                               WHERE aoo = indiceaoo
                                 AND ruolo = unitautente.ruolo
                                 AND privilegio NOT IN
                                        (privilegiosub,
                                         privilegiosup,
                                         privilegioequ,
                                         privilegioarea,
                                         privilegiosubtot
                                        ))
            LOOP
               BEGIN
                  INSERT INTO ag_priv_utente_tmp
                              (utente, unita, ruolo,
                               privilegio, dal, al
                              )
                       VALUES (p_utente, deppadre, unitautente.ruolo,
                               privilegi.privilegio, depdalpadre, depalpadre
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     NULL;
                  WHEN OTHERS
                  THEN
                     RAISE;
               END;
            END LOOP;
         END IF;
      END LOOP;
   END add_padri_per_privilegio;

/*****************************************************************************
    NOME:        riempi_unita_estese.
    DESCRIZIONE: Riempie una temporary table con utente, unita di cui fa parte, privilegi che ha
                 nelle unita' e unita della struttura sulle quali ha diritto grazie ai privilegi
                 di esensione del ruolo EPSUP, EPSUB, EPEQU.

   INPUT  p_utente varchar2: utente che di cui si vogliono conoscere unita di appartenenza e privilegi.


    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   PROCEDURE riempi_unita_estese (p_utente VARCHAR2)
   IS
      ultimariga   NUMBER;
   BEGIN
      riempi_unita_utente_tab (p_utente => p_utente);
      --DBMS_OUTPUT.put_line ('0');
      add_area_per_privilegio (p_utente => p_utente);
      --DBMS_OUTPUT.put_line ('1');
      add_fratelli_per_privilegio (p_utente => p_utente);
      --DBMS_OUTPUT.put_line ('2');
      add_discendenti_per_privilegio (p_utente => p_utente);
      --DBMS_OUTPUT.put_line ('3');
      add_padri_per_privilegio (p_utente => p_utente);
      --DBMS_OUTPUT.put_line ('4');
      --DBMS_OUTPUT.put_line ('fine fine');
      set_radici_area_per_privilegio (p_utente          => p_utente,
                                      p_privilegio      => privilegio_smistaarea
                                     );
   END riempi_unita_estese;

     /******************************************************************************
      NAME:       add_unitautenterec
      PURPOSE:    Inserisce la coppia p_unita, p_ruolo in p_tab se non presente.


      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        26/05/2007      SC    1. Created this function.

      NOTES:

   ******************************************************************************/
--   PROCEDURE add_unitautenterec (
--      p_record            unitautenterec,
--      p_tab      IN OUT   unitautentetab
--   )
--   AS
--      indice   NUMBER  := 0;
--      esiste   BOOLEAN := FALSE;
--   BEGIN
--      IF NVL (p_tab.FIRST, 0) > 0
--      THEN
--         FOR j IN NVL (p_tab.FIRST, 0) .. NVL (p_tab.LAST, 0)
--         LOOP
--            esiste :=
--                   p_tab (j).unita = p_record.unita
--               AND NVL (p_tab (j).ruolo, '*') = NVL (p_record.ruolo, '*');

   --            IF esiste
--            THEN
--               EXIT;
--            END IF;
--         END LOOP;
--      END IF;

   --      IF NOT esiste
--      THEN
--         indice := NVL (p_tab.LAST, 0) + 1;
--         p_tab (indice).unita := p_record.unita;
--         p_tab (indice).ruolo := p_record.ruolo;
--      END IF;
--   END add_unitautenterec;
   FUNCTION ad4_utgr_get_livello (p_utente IN VARCHAR2, p_gruppo IN VARCHAR2)
      RETURN NUMBER
   IS
        /******************************************************************************
         NAME:       AD4_UTGR_GET_LIVELLO
         PURPOSE:    Dati un utente (p_utente) ed il gruppo di appartenenza (p_gruppo)
                     restituisce il livello a cui si trova l'utente all'interno del gruppo.
            0 - non e in p_gruppo
            1 - figlio diretto di p_gruppo
            2 - figlio di un gruppo che a sup volta e figlio di p_gruppo...

         REVISIONS:
         Ver        Date        Author           Description
         ---------  ----------  ---------------  ------------------------------------
         1.0        03/10/2006          1. Created this function.

         NOTES:

      ******************************************************************************/
      tmpvar   NUMBER;
   BEGIN
      tmpvar := 0;

      SELECT     COUNT (gruppo)
            INTO tmpvar
            FROM ad4_utenti_gruppo utgr
      CONNECT BY PRIOR utgr.gruppo = utgr.utente
      START WITH utente = p_utente AND gruppo = p_gruppo;

      RETURN tmpvar;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_indice_aoo (p_codice_amm VARCHAR2, p_codice_aoo VARCHAR2)
      RETURN NUMBER
   IS
/******************************************************************************
   NAME:       GET_INDICE_AOO
   PURPOSE:    Dati codice amministrazione e codice_aoo, ne restituisce l'indice utilizzato
         nella tabella PARAMETRI.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/12/2006          1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     MOD_PROTOCOLLO
      Sysdate:         11/12/2006
      Date and Time:   11/12/2006, 13.24.10, and 11/12/2006 13.24.10
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
      indiceaoo   NUMBER;
   BEGIN
      SELECT SUBSTR (paoo.codice, INSTR (paoo.codice, '_', -1) + 1)
        INTO indiceaoo
        FROM parametri paoo, parametri pamm
       WHERE paoo.tipo_modello = '@agVar@'
         AND paoo.valore = p_codice_aoo
         AND pamm.tipo_modello = '@agVar@'
         AND pamm.valore = p_codice_amm
         AND SUBSTR (pamm.codice, -1) = SUBSTR (paoo.codice, -1);

      RETURN indiceaoo;
   EXCEPTION
      WHEN OTHERS
      THEN
         indiceaoo := 1;
         RETURN indiceaoo;
   END;

   FUNCTION get_ottica_aoo (p_indice_aoo VARCHAR2)
      RETURN VARCHAR2
   IS
/******************************************************************************
   NAME:       GET_OTTICA_AOO
   PURPOSE:    Dato l'indice dell'aoo in tabella PARAMETRI, restituisce il codice
                dell'ottiva istituzionale usato dalla AOO
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/01/2007          1. Created this function.

   NOTES:

******************************************************************************/
      ottica   parametri.valore%TYPE;
   BEGIN
      SELECT valore
        INTO ottica
        FROM parametri
       WHERE tipo_modello = '@agVar@'
         AND codice = 'SO_OTTICA_PROT_' || p_indice_aoo;

      RETURN ottica;
   EXCEPTION
      WHEN OTHERS
      THEN
         ottica := '*';
         RETURN ottica;
   END;

   FUNCTION get_ottica_utente (
      p_utente       VARCHAR2,
      p_codice_amm   VARCHAR2,
      p_codice_aoo   VARCHAR2
   )
      RETURN VARCHAR2
   IS
/******************************************************************************
   NAME:       GET_OTTICA_UTENTE
   PURPOSE:    Dato il codice utente e l''aoo per la quale lavora, restituisce
               l'ottica di SO4 utilizzata dalla Aoo.
      Se l'aoo non e' specificata, va ricavata in base alla posizione dell'utente
      in SO4.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/01/2007          1. Created this function.

   NOTES:

******************************************************************************/
      ottica   VARCHAR2 (18);
   BEGIN
      ottica := get_ottica_aoo (get_indice_aoo (p_codice_amm, p_codice_aoo));
      RETURN ottica;
   EXCEPTION
      WHEN OTHERS
      THEN
         ottica := '1';
         RETURN ottica;
   END;

/*****************************************************************************
    NOME:        inizializza_utente.
    DESCRIZIONE: Riempi la plsql table con utente, unita di cui fa parte, ruoli che ha
                 nelle unita'.

   INPUT  p_utente varchar2: utente che di cui si vogliono conoscere unita di appartenenza e ruoli.
          p_ret_tab Tabella completa dei dati dell'utente.

   OUTPUT 0 se p_utente nn è presente su ag_priv_utente_tmp (cioè se non ha nessun ruolo nella
            struttura organizzativa)
          1 se presente


    Rev.  Data       Autore  Descrizione.
    00    26/06/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION inizializza_utente (p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      IF NVL (bodyutente, '*') <> NVL (p_utente, '*')
      THEN
         bodyutente := p_utente;
         indiceaoo := get_indice_aoo (NULL, NULL);
         ottica := get_ottica_utente (p_utente, NULL, NULL);
      END IF;

      BEGIN
         SELECT 1
           INTO retval
           FROM ag_priv_utente_tmp
          WHERE ag_priv_utente_tmp.utente = p_utente AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END inizializza_utente;

   PROCEDURE inizializza_ag_priv_utente_tmp (p_utente VARCHAR2)
   IS
      retval   NUMBER;
   BEGIN
      retval := inizializza_utente (p_utente => p_utente);

      DELETE      ag_priv_utente_tmp
            WHERE utente = p_utente;

      riempi_unita_estese (p_utente => p_utente);
   END inizializza_ag_priv_utente_tmp;

   /*****************************************************************************
       NOME:        GET_PROTOCOLLO_PER_IDRIF.
       DESCRIZIONE: Individua il protocollo con idRif dato.

       INPUT  p_idRif varchar2 idRif del protocollo .
      RITORNO:  id_documento del protocollo con p_idrif.

       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_protocollo_per_idrif (p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      retval        NUMBER;
      indiceaoo     NUMBER                 := 1;
      unitacarico   seg_unita.unita%TYPE;
      indiceriga    NUMBER                 := 0;
   BEGIN
      SELECT docu.id_documento
        INTO retval
        FROM documenti docu, proto_view
       WHERE docu.id_documento = proto_view.id_documento
         AND proto_view.idrif = p_idrif
         AND docu.stato_documento NOT IN ('CA', 'RE');

--      SELECT docu.id_documento
--        INTO retval
--        FROM valori valo_idrif,
--             campi_documento cado_idrif,
--             documenti docu,
--             categorie_modello camo,
--             tipi_documento tido
--       WHERE valo_idrif.valore_stringa = p_idrif
--         AND cado_idrif.nome = campo_idrif
--         AND cado_idrif.id_campo = valo_idrif.id_campo
--         AND docu.id_documento = valo_idrif.id_documento
--         AND docu.id_documento_padre IS NULL
--         AND docu.id_tipodoc = tido.id_tipodoc
--         AND tido.nome = camo.codice_modello
--         AND camo.area = docu.area
--         AND camo.categoria = 'PROTO';
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_protocollo_per_idrif;

/*****************************************************************************
    NOME:        GET_ID_DOCUMENTO.
    DESCRIZIONE: Individua il protocollo con area modello e codice richiesta dati  dato.

    INPUT  p_area                    VARCHAR2
    , p_modello                 VARCHAR2
    , p_codice_richiesta        VARCHAR2
   RITORNO:  Id del documento identificato da p_area, p_modello, p_codice_richiesta.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_id_documento (
      p_area               VARCHAR2,
      p_modello            VARCHAR2,
      p_codice_richiesta   VARCHAR2
   )
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      BEGIN
         SELECT docu.id_documento
           INTO retval
           FROM documenti docu, modelli MOD
          WHERE MOD.area = p_area
            AND MOD.codice_modello = p_modello
            AND MOD.id_tipodoc = docu.id_tipodoc
            AND docu.area = MOD.area
            AND docu.codice_richiesta = p_codice_richiesta
            AND docu.stato_documento NOT IN ('CA', 'RE');
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END get_id_documento;

/*****************************************************************************
    NOME:        GET_ID_DOCUMENTO_FASCICOLO.
    DESCRIZIONE: Individua l'id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    INPUT  p_class_cod                    VARCHAR2
    , p_class_dal                 DATE
    , p_anno        NUMBER
    , p_numero  VARCHAR2
    , p_indice_aoo number indice dell'aoo nella tabella parametri
   RITORNO:  Id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    Rev.  Data       Autore  Descrizione.
    00    03/07/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_id_documento_fascicolo (
      p_class_cod    VARCHAR2,
      p_class_dal    DATE,
      p_anno         NUMBER,
      p_numero       VARCHAR2,
      p_indice_aoo   NUMBER
   )
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      BEGIN
         SELECT docu.id_documento
           INTO retval
           FROM documenti docu, seg_fascicoli
          WHERE docu.id_documento = seg_fascicoli.id_documento
            AND docu.stato_documento NOT IN ('CA', 'RE')
            AND seg_fascicoli.class_cod = p_class_cod
            AND seg_fascicoli.class_dal = p_class_dal
            AND seg_fascicoli.fascicolo_anno = p_anno
            AND seg_fascicoli.fascicolo_numero = p_numero;
--         SELECT docu.id_documento
--           INTO retval
--           FROM documenti docu,
--                valori valo_classcod,
--                valori valo_classdal,
--                valori valo_anno,
--                valori valo_numero,
--                campi_documento cado_classcod,
--                campi_documento cado_classdal,
--                campi_documento cado_anno,
--                campi_documento cado_numero,
--                parametri pa_area,
--                parametri pa_modello,
--                modelli
--          WHERE pa_area.codice = 'AREA_M_FASCICOLO_' || p_indice_aoo
--            AND pa_area.tipo_modello = '@agVar@'
--            AND pa_modello.codice = 'MODULO_FASCICOLO_' || p_indice_aoo
--            AND pa_modello.tipo_modello = '@agVar@'
--            AND modelli.area = pa_area.valore
--            AND modelli.codice_modello = pa_modello.valore
--            AND modelli.id_tipodoc = cado_classcod.id_tipodoc
--            AND docu.id_documento = valo_classcod.id_documento
--            AND valo_classcod.id_documento = valo_classdal.id_documento
--            AND valo_classcod.id_documento = valo_anno.id_documento
--            AND valo_classcod.id_documento = valo_numero.id_documento
--            AND valo_classcod.id_campo = cado_classcod.id_campo
--            AND valo_classdal.id_campo = cado_classdal.id_campo
--            AND valo_anno.id_campo = cado_anno.id_campo
--            AND valo_numero.id_campo = cado_numero.id_campo
--            AND cado_classcod.nome = campo_class_cod
--            AND cado_classdal.nome = campo_class_dal
--            AND cado_anno.nome = campo_anno_fascicolo
--            AND cado_numero.nome = campo_numero_fascicolo
--            AND valo_classcod.valore_stringa = p_class_cod
--            AND valo_classdal.valore_data = p_class_dal
--            AND valo_anno.valore_numero = p_anno
--            AND valo_numero.valore_stringa = p_numero;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := NULL;
      END;

      RETURN retval;
   END get_id_documento_fascicolo;

/*****************************************************************************
    NOME:        GET_STATO_FASCICOLO.
    DESCRIZIONE: Individua l'id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    INPUT  p_class_cod                    VARCHAR2
    , p_class_dal                 DATE
    , p_anno        NUMBER
    , p_numero  VARCHAR2
    , p_indice_aoo number indice dell'aoo nella tabella parametri
   RITORNO:  Id del documento FASCICOLO con i parametri passati.
    ATTENZIONE: si tratta dell'id nella tabella DOCUMENTI e non dell'id della cartella.

    Rev.  Data       Autore  Descrizione.
    00    03/07/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_stato_fascicolo (
      p_class_cod    VARCHAR2,
      p_class_dal    DATE,
      p_anno         NUMBER,
      p_numero       VARCHAR2,
      p_indice_aoo   NUMBER
   )
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (200);
   BEGIN
      BEGIN
         SELECT seg_fascicoli.stato_fascicolo
           INTO retval
           FROM documenti docu, seg_fascicoli
          WHERE docu.stato_documento NOT IN ('CA', 'RE')
            AND docu.id_documento = seg_fascicoli.id_documento
            AND seg_fascicoli.class_cod = p_class_cod
            AND seg_fascicoli.class_dal = p_class_dal
            AND seg_fascicoli.fascicolo_anno = p_anno
            AND seg_fascicoli.fascicolo_numero = p_numero;
--         SELECT valo_stato.valore_stringa
--           INTO retval
--           FROM documenti docu,
--                valori valo_classcod,
--                valori valo_classdal,
--                valori valo_anno,
--                valori valo_numero,
--                valori valo_stato,
--                campi_documento cado_classcod,
--                campi_documento cado_classdal,
--                campi_documento cado_anno,
--                campi_documento cado_numero,
--                campi_documento cado_stato,
--                parametri pa_area,
--                parametri pa_modello,
--                modelli
--          WHERE pa_area.codice = 'AREA_M_FASCICOLO_' || p_indice_aoo
--            AND pa_area.tipo_modello = '@agVar@'
--            AND pa_modello.codice = 'MODULO_FASCICOLO_' || p_indice_aoo
--            AND pa_modello.tipo_modello = '@agVar@'
--            AND modelli.area = pa_area.valore
--            AND modelli.codice_modello = pa_modello.valore
--            AND modelli.id_tipodoc = cado_classcod.id_tipodoc
--            AND docu.id_documento = valo_classcod.id_documento
--            AND docu.id_documento = valo_classdal.id_documento
--            AND docu.id_documento = valo_stato.id_documento
--            AND docu.id_documento = valo_anno.id_documento
--            AND docu.id_documento = valo_numero.id_documento
--            AND valo_classcod.id_campo = cado_classcod.id_campo
--            AND valo_stato.id_campo = cado_stato.id_campo
--            AND valo_classdal.id_campo = cado_classdal.id_campo
--            AND valo_anno.id_campo = cado_anno.id_campo
--            AND valo_numero.id_campo = cado_numero.id_campo
--            AND cado_classcod.nome = campo_class_cod
--            AND cado_classdal.nome = campo_class_dal
--            AND cado_anno.nome = campo_anno_fascicolo
--            AND cado_numero.nome = campo_numero_fascicolo
--            AND cado_stato.nome = campo_stato_fascicolo
--            AND valo_classcod.valore_stringa = p_class_cod
--            AND valo_classdal.valore_data = p_class_dal
--            AND valo_anno.valore_numero = p_anno
--            AND valo_numero.valore_stringa = p_numero;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := '0';
      END;

      RETURN retval;
   END get_stato_fascicolo;

   /*****************************************************************************
    NOME:        VERIFICA_CATEGORIA_DOCUMENTO
    DESCRIZIONE: Verifica se il tipo documento del documento identificato da p_id_documento
    è di catagoria p_categoria.

   INPUT  p_id_documento: identificativo del documento di cui verificare la categoria.
         p_categoria varchar2: codice della categoria di cui si vuole vedere se p_id_documento fa parte.
   RITORNO:  1 se p_id_documento è di categoria p_categoria, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    30/05/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_categoria_documento (
      p_id_documento   VARCHAR2,
      p_categoria      VARCHAR2
   )
      RETURN NUMBER
   IS
      retval     NUMBER         := 0;
      depunita   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT 1
           INTO retval
           FROM documenti docu, tipi_documento tido, categorie_modello camo
          WHERE docu.id_documento = p_id_documento
            AND docu.id_tipodoc = tido.id_tipodoc
            AND tido.nome = camo.codice_modello
            AND camo.area = docu.area
            AND camo.categoria = p_categoria
            AND docu.stato_documento NOT IN ('CA', 'RE');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      RETURN retval;
   END verifica_categoria_documento;

   /*****************************************************************************
    NOME:        VERIFICA_PRIVILEGIO_UTENTE
    DESCRIZIONE: Verifica se l'utente ha un certo privilegio:
   Se specificata l'unita' verifica se l'utente ha un ruolo con il privilegio richiesto nell'unita'.

   INPUT  p_privilegio: codice del privilegio da verificare.
         p_utente varchar2: utente che di cui verificare il privilegio.
      p_unita  varchar2 codice dell'unita' per la quale p_utente deve avere un ruolo
      con p_privilegio.
   p_unita_ascendenti        NUMBER indica se verificare il privilegio anche sulle unita ascendenti
                                    di p_unita. Se 1 verifica le ascendenti, se 0 no.
            Ha senso solo se p_Unita non e' nulla.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_privilegio_utente (
      p_unita        VARCHAR2,
      p_privilegio   VARCHAR2,
      p_utente       VARCHAR2
   )
      RETURN NUMBER
   IS
      retval     NUMBER                 := 0;
      depunita   seg_unita.unita%TYPE;
   BEGIN
      IF p_unita IS NULL
      THEN
         BEGIN
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp
             WHERE utente = p_utente
               AND privilegio = p_privilegio
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      ELSE
         BEGIN
            SELECT 1
              INTO retval
              FROM ag_priv_utente_tmp
             WHERE utente = p_utente
               AND privilegio = p_privilegio
               AND unita = p_unita
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;

      RETURN retval;
   END verifica_privilegio_utente;

/*****************************************************************************
    NOME:        VERIFICA_UNITA_UTENTE
    DESCRIZIONE: Verifica se l'utente appartiene all'unita specificata:

   INPUT  p_utente varchar2: utente che di cui verificare l'appartenenza.
      p_unita  varchar2 codice dell'unita' cui p_utente deve appartenere.
   RITORNO:  1 se l'utente appartiene a p_untia, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_unita_utente (p_unita VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      retval := ag_utilities.inizializza_utente (p_utente => p_utente);

      BEGIN
         SELECT 1
           INTO retval
           FROM ag_priv_utente_tmp
          WHERE utente = p_utente
            AND unita = p_unita
            AND appartenenza = 'D'
            AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := 0;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      RETURN retval;
   END verifica_unita_utente;

/*****************************************************************************
    NOME:        VERIFICA_RAMO_UTENTE
    DESCRIZIONE: Verifica se l'utente appartiene ad un'unita dello stesso ramo di p_unita,
    cioè p_unita stessa o un'ascendente o una discendente.

   INPUT  p_utente varchar2: utente che di cui verificare l'appartenenza.
      p_unita  varchar2 codice dell'unita' al cui ramo p_utente deve appartenere.
   RITORNO:  1 se l'utente appartiene ad un'unita del ramo di p_unita, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_ramo_utente (p_unita VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                NUMBER                 := 0;
      unitadiscendenti      t_ref_cursor;
      unitaascendenti       t_ref_cursor;
      depunita              seg_unita.unita%TYPE;
      depdescrizioneunita   VARCHAR2 (1000);
      progressivounita      NUMBER;
      dalunita              DATE;
      alunita               DATE;
      dloop                 NUMBER                 := 0;
      depesistenew          BOOLEAN                := TRUE;
   BEGIN
      retval := verifica_unita_utente (p_unita, p_utente);

      --DBMS_OUTPUT.put_line (   'UTENTE '
--                            || p_utente
--                            || ' APPARTIENE A UNITA '
--                            || p_unita
--                            || ' ? '
--                            || retval
--                           );

      --verifica se p_utente appartiene a una unita figlia di p_unita
      IF retval = 0
      THEN
         unitadiscendenti :=
                       so4_util.unita_get_discendenti (p_unita, NULL, ottica);

         IF unitadiscendenti%ISOPEN
         THEN
            LOOP
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH unitadiscendenti
                      INTO progressivounita, depunita, depdescrizioneunita,
                           dalunita, alunita;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        -- Gestisce l'errore
                        -- ORA-06504: PL/SQL: Return types of Result Set variables or query do not match
                        -- perche' la funzione
                        IF SQLCODE = -6504
                        THEN
                           depesistenew := FALSE;

                           FETCH unitadiscendenti
                            INTO progressivounita, depunita,
                                 depdescrizioneunita, dalunita;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH unitadiscendenti
                      INTO progressivounita, depunita, depdescrizioneunita,
                           dalunita, alunita;
                  ELSE
                     FETCH unitadiscendenti
                      INTO progressivounita, depunita, depdescrizioneunita,
                           dalunita;
                  END IF;
               END IF;

               --DBMS_OUTPUT.put_line (   'sono nel loop unita discendenti '
--                                     || progressivounita
--                                    );
               EXIT WHEN unitadiscendenti%NOTFOUND OR retval = 1;
               retval := verifica_unita_utente (depunita, p_utente);
               --DBMS_OUTPUT.put_line (   'UTENTE '
--                                     || p_utente
--                                     || ' APPARTIENE A UNITA '
--                                     || depunita
--                                     || ' ? '
--                                     || retval
--                                    );
            END LOOP;

            CLOSE unitadiscendenti;
         END IF;
      END IF;

--verifica se p_utente appartiene a una unita ascendente di p_unita
      IF retval = 0
      THEN
         unitaascendenti :=
                        so4_util.unita_get_ascendenti (p_unita, NULL, ottica);

         IF unitaascendenti%ISOPEN
         THEN
            LOOP
               FETCH unitaascendenti
                INTO progressivounita, depunita, depdescrizioneunita,
                     dalunita;

               --DBMS_OUTPUT.put_line (   'sono nel loop unita ascendenti '
--                                     || progressivounita
--                                    );
               EXIT WHEN unitaascendenti%NOTFOUND OR retval = 1;
               retval := verifica_unita_utente (depunita, p_utente);
               --DBMS_OUTPUT.put_line (   'UTENTE '
--                                     || p_utente
--                                     || ' APPARTIENE A UNITA '
--                                     || depunita
--                                     || ' ? '
--                                     || retval
--                                    );
            END LOOP;

            CLOSE unitaascendenti;
         END IF;
      END IF;

      --DBMS_OUTPUT.put_line (   'UTENTE '
--                            || p_utente
--                            || ' deve vedere UNITA '
--                            || p_unita
--                            || ' ? '
--                            || retval
--                           );
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END verifica_ramo_utente;

      /*****************************************************************************
    NOME:        ABILITA
    DESCRIZIONE: Funzione per abilitare tutti gli utenti ad una fase.

   INPUT
   RITORNO:  1.

    Rev.  Data       Autore  Descrizione.
    00    05/03/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION abilita
      RETURN NUMBER
   IS
   BEGIN
      RETURN 1;
   END;

/*****************************************************************************
 NOME:        GET_ID_PROFILO.
 DESCRIZIONE: Dato l'id di view_cartella calcola l'id del profilo associato.

INPUT  p_id_viewcartella varchar2: chiave identificativa nella tabella VIEW_CARTELLA.
RITORNO: number id del profilo associato al fascicolo

 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_id_profilo (p_id_viewcartella VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      SELECT cartelle.id_documento_profilo
        INTO retval
        FROM view_cartella, cartelle
       WHERE view_cartella.id_viewcartella = p_id_viewcartella
         AND view_cartella.id_cartella = cartelle.id_cartella;

      RETURN retval;
   END get_id_profilo;

/*****************************************************************************
 NOME:        GET_ACRONIMO_TABELLA.
 DESCRIZIONE: dati area e codice modello, riceva l'acronimo della tabella orizzontale
                associata al modello.

INPUT   p_area varchar2: area.
        p_codice_modello varchar2: codice modello
RITORNO: '' se il modello non ha tabella orizzontale o non ha acronimo
         l'acronimo del modello registrato nella tabella TIPI_DOCUMENTO

 Rev.  Data       Autore  Descrizione.
 00    21/01/2009  SC  A30787.0.0.
********************************************************************************/
   FUNCTION get_acronimo_tabella (p_area VARCHAR2, p_codice_modello VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   tipi_documento.acronimo_modello%TYPE;
   BEGIN
      BEGIN
         SELECT UPPER (t.acronimo_modello)
           INTO retval
           FROM aree a, tipi_documento t
          WHERE a.area = t.area_modello
            AND a.acronimo IS NOT NULL
            AND t.alias_modello IS NOT NULL
            AND t.area_modello = p_area
            AND t.nome = p_codice_modello;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            retval := '';
      END;

      RETURN retval;
   END get_acronimo_tabella;

/*****************************************************************************
 NOME:        GET_ID_VIEW_CLASSIFICA.
 DESCRIZIONE: Individua l'id della cartella classificazione identificata da codice e data
 di inizio validita, da esso trova il corrispondente id_view_cartella e lo restituisce.

INPUT  p_class_cod VARCHAR2, p_class_dal date: codice e data di inizio validita della
classifica
RITORNO: IDENTIFICATIVO DELLA CLASS DI CUI IL FASCICOLO FA PARTE IN VIEW_CARTELLA

 Rev.  Data       Autore  Descrizione.
 00    04/06/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_id_view_classifica (p_class_cod VARCHAR2, p_class_dal DATE)
      RETURN NUMBER
   IS
      idviewclas   NUMBER;
   BEGIN
      SELECT vica.id_viewcartella
        INTO idviewclas
        FROM cartelle cart,
             documenti docu,
             seg_classificazioni,
             view_cartella vica
       WHERE docu.stato_documento NOT IN ('CA', 'RE')
         AND docu.id_documento = seg_classificazioni.id_documento
         AND seg_classificazioni.class_cod = p_class_cod
         AND seg_classificazioni.class_dal = p_class_dal
         AND cart.id_documento_profilo = docu.id_documento
         AND vica.id_cartella = cart.id_cartella;

--      SELECT vica.id_viewcartella
--        INTO idviewclas
--        FROM cartelle cart,
--             documenti docu,
--             valori valo_cod,
--             valori valo_dal,
--             campi_documento cado_cod,
--             campi_documento cado_dal,
--             tipi_documento tido,
--             view_cartella vica
--       WHERE tido.nome = 'DIZ_CLASSIFICAZIONE'
--         AND tido.id_tipodoc = docu.id_tipodoc
--         AND docu.id_documento = valo_cod.id_documento
--         AND valo_cod.id_documento = valo_dal.id_documento
--         AND cado_cod.id_tipodoc = docu.id_tipodoc
--         AND cado_cod.nome = 'CLASS_COD'
--         AND cado_cod.id_tipodoc = cado_dal.id_tipodoc
--         AND cado_dal.nome = 'CLASS_DAL'
--         AND valo_cod.id_campo = cado_cod.id_campo
--         AND valo_dal.id_campo + 0 = cado_dal.id_campo
--         AND valo_cod.valore_stringa = p_class_cod
--         AND valo_dal.valore_data + 0 = p_class_dal
--         AND cart.id_documento_profilo = docu.id_documento
--         AND vica.id_cartella = cart.id_cartella;
      RETURN idviewclas;
   END get_id_view_classifica;

      /*****************************************************************************
    NOME:        GET_DATA_BLOCCO.
    DESCRIZIONE: Restituisce il valore di PARAMETRI DATA_BLOCCO_n dove n è l'indice dell'aoo
    indicata.
    Se non presente o null restiscuire 01/01/1900.
    In caso di errore restiscuire 31/12/2999.

   INPUT  p_CODICE_AMMINISTRAZIONE VARCHAR2, p_CODICE_AOO VARCHAR2
   RITORNO:valore di PARAMETRI DATA_BLOCCO_n

    Rev.  Data       Autore  Descrizione.
    00    04/06/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_data_blocco (
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   )
      RETURN DATE
   IS
      datablocco   DATE;
   BEGIN
      BEGIN
         SELECT TO_DATE (NVL (MAX (valore), '01/01/1900'), 'DD/MM/YYYY')
           INTO datablocco
           FROM parametri
          WHERE codice =
                      'DATA_BLOCCO_'
                   || ag_utilities.get_indice_aoo (p_codice_amministrazione,
                                                   p_codice_aoo
                                                  )
            AND tipo_modello = '@agVar@';
      EXCEPTION
         WHEN OTHERS
         THEN
            datablocco := TO_DATE ('31/12/2999', 'DD/MM/YYYY');
      END;

      RETURN datablocco;
   END get_data_blocco;

   PROCEDURE valorizza_aoo (
      p_table_name               VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   )
   IS
/******************************************************************************
   NAME:       VALORIZZA_AOO
   PURPOSE: Valorizzare i campi codice_Amministrazione e codice_aoo in p_table_name
   se nulli. I valori che verranno messi sono p_codice_amministrazione e p_codice_aoo.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/02/2008          1. Created this procedure. A25801.

******************************************************************************/
      righe                afc.t_ref_cursor;
      d_statement          afc.t_statement;
      d_update_statement   afc.t_statement;
      dep_id_documento     NUMBER;
      conta                NUMBER           := 0;
   BEGIN
      d_statement :=
            'SELECT ID_DOCUMENTO FROM '
         || p_table_name
         || ' WHERE CODICE_AMMINISTRAZIONE IS NULL AND CODICE_AOO IS NULL';

      OPEN righe FOR d_statement;

      --righe := afc_dml.get_ref_cursor (d_statement);
      IF righe%ISOPEN
      THEN
         LOOP
            FETCH righe
             INTO dep_id_documento;

            EXIT WHEN righe%NOTFOUND;
            --DBMS_OUTPUT.put_line ('ID ' || dep_id_documento);
            conta := conta + 1;
            d_update_statement :=
                  'UPDATE '
               || p_table_name
               || ' SET CODICE_AMMINISTRAZIONE = '''
               || p_codice_amministrazione
               || ''' ,'
               || '     CODICE_AOO = '''
               || p_codice_aoo
               || ''' '
               || ' where id_documento = '
               || dep_id_documento;
            afc.sql_execute (d_update_statement);

            IF conta = 100
            THEN
               COMMIT;
               --DBMS_OUTPUT.put_line ('----SIAMO A 100!!!----');
               conta := 0;
            END IF;
         END LOOP;

         COMMIT;
      --DBMS_OUTPUT.put_line ('----FINE!!!----');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         -- Consider logging the error and then re-raise
         RAISE;
   END valorizza_aoo;

   /*****************************************************************************
    NOME:        GET_DEFAULT_TIPO_SMISTAMENTO.
    DESCRIZIONE: Dato un modello, restituisce il tipo smistamento di default
    tra quelli possibili per il modello.
    Il tipo smistamento di default è quello con predominanza maggiore,
    cioè col valore minore in AG_TIPI_SMISTAMENTO.IMPORTANZA.


   INPUT  p_CODICE_AMMINISTRAZIONE VARCHAR2, p_CODICE_AOO VARCHAR2 chiave dell'aoo attiva
            p_area , p_codice_modello chiave identificativa del modello
   RITORNO:valore di PARAMETRI DATA_BLOCCO_n

    Rev.  Data       Autore  Descrizione.
    00    10/03/2008  SC  Prima emissione. A
   ********************************************************************************/
   FUNCTION get_default_tipo_smistamento (
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2,
      p_area                     VARCHAR2,
      p_codice_modello           VARCHAR2
   )
      RETURN VARCHAR2
   IS
      retval   ag_tipi_smistamento.tipo_smistamento%TYPE;
   BEGIN
      SELECT tsmo.tipo_smistamento
        INTO retval
        FROM ag_tipi_smistamento_modello tsmo, ag_tipi_smistamento tism
       WHERE tsmo.aoo =
                ag_utilities.get_indice_aoo (p_codice_amministrazione,
                                             p_codice_aoo
                                            )
         AND tsmo.area = p_area
         AND tsmo.codice_modello = p_codice_modello
         AND tsmo.tipo_smistamento = tism.tipo_smistamento
         AND tsmo.aoo = tism.aoo
         AND importanza <=
                (SELECT MIN (importanza)
                   FROM ag_tipi_smistamento, ag_tipi_smistamento_modello
                  WHERE ag_tipi_smistamento.aoo = tism.aoo
                    AND ag_tipi_smistamento.aoo =
                                               ag_tipi_smistamento_modello.aoo
                    AND ag_tipi_smistamento_modello.area = tsmo.area
                    AND ag_tipi_smistamento_modello.codice_modello =
                                                           tsmo.codice_modello
                    AND ag_tipi_smistamento_modello.tipo_smistamento =
                                          ag_tipi_smistamento.tipo_smistamento);

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   /*****************************************************************************
    NOME:        ESISTE_CATEGORIA.
    DESCRIZIONE: Verifica se esiste P_CATEGORIA e se ha almeno un modello associato.


   INPUT  P_CATEGORIA VARCHAR2 codice della categoria
   RITORNO:1 se la categoria esiste e ha almeno un modello associato,
           0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    23/05/2008  SC  Prima emissione. A27569.0.0
   ********************************************************************************/
   FUNCTION esiste_categoria (p_categoria VARCHAR2)
      RETURN NUMBER
   IS
      tmpvar   NUMBER;
   BEGIN
      SELECT DISTINCT 1
                 INTO tmpvar
                 FROM categorie_modello
                WHERE categoria = p_categoria;

      RETURN tmpvar;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         tmpvar := 0;
         RETURN tmpvar;
   END;

   /*****************************************************************************
    NOME:        DOCUMENTO_IS_IN_CATEGORIA.
    DESCRIZIONE: Verifica se p_id_documento appartiene a P_CATEGORIA.


   INPUT    P_ID_DOCUMENTO id del documento di cui si deve verificare l'appartenenza
            a P_CATEGORIA
            P_CATEGORIA VARCHAR2 codice della categoria
   RITORNO:1 se p_id_documento appartiene a p_categoria,
           0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    09/06/2008  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION documento_is_in_categoria (
      p_id_documento   NUMBER,
      p_categoria      VARCHAR2
   )
      RETURN NUMBER
   IS
      tmpvar   NUMBER;
   BEGIN
      SELECT DISTINCT 1
                 INTO tmpvar
                 FROM documenti, tipi_documento, categorie_modello, categorie
                WHERE id_documento = p_id_documento
                  AND stato_documento NOT IN ('CA', 'RE')
                  AND tipi_documento.area_modello = documenti.area
                  AND tipi_documento.id_tipodoc = documenti.id_tipodoc
                  AND tipi_documento.nome = categorie_modello.codice_modello
                  AND tipi_documento.area_modello = categorie_modello.area
                  AND categorie.categoria = p_categoria
                  AND categorie_modello.categoria = categorie.categoria;

      RETURN tmpvar;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         tmpvar := 0;
         RETURN tmpvar;
   END;

   /*****************************************************************************
    NOME:        GET_CATEGORIA_DELIBERE.
    DESCRIZIONE: Restituisce il codice della categoria delle delibere


   INPUT
   RITORNO:ag_utilities.categoriadelibere

    Rev.  Data       Autore  Descrizione.
    00    09/06/2008  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_categoria_delibere
      RETURN VARCHAR2
   IS
      tmpvar   VARCHAR2 (100);
   BEGIN
      RETURN ag_utilities.categoriadelibere;
   END;

   /*****************************************************************************
    NOME:        GET_CATEGORIA_DETERMINE.
    DESCRIZIONE: Restituisce il codice della categoria delle determine


   INPUT
   RITORNO:ag_utilities.categoriadetermine

    Rev.  Data       Autore  Descrizione.
    00    09/06/2008  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION get_categoria_determine
      RETURN VARCHAR2
   IS
      tmpvar   VARCHAR2 (100);
   BEGIN
      RETURN ag_utilities.categoriadetermine;
   END;

   /*****************************************************************************
       NOME:        GET_UNITA_RADICE.
       DESCRIZIONE: Dato il codice di un'unita, data di riferimento e ottica,
        cerca tra le unita ascendenti quella che non ha padre.

       INPUT  p_codice_unita varchar2 CODICE UNITA DI CUI CERCARE LA RADICE .
       p_data_riferimento data di validita delle unita.
       p_ottica OTTICA DI SO4 DA UTILIZZARE.
      RITORNO:  codice dell'unita tra le unita ascendenti di p_codice_unita
      quella che non ha padre.

       Rev.  Data       Autore  Descrizione.
       00    04/09/2008  SC  Prima emissione. A28345.2.0
   ********************************************************************************/
   FUNCTION get_unita_radice (
      p_codice_unita       VARCHAR2,
      p_data_riferimento   DATE,
      p_ottica             VARCHAR2
   )
      RETURN VARCHAR2
   IS
      cascendenti              afc.t_ref_cursor;
      depprogr                 NUMBER;
      dep_codice_unita_padre   seg_unita.unita%TYPE;
      depdescrizioneunita      VARCHAR2 (1000);
      dep_dal_padre            DATE;
      dep_al_padre             DATE;
   BEGIN
      NULL;
      cascendenti :=
         so4_util.unita_get_ascendenti (p_codice_unita,
                                        p_data_riferimento,
                                        p_ottica
                                       );

      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
             INTO depprogr, dep_codice_unita_padre, depdescrizioneunita,
                  dep_dal_padre, dep_al_padre;

            EXIT WHEN cascendenti%NOTFOUND;
--dbms_output.put_line(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
--                  p_dal_padre||', '||p_al_padre);
         END LOOP;

         CLOSE cascendenti;
      END IF;

      RETURN dep_codice_unita_padre;
   END get_unita_radice;

   /*****************************************************************************
       NOME:        GET_UNITA_RADICE_AREA.
       DESCRIZIONE: Dato il codice di un'unita, data di riferimento e ottica,
        cerca tra le unita ascendenti quella che rappresenta la radice dell'area
        di p_codice_unita.

        Per radice di area, se ag_suddivisioni non contiene righe si considera
        l'unità che non ha padre.
        Se ag_suddivisioni contiene righe, l'unità di area è la prima
        ascendente di p_codice_unita (lei compresa) la cui suddivisione
        è presente in ag_suddivisioni.

       INPUT  p_codice_unita varchar2 CODICE UNITA DI CUI CERCARE LA RADICE .
       p_data_riferimento data di validita delle unita.
       p_ottica OTTICA DI SO4 DA UTILIZZARE.
      RITORNO:  codice dell'unita tra le unita ascendenti di p_codice_unita
      quella che non ha padre.

       Rev.  Data       Autore  Descrizione.
       00    15/02/2010  SC  Prima emissione. A34954.2.0
   ********************************************************************************/
   FUNCTION get_unita_radice_area (
      p_codice_unita             VARCHAR2,
      p_data_riferimento         DATE,
      p_ottica                   VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   )
      RETURN VARCHAR2
   IS
      cascendenti              afc.t_ref_cursor;
      depprogr                 NUMBER;
      dep_codice_unita_padre   seg_unita.unita%TYPE;
      depdescrizioneunita      VARCHAR2 (1000);
      dep_dal_padre            DATE;
      dep_al_padre             DATE;
      suddivisione_presente    NUMBER                 := 0;
      dep_suddivisione         NUMBER;
   BEGIN
      NULL;
      cascendenti :=
         so4_util.unita_get_ascendenti_sudd (p_codice_unita,
                                             p_data_riferimento,
                                             p_ottica
                                            );

      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
             INTO depprogr, dep_codice_unita_padre, depdescrizioneunita,
                  dep_dal_padre, dep_al_padre, dep_suddivisione;

            BEGIN
               SELECT 1
                 INTO suddivisione_presente
                 FROM ag_suddivisioni
                WHERE dep_suddivisione = id_suddivisione
                  AND indice_aoo =
                         ag_utilities.get_indice_aoo
                                                    (p_codice_amministrazione,
                                                     p_codice_aoo
                                                    );
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            EXIT WHEN cascendenti%NOTFOUND OR suddivisione_presente = 1;
--dbms_output.put_line(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
--                  p_dal_padre||', '||p_al_padre);
         END LOOP;

         CLOSE cascendenti;
      END IF;

      RETURN dep_codice_unita_padre;
   END get_unita_radice_area;

   /*****************************************************************************
       NOME:        GET_UNITA_RADICE.
       DESCRIZIONE: Dati utente e privilegio, restituisce il cursore dei codici
       delle unita per cui l'utente ha il privilegio.

       INPUT  p_utente varchar2 CODICE UTENTE .
       p_privilegio codice privilegio.
      RITORNO:  cursore delle unita per le quali p_utente ha p_privilegio.

       Rev.  Data       Autore  Descrizione.
       00    04/09/2008  SC  Prima emissione. A28345.2.0
   ********************************************************************************/
   FUNCTION get_unita_priviegio_utente (
      p_utente       VARCHAR2,
      p_privilegio   VARCHAR2
   )
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      --DBMS_OUTPUT.put_line ('get_unita_priviegio_utente ');
      OPEN d_result FOR
         SELECT DISTINCT ag_priv_utente_tmp.unita, ag_priv_utente_tmp.dal,
                         ag_priv_utente_tmp.al
                    FROM ag_priv_utente_tmp
                   WHERE ag_priv_utente_tmp.utente = p_utente
                     AND privilegio = p_privilegio;

      --DBMS_OUTPUT.put_line ('get_unita_priviegio_utente p_utente ' || p_utente);
      --DBMS_OUTPUT.put_line (   'get_unita_priviegio_utente p_privilegio '
--                            || p_privilegio
--                           );
      RETURN d_result;
   END;

   /*****************************************************************************
       NOME:        documento_get_descrizione.

       DESCRIZIONE: Restituisce una stringa con i dati più significativi del
                    documento identificato da p_id_documento registrato nella
                    proto_view

       INPUT        p_id_documento

      RITORNO:

       Rev.  Data        Autore  Descrizione.
       00    10/09/2008  SN      Prima emissione.
       01    05/02/2009  SC      A31179.2.0 Evita documenti cancellati e
                                  prende solo registri della stessa aoo del protocollo.
   ********************************************************************************/
   FUNCTION documento_get_descrizione (p_id_documento IN VARCHAR2)
      RETURN VARCHAR2
   IS
      d_estremi_documento   VARCHAR2 (32767);
   BEGIN
      SELECT    sere.descrizione_tipo_registro
             || DECODE (prot.numero,
                        NULL, NULL,
                           ' n. '
                        || prot.numero
                        || ' del '
                        || TO_CHAR (prot.DATA, 'dd/mm/yyyy')
                       )
             || ' - Oggetto: '
             || prot.oggetto
        INTO d_estremi_documento
        FROM seg_registri sere,
             proto_view prot,
             documenti dreg,
             documenti dpro
       WHERE sere.anno_reg = prot.anno
         AND sere.tipo_registro = prot.tipo_registro
         AND prot.id_documento = TO_NUMBER (p_id_documento)
         AND prot.id_documento = dpro.id_documento
         AND dpro.stato_documento NOT IN ('CA', 'RE')
         AND sere.id_documento = dreg.id_documento
         AND dreg.stato_documento NOT IN ('CA', 'RE')
         AND sere.codice_aoo = prot.codice_aoo
         AND sere.codice_amministrazione = prot.codice_amministrazione;

      RETURN d_estremi_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error
                               (-20999,
                                   'ag_utilities.documento_get_descrizione: '
                                || SQLERRM
                               );
   END;

   /*****************************************************************************
       NOME:        get_defaultAooIndex

       DESCRIZIONE: Restituisce l'indice di default dell'AOO correntemente attiva

      RITORNO:

       Rev.  Data        Autore  Descrizione.
       00    29/09/2008  SN      Prima emissione.
   ********************************************************************************/
   FUNCTION get_defaultaooindex
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '1';
   END;

/*****************************************************************************
    NOME:        GET_RESPONSABILE_PRIVILEGIO
    DESCRIZIONE: Resituisce il primo responsabile (se esiste) di una unita
                    che gode di uno specifico privilegio.

   INPUT
   p_codice_uo      VARCHAR2
   p_privilegio     VARCHAR2
   p_cod_amm        VARCHAR2
   p_cod_aoo        VARCHAR2

    Rev.  Data       Autore  Descrizione.
    00    22/10/2008  AM  Prima emissione Creazione installanti.
   ********************************************************************************/
   FUNCTION get_responsabile_privilegio (
      p_codice_uo    VARCHAR2,
      p_privilegio   VARCHAR2,
      p_cod_amm      VARCHAR2,
      p_cod_aoo      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      d_ottica         VARCHAR2 (18);
      d_ni             NUMBER;
      d_descr          VARCHAR2 (400);
      d_nome_utente    VARCHAR2 (50);
      d_check_utente   NUMBER;
      retval           sys_refcursor;
   BEGIN
      d_ottica :=
         ag_utilities.get_ottica_aoo (ag_utilities.get_indice_aoo (p_cod_amm,
                                                                   p_cod_aoo
                                                                  )
                                     );
      retval :=
         so4.so4_util.unita_get_responsabile (NULL,
                                              p_codice_uo,
                                              d_ottica,
                                              NULL,
                                              NULL
                                             );

      LOOP
         FETCH retval
          INTO d_ni, d_descr;

         EXIT WHEN retval%NOTFOUND;

         IF (d_ni IS NOT NULL)
         THEN
            d_nome_utente := so4_util.comp_get_utente (d_ni);

            IF (d_descr IS NOT NULL AND LENGTH (d_nome_utente) > 0)
            THEN
               IF (ag_utilities.verifica_privilegio_utente (p_codice_uo,
                                                            p_privilegio,
                                                            d_nome_utente
                                                           ) = 1
                  )
               THEN
                  CLOSE retval;

                  RETURN d_nome_utente;
--
               END IF;
            END IF;
         END IF;
      END LOOP;

      CLOSE retval;

      RETURN '';
   END;

   /*****************************************************************************
      NOME:        RiPRISTINA_ULTIMO
      DESCRIZIONE:  quando si cancella una cartella parte un trigger che richiama questa funzione
      per decrementare l'ultimo numero sub nella tabella seg_fascicoli o nella seg_numerazioni_classifica

     INPUT
     new_id_documento_profilo      VARCHAR2

     output
     NUMBER   1 se va a buon fine 0 altrimenti

      Rev.  Data       Autore  Descrizione.
      00    17/02/2009  AM  Prima emissione A25616.0.0.
     ********************************************************************************/
   FUNCTION ripristina_ultimo (new_id_documento_profilo VARCHAR2)
      RETURN NUMBER
   IS
      d_ret         NUMBER        := 0;
      d_esiste      VARCHAR2 (20) := '';
      d_pos         NUMBER        := -1;
      d_numero      VARCHAR2 (20) := '';
      d_id_doc      VARCHAR2 (20) := '';
      d_last_fasc   VARCHAR2 (20) := '';
      d_prev_fasc   VARCHAR2 (20) := '';
   BEGIN
      DBMS_OUTPUT.put_line ('PRIMA della SELECT');

      SELECT fascicolo_numero
        INTO d_numero
        FROM seg_fascicoli f
       WHERE f.id_documento = new_id_documento_profilo;

      DBMS_OUTPUT.put_line ('d_numero:= ' || d_numero);
      d_pos := INSTR (d_numero, '.', -1);
      d_prev_fasc := SUBSTR (d_numero, 1, d_pos - 1);
      d_last_fasc := SUBSTR (d_numero, d_pos + 1);

      IF (d_pos > 0)
      THEN
         DBMS_OUTPUT.put_line (   'SUBFASCICOLO '
                               || new_id_documento_profilo
                               || '#'
                               || d_prev_fasc
                              );

         SELECT f2.id_documento
           INTO d_id_doc
           FROM seg_fascicoli f1, seg_fascicoli f2, cartelle ca
          WHERE f1.id_documento = new_id_documento_profilo
            AND f2.class_cod = f1.class_cod
            AND f2.class_dal = f1.class_dal
            AND f2.fascicolo_numero = d_prev_fasc
            AND f2.fascicolo_anno = f1.fascicolo_anno
            AND ca.id_documento_profilo = f2.id_documento
            AND NVL (ca.stato, ' ') <> 'CA';

         UPDATE seg_fascicoli
            SET ultimo_numero_sub = ultimo_numero_sub - 1
          WHERE id_documento = d_id_doc AND ultimo_numero_sub = d_last_fasc;

         d_ret := 1;
      ELSE
         DBMS_OUTPUT.put_line ('FASCICOLO');

         FOR n IN (SELECT   nucl.id_documento, nucl.anno
                       FROM seg_classificazioni clas,
                            seg_fascicoli fasc,
                            cartelle cart,
                            seg_numerazioni_classifica nucl,
                            documenti docu_nucl,
                            documenti docu_clas
                      WHERE fasc.id_documento = new_id_documento_profilo
                        AND clas.class_cod = fasc.class_cod
                        AND clas.class_dal = fasc.class_dal
                        AND cart.id_documento_profilo = clas.id_documento
                        AND NVL (cart.stato, ' ') <> 'CA'
                        AND docu_clas.id_documento = clas.id_documento
                        AND docu_clas.stato_documento NOT IN ('CA', 'RE')
                        AND docu_nucl.id_documento = nucl.id_documento
                        AND docu_nucl.stato_documento NOT IN ('CA', 'RE')
                        AND clas.class_cod = nucl.class_cod
                        AND clas.class_dal = nucl.class_dal
                        AND DECODE (clas.num_illimitata,
                                    'Y', nucl.anno,
                                    fasc.fascicolo_anno
                                   ) = nucl.anno
                   ORDER BY nucl.anno DESC)
         LOOP
            -- La riga di seg_numerazioni_classifica  di cui
            -- interessa portare indietro il numero e'
            -- quella del fascicolo, se la classificazione NON ha numerazione
            -- illimitata, altrimenti è il max(numerazione_classifica.anno).
            UPDATE seg_numerazioni_classifica nucl
               SET nucl.ultimo_numero_sub = nucl.ultimo_numero_sub - 1
             WHERE nucl.id_documento = n.id_documento
               AND ultimo_numero_sub = d_last_fasc;

            EXIT;
         END LOOP;

         d_ret := 1;
      END IF;

      RETURN d_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         DBMS_OUTPUT.put_line ('no data found');
         -- Consider logging the error and then re-raise
         RETURN 0;
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('OTHERS');
         -- Consider logging the error and then re-raise
         RETURN 0;
   END ripristina_ultimo;

   /*****************************************************************************
    NOME:        INIT_AG_PRIV_UTENTE_LOGIN
    DESCRIZIONE:  quando si cancella una cartella parte un trigger che richiama questa funzione
    per decrementare l'ultimo numero sub nella tabella seg_fascicoli o nella seg_numerazioni_classifica

   INPUT
   p_utente     VARCHAR2
   p_db_user    VARCHAR2
   p_tipo       VARCHAR2

   output
   NUMBER   1 se va a buon fine 0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    22/05/2009  AM  Prima emissione A25616.0.0.
   ********************************************************************************/
   PROCEDURE init_ag_priv_utente_login (
      p_utente    VARCHAR2,
      p_db_user   VARCHAR2,
      p_tipo      VARCHAR2
   )
   IS
      retval   NUMBER;
   BEGIN
      IF UPPER (p_db_user) IN ('GDM', 'DBFW') AND UPPER (p_tipo) = 'LOGON'
      THEN
         inizializza_ag_priv_utente_tmp (p_utente);
      END IF;
   END init_ag_priv_utente_login;

   /*****************************************************************************
    NOME:        IS_UNITA_IN_AREA
    DESCRIZIONE:  Verifica se p_codice_unita è discendente di p_codice_area.

   INPUT
   p_codice_area     VARCHAR2 codice unità radice di area
   p_codice_unita    VARCHAR2 codice unità di cui si deve verificare se sta nell'
                            area di p_codice_area.
   p_data            DATE   Data di riferimento in cui viene chiesta la struttura.
   p_ottica          VARCHAR2 ottica delle unità.
   output
   NUMBER   1 se va a buon fine 0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    09/03/2010  SC  Prima emissione A34954.5.1 D1039.
   ********************************************************************************/
   FUNCTION is_unita_in_area (
      p_codice_area    VARCHAR2,
      p_codice_unita   VARCHAR2,
      p_data           DATE,
      p_ottica         VARCHAR2
   )
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      DECLARE
         dep_progr_figlio         NUMBER;
         dep_codice_figlio        VARCHAR2 (1000);
         dep_descrizione_figlio   VARCHAR2 (32000);
         dep_dal_figlio           DATE;
         dep_al_figlio           DATE;
         v_cur                    afc.t_ref_cursor;
         dloop                    NUMBER           := 0;
         depesistenew             BOOLEAN          := TRUE;
      BEGIN
         v_cur :=
            so4_util.unita_get_discendenti (p_codice_uo      => p_codice_area,
                                            p_data           => p_data,
                                            p_ottica         => p_ottica
                                           );

         IF v_cur%ISOPEN
         THEN
            LOOP
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH v_cur
                      INTO dep_progr_figlio, dep_codice_figlio,
                           dep_descrizione_figlio, dep_dal_figlio,
                           dep_al_figlio;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        -- Gestisce l'errore
                        -- ORA-06504: PL/SQL: Return types of Result Set variables or query do not match
                        -- perche' la funzione
                        IF SQLCODE = -6504
                        THEN
                           depesistenew := FALSE;

                           FETCH v_cur
                            INTO dep_progr_figlio, dep_codice_figlio,
                                 dep_descrizione_figlio, dep_dal_figlio;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH v_cur
                      INTO dep_progr_figlio, dep_codice_figlio,
                           dep_descrizione_figlio, dep_dal_figlio,
                           dep_al_figlio;
                  ELSE
                     FETCH v_cur
                      INTO dep_progr_figlio, dep_codice_figlio,
                           dep_descrizione_figlio, dep_dal_figlio;
                  END IF;
               END IF;

               EXIT WHEN v_cur%NOTFOUND OR ret = 1;

               IF dep_codice_figlio = p_codice_unita
               THEN
                  ret := 1;
               END IF;
            END LOOP;

            IF v_cur%ISOPEN
            THEN
               CLOSE v_cur;
            END IF;
         END IF;
      END;

      RETURN ret;
   END is_unita_in_area;
END;
/
