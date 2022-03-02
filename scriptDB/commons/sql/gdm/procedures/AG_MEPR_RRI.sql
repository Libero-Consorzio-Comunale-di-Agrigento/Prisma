--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_MEPR_RRI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_mepr_rri (
   new_id_documento   NUMBER,
   new_stato_pr       VARCHAR2,
   new_processato     VARCHAR2
)
IS
/******************************************************************************
   NAME:       AG_MEPR_RRI
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        24/09/2012  SC        1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_MEPR_RRI
      Sysdate:         17/02/2009
      Date and Time:   17/02/2009, 16.50.08, and 17/02/2009 16.50.08
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN

   UPDATE seg_memo_protocollo
      SET stato_memo = new_stato_pr,
          processato_ag = new_processato
    WHERE memo_in_partenza = 'N'
      AND id_documento IN (
             SELECT id_documento_rif
               FROM riferimenti
              WHERE id_documento = new_id_documento
                AND tipo_relazione = 'PRINCIPALE');

   IF SQL%ROWCOUNT <> 1
   THEN



      UPDATE seg_memo_protocollo
         SET stato_memo = new_stato_pr,
             processato_ag = new_processato
       WHERE memo_in_partenza = 'N'
         AND id_documento IN (
                SELECT id_documento
                  FROM riferimenti
                 WHERE id_documento_rif = new_id_documento
                   AND tipo_relazione = 'PRINCIPALE');

   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_mepr_rri;
/
