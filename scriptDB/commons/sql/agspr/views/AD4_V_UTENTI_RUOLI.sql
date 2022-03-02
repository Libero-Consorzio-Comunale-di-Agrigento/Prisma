--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AD4_V_UTENTI_RUOLI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AD4_V_UTENTI_RUOLI" ("UTENTE", "RUOLO", "ISTANZA") AS 
  SELECT utente, modulo || '_' || ruolo ruolo, istanza
  FROM AD4_DIRITTI_ACCESSO
 WHERE istanza = 'AGSPR'
/
