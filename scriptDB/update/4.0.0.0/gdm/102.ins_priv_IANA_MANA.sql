--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_102.ins_priv_IANA_MANA failOnError:false
INSERT INTO AG_PRIVILEGI (PRIVILEGIO, DESCRIZIONE, IS_UNIVERSALE)
        VALUES (
                  'MANA',
                  'Consente di aggiornare soggetti presenti in anagrafica dal protocollo',
                  1)
/

INSERT INTO AG_PRIVILEGI (PRIVILEGIO, DESCRIZIONE, IS_UNIVERSALE)
        VALUES (
                  'IANA',
                  'Consente di inserire nuovi soggetti in anagrafica dal protocollo',
                  1)
/

INSERT INTO AG_PRIVILEGI_RUOLO (PRIVILEGIO, RUOLO, AOO)
   SELECT 'IANA', RUOLO, 1
     FROM AG_PRIVILEGI_RUOLO
    WHERE PRIVILEGIO = 'MRAP'
   UNION
   SELECT 'MANA', RUOLO, 1
     FROM AG_PRIVILEGI_RUOLO
    WHERE PRIVILEGIO = 'MRAP'
/
