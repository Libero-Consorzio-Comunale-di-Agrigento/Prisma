--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SMSC_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_smsc_tiu
   BEFORE INSERT OR UPDATE
   ON ag_smistamenti_scaduti
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
/******************************************************************************
   NAME:       AG_SMSC_TIU
   PURPOSE:
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        128/01/2010  SC           1. Created this trigger. A35655.3.0.
   NOTES:
   Automatically available Auto Replace Keywords:
      Object Name:     AG_CLAS_TIU
      Sysdate:         17/02/2009
      Date and Time:   17/02/2009, 16.23.00, and 17/02/2009 16.23.00
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      SEG_CLASSIFICAZIONI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF :NEW.data_aggiornamento IS NULL
   THEN
      :NEW.data_aggiornamento := SYSDATE;
   END IF;
END ag_smsc_tiu;
/
