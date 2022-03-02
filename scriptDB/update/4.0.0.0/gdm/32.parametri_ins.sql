--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_32.parametri_ins failOnError:false runOnChange:true
INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'URL_SI4CS_SERVICE_1', '@agVar@', ''
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'URL_SI4CS_SERVICE_1'
                     AND tipo_modello = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'FILE_ALLEGATO_OB_1', '@agVar@', 'N'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'FILE_ALLEGATO_OB_1'
                     AND tipo_modello = '@agVar@')
/


INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'ALLEGATO_STAMPA_UNICA_DEFAULT_1', '@agVar@', ''
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'ALLEGATO_STAMPA_UNICA_DEFAULT_1'
                     AND tipo_modello = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'INTEROP_ABILITA_UNZIP_1', '@agVar@', 'N'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'INTEROP_ABILITA_UNZIP_1'
                     AND tipo_modello = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE,
                       TIPO_MODELLO,
                       VALORE,
                       NOTE)
   SELECT 'ACCESSO_CIVICO_OGGETTO_DEFAULT_1',
          '@agVar@',
          'OGGETTO',
          'Indica se il campo oggetto dei dati di accesso civico deve essere prevalorizzato: OGGETTO = con l''oggetto della domanda, TIPO_ACCESSO = con il tipo di accesso civico, null = il campo non viene prevalorizzato; default: OGGETTO'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'ACCESSO_CIVICO_OGGETTO_DEFAULT_1'
                     AND TIPO_MODELLO = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT CODICE, TIPO_MODELLO, VALORE
     FROM (SELECT 'UNITA_CONCAT_CODICE_1' CODICE,
                  '@agVar@' TIPO_MODELLO,
                  DECODE (COUNT (1), 0, 'N', 'Y') VALORE
             FROM seg_unita
            WHERE SUBSTR (nome, 1, LENGTH (unita) + 2) = unita || ' -')
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'UNITA_CONCAT_CODICE_1'
                     AND tipo_modello = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE,
                       TIPO_MODELLO,
                       VALORE,
                       NOTE)
   SELECT 'ALLEGATO_STATO_FIRMA_DEFAULT_1',
          '@agVar@',
          'DA_NON_FIRMARE',
          'Indica il default dello stato di firma di un allegato. Valori possibili: DA_FIRMARE / DA_NON_FIRMARE; default: DA_NON_FIRMARE'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'ALLEGATO_STATO_FIRMA_DEFAULT_1'
                     AND TIPO_MODELLO = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE,
                       TIPO_MODELLO,
                       VALORE,
                       NOTE)
   SELECT 'PEC_APRI_POPUP_MOTIVO_INT_OPERATORE_1',
          '@agVar@',
          'N',
          'Indica se in apertura di un documento creato da pec, fino alla protocollazione, debba essere aperta una popup con le segnalazioni di incongruenze. Valori possibili: Y / N; default: Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'PEC_APRI_POPUP_MOTIVO_INT_OPERATORE_1'
                     AND TIPO_MODELLO = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE,
                       TIPO_MODELLO,
                       VALORE,
                       NOTE)
   SELECT 'CARATTERI_SPECIALI_NOME_FILE',
          '@agVar@',
          'àèéìòù°\/:*?"<>|',
          'Indicare i caratteri che NON devono essere presenti nei nomi dei file'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE     codice = 'CARATTERI_SPECIALI_NOME_FILE'
                     AND TIPO_MODELLO = '@agVar@')
/

INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'INTEROP_ABILITA_CREAZIONE_PG_CON_FLUSSO_1', '@agVar@', 'N'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE codice = 'INTEROP_ABILITA_CREAZIONE_PG_CON_FLUSSO_1')
/

INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'INTEROP_SCARICO_ATTIVA_FLUSSO_1', '@agVar@', 'N'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE codice = 'INTEROP_SCARICO_ATTIVA_FLUSSO_1')
/


INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'INTEROP_SCARICO_FLUSSO_1', '@agVar@', ''
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE codice = 'INTEROP_SCARICO_FLUSSO_1')
/
INSERT INTO PARAMETRI (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'CONSERVAZIONE_AUTOMATICA_LIMITE_1', '@agVar@', '-1'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE codice = 'CONSERVAZIONE_AUTOMATICA_LIMITE_1')
/

Insert into PARAMETRI
   (CODICE, TIPO_MODELLO, VALORE)
   SELECT 'AGGIORNAMENTO_TERMINATO_1', '@agVar@', 'N'
        FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM parametri
               WHERE codice = 'AGGIORNAMENTO_TERMINATO_1')
/
