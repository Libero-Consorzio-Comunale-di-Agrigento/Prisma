--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AS4_V_RECAPITI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AS4_V_RECAPITI" ("ID_RECAPITO", "NI", "DAL", "AL", "DESCRIZIONE", "ID_TIPO_RECAPITO", "INDIRIZZO", "PROVINCIA", "COMUNE", "STATO", "CAP", "PRESSO", "IMPORTANZA", "COMPETENZA", "COMPETENZA_ESCLUSIVA", "VERSION", "UTENTE_AGGIORNAMENTO", "DATA_AGGIORNAMENTO") AS 
  SELECT "ID_RECAPITO",
          "NI",
          "DAL",
          "AL",
          "DESCRIZIONE",
          "ID_TIPO_RECAPITO",
          "INDIRIZZO",
          "PROVINCIA",
          "COMUNE",
          "STATO",
          "CAP",
          "PRESSO",
          "IMPORTANZA",
          "COMPETENZA",
          "COMPETENZA_ESCLUSIVA",
          "VERSION",
          "UTENTE_AGGIORNAMENTO",
          "DATA_AGGIORNAMENTO"
     FROM ${global.db.as4.username}.AS4_V_RECAPITI

/
