--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_PROTOCOLLI_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER agp_protocolli_tiu
   BEFORE INSERT OR UPDATE
   ON AGP_PROTOCOLLI
   FOR EACH ROW
BEGIN
   IF     :new.tipo_registro IS NOT NULL
      AND (:new.anno IS NULL OR :new.numero IS NULL)
   THEN
      :new.tipo_registro := NULL;
   END IF;

   IF     :new.data_redazione IS NULL
   THEN
      :new.data_redazione := sysdate;
   END IF;
END;
/
