--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_PROTOCOLLO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_utilities_protocollo
AS
/******************************************************************************
   NAME:       AG_UTILITIES_PROTOCOLLO
   PURPOSE:    Package di utilities per i documenti di categoria PROTOCOLLO.
   REVISIONS:
   Ver        Date         Author         Description
   ---------  ----------   ------------   ------------------------------------
   00         24/06/2011   MMalferrari    Created this package.
   01         17/05/2012   GMannella      Creata proc. elimina_protocollo_fisico
   02         29/03/2013   MMalferrari    Creata proc. check_unicita_idrif
******************************************************************************/
   s_revisione   afc.t_revision := 'V1.02';

   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE check_unicita (
      p_table           VARCHAR2,
      p_anno            NUMBER,
      p_tipo_registro   VARCHAR2,
      p_numero          NUMBER,
      p_id_documento    NUMBER
   );

   PROCEDURE crea_log (p_log VARCHAR2);

   PROCEDURE elimina_protocollo_fisico (p_id_doc NUMBER, p_tipo VARCHAR2);

   PROCEDURE check_titolario (
      p_id_documento           NUMBER,
      p_class_cod_old          VARCHAR2,
      p_class_dal_old          DATE,
      p_fascicolo_anno_old     NUMBER,
      p_fascicolo_numero_old   VARCHAR2,
      p_class_cod_new          VARCHAR2,
      p_class_dal_new          DATE,
      p_fascicolo_anno_new     NUMBER,
      p_fascicolo_numero_new   VARCHAR2,
      p_utente                 VARCHAR2,
      p_is_protocollato        NUMBER,
      p_anno                   NUMBER,
      p_numero                 NUMBER,
      p_tipo_registro          VARCHAR2,
      p_data_protocollo        DATE
   );
      FUNCTION get_url_nuovo_pg
      RETURN VARCHAR2;

   PROCEDURE check_unicita_idrif (p_table varchar2, p_idrif varchar2, p_id_documento number);

   FUNCTION dominio_suap (
      p_area                     VARCHAR2,
      p_cm                       VARCHAR2,
      p_cr                       VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   )
      RETURN VARCHAR2;

   PROCEDURE calcola_id_nome_file_suap (
      p_area                     VARCHAR2,
      p_cm                       VARCHAR2,
      p_cr                       VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2,
      p_idfile_suap       IN OUT NUMBER,
      p_nomefile_suap     IN OUT VARCHAR2
   );

   PROCEDURE calcola_id_nome_file_suap (
      p_id_protocollo            NUMBER,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2,
      p_idfile_suap       IN OUT NUMBER,
      p_nomefile_suap     IN OUT VARCHAR2
   );

   FUNCTION get_protocollo (
      p_id_documento             IN   NUMBER
   )
      RETURN afc.t_ref_cursor;

   PROCEDURE ins_proto_key (
      p_anno            NUMBER,
      p_tipo_registro   VARCHAR2,
      p_numero          NUMBER
   );
