--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_TIPI_DOCUMENTO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER GDO_TIPI_DOCUMENTO_TIU
   BEFORE DELETE OR INSERT OR UPDATE
   ON GDO_TIPI_DOCUMENTO
   FOR EACH ROW
BEGIN
   IF INSERTING
   THEN
      IF :NEW.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'L''inserimento di nuovi tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;

   IF UPDATING
   THEN
      IF :OLD.ID_TIPO_DOCUMENTO < 0 AND :OLD.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'L''aggiornamento dei tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;

   IF DELETING
   THEN
      IF :OLD.ID_TIPO_DOCUMENTO < 0 AND :OLD.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'La cancellazione dei tipi di allegato va effettuata dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;
END;
/
