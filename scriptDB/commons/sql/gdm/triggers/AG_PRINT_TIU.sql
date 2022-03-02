--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_PRINT_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_PRINT_TIU
   BEFORE INSERT OR UPDATE
   ON SPR_PROTOCOLLI_INTERO
   FOR EACH ROW
BEGIN
   IF :NEW.numero IS NOT NULL and :old.numero is null then
         AG_UTILITIES_PROTOCOLLO.CALCOLA_ID_NOME_FILE_SUAP(:new.id_documento, :new.codice_amministrazione, :new.codice_aoo, :new.suap_iddoc_file, :new.suap_file);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
