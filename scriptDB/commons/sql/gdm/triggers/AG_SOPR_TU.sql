--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SOPR_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_sopr_tu
   BEFORE UPDATE OF denominazione_per_segnatura, cognome_per_segnatura
   ON seg_soggetti_protocollo
   FOR EACH ROW
DECLARE
BEGIN
   :NEW.TXT := :OLD.TXT;
   :NEW.TXT_AMM := :OLD.TXT_AMM;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_sopr_tu;
/
