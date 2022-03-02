--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200330.19.parametri_ins

INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE, NOTE)
   SELECT 'URL_SI4CS_SERVICE_1', '@agVar@', VALORE || '/Si4csEngine/service', 'Url del servizio di si4cs per lo scarico / invio mail. Default: ag_server_url + /Si4csEngine/service'
     FROM PARAMETRI
    WHERE     CODICE = 'AG_SERVER_URL'
          AND NOT EXISTS
                 (SELECT 1
                    FROM PARAMETRI
                   WHERE CODICE = 'URL_SI4CS_SERVICE_1')
/
INSERT INTO parametri (codice, tipo_modello, valore, note)
   SELECT 'PEC_USA_SI4CS_WS', '@agStrut@', 'N', 'Indica se lo scarico/invio delle mail devono avvenire con i servizi di si4cs ed essere percio'' letti/scritti da/su si4cs; valori possibili: Y/N. Default N.'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'PEC_USA_SI4CS_WS'
                     AND tipo_modello = '@agStrut@')
/