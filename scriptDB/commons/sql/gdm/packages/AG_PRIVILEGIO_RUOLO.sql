--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_PRIVILEGIO_RUOLO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_PRIVILEGIO_RUOLO"
IS
/******************************************************************************
 NOME:        AG_PRIVILEGIO_RUOLO
 DESCRIZIONE: Gestione tabella ag_privilegi_ruolo.
 ANNOTAZIONI: .
 REVISIONI:   .
 <CODE>
 Rev.  Data       Autore  Descrizione.
 00    21/12/2006  SC  Prima emissione.
 </CODE>
******************************************************************************/
   -- Revisione del Package
   s_revisione CONSTANT VARCHAR2 (40) := 'V1.00';
   s_table_name CONSTANT VARCHAR2 (30) := 'ag_privilegi_ruolo';
   SUBTYPE t_rowtype IS AG_PRIVILEGI_RUOLO%ROWTYPE;
   -- Tipo del record primary key
   TYPE t_PK IS RECORD (
      AOO                 AG_PRIVILEGI_RUOLO.AOO%TYPE
    , PRIVILEGIO          AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , RUOLO               AG_PRIVILEGI_RUOLO.RUOLO%TYPE
   );
   TYPE ag_prru_refcursor IS REF CURSOR;
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
      p_AOO            IN       AG_PRIVILEGI_RUOLO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , p_RUOLO          IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE);
   -- Aggiornamento di una riga
   PROCEDURE upd (
      p_NEW_AOO        IN       AG_PRIVILEGI_RUOLO.AOO%TYPE
    , p_NEW_PRIVILEGIO IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , p_NEW_RUOLO      IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE
    , p_OLD_AOO        IN       AG_PRIVILEGI_RUOLO.AOO%TYPE DEFAULT NULL
    , p_OLD_PRIVILEGIO IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE DEFAULT NULL
    , p_OLD_RUOLO      IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE DEFAULT NULL);
   -- Cancellazione di una riga
   PROCEDURE del (
      p_AOO            IN       AG_PRIVILEGI_RUOLO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , p_RUOLO          IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE
    , p_check_OLD      IN       INTEGER DEFAULT 0);
   -- righe corrispondenti alla selezione indicata
/**********************************************************************************
 NOME:        get_ruoli
 DESCRIZIONE: Restituisce un cursore con tutti i ruoli che hanno p_PRIVILEGIO.
              Se è specificato p_ruolo, restituisce solo una riga con p_ruolo, purche'
           esso abbia p_privilegio.
 PARAMETRI:   p_AOO            IN       VARCHAR2 Indice AOO per la ricerca
              p_PRIVILEGIO     IN       VARCHAR2 Codice Privilegio dicui cercare i ruoli
              p_RUOLO          IN       VARCHAR2 DEFAULT NULL codice ruolo, facoltativo.
 NOTE:        Se specificato p_ruolo, in pratica verifica se p_ruolo ha p_Privilegio
              per l'aoo di indice p_aoo.
**********************************************************************************/
   FUNCTION get_ruoli (
      p_AOO            IN       VARCHAR2
    , p_PRIVILEGIO     IN       VARCHAR2
   , p_RUOLO          IN       VARCHAR2 DEFAULT NULL)
      RETURN ag_prru_refcursor;
   FUNCTION get_privilegi (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_RUOLO          IN       VARCHAR2 DEFAULT NULL)
      RETURN ag_prru_refcursor;
/*****************************************************************************
 NOME:        verifica_privilegio_ruolo.
 DESCRIZIONE: Verifica se p_ruolo ha p_privilegio.
INPUT  p_AOO  in varchar2
, p_RUOLO  in varchar2
, p_PRIVILEGIO in varchar2
RITORNO:  1 = si, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION verifica_privilegio_ruolo (
      p_AOO            IN       VARCHAR2
    , p_RUOLO          IN       VARCHAR2
    , p_PRIVILEGIO     IN       VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY "AG_PRIVILEGIO_RUOLO"
IS
/******************************************************************************
 NOME:        AG_PRIVILEGIO_RUOLO
 DESCRIZIONE: Gestione tabella ag_privilegi_ruolo.
 ANNOTAZIONI: .
 REVISIONI:   .
 Rev.  Data        Autore  Descrizione.
 000   21/12/2006  SC  Prima emissione.
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
      p_AOO            IN       AG_PRIVILEGI_RUOLO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , p_RUOLO          IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE)
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
           FROM AG_PRIVILEGI_RUOLO
          WHERE AOO = p_AOO
            AND PRIVILEGIO = p_PRIVILEGIO
            AND RUOLO = p_RUOLO;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            d_result         := 0;
      END;
      RETURN d_result;
   END;                                                   -- AG_PRIVILEGIO_RUOLO.exists_id
--------------------------------------------------------------------------------
   PROCEDURE ins (
      p_AOO            IN       AG_PRIVILEGI_RUOLO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , p_RUOLO          IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE)
   IS
/******************************************************************************
 NOME:        ins
 DESCRIZIONE: Inserimento di una riga con chiave e attributi indicati.
 PARAMETRI:   Chiavi e attributi della table.
******************************************************************************/
   BEGIN
      INSERT INTO AG_PRIVILEGI_RUOLO
                  (AOO, PRIVILEGIO, RUOLO)
           VALUES (p_AOO, p_PRIVILEGIO, p_RUOLO);
   END;                                                         -- AG_PRIVILEGIO_RUOLO.ins
