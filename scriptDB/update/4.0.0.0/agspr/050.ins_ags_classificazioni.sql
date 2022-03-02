--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_050.ins_ags_classificazioni
--preconditions onFail:MARK_RAN
--precondition-sql-check expectedResult:1 SELECT count(1) FROM user_views where VIEW_NAME = 'AGS_CLASSIFICAZIONI'
-- se presenti (in installazione potrebbero non essere ancora presenti), disabilito i trigger di allineamento con gdm

BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_tiu disable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_taiu disable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/


BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_num_tiu disable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_unita_tiu disable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/

DECLARE
   d_radice               VARCHAR2 (255);
   d_resto                VARCHAR2 (255);
   d_parte                VARCHAR2 (255);
   d_separatore           VARCHAR2 (255);
   d_progressivo          NUMBER;
   d_progressivo_padre    NUMBER;
   d_class_trovata        NUMBER;
   d_id_classificazione   NUMBER;
BEGIN
   SELECT valore
     INTO d_separatore
     FROM gdo_impostazioni
    WHERE codice = 'SEP_CLASSIFICA';

   -- per prima cosa scorro tutte le classifiche "padre"
   FOR c
      IN (  SELECT -ts.id_documento id_classificazione,
                   ts.id_documento id_documento_esterno,
                   NULL id_classificazione_padre,
                   class_cod,
                   class_dal,
                   class_al,
                   ts.class_descr,
                   CAST (NVL (contenitore_documenti, 'N') AS CHAR (1))
                      contenitore_documenti,
                   CAST (NVL (num_illimitata, 'N') AS CHAR (1)) num_illimitata --  , class_cod
                                                                              ,
                   NVL (ins_doc_in_fasc_con_sub, 'N') doc_fascicoli_sub,
                   note,
                   enti.id_ente,
                   CAST (
                      DECODE (
                         NVL (c.stato, 'BO'),
                         'CA', 'N',
                         DECODE (NVL (d.stato_documento, 'BO'), 'CA', 'N', 'Y')) AS CHAR (1))
                      valido,
                   'RPI' utente_ins,
                   data_creazione data_ins,
                   d.utente_aggiornamento utente_upd,
                   d.data_aggiornamento data_upd,
                   0 version
              FROM gdm_classificazioni ts,
                   gdm_documenti d,
                   gdm_cartelle c,
                   gdo_enti enti
             WHERE     d.id_documento = ts.id_documento
                   AND c.id_documento_profilo = d.id_documento
                   AND enti.amministrazione = ts.codice_amministrazione
                   AND d.stato_documento = 'BO'
                   AND NVL (c.stato, 'BO') = 'BO'
                   AND enti.aoo = ts.codice_aoo
                   AND enti.ottica = gdm_ag_parametro.get_valore (
                                        'SO_OTTICA_PROT',
                                        ts.codice_amministrazione,
                                        ts.codice_aoo,
                                        '')
                   AND INSTR (class_cod, d_separatore) = 0
          ORDER BY class_cod, class_dal)
   LOOP
      --verifico se ho già inserito la classificazione precedentemente.....in questo caso devo riportare lo stesso progressivo
      BEGIN
         SELECT DISTINCT progressivo
           INTO d_progressivo
           FROM ags_classificazioni_new
          WHERE classificazione = c.class_cod;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_progressivo := c.id_documento_esterno;
      END;

      -- solo se non ho trovato la classificazione allora la inserisco
      INSERT INTO ags_classificazioni_new (id_classificazione,
                                           id_documento_esterno,
                                           progressivo,
                                           progressivo_padre,
                                           classificazione,
                                           classificazione_dal,
                                           classificazione_al,
                                           descrizione,
                                           contenitore_documenti,
                                           doc_fascicoli_sub,
                                           num_illimitata,
                                           note,
                                           id_ente,
                                           valido,
                                           utente_ins,
                                           data_ins,
                                           utente_upd,
                                           data_upd,
                                           version)
         SELECT c.id_classificazione,
                c.id_documento_esterno,
                d_progressivo,
                NULL,
                c.class_cod,
                c.class_dal,
                c.class_al,
                c.class_descr,
                c.contenitore_documenti,
                c.doc_fascicoli_sub,
                c.num_illimitata,
                c.note,
                c.id_ente,
                c.valido,
                c.utente_ins,
                NVL (c.data_ins, c.class_dal),
                c.utente_upd,
                c.data_upd,
                c.version
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM ags_classificazioni_new
                     WHERE     classificazione = c.class_cod
                           AND classificazione_dal = c.class_dal);
   END LOOP;

   FOR i IN 1 .. 99
   LOOP
      --scorro tutte le classifiche "figlie"
      FOR c
         IN (SELECT -ts.id_documento id_classificazione,
                    ts.id_documento id_documento_esterno,
                    class_cod classificazione,
                    class_dal classificazione_dal,
                    class_al classificazione_al,
                    ts.class_descr descrizione,
                    CAST (NVL (contenitore_documenti, 'N') AS CHAR (1))
                       contenitore_documenti,
                    CAST (NVL (num_illimitata, 'N') AS CHAR (1))
                       num_illimitata                          --  , class_cod
                                     ,
                    NVL (ins_doc_in_fasc_con_sub, 'N') doc_fascicoli_sub,
                    note,
                    enti.id_ente,
                    CAST (
                       DECODE (
                          NVL (c.stato, 'BO'),
                          'CA', 'N',
                          DECODE (NVL (d.stato_documento, 'BO'),
                                  'CA', 'N',
                                  'Y')) AS CHAR (1))
                       valido,
                    'RPI' utente_ins,
                    data_creazione data_ins,
                    d.utente_aggiornamento utente_upd,
                    d.data_aggiornamento data_upd,
                    0 version
               FROM gdm_classificazioni ts,
                    gdm_documenti d,
                    gdm_cartelle c,
                    gdo_enti enti
              WHERE     d.id_documento = ts.id_documento
                    AND c.id_documento_profilo = d.id_documento
                    AND enti.amministrazione = ts.codice_amministrazione
                    AND enti.aoo = ts.codice_aoo
                    AND d.stato_documento = 'BO'
                    AND NVL (c.stato, 'BO') = 'BO'
                    AND enti.ottica = gdm_ag_parametro.get_valore (
                                         'SO_OTTICA_PROT',
                                         ts.codice_amministrazione,
                                         ts.codice_aoo,
                                         '')
                    AND AFC.COUNTOCCURRENCEOF (class_cod, d_separatore) = i)
      LOOP
         BEGIN
            DBMS_OUTPUT.put_line (
               '=================================================');
            DBMS_OUTPUT.put_line (i);
            DBMS_OUTPUT.put_line (
               '=================================================');

            --calcolo la radice della classifica e quello che resta (tutto ciò dopo il separatore)
            d_radice :=
               SUBSTR (c.classificazione,
                       1,
                         INSTR (c.classificazione,
                                d_separatore,
                                1,
                                i)
                       - 1);

            BEGIN
               --trovo l'id del padre già inserito
               SELECT DISTINCT progressivo
                 INTO d_progressivo_padre
                 FROM ags_classificazioni_new
                WHERE     classificazione = d_radice
                      AND classificazione_dal = c.classificazione_dal;
            EXCEPTION
               WHEN OTHERS
               THEN
                  BEGIN
                     --trovo l'id del padre già inserito
                     SELECT DISTINCT progressivo
                       INTO d_progressivo_padre
                       FROM ags_classificazioni_new
                      WHERE     classificazione = d_radice
                            AND c.classificazione_dal BETWEEN classificazione_dal
                                                          AND NVL (
                                                                 classificazione_al,
                                                                 c.classificazione_dal);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        BEGIN
                           SELECT DISTINCT progressivo
                             INTO d_progressivo_padre
                             FROM ags_classificazioni_new
                            WHERE classificazione = d_radice AND ROWNUM = 1;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              raise_application_error (
                                 -20999,
                                    'Errore recupero progressivo padre ('
                                 || d_radice
                                 || ') di '
                                 || c.classificazione
                                 || ' del '
                                 || c.classificazione_dal
                                 || ': '
                                 || SQLERRM);
                        END;
                  END;
            END;


            DBMS_OUTPUT.put_line (
                  'Sto inserendo '
               || c.classificazione
               || ' del '
               || c.classificazione_dal
               || ' figlia di id  '
               || d_progressivo_padre);

            INSERT INTO ags_classificazioni_new (id_classificazione,
                                                 id_documento_esterno,
                                                 progressivo,
                                                 progressivo_padre,
                                                 classificazione,
                                                 classificazione_dal,
                                                 classificazione_al,
                                                 descrizione,
                                                 contenitore_documenti,
                                                 doc_fascicoli_sub,
                                                 num_illimitata,
                                                 note,
                                                 id_ente,
                                                 valido,
                                                 utente_ins,
                                                 data_ins,
                                                 utente_upd,
                                                 data_upd,
                                                 version)
               SELECT c.id_classificazione,
                      c.id_documento_esterno,
                      c.id_classificazione,
                      d_progressivo_padre,
                      c.classificazione,
                      c.classificazione_dal,
                      c.classificazione_al,
                      c.descrizione,
                      c.contenitore_documenti,
                      c.doc_fascicoli_sub,
                      c.num_illimitata,
                      c.note,
                      c.id_ente,
                      c.valido,
                      c.utente_ins,
                      NVL (c.data_ins, c.classificazione_dal),
                      c.utente_upd,
                      c.data_upd,
                      c.version
                 FROM DUAL
                WHERE NOT EXISTS
                         (SELECT 1
                            FROM ags_classificazioni_new
                           WHERE     classificazione = c.classificazione
                                 AND classificazione_dal =
                                        c.classificazione_dal);
         --d_id_classificazione := c.id_classificazione;
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END LOOP;
   END LOOP;
