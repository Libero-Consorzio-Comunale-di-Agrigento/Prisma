--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_utilities
AS
   /******************************************************************************
      NAME:       AG_UTILITIES
      PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
      REVISIONS:
      Ver       Date        Author          Description
      ----  ----------  ------------ --------------------------------------------
      00    03/10/2006               Created this package.
      01    23/05/2011  MMalferrari  Aggiunta funzione versione
      02    09/03/2012  MMalferrari  Aggiunto parametro p_dal alla funzione
                                     verifica_unita_utente.
      03    08/05/2013  MMalferrari  Aggiunto parametro p_calcola_estensioni
                                     alla procedura inizializza_ag_priv_utente_tmp
      04    17/11/2014  MMalferrari  Aggiunto parametro p_data alla funzione
                                     verifica_privilegio_casella.
      05    14/08/2015  MMalferrari  Aggiunta funzione is_doc_da_fasc.
      06    24/11/2015  MMalferrari  Aggiunta funzione is_prot_doc_esterni
      07    04/05/2016  MMalferrari  Aggiunta funzione is_protocollo
            27/04/2017  SC           CAMBIATE INTERFACCE E DEFAULT
   ******************************************************************************/
   s_revisione                   afc.t_revision := 'V1.07';
   storicoruoli                  VARCHAR2 (1);
   servletVisualizza             VARCHAR2(100) := '/jdms/common/ServletVisualizza.do?';

   FUNCTION versione
      RETURN VARCHAR2;

   campo_data_protocollo         VARCHAR2 (50) := 'DATA';
   campo_idrif                   VARCHAR2 (5) := 'IDRIF';
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
   smistamento_storico           VARCHAR2 (1) := 'F';
   smistamento_in_carico         VARCHAR2 (1) := 'C';
   smistamento_eseguito          VARCHAR2 (1) := 'E';
   smistamento_da_ricevere       VARCHAR2 (1) := 'R';
   indiceaoo                     VARCHAR2 (10) := 1;
   ottica                        VARCHAR2 (18);
   categoriaprotocollo           VARCHAR2 (5) := 'PROTO';
   categoriadelibere             VARCHAR2 (5) := 'DELI';
   categoriadetermine            VARCHAR2 (5) := 'DETE';
   campo_class_cod               VARCHAR2 (50) := 'CLASS_COD';
   campo_class_dal               VARCHAR2 (50) := 'CLASS_DAL';
   campo_anno_fascicolo          VARCHAR2 (50) := 'FASCICOLO_ANNO';
   campo_numero_fascicolo        VARCHAR2 (50) := 'FASCICOLO_NUMERO';
   campo_stato_fascicolo         VARCHAR2 (50) := 'STATO_FASCICOLO';
   stato_corrente                VARCHAR2 (50) := '1';
   stato_deposito                VARCHAR2 (50) := '2';
   stato_storico                 VARCHAR2 (50) := '3';

   utente_superuser_segreteria   VARCHAR2 (8) := 'RPI';
   privilegio_smistaarea         VARCHAR2 (20) := 'SMISTAAREA';
   privilegio_casella_ist        VARCHAR2 (20) := 'PMAILI';
   privilegio_casella_unita      VARCHAR2 (20) := 'PMAILU';
   privilegio_tutte_caselle      VARCHAR2 (20) := 'PMAILT';

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
   FUNCTION is_iter_fascicoli_attivo
      RETURN NUMBER;

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
   FUNCTION get_id_documento (p_area                VARCHAR2,
                              p_modello             VARCHAR2,
                              p_codice_richiesta    VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_ottica_utente (p_utente        VARCHAR2,
                               p_codice_amm    VARCHAR2,
                               p_codice_aoo    VARCHAR2)
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
   FUNCTION verifica_privilegio_utente (p_unita         VARCHAR2,
                                        p_privilegio    VARCHAR2,
                                        p_utente        VARCHAR2,
                                        p_data          DATE default null)
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

       Rev.  Data       Autore         Descrizione.
       00    02/01/2007  SC            Prima emissione.
       02    09/03/2012  MMalferrari   Aggiunto parametro p_dal.
      ********************************************************************************/
   FUNCTION verifica_unita_utente (p_unita     VARCHAR2,
                                   p_utente    VARCHAR2,
                                   p_dal       DATE DEFAULT TRUNC (SYSDATE) /*NULL*/
                                                                           )
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

   FUNCTION verifica_categoria_documento (p_area         VARCHAR2,
                                          p_cm           VARCHAR2,
                                          p_cr           VARCHAR2,
                                          p_categoria    VARCHAR2)
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
      p_id_documento        VARCHAR2,
      p_categoria           VARCHAR2,
      p_check_cancellato    NUMBER DEFAULT 1)
      RETURN NUMBER;

   /*****************************************************************************
    NOME:        inizializza_utente
    DESCRIZIONE: Aggiorna ag_priv_utente_tmp per p_utente.
    La funzione viene lanciata ad ogni login dell'utente.

   INPUT  p_utente: codice utente.

    Rev.  Data       Autore  Descrizione.
    00    30/05/2007  SC  Prima emissione.
   ********************************************************************************/
   PROCEDURE inizializza_ag_priv_utente_tmp (
      p_utente                VARCHAR2,
      p_calcola_estensioni    NUMBER DEFAULT 1);

   PROCEDURE riempi_ag_priv_utente_tmp;

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
   FUNCTION get_unita_privilegio (
      p_utente        VARCHAR2,
      p_privilegio    VARCHAR2,
      p_data          DATE DEFAULT TRUNC (SYSDATE))
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
   FUNCTION inizializza_utente (p_utente    VARCHAR2,
                                p_data      DATE DEFAULT TRUNC (SYSDATE) /*NULL*/
                                                                        )
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
   FUNCTION get_stato_fascicolo (p_class_cod     VARCHAR2,
                                 p_class_dal     DATE,
                                 p_anno          NUMBER,
                                 p_numero        VARCHAR2,
                                 p_indice_aoo    NUMBER)
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
   FUNCTION get_id_documento_fascicolo (p_class_cod     VARCHAR2,
                                        p_class_dal     DATE,
                                        p_anno          NUMBER,
                                        p_numero        VARCHAR2,
                                        p_indice_aoo    NUMBER)
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
   FUNCTION get_data_blocco (p_codice_amministrazione    VARCHAR2,
                             p_codice_aoo                VARCHAR2)
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
   PROCEDURE valorizza_aoo (p_table_name                VARCHAR2,
                            p_codice_amministrazione    VARCHAR2,
                            p_codice_aoo                VARCHAR2);

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
      p_codice_amministrazione    VARCHAR2,
      p_codice_aoo                VARCHAR2,
      p_area                      VARCHAR2,
      p_codice_modello            VARCHAR2)
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
   FUNCTION documento_is_in_categoria (p_id_documento    NUMBER,
                                       p_categoria       VARCHAR2)
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
   FUNCTION get_unita_priviegio_utente (p_utente        VARCHAR2,
                                        p_privilegio    VARCHAR2)
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
   FUNCTION get_unita_radice (p_codice_unita        VARCHAR2,
                              p_data_riferimento    DATE,
                              p_ottica              VARCHAR2)
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
   PROCEDURE leggi_unita_radice_area (p_progr_unita                  NUMBER,
                                    p_data_riferimento             DATE,
                                    p_ottica                       VARCHAR2,
                                    p_codice_amministrazione       VARCHAR2,
                                    p_codice_aoo                   VARCHAR2,
                                    a_progr_unita_radice       OUT NUMBER,
                                    a_codice_unita_radice      OUT VARCHAR2);



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
   FUNCTION get_responsabile_privilegio (p_codice_uo     VARCHAR2,
                                         p_privilegio    VARCHAR2,
                                         p_cod_amm       VARCHAR2,
                                         p_cod_aoo       VARCHAR2)
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
   PROCEDURE init_ag_priv_utente_login (p_utente     VARCHAR2,
                                        p_db_user    VARCHAR2,
                                        p_tipo       VARCHAR2);

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
   FUNCTION is_unita_in_area (p_codice_area     VARCHAR2,
                              p_codice_unita    VARCHAR2,
                              p_data            DATE,
                              p_ottica          VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_unita_in_area (p_progr_area     NUMBER,
                              p_progr_unita    NUMBER,
                              p_data           DATE,
                              p_ottica         VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************************
       NOME:        del_iter_chiusi.
       DESCRIZIONE: Elimina gli iter chiusi da un numerodi giorni salvato in
                   parametro GG_DEL_ITER_n @agVar@
       EPAREA.


      INPUT


       Rev.  Data       Autore  Descrizione.
       00    22/04/2010  SC  A37575.0.0  Prima emissione.
      ********************************************************************************/
   PROCEDURE del_iter_chiusi;

   /*****************************************************************************
     NOME:        VERIFICA_PRIVILEGIO_CASELLA
     DESCRIZIONE: Verifica se l'utente ha diritti su almeno uno dei destinatari
                  presenti in p_destinatari.

    INPUT  p_utente varchar2: utente che di cui verificare il privilegio.
           p_destinatari varchar2 stringa con i destinatari.

    RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.

     Rev.  Data       Autore  Descrizione.
     00    13/05/2011 MM  Prima emissione. A24015.0.0.
    ********************************************************************************/
   FUNCTION verifica_privilegio_casella (p_destinatari    CLOB,
                                         p_utente         VARCHAR2,
                                         p_data           DATE DEFAULT NULL)
      RETURN NUMBER;

   /*****************************************************************************
     NOME:        verifica_messaggio
     DESCRIZIONE: Verifica se il messaggio è collegato ad un documento di PROTOCOLLO, in caso affermativo
                            setta il documento a spedito o invia segnalazione d'erroe sulla scrivania
                            in base allo stato della spedizione


    RITORNO:  1 il messaggio è del protocoollo, 0 altrimenti.

     Rev.  Data       Autore  Descrizione.
     00    04/08/2010 MMA  Prima emissione.
    ********************************************************************************/
   PROCEDURE verifica_messaggio (p_messaggio              NUMBER,
                                 p_new_data_spedizione    DATE,
                                 p_new_stato              VARCHAR2,
                                 p_errore                 VARCHAR2);

   FUNCTION get_caselle_utente (p_codice_amm   IN VARCHAR2,
                                p_codice_aoo   IN VARCHAR2,
                                p_utente       IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION duplica_documento (p_documento              NUMBER,
                               p_utente                 VARCHAR2,
                               p_gestisci_competenze    NUMBER DEFAULT 1,
                               p_se_vuoto               NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION refresh_mv (p_nome_mv VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_tabella (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_fascicolo_per_idrif (p_idrif VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_id_viewcartella (p_id_profilo VARCHAR2)
      RETURN NUMBER;

   FUNCTION concat_instr (str_1 CLOB, str_2 CLOB, str_cercata VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_smistamento (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION is_lettera (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION is_lettera_nuova (p_idrif VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_lettera_grails (p_idrif VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_lettera_grails (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION is_prot_interop (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION get_documento_per_idrif (p_idrif VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_utenti_notifica_ripudio (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2,
                                         id_smistamenti        VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_new_idrif
      RETURN VARCHAR2;

   FUNCTION get_url_oggetto (p_server_url            IN VARCHAR2,
                             p_context_path          IN VARCHAR2,
                             p_id_oggetto            IN VARCHAR2,
                             p_tipo_oggetto          IN VARCHAR2,
                             p_area                  IN VARCHAR2,
                             p_cm                    IN VARCHAR2,
                             p_cr                    IN VARCHAR2,
                             p_rw                    IN VARCHAR2,
                             p_id_cartprovenienza    IN VARCHAR2,
                             p_id_queryprovenienza   IN VARCHAR2,
                             p_tag                   IN VARCHAR2 DEFAULT '1',
                             p_javascript            IN VARCHAR2 DEFAULT 'S',
                             p_gdc_link              IN VARCHAR2 DEFAULT 'S',
                             p_per_worklist          IN VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2;

   FUNCTION is_memo (p_id_tipodoc NUMBER)
      RETURN NUMBER;

   FUNCTION verifica_mf_utente (p_utente VARCHAR2, p_data DATE  DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION verifica_ismi_utente (p_utente VARCHAR2, p_data DATE  DEFAULT NULL)
      RETURN NUMBER;

   PROCEDURE notifica_pec (p_id_prot    NUMBER,
                           p_id_memo    NUMBER,
                           p_errore     VARCHAR2,
                           p_note       VARCHAR2);

   FUNCTION is_fascicolo (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION is_doc_da_fasc (p_id_tipodoc NUMBER)
      RETURN NUMBER;

   FUNCTION is_prot_doc_esterni (p_id_documento NUMBER)
      RETURN NUMBER;

   FUNCTION is_protocollo (p_id_tipodoc NUMBER)
      RETURN NUMBER;
   FUNCTION is_soggetto_protocollo (p_id_tipodoc NUMBER)
      RETURN NUMBER;

   FUNCTION get_Data_rif_privilegi (p_id_documento NUMBER)
      RETURN DATE;

   FUNCTION get_id_documento_from_idrif (p_idrif VARCHAR2)
      RETURN NUMBER;
   FUNCTION get_unita_radice_area (p_codice_unita              VARCHAR2,
                                   p_data_riferimento          DATE,
                                   p_ottica                    VARCHAR2,
                                   p_codice_amministrazione    VARCHAR2,
                                   p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GET_TIPI_DOCUMENTO_ASSOCIATI(P_TIPO_DOCUMENTO_RISPOSTA VARCHAR2)
   RETURN VARCHAR2 ;
   FUNCTION crea_task_esterno_TODO( P_ID_RIFERIMENTO IN VARCHAR2
                                  , P_ATTIVITA_DESCRIZIONE IN VARCHAR2
                                  , P_TOOLTIP_ATTIVITA_DESCR IN VARCHAR2
                                  , P_URL_RIF IN VARCHAR2
                                  , P_URL_RIF_DESC IN VARCHAR2
                                  , P_URL_EXEC IN VARCHAR2
                                  , P_TOOLTIP_URL_EXEC IN VARCHAR2
                                  , P_DATA_SCAD IN DATE
                                  , P_PARAM_INIT_ITER IN VARCHAR2
                                  , P_NOME_ITER IN VARCHAR2
                                  , P_DESCRIZIONE_ITER IN VARCHAR2
                                  , P_COLORE IN VARCHAR2
                                  , P_ORDINAMENTO IN VARCHAR2
                                  , P_UTENTE_ESTERNO IN VARCHAR2
                                  , P_CATEGORIA IN VARCHAR2
                                  , P_DESKTOP IN VARCHAR2
                                  , P_STATO IN VARCHAR2
                                  , P_TIPOLOGIA IN VARCHAR2
                                  , P_DATIAPPLICATIVI1 IN VARCHAR2
                                  , P_DATIAPPLICATIVI2 IN VARCHAR2
                                  , P_DATIAPPLICATIVI3 IN VARCHAR2
                                  , P_TIPO_BOTTONE IN VARCHAR2
                                  , P_DATA_ATTIVAZIONE IN DATE
                                  , P_DES_DETTAGLIO_1 IN VARCHAR2
                                  , P_DETTAGLIO_1 IN VARCHAR2)
   RETURN NUMBER;

   FUNCTION EXISTS_SMART_DESKTOP
   return NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY ag_utilities
AS
   /******************************************************************************
      NAME:       AG_UTILITIES
      PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
      REVISIONS:
      Ver        Date        Author          Description
      ---------  ----------  --------------- ------------------------------------
      000        03/10/2006                  Created this package.
      001        23/05/2011   MMalferrari    Aggiunta funzione versione + modifica
                                             A42787.0.0: Calcolo PRIVILEGI estesi:
                                             non consideriamo lo storico dell'unita'.
                                             A43957.0.0: Evitare la rigenerazione
                                             della tabella AG_PRIV_UTENTE_TMP.
      002        09/03/2012   MMalferrari    Aggiunto parametro p_dal alla funzione
                                             verifica_unita_utente.
      003        08/05/2013   MMalferrari    Aggiunto parametro p_calcola_estensioni
                                             alla procedura inizializza_ag_priv_utente_tmp
      004        30/09/2013   MMalferrari    Utilizzo vista seg_uo_mail in
                                             verifica_privilegio_casella al posto
                                             di seg_unita (per velocizzare)
      005        24/03/2013   MMalferrari    Modificata procedura aggiorna_priv_utente_tmp
                                             in modo che, in caso di presenza dello
                                             stesso privilegio per la stessa unita'
                                             per lo stesso utente uno diretto ed uno
                                             per estensione, assegni all'utente il
                                             privilegio diretto + creata procedura
                                             riempi_ag_priv_utente_tmp per ricalcolo
                                             privilegi per tutti gli utenti.
      006       17/11/2014     MMalferrari   Aggiunto parametro p_data alla funzione
                                             verifica_privilegio_casella.
      007       14/08/2015    MMalferrari    Aggiunta funzione is_doc_da_fasc.
      008       24/11/2015    MMalferrari    Aggiunta funzione is_prot_doc_esterni
      009       23/03/2016    MMalferrari    Modificata procedura add_fratelli_per_privilegio
      010       27/04/2016    MMalferrari    Modificata add_area_per_privilegio
      011       04/05/2016    MMalferrari    Aggiunta funzione is_protocollo
      012       17/08/2016    MMalferrari    Modificata procedura notifica_pec
      013       07/03/2017    MMalferrari    Versione 2.7
                27/04/2017    SC             ALLINEATO ALLO STANDARD
      014       01/12/2017    SC             Adeguamento SmartDesktop
      015       23/10/2018    SC             Join con Area in is_protocollo
      016       20/11/2018    SC             Feature #38096 Avvisi pec in caso
                                             di problemi nell'invio pec: a chi
                                             inviare le notifiche
   ******************************************************************************/
   s_revisione_body     afc.t_revision := '016';
   /********************************************************
   VARIABILI GLOBALI
   *********************************************************/
   privilegioarea       ag_privilegi.privilegio%TYPE := 'EPAREA';
   privilegiosup        ag_privilegi.privilegio%TYPE := 'EPSUP';
   privilegioequ        ag_privilegi.privilegio%TYPE := 'EPEQU';
   privilegiosub        ag_privilegi.privilegio%TYPE := 'EPSUB';
   privilegiosubtot     ag_privilegi.privilegio%TYPE := 'EPSUBTOT';
   storicoruoliestesi   VARCHAR2 (1);

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        VERSIONE
    DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
    RITORNA:     stringa VARCHAR2 contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   /*****************************************************************************
       NOME:        EXISTS_SMART_DESKTOP.
       DESCRIZIONE: Restituisce 1 se esiste il sinonimo JWF_WORKLIST_SERVICES

      Rev.  Data        Autore      Descrizione.
      014   01/12/2017    SC        Adeguamento SmartDesktop

   ********************************************************************************/
   FUNCTION EXISTS_SMART_DESKTOP
      RETURN NUMBER
   AS
      d_esiste    NUMBER := 0;
      d_usr_gdm   VARCHAR2 (100);
      d_usr_jwf   VARCHAR2 (100);
   BEGIN
      /*     SELECT user_oracle
             INTO d_usr_gdm
             FROM ad4_istanze
            WHERE istanza = 'AGS';

           SELECT user_oracle
             INTO d_usr_jwf
             FROM ad4_istanze
            WHERE istanza = 'JWFWEB';

           SELECT DISTINCT 1
             INTO d_esiste
             FROM all_synonyms
            WHERE synonym_name = 'JWF_WORKLIST_SERVICES';

           IF d_esiste = 1
           THEN
              SELECT DISTINCT 1
                INTO d_esiste
                FROM user_tab_privs
               WHERE     grantee = d_usr_gdm
                     AND grantor = d_usr_jwf
                     AND table_name = 'WORKLIST_SERVICES';

           END IF;*/

      SELECT 1
        INTO d_esiste
        FROM ad4_istanze ist_ags, ad4_istanze ist_jwf, user_tab_privs
       WHERE     ist_ags.istanza = 'AGS'
             AND ist_jwf.istanza = 'JWFWEB'
             AND ist_ags.user_oracle = user_tab_privs.grantee
             AND ist_jwf.user_oracle = user_tab_privs.grantor
             AND table_name = 'WORKLIST_SERVICES'
             AND privilege = 'EXECUTE';

      RETURN d_esiste;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION EXISTS_SO4_AGS_PKG
      RETURN NUMBER
   IS
      so4_pack_nuovo   NUMBER (1) := 0;
   BEGIN
      BEGIN
           SELECT DECODE (table_name, 'SO4_AGS_PKG', 1, 0)
             INTO so4_pack_nuovo
             FROM user_synonyms
            WHERE synonym_name = 'SO4_AGS_PKG'
         ORDER BY synonym_name;
      EXCEPTION
         WHEN OTHERS
         THEN
            so4_pack_nuovo := 0;
      END;

      RETURN so4_pack_nuovo;
   END EXISTS_SO4_AGS_PKG;

   /* 010   11/04/2017  SC            Introdotto progressivo unita */
   PROCEDURE INS_UNITA_UTENTE_TAB (p_utente          VARCHAR2,
                                   p_unita           VARCHAR2,
                                   p_ruolo           VARCHAR2,
                                   p_privilegio      VARCHAR2,
                                   p_appartenenza    VARCHAR2,
                                   p_dal             DATE,
                                   p_al              DATE,
                                   p_progressivo     NUMBER)
   IS
      d_esiste   NUMBER := -1;
      d_al       DATE;
   BEGIN
      --      IF p_unita = '7'
      --      THEN
      --         integritypackage.LOG ('inserisco in AG_PRUT_TEMP ');
      --         integritypackage.LOG (' unita ' || p_unita);
      --         integritypackage.LOG (' ruolo ' || p_ruolo);
      --         integritypackage.LOG (' appartenenza ' || p_appartenenza);
      --         integritypackage.LOG (' privilegio ' || p_privilegio);
      --         integritypackage.LOG (' p_dal ' || p_dal);
      --         integritypackage.LOG (' p_al ' || p_al);
      --      END IF;

      IF NVL (p_al, TO_DATE (3333333, 'j')) >= p_dal
      THEN
         BEGIN
            SELECT al
              INTO d_al
              FROM AG_PRUT_TEMP
             WHERE     utente = p_utente
                   AND unita = p_unita
                   AND progr_unita = p_progressivo
                   AND privilegio = p_privilegio
                   AND ( (p_privilegio NOT LIKE 'EP%') OR ruolo = p_ruolo)
                   AND appartenenza =
                          DECODE (p_appartenenza,
                                  'D', p_appartenenza,
                                  appartenenza);
         EXCEPTION
            WHEN TOO_MANY_ROWS
            THEN
               d_esiste := 1;
            WHEN NO_DATA_FOUND
            THEN
               d_esiste := 0;
         END;

         IF d_esiste = 0
         THEN
            --            IF p_UNITA = '7'
            --            THEN


            --               integritypackage.LOG ('inserisco in AG_PRUT_TEMP ');
            --               integritypackage.LOG (' unita ' || p_unita);
            --               integritypackage.LOG (' ruolo ' || p_ruolo);
            --               integritypackage.LOG (' appartenenza ' || p_appartenenza);
            --               integritypackage.LOG (' privilegio ' || p_privilegio);
            --               integritypackage.LOG (' p_dal ' || p_dal);
            --               integritypackage.LOG (' p_al ' || p_al);
            --            END IF;


            BEGIN
               INSERT /*+ APPEND */
                     INTO  AG_PRUT_TEMP (utente,
                                         unita,
                                         ruolo,
                                         privilegio,
                                         appartenenza,
                                         dal,
                                         al,
                                         progr_unita)
                    VALUES (p_utente,
                            p_unita,
                            p_ruolo,
                            p_privilegio,
                            p_appartenenza,
                            p_dal,
                            p_al,
                            p_progressivo);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  RAISE;
            END;
         ELSE
            --              IF p_UNITA = '7'
            --               THEN
            --                  integritypackage.LOG ('AGGIORNO AL in AG_PRUT_TEMP? ');
            --                  integritypackage.LOG (' unita ' || p_unita);
            --                  integritypackage.LOG (' ruolo ' || p_ruolo);
            --                  integritypackage.LOG (' appartenenza ' || p_appartenenza);
            --                  integritypackage.LOG (' privilegio ' || p_privilegio);
            --                  integritypackage.LOG (' d_al ' || d_al);
            --                  integritypackage.LOG (' p_dal ' || p_dal);
            --                  integritypackage.LOG (' p_al ' || p_al);
            --               END IF;

            IF GREATEST (NVL (p_al, TO_DATE (3333333, 'j')),
                         NVL (d_al, TO_DATE (3333333, 'j'))) >
                  NVL (d_al, TO_DATE (3333333, 'j'))
            THEN
               --               IF p_UNITA = '7'
               --               THEN


               --                  --integritypackage.LOG ('AGGIORNO AL in AG_PRUT_TEMP ');
               --               END IF;



               UPDATE AG_PRUT_TEMP
                  SET al = p_al
                WHERE     utente = p_utente
                      AND unita = p_unita
                      AND progr_unita = p_progressivo
                      AND privilegio = p_privilegio
                      AND appartenenza =
                             DECODE (p_appartenenza,
                                     'D', p_appartenenza,
                                     appartenenza);
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
   --NULL;
   END;

   PROCEDURE ins_area_tab (p_progressivo_start                 NUMBER,
                           p_progr_unita                       NUMBER,
                           p_unita                             VARCHAR2,
                           p_dal                               DATE,
                           p_al                                DATE,
                           t_area_tab            IN OUT NOCOPY t_areatab)
   IS
      d_esiste   NUMBER;
   BEGIN
      NULL;

      SELECT COUNT (1)
        INTO d_esiste
        FROM TABLE (t_area_tab)
       WHERE     progressivo_start = p_progressivo_start
             AND progr_unita_organizzativa = p_progr_unita
             AND dal = p_dal
             AND NVL (al, TO_DATE (3333333, 'j')) =
                    NVL (p_al, TO_DATE (3333333, 'j'));

      IF d_esiste = 0
      THEN
         BEGIN
            t_area_tab.EXTEND ();
            t_area_tab (t_area_tab.LAST) :=
               t_arearec (p_progressivo_start,
                          p_progr_unita,
                          p_unita,
                          p_dal,
                          p_al);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               NULL;
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
   END;

   FUNCTION get_unita_priv_utente_plsqlt (p_utente        VARCHAR2,
                                          p_privilegio    VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      ----INTEGRITYPACKAGE.LOG ('get_unita_priviegio_utente ');
      OPEN d_result FOR
         SELECT DISTINCT ag_priv_utente_tmp.progr_unita,
                         ag_priv_utente_tmp.unita,
                         ag_priv_utente_tmp.dal,
                         ag_priv_utente_tmp.al
           FROM AG_PRUT_TEMP ag_priv_utente_tmp
          WHERE     ag_priv_utente_tmp.utente = p_utente
                AND privilegio = p_privilegio;

      RETURN d_result;
   END;

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
          WHERE     paoo.tipo_modello = '@agVar@'
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
         raise_application_error (
            -20999,
            'ag_utilities.get_default_ammAoo: ' || SQLERRM);
   END;

   /*****************************************************************************
       NOME:        set_radici_area_per_privilegio.
       DESCRIZIONE: Dato utente e privilegio, per tutte le unit¿
        per cui l'utente ha il privilegio calcola l'unit¿ radice
        dell'area e la inserisce in AG_RADICI_AREA_UTENTE_TMP.

        Per radice di area, se ag_suddivisioni non contiene righe si considera
        l'unit¿ che non ha padre.
        Se ag_suddivisioni contiene righe, l'unit¿ di area ¿ la prima
        ascendente di p_codice_unita (lei compresa) la cui suddivisione
        ¿ presente in ag_suddivisioni.

       INPUT  p_utente varchar2 CODICE UNTENTE.
       p_privilegio PRIVILEGIO che deve avere l'uitente
       p_ottica OTTICA DI SO4 DA UTILIZZARE.


       Rev.  Data       Autore  Descrizione.
       00    15/02/2010  SC  Prima emissione. A34954.2.0
       01    09/03/2010  SC A34954.3.1 D1037
   ********************************************************************************/
   PROCEDURE set_radici_area_per_privilegio (
      p_utente                    VARCHAR2,
      p_privilegio                VARCHAR2,
      p_ottica                    VARCHAR2 DEFAULT NULL,
      p_codice_amministrazione    VARCHAR2 DEFAULT NULL,
      p_codice_aoo                VARCHAR2 DEFAULT NULL)
   IS
      v_unitasmistaarea          afc.t_ref_cursor;
      v_ammaoo                   afc.t_ref_cursor;
      dep_codice_unita           seg_unita.unita%TYPE;
      dep_progr_unita            SEG_UNITA.PROGR_UNITA_ORGANIZZATIVA%TYPE;
      d_unita_radice             seg_unita.unita%TYPE;
      d_progr_unita_radice       SEG_UNITA.PROGR_UNITA_ORGANIZZATIVA%TYPE;
      dep_dal_unita              DATE;
      dep_al_unita               DATE;
      d_codice_amministrazione   VARCHAR2 (1000);
      d_codice_aoo               VARCHAR2 (1000);
      d_ottica                   VARCHAR2 (1000);
   BEGIN
      d_codice_amministrazione := p_codice_amministrazione;
      d_codice_aoo := p_codice_aoo;
      d_ottica := p_ottica;

      IF d_codice_aoo IS NULL OR d_codice_amministrazione IS NULL
      THEN
         v_ammaoo := get_default_ammaoo ();

         IF v_ammaoo%ISOPEN
         THEN
            FETCH v_ammaoo INTO d_codice_amministrazione, d_codice_aoo;

            CLOSE v_ammaoo;
         END IF;
      END IF;

      IF d_ottica IS NULL
      THEN
         d_ottica :=
            get_ottica_utente (p_utente,
                               d_codice_amministrazione,
                               d_codice_aoo);
      END IF;

      DELETE ag_radici_area_utente_tmp
       WHERE utente = p_utente AND privilegio = p_privilegio;

      v_unitasmistaarea :=
         get_unita_priv_utente_plsqlt (p_utente, p_privilegio);

      IF v_unitasmistaarea%ISOPEN
      THEN
         -- verifica se l'utente ha privilegio per assegnare a componenti di qualunque unita
         LOOP
            -- costruisce una stringa delle unita di livello 0 dell'area per cui l'utente
            -- ha privilegio SMISTAAREA, i codici sono separati da @.
            FETCH v_unitasmistaarea
               INTO dep_progr_unita,
                    dep_codice_unita,
                    dep_dal_unita,
                    dep_al_unita;

            EXIT WHEN v_unitasmistaarea%NOTFOUND;

            IF (dep_al_unita IS NULL OR storicoruoli = 'Y')
            THEN
               -- SC A34954.3.1 D1037
               DECLARE
                  d_data_rif   DATE := NULL;
               BEGIN
                  IF storicoruoli = 'Y'
                  THEN
                     d_data_rif := dep_dal_unita;
                  END IF;


                  leggi_unita_radice_area (dep_progr_unita,
                                           d_data_rif,
                                           d_ottica,
                                           d_codice_amministrazione,
                                           d_codice_aoo,
                                           d_progr_unita_radice,
                                           d_unita_radice);
               END;

               IF d_unita_radice IS NOT NULL
               THEN
                  DECLARE
                     d_esiste   NUMBER := 0;
                  BEGIN
                     SELECT 1
                       INTO d_esiste
                       FROM ag_radici_area_utente_tmp
                      WHERE     utente = p_utente
                            AND progr_unita IS NULL
                            AND unita_radice_area = d_unita_radice
                            AND privilegio = p_privilegio;

                     UPDATE ag_radici_area_utente_tmp
                        SET progr_unita = d_progr_unita_radice
                      WHERE     utente = p_utente
                            AND progr_unita IS NULL
                            AND unita_radice_area = d_unita_radice
                            AND privilegio = p_privilegio;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        INSERT INTO ag_radici_area_utente_tmp (
                                       utente,
                                       progr_unita,
                                       unita_radice_area,
                                       privilegio)
                           SELECT p_utente,
                                  d_progr_unita_radice,
                                  d_unita_radice,
                                  p_privilegio
                             FROM DUAL
                            WHERE NOT EXISTS
                                     (SELECT 1
                                        FROM ag_radici_area_utente_tmp
                                       WHERE     utente = p_utente
                                             AND NVL (progr_unita,
                                                      d_progr_unita_radice) =
                                                    d_progr_unita_radice
                                             AND unita_radice_area =
                                                    d_unita_radice
                                             AND privilegio = p_privilegio);
                  END;
               END IF;
            END IF;
         END LOOP;

         --tolgo le unit¿ radice che hanno a loro volta ascendenti presenti in tabella
         FOR unita_radici_area
            IN (SELECT unita_radice_area, utente, privilegio
                  FROM ag_radici_area_utente_tmp
                 WHERE utente = p_utente AND privilegio = p_privilegio)
         LOOP
            DELETE ag_radici_area_utente_tmp
             WHERE     utente = unita_radici_area.utente
                   AND privilegio = unita_radici_area.privilegio
                   AND unita_radice_area =
                          unita_radici_area.unita_radice_area
                   AND EXISTS
                          (SELECT 1
                             FROM ag_radici_area_utente_tmp
                            WHERE     utente = unita_radici_area.utente
                                  AND privilegio =
                                         unita_radici_area.privilegio
                                  AND unita_radice_area !=
                                         unita_radici_area.unita_radice_area
                                  AND INSTR (
                                         SO4_AGS_PKG.unita_get_ascendenza (
                                            unita_radici_area.unita_radice_area),
                                         'O#' || unita_radice_area || '#',
                                         1) > 0);
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
   PROCEDURE get_unita_padre (p_progr_unita             NUMBER,
                              p_ottica                  VARCHAR2,
                              p_data                    DATE,
                              p_progr_unita_padre   OUT NUMBER,
                              p_cod_unita_padre     OUT VARCHAR2,
                              p_dal_padre           OUT DATE,
                              p_al_padre            OUT DATE)
   IS
      unitaascendenti       afc.t_ref_cursor;
      depdescrizioneunita   VARCHAR2 (32000);

      conta                 NUMBER := 0;
   BEGIN
      BEGIN
         unitaascendenti :=
            so4_util.get_ascendenti (p_progr_unor   => p_progr_unita,
                                     p_data         => p_data,
                                     p_ottica       => p_ottica);
      --            SO4_AGS_PKG.unita_get_ascendenti (
      --               p_codice_uo   => p_codice_unita,
      --               p_data        => p_data,

      --               p_ottica      => p_ottica);
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
               INTO p_progr_unita_padre,
                    p_cod_unita_padre,
                    depdescrizioneunita,
                    p_dal_padre,
                    p_al_padre;

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
       01    30/03/2017  SC  Aggiunto p_data e progressivo
   ********************************************************************************/
   FUNCTION get_unita_privilegio (
      p_utente        VARCHAR2,
      p_privilegio    VARCHAR2,
      p_data          DATE DEFAULT TRUNC (SYSDATE)                    /*null*/
                                                  )
      RETURN t_ref_cursor
   IS
      retval   t_ref_cursor;
   BEGIN
      OPEN retval FOR
         SELECT DISTINCT unita, progr_unita
           FROM ag_priv_utente_tmp
          WHERE     utente = p_utente
                AND privilegio = p_privilegio
                AND p_data <= NVL (al, TO_DATE (3333333, 'j')) --(p_data is null or p_data <= nvl(al, to_Date(3333333, 'j')))
                                                              ;

      RETURN retval;
   END get_unita_privilegio;

   /*****************************************************************************
       NOME:        riempi_unita_utente_tab.
       DESCRIZIONE: Riempie una table con utente, unita di cui fa parte, privilegi che ha
                    nelle unita'.

      INPUT  p_utente   varchar2:   utente che di cui si vogliono conoscere unita di appartenenza e privilegi.
             p_tabPriv  t_PrivTab:   pl/sql table dei privilegi dell'utente.


       Rev.  Data       Autore      Descrizione.
       00    02/01/2007 SC          Prima emissione.
             04/06/2009 SC          A30334.0.0 Richiede lo storico dei ruoli solo se previsto
                                    dal parametro STORICO_RUOLI_1. Per ora l'amministrazione/aoo
                                    associata all'utente non ¿ individualbile, quindi passo null
                                    ad ag_utilities.get_indice_aoo.
      001   23/05/2011  MMalferrari A43957.0.0: Evitare la rigenerazione della
                                    tabella AG_PRIV_UTENTE_TMP.
      002   11/04/2017  SC          Gestione progressivo unità
   ********************************************************************************/
   PROCEDURE riempi_unita_utente_tab (p_utente VARCHAR2)
   IS
      unitautente           afc.t_ref_cursor;
      privilegi             t_ref_cursor;
      depunita              seg_unita.unita%TYPE;
      depdescrizioneunita   VARCHAR2 (1000);
      depruolo              VARCHAR2 (8);
      depprivilegio         ag_privilegi.privilegio%TYPE;
      depdescrizioneruolo   VARCHAR2 (1000);
      depdal                DATE;
      depal                 DATE;
      depprogrunita         NUMBER;
   BEGIN
      -- A30334.0.0 SC richiede lo storico dei ruoli solo se previsto
      -- dal parametro STORICO_RUOLI_1. Per ora l'amministrazione/aoo
      -- associata all'utente non ¿ individualbile, quindi passo null
      -- ad ag_utilities.get_indice_aoo.


      unitautente :=
         SO4_AGS_PKG.ad4_utente_get_storico_unita (
            p_utente       => p_utente,
            p_ottica       => ottica,
            p_se_storico   => storicoruoli);


      IF unitautente%ISOPEN
      THEN
         LOOP
            FETCH unitautente
               INTO depprogrunita,
                    depunita,
                    depdescrizioneunita,
                    depdal,
                    depal,
                    depruolo,
                    depdescrizioneruolo;

            EXIT WHEN unitautente%NOTFOUND;

            IF depdal <= TRUNC (SYSDATE)
            THEN
               IF depal >= TRUNC (SYSDATE)
               THEN
                  depal := NULL;
               END IF;

               privilegi :=
                  ag_privilegio_ruolo.get_privilegi (indiceaoo, depruolo);

               IF privilegi%ISOPEN
               THEN
                  LOOP
                     FETCH privilegi INTO depprivilegio;

                     EXIT WHEN privilegi%NOTFOUND;

                     BEGIN
                        IF depprivilegio = 'CPROT'
                        THEN
                           INTEGRITYPACKAGE.LOG ('INSERISCO CPROT');
                        END IF;

                        ins_unita_utente_tab (p_utente,
                                              depunita,
                                              depruolo,
                                              depprivilegio,
                                              'D',
                                              depdal,
                                              depal,
                                              depprogrunita);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           RAISE;
                     END;
                  END LOOP;
               END IF;
            END IF;
         END LOOP;

         CLOSE unitautente;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
   --NULL;
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


       Rev.  Data       Autore         Descrizione.
       000   02/01/2007  SC            Prima emissione.
       001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
                                       non consideriamo lo storico dell'unita'.
                                       A43957.0.0: Evitare la rigenerazione della
                                       tabella AG_PRIV_UTENTE_TMP.
       009   23/03/2016  MMalferrari   Nel recupero dei fratelli, anche con storico_ruoli,
                                       prenda solo quelli che sono ad oggi figli dello
                                       stesso padre.
       010   11/04/2017  SC            Gestione date privilegi
   ********************************************************************************/
   PROCEDURE add_fratelli_per_privilegio (p_utente VARCHAR2)
   IS
      depfratello           VARCHAR2 (100);
      depdescrizioneunita   VARCHAR2 (32000);
      fratelli              t_ref_cursor;
      depprogr              NUMBER;
      depdatadal            DATE;
      depdataal             DATE;
      t_area_tab            t_areatab := t_areatab ();
      so4_pack_nuovo        NUMBER := 0;
   BEGIN
      so4_pack_nuovo := EXISTS_SO4_AGS_PKG;



      FOR unitautente
         IN (SELECT DISTINCT prut1.progr_unita progr,
                             prut1.unita,
                             ruolo,
                             prut1.dal,
                             prut1.al
               FROM AG_PRUT_TEMP prut1
              WHERE     utente = p_utente
                    AND privilegio = privilegioequ
                    AND al IS NULL)
      LOOP
         DECLARE
            area_calcolata   NUMBER := 0;
         BEGIN
            SELECT DISTINCT 1
              INTO area_calcolata
              FROM TABLE (t_area_tab)
             WHERE     progressivo_start = unitautente.progr
                   AND so4_pack_nuovo = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  -- Rev. 001 MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi: non
                  -- consideriamo lo storico dell'unita'.
                  --                  IF storicoruoli = 'Y'
                  --                  THEN
                  --                     fratelli :=



                  --                        SO4_AGS_PKG.unita_get_storico_pari_livello (
                  --                           p_codice_uo   => unitautente.unita,
                  --                           p_ottica      => ottica);
                  --                  ELSE


                  fratelli :=
                     SO4_AGS_PKG.unita_get_pari_livello (
                        p_progr_uo   => unitautente.progr,
                        p_data       => TRUNC (SYSDATE),
                        p_ottica     => ottica);

                  --                  END IF;


                  IF fratelli%ISOPEN
                  THEN
                     LOOP
                        FETCH fratelli
                           INTO depprogr,
                                depfratello,
                                depdescrizioneunita,
                                depdatadal,
                                depdataal;

                        EXIT WHEN fratelli%NOTFOUND;
                        --integritypackage.log('inserisce in area_tab fratello '||depfratello ||' per '||unitautente.progr);
                        ins_area_tab (unitautente.progr,
                                      depprogr,
                                      depfratello,
                                      depdatadal,
                                      depdataal,
                                      t_area_tab);
                     END LOOP;

                     CLOSE fratelli;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
         END;

         FOR u IN (SELECT progr_unita_organizzativa,
                          unita,
                          dal,
                          al
                     FROM TABLE (t_area_tab)
                    WHERE progressivo_start = unitautente.progr)
         LOOP
            -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
            -- non consideriamo lo storico dell'unita'.
            depprogr := u.progr_unita_organizzativa;
            depfratello := u.unita;
            depdatadal := u.dal;
            depdataal := u.al;

            IF depdatadal <= TRUNC (SYSDATE)
            THEN
               IF depdataal >= TRUNC (SYSDATE)
               THEN
                  depdataal := NULL;
               END IF;

               -- Rev. 009 MMalferrari
               -- se, ad oggi, gli uffici non hanno pi¿ lo stesso padre, non considera
               -- l'ufficio tra quelli da aggiungere per estensione EPEQU anche se il
               -- parametro storico_ruoli vale Y.
               --               declare
               --                  padreU varchar2(2000);
               --                  padreF varchar2(2000);
               --               begin



               --                  padreU := SO4_AGS_PKG.unita_get_unita_padre(unitautente.progr, ottica, sysdate);
               --                  padreF := SO4_AGS_PKG.unita_get_unita_padre(u.progr_unita_organizzativa, ottica, sysdate);
               --



               --                  if nvl(padreU, 'xxx') <> nvl(padreF, 'xxx') then

               --                     depdataal := to_date(2222222, 'j');
               --                  end if;
               --               end;



               IF NVL (depdataal, unitautente.dal) >= unitautente.dal
               THEN
                  FOR privilegi
                     IN (SELECT privilegio
                           FROM ag_privilegi_ruolo
                          WHERE     aoo = indiceaoo
                                AND ruolo = unitautente.ruolo
                                AND privilegio NOT IN (privilegiosub,
                                                       privilegiosup,
                                                       privilegioequ,
                                                       privilegioarea,
                                                       privilegiosubtot))
                  LOOP
                     BEGIN
                        ins_unita_utente_tab (
                           p_utente,
                           depfratello,
                           unitautente.ruolo,
                           privilegi.privilegio,
                           'E',
                           LEAST (depdatadal, unitautente.dal),
                           LEAST (
                              NVL (depdataal, unitautente.al),
                              NVL (unitautente.al, TO_DATE (3333333, 'j'))),
                           depprogr);
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
            END IF;
         END LOOP;
      END LOOP;

      t_area_tab.DELETE;
   END add_fratelli_per_privilegio;

   /*****************************************************************************
       NOME:        get_unita_pari_area.
       DESCRIZIONE: Calcola il cursore delle unita che fanno parte della stessa area di
       p_codice_unita.


      INPUT  p_codice_unita                  VARCHAR2 codice unita di cui si cerca
                                           l'area e le unita dell'area


       Rev.  Data        Autore        Descrizione.
       000   06/05/2008  SC            A27282.1.0  Prima emissione.
             15/02/2010  SC            A34954.2.0 Gestione suddivisioni per riconoscere l'area.
       001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
                                       non consideriamo lo storico dell'unita'.
      ********************************************************************************/
   FUNCTION get_unita_pari_area (p_progr_unita         NUMBER,
                                 p_data_riferimento    DATE)
      RETURN t_ref_cursor
   IS
      cascendenti              t_ref_cursor;
      cdiscendentiradice       t_ref_cursor;
      depprogr                 NUMBER;
      dep_codice_unita_padre   seg_unita.unita%TYPE;
      depdescrizioneunita      VARCHAR2 (1000);
      dep_dal_padre            DATE;
      dep_al_padre             DATE;
      suddivisione_presente    NUMBER := 0;
      dep_suddivisione         NUMBER;
   BEGIN
      /*  INTEGRITYPACKAGE.LOG (
              '---------------------------get_unita_pari_area codice '
           || p_codice_unita||' p_data_riferimento '||p_data_riferimento);*/
      NULL;
      cascendenti :=
         so4_util.get_ascendenti_sudd (p_progr_unita,
                                       p_data_riferimento,
                                       ottica);



      /*INTEGRITYPACKAGE.LOG (
                  'chiama SO4_AGS_PKG.unita_get_ascendenti_sudd per unita '
               || p_codice_unita||' p_data_riferimento '||p_data_riferimento);
      */
      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
               INTO depprogr,
                    dep_codice_unita_padre,
                    depdescrizioneunita,
                    dep_dal_padre,
                    dep_al_padre,
                    dep_suddivisione;

            BEGIN
               SELECT 1
                 INTO suddivisione_presente
                 FROM ag_suddivisioni
                WHERE     dep_suddivisione = id_suddivisione
                      AND indice_aoo = get_indice_aoo (NULL, NULL);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            EXIT WHEN cascendenti%NOTFOUND OR suddivisione_presente = 1;
         ----INTEGRITYPACKAGE.LOG(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
         --                p_dal_padre||', '||p_al_padre);
         END LOOP;

         CLOSE cascendenti;
      END IF;

      ----INTEGRITYPACKAGE.LOG('-----------------------------------');
      -- Rev. 001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
      -- non consideriamo lo storico dell'unita'.
      /* IF storicoruoli = 'Y'
       THEN


          --INTEGRITYPACKAGE.LOG (
          --   'dep_codice_unita_padre ' || dep_codice_unita_padre);
          cdiscendentiradice :=
             SO4_AGS_PKG.unita_get_storico_discendenti (
                dep_codice_unita_padre,
                ottica);
       ELSE*/


      cdiscendentiradice :=
         SO4_AGS_PKG.unita_get_discendenti (dep_codice_unita_padre,
                                            TRUNC (SYSDATE),
                                            ottica);


      /*INTEGRITYPACKAGE.LOG (
                  'chiama SO4_AGS_PKG.unita_get_discendenti per unita '
               || dep_codice_unita_padre)* */
      --END IF;

      -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: fine mod.
      RETURN cdiscendentiradice;
   END get_unita_pari_area;

   /*****************************************************************************
       NOME:        del_iter_chiusi.
       DESCRIZIONE: Elimina gli iter chiusi da un numerodi giorni salvato in
                   parametro GG_DEL_ITER_n @agVar@
       EPAREA.


      INPUT


       Rev.  Data       Autore  Descrizione.
       00    22/04/2010  SC  A37575.0.0  Prima emissione.
      ********************************************************************************/
   PROCEDURE del_iter_chiusi
   IS
   BEGIN
      jwf_utility.del_iter (
         TO_NUMBER (ag_parametro.get_valore ('GG_DEL_ITER', '@agStrut@', 30)));
   END del_iter_chiusi;

   /*****************************************************************************
       NOME:        add_area_per_privilegio.
       DESCRIZIONE: Aggiunge alla temporary table delle unita/privilegi dell'utente
       le unita dell'area dell'unita di appartenenza di p_utente.
       Questo accade solo per le unita cui p_utente appartiene e per cui ha privilegio
       EPAREA.


      INPUT  p_utente                  VARCHAR2 di cui si deve verificare se ha privilegio


       Rev. Data        Autore      Descrizione.
       00   06/05/2008  SC          A27282.1.0  Prima emissione.
       01   09/03/2010  SC          A34954.3.1 D1037
      001   23/05/2011  MMalferrari A43957.0.0: Evitare la rigenerazione della
                                    tabella AG_PRIV_UTENTE_TMP.
                                    A42787.0.0: Calcolo PRIVILEGI estesi: non
                                    consideriamo lo storico dell'unita'.
      010    27/04/2016 MMalferrari Gestione parametro STORICO_RUOLI_ESTESI_1.
      011    27/03/2017 SC           Non si considerano più i ruoli di estensione chiusi
                                    e si considera solo la struttura organizzativa ad oggi
   ********************************************************************************/
   PROCEDURE add_area_per_privilegio (p_utente VARCHAR2)
   IS
      depparente            VARCHAR2 (100);
      depdescrizioneunita   VARCHAR2 (32000);
      parenti               t_ref_cursor;
      depprogr              NUMBER;
      depdatadal            DATE;
      depdataal             DATE;
      dloop                 NUMBER := 0;
      depesistenew          BOOLEAN := TRUE;
      t_area_tab            t_areatab := t_areatab ();
      so4_pack_nuovo        NUMBER := 0;
   BEGIN
      so4_pack_nuovo := EXISTS_SO4_AGS_PKG;



      --INTEGRITYPACKAGE.LOG('add_area_per_privilegio ');

      FOR unitautente
         IN (SELECT DISTINCT p.progr_unita progr,
                             p.unita,
                             p.ruolo,
                             p.dal,
                             p.al
               FROM AG_PRUT_TEMP p
              WHERE     utente = p_utente
                    AND privilegio = privilegioarea
                    AND p.al IS NULL)
      LOOP
         -- SC A34954.3.1 D1037
         DECLARE
            d_data_rif   DATE := TRUNC (SYSDATE);
         BEGIN
            /* IF storicoruoli = 'Y'
             THEN

                d_data_rif := unitautente.dal;
             END IF; */


            --INTEGRITYPACKAGE.LOG(
            --  'cerco unita pari area per '
            -- || unitautente.unita
            -- || ' '
            --|| d_data_rif);

            DECLARE
               area_calcolata   NUMBER := 0;
            BEGIN
               SELECT DISTINCT 1
                 INTO area_calcolata
                 FROM TABLE (t_area_tab)
                WHERE     progressivo_start = unitautente.progr
                      AND so4_pack_nuovo = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  parenti :=
                     get_unita_pari_area (
                        p_progr_unita        => unitautente.progr,
                        p_data_riferimento   => d_data_rif);
            END;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         IF parenti%ISOPEN
         THEN
            LOOP
               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
               -- non consideriamo lo storico dell'unita'.
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH parenti
                        INTO depprogr,
                             depparente,
                             depdescrizioneunita,
                             depdatadal,
                             depdataal;
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
                              INTO depprogr,
                                   depparente,
                                   depdescrizioneunita,
                                   depdatadal;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH parenti
                        INTO depprogr,
                             depparente,
                             depdescrizioneunita,
                             depdatadal,
                             depdataal;
                  ELSE
                     FETCH parenti
                        INTO depprogr,
                             depparente,
                             depdescrizioneunita,
                             depdatadal;
                  END IF;
               END IF;

               EXIT WHEN parenti%NOTFOUND;
               /*INTEGRITYPACKAGE.LOG (
                     'ADD AREA di unita '
                  || unitautente.unita
                  || ' PER PRIVILEGIO '
                  || depparente
                  || ' '
                  || depdatadal
                  || ' '
                  || depdataal);*/

               ins_area_tab (unitautente.progr,
                             depprogr,
                             depparente,
                             depdatadal,
                             depdataal,
                             t_area_tab);
            END LOOP;

            CLOSE parenti;
         END IF;

         FOR u IN (SELECT DISTINCT progr_unita_organizzativa,
                                   unita,
                                   dal,
                                   al
                     FROM TABLE (t_area_tab)
                    WHERE progressivo_start = unitautente.progr)
         LOOP
            -- INTEGRITYPACKAGE.LOG(' ----- u.progr_unita_organizzativa '||u.progr_unita_organizzativa);
            /**** Bug #20899 redmine ***/
            IF unitautente.progr != u.progr_unita_organizzativa
            THEN
               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
               -- non consideriamo lo storico dell'unita'.
               depprogr := u.progr_unita_organizzativa;
               depparente := u.unita;
               depdatadal := u.dal;
               depdataal := u.al;
               depdatadal := LEAST (depdatadal, unitautente.dal);

               -- INTEGRITYPACKAGE.LOG(' ----- UNITAUTENTE.UNITA '||UNITAUTENTE.UNITA||' unitautente.dal : '|| unitautente.dal||' unitautente.al : '|| unitautente.al);
               -- INTEGRITYPACKAGE.LOG(' ----- depparente '||depparente||' depdatadal : '||depdatadal||' depdataal : '||depdataal);
               /***** Bug #20899 seconda parte **/
               depdataal :=
                  LEAST (
                     NVL (depdataal, unitautente.al),
                     NVL (unitautente.al, TO_DATE ('31122999', 'ddmmyyyy')));

               --   GREATEST (NVL (depdataal, unitautente.al), unitautente.al);
               /**   fine Bug #20899 seconda parte ****/

               IF depdatadal <= TRUNC (SYSDATE)
               THEN
                  IF depdataal >= TRUNC (SYSDATE)
                  THEN
                     depdataal := NULL;
                  END IF;

                  IF NVL (depdataal, TO_DATE ('31122999', 'ddmmyyyy')) >=
                        depdatadal
                  THEN
                     /*IF depdataal IS NULL
                     THEN*/



                     /* INTEGRITYPACKAGE.LOG('inserisco privilegi per '|| p_utente||','
                                                 ||depparente||','
                                                 ||unitautente.ruolo||',
                                                 privilegi.privilegio,
                                                 ''E'','
                                                 ||depdatadal||','
                                                 ||depdataal); */



                     FOR privilegi
                        IN (SELECT privilegio
                              FROM ag_privilegi_ruolo
                             WHERE     aoo = indiceaoo
                                   AND ruolo = unitautente.ruolo
                                   AND privilegio NOT IN (privilegioarea,
                                                          privilegiosub,
                                                          privilegiosup,
                                                          privilegioequ,
                                                          privilegiosubtot))
                     LOOP
                        BEGIN
                           ins_unita_utente_tab (p_utente,
                                                 depparente,
                                                 unitautente.ruolo,
                                                 privilegi.privilegio,
                                                 'E',
                                                 depdatadal,
                                                 depdataal,
                                                 depprogr);
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX
                           THEN
                              NULL;
                           WHEN OTHERS
                           THEN
                              RAISE;
                        END;
                     END LOOP;
                  --END IF;



                  END IF;
               END IF;
            END IF;                               /**** fine Bug #20899a ****/
         END LOOP;

         t_area_tab.delete ();
      END LOOP;

      t_area_tab.DELETE;
   END add_area_per_privilegio;

   /*****************************************************************************
       NOME:        add_discendenti_per_privilegio.
       DESCRIZIONE: Aggiunge alla temporary table delle unita dell'utente le unita figlie
       di quelle unita di cui l'utente fa parte con ruolo che possiede il privilegio
       p_privilegio.



      INPUT  p_utente                  VARCHAR2 di cui si deve verificare se ha privilegio.


       Rev.  Data        Autore        Descrizione.
       000   02/01/2007  SC            Prima emissione.
             23/09/2008  SC            A28345.25.0 GESTIONE EPSUBTOT
       001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
                                       non consideriamo lo storico dell'unita'.
                                       A43957.0.0: Evitare la rigenerazione della
                                       tabella AG_PRIV_UTENTE_TMP.
       002   11/04/2017  SC            Gestione date privilegi
   ********************************************************************************/
   PROCEDURE add_discendenti_per_privilegio (p_utente VARCHAR2)
   IS
      depfiglia             VARCHAR2 (100);
      depdescrizioneunita   VARCHAR2 (32000);
      discendenti           t_ref_cursor;
      depprogr              NUMBER;
      depdatadal            DATE;
      depdataal             DATE;
      dloop                 NUMBER := 0;
      depesistenew          BOOLEAN := TRUE;
      t_area_tab            t_areatab := t_areatab ();
      so4_pack_nuovo        NUMBER := 0;
   BEGIN
      so4_pack_nuovo := EXISTS_SO4_AGS_PKG;



      --INTEGRITYPACKAGE.LOG ('add_discendenti_per_privilegio');

      -- INSERISCE PRIVILEGI ESTESI PER EPSUB
      FOR unitautente
         IN (SELECT DISTINCT p.progr_unita progr,
                             p.unita,
                             ruolo,
                             p.dal,
                             p.al
               FROM AG_PRUT_TEMP p
              WHERE     utente = p_utente
                    AND privilegio = privilegiosub
                    AND p.al IS NULL)
      LOOP
         INTEGRITYPACKAGE.LOG (
               'unitautente '
            || unitautente.unita
            || ' dal '
            || unitautente.dal
            || ' al '
            || unitautente.al);

         DECLARE
            area_calcolata   NUMBER := 0;
         BEGIN
            SELECT DISTINCT 1
              INTO area_calcolata
              FROM TABLE (t_area_tab)
             WHERE     progressivo_start = unitautente.progr
                   AND so4_pack_nuovo = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
                  -- non consideriamo lo storico dell'unita'.
                  --                  IF storicoruoli = 'Y'
                  --                  THEN
                  --                     NULL;
                  --                     discendenti :=
                  --                        SO4_AGS_PKG.unita_get_storico_figlie (



                  --                           p_codice_uo   => unitautente.unita,
                  --                           p_ottica      => ottica);
                  --                  ELSE
                  --29/03/2017 SC Possiamo tornare a so4_util standard perchè
                  -- ne usavamo una personalizzata per farci restituire tutti,
                  -- i codici nella storia del progressivo
                  -- ma da adesso anche noi memorizziamo il progressivo
                  -- quindi non serve piu'.
                  -- Lo gestisco facendo richiamare so4_util a so4_ags_pkg.unita_get_unita_figlie


                  discendenti :=
                     so4_ags_pkg.unita_get_unita_figlie (
                        p_progr    => unitautente.progr,
                        p_ottica   => ottica,
                        p_data     => TRUNC (SYSDATE));
               --                  END IF;

               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: fine mod.
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               IF discendenti%ISOPEN
               THEN
                  INTEGRITYPACKAGE.LOG ('discendenti%ISOPEN');

                  LOOP
                     FETCH discendenti
                        INTO depprogr,
                             depfiglia,
                             depdescrizioneunita,
                             depdatadal,
                             depdataal;

                     EXIT WHEN discendenti%NOTFOUND;

                     /*  INTEGRITYPACKAGE.LOG (
                             'discendente '
                          || depfiglia
                          || ' dal '
                          || depdatadal
                          || ' al '
                          || depdataal);*/

                     ins_area_tab (unitautente.progr,
                                   depprogr,
                                   depfiglia,
                                   depdatadal,
                                   depdataal,
                                   t_area_tab);
                  END LOOP;

                  CLOSE discendenti;
               END IF;
         END;

         FOR d IN (SELECT progr_unita_organizzativa,
                          unita,
                          dal,
                          al
                     FROM TABLE (t_area_tab)
                    WHERE progressivo_start = unitautente.progr)
         LOOP
            depprogr := d.progr_unita_organizzativa;
            depfiglia := d.unita;
            depdatadal := d.dal;
            depdataal := d.al;

            /* INTEGRITYPACKAGE.LOG (
                   'discendente '
                || depfiglia
                || ' dal '
                || depdatadal
                || ' al '
                || depdataal);
             INTEGRITYPACKAGE.LOG (
                   'LEAST (depdatadal, unitautente.dal) '
                || LEAST (depdatadal, unitautente.dal));
             INTEGRITYPACKAGE.LOG (
                   'LEAST (NVL (depdataal, unitautente.al),unitautente.al) '
                || LEAST (NVL (depdataal, unitautente.al), unitautente.al));*/
            ins_area_tab (unitautente.progr,
                          depprogr,
                          depfiglia,
                          depdatadal,
                          depdataal,
                          t_area_tab);

            IF depdatadal <= TRUNC (SYSDATE)
            THEN
               IF depdataal >= TRUNC (SYSDATE)
               THEN
                  depdataal := NULL;
               END IF;

               IF NVL (depdataal, unitautente.dal) >= unitautente.dal
               THEN
                  FOR privilegi
                     IN (SELECT privilegio
                           FROM ag_privilegi_ruolo
                          WHERE     aoo = indiceaoo
                                AND ruolo = unitautente.ruolo
                                AND privilegio NOT IN (privilegiosub,
                                                       privilegiosup,
                                                       privilegioequ,
                                                       privilegioarea,
                                                       privilegiosubtot))
                  LOOP
                     BEGIN
                        ins_unita_utente_tab (
                           p_utente,
                           depfiglia,
                           unitautente.ruolo,
                           privilegi.privilegio,
                           'E',
                           LEAST (depdatadal, unitautente.dal),
                           LEAST (
                              NVL (depdataal, unitautente.al),
                              NVL (unitautente.al, TO_DATE (3333333, 'j'))),
                           depprogr);
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
            END IF;
         END LOOP;
      END LOOP;

      t_area_tab.DELETE;

      -- INSERISCE PRIVILEGI ESTESI PER EPSUBTOT, ESCLUDE I RUOLI CHE HANNO ANCHE EPAREA
      FOR unitautente
         IN (SELECT DISTINCT prut1.progr_unita progr,
                             prut1.unita,
                             ruolo,
                             prut1.dal,
                             prut1.al
               FROM AG_PRUT_TEMP prut1
              WHERE     utente = p_utente
                    AND privilegio = privilegiosubtot
                    AND prut1.al IS NULL)
      LOOP
         /*INTEGRITYPACKAGE.LOG (
               'unitautente EPSUBTOT '
            || unitautente.unita
            || ' dal '
            || unitautente.dal
            || ' al '
            || unitautente.al);*/

         DECLARE
            area_calcolata   NUMBER := 0;
         BEGIN
            SELECT DISTINCT 1
              INTO area_calcolata
              FROM TABLE (t_area_tab)
             WHERE progressivo_start = unitautente.progr;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
                  -- non consideriamo lo storico dell'unita'.
                  --                  IF storicoruoli = 'Y'
                  --                  THEN
                  --                     NULL;
                  --                     discendenti :=



                  --                        SO4_AGS_PKG.unita_get_storico_discendenti (
                  --                           unitautente.unita,
                  --                           ottica);
                  --                  ELSE



                  discendenti :=
                     SO4_AGS_PKG.get_discendenti (unitautente.progr,
                                                  TRUNC (SYSDATE),
                                                  ottica);

                  --                  END IF;


                  IF discendenti%ISOPEN
                  THEN
                     LOOP
                        -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
                        -- non consideriamo lo storico dell'unita'.
                        dloop := dloop + 1;

                        IF dloop = 1
                        THEN
                           BEGIN
                              FETCH discendenti
                                 INTO depprogr,
                                      depfiglia,
                                      depdescrizioneunita,
                                      depdatadal,
                                      depdataal;
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
                                       INTO depprogr,
                                            depfiglia,
                                            depdescrizioneunita,
                                            depdatadal;
                                 END IF;
                           END;
                        ELSE
                           IF depesistenew
                           THEN
                              FETCH discendenti
                                 INTO depprogr,
                                      depfiglia,
                                      depdescrizioneunita,
                                      depdatadal,
                                      depdataal;
                           ELSE
                              FETCH discendenti
                                 INTO depprogr,
                                      depfiglia,
                                      depdescrizioneunita,
                                      depdatadal;
                           END IF;
                        END IF;

                        -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: fine mod.
                        EXIT WHEN discendenti%NOTFOUND;

                        /*INTEGRITYPACKAGE.LOG (
                              '  discendente di '
                           || unitautente.progr
                           || ': '
                           || depfiglia
                           || ' dal '
                           || depdatadal
                           || ' al '
                           || depdataal);*/
                        ins_area_tab (
                           unitautente.progr,
                           depprogr,
                           depfiglia,
                           LEAST (depdatadal, unitautente.dal),
                           LEAST (
                              NVL (depdataal, unitautente.al),
                              NVL (unitautente.al, TO_DATE (3333333, 'j'))),
                           t_area_tab);
                     END LOOP;

                     CLOSE discendenti;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
         END;

         FOR d IN (SELECT progr_unita_organizzativa,
                          unita,
                          dal,
                          al
                     FROM TABLE (t_area_tab)
                    WHERE progressivo_start = unitautente.progr)
         LOOP
            depprogr := d.progr_unita_organizzativa;
            depfiglia := d.unita;
            depdatadal := d.dal;

            IF unitautente.dal > depdatadal
            THEN
               depdatadal := unitautente.dal;
            END IF;

            depdataal := d.al;

            --            IF unitautente.al < NVL (depdataal, TO_DATE (3333333, 'j'))
            --            THEN

            --               depdataal := unitautente.al;
            --            END IF;


            FOR privilegi
               IN (SELECT privilegio
                     FROM ag_privilegi_ruolo
                    WHERE     aoo = indiceaoo
                          AND ruolo = unitautente.ruolo
                          AND privilegio NOT IN (privilegiosub,
                                                 privilegiosup,
                                                 privilegioequ,
                                                 privilegioarea,
                                                 privilegiosubtot))
            LOOP
               BEGIN
                  ins_unita_utente_tab (p_utente,
                                        depfiglia,
                                        unitautente.ruolo,
                                        privilegi.privilegio,
                                        'E',
                                        depdatadal,
                                        depdataal,
                                        depprogr);
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
      END LOOP;

      t_area_tab.DELETE;
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
      001   23/05/2011  MMalferrari A43957.0.0: Evitare la rigenerazione della
                                    tabella AG_PRIV_UTENTE_TMP.
      002   11/04/2017  SC            Gestione date privilegi
   ********************************************************************************/
   PROCEDURE ADD_PADRI_PER_PRIVILEGIO (p_utente VARCHAR2)
   IS
      deppadre              VARCHAR2 (100);
      depdescrizioneunita   VARCHAR2 (32000);
      depdalpadre           DATE;
      depalpadre            DATE;
      depprogr              NUMBER;
      t_area_tab            t_areatab := t_areatab ();
      unitapadri            t_ref_cursor;
      so4_pack_nuovo        NUMBER := 0;
   BEGIN
      INTEGRITYPACKAGE.LOG ('ADD_PADRI_PER_PRIVILEGIO inizio ');
      so4_pack_nuovo := EXISTS_SO4_AGS_PKG;



      FOR unitautente
         IN (SELECT DISTINCT p.progr_unita progr,
                             p.unita,
                             p.ruolo,
                             p.dal,
                             p.al
               FROM AG_PRUT_TEMP p
              WHERE     utente = p_utente
                    AND privilegio = privilegiosup
                    AND p.al IS NULL)
      LOOP
         INTEGRITYPACKAGE.LOG (
               'UNITA PER CUI SI HA EPSUP '
            || unitautente.unita
            || ' '
            || unitautente.dal
            || ' '
            || unitautente.al);

         --SC A34954.3.1 D1037. Se non ¿ richiesto storico ruoli, la data in cui
         -- ricostruire la struttura ¿  quella di default di
         DECLARE
            area_calcolata   NUMBER := 0;
         BEGIN
            SELECT DISTINCT 1
              INTO area_calcolata
              FROM TABLE (t_area_tab)
             WHERE     progressivo_start = unitautente.progr
                   AND so4_pack_nuovo = 1;
         --INTEGRITYPACKAGE.LOG ('CALCOLO GIA'' FATTO ');
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --INTEGRITYPACKAGE.LOG ('CALCOLO DA FARE ');

               DECLARE
                  d_data_rif   DATE := TRUNC (SYSDATE);

                  stmt         VARCHAR2 (32000);
               BEGIN
                  --                  IF storicoruoli = 'Y'
                  --                  THEN


                  --                     d_data_rif := unitautente.dal;
                  --                  END IF;


                  IF so4_pack_nuovo = 1
                  THEN
                     stmt :=
                           '   begin :valore :=
                     SO4_AGS_PKG.unita_get_unita_padri(p_progr      => '''
                        || unitautente.progr
                        || ''', p_ottica         => '''
                        || ottica
                        || ''', p_data           => to_date('''
                        || TO_CHAR (unitautente.dal, 'dd/mm/yyyy')
                        || ''',''dd/mm/yyyy'') ); end;';

                     EXECUTE IMMEDIATE stmt USING OUT unitapadri;

                     --INTEGRITYPACKAGE.LOG (
                     --  ' unitautente.unita ' || unitautente.unita);

                     IF unitapadri%ISOPEN
                     THEN
                        --INTEGRITYPACKAGE.LOG (' unitapadri%ISOPEN');

                        LOOP
                           FETCH unitapadri
                              INTO depprogr,
                                   deppadre,
                                   depdescrizioneunita,
                                   depdalpadre,
                                   depalpadre;

                           EXIT WHEN unitapadri%NOTFOUND;

                           /*  INTEGRITYPACKAGE.LOG (
                                     'trovato padre '
                                  || deppadre
                                  || ' '
                                  || depdalpadre
                                  || ' '
                                  || depalpadre);*/
                           ins_area_tab (unitautente.progr,
                                         depprogr,
                                         deppadre,
                                         depdalpadre,
                                         depalpadre,
                                         t_area_tab);
                        END LOOP;
                     --  CLOSE unitapadri;
                     END IF;
                  ELSE
                     get_unita_padre (p_progr_unita         => unitautente.progr,
                                      p_ottica              => ottica,
                                      p_data                => d_data_rif,
                                      p_progr_unita_padre   => depprogr,
                                      p_cod_unita_padre     => deppadre,
                                      p_dal_padre           => depdalpadre,
                                      p_al_padre            => depalpadre);



                     ins_area_tab (unitautente.progr,
                                   depprogr,
                                   deppadre,
                                   depdalpadre,
                                   depalpadre,
                                   t_area_tab);
                  END IF;
               END;
         END;

         FOR u IN (SELECT progr_unita_organizzativa,
                          unita,
                          dal,
                          al
                     FROM TABLE (t_area_tab)
                    WHERE progressivo_start = unitautente.progr)
         LOOP
            -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
            -- non consideriamo lo storico dell'unita'.
            depprogr := u.progr_unita_organizzativa;
            deppadre := u.unita;

            /** Bug #20900 viene testato depdalpadre senza che prima venga valorizzato,
            così ha lultimo valore preso nel loop precedente
            lo assegno**/
            depdalpadre := u.dal;
            /** fine Bug #20900 **/
            --depalpadre := u.dal;
            depalpadre := u.al;

            --integritypackage.log('padre di '||unitautente.unita||' dal '||unitautente.dal);
            --integritypackage.log('gestione padre '||deppadre||' dal '||depdalpadre||' al '||depalpadre);

            IF deppadre IS NOT NULL AND depdalpadre <= TRUNC (SYSDATE)
            THEN
               IF NVL (depalpadre, TO_DATE (3333333, 'j')) >= TRUNC (SYSDATE)
               THEN
                  depalpadre := NULL;
               END IF;

               IF NVL (depalpadre, unitautente.dal) >= unitautente.dal
               THEN
                  FOR privilegi
                     IN (SELECT privilegio
                           FROM ag_privilegi_ruolo
                          WHERE     aoo = indiceaoo
                                AND ruolo = unitautente.ruolo
                                AND privilegio NOT IN (privilegiosub,
                                                       privilegiosup,
                                                       privilegioequ,
                                                       privilegioarea,
                                                       privilegiosubtot))
                  LOOP
                     BEGIN
                        INTEGRITYPACKAGE.LOG (
                              'INSERISCO '
                           || deppadre
                           || ' '
                           || LEAST (depdalpadre, unitautente.dal)
                           || ' '
                           || LEAST (
                                 NVL (depalpadre, unitautente.al),
                                 NVL (unitautente.al, TO_DATE (3333333, 'j'))));

                        ins_unita_utente_tab (
                           p_utente,
                           deppadre,
                           unitautente.ruolo,
                           privilegi.privilegio,
                           'E',
                           LEAST (depdalpadre, unitautente.dal),
                           LEAST (
                              NVL (depalpadre, unitautente.al),
                              NVL (unitautente.al, TO_DATE (3333333, 'j'))),
                           depprogr);
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
            END IF;
         END LOOP;
      END LOOP;

      IF unitapadri%ISOPEN
      THEN
         CLOSE unitapadri;
      END IF;

      t_area_tab.DELETE;
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
   BEGIN
      integritypackage.LOG ('**** riempi_unita_estese ****');
      add_area_per_privilegio (p_utente => p_utente);
      integritypackage.LOG ('**** fine add_area_per_privilegio ****');
      add_fratelli_per_privilegio (p_utente => p_utente);
      integritypackage.LOG ('**** fine add_fratelli_per_privilegio ****');
      add_discendenti_per_privilegio (p_utente => p_utente);
      integritypackage.LOG ('**** fine add_discendenti_per_privilegio ****');
      add_padri_per_privilegio (p_utente => p_utente);
      integritypackage.LOG ('**** fine add_padri_per_privilegio ****');
      set_radici_area_per_privilegio (p_utente       => p_utente,
                                      p_privilegio   => privilegio_smistaarea);
      integritypackage.LOG ('**** fine set_radici_area_per_privilegio ****');
   END riempi_unita_estese;

   PROCEDURE riempi_ag_priv_utente_tmp
   IS
      /*****************************************************************************
          NOME:        riempi_ag_priv_utente_tmp
          DESCRIZIONE: Riempie la table AG_PRIV_UTENTE_TMP con utente, unita di cui
                       fa parte, ruoli che ha nelle unita' per tutti gli utenti che
                       hanno ruolo AGP.

         Rev.  Data        Autore      Descrizione.
         001   20/03/2014  MMalferrari Creazione
         002   11/04/2017  SC          Gestisce anche agpriv_d_utente_tmp
      ********************************************************************************/
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      FOR uten
         IN (SELECT DISTINCT us.utente
               FROM so4_ruco rc, so4_componenti c, ad4_utenti_soggetti us
              WHERE     rc.ruolo = 'AGP'
                    AND SYSDATE BETWEEN rc.dal_pubb
                                    AND NVL (rc.al_pubb,
                                             TO_DATE ('3333333', 'j'))
                    AND c.id_componente = rc.id_componente
                    AND us.soggetto = c.ni)
      LOOP
         BEGIN
            inizializza_ag_priv_utente_tmp (uten.utente);
            -- Ora viene fatto al login non serve farlo ad ogni smistamento
            --ag_priv_d_utente_tmp_utility.init_ag_priv_d_utente_tmp (uten.utente);
            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
         END;
      END LOOP;
   END;

   /*****************************************************************************
       NOME:        sistema_codici_unita_prut_temp.
       DESCRIZIONE: Per ogni progressivo cerca i codici unità corrispondenti
                    validi alla data della riga in esame e aggiunge
                    le relative righe, in modo che le query che andranno
                    su ag_priv_utente_tmp potranno continuare a filtrare
                    per codice unita.


      INPUT  p_utente                  VARCHAR2 di cui si deve verificare se ha privilegio


       Rev. Data        Autore      Descrizione.
       00   11/04/2017  SC          Prima emissione.
   ********************************************************************************/
   PROCEDURE sistema_codici_unita_prut_temp (p_utente VARCHAR2)
   IS
   BEGIN
      --PRIMA, a parita di progressivo, tiene solo righe con al massimo
      --POI inerisce tutti i codici storici dell'unità con quel progressivo
      --dalla notte dei tempi fino alla data di chiusura del privilegio
      FOR priv_da_tenere
         IN (SELECT DISTINCT progr_unita,
                             appartenenza,
                             ruolo,
                             privilegio,
                             dal,
                             al
               FROM ag_prut_temp
              WHERE     utente = p_utente
                    AND NOT EXISTS
                           (SELECT 1
                              FROM ag_prut_temp prut
                             WHERE     prut.utente = ag_prut_temp.utente
                                   AND prut.progr_unita =
                                          ag_prut_temp.progr_unita
                                   AND prut.appartenenza =
                                          ag_prut_temp.appartenenza
                                   AND prut.privilegio =
                                          ag_prut_temp.privilegio
                                   AND NVL (prut.al, TO_DATE (3333333, 'j')) >
                                          NVL (ag_prut_temp.al,
                                               TO_DATE (3333333, 'j'))))
      LOOP
         DELETE ag_prut_temp
          WHERE     utente = p_utente
                AND privilegio = priv_da_tenere.privilegio
                AND progr_unita = priv_da_tenere.progr_unita
                AND appartenenza = priv_da_tenere.appartenenza
                AND NVL (ag_prut_temp.al, TO_DATE (3333333, 'j')) <
                       NVL (priv_da_tenere.al, TO_DATE (3333333, 'j'));
      END LOOP;

      FOR progr_presenti IN (SELECT progr_unita,
                                    al,
                                    appartenenza,
                                    unita,
                                    dal,
                                    ruolo,
                                    privilegio
                               FROM ag_prut_temp
                              WHERE utente = p_utente)
      LOOP
         DECLARE
            d_ret      afc.t_ref_cursor;
            d_codice   VARCHAR2 (100);
         BEGIN
            d_ret :=
               SO4_AGS_PKG.anuo_get_storico_codici (
                  progr_presenti.progr_unita,
                  progr_presenti.al);

            IF d_ret%ISOPEN
            THEN
               LOOP
                  FETCH d_ret INTO d_codice;

                  EXIT WHEN d_ret%NOTFOUND;

                  --integritypackage.log(' codice storico '||d_codice);
                  DECLARE
                     esiste   NUMBER := 0;
                  BEGIN
                     SELECT DISTINCT 1
                       INTO esiste
                       FROM ag_prut_temp
                      WHERE     utente = p_utente
                            AND unita = d_codice
                            AND progr_unita = progr_presenti.progr_unita
                            AND appartenenza = progr_presenti.appartenenza
                            AND ruolo = progr_presenti.ruolo
                            AND privilegio = progr_presenti.privilegio;
                  --integritypackage.log(' codice storico '||d_codice||' esiste '||esiste);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        -- integritypackage.log(' codice storico '||d_codice||' insert ');
                        INSERT /*+ APPEND */
                              INTO  AG_PRUT_TEMP (al,
                                                  appartenenza,
                                                  dal,
                                                  privilegio,
                                                  progr_unita,
                                                  ruolo,
                                                  unita,
                                                  utente)
                             VALUES (progr_presenti.al,
                                     progr_presenti.appartenenza,
                                     progr_presenti.dal,
                                     progr_presenti.privilegio,
                                     progr_presenti.progr_unita,
                                     progr_presenti.ruolo,
                                     d_codice,
                                     p_utente);
                  END;
               END LOOP;
            END IF;
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
   END;

   /*****************************************************************************
       NOME:        aggiorna_priv_utente_tmp.
       DESCRIZIONE:  Aggiorna la table AG_PRIV_UTENTE_TMP in base alla pl/sql table
                     p_tabPriv appena riempita.


      INPUT  p_utente  VARCHAR2 di cui si deve verificare se ha privilegio.
             p_tabPriv t_PrivTab pl/sql table appena riempita con i ruoli/privilegi
                                 dell'utente.

      Rev.  Data       Autore      Descrizione.
      001   23/05/2011  MMalferrari Creazione.
                                    A43957.0.0: Evitare la rigenerazione della
                                    tabella AG_PRIV_UTENTE_TMP.
     002   09/03/2017  SC          Introdotto progressivo unità e gestione date
   ********************************************************************************/
   PROCEDURE aggiorna_priv_utente_tmp (p_utente VARCHAR2)
   IS
   BEGIN
      /* cancella tute le righe senza pro
   gressivo, che derivano da login di versioni precedenti*/
      DELETE ag_priv_utente_tmp
       WHERE progr_unita IS NULL AND utente = p_utente;

      -- integritypackage.LOG ('**** aggiorna_priv_utente_tmp ****');

      sistema_codici_unita_prut_temp (p_utente);

      FOR upd
         IN (SELECT priv_new.utente,
                    priv_new.unita,
                    priv_new.ruolo,
                    priv_new.privilegio,
                    priv_new.appartenenza,
                    priv_new.dal,
                    priv_new.progr_unita
               FROM AG_PRUT_TEMP priv_new, ag_priv_utente_tmp
              WHERE     priv_new.utente = p_utente
                    AND ag_priv_utente_tmp.utente = priv_new.utente
                    AND ag_priv_utente_tmp.unita = priv_new.unita
                    AND ag_priv_utente_tmp.progr_unita = priv_new.progr_unita
                    AND ag_priv_utente_tmp.ruolo = priv_new.ruolo
                    AND ag_priv_utente_tmp.privilegio = priv_new.privilegio
                    AND ag_priv_utente_tmp.appartenenza <>
                           priv_new.appartenenza
                    AND (   priv_new.appartenenza = 'D'
                         OR (    priv_new.appartenenza = 'E'
                             AND NOT EXISTS
                                    (SELECT 1
                                       FROM AG_PRUT_TEMP priv_new2
                                      WHERE     utente = priv_new.utente
                                            AND unita = priv_new.unita
                                            AND progr_unita =
                                                   priv_new.progr_unita
                                            AND ruolo = priv_new.ruolo
                                            AND privilegio =
                                                   priv_new.privilegio
                                            AND appartenenza = 'D'))))
      LOOP
         --  integritypackage.LOG ('**** LOOP UPDATE APPARTENENZA ****');
         UPDATE ag_priv_utente_tmp
            SET appartenenza = upd.appartenenza
          WHERE     utente = upd.utente
                AND unita = upd.unita
                AND progr_unita = upd.progr_unita
                AND ruolo = upd.ruolo
                AND privilegio = upd.privilegio;
      END LOOP;

      FOR upd
         IN (SELECT priv_new.utente,
                    priv_new.unita,
                    priv_new.ruolo,
                    priv_new.privilegio,
                    priv_new.dal,
                    priv_new.al,
                    priv_new.appartenenza,
                    priv_new.progr_unita
               FROM AG_PRUT_TEMP priv_new, ag_priv_utente_tmp
              WHERE     priv_new.utente = p_utente
                    AND ag_priv_utente_tmp.utente = priv_new.utente
                    AND ag_priv_utente_tmp.unita = priv_new.unita
                    AND ag_priv_utente_tmp.progr_unita = priv_new.progr_unita
                    AND ag_priv_utente_tmp.ruolo = priv_new.ruolo
                    AND ag_priv_utente_tmp.privilegio = priv_new.privilegio
                    AND ag_priv_utente_tmp.appartenenza =
                           priv_new.appartenenza
                    AND NVL (ag_priv_utente_tmp.al, TO_DATE (3333333, 'j')) <>
                           NVL (priv_new.al, TO_DATE (3333333, 'j')))
      LOOP
         --  integritypackage.LOG ('**** LOOP UPDATE AL ****');
         UPDATE ag_priv_utente_tmp
            SET al = upd.al
          WHERE     utente = upd.utente
                AND unita = upd.unita
                AND progr_unita = upd.progr_unita
                AND ruolo = upd.ruolo
                AND privilegio = upd.privilegio
                AND appartenenza = upd.appartenenza;
      END LOOP;

      BEGIN
         FOR p
            IN (SELECT DISTINCT utente,
                                unita,
                                ruolo,
                                privilegio,
                                appartenenza,
                                dal,
                                al,
                                progr_unita
                  FROM AG_PRUT_TEMP priv_new
                 WHERE     utente = p_utente
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM ag_priv_utente_tmp
                                WHERE     utente = priv_new.utente
                                      AND unita = priv_new.unita
                                      AND progr_unita = priv_new.progr_unita
                                      AND ruolo = priv_new.ruolo
                                      AND privilegio = priv_new.privilegio))
         LOOP
            --    integritypackage.LOG ('**** LOOP INSERT ****');
            BEGIN
               INSERT INTO ag_priv_utente_tmp (utente,
                                               unita,
                                               ruolo,
                                               privilegio,
                                               appartenenza,
                                               dal,
                                               al,
                                               progr_unita)
                    VALUES (p.utente,
                            p.unita,
                            p.ruolo,
                            p.privilegio,
                            p.appartenenza,
                            p.dal,
                            p.al,
                            p.progr_unita);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
            END;
         END LOOP;
      END;

      DELETE ag_priv_utente_tmp
       WHERE (utente,
              unita,
              ruolo,
              privilegio,
              progr_unita) IN (SELECT utente,
                                      unita,
                                      ruolo,
                                      privilegio,
                                      progr_unita
                                 FROM ag_priv_utente_tmp priv_old
                                WHERE utente = p_utente
                               MINUS
                               SELECT utente,
                                      unita,
                                      ruolo,
                                      privilegio,
                                      progr_unita
                                 FROM AG_PRUT_TEMP priv_new
                                WHERE utente = p_utente);

      DELETE ag_priv_utente_tmp priv_new
       WHERE     utente = p_utente
             AND appartenenza = 'E'
             AND EXISTS
                    (SELECT 1
                       FROM ag_priv_utente_tmp priv_old
                      WHERE     priv_old.utente = priv_new.utente
                            AND priv_old.unita = priv_new.unita
                            AND priv_old.progr_unita = priv_new.progr_unita
                            AND priv_old.ruolo = priv_new.ruolo
                            AND priv_old.privilegio = priv_new.privilegio
                            AND appartenenza = 'D');

      -- se non c'è storico ruoli tolgo data chiusura:
      -- sono privilegi di utenti rimasti ultimi in unità definitavamente chiuse
      -- quindi il privilegio su quell'unità resta sempre valido
      -- (non applico a privilegi che danno diritti universali)
      -- Setto 1 nel campo IS_ULTIMA_CHIUSA per ricordare cosa ho fatto

      IF storicoruoli = 'N'
      THEN
         UPDATE ag_priv_utente_tmp
            SET is_ultima_chiusa = 1
          WHERE al IS NOT NULL AND utente = p_utente;

         UPDATE ag_priv_utente_tmp
            SET al = NULL
          WHERE     privilegio NOT IN (SELECT privilegio
                                         FROM ag_privilegi
                                        WHERE is_universale = 1)
                AND is_ultima_chiusa = 1
                AND utente = p_utente;
      END IF;
   --integritypackage.LOG ('**** fine ****');
   END;

   /*010   11/04/2017  SC            Gestione date privilegi e progressivo unita */
   PROCEDURE aggiorna_priv_D_utente_tmp (p_utente VARCHAR2)
   IS
   BEGIN
      integritypackage.LOG ('**** aggiorna_priv_d_utente_tmp ****');

      /* cancella tute le righe senza pro
      gressivo, che derivano da login di versioni precedenti*/
      DELETE ag_priv_d_utente_tmp
       WHERE progr_unita IS NULL AND utente = p_utente;

      /** sistemo le date di chiusura */
      FOR upd
         IN (SELECT priv_new.utente,
                    priv_new.unita,
                    priv_new.ruolo,
                    priv_new.privilegio,
                    priv_new.dal,
                    priv_new.al,
                    priv_new.appartenenza,
                    priv_new.progr_unita
               FROM AG_PRUT_TEMP priv_new, ag_priv_d_utente_tmp
              WHERE     priv_new.utente = p_utente
                    AND ag_priv_d_utente_tmp.utente = priv_new.utente
                    AND ag_priv_d_utente_tmp.unita = priv_new.unita
                    AND ag_priv_d_utente_tmp.progr_unita =
                           priv_new.progr_unita
                    AND ag_priv_d_utente_tmp.ruolo = priv_new.ruolo
                    AND ag_priv_d_utente_tmp.privilegio = priv_new.privilegio
                    AND priv_new.appartenenza = 'D'
                    AND NVL (ag_priv_d_utente_tmp.al, TO_DATE (3333333, 'j')) <>
                           NVL (priv_new.al, TO_DATE (3333333, 'j')))
      LOOP
         UPDATE ag_priv_d_utente_tmp
            SET al = upd.al
          WHERE     utente = upd.utente
                AND unita = upd.unita
                AND progr_unita = upd.progr_unita
                AND ruolo = upd.ruolo
                AND privilegio = upd.privilegio;
      END LOOP;

      /** inserisco le nuove righe */
      BEGIN
         FOR p
            IN (SELECT DISTINCT utente,
                                unita,
                                ruolo,
                                privilegio,
                                appartenenza,
                                dal,
                                al,
                                progr_unita
                  FROM AG_PRUT_TEMP priv_new
                 WHERE     utente = p_utente
                       AND appartenenza = 'D'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM ag_priv_d_utente_tmp
                                WHERE     utente = priv_new.utente
                                      AND unita = priv_new.unita
                                      AND progr_unita = priv_new.progr_unita
                                      AND ruolo = priv_new.ruolo
                                      AND privilegio = priv_new.privilegio))
         LOOP
            BEGIN
               INSERT INTO ag_priv_d_utente_tmp (utente,
                                                 unita,
                                                 ruolo,
                                                 privilegio,
                                                 dal,
                                                 al,
                                                 progr_unita)
                    VALUES (p.utente,
                            p.unita,
                            p.ruolo,
                            p.privilegio,
                            p.dal,
                            p.al,
                            p.progr_unita);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
            END;
         END LOOP;
      END;

      /** cancello le righe che non ci sono piu' **/
      DELETE ag_priv_d_utente_tmp
       WHERE (utente,
              unita,
              ruolo,
              privilegio,
              progr_unita) IN (SELECT utente,
                                      unita,
                                      ruolo,
                                      privilegio,
                                      progr_unita
                                 FROM ag_priv_d_utente_tmp priv_old
                                WHERE utente = p_utente
                               MINUS
                               SELECT utente,
                                      unita,
                                      ruolo,
                                      privilegio,
                                      progr_unita
                                 FROM AG_PRUT_TEMP priv_new
                                WHERE     utente = p_utente
                                      AND appartenenza = 'D');

      -- se non c'è storico ruoli tolgo data chiusura:
      -- sono privilegi di utenti rimasti ultimi in unità definitavamente chiuse
      -- quindi il privilegio su quell'unità resta sempre valido
      -- (non applico a privilegi che danno diritti universali)
      -- Setto 1 nel campo IS_ULTIMA_CHIUSA per ricordare cosa ho fatto

      IF storicoruoli = 'N'
      THEN
         UPDATE ag_priv_d_utente_tmp
            SET is_ultima_chiusa = 1
          WHERE al IS NOT NULL AND utente = p_utente;

         UPDATE ag_priv_d_utente_tmp
            SET al = NULL
          WHERE     privilegio NOT IN (SELECT privilegio
                                         FROM ag_privilegi
                                        WHERE is_universale = 1)
                AND is_ultima_chiusa = 1
                AND utente = p_utente;
      END IF;
   END aggiorna_priv_D_utente_tmp;


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

          SELECT COUNT (gruppo)
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
       WHERE     paoo.tipo_modello = '@agVar@'
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
       WHERE     tipo_modello = '@agVar@'
             AND codice = 'SO_OTTICA_PROT_' || p_indice_aoo;

      RETURN ottica;
   EXCEPTION
      WHEN OTHERS
      THEN
         ottica := '*';
         RETURN ottica;
   END;

   FUNCTION get_ottica_utente (p_utente        VARCHAR2,
                               p_codice_amm    VARCHAR2,
                               p_codice_aoo    VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
         NAME:       GET_OTTICA_UTENTE
         PURPOSE:    Dato il codice utente e l''aoo per la quale lavora, restituisce
                     l'ottica di SO4 utilizzata dalla Aoo.
            Se l'aoo non e' specificata, va ricavata in base alla posizione dell'utente
            in
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

      OUTPUT 0 se p_utente nn ¿ presente su AG_PRIV_UTENTE_TMP (cio¿ se non ha nessun ruolo nella
               struttura organizzativa)
             1 se presente


       Rev.  Data       Autore  Descrizione.
       00    26/06/2007  SC  Prima emissione.
       01    11/04/2017  SC  P_DATA DEVE ESSERE < AL
      ********************************************************************************/
   FUNCTION inizializza_utente (p_utente    VARCHAR2,
                                p_data      DATE DEFAULT TRUNC (SYSDATE) /*NULL*/
                                                                        )
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
          WHERE     ag_priv_utente_tmp.utente = p_utente
                AND (NVL (p_data, TRUNC (SYSDATE)) /* IS NULL

                    OR p_data BETWEEN dal
                                  AND*/
                                                  <=
                        NVL (al, TO_DATE (3333333, 'j')))
                AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := 0;
      END;

      RETURN retval;
   END inizializza_utente;

   PROCEDURE inizializza_ag_priv_utente_tmp (
      p_utente                VARCHAR2,
      p_calcola_estensioni    NUMBER DEFAULT 1)
   IS
      /*****************************************************************************
          NOME:        inizializza_ag_priv_utente_tmp.
          DESCRIZIONE: Riempie la table AG_PRIV_UTENTE_TMP con utente, unita di cui
                       fa parte, ruoli che ha nelle unita'.

         INPUT  p_utente   varchar2:   utente che di cui si vogliono conoscere unita'
                                       di appartenenza e ruoli.
         Rev.  Data        Autore      Descrizione.
         001   23/05/2011  MMalferrari A43957.0.0: Evitare la rigenerazione della
                                       tabella AG_PRIV_UTENTE_TMP.
         003   08/05/2013  MMalferrari Aggiunto parametro p_calcola_estensioni
      ********************************************************************************/
      retval    NUMBER := 0;
      d_count   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO d_count
        FROM AG_PRIV_UTENTE_BLACKLIST
       WHERE utente = p_utente;

      IF d_count = 0
      THEN
         retval := inizializza_utente (p_utente => p_utente);
         riempi_unita_utente_tab (p_utente => p_utente);

         IF p_calcola_estensioni = 1
         THEN
            riempi_unita_estese (p_utente => p_utente);
         END IF;

         aggiorna_priv_utente_tmp (p_utente => p_utente);
         aggiorna_priv_D_utente_tmp (p_utente => p_utente);
      END IF;
   END;

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
      retval   NUMBER;
   BEGIN
      SELECT docu.id_documento
        INTO retval
        FROM documenti docu, proto_view
       WHERE     docu.id_documento = proto_view.id_documento
             AND proto_view.idrif = p_idrif
             AND docu.stato_documento NOT IN ('CA', 'RE');

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_protocollo_per_idrif;

   FUNCTION get_documento_per_idrif (p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      SELECT docu.id_documento
        INTO retval
        FROM documenti docu, classificabile_view
       WHERE     docu.id_documento = classificabile_view.id_documento
             AND classificabile_view.idrif = p_idrif
             AND docu.stato_documento NOT IN ('CA', 'RE');

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_documento_per_idrif;

   FUNCTION get_fascicolo_per_idrif (p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      SELECT docu.id_documento
        INTO retval
        FROM documenti docu, seg_fascicoli fasc, cartelle cart
       WHERE     docu.id_documento = fasc.id_documento
             AND fasc.idrif = p_idrif
             AND docu.stato_documento NOT IN ('CA', 'RE')
             AND docu.id_documento = cart.id_documento_profilo
             AND NVL (cart.stato, 'BO') != 'CA';

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_fascicolo_per_idrif;

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
   FUNCTION get_id_documento (p_area                VARCHAR2,
                              p_modello             VARCHAR2,
                              p_codice_richiesta    VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      BEGIN
         SELECT docu.id_documento
           INTO retval
           FROM documenti docu, modelli MOD
          WHERE     MOD.area = p_area
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
   FUNCTION get_id_documento_fascicolo (p_class_cod     VARCHAR2,
                                        p_class_dal     DATE,
                                        p_anno          NUMBER,
                                        p_numero        VARCHAR2,
                                        p_indice_aoo    NUMBER)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      BEGIN
         SELECT docu.id_documento
           INTO retval
           FROM documenti docu, seg_fascicoli
          WHERE     docu.id_documento = seg_fascicoli.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE')
                AND seg_fascicoli.class_cod = p_class_cod
                AND seg_fascicoli.class_dal = p_class_dal
                AND seg_fascicoli.fascicolo_anno = p_anno
                AND seg_fascicoli.fascicolo_numero = p_numero;
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
   FUNCTION get_stato_fascicolo (p_class_cod     VARCHAR2,
                                 p_class_dal     DATE,
                                 p_anno          NUMBER,
                                 p_numero        VARCHAR2,
                                 p_indice_aoo    NUMBER)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (200);
   BEGIN
      BEGIN
         SELECT seg_fascicoli.stato_fascicolo
           INTO retval
           FROM documenti docu, seg_fascicoli
          WHERE     docu.stato_documento NOT IN ('CA', 'RE')
                AND docu.id_documento = seg_fascicoli.id_documento
                AND seg_fascicoli.class_cod = p_class_cod
                AND seg_fascicoli.class_dal = p_class_dal
                AND seg_fascicoli.fascicolo_anno = p_anno
                AND seg_fascicoli.fascicolo_numero = p_numero;
      EXCEPTION
         WHEN OTHERS
         THEN
            retval := '0';
      END;

      RETURN retval;
   END get_stato_fascicolo;

   FUNCTION verifica_categoria_documento (p_area         VARCHAR2,
                                          p_cm           VARCHAR2,
                                          p_cr           VARCHAR2,
                                          p_categoria    VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      RETURN verifica_categoria_documento (
                get_id_documento (p_area, p_cm, p_cr),
                p_categoria);
      RETURN retval;
   END verifica_categoria_documento;

   /*****************************************************************************
    NOME:        VERIFICA_CATEGORIA_DOCUMENTO
    DESCRIZIONE: Verifica se il tipo documento del documento identificato da p_id_documento
    ¿ di catagoria p_categoria.

   INPUT  p_id_documento: identificativo del documento di cui verificare la categoria.
         p_categoria varchar2: codice della categoria di cui si vuole vedere se p_id_documento fa parte.
   RITORNO:  1 se p_id_documento ¿ di categoria p_categoria, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    30/05/2007  SC  Prima emissione.
   ********************************************************************************/
   FUNCTION verifica_categoria_documento (
      p_id_documento        VARCHAR2,
      p_categoria           VARCHAR2,
      p_check_cancellato    NUMBER DEFAULT 1)
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      ----INTEGRITYPACKAGE.LOG('PRIMA verifica_categoria_documento '||p_categoria);
      BEGIN
         SELECT 1
           INTO retval
           FROM documenti docu, tipi_documento tido, categorie_modello camo
          WHERE     docu.id_documento = p_id_documento
                AND docu.id_tipodoc = tido.id_tipodoc
                AND tido.nome = camo.codice_modello
                AND camo.area = docu.area
                AND camo.categoria = p_categoria
                AND (   p_check_cancellato = 0
                     OR (    p_check_cancellato = 1
                         AND docu.stato_documento NOT IN ('CA', 'RE')));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE;
      END;

      ----INTEGRITYPACKAGE.LOG('DOPO verifica_categoria_documento '||retval);
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
 p_data data alla quale il privilegio deve essere verificato, se null non controlla le date.


            Ha senso solo se p_Unita non e' nulla.
   RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.

    Rev.  Data       Autore  Descrizione.
    00    02/01/2007  SC  Prima emissione.
    01    30/03/2017  SC p_data <= al anziche between dal and al.
   ********************************************************************************/
   FUNCTION verifica_privilegio_utente (p_unita         VARCHAR2,
                                        p_privilegio    VARCHAR2,
                                        p_utente        VARCHAR2,
                                        p_data          DATE DEFAULT NULL)
      RETURN NUMBER
   IS
      retval     NUMBER := 0;
      dep_data   DATE := NVL (p_data, TRUNC (SYSDATE));
   BEGIN
      IF p_utente = utente_superuser_segreteria
      THEN
         RETURN 1;
      END IF;

      IF p_unita IS NULL
      THEN
         BEGIN
            SELECT 1
              INTO retval
              FROM DUAL
             WHERE     EXISTS
                          (SELECT 1
                             FROM ag_priv_utente_tmp
                            WHERE     utente = p_utente
                                  AND privilegio = p_privilegio
                                  AND (dep_data <= /*BETWEEN dal
                                                  AND*/
                                          NVL (al, TO_DATE (3333333, 'j'))))
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
             WHERE     utente = p_utente
                   AND privilegio = p_privilegio
                   AND unita = p_unita
                   AND (dep_data <= /*BETWEEN dal
                                                  AND*/
                                   NVL (al, TO_DATE (3333333, 'j')))
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
    NOME:        VERIFICA_MF_UTENTE
    DESCRIZIONE:

   INPUT
   RITORNO:

    Rev.  Data       Autore  Descrizione.
    00                       Prima emissione.
    01    30/30/2017  SC p_data <= al anziche between dal and al.
   ********************************************************************************/
   FUNCTION verifica_mf_utente (p_utente VARCHAR2, p_data DATE)
      RETURN NUMBER
   IS
      retval     NUMBER := 0;
      dep_data   DATE := p_Data;
   BEGIN
      IF dep_data IS NULL
      THEN
         dep_data := TRUNC (SYSDATE);
      END IF;

      BEGIN
         SELECT DISTINCT 1
           INTO retval
           FROM ag_priv_utente_tmp
          WHERE     utente = p_utente
                AND privilegio LIKE 'MF%'
                AND (dep_data <= /*BETWEEN dal
                                AND*/
                                NVL (al, TO_DATE (3333333, 'j')))
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
   END verifica_mf_utente;

   /*****************************************************************************
     NOME:        VERIFICA_ISMI_UTENTE
     DESCRIZIONE:

    INPUT
    RITORNO:

     Rev.  Data       Autore  Descrizione.
     00                       Prima emissione.
     01    30/30/2017  SC p_data <= al anziche between dal and al.
    ********************************************************************************/
   FUNCTION verifica_ismi_utente (p_utente VARCHAR2, p_data DATE)
      RETURN NUMBER
   IS
      retval     NUMBER := 0;
      dep_data   DATE := NVL (p_Data, TRUNC (SYSDATE));
   BEGIN
      BEGIN
         SELECT DISTINCT 1
           INTO retval
           FROM ag_priv_utente_tmp
          WHERE     utente = p_utente
                AND privilegio LIKE 'ISMI%'
                AND (dep_data <= /*BETWEEN dal
                                AND*/
                                NVL (al, TO_DATE (3333333, 'j')))
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
   END verifica_ismi_utente;

   /*****************************************************************************
       NOME:        VERIFICA_UNITA_UTENTE
       DESCRIZIONE: Verifica se l'utente appartiene all'unita specificata:

      INPUT  p_utente varchar2: utente che di cui verificare l'appartenenza.
         p_unita  varchar2 codice dell'unita' cui p_utente deve appartenere.
      RITORNO:  1 se l'utente appartiene a p_untia, 0 altrimenti.

       Rev.  Data       Autore      Descrizione.
       000   02/01/2007 SC          Prima emissione.
       002   09/03/2012 MMalferrari Aggiunto parametro p_dal.
       003   30/03/2017  SC         p_dal <= al anziche between dal and al.
      ********************************************************************************/
   FUNCTION verifica_unita_utente (p_unita     VARCHAR2,
                                   p_utente    VARCHAR2,
                                   p_dal       DATE DEFAULT TRUNC (SYSDATE) /*NULL*/
                                                                           )
      RETURN NUMBER
   IS
      retval   NUMBER := 0;
   BEGIN
      retval := inizializza_utente (p_utente => p_utente);

      BEGIN
         SELECT 1
           INTO retval
           FROM DUAL
          WHERE     EXISTS
                       (SELECT 1
                          FROM ag_priv_d_utente_tmp
                         WHERE     utente = p_utente
                               AND unita = p_unita
                               AND (NVL (p_dal, TRUNC (SYSDATE)) <= /*BETWEEN dal
                                     AND*/
                                       NVL (al, TO_DATE (3333333, 'j'))))
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
       cio¿ p_unita stessa o un'ascendente o una discendente.

      INPUT  p_utente varchar2: utente che di cui verificare l'appartenenza.
         p_unita  varchar2 codice dell'unita' al cui ramo p_utente deve appartenere.
      RITORNO:  1 se l'utente appartiene ad un'unita del ramo di p_unita, 0 altrimenti.

       Rev.  Data       Autore  Descrizione.
       00    02/01/2007  SC  Prima emissione.
      ********************************************************************************/
   FUNCTION verifica_ramo_utente (p_unita VARCHAR2, p_utente VARCHAR2)
      RETURN NUMBER
   IS
      retval                NUMBER := 0;
      unitadiscendenti      t_ref_cursor;
      unitaascendenti       t_ref_cursor;
      depunita              seg_unita.unita%TYPE;
      depdescrizioneunita   VARCHAR2 (1000);
      progressivounita      NUMBER;
      dalunita              DATE;
      alunita               DATE;
      dloop                 NUMBER := 0;
      depesistenew          BOOLEAN := TRUE;
   BEGIN
      retval := verifica_unita_utente (p_unita, p_utente);

      --verifica se p_utente appartiene a una unita figlia di p_unita
      IF retval = 0
      THEN
         unitadiscendenti :=
            SO4_AGS_PKG.unita_get_discendenti (p_unita, NULL, ottica);

         IF unitadiscendenti%ISOPEN
         THEN
            LOOP
               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
               -- non consideriamo lo storico dell'unita'.
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH unitadiscendenti
                        INTO progressivounita,
                             depunita,
                             depdescrizioneunita,
                             dalunita,
                             alunita;
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
                              INTO progressivounita,
                                   depunita,
                                   depdescrizioneunita,
                                   dalunita;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH unitadiscendenti
                        INTO progressivounita,
                             depunita,
                             depdescrizioneunita,
                             dalunita,
                             alunita;
                  ELSE
                     FETCH unitadiscendenti
                        INTO progressivounita,
                             depunita,
                             depdescrizioneunita,
                             dalunita;
                  END IF;
               END IF;

               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: fine mod.
               EXIT WHEN unitadiscendenti%NOTFOUND OR retval = 1;
               retval := verifica_unita_utente (depunita, p_utente);
            END LOOP;

            CLOSE unitadiscendenti;
         END IF;
      END IF;

      --verifica se p_utente appartiene a una unita ascendente di p_unita
      IF retval = 0
      THEN
         unitaascendenti :=
            SO4_AGS_PKG.unita_get_ascendenti (p_unita, NULL, ottica);

         IF unitaascendenti%ISOPEN
         THEN
            LOOP
               FETCH unitaascendenti
                  INTO progressivounita,
                       depunita,
                       depdescrizioneunita,
                       dalunita;

               EXIT WHEN unitaascendenti%NOTFOUND OR retval = 1;
               retval := verifica_unita_utente (depunita, p_utente);
            END LOOP;

            CLOSE unitaascendenti;
         END IF;
      END IF;

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
       WHERE     view_cartella.id_viewcartella = p_id_viewcartella
             AND view_cartella.id_cartella = cartelle.id_cartella;

      RETURN retval;
   END get_id_profilo;

   FUNCTION get_id_viewcartella (p_id_profilo VARCHAR2)
      RETURN NUMBER
   IS
      retval   NUMBER;
   BEGIN
      SELECT view_cartella.id_viewcartella
        INTO retval
        FROM view_cartella, cartelle
       WHERE     cartelle.id_documento_profilo = p_id_profilo
             AND view_cartella.id_cartella = cartelle.id_cartella;

      RETURN retval;
   END get_id_viewcartella;

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
          WHERE     a.area = t.area_modello
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
       WHERE     docu.stato_documento NOT IN ('CA', 'RE')
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
 DESCRIZIONE: Restituisce il valore di PARAMETRI DATA_BLOCCO_n dove n ¿ l'indice dell'aoo
 indicata.
 Se non presente o null restiscuire 01/01/1900.
 In caso di errore restiscuire 31/12/2999.

INPUT  p_CODICE_AMMINISTRAZIONE VARCHAR2, p_CODICE_AOO VARCHAR2
RITORNO:valore di PARAMETRI DATA_BLOCCO_n

 Rev.  Data       Autore  Descrizione.
 00    04/06/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION get_data_blocco (p_codice_amministrazione    VARCHAR2,
                             p_codice_aoo                VARCHAR2)
      RETURN DATE
   IS
      datablocco   DATE;
   BEGIN
      BEGIN
         SELECT TO_DATE (NVL (MAX (valore), '01/01/1900'), 'DD/MM/YYYY')
           INTO datablocco
           FROM parametri
          WHERE     codice =
                          'DATA_BLOCCO_'
                       || get_indice_aoo (p_codice_amministrazione,
                                          p_codice_aoo)
                AND tipo_modello = '@agVar@';
      EXCEPTION
         WHEN OTHERS
         THEN
            datablocco := TO_DATE ('31/12/2999', 'DD/MM/YYYY');
      END;

      RETURN datablocco;
   END get_data_blocco;

   PROCEDURE valorizza_aoo (p_table_name                VARCHAR2,
                            p_codice_amministrazione    VARCHAR2,
                            p_codice_aoo                VARCHAR2)
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
      conta                NUMBER := 0;
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
            FETCH righe INTO dep_id_documento;

            EXIT WHEN righe%NOTFOUND;
            ----INTEGRITYPACKAGE.LOG ('ID ' || dep_id_documento);
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
               ----INTEGRITYPACKAGE.LOG ('----SIAMO A 100!!!----');
               conta := 0;
            END IF;
         END LOOP;

         COMMIT;
      ----INTEGRITYPACKAGE.LOG ('----FINE!!!----');
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
    Il tipo smistamento di default ¿ quello con predominanza maggiore,
    cio¿ col valore minore in AG_TIPI_SMISTAMENTO.IMPORTANZA.


   INPUT  p_CODICE_AMMINISTRAZIONE VARCHAR2, p_CODICE_AOO VARCHAR2 chiave dell'aoo attiva
            p_area , p_codice_modello chiave identificativa del modello
   RITORNO:valore di PARAMETRI DATA_BLOCCO_n

    Rev.  Data       Autore  Descrizione.
    00    10/03/2008  SC  Prima emissione. A
   ********************************************************************************/
   FUNCTION get_default_tipo_smistamento (
      p_codice_amministrazione    VARCHAR2,
      p_codice_aoo                VARCHAR2,
      p_area                      VARCHAR2,
      p_codice_modello            VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   ag_tipi_smistamento.tipo_smistamento%TYPE;
   BEGIN
      SELECT tsmo.tipo_smistamento
        INTO retval
        FROM ag_tipi_smistamento_modello tsmo, ag_tipi_smistamento tism
       WHERE     tsmo.aoo =
                    get_indice_aoo (p_codice_amministrazione, p_codice_aoo)
             AND tsmo.area = p_area
             AND tsmo.codice_modello = p_codice_modello
             AND tsmo.tipo_smistamento = tism.tipo_smistamento
             AND tsmo.aoo = tism.aoo
             AND importanza <=
                    (SELECT MIN (importanza)
                       FROM ag_tipi_smistamento, ag_tipi_smistamento_modello
                      WHERE     ag_tipi_smistamento.aoo = tism.aoo
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
   FUNCTION documento_is_in_categoria (p_id_documento    NUMBER,
                                       p_categoria       VARCHAR2)
      RETURN NUMBER
   IS
      tmpvar   NUMBER;
   BEGIN
      SELECT DISTINCT 1
        INTO tmpvar
        FROM documenti,
             tipi_documento,
             categorie_modello,
             categorie
       WHERE     id_documento = p_id_documento
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
   BEGIN
      RETURN categoriadelibere;
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
   BEGIN
      RETURN categoriadetermine;
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
   FUNCTION get_unita_radice (p_codice_unita        VARCHAR2,
                              p_data_riferimento    DATE,
                              p_ottica              VARCHAR2)
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
         SO4_AGS_PKG.unita_get_ascendenti (p_codice_unita,
                                           p_data_riferimento,
                                           p_ottica);



      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
               INTO depprogr,
                    dep_codice_unita_padre,
                    depdescrizioneunita,
                    dep_dal_padre,
                    dep_al_padre;

            EXIT WHEN cascendenti%NOTFOUND;
         ----INTEGRITYPACKAGE.LOG(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
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
        l'unit¿ che non ha padre.
        Se ag_suddivisioni contiene righe, l'unit¿ di area ¿ la prima
        ascendente di p_codice_unita (lei compresa) la cui suddivisione
        ¿ presente in ag_suddivisioni.

       INPUT  p_codice_unita varchar2 CODICE UNITA DI CUI CERCARE LA RADICE .
       p_data_riferimento data di validita delle unita.
       p_ottica OTTICA DI SO4 DA UTILIZZARE.
      RITORNO:  codice dell'unita tra le unita ascendenti di p_codice_unita
      quella che non ha padre.

       Rev.  Data       Autore  Descrizione.
       00    15/02/2010  SC  Prima emissione. A34954.2.0
   ********************************************************************************/
   PROCEDURE leggi_unita_radice_area (
      p_progr_unita                  NUMBER,
      p_data_riferimento             DATE,
      p_ottica                       VARCHAR2,
      p_codice_amministrazione       VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      a_progr_unita_radice       OUT NUMBER,
      a_codice_unita_radice      OUT VARCHAR2)
   IS
      cascendenti              afc.t_ref_cursor;
      depprogr                 NUMBER;
      dep_codice_unita_padre   seg_unita.unita%TYPE;
      depdescrizioneunita      VARCHAR2 (1000);
      dep_dal_padre            DATE;
      dep_al_padre             DATE;
      suddivisione_presente    NUMBER := 0;
      dep_suddivisione         NUMBER;
   BEGIN
      NULL;
      cascendenti :=
         so4_util.get_ascendenti_sudd (p_progr_unor   => p_progr_unita,
                                       p_data         => p_data_riferimento,
                                       p_ottica       => p_ottica);

      --         SO4_AGS_PKG.unita_get_ascendenti_sudd (p_codice_unita,
      --                                                    p_data_riferimento,
      --                                                    p_ottica);



      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
               INTO depprogr,
                    dep_codice_unita_padre,
                    depdescrizioneunita,
                    dep_dal_padre,
                    dep_al_padre,
                    dep_suddivisione;

            EXIT WHEN cascendenti%NOTFOUND OR suddivisione_presente = 1;

            BEGIN
               SELECT 1
                 INTO suddivisione_presente
                 FROM ag_suddivisioni
                WHERE     dep_suddivisione = id_suddivisione
                      AND indice_aoo =
                             get_indice_aoo (p_codice_amministrazione,
                                             p_codice_aoo);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            EXIT WHEN suddivisione_presente = 1;
         ----INTEGRITYPACKAGE.LOG(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
         --                  p_dal_padre||', '||p_al_padre);
         END LOOP;

         CLOSE cascendenti;
      END IF;

      a_progr_unita_radice := depprogr;
      a_codice_unita_radice := dep_codice_unita_padre;
   END leggi_unita_radice_area;



   /*****************************************************************************
       NOME:        get_unita_priviegio_utente.

       DESCRIZIONE: Dati utente e privilegio, restituisce il cursore dei codici
       delle unita per cui l'utente ha il privilegio.

       INPUT  p_utente varchar2 CODICE UTENTE .
       p_privilegio codice privilegio.
      RITORNO:  cursore delle unita per le quali p_utente ha p_privilegio.

       Rev.  Data       Autore  Descrizione.
       00    04/09/2008  SC  Prima emissione. A28345.2.0
   ********************************************************************************/
   FUNCTION get_unita_priviegio_utente (p_utente        VARCHAR2,
                                        p_privilegio    VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      ----INTEGRITYPACKAGE.LOG ('get_unita_priviegio_utente ');
      OPEN d_result FOR
         SELECT DISTINCT ag_priv_utente_tmp.unita,
                         ag_priv_utente_tmp.dal,
                         ag_priv_utente_tmp.al,
                         ag_priv_utente_tmp.progr_unita
           FROM ag_priv_utente_tmp
          WHERE     ag_priv_utente_tmp.utente = p_utente
                AND privilegio = p_privilegio;

      ----INTEGRITYPACKAGE.LOG ('get_unita_priviegio_utente p_utente ' || p_utente);
      ----INTEGRITYPACKAGE.LOG (   'get_unita_priviegio_utente p_privilegio '
      --                            || p_privilegio
      --                           );
      RETURN d_result;
   END;

   /*****************************************************************************
       NOME:        documento_get_descrizione.

       DESCRIZIONE: Restituisce una stringa con i dati pi¿ significativi del
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
             || DECODE (
                   prot.numero,
                   NULL, NULL,
                      ' n. '
                   || prot.numero
                   || ' del '
                   || TO_CHAR (prot.DATA, 'dd/mm/yyyy'))
             || ' - Oggetto: '
             || prot.oggetto
        INTO d_estremi_documento
        FROM seg_registri sere,
             proto_view prot,
             documenti dreg,
             documenti dpro
       WHERE     sere.anno_reg = prot.anno
             AND sere.tipo_registro = prot.tipo_registro
             AND prot.id_documento = TO_NUMBER (p_id_documento)
             AND prot.id_documento = dpro.id_documento
             AND dpro.stato_documento NOT IN ('CA', 'RE')
             AND sere.id_documento = dreg.id_documento
             AND dreg.stato_documento NOT IN ('CA', 'RE')
             AND UPPER (sere.codice_aoo) = UPPER (prot.codice_aoo)
             AND UPPER (sere.codice_amministrazione) =
                    UPPER (prot.codice_amministrazione);

      RETURN d_estremi_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_utilities.documento_get_descrizione: ' || SQLERRM);
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
       01    11/04/2017  SC  Gestione date privilegi
      ********************************************************************************/
   FUNCTION get_responsabile_privilegio (p_codice_uo     VARCHAR2,
                                         p_privilegio    VARCHAR2,
                                         p_cod_amm       VARCHAR2,
                                         p_cod_aoo       VARCHAR2)
      RETURN VARCHAR2
   IS
      d_ottica        VARCHAR2 (18);
      d_ni            NUMBER;
      d_descr         VARCHAR2 (400);
      d_nome_utente   VARCHAR2 (50);
      retval          SYS_REFCURSOR;
   BEGIN
      d_ottica := get_ottica_aoo (get_indice_aoo (p_cod_amm, p_cod_aoo));
      retval :=
         SO4_AGS_PKG.unita_get_responsabile (NULL,
                                             p_codice_uo,
                                             d_ottica,
                                             NULL,
                                             NULL);



      LOOP
         FETCH retval INTO d_ni, d_descr;

         EXIT WHEN retval%NOTFOUND;

         IF (d_ni IS NOT NULL)
         THEN
            d_nome_utente := SO4_AGS_PKG.comp_get_utente (d_ni);

            IF (d_descr IS NOT NULL AND LENGTH (d_nome_utente) > 0)
            THEN
               IF (verifica_privilegio_utente (p_codice_uo,
                                               p_privilegio,
                                               d_nome_utente,
                                               TRUNC (SYSDATE)) = 1)
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
      d_ret         NUMBER := 0;
      d_pos         NUMBER := -1;
      d_numero      VARCHAR2 (20) := '';
      d_id_doc      VARCHAR2 (20) := '';
      d_last_fasc   VARCHAR2 (20) := '';
      d_prev_fasc   VARCHAR2 (20) := '';
   BEGIN
      SELECT fascicolo_numero
        INTO d_numero
        FROM seg_fascicoli f
       WHERE f.id_documento = new_id_documento_profilo;

      d_pos := INSTR (d_numero, '.', -1);
      d_prev_fasc := SUBSTR (d_numero, 1, d_pos - 1);
      d_last_fasc := SUBSTR (d_numero, d_pos + 1);

      IF (d_pos > 0)
      THEN
         --         --INTEGRITYPACKAGE.LOG (   'SUBFASCICOLO '
         --                               || new_id_documento_profilo
         --                               || '#'
         --                               || d_prev_fasc
         --                              );
         SELECT f2.id_documento
           INTO d_id_doc
           FROM seg_fascicoli f1, seg_fascicoli f2, cartelle ca
          WHERE     f1.id_documento = new_id_documento_profilo
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
         -- --INTEGRITYPACKAGE.LOG ('FASCICOLO');
         FOR n
            IN (  SELECT nucl.id_documento, nucl.anno
                    FROM seg_classificazioni clas,
                         seg_fascicoli fasc,
                         cartelle cart,
                         seg_numerazioni_classifica nucl,
                         documenti docu_nucl,
                         documenti docu_clas
                   WHERE     fasc.id_documento = new_id_documento_profilo
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
                                     fasc.fascicolo_anno) = nucl.anno
                ORDER BY nucl.anno DESC)
         LOOP
            -- La riga di seg_numerazioni_classifica  di cui
            -- interessa portare indietro il numero e'
            -- quella del fascicolo, se la classificazione NON ha numerazione
            -- illimitata, altrimenti ¿ il max(numerazione_classifica.anno).
            UPDATE seg_numerazioni_classifica nucl
               SET nucl.ultimo_numero_sub = nucl.ultimo_numero_sub - 1
             WHERE     nucl.id_documento = n.id_documento
                   AND ultimo_numero_sub = d_last_fasc;

            EXIT;
         END LOOP;

         d_ret := 1;
      END IF;

      RETURN d_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- --INTEGRITYPACKAGE.LOG ('no data found');
         -- Consider logging the error and then re-raise
         RETURN 0;
      WHEN OTHERS
      THEN
         ----INTEGRITYPACKAGE.LOG ('OTHERS');
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
   PROCEDURE init_ag_priv_utente_login (p_utente     VARCHAR2,
                                        p_db_user    VARCHAR2,
                                        p_tipo       VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      d_continua   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT DISTINCT 1
           INTO d_continua
           FROM AD4_ISTANZE
          WHERE     ISTANZA IN ('DBFW', 'GDM', 'JWFWEB')
                AND UPPER (USER_ORACLE) = p_db_user;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_continua := 0;
      END;

      IF d_continua = 1 AND UPPER (p_tipo) = 'LOGON'
      THEN
         DBMS_OUTPUT.PUT_LINE ('INIZIO');
         inizializza_ag_priv_utente_tmp (p_utente);
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END init_ag_priv_utente_login;

   FUNCTION is_iter_fascicoli_attivo
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      IF ag_parametro.get_valore ('ITER_FASCICOLI_' || indiceaoo,
                                  '@agVar@',
                                  'N') = 'Y'
      THEN
         ret := 1;
      END IF;

      RETURN ret;
   END;

   /*****************************************************************************
    NOME:        IS_UNITA_IN_AREA
    DESCRIZIONE:  Verifica se p_codice_unita ¿ discendente di p_codice_area.

   INPUT
   p_codice_area     VARCHAR2 codice unit¿ radice di area
   p_codice_unita    VARCHAR2 codice unit¿ di cui si deve verificare se sta nell'
                            area di p_codice_area.
   p_data            DATE   Data di riferimento in cui viene chiesta la struttura.
   p_ottica          VARCHAR2 ottica delle unit¿.
   output
   NUMBER   1 se va a buon fine 0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    09/03/2010  SC  Prima emissione A34954.5.1 D1039.
   ********************************************************************************/
   FUNCTION is_unita_in_area (p_codice_area     VARCHAR2,
                              p_codice_unita    VARCHAR2,
                              p_data            DATE,
                              p_ottica          VARCHAR2)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      DECLARE
         dep_progr_figlio         NUMBER;
         dep_codice_figlio        VARCHAR2 (1000);
         dep_descrizione_figlio   VARCHAR2 (32000);
         dep_dal_figlio           DATE;
         dep_al_figlio            DATE;
         v_cur                    afc.t_ref_cursor;
         dloop                    NUMBER := 0;
         depesistenew             BOOLEAN := TRUE;
      BEGIN
         v_cur :=
            SO4_AGS_PKG.unita_get_discendenti (p_codice_uo   => p_codice_area,
                                               p_data        => p_data,
                                               p_ottica      => p_ottica);

         IF v_cur%ISOPEN
         THEN
            LOOP
               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
               -- non consideriamo lo storico dell'unita'.
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH v_cur
                        INTO dep_progr_figlio,
                             dep_codice_figlio,
                             dep_descrizione_figlio,
                             dep_dal_figlio,
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
                              INTO dep_progr_figlio,
                                   dep_codice_figlio,
                                   dep_descrizione_figlio,
                                   dep_dal_figlio;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH v_cur
                        INTO dep_progr_figlio,
                             dep_codice_figlio,
                             dep_descrizione_figlio,
                             dep_dal_figlio,
                             dep_al_figlio;
                  ELSE
                     FETCH v_cur
                        INTO dep_progr_figlio,
                             dep_codice_figlio,
                             dep_descrizione_figlio,
                             dep_dal_figlio;
                  END IF;
               END IF;

               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: fine mod.
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

   /*****************************************************************************
    NOME:        IS_UNITA_IN_AREA
    DESCRIZIONE:  Verifica se p_progr_unita ¿ discendente di p_progr_area.

   INPUT
   p_progr_area     NUMBER codice unit¿ radice di area
   p_progr_unita    NUMBER codice unit¿ di cui si deve verificare se sta nell'
                            area di p_codice_area.
   p_data            DATE   Data di riferimento in cui viene chiesta la struttura.
   p_ottica          VARCHAR2 ottica delle unit¿.
   output
   NUMBER   1 se va a buon fine 0 altrimenti

    Rev.  Data       Autore  Descrizione.
    00    31/03/2017  SC  Prima emissione
   ********************************************************************************/
   FUNCTION is_unita_in_area (p_progr_area     NUMBER,
                              p_progr_unita    NUMBER,
                              p_data           DATE,
                              p_ottica         VARCHAR2)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      DECLARE
         dep_progr_figlio         NUMBER;
         dep_codice_figlio        VARCHAR2 (1000);
         dep_descrizione_figlio   VARCHAR2 (32000);
         dep_dal_figlio           DATE;
         dep_al_figlio            DATE;
         v_cur                    afc.t_ref_cursor;
         dloop                    NUMBER := 0;
         depesistenew             BOOLEAN := TRUE;
      BEGIN
         v_cur :=
            SO4_AGS_PKG.get_discendenti (p_progr_unor   => p_progr_area,
                                         p_data         => p_data,
                                         p_ottica       => p_ottica);

         IF v_cur%ISOPEN
         THEN
            LOOP
               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: Calcolo PRIVILEGI estesi:
               -- non consideriamo lo storico dell'unita'.
               dloop := dloop + 1;

               IF dloop = 1
               THEN
                  BEGIN
                     FETCH v_cur
                        INTO dep_progr_figlio,
                             dep_codice_figlio,
                             dep_descrizione_figlio,
                             dep_dal_figlio,
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
                              INTO dep_progr_figlio,
                                   dep_codice_figlio,
                                   dep_descrizione_figlio,
                                   dep_dal_figlio;
                        END IF;
                  END;
               ELSE
                  IF depesistenew
                  THEN
                     FETCH v_cur
                        INTO dep_progr_figlio,
                             dep_codice_figlio,
                             dep_descrizione_figlio,
                             dep_dal_figlio,
                             dep_al_figlio;
                  ELSE
                     FETCH v_cur
                        INTO dep_progr_figlio,
                             dep_codice_figlio,
                             dep_descrizione_figlio,
                             dep_dal_figlio;
                  END IF;
               END IF;

               -- Rev.001   23/05/2011  MMalferrari   A42787.0.0: fine mod.
               EXIT WHEN v_cur%NOTFOUND OR ret = 1;

               IF dep_progr_figlio = p_progr_unita
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

   /*****************************************************************************
     NOME:        verifica_messaggio
     DESCRIZIONE: Verifica se il messaggio ¿ collegato ad un documento di PROTOCOLLO, in caso affermativo
                            setta il documento a spedito o invia segnalazione d'erroe sulla scrivania
                            in base allo stato della spedizione


    RITORNO:  1 il messaggio ¿ del protocoollo, 0 altrimenti.

     Rev.  Data       Autore  Descrizione.
     00    04/08/2010 MMA  Prima emissione.
     01    11/04/2017 SC   Gestione date privilegi
    014    01/12/2017 SC   Adeguamento SmartDesktop
    016    20/11/2019 SC   Feature #38096 Avvisi pec
    ********************************************************************************/
   PROCEDURE verifica_messaggio (p_messaggio              NUMBER,
                                 p_new_data_spedizione    DATE,
                                 p_new_stato              VARCHAR2,
                                 p_errore                 VARCHAR2)
   IS
      dep_id_prot               documenti.id_documento%TYPE;
      dep_id_memo               documenti.id_documento%TYPE;
      dep_area_prot             VARCHAR2 (200);
      dep_cr_prot               VARCHAR2 (200);
      dep_cm_prot               VARCHAR2 (200);
      dep_url_exec              VARCHAR2 (4000);
      dep_url_memo              VARCHAR2 (4000);
      dep_ute_prot              ad4_utenti.utente%TYPE;
      dep_unita_protocollante   seg_unita.unita%TYPE;
      dep_descrizione_att       VARCHAR2 (32000);
      dep_old_stato             VARCHAR2 (4000);
      dep_suffix_blocco         VARCHAR2 (3) := '';
      dep_id_riferimento        VARCHAR2 (100)
         := TO_CHAR (SYSTIMESTAMP, 'yyyymmddhh24missff6');
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      BEGIN
         SELECT NVL (stato_spedizione, 'READYTOSEND')
           INTO dep_old_stato
           FROM ag_cs_messaggi
          WHERE     id_cs_messaggio = p_messaggio
                AND data_modifica <= p_new_data_spedizione;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN;
      END;

      BEGIN
         SELECT csme.id_documento_protocollo,
                prot.utente_protocollante,
                prot.unita_protocollante,
                csme.id_documento_memo,
                   'Errore in spedizione del '
                || mepr.data_spedizione_memo
                || ' - '
                || mepr.oggetto
           INTO dep_id_prot,
                dep_ute_prot,
                dep_unita_protocollante,
                dep_id_memo,
                dep_descrizione_att
           FROM ag_cs_messaggi csme,
                proto_view prot,
                seg_memo_protocollo mepr
          WHERE     csme.id_cs_messaggio = p_messaggio
                AND csme.id_documento_protocollo = prot.id_documento
                AND mepr.id_documento = csme.id_documento_memo;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN;
      END;

      BEGIN
         SELECT docu.area, docu.codice_richiesta, tipi_documento.nome
           INTO dep_area_prot, dep_cr_prot, dep_cm_prot
           FROM documenti docu, tipi_documento
          WHERE     docu.id_documento = dep_id_prot
                AND tipi_documento.id_tipodoc = docu.id_tipodoc
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN;
      END;

      DECLARE
         dep_data      DATE;
         dep_cod_amm   proto_view.codice_amministrazione%TYPE;
         dep_cod_aoo   proto_view.codice_aoo%TYPE;
      BEGIN
         SELECT DATA, codice_amministrazione, codice_aoo
           INTO dep_data, dep_cod_amm, dep_cod_aoo
           FROM proto_view
          WHERE id_documento = dep_id_prot;


         IF TRUNC (dep_data) <= get_data_blocco (dep_cod_amm, dep_cod_aoo)
         THEN
            dep_suffix_blocco := 'BLC';
         END IF;
      END;

      BEGIN
         UPDATE ag_cs_messaggi
            SET stato_spedizione = p_new_stato,
                data_modifica = p_new_data_spedizione
          WHERE     id_cs_messaggio = p_messaggio
                AND id_documento_protocollo = dep_id_prot
                AND (   data_modifica < p_new_data_spedizione
                     OR (    data_modifica = p_new_data_spedizione
                         AND NVL (p_new_stato, 'READYTOSEND') IN ('SENTOK',
                                                                  'SENTFAILED')));

         COMMIT;

         IF NVL (p_new_stato, 'READYTOSEND') = 'SENTOK'
         THEN
            UPDATE seg_memo_protocollo
               SET spedito = 'Y'
             WHERE id_documento = dep_id_memo;

            COMMIT;
         END IF;

         IF NVL (p_new_stato, 'READYTOSEND') = 'SENTFAILED'
         THEN
            BEGIN
               dep_url_exec :=
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     dep_id_prot,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'W',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N');
               dep_url_memo :=
                  gdc_utility_pkg.f_get_url_oggetto ('',
                                                     '',
                                                     dep_id_memo,
                                                     'D',
                                                     '',
                                                     '',
                                                     '',
                                                     'R',
                                                     '',
                                                     '',
                                                     '5',
                                                     'N');

               FOR u
                  IN (SELECT ad4_utenti_soggetti.utente
                        FROM ad4_utenti_soggetti,
                             so4_vpco componenti,
                             so4_vpun anagrafe_unita_organizzative
                       WHERE     componenti.ni = ad4_utenti_soggetti.soggetto
                             AND componenti.dal <= TRUNC (SYSDATE)
                             AND (   componenti.al IS NULL
                                  OR componenti.al >= TRUNC (SYSDATE))
                             AND anagrafe_unita_organizzative.progr_unita_organizzativa =
                                    componenti.progr_unita_organizzativa
                             AND TRUNC (SYSDATE) BETWEEN anagrafe_unita_organizzative.dal
                                                     AND NVL (
                                                            anagrafe_unita_organizzative.al,
                                                            TRUNC (SYSDATE))
                             AND anagrafe_unita_organizzative.codice_uo =
                                    dep_unita_protocollante
                      UNION
                      SELECT dep_ute_prot FROM DUAL)
               LOOP
                  IF     gdm_competenza.gdm_verifica ('DOCUMENTI',
                                                      dep_id_prot,
                                                      'U',
                                                      u.utente,
                                                      'GDM') = 1
                  -- Feature #38096 Avvisi pec
                  /* AND verifica_privilegio_utente (
                            NULL,
                            'MRAP' || dep_suffix_blocco,
                            u.utente,
                            TRUNC (SYSDATE)) = 1*/
                  THEN
                     DECLARE
                        dep_id_attivita   NUMBER;
                     BEGIN
                        dep_id_attivita :=
                           ag_utilities_cruscotto.crea_task_esterno_TODO (
                              P_ID_RIFERIMENTO           => dep_id_riferimento,
                              P_ATTIVITA_DESCRIZIONE     => dep_descrizione_att,
                              P_TOOLTIP_ATTIVITA_DESCR   => dep_descrizione_att,
                              P_URL_RIF                  => dep_url_memo,
                              P_URL_RIF_DESC             => 'Visualizza memo',
                              P_URL_EXEC                 => dep_url_exec,
                              P_TOOLTIP_URL_EXEC         => 'Visualizza attivita''',
                              P_DATA_SCAD                => NULL,
                              P_PARAM_INIT_ITER          => 'NOTIFICA_INVIO_FALLITO',
                              P_NOME_ITER                => 'NOTIFICA_INVIO_FALLITO',
                              P_DESCRIZIONE_ITER         => 'Notifica di fallimento invio mail',
                              P_COLORE                   => NULL,
                              P_ORDINAMENTO              => NULL,
                              P_UTENTE_ESTERNO           => u.utente,
                              P_CATEGORIA                => NULL,
                              P_DESKTOP                  => NULL,
                              P_STATO                    => NULL,
                              P_TIPOLOGIA                => 'NOTIFICA_PEC',
                              P_DATIAPPLICATIVI1         => NULL,
                              P_DATIAPPLICATIVI2         => NULL,
                              P_DATIAPPLICATIVI3         => SYSDATE,
                              P_TIPO_BOTTONE             => 'VERIFICA_MESSAGGIO',
                              P_DATA_ATTIVAZIONE         => SYSDATE,
                              P_DES_DETTAGLIO_1          => 'Motivo notifica',
                              P_DETTAGLIO_1              =>    dep_descrizione_att
                                                            || CHR (10)
                                                            || p_errore,
                              P_ID_DOCUMENTO             => dep_id_prot);
                        COMMIT;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           ROLLBACK;
                     END;
                  END IF;
               END LOOP;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            DECLARE
               d_ret   NUMBER;
            BEGIN
               d_ret :=
                  amvweb.send_msg (
                     ag_parametro.get_valore (
                        'WS_MAIL_SENDER_' || get_defaultaooindex,
                        '@agVar@'),
                     ag_parametro.get_valore (
                        'WS_MAIL_RECIPIENT_' || get_defaultaooindex,
                        '@agVar@'),
                     'Segnalazione su invio mail',
                        dep_descrizione_att
                     || CHR (10)
                     || '=============================='
                     || CHR (10)
                     || p_errore
                     || CHR (10)
                     || '=============================='
                     || CHR (10)
                     || 'E'' possibile individuare il messaggio in si4cs.messaggi con identificativo '
                     || p_messaggio
                     || '.',
                     ag_parametro.get_valore (
                        'WS_MAIL_TAG_' || get_defaultaooindex,
                        '@agVar@'));
               COMMIT;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ROLLBACK;
            END;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END verifica_messaggio;

   PROCEDURE notifica_pec (p_id_prot    NUMBER,
                           p_id_memo    NUMBER,
                           p_errore     VARCHAR2,
                           p_note       VARCHAR2)
   /*****************************************************************************
       NOME:        notifica_pec.
       DESCRIZIONE: Crea un'attività sulla scrivania dell'utente protocollante e
                    degli utenti appartenenti all'unità protocollante in caso di
                    non accettazione o mancata consegna.
                    Se presenti i parametri NOTIFICA_PEC_SENDER, NOTIFICA_PEC_TAG
                    e NOTIFICA_PEC_RECIPIENT, manda anche una mail.

      Rev.  Data        Autore      Descrizione.
      012   17/08/2016  MMalferrari Utilizzo parametri NOTIFICA_PEC_% invece di
                                    WS_MAIL_% per l'invio mail.
      013   11/04/2017  SC          Gestione date privilegi
      014   01/12/2017  SC          Adeguamento SmartDesktop
      016       20/11/2018    SC             Feature #38096 Avvisi pec in caso
                                             di problemi nell'invio pec: a chi
                                             inviare le notifiche
   ********************************************************************************/
   IS
      dep_area_prot             VARCHAR2 (200);
      dep_cr_prot               VARCHAR2 (200);
      dep_cm_prot               VARCHAR2 (200);
      dep_url_prot              VARCHAR2 (4000);
      dep_url_memo              VARCHAR2 (4000);
      dep_ute_prot              ad4_utenti.utente%TYPE;
      dep_unita_protocollante   seg_unita.unita%TYPE;
      dep_descrizione_att       VARCHAR2 (32000);
      dep_suffix_blocco         VARCHAR2 (3) := '';
      dep_id_riferimento        VARCHAR2 (100)
         := TO_CHAR (SYSTIMESTAMP, 'yyyymmddhh24missff6');
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      BEGIN
         SELECT docu.area,
                docu.codice_richiesta,
                tipi_documento.nome,
                prot.utente_protocollante,
                prot.unita_protocollante,
                mepr.oggetto
           INTO dep_area_prot,
                dep_cr_prot,
                dep_cm_prot,
                dep_ute_prot,
                dep_unita_protocollante,
                dep_descrizione_att
           FROM proto_view prot,
                documenti docu,
                tipi_documento,
                seg_memo_protocollo mepr
          WHERE     p_id_prot = prot.id_documento
                AND docu.id_documento = prot.id_documento
                AND tipi_documento.id_tipodoc = docu.id_tipodoc
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND mepr.id_documento = p_id_memo;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN;
      END;

      DECLARE
         dep_data      DATE;
         dep_cod_amm   proto_view.codice_amministrazione%TYPE;
         dep_cod_aoo   proto_view.codice_aoo%TYPE;
      BEGIN
         SELECT DATA, codice_amministrazione, codice_aoo
           INTO dep_data, dep_cod_amm, dep_cod_aoo
           FROM proto_view
          WHERE id_documento = p_id_prot;

         IF TRUNC (dep_data) <= get_data_blocco (dep_cod_amm, dep_cod_aoo)
         THEN
            dep_suffix_blocco := 'BLC';
         END IF;
      END;

      BEGIN
         BEGIN
            dep_url_prot :=
               gdc_utility_pkg.f_get_url_oggetto ('',
                                                  '',
                                                  p_id_prot,
                                                  'D',
                                                  '',
                                                  '',
                                                  '',
                                                  'W',
                                                  '',
                                                  '',
                                                  '5',
                                                  'N');
            dep_url_memo :=
               gdc_utility_pkg.f_get_url_oggetto ('',
                                                  '',
                                                  p_id_memo,
                                                  'D',
                                                  '',
                                                  '',
                                                  '',
                                                  'R',
                                                  '',
                                                  '',
                                                  '5',
                                                  'N');

            FOR u
               IN (SELECT ad4_utenti_soggetti.utente
                     FROM ad4_utenti_soggetti,
                          so4_vpco componenti,
                          so4_vpun anagrafe_unita_organizzative
                    WHERE     componenti.ni = ad4_utenti_soggetti.soggetto
                          AND componenti.dal <= TRUNC (SYSDATE)
                          AND (   componenti.al IS NULL
                               OR componenti.al >= TRUNC (SYSDATE))
                          AND anagrafe_unita_organizzative.progr_unita_organizzativa =
                                 componenti.progr_unita_organizzativa
                          AND TRUNC (SYSDATE) BETWEEN anagrafe_unita_organizzative.dal
                                                  AND NVL (
                                                         anagrafe_unita_organizzative.al,
                                                         TRUNC (SYSDATE))
                          AND anagrafe_unita_organizzative.codice_uo =
                                 dep_unita_protocollante
                   UNION
                   SELECT dep_ute_prot FROM DUAL)
            LOOP
               IF     gdm_competenza.gdm_verifica ('DOCUMENTI',
                                                   p_id_prot,
                                                   'U',
                                                   u.utente,
                                                   'GDM') = 1
                  /*AND verifica_privilegio_utente (
                         NULL,
                         'MRAP' || dep_suffix_blocco,
                         u.utente,
                         TRUNC (SYSDATE)) = 1*/
               THEN
                  DECLARE
                     dep_id_attivita   NUMBER;
                  BEGIN
                     --                     dep_id_attivita :=
                     --                        jwf_utility.f_crea_task_esterno (
                     --                           p_id_riferimento           => dep_id_riferimento,
                     --                           p_attivita_descrizione     => dep_descrizione_att,
                     --                           p_tooltip_attivita_descr   => dep_descrizione_att,
                     --                           p_url_rif                  => dep_url_memo,
                     --                           p_url_rif_desc             => 'Visualizza memo',
                     --                           p_url_exec                 => dep_url_prot,
                     --                           p_tooltip_url_exec         => 'Visualizza attivita''',
                     --                           p_scadenza                 => NULL,
                     --                           p_param_init_iter          => 'NOTIFICA_PEC',
                     --                           p_nome_iter                => 'NOTIFICA_PEC',
                     --                           p_descrizione_iter         => p_errore,
                     --                           p_colore                   => NULL,
                     --                           p_ordinamento              => NULL,
                     --                           p_data_attivazione         => SYSDATE,
                     --                           p_utente_esterno           => u.utente,
                     --                           p_categoria                => NULL,
                     --                           p_desktop                  => NULL,
                     --                           p_stato                    => NULL,
                     --                           p_tipologia                => 'NOTIFICA_PEC',
                     --                           p_espressione              => 'TODO',
                     --                           p_messaggio_todo           =>    dep_descrizione_att
                     --                                                         || ' '
                     --                                                         || p_note,
                     --                           p_dati_applicativi_2       => NULL,
                     --                           p_dati_applicativi_3       => SYSDATE,
                     --                           p_note                     => p_note);

                     dep_id_attivita :=
                        ag_utilities_cruscotto.crea_task_esterno_TODO (
                           P_ID_RIFERIMENTO           => dep_id_riferimento,
                           P_ATTIVITA_DESCRIZIONE     => dep_descrizione_att,
                           P_TOOLTIP_ATTIVITA_DESCR   => dep_descrizione_att,
                           P_URL_RIF                  => dep_url_memo,
                           P_URL_RIF_DESC             => 'Visualizza memo',
                           P_URL_EXEC                 => dep_url_prot,
                           P_TOOLTIP_URL_EXEC         => 'Visualizza attivita''',
                           P_DATA_SCAD                => NULL,
                           P_PARAM_INIT_ITER          => 'NOTIFICA_PEC',
                           P_NOME_ITER                => 'NOTIFICA_PEC',
                           P_DESCRIZIONE_ITER         => p_errore,
                           P_COLORE                   => NULL,
                           P_ORDINAMENTO              => NULL,
                           P_UTENTE_ESTERNO           => u.utente,
                           P_CATEGORIA                => NULL,
                           P_DESKTOP                  => NULL,
                           P_STATO                    => NULL,
                           P_TIPOLOGIA                => 'NOTIFICA_PEC',
                           P_DATIAPPLICATIVI1         => NULL,
                           P_DATIAPPLICATIVI2         => NULL,
                           P_DATIAPPLICATIVI3         => SYSDATE,
                           P_TIPO_BOTTONE             => 'NOTIFICA_PEC',
                           P_DATA_ATTIVAZIONE         => SYSDATE,
                           P_DES_DETTAGLIO_1          => 'Motivo notifica',
                           P_DETTAGLIO_1              =>    dep_descrizione_att
                                                         || ' '
                                                         || p_note,
                           P_ID_DOCUMENTO             => p_id_prot);
                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         DECLARE
            d_ret         NUMBER;
            d_sender      VARCHAR2 (100);
            d_tag         VARCHAR2 (100);
            d_recipient   VARCHAR2 (100);
         BEGIN
            d_sender :=
               ag_parametro.get_valore (
                  'NOTIFICA_PEC_SENDER_' || get_defaultaooindex,
                  '@agVar@');
            d_recipient :=
               ag_parametro.get_valore (
                  'NOTIFICA_PEC_RECIPIENT_' || get_defaultaooindex,
                  '@agVar@');
            d_tag :=
               ag_parametro.get_valore (
                  'NOTIFICA_PEC_TAG_' || get_defaultaooindex,
                  '@agVar@');

            IF     TRIM (d_sender) IS NOT NULL
               AND TRIM (d_recipient) IS NOT NULL
               AND TRIM (d_tag) IS NOT NULL
            THEN
               BEGIN
                  d_ret :=
                     amvweb.send_msg (
                        d_sender,
                        d_recipient,
                        'Segnalazione su invio mail',
                           dep_descrizione_att
                        || CHR (10)
                        || '=============================='
                        || CHR (10)
                        || p_errore
                        || '.',
                        d_tag);
                  COMMIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ROLLBACK;
               END;
            END IF;
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END notifica_pec;

   /*****************************************************************************
          NOME:        get_caselle_utente
          DESCRIZIONE: Restituisce un cursore con le caselle di posta elettronica/fax
                       che l'utente può gestire



          Rev. Data        Autore      Descrizione.
         000                            Prima emissione.
         001  30/03/2017   SC           Gestione progressivo unità
                                        e date privilegi
      ********************************************************************************/
   FUNCTION get_caselle_utente (p_codice_amm   IN VARCHAR2,
                                p_codice_aoo   IN VARCHAR2,
                                p_utente       IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT casella, email
           FROM (SELECT 1 ordinamento,
                           aoo.denominazione
                        || ' ('
                        || indirizzo_istituzionale
                        || ')'
                           casella,
                        indirizzo_istituzionale email
                   FROM so4_aoo_view aoo
                  WHERE     verifica_privilegio_utente (
                               NULL,
                               privilegio_casella_ist,
                               p_utente,
                               TRUNC (SYSDATE)) = 1
                        AND codice_amministrazione = p_codice_amm
                        AND codice_aoo = p_codice_aoo
                        AND al IS NULL
                 UNION
                 SELECT 2 ordinamento,
                        s.nome || ' (' || indirizzo_mail_ist || ')' casella,
                        indirizzo_mail_ist email
                   FROM seg_unita s, ag_priv_utente_tmp p
                  WHERE     p.utente = p_utente
                        AND s.progr_unita_organizzativa = p.progr_unita
                        AND s.codice_amministrazione = p_codice_amm
                        AND p.privilegio = privilegio_casella_unita
                        AND s.al IS NULL
                        AND TRUNC (SYSDATE) <= /*BETWEEN p.dal
                                                AND*/
                               NVL (p.al, TO_DATE (3333333, 'j'))
                        AND indirizzo_mail_ist IS NOT NULL
                 UNION
                 SELECT 3, '(Tutte)', '%'
                   FROM DUAL
                  WHERE verifica_privilegio_utente (NULL,
                                                    privilegio_tutte_caselle,
                                                    p_utente,
                                                    TRUNC (SYSDATE)) = 1
                 ORDER BY 1, 2);

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   /*******************************************************************************
     NOME:        VERIFICA_PRIVILEGIO_CASELLA
     DESCRIZIONE: Verifica se l'utente ha diritti su almeno uno dei destinatari
                  presenti in p_destinatari.

    INPUT  p_utente        varchar2: utente che di cui verificare il privilegio.
           p_destinatari   varchar2  stringa con i destinatari.
           p_data          date      data di riferimento per il calcolo del privilegio.
    RITORNO:  1 se l'utente ha il privilegio, 0 altrimenti.

    Rev.    Data       Autore    Descrizione.
    000     13/05/2011 MM        Prima emissione. A24015.0.0.
    004     30/09/2013 MM        Utilizzo vista seg_uo_mail al posto di seg_unita
                                 (per velocizzare).
    006     17/11/2014 MM        Aggiunto parametro p_data alla funzione
    007     30/30/2017 SC        p_data <= al anziche between dal and al.
   ********************************************************************************/
   FUNCTION verifica_privilegio_casella (p_destinatari    CLOB,
                                         p_utente         VARCHAR2,
                                         p_data           DATE)
      RETURN NUMBER
   IS
      retval          NUMBER := 0;
      d_cod_amm       VARCHAR2 (100);
      d_cod_aoo       VARCHAR2 (100);
      d_destinatari   CLOB := LOWER (p_destinatari);
   BEGIN
      IF p_utente = utente_superuser_segreteria
      THEN
         RETURN 1;
      END IF;

      d_cod_amm :=
         ag_parametro.get_valore (
            'CODICE_AMM_' || get_indice_aoo (NULL, NULL),
            '@agVar@');
      d_cod_aoo :=
         ag_parametro.get_valore (
            'CODICE_AOO_' || get_indice_aoo (NULL, NULL),
            '@agVar@');

      IF LENGTH (TRIM (TRIM (BOTH ',' FROM d_destinatari))) = 0
      THEN
         d_destinatari := '';
      END IF;

      BEGIN
         SELECT 1
           INTO retval
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM DUAL
                     WHERE verifica_privilegio_utente (
                              NULL,
                              privilegio_tutte_caselle,
                              p_utente,
                              p_data) = 1
                    UNION
                    SELECT 1
                      FROM so4_aoo_view aoo
                     WHERE     verifica_privilegio_utente (
                                  NULL,
                                  privilegio_casella_ist,
                                  p_utente,
                                  p_data) = 1
                           AND INSTR (
                                  NVL (d_destinatari,
                                       LOWER (indirizzo_istituzionale)),
                                  LOWER (indirizzo_istituzionale)) > 0
                           AND codice_amministrazione = d_cod_amm
                           AND codice_aoo = d_cod_aoo
                           AND aoo.al IS NULL
                    UNION
                    SELECT 1
                      FROM so4_aoo_view aoo
                     WHERE     verifica_privilegio_utente (
                                  NULL,
                                  privilegio_casella_ist,
                                  p_utente,
                                  p_data) = 1
                           AND INSTR (
                                  NVL (d_destinatari,
                                       LOWER (mailfax_istituzionale)),
                                  LOWER (mailfax_istituzionale)) > 0
                           AND codice_amministrazione = d_cod_amm
                           AND codice_aoo = d_cod_aoo
                           AND aoo.al IS NULL
                    UNION
                    SELECT 1
                      FROM ag_priv_utente_tmp prut, seg_uo_mail unit
                     WHERE     prut.utente = p_utente
                           AND prut.privilegio = privilegio_casella_unita
                           AND prut.unita = unit.cod_uo
                           AND INSTR (d_destinatari, LOWER (unit.email)) > 0
                           AND NVL (p_data, TRUNC (SYSDATE)) <= /*BETWEEN prut.dal
                                                           AND*/
                                  NVL (prut.al, TO_DATE ('3333333', 'j'))
                    UNION
                    SELECT 1
                      FROM ag_priv_utente_tmp prut, seg_uo_mail unit
                     WHERE     prut.utente = p_utente
                           AND prut.privilegio = privilegio_casella_unita
                           AND prut.unita = unit.cod_uo
                           AND INSTR (d_destinatari, LOWER (unit.mailfax)) >
                                  0
                           AND NVL (p_data, TRUNC (SYSDATE)) <= /*BETWEEN prut.dal
                                                           AND*/
                                  NVL (prut.al, TO_DATE ('3333333', 'j')));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      RETURN retval;
   END verifica_privilegio_casella;

   FUNCTION refresh_mv (p_nome_mv VARCHAR2)
      RETURN NUMBER
   AS
      ret   NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      BEGIN
         ret := 1;
         DBMS_SNAPSHOT.REFRESH (p_nome_mv);
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            RAISE;
      --   ret := 0;
      END;

      RETURN ret;
   END refresh_mv;

   FUNCTION duplica_documento (p_documento              NUMBER,
                               p_utente                 VARCHAR2,
                               p_gestisci_competenze    NUMBER DEFAULT 1,
                               p_se_vuoto               NUMBER DEFAULT 0)
      RETURN NUMBER
   AS
      n_iddoc   documenti.id_documento%TYPE;
   BEGIN
      BEGIN
         SELECT docu_sq.NEXTVAL INTO n_iddoc FROM DUAL;

         /* INSERISCO LA NUOVA RICHIESTA */
         INSERT INTO richieste (codice_richiesta,
                                area,
                                id_tipo_pratica,
                                data_scadenza,
                                data_inserimento)
            SELECT 'PLSQL-' || n_iddoc || '-DUPLICA-' || p_documento,
                   area,
                   NULL,
                   NULL,
                   SYSDATE
              FROM documenti
             WHERE id_documento = p_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20990',
               'Impossibile duplicare il documento ' || SQLERRM);
      END;

      BEGIN
         /* INSERISCO IL NUOVO DOCUMENTO */
         INSERT INTO documenti (id_documento,
                                id_libreria,
                                id_tipodoc,
                                codice_richiesta,
                                area,
                                data_aggiornamento,
                                utente_aggiornamento)
            SELECT n_iddoc,
                   id_libreria,
                   id_tipodoc,
                   'PLSQL-' || n_iddoc || '-DUPLICA-' || p_documento,
                   area,
                   SYSDATE,
                   p_utente
              FROM documenti
             WHERE id_documento = p_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20991',
               'Impossibile duplicare il documento ' || SQLERRM);
      END;

      BEGIN
         /* SETTO L'ACTIVITY_LOG  */
         INSERT INTO activity_log (id_log,
                                   id_documento,
                                   tipo_azione,
                                   data_aggiornamento,
                                   utente_aggiornamento)
            SELECT aclo_sq.NEXTVAL,
                   n_iddoc,
                   'C',
                   SYSDATE,
                   p_utente
              FROM activity_log
             WHERE id_documento = p_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20992',
               'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
      END;

      DECLARE
         d_table_name   VARCHAR2 (100);
      BEGIN
         BEGIN
            SELECT    UPPER (NVL (aree.acronimo, 'X'))
                   || '_'
                   || UPPER (NVL (alias_modello, 'X'))
              INTO d_table_name
              FROM user_objects,
                   tipi_documento td,
                   documenti,
                   aree
             WHERE     object_type = 'TABLE'
                   AND object_name =
                             UPPER (NVL (aree.acronimo, 'X'))
                          || '_'
                          || UPPER (NVL (alias_modello, 'X'))
                   AND id_documento = p_documento
                   AND td.id_tipodoc = documenti.id_tipodoc
                   AND aree.area = td.area_modello;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_table_name := '';
         END;

         IF d_table_name IS NULL
         THEN
            /* Copio i VALORI */
            INSERT INTO valori (id_valore,
                                id_documento,
                                id_campo,
                                valore_numero,
                                valore_data,
                                valore_clob,
                                data_aggiornamento,
                                utente_aggiornamento)
               SELECT valo_sq.NEXTVAL,
                      n_iddoc,
                      id_campo,
                      DECODE (p_se_vuoto, 0, valore_numero, NULL),
                      DECODE (p_se_vuoto, 0, valore_data, NULL),
                      DECODE (p_se_vuoto, 0, valore_clob, NULL),
                      SYSDATE,
                      p_utente
                 FROM valori
                WHERE id_documento = p_documento;
         ELSE
            DECLARE
               d_columns   VARCHAR2 (32767);
               d_values    VARCHAR2 (32767);
               d_insert    VARCHAR2 (32767);
            BEGIN
               FOR c IN (  SELECT column_name
                             FROM user_tab_columns
                            WHERE table_name = d_table_name
                         ORDER BY column_id)
               LOOP
                  d_columns := c.column_name || ', ' || d_columns;

                  IF c.column_name = 'ID_DOCUMENTO'
                  THEN
                     d_values := n_iddoc || ', ' || d_values;
                  ELSE
                     IF p_se_vuoto = 1
                     THEN
                        d_values := 'null, ' || d_values;
                     ELSE
                        d_values := c.column_name || ', ' || d_values;
                     END IF;
                  END IF;
               END LOOP;

               d_columns := SUBSTR (d_columns, 1, LENGTH (d_columns) - 2);
               d_values := SUBSTR (d_values, 1, LENGTH (d_values) - 2);
               d_insert :=
                     'insert into '
                  || d_table_name
                  || '('
                  || d_columns
                  || ')'
                  || 'select '
                  || d_values
                  || '  from '
                  || d_table_name
                  || ' where id_documento = '
                  || p_documento;

               EXECUTE IMMEDIATE d_insert;
            END;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20993',
               'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
      END;

      BEGIN
         /* Copio gli OGGETTI_FILE */
         INSERT INTO oggetti_file (id_oggetto_file,
                                   id_documento,
                                   id_oggetto_file_padre,
                                   id_formato,
                                   filename,
                                   "FILE",
                                   testoocr,
                                   allegato,
                                   data_aggiornamento,
                                   utente_aggiornamento)
            SELECT ogg_file_sq.NEXTVAL,
                   n_iddoc,
                   id_oggetto_file_padre,
                   id_formato,
                   filename,
                   "FILE",
                   testoocr,
                   allegato,
                   SYSDATE,
                   p_utente
              FROM oggetti_file
             WHERE id_documento = p_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20994',
               'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
      END;

      BEGIN
         /* Setto lo sato a Bozza in STATI_DOCUMENTO  */
         INSERT INTO stati_documento (id_documento,
                                      stato,
                                      commento,
                                      data_aggiornamento,
                                      utente_aggiornamento)
              VALUES (n_iddoc,
                      'BO',
                      'DUPLICATO',
                      SYSDATE,
                      p_utente);
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20995',
               'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
      END;

      BEGIN
         /* Inserisco i  RIFERIMENTI */
         FOR rife IN (SELECT id_documento_rif,
                             area,
                             libreria_remota,
                             tipo_relazione
                        FROM riferimenti
                       WHERE id_documento = p_documento)
         LOOP
            INSERT INTO riferimenti (id_documento,
                                     id_documento_rif,
                                     area,
                                     libreria_remota,
                                     tipo_relazione,
                                     data_aggiornamento,
                                     utente_aggiornamento)
                 VALUES (n_iddoc,
                         rife.id_documento_rif,
                         rife.area,
                         rife.libreria_remota,
                         rife.tipo_relazione,
                         SYSDATE,
                         p_utente);
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20996',
               'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
      END;

      IF p_gestisci_competenze = 1
      THEN
         BEGIN
            /* Assegno le COMPETENZE  */
            INSERT INTO si4_competenze (id_competenza,
                                        id_abilitazione,
                                        utente,
                                        oggetto,
                                        accesso,
                                        ruolo,
                                        dal,
                                        al,
                                        data_aggiornamento,
                                        utente_aggiornamento)
               SELECT comp_sq.NEXTVAL,
                      id_abilitazione,
                      utente,
                      n_iddoc,
                      'S',
                      ruolo,
                      dal,
                      al,
                      SYSDATE,
                      p_utente
                 FROM si4_competenze
                WHERE     oggetto = p_documento
                      AND EXISTS
                             (SELECT id_abilitazione
                                FROM si4_abilitazioni a, si4_tipi_oggetto o
                               WHERE     a.id_tipo_oggetto =
                                            o.id_tipo_oggetto
                                     AND tipo_oggetto = 'DOCUMENTI'
                                     AND id_abilitazione =
                                            si4_competenze.id_abilitazione)
                      AND accesso = 'S'
                      AND SYSDATE BETWEEN dal AND al;

            IF gdm_competenza.si4_verifica ('DOCUMENTI',
                                            n_iddoc,
                                            'U',
                                            p_utente,
                                            'GDM',
                                            TO_CHAR (SYSDATE, 'dd/mm/yyyy')) =
                  0
            THEN
               gdm_competenza.si4_assegna ('DOCUMENTI',
                                           n_iddoc,
                                           'LU',
                                           p_utente,
                                           'GDM',
                                           p_utente,
                                           'S',
                                           TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
                                           NULL);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               raise_application_error (
                  '-20997',
                  'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
         END;
      END IF;

      BEGIN
         /* drop dei LINKS */
         INSERT INTO links (id_link,
                            id_cartella,
                            id_oggetto,
                            tipo_oggetto,
                            data_aggiornamento,
                            utente_aggiornamento)
            SELECT link_sq.NEXTVAL,
                   id_cartella,
                   n_iddoc,
                   tipo_oggetto,
                   SYSDATE,
                   p_utente
              FROM links
             WHERE id_oggetto = p_documento AND tipo_oggetto = 'D';
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20998',
               'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
      END;

      BEGIN
         COMMIT;
         RETURN n_iddoc;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               '-20999',
               'IMPOSSIBILE DUPLICARE IL DOCUMENTO ' || SQLERRM);
      END;
   END;

   FUNCTION get_tabella (p_id_documento NUMBER)
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
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_tabella := '';
      END;

      RETURN d_tabella;
   END;

   FUNCTION concat_instr (str_1 CLOB, str_2 CLOB, str_cercata VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER;
      d_cerca    CLOB := ',';
   BEGIN
      IF (str_1 IS NULL AND str_2 IS NULL)
      THEN
         d_return := 0;
      ELSE
         IF str_1 IS NOT NULL
         THEN
            d_cerca := d_cerca || REPLACE (str_1, ' ', '') || ',';
         END IF;

         IF str_2 IS NOT NULL
         THEN
            d_cerca := d_cerca || REPLACE (str_2, ' ', '') || ',';
         END IF;

         d_return := INSTR (d_cerca, ',' || str_cercata || ',');
      END IF;

      RETURN d_return;
   END;

   /******************************************************************************
    NOME:        is_smistamento
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_documento ¿ uno smistamento.
    RITORNA:     number 1 se ¿ uno smistamento, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_smistamento (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM seg_smistamenti
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END is_smistamento;

   /******************************************************************************
    NOME:        is_fascicolo
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_documento ¿ un fascicolo.
    RITORNA:     number 1 se ¿ un fascicolo, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_fascicolo (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM seg_fascicoli
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END is_fascicolo;

   /******************************************************************************
    NOME:        is_lettera
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_documento ¿ una lettera.
    RITORNA:     number 1 se ¿ una lettera, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_lettera (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM spr_lettere_uscita
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END is_lettera;

   FUNCTION is_soggetto_protocollo (p_id_tipodoc NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM tipi_documento
          WHERE id_tipodoc = p_id_tipodoc AND nome = 'M_SOGGETTO';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   /******************************************************************************
    NOME:        is_lettera
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_documento
                 è una lettera.
    RITORNA:     number 1 se è una lettera, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_lettera_nuova (p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM spr_lettere_uscita
          WHERE idrif = p_idrif AND key_iter_lettera = -1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   /******************************************************************************
    NOME:        is_lettera_grails
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_documento
                 è una lettera.
    RITORNA:     number 1 se è una lettera, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_lettera_grails (p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM spr_lettere_uscita
          WHERE idrif = p_idrif AND key_iter_lettera = -1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   /******************************************************************************
    NOME:        is_lettera_grails
    INPUT:       p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_documento
                 è una lettera.
    RITORNA:     number 1 se è una lettera, 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_lettera_grails (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM spr_lettere_uscita
          WHERE id_documento = p_id_documento AND key_iter_lettera = -1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   /******************************************************************************
    NOME:         is_prot_interop
    INPUT:        p_id_documento id del documento di cui verificare il tipo di documento
    DESCRIZIONE:  A27756.5.0 Verifica se il documento identificato da p_id_documento
                  ¿ un documento di interoperabilita'.
    RITORNA:      number 1 se ¿ un documento di interoperabilita', 0 altrimenti.
    NOTE:
   ******************************************************************************/
   FUNCTION is_prot_interop (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM spr_protocolli_intero
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END is_prot_interop;

   FUNCTION get_utenti_notifica_ripudio (p_area                VARCHAR2,
                                         p_codice_modello      VARCHAR2,
                                         p_codice_richiesta    VARCHAR2,
                                         p_codice_unita        VARCHAR2,
                                         p_azione              VARCHAR2,
                                         id_smistamenti        VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_id_documento   NUMBER;
   BEGIN
      dep_id_documento :=
         get_id_documento (p_area, p_codice_modello, p_codice_richiesta);

      IF verifica_categoria_documento (dep_id_documento, 'PROTO') = 1
      THEN
         RETURN ag_competenze_protocollo.get_utenti_notifica_ripudio (
                   p_area,
                   p_codice_modello,
                   p_codice_richiesta,
                   p_codice_unita,
                   p_azione,
                   id_smistamenti);
      ELSE
         RETURN ag_competenze_documento.get_utenti_notifica_ripudio (
                   p_area,
                   p_codice_modello,
                   p_codice_richiesta,
                   p_codice_unita,
                   p_azione,
                   id_smistamenti);
      END IF;
   END;

   FUNCTION get_new_idrif
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (100);
   BEGIN
      SELECT TO_CHAR (seq_idrif.NEXTVAL) INTO d_return FROM DUAL;

      RETURN d_return;
   END;

   FUNCTION get_url_oggetto (p_server_url            IN VARCHAR2,
                             p_context_path          IN VARCHAR2,
                             p_id_oggetto            IN VARCHAR2,
                             p_tipo_oggetto          IN VARCHAR2,
                             p_area                  IN VARCHAR2,
                             p_cm                    IN VARCHAR2,
                             p_cr                    IN VARCHAR2,
                             p_rw                    IN VARCHAR2,
                             p_id_cartprovenienza    IN VARCHAR2,
                             p_id_queryprovenienza   IN VARCHAR2,
                             p_tag                   IN VARCHAR2 DEFAULT '1',
                             p_javascript            IN VARCHAR2 DEFAULT 'S',
                             p_gdc_link              IN VARCHAR2 DEFAULT 'S',
                             p_per_worklist          IN VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
   IS
      d_return         VARCHAR2 (4000);
      d_context_path   VARCHAR2 (1000) := NVL (p_context_path, 'jdms');
   BEGIN
      IF d_context_path = 'jdms'
      THEN
         d_context_path := d_context_path || '/common/';
      END IF;

      BEGIN
         EXECUTE IMMEDIATE
               'select GDC_UTILITY_PKG.F_GET_URL_OGGETTO ( '''
            || P_SERVER_URL
            || ''', '''
            || d_CONTEXT_PATH
            || ''', '''
            || P_ID_OGGETTO
            || ''', '''
            || P_TIPO_OGGETTO
            || ''', '''
            || P_AREA
            || ''', '''
            || P_CM
            || ''', '''
            || P_CR
            || ''', '''
            || P_RW
            || ''', '''
            || P_ID_CARTPROVENIENZA
            || ''', '''
            || P_ID_QUERYPROVENIENZA
            || ''', '''
            || P_TAG
            || ''', '''
            || P_JAVASCRIPT
            || ''', '''
            || P_GDC_LINK
            || ''' ) from dual'
            INTO d_return;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_return :=
               gdc_utility_pkg.f_get_url_oggetto (p_server_url,
                                                  d_context_path,
                                                  p_id_oggetto,
                                                  p_tipo_oggetto,
                                                  p_area,
                                                  p_cm,
                                                  p_cr,
                                                  p_rw,
                                                  p_id_cartprovenienza,
                                                  p_id_queryprovenienza,
                                                  p_tag,
                                                  p_javascript);

            IF NVL (p_gdc_link, 'S') = 'N'
            THEN
               d_return :=
                  REPLACE (
                     d_return,
                     '&GDC_Link=..%2Fcommon%2FClosePageAndRefresh.do',
                     '&GDC_Link_NO=..%2Fcommon%2FClosePageAndRefresh.do');
               d_return :=
                  REPLACE (d_return,
                           '&GDC_Link=../common/ClosePageAndRefresh.do',
                           '&GDC_Link_NO=../common/ClosePageAndRefresh.do');
            END IF;

            IF NVL (p_per_worklist, 'N') <> 'N'
            THEN
               d_return := REPLACE (d_return, '../../', '../');
            END IF;
      END;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION is_memo (p_id_tipodoc NUMBER)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        is_memo
       INPUT:       p_id_tipodoc id_tipodoc del documento da verificare
       DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_tipodoc
                    e' un memo.
       RITORNA:     number 1 se e' un memo, 0 altrimenti.
       NOTE:
      ******************************************************************************/
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM tipi_documento
          WHERE id_tipodoc = p_id_tipodoc AND nome = 'MEMO_PROTOCOLLO';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   FUNCTION is_doc_da_fasc (p_id_tipodoc NUMBER)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        IS_DOC_DA_FASC
       INPUT:       p_id_tipodoc id del documento di cui verificare il tipo di documento
       DESCRIZIONE: Verifica se il documento identificato da p_id_tipodoc
                    e' un documento da fascicolare.
       RITORNA:     number 1 se ¿ un documento da fascicolare, 0 altrimenti.
       NOTE:
      ******************************************************************************/
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM tipi_documento
          WHERE id_tipodoc = p_id_tipodoc AND nome = 'DOC_DA_FASCICOLARE';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   FUNCTION is_prot_doc_esterni (p_id_documento NUMBER)
      RETURN NUMBER
   IS
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM spr_protocolli_docesterni
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   FUNCTION is_protocollo (p_id_tipodoc NUMBER)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        is_protocollo
       INPUT:       p_id_tipodoc id_tipodoc del documento da verificare
       DESCRIZIONE: A27756.5.0 Verifica se il documento identificato da p_id_tipodoc
                    e' un protocollo.
       RITORNA:     number 1 se e' un protocollo, 0 altrimenti.
       NOTE:
      ******************************************************************************/
      ret   NUMBER := 0;
   BEGIN
      BEGIN
         SELECT 1
           INTO ret
           FROM tipi_documento td, categorie_modello cm
          WHERE     id_tipodoc = p_id_tipodoc
                AND cm.categoria = 'PROTO'
                AND td.nome = CM.CODICE_MODELLO
                AND td.area_modello = CM.AREA;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ret := 0;
      END;

      RETURN ret;
   END;

   /*****************************************************************************
          NOME:        get_Data_rif_privilegi
          DESCRIZIONE: Restituisce la data di riferimento
                       da utilizzare per verificare i diritti sul documento.
                       se storicoruoli = Y restituisce la data di creazione/protocollo
                       del documento o del fascicolo
                       se storicoruoli = N restituisce la data odierna



          Rev. Data        Autore      Descrizione.
         000   11/04/2017  SC          Prima emissione.
      ********************************************************************************/
   FUNCTION get_Data_rif_privilegi (p_id_documento NUMBER)
      RETURN DATE
   IS
      dep_data    DATE;
      dep_campo   VARCHAR2 (100) := 'DATA';
   BEGIN
      IF storicoruoli = 'Y'
      THEN
         IF verifica_categoria_documento (p_id_documento,
                                          'POSTA_ELETTRONICA') = 1
         THEN
            dep_campo := 'DATA_RICEZIONE';
         END IF;

         IF is_fascicolo (p_id_documento) = 1
         THEN
            dep_campo := 'DATA_CREAZIONE';
         END IF;

         RETURN TRUNC (
                   NVL (
                      TO_DATE (f_valore_campo (p_id_documento, dep_campo),
                               'dd/mm/yyyy hh24:mi:ss'),
                      SYSDATE));
      ELSE
         RETURN TRUNC (SYSDATE);
      END IF;
   END get_Data_rif_privilegi;

   FUNCTION get_id_documento_from_idrif (p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_documento   NUMBER;
   BEGIN
      dep_id_documento :=
         NVL (
            NVL (get_protocollo_per_idrif (p_idrif),
                 get_fascicolo_per_idrif (p_idrif)),
            get_documento_per_idrif (p_idrif));
      RETURN dep_id_documento;
   END;

   /*****************************************************************************
        NOME:        GET_UNITA_RADICE_AREA.
        DESCRIZIONE: Dato il codice di un'unita, data di riferimento e ottica,
         cerca tra le unita ascendenti quella che rappresenta la radice dell'area
         di p_codice_unita.

         Per radice di area, se ag_suddivisioni non contiene righe si considera
         l'unit¿ che non ha padre.
         Se ag_suddivisioni contiene righe, l'unit¿ di area ¿ la prima
         ascendente di p_codice_unita (lei compresa) la cui suddivisione
         ¿ presente in ag_suddivisioni.

        INPUT  p_codice_unita varchar2 CODICE UNITA DI CUI CERCARE LA RADICE .
        p_data_riferimento data di validita delle unita.
        p_ottica OTTICA DI SO4 DA UTILIZZARE.
       RITORNO:  codice dell'unita tra le unita ascendenti di p_codice_unita
       quella che non ha padre.

        Rev.  Data       Autore  Descrizione.
        00    15/02/2010  SC  Prima emissione. A34954.2.0
    ********************************************************************************/
   FUNCTION get_unita_radice_area (p_codice_unita              VARCHAR2,
                                   p_data_riferimento          DATE,
                                   p_ottica                    VARCHAR2,
                                   p_codice_amministrazione    VARCHAR2,
                                   p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2
   IS
      cascendenti              afc.t_ref_cursor;
      depprogr                 NUMBER;
      dep_codice_unita_padre   seg_unita.unita%TYPE;
      depdescrizioneunita      VARCHAR2 (1000);
      dep_dal_padre            DATE;
      dep_al_padre             DATE;
      suddivisione_presente    NUMBER := 0;
      dep_suddivisione         NUMBER;
   BEGIN
      NULL;
      cascendenti :=
         so4_ags_pkg.unita_get_ascendenti_sudd (p_codice_unita,
                                                p_data_riferimento,
                                                p_ottica);

      IF cascendenti%ISOPEN
      THEN
         LOOP
            FETCH cascendenti
               INTO depprogr,
                    dep_codice_unita_padre,
                    depdescrizioneunita,
                    dep_dal_padre,
                    dep_al_padre,
                    dep_suddivisione;

            EXIT WHEN cascendenti%NOTFOUND OR suddivisione_presente = 1;

            BEGIN
               SELECT 1
                 INTO suddivisione_presente
                 FROM ag_suddivisioni
                WHERE     dep_suddivisione = id_suddivisione
                      AND indice_aoo =
                             ag_utilities.get_indice_aoo (
                                p_codice_amministrazione,
                                p_codice_aoo);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            EXIT WHEN suddivisione_presente = 1;
         ----INTEGRITYPACKAGE.LOG(depprogr||', '||p_codice_unita_padre||', '||depdescrizioneunita||', '||
         --                  p_dal_padre||', '||p_al_padre);
         END LOOP;

         CLOSE cascendenti;
      END IF;

      RETURN dep_codice_unita_padre;
   END get_unita_radice_area;

   FUNCTION GET_TIPI_DOCUMENTO_ASSOCIATI (P_TIPO_DOCUMENTO_RISPOSTA VARCHAR2)
      RETURN VARCHAR2
   IS
      RET   VARCHAR2 (32000);
   BEGIN
      FOR TD
         IN (SELECT DESCRIZIONE_TIPO_DOCUMENTO DES
               FROM SEG_TIPI_DOCUMENTO TIDO, DOCUMENTI DOCU
              WHERE     TIDO.ID_DOCUMENTO = DOCU.ID_DOCUMENTO
                    AND DOCU.STATO_DOCUMENTO NOT IN ('CA', 'RE', 'PB')
                    AND RISPOSTA = 'N'
                    AND TIPO_DOC_RISPOSTA = P_TIPO_DOCUMENTO_RISPOSTA)
      LOOP
         IF RET IS NULL
         THEN
            RET := '- ' || TD.DES;
         ELSE
            RET := RET || CHR (13) || CHR (10) || '- ' || TD.DES;
         END IF;
      END LOOP;

      RETURN RET;
   END;

   /*****************************************************************************
       NOME:        crea_task_esterno_TODO.
       DESCRIZIONE: Crea task_esterno JWF_WORKLIST_SERVICES
                    e bottone in multiselezione per eliminare le
                    attività TODO se esiste JWF_WORKLIST_SERVICES,
                    altrimenti crea attività TODO classica.

      Rev.  Data        Autore      Descrizione.
      014   01/12/2017    SC        Adeguamento SmartDesktop

   ********************************************************************************/
   FUNCTION crea_task_esterno_TODO (P_ID_RIFERIMENTO           IN VARCHAR2,
                                    P_ATTIVITA_DESCRIZIONE     IN VARCHAR2,
                                    P_TOOLTIP_ATTIVITA_DESCR   IN VARCHAR2,
                                    P_URL_RIF                  IN VARCHAR2,
                                    P_URL_RIF_DESC             IN VARCHAR2,
                                    P_URL_EXEC                 IN VARCHAR2,
                                    P_TOOLTIP_URL_EXEC         IN VARCHAR2,
                                    P_DATA_SCAD                IN DATE,
                                    P_PARAM_INIT_ITER          IN VARCHAR2,
                                    P_NOME_ITER                IN VARCHAR2,
                                    P_DESCRIZIONE_ITER         IN VARCHAR2,
                                    P_COLORE                   IN VARCHAR2,
                                    P_ORDINAMENTO              IN VARCHAR2,
                                    P_UTENTE_ESTERNO           IN VARCHAR2,
                                    P_CATEGORIA                IN VARCHAR2,
                                    P_DESKTOP                  IN VARCHAR2,
                                    P_STATO                    IN VARCHAR2,
                                    P_TIPOLOGIA                IN VARCHAR2,
                                    P_DATIAPPLICATIVI1         IN VARCHAR2,
                                    P_DATIAPPLICATIVI2         IN VARCHAR2,
                                    P_DATIAPPLICATIVI3         IN VARCHAR2,
                                    P_TIPO_BOTTONE             IN VARCHAR2,
                                    P_DATA_ATTIVAZIONE         IN DATE,
                                    P_DES_DETTAGLIO_1          IN VARCHAR2,
                                    P_DETTAGLIO_1              IN VARCHAR2)
      RETURN NUMBER
   AS
   BEGIN
      RETURN ag_utilities_cruscotto.crea_task_esterno_TODO (
                P_ID_RIFERIMENTO,
                P_ATTIVITA_DESCRIZIONE,
                P_TOOLTIP_ATTIVITA_DESCR,
                P_URL_RIF,
                P_URL_RIF_DESC,
                P_URL_EXEC,
                P_TOOLTIP_URL_EXEC,
                P_DATA_SCAD,
                P_PARAM_INIT_ITER,
                P_NOME_ITER,
                P_DESCRIZIONE_ITER,
                P_COLORE,
                P_ORDINAMENTO,
                P_UTENTE_ESTERNO,
                P_CATEGORIA,
                P_DESKTOP,
                P_STATO,
                P_TIPOLOGIA,
                P_DATIAPPLICATIVI1,
                P_DATIAPPLICATIVI2,
                P_DATIAPPLICATIVI3,
                P_TIPO_BOTTONE,
                P_DATA_ATTIVAZIONE,
                P_DES_DETTAGLIO_1,
                P_DETTAGLIO_1);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;
BEGIN
   storicoruoli :=
      ag_parametro.get_valore (
         'STORICO_RUOLI_' || ag_utilities.get_indice_aoo (NULL, NULL),
         '@agVar@');
END;
/
