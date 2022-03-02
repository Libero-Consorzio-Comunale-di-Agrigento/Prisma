--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_IMPOSTAZIONI_TIO runOnChange:true stripComments:false

CREATE OR REPLACE TRIGGER GDO_IMPOSTAZIONI_TIO
   INSTEAD OF DELETE OR INSERT OR UPDATE
   ON GDO_IMPOSTAZIONI
   FOR EACH ROW
BEGIN
   IF INSERTING
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
         'L''inserimento di nuove impostazioni va effettuato dalla tabella del relativo dizionario nel documentale.');
   END IF;

   IF UPDATING
   THEN
      IF :new.codice = 'MOD_SPED_ATTIVO'
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
            'L''aggiornamento dell'' impostazione ''MOD_SPED_ATTIVO'' non e'' effettuabile.');
      END IF;

      IF :new.codice = 'URL_ANAGRAFICA'
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
            'L''aggiornamento dell'' impostazione ''URL_ANAGRAFICA'' non e'' effettuabile.');
      END IF;

      DECLARE
         d_valore   VARCHAR2 (10) := :new.valore;
      BEGIN
         IF :new.CODICE = 'SCANNER'
         THEN
            IF NVL (:new.valore, 'Y') = 'Y'
            THEN
               d_valore := 'SI';
            ELSE
               d_valore := 'NO';
            END IF;
         END IF;

         IF NVL (:OLD.valore, '*#*') <> NVL (:NEW.valore, '*#*')
         THEN
            UPDATE GDM_PARAMETRI
               SET VALORE = d_valore
             WHERE     TIPO_MODELLO = :NEW.TIPO_MODELLO_ESTERNO
                   AND CODICE = :NEW.CODICE_ESTERNO;
         END IF;
      END;
   END IF;


   IF DELETING
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
         'La cancellazione di impostazioni va effettuato dalla tabella del relativo dizionario nel documentale.');
   END IF;
END;
/
