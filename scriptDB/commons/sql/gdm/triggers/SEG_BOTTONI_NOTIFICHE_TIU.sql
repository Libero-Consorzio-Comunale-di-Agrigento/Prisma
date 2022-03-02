--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_SEG_BOTTONI_NOTIFICHE_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER SEG_BOTTONI_NOTIFICHE_TIU
BEFORE INSERT OR UPDATE
ON SEG_BOTTONI_NOTIFICHE
FOR EACH ROW
DECLARE
   a_messaggio       VARCHAR2 (32000);
   a_istruzione      VARCHAR2 (32000);
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            VARCHAR2 (200);
/******************************************************************************
   NAME:       seg_bottoni_notifiche_TIU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/12/2017  SC           1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_CLAS_TIU
      Sysdate:         17/02/2009
      Date and Time:   17/02/2009, 16.23.00, and 17/02/2009 16.23.00
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      SEG_CLASSIFICAZIONI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
DEP_ID NUMBER;
DEP_SEQUENZA NUMBER;
BEGIN
   IF INSERTING
   THEN

      SELECT nvl(MAX(ID), 0) + 1
        INTO DEP_ID
        FROM seg_bottoni_notifiche
      ;
      :NEW.ID := DEP_ID;

      IF :NEW.SEQUENZA IS NULL THEN
          SELECT NVL(MAX(sequenza), 0) + 10
            INTO dep_sequenza
            FROM seg_bottoni_notifiche
          ;
          :NEW.SEQUENZA := DEP_SEQUENZA;
      END IF;

      IF :NEW.UTENTE_INS IS NULL
      THEN
         :NEW.UTENTE_INS := NVL(SI4.UTENTE, 'RPI');
      END IF;
      IF :NEW.UTENTE_UPD IS NULL
      THEN
         :NEW.UTENTE_UPD := NVL(SI4.UTENTE, 'RPI');
      END IF;

      IF :NEW.DATA_INS IS NULL
      THEN
         :NEW.DATA_INS := SYSDATE;
      END IF;
      IF :NEW.DATA_UPD IS NULL
      THEN
         :NEW.DATA_UPD := SYSDATE;
      END IF;

      IF :NEW.VERSION IS NULL
      THEN
         :NEW.VERSION := 1;
      END IF;

      IF :NEW.CODICE_AMMINISTRAZIONE IS NULL
      THEN
        declare
            c_defammaoo afc.t_ref_cursor;
            d_cod_amm varchar2(100);
            d_cod_aoo varchar2(100);
        begin
            c_defammaoo := ag_utilities.get_default_ammaoo ();

             IF c_defammaoo%ISOPEN
             THEN
                LOOP
                   FETCH c_defammaoo INTO d_cod_amm, d_cod_aoo;

                   EXIT WHEN c_defammaoo%NOTFOUND;
                END LOOP;
             END IF;
             :NEW.CODICE_AMMINISTRAZIONE := d_cod_amm;
             :NEW.CODICE_AOO :=  d_cod_aoo;
        end;

      END IF;

   END IF;

   IF UPDATING
   THEN
      IF :NEW.UTENTE_UPD IS NULL
      THEN
         :NEW.UTENTE_UPD := NVL(SI4.UTENTE, 'RPI');
      END IF;

      IF :NEW.DATA_UPD IS NULL
      THEN
         :NEW.DATA_UPD := SYSDATE;
      END IF;

      IF :NEW.VERSION IS NULL
      THEN
         :NEW.VERSION := :OLD.VERSION+1;
      END IF;
   END IF;

END seg_bottoni_notifiche_TIU;
/
