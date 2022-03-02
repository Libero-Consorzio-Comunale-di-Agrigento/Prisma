--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_72020090_171.gdo_tipologie_soggetto_regole_upd

UPDATE GDO_TIPOLOGIE_SOGGETTO_REGOLE
   SET TIPO_SOGGETTO_PARTENZA = ''
 WHERE TIPO_SOGGETTO_PARTENZA = '-- nessuno --'
/
