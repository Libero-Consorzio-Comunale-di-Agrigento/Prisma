--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_FILE_DOCUMENTO_LOG_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER GDO_FILE_DOCUMENTO_LOG_TIU
   BEFORE INSERT OR UPDATE
   ON GDO_FILE_DOCUMENTO_LOG
   FOR EACH ROW
BEGIN
   --in fase di eliminazione imposto la data_upd uguale alla data di sistema
   IF (:NEW.REVTYPE = 2) THEN
      :NEW.DATA_UPD   := SYSDATE;
   END IF;

   :NEW.DATA_LOG   := TRUNC (:NEW.DATA_UPD);
END GDO_FILE_DOCUMENTO_LOG_TIU;
/
