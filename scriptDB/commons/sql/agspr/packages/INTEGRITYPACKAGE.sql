--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_INTEGRITYPACKAGE runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE integritypackage
/******************************************************************************
 NOME:        IntegrityPackage
 DESCRIZIONE: Oggetti per la gestione della Integrita Referenziale.
              Contiene le Procedure e function per la gestione del livello di
              annidamento dei trigger.
              Contiene le Procedure per il POSTING degli script alla fase di
              AFTER STATEMENT.
 REVISIONI:
 Rev. Data        Autore  Descrizione
 ---- ----------  ------  ----------------------------------------------------
 01    23/01/2001  MF      Inserimento commento.
 02    04/12/2002  SN      In caso di errore visualizza lo statement
 03    22/12/2003  SN      Rilevamento errore in caso di select
                          Sistemazione frase in base a default stabiliti.
 04    10/05/2004  SN      Se errore 20999 non si visualizza lo statement a
                          meno che non sia stata settata la variabile debug a 1.
 05    20/12/2004  SN      Se errore non compreso fra 20000 e 20999 non visualizza
                          lo statement a meno che debug sia = 1.
 06    04/08/2005  SN      Gestione di integrityerror.
 07    26/08/2005  SN      Sistemazione messaggio di errore
 08    12/10/2005  SN      Errore rimappato attraverso si4.get_error
 09    21/10/2005  SN      Modificato controllo errore
 10    30/08/2006  FT      Modifica dichiarazione subtype per incompatibilit¿ con
                           versione 7 di Oracle
 11    04/12/2008  MM      Creazione procedure log.
 12    20/03/2009  MM      Creazione procedure log con parametro clob.
 NOTA: In futuro verra tolta la substr nella SISTEMA MESSAGGIO quando verra
 rilasciata una versione di ad4 che lo consenta.
******************************************************************************/
AS
   d_revision       VARCHAR2 (30);

   SUBTYPE t_revision IS d_revision%TYPE;

   s_revisione      t_revision := 'V1.12';

   FUNCTION versione
      RETURN t_revision;

   -- Variabili per SET Switched FUNCTIONAL Integrity
   functional       BOOLEAN := TRUE;
   integrityerror   EXCEPTION;

   PROCEDURE setdebugon;

   PROCEDURE setdebugoff;

   -- Procedure for Referential Integrity
   PROCEDURE setfunctional;

   PROCEDURE resetfunctional;

   PROCEDURE initnestlevel;

   FUNCTION getnestlevel
      RETURN NUMBER;

   PROCEDURE nextnestlevel;

   PROCEDURE previousnestlevel;

   /* Variabili e Procedure per IR su Relazioni Ricorsive */
   TYPE t_operazione IS TABLE OF VARCHAR2 (32000)
      INDEX BY BINARY_INTEGER;

   TYPE t_messaggio IS TABLE OF VARCHAR2 (2000)
      INDEX BY BINARY_INTEGER;

   d_istruzione     t_operazione;
   d_messaggio      t_messaggio;
   d_entry          BINARY_INTEGER := 0;

   PROCEDURE set_postevent (p_istruzione   IN VARCHAR2,
                            p_messaggio    IN VARCHAR2);

   PROCEDURE exec_postevent;

   /******************************************************************************
    DESCRIZIONE: Esegue gli statement precedentemente impostati.
                 Se inizia con:
                 SELECT: toglie eventuale ';' in fondo
                 :=    : si suppone segua la chiamata ad una funzione, viene
                         dichiarata una variabile e le si assegna il ritorno
                 in caso di stringa diversa mette il codice fra begin e end
    ******************************************************************************/
   PROCEDURE LOG (p_log IN VARCHAR2);

   PROCEDURE LOG (p_log IN CLOB);
