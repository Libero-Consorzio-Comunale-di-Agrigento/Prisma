--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_RICERCA runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_UTILITIES_RICERCA
AS
/******************************************************************************
   NAME:       AG_UTILITIES_RICERCA
   PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI per le ricerche.
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/11/2007           1.     Created this package.
******************************************************************************/
/*****************************************************************************
    NOME:        GET_NUMERO_FASCICOLO_RICERCA.
    DESCRIZIONE: Dato un numero di fascicolo lo restituisce concatenando gli zeri per gestire
                      l'ordinamento in manierca corretta..

    INPUT  p_numero_fascicolo          VARCHAR2

    OUTPUT numero di fascicolo con l'aggiunta degli zeri per l'ordinamento

    Rev.  Data       Autore  Descrizione.
    00    08/11/2007  LT  Prima emissione.
********************************************************************************/
   FUNCTION get_numero_fascicolo_ricerca (p_numero_fascicolo VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION ordinamento_in_titolario (p_oggetto NUMBER, p_tipo_ordinamento varchar2 default null)
      RETURN VARCHAR2;
   FUNCTION get_stringa_per_contains (p_stringa_in VARCHAR2)
      RETURN VARCHAR2;
END ag_utilities_ricerca;
/
CREATE OR REPLACE PACKAGE BODY     AG_UTILITIES_RICERCA
AS
   /********************************************************
   VARIABILI GLOBALI
   *********************************************************/

   /******************************************************************************
      NAME:       AG_UTILITIES_RICERCA
      PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0       09/11/2007             1. Created this package body.
   ******************************************************************************/

   /*****************************************************************************
    NOME:        GET_NUMERO_FASCICOLO_RICERCA.
    DESCRIZIONE: Dato un numero di fascicolo lo restituisce concatenando gli zeri per gestire
                      l'ordinamento in manierca corretta..

    INPUT  p_numero_fascicolo          VARCHAR2

    OUTPUT numero di fascicolo con l'aggiunta degli zeri per l'ordinamento

    Rev.  Data       Autore  Descrizione.
    00    08/11/2007  LT  Prima emissione.
   ********************************************************************************/
   FUNCTION get_stringa_per_contains (p_stringa_in VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN REPLACE (REPLACE (TRIM (p_stringa_in), ' ', ' and '), '-', '\-');
   END;

   FUNCTION get_numero_fascicolo_ricerca (p_numero_fascicolo VARCHAR2)
      RETURN VARCHAR2
   IS
      numero_fascicolo_ricerca   VARCHAR2 (100);
      dep_numero_fascicolo       VARCHAR2 (100) := p_numero_fascicolo;
      dep_parte_fascicolo        VARCHAR2 (100);
   BEGIN
      WHILE     LENGTH (dep_numero_fascicolo) <> 0
            AND INSTR (dep_numero_fascicolo, '.') <> 0
      LOOP
         dep_parte_fascicolo :=
            LPAD (
               SUBSTR (dep_numero_fascicolo,
                       1,
                       INSTR (dep_numero_fascicolo, '.')),
               8,
               '0');
         dep_numero_fascicolo :=
            REPLACE (dep_numero_fascicolo, LTRIM (dep_parte_fascicolo, '0'));
         numero_fascicolo_ricerca :=
            numero_fascicolo_ricerca || dep_parte_fascicolo;
      END LOOP;

      numero_fascicolo_ricerca :=
         numero_fascicolo_ricerca || LPAD (dep_numero_fascicolo, 7, '0');
      RETURN numero_fascicolo_ricerca;
   EXCEPTION
      WHEN OTHERS
      THEN
         numero_fascicolo_ricerca := p_numero_fascicolo;
         RETURN numero_fascicolo_ricerca;
   END get_numero_fascicolo_ricerca;

   FUNCTION ordinamento_in_titolario (p_oggetto             NUMBER,
                                      p_tipo_ordinamento    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_ordinamento           links.ordinamento%TYPE;
      d_categoria             categorie.categoria%TYPE;
      d_is_protocollato       NUMBER;
      d_tabella               VARCHAR2 (32000);
      d_codice_modello        tipi_documento.nome%TYPE;
      d_area_modello          aree.area%TYPE;
      d_data_creazione        VARCHAR2 (100);
      d_nome_campo_registro   VARCHAR2 (100);
      d_nome_campo_data       varchar2 (100);
      d_nome_campo_numero     varchar2 (100);
      d_statement             VARCHAR2 (32767);
      d_tipo_ordinamento      VARCHAR2 (100);
   BEGIN
      d_tipo_ordinamento :=
         NVL (
            p_tipo_ordinamento,
            NVL (
               AG_PARAMETRO.GET_VALORE ('ORDINAMENTO_FASC', '@agStrut@', ''),
               'ANNO_DESC_DATA_ASC'));

      SELECT f_nome_tabella (tido.area_modello, tido.nome),
             tido.nome,
             tido.area_modello
        INTO d_tabella, d_codice_modello, d_area_modello
        FROM documenti docu, tipi_documento tido
       WHERE     docu.id_documento = p_oggetto
             AND docu.id_tipodoc = tido.id_tipodoc;

      integritypackage.LOG ('d_tabella ' || d_tabella);
      integritypackage.LOG ('d_codice_modello ' || d_codice_modello);
      integritypackage.LOG ('d_area_modello ' || d_area_modello);
      integritypackage.LOG ('d_tipo_ordinamento ' || d_tipo_ordinamento);

      IF d_tabella IN ('SAM_VERBALE_DELIBERA',
                       'SAM_DELIBERA_GS4',
                       'SAT_DELIBERA',
                       'SAT_DETERMINA',
                       'SAM_DETE_DETERMINA',
                       'GAT_DELIBERA',
                       'GAT_DETERMINA',
                       'GAT_SEDUTA_STAMPA')
      THEN
         BEGIN
            IF d_tabella IN ('SAT_DELIBERA', 'SAT_DETERMINA', 'GAT_DELIBERA', 'GAT_DETERMINA',  'GAT_SEDUTA_STAMPA')
            THEN
               d_nome_campo_registro := 'TIPO_REGISTRO';
            ELSE
               d_nome_campo_registro := 'TIPO_REGISTRO_SCELTA';
            END IF;

            IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
            THEN
               d_statement :=
                  'SELECT 9999 -  LPAD (NVL (TO_NUMBER (anno), 0), 4)
                             || TO_CHAR (NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss'')';
            ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
            THEN
               d_statement :=
                  'SELECT LPAD (NVL (TO_NUMBER (anno), 0), 4)
                             || TO_CHAR (NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss'')';
            ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
            THEN
               d_statement :=
                  'SELECT 9999 -  LPAD (NVL (TO_NUMBER (anno), 0), 4)
                             || 99991231235959 - to_number(TO_CHAR(NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''j''))';
            END IF;

            d_statement :=
                  d_statement
               || '|| ''001''
                   || LPAD (NVL('
               || d_nome_campo_registro
               || ', ''z''), 4, ''z'')
                   || LPAD (NVL (TO_NUMBER (numero), 0), 20, 0)'
               || '  FROM '
               || d_tabella
               || ' WHERE id_documento = '
               || p_oggetto
               || '   AND anno is not null';

            IF d_tabella IN ('SAM_DETE_DETERMINA', 'SAT_DETERMINA')
            THEN
               d_statement := d_statement || ' AND n_determina is not null';
            END IF;

            if d_tabella in ('GAT_DETERMINA') then
               d_statement   := d_statement || ' AND numero_determina is not null';
            end if;

            if d_tabella in ('GAT_DELIBERA') then
               d_statement   := d_statement || ' AND numero_delibera is not null';
            end if;

            integritypackage.LOG (d_statement);

            EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  if d_tabella in ('GAT_SEDUTA_STAMPA') then
                     d_nome_campo_data     := 'DATA_INS';
                     d_nome_campo_numero   := 'NUMERO';
                  else
                      if d_tabella in ('GAT_DETERMINA') then
                         d_nome_campo_data     := 'DATA_NUMERO_DETERMINA';
                         d_nome_campo_numero   := 'NUMERO_DETERMINA';
                      else
                         if d_tabella in ('GAT_DELIBERA') then
                            d_nome_campo_data     := 'DATA_NUMERO_DELIBERA';
                            d_nome_campo_numero   := 'NUMERO_DELIBERA';
                         else
                            d_nome_campo_data     := 'DATA_REG_DETERMINA';
                            d_nome_campo_numero   := 'N_DETERMINA';
                         end if;
                      end if;
                  end if;

                  IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
                  THEN
                     d_statement :=
                        'SELECT 9999 -  LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                                   || TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss'')';
                  ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
                  THEN
                     d_statement :=
                        'SELECT LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                                   || TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss'')';
                  ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
                  THEN
                     d_statement :=
                        'SELECT 9999 -  LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                                   || 99991231235959 - to_number(TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss''))';
                  END IF;

                  IF d_tabella IN ('SAM_DETE_DETERMINA', 'SAT_DETERMINA', 'GAT_DETERMINA', 'GAT_DELIBERA', 'GAT_SEDUTA_STAMPA')
                  THEN
                     d_statement := d_statement || '|| ''003''';
                  ELSE
                     d_statement := d_statement || '|| ''002''';
                  END IF;

                  d_statement :=
                        d_statement
                     || '|| LPAD (NVL('
                     || d_nome_campo_registro
                     || ', ''z''), 4, ''z'')
                         || LPAD (NVL (TO_NUMBER ('||d_nome_campo_numero||'), 0), 20, 0)'
                     || '  FROM '
                     || d_tabella
                     || ' WHERE id_documento = '
                     || p_oggetto
                     || '   AND anno is null';

                  IF d_tabella IN ('SAM_DETE_DETERMINA', 'SAT_DETERMINA', 'GAT_DETERMINA', 'GAT_DELIBERA')
                  THEN
                     d_statement :=
                        d_statement || ' AND ' || d_nome_campo_numero || ' is not null';
                  END IF;

                  integritypackage.LOG (d_statement);

                  EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     IF d_tabella IN ('SAM_DETE_DETERMINA', 'SAT_DETERMINA', 'GAT_DETERMINA')
                     THEN
                        BEGIN
                           if d_tabella in ('GAT_DETERMINA') then
                              d_nome_campo_data     := 'DATA_NUMERO_PROPOSTA';
                              d_nome_campo_numero   := 'NUMERO_PROPOSTA';
                           else
                              d_nome_campo_data     := 'DATA_REG_PROPOSTA';
                              d_nome_campo_numero   := 'N_PROPOSTA';
                           end if;

                           IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
                           THEN
                              d_statement :=
                                 'SELECT 9999-  LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                                            || TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
                           ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
                           THEN
                              d_statement :=
                                 'SELECT LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                                            || TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss'')';
                           ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
                           THEN
                              d_statement :=
                                 'SELECT 9999 -  LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                                            || 99991231235959 - to_number(TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss''))';
                           END IF;

                           d_statement :=
                                 d_statement
                              || '|| ''004''
                                  || LPAD (NVL('
                              || d_nome_campo_registro
                              || ', ''z''), 4, ''z'')
                                  || LPAD (NVL (TO_NUMBER ('|| d_nome_campo_numero|| '), 0), 20, 0)'
                              || '  FROM '
                              || d_tabella
                              || ' WHERE id_documento = '
                              || p_oggetto
                              || '   AND anno is null and '|| d_nome_campo_numero|| ' is not null';
                           integritypackage.LOG (d_statement);

                           EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
                        END;
                     END IF;
               END;
         END;
      END IF;


      IF d_tabella IN ('SAM_DELE_DELIBERA', 'SAT_PROPOSTA_DELIBERA', 'GAT_PROPOSTA_DELIBERA')
      THEN
         if d_tabella in ('GAT_PROPOSTA_DELIBERA') then
            d_nome_campo_data       := 'DATA_NUMERO_PROPOSTA';
            d_nome_campo_numero     := 'NUMERO_PROPOSTA';
            d_nome_campo_registro   := 'TIPO_REGISTRO';
         else
            d_nome_campo_data       := 'DATA_REG_PROPOSTA';
            d_nome_campo_numero     := 'N_PROPOSTA';
            d_nome_campo_registro   := 'TIPO_REGISTRO';
         end if;

         IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
         THEN
            d_statement :=
               'SELECT 9999-  LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                          || TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
         ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
         THEN
            d_statement :=
               'SELECT LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                          || TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss'')';
         ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
         THEN
            d_statement :=
               'SELECT 9999 -  LPAD (NVL (to_char('|| d_nome_campo_data||',''yyyy''), 1900), 4)
                          || 99991231235959 - to_number(TO_CHAR (NVL ('|| d_nome_campo_data||', TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')),''yyyymmddhh24miss''))';
         END IF;

         d_statement :=
               d_statement
            || '|| ''004''
                || LPAD (NVL('
            || d_nome_campo_registro
            || ', ''z''), 4, ''z'')
                || LPAD (NVL (TO_NUMBER ('||d_nome_campo_numero||'), 0), 20, 0)'
            || '  FROM '
            || d_tabella
            || ' WHERE id_documento = '
            || p_oggetto;
         integritypackage.LOG (d_statement);

         EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
      END IF;

       if d_ordinamento is null then
          if d_tabella in ('SPR_LETTERE_USCITA', 'SPR_PROVVEDIMENTI') then
             if d_tabella = 'SPR_LETTERE_USCITA' then
                select count (1)
                  into d_is_protocollato
                  from spr_lettere_uscita
                 where anno is not null
                   and numero is not null
                   and tipo_registro is not null
                   and id_documento = p_oggetto;
             else
                if d_tabella = 'SPR_PROVVEDIMENTI' then
                   select count (1)
                     into d_is_protocollato
                     from spr_provvedimenti
                    where anno is not null
                      and numero is not null
                      and tipo_registro is not null
                      and id_documento = p_oggetto;
                end if;
             end if;

             if d_is_protocollato = 0 then
                select to_char (min (stdo.data_aggiornamento), 'yyyymmddhh24miss')
                  into d_data_creazione
                  from stati_documento stdo
                 where stdo.id_documento = p_oggetto
                   and stdo.stato = 'BO';

                if d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC' then
                   d_statement      :=
                         'SELECT 9999 - LPAD (NVL (TO_NUMBER ('
                      || d_data_creazione
                      || '), 0), 4)
                                  || to_char(nvl (to_date('
                      || d_data_creazione
                      || ', ''yyyymmddhh24miss''), to_date (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
                elsif d_tipo_ordinamento = 'ANNO_DATA_ASC' then
                   d_statement      :=
                         'SELECT LPAD (NVL (TO_NUMBER ('
                      || d_data_creazione
                      || '), 0), 4)
                                  || to_char(nvl (to_date('
                      || d_data_creazione
                      || ', ''yyyymmddhh24miss''), to_date (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
                elsif d_tipo_ordinamento = 'ANNO_DATA_DESC' then
                   d_statement      :=
                         'SELECT 9999 - LPAD (NVL (TO_NUMBER ('
                      || d_data_creazione
                      || '), 0), 4)
                                  || 99991231235959 - to_number(to_char(nvl (to_date('
                      || d_data_creazione
                      || ', ''yyyymmddhh24miss''), to_date (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss''))';
                end if;

                d_statement      :=
                   d_statement || '|| ''001''
                              || lpad (nvl (tipo_registro, ''z''), 4, ''z'')
                              || lpad (nvl (to_number (numero), 0), 20, 0)
                         from ' || d_tabella || '
                        where anno is null and id_documento = ' || p_oggetto;

                integritypackage.log (d_statement);

                execute immediate d_statement into d_ordinamento;
             end if;
          end if;
       end if;

      IF d_ordinamento IS NULL
      THEN
         BEGIN
            SELECT categoria
              INTO d_categoria
              FROM categorie_modello camo
             WHERE     camo.area = d_area_modello
                   AND camo.codice_modello = d_codice_modello
                   AND camo.categoria = 'PROTO';

            integritypackage.LOG ('d_categoria ' || d_categoria);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               integritypackage.LOG (
                  'd_categoria PROTO NOT FOUND ' || d_categoria);

               BEGIN
                  SELECT categoria
                    INTO d_categoria
                    FROM categorie_modello camo
                   WHERE     camo.area = d_area_modello
                         AND camo.codice_modello = d_codice_modello
                         AND camo.categoria = 'POSTA_ELETTRONICA';

                  integritypackage.LOG ('d_categoria ' || d_categoria);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     integritypackage.LOG (
                           'd_categoria POSTA_ELETTRONICA NOT FOUND '
                        || d_categoria);

                     BEGIN
                        SELECT categoria
                          INTO d_categoria
                          FROM categorie_modello camo
                         WHERE     camo.area = d_area_modello
                               AND camo.codice_modello = d_codice_modello
                               AND camo.categoria = 'CLASSIFICABILE';

                        integritypackage.LOG ('d_categoria ' || d_categoria);
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           integritypackage.LOG (
                                 'd_categoria CLASSIFICABILE NOT FOUND '
                              || d_categoria);

                           BEGIN
                              SELECT categoria
                                INTO d_categoria
                                FROM categorie_modello camo
                               WHERE     camo.area = d_area_modello
                                     AND camo.codice_modello =
                                            d_codice_modello
                                     AND camo.categoria =
                                            'CLASSIFICABILE_OUT';

                              integritypackage.LOG (
                                 'd_categoria ' || d_categoria);
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 integritypackage.LOG (
                                       'd_categoria CLASSIFICABILE_OUT NOT FOUND '
                                    || d_categoria);
                                 d_categoria := NULL;
                           END;
                     END;
               END;
         END;

         integritypackage.LOG ('d_categoria trovata ' || d_categoria);

         BEGIN
            IF d_categoria = 'PROTO'
            THEN
               IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
               THEN
                  d_statement :=
                     'SELECT 9999 - LPAD (NVL (TO_NUMBER (anno), 0), 4)
                          || TO_CHAR(NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
               THEN
                  d_statement :=
                     'SELECT LPAD (NVL (TO_NUMBER (anno), 0), 4)
                          || TO_CHAR(NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
               THEN
                  d_statement :=
                     'SELECT 9999 - LPAD (NVL (TO_NUMBER (anno), 0), 4)
                          || 99991231235959 - to_number(TO_CHAR(NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss''))';
               END IF;

               d_statement :=
                     d_statement
                  || '|| ''001''
                      || LPAD (NVL (tipo_registro, ''z''), 4, ''z'')
                      || LPAD (NVL (TO_NUMBER (numero), 0), 20, 0)
                 FROM proto_view
                WHERE id_documento = '
                  || p_oggetto;

               integritypackage.LOG (d_statement);

               EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
            ELSIF d_categoria = 'POSTA_ELETTRONICA'
            THEN
               SELECT TO_CHAR (MIN (stdo.data_aggiornamento), 'yyyymmdd')
                 INTO d_data_creazione
                 FROM stati_documento stdo
                WHERE stdo.id_documento = p_oggetto AND stdo.stato = 'BO';


               IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
               THEN
                  d_statement :=
                        'SELECT 9999 -  LPAD (to_char(nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')),''yyyy''), 4)
                          || TO_CHAR (nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
               THEN
                  d_statement :=
                        'SELECT LPAD (to_char(nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')),''yyyy''), 4)
                          || TO_CHAR (nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
               THEN
                  d_statement :=
                        'SELECT 9999 -  LPAD (to_char(nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')),''yyyy''), 4)
                          || 99991231235959 - to_number(TO_CHAR (nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')), ''yyyymmddhh24miss''))';
               END IF;

               d_statement :=
                     d_statement
                  || '|| ''005''
                      || LPAD ( ''z'', 4, ''z'')
                      || LPAD (NVL (TO_NUMBER (id_documento), 0), 20, 0)
                    FROM posta_elettronica_view
                   WHERE id_documento = '
                  || p_oggetto;

               integritypackage.LOG (d_statement);

               EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
            ELSIF d_categoria = 'CLASSIFICABILE'
            THEN
               IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
               THEN
                  d_statement :=
                     'SELECT 9999 -  LPAD (NVL (to_char(DATA,''yyyy''), 1900), 4)
                          || TO_CHAR (NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
               THEN
                  d_statement :=
                     'SELECT LPAD (NVL (to_char(DATA,''yyyy''), 1900), 4)
                          || TO_CHAR (NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
               THEN
                  d_statement :=
                     'SELECT 9999 -  LPAD (NVL (to_char(DATA,''yyyy''), 1900), 4)
                          || 99991231235959 - to_number(TO_CHAR (NVL (DATA, TO_DATE (''19000101000000'', ''yyyymmddhh24miss'')), ''yyyymmddhh24miss''))';
               END IF;

               d_statement :=
                     d_statement
                  || '|| ''005''
                     || LPAD ( ''z'', 4, ''z'')
                     || LPAD (NVL (TO_NUMBER (id_documento), 0), 20, 0)
                FROM classificabile_view
               WHERE id_documento = '
                  || p_oggetto;
               integritypackage.LOG (d_statement);

               EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
            ELSIF d_categoria = 'CLASSIFICABILE_OUT'
            THEN
               IF d_tipo_ordinamento = 'ANNO_DESC_DATA_ASC'
               THEN
                  d_statement :=
                        'SELECT 9999 -  LPAD (to_char(nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')),''yyyy''), 4)
                          || TO_CHAR (nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_ASC'
               THEN
                  d_statement :=
                        'SELECT LPAD (to_char(nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')),''yyyy''), 4)
                          || TO_CHAR (nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')), ''yyyymmddhh24miss'')';
               ELSIF d_tipo_ordinamento = 'ANNO_DATA_DESC'
               THEN
                  d_statement :=
                        'SELECT 9999 -  LPAD (to_char(nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')),''yyyy''), 4)
                          || 99991231235959 - to_number(TO_CHAR (nvl(data_ricezione, to_date('''
                     || d_data_creazione
                     || ''',''yyyymmddhh24miss'')), ''yyyymmddhh24miss''))';
               END IF;

               d_statement :=
                     d_statement
                  || '|| ''006''
                     || LPAD ( ''z'', 4, ''z'')
                     || LPAD (NVL (TO_NUMBER (id_documento), 0), 20, 0)
                FROM classificabile_out_view
               WHERE id_documento = '
                  || p_oggetto;
               integritypackage.LOG (d_statement);

               EXECUTE IMMEDIATE d_statement INTO d_ordinamento;
            ELSIF d_categoria IS NULL
            THEN
               d_ordinamento := NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_ordinamento := NULL;
         END;

         IF d_ordinamento IS NULL
         THEN
            SELECT '999919000101000000999zzzz' || LPAD (0, 20, 0)
              INTO d_ordinamento
              FROM documenti
             WHERE id_documento = p_oggetto;
         END IF;
      END IF;

      RETURN d_ordinamento;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   --      raise_application_error (-20999,
   --                               'Oggetto: ' || p_oggetto || ' - ' || SQLERRM
   --                              );
   END;
END ag_utilities_ricerca;
/
