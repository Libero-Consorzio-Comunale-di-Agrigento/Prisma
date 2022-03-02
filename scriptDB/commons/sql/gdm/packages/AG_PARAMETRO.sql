--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_PARAMETRO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_PARAMETRO
AS
/******************************************************************************
   NAME:       AG_PARAMETRO
   PURPOSE:    Gestisce la tabella PARAMETRI.

   REVISIONS:
   Ver         Date        Author            Description
   ---------   ----------  ---------------   ------------------------------------
   1.00        18/12/2007                    1. Created this package.
   1.01        16/05/2012  MM                Modifiche V2.1.
   1.02        26/02/2015  MM                Creazione get_all_ag_parameters
   1.03        23/03/2017  MM                Creazione set_valore con codice
                                             amministrazione e aoo e del.
******************************************************************************/

   c_tipo_modello CONSTANT PARAMETRI.TIPO_MODELLO%TYPE := '@agVar@';
   c_tipo_modello_sped CONSTANT PARAMETRI.TIPO_MODELLO%TYPE := '@agSped@';
   s_revisione   afc.t_revision := 'V1.03';

   FUNCTION versione
      RETURN VARCHAR2;

   /*****************************************************************************
      NOME:        set_valore
      DESCRIZIONE:   aggiorna un valore sulla tabella parametri.
      INPUT    p_codice  in varchar2
            , p_tipo_modello  in varchar2
            , p_valore in varchar2

      Rev.  Data        Autore                      Descrizione.
      00    02/01/2007  Enrico Sasdelli            Prima emissione.
   ********************************************************************************/
   PROCEDURE set_valore (
      p_codice        IN   VARCHAR,
      p_tipo_valore   IN   VARCHAR,
      p_valore        IN   VARCHAR
   );

   PROCEDURE set_valore
   (p_codice IN PARAMETRI.CODICE%TYPE
   ,p_codice_amm IN VARCHAR2
   ,p_codice_aoo IN VARCHAR2
   ,p_valore IN PARAMETRI.VALORE%TYPE
   ,p_tipo_modello in varchar2 default c_tipo_modello
   ,p_note in varchar2 default null);

   FUNCTION get_valore
   (p_codice IN PARAMETRI.CODICE%TYPE
   ,p_tipo_valore IN PARAMETRI.TIPO_MODELLO%TYPE
   ,p_default IN PARAMETRI.VALORE%TYPE default '')
      /******************************************************************************
       NOME:        get_valore. A25585.
       DESCRIZIONE: Restituisce il valore identificato da p_codice, p_tipo_valore .
       PARAMETRI:   p_codice: il codice sulla tabella parametri
                    p_tipo_valore:    il tipo_modello sulla tabella parametri
                    p_default: valore da restituire in caso di exception
      ******************************************************************************/
   RETURN PARAMETRI.VALORE%TYPE;

   FUNCTION get_valore
   (p_codice IN PARAMETRI.CODICE%TYPE
   ,p_codice_amm IN VARCHAR2
   ,p_codice_aoo IN VARCHAR2
   ,p_default IN PARAMETRI.VALORE%TYPE
   ,p_tipo_modello in varchar2 default c_tipo_modello)
  /******************************************************************************
   NOME:        get_valore.
   DESCRIZIONE: Restituisce il valore identificato da p_codice.
                Consente di gestire personalizzazioni.
   PARAMETRI:   p_codice:      codice sulla tabella parametri
                p_codice_amm:  codice dell'amministrazione corrente
                p_codice_aoo:  codice dell'aoo attiva
                p_default:     valore del parametro da restituire in caso di exception
    Rev.  Data        Autore   Descrizione.
    00    08/04/2008  SN       A26822.0.0. Prima emissione.
  ******************************************************************************/
  RETURN PARAMETRI.VALORE%TYPE;
  PRAGMA RESTRICT_REFERENCES (get_valore, WNDS);

  FUNCTION get_all_strut_parameters
  /******************************************************************************
   NOME:        get_all_strut_parameters.
   DESCRIZIONE: Restituisce un ref_cursor con i valori di tutti i
                parametri aventi tipo_modello = @agStrut@.

   PARAMETRI:
    Rev.  Data        Autore   Descrizione.
     001 08/09/2008   SN        Creazione.
  ******************************************************************************/
      RETURN AFC.t_ref_cursor;

  FUNCTION get_all_Sped_parameters
  /******************************************************************************
   NOME:        get_all_Sped_parameters.
   DESCRIZIONE: Restituisce un ref_cursor con i valori di tutti i
                parametri aventi tipo_modello = @agSped@.

   PARAMETRI:
    Rev.  Data        Autore   Descrizione.
     001 02/0112011   MMur        Creazione.
  ******************************************************************************/
      RETURN AFC.t_ref_cursor;

   FUNCTION get_all_ag_parameters
  /******************************************************************************
   NOME:        get_all_ag_parameters.
   DESCRIZIONE: Restituisce un ref_cursor con i valori di tutti i
                parametri aventi tipo_modello = @agStrut@, @agVar@, @STANDARD@

   PARAMETRI:
    Rev.  Data        Autore   Descrizione.
    002   26/02/2015   MMAL    Creazione.
  ******************************************************************************/
   ( p_codice_amm IN VARCHAR2
   , p_codice_aoo IN VARCHAR2)
      RETURN AFC.t_ref_cursor;

   PROCEDURE del (p_codice       IN PARAMETRI.CODICE%TYPE,
                  p_tipo_valore  IN PARAMETRI.TIPO_MODELLO%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY     AG_PARAMETRO
IS
   /******************************************************************************
      NAME:       GDM.AG_PARAMETRO
      PURPOSE:    Gestisce la tabella PARAMETRI.

      REVISIONS:
      Ver         Date        Author            Description
      ---------   ----------  ---------------   ------------------------------------
      000        18/12/2007                     1. Created this package.
      001        16/05/2012   MM                Modifiche V2.1.
      002        26/02/2015   MM                Creazione get_all_ag_parameters
      003        23/03/2017   MM                Creazione set_valore con codice
                                                amministrazione e aoo.
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '003';

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

   PROCEDURE set_valore (p_codice        IN VARCHAR,
                         p_tipo_valore   IN VARCHAR,
                         p_valore        IN VARCHAR)
   /******************************************************************************
    NOME:        set_valore
    DESCRIZIONE:  Inserisce un valore associato ad un tipo_modello e codice sulla tabella parametri.
               Se la coppia codice-tipo_modello esiste giý per i parametri richiesti allora aggiorna il valore
               presente sulla tabella con quello passato alla procedure.
    PARAMETRI:   p_codice: il codice sulla tabella parametri
              p_tipo_valore:    il tipo_modello sulla tabella parametri
              p_valore:         il valore che si vuole aggiornare.
   ******************************************************************************/
   IS
   BEGIN
      INSERT INTO parametri (codice, tipo_modello, valore)
           VALUES (p_codice, p_tipo_valore, p_valore);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         BEGIN
            UPDATE parametri
               SET valore = p_valore
             WHERE codice = p_codice AND tipo_modello = p_tipo_valore;
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE;
         END;
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE set_valore (p_codice         IN PARAMETRI.CODICE%TYPE,
                         p_codice_amm     IN VARCHAR2,
                         p_codice_aoo     IN VARCHAR2,
                         p_valore         IN PARAMETRI.VALORE%TYPE,
                         p_tipo_modello   IN VARCHAR2 DEFAULT c_tipo_modello,
                         p_note           IN VARCHAR2 DEFAULT NULL)
   /******************************************************************************
     NOME:           set_valore
     DESCRIZIONE:    Inserisce un valore associato ad un tipo_modello e codice
                     sulla tabella parametri.
                     Se la coppia codice-tipo_modello esiste giý per i parametri
                     richiesti allora aggiorna il valore  presente sulla tabella
                     con quello passato alla procedure.
     PARAMETRI:  p_codice:      codice sulla tabella parametri
                 p_codice_amm:  codice dell'amministrazione corrente
                 p_codice_aoo:  codice dell'aoo attiva
                 p_valore:      valore che si vuole aggiornare.
     Rev.  Data        Autore   Descrizione.
     003   23/03/2017  MM       Prima emissione.
   ******************************************************************************/
   IS
      retval       parametri.valore%TYPE;
      d_codice     VARCHAR2 (1000) := p_codice;
      d_suffisso   VARCHAR2 (10);
   BEGIN
      IF SUBSTR (d_codice, -1) != '_'
      THEN
         d_codice := d_codice || '_';
      END IF;

      BEGIN
         SELECT SUBSTR (codice,
                        DECODE (INSTR (codice,
                                       '_',
                                       1,
                                       2),
                                0, TO_NUMBER (NULL),
                                (  INSTR (codice,
                                          '_',
                                          1,
                                          2)
                                 + 1)),
                        LENGTH (codice))
           INTO d_suffisso
           FROM parametri
          WHERE     valore = p_codice_aoo
                AND tipo_modello = c_tipo_modello
                AND codice IN (SELECT    'CODICE_AOO_'
                                      || SUBSTR (codice,
                                                 DECODE (INSTR (codice,
                                                                '_',
                                                                1,
                                                                2),
                                                         0, TO_NUMBER (NULL),
                                                         (  INSTR (codice,
                                                                   '_',
                                                                   1,
                                                                   2)
                                                          + 1)),
                                                 LENGTH (codice))
                                 FROM parametri
                                WHERE     valore = p_codice_amm
                                      AND tipo_modello = c_tipo_modello
                                      AND codice LIKE 'CODICE_AMM_' || '%');
      EXCEPTION
         WHEN OTHERS
         THEN
            d_suffisso := '';
      END;

      d_codice := d_codice || d_suffisso;

      set_valore(d_codice, p_tipo_modello, p_valore, p_note);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_valore (p_codice        IN PARAMETRI.CODICE%TYPE,
                        p_tipo_valore   IN PARAMETRI.TIPO_MODELLO%TYPE,
                        p_default       IN PARAMETRI.VALORE%TYPE DEFAULT '')
      /******************************************************************************
       NOME:        get_valore. A25585.
       DESCRIZIONE: Restituisce il valore identificato da p_codice, p_tipo_valore .
       PARAMETRI:   p_codice: il codice sulla tabella parametri
                    p_tipo_valore:    il tipo_modello sulla tabella parametri
       Rev.  Data        Autore   Descrizione.
       00    15/04/2008  SN       A26926.0.0 Inserita la return e modificata la gestione
                                  delle exception.
      ******************************************************************************/
      RETURN PARAMETRI.VALORE%TYPE
   IS
      retval   parametri.valore%TYPE;
   BEGIN
      SELECT valore
        INTO retval
        FROM parametri
       WHERE codice = p_codice AND tipo_modello = p_tipo_valore;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN p_default;
   END;

   FUNCTION get_valore (p_codice         IN PARAMETRI.CODICE%TYPE,
                        p_codice_amm     IN VARCHAR2,
                        p_codice_aoo     IN VARCHAR2,
                        p_default        IN PARAMETRI.VALORE%TYPE,
                        p_tipo_modello   IN VARCHAR2 DEFAULT c_tipo_modello)
      /******************************************************************************
       NOME:        get_valore.
       DESCRIZIONE: Restituisce il valore identificato da p_codice.
                    Consente di gestire personalizzazioni.
       PARAMETRI:   p_codice:      codice sulla tabella parametri
                    p_codice_amm:  codice dell'amministrazione corrente
                    p_codice_aoo:  codice dell'aoo attiva
                    p_default:     valore del parametro da restituire in caso di exception
        Rev.  Data        Autore   Descrizione.
        00    08/04/2008  SN       A26822.0.0. Prima emissione.
      ******************************************************************************/
      RETURN PARAMETRI.VALORE%TYPE
   IS
      retval       parametri.valore%TYPE;
      dep_codice   VARCHAR2 (1000) := p_codice;
   BEGIN
      IF SUBSTR (dep_codice, -1) != '_'
      THEN
         dep_codice := dep_codice || '_';
      END IF;

      SELECT valore
        INTO retval
        FROM parametri
       WHERE     tipo_modello = p_tipo_modello
             AND codice =
                       dep_codice
                    || (SELECT SUBSTR (codice,
                                       DECODE (INSTR (codice,
                                                      '_',
                                                      1,
                                                      2),
                                               0, TO_NUMBER (NULL),
                                               (  INSTR (codice,
                                                         '_',
                                                         1,
                                                         2)
                                                + 1)),
                                       LENGTH (codice))
                          FROM parametri
                         WHERE     valore = p_codice_aoo
                               AND tipo_modello = c_tipo_modello
                               AND codice IN (SELECT    'CODICE_AOO_'
                                                     || SUBSTR (
                                                           codice,
                                                           DECODE (
                                                              INSTR (codice,
                                                                     '_',
                                                                     1,
                                                                     2),
                                                              0, TO_NUMBER (
                                                                    NULL),
                                                              (  INSTR (
                                                                    codice,
                                                                    '_',
                                                                    1,
                                                                    2)
                                                               + 1)),
                                                           LENGTH (codice))
                                                FROM parametri
                                               WHERE     valore =
                                                            p_codice_amm
                                                     AND tipo_modello =
                                                            c_tipo_modello
                                                     AND codice LIKE
                                                               'CODICE_AMM_'
                                                            || '%'));

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN p_default;
   END;

   FUNCTION get_all_strut_parameters
      /******************************************************************************
       NOME:        get_all_strut_parameters.
       DESCRIZIONE: Restituisce un ref_cursor con i valori di tutti i
                    parametri aventi tipo_modello = @agStrut@.

       PARAMETRI:
        Rev.  Data        Autore   Descrizione.
         001 08/09/2008   SN        Creazione.
      ******************************************************************************/
      RETURN AFC.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT codice, valore, tipo_modello
           FROM parametri
          WHERE     tipo_modello = '@agStrut@'
                AND codice NOT LIKE '%PWD%'
                AND codice NOT LIKE '%PSW%'
                AND codice NOT LIKE '%PASSWORD%';

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_parametro.get_all_strut_parameters: ' || SQLERRM);
   END;

   FUNCTION get_all_sped_parameters
      /******************************************************************************
       NOME:        get_all_sped_parameters.
       DESCRIZIONE: Restituisce un ref_cursor con i valori di tutti i
                    parametri aventi tipo_modello = @agSped@.

       PARAMETRI:
        Rev.  Data        Autore   Descrizione.
         001 02/11/2011   MMur        Creazione.
      ******************************************************************************/
      RETURN AFC.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT parametri.codice, parametri.valore
           FROM parametri
          WHERE parametri.tipo_modello = '@agSped@';

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_parametro.get_all_sped_parameters: ' || SQLERRM);
   END;

   FUNCTION get_all_ag_parameters/******************************************************************************
                                  NOME:        get_all_ag_parameters.
                                  DESCRIZIONE: Restituisce un ref_cursor con i valori di tutti i
                                               parametri aventi tipo_modello = @agStrut@, @agVar@, @STANDARD@

                                  PARAMETRI:
                                   Rev.  Data        Autore   Descrizione.
                                   002   26/02/2015   MMAL    Creazione.
                                 ******************************************************************************/
   (p_codice_amm IN VARCHAR2, p_codice_aoo IN VARCHAR2)
      RETURN AFC.t_ref_cursor
   IS
      d_result   afc.t_ref_cursor;
   BEGIN
      OPEN d_result FOR
         SELECT codice, valore, tipo_modello
           FROM parametri
          WHERE     tipo_modello = '@agStrut@'
                AND codice NOT LIKE '%PWD%'
                AND codice NOT LIKE '%PSW%'
                AND codice NOT LIKE '%PASSWORD%'
         UNION
         SELECT SUBSTR (codice, 1, LENGTH (codice) - 2), valore, tipo_modello
           FROM parametri
          WHERE     tipo_modello = '@agVar@'
                AND codice NOT LIKE '%PWD%'
                AND (   codice NOT LIKE '%PSW%'
                     OR SUBSTR (codice, 1, LENGTH (codice) - 2) =
                           'PARIX_WS_PSW'
                           OR SUBSTR (codice, 1, LENGTH (codice) - 2) =
                           'ANAG_POPOLAZIONE_WS_PSW' )
                AND codice NOT LIKE '%PASSWORD%'
                AND SUBSTR (codice, -1, 1) IN (SELECT SUBSTR (
                                                         codice,
                                                         DECODE (
                                                            INSTR (codice,
                                                                   '_',
                                                                   1,
                                                                   2),
                                                            0, TO_NUMBER (
                                                                  NULL),
                                                            (  INSTR (codice,
                                                                      '_',
                                                                      1,
                                                                      2)
                                                             + 1)),
                                                         LENGTH (codice))
                                                 FROM parametri
                                                WHERE     valore =
                                                             p_codice_aoo
                                                      AND tipo_modello =
                                                             '@agVar@'
                                                      AND codice IN (SELECT    'CODICE_AOO_'
                                                                            || SUBSTR (
                                                                                  codice,
                                                                                  DECODE (
                                                                                     INSTR (
                                                                                        codice,
                                                                                        '_',
                                                                                        1,
                                                                                        2),
                                                                                     0, TO_NUMBER (
                                                                                           NULL),
                                                                                     (  INSTR (
                                                                                           codice,
                                                                                           '_',
                                                                                           1,
                                                                                           2)
                                                                                      + 1)),
                                                                                  LENGTH (
                                                                                     codice))
                                                                       FROM parametri
                                                                      WHERE     valore =
                                                                                   p_codice_amm
                                                                            AND tipo_modello =
                                                                                   '@agVar@'
                                                                            AND codice LIKE
                                                                                      'CODICE_AMM_'
                                                                                   || '%'))
         UNION
         SELECT codice, valore, tipo_modello
           FROM parametri
          WHERE     tipo_modello = '@agViewer@'
                AND codice NOT LIKE '%PWD%'
                AND codice NOT LIKE '%PSW%'
                AND codice NOT LIKE '%PASSWORD%'
         UNION
         SELECT codice, valore, tipo_modello
           FROM parametri
          WHERE     tipo_modello = '@ag@'
                AND codice NOT LIKE '%PWD%'
                AND codice NOT LIKE '%PSW%'
                AND codice NOT LIKE '%PASSWORD%'
         UNION
         SELECT codice, valore, tipo_modello
           FROM parametri
          WHERE     tipo_modello = '@STANDARD'
                AND codice NOT LIKE '%PWD%'
                AND codice NOT LIKE '%PSW%'
                AND codice NOT LIKE '%PASSWORD%';

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'ag_parametro.get_all_doc_parameters: ' || SQLERRM);
   END;

   PROCEDURE del (p_codice       IN PARAMETRI.CODICE%TYPE,
                  p_tipo_valore  IN PARAMETRI.TIPO_MODELLO%TYPE)
   IS
   BEGIN
      delete parametri
       WHERE codice = p_codice AND tipo_modello = p_tipo_valore;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;
END;
/
