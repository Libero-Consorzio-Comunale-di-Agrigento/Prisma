--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200330.20.gdo_tipologie_soggetto_regole_ins
INSERT INTO gdo_tipologie_soggetto_regole (ID_TIPOLOGIA_SOGGETTO_REGOLA,
                                           VERSION,
                                           DATA_INS,
                                           ID_ENTE,
                                           DATA_UPD,
                                           REGOLA_DEFAULT_NOME_BEAN,
                                           REGOLA_DEFAULT_NOME_METODO,
                                           REGOLA_LISTA_NOME_BEAN,
                                           REGOLA_LISTA_NOME_METODO,
                                           SEQUENZA,
                                           TIPO_SOGGETTO,
                                           TIPO_SOGGETTO_PARTENZA,
                                           ID_TIPOLOGIA_SOGGETTO,
                                           UTENTE_INS,
                                           UTENTE_UPD,
                                           VALIDO)
   SELECT HIBERNATE_SEQUENCE.NEXTVAL,
          0,
          SYSDATE,
          1,
          SYSDATE,
          'regoleCalcoloSoggettiProtocolloRepository',
          'getUnitaProtocollanteDefaultMessaggiArrivo',
          'regoleCalcoloSoggettiProtocolloRepository',
          'ricercaUnitaProtocollanteMessaggiArrivo',
          (SELECT NVL (MAX (SEQUENZA), 0) + 1
             FROM GDO_TIPOLOGIE_SOGGETTO_REGOLE gdosr
            WHERE     gdosr.ID_TIPOLOGIA_SOGGETTO =
                         GDO_TIPOLOGIE_SOGGETTO.ID_TIPOLOGIA_SOGGETTO
                  AND TIPO_SOGGETTO = 'UO_MESSAGGIO'),
          'UO_MESSAGGIO',
          'REDATTORE',
          ID_TIPOLOGIA_SOGGETTO,
          'RPI',
          'RPI',
          'Y'
     FROM GDO_TIPOLOGIE_SOGGETTO
    WHERE DESCRIZIONE = 'PROTOCOLLO' AND VALIDO = 'Y'
/
