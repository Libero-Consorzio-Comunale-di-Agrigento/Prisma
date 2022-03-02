--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AS4_V_SOGGETTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AS4_V_SOGGETTI" ("NI", "DAL", "COGNOME", "NOME", "NOMINATIVO_RICERCA", "SESSO", "DATA_NAS", "PROVINCIA_NAS", "COMUNE_NAS", "STATO_NAS", "LUOGO_NAS", "CODICE_FISCALE", "CODICE_FISCALE_ESTERO", "PARTITA_IVA", "CITTADINANZA", "GRUPPO_LING", "INDIRIZZO_RES", "PROVINCIA_RES", "COMUNE_RES", "STATO_RES", "CAP_RES", "TEL_RES", "FAX_RES", "PRESSO", "INDIRIZZO_DOM", "PROVINCIA_DOM", "COMUNE_DOM", "STATO_DOM", "CAP_DOM", "TEL_DOM", "FAX_DOM", "UTENTE_AGG", "DATA_AGG", "COMPETENZA", "COMPETENZA_ESCLUSIVA", "TIPO_SOGGETTO", "FLAG_TRG", "STATO_CEE", "PARTITA_IVA_CEE", "FINE_VALIDITA", "AL", "DENOMINAZIONE", "INDIRIZZO_WEB", "NOTE", "UTENTE") AS 
  SELECT "NI",
          "DAL",
          "COGNOME",
          "NOME",
          "NOMINATIVO_RICERCA",
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
          "INDIRIZZO_RES",
          "PROVINCIA_RES",
          "COMUNE_RES",
          "STATO_RES",
          "CAP_RES",
          "TEL_RES",
          "FAX_RES",
          "PRESSO",
          "INDIRIZZO_DOM",
          "PROVINCIA_DOM",
          "COMUNE_DOM",
          "STATO_DOM",
          "CAP_DOM",
          "TEL_DOM",
          "FAX_DOM",
          "UTENTE_AGG",
          "DATA_AGG",
          "COMPETENZA",
          "COMPETENZA_ESCLUSIVA",
          "TIPO_SOGGETTO",
          "FLAG_TRG",
          "STATO_CEE",
          "PARTITA_IVA_CEE",
          "FINE_VALIDITA",
          "AL",
          "DENOMINAZIONE",
          "INDIRIZZO_WEB",
          "NOTE",
          "UTENTE"
     FROM ${global.db.as4.username}.AS4_V_SOGGETTI

/
