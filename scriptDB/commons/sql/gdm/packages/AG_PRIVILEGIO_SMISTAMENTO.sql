--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_PRIVILEGIO_SMISTAMENTO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE       "AG_PRIVILEGIO_SMISTAMENTO"
IS
/******************************************************************************
 NOME:        AG_PRIVILEGIO_SMISTAMENTO
 DESCRIZIONE: Gestione tabella ag_privilegi_smistamento.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    24/01/2007  SC  Prima emissione.
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione CONSTANT VARCHAR2 (40) := 'V1.00';
   s_table_name CONSTANT VARCHAR2 (30) := 'ag_privilegi_smistamento';
   SUBTYPE t_rowtype IS AG_PRIVILEGI_SMISTAMENTO%ROWTYPE;
   -- Tipo del record primary key
   TYPE t_PK IS RECORD (
      AOO                 AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , PRIVILEGIO          AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , TIPO_SMISTAMENTO    AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE
   );
   TYPE ag_prsm_refcursor IS REF CURSOR;
   -- Exceptions
   --<exception_name> exception;
   --pragma exception_init( <exception_name>, <error_code> );
   --s_<exception_name>_number constant AFC_Error.t_error_number := <error_code>;
   --s_<exception_name>_msg    constant AFC_Error.t_error_msg := <error_message>;
   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (versione, WNDS);
   -- Inserimento di una riga
   PROCEDURE ins (
      p_AOO            IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , p_TIPO_SMISTAMENTO IN     AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE);
   -- Aggiornamento di una riga
   PROCEDURE upd (
      p_NEW_AOO        IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , p_NEW_PRIVILEGIO IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , p_NEW_TIPO_SMISTAMENTO IN AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE
    , p_OLD_AOO        IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE DEFAULT NULL
    , p_OLD_PRIVILEGIO IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE DEFAULT NULL
    , p_OLD_TIPO_SMISTAMENTO IN AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE
            DEFAULT NULL);
   -- Cancellazione di una riga
   PROCEDURE del (
      p_AOO            IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , p_TIPO_SMISTAMENTO IN     AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE
    , p_check_OLD      IN       INTEGER DEFAULT 0);
   -- righe corrispondenti alla selezione indicata
/******************************************************************************
 NOME:        get_tipi_smistamento
 DESCRIZIONE: Dato un privilegio restituisce i privilegi associati.
 PARAMETRI:   Indice dell'AOO e privilegio.
 NOTE:
******************************************************************************/
   FUNCTION get_tipi_smistamento (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_PRIVILEGIO     IN       VARCHAR2 DEFAULT NULL)
      RETURN ag_prsm_refcursor;
/******************************************************************************
 NOME:        get_privilegi
 DESCRIZIONE: Dato un tipo di smistamento restituisce i privilegi associati.
 PARAMETRI:   Indice dell'AOO e tipo_smsitamento.
 NOTE:
******************************************************************************/
   FUNCTION get_privilegi (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_TIPO_SMISTAMENTO IN     VARCHAR2 DEFAULT NULL)
      RETURN ag_prsm_refcursor;
/******************************************************************************
 NOME:        get_privilegi_ruolo
 DESCRIZIONE: Dato un tipo di smistamento e un ruolo restituisce i privilegi associati
              al tipo smistamento che sono relativi al ruolo.
 PARAMETRI:   Indice dell'AOO, tipo_smistamento e codice del ruolo.
 NOTE:
******************************************************************************/
   FUNCTION get_privilegi_ruolo (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_TIPO_SMISTAMENTO IN     VARCHAR2 DEFAULT NULL
    , p_RUOLO IN     VARCHAR2 DEFAULT NULL)
      RETURN ag_prsm_refcursor;
