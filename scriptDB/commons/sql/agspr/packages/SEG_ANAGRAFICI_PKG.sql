--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_SEG_ANAGRAFICI_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE seg_anagrafici_pkg
IS
   /******************************************************************************
    NOME:        seg_anagrafici_pkg
    DESCRIZIONE: Gestione vista SEG_ANAGRAFICI.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    17/01/2017    mmalferrari    Prima emissione.
    01    06/08/2019    gmannella      Gestione cf_estero in funzioni ricerca e
                                       ricerca_anagrafici.
    02    31/01/2020    gmannella      Modificata funzione ricerca (aggiunto
                                       parametrop_denom_tipo_ricerca)
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.02';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (versione, WNDS);

   FUNCTION ricerca (
      p_ricerca              IN VARCHAR2,
      p_isquery              IN VARCHAR2,
      p_denominazione        IN VARCHAR2,
      p_indirizzo            IN VARCHAR2,
      p_cf                   IN VARCHAR2,
      p_pi                   IN VARCHAR2,
      p_email                IN VARCHAR2,
      p_dal                  IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto        IN NUMBER DEFAULT -1,
      p_cf_estero            IN VARCHAR2 DEFAULT NULL,
      p_denom_tipo_ricerca   IN VARCHAR2 DEFAULT NULL,
      p_escudi_ricerca_ni IN NUMBER DEFAULT 0)
      RETURN afc.t_ref_cursor;

   FUNCTION ricerca_anagrafici_base (
      p_ricerca         IN VARCHAR2,
      p_isquery         IN VARCHAR2,
      p_denominazione   IN VARCHAR2,
      p_indirizzo       IN VARCHAR2,
      p_cf              IN VARCHAR2,
      p_pi              IN VARCHAR2,
      p_email           IN VARCHAR2,
      p_dal             IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto   IN NUMBER DEFAULT -1)
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

   FUNCTION ricerca_per_amm (
      p_amm                   IN VARCHAR2,
      p_aoo                    IN VARCHAR2,
      p_uo                      IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION ricerca_per_ni (
      p_ni                      IN VARCHAR2,
      p_tipo_soggetto   IN NUMBER DEFAULT -1)
      RETURN afc.t_ref_cursor;

   FUNCTION get_indirizzi_amm (p_cod_amm    VARCHAR2,
                               p_cod_aoo    VARCHAR2,
                               p_cod_uo     VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION get_COMPONENTI_LISTA (P_ID_LISTA NUMBER)
      RETURN afc.t_ref_cursor;
END;
/
CREATE OR REPLACE PACKAGE BODY SEG_ANAGRAFICI_PKG
IS
   /******************************************************************************
    NOME:        seg_anagrafici_pkg
    DESCRIZIONE: Gestione vista SEG_ANAGRAFICI.
    ANNOTAZIONI: .
    REVISIONI:   .
    Rev.  Data          Autore        Descrizione.
    000   17/01/2017    mmalferrari   Prima emissione.
    001   06/08/2019    gmannella     Gestione cf_estero in funzioni ricerca e
                                      ricerca_anagrafici.
    002   04/11/2019    mmalferrari   Gestione ordinamento in ricerca_per_campo
    003   13/11/2019    gmannella     Modificata get_componenti_lista
    004   31/01/2020    gmannella     Creata getCondizioneDenominazione e modificate
                                                        ricerca_per_campo, ricerca_anagrafici
    006   20/10/2020    gmannella    modificata la ricerca_per_ni aggiungendo condizione su tipo_soggetto
                                                       se -1 non effettuta la WHERE
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '006';

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

   FUNCTION getCondizioneDenominazione (
      p_denominazione        IN VARCHAR2,
      p_denom_tipo_ricerca   IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      d_condizione       VARCHAR2 (32000) := '';
      d_denominazione    VARCHAR2 (4000) := p_denominazione;
      d_caso_catsearch   BOOLEAN := FALSE;
   BEGIN
      IF d_denominazione IS NOT NULL
      THEN
         d_denominazione := REPLACE (d_denominazione, '''', '''''');

         --CASO RICERCA "FRASE LIBERA"
         IF p_denom_tipo_ricerca IS NULL
         THEN
            d_caso_catsearch := TRUE;
         END IF;

         IF p_denom_tipo_ricerca = 'CONTIENE'
         THEN
            d_caso_catsearch := TRUE;
            d_denominazione := '**' || d_denominazione || '*';
         END IF;

         IF p_denom_tipo_ricerca = 'CONTIENE_FRASE_ESATTA'
         THEN
            d_caso_catsearch := TRUE;
            d_denominazione := '"' || d_denominazione || '"';
         END IF;

         IF d_caso_catsearch
         THEN
            d_condizione :=
                  ' (catsearch ( denominazione,'''
               || REPLACE (REPLACE (UPPER (d_denominazione), '', ''''),
                           '%',
                           '*')
               || ''', NULL) > 0)  ';
         ELSE
            IF p_denom_tipo_ricerca = 'UGUALE'
            THEN
               d_condizione :=
                     ' denominazione =  '''
                  || REPLACE (d_denominazione, '', '''')
                  || '''';
            END IF;

            IF p_denom_tipo_ricerca = 'INIZIO'
            THEN
               d_condizione :=
                     ' instr(denominazione ,  '''
                  || REPLACE (d_denominazione, '', '''')
                  || ''') =1  ';
            END IF;

            IF p_denom_tipo_ricerca = 'FINE'
            THEN
               d_condizione :=
                     ' instr(denominazione ,  '''
                  || REPLACE (d_denominazione, '', '''')
                  || ''' , -1 ) =   length(denominazione) - length( '''
                  || REPLACE (d_denominazione, '', '''')
                  || ''' ) +1   ';
            END IF;
         END IF;
      END IF;

      if trim(d_condizione)='' or d_condizione is null then
        d_condizione:='1=1';
      end if;

      RETURN d_condizione;
   END;


   --------------------------------------------------------------------------------
   FUNCTION ricerca_per_campo (
      p_campo                   VARCHAR2,
      p_ricerca                 VARCHAR2,
      p_count                   INTEGER,
      p_filtro                  VARCHAR2,
      p_dal                     VARCHAR2,
      p_anagrafica              VARCHAR2 DEFAULT 'SEG_ANAGRAFICI',
      p_denom_tipo_ricerca   IN VARCHAR2 DEFAULT NULL)
      RETURN afc.t_ref_cursor
   IS
      d_sql       VARCHAR2 (4000);
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
         d_sql := d_sql || 'count(''';
      END IF;

      d_sql := d_sql || '*';

      IF p_count = 1
      THEN
         d_sql := d_sql || ''')';
      END IF;

      d_sql :=
            d_sql
         || ' from '
         || p_anagrafica
         || ' where to_date('''
         || p_dal
         || ''',''dd/mm/yyyy'') between trunc(nvl(dal, sysdate)) and trunc(nvl(al,sysdate))';


      d_sql :=
            d_sql
         || 'AND (   NVL (tipo_spedizione, ''XXX'') = ''MAIL''
              OR (    NVL (tipo_spedizione, ''XXX'') <> ''MAIL''
                  AND NOT EXISTS
                         (SELECT 1
                            FROM as4_ANAGRAFICI anag,
                                 as4_recapiti reca,
                                 as4_contatti cont,
                                 as4_tipi_contatto tico
                           WHERE     anag.ni = '
         || p_anagrafica
         || '.ni
                                 AND anag.dal = '
         || p_anagrafica
         || '.dal
                                 AND anag.ni = reca.ni(+)
                                 AND reca.id_recapito = cont.id_recapito(+)
                                 AND cont.id_tipo_contatto =
                                        tico.id_tipo_contatto(+)
                                 AND anag.al IS NULL
                                 AND reca.al IS NULL
                                 AND cont.al IS NULL
                                 AND tico.tipo_spedizione = ''MAIL''
                                 AND reca.ID_TIPO_RECAPITO = '
         || p_anagrafica
         || '.ID_TIPO_RECAPITO)))';

      IF p_filtro IS NOT NULL
      THEN
         d_sql := d_sql || ' and ' || p_filtro;
      END IF;

      IF UPPER (p_campo) = 'NI'
      THEN
         d_sql := d_sql || ' and ni = ' || d_ricerca;
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
            || ' and '
            || getCondizioneDenominazione (d_ricerca, p_denom_tipo_ricerca);
      END IF;

      IF p_count = 0
      THEN
         d_sql :=
               d_sql
            || ' order by denominazione, codice_fiscale, to_number(ni), decode(TIPO_INDIRIZZO, ''RESIDENZA'', -1,as4_tipi_recapito_tpk.get_IMPORTANZA(ID_TIPO_RECAPITO)),TIPO_INDIRIZZO';
      END IF;

      DBMS_OUTPUT.put_line (d_sql);

      integritypackage.LOG (d_sql);

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
      d_select            VARCHAR2 (20000);
      d_table             VARCHAR2 (100);
      d_where             VARCHAR2 (32767);
      d_where_base        VARCHAR2 (32767);
      d_where_deno        VARCHAR2 (32767);
      d_denominazione     VARCHAR2 (32767);
      d_colonne                 VARCHAR2(20000);
   BEGIN
   d_colonne :='DENOMINAZIONE,'||
                        'COGNOME,'||
                        'NOME,'||
                        'CODICE_FISCALE,'||
                        'PARTITA_IVA,'||
                        'INDIRIZZO,'||
                        'INDIRIZZO_COMPLETO,'||
                        'CAP,'||
                        'COMUNE,'||
                        'PROVINCIA_SIGLA,'||
                        'EMAIL,'||
                        'FAX,'||
                        'TIPO_SOGGETTO,'||
                        'ANAGRAFICA,'||
                        'COD_AMM,'||
                        'COD_AOO,'||
                        'COD_UO,'||
                        'TO_CHAR(NI),'||
                        'DAL,'||
                        'AL,'||
                        'TIPO_INDIRIZZO,'||
                        'ID_RECAPITO,'||
                        'ID_CONTATTO,'||
                        'CF_ESTERO,'||
                        'ID_TIPO_RECAPITO,'||
                        'TIPO_SPEDIZIONE ';

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
          d_select := 'SELECT '||d_colonne||' FROM ';
         d_table := ' seg_anagrafici_base ';
         d_where := d_where_base || d_where_deno;
         d_statement := d_select || d_table || d_where;
       /*  d_table := ' seg_anagrafici_so4 ';
         d_where := d_where_base || d_where_deno;*/
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_anagrafici_altri ';
         d_where := d_where_base || d_where_deno || ' AND tipo_soggetto <> 3 ';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_anagrafici_altri ';
         d_where :=
               d_where_base
            || d_where_deno
            || ' AND tipo_soggetto = 3 AND tipo_indirizzo = ''SEDE LEGALE''';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_table := ' seg_anagrafici_altri ';
         d_where :=
               d_where_base
            || d_where_deno
            || ' AND tipo_soggetto = 3 AND nvl(tipo_indirizzo, '' '') <> ''SEDE LEGALE''';
         d_where :=
               d_where
            || d_where_deno
            || '  AND NOT EXISTS (SELECT 1 FROM '
            || d_table
            || d_where_base
            || ' AND tipo_soggetto = 3 AND tipo_indirizzo = ''SEDE LEGALE'')';
         d_statement :=
            d_statement || ' UNION ' || d_select || d_table || d_where;
         d_statement_count := 'SELECT COUNT(1) FROM (' || d_statement || ')';
         integritypackage.LOG (d_statement);

         EXECUTE IMMEDIATE d_statement_count INTO d_rows;

         IF d_rows <> 1
         THEN
            d_table := ' seg_soggetti_mv ';
            d_where := ' where codice_fiscale = null ';
            d_statement := 'SELECT * FROM ' || d_table || d_where;
         END IF;
      END IF;

      integritypackage.LOG (d_statement);

      OPEN d_return FOR d_statement;

      RETURN d_return;
   END;

   FUNCTION ricerca_per_amm (
      p_amm                   IN VARCHAR2,
      p_aoo                    IN VARCHAR2,
      p_uo                      IN VARCHAR2)
   RETURN afc.t_ref_cursor
   IS
   d_return            afc.t_ref_cursor;
   d_select             VARCHAR2 (100);
   d_table              VARCHAR2 (100);
   d_where            VARCHAR2 (32767);
   d_rows              NUMBER := 0;
   d_statement     VARCHAR2 (32767);
   BEGIN
         d_select := 'SELECT DISTINCT  * FROM ';
         d_table := ' SEG_ANAGRAFICI ';
         d_where := ' WHERE ';

         IF p_uo IS NULL AND p_aoo IS NULL THEN
               --ricerco per AMM
               d_where := d_where || 'lower(cod_amm) = lower('''||p_amm||''') ';
               d_where := d_where || ' and  nvl(tipo_indirizzo, ''RESIDENZA'') = ''RESIDENZA'' ';
         ELSE
              IF p_uo IS NULL THEN
                --ricerco per AOO
                 d_where := d_where || 'lower(cod_amm) = lower('''||p_amm||''') ';
                 d_where := d_where || ' and lower(cod_aoo) = lower('''||p_aoo||''') ';
              ELSE
                --ricerco per UO
                 d_where := d_where || 'lower(cod_amm) = lower('''||p_amm||''') ';
                 d_where := d_where || ' and lower(cod_uo) =  lower('''||p_uo||''') ';
              END IF;
         END IF;

         d_where := d_where || ' and tipo_soggetto=2 and al is null  ';

         d_statement :=  d_select || d_table || d_where;
        -- dbms_output.put_line( d_statement);
         integritypackage.LOG (d_statement);

        OPEN d_return FOR d_statement;

        RETURN d_return;
   END;

   FUNCTION ricerca_per_ni (
      p_ni                       IN VARCHAR2,
      p_tipo_soggetto   IN NUMBER DEFAULT -1)
   RETURN afc.t_ref_cursor
   IS
   d_return            afc.t_ref_cursor;
   d_select             VARCHAR2 (100);
   d_table              VARCHAR2 (100);
   d_where            VARCHAR2 (32767);
   d_statement      VARCHAR2 (32767);
   BEGIN
         d_select := 'SELECT DISTINCT  * FROM ';
         d_table := ' SEG_ANAGRAFICI ';
         d_where := ' WHERE NI ='||p_ni;
         if nvl(p_tipo_soggetto,-1) <> -1 then
           d_where := d_where || ' and tipo_soggetto= '||p_tipo_soggetto;
         end if;

         d_statement :=  d_select || d_table || d_where;

         integritypackage.LOG (d_statement);

        OPEN d_return FOR d_statement;

        RETURN d_return;
   END;

   --------------------------------------------------------------------------------
   --   FUNCTION ricerca (
   --      p_ricerca         IN VARCHAR2,
   --      p_isquery         IN VARCHAR2,
   --      p_denominazione   IN VARCHAR2,
   --      p_indirizzo       IN VARCHAR2,
   --      p_cf              IN VARCHAR2,
   --      p_pi              IN VARCHAR2,
   --      p_email           IN VARCHAR2,
   --      p_dal             IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
   --      p_tipo_soggetto   IN NUMBER DEFAULT -1)
   --      RETURN afc.t_ref_cursor
   --   IS
   --      /******************************************************************************
   --       NOME:        RICERCA.
   --       DESCRIZIONE: Ricerca in SEG_ANAGRAFICI col seguente criterio:
   --                     se e' un numero
   --                        se e' lungo 11: ricerca per partita iva prima nel campo PI poi
   --                                        nel campo CF;
   --                        altrimenti: ricerca per numero individuale (NI)
   --                     altrimenti: ricerca per denominazione con catsearch.
   --
   --       ARGOMENTI:   p_ricerca    Stringa contenente CF/PI/Denominazione da ricercare.
   --                    p_dal        Data di utilizzo soggetto (formato dd/mm/yyyy).
   --       ECCEZIONI:   - 20999 Soggetto non Disponibile.
   --       ANNOTAZIONI: -
   --       REVISIONI:
   --       Rev. Data       Autore       Descrizione
   --       ---- ---------- ------------ -------------------------------------------------
   --       0    08/02/2010 MMalferrari  Creazione.
   --       1    24/01/2012 MMalferrari  Gestione carattere % all'inizio della stringa di
   --                                    ricerca
   --      ******************************************************************************/
   --      d_dal      VARCHAR2 (10) := NVL (p_dal, TO_CHAR (SYSDATE, 'dd/mm/yyyy'));
   --      d_return   afc.t_ref_cursor;
   --      d_rows     NUMBER;
   --      d_filtro   VARCHAR2 (2000);
   --   BEGIN
   --      IF NVL (p_tipo_soggetto, '-1') <> '-1'
   --      THEN
   --         d_filtro := 'tipo_soggetto = ' || p_tipo_soggetto;
   --      END IF;
   --
   --      IF p_isquery = 'ISQUERY'
   --      THEN
   --         IF     p_denominazione IS NULL
   --            AND p_cf IS NULL
   --            AND p_email IS NULL
   --            AND p_pi IS NULL
   --         THEN
   --            raise_application_error (
   --               -20999,
   --               'Inserire dei parametri di ricerca (denominazione, codice fiscale, partita iva oppure email).');
   --         ELSE
   --            OPEN d_return FOR
   --               SELECT *
   --                 FROM seg_anagrafici
   --                WHERE     (catsearch (
   --                              denominazione,
   --                              REPLACE (
   --                                 REPLACE (UPPER (p_denominazione), '', ''''),
   --                                 '%',
   --                                 '*'),
   --                              NULL) > 0)
   --                      AND NVL (codice_fiscale, '%') LIKE
   --                             ('%' || NVL (UPPER (p_cf), '%') || '%')
   --                      AND NVL (partita_iva, '%') LIKE
   --                             ('%' || NVL (UPPER (p_pi), '%') || '%')
   --                      AND NVL (indirizzo, '%') LIKE
   --                             ('%' || NVL (UPPER (p_indirizzo), '%') || '%')
   --                      AND NVL (UPPER (email), '%') LIKE
   --                             ('%' || NVL (UPPER (p_email), '%') || '%')
   --                      AND NVL (p_dal, (SYSDATE)) BETWEEN TRUNC (
   --                                                            NVL (dal,
   --                                                                 SYSDATE))
   --                                                     AND TRUNC (
   --                                                            NVL (al, SYSDATE))
   --                      AND p_denominazione IS NOT NULL
   --                      AND (   tipo_soggetto = p_tipo_soggetto
   --                           OR p_tipo_soggetto = -1)
   --               UNION
   --               SELECT *
   --                 FROM seg_anagrafici
   --                WHERE     NVL (codice_fiscale, '%') LIKE
   --                             ('%' || NVL (UPPER (p_cf), '%') || '%')
   --                      AND NVL (partita_iva, '%') LIKE
   --                             ('%' || NVL (UPPER (p_pi), '%') || '%')
   --                      AND NVL (indirizzo, '%') LIKE
   --                             ('%' || NVL (UPPER (p_indirizzo), '%') || '%')
   --                      AND NVL (UPPER (email), '%') LIKE
   --                             ('%' || NVL (UPPER (p_email), '%') || '%')
   --                      AND NVL (p_dal, TRUNC (SYSDATE)) BETWEEN TRUNC (
   --                                                                  NVL (
   --                                                                     dal,
   --                                                                     SYSDATE))
   --                                                           AND TRUNC (
   --                                                                  NVL (
   --                                                                     al,
   --                                                                     SYSDATE))
   --                      AND p_denominazione IS NULL
   --                      AND (   tipo_soggetto = p_tipo_soggetto
   --                           OR p_tipo_soggetto = -1);
   --         END IF;
   --
   --         RETURN d_return;
   --      ELSE
   --         IF p_ricerca IS NULL
   --         THEN
   --            raise_application_error (
   --               -20999,
   --               'Scrivere correttamente il codice fiscale oppure la partita iva oppure parte della denominazione del soggetto (almeno 3 caratteri).');
   --         END IF;
   --
   --         IF LENGTH (p_ricerca) > 240
   --         THEN
   --            raise_application_error (
   --               -20999,
   --               'Denominazione troppo lunga (lunghezza massima 240)!');
   --         END IF;
   --
   --         -- Lettura Anagrafe Soggetti;
   --         IF afc.is_number (p_ricerca) = 1
   --         THEN
   --            -----------------------------------------------------------------------
   --            --                 Ricerca per NI o PARTITA IVA o CF
   --            -----------------------------------------------------------------------
   --            IF LENGTH (p_ricerca) = 11
   --            THEN
   --               -- se e' lungo 11 prova per PI.
   --               d_return :=
   --                  ricerca_per_campo ('PI',
   --                                     p_ricerca,
   --                                     1,
   --                                     d_filtro,
   --                                     d_dal);
   --
   --               FETCH d_return INTO d_rows;
   --
   --               IF d_rows > 0
   --               THEN
   --                  CLOSE d_return;
   --
   --                  d_return :=
   --                     ricerca_per_campo ('PI',
   --                                        p_ricerca,
   --                                        0,
   --                                        d_filtro,
   --                                        d_dal);
   --                  RETURN d_return;
   --               ELSE
   --                  -- cerca PI in campo CF
   --                  d_return :=
   --                     ricerca_per_campo ('CF',
   --                                        p_ricerca,
   --                                        1,
   --                                        d_filtro,
   --                                        d_dal);
   --
   --                  FETCH d_return INTO d_rows;
   --
   --                  IF d_rows > 0
   --                  THEN
   --                     CLOSE d_return;
   --
   --                     d_return :=
   --                        ricerca_per_campo ('CF',
   --                                           p_ricerca,
   --                                           0,
   --                                           d_filtro,
   --                                           d_dal);
   --                     RETURN d_return;
   --                  END IF;
   --               END IF;
   --            END IF;
   --
   --            IF d_return%ISOPEN
   --            THEN
   --               CLOSE d_return;
   --            END IF;
   --
   --            d_return :=
   --               ricerca_per_campo ('NI',
   --                                  p_ricerca,
   --                                  1,
   --                                  d_filtro,
   --                                  d_dal);
   --
   --            FETCH d_return INTO d_rows;
   --
   --            CLOSE d_return;
   --
   --            d_return :=
   --               ricerca_per_campo ('NI',
   --                                  p_ricerca,
   --                                  0,
   --                                  d_filtro,
   --                                  d_dal);
   --            RETURN d_return;
   --         ELSE
   --            --------------------------------------------------------------------------------
   --            --                 Ricerca per EMAIL
   --            --------------------------------------------------------------------------------
   --            IF INSTR (p_ricerca, '@') > 0
   --            THEN
   --               d_return :=
   --                  ricerca_per_campo ('EMAIL',
   --                                     p_ricerca,
   --                                     1,
   --                                     d_filtro,
   --                                     d_dal);
   --
   --               FETCH d_return INTO d_rows;
   --
   --               IF d_rows > 0
   --               THEN
   --                  CLOSE d_return;
   --
   --                  d_return :=
   --                     ricerca_per_campo ('EMAIL',
   --                                        p_ricerca,
   --                                        0,
   --                                        d_filtro,
   --                                        d_dal);
   --                  RETURN d_return;
   --               END IF;
   --            END IF;
   --
   --            --------------------------------------------------------------------------------
   --            --                 Ricerca per CODICE FISCALE
   --            --------------------------------------------------------------------------------
   --            IF LENGTH (p_ricerca) = 16
   --            THEN
   --               d_return :=
   --                  ricerca_per_campo ('CF',
   --                                     p_ricerca,
   --                                     1,
   --                                     d_filtro,
   --                                     d_dal);
   --
   --               FETCH d_return INTO d_rows;
   --
   --               IF d_rows > 0
   --               THEN
   --                  CLOSE d_return;
   --
   --                  d_return :=
   --                     ricerca_per_campo ('CF',
   --                                        p_ricerca,
   --                                        0,
   --                                        d_filtro,
   --                                        d_dal);
   --                  RETURN d_return;
   --               END IF;
   --            END IF;
   --
   --            --------------------------------------------------------------------------------
   --            --                        Ricerca per DENOMINAZIONE
   --            --------------------------------------------------------------------------------
   --            IF d_return%ISOPEN
   --            THEN
   --               CLOSE d_return;
   --            END IF;
   --
   --            d_return :=
   --               ricerca_per_campo ('DENOMINAZIONE',
   --                                  p_ricerca,
   --                                  1,
   --                                  d_filtro,
   --                                  d_dal);
   --
   --            FETCH d_return INTO d_rows;
   --
   --            CLOSE d_return;
   --
   --            d_return :=
   --               ricerca_per_campo ('DENOMINAZIONE',
   --                                  p_ricerca,
   --                                  0,
   --                                  d_filtro,
   --                                  d_dal);
   --            RETURN d_return;
   --         END IF;
   --      END IF;
   --   END;

   --------------------------------------------------------------------------------



   FUNCTION ricerca_anagrafici (
      p_ricerca              IN VARCHAR2,
      p_isquery              IN VARCHAR2,
      p_denominazione        IN VARCHAR2,
      p_indirizzo            IN VARCHAR2,
      p_cf                   IN VARCHAR2,
      p_pi                   IN VARCHAR2,
      p_email                IN VARCHAR2,
      p_dal                  IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto        IN NUMBER DEFAULT -1,
      p_anagrafica           IN VARCHAR2 DEFAULT 'SEG_ANAGRAFICI',
      p_cf_estero            IN VARCHAR2 DEFAULT NULL,
      p_denom_tipo_ricerca   IN VARCHAR2 DEFAULT NULL,
      p_escudi_ricerca_ni IN NUMBER DEFAULT 0)
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
      ******************************************************************************/
      d_dal             VARCHAR2 (10) := NVL (p_dal, TO_CHAR (SYSDATE, 'dd/mm/yyyy'));
      d_return          afc.t_ref_cursor;
      d_rows            NUMBER;
      d_filtro          VARCHAR2 (2000);
      d_stmt_cursor     VARCHAR2 (32000);
      d_denominazione   VARCHAR2 (4000) := p_denominazione;
   BEGIN
      IF NVL (p_tipo_soggetto, '-1') <> '-1'
      THEN
         d_filtro := 'tipo_soggetto = ' || p_tipo_soggetto;
      END IF;

      IF p_isquery = 'ISQUERY'
      THEN
         IF     p_denominazione IS NULL
            AND p_cf IS NULL
            AND p_email IS NULL
            AND p_pi IS NULL
            AND p_cf_estero IS NULL
         THEN
            raise_application_error (
               -20999,
               'Inserire dei parametri di ricerca (denominazione, codice fiscale, id fiscale estero,  partita iva oppure email).');
         ELSE
            d_stmt_cursor :=
                  'SELECT * '
               || '  FROM '
               || p_anagrafica
               || ' WHERE  '
               || getCondizioneDenominazione (p_denominazione,
                                              p_denom_tipo_ricerca)
               || '      AND NVL (codice_fiscale, ''%'') LIKE '''
               || ('%' || NVL (UPPER (p_cf), '%') || '%')
               || ''''
               || '      AND NVL (cf_estero, ''%'') LIKE '''
               || ('%' || NVL (p_cf_estero, '%') || '%')
               || ''''
               || '      AND NVL (partita_iva, ''%'') LIKE '''
               || ('%' || NVL (UPPER (p_pi), '%') || '%')
               || ''''
               || '      AND NVL (indirizzo, ''%'') LIKE '''
               || ('%' || NVL (UPPER (p_indirizzo), '%') || '%')
               || ''''
               || '      AND NVL (UPPER (email), ''%'') = '''
               || (     NVL (UPPER (p_email), '%') )
               || ''''
               || '      AND to_date ('''
               || d_dal
               || ''', ''dd/mm/yyyy'') BETWEEN TRUNC ('
               || '                                           NVL (dal, SYSDATE))'
               || '                                     AND TRUNC ('
               || '                                            NVL (al, SYSDATE))'
               || '      AND '''
               || REPLACE (p_denominazione, '''', '''''')
               || ''' IS NOT NULL '
               || '      AND (   tipo_soggetto = '''
               || p_tipo_soggetto
               || ''''
               || '          OR '
               || p_tipo_soggetto
               || ' = -1)'
               || 'UNION '
               || 'SELECT * '
               || '  FROM '
               || p_anagrafica
               || ' WHERE     NVL (codice_fiscale, ''%'') LIKE '''
               || ('%' || NVL (UPPER (p_cf), '%') || '%')
               || ''''
               || '      AND NVL (cf_estero, ''%'') LIKE '''
               || ('%' || NVL (p_cf_estero, '%') || '%')
               || ''''
               || '   AND NVL (partita_iva, ''%'') LIKE '''
               || ('%' || NVL (UPPER (p_pi), '%') || '%')
               || ''''
               || '   AND NVL (indirizzo, ''%'') LIKE '''
               || ('%' || NVL (UPPER (p_indirizzo), '%') || '%')
               || ''''
               || '   AND NVL (UPPER (email), ''%'') = '''
               || (  NVL (UPPER (p_email), '%') )
               || ''''
               || '      AND to_date ('''
               || d_dal
               || ''', ''dd/mm/yyyy'')  BETWEEN TRUNC ('
               || '                                           NVL (dal, SYSDATE))'
               || '                                     AND TRUNC ('
               || '                                            NVL (al, SYSDATE))'
               || '   AND '''
               || REPLACE (p_denominazione, '''', '''''')
               || ''' IS NULL '
               || '   AND (   tipo_soggetto = '''
               || p_tipo_soggetto
               || ''''
               || '          OR '
               || p_tipo_soggetto
               || ' = -1)';
            DBMS_OUTPUT.put_line (d_stmt_cursor);

            OPEN d_return FOR d_stmt_cursor;
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
                                     d_dal,
                                     p_anagrafica,
                                     p_denom_tipo_ricerca);

               FETCH d_return INTO d_rows;

               IF d_rows > 0
               THEN
                  CLOSE d_return;

                  d_return :=
                     ricerca_per_campo ('PI',
                                        p_ricerca,
                                        0,
                                        d_filtro,
                                        d_dal,
                                        p_anagrafica,
                                        p_denom_tipo_ricerca);
                  RETURN d_return;
               ELSE
                  -- cerca PI in campo CF
                  d_return :=
                     ricerca_per_campo ('CF',
                                        p_ricerca,
                                        1,
                                        d_filtro,
                                        d_dal,
                                        p_anagrafica,
                                        p_denom_tipo_ricerca);

                  FETCH d_return INTO d_rows;

                  IF d_rows > 0
                  THEN
                     CLOSE d_return;

                     d_return :=
                        ricerca_per_campo ('CF',
                                           p_ricerca,
                                           0,
                                           d_filtro,
                                           d_dal,
                                           p_anagrafica,
                                           p_denom_tipo_ricerca);
                     RETURN d_return;
                  END IF;
               END IF;
            END IF;

            IF d_return%ISOPEN
            THEN
               CLOSE d_return;
            END IF;

            IF p_escudi_ricerca_ni=0 THEN
                d_return :=
                   ricerca_per_campo ('NI',
                                      p_ricerca,
                                      1,
                                      d_filtro,
                                      d_dal,
                                      p_anagrafica,
                                      p_denom_tipo_ricerca);

                FETCH d_return INTO d_rows;

                CLOSE d_return;

                d_return :=
                   ricerca_per_campo ('NI',
                                      p_ricerca,
                                      0,
                                      d_filtro,
                                      d_dal,
                                      p_anagrafica,
                                      p_denom_tipo_ricerca);
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
                                     d_dal,
                                     p_anagrafica,
                                     p_denom_tipo_ricerca);

               FETCH d_return INTO d_rows;

               IF d_rows > 0
               THEN
                  CLOSE d_return;

                  d_return :=
                     ricerca_per_campo ('EMAIL',
                                        p_ricerca,
                                        0,
                                        d_filtro,
                                        d_dal,
                                        p_anagrafica,
                                        p_denom_tipo_ricerca);
                  RETURN d_return;
               END IF;
            END IF;

            --------------------------------------------------------------------------------
            --                 Ricerca per CODICE FISCALE
            --------------------------------------------------------------------------------
            IF LENGTH (p_ricerca) = 16
            THEN
               d_return :=
                  ricerca_per_campo ('CF',
                                     p_ricerca,
                                     1,
                                     d_filtro,
                                     d_dal,
                                     p_anagrafica,
                                     p_denom_tipo_ricerca);

               FETCH d_return INTO d_rows;

               IF d_rows > 0
               THEN
                  CLOSE d_return;

                  d_return :=
                     ricerca_per_campo ('CF',
                                        p_ricerca,
                                        0,
                                        d_filtro,
                                        d_dal,
                                        p_anagrafica,
                                        p_denom_tipo_ricerca);
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
                                  d_dal,
                                  p_anagrafica,
                                  p_denom_tipo_ricerca);

            FETCH d_return INTO d_rows;

            CLOSE d_return;

            d_return :=
               ricerca_per_campo ('DENOMINAZIONE',
                                  p_ricerca,
                                  0,
                                  d_filtro,
                                  d_dal,
                                  p_anagrafica,
                                  p_denom_tipo_ricerca);
            RETURN d_return;
         END IF;
      END IF;
   END;

   FUNCTION ricerca (
      p_ricerca              IN VARCHAR2,
      p_isquery              IN VARCHAR2,
      p_denominazione        IN VARCHAR2,
      p_indirizzo            IN VARCHAR2,
      p_cf                   IN VARCHAR2,
      p_pi                   IN VARCHAR2,
      p_email                IN VARCHAR2,
      p_dal                  IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto        IN NUMBER DEFAULT -1,
      p_cf_estero            IN VARCHAR2 DEFAULT NULL,
      p_denom_tipo_ricerca   IN VARCHAR2 DEFAULT NULL,
      p_escudi_ricerca_ni IN NUMBER DEFAULT 0)
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
   ******************************************************************************/
   BEGIN
      RETURN ricerca_anagrafici (
                p_ricerca              => p_ricerca,
                p_isquery              => p_isquery,
                p_denominazione        => p_denominazione,
                p_indirizzo            => p_indirizzo,
                p_cf                   => p_cf,
                p_pi                   => p_pi,
                p_email                => p_email,
                p_dal                  => p_dal,
                p_tipo_soggetto        => p_tipo_soggetto,
                p_anagrafica           => 'SEG_ANAGRAFICI',
                p_cf_estero            => p_cf_estero,
                p_denom_tipo_ricerca   => p_denom_tipo_ricerca,
                p_escudi_ricerca_ni => p_escudi_ricerca_ni);
   END;

   FUNCTION ricerca_anagrafici_base (
      p_ricerca         IN VARCHAR2,
      p_isquery         IN VARCHAR2,
      p_denominazione   IN VARCHAR2,
      p_indirizzo       IN VARCHAR2,
      p_cf              IN VARCHAR2,
      p_pi              IN VARCHAR2,
      p_email           IN VARCHAR2,
      p_dal             IN VARCHAR2 DEFAULT TO_CHAR (SYSDATE, 'dd/mm/yyyy'),
      p_tipo_soggetto   IN NUMBER DEFAULT -1)
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
      ******************************************************************************/
      d_dal      VARCHAR2 (10) := NVL (p_dal, TO_CHAR (SYSDATE, 'dd/mm/yyyy'));
      d_return   afc.t_ref_cursor;
      d_rows     NUMBER;
      d_filtro   VARCHAR2 (2000);
   BEGIN
      RETURN ricerca_anagrafici (p_ricerca         => p_ricerca,
                                 p_isquery         => p_isquery,
                                 p_denominazione   => p_denominazione,
                                 p_indirizzo       => p_indirizzo,
                                 p_cf              => p_cf,
                                 p_pi              => p_pi,
                                 p_email           => p_email,
                                 p_dal             => p_dal,
                                 p_tipo_soggetto   => p_tipo_soggetto,
                                 p_anagrafica      => 'SEG_ANAGRAFICI_BASE');
   END;

   FUNCTION get_indirizzi_amm (p_cod_amm    VARCHAR2,
                               p_cod_aoo    VARCHAR2,
                               p_cod_uo     VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_return   afc.t_ref_cursor;
   BEGIN
      OPEN d_return FOR
         SELECT descrizione_amm descrizione,
                cod_amm codice,
                indirizzo_amm indirizzo,
                cap_amm cap,
                comune_amm comune,
                sigla_prov_amm provincia_sigla,
                mail_amm email,
                fax_amm fax,
                'AMM' tipo_indirizzo,
                1 ordinamento
           FROM SEG_AMM_AOO_UO_TAB
          WHERE cod_amm = p_cod_amm AND tipo = 'AMM'
         UNION
         SELECT descrizione_amm,
                cod_amm,
                indirizzo_amm indirizzo,
                cap_amm cap,
                comune_amm comune,
                sigla_prov_amm provincia_sigla,
                mail_amm email,
                fax_amm fax,
                'AMM' tipo_indirizzo,
                1 ordinamento
           FROM SEG_AMM_AOO_UO_TAB
          WHERE cod_amm = p_cod_amm AND cod_aoo = p_cod_aoo AND tipo = 'AOO'
         UNION
         SELECT descrizione_amm,
                cod_amm,
                indirizzo_amm indirizzo,
                cap_amm cap,
                comune_amm comune,
                sigla_prov_amm provincia_sigla,
                mail_amm email,
                fax_amm fax,
                'AMM' tipo_indirizzo,
                1 ordinamento
           FROM SEG_AMM_AOO_UO_TAB
          WHERE cod_amm = p_cod_amm AND cod_uo = p_cod_uo AND tipo = 'UO'
         UNION
         SELECT descrizione_aoo,
                cod_aoo,
                indirizzo_aoo indirizzo,
                cap_aoo cap,
                comune_aoo comune,
                sigla_prov_aoo provincia_sigla,
                mail_aoo email,
                fax_aoo fax,
                'AOO' tipo_indirizzo,
                2 ordinamento
           FROM SEG_AMM_AOO_UO_TAB
          WHERE cod_amm = p_cod_amm AND cod_aoo = p_cod_aoo AND tipo = 'AOO'
         UNION
         SELECT descrizione_uo,
                cod_uo,
                indirizzo_uo indirizzo,
                cap_uo cap,
                comune_uo comune,
                sigla_prov_uo provincia_sigla,
                mail_uo email,
                fax_uo fax,
                'UO' tipo_indirizzo,
                3 ordinamento
           FROM SEG_AMM_AOO_UO_TAB
          WHERE cod_amm = p_cod_amm AND cod_uo = p_cod_uo AND tipo = 'UO'
         ORDER BY ordinamento;

      RETURN d_return;
   END;

   FUNCTION get_componenti_lista (P_ID_LISTA NUMBER)
      RETURN afc.t_ref_cursor
   IS
      d_return         afc.t_ref_cursor;
      d_codice_lista   VARCHAR2 (8);
   BEGIN
      SELECT codice
        INTO d_codice_lista
        FROM agp_liste_distribuzione
       WHERE id_lista = p_id_lista;

      OPEN d_return FOR
           SELECT DENOMINAZIONE,
                  COGNOME,
                  NOME,
                  CODICE_FISCALE,
                  PARTITA_IVA,
                  INDIRIZZO,
                  TRIM (
                        INDIRIZZO
                     || DECODE (cap, NULL, '', ' ' || CAP)
                     || DECODE (comune, NULL, '', ' ' || COMUNE)
                     || DECODE (PROVINCIA_SIGLA,
                                NULL, '',
                                ' (' || PROVINCIA_SIGLA || ')'))
                     INDIRIZZO_COMPLETO,
                  CAP,
                  COMUNE,
                  PROVINCIA_SIGLA,
                  EMAIL,
                  FAX,
                  DECODE (COD_AMM, NULL, 1, 2) TIPO_SOGGETTO,
                  DECODE (COD_AMM, NULL, 'Soggetto', 'Amministrazione')
                     ANAGRAFICA,
                  COD_AMM,
                  COD_AOO,
                  COD_UO,
                  NI,
                  NULL DAL,
                  NULL AL,
                  DECODE (
                     COD_UO,
                     NULL, DECODE (COD_AOO,
                                   NULL, DECODE (COD_AMM, NULL, NULL, 'AMM'),
                                   'AOO'),
                     'UO')
                     TIPO_INDIRIZZO,
                  NULL CF_ESTERO
             FROM AGP_LISTE_DISTRIB_COMPONENTI LDCO, gdm_documenti d
            WHERE     d.id_documento = LDCO.id_documento_esterno
                  AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                  AND LDCO.CODICE_LISTA = d_codice_lista
         /*         SELECT DENOMINAZIONE,
                         COGNOME,
                         NOME,
                         CODICE_FISCALE,
                         PARTITA_IVA,
                         INDIRIZZO,
                         INDIRIZZO_COMPLETO,
                         CAP,
                         COMUNE,
                         PROVINCIA_SIGLA,
                         EMAIL,
                         FAX,
                         TIPO_SOGGETTO,
                         ANAGRAFICA,
                         ANAG.COD_AMM,
                         ANAG.COD_AOO,
                         ANAG.COD_UO,
                         ANAG.NI,
                         DAL,
                         AL,
                         TIPO_INDIRIZZO
                    FROM seg_anagrafici_base ANAG,
                         AGP_LISTE_DISTRIB_COMPONENTI LDCO,
                         gdm_documenti d
                   WHERE     LDCO.NI IS NULL
                         AND ANAG.COD_AMM = LDCO.COD_AMM
                         AND NVL (ANAG.COD_AOO, ' ') = NVL (LDCO.COD_AOO, ' ')
                         AND NVL (ANAG.COD_UO, ' ') = NVL (LDCO.COD_UO, ' ')
                         AND d.id_documento = LDCO.id_documento_esterno
                         AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                         --AND LDCO.ID_LISTA = P_ID_LISTA
                         AND LDCO.CODICE_LISTA = d_codice_lista
                         AND NVL(LDCO.ID_RECAPITO, 0) = NVL(ANAG.ID_RECAPITO (+), 0)
                         AND NVL(LDCO.ID_CONTATTO, 0) = NVL(ANAG.ID_CONTATTO (+), 0)
                  UNION
                  SELECT DENOMINAZIONE,
                         COGNOME,
                         NOME,
                         CODICE_FISCALE,
                         PARTITA_IVA,
                         INDIRIZZO,
                         INDIRIZZO_COMPLETO,
                         CAP,
                         COMUNE,
                         PROVINCIA_SIGLA,
                         EMAIL,
                         FAX,
                         TIPO_SOGGETTO,
                         'A' ANAGRAFICA,
                         '' COD_AMM,
                         '' COD_AOO,
                         '' COD_UO,
                         SOGG.NI,
                         SOGG.DAL,
                         SOGG.AL,
                         TIPO_INDIRIZZO
                    FROM seg_anagrafici_base SOGG,
                         AGP_LISTE_DISTRIB_COMPONENTI LDCO,
                         gdm_documenti d
                   WHERE     LDCO.NI = SOGG.NI
                         AND d.id_documento = LDCO.id_documento_esterno
                         AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                         AND SYSDATE BETWEEN SOGG.DAL
                                         AND NVL (SOGG.AL, TO_DATE ('3333333', 'J'))
                         --AND LDCO.ID_LISTA = P_ID_LISTA
                         AND LDCO.CODICE_LISTA = d_codice_lista
                         AND LDCO.ID_RECAPITO = SOGG.ID_RECAPITO
                         AND NVL(LDCO.ID_CONTATTO, 0) = NVL(SOGG.ID_CONTATTO, 0)
                         AND LDCO.ID_RECAPITO is not null
                  UNION
                  SELECT DENOMINAZIONE,
                         COGNOME,
                         NOME,
                         CODICE_FISCALE,
                         PARTITA_IVA,
                         INDIRIZZO,
                         INDIRIZZO_COMPLETO,
                         CAP,
                         COMUNE,
                         PROVINCIA_SIGLA,
                         EMAIL,
                         FAX,
                         TIPO_SOGGETTO,
                         'A' ANAGRAFICA,
                         '' COD_AMM,
                         '' COD_AOO,
                         '' COD_UO,
                         SOGG.NI,
                         SOGG.DAL,
                         SOGG.AL,
                         TIPO_INDIRIZZO
                    FROM seg_anagrafici_base SOGG,
                         AGP_LISTE_DISTRIB_COMPONENTI LDCO,
                         gdm_documenti d
                   WHERE     LDCO.NI = SOGG.NI
                         AND d.id_documento = LDCO.id_documento_esterno
                         AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                         AND SYSDATE BETWEEN SOGG.DAL
                                         AND NVL (SOGG.AL, TO_DATE ('3333333', 'J'))
                         --AND LDCO.ID_LISTA = P_ID_LISTA
                         AND LDCO.CODICE_LISTA = d_codice_lista
                         AND LDCO.ID_RECAPITO is null
                         and not exists (select 1
                                           from seg_anagrafici_base
                                          where LDCO.NI = seg_anagrafici_base.ni
                                            and seg_anagrafici_base.id_recapito is not null)
                  UNION
                  SELECT DENOMINAZIONE,
                         COGNOME,
                         NOME,
                         CODICE_FISCALE,
                         PARTITA_IVA,
                         INDIRIZZO,
                         INDIRIZZO_COMPLETO,
                         CAP,
                         COMUNE,
                         PROVINCIA_SIGLA,
                         EMAIL,
                         FAX,
                         TIPO_SOGGETTO,
                         'A' ANAGRAFICA,
                         '' COD_AMM,
                         '' COD_AOO,
                         '' COD_UO,
                         SOGG.NI,
                         SOGG.DAL,
                         SOGG.AL,
                         TIPO_INDIRIZZO
                    FROM seg_anagrafici_base SOGG,
                         AGP_LISTE_DISTRIB_COMPONENTI LDCO,
                         (select ni, id_recapito
                            from as4_recapiti reca
                           where id_tipo_recapito = 1) residenze,
                         gdm_documenti d
                   WHERE     LDCO.NI = SOGG.NI
                         AND d.id_documento = LDCO.id_documento_esterno
                         AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                         AND SYSDATE BETWEEN SOGG.DAL
                                         AND NVL (SOGG.AL, TO_DATE ('3333333', 'J'))
                         --AND LDCO.ID_LISTA = P_ID_LISTA
                         AND LDCO.CODICE_LISTA = d_codice_lista
                         AND LDCO.ID_RECAPITO is null
                         AND SOGG.ni = residenze.ni
                         AND SOGG.id_recapito = residenze.id_recapito*/
         ORDER BY 1;

      RETURN d_return;
   END;
END;
/
