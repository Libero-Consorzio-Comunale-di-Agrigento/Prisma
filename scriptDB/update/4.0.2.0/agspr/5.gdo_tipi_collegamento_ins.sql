--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20200831_5.gdo_tipi_collegamento_ins
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
          'EMER',
          'Registro di Emergenza',
          'Registro di Emergenza',
          e.id_ente,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y',
          'Y'
     FROM gdo_enti e -- inserisco i dizionari per ogni ente configurato
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO t
               WHERE t.TIPO_COLLEGAMENTO = 'EMER' and t.ID_ENTE = e.id_ente)
/