/******************************************************************************
 NOME:        verifica_privilegio
 DESCRIZIONE: Dato un tipo di smistamento e un privilegio verifica se il tipo_smistamento
              prevede il privilegio..
 PARAMETRI:   Indice dell'AOO, tipo_smistamento e codice del privilegio.
RETURN        1 se esiste p_privilegio per p_tipo_smistamento
              0 altrimenti.
 NOTE:
******************************************************************************/
   FUNCTION verifica_privilegio (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_TIPO_SMISTAMENTO IN     VARCHAR2 DEFAULT NULL
    , p_PRIVILEGIO IN     VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
END Ag_Privilegio_Smistamento;
/
CREATE OR REPLACE PACKAGE BODY       "AG_PRIVILEGIO_SMISTAMENTO"
IS
/******************************************************************************
 NOME:        AG_PRIVILEGIO_SMISTAMENTO
 DESCRIZIONE: Gestione tabella Ag_Privilegio_smistamento.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   24/01/2007  SC  Prima emissione.
******************************************************************************/
   --s_revisione_body      constant VARCHAR2(40);
   --s_error_table AFC_Error.t_error_table;
   --------------------------------------------------------------------------------
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
      RETURN s_revisione;
   END;                                                    -- AG_PRIVILEGIO_RUOLO.versione
--------------------------------------------------------------------------------
   FUNCTION exists_id (
      p_AOO            IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , p_TIPO_SMISTAMENTO IN     AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE)
      RETURN NUMBER
   IS
/******************************************************************************
 NOME:        exists_id
 DESCRIZIONE: Esistenza riga con chiave indicata.
 PARAMETRI:   Attributi chiave.
 RITORNA:     number: 1 se la riga esiste, 0 altrimenti.
 NOTE:        cfr. existsId per ritorno valori boolean.
******************************************************************************/
      d_result            NUMBER;
   BEGIN
      BEGIN
         SELECT 1
           INTO d_result
           FROM AG_PRIVILEGI_SMISTAMENTO
          WHERE AOO = p_AOO
            AND PRIVILEGIO = p_PRIVILEGIO
            AND TIPO_SMISTAMENTO = p_TIPO_SMISTAMENTO;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            d_result         := 0;
      END;
      RETURN d_result;
   END;
   -- AG_PRIVILEGIO_SMISTAMENTO.exists_id
   --------------------------------------------------------------------------------
   PROCEDURE ins (
      p_AOO            IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , p_TIPO_SMISTAMENTO IN     AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE)
   IS
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
   BEGIN
      INSERT INTO AG_PRIVILEGI_SMISTAMENTO
                  (AOO, PRIVILEGIO, TIPO_SMISTAMENTO)
           VALUES (p_AOO, p_PRIVILEGIO, p_TIPO_SMISTAMENTO);
   END;                                                   -- AG_PRIVILEGIO_SMISTAMENTO.ins
--------------------------------------------------------------------------------
   PROCEDURE upd (
      p_NEW_AOO        IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , p_NEW_PRIVILEGIO IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , p_NEW_TIPO_SMISTAMENTO IN AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE
    , p_OLD_AOO        IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE DEFAULT NULL
    , p_OLD_PRIVILEGIO IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE DEFAULT NULL
    , p_OLD_TIPO_SMISTAMENTO IN AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE
            DEFAULT NULL)
   IS
/******************************************************************************
 NOME:        upd
 DESCRIZIONE: Aggiornamento di una riga con chiave.
 PARAMETRI:   Chiavi e attributi della table
              p_check_OLD: 0, ricerca senza controllo su attributi precedenti
                           1, ricerca con controllo anche su attributi precedenti.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
******************************************************************************/
      d_row_found         NUMBER;
   BEGIN
      UPDATE AG_PRIVILEGI_SMISTAMENTO
         SET AOO = p_NEW_AOO
           , PRIVILEGIO = p_NEW_PRIVILEGIO
           , TIPO_SMISTAMENTO = p_NEW_TIPO_SMISTAMENTO
       WHERE AOO = p_OLD_AOO
         AND PRIVILEGIO = p_OLD_PRIVILEGIO
         AND TIPO_SMISTAMENTO = p_OLD_TIPO_SMISTAMENTO;
      d_row_found      := SQL%ROWCOUNT;
   /*if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;*/
   END;                                                   -- AG_PRIVILEGIO_SMISTAMENTO.upd
--------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   PROCEDURE del (
      p_AOO            IN       AG_PRIVILEGI_SMISTAMENTO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO%TYPE
    , p_TIPO_SMISTAMENTO IN     AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO%TYPE
    , p_check_old      IN       INTEGER DEFAULT 0)
   IS
/******************************************************************************
 NOME:        del
 DESCRIZIONE: Cancellazione della riga indicata.
 PARAMETRI:   Chiavi e attributi della table.
              p_check_OLD: 0, ricerca senza controllo su attributi precedenti
                           1, ricerca con controllo anche su attributi precedenti.
 NOTE:        Nel caso in cui non venga elaborato alcun record viene lanciata
              l'eccezione -20010 (cfr. AFC_ERROR).
              Se p_check_old = 1, viene controllato se il record corrispondente a
              tutti i campi passati come parametri esiste nella tabella.
******************************************************************************/
      d_row_found         NUMBER;
   BEGIN
      DELETE FROM AG_PRIVILEGI_SMISTAMENTO
            WHERE AOO = p_AOO
              AND PRIVILEGIO = p_PRIVILEGIO
              AND TIPO_SMISTAMENTO = p_TIPO_SMISTAMENTO;
      d_row_found      := SQL%ROWCOUNT;
   /*if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number, AFC_ERROR.modified_by_other_user_msg );
   end if;
   DbC.POST ( not DbC.PostOn or not existsId ( p_AOO
                                             , p_PRIVILEGIO
                                             , p_RUOLO
                                             )
            , 'existsId on AG_PRIVILEGIO_RUOLO.del'
            );*/
   END;                                                   -- AG_PRIVILEGIO_SMISTAMENTO.del
--------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   -- < Metodi getter: espandere template "getter" >
   --------------------------------------------------------------------------------
/******************************************************************************
 NOME:        get_tipi_smistamento
 DESCRIZIONE: Dato un privilegio restituisce i privilegi associati.
 PARAMETRI:   Indice dell'AOO e privilegio.
 NOTE:
******************************************************************************/
   FUNCTION get_tipi_smistamento (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_PRIVILEGIO     IN       VARCHAR2 DEFAULT NULL)
      RETURN ag_prsm_refcursor
   IS
      p_ret_rc            ag_prsm_refcursor;
   BEGIN
      OPEN p_ret_rc FOR
         SELECT TIPO_SMISTAMENTO
           FROM AG_PRIVILEGI_SMISTAMENTO
          WHERE privilegio = p_PRIVILEGIO
            AND aoo = p_AOO;
      RETURN p_ret_rc;
   END;
/******************************************************************************
 NOME:        get_privilegi
 DESCRIZIONE: Dato un tipo di smistamento restituisce i privilegi associati.
 PARAMETRI:   Indice dell'AOO e tipo_smsitamento.
 NOTE:
******************************************************************************/
   FUNCTION get_privilegi (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_TIPO_SMISTAMENTO IN     VARCHAR2 DEFAULT NULL)
      RETURN ag_prsm_refcursor
   IS
      p_ret_rc            ag_prsm_refcursor;
   BEGIN
      OPEN p_ret_rc FOR
         SELECT privilegio
           FROM AG_PRIVILEGI_SMISTAMENTO
          WHERE TIPO_SMISTAMENTO = p_TIPO_SMISTAMENTO
            AND aoo = p_AOO;
      RETURN p_ret_rc;
   END get_privilegi;
/******************************************************************************
 NOME:        get_privilegi_ruolo
 DESCRIZIONE: Dato un tipo di smistamento e un ruolo restituisce i privilegi associati
              al tipo smistamento che sono relativi al ruolo.
 PARAMETRI:   Indice dell'AOO, tipo_smistamento e codice del ruolo.
 NOTE:
******************************************************************************/
   FUNCTION get_privilegi_ruolo (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_TIPO_SMISTAMENTO IN     VARCHAR2 DEFAULT NULL
    , p_RUOLO IN     VARCHAR2 DEFAULT NULL)
      RETURN ag_prsm_refcursor
   IS
      p_ret_rc            ag_prsm_refcursor;
   BEGIN
      OPEN p_ret_rc FOR
         SELECT AG_PRIVILEGI_SMISTAMENTO.privilegio
           FROM AG_PRIVILEGI_SMISTAMENTO
        , AG_PRIVILEGI_RUOLO
          WHERE AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO = p_TIPO_SMISTAMENTO
            AND AG_PRIVILEGI_SMISTAMENTO.aoo = p_AOO
   AND AG_PRIVILEGI_SMISTAMENTO.AOO = AG_PRIVILEGI_RUOLO.AOO
   AND AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO = AG_PRIVILEGI_RUOLO.privilegio
   AND AG_PRIVILEGI_RUOLO.RUOLO = P_RUOLO;
      RETURN p_ret_rc;
   END get_privilegi_ruolo;
/******************************************************************************
 NOME:        verifica_privilegio
 DESCRIZIONE: Dato un tipo di smistamento e un privilegio verifica se il tipo_smistamento
              prevede il privilegio..
 PARAMETRI:   Indice dell'AOO, tipo_smistamento e codice del privilegio.
RETURN        1 se esiste p_privilegio per p_tipo_smistamento
              0 altrimenti.
 NOTE:
******************************************************************************/
   FUNCTION verifica_privilegio (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_TIPO_SMISTAMENTO IN     VARCHAR2 DEFAULT NULL
    , p_PRIVILEGIO IN     VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      retVal            NUMBER;
   BEGIN
      SELECT DISTINCT 1
       INTO retVal
        FROM AG_PRIVILEGI_SMISTAMENTO
       WHERE AG_PRIVILEGI_SMISTAMENTO.TIPO_SMISTAMENTO = p_TIPO_SMISTAMENTO
         AND AG_PRIVILEGI_SMISTAMENTO.aoo = p_AOO
         AND AG_PRIVILEGI_SMISTAMENTO.PRIVILEGIO = p_privilegio;
      RETURN retVal;
   EXCEPTION
   WHEN OTHERS THEN
      return 0;
   END verifica_privilegio;
END Ag_Privilegio_Smistamento;
/
