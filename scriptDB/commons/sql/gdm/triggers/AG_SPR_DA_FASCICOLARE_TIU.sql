--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_DA_FASCICOLARE_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_spr_da_fascicolare_tiu
   BEFORE INSERT OR UPDATE
   ON spr_da_fascicolare
   FOR EACH ROW
BEGIN
   IF NVL (:NEW.stato_scarto, '**') <> NVL (:OLD.stato_scarto, '**')
   THEN
      :NEW.data_stato_scarto := SYSDATE;
   END IF;
END;
/
