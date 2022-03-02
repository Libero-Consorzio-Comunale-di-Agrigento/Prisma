--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_CATEGORIE_MODELLO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_CATEGORIE_MODELLO_TIU
   BEFORE INSERT OR UPDATE
   ON CATEGORIE_MODELLO
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
BEGIN
   IF :NEW.CATEGORIA = 'PROTO'
   THEN
      INSERT INTO TIPI_RELAZIONE (AREA,
                                  TIPO_RELAZIONE,
                                  DESCRIZIONE,
                                  VISIBILE,
                                  DIPENDENZA,
                                  DATA_AGGIORNAMENTO,
                                  UTENTE_AGGIORNAMENTO)
         SELECT :NEW.AREA,
                'PROT_PREC',
                'Precedente/Seguente',
                'S',
                'N',
                SYSDATE,
                'RPI'
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM TIPI_RELAZIONE
                     WHERE AREA = :NEW.AREA AND TIPO_RELAZIONE = 'PROT_PREC');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- CONSIDER LOGGING THE ERROR AND THEN RE-RAISE
      RAISE;
END;
/
