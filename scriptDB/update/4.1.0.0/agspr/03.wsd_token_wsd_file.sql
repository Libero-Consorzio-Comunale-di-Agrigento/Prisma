--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200327.3.wsd_token_wsd_file

CREATE TABLE WSD_TOKEN
(
  ID_WSD_TOKEN  NUMBER,
  TOKEN         VARCHAR2(100 BYTE)              NOT NULL,
  ID_ENTE       NUMBER                          NOT NULL,
  VALIDO        CHAR(1 BYTE)                    DEFAULT 'Y',
  UTENTE_INS    VARCHAR2(255 BYTE),
  DATA_INS      DATE                            NOT NULL,
  UTENTE_UPD    VARCHAR2(255 BYTE)              NOT NULL,
  DATA_UPD      DATE                            NOT NULL,
  VERSION       NUMBER                          NOT NULL
)
/

CREATE UNIQUE INDEX WSD_TOKEN_PK
    ON WSD_TOKEN (ID_WSD_TOKEN)
/

ALTER TABLE WSD_TOKEN
 ADD CONSTRAINT WSD_TOKEN_PK
  PRIMARY KEY
  (ID_WSD_TOKEN)
  USING INDEX WSD_TOKEN_PK
/

ALTER TABLE WSD_TOKEN
 ADD CONSTRAINT WSD_TOKEN_ENTE_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE)
/

CREATE INDEX WSD_TOKEN_ENTE_FK
    ON WSD_TOKEN (ID_ENTE)
/

CREATE UNIQUE INDEX WSD_TOKEN_TOKEN_UK
    ON WSD_TOKEN (TOKEN)
/

CREATE TABLE WSD_FILE
(
  ID_WSD_FILE   NUMBER,
  ID_WSD_TOKEN  NUMBER                          NOT NULL,
  CONTENT_TYPE  VARCHAR2(255 BYTE),
  CONTENT       BLOB                            NOT NULL
)
/

CREATE UNIQUE INDEX WSD_FILE_PK
    ON WSD_FILE (ID_WSD_FILE)
/

ALTER TABLE WSD_FILE
 ADD CONSTRAINT WSD_FILE_PK
  PRIMARY KEY
  (ID_WSD_FILE)
  USING INDEX WSD_FILE_PK
/

CREATE INDEX WSD_FILE_WSD_TOKEN_TOKEN_FK
    ON WSD_FILE (ID_WSD_TOKEN)
/

ALTER TABLE WSD_FILE
 ADD CONSTRAINT WSD_FILE_WSD_TOKEN_TOKEN_FK
  FOREIGN KEY (ID_WSD_TOKEN)
  REFERENCES WSD_TOKEN (ID_WSD_TOKEN)
/
