--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_PROTOCOLLI_CORR_LOG_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGP_PROTOCOLLI_CORR_LOG_TIU
   BEFORE INSERT OR UPDATE
   ON AGP_PROTOCOLLI_CORR_LOG
   FOR EACH ROW
BEGIN
   --in fase di eliminazione imposto la data_upd uguale alla data di sistema
   IF (:NEW.REVTYPE = 2) THEN
      :NEW.DATA_UPD   := SYSDATE;
   END IF;

   :NEW.DATA_LOG   := TRUNC (:NEW.DATA_UPD);
END AGP_PROTOCOLLI_CORR_LOG_TIU;
/
