--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200904_41.gdo_file_documento_log_alter failOnError:false

ALTER TABLE gdo_file_documento_log ADD (
  DATA_VERIFICA      DATE,
  DATA_VERIFICA_MOD  NUMBER(1) DEFAULT 0,
  ESITO_VERIFICA     VARCHAR2(255),
  ESITO_VERIFICA_MOD NUMBER(1) DEFAULT 0)
/