--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_OGGETTI_RICORRENTI_TIO runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGP_OGGETTI_RICORRENTI_TIO
   INSTEAD OF DELETE OR INSERT OR UPDATE
   ON AGP_OGGETTI_RICORRENTI
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
           FROM gdm_seg_tipi_frase
          WHERE     codice_amministrazione = d_codice_amm
                AND codice_aoo = d_codice_aoo
                AND TIPO_FRASE = :NEW.CODICE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF d_esiste = 1
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
            'Oggetto ricorrente ''' || :NEW.CODICE || ''' gia'' presente.');
      END IF;

      DECLARE
         RetVal   NUMBER;
      BEGIN
         RetVal :=
            GDM_TIPI_FRASE_UTILITY.CREA (:NEW.CODICE,
                                         :NEW.OGGETTO,
                                         /*:NEW.VALIDO_DAL,
                                         :NEW.VALIDO_AL,*/
                                         d_codice_amm,
                                         d_codice_aoo,
                                         :NEW.UTENTE_ins);
      END;
   END IF;

   IF UPDATING
   THEN
      --raise_application_error(-20999, 'nvl(:NEW.VALIDO, ''*'') '||nvl(:NEW.VALIDO, '*'));
      --raise_application_error(-20999, 'nvl(:OLD.VALIDO, ''*'') '||nvl(:OLD.VALIDO, '*'));
      IF NVL (:NEW.VALIDO, '*') != NVL (:OLD.VALIDO, '*')
      THEN
         IF NVL (:NEW.VALIDO, '*') = 'N'
         THEN
            DECLARE
               ret   NUMBER;
            BEGIN
               ret :=
                  gdm_profilo.cancella (:old.id_documento_esterno,
                                        :old.utente_upd);
            END;
         ELSE
            DECLARE
               ret   NUMBER;
            BEGIN
               ret :=
                  gdm_profilo.cambia_stato (:old.id_documento_esterno,
                                            :old.utente_upd,
                                            'BO');
            END;
         END IF;
      ELSE
         UPDATE gdm_seg_tipi_frase
            SET oggetto = :NEW.oggetto
          WHERE ID_DOCUMENTO = -:OLD.ID_OGGETTO_RICORRENTE;

         UPDATE GDM_DOCUMENTI
            SET DATA_AGGIORNAMENTO = SYSDATE,
                UTENTE_AGGIORNAMENTO = :NEW.UTENTE_UPD
          WHERE ID_DOCUMENTO = -:OLD.ID_OGGETTO_RICORRENTE;
      END IF;
   END IF;

   IF DELETING
   THEN
      DECLARE
         ret   NUMBER;
      BEGIN
         /*if gdm_tipi_frase_utility.IS_ELIMINABILE(:old.id_documento_esterno) = 1 then  */
         ret :=
            gdm_profilo.cancella (:old.id_documento_esterno, :old.utente_upd);
      /*else
          raise_application_error(-20999, 'Oggetto ricorrente non eliminabile perchè utilizzato.');
      end if;*/
      END;
   END IF;
END;
/
