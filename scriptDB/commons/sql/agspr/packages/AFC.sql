--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AFC runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AFC
IS
   /******************************************************************************
    NOME:        AFC
    DESCRIZIONE: Procedure e Funzioni di utilita' comune.
    ANNOTAZIONI: -
    REVISIONI:
    Rev.  Data        Autore  Descrizione
    ----  ----------  ------  ----------------------------------------------------
    00    20/01/2003  MM      Prima emissione.
    01    18/03/2005  MF      Adozione nello Standard AFC (nessuna modifica).
    02    26/04/2005  CZ      Aggiunte to_boolean e xor
    03    14/06/2005  MM      Creazione GET_SUBSTR ( p_stringa    IN  varchar2
                                                   , p_separatore IN  varchar2
                                                   , p_occorrenza IN  varchar2
                                                   )
    04    01/09/2005  FT      Aggiunta dei metodi protect_wildcard, version
                              aggiunta dei subtype t_object_name, t_message,
                              t_statement, t_revision
    05    27/09/2005  MF      Cambio nomenclatura s_revisione e s_revisione_body.
                              Tolta dipendenza get_stringParm da Package Si4.
    06    24/11/2005  FT      Aggiunta di mxor
    07    04/01/2006  MM      Aggiunta is_number
    08    12/01/2006  MM      Aggiunta is_numeric e to_number(p_value in varchar2)
    09    01/02/2006  FT      Aumento di parametri per mxor
    10    22/02/2006  FT      Aggiunta dei metodi get_field_condition e decode_value
                              e del type t_ref_cursor
    11    02/03/2006  FT      Aggiunta della function SQL_execute
    12    21/03/2006  MF      Get_filed_condition: Introdotto prefix e suffix.
    13    19/05/2006  FT      Aggiunta metodo to_clob
    14    25/06/2006  MF      Parametro in to_clob per ottenere empty in caso di null.
    15    28/06/2006  FT      Aggiunta funzione date_format e parametro p_date_format
                              in get_field_condition
    16    30/08/2006  FT      Modifica dichiarazione subtype per incompatibilit¿ con
                              versione 7 di Oracle; eliminazione della funzione to_clob
    17    19/10/2006  FT      Aggiunta funzione quote
    18    30/10/2006  FT      Aggiunta funzione countOccurrenceOf
    19    21/12/2006  FT      Aggiunta funzione init_cronologia
    20    27/02/2007  FT      Spostata funzione init_cronologia nel package SI4
    21    14/03/2007  FT      Aggiunta overloading di get_field_condition per
                              p_field_value di tipo DATE
    22    06/04/2009  MF      Aggiunte funzioni di "default_null".
   ******************************************************************************/
   d_revision      VARCHAR2 (30);

   SUBTYPE t_revision IS d_revision%TYPE;

   d_object_name   VARCHAR2 (30);

   SUBTYPE t_object_name IS d_object_name%TYPE;

   d_message       VARCHAR2 (1000);

   SUBTYPE t_message IS d_message%TYPE;

   d_statement     VARCHAR2 (32000);

   SUBTYPE t_statement IS d_statement%TYPE;

   TYPE t_ref_cursor IS REF CURSOR;

   s_revisione     t_revision := 'V1.22';

   FUNCTION versione
      RETURN t_revision;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS, WNPS);

   FUNCTION version (p_revisione t_revision, p_revisione_body t_revision)
      RETURN t_revision;

   PRAGMA RESTRICT_REFERENCES (version, WNDS, WNPS);

   -- Memorizza nome item per gestione "default_null".
   PROCEDURE default_null (p_item_name IN VARCHAR2 DEFAULT NULL);

   -- Ritorna valore NULL per inizializzazione default value e
   -- memorizza nome item per gestione "default_null".
   FUNCTION default_null (p_item_name IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   -- Ritorna 1 se nome item ¿ stato valorizzato gestione "default_null".
   FUNCTION is_default_null (p_item_name IN VARCHAR2)
      RETURN NUMBER;

   -- Ottiene la stringa precedente alla stringa di separazione, modificando
   -- la stringa di partenza con la parte seguente, escludendo la stringa di
   -- separazione
   FUNCTION get_substr (p_stringa IN OUT VARCHAR2, p_separatore IN VARCHAR2)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (get_substr, WNDS);

   FUNCTION get_substr (p_stringa      IN VARCHAR2,
                        p_separatore   IN VARCHAR2,
                        p_occorrenza   IN VARCHAR2)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (get_substr, WNDS);

   -- Estrapola un Parametro da una Stringa
   FUNCTION get_stringParm (p_stringa          IN VARCHAR2,
                            p_identificativo   IN VARCHAR2)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (get_stringParm, WNDS);

   FUNCTION countOccurrenceOf (p_stringa        IN VARCHAR2,
                               p_sottostringa   IN VARCHAR2)
      RETURN NUMBER;

   -- Protezione dei caratteri speciali ('_' e '%') nella stringa p_stringa
   FUNCTION protect_wildcard (p_stringa IN VARCHAR2)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (protect_wildcard, WNDS);

   -- Gestione apici (aggiunta di quelli esterni e raddoppio di quelli interni)
   -- per la stringa p_stringa
   FUNCTION quote (p_stringa IN VARCHAR2)
      RETURN VARCHAR2;

   -- Cast number [0,1] => boolean [false, true]
   -- null arguments are NOT handled
   FUNCTION to_boolean (p_value IN NUMBER)
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (to_boolean, WNDS);

   -- Cast boolean [false, true] => number [0,1]
   -- null arguments are NOT handled
   FUNCTION TO_NUMBER (p_value IN BOOLEAN)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (TO_NUMBER, WNDS);

   FUNCTION TO_NUMBER (p_value IN VARCHAR2)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (TO_NUMBER, WNDS);

   -- Esecuzione istruzione dinamica
   PROCEDURE SQL_execute (p_stringa t_statement);

   -- Esecuzione istruzione dinamica con valore di ritorno
   FUNCTION SQL_execute (p_stringa t_statement)
      RETURN VARCHAR2;

   -- Exclusive xor
   -- null arguments are NOT handled
   FUNCTION xor (p_value_1 IN BOOLEAN, p_value_2 IN BOOLEAN)
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (xor, WNDS);

   FUNCTION xor (p_value_1   IN BOOLEAN,
                 p_value_2   IN BOOLEAN,
                 p_value_3   IN BOOLEAN)
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (xor, WNDS);

   FUNCTION xor (p_value_1   IN BOOLEAN,
                 p_value_2   IN BOOLEAN,
                 p_value_3   IN BOOLEAN,
                 p_value_4   IN BOOLEAN)
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (xor, WNDS);

   -- Multiple xor
   FUNCTION mxor (p_value_1   IN BOOLEAN,
                  p_value_2   IN BOOLEAN,
                  p_value_3   IN BOOLEAN DEFAULT FALSE,
                  p_value_4   IN BOOLEAN DEFAULT FALSE,
                  p_value_5   IN BOOLEAN DEFAULT FALSE,
                  p_value_6   IN BOOLEAN DEFAULT FALSE,
                  p_value_7   IN BOOLEAN DEFAULT FALSE,
                  p_value_8   IN BOOLEAN DEFAULT FALSE)
      RETURN BOOLEAN;

   PRAGMA RESTRICT_REFERENCES (mxor, WNDS);

   -- Verifica che la stringa passata sia un numero
   FUNCTION is_number (p_char IN VARCHAR2)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (is_number, WNDS);

   -- Verifica che la stringa passata sia formata da soli numeri
   FUNCTION is_numeric (p_char IN VARCHAR2)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (is_numeric, WNDS);

   -- Ottiene stringa con condizione SQL
   FUNCTION get_field_condition (p_prefix        IN VARCHAR2,
                                 p_field_value   IN VARCHAR2,
                                 p_suffix        IN VARCHAR2,
                                 p_flag          IN NUMBER DEFAULT 0,
                                 p_date_format   IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   -- Ottiene stringa con condizione SQL
   -- overloading per p_field_condition di tipo DATE
   FUNCTION get_field_condition (p_prefix        IN VARCHAR2,
                                 p_field_value   IN DATE,
                                 p_suffix        IN VARCHAR2,
                                 p_flag          IN NUMBER DEFAULT 0,
                                 p_date_format   IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   -- Istruzione "decode" per PL/SQL
   FUNCTION decode_value (p_check_value     IN VARCHAR2,
                          p_against_value   IN VARCHAR2,
                          p_then_result     IN VARCHAR2,
                          p_else_result     IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION date_format
      RETURN VARCHAR2;
END AFC;
/
CREATE OR REPLACE PACKAGE BODY AFC
IS
   /******************************************************************************
    NOME:        AFC
    DESCRIZIONE: Procedure e Funzioni di utilita' comune.
    ANNOTAZIONI: -
    REVISIONI:
    Rev.  Data        Autore  Descrizione
    ----  ----------  ------  ----------------------------------------------------
    000   20/01/2003  MM      Prima emissione.
    001   26/04/2005  CZ      Aggiunte to_boolean e xor
    002   14/06/2005  MM      Introduzione funczione GET_SUBSTR
                              (p_stringa IN varchar2, p_separatore IN  varchar2
                              , p_occorrenza IN  varchar2).
    003   01/09/2005  FT      Aggiunta dei metodi protect_wildcard, version
                              aggiunta dei subtype t_object_name, t_message,
                              t_statement, t_revision
    004   27/09/2005  MF      Cambio nomenclatura s_revisione e s_revisione_body.
                              Tolta dipendenza get_stringParm da Package Si4.
                              Inserimento SQL_execute per istruzioni dinamiche.
    005   24/11/2005  FT      Aggiunta di mxor
    006   04/01/2006  MM      Aggiunta is_number
    007   12/01/2006  MM      Aggiunte is_numeric e to_number(p_value in varchar2),
                              corretta is_number, corretta get_substr in modo che
                              gestisca stringhe fino a 32000 caratteri.
    008   01/02/2006  FT      Aumento di parametri per mxor
    009   22/02/2006  FT      Aggiunta dei metodi get_field_condition e decode_value
    010   02/03/2006  FT      Aggiunta function SQL_execute
    011   21/03/2006  MF      get_filed_condition:
                              - Introdotto prefix e suffix
                              - return type t_statement
                              decode_value:
                              - return type t_statement
    012   26/04/2006  MM      Modifica get_stringParm.
    013   19/05/2006  FT      Aggiunta metodo to_clob
    014   25/06/2006  MF      Parametro in to_clob per ottenere empty in caso di null.
    015   28/06/2006  FT      Aggiunta function date_format; in get_field_condition,
                              modificata gestione di p_field_value (gestione di operatori
                              di default e scorporo dell'operatore da p_field_value)
                              e aggiunto parametro p_date_format
    016   30/08/2006  FT      Eliminazione della funzione to_clob
    017   04/09/2006  FT      Corretto get_field_condition: aggiunta di apici a p_field_value
                              in caso di 'like' implicito; controllo con 'lower' per caso di like
    018   05/09/2006  FT      Modificata gestione 'like' implicito e raddoppio apici singoli
                              in get_field_condition
    019   19/10/2006  FT      Aggiunta funzione quote
    020   30/10/2006  FT      Aggiunta funzione countOccurrenceOf
    021   21/12/2006  FT      Aggiunta funzione init_cronologia
    022   03/01/2007  FT      Modificata logica di gestione del flag in get_field_condition
                              per permettere di passare NULL e comportarsi come fosse il valore
                              di default
    023   27/02/2007  FT      Spostata funzione init_cronologia nel package SI4
    024   14/03/2007  FT      Aggiunta overloading di get_field_condition per p_field_value di tipo DATE
    025   09/01/2008  FT      get_field_condition: aggiunta possibilita di passare l'operatore
                              anche con p_flag = 0; modificata gestione DATE
    026   18/03/2008  FT      get_field_condition: aggiunta possibilita di cercare per like
                              su campi di tipo date
    027   08/10/2008  FT      get_field_condition: aggiunta degli operatori IN, BETWEEN,
                              EXISTS e NOT
    028   06/04/2009  MF      Aggiunte funzioni di "default_null".
    029   18/05/2008  MF      Variabile d_item_name di tipo t_statement in default_null e
                              is_default_null.
   ******************************************************************************/
   s_revisione_body             t_revision := '029';
   s_default_null               t_statement;
   s_default_null_object_name   t_object_name;

   --------------------------------------------------------------------------------
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
      RETURN version (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------
   FUNCTION version (p_revisione t_revision, p_revisione_body t_revision)
      RETURN t_revision
   IS
      /******************************************************************************
       NOME:        VERSION
       DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
       PARAMETRI:   p_revisione      revisione del Package specification.
                    p_revision_body  revisione del Package body.
       RITORNA:     stringa VARCHAR2 contenente versione e revisione.
       NOTE:        Primo numero  : versione compatibilita del Package.
                    Secondo numero: revisione del Package specification.
                    Terzo numero  : revisione del Package body.
      ******************************************************************************/
      d_result   VARCHAR2 (10);
   BEGIN
      d_result := p_revisione || '.' || p_revisione_body;
      RETURN d_result;
   END version;

   --------------------------------------------------------------------------------
   FUNCTION get_substr (p_stringa IN OUT VARCHAR2, p_separatore IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        GET_SUBSTR
       DESCRIZIONE: Ottiene la stringa precedente alla stringa di separazione, modificando
                    la stringa di partenza con la parte seguente, escludendo la stringa di
                    separazione.
       PARAMETRI:   p_stringa      Stringa da esaminare.
                    p_separatore   Stringa di separazione.
       RITORNA:     varchar2: se trovata stringa di separazione : la sottostringa;
                              se non trovata                    : la stringa originale.
                    Esempio:
                       da  stringa     ABCD.
                       con sub-stringa B.
                           ritorna A.
                           modificando l'originale in CD.
       ANNOTAZIONI: -
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       000   7/01/2003   MM      Prima emissione.
      ******************************************************************************/
      sStringa   VARCHAR2 (32000);
      iPos       INTEGER;
   BEGIN
      iPos := INSTR (p_stringa, p_separatore);

      IF iPos = 0
      THEN
         sStringa := p_stringa;
         p_stringa := '';
      ELSE
         sStringa := SUBSTR (p_stringa, 1, iPos - 1);
         p_stringa := SUBSTR (p_stringa, iPos + LENGTH (p_separatore));
      END IF;

      RETURN sStringa;
   END get_substr;

   --------------------------------------------------------------------------------
   FUNCTION get_substr (p_stringa      IN VARCHAR2,
                        p_separatore   IN VARCHAR2,
                        p_occorrenza   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        GET_SUBSTR
       DESCRIZIONE: Ottiene la stringa precedente alla stringa di separazione.
       PARAMETRI:   p_stringa      Stringa da esaminare.
                    p_separatore   Stringa di separazione.
                 p_occorrenza   P o U a seconda che si voglia considerare la Prima
                                o l'ultima occorrenza della stringa di separazione.
       RITORNA:     varchar2: se trovata stringa di separazione : la sottostringa;
                              se non trovata                    : la stringa originale.
       ANNOTAZIONI: -
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       000   14/04/2005  MM      Prima emissione.
      ******************************************************************************/
      sStringa   VARCHAR2 (32000);
      iPos       INTEGER;
      iOcc       INTEGER;
   BEGIN
      IF p_occorrenza = 'P'
      THEN
         iOcc := 1;
      ELSIF p_occorrenza = 'U'
      THEN
         iOcc := -1;
      ELSE
         iOcc := 1;
      END IF;

      iPos :=
         INSTR (p_stringa,
                p_separatore,
                iOcc,
                1);

      IF iPos = 0
      THEN
         sStringa := p_stringa;
      ELSE
         sStringa := SUBSTR (p_stringa, 1, iPos - 1);
      END IF;

      RETURN sStringa;
   END get_substr;

   --------------------------------------------------------------------------------
   FUNCTION get_stringParm (p_stringa          IN VARCHAR2,
                            p_identificativo   IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        GET_STRINGPARM.
       DESCRIZIONE: Estrapola un Parametro da una Stringa.
                    L'identificativo puo essere :
                           /x      seguito da " " (spazio) - Case sensitive.
                           -x      seguito da " " (spazio) - Case sensitive.
                           X      seguito da "=" (uguale) - Ignore Case.
                    Se il Parametro inizia con "'" (apice) o '"' (doppio apice)
                               viene estratto fino al prossimo apice o doppio apice;
                    altrimenti
                               viene estratto fino allo " " (spazio).
       PARAMETRI:   p_Stringa        varchar2 Valore contenente la stringa da esaminare.
                    p_Identificativo varchar2 Stringa identificativa del Parametro da estrarre.
       RITORNA:     varchar2: Valore del parametro estrapolato dalla stringa.
       ANNOTAZIONI: -
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       000   17/01/2003  MM      Prima emissione.
       004   27/09/2005  MF      Tolta dipendenza get_stringParm da Package Si4.
       012   26/04/2006  MM      (BO14061) Ritorna un risultato errato se il valore del
                                 parametro richiesto e nullo.
      ******************************************************************************/
      d_stringa     VARCHAR2 (2000);
      d_parametro   VARCHAR2 (2000);
      d_termine     VARCHAR2 (2000);
      d_pos         INTEGER;
   BEGIN
      d_stringa := LTRIM (RTRIM (p_stringa));

      IF SUBSTR (p_identificativo, 1, 1) IN ('/', '-')
      THEN
         d_parametro := p_identificativo;
         d_pos := INSTR (d_stringa, d_parametro);
      ELSE
         d_parametro := UPPER (p_identificativo) || '=';
         d_pos := INSTR (UPPER (d_stringa), d_parametro);
      END IF;

      IF d_pos = 0
      THEN
         RETURN '';
      ELSE
         d_pos := d_pos + LENGTH (d_parametro);
      END IF;

      d_stringa := RTRIM (SUBSTR (d_stringa, d_pos));

      -- Carattere finale determinato in funzione del carattere iniziale
      IF    SUBSTR (LTRIM (d_stringa), 1, 1) = ''''
         OR SUBSTR (LTRIM (d_stringa), 1, 1) = '"'
      THEN
         d_stringa := LTRIM (d_stringa);
         d_termine := SUBSTR (d_stringa, 1, 1);
         d_stringa := SUBSTR (d_stringa, 2);
      ELSE
         d_termine := ' ';
      END IF;

      d_stringa := GET_SUBSTR (d_stringa, d_termine);
      RETURN d_stringa;
   END get_stringParm;

   --------------------------------------------------------------------------------
   FUNCTION countOccurrenceOf (p_stringa        IN VARCHAR2,
                               p_sottostringa   IN VARCHAR2)
      RETURN NUMBER
   /******************************************************************************
    NOME:        countOccurrenceOf
    DESCRIZIONE: numero di occorrenze di p_sottostringa in p_stringa
    PARAMETRI:   p_stringa
                 p_sottostringa
    RITORNA:     varchar2
    NOTE:        -
   ******************************************************************************/
   IS
      d_result   INTEGER := 0;
      d_pos      INTEGER := 0;
   BEGIN
      d_pos := INSTR (p_stringa, p_sottostringa);

      WHILE d_pos > 0
      LOOP
         d_result := d_result + 1;
         d_pos := INSTR (p_stringa, p_sottostringa, d_pos + 1);
      END LOOP;

      RETURN d_result;
   END countOccurrenceOf;

   --------------------------------------------------------------------------------
   FUNCTION protect_wildcard (p_stringa IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        protect_wildcard
       VISIBILITA': pubblica
       DESCRIZIONE: protezione dei caratteri speciali ('_' e '%') nella stringa p_stringa
       PARAMETRI:   p_stringa
       RITORNA:     VARCHAR2
       NOTE:        -
      ******************************************************************************/
      d_result   VARCHAR2 (2000);
   BEGIN
      d_result := REPLACE (p_stringa, '_', '\_');
      d_result := REPLACE (d_result, '%', '\%');
      RETURN d_result;
   END protect_wildcard;

   --------------------------------------------------------------------------------
   FUNCTION quote (p_stringa IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        quote
       VISIBILITA': pubblica
       DESCRIZIONE: Gestione apici (aggiunta di quelli esterni e raddoppio di quelli
                    interni) per la stringa p_stringa
       PARAMETRI:   p_stringa
       RITORNA:     VARCHAR2
       NOTE:        -
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       019   19/10/2006  FT      Aggiunta funzione quote
      ******************************************************************************/
      d_result   VARCHAR2 (2000);
   BEGIN
      d_result := REPLACE (p_stringa, '''', '''''');
      d_result := '''' || d_result || '''';
      RETURN d_result;
   END quote;

   --------------------------------------------------------------------------------
   FUNCTION to_boolean (p_value IN NUMBER)
      RETURN BOOLEAN
   IS
      /******************************************************************************
       NOME:        to_boolean
       VISIBILITA': pubblica
       DESCRIZIONE: conversione booleana di valori number (1,0)
       PARAMETRI:   p_value: number: 1 o 0
       RITORNA:     boolean: true se 1, false se 0
       NOTE:        accetta solo argomenti validi (non nulli: NON implementa logica
                    booleana estesa al null)
      ******************************************************************************/
      d_result   BOOLEAN;
   BEGIN
      DbC.PRE (p_value IS NOT NULL);
      DbC.PRE (p_value = 1 OR p_value = 0);

      IF p_value = 1
      THEN
         d_result := TRUE;
      ELSE
         d_result := FALSE;
      END IF;

      DbC.POST (d_result IS NOT NULL);
      RETURN d_result;
   END;                                                      -- AFC.to_boolean

   --------------------------------------------------------------------------------
   FUNCTION TO_NUMBER (p_value IN BOOLEAN)
      RETURN NUMBER
   /******************************************************************************
    NOME:        to_number
    VISIBILITA': pubblica
    DESCRIZIONE: conversione number di valori booleani
    PARAMETRI:   p_value: boolean: true o false
    RITORNA:     boolean: 1 se true, 0 se false
    NOTE:        accetta solo argomenti validi (non nulli: NON implementa logica
                 booleana estesa al null)
   ******************************************************************************/
   IS
      d_result   NUMBER;
   BEGIN
      DbC.PRE (p_value IS NOT NULL);

      IF p_value
      THEN
         d_result := 1;
      ELSE
         d_result := 0;
      END IF;

      DbC.POST (d_result IS NOT NULL);
      DbC.POST (d_result = 1 OR d_result = 0);
      RETURN d_result;
   END;                                                       -- AFC.to_number

   --------------------------------------------------------------------------------
   FUNCTION TO_NUMBER (p_value IN VARCHAR2)
      RETURN NUMBER
   /******************************************************************************
    NOME:        to_number
    VISIBILITA': pubblica
    DESCRIZIONE: conversione number di stringhe
    PARAMETRI:   p_value: varchar2
    RITORNA:     number corrispondente o exception
    NOTE:        In caso la stringa passata non sia un numero esce con eccezione
                 ORA -06502.
   ******************************************************************************/
   IS
      d_result   NUMBER;
   BEGIN
      d_result := STANDARD.TO_NUMBER (p_value);
      RETURN d_result;
   END TO_NUMBER;

   --------------------------------------------------------------------------------
   PROCEDURE SQL_execute (p_stringa t_statement)
   IS
      /******************************************************************************
       NOME:        SQL_execute
       DESCRIZIONE: Esegue lo statement passato.
       ARGOMENTI:   p_stringa varchar2 statement sql da eseguire
       ECCEZIONI:
       ANNOTAZIONI: -
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       004   27/09/2005  MF      Cambio nomenclatura s_revisione e s_revisione_body.
                                 Tolta dipendenza get_stringParm da Package Si4.
                                 Inserimento SQL_execute per istruzioni dinamiche.
      ******************************************************************************/
      d_cursor           INTEGER;
      d_rows_processed   INTEGER;
   BEGIN
      d_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (d_cursor, p_stringa, DBMS_SQL.native);
      d_rows_processed := DBMS_SQL.execute (d_cursor);
      DBMS_SQL.close_cursor (d_cursor);
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_SQL.close_cursor (d_cursor);
         RAISE;
   END SQL_EXECUTE;

   --------------------------------------------------------------------------------
   FUNCTION SQL_execute (p_stringa t_statement)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        SQL_execute
       DESCRIZIONE: Esegue lo statement passato e rotorna il valore di ritorno.
       ARGOMENTI:   p_stringa varchar2 statement sql da eseguire
       ECCEZIONI:
       ANNOTAZIONI: -
       RITORNA:     varchar2 il valore di ritorno dello statement SQL p_stringa
      ******************************************************************************/
      d_cursor           INTEGER;
      d_rows_processed   INTEGER;
      d_result           VARCHAR2 (32000);
   BEGIN
      d_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (d_cursor, p_stringa, DBMS_SQL.native);
      DBMS_SQL.define_column (d_cursor,
                              1,
                              d_result,
                              32000);
      d_rows_processed := DBMS_SQL.execute (d_cursor);

      IF DBMS_SQL.fetch_rows (d_cursor) > 0
      THEN
         DBMS_SQL.COLUMN_VALUE (d_cursor, 1, d_result);
      END IF;

      DBMS_SQL.close_cursor (d_cursor);
      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_SQL.close_cursor (d_cursor);
         RAISE;
   END SQL_execute;

   --------------------------------------------------------------------------------
   FUNCTION xor (p_value_1 IN BOOLEAN, p_value_2 IN BOOLEAN)
      RETURN BOOLEAN
   IS
      /******************************************************************************
       NOME:        xor
       VISIBILITA': pubblica
       DESCRIZIONE: operatore booleano di or esclusivo
       PARAMETRI:   p_value_1: boolean
                    p_value_2: boolean
       RITORNA:     boolean
       NOTE:        accetta solo argomenti validi (non nulli: NON implementa logica
                    booleana estesa al null)
      ******************************************************************************/
      d_result   BOOLEAN;
   BEGIN
      DbC.PRE (p_value_1 IS NOT NULL);
      DbC.PRE (p_value_2 IS NOT NULL);
      d_result := p_value_1 != p_value_2;
      DbC.POST (d_result IS NOT NULL);
      RETURN d_result;
   END;                                                             -- AFC.xor

   --------------------------------------------------------------------------------
   FUNCTION xor (p_value_1   IN BOOLEAN,
                 p_value_2   IN BOOLEAN,
                 p_value_3   IN BOOLEAN)
      RETURN BOOLEAN
   IS
      /******************************************************************************
       NOME:        xor
       VISIBILITA': pubblica
       DESCRIZIONE: operatore booleano di or esclusivo
       PARAMETRI:   p_value_1: boolean
                    p_value_2: boolean
       RITORNA:     boolean
       NOTE:        accetta solo argomenti validi (non nulli: NON implementa logica
                    booleana estesa al null)
      ******************************************************************************/
      d_result   BOOLEAN;
   BEGIN
      DbC.PRE (p_value_3 IS NOT NULL);
      -- p_value_1 and p_value_2 checked into the binary base function
      d_result := xor (p_value_1, p_value_2) != p_value_3;
      DbC.POST (d_result IS NOT NULL);
      RETURN d_result;
   END;                                                             -- AFC.xor

   --------------------------------------------------------------------------------
   FUNCTION xor (p_value_1   IN BOOLEAN,
                 p_value_2   IN BOOLEAN,
                 p_value_3   IN BOOLEAN,
                 p_value_4   IN BOOLEAN)
      RETURN BOOLEAN
   IS
      /******************************************************************************
       NOME:        xor
       VISIBILITA': pubblica
       DESCRIZIONE: operatore booleano di or esclusivo
       PARAMETRI:   p_value_1: boolean
                    p_value_2: boolean
                    p_value_3: boolean
                    p_value_4: boolean
       RITORNA:     boolean
       NOTE:        accetta solo argomenti validi (non nulli: NON implementa logica
                    booleana estesa al null)
      ******************************************************************************/
      d_result   BOOLEAN;
   BEGIN
      d_result := xor (p_value_1, p_value_2) != xor (p_value_3, p_value_4);
      DbC.POST (d_result IS NOT NULL);
      RETURN d_result;
   END;                                                             -- AFC.xor

   --------------------------------------------------------------------------------
   FUNCTION mxor (p_value_1   IN BOOLEAN,
                  p_value_2   IN BOOLEAN,
                  p_value_3   IN BOOLEAN DEFAULT FALSE,
                  p_value_4   IN BOOLEAN DEFAULT FALSE,
                  p_value_5   IN BOOLEAN DEFAULT FALSE,
                  p_value_6   IN BOOLEAN DEFAULT FALSE,
                  p_value_7   IN BOOLEAN DEFAULT FALSE,
                  p_value_8   IN BOOLEAN DEFAULT FALSE)
      RETURN BOOLEAN
   IS
      /******************************************************************************
       NOME:        mxor
       VISIBILITA': pubblica
       DESCRIZIONE: operatore booleano di or esclusivo: ritorna true se solo uno dei
                    parametri e true e tutti gli altri sono false
       PARAMETRI:   p_value_1: boolean
                    p_value_2: boolean
                    p_value_3: boolean
                    p_value_4: boolean
                    p_value_5: boolean
                    p_value_6: boolean
                    p_value_7: boolean
                    p_value_8: boolean
       RITORNA:     boolean
       NOTE:        funziona per 2, 3, 4, 5, 6, 7 e 8 operandi
      ******************************************************************************/
      d_result   BOOLEAN;
   BEGIN
      d_result :=
                p_value_1
            AND NOT p_value_2
            AND NOT p_value_3
            AND NOT p_value_4
            AND NOT p_value_5
            AND NOT p_value_6
            AND NOT p_value_7
            AND NOT p_value_8
         OR     NOT p_value_1
            AND p_value_2
            AND NOT p_value_3
            AND NOT p_value_4
            AND NOT p_value_5
            AND NOT p_value_6
            AND NOT p_value_7
            AND NOT p_value_8
         OR     NOT p_value_1
            AND NOT p_value_2
            AND p_value_3
            AND NOT p_value_4
            AND NOT p_value_5
            AND NOT p_value_6
            AND NOT p_value_7
            AND NOT p_value_8
         OR     NOT p_value_1
            AND NOT p_value_2
            AND NOT p_value_3
            AND p_value_4
            AND NOT p_value_5
            AND NOT p_value_6
            AND NOT p_value_7
            AND NOT p_value_8
         OR     NOT p_value_1
            AND NOT p_value_2
            AND NOT p_value_3
            AND NOT p_value_4
            AND p_value_5
            AND NOT p_value_6
            AND NOT p_value_7
            AND NOT p_value_8
         OR     NOT p_value_1
            AND NOT p_value_2
            AND NOT p_value_3
            AND NOT p_value_4
            AND NOT p_value_5
            AND p_value_6
            AND NOT p_value_7
            AND NOT p_value_8
         OR     NOT p_value_1
            AND NOT p_value_2
            AND NOT p_value_3
            AND NOT p_value_4
            AND NOT p_value_5
            AND NOT p_value_6
            AND p_value_7
            AND NOT p_value_8
         OR     NOT p_value_1
            AND NOT p_value_2
            AND NOT p_value_3
            AND NOT p_value_4
            AND NOT p_value_5
            AND NOT p_value_6
            AND NOT p_value_7
            AND p_value_8;
      DbC.POST (d_result IS NOT NULL);
      RETURN d_result;
   END;                                                            -- AFC.mxor

   --------------------------------------------------------------------------------
   FUNCTION is_number (p_char IN VARCHAR2)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        is_number
       VISIBILITA': pubblica
       DESCRIZIONE: Verifica che la stringa passata sia un numero.
       PARAMETRI:   p_char: varchar2 stringa da controllare.
       RITORNA:     number 1: e' un numero
                           0: NON e' un numero
       NOTE:        in caso che p_char sia nullo, la funzione ritorna 1.
      ******************************************************************************/
      d_result   NUMBER := 1;
      d_test     NUMBER;
   BEGIN
      d_test := TO_NUMBER (p_char);
      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -6502
         THEN
            RETURN 0;
         ELSE
            RAISE;
         END IF;
   END is_number;

   --------------------------------------------------------------------------------
   FUNCTION is_numeric (p_char IN VARCHAR2)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        is_numeric
       VISIBILITA': pubblica
       DESCRIZIONE: Verifica che la stringa passata sia formata da soli numeri.
       PARAMETRI:   p_char: varchar2 stringa da controllare.
       RITORNA:     number 1: e' formata da soli numeri
                           0: NON e' formata da soli numeri
       NOTE:        in caso che p_char sia nullo, la funzione ritorna 0.
                    La lunghezza massima della stringa passata e' 32000.
      ******************************************************************************/
      d_result      NUMBER := 0;
      d_translate   VARCHAR2 (32000);
      d_compare     VARCHAR2 (32000);
      d_len         NUMBER := LENGTH (p_char);
      d_loop        NUMBER := 1;
   BEGIN
      IF p_char IS NOT NULL
      THEN
         d_translate := TRANSLATE (p_char, '0123456789x', 'xxxxxxxxxxa');

         WHILE d_loop <= d_len
         LOOP
            d_compare := d_compare || 'x';
            d_loop := d_loop + 1;
         END LOOP;

         IF d_compare = d_translate
         THEN
            d_result := 1;
         END IF;
      END IF;

      RETURN d_result;
   END is_numeric;

   --------------------------------------------------------------------------------
   FUNCTION get_field_condition (p_prefix        IN VARCHAR2,
                                 p_field_value   IN VARCHAR2,
                                 p_suffix        IN VARCHAR2,
                                 p_flag          IN NUMBER DEFAULT 0,
                                 p_date_format   IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        get_field_condition
       DESCRIZIONE: Ottiene stringa con condizione SQL.
       PARAMETRI:   p_prefix       stringa per prefissare la condizione
                    p_field_value  valore da controllare
                    p_suffix       stringa per suffissare la condizione
                    p_flag         0 = se p_field_value inizia con un operatore viene usato quello,
                                       senno viene usato l'operatore =
                                   1 = condizione indicata in valore
                    p_date_format  se p_field_value e di tipo date, contiene il formato
                                   da utilizzare per effettuare la conversione
       RITORNA:     varchar2 con stringa SQL
       NOTE:        Se p_field_value e NULL ritorna NULL.
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       009   22/02/2006  FT      Aggiunta dei metodi get_field_condition e decode_value
       011   21/03/2006  MF      - Introdotto prefix e suffix
                                 - return type t_statement
       015   28/06/2006  FT      modificata gestione di p_field_value: gestione di operatori
                                 di default e scorporo dell'operatore dal valore;
                                 aggiunto parametro p_date_format
       017   04/09/2006  FT      Aggiunta di apici a p_field_value in caso di 'like' implicito;
                                 controllo con 'lower' per caso di like
       018   05/09/2006  FT      Modificata gestione 'like' implicito e raddoppio apici singoli
       022   03/01/2007  FT      Modificata logica di gestione di p_flag per permettere di
                                 passare NULL e comportarsi come fosse il valore di default (0)
       025   09/01/2008  FT      Aggiunta possibilita di passare l'operatore
                                 anche con p_flag = 0; modificata gestione DATE: se il valore
                                 inizia per 'to_date(' non vengono applicate le regole di parsing
                                 ma viene concatenato direttamente al risultato finale
       026   18/03/2008  FT      Aggiunta possibilita di cercare per like su campi di tipo date
       027   08/10/2008  FT      Aggiunta degli operatori IN, BETWEEN, EXISTS e NOT
      ******************************************************************************/
      d_result           t_statement;
      d_operator         VARCHAR2 (7);
      d_char_operator    NUMBER := 0;
      d_value            t_statement;
      d_prefix           t_statement;
      d_field_value      AFC.t_statement;
      d_field_value_op   AFC.t_statement;
   BEGIN
      d_field_value := LTRIM (RTRIM (p_field_value));
      d_field_value_op := LOWER (REPLACE (p_field_value, ' ', ''));

      IF d_field_value IS NOT NULL
      THEN
         IF p_flag = 0 OR p_flag IS NULL
         THEN
            -- presenza del NOT iniziale
            IF SUBSTR (d_field_value_op, 1, 3) = 'not'
            THEN
               d_prefix :=
                     SUBSTR (p_prefix, 1, INSTR (p_prefix, '(') - 1)
                  || ' not '
                  || SUBSTR (p_prefix, INSTR (p_prefix, '('));
               d_field_value := LTRIM (SUBSTR (d_field_value, 4));
               d_field_value_op := LTRIM (SUBSTR (d_field_value_op, 4));
            ELSE
               -- caso like generico
               d_prefix := p_prefix;
            END IF;

            IF    SUBSTR (d_field_value_op, 1, 2) = '=='
               OR SUBSTR (d_field_value_op, 1, 2) = '=>'
               OR SUBSTR (d_field_value_op, 1, 2) = '>='
               OR SUBSTR (d_field_value_op, 1, 2) = '<='
               OR SUBSTR (d_field_value_op, 1, 2) = '=<'
               OR SUBSTR (d_field_value_op, 1, 2) = '<>'
               OR SUBSTR (d_field_value_op, 1, 2) = '!='
               OR SUBSTR (d_field_value_op, 1, 2) = '!>'
               OR SUBSTR (d_field_value_op, 1, 2) = '!<'
            THEN
               d_operator := SUBSTR (d_field_value_op, 1, 2);
               d_char_operator := 2;
            ELSIF    SUBSTR (d_field_value_op, 1, 1) = '>'
                  OR SUBSTR (d_field_value_op, 1, 1) = '<'
            THEN
               d_operator := SUBSTR (d_field_value_op, 1, 1);
               d_char_operator := 1;
            ELSIF SUBSTR (d_field_value_op, 1, 1) = '='
            THEN
               d_operator := '=';
               d_char_operator := 1;
            ELSIF SUBSTR (d_field_value_op, 1, 8) = 'between '
            THEN
               d_operator := SUBSTR (d_field_value_op, 1, 7);
               d_char_operator := 7;
            ELSIF SUBSTR (d_field_value_op, 1, 7) = 'exists('
            THEN
               d_operator := SUBSTR (d_field_value_op, 1, 6);
               d_char_operator := 6;
            ELSIF SUBSTR (d_field_value_op, 1, 3) = 'in('
            THEN
               d_operator := SUBSTR (d_field_value_op, 1, 2);
               d_char_operator := 2;
            ELSIF     (   (    INSTR (d_field_value_op, '_') != 0
                           AND INSTR (LOWER (d_field_value_op), 'to_date(') =
                                  0)
                       OR INSTR (d_field_value_op, '%') != 0)
                  AND NOT (    SUBSTR (d_field_value_op, 1, 1) = ''''
                           AND SUBSTR (d_field_value_op, -1) = '''')
            THEN
               -- operatore 'like'
               IF p_date_format IS NOT NULL
               THEN
                  -- caso like per date: trasformo in stringa il campo della tabella
                  d_prefix :=
                        SUBSTR (p_prefix, 1, INSTR (p_prefix, '('))
                     || ' to_char( '
                     || SUBSTR (p_prefix, INSTR (p_prefix, '(') + 1)
                     || ', '''
                     || p_date_format
                     || ''' ) ';
               ELSE
                  -- caso like generico
                  d_prefix := p_prefix;
               END IF;

               d_operator := 'like';
               d_field_value :=
                  '''' || REPLACE (d_field_value, '''', '''''') || '''';
            ELSE
               d_operator := '=';
            END IF;

            IF d_operator = '=='
            THEN
               d_operator := '=';
            ELSIF d_operator = '=>'
            THEN
               d_operator := '>=';
            ELSIF d_operator = '=<'
            THEN
               d_operator := '<=';
            END IF;

            d_value :=
               LTRIM (RTRIM (SUBSTR (d_field_value, d_char_operator + 1)));

            -- gestione apici
            IF p_date_format IS NOT NULL
            THEN
               IF SUBSTR (LOWER (d_value), 1, 8) != 'to_date('
               THEN
                  -- ¿ stata passata una data convertita in stringa (es: '15/01/1981 00:00:00')
                  d_value :=
                        'to_date( '''
                     || d_value
                     || ''', '''
                     || p_date_format
                     || ''' ) ';
               END IF;
            ELSE
               IF        SUBSTR (d_value, 1, 1) = ''''
                     AND SUBSTR (d_value, -1) = ''''
                  OR LOWER (d_operator) IN ('in', 'between', 'exists')
               THEN
                  d_value := d_value;
               ELSE
                  d_value := '''' || REPLACE (d_value, '''', '''''') || '''';
               END IF;
            END IF;

            d_value := d_operator || ' ' || d_value;
         ELSIF p_flag = 1
         THEN
            d_prefix := p_prefix;
            d_value := p_field_value;
         END IF;

         d_result := d_prefix || ' ' || d_value || ' ' || p_suffix;
      END IF;

      RETURN d_result;
   END get_field_condition;

   --------------------------------------------------------------------------------
   FUNCTION get_field_condition (p_prefix        IN VARCHAR2,
                                 p_field_value   IN DATE,
                                 p_suffix        IN VARCHAR2,
                                 p_flag          IN NUMBER DEFAULT 0,
                                 p_date_format   IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        get_field_condition
       DESCRIZIONE: Ottiene stringa con condizione SQL.
       PARAMETRI:   p_prefix       stringa per prefissare la condizione
                    p_field_value  valore da controllare
                    p_suffix       stringa per suffissare la condizione
                    p_flag         0= condizione per uguale
                                   1= condizione indicata in valore
                    p_date_format  se p_field_value e di tipo date, contiene il formato
                                   da utilizzare per effettuare la conversione
       RITORNA:     varchar2 con stringa SQL
       NOTE:        overloading per field_value di tipo DATE
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       024   14/03/2007  FT      Aggiunta overloading di get_field_condition per p_field_value
                                 di tipo DATE
      ******************************************************************************/
      d_result   t_statement;
   BEGIN
      d_result :=
         get_field_condition (
            p_prefix        => p_prefix,
            p_field_value   => TO_CHAR (p_field_value, date_format),
            p_suffix        => p_suffix,
            p_flag          => p_flag,
            p_date_format   => p_date_format);
      RETURN d_result;
   END get_field_condition;

   --------------------------------------------------------------------------------
   FUNCTION decode_value (p_check_value     IN VARCHAR2,
                          p_against_value   IN VARCHAR2,
                          p_then_result     IN VARCHAR2,
                          p_else_result     IN VARCHAR2)
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        decode_value
       DESCRIZIONE: Istruzione "decode" per PL/SQL.
       PARAMETRI:   p_check_value    valore da controllare
                    p_against_value  valore di confronto
                    p_then_result    risultato per uguale
                    p_else_result    risultato per diverso
       RITORNA:     varchar2
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       009   22/02/2006  FT      Aggiunta dei metodi get_field_condition e decode_value
       011   21/03/2006  MF      - return type t_statement
       ******************************************************************************/
      d_result   t_statement;
   BEGIN
      IF    p_check_value = p_against_value
         OR (p_check_value IS NULL AND p_against_value IS NULL)
      THEN
         d_result := p_then_result;
      ELSE
         d_result := p_else_result;
      END IF;

      RETURN d_result;
   END decode_value;

   --------------------------------------------------------------------------------
   FUNCTION date_format
      RETURN VARCHAR2
   IS
      /******************************************************************************
       NOME:        date_format
       DESCRIZIONE: Ritorna il formato standard di conversione di una data.
       PARAMETRI:   -
       RITORNA:     varchar2
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       015   19/05/2006  --      Prima emissione
      ******************************************************************************/
      d_result   VARCHAR2 (21);
   BEGIN
      d_result := 'dd/mm/yyyy hh24:mi:ss';
      RETURN d_result;
   END date_format;

   --------------------------------------------------------------------------------
   --------------------------------------------------------------------------------
   PROCEDURE default_null (p_item_name IN VARCHAR2 DEFAULT NULL)
   IS
      /******************************************************************************
       NOME:        default_null
       DESCRIZIONE: Memorizza nome item per gestione "default_null".
       ANNOTAZIONI: -
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       028   6/04/2008   MF      Prima emissione.
       029   18/05/2008  MF      Variabile d_item_name di tipo t_statement.
      ******************************************************************************/
      d_item_name     t_statement := UPPER (p_item_name);
      d_object_name   t_object_name;
   BEGIN
      IF (INSTR (d_item_name, '.') > 0)
      THEN
         -- Se il nome contiene oggetto.item
         d_object_name := afc.get_substr (d_item_name, '.');

         IF (   s_default_null_object_name != d_object_name
             OR s_default_null_object_name IS NULL)
         THEN
            -- A cambio object inizializza il "defaul_value"
            s_default_null_object_name := d_object_name;
            s_default_null := NULL;
         END IF;
      END IF;

      IF (d_item_name IS NULL)
      THEN
         -- Se item NULL inizializza il "defaul_value"
         s_default_null_object_name := NULL;
         s_default_null := NULL;
      ELSE
         -- Memorizza item inizializzato a NULL
         s_default_null := s_default_null || '#' || d_item_name;
      END IF;
   END default_null;

   --------------------------------------------------------------------------------
   FUNCTION default_null (p_item_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        default_null
    DESCRIZIONE: Ritorna valore NULL per inizializzazione default value e
                 memorizza nome item per gestione "default_null".
    ANNOTAZIONI: -
    REVISIONI:
    Rev.  Data        Autore  Descrizione
    ----  ----------  ------  ------------------------------------------------------
    028   6/04/2008   MF      Prima emissione.
   ******************************************************************************/
   BEGIN
      default_null (p_item_name);
      RETURN NULL;
   END default_null;

   --------------------------------------------------------------------------------
   FUNCTION is_default_null (p_item_name IN VARCHAR2)
      RETURN NUMBER
   IS
      /******************************************************************************
       NOME:        is_default_null
       DESCRIZIONE: Ritorna 1 se nome item ¿ stato valorizzato con gestione "default_null".
       RITORNA:     number: 1 se item inizializzato a null
                            0 se item non inizializzato.
       ANNOTAZIONI: -
       REVISIONI:
       Rev.  Data        Autore  Descrizione
       ----  ----------  ------  ------------------------------------------------------
       028   6/04/2008   MF      Prima emissione.
       029   18/05/2008  MF      Variabile d_item_name di tipo t_statement.
      ******************************************************************************/
      d_item_name     t_statement := UPPER (p_item_name);
      d_object_name   t_object_name;
   BEGIN
      IF (INSTR (d_item_name, '.') > 0)
      THEN
         -- Se il nome contiene oggetto.item
         d_object_name := afc.get_substr (d_item_name, '.');
      END IF;

      IF (    (   d_object_name IS NULL
               OR d_object_name = s_default_null_object_name)
          AND (INSTR (s_default_null, '#' || d_item_name) > 0))
      THEN
         -- Se object non indicato o uguale a ultimo trattato
         -- e item ¿ stato valorizzato gestione con "default_null".
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END is_default_null;
END AFC;
/
