--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SEG_FASCICOLI_AU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SEG_FASCICOLI_AU
   BEFORE UPDATE
   ON SEG_FASCICOLI    FOR EACH ROW
DECLARE
   d_in_error   NUMBER := 0;
BEGIN
   IF AG_PARAMETRO.GET_VALORE ('CONF_SCAN_FLUSSO_1', '@agVar@') IS NOT NULL
   THEN
      IF :old.data_chiusura IS NOT NULL AND :new.data_chiusura IS NULL
      THEN
         DELETE riferimenti
          WHERE     tipo_relazione = 'PROT_FATCO'
                AND id_documento = :new.id_documento;
      END IF;

      IF :old.stato_fascicolo = 1 AND :new.stato_fascicolo <> 1
      THEN
         DECLARE
            d_num_att_conf   NUMBER;
         BEGIN
            SELECT p.numero
              INTO d_num_att_conf
              FROM riferimenti r, proto_view p
             WHERE     tipo_relazione = 'PROT_FATCO'
                   AND r.id_documento = :new.id_documento
                   AND p.id_documento = r.id_documento_rif;

            IF d_num_att_conf IS NULL
            THEN
               SELECT COUNT (1)
                 INTO d_in_error
                 FROM proto_view
                WHERE     class_cod = :new.class_cod
                      AND class_dal = :new.class_dal
                      AND fascicolo_anno = :new.fascicolo_anno
                      AND fascicolo_numero = :new.fascicolo_numero
                      AND documento_tramite =
                             AG_PARAMETRO.GET_VALORE ('CONF_SCAN_TRAMITE_1',
                                                      '@agVar@');
            ELSE
               d_in_error := 0;
            END IF;


         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_in_error := 0;
         END;

         IF d_in_error > 0
         THEN
            raise_application_error (
               -20999,
               'prima di modificare lo stato del fascicolo, deve essere terminato il flusso di attestazione di conformita''.');
         END IF;
      END IF;
   END IF;
END;
/
