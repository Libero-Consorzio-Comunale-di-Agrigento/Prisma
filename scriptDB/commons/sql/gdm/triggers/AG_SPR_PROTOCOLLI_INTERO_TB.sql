--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_PROTOCOLLI_INTERO_TB runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SPR_PROTOCOLLI_INTERO_TB BEFORE INSERT OR UPDATE OR DELETE ON SPR_PROTOCOLLI_INTERO BEGIN IF INTEGRITYPACKAGE.GETNESTLEVEL = 0 THEN INTEGRITYPACKAGE.INITNESTLEVEL; END IF; END;
/
