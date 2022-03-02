--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_126_agp_documenti_dati_scarto

CREATE TABLE AGP_DOCUMENTI_DATI_SCARTO
(
  ID_DOCUMENTO_DATI_SCARTO  NUMBER              NOT NULL,
  STATO                     VARCHAR2(255),
  DATA_STATO                DATE,
  NULLA_OSTA                VARCHAR2(255),
  DATA_NULLA_OSTA           DATE,
  UTENTE_INS                VARCHAR2(255),
  DATA_INS                  DATE,
  UTENTE_UPD                VARCHAR2(255),
  DATA_UPD                  DATE,
  VERSION                   NUMBER              NOT NULL
)
/
ALTER TABLE AGP_DOCUMENTI_DATI_SCARTO ADD (
  CONSTRAINT AGP_DOCUMENTI_DATI_SCARTO_PK
  PRIMARY KEY
  (ID_DOCUMENTO_DATI_SCARTO))
/