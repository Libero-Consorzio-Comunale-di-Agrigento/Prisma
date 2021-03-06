--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_BOTTONI_NOTIFICHE_TIO runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGP_BOTTONI_NOTIFICHE_TIO
   INSTEAD OF DELETE OR INSERT OR UPDATE
   ON AGP_BOTTONI_NOTIFICHE
   FOR EACH ROW
DECLARE
BEGIN
   IF UPDATING
   THEN
      UPDATE GDM_SEG_BOTTONI_NOTIFICHE
         SET LABEL = :NEW.LABEL,
             ICONA_SHORT = :NEW.ICONA_SHORT,
             ICONA = 'fa fa-' || :NEW.ICONA_SHORT,
             UTENTE_UPD = :NEW.UTENTE_UPD,
             DATA_UPD = :NEW.DATA_UPD,
             TOOLTIP = :NEW.TOOLTIP,
             SEQUENZA = :NEW.SEQUENZA,
             URL_AZIONE = :NEW.URL_AZIONE
       WHERE ID = -:NEW.ID;
   END IF;
END;
/
