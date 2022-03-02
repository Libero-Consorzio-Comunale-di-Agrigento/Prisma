--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_078.gdo_tipi_collegamento_ins
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
          'PROV_PROT',
          'Documento annullato dal provvedimento',
          'Documento annullato dal provvedimento',
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
               WHERE t.TIPO_COLLEGAMENTO = 'PROV_PROT' and t.ID_ENTE = e.id_ente)
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
                                   VALIDO)
   SELECT hibernate_sequence.NEXTVAL,
          'PROT_DAFAS',
          'Collegamento tra il documento da fascicolare ed il protocollo generato',
          'Collegamento tra il documento da fascicolare ed il protocollo generato',
          e.id_ente,
          'RPI',
          SYSDATE,
          'RPI',
          SYSDATE,
          'Y'
     FROM gdo_enti e -- inserisco i dizionari per ogni ente configurato
    WHERE NOT EXISTS
             (SELECT 1
                FROM GDO_TIPI_COLLEGAMENTO t
               WHERE t.TIPO_COLLEGAMENTO = 'PROV_DAFAS' and t.ID_ENTE = e.id_ente)
/