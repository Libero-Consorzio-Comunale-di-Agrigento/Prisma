--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_TIDO_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_tido_tu
   BEFORE UPDATE OF dataval_al
   ON SEG_TIPI_DOCUMENTO
   FOR EACH ROW
DECLARE
   d_data_prot   DATE;
BEGIN
   IF :NEW.dataval_al != :OLD.dataval_al AND :new.dataval_al IS NOT NULL
   THEN
      BEGIN
         SELECT NVL (MAX (data), TO_DATE (2222222, 'j'))
           INTO d_data_prot
           FROM proto_view
          WHERE tipo_documento = :new.tipo_documento;

         IF TRUNC (d_data_prot) > TRUNC (:new.dataval_al)
         THEN
            raise_application_error (
               -20999,
                  'Il tipo di documento e'' stato utilizzato in almeno un documento protocollato in data successiva ('
               || TO_CHAR (d_data_prot, 'dd/mm/yyyy')
               || ') alla data di chiusura.');
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN

      RAISE;
END;
/
