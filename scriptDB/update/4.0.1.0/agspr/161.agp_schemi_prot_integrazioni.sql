--liquibase formatted sql
--changeset rdestasio:4.0.1.0_20200615_161.agp_schemi_prot_integrazioni failOnError:false
CREATE TABLE AGP_SCHEMI_PROT_INTEGRAZIONI
(
  ID_SCHEMA_PROT_INTEGRAZIONI  NUMBER           NOT NULL,
  APPLICATIVO                  VARCHAR2(255),
  ID_SCHEMA_PROTOCOLLO         NUMBER           NOT NULL,
  UTENTE_INS                   VARCHAR2(255) NOT NULL,
  DATA_INS                     DATE             NOT NULL,
  UTENTE_UPD                   VARCHAR2(255) NOT NULL,
  DATA_UPD                     DATE             NOT NULL,
  VALIDO                       CHAR(1)     DEFAULT 'Y'  NOT NULL,
  VERSION                      NUMBER           DEFAULT 0,
  ID_ENTE                      NUMBER           NOT NULL
)
/

CREATE UNIQUE INDEX AGP_SCHEMA_PROT_INTEGRAZIO_UK ON AGP_SCHEMI_PROT_INTEGRAZIONI
(APPLICATIVO, ID_SCHEMA_PROTOCOLLO)
/

CREATE UNIQUE INDEX AGP_SCHEMI_PROT_INTEGRAZIO_PK ON AGP_SCHEMI_PROT_INTEGRAZIONI
(ID_SCHEMA_PROT_INTEGRAZIONI)
/

ALTER TABLE AGP_SCHEMI_PROT_INTEGRAZIONI ADD (
  CONSTRAINT AGP_SCHEMI_PROT_INTEGRAZIO_PK
  PRIMARY KEY
  (ID_SCHEMA_PROT_INTEGRAZIONI)
  USING INDEX AGP_SCHEMI_PROT_INTEGRAZIO_PK
,  CONSTRAINT AGP_SCHEMA_PROT_INTEGRAZIO_UK
  UNIQUE (APPLICATIVO, ID_SCHEMA_PROTOCOLLO)
  USING INDEX AGP_SCHEMA_PROT_INTEGRAZIO_UK)
/

GRANT SELECT ON AGP_SCHEMI_PROT_INTEGRAZIONI TO ${global.db.gdm.username} WITH GRANT OPTION
/

