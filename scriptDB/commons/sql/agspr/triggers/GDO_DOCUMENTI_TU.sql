--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_GDO_DOCUMENTI_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER GDO_DOCUMENTI_TU
   AFTER UPDATE OF VALIDO
   ON GDO_DOCUMENTI
   FOR EACH ROW
DECLARE
   d_apri_fasc                   NUMBER := 0;
   d_esiste_altra_attestazione   NUMBER := 0;
BEGIN
   IF :NEW.VALIDO = 'N'
   THEN
      BEGIN
         SELECT -p.id_fascicolo
           INTO d_apri_fasc
           FROM agp_protocolli p, gdo_tipi_documento td
          WHERE     p.id_documento = :new.id_documento
                AND td.id_tipo_documento = p.id_tipo_protocollo
                AND td.codice =
                       GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                          'CONF_SCAN_FLUSSO',
                          :new.id_ente)
                AND p.numero IS NULL;

         UPDATE gdm_fascicoli
            SET data_chiusura = NULL, stato_fascicolo = 1
          WHERE id_documento = d_apri_fasc;
-- Bug #37705 Verificare possibili deadlock causati dall'allineamento GDM - AGSPR
-- la cancellazione del riferimento tra la lettera e il fascicolo è già gestita da trigger di GDM
--         DELETE gdm_riferimenti
--          WHERE     tipo_relazione = 'PROT_FATCO'
--                AND id_documento = :new.id_documento_esterno;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
