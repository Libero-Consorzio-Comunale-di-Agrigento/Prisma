--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SEG_MEMO_PROTOCOLLO_AU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_SEG_MEMO_PROTOCOLLO_au
   AFTER UPDATE
   ON SEG_MEMO_PROTOCOLLO
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