END integritypackage;
/* End Package: IntegrityPackage
   N.B.: In caso di "Generate Trigger" successive alla prima
         IGNORARE Errore di Package gia presente
*/
/
CREATE OR REPLACE PACKAGE BODY integritypackage
/******************************************************************************
 NOME:        IntegrityPackage
 DESCRIZIONE: Oggetti per la gestione della Integrita Referenziale.
              Contiene le Procedure e function per la gestione del livello di
              annidamento dei trigger.
              Contiene le Procedure per il POSTING degli script alla fase di
              AFTER STATEMENT.
 REVISIONI:
 Rev. Data        Autore  Descrizione
 ---- ----------  ------  ----------------------------------------------------
 1    23/01/2001  MF      Inserimento commento.
 2    04/12/2002  SN      In caso di errore visualizza lo statement
 3    22/12/2003  SN      Rilevamento errore in caso di select
                          Sistemazione frase in base a default stabiliti.
 4    10/05/2004  SN      Se errore 20999 non si visualizza lo statement a
                          meno che non sia stata settata la variabile debug a 1.
 5    20/12/2004  SN      Se errore non compreso fra 20000 e 20999 non visualizza
                          lo statement a meno che debug sia = 1.
 6    04/08/2005  SN      Gestione di integrityerror.
 7    26/08/2005  SN      Sistemazione messaggio di errore
 8    12/10/2005  SN      Errore rimappato attraverso si4.get_error
 9    21/10/2005  SN      Modificato controllo errore
 10   07/03/2006  SN      Controllo dinamico si4_get error e sistemata versione
 11   30/08/2006  FT      Modifica dichiarazione subtype per incompatibilit¿ con
                          versione 7 di Oracle
 12   14/09/2006  FT      In exec_postevent: inserita inizializzazione del nestlevel
                          anche in caso di exception; corretta memorizzazione numero di
                          righe processate
 13   29/11/2006  FT      Modificata inizializzazione (a 0) del flag debug
 14   04/12/2008  MM      Creazione procedure log.
 15   04/12/2008  MM      Creazione procedure log con parametro clob.
 NOTA: In futuro verra tolta la substr nella SISTEMA MESSAGGIO quando verra
 rilasciata una versione di ad4 che lo consenta.
******************************************************************************/
AS
   nestlevel          PLS_INTEGER;
   -- Variabile da valorizzare a 1 per visualizzare l'istruzione
   -- che genera errore in ExecPostEvent anche se con errore user defined (20999)
   debug              PLS_INTEGER := 0;
   d_lungo            VARCHAR2 (32767);

   SUBTYPE t_lungo IS d_lungo%TYPE;

   s_revisione_body   t_revision := '015';

   FUNCTION versione
      RETURN t_revision
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
      RETURN s_revisione || '.' || s_revisione_body;
   END versione;

   PROCEDURE setdebugon
   IS
   BEGIN
      debug := 1;
   END;

   PROCEDURE setdebugoff
   IS
   BEGIN
      debug := 0;
   END;

   PROCEDURE sistema_messaggio_errore (p_errore        IN     VARCHAR2,
                                       p_actual_istr   IN     VARCHAR2,
                                       p_messaggio        OUT VARCHAR2,
                                       p_codice           OUT VARCHAR2)
   /***********************************************************************************
   NOME:        sistema_messaggio_errore
   DESCRIZIONE: Esecuzione istruzioni memorizzate in POST Statement.
   ARGOMENTI:   p_errore     : errore rilevato in esecuzione dello statement
                p_actual_istr: istruzione che ha generato l'errore
                p_messaggio  : messaggio di errore da visualizzare
                p_codice     :    numero di errore da visualizzare
   REVISIONI:
   Rev. Data       Autore Descrizione
   ---- ---------- ------ ------------------------------------------------------------
   10   07/03/2006  SN    In caso di errore decide quale numero di errore visualizzare
                          e quale messaggio.
                          Se l'errore e user-defined quindi tra -20000 e -20999  si
                          comporta in modo diverso a seconda che sia attivo o meno
                          il debug:
                          1)debug attivo: visualizza statement che ha causato l'errore.
                          2)debug inattivo: visualizza solo il messaggio di errore
                          Se l'errore intercettato e generato direttamente da Oracle
                          si pensa che fosse non voluto e viene sempre visualizzato
                          lo statement che lo ha generato indipendentemente da come
                          il debug e settato.
                          Se durante l'errore viene scatenato un integrity error lo
                          statement non viene mai visualizzato indipendentemente da
                          come il debug e settato.
  ************************************************************************************/
   IS
      d_errore                t_lungo := p_errore;
      d_ultima_parte_errore   t_lungo;
      d_err_user_defined      BOOLEAN := FALSE;
   BEGIN
      d_errore := REPLACE (d_errore, 'ORA-', 'ora-');

      IF SUBSTR (d_errore, INSTR (d_errore, 'ora-') + 4, 2) = '20'
      THEN
         d_err_user_defined := TRUE;
         -- se user defined ributto fuori lo stesso numero di errore
         p_codice := SUBSTR (d_errore, INSTR (d_errore, 'ora') + 3, 6);
      END IF;

      DECLARE
         CURSOR c_esiste_pac
         IS
            SELECT 1 esiste
              FROM all_arguments
             WHERE     package_name = 'SI4'
                   AND owner = USER
                   AND position = 1
                   AND object_name = 'GET_ERROR';

         d_esiste_pac   c_esiste_pac%ROWTYPE;
      BEGIN
         OPEN c_esiste_pac;

         FETCH c_esiste_pac INTO d_esiste_pac;

         IF c_esiste_pac%FOUND AND d_esiste_pac.esiste = 1
         THEN
            -- sistema d_errore ricaricandolo con sql dinamico
            DECLARE
               cursor_name      INTEGER;
               rows_processed   INTEGER;
               d_ritorno        t_lungo;
            BEGIN
               cursor_name := DBMS_SQL.open_cursor;
               DBMS_SQL.parse (
                  cursor_name,
                     'select si4.get_error('''
                  || REPLACE (p_errore, '''', '''''')
                  || ''') from dual',
                  DBMS_SQL.native);
               DBMS_SQL.define_column (cursor_name,
                                       1,
                                       d_ritorno,
                                       32000);
               rows_processed := DBMS_SQL.execute (cursor_name);

               --esecuzione istruzione e controllo errore
               IF DBMS_SQL.fetch_rows (cursor_name) > 0
               THEN
                  DBMS_SQL.COLUMN_VALUE (cursor_name, 1, d_ritorno);
                  d_errore := d_ritorno;
               -- dinamico = si4.get_error(p_errore);
               END IF;

               DBMS_SQL.close_cursor (cursor_name);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_SQL.close_cursor (cursor_name);
                  RAISE;
            END;
         END IF;

         CLOSE c_esiste_pac;
      END;

      d_errore := REPLACE (d_errore, 'ORA-', 'ora-');
      initnestlevel;
      p_messaggio := NULL;

      -- se user defined visualizzo l'istruzione solo se debug = 1
      -- altrimenti sempre visualizzata istruzione
      IF d_err_user_defined
      THEN         -- se user defined ributto fuori lo stesso numero di errore
         IF INSTR (d_errore, 'ora') = 1            -- inizia con codice errore
         THEN
            d_errore := SUBSTR (d_errore, 11);
         END IF;

         IF INSTR (d_errore, 'ora-') > 0
         THEN
            d_ultima_parte_errore :=
               SUBSTR (d_errore, INSTR (d_errore, 'ora-'));
            d_errore :=
               RTRIM (SUBSTR (d_errore, 1, INSTR (d_errore, 'ora-') - 1),
                      CHR (10));
         END IF;
      ELSE                                                 -- non user defined
         p_codice := -20999;
      END IF;

      p_messaggio := d_errore || CHR (10);

      IF NOT d_err_user_defined OR debug = 1
      THEN   -- se non user defined o debug attivo visualizzo anche istruzione
         p_messaggio := p_messaggio || 'ISTRUZIONE :' || p_actual_istr;
      END IF;

      p_messaggio := p_messaggio || CHR (10) || d_ultima_parte_errore;
      -- vincolo in powerbuilder messaggio minore di 200 caratteri
      p_messaggio := SUBSTR (p_messaggio, 1, 200) || '...';
   END sistema_messaggio_errore;

   -- Procedure to Initialize Switched Functional Integrity
   PROCEDURE setfunctional
   IS
   BEGIN
      functional := TRUE;
   END;

   -- Procedure to Reset Switched Functional Integrity
   PROCEDURE resetfunctional
   IS
   BEGIN
      functional := FALSE;
   END;

   -- Procedure to initialize the trigger nest level
   PROCEDURE initnestlevel
   IS
   BEGIN
      nestlevel := 0;
      d_entry := 0;
   END;

   -- Function to return the trigger nest level
   FUNCTION getnestlevel
      RETURN NUMBER
   IS
   BEGIN
      IF nestlevel IS NULL
      THEN
         nestlevel := 0;
      END IF;

      RETURN (nestlevel);
   END;

   -- Procedure to increase the trigger nest level
   PROCEDURE nextnestlevel
   IS
   BEGIN
      IF nestlevel IS NULL
      THEN
         nestlevel := 0;
      END IF;

      nestlevel := nestlevel + 1;
   END;

   -- Procedure to decrease the trigger nest level
   PROCEDURE previousnestlevel
   IS
   BEGIN
      nestlevel := nestlevel - 1;
   END;

   -- Procedure Memorizzazione istruzioni da attivare in POST statement
   PROCEDURE set_postevent/******************************************************************************
                           NOME:        Set_PostEvent
                           DESCRIZIONE: Memorizzazione istruzioni da attivare in POST statement.
                           ARGOMENTI:   a_istruzione VARCHAR2 Istruzione SQL da memorizzare.
                                        a_messaggio  VARCHAR2 Messaggio da inviare per errore in esecuzione.
                           REVISIONI:
                           Rev. Data       Autore Descrizione
                           ---- ---------- ------ ------------------------------------------------------
                           1    23/01/2001  MF    Inserimento commento.
                          ******************************************************************************/
   (p_istruzione IN VARCHAR2, p_messaggio IN VARCHAR2)
   IS
      actual_level   PLS_INTEGER;
   BEGIN
      actual_level := integritypackage.getnestlevel;
      d_entry := d_entry + 1;
      d_istruzione (d_entry) := p_istruzione;
      d_messaggio (d_entry) := LPAD (actual_level, 2, '0') || p_messaggio;
   END set_postevent;

   -- Procedure Esecuzione istruzioni memorizzate in POST Statement
   PROCEDURE exec_postevent
   /***********************************************************************************
    NOME:        Exec_PostEvent
    DESCRIZIONE: Esecuzione istruzioni memorizzate in POST Statement.
    ARGOMENTI:   -
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------------
    1    23/01/2001  MF    Inserimento commento.
    2    04/12/2002  SN    In caso di errore visualizza lo statement
    3    22/12/2003  SN    Rilevamento errore in caso di select
                           Sistemazione frase in base a default stabiliti.
    4    10/05/2004  SN    Modificato ExecPostEvent per gestione errore 20999
                           e visualizzazione statement solo se variabile debug a 1.
                           Usati solo 200 caratteri per messaggio di errore altrimenti
                           problemi durante la visualizzazione in PB (x lo standard).
    10   31/10/2005  SN    Tolta substr del messaggio di errore a 200 caratteri.
    12   14/09/2006  FT    In exec_postevent: inserita inizializzazione del nestlevel
                           anche in caso di exception; corretta memorizzazione numero di
                           righe processate
   ************************************************************************************/
   IS
      cursor_id         PLS_INTEGER;
      rows_processed    PLS_INTEGER;
      actual_level      PLS_INTEGER;
      element_level     PLS_INTEGER;
      element_message   VARCHAR2 (2000);
      d_actual_istr     t_lungo;
      d_ritorno         t_lungo;
      d_messaggio_out   t_lungo;
      d_codice_out      NUMBER (10);
   BEGIN
      actual_level := integritypackage.getnestlevel;

      FOR loopcnt IN 1 .. d_entry
      LOOP
         element_level := TO_NUMBER (SUBSTR (d_messaggio (loopcnt), 1, 2));

         IF     element_level = actual_level
            AND d_istruzione (loopcnt) IS NOT NULL
         THEN
            integritypackage.nextnestlevel;

            BEGIN
               d_actual_istr := d_istruzione (loopcnt);
               cursor_id := DBMS_SQL.open_cursor;

               BEGIN
                  -- controllo ed eventuale  modifica statement
                  IF UPPER (SUBSTR (LTRIM (d_istruzione (loopcnt)), 1, 6)) =
                        'SELECT'
                  THEN
                     d_istruzione (loopcnt) :=
                        RTRIM (d_istruzione (loopcnt), ' ;');
                  ELSE                                           -- non select
                     --se non ci sono mettere begin e end
                     IF UPPER (SUBSTR (LTRIM (d_istruzione (loopcnt)), 1, 2)) =
                           ':='
                     THEN
                        -- AGGIUNGO LA GESTIONE DEL RITORNO
                        d_istruzione (loopcnt) :=
                              'DECLARE d_RITORNO VARCHAR2(32000);'
                           || 'BEGIN d_RITORNO'
                           || RTRIM (d_istruzione (loopcnt), ' ;')
                           || '; END;';
                     ELSIF UPPER (
                              SUBSTR (LTRIM (d_istruzione (loopcnt)), 1, 5)) !=
                              'BEGIN'
                     THEN
                        -- in caso di declare mette un altro begin end esterno
                        d_istruzione (loopcnt) :=
                              'BEGIN '
                           || RTRIM (d_istruzione (loopcnt), ' ;')
                           || '; END;';
                     END IF;
                  END IF;

                  -- controllo sintattico istruzione
                  -- Tolta andata a capo chr(13) || chr(10) altrimenti
                  -- errore inspiegabile se presente... dice che la sintassi
                  -- e sbagliata
                  DBMS_SQL.parse (
                     cursor_id,
                     REPLACE (d_istruzione (loopcnt),
                              CHR (13) || CHR (10),
                              ' '),
                     DBMS_SQL.native);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     sistema_messaggio_errore (SQLERRM,
                                               d_actual_istr,
                                               d_messaggio_out,
                                               d_codice_out);

                     IF d_messaggio_out IS NOT NULL
                     THEN
                        raise_application_error (d_codice_out,
                                                 d_messaggio_out);
                     ELSE
                        RAISE;
                     END IF;
               END;

               IF UPPER (SUBSTR (LTRIM (d_istruzione (loopcnt)), 1, 6)) =
                     'SELECT'
               THEN
                  BEGIN             --esecuzione istruzione e controllo errore
                     -- definizione della colonna. Serve per riuscire ad
                     -- intercettare gli errori ORA-
                     -- non importa effettivamente caricare il valore
                     DBMS_SQL.define_column (cursor_id,
                                             1,
                                             d_ritorno,
                                             32000);
                     --esecuzione istruzione e controllo errore
                     rows_processed := DBMS_SQL.execute (cursor_id);

                     IF DBMS_SQL.fetch_rows (cursor_id) > 0
                     THEN
                        rows_processed := 1;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        sistema_messaggio_errore (SQLERRM,
                                                  d_actual_istr,
                                                  d_messaggio_out,
                                                  d_codice_out);

                        IF d_messaggio_out IS NOT NULL
                        THEN
                           raise_application_error (d_codice_out,
                                                    d_messaggio_out);
                        ELSE
                           RAISE;
                        END IF;
                  END;

                  IF     rows_processed > 0
                     AND SUBSTR (
                            LTRIM (
                               SUBSTR (LTRIM (d_istruzione (loopcnt)), 7)),
                            1,
                            1) = '0'
                  THEN
                     element_message := SUBSTR (d_messaggio (loopcnt), 3);

                     IF element_message IS NULL
                     THEN
                        element_message :=
                           'Sono presenti registrazioni collegate. Operazione non eseguita.';
                     END IF;

                     raise_application_error (-20008, element_message);
                  ELSIF     rows_processed = 0
                        AND SUBSTR (
                               LTRIM (
                                  SUBSTR (LTRIM (d_istruzione (loopcnt)), 7)),
                               1,
                               1) != '0'
                  THEN
                     element_message := SUBSTR (d_messaggio (loopcnt), 3);

                     IF element_message IS NULL
                     THEN
                        element_message :=
                           'Non e'' presente la registrazione richiesta. Operazione non eseguita.';
                     END IF;

                     raise_application_error (-20008, element_message);
                  END IF;
               ELSE                                 -- non statement di SELECT
                  BEGIN
                     rows_processed := DBMS_SQL.execute (cursor_id);
                  EXCEPTION
                     WHEN integrityerror
                     THEN
                        raise_application_error (
                           -20999,
                           SUBSTR (d_messaggio (loopcnt), 3));
                     WHEN OTHERS
                     THEN
                        -- per evitare problemi con PB e la gestione errori scrivo minuscolo
                        sistema_messaggio_errore (SQLERRM,
                                                  d_actual_istr,
                                                  d_messaggio_out,
                                                  d_codice_out);

                        IF d_messaggio_out IS NOT NULL
                        THEN
                           raise_application_error (d_codice_out,
                                                    d_messaggio_out);
                        ELSE
                           RAISE;
                        END IF;
                  END;
               END IF;

               DBMS_SQL.close_cursor (cursor_id);
            END;

            integritypackage.previousnestlevel;
            d_istruzione (loopcnt) := NULL;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         integritypackage.initnestlevel;
         RAISE;
   END exec_postevent;

   PROCEDURE LOG/***********************************************************************************
                NOME:        log
                DESCRIZIONE: Emissione log se previsto debug (debug = 1).
                ARGOMENTI:   p_log: messaggio da visualizzare
                REVISIONI:
                Rev. Data       Autore Descrizione
                ---- ---------- ------ ------------------------------------------------------------
                14   04/12/2008 MM     Creazione.
               ************************************************************************************/
   (p_log IN VARCHAR2)
   IS
      d_max   INTEGER := 250;
   BEGIN
      IF debug = 1
      THEN
         IF NVL (LENGTH (p_log), 0) <= d_max
         THEN
            DBMS_OUTPUT.put_line (p_log);
         ELSE
            DECLARE
               i          INTEGER;
               d_inizio   INTEGER;
               d_loop     INTEGER := CEIL (LENGTH (p_log) / d_max);
            BEGIN
               FOR i IN 1 .. d_loop
               LOOP
                  d_inizio := ( (i - 1) * d_max) + 1;
                  DBMS_OUTPUT.put_line (SUBSTR (p_log, d_inizio, d_max));
               END LOOP;
            END;
         END IF;
      END IF;
   END LOG;

   PROCEDURE LOG/***********************************************************************************
                NOME:        log
                DESCRIZIONE: Emissione log se previsto debug (debug = 1).
                ARGOMENTI:   p_log: messaggio da visualizzare
                REVISIONI:
                Rev. Data       Autore Descrizione
                ---- ---------- ------ ------------------------------------------------------------
                15   20/03/2009 MM     Creazione.
               ************************************************************************************/
   (p_log IN CLOB)
   IS
      d_max   INTEGER := 250;
      d_log   VARCHAR2 (32767);
   BEGIN
      IF DBMS_LOB.GETLENGTH (p_log) > 32767
      THEN
         d_log := DBMS_LOB.SUBSTR (p_log, 32000, 1);
         d_log := d_log || '...';
      END IF;

      LOG (d_log);
   END LOG;
END integritypackage;
/
