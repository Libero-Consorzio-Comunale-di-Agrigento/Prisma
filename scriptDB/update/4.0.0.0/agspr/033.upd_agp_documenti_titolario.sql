--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_033.upd_agp_documenti_titolario
UPDATE AGP_DOCUMENTI_TITOLARIO SET VERSION = 0 WHERE VERSION IS NULL
/

UPDATE AGP_DOCUMENTI_TITOLARIO SET VALIDO = 'Y' WHERE VALIDO IS NULL
/
