--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGS_CLASSIFICAZIONI_TC runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ags_classificazioni_TC
   after INSERT or UPDATE or DELETE on ags_classificazioni
BEGIN
   /* EXEC PostEvent for Custom Functional Check */
   IntegrityPackage.Exec_PostEvent;
END;
/
