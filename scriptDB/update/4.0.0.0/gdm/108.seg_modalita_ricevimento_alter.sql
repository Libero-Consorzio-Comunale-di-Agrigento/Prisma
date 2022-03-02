--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_108.seg_modalita_ricevimento_alter failOnError:false
ALTER TABLE SEG_MODALITA_RICEVIMENTO
MODIFY(TIPO_SPEDIZIONE VARCHAR2(255))
/