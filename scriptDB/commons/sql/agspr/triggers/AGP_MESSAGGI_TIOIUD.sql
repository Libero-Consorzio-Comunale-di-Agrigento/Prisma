--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_MESSAGGI_TIOIUD runOnChange:true stripComments:false

CREATE OR REPLACE TRIGGER AGP_MESSAGGI_TIOIUD
   /******************************************************************************
              NOME:        AGP_MESSAGGI_TIOIUD
              DESCRIZIONE: Trigger instead of INSERT or UPDATE or DELETE on View
                           AGP_MESSAGGI
              ANNOTAZIONI: -
              REVISIONI:
              Rev. Data       Autore       Descrizione
              ---- ---------- -----------  -----------------------------------------------
                 0 11/06/2019 MMalferrari  Creazione.
             ******************************************************************************/
   INSTEAD OF INSERT OR UPDATE OR DELETE
   ON AGP_MESSAGGI
   FOR EACH ROW
DECLARE
   d_id   NUMBER;
BEGIN
   IF INSERTING
   THEN
      d_id :=
         gdm_ag_memo_utility.crea_in_partenza (:new.mittente,
                                               :new.destinatari,
                                               :new.destinatari_conoscenza,
                                               :new.destinatari_nascosti,
                                               :new.oggetto,
                                               :new.corpo,
                                               :new.utente_ins);
   END IF;

   IF UPDATING
   THEN
      DECLARE
         d_class_cod          VARCHAR2 (100);
         d_class_dal          DATE;
         d_fascicolo_anno     NUMBER;
         d_fascicolo_numero   VARCHAR2 (100);
      BEGIN
         IF :new.id_classificazione IS NOT NULL
         THEN
            SELECT classificazione, classificazione_dal
              INTO d_class_cod, d_class_dal
              FROM ags_classificazioni
             WHERE id_classificazione = :new.id_classificazione;

            IF :new.id_fascicolo IS NOT NULL
            THEN
               SELECT anno, numero
                 INTO d_fascicolo_anno, d_fascicolo_numero
                 FROM ags_fascicoli
                WHERE id_documento = :new.id_fascicolo;
            END IF;
         END IF;

         gdm_ag_memo_utility.aggiorna (:new.id_documento_esterno,
                                       :new.mittente,
                                       :new.destinatari,
                                       :new.destinatari_conoscenza,
                                       :new.destinatari_nascosti,
                                       :new.oggetto,
                                       :new.corpo,
                                       :new.data_ricezione,
                                       :new.in_partenza,
                                       :new.message_id,
                                       :new.motivo_no_proc,
                                       NULL,
                                       :new.stato_memo,
                                       :new.data_stato_memo,
                                       :new.data_spedizione_memo,
                                       d_class_cod,
                                       d_class_dal,
                                       :new.destinatari_ente,
                                       :new.destinatari_conoscenza_ente,
                                       d_fascicolo_anno,
                                       d_fascicolo_numero,
                                       :new.idrif,
                                       :new.riservato,
                                       :new.tipo_messaggio,
                                       :new.tipo_corpo,
                                       :new.tagmail_invio,
                                       :new.spedito,
                                       :new.generata_eccezione,
                                       :new.registrata_accettazione,
                                       :new.registrata_non_accettazione,
                                       :new.unita,
                                       :new.utente_upd);
      END;
   END IF;

   IF DELETING
   THEN
      gdm_ag_memo_utility.cancella (:old.id_documento_esterno,
                                    :old.utente_upd);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
