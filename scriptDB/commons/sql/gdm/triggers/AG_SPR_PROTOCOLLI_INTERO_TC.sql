--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_PROTOCOLLI_INTERO_TC runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SPR_PROTOCOLLI_INTERO_TC AFTER INSERT OR UPDATE OR DELETE ON SPR_PROTOCOLLI_INTERO BEGIN INTEGRITYPACKAGE.EXEC_POSTEVENT; END;
/