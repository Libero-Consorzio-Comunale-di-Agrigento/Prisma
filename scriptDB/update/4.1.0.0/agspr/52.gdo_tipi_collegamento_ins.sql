--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201008_52.gdo_tipi_collegamento_ins

INSERT INTO GDO_TIPI_COLLEGAMENTO (ID_TIPO_COLLEGAMENTO,
                                   TIPO_COLLEGAMENTO,
                                   DESCRIZIONE,
                                   COMMENTO,
                                   ID_ENTE,
                                   UTENTE_INS,
                                   DATA_INS,
                                   UTENTE_UPD,
                                   DATA_UPD,
                                   VALIDO,
                                   SISTEMA)
   SELECT hibernate_sequence.NEXTVAL,
          'PROT_CONF',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio conferma ricezione',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio conferma ricezione',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM dual
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_CONF')
/

INSERT INTO GDO_TIPI_COLLEGAMENTO (ID_TIPO_COLLEGAMENTO,
                                   TIPO_COLLEGAMENTO,
                                   DESCRIZIONE,
                                   COMMENTO,
                                   ID_ENTE,
                                   UTENTE_INS,
                                   DATA_INS,
                                   UTENTE_UPD,
                                   DATA_UPD,
                                   VALIDO,
                                   SISTEMA)
   SELECT hibernate_sequence.NEXTVAL,
          'PROT_AGG',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio aggiornamento',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio aggiornamento',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM dual
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_AGG')
/

INSERT INTO GDO_TIPI_COLLEGAMENTO (ID_TIPO_COLLEGAMENTO,
                                   TIPO_COLLEGAMENTO,
                                   DESCRIZIONE,
                                   COMMENTO,
                                   ID_ENTE,
                                   UTENTE_INS,
                                   DATA_INS,
                                   UTENTE_UPD,
                                   DATA_UPD,
                                   VALIDO,
                                   SISTEMA)
   SELECT hibernate_sequence.NEXTVAL,
          'PROT_ECC',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio eccezione',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio eccezione',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM dual
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_ECC')
/

INSERT INTO GDO_TIPI_COLLEGAMENTO (ID_TIPO_COLLEGAMENTO,
                                   TIPO_COLLEGAMENTO,
                                   DESCRIZIONE,
                                   COMMENTO,
                                   ID_ENTE,
                                   UTENTE_INS,
                                   DATA_INS,
                                   UTENTE_UPD,
                                   DATA_UPD,
                                   VALIDO,
                                   SISTEMA)
   SELECT hibernate_sequence.NEXTVAL,
          'PROT_ANN',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio annullamento',
          'Collegamento fra protocollo e messaggio in arrivo per messaggio annullamento',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM dual
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_ANN')
/

INSERT INTO GDO_TIPI_COLLEGAMENTO (ID_TIPO_COLLEGAMENTO,
                                   TIPO_COLLEGAMENTO,
                                   DESCRIZIONE,
                                   COMMENTO,
                                   ID_ENTE,
                                   UTENTE_INS,
                                   DATA_INS,
                                   UTENTE_UPD,
                                   DATA_UPD,
                                   VALIDO,
                                   SISTEMA)
   SELECT hibernate_sequence.NEXTVAL,
          'PROT_PEC',
          'Collegamento fra messaggio inviato e messaggio ricevuto',
          'Collegamento fra messaggio inviato e messaggio ricevuto',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM dual
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_PEC')
/

INSERT INTO GDO_TIPI_COLLEGAMENTO (ID_TIPO_COLLEGAMENTO,
                                   TIPO_COLLEGAMENTO,
                                   DESCRIZIONE,
                                   COMMENTO,
                                   ID_ENTE,
                                   UTENTE_INS,
                                   DATA_INS,
                                   UTENTE_UPD,
                                   DATA_UPD,
                                   VALIDO,
                                   SISTEMA)
   SELECT hibernate_sequence.NEXTVAL,
          'PROT_RR',
          'Collegamento fra protocollo e messaggio in partenza per messaggio invio ricevuta',
          'Collegamento fra protocollo e messaggio in partenza per messaggio invio ricevuta',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM dual
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_RR')
/