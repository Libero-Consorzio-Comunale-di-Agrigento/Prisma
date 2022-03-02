--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_SEG_TIAL_TAIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER SEG_TIAL_TAIU
   AFTER INSERT OR UPDATE OR DELETE
   ON SEG_TIPI_ALLEGATO
   FOR EACH ROW
DECLARE
   d_id       NUMBER;
   d_utente   VARCHAR2 (100) := 'RPI';
   d_data     DATE := SYSDATE;
BEGIN
   BEGIN
      SELECT utente_aggiornamento, data_aggiornamento
        INTO d_utente, d_data
        FROM DOCUMENTI
       WHERE id_documento = :new.id_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         d_utente := 'RPI';
         d_data := SYSDATE;
   END;

   IF INSERTING
   THEN
      AGSPR_INTEGRITYPACKAGE.initNestLevel;
      AGSPR_INTEGRITYPACKAGE.NextNestLevel;
      d_id :=
         AGSPR_TIPI_ALLEGATO_PKG.ins (-:new.id_documento,
                                      :new.codice_amministrazione,
                                      :new.codice_aoo,
                                      nvl(:new.descrizione_tipo_allegato, ' '),
                                      NULL,
                                      :new.tipo_allegato,
                                      'Y',
                                      'Y',
                                      d_utente,
                                      d_data);
      AGSPR_INTEGRITYPACKAGE.initNestLevel;
   END IF;

   IF UPDATING
   THEN
      AGSPR_INTEGRITYPACKAGE.initNestLevel;
      AGSPR_INTEGRITYPACKAGE.NextNestLevel;
      AGSPR_TIPI_ALLEGATO_PKG.upd (-:new.id_documento,
                                   :new.tipo_allegato,
                                   :new.descrizione_tipo_allegato,
                                   NULL,
                                   NULL,
                                   NULL,
                                   d_utente,
                                   d_data);
      AGSPR_INTEGRITYPACKAGE.initNestLevel;
   END IF;

   IF DELETING
   THEN
      AGSPR_TIPI_ALLEGATO_PKG.del (-:OLD.id_documento);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      AGSPR_INTEGRITYPACKAGE.initNestLevel;
      RAISE;
END;
/
