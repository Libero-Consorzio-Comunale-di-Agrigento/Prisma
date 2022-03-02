--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_LEUS_UNITA runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_spr_leus_unita
   BEFORE UPDATE OR INSERT
   ON spr_lettere_uscita
   FOR EACH ROW
DECLARE
BEGIN
   IF (    :NEW.descrizione_unita IS NULL
       AND :NEW.unita_protocollante IS NOT NULL)
   THEN
      :NEW.descrizione_unita :=
         ag_unita_utility.get_descrizione (:NEW.unita_protocollante,
                                           TRUNC (SYSDATE));
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END ag_spr_leus_unita;
/
