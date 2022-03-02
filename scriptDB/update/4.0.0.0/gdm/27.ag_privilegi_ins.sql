--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_27.ag_privilegi_ins failOnError:false
Insert into AG_PRIVILEGI
   (PRIVILEGIO, DESCRIZIONE, IS_UNIVERSALE)
 Values
   ('MDATAARRBLC', 'Modifica la data di arrivo di Documenti di Protocollo bloccati', 0)
/

Insert into AG_PRIVILEGI
   (PRIVILEGIO, DESCRIZIONE, IS_UNIVERSALE)
 Values
   ('MDOCESTBLC', 'Modifica i dati del documento esterno di Documenti di Protocollo bloccati', 0)
/

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

COMMIT
/