--------------------------------------------------------------------------------
   PROCEDURE upd (
      p_NEW_AOO        IN       AG_PRIVILEGI_RUOLO.AOO%TYPE
    , p_NEW_PRIVILEGIO IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , p_NEW_RUOLO      IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE
    , p_OLD_AOO        IN       AG_PRIVILEGI_RUOLO.AOO%TYPE DEFAULT NULL
    , p_OLD_PRIVILEGIO IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE DEFAULT NULL
    , p_OLD_RUOLO      IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE DEFAULT NULL)
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
      UPDATE AG_PRIVILEGI_RUOLO
         SET AOO = p_NEW_AOO
           , PRIVILEGIO = p_NEW_PRIVILEGIO
           , RUOLO = p_NEW_RUOLO
       WHERE AOO = p_OLD_AOO
         AND PRIVILEGIO = p_OLD_PRIVILEGIO
         AND RUOLO = p_OLD_RUOLO;
      d_row_found      := SQL%ROWCOUNT;
   /*if d_row_found < 1
   then
      raise_application_error ( AFC_ERROR.modified_by_other_user_number
                              , AFC_ERROR.modified_by_other_user_msg
                              );
   end if;*/
   END;                                                         -- AG_PRIVILEGIO_RUOLO.upd
--------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   PROCEDURE del (
      p_AOO            IN       AG_PRIVILEGI_RUOLO.AOO%TYPE
    , p_PRIVILEGIO     IN       AG_PRIVILEGI_RUOLO.PRIVILEGIO%TYPE
    , p_RUOLO          IN       AG_PRIVILEGI_RUOLO.RUOLO%TYPE
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
      DELETE FROM AG_PRIVILEGI_RUOLO
            WHERE AOO = p_AOO
              AND PRIVILEGIO = p_PRIVILEGIO
              AND RUOLO = p_RUOLO;
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
   END;                                                         -- AG_PRIVILEGIO_RUOLO.del
--------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   -- < Metodi getter: espandere template "getter" >
   --------------------------------------------------------------------------------
/**********************************************************************************
 NOME:        get_ruoli
 DESCRIZIONE: Restituisce un cursore con tutti i ruoli che hanno p_PRIVILEGIO.
              Se è specificato p_ruolo, restituisce solo una riga con p_ruolo, purche'
           esso abbia p_privilegio.
 PARAMETRI:   p_AOO            IN       VARCHAR2 Indice AOO per la ricerca
              p_PRIVILEGIO     IN       VARCHAR2 Codice Privilegio dicui cercare i ruoli
              p_RUOLO          IN       VARCHAR2 DEFAULT NULL codice ruolo, facoltativo.
 NOTE:        Se specificato p_ruolo, in pratica verifica se p_ruolo ha p_Privilegio
              per l'aoo di indice p_aoo.
**********************************************************************************/
   FUNCTION get_ruoli (
      p_AOO            IN       VARCHAR2
    , p_PRIVILEGIO     IN       VARCHAR2
   , p_RUOLO          IN       VARCHAR2 DEFAULT NULL)
      RETURN ag_prru_refcursor
   IS
      p_ret_rc            ag_prru_refcursor;
   BEGIN
      OPEN p_ret_rc FOR
         SELECT ruolo
           FROM AG_PRIVILEGI_RUOLO
          WHERE privilegio = p_PRIVILEGIO
            AND aoo = p_AOO
         AND ruolo = NVL(p_RUOLO, ruolo);
      RETURN p_ret_rc;
   END;
   FUNCTION get_privilegi (
      p_AOO            IN       VARCHAR2 DEFAULT NULL
    , p_RUOLO          IN       VARCHAR2 DEFAULT NULL)
      RETURN ag_prru_refcursor
   IS
      p_ret_rc            ag_prru_refcursor;
   BEGIN
      OPEN p_ret_rc FOR
         SELECT privilegio
           FROM AG_PRIVILEGI_RUOLO
          WHERE ruolo = p_RUOLO
            AND aoo = p_AOO;
      RETURN p_ret_rc;
   END;
/*****************************************************************************
 NOME:        verifica_privilegio_ruolo.
 DESCRIZIONE: Verifica se p_ruolo ha p_privilegio.
INPUT  p_AOO  in varchar2
, p_RUOLO  in varchar2
, p_PRIVILEGIO in varchar2
RITORNO:  1 = si, 0 altrimenti.
 Rev.  Data       Autore  Descrizione.
 00    02/01/2007  SC  Prima emissione.
********************************************************************************/
   FUNCTION verifica_privilegio_ruolo (
      p_AOO            IN       VARCHAR2
    , p_RUOLO          IN       VARCHAR2
    , p_PRIVILEGIO     IN       VARCHAR2)
      RETURN NUMBER
   IS
      retVal              NUMBER;
   BEGIN
      BEGIN
         SELECT DISTINCT 1
                    INTO retVal
                    FROM AG_PRIVILEGI_RUOLO
                   WHERE ruolo = p_RUOLO
                     AND aoo = p_AOO
                     AND privilegio = p_privilegio;
      EXCEPTION
         WHEN OTHERS THEN
            retVal           := 0;
      END;
      RETURN retVal;
   END;
--------------------------------------------------------------------------------
--begin
-- inserimento degli errori nella tabella
--s_error_table( s_<exception_name>_number ) := s_<exception_name>_msg;
END;
/
