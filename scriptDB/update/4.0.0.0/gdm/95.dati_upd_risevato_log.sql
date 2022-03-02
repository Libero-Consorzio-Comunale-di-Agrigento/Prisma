--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_95.dati_upd_risevato_log failOnError:false
UPDATE DATI
SET TIPO_LOG = 1
WHERE AREA IN ('SEGRETERIA', 'SEGRETERIA.PROTOCOLLO')
AND DATO = 'RISERVATO'
/