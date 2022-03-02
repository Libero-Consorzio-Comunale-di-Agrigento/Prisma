--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201006_46.agp_trasco_storico_log

CREATE TABLE AGP_TRASCO_STORICO_LOG
(
  ID_DOCUMENTO          NUMBER                  NOT NULL,
  ID_DOCUMENTO_ESTERNO  NUMBER                  NOT NULL,
  TRASCO_STORICO        VARCHAR2(1 BYTE)        DEFAULT 'N'                   NOT NULL
)
/
CREATE UNIQUE INDEX AGP_TRASCO_STORICO_LOG_PK ON AGP_TRASCO_STORICO_LOG
(ID_DOCUMENTO)
/