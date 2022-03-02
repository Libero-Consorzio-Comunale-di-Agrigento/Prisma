--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_JOB runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_utilities_job
AS
/******************************************************************************
   NAME:       AG_UTILITIES_JOB
   PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
   REVISIONS:
   Ver        Date        Author          Description
   ---------  ----------  --------------- ------------------------------------
   00         22/02/2013    SS           Created this package.
******************************************************************************/--s_revisione                   afc.t_revision := 'V1.02';

   /*****************************************************************************
    NOME:        job_del_memo_stream.
    DESCRIZIONE: Elimina i messaggi duplicati dello scarico della pec
                parametri:
   ********************************************************************************/
   PROCEDURE job_del_memo_stream (p_id_documento NUMBER DEFAULT NULL);

   /*****************************************************************************
    NOME:        JOB_GET_MAIL.
    DESCRIZIONE: CHIAMA LA SERVLET DI SCARICO PEC
   ********************************************************************************/
   PROCEDURE storeallmessages (
      p_server      VARCHAR2,
      p_fileprop    VARCHAR2,
      p_tagmail     VARCHAR2,
      p_sender      VARCHAR2,
      p_recipient   VARCHAR2
   );

   PROCEDURE attiva_storeallmessages;

   PROCEDURE ripristina_documento_interop (dep_id_documento NUMBER);

   PROCEDURE ripristina_cancellati;

    PROCEDURE calcola_spazio_pulisci_prin_ca (p_versione  VARCHAR2,p_giorni_da_non_cancellare NUMBER);
    PROCEDURE calcola_spazio_pulisci_memo_ca (p_versione  VARCHAR2,p_giorni_da_non_cancellare NUMBER);
    PROCEDURE calcola_spazio_pulisci_stream (p_versione  VARCHAR2,p_giorni_da_non_cancellare NUMBER);
    PROCEDURE calcola_spzio_pulisci_scartati (p_versione  VARCHAR2,p_giorni_da_non_cancellare NUMBER);
    PROCEDURE calcola_spazio_prot_pec (p_versione  VARCHAR2,p_giorni_da_non_cancellare NUMBER);
    PROCEDURE calcola_spzio_pulisci_anomalie (p_versione  VARCHAR2,p_giorni_da_non_cancellare NUMBER);

    PROCEDURE pulisci_memo_ca (p_giorni_da_non_cancellare NUMBER, p_solofile NUMBER DEFAULT 1);

    PROCEDURE attiva_pulisci_memo_ca(p_giorni_da_non_cancellare NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY ag_utilities_job
AS
   /******************************************************************************
      NAME:       AG_UTILITIES_JOB
      PURPOSE:    Package di utilities per il progetto di AFFARI_GENERALI.
      REVISIONS:
      Ver        Date        Author          Description
      ---------  ----------  --------------- ------------------------------------
      00         22/02/2013    SS           Created this package.
   ******************************************************************************/
   --s_revisione                   afc.t_revision := 'V1.02';
   PROCEDURE pulisci_tabella_tmp
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE FROM UTILITIES_JOB_PULISCI_TMP;

      INSERT INTO UTILITIES_JOB_PULISCI_TMP (DIMENSIONE)
           VALUES (0);

      COMMIT;
   END;

   PROCEDURE riempi_tabella_tmp (p_id_documento     NUMBER,
                                 p_like_filename    VARCHAR2 DEFAULT NULL)
   IS
      A_SPAZIO   NUMBER (20);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      --inserisco qui la dim
      SELECT NVL (
                SUM (
                   DECODE (path_file,
                           NULL, NVL (DBMS_LOB.getlength (testoocr), 0),
                           NVL (DBMS_LOB.getlength ("FILE"), 0))),
                0)
        INTO A_SPAZIO
        FROM oggetti_file
       WHERE     id_documento = p_id_documento
             AND (   p_like_filename IS NULL
                  OR LOWER (filename) LIKE p_like_filename);

      UPDATE UTILITIES_JOB_PULISCI_TMP
         SET DIMENSIONE = DIMENSIONE + A_SPAZIO;

      COMMIT;
   END;

   PROCEDURE GETPATH_FILE_FS (P_IDOGGETTO_FILE          NUMBER,
                              P_DIRECTORY        IN OUT VARCHAR2,
                              P_PATH_DIR_FS      IN OUT VARCHAR2,
                              P_PATH_FILE        IN OUT VARCHAR2)
   AS
   BEGIN
      SELECT F_GETDIRECTORY_AREA_NAME (DOCUMENTI.ID_DOCUMENTO),
                TIPI_DOCUMENTO.ACRONIMO_MODELLO
             || '/'
             || TO_CHAR (TRUNC (DOCUMENTI.ID_DOCUMENTO / 1000))
             || '/'
             || DOCUMENTI.ID_DOCUMENTO
             || '/'
             || P_IDOGGETTO_FILE
        INTO P_DIRECTORY, P_PATH_FILE
        FROM TIPI_DOCUMENTO,
             AREE,
             DOCUMENTI,
             OGGETTI_FILE
       WHERE     DOCUMENTI.AREA = AREE.AREA
             AND DOCUMENTI.ID_TIPODOC = TIPI_DOCUMENTO.ID_TIPODOC
             AND OGGETTI_FILE.ID_OGGETTO_FILE = P_IDOGGETTO_FILE
             AND OGGETTI_FILE.ID_DOCUMENTO = DOCUMENTI.ID_DOCUMENTO;

      SELECT directory_path
        INTO P_PATH_DIR_FS
        FROM DBA_DIRECTORIES
       WHERE UPPER (directory_name) = P_DIRECTORY;
   END GETPATH_FILE_FS;

   FUNCTION IS_FS_FILE (P_IDOGGETTO_FILE NUMBER)
      RETURN NUMBER
   IS
      A_RET   NUMBER (1) := 0;
   BEGIN
      SELECT DECODE (PATH_FILE, NULL, 0, DECODE (PATH_FILE, '', 0, 1))
        INTO A_RET
        FROM OGGETTI_FILE
       WHERE ID_OGGETTO_FILE = P_IDOGGETTO_FILE;

      RETURN A_RET;
   END IS_FS_FILE;

   PROCEDURE DELETEOGGETTOFILE (P_IDOGGETTO_FILE NUMBER)
   AS
      a_dir           VARCHAR2 (1000);
      a_path_dir_fs   VARCHAR2 (1000);
      a_path_file     VARCHAR2 (1000);
      a_isFileFs      NUMBER (1) := 0;
   BEGIN
      IF IS_FS_FILE (P_IDOGGETTO_FILE) = 1
      THEN
         GETPATH_FILE_FS (P_IDOGGETTO_FILE,
                          a_dir,
                          a_path_dir_fs,
                          a_path_file);
         a_isFileFs := 1;
      END IF;

      DELETE FROM OGGETTI_FILE
            WHERE ID_OGGETTO_FILE = P_IDOGGETTO_FILE;

      IF a_isFileFs = 1
      THEN
         DBMS_BACKUP_RESTORE.DELETEFILE (
            a_path_dir_fs || '/' || REPLACE (a_path_file, '$', '\$'));
      END IF;
   END DELETEOGGETTOFILE;

   PROCEDURE elimina_oggetti_file (p_id_documento     NUMBER,
                                   p_like_filename    VARCHAR2 DEFAULT NULL,
                                   p_solospazio       NUMBER DEFAULT 0)
   AS
   BEGIN
      IF p_solospazio = 0
      THEN
         FOR ogfi
            IN (SELECT id_oggetto_file
                  FROM oggetti_file
                 WHERE     id_documento = p_id_documento
                       AND (   p_like_filename IS NULL
                            OR LOWER (filename) LIKE p_like_filename))
         LOOP
            DELETEOGGETTOFILE (ogfi.id_oggetto_file);
         END LOOP;
      ELSE
         riempi_tabella_tmp (p_id_documento, p_like_filename);
      END IF;
   END elimina_oggetti_file;


   PROCEDURE elimina_documento (p_id_documento    NUMBER,
                                p_versione        VARCHAR2,
                                fase              VARCHAR2,
                                p_solospazio      NUMBER DEFAULT 0,
                                p_solofile        NUMBER DEFAULT 0)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      conta              NUMBER;
      delete_smis_stmt   VARCHAR2 (32000);
   BEGIN
      IF p_versione = 'V2.2' AND p_solospazio = 0 AND p_solofile = 0
      THEN
         BEGIN
            delete_smis_stmt :=
                  'delete seg_smistamenti where idrif = (select idrif from seg_memo_protocollo where id_documento = '
               || p_id_documento
               || ')';

            EXECUTE IMMEDIATE delete_smis_stmt;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               DBMS_OUTPUT.put_line (
                     'ERRORE - '
                  || fase
                  || ' - FALLITA ELIMINAZIONE SMISTAMENTI DEL MEMO '
                  || p_id_documento);
         END;
      END IF;

      IF p_solospazio = 0 AND p_solofile = 0
      THEN
         UPDATE documenti
            SET id_documento_padre = NULL
          WHERE id_documento_padre = p_id_documento;
      END IF;

      elimina_oggetti_file (p_id_documento, NULL, p_solospazio);

      IF p_solospazio = 0 AND p_solofile = 0
      THEN
         conta := f_elimina_documento (p_id_documento, 0);
         DBMS_OUTPUT.put_line (
               'OK - '
            || fase
            || ' - ELIMINATO DOCUMENTO '
            || p_id_documento
            || ' ritorno '
            || conta);
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         DBMS_OUTPUT.put_line (
               'ERRORE - '
            || fase
            || ' - FALLITA ELIMINAZIONE DOCUMENTO '
            || p_id_documento);
   END elimina_documento;

   PROCEDURE elimina_protocollo_fisico (p_id_doc        NUMBER,
                                        p_tipo          VARCHAR2,
                                        p_solospazio    NUMBER DEFAULT 0)
   AS
      a_idrif     spr_protocolli.idrif%TYPE;
      a_modello   VARCHAR2 (100);
      a_ret       NUMBER (1);
   BEGIN
      IF p_solospazio = 0
      THEN
         BEGIN
            --ANNULLO l'id_doc_padre
            UPDATE documenti
               SET id_documento_padre = NULL
             WHERE id_documento IN (SELECT id_documento
                                      FROM riferimenti
                                     WHERE     id_documento_rif = p_id_doc
                                           AND tipo_relazione = 'PROT_PREC');
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               raise_application_error (
                  -20999,
                  'Errore in annullamento id_doc_padre. Errore: ' || SQLERRM);
         END;
      END IF;

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
      FOR i IN (SELECT 1, 'Smistamento' tipo, id_documento
                  FROM seg_smistamenti
                 WHERE idrif = a_idrif
                UNION ALL
                SELECT 2, 'Soggetto' tipo, id_documento
                  FROM seg_soggetti_protocollo
                 WHERE idrif = a_idrif
                UNION ALL
                SELECT 3, 'Allegato' tipo, id_documento
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
               elimina_oggetti_file (a_doc, NULL, p_solospazio);
            --DELETE oggetti_file
            -- WHERE id_documento = a_doc;
            END IF;

            IF p_solospazio = 0
            THEN
               a_ret := f_elimina_documento (a_doc, 0);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               raise_application_error (
                  -20999,
                     'Errore in Cancellazione '
                  || i.tipo
                  || ' (con id='
                  || a_doc
                  || ') collegato al protocollo. Errore: '
                  || SQLERRM);
         END;
      END LOOP;

      BEGIN
         elimina_oggetti_file (p_id_doc, NULL, p_solospazio);

         --DELETE oggetti_file
         -- WHERE id_documento = p_id_doc;

         IF p_solospazio = 0
         THEN
            a_ret := f_elimina_documento (p_id_doc, 0);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            raise_application_error (
               -20999,
               'Errore in eliminazione protocollo. Errore: ' || SQLERRM);
      END;
   END elimina_protocollo_fisico;

   PROCEDURE elimina_protocollo_interop (p_id_documento    NUMBER,
                                         p_versione        VARCHAR2,
                                         fase              VARCHAR2,
                                         p_solospazio      NUMBER DEFAULT 0)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF p_solospazio = 0
      THEN
         DELETE riferimenti
          WHERE     tipo_relazione IN ('FAX', 'MAIL')
                AND id_documento = p_id_documento;

         UPDATE documenti
            SET id_documento_padre = NULL
          WHERE id_documento_padre = p_id_documento;
      END IF;

      elimina_protocollo_fisico (p_id_documento, 'INTEROP', p_solospazio);
      COMMIT;
      DBMS_OUTPUT.put_line (
         'OK - ' || fase || ' - ELIMINATO PROTOCOLLO ' || p_id_documento);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         DBMS_OUTPUT.put_line (
               'ERRORE - '
            || fase
            || ' - FALLITA ELIMINAZIONE PROTOCOLLO '
            || p_id_documento);
   END elimina_protocollo_interop;

   PROCEDURE elimina_eml (p_id_documento    NUMBER,
                          fase              VARCHAR2,
                          p_solospazio      NUMBER DEFAULT 0)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      elimina_oggetti_file (p_id_documento, '%.eml', p_solospazio);
      --      DELETE oggetti_file
      --       WHERE id_documento = p_id_documento AND LOWER (filename) LIKE '%.eml';

      COMMIT;

      IF p_solospazio = 0
      THEN
         DBMS_OUTPUT.put_line (
            'OK - ' || fase || ' - ELIMINATO EML DI ' || p_id_documento);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         DBMS_OUTPUT.put_line (
               'ERRORE - '
            || fase
            || ' - FALLITA ELIMINAZIONE .EML DI '
            || p_id_documento);
   END elimina_eml;


   /*eliminare i documenti generati dai messaggi di interoperabilità
   messi in stato CA dall¿utente e i MEMO e lo STREAM associati
   (tranne i messaggi che hanno generato notifica eccezione).
   Vanno quindi eliminati tutti i record presenti
   su SPR_PROTOCOLLLI_INTERO+OGGETTI_FILE
   (e altre tabelle collegate tramite IDRIF: SEG_ALLEGATI_PROTOCOLLO+OGGETTI_FILE,
   SEG_SOGGETTI_PROTOCOLLO, SEG_SMISTAMENTI o ID_DOCUMENTO: LINKS)
   con campo NUMERO null,
   STATO_PR=DP e stato CA sulla documenti
   e il MEMO associato con tipo_Relazione=¿MAIL¿
   e l¿eventuale MEMO associato
   (quest¿ultimo è presente nel caso di ANOMALIA MESSAGGIO)
   con tipo_relazione=¿PRINCIPALE¿
   e lo STREAM associato al MEMO con tipo_relazione=¿STREAM¿.
   */
   PROCEDURE pulisci_prin_ca (p_id_documento                NUMBER,
                              p_versione                    VARCHAR2,
                              p_giorni_da_non_cancellare    NUMBER,
                              p_solospazio                  NUMBER DEFAULT 0)
   IS
      TYPE r_cursor IS REF CURSOR;

      cur_iddoc    r_cursor;
      id_doc_del   spr_protocolli_intero.id_documento%TYPE;
      id_rif_del   spr_protocolli_intero.idrif%TYPE;
      stmt         VARCHAR2 (32000);
   BEGIN
      stmt :=
            'select  spi.id_documento,idrif
                    from spr_protocolli_intero spi,documenti doc
                    where
                     spi.id_documento=DOC.ID_DOCUMENTO
                     and spi.id_documento IN
                        (select id_documento from stati_documento
                        where id_documento =spi.id_documento
                        group by id_documento
                        having trunc(min(data_aggiornamento)) < sysdate - '
         || p_giorni_da_non_cancellare
         || ' )
                    and stato_documento=''CA''
                    and numero is null
                    and stato_pr=''DP''  ';

      IF p_id_documento IS NOT NULL
      THEN
         stmt := stmt || ' and spi.id_documento = ' || p_id_documento;
      END IF;

      OPEN cur_iddoc FOR stmt;

      LOOP
         FETCH cur_iddoc INTO id_doc_del, id_rif_del;

         EXIT WHEN cur_iddoc%NOTFOUND;
         DBMS_OUTPUT.put_line (
               '1 - ''DA PROTOCOLLARE'' CANCELLATO '
            || id_doc_del
            || '-'
            || id_rif_del);

         DECLARE
            esistono_altri_prot   NUMBER := 0;
            esistono_eccezioni    NUMBER := 0;
            id_memo               NUMBER := 0;
         BEGIN
            BEGIN
               SELECT id_documento_rif
                 INTO id_memo
                 FROM riferimenti
                WHERE     id_documento = id_doc_del
                      AND tipo_relazione IN ('MAIL', 'FAX');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            SELECT COUNT (*)
              INTO esistono_altri_prot
              FROM riferimenti r1, documenti
             WHERE     r1.id_documento_rif = id_memo
                   AND r1.tipo_relazione IN ('MAIL', 'FAX')
                   AND r1.id_documento != id_doc_del
                   AND documenti.id_documento = r1.id_documento
                   AND documenti.stato_documento != 'CA';

            SELECT COUNT (*)
              INTO esistono_eccezioni
              FROM riferimenti r1, documenti
             WHERE     r1.id_documento = id_memo
                   AND r1.tipo_relazione IN ('PROT_ECC');

            IF esistono_altri_prot = 0 AND esistono_eccezioni = 0
            THEN
               FOR rec
                  IN                                                 -- stream
                     (SELECT id_documento_rif
                        FROM riferimenti
                       WHERE     id_documento IN (SELECT id_documento
                                                    FROM riferimenti
                                                   WHERE     tipo_relazione =
                                                                'PRINCIPALE'
                                                         AND id_documento_rif IN (SELECT id_documento_rif
                                                                                    --ho gli id della seg_memo
                                                                                    FROM riferimenti
                                                                                   WHERE     tipo_relazione IN ('FAX',
                                                                                                                'MAIL')
                                                                                         AND id_documento =
                                                                                                id_doc_del)
                                                  UNION
                                                  SELECT id_documento_rif
                                                    --ho gli id della seg_memo
                                                    FROM riferimenti
                                                   WHERE     tipo_relazione IN ('FAX',
                                                                                'MAIL')
                                                         AND id_documento =
                                                                id_doc_del)
                             AND tipo_relazione = 'STREAM')
               LOOP
                  elimina_documento (
                     rec.id_documento_rif,
                     p_versione,
                     '1 - STREAM DI ''DA PROTOCOLLARE'' CANCELLATI',
                     p_solospazio);
               END LOOP;

               FOR rec
                  IN                                             -- principale
                     (SELECT id_documento
                        FROM riferimenti
                       WHERE     tipo_relazione = 'PRINCIPALE'
                             AND id_documento_rif IN (SELECT id_documento_rif
                                                        --ho gli id della seg_memo
                                                        FROM riferimenti
                                                       WHERE     tipo_relazione IN ('FAX',
                                                                                    'MAIL')
                                                             AND id_documento =
                                                                    id_doc_del))
               LOOP
                  elimina_documento (
                     rec.id_documento,
                     p_versione,
                     '1 - PRINCIPALE DI ''DA PROTOCOLLARE'' CANCELLATI',
                     p_solospazio);
               END LOOP;

               FOR rec
                  IN                                                   -- mail
                     (SELECT id_documento_rif       --ho gli id della seg_memo
                        FROM riferimenti
                       WHERE     tipo_relazione IN ('FAX', 'MAIL')
                             AND id_documento = id_doc_del)
               LOOP
                  elimina_documento (
                     rec.id_documento_rif,
                     p_versione,
                     '1 - MEMO DI ''DA PROTOCOLLARE'' CANCELLATI',
                     p_solospazio);
               END LOOP;
            END IF;

            --1 sp1 mi cancella anche seg_allegati_protocollo, seg_soggetti_protocollo e seg_smistamenti
            elimina_protocollo_interop (id_doc_del,
                                        p_versione,
                                        '1 - ''DA PROTOCOLLARE'' CANCELLATI',
                                        p_solospazio);
         END;
      END LOOP;
   END pulisci_prin_ca;

   PROCEDURE calcola_spazio_pulisci_prin_ca (
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER)
   AS
   BEGIN
      pulisci_tabella_tmp;
      pulisci_prin_ca (NULL,
                       p_versione,
                       p_giorni_da_non_cancellare,
                       1);
   END;

   /*Eliminare tutti i MEMO messi in stato CA dall¿utente
   e il MEMO e lo STREAM associati.
   Vanno quindi eliminati tutti i record presenti su
   SEG_MEMO_PROTOCOLLO in stato CA per cui non esiste
   un riferimento con tipo_relazione=¿MAIL¿
   con id doc riferimento uguale a quello del MEMO
   e lo STREAM ad esso associato e l¿eventuale MEMO.*/
   PROCEDURE pulisci_memo_ca (p_id_documento                NUMBER,
                              p_versione                    VARCHAR2,
                              p_giorni_da_non_cancellare    NUMBER,
                              p_solospazio                  NUMBER DEFAULT 0,
                              p_solofile                    NUMBER DEFAULT 0)
   IS
   BEGIN
      FOR rec
         IN (SELECT id_documento
               FROM riferimenti
              WHERE     id_documento_rif IN (SELECT smp.id_documento
                                               FROM seg_memo_protocollo smp,
                                                    documenti doc
                                              WHERE     smp.id_documento =
                                                           doc.id_documento
                                                    AND smp.id_documento IN (  SELECT id_documento
                                                                                 FROM stati_documento
                                                                                WHERE id_documento =
                                                                                         smp.id_documento
                                                                             GROUP BY id_documento
                                                                               HAVING TRUNC (
                                                                                         MIN (
                                                                                            data_aggiornamento)) <
                                                                                           SYSDATE
                                                                                         - p_giorni_da_non_cancellare)
                                                    AND stato_documento =
                                                           'CA'
                                                    AND NOT EXISTS
                                                           (SELECT 1
                                                              FROM riferimenti
                                                             WHERE     tipo_relazione IN ('FAX',
                                                                                          'MAIL')
                                                                   AND id_documento_rif =
                                                                          smp.id_documento))
                    AND tipo_relazione IN ('PRINCIPALE', 'STREAM')
                    AND id_documento_rif =
                           NVL (p_id_documento, id_documento_rif))
      LOOP
         -- DELETE FROM STREAM_MEMO_PROTOCOLLO E PRINCIPALE
         elimina_documento (rec.id_documento,
                            p_versione,
                            '2 - PRINCIPALE DI MEMO CANCELLATI',
                            p_solospazio,
                            p_solofile);
      END LOOP;

      FOR rec
         IN (SELECT id_documento_rif
               FROM riferimenti
              WHERE     id_documento IN (SELECT smp.id_documento
                                           FROM seg_memo_protocollo smp,
                                                documenti doc
                                          WHERE     smp.id_documento =
                                                       doc.id_documento
                                                AND smp.id_documento IN (  SELECT id_documento
                                                                             FROM stati_documento
                                                                            WHERE id_documento =
                                                                                     smp.id_documento
                                                                         GROUP BY id_documento
                                                                           HAVING TRUNC (
                                                                                     MIN (
                                                                                        data_aggiornamento)) <
                                                                                       SYSDATE
                                                                                     - p_giorni_da_non_cancellare)
                                                AND stato_documento = 'CA'
                                                AND NOT EXISTS
                                                       (SELECT 1
                                                          FROM riferimenti
                                                         WHERE     tipo_relazione IN ('FAX',
                                                                                      'MAIL')
                                                               AND id_documento_rif =
                                                                      smp.id_documento))
                    AND tipo_relazione IN ('PRINCIPALE', 'STREAM')
                    AND id_documento = NVL (p_id_documento, id_documento))
      LOOP
         -- DELETE FROM STREAM_MEMO_PROTOCOLLO E PRINCIPALE
         elimina_documento (rec.id_documento_rif,
                            p_versione,
                            '2 - STREAM DI MEMO CANCELLATI',
                            p_solospazio,
                            p_solofile);
      END LOOP;

      FOR rec
         IN (SELECT smp.id_documento
               FROM seg_memo_protocollo smp, documenti doc
              WHERE     smp.id_documento = doc.id_documento
                    AND smp.id_documento IN (  SELECT id_documento
                                                 FROM stati_documento
                                                WHERE id_documento =
                                                         smp.id_documento
                                             GROUP BY id_documento
                                               HAVING TRUNC (
                                                         MIN (
                                                            data_aggiornamento)) <
                                                           SYSDATE
                                                         - p_giorni_da_non_cancellare)
                    AND stato_documento = 'CA'
                    AND NOT EXISTS
                           (SELECT 1
                              FROM riferimenti
                             WHERE     tipo_relazione IN ('FAX', 'MAIL')
                                   AND id_documento_rif = smp.id_documento)
                    AND smp.id_documento =
                           NVL (p_id_documento, smp.id_documento))
      LOOP
         -- DELETE FROM SEG_MEMO_PROTOCOLLO
         elimina_documento (rec.id_documento,
                            p_versione,
                            '2 - MEMO CANCELLATI',
                            p_solospazio,
                            p_solofile);
      END LOOP;
   END pulisci_memo_ca;

   PROCEDURE pulisci_memo_ca (p_giorni_da_non_cancellare    NUMBER,
                              p_solofile                    NUMBER DEFAULT 1)
   IS
   BEGIN
      pulisci_memo_ca (NULL,
                       '',
                       p_giorni_da_non_cancellare,
                       0,
                       p_solofile);
   END;

   PROCEDURE calcola_spazio_pulisci_memo_ca (
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER)
   AS
   BEGIN
      pulisci_tabella_tmp;
      pulisci_memo_ca (NULL,
                       p_versione,
                       p_giorni_da_non_cancellare,
                       1);
   END;

   /*Eliminare tutti gli STREAM che hanno associato un MEMO
   che ha il campo PROCESSATO_AG= Y con possibilità
   di inserire un riferimento temporale per l¿eliminazione
   (tabella RIFERIMENTI con tipo_Relazione=¿STREAM¿
   e id_documento_rif corrisponde all¿id documento dello STREAM)*/
   PROCEDURE pulisci_stream (p_id_documento                NUMBER,
                             p_versione                    VARCHAR2,
                             p_giorni_da_non_cancellare    NUMBER,
                             p_solospazio                  NUMBER DEFAULT 0)
   IS
      TYPE r_cursor IS REF CURSOR;

      cur_iddoc    r_cursor;
      id_doc_del   spr_protocolli_intero.id_documento%TYPE;
      stmt         VARCHAR2 (32000);
   BEGIN
      IF p_versione = 'V2.1'
      THEN
         FOR rec
            IN (SELECT ssmp.id_documento
                  FROM seg_stream_memo_proto ssmp,
                       seg_memo_protocollo smp,
                       riferimenti rif
                 WHERE     ssmp.id_documento = rif.id_documento_rif
                       AND smp.id_documento = rif.id_documento
                       AND ssmp.id_documento IN (  SELECT id_documento
                                                     FROM stati_documento
                                                    WHERE id_documento =
                                                             ssmp.id_documento
                                                 GROUP BY id_documento
                                                   HAVING TRUNC (
                                                             MIN (
                                                                data_aggiornamento)) <
                                                               SYSDATE
                                                             - p_giorni_da_non_cancellare)
                       AND tipo_relazione = 'STREAM'
                       AND processato_ag = 'Y'
                       AND smp.id_documento =
                              NVL (p_id_documento, smp.id_documento))
         LOOP
            DBMS_OUTPUT.put_line ('3A ' || rec.id_documento);
            -- DELETE FROM SEG_STREAM_MEMO_PROTO
            elimina_documento (rec.id_documento,
                               p_versione,
                               '3 - STREAM PER VERSIONE 2.1 ',
                               p_solospazio);
         END LOOP;
      ELSE                        --v2.2 faccio così se no non compila il pack
         stmt :=
               ' select ssmp.id_documento from seg_stream_memo_proto ssmp,seg_memo_protocollo  smp, riferimenti rif
                        where
                        ssmp.id_documento=rif.id_documento_rif
                        and smp.id_documento = RIF.ID_DOCUMENTO
                        and  tipo_relazione =''STREAM''
                        and smp.stato_memo in (''DP'',''DPS'',''PR'', ''SC'')
                        and  trunc(sysdate - smp.data_stato_memo) > '
            || p_giorni_da_non_cancellare;

         IF p_id_documento IS NOT NULL
         THEN
            stmt := stmt || ' and smp.id_documento = ' || p_id_documento;
         END IF;

         LOOP
            OPEN cur_iddoc FOR stmt;

            FETCH cur_iddoc INTO id_doc_del;

            EXIT WHEN cur_iddoc%NOTFOUND;

            --DELETE FROM SEG_STREAM_MEMO_PROTO
            BEGIN
               elimina_documento (id_doc_del,
                                  p_versione,
                                  '3 - STREAM PER VERSIONE 2.2 ',
                                  p_solospazio);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (
                        'Fallita eliminazione stream '
                     || id_doc_del
                     || ' '
                     || SQLERRM);
            END;
         END LOOP;
      END IF;
   END pulisci_stream;

   PROCEDURE calcola_spazio_pulisci_stream (
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER)
   AS
   BEGIN
      pulisci_tabella_tmp;
      pulisci_stream (NULL,
                      p_versione,
                      p_giorni_da_non_cancellare,
                      1);
   END;

   PROCEDURE pulisci_scartati (
      p_id_documento                NUMBER,
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER,
      p_solospazio                  NUMBER DEFAULT 0)
   IS
      TYPE r_cursor IS REF CURSOR;

      cur_iddoc          r_cursor;
      id_doc_del         spr_protocolli_intero.id_documento%TYPE;
      dep_id_documento   NUMBER := NVL (p_id_documento, 0);
   BEGIN
      IF p_versione = 'V2.2'
      THEN
         LOOP
            OPEN cur_iddoc FOR
                  ' select smp.id_documento '
               || ' from seg_memo_protocollo  smp
                        where stato_memo = ''SC''
                        and  trunc(sysdate - data_stato_memo) > '
               || p_giorni_da_non_cancellare
               || ' and smp.id_documento = decode('
               || dep_id_documento
               || ', 0, smp.id_documento, '
               || dep_id_documento
               || ')';

            FETCH cur_iddoc INTO id_doc_del;

            EXIT WHEN cur_iddoc%NOTFOUND;

            --DELETE FROM SEG_STREAM_MEMO_PROTO
            DECLARE
               id_stream   NUMBER;
            BEGIN
               SELECT id_documento_rif
                 INTO id_stream
                 FROM riferimenti, seg_stream_memo_proto
                WHERE     riferimenti.id_documento = id_doc_del
                      AND seg_stream_memo_proto.id_documento =
                             riferimenti.id_documento_rif;

               elimina_documento (
                  id_stream,
                  p_versione,
                  '6 - ELIMINAZIONE STREAM DI MEMO SCARTATI ',
                  p_solospazio);
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            elimina_documento (id_doc_del,
                               p_versione,
                               '7 - ELIMINAZIONE MEMO SCARTATI ',
                               p_solospazio);
         END LOOP;
      END IF;
   END pulisci_scartati;

   PROCEDURE calcola_spzio_pulisci_scartati (
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER)
   AS
   BEGIN
      pulisci_tabella_tmp;
      pulisci_scartati (NULL,
                        p_versione,
                        p_giorni_da_non_cancellare,
                        1);
   END;

   /*CONSEGNA e altri messaggi automatici da PEC:
   un memo che ha PROCESSATO_AG = Y, è associato
   con relazione PRINCIPALE attiva ad un altro MEMO e
   con relazione PROT_PEC passiva ad un ulteriore MEMO
   contiene tutte le informazioni che servono per cui
   si può cancellare il MEMO associato via PRINCIPALE.
   Si può poi cancellare anche il file .eml in quanto
   rappresenta il MEMO spedito di cui abbiamo i dati
   nella relazione PROT_PEC.*/
   PROCEDURE pulisci_prot_pec (
      p_id_documento                NUMBER,
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER,
      p_solospazio                  NUMBER DEFAULT 0)
   IS
      TYPE r_cursor IS REF CURSOR;

      cur_iddoc          r_cursor;
      id_doc_del_eml     spr_protocolli_intero.id_documento%TYPE;
      id_doc_imbustato   spr_protocolli_intero.idrif%TYPE;
      dep_id_documento   NUMBER := NVL (p_id_documento, 0);
   BEGIN
      IF p_versione = 'V2.1'
      THEN
         FOR rec
            IN (SELECT smp.id_documento busta, rif.id_documento_rif imbustato
                  FROM seg_memo_protocollo smp, riferimenti rif
                 WHERE     smp.id_documento IN (  SELECT id_documento
                                                    FROM stati_documento
                                                   WHERE id_documento =
                                                            smp.id_documento
                                                GROUP BY id_documento
                                                  HAVING TRUNC (
                                                            MIN (
                                                               data_aggiornamento)) <
                                                              SYSDATE
                                                            - p_giorni_da_non_cancellare)
                       AND smp.id_documento =
                              NVL (p_id_documento, smp.id_documento)
                       AND processato_ag = 'Y'
                       AND smp.id_documento = rif.id_documento
                       AND rif.tipo_relazione = 'PRINCIPALE'
                       AND EXISTS
                              (SELECT 1
                                 FROM riferimenti
                                WHERE     tipo_relazione = 'PROT_PEC'
                                      AND id_documento_rif = smp.id_documento))
         LOOP
            elimina_eml (rec.busta,
                         '5 - ELIMINAZIONE EML DI MESSAGGI AUTOMATICI PEC ',
                         p_solospazio);
            elimina_documento (
               rec.imbustato,
               p_versione,
               '5 - ELIMINAZIONE IMBUSTATO DI MESSAGGI AUTOMATICI PEC ',
               p_solospazio);
         END LOOP;
      ELSE
         LOOP
            OPEN cur_iddoc FOR
                  ' select smp.id_documento busta, rif.id_documento_rif imbustato'
               || ' from seg_memo_protocollo  smp, riferimenti rif
                        where stato_memo != ''DG''
                        and  trunc(sysdate - data_stato_memo) > '
               || p_giorni_da_non_cancellare
               || ' and smp.id_documento = decode('
               || dep_id_documento
               || ',0, smp.id_documento, '
               || dep_id_documento
               || ')
                        AND smp.id_documento = rif.id_documento
                        AND rif.tipo_relazione = ''PRINCIPALE''
                        AND EXISTS (SELECT 1 FROM OGGETTI_FILE WHERE ID_DOCUMENTO = SMP.ID_DOCUMENTO
                        AND UPPER(FILENAME) LIKE ''%.EML'')
                        AND EXISTS (
                          SELECT 1
                            FROM riferimenti
                           WHERE tipo_relazione = ''PROT_PEC''
                             AND id_documento_rif = smp.id_documento)';

            FETCH cur_iddoc INTO id_doc_del_eml, id_doc_imbustato;

            EXIT WHEN cur_iddoc%NOTFOUND;
            elimina_eml (id_doc_del_eml,
                         '5 - ELIMINAZIONE EML DI MESSAGGI AUTOMATICI PEC ',
                         p_solospazio);
            elimina_documento (
               id_doc_imbustato,
               p_versione,
               '5 - ELIMINAZIONE IMBUSTATO DI MESSAGGI AUTOMATICI PEC ',
               p_solospazio);
         END LOOP;
      END IF;
   END pulisci_prot_pec;

   PROCEDURE calcola_spazio_prot_pec (p_versione                    VARCHAR2,
                                      p_giorni_da_non_cancellare    NUMBER)
   AS
   BEGIN
      pulisci_tabella_tmp;
      pulisci_prot_pec (NULL,
                        p_versione,
                        p_giorni_da_non_cancellare,
                        1);
   END;

   /*ANOMALIE protocollate o da protocollare
   (PROCESSATO_AG = Y, ha un riferimento PRINCIPALE attivo
   con un memo che a sua volta è associato
   con riferimento MAIL passivo a un protocollo):
   non si può cancellare il memo ANOMALIA
   in quanto è quello che viene mostrato nelle ricerche
   sui messaggi e non si può cancellare il memo
   in esso contenuto in quanto è associato al protocollo.
   Si può eliminare il file .eml che si trova nella OGGETTI_FILE
   con id_documento uguale all'id_documento dell'ANOMALIA.

  ANOMALIE che hanno generato una notifica eccezione:
  PROCESSATO_AG = N e GENERATA_ECCEZIONE = Y, relazione
  PRINCIPALE attiva con MEMO contenuto.
  Quest'ultimo ha relazione attiva PROT_ECC con
  memo in partenza che contiene l'eccezione.
  In questo caso il memo contenuto non si può cancellare,
  si può cancellare solo l'eml che sta dentro l'anomalia.*/
   PROCEDURE pulisci_anomalie (
      p_id_documento                NUMBER,
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER,
      p_solospazio                  NUMBER DEFAULT 0)
   IS
      TYPE r_cursor IS REF CURSOR;

      cur_iddoc          r_cursor;
      id_doc_del         spr_protocolli_intero.id_documento%TYPE;
      dep_id_documento   NUMBER := NVL (p_id_documento, 0);
   BEGIN
      IF p_versione = 'V2.1'
      THEN
         FOR rec
            IN (SELECT smp.id_documento
                  FROM seg_memo_protocollo smp, riferimenti rif
                 WHERE     smp.id_documento IN (  SELECT id_documento
                                                    FROM stati_documento
                                                   WHERE id_documento =
                                                            smp.id_documento
                                                GROUP BY id_documento
                                                  HAVING TRUNC (
                                                            MIN (
                                                               data_aggiornamento)) <
                                                              SYSDATE
                                                            - p_giorni_da_non_cancellare)
                       AND smp.id_documento =
                              NVL (p_id_documento, smp.id_documento)
                       AND (processato_ag = 'Y' OR generata_eccezione = 'Y')
                       AND smp.id_documento = rif.id_documento
                       AND rif.tipo_relazione = 'PRINCIPALE'
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM riferimenti
                                WHERE     tipo_relazione = 'PROT_PEC'
                                      AND id_documento_rif = smp.id_documento))
         LOOP
            elimina_eml (rec.id_documento,
                         '4 - ELIMINAZIONE EML DI ANOMALIA E CONSEGNA ',
                         p_solospazio);
         END LOOP;
      ELSE
         LOOP
            OPEN cur_iddoc FOR
                  ' select smp.id_documento '
               || ' from seg_memo_protocollo  smp, riferimenti rif
                        where stato_memo != ''DG''
                        and  trunc(sysdate - data_stato_memo) > '
               || p_giorni_da_non_cancellare
               || ' and smp.id_documento = decode('
               || dep_id_documento
               || ', 0, smp.id_documento, '
               || dep_id_documento
               || ')
                        AND smp.id_documento = rif.id_documento
                        AND rif.tipo_relazione = ''PRINCIPALE''
                        AND EXISTS (SELECT 1 FROM OGGETTI_FILE WHERE ID_DOCUMENTO = SMP.ID_DOCUMENTO
                        AND UPPER(FILENAME) LIKE ''%.EML'')
                        AND NOT EXISTS (
                          SELECT 1
                            FROM riferimenti
                           WHERE tipo_relazione = ''PROT_PEC''
                             AND id_documento_rif = smp.id_documento)';

            FETCH cur_iddoc INTO id_doc_del;

            EXIT WHEN cur_iddoc%NOTFOUND;
            --DELETE FROM SEG_STREAM_MEMO_PROTO
            elimina_eml (id_doc_del,
                         '4 - ELIMINAZIONE EML DI MESSAGGI AUTOMATICI PEC ',
                         p_solospazio);
         END LOOP;
      END IF;
   END pulisci_anomalie;

   PROCEDURE calcola_spzio_pulisci_anomalie (
      p_versione                    VARCHAR2,
      p_giorni_da_non_cancellare    NUMBER)
   AS
   BEGIN
      pulisci_tabella_tmp;
      pulisci_anomalie (NULL,
                        p_versione,
                        p_giorni_da_non_cancellare,
                        1);
   END;

   /*****************************************************************************
    NOME:        job_del_memo_stream.
    DESCRIZIONE: Elimina i messaggi duplicati dello scarico della pec
                parametri:
    Rev.  Data       Autore  Descrizione.
    00    30/01/2013  SS  1.0
   ********************************************************************************/
   PROCEDURE job_del_memo_stream (p_id_documento NUMBER DEFAULT NULL)
   IS
      versione                   VARCHAR2 (8);
      giorni_da_non_cancellare   INTEGER
         := ag_parametro.get_valore ('CONSERVA_MAIL_GG', '@agStrut@', 16);
      d_contatore                INTEGER := 0;

      TYPE r_cursor IS REF CURSOR;

      cur_iddoc                  r_cursor;
      id_doc_del                 spr_protocolli_intero.id_documento%TYPE;
      id_rif_del                 spr_protocolli_intero.idrif%TYPE;
      id_doc_del_eml             spr_protocolli_intero.id_documento%TYPE;
      id_doc_imbustato           spr_protocolli_intero.id_documento%TYPE;
   BEGIN
      DBMS_OUTPUT.put_line (
            'INIZIO JOB DEL MEMO STREAM GIORNI_DA_NON_CANCELLARE: '
         || giorni_da_non_cancellare);
      ripristina_cancellati;

      --CAPIRE COME INSERIRE LE CONDIZIONI DI NON INTEGRAZIONE CON INTERPRO E DI SCARICO IMAP
      BEGIN
         SELECT 'V2.2'
           INTO versione
           FROM user_tab_columns
          WHERE     table_name = 'SEG_MEMO_PROTOCOLLO'
                AND column_name = 'DATA_STATO_MEMO';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            versione := 'V2.1';
      END;

      BEGIN
         DBMS_OUTPUT.put_line ('v: ' || versione);
         --------------------------------1-----------------------------------------------
         pulisci_prin_ca (p_id_documento, versione, giorni_da_non_cancellare);
         --------------------------------2-----------------------------------------------
         pulisci_memo_ca (p_id_documento, versione, giorni_da_non_cancellare);
         --------------------------------3-----------------------------------------------
         pulisci_stream (p_id_documento, versione, giorni_da_non_cancellare);
         --------------------------------4-----------------------------------------------
         pulisci_anomalie (p_id_documento,
                           versione,
                           giorni_da_non_cancellare);
         --------------------------------5-----------------------------------------------
         pulisci_prot_pec (p_id_documento,
                           versione,
                           giorni_da_non_cancellare);
         --------------------------------6-----------------------------------------------
         pulisci_scartati (p_id_documento,
                           versione,
                           giorni_da_non_cancellare);
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (SQLERRM);
         ROLLBACK;
         RAISE;
   END job_del_memo_stream;

   PROCEDURE attiva_storeallmessages
   IS
      d_job        NUMBER;
      d_interval   VARCHAR2 (1000);
   BEGIN
      d_interval :=
         ag_parametro.get_valore (
            'WS_MAIL_INTERVAL_' || ag_utilities.get_defaultaooindex,
            '@agVar@',
            '15');
      d_job :=
         job_utility.attiva_one_job (
               'declare '
            || 'd_server       VARCHAR2(1000); '
            || 'd_fileprop     VARCHAR2(1000); '
            || 'd_tagmail      VARCHAR2(1000); '
            || 'd_sender       VARCHAR2(1000); '
            || 'd_recipient    VARCHAR2(1000); '
            || 'begin  '
            || 'd_server    := nvl(AG_PARAMETRO.GET_VALORE(''WS_MAIL_URL_''||AG_UTILITIES.get_defaultaooindex, ''@agVar@''), AG_PARAMETRO.GET_VALORE(''AG_SERVER_URL'', ''@ag@''));  '
            ||                    --'d_server:=''''; '||
              'd_tagmail   := AG_PARAMETRO.GET_VALORE(''WS_MAIL_TAG_''||AG_UTILITIES.get_defaultaooindex, ''@agVar@'');  '
            || 'd_sender    := AG_PARAMETRO.GET_VALORE(''WS_MAIL_SENDER_''||AG_UTILITIES.get_defaultaooindex, ''@agVar@'');  '
            || 'd_recipient := AG_PARAMETRO.GET_VALORE(''WS_MAIL_RECIPIENT_''||AG_UTILITIES.get_defaultaooindex, ''@agVar@''); '
            || 'd_fileprop  := AG_PARAMETRO.GET_VALORE(''WS_MAIL_PROPERTIES_''||AG_UTILITIES.get_defaultaooindex, ''@agVar@''); '
            || 'AG_UTILITIES_JOB.storeallmessages(d_server, d_fileprop, d_tagmail, d_sender, d_recipient); '
            || 'end;',
            'SYSDATE+1/1440*' || d_interval);
   END;

   PROCEDURE attiva_pulisci_memo_ca(p_giorni_da_non_cancellare NUMBER)
   IS
      d_job        NUMBER;
   BEGIN
      d_job :=
         job_utility.attiva_one_job (
               'begin  '
            || '   AG_UTILITIES_JOB.pulisci_memo_ca('||p_giorni_da_non_cancellare||', 1); '
            || 'end;',
            'SYSDATE+1');
   END;

   PROCEDURE storeallmessages (p_server       VARCHAR2,
                               p_fileprop     VARCHAR2,
                               p_tagmail      VARCHAR2,
                               p_sender       VARCHAR2,
                               p_recipient    VARCHAR2)
   IS
      --prendere parametro url di scarico e timeout da parametri  al momento sono fissi
      req           UTL_HTTP.req;
      resp          UTL_HTTP.resp;
      VALUE         VARCHAR2 (1024);
      url_scarico   VARCHAR2 (512);
      d_prosegui    NUMBER := -1;
      d_mail        NUMBER := 0;
      d_gg_log      NUMBER;
      d_data        DATE;
      d_id          NUMBER;
      d_minuti      NUMBER;
      d_ret         INTEGER;
      d_log         VARCHAR2 (100);
      d_text        VARCHAR2 (4000);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DBMS_OUTPUT.put_line ('p_server ' || p_server);
      d_gg_log :=
         TO_NUMBER (
            ag_parametro.get_valore (
               'WS_MAIL_LOG_GG_' || ag_utilities.get_defaultaooindex,
               '@agVar@',
               '30'));

      DELETE mailservice_log
       WHERE DATA < SYSDATE - d_gg_log AND proc_executor = p_fileprop;

      COMMIT;

      --      begin
      --         select data, id, log, to_number(trunc((sysdate - to_date(to_char(data,'ddmmyyyy hh24miss'),'ddmmyyyy hh24miss'))*1440 ))
      --           into d_data, d_id, d_log, d_minuti
      --           from mailservice_log
      --          where data = (select max(data) from mailservice_log where proc_executor = p_fileprop)
      --            and proc_executor = p_fileprop;
      --      exception
      --         when no_data_found then
      --            d_prosegui := -1;
      --      end;
      --
      --      dbms_output.put_line('d_log '||d_log);
      --
      --      if d_log in ('STARTED','NORESP') then
      --          d_prosegui := 0;
      --      end if;
      FOR LOG
         IN (SELECT DATA,
                    ID,
                    LOG,
                    TO_NUMBER (
                       TRUNC (
                            (  SYSDATE
                             - TO_DATE (TO_CHAR (DATA, 'ddmmyyyy hh24miss'),
                                        'ddmmyyyy hh24miss'))
                          * 1440))
                       minuti
               FROM mailservice_log
              WHERE     DATA = (SELECT MAX (DATA)
                                  FROM mailservice_log
                                 WHERE proc_executor = p_fileprop)
                    AND proc_executor = p_fileprop)
      LOOP
         d_data := LOG.DATA;
         d_id := LOG.ID;
         d_log := LOG.LOG;
         d_minuti := LOG.minuti;
         d_prosegui := 0;

         IF d_log IN ('COMPLETED', 'FORCED', 'NOSTART')
         THEN
            d_prosegui := 1;
            EXIT;
         END IF;
      END LOOP;

      -- se sono passati piu'' di 30 minuti dall'ultima esecuzione manda mail
      DBMS_OUTPUT.put_line ('d_prosegui ' || d_prosegui);
      DBMS_OUTPUT.put_line ('d_minuti ' || d_minuti);
      DBMS_OUTPUT.put_line ('d_log ' || d_log);

      IF d_prosegui = -1
      THEN
         d_mail := 1;
         d_text := 'Servizio mai partito. Avviare il contesto mailservice.';

         INSERT INTO mailservice_log (LOG, proc_executor)
              VALUES ('NOSTART', p_fileprop);
      ELSE
         IF    (d_minuti >= 30 AND NVL (d_log, ' ') <> 'NOSTART')
            OR (d_minuti >= 1440 AND NVL (d_log, ' ') = 'NOSTART')
         THEN
            d_mail := 1;
            d_text := 'Scarico ';

            IF d_log IN ('STARTED', 'NORESP')
            THEN
               d_text := d_text || 'attivo';
            ELSE
               d_text := d_text || 'non effettuato';
            END IF;

            d_text :=
                  d_text
               || ' da '
               || d_minuti
               || ' minuti. Se il problema persiste, riavviare il contesto mailservice.';
         END IF;
      END IF;

      DBMS_OUTPUT.put_line ('d_prosegui ' || d_prosegui);

      IF d_mail = 1 AND TRIM (p_tagmail) IS NOT NULL
      THEN
         BEGIN
            d_ret :=
               amvweb.send_msg (p_sender,
                                p_recipient,
                                'Segnalazione su scarico pec',
                                d_text,
                                p_tagmail);
         EXCEPTION
            WHEN OTHERS
            THEN
               --RAISE;
               DBMS_OUTPUT.put_line ('send_msg ' || SQLERRM);
         END;
      END IF;

      COMMIT;

      IF d_prosegui > 0
      THEN
         url_scarico :=
               p_server
            || '/mailservice/storeallmsgs'
            || CHR (63)
            || 'fileprop='
            || p_fileprop
            || '&tagmail='
            || p_tagmail
            || '&sender='
            || p_sender
            || '&mail='
            || p_recipient;
         UTL_HTTP.set_transfer_timeout (1);
         req := UTL_HTTP.begin_request (url_scarico, 'POST');
         -- inizia la richiesta
         UTL_HTTP.set_header (req, 'User-Agent', 'Mozilla/4.0');
         resp := UTL_HTTP.get_response (req);

         LOOP
            UTL_HTTP.read_line (resp, VALUE, TRUE);
            DBMS_OUTPUT.put_line (VALUE);
         END LOOP;

         UTL_HTTP.end_response (resp);
      END IF;

      COMMIT;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         ROLLBACK;
         UTL_HTTP.end_response (resp);
      WHEN OTHERS
      THEN
         ROLLBACK;
         NULL;
   --         --TIMEOUT
   --         IF INSTR (SQLERRM, '-29276') > 0
   --         THEN
   --            NULL;
   --         ELSE
   --            RAISE;
   --         END IF;
   END;

   PROCEDURE ripristina_documento_interop (dep_id_documento NUMBER)
   AS
      dep_data_stato      DATE;
      dep_utente          stati_documento.utente_aggiornamento%TYPE;
      dep_stato           stati_documento.stato%TYPE;
      dep_utente_delete   stati_documento.utente_aggiornamento%TYPE;
      dep_data_delete     DATE;
   BEGIN
      BEGIN
         SELECT utente_aggiornamento, data_aggiornamento
           INTO dep_utente_delete, dep_data_delete
           FROM stati_documento
          WHERE id_documento = dep_id_documento AND stato = 'CA';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
      END;

      DELETE stati_documento
       WHERE id_documento = dep_id_documento AND stato = 'CA';

      SELECT MAX (data_aggiornamento)
        INTO dep_data_stato
        FROM stati_documento
       WHERE id_documento = dep_id_documento;

      DBMS_OUTPUT.put_line (
            'dep_data_stato '
         || TO_CHAR (dep_data_stato, 'DD/MM/YYYY HH24:MI:SS'));

      SELECT utente_aggiornamento, stato
        INTO dep_utente, dep_stato
        FROM stati_documento
       WHERE     id_documento = dep_id_documento
             AND data_aggiornamento = dep_data_stato;

      DBMS_OUTPUT.put_line ('dep_utente ' || dep_utente);
      DBMS_OUTPUT.put_line ('dep_stato ' || dep_stato);

      UPDATE documenti
         SET data_aggiornamento = dep_data_stato,
             utente_aggiornamento = dep_utente,
             stato_documento = dep_stato
       WHERE id_documento = dep_id_documento;

      UPDATE stati_documento
         SET commento =
                   'Per integrita'' dati di interoperabilita'', in data '
                || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                || ' e'' stato ripristinato record cancellato da '
                || dep_utente_delete
                || ' il giorno '
                || TO_CHAR (dep_data_delete, 'dd/mm/yyyy hh24:mi:ss')
       WHERE     id_documento = dep_id_documento
             AND data_aggiornamento = dep_data_stato;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE ripristina_cancellati
   AS
      d_conta   NUMBER := 0;
   BEGIN
      /*memo rif in una relazione principale, non dovrebbe essere possibile cancellarli
      perchè non sono mai disponibili da interfaccia .
      Considero da non cancellare definitiVamente solo quelli il cui principale
      è a sua volta collegato ad un protocollo*/
      FOR memo
         IN (SELECT d.id_documento
               FROM seg_memo_protocollo s, documenti d
              WHERE     d.id_documento = s.id_documento
                    AND d.stato_documento = 'CA'
                    AND s.memo_in_partenza = 'N'
                    AND EXISTS
                           (SELECT 1
                              FROM riferimenti r, documenti dm
                             WHERE     id_documento_rif = s.id_documento
                                   AND tipo_relazione = 'PRINCIPALE'
                                   AND dm.id_documento = r.id_documento
                                   AND dm.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                                   AND EXISTS
                                          (SELECT 1
                                             FROM riferimenti rm,
                                                  documenti dprot
                                            WHERE     rm.id_documento_rif =
                                                         d.id_documento
                                                  AND tipo_relazione IN ('FAX',
                                                                         'MAIL')
                                                  AND rm.id_documento =
                                                         dprot.id_documento
                                                  AND dprot.stato_documento NOT IN ('CA',
                                                                                    'RE',
                                                                                    'PB'))))
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;
      d_conta := 0;

      /* memo in arrivo cancellati ma protocollati */
      FOR memo
         IN (SELECT s.id_documento
               FROM seg_memo_protocollo s, documenti d
              WHERE     d.id_documento = s.id_documento
                    AND d.stato_documento = 'CA'
                    AND s.memo_in_partenza = 'N'
                    AND EXISTS
                           (SELECT 1
                              FROM riferimenti r,
                                   documenti dm,
                                   spr_protocolli_intero p
                             WHERE     id_documento_rif = s.id_documento
                                   AND tipo_relazione IN ('FAX', 'MAIL')
                                   AND dm.id_documento = r.id_documento
                                   AND dm.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                                   AND p.id_documento = dm.id_documento
                                   AND p.stato_pr != 'DP'))
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /* memo in arrivo cancellati con figlio protocollato*/
      FOR memo
         IN (SELECT d.id_documento, s.oggetto
               FROM seg_memo_protocollo s, documenti d
              WHERE     d.id_documento = s.id_documento
                    AND d.stato_documento = 'CA'
                    AND s.memo_in_partenza = 'N'
                    AND EXISTS
                           (SELECT 1
                              FROM riferimenti r, documenti dm
                             WHERE     r.id_documento = s.id_documento
                                   AND tipo_relazione = 'PRINCIPALE'
                                   AND dm.id_documento = r.id_documento_rif
                                   AND EXISTS
                                          (SELECT 1
                                             FROM riferimenti rm,
                                                  documenti dprot,
                                                  proto_view
                                            WHERE     rm.id_documento_rif =
                                                         dm.id_documento
                                                  AND tipo_relazione IN ('FAX',
                                                                         'MAIL')
                                                  AND rm.id_documento =
                                                         dprot.id_documento
                                                  AND proto_view.id_documento =
                                                         dprot.id_documento
                                                  AND proto_view.stato_pr !=
                                                         'DP'
                                                  AND dprot.stato_documento NOT IN ('CA',
                                                                                    'RE',
                                                                                    'PB'))))
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /* memo in arrivo cancellati per i quali è stata spedita una
      notifica eccezione */
      FOR memo
         IN (SELECT d.id_documento
               FROM seg_memo_protocollo s, documenti d
              WHERE     d.id_documento = s.id_documento
                    AND d.stato_documento = 'CA'
                    AND s.memo_in_partenza = 'N'
                    AND EXISTS
                           (SELECT 1
                              FROM riferimenti r,
                                   documenti dm,
                                   seg_memo_protocollo mp
                             WHERE     id_documento_rif = dm.id_documento
                                   AND tipo_relazione = 'PROT_ECC'
                                   AND s.id_documento = r.id_documento
                                   AND dm.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                                   AND mp.id_documento = dm.id_documento
                                   AND mp.memo_in_partenza = 'Y'))
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /* Memo di notifiche eccezione ricevute */
      FOR memo
         IN (SELECT d.id_documento
               FROM seg_memo_protocollo s, documenti d
              WHERE     d.id_documento = s.id_documento
                    AND d.stato_documento = 'CA'
                    AND s.memo_in_partenza = 'N'
                    AND EXISTS
                           (SELECT 1
                              FROM riferimenti r, documenti dm, proto_view p
                             WHERE     id_documento_rif = s.id_documento
                                   AND tipo_relazione = 'PROT_ECC'
                                   AND dm.id_documento = r.id_documento
                                   AND dm.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                                   AND p.id_documento = dm.id_documento))
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /* Memo cancellati di messaggi automatici PEC associati
      a memo in partenza che non sono cancellati*/
      FOR memo
         IN (SELECT d.id_documento
               FROM seg_memo_protocollo s, documenti d
              WHERE     d.id_documento = s.id_documento
                    AND d.stato_documento = 'CA'
                    AND s.memo_in_partenza = 'N'
                    AND EXISTS
                           (SELECT 1
                              FROM riferimenti r,
                                   documenti dm,
                                   seg_memo_protocollo m
                             WHERE     id_documento_rif = s.id_documento
                                   AND tipo_relazione = 'PROT_PEC'
                                   AND dm.id_documento = r.id_documento
                                   AND dm.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                                   AND dm.id_documento = m.id_documento
                                   AND m.memo_in_partenza = 'Y'))
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /* Memo cancellati di messaggi automatici PEC associati a memo in partenza che non sono cancellati*/
      FOR memo
         IN (SELECT d.id_documento
               FROM seg_memo_protocollo s, documenti d
              WHERE     d.id_documento = s.id_documento
                    AND d.stato_documento = 'CA'
                    AND s.memo_in_partenza = 'N'
                    AND EXISTS
                           (SELECT 1
                              FROM riferimenti r,
                                   documenti dm,
                                   seg_memo_protocollo m
                             WHERE     id_documento_rif = dm.id_documento
                                   AND tipo_relazione = 'PROT_PEC'
                                   AND r.id_documento = s.id_documento
                                   AND dm.stato_documento NOT IN ('CA',
                                                                  'RE',
                                                                  'PB')
                                   AND m.id_documento = dm.id_documento
                                   AND m.memo_in_partenza = 'Y'))
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /*memo in arrivo cancellati di aggiornamento conferma di protocolli*/
      FOR memo
         IN (SELECT m.id_documento
               FROM riferimenti r,
                    seg_memo_protocollo m,
                    documenti d,
                    proto_view p
              WHERE     tipo_relazione = 'PROT_AGG'
                    AND r.id_documento_rif = m.id_documento
                    AND m.memo_in_partenza = 'N'
                    AND d.id_documento = m.id_documento
                    AND d.stato_documento = 'CA'
                    AND r.id_documento = p.id_documento
                    AND NVL (p.stato_pr, '*') != 'DP')
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /*memo in arrivo cancellati di annullamento di protocolli*/
      FOR memo
         IN (SELECT m.id_documento
               FROM riferimenti r,
                    seg_memo_protocollo m,
                    documenti d,
                    proto_view p
              WHERE     tipo_relazione = 'PROT_ANN'
                    AND r.id_documento_rif = m.id_documento
                    AND m.memo_in_partenza = 'N'
                    AND d.id_documento = m.id_documento
                    AND d.stato_documento = 'CA'
                    AND r.id_documento = p.id_documento
                    AND NVL (p.stato_pr, '*') != 'DP')
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;

      /*memo in arrivo cancellati di eccezione di protocolli*/
      FOR memo
         IN (SELECT m.id_documento
               FROM riferimenti r,
                    seg_memo_protocollo m,
                    documenti d,
                    proto_view p
              WHERE     tipo_relazione = 'PROT_ECC'
                    AND r.id_documento_rif = m.id_documento
                    AND m.memo_in_partenza = 'N'
                    AND d.id_documento = m.id_documento
                    AND d.stato_documento = 'CA'
                    AND r.id_documento = p.id_documento
                    AND NVL (p.stato_pr, '*') != 'DP')
      LOOP
         ag_utilities_job.ripristina_documento_interop (memo.id_documento);
         d_conta := d_conta + 1;

         IF d_conta >= 99
         THEN
            COMMIT;
            d_conta := 0;
         END IF;
      END LOOP;

      COMMIT;
   END;
END;
/
