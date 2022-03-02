--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_CODA_FIRMA_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER gdo_coda_firma_tiu
   BEFORE INSERT OR UPDATE
   ON gdo_coda_firma
   FOR EACH ROW
BEGIN
   IF :new.utente_firmatario_effettivo IS NULL
   THEN
      :new.utente_firmatario_effettivo := :new.utente_firmatario;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
