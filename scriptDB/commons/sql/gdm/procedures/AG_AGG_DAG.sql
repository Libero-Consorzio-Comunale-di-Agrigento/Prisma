--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_AGG_DAG runOnChange:true stripComments:false failOnError:false

CREATE TABLE AG_DAG_TRASCO_LOG
(
  TABELLA           VARCHAR2(255),
  ID_DOCUMENTO_GDM  NUMBER,
  LOG_TRASCO        CLOB,
  ESITO             VARCHAR2(2)
)
/

CREATE OR REPLACE PROCEDURE ag_agg_dag (p_tabella VARCHAR2)
IS
   d_result         afc.t_ref_cursor;
   d_id_doc_gdm     NUMBER;
   d_id_doc_agspr   NUMBER;
   d_stm            VARCHAR2 (1000);

   PROCEDURE ins_log (p_TABELLA       VARCHAR2,
                      p_ID_DOC_GDM    NUMBER,
                      p_LOG_TRASCO    CLOB,
                      p_esito         VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO AG_DAG_TRASCO_LOG (TABELLA,
                                     ID_DOCUMENTO_GDM,
                                     LOG_TRASCO,
                                     esito)
           VALUES (p_tabella,
                   p_ID_DOC_GDM,
                   p_LOG_TRASCO,
                   p_esito);

      COMMIT;
   END;
BEGIN
   d_stm := 'select distinct id_protocollo from ' || p_tabella;
   DBMS_OUTPUT.put_line (
      '==================================================================');
   DBMS_OUTPUT.put_line (d_stm);
   DBMS_OUTPUT.put_line (
      '==================================================================');

   OPEN d_result FOR d_stm;

   IF d_result%ISOPEN
   THEN
      LOOP
         FETCH d_result INTO d_id_doc_gdm;

         EXIT WHEN d_result%NOTFOUND;
         DBMS_OUTPUT.put_line ('------------ d_id_doc_gdm ' || d_id_doc_gdm);

         BEGIN
            d_id_doc_agspr :=
               AGSPR_AGP_PROTOCOLLI_PKG.get_id_documento (d_id_doc_gdm);

            IF d_id_doc_agspr IS NULL
            THEN
               d_id_doc_agspr :=
                  AGSPR_AGP_TRASCO_PKG.crea_protocollo_agspr (d_id_doc_gdm);
            END IF;

            DBMS_OUTPUT.put_line (
                  '------------ d_id_doc_gdm '
               || d_id_doc_gdm
               || ' => '
               || d_id_doc_agspr);

            EXECUTE IMMEDIATE
                  'update '
               || p_tabella
               || ' set id_protocollo = '
               || d_id_doc_agspr
               || ' where id_protocollo = '
               || d_id_doc_gdm;

            ins_log (
               p_TABELLA,
               d_id_doc_gdm,
               'd_id_doc_gdm ' || d_id_doc_gdm || ' => ' || d_id_doc_agspr,
               'OK');
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (SQLERRM);
               ins_log (p_TABELLA,
                        d_id_doc_gdm,
                        SQLERRM,
                        'KO');
         END;
      END LOOP;

      CLOSE d_result;
   END IF;
END;
/
