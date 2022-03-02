--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_DOCUMENTI_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER GDO_DOCUMENTI_TIU
   BEFORE INSERT OR UPDATE
   ON GDO_DOCUMENTI
   FOR EACH ROW
DECLARE
BEGIN
   :NEW.RISERVATO := NVL (:NEW.RISERVATO, 'N');
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
