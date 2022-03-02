--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_TIPI_SOGGETTO runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_TIPI_SOGGETTO" ("TIPO_SOGGETTO", "DESCRIZIONE", "SEQUENZA") AS 
  SELECT "TIPO_SOGGETTO", "DESCRIZIONE", "SEQUENZA"
     FROM gdm_ag_tipi_soggetto
/
