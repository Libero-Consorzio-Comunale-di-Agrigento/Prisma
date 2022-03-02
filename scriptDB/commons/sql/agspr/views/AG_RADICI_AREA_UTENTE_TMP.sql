--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AG_RADICI_AREA_UTENTE_TMP runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AG_RADICI_AREA_UTENTE_TMP" ("UTENTE", "UNITA_RADICE_AREA", "PRIVILEGIO", "PROGR_UNITA") AS 
  select "UTENTE","UNITA_RADICE_AREA","PRIVILEGIO","PROGR_UNITA" from ${global.db.gdm.username}.AG_RADICI_AREA_UTENTE_TMP
/
