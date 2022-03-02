--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_074.gdo_tipologie_soggetto_regole_upd
UPDATE GDO_TIPOLOGIE_SOGGETTO_REGOLE
   SET REGOLA_DEFAULT_NOME_METODO = 'getUnitaProtocollanteConPrivilegiDefault',
       REGOLA_LISTA_NOME_METODO = 'ricercaUnitaProtocollanteConPrivilegi',
       RUOLO = NULL
 WHERE     ID_TIPOLOGIA_SOGGETTO IN (SELECT ID_TIPOLOGIA_SOGGETTO
                                       FROM GDO_TIPOLOGIE_SOGGETTO
                                      WHERE descrizione = 'PROTOCOLLO')
       AND tipo_soggetto = 'UO_PROTOCOLLANTE'
/