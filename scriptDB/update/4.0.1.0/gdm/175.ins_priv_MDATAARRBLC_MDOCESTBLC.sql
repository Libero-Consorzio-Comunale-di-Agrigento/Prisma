--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200715_175.ins_priv_MDATAARRBLC_MDOCESTBLC failOnError:false

INSERT INTO AG_PRIVILEGI (PRIVILEGIO, DESCRIZIONE, IS_UNIVERSALE)
   SELECT 'MDATAARRBLC',
          'Modifica la data di arrivo di Documenti di Protocollo bloccati',
          1
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AG_PRIVILEGI
               WHERE PRIVILEGIO = 'MDATAARRBLC')
/

INSERT INTO AG_PRIVILEGI (PRIVILEGIO, DESCRIZIONE, IS_UNIVERSALE)
   SELECT 'MDOCESTBLC',
          'Modifica i dati del documento esterno di Documenti di Protocollo bloccati',
          1
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM AG_PRIVILEGI
               WHERE PRIVILEGIO = 'MDOCESTBLC')
/

INSERT INTO AG_PRIVILEGI_RUOLO (PRIVILEGIO, RUOLO, AOO)
   SELECT PRIVILEGIO, RUOLO, 1
     FROM AG_PRIVILEGI_RUOLO pr
    WHERE     PRIVILEGIO IN ('MDOCESTBLC', 'MDATAARRBLC')
          AND ruolo = 'AGPSUP'
          AND NOT EXISTS
                 (SELECT 1
                    FROM AG_PRIVILEGI_RUOLO pr2
                   WHERE pr2.privilegio = pr.privilegio AND ruolo = 'AGPSUP')
/
