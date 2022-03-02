--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_CLASSIFICAZIONI_TB runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ags_classificazioni_TB
   before INSERT or UPDATE or DELETE on ags_classificazioni
BEGIN
   /* RESET PostEvent for Custom Functional Check */
   IF IntegrityPackage.GetNestLevel = 0 THEN
      IntegrityPackage.InitNestLevel;
   END IF;
END;
/
