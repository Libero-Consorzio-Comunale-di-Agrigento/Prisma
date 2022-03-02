--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AGSPR_PRIN_DATI_INTEROP_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGSPR_PRIN_DATI_INTEROP_TIU
   BEFORE INSERT OR UPDATE
   ON SPR_PROTOCOLLI_INTERO
   FOR EACH ROW
DECLARE
   d_utente_agg   VARCHAR2 (100);
BEGIN
   IF    NVL (:new.INVIATA_CONF_RIC, ' ') <> NVL (:old.INVIATA_CONF_RIC, ' ')
      OR NVL (:new.REG_ACCETTAZIONE_CONFERMA, ' ') <>
            NVL (:old.REG_ACCETTAZIONE_CONFERMA, ' ')
   THEN
      BEGIN
         SELECT utente_aggiornamento
           INTO d_utente_agg
           FROM documenti
          WHERE id_documento = :new.id_documento;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_utente_agg := 'RPI';
      END;

      IF NVL (:new.INVIATA_CONF_RIC, ' ') <> NVL (:old.INVIATA_CONF_RIC, ' ')
      THEN
         AGSPR_PROTO_DATI_INTEROP_PKG.set_inviata_conferma_ricezione (
            :new.id_documento,
            :new.inviata_conf_ric,
            d_utente_agg);
      END IF;

      IF NVL (:new.REG_ACCETTAZIONE_CONFERMA, ' ') <>
            NVL (:old.REG_ACCETTAZIONE_CONFERMA, ' ')
      THEN
         AGSPR_PROTO_DATI_INTEROP_PKG.set_ric_accettazione_conferma (
            :new.id_documento,
            :new.REG_ACCETTAZIONE_CONFERMA,
            d_utente_agg);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
