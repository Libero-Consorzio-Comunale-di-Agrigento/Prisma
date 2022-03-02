--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AD4_V_UTENTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AD4_V_UTENTI" ("UTENTE", "NOMINATIVO", "PASSWORD", "ENABLED", "ACCOUNT_EXPIRED", "ACCOUNT_LOCKED", "PASSWORD_EXPIRED", "TIPO_UTENTE", "NOMINATIVO_SOGGETTO", "COGNOME_SOGGETTO", "NOME_SOGGETTO", "ESISTE_SOGGETTO") AS 
  SELECT u.utente,
          u.nominativo,
          u.password,
          CAST (DECODE (u.stato, 'U', 'Y', 'N') AS CHAR (1)) enabled,
          CAST (DECODE (u.stato, 'U', 'N', 'Y') AS CHAR (1)) account_expired,
          CAST (DECODE (u.stato, 'U', 'N', 'Y') AS CHAR (1)) account_locked,
          CAST (DECODE (u.pwd_da_modificare, 'NO', 'N', 'Y') AS CHAR (1))
             password_expired,
          u.tipo_utente,
          AD4_SOGGETTO.GET_DENOMINAZIONE (
             AD4_UTENTE.GET_SOGGETTO (u.utente, 'N', 0))
             nominativo_soggetto,
          AD4_SOGGETTO.GET_COGNOME (
             AD4_UTENTE.GET_SOGGETTO (u.utente, 'N', 0))
             COGNOME_SOGGETTO,
          AD4_SOGGETTO.GET_NOME (AD4_UTENTE.GET_SOGGETTO (u.utente, 'N', 0),
                                 'N',
                                 0)
             NOME_SOGGETTO,
          CAST (
             DECODE (AD4_UTENTE.GET_SOGGETTO (u.utente, 'N', 0),
                     NULL, 'N',
                     'Y') AS CHAR (1))
             esiste_soggetto
     FROM AD4_UTENTI u
/
