--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AS4_V_TIPI_SOGGETTO runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AS4_V_TIPI_SOGGETTO" ("TIPO_SOGGETTO", "DESCRIZIONE", "FLAG_TRG", "CATEGORIA_TIPO_SOGGETTO") AS 
  SELECT "TIPO_SOGGETTO",
          "DESCRIZIONE",
          "FLAG_TRG",
          "CATEGORIA_TIPO_SOGGETTO"
     FROM ${global.db.as4.username}.AS4_V_TIPI_SOGGETTO

/
