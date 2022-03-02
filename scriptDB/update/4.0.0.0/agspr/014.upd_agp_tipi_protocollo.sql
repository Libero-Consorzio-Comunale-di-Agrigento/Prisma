--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_014.upd_agp_tipi_protocollo
BEGIN
   FOR tp
      IN (  SELECT categoria, MIN (id_tipo_protocollo) id_tipo_protocollo
              FROM AGP_TIPI_PROTOCOLLO tp
             WHERE NOT EXISTS
                      (SELECT 1
                         FROM AGP_TIPI_PROTOCOLLO
                        WHERE CATEGORIA = TP.CATEGORIA AND predefinito = 'Y')
          GROUP BY categoria)
   LOOP
      UPDATE AGP_TIPI_PROTOCOLLO
         SET predefinito = 'Y'
       WHERE id_tipo_protocollo = tp.id_tipo_protocollo;
   END LOOP;
   commit;
END;
/
update agp_tipi_protocollo
   set firm_obbligatorio   = 'N'
     , firm_visibile       = 'N'
     , funz_obbligatorio   = 'N'
     , funz_visibile       = 'N'
 where categoria not in ('LETTERA', 'PROVVEDIMENTO')
/
commit
/