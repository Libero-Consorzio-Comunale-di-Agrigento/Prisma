--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_CS_MESSAGGI_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ag_cs_messaggi_tu
   BEFORE UPDATE
   ON ag_cs_messaggi
   FOR EACH ROW
BEGIN
   if  NVL (:OLD.stato_spedizione, 'READYTOSEND') in ('SENTOK', 'SENTFAILED') and  NVL (:new.stato_spedizione, 'READYTOSEND') in ('READYTOSEND', 'SENDING') then
      :new.stato_spedizione :=  NVL(:OLD.stato_spedizione, 'READYTOSEND');
   end if;

   IF (    NVL (:NEW.stato_spedizione, 'READYTOSEND') != 'READYTOSEND'
       AND NVL (:NEW.stato_spedizione, 'READYTOSEND') !=
                                    NVL (:OLD.stato_spedizione, 'READYTOSEND')
      )
   THEN
      IF :NEW.data_modifica IS NULL
      THEN
         :NEW.data_modifica := SYSDATE;
      END IF;
   END IF;
END;
/
