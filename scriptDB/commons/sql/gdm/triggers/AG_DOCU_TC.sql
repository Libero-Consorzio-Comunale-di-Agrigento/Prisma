--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_DOCU_TC runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_DOCU_TC
   AFTER INSERT OR UPDATE OR DELETE ON DOCUMENTI
BEGIN
   /* EXEC POSTEVENT FOR CUSTOM FUNCTIONAL CHECK */
   INTEGRITYPACKAGE.EXEC_POSTEVENT;
END;
/
