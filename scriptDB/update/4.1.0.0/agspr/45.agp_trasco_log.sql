--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201006_45.agp_trasco_log

CREATE TABLE AGP_TRASCO_LOG
(
  ID_DOCUMENTO_ESTERNO  NUMBER                  NOT NULL,
  ID_DOCUMENTO          NUMBER,
  LOG                   CLOB,
  ISTRUZIONE            VARCHAR2(4000),
  DATA_ESECUZIONE       DATE
)
/