--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_RICALCOLA_ATTIVITA runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE     ag_ricalcola_attivita
IS
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE smistamenti (p_unita     VARCHAR2,
                          p_utente    VARCHAR2,
                          p_id_log    NUMBER);

   PROCEDURE notifiche_ins_fasc (p_unita     VARCHAR2,
                                 p_utente    VARCHAR2,
                                 p_id_log    NUMBER);

   PROCEDURE cancella_attivita_utente (p_nominativo    VARCHAR2,
                                       p_utente        VARCHAR2,
                                       p_id_log        NUMBER);

   PROCEDURE smistamenti_periodo (p_dal       DATE,
                                  p_al        DATE,
                                  p_utente    VARCHAR2 DEFAULT NULL,
                                  p_id_log    NUMBER);

   FUNCTION init (p_id_log NUMBER)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY ag_ricalcola_attivita
IS
   s_revisione_body   afc.t_revision := '000';
   s_server           parametri.valore%TYPE;
   s_context          parametri.valore%TYPE;
   s_idworkarea       NUMBER;
   s_des_url_query    VARCHAR2 (32000) := 'Visualizza elenco ';
   s_iter_doc         VARCHAR2 (32000);
   s_iter_fasc        VARCHAR2 (32000);
   n_id_log           NUMBER;
   s_start            VARCHAR2 (10) := ' START.';
   s_end              VARCHAR2 (10) := ' END.';
   s_ufficio          seg_unita.unita%TYPE := CHR (1);

   TYPE string_array IS TABLE OF VARCHAR2 (32767);

   CURSOR c_smistamenti_attivi_periodo (
      p_dal    DATE,
      p_al     DATE)
   IS
        SELECT DISTINCT s.ufficio_smistamento
          FROM seg_smistamenti s, documenti ds
         WHERE     stato_smistamento IN ('C', 'R')
               AND ds.id_documento = s.id_documento
               AND ds.stato_documento NOT IN ('CA', 'RE', 'PB')
               AND tipo_smistamento != 'DUMMY'
               AND key_iter_smistamento = -1
               AND DECODE (stato_smistamento,
                           'C', presa_in_carico_dal,
                           smistamento_dal) BETWEEN p_dal
                                                AND p_al
      ORDER BY 1;

   CURSOR c_unita_smistamenti_attivi_ca (
      p_ultima_unita    VARCHAR2)
   IS
        SELECT DISTINCT s.ufficio_smistamento
          FROM seg_smistamenti s, documenti ds, jwf_task_esterni
         WHERE     stato_smistamento IN ('C', 'R')
               AND ds.id_documento = s.id_documento
               AND ds.stato_documento IN ('CA', 'RE', 'PB')
               AND tipo_smistamento != 'DUMMY'
               AND key_iter_smistamento = -1
               AND ufficio_smistamento > p_ultima_unita
               AND id_riferimento = TO_CHAR (s.id_documento)
      ORDER BY 1;

   CURSOR c_unita_smistamenti_attivi (
      p_ultima_unita    VARCHAR2)
   IS
        SELECT DISTINCT s.ufficio_smistamento
          FROM seg_smistamenti s, documenti ds
         WHERE     stato_smistamento IN ('C', 'R')
               AND ds.id_documento = s.id_documento
               AND ds.stato_documento NOT IN ('CA', 'RE', 'PB')
               AND tipo_smistamento != 'DUMMY'
               AND key_iter_smistamento = -1
               AND ufficio_smistamento > p_ultima_unita
      ORDER BY 1;

   CURSOR c_attivita_utente_smistamenti (
      p_utente    VARCHAR2)
   IS
        SELECT DISTINCT
               jwf_task_esterni.id_attivita,
               jwf_task_esterni.id_riferimento,
               ds.codice_richiesta
          FROM jwf_task_esterni, seg_smistamenti s, documenti ds
         WHERE     tipologia IN ('ATTIVA_ITER_DOCUMENTALE',
                                 'ATTIVA_ITER_FASCICOLARE')
               AND utente_esterno = p_utente
               AND s.id_documento = id_riferimento
               AND ds.id_documento = s.id_documento
      ORDER BY 1;

   CURSOR c_attivita_utente_notifiche (
      p_utente    VARCHAR2)
   IS
        SELECT DISTINCT
               jwf_task_esterni.id_attivita,
               jwf_task_esterni.id_riferimento,
               dati_applicativi_1 id_documento,
               dati_applicativi_2 id_cartella,
               SUBSTR (dati_applicativi_3,
                       1,
                       INSTR (dati_applicativi_3, '#') - 1)
                  tipo,
               SUBSTR (dati_applicativi_3, INSTR (dati_applicativi_3, '#') + 1)
                  unita_competente,
               param_init_iter
          FROM jwf_task_esterni
         WHERE     nome_iter = 'NOTIFICA_INS_DOC_FASC'
               AND dati_applicativi_1 IS NOT NULL
               AND utente_esterno = p_utente
               AND espressione = 'TODO'
               AND (   dati_applicativi_3 LIKE 'CARICO#%'
                    OR dati_applicativi_3 LIKE 'COMPETENTE#%')
      ORDER BY 1;

   CURSOR c_smistamenti_unita (
      p_unita    VARCHAR2)
   IS
      SELECT s.id_documento,
             s.codice_amministrazione,
             s.codice_aoo,
             'SEGRETERIA' area,
             'M_SMISTAMENTO' codice_modello,
             ds.codice_richiesta,
             dp.area area_docpadre,
             td.nome codice_modello_docpadre,
             dp.codice_richiesta codice_richiesta_docpadre,
             s.ufficio_smistamento unita_ricevente,
             s.des_ufficio_smistamento des_unita_ricevente,
             s.stato_smistamento,
             s.tipo_smistamento,
             s.smistamento_dal data_smistamento,
             dp.id_documento id_docpadre,
             s.codice_assegnatario,
             s.des_ufficio_trasmissione
        FROM seg_smistamenti s,
             documenti ds,
             documenti dp,
             tipi_documento td
       WHERE     stato_smistamento IN ('C', 'R')
             AND ds.id_documento = s.id_documento
             AND ds.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND ufficio_smistamento = p_unita
             AND ds.id_documento_padre = dp.id_documento
             AND dp.id_tipodoc = td.id_tipodoc
             AND tipo_smistamento != 'DUMMY'
             AND key_iter_smistamento = -1;

   CURSOR c_smistamenti_unita_periodo (
      p_dal      DATE,
      p_al       DATE,
      p_unita    VARCHAR2)
   IS
      SELECT s.id_documento,
             s.codice_amministrazione,
             s.codice_aoo,
             'SEGRETERIA' area,
             'M_SMISTAMENTO' codice_modello,
             ds.codice_richiesta,
             dp.area area_docpadre,
             td.nome codice_modello_docpadre,
             dp.codice_richiesta codice_richiesta_docpadre,
             s.ufficio_smistamento unita_ricevente,
             s.des_ufficio_smistamento des_unita_ricevente,
             s.stato_smistamento,
             s.tipo_smistamento,
             s.smistamento_dal data_smistamento,
             dp.id_documento id_docpadre,
             s.codice_assegnatario,
             s.des_ufficio_trasmissione
        FROM seg_smistamenti s,
             documenti ds,
             documenti dp,
             tipi_documento td
       WHERE     stato_smistamento IN ('C', 'R')
             AND ds.id_documento = s.id_documento
             AND ds.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND ufficio_smistamento = p_unita
             AND ds.id_documento_padre = dp.id_documento
             AND dp.id_tipodoc = td.id_tipodoc
             AND tipo_smistamento != 'DUMMY'
             AND key_iter_smistamento = -1
             AND DECODE (stato_smistamento,
                         'C', presa_in_carico_dal,
                         smistamento_dal) BETWEEN p_dal
                                              AND p_al;

   CURSOR c_smistamenti_unita_ca (
      p_unita    VARCHAR2)
   IS
      SELECT DISTINCT s.id_documento
        FROM seg_smistamenti s, documenti ds, jwf_task_esterni
       WHERE     stato_smistamento IN ('C', 'R')
             AND ds.id_documento = s.id_documento
             AND ds.stato_documento IN ('CA', 'RE', 'PB')
             AND ufficio_smistamento = p_unita
             AND tipo_smistamento != 'DUMMY'
             AND jwf_task_esterni.id_riferimento = TO_CHAR (s.id_documento)
             AND key_iter_smistamento = -1;

   CURSOR c_notifiche_ins_fasc_per_unita (
      p_unita    VARCHAR2)
   IS
      SELECT DISTINCT id_riferimento,
                      dati_applicativi_1 id_documento,
                      dati_applicativi_2 id_cartella,
                      dati_applicativi_3 tipo_e_unita,
                      param_init_iter
        FROM jwf_task_esterni
       WHERE     espressione = 'TODO'
             AND dati_applicativi_1 IS NOT NULL
             AND nome_iter = 'NOTIFICA_INS_DOC_FASC'
             AND dati_applicativi_3 IN ('CARICO#' || p_unita,
                                        'COMPETENTE#' || p_unita);

   CURSOR c_unita_notifiche (
      p_unita    VARCHAR2)
   IS
      SELECT SUBSTR (dati_applicativi_3,
                     INSTR (dati_applicativi_3, '#') + 1,
                     LENGTH (dati_applicativi_3))
        FROM jwf_task_esterni
       WHERE     espressione = 'TODO'
             AND nome_iter = 'NOTIFICA_INS_DOC_FASC'
             AND DECODE (
                    p_unita,
                    NULL, SUBSTR (dati_applicativi_3,
                                  0,
                                  INSTR (dati_applicativi_3, '#')),
                    dati_applicativi_3) IN ('CARICO#' || p_unita,
                                            'COMPETENTE#' || p_unita);

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

   FUNCTION calcola_url_query_iter_doc (p_unita                VARCHAR2,
                                        p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_id_query   NUMBER;
      dep_tipo       VARCHAR2 (100);
   BEGIN
      SELECT MAX (QUERY.id_query),
             DECODE (p_stato_smistamento,
                     'R', 'M_DA_RICEVERE',
                     'M_IN_CARICO')
        INTO dep_id_query, dep_tipo
        FROM QUERY
       WHERE codiceads =
                   'SEGRETERIA.PROTOCOLLO#DOCUMENTI_'
                || DECODE (p_stato_smistamento,
                           'R', 'DA_RICEVERE',
                           'IN_CARICO');

      RETURN    s_server
             || '/'
             || s_context
             || '/common/WorkArea.do?WRKSP='
             || s_idworkarea
             || '&idQuery='
             || dep_id_query
             || '&PAR_AGSPR_UNITA='
             || p_unita
             || '&PAR_AGSPR_TIPO_RICERCA='
             || dep_tipo;
   END calcola_url_query_iter_doc;

   FUNCTION calcola_url_query_iter_fasc (p_unita                VARCHAR2,
                                         p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_id_query   NUMBER;
      dep_tipo       VARCHAR2 (100);
   BEGIN
      SELECT MAX (QUERY.id_query),
             DECODE (p_stato_smistamento,
                     'R', 'M_DA_RICEVERE',
                     'M_IN_CARICO')
        INTO dep_id_query, dep_tipo
        FROM QUERY
       WHERE codiceads =
                   'SEGRETERIA#FASCICOLI_'
                || DECODE (p_stato_smistamento,
                           'R', 'DA_RICEVERE',
                           'IN_CARICO');

      RETURN    s_server
             || '/'
             || s_context
             || '/common/WorkArea.do?WRKSP='
             || s_idworkarea
             || '&idQuery='
             || dep_id_query
             || '&PAR_AGSPR_UNITA='
             || p_unita
             || '&PAR_AGSPR_TIPO_RICERCA='
             || dep_tipo;
   END calcola_url_query_iter_fasc;

   FUNCTION calcola_url_query_iter (p_id_oggetto           NUMBER,
                                    p_unita                VARCHAR2,
                                    p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      --dbms_output.put_line('prima calcola_url_query_iter');
      IF ag_utilities.verifica_categoria_documento (p_id_oggetto, 'FASC') = 1
      THEN
         RETURN calcola_url_query_iter_fasc (p_unita, p_stato_smistamento);
      ELSE
         RETURN calcola_url_query_iter_doc (p_unita, p_stato_smistamento);
      END IF;
   END calcola_url_query_iter;

   FUNCTION crea_task_esterni_utente (
      p_area                         VARCHAR2,
      p_codice_modello               VARCHAR2,
      p_codice_richiesta             VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_id_riferimento               VARCHAR2,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_url_rif                      VARCHAR2,
      p_url_rif_desc                 VARCHAR2,
      p_url_exec                     VARCHAR2,
      p_tooltip_url_exec             VARCHAR2,
      p_stato                        VARCHAR2 DEFAULT NULL,
      p_tipologia                    VARCHAR2 DEFAULT NULL,
      p_datiapplicativi1             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi2             VARCHAR2 DEFAULT NULL,
      p_datiapplicativi3             VARCHAR2 DEFAULT NULL,
      p_param_init_iter              VARCHAR2 DEFAULT NULL,
      a_utente                       VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
   IS
      listaacl          VARCHAR2 (32000);
      listaidattivita   VARCHAR2 (10000);
      d_id_attivita     NUMBER;
      p_2               VARCHAR2 (32000);
      p_sel             VARCHAR2 (32000);

      TYPE rc_sql IS REF CURSOR;

      c_utenti          rc_sql;
      p_utente          VARCHAR2 (1000);
   BEGIN
      DBMS_OUTPUT.put_line ('crea_task_esterni_utente 1');
      listaacl :=
         ag_utilities_cruscotto.get_utenti_accesso_smistamento (
            p_area,
            p_codice_modello,
            p_codice_richiesta);
      DBMS_OUTPUT.put_line ('crea_task_esterni_utente 2');
      listaidattivita := 'X';
      p_2 := REPLACE (listaacl, '@', ''',''');
      p_2 := SUBSTR (p_2, 3);
      p_2 := SUBSTR (p_2, 1, LENGTH (p_2) - 2);
      p_sel := 'select utente from ad4_utenti where utente in (' || p_2 || ')';

      IF a_utente IS NOT NULL
      THEN
         p_sel := p_sel || ' and utente = ''' || a_utente || '''';
      END IF;

      DBMS_OUTPUT.put_line ('crea_task_esterni_utente ' || p_sel);

      BEGIN
         OPEN c_utenti FOR p_sel;

         LOOP
            FETCH c_utenti INTO p_utente;

            EXIT WHEN c_utenti%NOTFOUND;

            BEGIN
               --dbms_output.put_line('ute-->'||cElencoUtenti.utente);
               d_id_attivita :=
                  ag_smistamento.crea_task_esterno (
                     p_id_riferimento,
                     p_codice_amm,
                     p_codice_aoo,
                     p_area_docpadre,
                     p_codice_modello_docpadre,
                     p_codice_richiesta_docpadre,
                     p_url_rif,
                     p_url_rif_desc,
                     p_url_exec,
                     p_tooltip_url_exec,
                     p_utente,
                     p_stato,
                     p_tipologia,
                     p_datiapplicativi1,
                     p_datiapplicativi2,
                     p_datiapplicativi3,
                     p_param_init_iter);

               -- Rev. 002 27/01/2011 MM: Parametro ITER_DOCUMENTI_n = N, quindi non deve
               -- essere creata l'attivita' in scrivania.
               IF d_id_attivita IS NOT NULL
               THEN
                  -- Rev. 002 27/01/2011 MM: fine mod.
                  IF listaidattivita = 'X'
                  THEN
                     listaidattivita := TO_CHAR (d_id_attivita);
                  ELSE
                     listaidattivita :=
                        listaidattivita || '@' || TO_CHAR (d_id_attivita);
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_application_error (
                     -20999,
                        'Errore in creazione task esterno per utente '
                     || p_utente
                     || '.Errore: '
                     || SQLERRM);
            END;
         END LOOP;

         IF c_utenti%ISOPEN
         THEN
            CLOSE c_utenti;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF c_utenti%ISOPEN
            THEN
               CLOSE c_utenti;
            END IF;
      END;

      RETURN listaidattivita;
   END;

   PROCEDURE close_cursore (c afc.t_ref_cursor)
   IS
   BEGIN
      IF c%ISOPEN
      THEN
         CLOSE c;
      END IF;
   END;

   PROCEDURE calcola_attributi_smistamento (
      p_id_docpadre               NUMBER,
      p_stato_smistamento         VARCHAR2,
      p_des_unita_ricevente       VARCHAR2,
      p_tipo_smistamento          VARCHAR2,
      dep_url_rif_desc        OUT VARCHAR2,
      dep_rw                  OUT VARCHAR2)
   AS
   BEGIN
      SELECT    s_des_url_query
             || DECODE (
                   ag_utilities.verifica_categoria_documento (p_id_docpadre,
                                                              'FASC'),
                   1, 'fascicoli',
                   'documenti')
             || ' '
             || DECODE (p_stato_smistamento, 'R', 'da ricevere', 'in carico')
             || ' per '
             || p_des_unita_ricevente,
             DECODE (
                p_stato_smistamento,
                'C', DECODE (p_tipo_smistamento, 'COMPETENZA', 'W', 'R'),
                'R'),
             DECODE (
                ag_utilities.verifica_categoria_documento (p_id_docpadre,
                                                           'FASC'),
                1, s_iter_fasc,
                s_iter_doc)
        INTO dep_url_rif_desc, dep_rw, s_iter_doc
        FROM DUAL;
   END;

   PROCEDURE log_errore (messaggio VARCHAR2, errore VARCHAR2)
   IS
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' '
         || messaggio
         || CHR (10)
         || '    '
         || errore);
      jwf_log_utility_pkg.append_errore (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' '
         || messaggio
         || CHR (10)
         || '    '
         || errore);
   END;

   FUNCTION verifica_privilegi_utente (d_riservato            VARCHAR2,
                                       p_utente               VARCHAR2,
                                       p_stato_smistamento    VARCHAR2,
                                       p_unita_ricevente      VARCHAR2,
                                       p_assegnatario         VARCHAR2,
                                       p_dal                  DATE)
      RETURN NUMBER
   IS
      p_ret   NUMBER := 0;
   BEGIN
      IF p_utente IS NOT NULL
      THEN
         IF NVL (p_assegnatario, ' ') = p_utente
         THEN
            RETURN 1;
         END IF;

         IF p_stato_smistamento = 'C'
         THEN
            SELECT DISTINCT (1)
              INTO p_ret
              FROM ag_priv_d_utente_tmp
             WHERE     utente = p_utente
                   AND unita = p_unita_ricevente
                   AND privilegio =
                          'VS' || DECODE (d_riservato, 'Y', 'R', '')
                   AND (p_dal /*IS NULL
                     OR p_dal BETWEEN dal
                                  AND*/
                             <= NVL (al, TO_DATE (3333333, 'j')));
         ELSE
            SELECT DISTINCT (1)
              INTO p_ret
              FROM ag_priv_d_utente_tmp pvs, ag_priv_d_utente_tmp pcarico
             WHERE     pvs.utente = p_utente
                   AND pvs.unita = p_unita_ricevente
                   AND pvs.privilegio =
                          'VS' || DECODE (d_riservato, 'Y', 'R', '')
                   AND pcarico.unita = pvs.unita
                   AND pcarico.utente = pvs.utente
                   AND pcarico.privilegio = 'CARICO'
                   AND (p_dal /*IS NULL
                     OR p_dal BETWEEN pcarico.dal
                                  AND*/
                             <= NVL (pcarico.al, TO_DATE (3333333, 'j')))
                   AND (p_dal /*IS NULL
                     OR p_dal BETWEEN pvs.dal
                                  AND */
                             <= NVL (pvs.al, TO_DATE (3333333, 'j')));
         END IF;
      END IF;

      RETURN p_ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION gdm_binding (p_testo IN VARCHAR2, p_id_doc IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN si4comp_binding (REPLACE (p_testo, ':ID_DOCUMENTO', ':OGGETTO'),
                              p_id_doc,
                              'DOCUMENTI');
   END gdm_binding;

   FUNCTION init_parametri
      RETURN NUMBER
   IS
   BEGIN
      BEGIN
         SELECT valore
           INTO s_server
           FROM parametri
          WHERE codice = 'AG_SERVER_URL' AND tipo_modello = '@ag@';

         jwf_log_utility_pkg.append_log (
            n_id_log,
            'AG_RICALCOLA_ATTIVITA Parametro AG_SERVER_URL:' || s_server);

         BEGIN
            SELECT valore
              INTO s_iter_doc
              FROM parametri
             WHERE codice = 'NOME_ITER_SMIST' AND tipo_modello = '@agStrut@';
         EXCEPTION
            WHEN OTHERS
            THEN
               s_iter_doc := 'ATTIVA_ITER_DOCUMENTALE';
         END;

         jwf_log_utility_pkg.append_log (
            n_id_log,
            'AG_RICALCOLA_ATTIVITA Parametro NOME_ITER_SMIST:' || s_iter_doc);
         s_iter_fasc := 'ATTIVA_ITER_FASCICOLARE';
         jwf_log_utility_pkg.append_log (
            n_id_log,
            'AG_RICALCOLA_ATTIVITA NOME ITER FASCICOLI:' || s_iter_fasc);

         BEGIN
            SELECT valore
              INTO s_context
              FROM parametri
             WHERE codice = 'AG_CONTEXT_PATH' AND tipo_modello = '@ag@';
         EXCEPTION
            WHEN OTHERS
            THEN
               s_context := 'jdms';
         END;

         jwf_log_utility_pkg.append_log (
            n_id_log,
            'AG_RICALCOLA_ATTIVITA Parametro AG_CONTEXT_PATH:' || s_context);

         BEGIN
            SELECT id_cartella
              INTO s_idworkarea
              FROM cartelle
             WHERE nome = 'Protocollo' AND id_cartella < 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               jwf_log_utility_pkg.fine_elaborazione (
                  n_id_log,
                  'AG_RICALCOLA_ATTIVITA - Workarea Protocollo non trovata.',
                  'ERRORE');
               RETURN -1;
         END;

         jwf_log_utility_pkg.append_log (
            n_id_log,
               'AG_RICALCOLA_ATTIVITA Parametro id Workarea Protocollo:'
            || s_idworkarea);
         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            jwf_log_utility_pkg.fine_elaborazione (
               n_id_log,
                  'AG_RICALCOLA_ATTIVITA - Parametro AG_SERVER_URL@ag@ non trovato. '
               || SQLERRM,
               'ERRORE');
            RETURN -1;
      END;
   END init_parametri;

   FUNCTION split_string (str IN VARCHAR2, delimeter IN CHAR)
      RETURN string_array
   IS
      RESULT      string_array := string_array ();
      split_str   LONG DEFAULT str || delimeter;
      i           NUMBER;
   BEGIN
      LOOP
         i := INSTR (split_str, delimeter);
         EXIT WHEN NVL (i, 0) = 0;
         RESULT.EXTEND;
         RESULT (RESULT.COUNT) := TRIM (SUBSTR (split_str, 1, i - 1));
         split_str := SUBSTR (split_str, i + LENGTH (delimeter));
      END LOOP;

      RETURN RESULT;
   END split_string;

   FUNCTION f_get_url_oggetto (
      p_server_url            IN VARCHAR2,
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
      p_javascript            IN VARCHAR2 DEFAULT 'S')
      RETURN VARCHAR2
   IS
      url            VARCHAR2 (4000) := '';
      query_string   VARCHAR2 (4000) := '';
      terna          VARCHAR2 (200);
      area           documenti.area%TYPE;
      cm             tipi_documento.nome%TYPE;
      cr             documenti.codice_richiesta%TYPE;
      id_doc         documenti.id_documento%TYPE;
      id_oggetto     cartelle.id_cartella%TYPE;
      stato          documenti.stato_documento%TYPE;
      p_jdms_link    parametri.valore%TYPE;
      vterna         string_array;
      provenienza    VARCHAR2 (1);
   BEGIN
      BEGIN
         id_oggetto := p_id_oggetto;

         -- RECUPERO ID_DOCUMENTO O PROFILO
         IF LENGTH (NVL (id_oggetto, '')) > 0
         THEN
            BEGIN
               IF p_tipo_oggetto = 'C'
               THEN
                  BEGIN
                     SELECT f_iddoc_from_cartella (id_oggetto)
                       INTO id_doc
                       FROM DUAL;

                     IF id_doc = -1
                     THEN
                        raise_application_error (
                           -20999,
                              'Errore in F_IDDOC_FROM_CARTELLA. PROFILO NON TROVATO (P_ID_OGGETTO)::('
                           || id_oggetto
                           || ')');
                     END IF;
                  END;
               ELSE
                  IF p_tipo_oggetto = 'Q'
                  THEN
                     BEGIN
                        SELECT f_iddoc_from_query (id_oggetto)
                          INTO id_doc
                          FROM DUAL;

                        IF id_doc = -1
                        THEN
                           raise_application_error (
                              -20998,
                                 'Errore in F_IDDOC_FROM_QUERY. PROFILO NON TROVATO (P_ID_OGGETTO)::('
                              || id_oggetto
                              || ')');
                        END IF;
                     END;
                  ELSE
                     id_doc := id_oggetto;
                  END IF;
               END IF;
            END;
         END IF;

         -- RECUPERO TERNA CM@AREA@CR
         IF LENGTH (NVL (id_oggetto, '')) > 0
         THEN
            BEGIN
               SELECT f_cm_area_cr_from_iddoc (id_doc) INTO terna FROM DUAL;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  raise_application_error (
                     -20997,
                        'Errore in F_CM_AREA_CR_FROM_IDDOC. TERNA NON TROVATA (ID_DOC)::('
                     || id_doc
                     || ')');
            END;
         ELSE
            IF LENGTH (NVL (p_cr, '')) > 0
            THEN
               -- RECUPERO ID_OGGETTO
               BEGIN
                  SELECT f_iddoc_from_cm_area_cr (p_cm, p_area, p_cr)
                    INTO id_doc
                    FROM DUAL;

                  IF id_doc = -1
                  THEN
                     raise_application_error (
                        -20996,
                           'Errore in F_IDDOC_FROM_CM_AREA_CR ID_DOCUMENTO NON TROVATO (P_CM,P_AREA,P_CR)::('
                        || p_cm
                        || ','
                        || p_area
                        || ','
                        || p_cr
                        || ')');
                  END IF;

                  -- RECUPERO ID_QUERY O ID_CARTELLA
                  BEGIN
                     IF p_tipo_oggetto = 'Q'
                     THEN
                        SELECT id_oggetto
                          INTO id_oggetto
                          FROM QUERY
                         WHERE id_documento_profilo = id_doc;
                     ELSE
                        SELECT id_cartella
                          INTO id_oggetto
                          FROM cartelle
                         WHERE id_documento_profilo = id_doc;
                     END IF;
                  END;
               END;
            END IF;
         END IF;

         -- RECUPERO STATO DEL DOCUEMNTO
         BEGIN
            SELECT f_stato_documento (id_doc) INTO stato FROM DUAL;
         END;

         IF LENGTH (NVL (terna, '')) > 0
         THEN
            vterna := split_string (terna, '@');
            cm := vterna (1);
            area := vterna (2);
            cr := vterna (3);
         ELSE
            cm := p_cm;
            area := p_area;
            cr := p_cr;
         END IF;

         -- RECUPRO PROVENIENZA
         IF NVL (p_id_queryprovenienza, '-1') = '-1'
         THEN
            provenienza := 'C';
         ELSE
            provenienza := 'Q';
         END IF;

         -- RECUPERO PARAMETRO JDMS_LINK
         BEGIN
            SELECT ag_parametro.get_valore ('JDMS_LINK', '@DMSERVER@', 'N')
              INTO p_jdms_link
              FROM DUAL;
         END;

         IF p_jdms_link = 'S' AND LENGTH (NVL (id_doc, '')) > 0
         THEN
            IF p_javascript = 'N'
            THEN
               BEGIN
                  SELECT j.url
                    INTO url
                    FROM documenti d, jdms_link j
                   WHERE     d.id_documento = id_doc
                         AND d.id_tipodoc = j.id_tipodoc
                         AND j.tag = '-' || p_tag;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        url := '';
                     END;
               END;
            END IF;

            IF NVL (LENGTH (url), 0) = 0
            THEN
               BEGIN
                  SELECT j.url
                    INTO url
                    FROM documenti d, jdms_link j
                   WHERE     d.id_documento = id_doc
                         AND d.id_tipodoc = j.id_tipodoc
                         AND j.tag = p_tag;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        -- COSTRUZIONE URL ASSOLUTO
                        IF     LENGTH (NVL (p_server_url, '')) > 0
                           AND LENGTH (NVL (p_context_path, '')) > 0
                        THEN
                           url := p_server_url || '/' || p_context_path;
                        ELSE
                           url := '../jdms/common/';
                        END IF;

                        query_string :=
                              'idDoc='
                           || id_oggetto
                           || '&rw='
                           || p_rw
                           || '&cm='
                           || +cm
                           || '&area='
                           || area
                           || '&cr='
                           || cr
                           || '&idCartProveninez='
                           || p_id_cartprovenienza
                           || '&idQueryProveninez='
                           || p_id_queryprovenienza
                           || '&Provenienza='
                           || provenienza
                           || '&stato='
                           || NVL (stato, 'BO')
                           || '&MVPG=ServletModulisticaDocumento'
                           || '&GDC_Link=..%2Fcommon%2FClosePageAndRefresh.do%3FidQueryProveninez%3D'
                           || p_id_queryprovenienza;
                        url := url || 'DocumentoView.do?' || query_string;

                        IF p_javascript = 'S'
                        THEN
                           url :=
                                 'var wd=window.open('''
                              || url
                              || ''', '''',''toolbar= 0,location= 0,directories= 0,status= 0,menubar= 0,scrollbars= 0,copyhistory= 0,modal=yes'');resizeFullScreen(wd,0,100);';
                        END IF;
                     END;
               END;
            END IF;

            url := REPLACE (url, ':idOggetto', id_oggetto);
            url := REPLACE (url, ':tipoOggetto', p_tipo_oggetto);
            url := REPLACE (url, ':area', area);
            url := REPLACE (url, ':cm', cm);
            url := REPLACE (url, ':cr', cr);
            url := REPLACE (url, ':profilo', id_doc);
            url := REPLACE (url, ':idCartProvenienza', p_id_cartprovenienza);
            url := REPLACE (url, ':idQueryProvenienza', p_id_queryprovenienza);
            url := REPLACE (url, ':rw', p_rw);
            url := REPLACE (url, ':MVPG', 'ServletModulisticaDocumento');
            url := REPLACE (url, ':stato', NVL (stato, 'BO'));
            url := REPLACE (url, ':Provenienza', provenienza);
            url :=
               REPLACE (
                  url,
                  ':GDC_Link',
                     '..%2Fcommon%2FClosePageAndRefresh.do%3FidQueryProveninez%3D'
                  || p_id_queryprovenienza);
            url := gdm_binding (url, id_doc);
         ELSE
            BEGIN
               -- COSTRUZIONE URL ASSOLUTO
               IF     LENGTH (NVL (p_server_url, '')) > 0
                  AND LENGTH (NVL (p_context_path, '')) > 0
               THEN
                  url := p_server_url || '/' || p_context_path;
               ELSE
                  url := '../jdms/common/';
               END IF;

               query_string :=
                     'idDoc='
                  || id_oggetto
                  || '&rw='
                  || p_rw
                  || '&cm='
                  || +cm
                  || '&area='
                  || area
                  || '&cr='
                  || cr
                  || '&idCartProveninez='
                  || p_id_cartprovenienza
                  || '&idQueryProveninez='
                  || p_id_queryprovenienza
                  || '&Provenienza='
                  || provenienza
                  || '&stato='
                  || NVL (stato, 'BO')
                  || '&MVPG=ServletModulisticaDocumento' --|| '&GDC_Link=..%2Fcommon%2FClosePageAndRefresh.do%3FidQueryProveninez%3D'
                                                        --|| p_id_queryprovenienza
               ;
               url := url || 'DocumentoView.do?' || query_string;

               IF p_javascript = 'S'
               THEN
                  url :=
                        'var wd=window.open('''
                     || url
                     || ''', '''',''toolbar= 0,location= 0,directories= 0,status= 0,menubar= 0,scrollbars= 0,copyhistory= 0,modal=yes'');resizeFullScreen(wd,0,100);';
               END IF;
            END;
         END IF;
      END;

      RETURN url;
   END f_get_url_oggetto;

   FUNCTION calcola_url_documento (p_id_oggetto NUMBER, p_rw VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_id_cartella   NUMBER;
   BEGIN
      -- dbms_output.put_line('prima calcola_url_documento ');

      IF ag_utilities.verifica_categoria_documento (p_id_oggetto, 'FASC') = 1
      THEN
         SELECT id_cartella
           INTO dep_id_cartella
           FROM cartelle
          WHERE id_documento_profilo = p_id_oggetto;

         RETURN f_get_url_oggetto ('',
                                   '',
                                   dep_id_cartella,
                                   'C',
                                   '',
                                   '',
                                   '',
                                   p_rw,
                                   '',
                                   '',
                                   '5',
                                   'N');
      ELSE
         --   dbms_output.put_line('dopo calcola_url_documento ');
         RETURN f_get_url_oggetto ('',
                                   '',
                                   p_id_oggetto,
                                   'D',
                                   '',
                                   '',
                                   '',
                                   p_rw,
                                   '',
                                   '',
                                   '5',
                                   'N');
      END IF;
   END;

   FUNCTION calcola_dati_app_documento (p_id_oggetto NUMBER)
      RETURN VARCHAR2
   IS
      ret   VARCHAR2 (32000);
   BEGIN
      --dbms_output.put_line('1 calcola_dati_app_documento '||p_id_oggetto);
      IF ag_utilities.verifica_categoria_documento (p_id_oggetto, 'PROTO') =
            1
      THEN
         SELECT p.anno || '/' || LPAD (p.numero, 7, 0)
           INTO ret
           FROM proto_view p
          WHERE p.id_documento = p_id_oggetto;
      ELSIF ag_utilities.verifica_categoria_documento (p_id_oggetto,
                                                       'POSTA_ELETTRONICA') =
               1
      THEN
         --dbms_output.put_line('prima calcola_dati_app_documento '||p_id_oggetto);
         SELECT    'Messaggio '
                || DECODE (oggetto, NULL, '', 'con oggetto: ' || oggetto)
           INTO ret
           FROM seg_memo_protocollo p
          WHERE p.id_documento = p_id_oggetto;
      --dbms_output.put_line('prima calcola_dati_app_documento ');
      ELSIF ag_utilities.verifica_categoria_documento (p_id_oggetto,
                                                       'CLASSIFICABILE') = 1
      THEN
         SELECT    'Documento '
                || DECODE (DATA,
                           NULL, '',
                           'del ' || TO_CHAR (DATA, 'dd/mm/yyyy'))
                || DECODE (oggetto, NULL, '', 'oggetto: ' || oggetto)
           INTO ret
           FROM spr_da_fascicolare p
          WHERE p.id_documento = p_id_oggetto;
      ELSIF ag_utilities.verifica_categoria_documento (p_id_oggetto, 'FASC') =
               1
      THEN
         SELECT fascicolo_anno || '/' || fascicolo_numero
           INTO ret
           FROM seg_fascicoli p
          WHERE p.id_documento = p_id_oggetto;
      ELSE
         raise_application_error (
            -20999,
               'AG_RICALCOLA_ATTIVITA.calcola_dati_app_documento - Il documento '
            || p_id_oggetto
            || ' non è un documento smistabile.');
      END IF;

      RETURN ret;
   END;

   FUNCTION calcola_des_documento (p_id_oggetto           NUMBER,
                                   p_tipo_smistamento     VARCHAR2,
                                   p_stato_smistamento    VARCHAR2)
      RETURN VARCHAR2
   IS
      labelattivita   VARCHAR2 (32000);
      stipodoc        VARCHAR2 (100) := ' PG ';
   BEGIN
      --dbms_output.put_line('prima calcola_des_documento ');
      IF ag_utilities.verifica_categoria_documento (p_id_oggetto, 'PROTO') =
            1
      THEN
         BEGIN
            SELECT    DECODE (
                         p_stato_smistamento,
                         'R',    DECODE (p_tipo_smistamento,
                                         'COMPETENZA', 'Prendi in carico',
                                         'Presa visione')
                              || ' -'
                              || DECODE (
                                    td.nome,
                                    'M_PROTOCOLLO_INTEROPERABILITA', 'da PEC',
                                    '')
                              || stipodoc,
                         DECODE (
                            p_tipo_smistamento,
                            'COMPETENZA',    'In carico - '
                                          || DECODE (
                                                td.nome,
                                                'M_PROTOCOLLO_INTEROPERABILITA', 'da PEC',
                                                '')
                                          || stipodoc,
                            'Presa visione '))
                   || p.anno
                   || ' / '
                   || p.numero
                   || ': '
                   || p.oggetto
              INTO labelattivita
              FROM proto_view p, documenti d, tipi_documento td
             WHERE     p.id_documento = p_id_oggetto
                   AND p.id_documento = d.id_documento
                   AND d.id_tipodoc = td.id_tipodoc;
         --dbms_output.put_line('dopo calcola_des_documento ');
         EXCEPTION
            WHEN OTHERS
            THEN
               -- dbms_output.put_line('error calcola_des_documento ');
               raise_application_error (
                  -20999,
                     'AG_RICALCOLA_ATTIVITA.calcola_des_documento - Errore nel rintracciare il documento '
                  || p_id_oggetto
                  || ' '
                  || SQLERRM);
         END;
      ELSIF ag_utilities.verifica_categoria_documento (p_id_oggetto,
                                                       'POSTA_ELETTRONICA') =
               1
      THEN
         SELECT    DECODE (
                      p_tipo_smistamento,
                      'CONOSCENZA', 'Presa visione ',
                      DECODE (p_stato_smistamento,
                              'R', 'Prendi in carico ',
                              'In carico - '))
                || 'Messaggio '
                || DECODE (oggetto, NULL, '', 'con oggetto: ' || oggetto)
           INTO labelattivita
           FROM seg_memo_protocollo p
          WHERE p.id_documento = p_id_oggetto;
      --  dbms_output.put_line('dopo calcola_des_documento posta ele '||labelattivita);
      ELSIF ag_utilities.verifica_categoria_documento (p_id_oggetto,
                                                       'CLASSIFICABILE') = 1
      THEN
         SELECT    DECODE (
                      p_tipo_smistamento,
                      'CONOSCENZA', 'Presa visione ',
                      DECODE (p_stato_smistamento,
                              'R', 'Prendi in carico ',
                              'In carico - '))
                || 'Documento '
                || DECODE (DATA,
                           NULL, '',
                           'del ' || TO_CHAR (DATA, 'dd/mm/yyyy'))
                || DECODE (oggetto, NULL, '', 'oggetto: ' || oggetto)
           INTO labelattivita
           FROM spr_da_fascicolare p
          WHERE p.id_documento = p_id_oggetto;
      --     dbms_output.put_line('dopo calcola_des_documento class');
      ELSIF ag_utilities.verifica_categoria_documento (p_id_oggetto, 'FASC') =
               1
      THEN
         SELECT    DECODE (
                      p_tipo_smistamento,
                      'CONOSCENZA', 'Presa visione ',
                      DECODE (p_stato_smistamento,
                              'R', 'Prendi in carico ',
                              'In carico - '))
                || 'Fascicolo '
                || class_cod
                || ' - '
                || fascicolo_anno
                || '/'
                || fascicolo_numero
                || DECODE (fascicolo_oggetto,
                           NULL, '',
                           ': ' || fascicolo_oggetto)
           INTO labelattivita
           FROM seg_fascicoli p
          WHERE p.id_documento = p_id_oggetto;
      ELSE
         --   dbms_output.put_line('errore calcola_des_documento ');
         raise_application_error (
            -20999,
               'AG_RICALCOLA_ATTIVITA.calcola_des_documento - Il documento '
            || p_id_oggetto
            || ' non è un documento smistabile.');
      END IF;

      RETURN labelattivita;
   END;

   PROCEDURE ricalcola_smistamento (p_id_riferimento               NUMBER,
                                    p_codice_amm                   VARCHAR2,
                                    p_codice_aoo                   VARCHAR2,
                                    p_area                         VARCHAR2,
                                    p_codice_modello               VARCHAR2,
                                    p_codice_richiesta             VARCHAR2,
                                    p_area_docpadre                VARCHAR2,
                                    p_codice_modello_docpadre      VARCHAR2,
                                    p_codice_richiesta_docpadre    VARCHAR2,
                                    p_unita_ricevente              VARCHAR2,
                                    p_des_unita_ricevente          VARCHAR2,
                                    p_stato_smistamento            VARCHAR2,
                                    p_tipo_smistamento             VARCHAR2,
                                    p_data_smistamento             DATE,
                                    p_id_docpadre                  NUMBER,
                                    p_codice_assegnatario          VARCHAR2,
                                    p_des_uff_trasmissione         VARCHAR2)
   IS
      riga_task           jwf_task_esterni%ROWTYPE;
      listaacl            VARCHAR2 (32000);
      d_id_attivita       VARCHAR2 (32000);
      p_2                 VARCHAR2 (32000);
      d_utente            VARCHAR2 (1000);
      esistono_attivita   NUMBER := 0;

      TYPE rc_sql IS REF CURSOR;

      c_utenti            rc_sql;
      p_sel               VARCHAR2 (32000);
      isutenteabilitato   NUMBER := 0;
      d_riservato         VARCHAR2 (1);
   BEGIN
      DBMS_OUTPUT.put_line (
         '********** ricalcola_smistamento ' || p_id_riferimento);


      BEGIN
         SELECT 1
           INTO esistono_attivita
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM jwf_task_esterni
                     WHERE     id_riferimento = p_id_riferimento
                           AND tipologia IN ('ATTIVA_ITER_DOCUMENTALE',
                                             'ATTIVA_ITER_FASCICOLARE'));

         listaacl :=
            ag_utilities_cruscotto.get_utenti_accesso_smistamento (
               'SEGRETERIA',
               'M_SMISTAMENTO',
               p_codice_richiesta);
         DBMS_OUTPUT.put_line ('********** listaacl ' || listaacl);

         IF NVL (listaacl, '@') != '@'
         THEN
            p_2 := REPLACE (listaacl, '@', ''',''');
            p_2 := SUBSTR (p_2, 3);
            p_2 := SUBSTR (p_2, 1, LENGTH (p_2) - 2);
            p_sel :=
                  ' DELETE      jwf_task_esterni '
               || '  WHERE id_attivita IN ('
               || ' SELECT id_attivita '
               || '  FROM jwf_task_esterni '
               || ' WHERE id_riferimento = '''
               || p_id_riferimento
               || ''''
               || '   AND tipologia in (''ATTIVA_ITER_DOCUMENTALE'', ''ATTIVA_ITER_FASCICOLARE'')'
               || '   AND utente_esterno NOT IN ('
               || p_2
               || '))';

            EXECUTE IMMEDIATE p_sel;

            p_sel :=
                  'select utente from ad4_utenti where utente in ('
               || p_2
               || ')';

            BEGIN
               OPEN c_utenti FOR p_sel;

               LOOP
                  FETCH c_utenti INTO d_utente;

                  EXIT WHEN c_utenti%NOTFOUND;
                  isutenteabilitato := 0;
                  d_riservato :=
                     NVL (f_valore_campo (p_id_docpadre, 'RISERVATO'), 'N');

                  DECLARE
                     attivita_presente   NUMBER := 0;
                  BEGIN
                     SELECT DISTINCT id_attivita
                       INTO attivita_presente
                       FROM jwf_task_esterni
                      WHERE     utente_esterno = d_utente
                            AND id_riferimento = p_id_riferimento
                            AND tipologia IN ('ATTIVA_ITER_DOCUMENTALE',
                                              'ATTIVA_ITER_FASCICOLARE');

                     --CONTROLLIAMO I PRIVILEGI AD OGGI PER LASCIARE IN SCRIVANIA
                     --ATTIVITà SOLO PER UTENTI ABILITATI OGGI, IGNORANDO LO STORICO


                     isutenteabilitato :=
                        verifica_privilegi_utente (d_riservato,
                                                   d_utente,
                                                   p_stato_smistamento,
                                                   p_unita_ricevente,
                                                   p_codice_assegnatario,
                                                   TRUNC (SYSDATE));

                     IF isutenteabilitato = 0
                     THEN
                        BEGIN
                           jwf_utility.p_elimina_task_esterno (
                              attivita_presente,
                              p_id_riferimento,
                              'ATTIVA_ITER_DOCUMENTALE');
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              log_errore (
                                    ' **** SMISTAMENTO '
                                 || p_id_riferimento
                                 || '**** ERRORE IN CANCELLAZIONE ATTIVITA '
                                 || attivita_presente,
                                 SQLERRM);
                        END;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           DECLARE
                              d_att_esistente     NUMBER := 0;
                              d_stato_esistente   jwf_task_esterni.stato%TYPE;
                           BEGIN
                              --CONTROLLIAMO I PRIVILEGI AD OGGI PER LASCIARE IN SCRIVANIA
                              --ATTIVITà SOLO PER UTENTI ABILITATI OGGI, IGNORANDO LO STORICO
                              isutenteabilitato :=
                                 verifica_privilegi_utente (
                                    d_riservato,
                                    d_utente,
                                    p_stato_smistamento,
                                    p_unita_ricevente,
                                    p_codice_assegnatario,
                                    TRUNC (SYSDATE));

                              IF isutenteabilitato = 1
                              THEN
                                 SELECT *
                                   INTO riga_task
                                   FROM jwf_task_esterni
                                  WHERE     id_riferimento = p_id_riferimento
                                        AND ROWNUM = 1
                                        AND tipologia IN ('ATTIVA_ITER_DOCUMENTALE',
                                                          'ATTIVA_ITER_FASCICOLARE');

                                 --se c'è una riga uguale con stato A, non serve
                                 -- crearne un'altra con stato diverso da A.
                                 IF riga_task.stato = 'C'
                                 THEN
                                    SELECT DISTINCT id_attivita
                                      INTO d_att_esistente
                                      FROM jwf_task_esterni
                                     WHERE     espressione =
                                                  riga_task.espressione
                                           AND descrizione =
                                                  riga_task.descrizione
                                           AND url_rif = riga_task.url_rif
                                           AND url_rif_desc =
                                                  riga_task.url_rif_desc
                                           AND url_exec = riga_task.url_exec
                                           AND param_init_iter =
                                                  riga_task.param_init_iter
                                           AND attivita_help =
                                                  riga_task.attivita_help
                                           AND attivita_descr =
                                                  riga_task.attivita_descr
                                           AND utente_esterno = d_utente
                                           AND tipologia =
                                                  riga_task.tipologia
                                           AND dati_applicativi_1 =
                                                  riga_task.dati_applicativi_1
                                           AND stato = 'A'
                                           AND id_attivita !=
                                                  riga_task.id_attivita;
                                 --esiste già un'attivita per l'assegnazione
                                 -- non ne ricreo una per il carico
                                 ELSE
                                    raise_application_error (
                                       -20999,
                                       'Esegui codice nell''exception 2');
                                 END IF;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 d_att_esistente := 0;

                                 --                                 d_id_attivita :=
                                 --                                    jwf_utility.f_crea_task_esterno (
                                 --                                       p_id_riferimento,
                                 --                                       riga_task.descrizione,
                                 --                                       riga_task.attivita_descr,
                                 --                                       riga_task.url_rif,
                                 --                                       riga_task.url_rif_desc,
                                 --                                       riga_task.url_exec,
                                 --                                       riga_task.attivita_help,
                                 --                                       riga_task.scadenza,
                                 --                                       'SMISTAMENTO a ' || p_unita_ricevente,
                                 --                                       riga_task.nome_iter,
                                 --                                       riga_task.descrizione_iter,
                                 --                                       riga_task.colore,
                                 --                                       riga_task.ordinamento,
                                 --                                       riga_task.data_attivazione,
                                 --                                       d_utente,
                                 --                                       riga_task.categoria,
                                 --                                       riga_task.desktop,
                                 --                                       riga_task.stato,
                                 --                                       riga_task.tipologia,
                                 --                                       riga_task.dati_applicativi_1,
                                 --                                       riga_task.dati_applicativi_2,
                                 --                                       riga_task.dati_applicativi_3);

                                 IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
                                 THEN
                                    D_ID_ATTIVITA :=
                                       ag_smistamento.crea_task_esterno_new (
                                          P_ID_RIFERIMENTO,
                                          riga_task.descrizione,
                                          riga_task.attivita_descr,
                                          riga_task.url_rif,
                                          riga_task.url_rif_desc,
                                          riga_task.url_exec,
                                          riga_task.attivita_help,
                                          riga_task.scadenza,
                                          riga_task.param_init_iter,
                                          riga_task.nome_iter,
                                          riga_task.descrizione_iter,
                                          riga_task.colore,
                                          riga_task.ordinamento,
                                          d_utente,
                                          riga_task.categoria,
                                          riga_task.desktop,
                                          riga_task.stato,
                                          riga_task.stato,
                                          riga_task.stato,
                                          p_unita_ricevente,
                                          riga_task.tipologia,
                                          riga_task.dati_applicativi_1,
                                          riga_task.dati_applicativi_2,
                                          NULL,
                                          riga_task.dati_applicativi_3,
                                          p_id_docpadre,
                                          f_valore_campo (P_ID_RIFERIMENTO,
                                                          'TIPO_SMISTAMENTO'),
                                          p_des_uff_trasmissione);
                                 ELSE
                                    d_id_attivita :=
                                       jwf_utility.f_crea_task_esterno (
                                          p_id_riferimento,
                                          riga_task.descrizione,
                                          riga_task.attivita_descr,
                                          riga_task.url_rif,
                                          riga_task.url_rif_desc,
                                          riga_task.url_exec,
                                          riga_task.attivita_help,
                                          riga_task.scadenza,
                                             'SMISTAMENTO a '
                                          || p_unita_ricevente,
                                          riga_task.nome_iter,
                                          riga_task.descrizione_iter,
                                          riga_task.colore,
                                          riga_task.ordinamento,
                                          riga_task.data_attivazione,
                                          d_utente,
                                          riga_task.categoria,
                                          riga_task.desktop,
                                          riga_task.stato,
                                          riga_task.tipologia,
                                          riga_task.dati_applicativi_1,
                                          riga_task.dati_applicativi_2,
                                          riga_task.dati_applicativi_3);
                                 END IF;
                           END;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              ROLLBACK;
                              log_errore (
                                    '**** SMISTAMENTO '
                                 || p_id_riferimento
                                 || ' **** ERRORE in creazione task esterno per utente '
                                 || d_utente,
                                 SQLERRM);
                        END;
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
               END LOOP;

               close_cursore (c_utenti);
            EXCEPTION
               WHEN OTHERS
               THEN
                  close_cursore (c_utenti);
            END;
         ELSE
            BEGIN
               jwf_utility.p_elimina_task_esterno (NULL,
                                                   p_id_riferimento,
                                                   'ATTIVA_ITER_DOCUMENTALE');
            EXCEPTION
               WHEN OTHERS
               THEN
                  log_errore (
                        ' **** SMISTAMENTO '
                     || p_id_riferimento
                     || '**** nessun utente da abilitare ERRORE IN CANCELLAZIONE ATTIVITA ',
                     SQLERRM);
            END;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DECLARE
               dep_url_rif_desc   VARCHAR2 (32000);
               dep_rw             VARCHAR2 (1);
            BEGIN
               calcola_attributi_smistamento (p_id_docpadre,
                                              p_stato_smistamento,
                                              p_des_unita_ricevente,
                                              p_tipo_smistamento,
                                              dep_url_rif_desc,
                                              dep_rw);
               d_id_attivita :=
                  ag_smistamento.crea_task_esterni (
                     p_area,
                     p_codice_modello,
                     p_codice_richiesta,
                     p_area_docpadre,
                     p_codice_modello_docpadre,
                     p_codice_richiesta_docpadre,
                     p_id_riferimento,
                     p_codice_amm,
                     p_codice_aoo,
                     calcola_url_query_iter (p_id_docpadre,
                                             p_unita_ricevente,
                                             p_stato_smistamento),
                     dep_url_rif_desc,
                     calcola_url_documento (p_id_docpadre, dep_rw),
                     calcola_des_documento (p_id_docpadre,
                                            p_tipo_smistamento,
                                            p_stato_smistamento),
                     TO_CHAR (NULL),
                     s_iter_doc,
                     calcola_dati_app_documento (p_id_docpadre),
                     NULL,
                     NULL,
                     'SMISTAMENTO a ' || p_des_unita_ricevente);
            EXCEPTION
               WHEN OTHERS
               THEN
                  ROLLBACK;
                  log_errore (
                        '**** SMISTAMENTO '
                     || p_id_riferimento
                     || '**** ERRORE in ag_smistamento.crea_task_esterni in fase di ricalcolo task NUOVI.',
                     SQLERRM);
            END;
      END;

      COMMIT;
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.ricalcola_smistamento '
         || p_id_riferimento
         || s_end);
   END ricalcola_smistamento;

   PROCEDURE ricalcola_smistamento_periodo (
      p_id_riferimento               NUMBER,
      p_codice_amm                   VARCHAR2,
      p_codice_aoo                   VARCHAR2,
      p_area                         VARCHAR2,
      p_codice_modello               VARCHAR2,
      p_codice_richiesta             VARCHAR2,
      p_area_docpadre                VARCHAR2,
      p_codice_modello_docpadre      VARCHAR2,
      p_codice_richiesta_docpadre    VARCHAR2,
      p_unita_ricevente              VARCHAR2,
      p_des_unita_ricevente          VARCHAR2,
      p_stato_smistamento            VARCHAR2,
      p_tipo_smistamento             VARCHAR2,
      p_data_smistamento             DATE,
      p_id_docpadre                  NUMBER,
      p_codice_assegnatario          VARCHAR2,
      p_utente                       VARCHAR2 DEFAULT NULL,
      p_des_uff_trasmissione         VARCHAR2)
   IS
      riga_task           jwf_task_esterni%ROWTYPE;
      listaacl            VARCHAR2 (32000);
      d_id_attivita       VARCHAR2 (32000);
      p_2                 VARCHAR2 (32000);
      d_utente            VARCHAR2 (1000);
      esistono_attivita   NUMBER := 0;

      TYPE rc_sql IS REF CURSOR;

      c_utenti            rc_sql;
      p_sel               VARCHAR2 (32000);
      isutenteabilitato   NUMBER := 0;
      d_riservato         VARCHAR2 (1);
   BEGIN
      DBMS_OUTPUT.put_line (
         '********** ricalcola_smistamento_periodo ' || p_id_riferimento);



      BEGIN
         SELECT 1
           INTO esistono_attivita
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM jwf_task_esterni
                     WHERE     id_riferimento = p_id_riferimento
                           AND tipologia IN ('ATTIVA_ITER_DOCUMENTALE',
                                             'ATTIVA_ITER_FASCICOLARE'));

         DBMS_OUTPUT.put_line (
            '********** esistono_attivita ' || esistono_attivita);
         listaacl :=
            ag_utilities_cruscotto.get_utenti_accesso_smistamento (
               'SEGRETERIA',
               'M_SMISTAMENTO',
               p_codice_richiesta);
         DBMS_OUTPUT.put_line ('********** listaacl ' || listaacl);
         DBMS_OUTPUT.put_line ('********** p_utente ' || p_utente);

         IF NVL (listaacl, '@') != '@'
         THEN
            p_2 := REPLACE (listaacl, '@', ''',''');
            p_2 := SUBSTR (p_2, 3);
            p_2 := SUBSTR (p_2, 1, LENGTH (p_2) - 2);
            --            p_sel :=
            --                  ' DELETE      jwf_task_esterni '
            --               || '  WHERE id_attivita IN ('
            --               || ' SELECT id_attivita '
            --               || '  FROM jwf_task_esterni '
            --               || ' WHERE id_riferimento = '''
            --               || p_id_riferimento
            --               || ''''
            --               || '   AND tipologia in (''ATTIVA_ITER_DOCUMENTALE'', ''ATTIVA_ITER_FASCICOLARE'')'
            --               || '   AND utente_esterno NOT IN ('
            --               || p_2
            --               || '))';
            --            if p_utente is not null then
            --               p_sel := p_sel||
            --               ' AND utente_esterno = '''||p_utente||'''';
            --            end if;
            --            EXECUTE IMMEDIATE p_sel;
            DBMS_OUTPUT.PUT_LINE (P_SEL);
            p_sel :=
                  'select utente from ad4_utenti where utente in ('
               || p_2
               || ')';

            IF p_utente IS NOT NULL
            THEN
               p_sel := p_sel || ' and utente = ''' || p_utente || '''';
            END IF;

            --dbms_output.put_line('p_sel '||p_sel);
            BEGIN
               OPEN c_utenti FOR p_sel;

               LOOP
                  FETCH c_utenti INTO d_utente;

                  EXIT WHEN c_utenti%NOTFOUND;
                  isutenteabilitato := 0;
                  d_riservato :=
                     NVL (f_valore_campo (p_id_docpadre, 'RISERVATO'), 'N');
                  DBMS_OUTPUT.put_line ('********** d_utente ' || d_utente);

                  DECLARE
                     attivita_presente   NUMBER := 0;
                  BEGIN
                     SELECT DISTINCT id_attivita
                       INTO attivita_presente
                       FROM jwf_task_esterni
                      WHERE     utente_esterno = d_utente
                            AND id_riferimento = p_id_riferimento
                            AND tipologia IN ('ATTIVA_ITER_DOCUMENTALE',
                                              'ATTIVA_ITER_FASCICOLARE');

                     --CONTROLLIAMO I PRIVILEGI AD OGGI PER LASCIARE IN SCRIVANIA
                     --ATTIVITà SOLO PER UTENTI ABILITATI OGGI, IGNORANDO LO STORICO


                     isutenteabilitato :=
                        verifica_privilegi_utente (d_riservato,
                                                   d_utente,
                                                   p_stato_smistamento,
                                                   p_unita_ricevente,
                                                   p_codice_assegnatario,
                                                   TRUNC (SYSDATE));

                     IF isutenteabilitato = 0
                     THEN
                        BEGIN
                           jwf_utility.p_elimina_task_esterno (
                              attivita_presente,
                              p_id_riferimento,
                              'ATTIVA_ITER_FASCICOLARE');
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              log_errore (
                                    ' **** SMISTAMENTO '
                                 || p_id_riferimento
                                 || '**** ERRORE IN CANCELLAZIONE ATTIVITA '
                                 || attivita_presente,
                                 SQLERRM);
                        END;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           DECLARE
                              d_att_esistente     NUMBER := 0;
                              d_stato_esistente   jwf_task_esterni.stato%TYPE;
                           BEGIN
                              isutenteabilitato :=
                                 verifica_privilegi_utente (
                                    d_riservato,
                                    d_utente,
                                    p_stato_smistamento,
                                    p_unita_ricevente,
                                    p_codice_assegnatario,
                                    SYSDATE);

                              IF isutenteabilitato = 1
                              THEN
                                 SELECT *
                                   INTO riga_task
                                   FROM jwf_task_esterni
                                  WHERE     id_riferimento = p_id_riferimento
                                        AND ROWNUM = 1
                                        AND tipologia IN ('ATTIVA_ITER_DOCUMENTALE',
                                                          'ATTIVA_ITER_FASCICOLARE');

                                 --se c'è una riga uguale con stato A, non serve
                                 -- crearne un'altra con stato diverso da A.
                                 IF riga_task.stato = 'C'
                                 THEN
                                    SELECT DISTINCT id_attivita
                                      INTO d_att_esistente
                                      FROM jwf_task_esterni
                                     WHERE     espressione =
                                                  riga_task.espressione
                                           AND descrizione =
                                                  riga_task.descrizione
                                           AND url_rif = riga_task.url_rif
                                           AND url_rif_desc =
                                                  riga_task.url_rif_desc
                                           AND url_exec = riga_task.url_exec
                                           AND param_init_iter =
                                                  riga_task.param_init_iter
                                           AND attivita_help =
                                                  riga_task.attivita_help
                                           AND attivita_descr =
                                                  riga_task.attivita_descr
                                           AND utente_esterno = d_utente
                                           AND tipologia =
                                                  riga_task.tipologia
                                           AND dati_applicativi_1 =
                                                  riga_task.dati_applicativi_1
                                           AND stato = 'A'
                                           AND id_attivita !=
                                                  riga_task.id_attivita;
                                 --esiste già un'attivita per l'assegnazione
                                 -- non ne ricreo una per il carico
                                 ELSE
                                    raise_application_error (
                                       -20999,
                                       'Esegui codice nell''exception 2');
                                 END IF;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 d_att_esistente := 0;

                                 --                                 d_id_attivita :=
                                 --                                    jwf_utility.f_crea_task_esterno (
                                 --                                       p_id_riferimento,
                                 --                                       riga_task.descrizione,
                                 --                                       riga_task.attivita_descr,
                                 --                                       riga_task.url_rif,
                                 --                                       riga_task.url_rif_desc,
                                 --                                       riga_task.url_exec,
                                 --                                       riga_task.attivita_help,
                                 --                                       riga_task.scadenza,
                                 --                                       'SMISTAMENTO a ' || p_unita_ricevente,
                                 --                                       riga_task.nome_iter,
                                 --                                       riga_task.descrizione_iter,
                                 --                                       riga_task.colore,
                                 --                                       riga_task.ordinamento,
                                 --                                       riga_task.data_attivazione,
                                 --                                       d_utente,
                                 --                                       riga_task.categoria,
                                 --                                       riga_task.desktop,
                                 --                                       riga_task.stato,
                                 --                                       riga_task.tipologia,
                                 --                                       riga_task.dati_applicativi_1,
                                 --                                       riga_task.dati_applicativi_2,
                                 --                                       riga_task.dati_applicativi_3);

                                 IF AG_UTILITIES.EXISTS_SMART_DESKTOP = 1
                                 THEN
                                    D_ID_ATTIVITA :=
                                       ag_smistamento.crea_task_esterno_new (
                                          P_ID_RIFERIMENTO,
                                          riga_task.descrizione,
                                          riga_task.attivita_descr,
                                          riga_task.url_rif,
                                          riga_task.url_rif_desc,
                                          riga_task.url_exec,
                                          riga_task.attivita_help,
                                          riga_task.scadenza,
                                          riga_task.param_init_iter,
                                          riga_task.nome_iter,
                                          riga_task.descrizione_iter,
                                          riga_task.colore,
                                          riga_task.ordinamento,
                                          d_utente,
                                          riga_task.categoria,
                                          riga_task.desktop,
                                          riga_task.stato,
                                          riga_task.stato,
                                          riga_task.stato,
                                          p_unita_ricevente,
                                          riga_task.tipologia,
                                          riga_task.dati_applicativi_1,
                                          riga_task.dati_applicativi_2,
                                          NULL,
                                          riga_task.dati_applicativi_3,
                                          p_id_docpadre,
                                          f_valore_campo (P_ID_RIFERIMENTO,
                                                          'TIPO_SMISTAMENTO'),
                                          p_des_uff_trasmissione);
                                 ELSE
                                    d_id_attivita :=
                                       jwf_utility.f_crea_task_esterno (
                                          p_id_riferimento,
                                          riga_task.descrizione,
                                          riga_task.attivita_descr,
                                          riga_task.url_rif,
                                          riga_task.url_rif_desc,
                                          riga_task.url_exec,
                                          riga_task.attivita_help,
                                          riga_task.scadenza,
                                             'SMISTAMENTO a '
                                          || p_unita_ricevente,
                                          riga_task.nome_iter,
                                          riga_task.descrizione_iter,
                                          riga_task.colore,
                                          riga_task.ordinamento,
                                          riga_task.data_attivazione,
                                          d_utente,
                                          riga_task.categoria,
                                          riga_task.desktop,
                                          riga_task.stato,
                                          riga_task.tipologia,
                                          riga_task.dati_applicativi_1,
                                          riga_task.dati_applicativi_2,
                                          riga_task.dati_applicativi_3);
                                 END IF;
                           END;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              ROLLBACK;
                              log_errore (
                                    '**** SMISTAMENTO '
                                 || p_id_riferimento
                                 || ' **** ERRORE in creazione task esterno per utente '
                                 || d_utente,
                                 SQLERRM);
                        END;
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
               END LOOP;

               close_cursore (c_utenti);
            EXCEPTION
               WHEN OTHERS
               THEN
                  close_cursore (c_utenti);
            END;
         --   dbms_output.put_line('ricalcola_smistamento_periodo 2');
         /*ELSE
            BEGIN
               jwf_utility.p_elimina_task_esterno (NULL,
                                                   p_id_riferimento,
                                                   'SMISTAMENTO');
            EXCEPTION
               WHEN OTHERS
               THEN
                  log_errore (
                        ' **** SMISTAMENTO '
                     || p_id_riferimento
                     || '**** nessun utente da abilitare ERRORE IN CANCELLAZIONE ATTIVITA ',
                     SQLERRM);
            END;*/
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --    DBMS_OUTPUT.put_line ('********** esistono_attivita ' || esistono_attivita);
            DECLARE
               dep_url_rif_desc   VARCHAR2 (32000);
               dep_rw             VARCHAR2 (1);
            BEGIN
               --   dbms_output.put_line('select count ha dato 0');
               listaacl :=
                  ag_utilities_cruscotto.get_utenti_accesso_smistamento (
                     'SEGRETERIA',
                     'M_SMISTAMENTO',
                     p_codice_richiesta);

               IF    p_utente IS NULL
                  OR INSTR (listaacl, '@' || p_utente || '@') > 0
               THEN
                  --   dbms_output.put_line('ricalcolo per tutti o per '||p_utente);
                  calcola_attributi_smistamento (p_id_docpadre,
                                                 p_stato_smistamento,
                                                 p_des_unita_ricevente,
                                                 p_tipo_smistamento,
                                                 dep_url_rif_desc,
                                                 dep_rw);
                  -- dbms_output.put_line('prima crea_task_esterni_utente');
                  d_id_attivita :=
                     crea_task_esterni_utente (
                        p_area,
                        p_codice_modello,
                        p_codice_richiesta,
                        p_area_docpadre,
                        p_codice_modello_docpadre,
                        p_codice_richiesta_docpadre,
                        p_id_riferimento,
                        p_codice_amm,
                        p_codice_aoo,
                        calcola_url_query_iter (p_id_docpadre,
                                                p_unita_ricevente,
                                                p_stato_smistamento),
                        dep_url_rif_desc,
                        calcola_url_documento (p_id_docpadre, dep_rw),
                        calcola_des_documento (p_id_docpadre,
                                               p_tipo_smistamento,
                                               p_stato_smistamento),
                        TO_CHAR (NULL),
                        s_iter_doc,
                        calcola_dati_app_documento (p_id_docpadre),
                        NULL,
                        NULL,
                        'SMISTAMENTO a ' || p_des_unita_ricevente,
                        p_utente);
               --dbms_output.put_line('dopo crea_task_esterni_utente d_id_attivita '||d_id_attivita);
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ROLLBACK;
                  log_errore (
                        '**** SMISTAMENTO '
                     || p_id_riferimento
                     || '**** ERRORE in ag_smistamento.crea_task_esterni_utente in fase di ricalcolo task NUOVI.',
                     SQLERRM);
            END;
      END;

      COMMIT;
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.ricalcola_smistamento_periodo '
         || p_id_riferimento
         || s_end);
   END ricalcola_smistamento_periodo;

   PROCEDURE ricalcola_notifica (p_id_riferimento     NUMBER,
                                 p_id_documento       NUMBER,
                                 p_id_cartella        NUMBER,
                                 p_tipo               VARCHAR2,
                                 p_unita_comp         VARCHAR2,
                                 p_param_init_iter    VARCHAR2)
   IS
      riga_task           jwf_task_esterni%ROWTYPE;
      listaacl            VARCHAR2 (32000);
      d_id_attivita       VARCHAR2 (32000);
      dep_cr              documenti.codice_richiesta%TYPE;
      d_utenti_notifica   VARCHAR2 (32000) := '@';
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            'AG_RICALCOLA_ATTIVITA.ricalcola_notifica per documento '
         || p_id_documento
         || ' fascicolo '
         || p_id_cartella
         || ' tipo '
         || p_tipo
         || ' unita '
         || p_unita_comp
         || s_start);

      -- verifico se il documento è ancora in quel fasc
      BEGIN
         SELECT 1
           INTO dep_cr
           FROM links
          WHERE     id_cartella = p_id_cartella
                AND id_oggetto = p_id_documento
                AND tipo_oggetto = 'D';

         IF p_tipo = 'CARICO'
         THEN
            -- verifico se il fascicolo è ancora in carico alla stessa unita
            BEGIN
               SELECT documenti.codice_richiesta
                 INTO dep_cr
                 FROM seg_fascicoli,
                      cartelle,
                      seg_smistamenti,
                      documenti
                WHERE     cartelle.id_cartella = p_id_cartella
                      AND seg_fascicoli.id_documento =
                             cartelle.id_documento_profilo
                      AND seg_fascicoli.idrif = seg_smistamenti.idrif
                      AND seg_smistamenti.id_documento =
                             documenti.id_documento
                      AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND stato_smistamento IN ('C', 'E')
                      AND tipo_smistamento = 'COMPETENZA'
                      AND tipo_smistamento != 'DUMMY'
                      AND seg_smistamenti.ufficio_smistamento = p_unita_comp;

               d_utenti_notifica :=
                     d_utenti_notifica
                  || ag_utilities_cruscotto.get_utenti_accesso_smistamento (
                        'SEGRETERIA',
                        'M_SMISTAMENTO',
                        dep_cr);

               -- cancello le att per gli utenti non piu' interessati
               FOR a
                  IN (SELECT id_attivita, utente_esterno
                        FROM jwf_task_esterni
                       WHERE     id_riferimento = p_id_riferimento
                             AND dati_applicativi_2 = p_id_cartella
                             AND param_init_iter = p_param_init_iter
                             AND dati_applicativi_3 =
                                    p_tipo || '#' || p_unita_comp
                             AND INSTR (d_utenti_notifica,
                                        '@' || utente_esterno || '@') = 0)
               LOOP
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (a.id_attivita,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE ATTIVITA '
                           || a.id_attivita,
                           SQLERRM);
                  END;
               END LOOP;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (NULL,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE.',
                           SQLERRM);
                  END;
               WHEN OTHERS
               THEN
                  log_errore (
                        'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
                     || p_id_documento
                     || ' , '
                     || p_id_cartella
                     || ', ERRORE IN ELABORAZIONE.',
                     SQLERRM);
            END;
         ELSE
            BEGIN
               SELECT 1
                 INTO dep_cr
                 FROM seg_fascicoli, cartelle
                WHERE     cartelle.id_cartella = p_id_cartella
                      AND seg_fascicoli.id_documento =
                             cartelle.id_documento_profilo
                      AND seg_fascicoli.ufficio_competenza = p_unita_comp;

               d_utenti_notifica :=
                  ag_competenze_fascicolo.get_utenti_cref_uff_competenza (
                     p_unita_comp);

               FOR a
                  IN (SELECT id_attivita, utente_esterno
                        FROM jwf_task_esterni
                       WHERE     id_riferimento = p_id_riferimento
                             AND dati_applicativi_2 = p_id_cartella
                             AND param_init_iter = p_param_init_iter
                             AND dati_applicativi_3 =
                                    p_tipo || '#' || p_unita_comp
                             AND INSTR (d_utenti_notifica,
                                        '@' || utente_esterno || '@') = 0)
               LOOP
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (a.id_attivita,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE ATTIVITA '
                           || a.id_attivita,
                           SQLERRM);
                  END;
               END LOOP;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (NULL,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE.',
                           SQLERRM);
                  END;
               WHEN OTHERS
               THEN
                  log_errore (
                        'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
                     || p_id_documento
                     || ' , '
                     || p_id_cartella
                     || ', ERRORE IN ELABORAZIONE.',
                     SQLERRM);
            END;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               jwf_utility.p_elimina_task_esterno (NULL,
                                                   p_id_riferimento,
                                                   p_param_init_iter);
            EXCEPTION
               WHEN OTHERS
               THEN
                  log_errore (
                        'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
                     || p_id_documento
                     || ' , '
                     || p_id_cartella
                     || ', ERRORE IN CANCELLAZIONE.',
                     SQLERRM);
            END;
         WHEN OTHERS
         THEN
            log_errore (
                  'AG_RICALCOLA_ATTIVITA.ricalcola_notifica documento '
               || p_id_documento
               || ' , '
               || p_id_cartella
               || ', ERRORE IN ELABORAZIONE.',
               SQLERRM);
      END;

      COMMIT;
      jwf_log_utility_pkg.append_log (
         n_id_log,
            'AG_RICALCOLA_ATTIVITA.ricalcola_notifica '
         || p_id_documento
         || ' , '
         || p_id_cartella
         || s_end);
   END ricalcola_notifica;

   PROCEDURE cancella_notifica_utente (p_utente             VARCHAR2,
                                       p_id_attivita        NUMBER,
                                       p_id_riferimento     NUMBER,
                                       p_id_documento       NUMBER,
                                       p_id_cartella        NUMBER,
                                       p_tipo               VARCHAR2,
                                       p_unita_comp         VARCHAR2,
                                       p_param_init_iter    VARCHAR2)
   IS
      riga_task           jwf_task_esterni%ROWTYPE;
      listaacl            VARCHAR2 (32000);
      d_id_attivita       VARCHAR2 (32000);
      dep_cr              documenti.codice_richiesta%TYPE;
      d_utenti_notifica   VARCHAR2 (32000) := '@';
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente per documento '
         || p_id_documento
         || ' fascicolo '
         || p_id_cartella
         || ' tipo '
         || p_tipo
         || ' unita '
         || p_unita_comp
         || s_start);

      -- verifico se il documento è ancora in quel fasc
      BEGIN
         SELECT 1
           INTO dep_cr
           FROM links
          WHERE     id_cartella = p_id_cartella
                AND id_oggetto = p_id_documento
                AND tipo_oggetto = 'D';

         IF p_tipo = 'CARICO'
         THEN
            -- verifico se il fascicolo è ancora in carico alla stessa unita
            BEGIN
               SELECT documenti.codice_richiesta
                 INTO dep_cr
                 FROM seg_fascicoli,
                      cartelle,
                      seg_smistamenti,
                      documenti
                WHERE     cartelle.id_cartella = p_id_cartella
                      AND seg_fascicoli.id_documento =
                             cartelle.id_documento_profilo
                      AND seg_fascicoli.idrif = seg_smistamenti.idrif
                      AND seg_smistamenti.id_documento =
                             documenti.id_documento
                      AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND stato_smistamento IN ('C', 'E')
                      AND tipo_smistamento = 'COMPETENZA'
                      AND tipo_smistamento != 'DUMMY'
                      AND seg_smistamenti.ufficio_smistamento = p_unita_comp;

               d_utenti_notifica :=
                     d_utenti_notifica
                  || ag_utilities_cruscotto.get_utenti_accesso_smistamento (
                        'SEGRETERIA',
                        'M_SMISTAMENTO',
                        dep_cr);

               IF INSTR (NVL (d_utenti_notifica, '@'), p_utente) = 0
               THEN
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (p_id_attivita,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente per documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE ATTIVITA '
                           || p_id_attivita,
                           SQLERRM);
                  END;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (p_id_attivita,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE.',
                           SQLERRM);
                  END;
               WHEN OTHERS
               THEN
                  log_errore (
                        'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente documento '
                     || p_id_documento
                     || ' , '
                     || p_id_cartella
                     || ', ERRORE IN ELABORAZIONE.',
                     SQLERRM);
            END;
         ELSE
            BEGIN
               SELECT 1
                 INTO dep_cr
                 FROM seg_fascicoli, cartelle
                WHERE     cartelle.id_cartella = p_id_cartella
                      AND seg_fascicoli.id_documento =
                             cartelle.id_documento_profilo
                      AND seg_fascicoli.ufficio_competenza = p_unita_comp;

               d_utenti_notifica :=
                  ag_competenze_fascicolo.get_utenti_cref_uff_competenza (
                     p_unita_comp);

               IF INSTR (NVL (d_utenti_notifica, '@'), p_utente) = 0
               THEN
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (p_id_attivita,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE ATTIVITA '
                           || p_id_attivita,
                           SQLERRM);
                  END;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     jwf_utility.p_elimina_task_esterno (NULL,
                                                         p_id_riferimento,
                                                         p_param_init_iter);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_errore (
                              'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente documento '
                           || p_id_documento
                           || ' , '
                           || p_id_cartella
                           || ', ERRORE IN CANCELLAZIONE.',
                           SQLERRM);
                  END;
               WHEN OTHERS
               THEN
                  log_errore (
                        'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente documento '
                     || p_id_documento
                     || ' , '
                     || p_id_cartella
                     || ', ERRORE IN ELABORAZIONE.',
                     SQLERRM);
            END;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               jwf_utility.p_elimina_task_esterno (NULL,
                                                   p_id_riferimento,
                                                   p_param_init_iter);
            EXCEPTION
               WHEN OTHERS
               THEN
                  log_errore (
                        'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente documento '
                     || p_id_documento
                     || ' , '
                     || p_id_cartella
                     || ', ERRORE IN CANCELLAZIONE.',
                     SQLERRM);
            END;
         WHEN OTHERS
         THEN
            log_errore (
                  'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente documento '
               || p_id_documento
               || ' , '
               || p_id_cartella
               || ', ERRORE IN ELABORAZIONE.',
               SQLERRM);
      END;

      COMMIT;
      jwf_log_utility_pkg.append_log (
         n_id_log,
            'AG_RICALCOLA_ATTIVITA.cancella_notifica_utente '
         || p_id_documento
         || ' , '
         || p_id_cartella
         || s_end);
   END cancella_notifica_utente;

   PROCEDURE notifiche_ins_fasc_per_unita (p_unita VARCHAR2)
   IS
      dep_tipo               VARCHAR2 (100);
      dep_unita_competente   seg_unita.unita%TYPE;
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc_per_unita '
         || p_unita
         || s_start);

      FOR s IN c_notifiche_ins_fasc_per_unita (p_unita)
      LOOP
         dep_tipo :=
            SUBSTR (s.tipo_e_unita, 1, INSTR (s.tipo_e_unita, '#') - 1);
         dep_unita_competente :=
            SUBSTR (s.tipo_e_unita, INSTR (s.tipo_e_unita, '#') + 1);
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' **** NOTIFICA '
            || s.id_riferimento
            || '****'
            || s_start);
         ricalcola_notifica (s.id_riferimento,
                             s.id_documento,
                             s.id_cartella,
                             dep_tipo,
                             dep_unita_competente,
                             s.param_init_iter);
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' **** NOTIFICA '
            || s.id_riferimento
            || '****'
            || s_end);
      END LOOP;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc_per_unita '
         || p_unita
         || s_end);
   END notifiche_ins_fasc_per_unita;

   PROCEDURE notifiche_ins_fasc_tutti
   IS
      apri_cursore   BOOLEAN := TRUE;
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc_tutti'
         || s_start);

      BEGIN
         WHILE apri_cursore
         LOOP
            apri_cursore := FALSE;

            OPEN c_unita_notifiche (s_ufficio);

            IF c_unita_notifiche%ISOPEN
            THEN
               FETCH c_unita_notifiche INTO s_ufficio;

               BEGIN
                  IF c_unita_notifiche%FOUND
                  THEN
                     apri_cursore := TRUE;
                     notifiche_ins_fasc_per_unita (s_ufficio);
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     log_errore (
                           'AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc_tutti FALLITA ELABORAZIONE PER UFFICIO '
                        || s_ufficio,
                        SQLERRM);
               END;

               IF c_unita_notifiche%ISOPEN
               THEN
                  CLOSE c_unita_notifiche;
               END IF;
            END IF;
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            log_errore (
               'AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc_tutti ERRORE SUL CURSORE.',
               SQLERRM);

            IF c_unita_notifiche%ISOPEN
            THEN
               CLOSE c_unita_notifiche;
            END IF;
      END;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc_tutti'
         || s_end);
   EXCEPTION
      WHEN OTHERS
      THEN
         log_errore (
            'AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc_tutti ERRORE.',
            SQLERRM);

         IF c_unita_notifiche%ISOPEN
         THEN
            CLOSE c_unita_notifiche;
         END IF;
   END notifiche_ins_fasc_tutti;

   PROCEDURE smistamenti_per_unita_periodo (
      p_dal       DATE,
      p_al        DATE,
      p_unita     VARCHAR2,
      p_utente    VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_per_unita_periodo '
         || p_unita
         || s_start);

      FOR s IN c_smistamenti_unita_periodo (p_dal, p_al, p_unita)
      LOOP
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' Lancio ricalcolo per smistamento '
            || s.id_documento
            || ' del '
            || s.data_smistamento
            || ' tipo '
            || s.tipo_smistamento
            || ' stato '
            || s.stato_smistamento
            || ' unita ricevente '
            || s.unita_ricevente);
         ricalcola_smistamento_periodo (s.id_documento,
                                        s.codice_amministrazione,
                                        s.codice_aoo,
                                        s.area,
                                        s.codice_modello,
                                        s.codice_richiesta,
                                        s.area_docpadre,
                                        s.codice_modello_docpadre,
                                        s.codice_richiesta_docpadre,
                                        s.unita_ricevente,
                                        s.des_unita_ricevente,
                                        s.stato_smistamento,
                                        s.tipo_smistamento,
                                        s.data_smistamento,
                                        s.id_docpadre,
                                        s.codice_assegnatario,
                                        p_utente,
                                        s.des_ufficio_trasmissione);
      END LOOP;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_per_unita_periodo '
         || p_unita
         || s_end);
   EXCEPTION
      WHEN OTHERS
      THEN
         --  dbms_output.put_line('smistamenti_per_unita_periodo '||sqlerrm);
         RAISE;
   END smistamenti_per_unita_periodo;

   PROCEDURE smistamenti_per_unita (p_unita VARCHAR2)
   IS
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_per_unita '
         || p_unita
         || s_start);

      FOR s IN c_smistamenti_unita (p_unita)
      LOOP
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' Lancio ricalcolo per smistamento '
            || s.id_documento
            || ' del '
            || s.data_smistamento
            || ' tipo '
            || s.tipo_smistamento
            || ' stato '
            || s.stato_smistamento
            || ' unita ricevente '
            || s.unita_ricevente);
         ricalcola_smistamento (s.id_documento,
                                s.codice_amministrazione,
                                s.codice_aoo,
                                s.area,
                                s.codice_modello,
                                s.codice_richiesta,
                                s.area_docpadre,
                                s.codice_modello_docpadre,
                                s.codice_richiesta_docpadre,
                                s.unita_ricevente,
                                s.des_unita_ricevente,
                                s.stato_smistamento,
                                s.tipo_smistamento,
                                s.data_smistamento,
                                s.id_docpadre,
                                s.codice_assegnatario,
                                s.des_ufficio_trasmissione);
      END LOOP;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_per_unita '
         || p_unita
         || s_end);
   END smistamenti_per_unita;

   PROCEDURE smistamenti_tutti
   IS
      apri_cursore   BOOLEAN := TRUE;
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_tutti'
         || s_start);

      BEGIN
         WHILE apri_cursore
         LOOP
            apri_cursore := FALSE;

            OPEN c_unita_smistamenti_attivi (s_ufficio);

            IF c_unita_smistamenti_attivi%ISOPEN
            THEN
               FETCH c_unita_smistamenti_attivi INTO s_ufficio;

               BEGIN
                  IF c_unita_smistamenti_attivi%FOUND
                  THEN
                     apri_cursore := TRUE;
                     smistamenti_per_unita (s_ufficio);
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     log_errore (
                           'AG_RICALCOLA_ATTIVITA.smistamenti_tutti FALLITA ELABORAZIONE PER UFFICIO '
                        || s_ufficio,
                        SQLERRM);
               END;

               IF c_unita_smistamenti_attivi%ISOPEN
               THEN
                  CLOSE c_unita_smistamenti_attivi;
               END IF;
            END IF;
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            log_errore (
               'AG_RICALCOLA_ATTIVITA.smistamenti_tutti ERRORE SUL CURSORE.',
               SQLERRM);

            IF c_unita_smistamenti_attivi%ISOPEN
            THEN
               CLOSE c_unita_smistamenti_attivi;
            END IF;
      END;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_tutti'
         || s_end);
   EXCEPTION
      WHEN OTHERS
      THEN
         log_errore ('AG_RICALCOLA_ATTIVITA.smistamenti_tutti ERRORE.',
                     SQLERRM);

         IF c_unita_smistamenti_attivi%ISOPEN
         THEN
            CLOSE c_unita_smistamenti_attivi;
         END IF;
   END smistamenti_tutti;

   /*Procedure per creare attivita
   di smistamenti creati o presi in carico tra p_dal e p_al
   in caso non siano state create in automatico.
   Non cancella attivita 'errate'.
   Se specificato p_utente, lavora solo su quello.
   p_id_log va generato con la sequence jwf.log_utility_sq
   e va creata la riga corrispodente in jwf.log_utility.*/
   PROCEDURE smistamenti_periodo (p_dal       DATE,
                                  p_al        DATE,
                                  p_utente    VARCHAR2 DEFAULT NULL,
                                  p_id_log    NUMBER)
   IS
      apri_cursore   BOOLEAN := TRUE;
   BEGIN
      IF init (p_id_log) = 0
      THEN
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' AG_RICALCOLA_ATTIVITA.smistamenti_periodo'
            || s_start);

         BEGIN
            FOR S IN c_smistamenti_attivi_periodo (p_dal, p_al)
            LOOP
               DBMS_OUTPUT.PUT_LINE (
                  'SMISTAMENTI DI ' || s.ufficio_smistamento);
               smistamenti_per_unita_periodo (p_dal,
                                              p_al,
                                              s.ufficio_smistamento,
                                              p_utente);
            END LOOP;
         /*WHILE apri_cursore
         LOOP
            apri_cursore := FALSE;

            OPEN c_smistamenti_attivi_periodo (p_dal, p_al);

            IF c_smistamenti_attivi_periodo%ISOPEN
            THEN
               FETCH c_smistamenti_attivi_periodo INTO s_ufficio;

               BEGIN
                  IF c_smistamenti_attivi_periodo%FOUND
                  THEN
                     apri_cursore := TRUE;
                     smistamenti_per_unita_periodo (p_dal,
                                                    p_al,
                                                    s_ufficio,
                                                    p_utente);
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     log_errore (
                           'AG_RICALCOLA_ATTIVITA.smistamenti_periodo FALLITA ELABORAZIONE PER UFFICIO '
                        || s_ufficio,
                        SQLERRM);
               END;
               IF c_smistamenti_attivi_periodo%ISOPEN
               THEN
                  CLOSE c_smistamenti_attivi_periodo;
               END IF;
            END IF;
         END LOOP;*/
         EXCEPTION
            WHEN OTHERS
            THEN
               --     dbms_output.put_line('1 smistamenti_periodo '||sqlerrm);
               log_errore (
                  'AG_RICALCOLA_ATTIVITA.smistamenti_periodo ERRORE SUL CURSORE.',
                  SQLERRM);

               IF c_smistamenti_attivi_periodo%ISOPEN
               THEN
                  CLOSE c_smistamenti_attivi_periodo;
               END IF;
         END;

         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' AG_RICALCOLA_ATTIVITA.smistamenti_periodo'
            || s_end);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         --   dbms_output.put_line('2 smistamenti_periodo '||sqlerrm);
         log_errore ('AG_RICALCOLA_ATTIVITA.smistamenti_periodo ERRORE.',
                     SQLERRM);

         IF c_smistamenti_attivi_periodo%ISOPEN
         THEN
            CLOSE c_smistamenti_attivi_periodo;
         END IF;
   END smistamenti_periodo;


   FUNCTION init (p_id_log NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      n_id_log := p_id_log;
      RETURN init_parametri;
   END;

   PROCEDURE smistamenti (p_unita     VARCHAR2,
                          p_utente    VARCHAR2,
                          p_id_log    NUMBER)
   IS
   BEGIN
      IF init (p_id_log) = 0
      THEN
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' AG_RICALCOLA_ATTIVITA.smistamenti'
            || s_start);

         -- per ogni id_riferimento cancello tutte le attivita
         -- ricalcolo e commit
         BEGIN
            IF NVL (p_unita, '*') = '*'
            THEN
               smistamenti_tutti;
            ELSE
               smistamenti_per_unita (p_unita);
            END IF;

            jwf_log_utility_pkg.append_log (
               n_id_log,
                  TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
               || ' AG_RICALCOLA_ATTIVITA.smistamenti'
               || s_end);
            jwf_log_utility_pkg.fine_elaborazione (n_id_log, NULL, 'OK');
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               jwf_log_utility_pkg.fine_elaborazione (
                  n_id_log,
                     TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                  || ' AG_RICALCOLA_ATTIVITA.smistamenti '
                  || CHR (10)
                  || '    '
                  || SQLERRM,
                  'ERRORE');
         END;
      END IF;
   END smistamenti;


   PROCEDURE notifiche_ins_fasc (p_unita     VARCHAR2,
                                 p_utente    VARCHAR2,
                                 p_id_log    NUMBER)
   IS
   BEGIN
      IF p_id_log > 0
      THEN
         n_id_log := p_id_log;
         jwf_log_utility_pkg.set_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc'
            || s_start);

         -- per ogni id_riferimento cancello tutte le attivita
         -- ricalcolo e commit
         BEGIN
            IF NVL (p_unita, '*') = '*'
            THEN
               notifiche_ins_fasc_tutti;
            ELSE
               notifiche_ins_fasc_per_unita (p_unita);
            END IF;

            jwf_log_utility_pkg.append_log (
               n_id_log,
                  TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
               || ' AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc'
               || s_end);
            jwf_log_utility_pkg.fine_elaborazione (n_id_log, NULL, 'OK');
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               jwf_log_utility_pkg.fine_elaborazione (
                  n_id_log,
                     TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                  || ' AG_RICALCOLA_ATTIVITA.notifiche_ins_fasc '
                  || CHR (10)
                  || '    '
                  || SQLERRM,
                  'ERRORE');
         END;
      END IF;
   END notifiche_ins_fasc;

   PROCEDURE smistamenti_per_unita_ca (p_unita VARCHAR2)
   IS
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_per_unita_ca '
         || p_unita
         || s_start);
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' **** CANCELLO ATTIVITA PER EVENTUALI SMISTAMENTI IN STATO CA '
         || s_start);

      FOR s IN c_smistamenti_unita_ca (p_unita)
      LOOP
         BEGIN
            jwf_utility.p_elimina_task_esterno (NULL,
                                                s.id_documento,
                                                'ATTIVA_ITER_FASCICOLARE');
         EXCEPTION
            WHEN OTHERS
            THEN
               log_errore (
                     '**** SMISTAMENTO '
                  || s.id_documento
                  || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                  || ' **** ERRORE IN ELIMINAZIONE ATTIVITA.',
                  SQLERRM);
         END;
      END LOOP;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' **** CANCELLO ATTIVITA PER EVENTUALI SMISTAMENTI IN STATO CA '
         || s_end);
      COMMIT;
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_per_unita_ca '
         || p_unita
         || s_end);
   END smistamenti_per_unita_ca;

   PROCEDURE smistamenti_tutti_ca
   IS
      apri_cursore   BOOLEAN := TRUE;
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_tutti_ca'
         || s_start);

      BEGIN
         WHILE apri_cursore
         LOOP
            apri_cursore := FALSE;

            OPEN c_unita_smistamenti_attivi_ca (s_ufficio);

            IF c_unita_smistamenti_attivi_ca%ISOPEN
            THEN
               FETCH c_unita_smistamenti_attivi_ca INTO s_ufficio;

               BEGIN
                  IF c_unita_smistamenti_attivi_ca%FOUND
                  THEN
                     apri_cursore := TRUE;
                     smistamenti_per_unita_ca (s_ufficio);
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     log_errore (
                           'AG_RICALCOLA_ATTIVITA.smistamenti_tutti_ca FALLITA ELABORAZIONE PER UFFICIO '
                        || s_ufficio,
                        SQLERRM);
               END;

               IF c_unita_smistamenti_attivi_ca%ISOPEN
               THEN
                  CLOSE c_unita_smistamenti_attivi_ca;
               END IF;
            END IF;
         END LOOP;
      EXCEPTION
         WHEN OTHERS
         THEN
            log_errore (
               'AG_RICALCOLA_ATTIVITA.smistamenti_tutti_ca ERRORE SUL CURSORE.',
               SQLERRM);

            IF c_unita_smistamenti_attivi_ca%ISOPEN
            THEN
               CLOSE c_unita_smistamenti_attivi_ca;
            END IF;
      END;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
         || ' AG_RICALCOLA_ATTIVITA.smistamenti_tutti_ca'
         || s_end);
   EXCEPTION
      WHEN OTHERS
      THEN
         log_errore ('AG_RICALCOLA_ATTIVITA.smistamenti_tutti_ca ERRORE.',
                     SQLERRM);

         IF c_unita_smistamenti_attivi_ca%ISOPEN
         THEN
            CLOSE c_unita_smistamenti_attivi_ca;
         END IF;
   END smistamenti_tutti_ca;

   PROCEDURE smistamenti_cancellati (p_unita     VARCHAR2,
                                     p_utente    VARCHAR2,
                                     p_id_log    NUMBER)
   IS
   BEGIN
      IF init (p_id_log) = 0
      THEN
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' AG_RICALCOLA_ATTIVITA.smistamenti'
            || s_start);

         -- per ogni id_riferimento cancello tutte le attivita
         -- ricalcolo e commit
         BEGIN
            IF NVL (p_unita, '*') = '*'
            THEN
               smistamenti_tutti_ca;
            ELSE
               smistamenti_per_unita_ca (p_unita);
            END IF;

            jwf_log_utility_pkg.append_log (
               n_id_log,
                  TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
               || ' AG_RICALCOLA_ATTIVITA.smistamenti'
               || s_end);
            jwf_log_utility_pkg.fine_elaborazione (n_id_log, NULL, 'OK');
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               jwf_log_utility_pkg.fine_elaborazione (
                  n_id_log,
                     TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                  || ' AG_RICALCOLA_ATTIVITA.smistamenti '
                  || CHR (10)
                  || '    '
                  || SQLERRM,
                  'ERRORE');
         END;
      END IF;
   END smistamenti_cancellati;

   PROCEDURE cancella_smistamento_utente (p_codice_richiesta    VARCHAR2,
                                          p_id_attivita         NUMBER,
                                          p_id_riferimento      VARCHAR2,
                                          P_UTENTE              VARCHAR2)
   AS
      listaacl   VARCHAR2 (32000);
   BEGIN
      jwf_log_utility_pkg.append_log (
         n_id_log,
            'AG_RICALCOLA_ATTIVITA.cancella_smistamento_utente per documento '
         || p_id_riferimento
         || s_start);

      listaacl :=
         ag_utilities_cruscotto.get_utenti_accesso_smistamento (
            'SEGRETERIA',
            'M_SMISTAMENTO',
            p_codice_richiesta);

      --  dbms_output.put_line( 'AG_RICALCOLA_ATTIVITA.cancella_smistamento_utente per documento '
      --     || p_id_riferimento);
      --  dbms_output.put_line('listaacl '||listaacl);
      IF INSTR (NVL (listaacl, '@'), p_utente) = 0
      THEN
         BEGIN
            jwf_utility.p_elimina_task_esterno (p_id_attivita,
                                                p_id_riferimento,
                                                'ATTIVA_ITER_FASCICOLARE');

            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               log_errore (
                     'AG_RICALCOLA_ATTIVITA.cancella_smistamento_utente per documento '
                  || p_id_riferimento
                  || ', ERRORE IN CANCELLAZIONE ATTIVITA '
                  || p_id_attivita,
                  SQLERRM);
         END;
      END IF;

      jwf_log_utility_pkg.append_log (
         n_id_log,
            'AG_RICALCOLA_ATTIVITA.cancella_smistamento_utente '
         || p_id_riferimento
         || s_end);
   END cancella_smistamento_utente;

   PROCEDURE cancella_attivita_utente (p_nominativo    VARCHAR2,
                                       p_utente        VARCHAR2,
                                       p_id_log        NUMBER)
   IS
      dep_utente   VARCHAR2 (8);
      listaacl     VARCHAR2 (32000);
   BEGIN
      IF init (p_id_log) = 0
      THEN
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' AG_RICALCOLA_ATTIVITA.cancella_attivita_utente '
            || p_nominativo
            || s_start);
         dep_utente := ad4_utente.get_utente (p_nominativo => p_nominativo);

         IF dep_utente IS NULL
         THEN
            jwf_log_utility_pkg.fine_elaborazione (
               n_id_log,
                  TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
               || ' AG_RICALCOLA_ATTIVITA.cancella_attivita_utente '
               || p_nominativo
               || ' non presente ',
               'ERRORE');
            RETURN;
         END IF;

         FOR s IN c_attivita_utente_smistamenti (dep_utente)
         LOOP
            cancella_smistamento_utente (s.codice_richiesta,
                                         s.id_attivita,
                                         s.id_riferimento,
                                         DEP_UTENTE);
         END LOOP;

         --  DBMS_OUTPUT.put_line ('fine loop smista');

         FOR n IN c_attivita_utente_notifiche (dep_utente)
         LOOP
            --     DBMS_OUTPUT.put_line ('loop noti id doc ' || n.id_documento);
            cancella_notifica_utente (dep_utente,
                                      n.id_attivita,
                                      n.id_riferimento,
                                      n.id_documento,
                                      n.id_cartella,
                                      n.tipo,
                                      n.unita_competente,
                                      n.param_init_iter);
         END LOOP;

         --  DBMS_OUTPUT.put_line ('fine loop noti');
         jwf_log_utility_pkg.append_log (
            n_id_log,
               TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
            || ' AG_RICALCOLA_ATTIVITA.cancella_attivita_utente '
            || p_nominativo
            || s_end);
         jwf_log_utility_pkg.fine_elaborazione (n_id_log, NULL, 'OK');
      END IF;
   END cancella_attivita_utente;
END;
/
