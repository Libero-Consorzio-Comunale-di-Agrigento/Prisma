--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_157_upd_agp_schemi_prot_categorie

BEGIN
   FOR TP
      IN (  SELECT ID_SCHEMA_PROTOCOLLO,
                   CATEGORIA,
                   MIN (ID_TIPO_PROTOCOLLO) ID_TIPO_PROTOCOLLO
              FROM agp_tipi_protocollo
             WHERE id_schema_protocollo IS NOT NULL
            HAVING COUNT (1) = 1
          GROUP BY ID_SCHEMA_PROTOCOLLO, CATEGORIA)
   LOOP
      INSERT INTO AGP_SCHEMI_PROT_CATEGORIE (ID_SCHEMA_PROT_CATEGORIA,
                                             ID_SCHEMA_PROTOCOLLO,
                                             CATEGORIA,
                                             ID_TIPO_PROTOCOLLO,
                                             VERSION,
                                             VALIDO,
                                             UTENTE_INS,
                                             DATA_INS,
                                             UTENTE_UPD,
                                             DATA_UPD,
                                             MODIFICABILE)
         SELECT hibernate_sequence.NEXTVAL,
                tp.ID_SCHEMA_PROTOCOLLO,
                tp.CATEGORIA,
                tp.ID_TIPO_PROTOCOLLO,
                0,
                'Y',
                'RPI',
                SYSDATE,
                'RPI',
                SYSDATE,
                'N'
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM AGP_SCHEMI_PROT_CATEGORIE
                     WHERE     ID_SCHEMA_PROTOCOLLO = tp.ID_SCHEMA_PROTOCOLLO
                           AND CATEGORIA = tp.CATEGORIA
                           AND ID_TIPO_PROTOCOLLO = tp.ID_TIPO_PROTOCOLLO);
   END LOOP;

   FOR TP
      IN (SELECT ID_SCHEMA_PROTOCOLLO, CATEGORIA, ID_TIPO_PROTOCOLLO
            FROM agp_tipi_protocollo
           WHERE (ID_SCHEMA_PROTOCOLLO, CATEGORIA) IN (  SELECT ID_SCHEMA_PROTOCOLLO,
                                                                CATEGORIA
                                                           FROM agp_tipi_protocollo
                                                          WHERE id_schema_protocollo
                                                                   IS NOT NULL
                                                         HAVING COUNT (1) > 1
                                                       GROUP BY ID_SCHEMA_PROTOCOLLO,
                                                                CATEGORIA))
   LOOP
      INSERT INTO AGP_SCHEMI_PROT_CATEGORIE (ID_SCHEMA_PROT_CATEGORIA,
                                             ID_SCHEMA_PROTOCOLLO,
                                             CATEGORIA,
                                             ID_TIPO_PROTOCOLLO,
                                             VERSION,
                                             VALIDO,
                                             UTENTE_INS,
                                             DATA_INS,
                                             UTENTE_UPD,
                                             DATA_UPD,
                                             MODIFICABILE)
         SELECT hibernate_sequence.NEXTVAL,
                tp.ID_SCHEMA_PROTOCOLLO,
                tp.CATEGORIA,
                tp.ID_TIPO_PROTOCOLLO,
                0,
                'Y',
                'RPI',
                SYSDATE,
                'RPI',
                SYSDATE,
                'Y'
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM AGP_SCHEMI_PROT_CATEGORIE
                     WHERE     ID_SCHEMA_PROTOCOLLO = tp.ID_SCHEMA_PROTOCOLLO
                           AND CATEGORIA = tp.CATEGORIA
                           AND ID_TIPO_PROTOCOLLO = tp.ID_TIPO_PROTOCOLLO);           
   END LOOP;
   
   update agp_tipi_protocollo
      set ID_SCHEMA_PROTOCOLLO = null
    where ID_SCHEMA_PROTOCOLLO is not null;

   COMMIT;
END;
/