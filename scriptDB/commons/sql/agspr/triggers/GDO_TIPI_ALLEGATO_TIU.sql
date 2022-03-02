--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_TIPI_ALLEGATO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER GDO_TIPI_ALLEGATO_TIU
   BEFORE DELETE OR INSERT OR UPDATE
   ON GDO_TIPI_ALLEGATO
   FOR EACH ROW
BEGIN
   IF INTEGRITYPACKAGE.getNestLevel = 0
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
         'L''inserimento / eliminazione /aggiornamento dei tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
   END IF;
END;
/