END;
/

BEGIN
   FOR clas_num
      IN (SELECT -gsnc.id_documento id_classificazione_num,
                 acn.id_classificazione id_classificazione,
                 gsnc.anno anno,
                 gsnc.ultimo_numero_sub ultimo_numero_fascicolo,
                 e.id_ente id_ente,
                 'Y' valido,
                 'RPI' utente_ins,
                 SYSDATE data_ins,
                 'RPI' utente_upd,
                 SYSDATE data_upd,
                 0 version
            FROM ags_classificazioni_new acn,
                 gdm_seg_numerazioni_classifica gsnc,
                 gdo_enti e
           WHERE     gsnc.class_cod = acn.classificazione
                 AND gsnc.class_dal = acn.classificazione_dal
                 AND e.id_ente = 1
                 AND gsnc.codice_amministrazione = e.amministrazione)
   LOOP
      INSERT INTO ags_classificazioni_num (id_classificazione_num,
                                           id_classificazione,
                                           anno,
                                           ultimo_numero_fascicolo,
                                           id_ente,
                                           valido,
                                           utente_ins,
                                           data_ins,
                                           utente_upd,
                                           data_upd,
                                           version)
         SELECT clas_num.id_classificazione_num,
                clas_num.id_classificazione,
                clas_num.anno,
                clas_num.ultimo_numero_fascicolo,
                clas_num.id_ente,
                clas_num.valido,
                clas_num.utente_ins,
                clas_num.data_ins,
                clas_num.utente_upd,
                clas_num.data_upd,
                clas_num.version
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM ags_classificazioni_num
                     WHERE     id_classificazione =
                                  clas_num.id_classificazione
                           AND anno = clas_num.anno
                           AND id_ente = 1);
   END LOOP;
