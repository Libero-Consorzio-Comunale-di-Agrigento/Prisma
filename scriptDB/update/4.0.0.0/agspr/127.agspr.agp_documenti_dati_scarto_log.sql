--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_127_agp_documenti_dati_scarto_log

CREATE TABLE AGP_DOCUMENTI_DATI_SCARTO_LOG
(
  ID_DOCUMENTO_DATI_SCARTO  NUMBER              NOT NULL,
  REV                       NUMBER(19),
  REVTYPE                   NUMBER(3),
  REVEND                    NUMBER(19),
  STATO                     VARCHAR2(255),
  STATO_MOD                 NUMBER(1)           DEFAULT 0                     NOT NULL,
  DATA_STATO                DATE,
  DATA_STATO_MOD            NUMBER(1)           DEFAULT 0                     NOT NULL,
  NULLA_OSTA                VARCHAR2(255),
  NULLA_OSTA_MOD            NUMBER(1)           DEFAULT 0                     NOT NULL,
  DATA_NULLA_OSTA           DATE,
  DATA_NULLA_OSTA_MOD       NUMBER(1)           DEFAULT 0                     NOT NULL,
  UTENTE_INS                VARCHAR2(255),
  UTENTE_INS_MOD            NUMBER(1)           DEFAULT 0                     NOT NULL,
  DATA_INS                  DATE,
  DATE_CREATED_MOD          NUMBER(1)           DEFAULT 0                     NOT NULL,
  UTENTE_UPD                VARCHAR2(255),
  UTENTE_UPD_MOD            NUMBER(1)           DEFAULT 0                     NOT NULL,
  DATA_UPD                  DATE,
  LAST_UPDATED_MOD          NUMBER(1)           DEFAULT 0                     NOT NULL
)
/
ALTER TABLE AGP_DOCUMENTI_DATI_SCARTO_LOG ADD (
  CONSTRAINT AGP_DOCU_DATI_SCARTO_LOG_PK
  PRIMARY KEY
  (ID_DOCUMENTO_DATI_SCARTO, REV))
/