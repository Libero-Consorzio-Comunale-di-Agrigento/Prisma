--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_COES_CODICEADS_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_coes_codiceads_tiu
   BEFORE INSERT OR UPDATE
   ON collegamenti_esterni
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   dep_area_documento           VARCHAR2 (1000);
   dep_cartella_con_codiceads   NUMBER;
/******************************************************************************
   NAME:       AG_COES_CODICEADS_TIU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/04/2012             1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_CART_CODICEADS_TIU
      Sysdate:         13/04/2012
      Date and Time:   13/04/2012, 13.09.06, and 13/04/2012 13.09.06
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      CARTELLE (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN

   IF     instr(:new.url, 'agspr') > 0
   THEN
      :NEW.codiceads :=
               'SEGRETERIA' || '#' || replace_for_codiceads (:NEW.nome);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_coes_codiceads_iu;
/
