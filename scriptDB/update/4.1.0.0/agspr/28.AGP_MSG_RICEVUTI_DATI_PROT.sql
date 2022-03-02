--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200828_28.AGP_MSG_RICEVUTI_DATI_PROT

drop TABLE AGP_MSG_RICEVUTI_DATI_PROT
/

CREATE TABLE AGP_MSG_RICEVUTI_DATI_PROT
(
  ID_DOCUMENTO            NUMBER                NOT NULL,
  ID_MESSAGGIO_SI4CS      NUMBER                NOT NULL,
  OGGETTO                 VARCHAR2(2000 BYTE),
  TESTO                   CLOB,
  MIME_TESTO              VARCHAR2(255 BYTE),
  DATA_RICEZIONE          DATE,
  MITTENTE                VARCHAR2(2000 BYTE),
  DESTINATARI             CLOB,
  DESTINATARI_CONOSCENZA  CLOB,
  DESTINATARI_NASCOSTI    CLOB,
  TIPO                    VARCHAR2(255 BYTE),
  STATO                   VARCHAR2(255 BYTE)    DEFAULT 'DA_GESTIRE'          NOT NULL,
  DATA_STATO              DATE                  DEFAULT SYSDATE               NOT NULL,
  ID_CLASSIFICAZIONE      NUMBER,
  ID_FASCICOLO            NUMBER,
  NOTE                    VARCHAR2(4000 BYTE),
  DATA_SPEDIZIONE         DATE
)
/

CREATE INDEX AGP_MSG_RICEVUTI_DATI_PROT_PK ON AGP_MSG_RICEVUTI_DATI_PROT
(ID_DOCUMENTO)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT ADD (
  CONSTRAINT AGP_MSG_RICEVUTI_DATI_PROT_PK
  PRIMARY KEY
  (ID_DOCUMENTO)
  USING INDEX AGP_MSG_RICEVUTI_DATI_PROT_PK)
/

CREATE UNIQUE INDEX AGP_MESSAGGI_DATI_PROT_UK ON AGP_MSG_RICEVUTI_DATI_PROT
(ID_MESSAGGIO_SI4CS)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT ADD (
  CONSTRAINT AGP_MESSAGGI_DATI_PROT_UK
  UNIQUE (ID_MESSAGGIO_SI4CS)
  USING INDEX AGP_MESSAGGI_DATI_PROT_UK)
/

CREATE INDEX AGP_MRDA_CLAS_FK ON AGP_MSG_RICEVUTI_DATI_PROT
(ID_CLASSIFICAZIONE)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT ADD (
  CONSTRAINT AGP_MRDA_CLAS_FK
  FOREIGN KEY (ID_CLASSIFICAZIONE)
  REFERENCES AGS_CLASSIFICAZIONI (ID_CLASSIFICAZIONE)
  ENABLE VALIDATE)
/

CREATE INDEX AGP_MRDA_FASC_FK ON AGP_MSG_RICEVUTI_DATI_PROT
(ID_FASCICOLO)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT ADD (
  CONSTRAINT AGP_MRDA_FASC_FK
  FOREIGN KEY (ID_FASCICOLO)
  REFERENCES AGS_FASCICOLI (ID_DOCUMENTO)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT ADD (
  CONSTRAINT AGP_MRDA_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO))
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT ADD (
  CONSTRAINT AGP_MSG_RIC_DATI_PROT_STATO_CC
  CHECK (STATO IN ('DA_GESTIRE', 'DA_PROTOCOLLARE_CON_SEGNATURA', 'DA_PROTOCOLLARE_SENZA_SEGNATURA', 'GESTITO', 'GENERATA_ECCEZIONE', 'NON_PROTOCOLLATO', 'PROTOCOLLATO', 'SCARTATO') AND STATO = UPPER(STATO))
  ENABLE VALIDATE)
/

drop TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG
/

CREATE TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG
(
  ID_DOCUMENTO            NUMBER(19),
  REV                     NUMBER(19),
  DATA_RICEZIONE          TIMESTAMP(6),
  DATA_RICEZIONE_MOD      NUMBER(1)             DEFAULT 0                     NOT NULL,
  DATA_STATO              TIMESTAMP(6),
  DATA_STATO_MOD          NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_MESSAGGIO_SI4CS      NUMBER(19),
  ID_MESSAGGIO_SI4CS_MOD  NUMBER(1)             DEFAULT 0                     NOT NULL,
  STATO                   VARCHAR2(255 BYTE),
  STATO_MESSAGGIO_MOD     NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_CLASSIFICAZIONE      NUMBER(19),
  CLASSIFICAZIONE_MOD     NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_FASCICOLO            NUMBER(19),
  FASCICOLO_MOD           NUMBER(1)             DEFAULT 0                     NOT NULL,
  DATA_SPEDIZIONE_MOD     NUMBER(1)             DEFAULT 0                     NOT NULL,
  DATA_SPEDIZIONE         TIMESTAMP(6)
)
/

CREATE UNIQUE INDEX AGP_MSG_RICE_DATI_PROT_LOG_PK ON AGP_MSG_RICEVUTI_DATI_PROT_LOG
(ID_DOCUMENTO, REV)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG ADD (
  CONSTRAINT AGP_MSG_RICE_DATI_PROT_LOG_PK
  PRIMARY KEY
  (ID_DOCUMENTO, REV)
  USING INDEX AGP_MSG_RICE_DATI_PROT_LOG_PK)
/

CREATE INDEX AGP_MRDL_CLAS_FK ON AGP_MSG_RICEVUTI_DATI_PROT_LOG
(ID_CLASSIFICAZIONE)
/
ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG ADD (
  CONSTRAINT AGP_MRDL_CLAS_FK
  FOREIGN KEY (ID_CLASSIFICAZIONE)
  REFERENCES AGS_CLASSIFICAZIONI (ID_CLASSIFICAZIONE))
/

CREATE INDEX AGP_MRDL_FASC_FK ON AGP_MSG_RICEVUTI_DATI_PROT_LOG
(ID_FASCICOLO)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG ADD (
  CONSTRAINT AGP_MRDL_FASC_FK
  FOREIGN KEY (ID_FASCICOLO)
  REFERENCES AGS_FASCICOLI (ID_DOCUMENTO))
/
