--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_SO4_V_UNITA runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SO4_V_UNITA" ("PROGR", "AMMINISTRAZIONE", "CODICE", "DESCRIZIONE", "DAL", "OTTICA", "AL", "INDIRIZZO", "CAP", "PROVINCIA", "COMUNE", "TELEFONO", "FAX") AS 
  SELECT progr_unita_organizzativa,
       amministrazione,
       codice_UO CODICE,
       descrizione,
       dal,
       ottica,
       al,
       indirizzo,
       cap,
       provincia,
       comune,
       telefono,
       fax
  FROM SO4_AUOR
/
