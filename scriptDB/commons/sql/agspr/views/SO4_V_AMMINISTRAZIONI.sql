--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_SO4_V_AMMINISTRAZIONI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SO4_V_AMMINISTRAZIONI" ("CODICE", "ENTE", "DATA_ISTITUZIONE", "DATA_SOPPRESSIONE", "ID_SOGGETTO") AS 
  SELECT codice_amministrazione AS codice,
          DECODE (ente, 'SI', 1, 0) AS ente,
          data_istituzione,
          data_soppressione,
          ni AS id_soggetto
     FROM SO4_AMMINISTRAZIONI

/
