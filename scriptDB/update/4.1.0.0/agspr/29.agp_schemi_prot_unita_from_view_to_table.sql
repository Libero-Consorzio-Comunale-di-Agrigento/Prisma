--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200828_29.agp_schemi_prot_unita_from_view_to_table failOnError:false

rename agp_schemi_prot_unita to agp_schemi_prot_unita_view
/

drop trigger agp_schemi_prot_unita_tio
/

CREATE TABLE AGP_SCHEMI_PROT_UNITA
(
  ID_SCHEMA_PROT_UNITA  NUMBER                  NOT NULL,
  ID_SCHEMA_PROTOCOLLO  NUMBER                  NOT NULL,
  UNITA_OTTICA          VARCHAR2(255 BYTE),
  UNITA_PROGR           NUMBER(19),
  UNITA_DAL             DATE,
  RUOLO                 VARCHAR2(255 BYTE),
  UTENTE                VARCHAR2(255 BYTE),
  ID_ENTE               NUMBER                  NOT NULL,
  ID_DOCUMENTO_ESTERNO  NUMBER                  NOT NULL,
  UTENTE_INS            VARCHAR2(255 BYTE)      NOT NULL,
  DATA_INS              DATE                    NOT NULL,
  UTENTE_UPD            VARCHAR2(255 BYTE)      NOT NULL,
  DATA_UPD              DATE                    NOT NULL,
  VALIDO                CHAR(1 BYTE)            DEFAULT 'Y'                   NOT NULL,
  VERSION               NUMBER                  NOT NULL
)
/

CREATE UNIQUE INDEX AGP_SCHEMI_PROT_UNITA_PK ON AGP_SCHEMI_PROT_UNITA
(ID_SCHEMA_PROT_UNITA)
/

CREATE INDEX AGP_SCPRUN_ENTE_FK ON AGP_SCHEMI_PROT_UNITA
(ID_ENTE)
/

ALTER TABLE AGP_SCHEMI_PROT_UNITA ADD (
  CONSTRAINT AGP_SCHEMI_PROT_UNITA_PK
  PRIMARY KEY
  (ID_SCHEMA_PROT_UNITA)
  USING INDEX AGP_SCHEMI_PROT_UNITA_PK)
/


ALTER TABLE AGP_SCHEMI_PROT_UNITA ADD (
  CONSTRAINT AGP_SCPRUN_ENTE_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE))
/

INSERT INTO AGP_SCHEMI_PROT_UNITA (ID_SCHEMA_PROT_UNITA,
                                   ID_SCHEMA_PROTOCOLLO,
                                   UNITA_OTTICA,
                                   UNITA_PROGR,
                                   UNITA_DAL,
                                   ID_ENTE,
                                   ID_DOCUMENTO_ESTERNO,
                                   UTENTE_INS,
                                   DATA_INS,
                                   UTENTE_UPD,
                                   DATA_UPD,
                                   VALIDO,
                                   VERSION)
   SELECT ID_SCHEMA_PROT_UNITA,
          ID_SCHEMA_PROTOCOLLO,
          UNITA_OTTICA,
          UNITA_PROGR,
          UNITA_DAL,
          ID_ENTE,
          ID_DOCUMENTO_ESTERNO,
          UTENTE_INS,
          nvl(DATA_INS,sysdate),
          UTENTE_UPD,
          DATA_UPD,
          VALIDO,
          VERSION
     FROM AGP_SCHEMI_PROT_UNITA_VIEW
/
