--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_ACRA_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_acra_tiu
   BEFORE INSERT OR UPDATE
   ON ag_acquisizione_rapporti
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   tmpvar   NUMBER;
/******************************************************************************
   NAME:
   PURPOSE:
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/11/2007             1. Created this trigger.
   NOTES:
   Automatically available Auto Replace Keywords:
      Object Name:
      Sysdate:         22/11/2007
      Date and Time:   22/11/2007, 15.16.24, and 22/11/2007 15.16.24
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      AG_ACQUISIZIONE_RAPPORTI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF INSERTING
   THEN
      tmpvar := 0;
      SELECT ag_acra_sq.NEXTVAL
        INTO tmpvar
        FROM DUAL;
      :NEW.progressivo := tmpvar;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
