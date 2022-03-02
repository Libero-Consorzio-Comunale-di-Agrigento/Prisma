--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_SEG_SMISTAMENTI_TIDO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER seg_smistamenti_tido_tiu
   BEFORE INSERT OR UPDATE
   ON seg_smistamenti_tipi_documento
   FOR EACH ROW
DECLARE
BEGIN
   IF updating and :new.tipo_documento is null
   THEN
      raise_application_error(-20999, 'Campo Tipo Documento obbligatorio');
   END IF;
END;
/
