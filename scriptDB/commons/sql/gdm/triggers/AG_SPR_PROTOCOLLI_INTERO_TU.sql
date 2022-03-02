--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_PROTOCOLLI_INTERO_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_SPR_PROTOCOLLI_INTERO_tu
   BEFORE UPDATE
   ON SPR_PROTOCOLLI_INTERO
   FOR EACH ROW
BEGIN
   IF nvl(upper(:new.allegato_principale), ' ') <> nvl(upper(:old.allegato_principale), ' ') and
      (:old.verifica_firma is not null or :old.data_verifica is not null)
   THEN
      :new.verifica_firma := NULL;
      :new.data_verifica := null;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
