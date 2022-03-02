--liquibase formatted sql
--changeset mmalferrari:agp_protocolli_ogg_tiu runOnChange:true stripComments:false

CREATE OR REPLACE TRIGGER agp_protocolli_ogg_tiu
   BEFORE INSERT OR UPDATE
   ON AGP_PROTOCOLLI
   FOR EACH ROW
BEGIN
   FOR c IN (SELECT code
               FROM BLACKLISTCHAR)
   LOOP
      :new.oggetto := REPLACE (:new.oggetto, CHR (c.code), ' ');
   END LOOP;
END;
/