END;
/

DECLARE
   d_id_classificazione   NUMBER;
   d_progr                NUMBER;
   d_dal                  DATE;
   d_ottica               VARCHAR2 (255);
BEGIN
   FOR c
      IN (SELECT uni.class_cod,
                 uni.class_dal,
                 uni.codice_amministrazione,
                 uni.codice_aoo,
                 uni.descrizione_unita_smistamento,
                 uni.unita,
                 e.id_ente
            FROM gdm_seg_classificazioni cla,
                 gdm_seg_unita_classifica uni,
                 gdo_enti e,                    -- devo inserire per ogni ente
                 gdm_documenti d,
                 gdm_cartelle c
           WHERE     d.id_documento = cla.id_documento
                 AND c.id_documento_profilo = d.id_documento
                 AND d.stato_documento = 'BO'
                 AND NVL (c.stato, 'BO') = 'BO'
                 AND cla.class_cod = uni.class_cod
                 AND cla.class_dal = uni.class_dal
                 AND cla.codice_amministrazione = uni.codice_amministrazione)
   LOOP
      BEGIN
         SELECT id_classificazione
           INTO d_id_classificazione
           FROM ags_classificazioni_new
          WHERE     classificazione = c.class_cod
                AND classificazione_dal = c.class_dal;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20999,
               c.class_cod || ' ' || c.class_dal || ' ' || SQLERRM);
      END;

      BEGIN
         SELECT progr, dal, ottica
           INTO d_progr, d_dal, d_ottica
           FROM so4_v_unita_organizzative_pubb
          WHERE codice = c.unita AND al IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT progr, dal, ottica
                 INTO d_progr, d_dal, d_ottica
                 FROM (  SELECT progr, dal, ottica
                           FROM so4_v_unita_organizzative_pubb
                          WHERE codice = c.unita AND al IS NOT NULL
                       ORDER BY dal DESC)
                WHERE ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_progr := NULL;
                  d_dal := NULL;
                  d_ottica := NULL;
            END;
      END;

      IF d_progr IS NOT NULL
      THEN
         INSERT INTO ags_classificazioni_unita (id_classificazione_unita,
                                                id_classificazione,
                                                unita_progr,
                                                unita_dal,
                                                unita_ottica,
                                                id_ente,
                                                valido,
                                                utente_ins,
                                                data_ins,
                                                utente_upd,
                                                data_upd,
                                                version)
              VALUES (hibernate_sequence.NEXTVAL,
                      d_id_classificazione,
                      d_progr,
                      d_dal,
                      d_ottica,
                      c.id_ente,
                      'Y',
                      'RPI',
                      SYSDATE,
                      'RPI',
                      SYSDATE,
                      0);
      END IF;
   END LOOP;
   commit;
END;
/

-- se presenti (in installazione potrebbero non essere ancora presenti), riabilito i trigger di allineamento con gdm

BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_tiu enable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_tiu enable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_num_tiu enable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'alter trigger ags_classificazioni_unita_tiu enable';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/
