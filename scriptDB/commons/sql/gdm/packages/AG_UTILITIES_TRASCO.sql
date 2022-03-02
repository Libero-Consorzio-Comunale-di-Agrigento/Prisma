--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_TRASCO runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_utilities_trasco
AS
/******************************************************************************
   NAME:       AG_UTILITIES
   PURPOSE:    Package di utilities di trascodifica per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver        Date        Author          Description
   ---------  ----------  --------------- ------------------------------------
   00         20/12/2012                  Created this package.
******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE EXECUTE_NUM_CLASSFASC(A_ANNO_FASC NUMBER,A_CODAMM VARCHAR2, A_CODAOO VARCHAR2);
   PROCEDURE DUPLICA_ANNO_FASCICOLO(A_ANNO_DA NUMBER, A_ANNO_A NUMBER, A_NUMERO_DA VARCHAR2, A_NUMERO_A VARCHAR2, A_CODAMM VARCHAR2, A_CODAOO VARCHAR2);

      PROCEDURE duplica_anno_fascicolo (
      a_class_cod   VARCHAR2,
      a_class_dal   VARCHAR2,
      a_anno_da     NUMBER,
      a_anno_a      NUMBER,
      a_numero_da   VARCHAR2,
      a_numero_a    VARCHAR2,
      a_codamm      VARCHAR2,
      a_codaoo      VARCHAR2
   );
END;
/
CREATE OR REPLACE PACKAGE BODY ag_utilities_trasco
AS
/******************************************************************************
   NAME:       AG_UTILITIES_TRASCO
   PURPOSE:    Package di utilities di trascodifica per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver        Date        Author          Description
   ---------  ----------  --------------- ------------------------------------
   000        20/12/2012                  Created this package.
   001        08/01/2019   mmalferrari    Modificata duplica_anno_fascicolo
                                          per evitare a priori che selezioni
                                          i sub-fascicoli.
******************************************************************************/
   s_revisione_body   afc.t_revision := '001';

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

   PROCEDURE sistema_ultimo_numero_sub (
      a_id_documento       NUMBER,
      a_class_cod          VARCHAR2,
      a_class_dal          DATE,
      a_fascicolo_anno     NUMBER,
      a_fascicolo_numero   VARCHAR2
   )
   AS
      dep_max_sub   NUMBER;
   BEGIN
      DBMS_OUTPUT.put_line ('a_id_documento ' || a_id_documento);
      DBMS_OUTPUT.put_line ('a_class_cod ' || a_class_cod);
      DBMS_OUTPUT.put_line ('a_class_dal ' || a_class_dal);
      DBMS_OUTPUT.put_line ('a_fascicolo_anno ' || a_fascicolo_anno);
      DBMS_OUTPUT.put_line ('a_fascicolo_numero ' || a_fascicolo_numero);

      SELECT MAX (TO_NUMBER (SUBSTR (fascicolo_numero,
                                     INSTR (fascicolo_numero, '.', -1) + 1
                                    )
                            )
                 )
        INTO dep_max_sub
        FROM seg_fascicoli, cartelle, documenti
       WHERE seg_fascicoli.class_cod = a_class_cod
         AND seg_fascicoli.class_dal = a_class_dal
         AND seg_fascicoli.fascicolo_anno = a_fascicolo_anno
         AND seg_fascicoli.fascicolo_numero LIKE a_fascicolo_numero || '.%'
         AND seg_fascicoli.fascicolo_numero NOT LIKE
                                                  a_fascicolo_numero || '.%.%'
         AND seg_fascicoli.id_documento = documenti.id_documento
         AND documenti.stato_documento NOT IN ('CA', 'PB', 'RE')
         AND documenti.id_documento = cartelle.id_documento_profilo
         AND NVL (cartelle.stato, 'BO') != 'CA';

      UPDATE seg_fascicoli
         SET ultimo_numero_sub = NVL (dep_max_sub, 0)
       WHERE id_documento = a_id_documento;

      COMMIT;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('ERRR ' || SQLERRM);
         RAISE;
   END;

   PROCEDURE execute_num_classfasc (
      a_anno_fasc   NUMBER,
      a_codamm      VARCHAR2,
      a_codaoo      VARCHAR2
   )
   AS
      TYPE selcur IS REF CURSOR;

      utenticur          selcur;
      a_class_cod        seg_classificazioni.class_cod%TYPE;
      a_class_dal        seg_classificazioni.class_dal%TYPE;
      a_num_illimitata   seg_classificazioni.num_illimitata%TYPE;
      a_select           VARCHAR2 (32000);
      a_err              VARCHAR2 (32000);

      CURSOR estrazione_da_tabella
      IS
         SELECT   seg_classificazioni.class_cod,
                  seg_classificazioni.class_dal,
                  seg_classificazioni.num_illimitata
             FROM seg_classificazioni, seg_fascicoli, cartelle, documenti
            WHERE seg_fascicoli.fascicolo_anno = a_anno_fasc
              AND seg_fascicoli.class_cod = seg_classificazioni.class_cod
              AND seg_fascicoli.class_dal = seg_classificazioni.class_dal
              AND seg_classificazioni.contenitore_documenti = 'Y'
              AND seg_classificazioni.num_illimitata <> 'Y'
              AND seg_classificazioni.id_documento = documenti.id_documento
              AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
              AND documenti.id_documento = cartelle.id_documento_profilo
              AND NVL (cartelle.stato, 'BO') != 'CA'
         ORDER BY 1, 2;
   BEGIN
      OPEN estrazione_da_tabella;

      LOOP
         DECLARE
            a_elab_annocorr   BOOLEAN         := FALSE;
            a_iddoc           NUMBER (10);
            a_ret_char        VARCHAR2 (4000);
            a_ret             NUMBER (1)      := 0;
            a_chiavi          VARCHAR2 (1000);
         BEGIN
            FETCH estrazione_da_tabella
             INTO a_class_cod, a_class_dal, a_num_illimitata;

            EXIT WHEN estrazione_da_tabella%NOTFOUND;
            a_select := 'SELECT ';
            a_select := a_select || 'fascicolo_anno';
            a_select :=
                   a_select || ', nvl(MAX (TO_NUMBER (fascicolo_numero)),0) ';
            a_select := a_select || ' FROM seg_fascicoli fasc ';
            a_select := a_select || ', documenti docu ';
            a_select := a_select || ', cartelle cartfasc ';
            a_select := a_select || ', seg_classificazioni clas ';
            a_select := a_select || ', cartelle cartclas ';
            a_select :=
                  a_select || ' WHERE fasc.id_documento = docu.id_documento ';
            a_select :=
                  a_select
               || ' AND docu.stato_documento NOT IN (''CA'', ''RE'',''PB'') ';
            a_select := a_select || ' AND fasc.class_cod IS NOT NULL ';
            a_select := a_select || ' AND fasc.class_dal IS NOT NULL ';
            a_select := a_select || ' AND fasc.fascicolo_anno IS NOT NULL ';
            a_select := a_select || ' AND fasc.fascicolo_numero IS NOT NULL ';
            a_select :=
                  a_select
               || ' AND docu.id_documento = cartfasc.id_documento_profilo ';
            a_select :=
                    a_select || ' AND NVL (cartfasc.stato, ''BO'') <> ''CA'' ';
            a_select :=
                  a_select || ' AND INSTR (fasc.fascicolo_numero, ''.'') = 0 ';
            a_select := a_select || ' AND clas.class_cod = fasc.class_cod ';
            a_select := a_select || ' AND clas.class_dal = fasc.class_dal ';
            a_select :=
                  a_select
               || ' AND clas.id_documento = cartclas.id_documento_profilo ';
            a_select :=
                    a_select || ' AND NVL (cartclas.stato, ''BO'') <> ''CA'' ';
            a_select := a_select || ' AND clas.contenitore_documenti = ''Y'' ';
            a_select :=
                a_select || ' AND fasc.class_cod = ''' || a_class_cod || ''' ';
            a_select :=
                  a_select
               || ' AND fasc.class_dal = to_date('''
               || TO_CHAR (a_class_dal, 'dd/mm/yyyy')
               || ''',''dd/mm/yyyy'') ';
            a_select :=
               a_select || ' AND fasc.fascicolo_anno = ' || a_anno_fasc || ' ';
            a_select :=
                  a_select
               || ' AND clas.num_illimitata = ''N'' GROUP BY fasc.fascicolo_anno';

            OPEN utenticur FOR a_select;

            LOOP
               DECLARE
                  a_anno_fasc       seg_fascicoli.fascicolo_anno%TYPE;
                  a_num_fasc        seg_fascicoli.fascicolo_numero%TYPE;
                  a_max_anno_elab   seg_fascicoli.fascicolo_anno%TYPE    := 0;
                  a_conta           NUMBER (10);
               BEGIN
                  FETCH utenticur
                   INTO a_anno_fasc, a_num_fasc;

                  EXIT WHEN utenticur%NOTFOUND;

                  --VERIFICA ESISTENZA NUMERAZIONE
                  SELECT COUNT (*), MAX (nucl.id_documento)
                    INTO a_conta, a_iddoc
                    FROM seg_numerazioni_classifica nucl, documenti docu
                   WHERE docu.id_documento = nucl.id_documento
                     AND docu.stato_documento NOT IN ('CA', 'RE')
                     AND nucl.class_cod = a_class_cod
                     AND nucl.class_dal = a_class_dal
                     AND nucl.anno = a_anno_fasc
                     AND codice_amministrazione = a_codamm
                     AND codice_aoo = a_codaoo;

                  --dbms_output.put_line('-->'||A_CLASS_COD||'-->'||A_NUM_FASC||'-->'||A_CONTA);
                  IF a_conta = 0
                  THEN
                     a_err := NULL;
                     a_chiavi :=
                           'A_CLASS_COD = '
                        || a_class_cod
                        || ', A_CLASS_DAL = '
                        || a_class_dal
                        || ', A_ANNO_FASC = '
                        || a_anno_fasc
                        || ', ULTIMO_NUMERO_SUB = '
                        || a_num_fasc;

                     BEGIN
                        a_iddoc :=
                           gdm_profilo.crea_documento
                                                  ('SEGRETERIA',
                                                   'NUMERAZIONE_CLASSIFICHE',
                                                   NULL,
                                                   'GDM',
                                                   FALSE
                                                  );
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           raise_application_error
                                 (-20999,
                                     'Errore in GDM_PROFILO.CREA_DOCUMENTO: '
                                  || SQLERRM
                                 );
                     END;

                     INSERT INTO seg_numerazioni_classifica
                                 (id_documento, anno, class_cod,
                                  class_dal, codice_amministrazione,
                                  codice_aoo, ultimo_numero_sub
                                 )
                          VALUES (a_iddoc, a_anno_fasc, a_class_cod,
                                  a_class_dal, a_codamm,
                                  a_codaoo, a_num_fasc
                                 );

                     a_ret_char :=
                        f_full_text_horiz (a_iddoc,
                                           'SEG_NUMERAZIONI_CLASSIFICA'
                                          );
                  ELSE
                     UPDATE seg_numerazioni_classifica
                        SET ultimo_numero_sub = a_num_fasc
                      WHERE id_documento = a_iddoc;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     raise_application_error
                        (-20999,
                            'Errore in estrazione anni/numeri fascicolo per anno='
                         || a_anno_fasc
                         || ',numero='
                         || a_num_fasc
                         || ' . SELECT ESEGUITA='
                         || a_select
                         || '. Errore: '
                         || SQLERRM
                        );
               END;
            END LOOP;

            CLOSE utenticur;
         EXCEPTION
            WHEN OTHERS
            THEN
               a_err :=
                     'Errore in numerazione classifiche per class_cod = '
                  || a_class_cod
                  || ', class_dal = '
                  || a_class_dal
                  || '. Errore: '
                  || SQLERRM;
               raise_application_error (-20999, a_err);
         END;
      END LOOP;

      CLOSE estrazione_da_tabella;
   END;

   PROCEDURE duplica_singolo_fascicolo (
      seg_fascicoli_record   seg_fascicoli%ROWTYPE,
      a_anno_a               NUMBER
   )
   AS
      conta                 NUMBER (10);
      a_iddoc_padre         NUMBER (10);
      a_cartella_padre      NUMBER (10);
      a_cartella_new        NUMBER (10);
      a_num_illimitata      VARCHAR2 (1);
      a_nome                seg_fascicoli.nome%TYPE;
      a_data_apertura       seg_fascicoli.data_apertura%TYPE;
      a_data_creazione      seg_fascicoli.data_creazione%TYPE;
      a_data_stato          seg_fascicoli.data_stato%TYPE;
      a_iddoc               NUMBER (10);
      a_ret_char            VARCHAR2 (4000);
      seg_fascicoli_figli   seg_fascicoli%ROWTYPE;

      CURSOR estrazione_figli
      IS
         SELECT   seg_fascicoli.*
             FROM seg_fascicoli, documenti, cartelle
            WHERE fascicolo_anno = seg_fascicoli_record.fascicolo_anno
              AND class_cod = seg_fascicoli_record.class_cod
              AND class_dal = seg_fascicoli_record.class_dal
              AND data_chiusura IS NULL
              AND fascicolo_numero LIKE
                                 seg_fascicoli_record.fascicolo_numero || '.%'
              AND fascicolo_numero NOT LIKE
                               seg_fascicoli_record.fascicolo_numero || '.%.%'
              AND seg_fascicoli.id_documento = documenti.id_documento
              AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
              AND documenti.id_documento = cartelle.id_documento_profilo
              AND NVL (cartelle.stato, 'BO') != 'CA'
              AND seg_fascicoli.codice_amministrazione =
                                   seg_fascicoli_record.codice_amministrazione
              AND seg_fascicoli.codice_aoo = seg_fascicoli_record.codice_aoo
         ORDER BY class_cod, class_dal, fascicolo_numero;
   BEGIN
      --CONTROLLO SE ESISTE GIA' UN FASCICOLO X QUELL'ANNO E CON LE STESSE CARATTERISTICHE
      BEGIN
         SELECT COUNT (*), MAX (seg_fascicoli.id_documento)
           INTO conta, a_iddoc
           FROM seg_fascicoli, documenti, cartelle
          WHERE seg_fascicoli.class_cod = seg_fascicoli_record.class_cod
            AND seg_fascicoli.class_dal = seg_fascicoli_record.class_dal
            AND seg_fascicoli.fascicolo_anno = a_anno_a
            AND seg_fascicoli.fascicolo_numero =
                                         seg_fascicoli_record.fascicolo_numero
            AND seg_fascicoli.codice_amministrazione =
                                   seg_fascicoli_record.codice_amministrazione
            AND seg_fascicoli.codice_aoo = seg_fascicoli_record.codice_aoo
            AND seg_fascicoli.id_documento = documenti.id_documento
            AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
            AND documenti.id_documento = cartelle.id_documento_profilo
            AND NVL (cartelle.stato, 'BO') != 'CA';
      END;

      IF conta = 0
      THEN
         BEGIN
            IF INSTR (seg_fascicoli_record.fascicolo_numero, '.') = 0
            THEN
               BEGIN
                  SELECT seg_classificazioni.id_documento,
                         cartelle.id_cartella,
                         seg_classificazioni.num_illimitata
                    INTO a_iddoc_padre,
                         a_cartella_padre,
                         a_num_illimitata
                    FROM seg_classificazioni, cartelle, documenti
                   WHERE class_cod = seg_fascicoli_record.class_cod
                     AND class_dal = seg_fascicoli_record.class_dal
                     AND codice_amministrazione =
                                   seg_fascicoli_record.codice_amministrazione
                     AND codice_aoo = seg_fascicoli_record.codice_aoo
                     AND seg_classificazioni.id_documento =
                                                 cartelle.id_documento_profilo
                     AND NVL (cartelle.stato, 'BO') = 'BO'
                     AND documenti.id_documento =
                                              seg_classificazioni.id_documento
                     AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB');
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     raise_application_error
                        (-20999,
                            'Attenzione, non esiste la cartella padre CLASSIFICA con CLASS_COD='
                         || seg_fascicoli_record.class_cod
                         || ' e CLASS_DAL = '
                         || seg_fascicoli_record.class_dal
                        );
               END;
            ELSE
               BEGIN
                  SELECT seg_fascicoli.id_documento, cartelle.id_cartella
                    INTO a_iddoc_padre, a_cartella_padre
                    FROM seg_fascicoli, cartelle, documenti
                   WHERE class_cod = seg_fascicoli_record.class_cod
                     AND class_dal = seg_fascicoli_record.class_dal
                     AND codice_amministrazione =
                                   seg_fascicoli_record.codice_amministrazione
                     AND codice_aoo = seg_fascicoli_record.codice_aoo
                     AND fascicolo_anno = a_anno_a
                     AND fascicolo_numero =
                            SUBSTR
                               (seg_fascicoli_record.fascicolo_numero,
                                1,
                                  INSTR
                                       (seg_fascicoli_record.fascicolo_numero,
                                        '.',
                                        -1
                                       )
                                - 1
                               )
                     AND seg_fascicoli.id_documento =
                                                 cartelle.id_documento_profilo
                     AND NVL (cartelle.stato, 'BO') = 'BO'
                     AND documenti.id_documento = seg_fascicoli.id_documento
                     AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB');
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     raise_application_error
                        (-20999,
                            'Attenzione, non esiste la cartella padre FASCICOLO con CLASS_COD='
                         || seg_fascicoli_record.class_cod
                         || ', CLASS_DAL = '
                         || seg_fascicoli_record.class_dal
                         || ', FASCICOLO_ANNO = '
                         || a_anno_a
                         || ' e FASCICOLO_NUMERO = '
                         || SUBSTR
                               (seg_fascicoli_record.fascicolo_numero,
                                1,
                                  INSTR
                                       (seg_fascicoli_record.fascicolo_numero,
                                        '.',
                                        -1
                                       )
                                - 1
                               )
                        );
               END;
            END IF;

            IF NVL (a_num_illimitata, 'N') <> 'Y'
            THEN
               a_nome := a_anno_a || SUBSTR (seg_fascicoli_record.nome, 5);
               a_data_apertura := TRUNC (SYSDATE);
               --  ADD_MONTHS (seg_fascicoli_record.data_apertura, 12) - 1;
               a_data_creazione := TRUNC (SYSDATE);
               a_data_stato := TRUNC (SYSDATE);
               --CREO LA CARTELLA FASCICOLO
               a_cartella_new :=
                  gdm_cartelle.crea_cartella ('SEGRETERIA',
                                              'FASCICOLO',
                                              SUBSTR (a_nome, 1, 100),
                                              a_cartella_padre,
                                              'GDM'
                                             );

               --RECUPERO L'ID DOC PROFILO DALLA CARTELLA CREATA
               BEGIN
                  SELECT id_documento_profilo
                    INTO a_iddoc
                    FROM cartelle
                   WHERE id_cartella = a_cartella_new;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     raise_application_error
                        (-20999,
                            'Errore in recupero id_documento profilo da cartella appena creata con id = '
                         || a_cartella_new
                        );
               END;

               INSERT INTO seg_fascicoli
                           (id_documento, anno_archiviazione,
                            anno_fascicolo_padre, base_normativa,
                            calcola_nome, class_al, class_cod, class_dal,
                            codice_amministrazione, codice_aoo,
                            creata_cartella, cr_padre, data_apertura,
                            data_archiviazione, data_chiusura, data_creazione,
                            data_stato, desc_procedimento, fascicolo_anno,
                            fascicolo_numero, fascicolo_oggetto, nome, note,
                            numero_fascicolo_padre, procedimento,
                            responsabile, riservato, stato_fascicolo, sub,
                            topografia, ufficio_competenza, uff_assegnatario,
                            ultimo_numero_sub, utente_creazione,
                            utente_sessione, descrizione_classifica,
                            descrizione_classifica_visu, ufficio_creazione,
                            descrizione_ufficio_competenza, dati_ripudio)
                  SELECT a_iddoc, a_anno_a, 0, base_normativa, calcola_nome,
                         class_al, class_cod, class_dal,
                         codice_amministrazione, codice_aoo, creata_cartella,
                         cr_padre, a_data_apertura, a_data_creazione, NULL,
                         a_data_creazione, a_data_stato, desc_procedimento,
                         a_anno_a, fascicolo_numero, fascicolo_oggetto,
                         a_nome, note, 0, procedimento, responsabile,
                         riservato, stato_fascicolo, sub, topografia,
                         ufficio_competenza, uff_assegnatario,
                         ultimo_numero_sub, 'RPI', 'RPI',
                         descrizione_classifica, descrizione_classifica_visu,
                         ufficio_creazione, descrizione_ufficio_competenza,
                         dati_ripudio
                    FROM seg_fascicoli
                   WHERE id_documento = seg_fascicoli_record.id_documento;

               a_ret_char := f_full_text_horiz (a_iddoc, 'SEG_FASCICOLI');

               --RIGENERO L'ORDINAMENTO SULLA LINKS
               DECLARE
                  a_ret   NUMBER (10);
               BEGIN
                  a_ret :=
                     ordinamento_pkg.genera_chiave (a_cartella_new,
                                                    'C',
                                                    a_cartella_padre
                                                   );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     raise_application_error
                        (-20999,
                            'Errore in aggiornamento chiave di ordinamento per la tabella link. Errore: '
                         || SQLERRM
                        );
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                               (-20999,
                                   'Errore in inserimento fascicolo numero= '
                                || seg_fascicoli_record.fascicolo_numero
                                || '. Errore ='
                                || SQLERRM
                               );
         END;
      ELSE
         IF conta > 1
         THEN
            a_iddoc := 0;
         END IF;
      END IF;

      COMMIT;

      OPEN estrazione_figli;

      LOOP
         BEGIN
            FETCH estrazione_figli
             INTO seg_fascicoli_figli;

            EXIT WHEN estrazione_figli%NOTFOUND;
            duplica_singolo_fascicolo (seg_fascicoli_figli, a_anno_a);
         END;
      END LOOP;

      CLOSE estrazione_figli;

      sistema_ultimo_numero_sub (a_iddoc,
                                 seg_fascicoli_record.class_cod,
                                 seg_fascicoli_record.class_dal,
                                 a_anno_a,
                                 seg_fascicoli_record.fascicolo_numero
                                );
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (-20999,
                                     'Errore in duplica del fascicolo '
                                  || seg_fascicoli_record.class_cod
                                  || ' del '
                                  || TO_CHAR (seg_fascicoli_record.class_dal,
                                              'dd/mm/yyyy'
                                             )
                                  || ' '
                                  || seg_fascicoli_record.fascicolo_anno
                                  || '/'
                                  || seg_fascicoli_record.fascicolo_numero,
                                  TRUE
                                 );
   END;

   PROCEDURE duplica_anno_fascicolo (
      a_class_cod   VARCHAR2,
      a_class_dal   VARCHAR2,
      a_anno_da     NUMBER,
      a_anno_a      NUMBER,
      a_numero_da   VARCHAR2,
      a_numero_a    VARCHAR2,
      a_codamm      VARCHAR2,
      a_codaoo      VARCHAR2
   )
   AS
      CURSOR estrazione_da_tabella
      IS
         SELECT   seg_fascicoli.*
             FROM (select * from seg_fascicoli where instr(fascicolo_numero,'.') = 0) seg_fascicoli, documenti, cartelle
            WHERE fascicolo_anno = a_anno_da
              AND seg_fascicoli.class_cod LIKE NVL (a_class_cod, '%')
              AND seg_fascicoli.class_dal =
                     DECODE (NVL (a_class_cod, '%'),
                             '%', seg_fascicoli.class_dal,
                             DECODE (a_class_dal,
                                     '', seg_fascicoli.class_dal,
                                     TO_DATE (a_class_dal, 'DD/MM/YYYY')
                                    )
                            )
              AND TO_NUMBER (fascicolo_numero)
                     BETWEEN NVL (a_numero_da, TO_NUMBER (fascicolo_numero))
                         AND NVL (a_numero_a, TO_NUMBER (fascicolo_numero))
              AND data_chiusura IS NULL
              AND fascicolo_numero NOT LIKE '%.%'
              AND fascicolo_numero IS NOT NULL
              AND seg_fascicoli.id_documento = documenti.id_documento
              AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
              AND documenti.id_documento = cartelle.id_documento_profilo
              AND NVL (cartelle.stato, 'BO') != 'CA'
              AND seg_fascicoli.codice_amministrazione = a_codamm
              AND seg_fascicoli.codice_aoo = a_codaoo
         ORDER BY class_cod, class_dal, TO_NUMBER (fascicolo_numero);

      seg_fascicoli_record   seg_fascicoli%ROWTYPE;
      a_iddoc_padre          NUMBER (10);
      a_cartella_padre       NUMBER (10);
      a_cartella_new         NUMBER (10);
      a_iddoc                NUMBER (10);
      a_num_illimitata       VARCHAR2 (1);
      a_nome                 seg_fascicoli.nome%TYPE;
      a_data_apertura        seg_fascicoli.data_apertura%TYPE;
      a_data_creazione       seg_fascicoli.data_creazione%TYPE;
      a_data_stato           seg_fascicoli.data_stato%TYPE;
      a_ret_char             VARCHAR2 (4000);
      conta                  NUMBER (10);
   BEGIN
      OPEN estrazione_da_tabella;

      LOOP
         BEGIN
            FETCH estrazione_da_tabella
             INTO seg_fascicoli_record;

            EXIT WHEN estrazione_da_tabella%NOTFOUND;
            duplica_singolo_fascicolo (seg_fascicoli_record, a_anno_a);
         END;
      END LOOP;

      CLOSE estrazione_da_tabella;

      -- TODO NUMERAZIONE CLASS.....PRENDILA DA CLASSIFICA
      execute_num_classfasc (a_anno_a, a_codamm, a_codaoo);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         raise_application_error
                     (-20999,
                         'Errore in DUPLICA_ANNO_FASCICOLO per CLASSIFICA = '
                      || NVL (a_class_cod, 'null')
                      || ' del '
                      || TO_DATE (a_class_dal, 'DDMMYYYY')
                      || ' ANNO_DA= '
                      || a_anno_da
                      || ' ANNO_A= '
                      || a_anno_a
                      || ' NUMERO_DA= '
                      || a_numero_da
                      || ' NUMERO_A= '
                      || a_numero_a
                      || '. Errore = '
                      || SQLERRM
                     );
   END;

   PROCEDURE duplica_anno_fascicolo (
      a_anno_da     NUMBER,
      a_anno_a      NUMBER,
      a_numero_da   VARCHAR2,
      a_numero_a    VARCHAR2,
      a_codamm      VARCHAR2,
      a_codaoo      VARCHAR2
   )
   AS
      CURSOR estrazione_da_tabella
      IS
         SELECT   *
             FROM (select * from seg_fascicoli where instr(fascicolo_numero,'.') = 0) seg_fascicoli
            WHERE fascicolo_anno = a_anno_da
              AND data_chiusura IS NULL
              AND fascicolo_numero BETWEEN NVL (a_numero_da, fascicolo_numero)
                                       AND NVL (a_numero_a, fascicolo_numero)
         ORDER BY class_cod, class_dal, fascicolo_numero;

      seg_fascicoli_record   seg_fascicoli%ROWTYPE;
      conta                  NUMBER (10);
      a_iddoc_padre          NUMBER (10);
      a_cartella_padre       NUMBER (10);
      a_cartella_new         NUMBER (10);
      a_iddoc                NUMBER (10);
      a_num_illimitata       VARCHAR2 (1);
      a_nome                 seg_fascicoli.nome%TYPE;
      a_data_apertura        seg_fascicoli.data_apertura%TYPE;
      a_data_creazione       seg_fascicoli.data_creazione%TYPE;
      a_data_stato           seg_fascicoli.data_stato%TYPE;
      a_ret_char             VARCHAR2 (4000);
   BEGIN
      OPEN estrazione_da_tabella;

      LOOP
         BEGIN
            FETCH estrazione_da_tabella
             INTO seg_fascicoli_record;

            EXIT WHEN estrazione_da_tabella%NOTFOUND;

            --CONTROLLO SE ESISTE GIA' UN FASCICOLO X QUELL'ANNO E CON LE STESSE CARATTERISTICHE
            BEGIN
               SELECT COUNT (*)
                 INTO conta
                 FROM seg_fascicoli
                WHERE seg_fascicoli.class_cod = seg_fascicoli_record.class_cod
                  AND seg_fascicoli.class_dal = seg_fascicoli_record.class_dal
                  AND seg_fascicoli.fascicolo_anno = a_anno_a
                  AND seg_fascicoli.fascicolo_numero =
                                         seg_fascicoli_record.fascicolo_numero
                  AND seg_fascicoli.codice_amministrazione = a_codamm
                  AND seg_fascicoli.codice_aoo = a_codaoo;
            END;

            IF conta = 0
            THEN
               BEGIN
                  --TODO (VEDI ALLA FINE C'è CODSICE ESEMPIO)
                  BEGIN
                     SELECT seg_classificazioni.id_documento,
                            cartelle.id_cartella,
                            seg_classificazioni.num_illimitata
                       INTO a_iddoc_padre,
                            a_cartella_padre,
                            a_num_illimitata
                       FROM seg_classificazioni, cartelle
                      WHERE class_cod = seg_fascicoli_record.class_cod
                        AND class_dal = seg_fascicoli_record.class_dal
                        AND codice_amministrazione = a_codamm
                        AND codice_aoo = a_codaoo
                        AND seg_classificazioni.id_documento =
                                                 cartelle.id_documento_profilo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        raise_application_error
                           (-20999,
                               'Attenzione, non esiste la cartella padre CLASSIFICA con CLASS_COD='
                            || seg_fascicoli_record.class_cod
                            || ' e CLASS_DAL = '
                            || seg_fascicoli_record.class_dal
                           );
                  END;

                  IF a_num_illimitata <> 'Y'
                  THEN
                     a_nome :=
                            a_anno_a || SUBSTR (seg_fascicoli_record.nome, 5);
                     a_data_apertura := TRUNC (SYSDATE);
                     --  ADD_MONTHS (seg_fascicoli_record.data_apertura, 12) - 1;
                     a_data_creazione := TRUNC (SYSDATE);
                     a_data_stato := TRUNC (SYSDATE);
                     --CREO LA CARTELLA FASCICOLO
                     a_cartella_new :=
                        gdm_cartelle.crea_cartella ('SEGRETERIA',
                                                    'FASCICOLO',
                                                    SUBSTR (a_nome, 1, 100),
                                                    a_cartella_padre,
                                                    'GDM'
                                                   );

                     --RECUPERO L'ID DOC PROFILO DALLA CARTELLA CREATA
                     BEGIN
                        SELECT id_documento_profilo
                          INTO a_iddoc
                          FROM cartelle
                         WHERE id_cartella = a_cartella_new;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           raise_application_error
                              (-20999,
                                  'Errore in recupero id_documento profilo da cartella appena creata con id = '
                               || a_cartella_new
                              );
                     END;

                     INSERT INTO seg_fascicoli
                                 (id_documento, anno_archiviazione,
                                  anno_fascicolo_padre, base_normativa,
                                  calcola_nome, class_al, class_cod,
                                  class_dal, codice_amministrazione,
                                  codice_aoo, creata_cartella, cr_padre,
                                  data_apertura, data_archiviazione,
                                  data_chiusura, data_creazione, data_stato,
                                  desc_procedimento, fascicolo_anno,
                                  fascicolo_numero, fascicolo_oggetto, nome,
                                  note, numero_fascicolo_padre, procedimento,
                                  responsabile, riservato, stato_fascicolo,
                                  sub, topografia, ufficio_competenza,
                                  uff_assegnatario, ultimo_numero_sub,
                                  utente_creazione, utente_sessione,
                                  descrizione_classifica,
                                  descrizione_classifica_visu,
                                  ufficio_creazione,
                                  descrizione_ufficio_competenza,
                                  dati_ripudio)
                        SELECT a_iddoc, a_anno_a, 0, base_normativa,
                               calcola_nome, class_al, class_cod, class_dal,
                               codice_amministrazione, codice_aoo,
                               creata_cartella, cr_padre, a_data_apertura,
                               a_data_creazione, NULL, a_data_creazione,
                               a_data_stato, desc_procedimento, a_anno_a,
                               fascicolo_numero, fascicolo_oggetto, a_nome,
                               note, 0, procedimento, responsabile, riservato,
                               stato_fascicolo, sub, topografia,
                               ufficio_competenza, uff_assegnatario,
                               ultimo_numero_sub, 'GDM', 'GDM',
                               descrizione_classifica,
                               descrizione_classifica_visu, ufficio_creazione,
                               descrizione_ufficio_competenza, dati_ripudio
                          FROM seg_fascicoli
                         WHERE id_documento =
                                             seg_fascicoli_record.id_documento;

                     a_ret_char :=
                                  f_full_text_horiz (a_iddoc, 'SEG_FASCICOLI');

                     --RIGENERO L'ORDINAMENTO SULLA LINKS
                     DECLARE
                        a_ret   NUMBER (10);
                     BEGIN
                        a_ret :=
                           ordinamento_pkg.genera_chiave (a_cartella_new,
                                                          'C',
                                                          a_cartella_padre
                                                         );
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           raise_application_error
                              (-20999,
                                  'Errore in aggiornamento chiave di ordinamento per la tabella link. Errore: '
                               || SQLERRM
                              );
                     END;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     raise_application_error
                               (-20999,
                                   'Errore in inserimento fascicolo numero= '
                                || seg_fascicoli_record.fascicolo_numero
                                || '. Errore ='
                                || SQLERRM
                               );
               END;
            END IF;

            COMMIT;
         END;
      END LOOP;

      CLOSE estrazione_da_tabella;

      -- TODO NUMERAZIONE CLASS.....PRENDILA DA CLASSIFICA
      execute_num_classfasc (a_anno_a, a_codamm, a_codaoo);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         raise_application_error
                         (-20999,
                             'Errore in DUPLICA_ANNO_FASCICOLO per ANNO_DA= '
                          || a_anno_da
                          || ' ANNO_A= '
                          || a_anno_a
                          || ' NUMERO_DA= '
                          || a_numero_da
                          || ' NUMERO_A= '
                          || a_numero_a
                          || '. Errore = '
                          || SQLERRM
                         );
   END;
END;
/
