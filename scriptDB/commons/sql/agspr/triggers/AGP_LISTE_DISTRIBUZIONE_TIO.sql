--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_LISTE_DISTRIBUZIONE_TIO runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGP_LISTE_DISTRIBUZIONE_TIO
   INSTEAD OF DELETE OR INSERT OR UPDATE
   ON AGP_LISTE_DISTRIBUZIONE
   FOR EACH ROW
DECLARE
   d_codice_amm   VARCHAR2 (100);
   d_codice_aoo   VARCHAR2 (100);
   d_esiste       NUMBER := 0;
BEGIN
   IF INSERTING
   THEN
      SELECT amministrazione, aoo
        INTO d_codice_amm, d_codice_aoo
        FROM gdo_enti
       WHERE id_ente = :new.id_ente;

      BEGIN
         SELECT DISTINCT 1
           INTO d_esiste
           FROM gdm_seg_liste_distribuzione
          WHERE     codice_amministrazione = d_codice_amm
                AND codice_aoo = d_codice_aoo
                AND CODICE_LISTA_DISTRIBUZIONE = :NEW.CODICE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF d_esiste = 1
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
               'Lista di distribuzione '''
            || :NEW.CODICE
            || ''' gia'' presente.');
      END IF;

      d_esiste := 0;

      BEGIN
         SELECT DISTINCT 1
           INTO d_esiste
           FROM gdm_SEG_LISTE_DISTRIBUZIONE
          WHERE     codice_amministrazione = d_codice_amm
                AND codice_aoo = d_codice_aoo
                AND LOWER (DES_LISTA_DISTRIBUZIONE) =
                       LOWER (:NEW.DESCRIZIONE);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF d_esiste = 1
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
               'Lista di distribuzione '''
            || :NEW.DESCRIZIONE
            || ''' gia'' presente.');
      END IF;

      DECLARE
         RetVal   NUMBER;
      BEGIN
         RetVal :=
            GDM_LISTE_DIST_UTILITY.CREA (:NEW.CODICE,
                                         :NEW.DESCRIZIONE,
                                         /*:NEW.VALIDO_DAL,
                                         :NEW.VALIDO_AL,*/
                                         d_codice_amm,
                                         d_codice_aoo,
                                         :NEW.UTENTE_ins);
      END;
   END IF;

   IF UPDATING
   THEN
      IF NVL (:NEW.VALIDO, '*') != NVL (:OLD.VALIDO, '*')
      THEN
         IF NVL (:NEW.VALIDO, '*') = 'N'
         THEN
            DECLARE
               ret   NUMBER;
            BEGIN
               ret :=
                  gdm_profilo.cancella (:old.ID_DOCUMENTO_ESTERNO,
                                        :old.utente_upd);
            END;
         ELSE
            DECLARE
               ret   NUMBER;
            BEGIN
               ret :=
                  gdm_profilo.cambia_stato (:old.ID_DOCUMENTO_ESTERNO,
                                            :old.utente_upd,
                                            'BO');
            END;
         END IF;
      ELSE
         UPDATE gdm_SEG_LISTE_DISTRIBUZIONE
            SET DES_LISTA_DISTRIBUZIONE = :NEW.DESCRIZIONE
          WHERE ID_DOCUMENTO = :OLD.ID_DOCUMENTO_ESTERNO;

         UPDATE GDM_DOCUMENTI
            SET DATA_AGGIORNAMENTO = SYSDATE,
                UTENTE_AGGIORNAMENTO = :NEW.UTENTE_UPD
          WHERE ID_DOCUMENTO = :OLD.ID_DOCUMENTO_ESTERNO;
      END IF;
   END IF;

   IF DELETING
   THEN
      DECLARE
         ret   NUMBER;
      BEGIN
         ret :=
            gdm_profilo.cancella (:old.ID_DOCUMENTO_ESTERNO, :old.utente_upd);
      END;
   END IF;
END;
/