END;
/
CREATE OR REPLACE PACKAGE BODY ag_utilities_protocollo
AS
/******************************************************************************
   NAME:       AG_UTILITIES_PROTOCOLLO
   PURPOSE:    Package di utilities per i documenti di categoria PROTOCOLLO.
   REVISIONS:
   Ver        Date         Author         Description
   ---------  ----------   ------------   ------------------------------------
   000        24/06/2011   MMalferrari    Created this package.
   001        17/05/2012   GMannella      Creata proc. elimina_protocollo_fisico
   002        29/03/2013   MMalferrari    Creata proc. check_unicita_idrif
              26/04/2017   SC             ALLINEATO ALLO STANDARD
   003        26/10/2018   MMalferrari    Nodificata check_unicita
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

   FUNCTION get_url_nuovo_pg
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
      d_ret   VARCHAR2 (32000);
   BEGIN
      SELECT    '<FUNCTION_OUTPUT><RESULT>OK</RESULT><ERROR/><REDIRECT>'
             || gdc_utility_pkg.f_get_url_oggetto ('',
                                                   '',
                                                   '10019102',
                                                   'C',
                                                   '',
                                                   '',
                                                   '',
                                                   'W',
                                                   '',
                                                   '',
                                                   '5'
                                                  )
             || '</REDIRECT><REFRESH>N</REFRESH><FORCE_REDIRECT>Y</FORCE_REDIRECT>'
             || '<LISTAID><MSG></MSG><ERROR></ERROR></LISTAID></FUNCTION_OUTPUT>'
        INTO d_ret
        FROM DUAL;

      RETURN d_ret;
   END;

   PROCEDURE crea_log (p_log VARCHAR2)
   IS
/******************************************************************************
 NOME:        crea_log
 DESCRIZIONE: Inserisce nella tabella KEY_ERROR_LOG il risultato
              dell'operazione effettuata.
 PARAMETRI:   p_log        IN varchar2 log dell'operazione.
 ANNOTAZIONI:
 REVISIONI:
 Rev. Data       Autore Descrizione
 ---- ---------- ------ ------------------------------------------------------
    1 05/04/2014 MM     Creazione
******************************************************************************/
      d_max   INTEGER         := 2000;
      d_log   VARCHAR2 (2000) := SUBSTR (p_log, 1, 2000);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DECLARE
         i          INTEGER;
         d_inizio   INTEGER;
         d_loop     INTEGER := CEIL (LENGTH (p_log) / d_max);
      BEGIN
         FOR i IN 1 .. d_loop
         LOOP
            d_inizio := ((i - 1) * d_max) + 1;
            d_log := SUBSTR (p_log, d_inizio, d_max);

            INSERT INTO key_error_log
                        (error_session, ERROR_TEXT, error_date,
                         error_user
                        )
                 VALUES (USERENV ('sessionid'), p_log, SYSDATE,
                         NVL (si4.utente, USER)
                        );
         END LOOP;
      END;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   PROCEDURE check_unicita (
      p_table           VARCHAR2,
      p_anno            NUMBER,
      p_tipo_registro   VARCHAR2,
      p_numero          NUMBER,
      p_id_documento    NUMBER
   )
   IS
      depnometabella   VARCHAR2 (100);
      depstmt          VARCHAR2 (32000);
   BEGIN
      FOR c_categorie IN (SELECT area, codice_modello
                            FROM categorie_modello
                           WHERE categoria = ag_utilities.categoriaprotocollo)
      LOOP
         depnometabella :=
                f_nome_tabella (c_categorie.area, c_categorie.codice_modello);

         dbms_output.put_line('-- '||depnometabella);
         dbms_output.put_line('p_table '||p_table);
         IF NVL (depnometabella, p_table) <> p_table
         THEN
            DECLARE
               d_count   NUMBER;
            BEGIN
               depstmt :=
                     'select count(1) from '
                  || depnometabella
                  || ' where anno = '
                  || p_anno
                  || ' and numero = '
                  || p_numero
                  || ' and tipo_registro = nvl('''
                  || p_tipo_registro
                  || ''', AG_PARAMETRO.GET_VALORE(''TIPO_REGISTRO_1'', ''@agVar@'', ''''))';

               dbms_output.put_line(depstmt);
               EXECUTE IMMEDIATE depstmt
                            INTO d_count;

               IF d_count > 0
               THEN
                  raise_application_error (-20999,
                                              'Numero di protocollo '
                                           || p_numero
                                           || ' per l''anno '
                                           || p_anno
                                           || ' gia'' assegnato ('
                                           || depnometabella
                                           || ')'
                                          );
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  crea_log (p_table || '[' || p_id_documento || ']: '
                            || SQLERRM
                           );
                  RAISE;
            END;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE elimina_protocollo_fisico (p_id_doc NUMBER, p_tipo VARCHAR2)
   AS
      a_idrif     spr_protocolli.idrif%TYPE;
      a_modello   VARCHAR2 (100);
      a_ret       NUMBER (1);
   BEGIN
      BEGIN
         --ANNULLO l'id_doc_padre
         UPDATE documenti
            SET id_documento_padre = NULL
          WHERE id_documento IN (
                   SELECT id_documento
                     FROM riferimenti
                    WHERE id_documento_rif = p_id_doc
                      AND tipo_relazione = 'PROT_PREC');
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error
                          (-20999,
                              'Errore in annullamento id_doc_padre. Errore: '
                           || SQLERRM
                          );
      END;

      IF p_tipo = 'PG'
      THEN
         a_modello := 'M_PROTOCOLLO';

         SELECT idrif
           INTO a_idrif
           FROM spr_protocolli
          WHERE id_documento = p_id_doc;
      ELSE
         a_modello := 'M_PROTOCOLLO_INTEROPERABILITA';

         SELECT idrif
           INTO a_idrif
           FROM spr_protocolli_intero
          WHERE id_documento = p_id_doc;
      END IF;

      -- ELIMINO PRIMA TUTTI GLI SMISTAMENTI/SOGGETTI/ALLEGATI COLLEGATI
      FOR i IN (SELECT   1, 'Smistamento' tipo, id_documento
                    FROM seg_smistamenti
                   WHERE idrif = a_idrif
                UNION ALL
                SELECT   2, 'Soggetto' tipo, id_documento
                    FROM seg_soggetti_protocollo
                   WHERE idrif = a_idrif
                UNION ALL
                SELECT   3, 'Allegato' tipo, id_documento
                    FROM seg_allegati_protocollo
                   WHERE idrif = a_idrif
                ORDER BY 1)
      LOOP
         DECLARE
            a_doc   NUMBER (10);
         BEGIN
            a_doc := i.id_documento;

            IF i.tipo = 'Allegato'
            THEN
               DELETE      oggetti_file
                     WHERE id_documento = a_doc;
            END IF;

            a_ret := f_elimina_documento (a_doc, 0);
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               raise_application_error
                                    (-20999,
                                        'Errore in Cancellazione '
                                     || i.tipo
                                     || ' (con id='
                                     || a_doc
                                     || ') collegato al protocollo. Errore: '
                                     || SQLERRM
                                    );
         END;
      END LOOP;

      BEGIN
         DELETE      oggetti_file
               WHERE id_documento = p_id_doc;

         a_ret := f_elimina_documento (p_id_doc, 0);
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error
                            (-20999,
                                'Errore in eliminazione protocollo. Errore: '
                             || SQLERRM
                            );
      END;
   END;

   PROCEDURE check_titolario (
      p_id_documento           NUMBER,
      p_class_cod_old          VARCHAR2,
      p_class_dal_old          DATE,
      p_fascicolo_anno_old     NUMBER,
      p_fascicolo_numero_old   VARCHAR2,
      p_class_cod_new          VARCHAR2,
      p_class_dal_new          DATE,
      p_fascicolo_anno_new     NUMBER,
      p_fascicolo_numero_new   VARCHAR2,
      p_utente                 VARCHAR2,
      p_is_protocollato        NUMBER,
      p_anno                   NUMBER,
      p_numero                 NUMBER,
      p_tipo_registro          VARCHAR2,
      p_data_protocollo        DATE
   )
   IS
      modificata_classifica    NUMBER                         := 0;
      modificato_fascicolo     NUMBER                         := 0;
      stato_fascicolo_old      NUMBER;
      privilegio_abilitato     NUMBER                         := 1;
      descrizione_protocollo   VARCHAR2 (2000);
      privilegio_controllato   ag_privilegi.privilegio%TYPE;
   BEGIN
      IF p_is_protocollato = 1
      THEN
         IF    (p_class_cod_old IS NULL AND p_class_cod_new IS NOT NULL)
            OR (p_class_cod_new IS NULL AND p_class_cod_old IS NOT NULL)
            OR (    p_class_cod_old IS NOT NULL
                AND p_class_cod_new IS NOT NULL
                AND p_class_cod_old <> p_class_cod_new
               )
         THEN
            modificata_classifica := 1;
         END IF;

         IF    (    (   p_fascicolo_anno_old IS NULL
                     OR p_fascicolo_numero_old IS NULL
                    )
                AND (   p_fascicolo_anno_new IS NOT NULL
                     OR p_fascicolo_numero_new IS NOT NULL
                    )
               )
            OR (    (   p_fascicolo_anno_new IS NULL
                     OR p_fascicolo_numero_new IS NULL
                    )
                AND (   p_fascicolo_anno_old IS NOT NULL
                     OR p_fascicolo_numero_old IS NOT NULL
                    )
               )
            OR (    p_fascicolo_anno_old IS NOT NULL
                AND p_fascicolo_numero_old IS NOT NULL
                AND p_fascicolo_anno_new IS NOT NULL
                AND p_fascicolo_numero_new IS NOT NULL
                AND (   p_fascicolo_anno_old <> p_fascicolo_anno_new
                     OR p_fascicolo_numero_old <> p_fascicolo_numero_new
                    )
               )
         THEN
            modificato_fascicolo := 1;
         END IF;

         DBMS_OUTPUT.put_line (   'mod clas, mod fasc '
                               || modificata_classifica
                               || ' '
                               || modificato_fascicolo
                              );

         IF modificata_classifica = 1
         THEN
            privilegio_abilitato :=
               ag_competenze_protocollo.verifica_privilegio_protocollo
                                                             (p_id_documento,
                                                              'MC',
                                                              p_utente
                                                             );
            privilegio_controllato := 'MC';
            DBMS_OUTPUT.put_line (   'privilegio_controllato '
                                  || privilegio_controllato
                                 );
         END IF;

         IF privilegio_abilitato = 1 AND modificato_fascicolo = 1
         THEN
            BEGIN
               SELECT NVL (stato_fascicolo, 1)
                 INTO stato_fascicolo_old
                 FROM seg_fascicoli f, cartelle c, documenti d
                WHERE class_cod = p_class_cod_old
                  AND class_dal = p_class_dal_old
                  AND fascicolo_anno = p_fascicolo_anno_old
                  AND fascicolo_numero = p_fascicolo_numero_old
                  AND c.id_documento_profilo = f.id_documento
                  AND NVL (c.stato, 'BO') != 'CA'
                  AND d.id_documento = c.id_documento_profilo
                  AND d.stato_documento NOT IN ('CA', 'RE', 'PB');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  stato_fascicolo_old := 1;
               WHEN OTHERS
               THEN
                  RAISE;
            END;

            DBMS_OUTPUT.put_line ('dopo ndf');

            IF stato_fascicolo_old = 1
            THEN
               privilegio_abilitato :=
                  ag_competenze_protocollo.verifica_privilegio_protocollo
                                                             (p_id_documento,
                                                              'MFD',
                                                              p_utente
                                                             );
               privilegio_controllato := 'MFD';
               DBMS_OUTPUT.put_line (   'privilegio_controllato '
                                     || privilegio_controllato
                                    );
            ELSE
               privilegio_abilitato :=
                  ag_competenze_protocollo.verifica_privilegio_protocollo
                                                             (p_id_documento,
                                                              'MDDEP',
                                                              p_utente
                                                             );
               privilegio_controllato := 'MDDEP';
               DBMS_OUTPUT.put_line (   'privilegio_controllato '
                                     || privilegio_controllato
                                    );
            END IF;
         END IF;
      END IF;

      IF privilegio_abilitato = 0
      THEN
         BEGIN
            SELECT    seg_registri.descrizione_tipo_registro
                   || ' n. '
                   || p_numero
                   || ' del '
                   || TO_CHAR (TRUNC (p_data_protocollo), 'DD/MM/YYYY')
              INTO descrizione_protocollo
              FROM seg_registri
             WHERE tipo_registro = p_tipo_registro
               AND seg_registri.anno_reg = p_anno;
         EXCEPTION
            WHEN OTHERS
            THEN
               descrizione_protocollo :=
                     p_tipo_registro
                  || ' n. '
                  || p_numero
                  || ' del '
                  || TO_CHAR (TRUNC (p_data_protocollo), 'DD/MM/YYYY');
         END;

         raise_application_error
            (-20998,
                'L''utente '
             || ad4_utente.get_nominativo (p_utente)
             || ' non è abilitato a modificare la classificazione principale di '
             || descrizione_protocollo
             || ' (privilegio necessario '''
             || privilegio_controllato
             || ''')'
            );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE check_unicita_idrif (
      p_table          VARCHAR2,
      p_idrif          VARCHAR2,
      p_id_documento   NUMBER
   )
   IS
      depnometabella   VARCHAR2 (100);
      depstmt          VARCHAR2 (32000);
   BEGIN
      FOR c_categorie IN (SELECT area, codice_modello
                            FROM categorie_modello
                           WHERE categoria = ag_utilities.categoriaprotocollo)
      LOOP
         depnometabella :=
                f_nome_tabella (c_categorie.area, c_categorie.codice_modello);

         --dbms_output.put_line('-- '||depnometabella);
         IF NVL (depnometabella, p_table) <> p_table
         THEN
            DECLARE
               d_count   NUMBER;
            BEGIN
               depstmt :=
                     'select count(1) from '
                  || depnometabella
                  || ' where idrif = '''
                  || p_idrif
                  || '''';

               --dbms_output.put_line(depstmt);
               EXECUTE IMMEDIATE depstmt
                            INTO d_count;

               IF d_count > 0
               THEN
                  raise_application_error (-20999,
                                              'Idrif '
                                           || p_idrif
                                           || ' gia'' assegnato ('
                                           || depnometabella
                                           || ')'
                                          );
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  crea_log (   p_table
                            || '['
                            || p_id_documento
                            || ' - idrif '
                            || p_idrif
                            || ']: '
                            || SQLERRM
                           );
                  RAISE;
            END;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE calcola_id_nome_file_suap (
      p_id_protocollo            NUMBER,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2,
      p_idfile_suap       IN OUT NUMBER,
      p_nomefile_suap     IN OUT VARCHAR2
   )
   AS
      ret                 VARCHAR2 (32000);
      cerca_file          NUMBER                  := 0;
      dep_mittente_suap   parametri.valore%TYPE;
      suap_enabled        parametri.valore%TYPE;
      suap_tipo_file      parametri.valore%TYPE;
   BEGIN
      suap_enabled :=
         ag_parametro.get_valore ('WS_SUAP_ENABLED_',
                                  p_codice_amministrazione,
                                  p_codice_aoo,
                                  'N'
                                 );
      DBMS_OUTPUT.put_line ('suap_enabled ' || suap_enabled);

      IF NVL (suap_enabled, 'N') = 'Y'
      THEN
         dep_mittente_suap :=
               '%'
            || ag_parametro.get_valore ('WS_SUAP_MAIL_',
                                        p_codice_amministrazione,
                                        p_codice_aoo,
                                        'SUAP.TO@CERT.CAMCOM.IT'
                                       )
            || '%';
         DBMS_OUTPUT.put_line ('dep_mittente_suap ' || dep_mittente_suap);
         suap_tipo_file :=
            ag_parametro.get_valore ('WS_SUAP_FILE_',
                                     p_codice_amministrazione,
                                     p_codice_aoo,
                                     'N'
                                    );
         DBMS_OUTPUT.put_line ('suap_tipo_file ' || suap_tipo_file);

         BEGIN
            SELECT NVL (MAX (1), 0)
              INTO cerca_file
              FROM riferimenti, seg_memo_protocollo, documenti
             WHERE riferimenti.id_documento = p_id_protocollo
               AND riferimenti.tipo_relazione = 'MAIL'
               AND riferimenti.id_documento_rif =
                                              seg_memo_protocollo.id_documento
               AND documenti.id_documento = seg_memo_protocollo.id_documento
               AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
               AND UPPER (seg_memo_protocollo.mittente) LIKE dep_mittente_suap;

            DBMS_OUTPUT.put_line ('cerca_file ' || cerca_file);

            IF cerca_file = 1
            THEN
               BEGIN
                  SELECT ogfi_prin.filename, ogfi_prin.id_documento
                    INTO p_nomefile_suap, p_idfile_suap
                    FROM oggetti_file ogfi_prin,
                         spr_protocolli_intero prin,
                         documenti docu_prin
                   WHERE prin.id_documento = p_id_protocollo
                     AND prin.id_documento = docu_prin.id_documento
                     AND docu_prin.stato_documento NOT IN ('CA', 'RE', 'PB')
                     AND prin.id_documento = ogfi_prin.id_documento
                     AND ogfi_prin.filename LIKE '%' || suap_tipo_file;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT ogfi_alpr.filename, ogfi_alpr.id_documento
                          INTO p_nomefile_suap, p_idfile_suap
                          FROM spr_protocolli_intero prin,
                               seg_allegati_protocollo alpr,
                               oggetti_file ogfi_alpr,
                               documenti docu_prin,
                               documenti docu_alpr
                         WHERE prin.id_documento = p_id_protocollo
                           AND prin.id_documento = docu_prin.id_documento
                           AND docu_prin.stato_documento NOT IN
                                                           ('CA', 'RE', 'PB')
                           AND alpr.idrif = prin.idrif
                           AND alpr.id_documento = docu_alpr.id_documento
                           AND docu_alpr.stato_documento NOT IN
                                                           ('CA', 'RE', 'PB')
                           AND alpr.id_documento = ogfi_alpr.id_documento
                           AND ogfi_alpr.filename LIKE '%' || suap_tipo_file;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           NULL;
                     END;
               END;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END IF;
   END;

   PROCEDURE calcola_id_nome_file_suap (
      p_area                     VARCHAR2,
      p_cm                       VARCHAR2,
      p_cr                       VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2,
      p_idfile_suap       IN OUT NUMBER,
      p_nomefile_suap     IN OUT VARCHAR2
   )
   AS
      dep_id_proto        NUMBER;
      ret                 VARCHAR2 (32000);
      cerca_file          NUMBER                  := 0;
      dep_mittente_suap   parametri.valore%TYPE;
      suap_enabled        parametri.valore%TYPE;
      suap_tipo_file      parametri.valore%TYPE;
   BEGIN
      dep_id_proto := ag_utilities.get_id_documento (p_area, p_cm, p_cr);
      calcola_id_nome_file_suap(dep_id_proto, p_codice_amministrazione, p_codice_aoo, p_idfile_suap, p_nomefile_suap);
   END;

   FUNCTION dominio_suap (
      p_area                     VARCHAR2,
      p_cm                       VARCHAR2,
      p_cr                       VARCHAR2,
      p_codice_amministrazione   VARCHAR2,
      p_codice_aoo               VARCHAR2
   )
      RETURN VARCHAR2
   AS
      dep_nome_file       VARCHAR2 (100);
      dep_id_doc_file     NUMBER;
      ret                 VARCHAR2 (32000);
   BEGIN
      begin
         calcola_id_nome_file_suap(p_area, p_cm, p_cr, p_codice_amministrazione, p_codice_aoo, dep_id_doc_file, dep_nome_file);
      exception
         when others then
            dep_nome_file := null;
            dep_id_doc_file := null;
      end;
      ret :=
            '<C>SUAP_FILE</C><V>'
         || dep_nome_file
         || '</V><C>SUAP_IDDOC_FILE</C><V>'
         || dep_id_doc_file
         || '</V>';
   END;

   FUNCTION get_protocollo (
      p_id_documento             IN   NUMBER
   )
      RETURN afc.t_ref_cursor
   IS
      d_refcursor afc.t_ref_cursor;
   BEGIN
      OPEN d_refcursor FOR
         select *
           from proto_view p, documenti d
          where p.id_documento = p_id_documento
            and d.id_documento = p.id_documento
            and d.stato_documento not in ('CA', 'RE', 'PB')
         ;
      RETURN d_refcursor;
   END;

   PROCEDURE ins_proto_key (
      p_anno            NUMBER,
      p_tipo_registro   VARCHAR2,
      p_numero          NUMBER
   )
   IS
      d_tipo_registro varchar(10) := p_tipo_registro;
   BEGIN
      d_tipo_registro := nvl(d_tipo_registro, ag_parametro.get_valore('TIPO_REGISTRO_1','@agVar@',''));
      insert into ag_proto_key (anno, tipo_registro, numero)
           values (p_anno, d_tipo_registro, p_numero);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         raise_application_error(-20999,
                                              'Numero di protocollo '
                                           || p_numero
                                           || ' per l''anno '
                                           || p_anno
                                           || ' e registro '''
                                           || d_tipo_registro ||''''
                                           || ' gia'' assegnato.');
      WHEN OTHERS
      THEN
         RAISE;
   END;
END;
/
