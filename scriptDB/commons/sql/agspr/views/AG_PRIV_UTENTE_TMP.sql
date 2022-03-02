--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AG_PRIV_UTENTE_TMP runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AG_PRIV_UTENTE_TMP" ("UTENTE", "UNITA", "RUOLO", "PRIVILEGIO", "APPARTENENZA", "DAL", "AL", "PROGR_UNITA", "IS_ULTIMA_CHIUSA") AS 
  select "UTENTE","UNITA","RUOLO","PRIVILEGIO","APPARTENENZA","DAL","AL","PROGR_UNITA","IS_ULTIMA_CHIUSA" from ${global.db.gdm.username}.AG_PRIV_UTENTE_TMP
/
