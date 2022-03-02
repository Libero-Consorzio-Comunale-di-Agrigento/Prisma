--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_TIPI_PROTOCOLLO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER agp_tipi_protocollo_tiu
   BEFORE INSERT OR UPDATE
   ON agp_tipi_protocollo
   FOR EACH ROW
BEGIN
   IF :new.predefinito = 'Y'
   THEN
      IF :new.categoria = 'PEC'
      THEN
         UPDATE gdm_parametri
            SET valore = :new.id_tipo_protocollo
          WHERE codice = 'INTEROP_SCARICO_FLUSSO_1';
      END IF;
      IF :new.categoria = 'PROTOCOLLO'
      THEN
         UPDATE gdm_parametri
            SET valore = :new.id_tipo_protocollo
          WHERE codice = 'WS_DOCAREA_FLUSSO_1';
      END IF;
   END IF;
END;
/
