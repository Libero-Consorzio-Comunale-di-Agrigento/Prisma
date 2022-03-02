--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20201013_6.gdo_file_documento_upd
DECLARE
   d_id_doc   NUMBER := 0;
   d_seq      NUMBER := 0;
BEGIN
   FOR d
      IN (  SELECT *
              FROM gdo_file_documento
             WHERE id_documento IN (  SELECT id_documento
                                        FROM gdo_file_documento
                                       WHERE     sequenza = 0
                                      HAVING COUNT (1) > 1
                                    GROUP BY id_documento)
          ORDER BY id_documento DESC, id_file_documento)
   LOOP
      IF d_id_doc = d.id_documento
      THEN
         d_seq := d_seq + 1;
      ELSE
         d_seq := 0;
      END IF;

      UPDATE gdo_file_documento
         SET sequenza = d_seq
       WHERE id_file_documento = d.id_file_documento;

      d_id_doc := d.id_documento;
   END LOOP;
   commit;
END;
/
