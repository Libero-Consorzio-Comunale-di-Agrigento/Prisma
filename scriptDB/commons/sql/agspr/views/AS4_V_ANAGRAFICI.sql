--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AS4_V_ANAGRAFICI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AS4_V_ANAGRAFICI" ("ID_ANAGRAFICA", "NI", "DAL", "AL", "COGNOME", "NOME", "SESSO", "DATA_NAS", "PROVINCIA_NAS", "COMUNE_NAS", "STATO_NAS", "LUOGO_NAS", "CODICE_FISCALE", "CODICE_FISCALE_ESTERO", "PARTITA_IVA", "CITTADINANZA", "GRUPPO_LING", "COMPETENZA", "COMPETENZA_ESCLUSIVA", "TIPO_SOGGETTO", "STATO_CEE", "PARTITA_IVA_CEE", "FINE_VALIDITA", "STATO_SOGGETTO", "DENOMINAZIONE", "NOTE", "VERSION", "UTENTE", "DATA_AGG", "DENOMINAZIONE_RICERCA") AS 
  SELECT "ID_ANAGRAFICA",
          "NI",
          "DAL",
          "AL",
          "COGNOME",
          "NOME",
          "SESSO",
          "DATA_NAS",
          "PROVINCIA_NAS",
          "COMUNE_NAS",
          "STATO_NAS",
          "LUOGO_NAS",
          "CODICE_FISCALE",
          "CODICE_FISCALE_ESTERO",
          "PARTITA_IVA",
          "CITTADINANZA",
          "GRUPPO_LING",
          "COMPETENZA",
          "COMPETENZA_ESCLUSIVA",
          "TIPO_SOGGETTO",
          "STATO_CEE",
          "PARTITA_IVA_CEE",
          "FINE_VALIDITA",
          "STATO_SOGGETTO",
          "DENOMINAZIONE",
          "NOTE",
          "VERSION",
          "UTENTE",
          "DATA_AGG",
          "DENOMINAZIONE_RICERCA"
     FROM ${global.db.as4.username}.AS4_V_ANAGRAFICI

/
