--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AS4_V_CONTATTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AS4_V_CONTATTI" ("ID_CONTATTO", "ID_RECAPITO", "DAL", "AL", "VALORE", "ID_TIPO_CONTATTO", "NOTE", "IMPORTANZA", "COMPETENZA", "COMPETENZA_ESCLUSIVA", "VERSION", "UTENTE_AGGIORNAMENTO", "DATA_AGGIORNAMENTO") AS 
  SELECT "ID_CONTATTO",
          "ID_RECAPITO",
          "DAL",
          "AL",
          "VALORE",
          "ID_TIPO_CONTATTO",
          "NOTE",
          "IMPORTANZA",
          "COMPETENZA",
          "COMPETENZA_ESCLUSIVA",
          "VERSION",
          "UTENTE_AGGIORNAMENTO",
          "DATA_AGGIORNAMENTO"
     FROM ${global.db.as4.username}.AS4_V_CONTATTI

/
