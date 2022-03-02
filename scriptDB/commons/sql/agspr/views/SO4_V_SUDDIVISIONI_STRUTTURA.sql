--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_SO4_V_SUDDIVISIONI_STRUTTURA runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SO4_V_SUDDIVISIONI_STRUTTURA" ("ID_SUDDIVISIONE", "OTTICA", "CODICE", "DESCRIZIONE", "ABBREVIAZIONE", "ORDINAMENTO") AS 
  SELECT id_suddivisione,
          ottica,
          suddivisione AS codice,
          descrizione,
          des_abb AS abbreviazione,
          ordinamento
     FROM SO4_SUDDIVISIONI_STRUTTURA

/
