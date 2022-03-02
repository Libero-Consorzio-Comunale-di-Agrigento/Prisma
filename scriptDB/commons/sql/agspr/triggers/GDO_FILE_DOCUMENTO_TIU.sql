--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_FILE_DOCUMENTO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER GDO_FILE_DOCUMENTO_TIU
   BEFORE INSERT OR UPDATE
   ON GDO_FILE_DOCUMENTO
   FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.content_type = 'application/pkcs7-mime'
   THEN
      :NEW.content_type := 'application/octet-stream';
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
