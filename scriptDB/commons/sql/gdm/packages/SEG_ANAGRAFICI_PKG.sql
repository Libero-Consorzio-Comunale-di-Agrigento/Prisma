--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_SEG_ANAGRAFICI_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE seg_anagrafici_pkg
IS
   /******************************************************************************
    NOME:        seg_anagrafici_pkg
    DESCRIZIONE: Gestione vista SEG_ANAGRAFICI.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    11/04/2011    mmalferrari    Prima emissione.
    01    11/05/2012    mmalferrari    funzione ricerca aggiunto paramentro
                                       p_tipo_soggetto.
    02    05/08/2019    gmannella      Gestione cf_estero in funzione ricerca.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.02';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   FUNCTION get_campo_amm (
      p_note_amm_aoo_uo       IN VARCHAR2,
      p_campo                 IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_campo_aoo (
      p_note_amm_aoo_uo       IN VARCHAR2,
      p_campo                 IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_campo_uo (
      p_note_amm_aoo_uo       IN VARCHAR2,
      p_campo                 IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_codice_amm_from_note_anag (
      p_note_amm_aoo_uo     IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_codice_aoo_from_note_anag (
      p_note_amm_aoo_uo     IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_codice_uo_from_note_anag (
      p_note_amm_aoo_uo     IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION ricerca (
      p_ricerca         IN VARCHAR2,
      p_isquery         IN VARCHAR2,
      p_denominazione   IN VARCHAR2,
      p_indirizzo       IN VARCHAR2,
      p_cf              IN VARCHAR2,
      p_pi              IN VARCHAR2,
      p_email           IN VARCHAR2,
      p_dal             IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto   IN NUMBER DEFAULT -1,
      p_cf_estero IN VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor;

   FUNCTION ricerca_per_cf_pi (
      p_cf_pi                   IN VARCHAR2,
      p_ritorna_solo_se_unico   IN NUMBER DEFAULT 0,
      p_data_rif                IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE,
                                                             'dd/mm/yyyy'))
      RETURN afc.t_ref_cursor;

   FUNCTION ricerca_per_cf_pi_den (
      p_cf_pi                   IN VARCHAR2,
      p_denominazione           IN VARCHAR2,
      p_ritorna_solo_se_unico   IN NUMBER DEFAULT 0,
      p_data_rif                IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE,
                                                             'dd/mm/yyyy'))
      RETURN afc.t_ref_cursor;
END;
/
CREATE OR REPLACE PACKAGE BODY seg_anagrafici_pkg
IS
   /******************************************************************************
    NOME:        seg_anagrafici_pkg
    DESCRIZIONE: Gestione vista SEG_ANAGRAFICI.
    ANNOTAZIONI: .
    REVISIONI:   .
    Rev.  Data          Autore        Descrizione.
    000   11/04/2011    mmalferrari   Prima emissione.
    001   11/05/2012    mmalferrari   funzione ricerca aggiunto parametro
                                      p_tipo_soggetto.
    002   24/05/2018    SC            Ridotte le possibilita di entrare in ricerca per CF.
                                      Diminuite le query eseguite.
    003   05/08/2019    gmannella     Gestione cf_estero in funzione ricerca.
    004   07/01/2020    mmalferrari   Modificato ordinamento in ricerca_per_campo
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '004';

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
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------
   FUNCTION ricerca_per_campo (p_campo      VARCHAR2,
                               p_ricerca    VARCHAR2,
                               p_count      INTEGER,
                               p_filtro     VARCHAR2,
                               p_dal        VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_sql       VARCHAR2 (1000);
      d_return    afc.t_ref_cursor;
      d_ricerca   VARCHAR2 (240) := p_ricerca;
   BEGIN
      IF SUBSTR (d_ricerca, 1, 1) = '%'
      THEN
         d_ricerca := '%' || d_ricerca;
      END IF;

      d_sql := 'select ';

      IF p_count = 1
      THEN
         d_sql := d_sql || 'count(1)';
      ELSE
         d_sql := d_sql || '*';
      END IF;

      d_sql :=
            d_sql
         || ' from seg_anagrafici where to_date('''
         || p_dal
         || ''',''dd/mm/yyyy'') between trunc(nvl(dal, sysdate)) and trunc(nvl(al,sysdate))';

      IF p_filtro IS NOT NULL
      THEN
         d_sql := d_sql || ' and ' || p_filtro;
      END IF;

      IF UPPER (p_campo) = 'NI'
      THEN
         d_sql := d_sql || ' and ni_persona = ' || d_ricerca;
      ELSIF UPPER (p_campo) = 'CF'
      THEN
         d_sql :=
            d_sql || ' and codice_fiscale = upper(''' || d_ricerca || ''')';
      ELSIF UPPER (p_campo) = 'PI'
      THEN
         d_sql := d_sql || ' and partita_iva = ''' || d_ricerca || '''';
      ELSIF UPPER (p_campo) = 'EMAIL'
      THEN
         d_sql :=
            d_sql || ' and upper(email) = upper(''' || d_ricerca || ''')';
      ELSE
         d_sql :=
               d_sql
            || ' and catsearch (denominazione, '''
            || REPLACE (REPLACE (d_ricerca, '''', ''''''), '%', '*')
            || ''', NULL) > 0';
      END IF;

      IF p_count = 0
      THEN
         d_sql := d_sql || ' order by denominazione, codice_fiscale, to_number(ni), decode(DESCRIZIONE_TIPO_RECAPITO, ''RESIDENZA'', -1,as4_tipi_recapito_tpk.get_IMPORTANZA(ID_TIPO_RECAPITO)),DESCRIZIONE_TIPO_RECAPITO';
      END IF;

      DBMS_OUTPUT.put_line (d_sql);

      OPEN d_return FOR d_sql;

      RETURN d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION ricerca_per_cf_pi (
      p_cf_pi                   IN VARCHAR2,
      p_ritorna_solo_se_unico   IN NUMBER DEFAULT 0,
      p_data_rif                IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE,
                                                             'dd/mm/yyyy'))
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       NOME:        ricerca_per_cf_pi.
       DESCRIZIONE: Ricerca in SEG_ANAGRAFICI per partita iva o codice fiscale.

       ARGOMENTI:   p_cf_pi      Stringa contenente CF/PI da ricercare.
                    p_data_rif   Data di utilizzo soggetto (formato dd/mm/yyyy).
       ANNOTAZIONI: -
       REVISIONI:
       Rev. Data       Autore       Descrizione
       ---- ---------- ------------ -------------------------------------------------
       0    11/04/2012 MMalferrari  Creazione.
      ******************************************************************************/
      d_dal               VARCHAR2 (10)
                             := NVL (p_data_rif, TO_CHAR (SYSDATE, 'dd/mm/yyyy'));
      d_return            afc.t_ref_cursor;
      d_rows              NUMBER := 0;
      d_statement         VARCHAR2 (32767);
      d_statement_count   VARCHAR2 (32767);
      d_select            VARCHAR2 (100);
      d_table             VARCHAR2 (100);
      d_where             VARCHAR2 (32767);
      d_where_base        VARCHAR2 (32767);
   BEGIN
      d_select := 'SELECT * FROM ';
      d_table := ' SEG_ANAGRAFICI ';
      d_where_base :=
            ' WHERE (partita_iva = '''
         || p_cf_pi
         || ''' OR codice_fiscale = upper ('''
         || p_cf_pi
         || '''))
                          AND to_date('''
         || d_dal
         || ''', ''dd/mm/yyyy'') BETWEEN TRUNC (NVL (dal, SYSDATE)) AND TRUNC (NVL (al, SYSDATE))';
      d_where := d_where_base;
      d_statement := d_select || d_table || d_where;

      IF p_ritorna_solo_se_unico = 1
      THEN
         d_table := ' seg_anagrafici_as4 ';
         d_where := d_where_base;
         d_statement := d_select || d_table || d_where;
         d_table := ' seg_anagrafici_so4 ';
         d_where := d_where_base;
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_soggetti_mv ';
         d_where := d_where_base || ' AND tipo_soggetto <> 3 ';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_soggetti_mv ';
         d_where :=
               d_where_base
            || ' AND tipo_soggetto = 3 AND tipo_localizzazione = ''SEDE LEGALE''';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_soggetti_mv ';
         d_where :=
               d_where_base
            || ' AND tipo_soggetto = 3 AND nvl(tipo_localizzazione, '' '') <> ''SEDE LEGALE''';
         d_where :=
               d_where
            || '  AND NOT EXISTS (SELECT 1 FROM '
            || d_table
            || d_where_base
            || ' AND tipo_soggetto = 3 AND tipo_localizzazione = ''SEDE LEGALE'')';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_statement_count := 'SELECT COUNT(1) FROM (' || d_statement || ')';

         EXECUTE IMMEDIATE d_statement_count INTO d_rows;

         IF d_rows <> 1
         THEN
            d_table := ' seg_soggetti_mv ';
            d_where := ' where codice_fiscale = null ';
            d_statement := d_select || d_table || d_where;
         END IF;
      END IF;

      integritypackage.LOG (d_statement);

      OPEN d_return FOR d_statement;

      RETURN d_return;
   END;

   FUNCTION ricerca_per_cf_pi_den (
      p_cf_pi                   IN VARCHAR2,
      p_denominazione           IN VARCHAR2,
      p_ritorna_solo_se_unico   IN NUMBER DEFAULT 0,
      p_data_rif                IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE,
                                                             'dd/mm/yyyy'))
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       NOME:        ricerca_per_cf_pi.
       DESCRIZIONE: Ricerca in SEG_ANAGRAFICI per partita iva o codice fiscale.

       ARGOMENTI:   p_cf_pi      Stringa contenente CF/PI da ricercare.
                    p_data_rif   Data di utilizzo soggetto (formato dd/mm/yyyy).
       ANNOTAZIONI: -
       REVISIONI:
       Rev. Data       Autore       Descrizione
       ---- ---------- ------------ -------------------------------------------------
       0    11/04/2012 MMalferrari  Creazione.
      ******************************************************************************/
      d_dal               VARCHAR2 (10)
                             := NVL (p_data_rif, TO_CHAR (SYSDATE, 'dd/mm/yyyy'));
      d_return            afc.t_ref_cursor;
      d_rows              NUMBER := 0;
      d_statement         VARCHAR2 (32767);
      d_statement_count   VARCHAR2 (32767);
      d_select            VARCHAR2 (100);
      d_table             VARCHAR2 (100);
      d_where             VARCHAR2 (32767);
      d_where_base        VARCHAR2 (32767);
      d_where_deno        VARCHAR2 (32767);
      d_denominazione     VARCHAR2 (32767);
   BEGIN
      d_denominazione := REPLACE (p_denominazione, '''', '''''');
      integritypackage.LOG (d_denominazione);
      d_select := 'SELECT * FROM ';
      d_table := ' SEG_ANAGRAFICI ';
      d_where_base :=
            ' WHERE (partita_iva = '''
         || p_cf_pi
         || ''' OR codice_fiscale = upper ('''
         || p_cf_pi
         || '''))
                          AND to_date('''
         || d_dal
         || ''', ''dd/mm/yyyy'') BETWEEN TRUNC (NVL (dal, SYSDATE)) AND TRUNC (NVL (al, SYSDATE))';
      d_where_deno :=
            ' AND replace(NVL('''
         || d_denominazione
         || ''', denominazione),'' '','''') = replace(denominazione, '' '', '''')';
      d_where := d_where_base || d_where_deno;
      d_statement := d_select || d_table || d_where;

      IF p_ritorna_solo_se_unico = 1
      THEN
         d_table := ' seg_anagrafici_as4 ';
         d_where := d_where_base || d_where_deno;
         d_statement := d_select || d_table || d_where;
         /*d_table := ' seg_anagrafici_so4 ';
         d_where := d_where_base || d_where_deno;
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;*/
         d_table := ' seg_soggetti_mv ';
         d_where := d_where_base || d_where_deno || ' AND tipo_soggetto <> 3 ';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_soggetti_mv ';
         d_where :=
               d_where_base
            || d_where_deno
            || ' AND tipo_soggetto = 3 AND tipo_localizzazione = ''SEDE LEGALE''';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_soggetti_mv ';
         d_where :=
               d_where_base
            || d_where_deno
            || ' AND tipo_soggetto = 3 AND nvl(tipo_localizzazione, '' '') <> ''SEDE LEGALE''';
         d_where :=
               d_where
            || d_where_deno
            || '  AND NOT EXISTS (SELECT 1 FROM '
            || d_table
            || d_where_base
            || ' AND tipo_soggetto = 3 AND tipo_localizzazione = ''SEDE LEGALE'')';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_statement_count := 'SELECT COUNT(1) FROM (' || d_statement || ')';
         integritypackage.LOG (d_statement);

         EXECUTE IMMEDIATE d_statement_count INTO d_rows;

         IF d_rows <> 1
         THEN
            d_table := ' seg_soggetti_mv ';
            d_where := ' where codice_fiscale = null ';
            d_statement := d_select || d_table || d_where;
         END IF;
      END IF;

      integritypackage.LOG (d_statement);

      OPEN d_return FOR d_statement;

      RETURN d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION get_codice_amm_from_note_anag (
      p_note_amm_aoo_uo     IN VARCHAR2)
      RETURN VARCHAR2
   IS
   d_return VARCHAR2(32000);
   BEGIN
   dbms_output.put_line('amm '||p_note_amm_aoo_uo);
      if INSTR (p_note_amm_aoo_uo, ':') = 0 then --amm
         return p_note_amm_aoo_uo;
      end if;
      d_return := substr(p_note_amm_aoo_uo, 1, instr(p_note_amm_aoo_uo, ':')-1);
      RETURN d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION get_codice_aoo_from_note_anag (
      p_note_amm_aoo_uo     IN VARCHAR2)
      RETURN VARCHAR2
   IS
   d_return VARCHAR2(32000);
   d_pos_inizio number;
   d_tot_caratteri number := 1000;
   BEGIN
   dbms_output.put_line('aoo '||p_note_amm_aoo_uo);
      if INSTR (p_note_amm_aoo_uo, ':') = 0 then --amm
         return '';
      end if;
      if INSTR (p_note_amm_aoo_uo, ':') > 0 then
         if INSTR (p_note_amm_aoo_uo, '::') > 0 then --uo senzo aoo
            return '';
         else
            d_pos_inizio := INSTR (p_note_amm_aoo_uo, ':') + 1;
            if INSTR (p_note_amm_aoo_uo,
                                                    ':',
                                                    1,
                                                    2) > 0 then --uo con aoo
            d_tot_caratteri := INSTR (p_note_amm_aoo_uo,
                                                      ':',
                                                      1,
                                                      2)
                                             - d_pos_inizio
                                             ;
            end if;
         end if;
      end if;
      d_return := SUBSTR (p_note_amm_aoo_uo, d_pos_inizio, d_tot_caratteri);
      return d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION get_codice_uo_from_note_anag (
      p_note_amm_aoo_uo     IN VARCHAR2)
      RETURN VARCHAR2
   IS
   d_return VARCHAR2(32000);
   d_pos_inizio number;
   d_tot_caratteri number := 1000;
   BEGIN
   dbms_output.put_line('uo '||p_note_amm_aoo_uo);
      if INSTR (p_note_amm_aoo_uo, ':') = 0 then --amm
         return '';
      end if;
      if INSTR (p_note_amm_aoo_uo, ':',
                                 1,
                                 2) = 0 then --aoo
         return '';
      end if;
      d_pos_inizio := INSTR (p_note_amm_aoo_uo, ':',
                                 1,
                                 2) +1;
      d_return := substr(p_note_amm_aoo_uo, d_pos_inizio);
      return d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION get_campo_amm (
      p_note_amm_aoo_uo       IN VARCHAR2,
      p_campo                 IN VARCHAR2)
      RETURN VARCHAR2
   IS
   d_return VARCHAR2(32000);
   d_cod_amm VARCHAR2(32000);
   d_select VARCHAR2(32000);
   d_campo VARCHAR2(32000) := p_campo;
   BEGIN
      d_cod_amm := get_codice_amm_from_note_anag (p_note_amm_aoo_uo);
      --DBMS_OUTPUT.PUT_LINE(d_cod_amm);
      if lower(d_campo) = 'dal' then
         d_campo := 'to_char(dal, ''dd/mm/yyyy'')';
      end if;
      d_select := 'select '||d_campo||' FROM seg_amministrazioni WHERE '||d_campo||' is not null and codice = '''||d_cod_amm||''' and rownum = 1';
      --DBMS_OUTPUT.PUT_LINE(D_SELECT);
      EXECUTE IMMEDIATE  d_select INTO d_return;
      RETURN d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION get_campo_aoo (
      p_note_amm_aoo_uo       IN VARCHAR2,
      p_campo                 IN VARCHAR2)
      RETURN VARCHAR2
   IS
   d_return VARCHAR2(32000);
   d_cod_amm VARCHAR2(32000);
   d_codice  VARCHAR2(32000);
   d_cod_aoo VARCHAR2(32000);
   d_select VARCHAR2(32000);
   d_campo VARCHAR2(32000) := p_campo;
   BEGIN
      d_cod_amm := get_codice_amm_from_note_anag (p_note_amm_aoo_uo);
      d_cod_aoo := get_codice_aoo_from_note_anag (p_note_amm_aoo_uo);
      d_codice := d_cod_amm||':'||d_cod_aoo;
      if d_cod_aoo is not null then
          DBMS_OUTPUT.PUT_LINE(d_cod_amm);
          if lower(d_campo) = 'dal' then
             d_campo := 'to_char(dal, ''dd/mm/yyyy'')';
          end if;
          d_select := 'select '||d_campo||' FROM seg_aoo WHERE '||d_campo||' is not null and codice = '''||d_codice||''' and rownum = 1';
          EXECUTE IMMEDIATE  d_select INTO d_return;
      end if;
      RETURN d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION get_campo_uo (
      p_note_amm_aoo_uo       IN VARCHAR2,
      p_campo                 IN VARCHAR2)
      RETURN VARCHAR2
   IS
   d_return VARCHAR2(32000);
   d_select VARCHAR2(32000);
   d_campo VARCHAR2(32000) := p_campo;
   BEGIN
      if lower(d_campo) = 'dal' then
         d_campo := 'to_char(dal, ''dd/mm/yyyy'')';
      end if;
      d_select := 'select '||d_campo||' FROM seg_uo WHERE '||d_campo||' is not null and codice = '''||p_note_amm_aoo_uo||''' and rownum = 1';
      --DBMS_OUTPUT.PUT_LINE(D_SELECT);
      EXECUTE IMMEDIATE  d_select INTO d_return;
      RETURN d_return;
   END;

   --------------------------------------------------------------------------------
   FUNCTION ricerca (
      p_ricerca         IN VARCHAR2,
      p_isquery         IN VARCHAR2,
      p_denominazione   IN VARCHAR2,
      p_indirizzo       IN VARCHAR2,
      p_cf              IN VARCHAR2,
      p_pi              IN VARCHAR2,
      p_email           IN VARCHAR2,
      p_dal             IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto   IN NUMBER DEFAULT -1,
      p_cf_estero IN VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor
   IS
      /******************************************************************************
       NOME:        RICERCA.
       DESCRIZIONE: Ricerca in SEG_ANAGRAFICI col seguente criterio:
                     se e' un numero
                        se e' lungo 11: ricerca per partita iva prima nel campo PI poi
                                        nel campo CF;
                        altrimenti: ricerca per numero individuale (NI)
                     altrimenti: ricerca per denominazione con catsearch.

       ARGOMENTI:   p_ricerca    Stringa contenente CF/PI/Denominazione da ricercare.
                    p_dal        Data di utilizzo soggetto (formato dd/mm/yyyy).
       ECCEZIONI:   - 20999 Soggetto non Disponibile.
       ANNOTAZIONI: -
       REVISIONI:
       Rev. Data       Autore       Descrizione
       ---- ---------- ------------ -------------------------------------------------
       0    08/02/2010 MMalferrari  Creazione.
       1    24/01/2012 MMalferrari  Gestione carattere % all'inizio della stringa di
                                    ricerca
       2    24/05/2018    SC        Ridotte le possibilita di entrare in ricerca per CF
                                    Diminuite le query eseguite.
      ******************************************************************************/
      d_dal      VARCHAR2 (10) := NVL (p_dal, TO_CHAR (SYSDATE, 'dd/mm/yyyy'));
      d_return   afc.t_ref_cursor;
      d_rows     NUMBER;
      d_filtro   VARCHAR2 (2000);
   BEGIN
      IF NVL (p_tipo_soggetto, '-1') <> '-1'
      THEN
         d_filtro := 'tipo_soggetto = ' || p_tipo_soggetto;
      END IF;

      IF p_isquery = 'ISQUERY'
      THEN
         IF     p_denominazione IS NULL
            AND p_cf IS NULL
            AND p_cf_estero IS NULL
            AND p_email IS NULL
            AND p_pi IS NULL
         THEN
            raise_application_error (
               -20999,
               'Inserire dei parametri di ricerca (denominazione, codice fiscale, codice fiscale estero,  partita iva oppure email).');
         ELSE
            OPEN d_return FOR
               SELECT *
                 FROM seg_anagrafici
                WHERE     (catsearch (
                              denominazione,
                              REPLACE (
                                 REPLACE (UPPER (p_denominazione), '', ''''),
                                 '%',
                                 '*'),
                              NULL) > 0)
                      AND NVL (codice_fiscale, '%') LIKE
                             ('%' || NVL (UPPER (p_cf), '%') || '%')
                     AND NVL (cf_estero, '%') LIKE
                             ('%' || NVL (UPPER (p_cf_estero), '%') || '%')
                      AND NVL (partita_iva, '%') LIKE
                             ('%' || NVL (UPPER (p_pi), '%') || '%')
                      AND NVL (indirizzo, '%') LIKE
                             ('%' || NVL (UPPER (p_indirizzo), '%') || '%')
                      AND NVL (UPPER (email), '%') LIKE
                             ('%' || NVL (UPPER (p_email), '%') || '%')
                      AND NVL (p_dal, (SYSDATE)) BETWEEN TRUNC (
                                                            NVL (dal,
                                                                 SYSDATE))
                                                     AND TRUNC (
                                                            NVL (al, SYSDATE))
                      AND p_denominazione IS NOT NULL
                      AND (   tipo_soggetto = p_tipo_soggetto
                           OR p_tipo_soggetto = -1)
               UNION
               SELECT *
                 FROM seg_anagrafici
                WHERE     NVL (codice_fiscale, '%') LIKE
                             ('%' || NVL (UPPER (p_cf), '%') || '%')
                       AND NVL (cf_estero, '%') LIKE
                             ('%' || NVL (UPPER (p_cf_estero), '%') || '%')
                      AND NVL (partita_iva, '%') LIKE
                             ('%' || NVL (UPPER (p_pi), '%') || '%')
                      AND NVL (indirizzo, '%') LIKE
                             ('%' || NVL (UPPER (p_indirizzo), '%') || '%')
                      AND NVL (UPPER (email), '%') LIKE
                             ('%' || NVL (UPPER (p_email), '%') || '%')
                      AND NVL (p_dal, TRUNC (SYSDATE)) BETWEEN TRUNC (
                                                                  NVL (
                                                                     dal,
                                                                     SYSDATE))
                                                           AND TRUNC (
                                                                  NVL (
                                                                     al,
                                                                     SYSDATE))
                      AND p_denominazione IS NULL
                      AND (   tipo_soggetto = p_tipo_soggetto
                           OR p_tipo_soggetto = -1);
         END IF;

         RETURN d_return;
      ELSE
         IF p_ricerca IS NULL
         THEN
            raise_application_error (
               -20999,
               'Scrivere correttamente il codice fiscale oppure la partita iva oppure parte della denominazione del soggetto (almeno 3 caratteri).');
         END IF;

         IF LENGTH (p_ricerca) > 240
         THEN
            raise_application_error (
               -20999,
               'Denominazione troppo lunga (lunghezza massima 240)!');
         END IF;

         -- Lettura Anagrafe Soggetti;
         IF afc.is_number (p_ricerca) = 1
         THEN
            -----------------------------------------------------------------------
            --                 Ricerca per NI o PARTITA IVA o CF
            -----------------------------------------------------------------------
            IF LENGTH (p_ricerca) = 11
            THEN
               -- se e' lungo 11 prova per PI.
               d_return :=
                  ricerca_per_campo ('PI',
                                     p_ricerca,
                                     1,
                                     d_filtro,
                                     d_dal);

               FETCH d_return INTO d_rows;

               IF d_rows > 0
               THEN
                  CLOSE d_return;

                  d_return :=
                     ricerca_per_campo ('PI',
                                        p_ricerca,
                                        0,
                                        d_filtro,
                                        d_dal);
                  RETURN d_return;
               ELSE
                  -- cerca PI in campo CF
                  d_return :=
                     ricerca_per_campo ('CF',
                                        p_ricerca,
                                        1,
                                        d_filtro,
                                        d_dal);

                  FETCH d_return INTO d_rows;

                  IF d_rows > 0
                  THEN
                     CLOSE d_return;

                     d_return :=
                        ricerca_per_campo ('CF',
                                           p_ricerca,
                                           0,
                                           d_filtro,
                                           d_dal);
                     RETURN d_return;
                  END IF;
               END IF;
            END IF;

            IF d_return%ISOPEN
            THEN
               CLOSE d_return;
            END IF;

            d_return :=
               ricerca_per_campo ('NI',
                                  p_ricerca,
                                  1,
                                  d_filtro,
                                  d_dal);

            FETCH d_return INTO d_rows;

            -- Diminuite le query eseguite.
            IF d_rows > 0
            THEN
               CLOSE d_return;

               d_return :=
                  ricerca_per_campo ('NI',
                                     p_ricerca,
                                     0,
                                     d_filtro,
                                     d_dal);
            END IF;

            RETURN d_return;
         ELSE
            --------------------------------------------------------------------------------
            --                 Ricerca per EMAIL
            --------------------------------------------------------------------------------
            IF INSTR (p_ricerca, '@') > 0
            THEN
               d_return :=
                  ricerca_per_campo ('EMAIL',
                                     p_ricerca,
                                     1,
                                     d_filtro,
                                     d_dal);

               FETCH d_return INTO d_rows;

               IF d_rows > 0
               THEN
                  CLOSE d_return;

                  d_return :=
                     ricerca_per_campo ('EMAIL',
                                        p_ricerca,
                                        0,
                                        d_filtro,
                                        d_dal);
                  RETURN d_return;
               END IF;
            END IF;

            --------------------------------------------------------------------------------
            --                 Ricerca per CODICE FISCALE
            --------------------------------------------------------------------------------
            --002   24/05/2018    SC            Ridotte le possibilita di entrare in ricerca per CF
            IF     LENGTH (p_ricerca) = 16
               AND INSTR (p_ricerca, ' ') = 0
               AND (   INSTR (p_ricerca, '0') > 0
                    OR INSTR (p_ricerca, '1') > 0
                    OR INSTR (p_ricerca, '2') > 0
                    OR INSTR (p_ricerca, '3') > 0
                    OR INSTR (p_ricerca, '4') > 0
                    OR INSTR (p_ricerca, '5') > 0
                    OR INSTR (p_ricerca, '6') > 0
                    OR INSTR (p_ricerca, '7') > 0
                    OR INSTR (p_ricerca, '8') > 0
                    OR INSTR (p_ricerca, '9') > 0)
            THEN
               d_return :=
                  ricerca_per_campo ('CF',
                                     p_ricerca,
                                     1,
                                     d_filtro,
                                     d_dal);

               FETCH d_return INTO d_rows;

               IF d_rows > 0
               THEN
                  CLOSE d_return;

                  d_return :=
                     ricerca_per_campo ('CF',
                                        p_ricerca,
                                        0,
                                        d_filtro,
                                        d_dal);
                  RETURN d_return;
               END IF;
            END IF;

            --------------------------------------------------------------------------------
            --                        Ricerca per DENOMINAZIONE
            --------------------------------------------------------------------------------
            IF d_return%ISOPEN
            THEN
               CLOSE d_return;
            END IF;

            d_return :=
               ricerca_per_campo ('DENOMINAZIONE',
                                  p_ricerca,
                                  1,
                                  d_filtro,
                                  d_dal);

            FETCH d_return INTO d_rows;

            -- Diminuite le query eseguite.
            IF d_rows > 0
            THEN
               CLOSE d_return;

               d_return :=
                  ricerca_per_campo ('DENOMINAZIONE',
                                     p_ricerca,
                                     0,
                                     d_filtro,
                                     d_dal);
            END IF;

            RETURN d_return;
         END IF;
      END IF;
   END;
END;
/
