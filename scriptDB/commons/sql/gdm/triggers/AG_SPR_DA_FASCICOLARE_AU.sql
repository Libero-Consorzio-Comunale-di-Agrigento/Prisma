--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_DA_FASCICOLARE_AU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_SPR_DA_FASCICOLARE_au
   AFTER UPDATE
   ON SPR_DA_FASCICOLARE
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
BEGIN

   IF NVL (:NEW.OGGETTO, '') <> NVL (:OLD.OGGETTO, '')
   THEN
      AG_UTILITIES_CRUSCOTTO.UPD_OGG_TASK_EST_COMMIT (:NEW.IDRIF,
                                                    NVL (:NEW.OGGETTO, ''),
                                                    NVL (:OLD.OGGETTO, ''),
                                                    NULL,
                                                    NULL);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
            'Errore in aggiornamento oggetto dei task esterni. Errore: '
         || SQLERRM);
END;
/
