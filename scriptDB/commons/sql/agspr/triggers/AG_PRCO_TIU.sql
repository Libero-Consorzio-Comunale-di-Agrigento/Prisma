--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AG_PRCO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_prco_tiu
   BEFORE UPDATE OR INSERT
   ON agp_protocolli_corrispondenti
   FOR EACH ROW
DECLARE
BEGIN
   :new.email := TRIM (:new.email);
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
