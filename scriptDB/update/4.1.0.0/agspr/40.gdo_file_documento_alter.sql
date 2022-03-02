--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200904_40.gdo_file_documento_alter failOnError:false

ALTER TABLE gdo_file_documento ADD (
  DATA_VERIFICA              DATE,
  ESITO_VERIFICA             VARCHAR2(255))
/