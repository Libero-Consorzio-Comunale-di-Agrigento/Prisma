--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200828_32.gdo_tipi_collegamento_ins_fasc

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
          'F_PREC_SEG',
          'Fascicolo Precedente/Seguente',
          'Fascicolo Precedente/Seguente',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
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
          'F_COLLEGA',
          'Collegamento tra Fascicoli',
          'Collegamento tra Fascicoli',
          1,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM DUAL
/
