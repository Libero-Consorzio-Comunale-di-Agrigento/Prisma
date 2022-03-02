--liquibase formatted sql
--changeset rdestasio:181.inserisci_id_doc_padre runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_sistema_id_padre
IS
   d_conta   NUMBER := 0;
BEGIN
   FOR alle
      IN (SELECT alpr.id_documento, p.id_documento id_documento_padre
            FROM seg_allegati_protocollo alpr, documenti d, proto_view p
           WHERE     d.id_documento = alpr.id_documento
                 AND d.stato_documento = 'BO'
                 AND d.id_documento_padre IS NULL
                 AND p.idrif = alpr.idrif)
   LOOP
      UPDATE documenti
         SET id_documento_padre = alle.id_documento_padre
       WHERE id_documento = alle.id_documento;

      d_conta := d_conta + 1;

      IF d_conta = 100
      THEN
         d_conta := 0;
         COMMIT;
      END IF;
   END LOOP;

   COMMIT;
END;
/
