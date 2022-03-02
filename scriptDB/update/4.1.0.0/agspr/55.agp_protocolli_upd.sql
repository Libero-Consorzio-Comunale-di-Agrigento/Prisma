--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201020_55.agp_protocolli_upd

BEGIN
   FOR l
      IN (SELECT data_ins, p.id_documento
            FROM gdo_documenti d, agp_protocolli p, agp_tipi_protocollo t
           WHERE     T.CATEGORIA = 'LETTERA'
                 AND P.ID_TIPO_PROTOCOLLO = P.ID_TIPO_PROTOCOLLO
                 AND d.id_documento = P.ID_DOCUMENTO
                 AND p.data_redazione IS NULL)
   LOOP
      UPDATE agp_protocolli
         SET data_redazione = l.data_ins
       WHERE id_documento = l.id_documento;
   END LOOP;
   commit;
END;
/