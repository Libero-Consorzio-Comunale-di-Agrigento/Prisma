--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AS4_V_TIPI_RECAPITO runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AS4_V_TIPI_RECAPITO" ("ID_TIPO_RECAPITO", "DESCRIZIONE", "UNICO", "IMPORTANZA", "VERSION", "UTENTE_AGGIORNAMENTO", "DATA_AGGIORNAMENTO") AS 
  SELECT "ID_TIPO_RECAPITO",
          "DESCRIZIONE",
          "UNICO",
          "IMPORTANZA",
          "VERSION",
          "UTENTE_AGGIORNAMENTO",
          "DATA_AGGIORNAMENTO"
     FROM ${global.db.as4.username}.AS4_V_TIPI_RECAPITO

/
