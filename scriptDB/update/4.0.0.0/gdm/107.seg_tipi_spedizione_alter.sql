--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_107.seg_tipi_spedizione_alter failOnError:false
ALTER TABLE SEG_TIPI_SPEDIZIONE
MODIFY(TIPO_SPEDIZIONE VARCHAR2(255))
/