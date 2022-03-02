--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_SO4_V_AOO runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SO4_V_AOO" ("PROGR_AOO", "AMMINISTRAZIONE", "CODICE", "DESCRIZIONE", "ABBREVIAZIONE", "INDIRIZZO", "CAP", "PROVINCIA", "COMUNE", "TELEFONO", "FAX", "UTENTE_AGGIORNAMENTO", "DATA_AGGIORNAMENTO", "DAL", "AL") AS 
  SELECT progr_aoo,
          codice_amministrazione amministrazione,
          codice_aoo codice,
          descrizione,
          des_abb abbreviazione,
          indirizzo,
          cap,
          provincia,
          comune,
          telefono,
          fax,
          utente_aggiornamento,
          data_aggiornamento,
          dal,
          al
     FROM SO4_AOO

/
