--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200827_25.gdo_documenti_soggetti_log

CREATE TABLE GDO_DOCUMENTI_SOGGETTI_LOG
(
  ID_DOCUMENTO_SOGGETTO     NUMBER(19)          NOT NULL,
  ID_DOCUMENTO              NUMBER(19)          NOT NULL,
  REV                       NUMBER(19)          NOT NULL,
  REVTYPE                   NUMBER(3),
  REVEND                    NUMBER(19),
  VERSION                   NUMBER(19),
  VERSION_MOD               NUMBER(1)           DEFAULT 0                     NOT NULL,
  UTENTE                    VARCHAR2(255 BYTE),
  UTENTE_AD4_MOD            NUMBER(1)           DEFAULT 0                     NOT NULL,
  ATTIVO                    CHAR(1 BYTE),
  ATTIVO_MOD                NUMBER(1)           DEFAULT 0                     NOT NULL,
  TIPO_SOGGETTO             VARCHAR2(255 BYTE),
  TIPO_SOGGETTO_MOD         NUMBER(1)           DEFAULT 0                     NOT NULL,
  SEQUENZA                  NUMBER(19),
  SEQUENZA_MOD              NUMBER(1)           DEFAULT 0                     NOT NULL,
  UNITA_PROGR               NUMBER(19),
  UNITA_PROGR_MOD           NUMBER(1)           DEFAULT 0                     NOT NULL,
  UNITA_DAL                 DATE,
  UNITA_DAL_MOD             NUMBER(1)           DEFAULT 0                     NOT NULL,
  UNITA_OTTICA              VARCHAR2(255 BYTE),
  UNITA_OTTICA_MOD          NUMBER(1)           DEFAULT 0                     NOT NULL,
  UNITA_SO4                 NUMBER(19),
  UNITA_SO4_MOD             NUMBER(1)           DEFAULT 0                     NOT NULL,
  ID_TIPO_COLLEGAMENTO      NUMBER(19),
  ID_TIPO_COLLEGAMENTO_MOD  NUMBER(1)           DEFAULT 0                     NOT NULL,
  SOGGETTI                  VARCHAR2(255 BYTE),
  SOGGETTI_MOD              NUMBER(1)           DEFAULT 0                     NOT NULL,
  DOCUMENTO_MOD             NUMBER(1)           DEFAULT 0                     NOT NULL
)
/
CREATE UNIQUE INDEX GDO_DOCUMENTI_SOGGETTI_LOG_PK ON GDO_DOCUMENTI_SOGGETTI_LOG
(ID_DOCUMENTO_SOGGETTO, REV)
/

ALTER TABLE GDO_DOCUMENTI_SOGGETTI_LOG ADD (
  CONSTRAINT GDO_DOCUMENTI_SOGGETTI_LOG_PK
  PRIMARY KEY
  (ID_DOCUMENTO_SOGGETTO, REV)
  USING INDEX GDO_DOCUMENTI_SOGGETTI_LOG_PK)
/
