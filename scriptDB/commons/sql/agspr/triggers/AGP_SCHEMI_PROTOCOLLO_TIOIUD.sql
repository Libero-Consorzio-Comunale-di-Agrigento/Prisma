--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_SCHEMI_PROTOCOLLO_TIOIUD runOnChange:true stripComments:false

CREATE OR REPLACE TRIGGER AGP_SCHEMI_PROTOCOLLO_TIOIUD
/******************************************************************************
          NOME:        AGP_SCHEMI_PROTOCOLLO_TIOIUD
          DESCRIZIONE: Trigger instead of INSERT or UPDATE or DELETE on View AGP_SCHEMI_PROTOCOLLO
                       per l'allineamento con SO4.COMPETENZE_DELEGA
          ANNOTAZIONI: -
          REVISIONI:
          Rev. Data       Autore       Descrizione
          ---- ---------- ------      ------------------------------------------------------
             0 19/12/2017 MMalferrari  Creazione.
         ******************************************************************************/
   INSTEAD OF INSERT OR UPDATE OR DELETE
   ON AGP_SCHEMI_PROTOCOLLO
   FOR EACH ROW
DECLARE
   d_id_applicativo   NUMBER;
   d_modulo           VARCHAR2 (10) := 'AGSPR';
BEGIN
   IF INSERTING
   THEN
      DECLARE
         d_dataval_al   DATE := NULL;
      BEGIN
         d_dataval_al := :new.valido_al;

         IF NVL (:new.valido, 'Y') = 'N' AND NVL (:old.valido, 'Y') = 'Y'
         THEN
            d_dataval_al := SYSDATE;
         END IF;

         IF NVL (:new.valido, 'Y') = 'Y' AND NVL (:old.valido, 'Y') = 'N'
         THEN
            d_dataval_al := NULL;
         END IF;

         FOR app
            IN (SELECT id_applicativo
                  FROM so4_applicativi appl, ad4_istanze ista
                 WHERE     modulo = d_modulo
                       AND ista.user_oracle = USER
                       AND appl.istanza = ista.istanza)
         LOOP
            so4_competenze_delega_tpk.ins (NULL,
                                           :new.codice,
                                           :new.descrizione,
                                           app.id_applicativo,
                                           d_dataval_al);
         END LOOP;
      END;
   END IF;

   IF UPDATING
   THEN
      FOR code
         IN (SELECT id_competenza_delega
               FROM so4_competenze_delega code,
                    ad4_istanze ista,
                    so4_applicativi appl
              WHERE     appl.modulo = d_modulo
                    AND ista.user_oracle = USER
                    AND appl.istanza = ista.istanza
                    AND code.id_applicativo = appl.id_applicativo
                    AND code.codice = :new.codice)
      LOOP
         so4_competenze_delega_tpk.upd (
            p_check_old                  => 0,
            p_new_id_competenza_delega   => code.id_competenza_delega,
            p_new_codice                 => :new.codice,
            p_new_descrizione            => :new.descrizione,
            p_new_fine_validita          => :new.valido_al);
      END LOOP;
   END IF;

   IF DELETING
   THEN
      FOR code
         IN (SELECT id_competenza_delega
               FROM so4_competenze_delega code,
                    ad4_istanze ista,
                    so4_applicativi appl
              WHERE     appl.modulo = d_modulo
                    AND ista.user_oracle = USER
                    AND appl.istanza = ista.istanza
                    AND code.id_applicativo = appl.id_applicativo
                    AND code.codice = :new.codice)
      LOOP
         so4_competenze_delega_tpk.del (0, code.id_competenza_delega);
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
