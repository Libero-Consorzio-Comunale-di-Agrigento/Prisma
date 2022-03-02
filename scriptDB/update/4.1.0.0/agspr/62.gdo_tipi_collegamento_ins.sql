--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201028_62.gdo_tipi_collegamento_ins.sql failOnError:false

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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'PROT_RIFE',
          'Riferimenti del Protocollo',
          'Riferimenti del Protocollo',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_RIFE')
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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'ALLEGATO',
          'Allegato',
          'Allegato',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'ALLEGATO')
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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'PROT_PREC',
          'Protocollo Precedente',
          'Protocollo Precedente',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_PREC')
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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'COLLEGATO',
          'Documento Collegato',
          'Documento Collegato',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'COLLEGATO')
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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'MAIL',
          'Collegamento fra messaggio e protocollo',
          'Collegamento fra messaggio e protocollo',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'MAIL')

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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'PROT_DAFAS',
          'Collegamento tra il documento da fascicolare ed il protocollo generato',
          'Collegamento tra il documento da fascicolare ed il protocollo generato',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_DAFAS')
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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'EMER',
          'Registro di Emergenza',
          'Registro di Emergenza',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'EMER')
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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'PROV_PROT',
          'Documento annullato dal provvedimento',
          'Documento annullato dal provvedimento',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROV_PROT')
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
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          'PROT_DAAC',
          'Registro accessi',
          'Registro accessi',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO
               WHERE TIPO_COLLEGAMENTO = 'PROT_DAAC')
/

COMMIT
/