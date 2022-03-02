--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_036.storico.envers failOnError:false
CREATE TABLE REVINFO
(
  REV       NUMBER(19)                          NOT NULL,
  REVTSTMP  TIMESTAMP(6)                        NOT NULL
)
/

ALTER TABLE REVINFO ADD (
CONSTRAINT REVINFO_PK
  PRIMARY KEY
  (REV)
  ENABLE VALIDATE)
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
  STATO                   VARCHAR2(255),
  STATO_MESSAGGIO_MOD     NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_CLASSIFICAZIONE      NUMBER(19),
  CLASSIFICAZIONE_MOD     NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_FASCICOLO            NUMBER(19),
  FASCICOLO_MOD           NUMBER(1)             DEFAULT 0                     NOT NULL
)
/


CREATE TABLE AGP_PROTOCOLLI_CORR_LOG
(
  ID_PROTOCOLLO_CORRISPONDENTE  NUMBER(19)      NOT NULL,
  REV                           NUMBER(19)      NOT NULL,
  REVTYPE                       NUMBER(3),
  REVEND                        NUMBER(19),
  DATA_INS                      TIMESTAMP(6),
  DATE_CREATED_MOD              NUMBER(1)       DEFAULT 0                     NOT NULL,
  DATA_UPD                      TIMESTAMP(6),
  LAST_UPDATED_MOD              NUMBER(1)       DEFAULT 0                     NOT NULL,
  VALIDO                        CHAR(1),
  VALIDO_MOD                    NUMBER(1)       DEFAULT 0                     NOT NULL,
  BC_SPEDIZIONE                 VARCHAR2(255),
  BARCODE_SPEDIZIONE_MOD        NUMBER(1)       DEFAULT 0                     NOT NULL,
  CAP                           VARCHAR2(255),
  CAP_MOD                       NUMBER(1)       DEFAULT 0                     NOT NULL,
  CODICE_FISCALE                VARCHAR2(255),
  CODICE_FISCALE_MOD            NUMBER(1)       DEFAULT 0                     NOT NULL,
  COGNOME                       VARCHAR2(255),
  COGNOME_MOD                   NUMBER(1)       DEFAULT 0                     NOT NULL,
  COMUNE                        VARCHAR2(255),
  COMUNE_MOD                    NUMBER(1)       DEFAULT 0                     NOT NULL,
  CONOSCENZA                    CHAR(1),
  CONOSCENZA_MOD                NUMBER(1)       DEFAULT 0                     NOT NULL,
  COSTO_SPEDIZIONE              NUMBER(19,2),
  COSTO_SPEDIZIONE_MOD          NUMBER(1)       DEFAULT 0                     NOT NULL,
  DATA_SPEDIZIONE               TIMESTAMP(6),
  DATA_SPEDIZIONE_MOD           NUMBER(1)       DEFAULT 0                     NOT NULL,
  DENOMINAZIONE                 VARCHAR2(4000),
  DENOMINAZIONE_MOD             NUMBER(1)       DEFAULT 0                     NOT NULL,
  EMAIL                         VARCHAR2(255),
  EMAIL_MOD                     NUMBER(1)       DEFAULT 0                     NOT NULL,
  FAX                           VARCHAR2(255),
  FAX_MOD                       NUMBER(1)       DEFAULT 0                     NOT NULL,
  ID_DOCUMENTO_ESTERNO          NUMBER(19),
  ID_DOCUMENTO_ESTERNO_MOD      NUMBER(1)       DEFAULT 0                     NOT NULL,
  INDIRIZZO                     VARCHAR2(4000),
  INDIRIZZO_MOD                 NUMBER(1)       DEFAULT 0                     NOT NULL,
  NOME                          VARCHAR2(255),
  NOME_MOD                      NUMBER(1)       DEFAULT 0                     NOT NULL,
  PARTITA_IVA                   VARCHAR2(255),
  PARTITA_IVA_MOD               NUMBER(1)       DEFAULT 0                     NOT NULL,
  PROVINCIA_SIGLA               VARCHAR2(255),
  PROVINCIA_SIGLA_MOD           NUMBER(1)       DEFAULT 0                     NOT NULL,
  QUANTITA                      NUMBER(19),
  QUANTITA_MOD                  NUMBER(1)       DEFAULT 0                     NOT NULL,
  TIPO_CORRISPONDENTE           VARCHAR2(255),
  TIPO_CORRISPONDENTE_MOD       NUMBER(1)       DEFAULT 0                     NOT NULL,
  TIPO_INDIRIZZO                VARCHAR2(255),
  TIPO_INDIRIZZO_MOD            NUMBER(1)       DEFAULT 0                     NOT NULL,
  UTENTE_INS                    VARCHAR2(255),
  UTENTE_INS_MOD                NUMBER(1)       DEFAULT 0                     NOT NULL,
  UTENTE_UPD                    VARCHAR2(255),
  UTENTE_UPD_MOD                NUMBER(1)       DEFAULT 0                     NOT NULL,
  ID_DOCUMENTO                  NUMBER(19),
  PROTOCOLLO_MOD                NUMBER(1)       DEFAULT 0                     NOT NULL,
  ID_FISCALE_ESTERO             VARCHAR2(255),
  ID_FISCALE_ESTERO_MOD         NUMBER(1)       DEFAULT 0                     NOT NULL,
  DATA_LOG                      DATE
)
/

CREATE TABLE AGP_PROTOCOLLI_DATI_SCARTO_LOG
(
  ID_PROTOCOLLO_DATI_SCARTO  NUMBER             NOT NULL,
  REV                        NUMBER(19),
  REVTYPE                    NUMBER(3),
  REVEND                     NUMBER(19),
  STATO                      VARCHAR2(255),
  STATO_MOD                  NUMBER(1)          DEFAULT 0                     NOT NULL,
  DATA_STATO                 DATE,
  DATA_STATO_MOD             NUMBER(1)          DEFAULT 0                     NOT NULL,
  NULLA_OSTA                 VARCHAR2(255),
  NULLA_OSTA_MOD             NUMBER(1)          DEFAULT 0                     NOT NULL,
  DATA_NULLA_OSTA            DATE,
  DATA_NULLA_OSTA_MOD        NUMBER(1)          DEFAULT 0                     NOT NULL,
  UTENTE_INS                 VARCHAR2(255),
  UTENTE_INS_MOD             NUMBER(1)          DEFAULT 0                     NOT NULL,
  DATA_INS                   DATE,
  DATE_CREATED_MOD           NUMBER(1)          DEFAULT 0                     NOT NULL,
  UTENTE_UPD                 VARCHAR2(255),
  UTENTE_UPD_MOD             NUMBER(1)          DEFAULT 0                     NOT NULL,
  DATA_UPD                   DATE,
  LAST_UPDATED_MOD           NUMBER(1)          DEFAULT 0                     NOT NULL
)
/

CREATE TABLE GDO_DOCUMENTI_COLLEGATI_LOG
(
  ID_DOCUMENTO_COLLEGATO  NUMBER(19)            NOT NULL,
  REV                     NUMBER(19)            NOT NULL,
  REVTYPE                 NUMBER(3),
  REVEND                  NUMBER(19),
  DATA_INS                TIMESTAMP(6),
  DATE_CREATED_MOD        NUMBER(1)             DEFAULT 0                     NOT NULL,
  DATA_UPD                TIMESTAMP(6),
  LAST_UPDATED_MOD        NUMBER(1)             DEFAULT 0                     NOT NULL,
  VALIDO                  CHAR(1),
  VALIDO_MOD              NUMBER(1)             DEFAULT 0                     NOT NULL,
  UTENTE_INS              VARCHAR2(255),
  UTENTE_INS_MOD          NUMBER(1)             DEFAULT 0                     NOT NULL,
  UTENTE_UPD              VARCHAR2(255),
  UTENTE_UPD_MOD          NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_COLLEGATO            NUMBER(19),
  COLLEGATO_MOD           NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_DOCUMENTO            NUMBER(19),
  DOCUMENTO_MOD           NUMBER(1)             DEFAULT 0                     NOT NULL,
  ID_TIPO_COLLEGAMENTO    NUMBER(19),
  TIPO_COLLEGAMENTO_MOD   NUMBER(1)             DEFAULT 0                     NOT NULL
)
/

CREATE TABLE GDO_DOCUMENTI_LOG
(
  ID_DOCUMENTO              NUMBER(19)          NOT NULL,
  REV                       NUMBER(19)          NOT NULL,
  REVTYPE                   NUMBER(3),
  REVEND                    NUMBER(19),
  DATA_INS                  TIMESTAMP(6),
  DATE_CREATED_MOD          NUMBER(1)           DEFAULT 0                     NOT NULL,
  DATA_UPD                  TIMESTAMP(6),
  LAST_UPDATED_MOD          NUMBER(1)           DEFAULT 0                     NOT NULL,
  VALIDO                    CHAR(1),
  VALIDO_MOD                NUMBER(1)           DEFAULT 0                     NOT NULL,
  ID_DOCUMENTO_ESTERNO      NUMBER(19),
  ID_DOCUMENTO_ESTERNO_MOD  NUMBER(1)           DEFAULT 0                     NOT NULL,
  RISERVATO                 CHAR(1),
  RISERVATO_MOD             NUMBER(1)           DEFAULT 0                     NOT NULL,
  STATO                     VARCHAR2(255),
  STATO_MOD                 NUMBER(1)           DEFAULT 0                     NOT NULL,
  STATO_CONSERVAZIONE       VARCHAR2(255),
  STATO_CONSERVAZIONE_MOD   NUMBER(1)           DEFAULT 0                     NOT NULL,
  STATO_FIRMA               VARCHAR2(255),
  STATO_FIRMA_MOD           NUMBER(1)           DEFAULT 0                     NOT NULL,
  UTENTE_INS                VARCHAR2(255),
  UTENTE_INS_MOD            NUMBER(1)           DEFAULT 0                     NOT NULL,
  UTENTE_UPD                VARCHAR2(255),
  UTENTE_UPD_MOD            NUMBER(1)           DEFAULT 0                     NOT NULL,
  ID_ENTE                   NUMBER(19),
  ENTE_MOD                  NUMBER(1)           DEFAULT 0                     NOT NULL,
  DOCUMENTI_COLLEGATI_MOD   NUMBER(1)           DEFAULT 0                     NOT NULL,
  FILE_DOCUMENTI_MOD        NUMBER(1)           DEFAULT 0                     NOT NULL,
  ID_ENGINE_ITER            NUMBER(19),
  ITER_MOD                  NUMBER(1)           DEFAULT 0                     NOT NULL,
  TIPO_OGGETTO              VARCHAR2(255),
  TIPO_OGGETTO_MOD          NUMBER(1)           DEFAULT 0                     NOT NULL,
  DATA_LOG                  DATE
)
/

CREATE TABLE GDO_FILE_DOCUMENTO_LOG
(
  ID_FILE_DOCUMENTO    NUMBER(19)               NOT NULL,
  REV                  NUMBER(19)               NOT NULL,
  REVTYPE              NUMBER(3),
  REVEND               NUMBER(19),
  DATA_INS             TIMESTAMP(6),
  DATE_CREATED_MOD     NUMBER(1)                DEFAULT 0                     NOT NULL,
  DATA_UPD             TIMESTAMP(6),
  LAST_UPDATED_MOD     NUMBER(1)                DEFAULT 0                     NOT NULL,
  VALIDO               CHAR(1),
  VALIDO_MOD           NUMBER(1)                DEFAULT 0                     NOT NULL,
  CODICE               VARCHAR2(255),
  CODICE_MOD           NUMBER(1)                DEFAULT 0                     NOT NULL,
  CONTENT_TYPE         VARCHAR2(255),
  CONTENT_TYPE_MOD     NUMBER(1)                DEFAULT 0                     NOT NULL,
  DIMENSIONE           NUMBER(19),
  DIMENSIONE_MOD       NUMBER(1)                DEFAULT 0                     NOT NULL,
  FIRMATO              CHAR(1),
  FIRMATO_MOD          NUMBER(1)                DEFAULT 0                     NOT NULL,
  ID_FILE_ESTERNO      NUMBER(19),
  ID_FILE_ESTERNO_MOD  NUMBER(1)                DEFAULT 0                     NOT NULL,
  MARCATO              CHAR(1),
  MARCATO_MOD          NUMBER(1)                DEFAULT 0                     NOT NULL,
  MODIFICABILE         CHAR(1),
  MODIFICABILE_MOD     NUMBER(1)                DEFAULT 0                     NOT NULL,
  NOME                 VARCHAR2(255),
  NOME_MOD             NUMBER(1)                DEFAULT 0                     NOT NULL,
  REVISIONE_STORICO    NUMBER(19),
  REVISIONE_MOD        NUMBER(1)                DEFAULT 0                     NOT NULL,
  SEQUENZA             NUMBER(10),
  SEQUENZA_MOD         NUMBER(1)                DEFAULT 0                     NOT NULL,
  TESTO                CLOB,
  TESTO_MOD            NUMBER(1)                DEFAULT 0                     NOT NULL,
  UTENTE_INS           VARCHAR2(255),
  UTENTE_INS_MOD       NUMBER(1)                DEFAULT 0                     NOT NULL,
  UTENTE_UPD           VARCHAR2(255),
  UTENTE_UPD_MOD       NUMBER(1)                DEFAULT 0                     NOT NULL,
  ID_DOCUMENTO         NUMBER(19),
  DOCUMENTO_MOD        NUMBER(1)                DEFAULT 0                     NOT NULL,
  FILE_ORIGINALE_ID    NUMBER(19),
  FILE_ORIGINALE_MOD   NUMBER(1)                DEFAULT 0                     NOT NULL,
  FILE_STORICI_MOD     NUMBER(1)                DEFAULT 0                     NOT NULL,
  ID_MODELLO_TESTO     NUMBER(19),
  MODELLO_TESTO_MOD    NUMBER(1)                DEFAULT 0                     NOT NULL,
  DATA_LOG             DATE
)
/

CREATE TABLE WKF_ENGINE_ITER_LOG
(
  ID_ENGINE_ITER     NUMBER(19)                 NOT NULL,
  REV                NUMBER(19)                 NOT NULL,
  REVTYPE            NUMBER(3),
  REVEND             NUMBER(19),
  DATA_FINE          TIMESTAMP(6),
  DATA_FINE_MOD      NUMBER(1)                  DEFAULT 0                     NOT NULL,
  DATA_INIZIO        TIMESTAMP(6),
  DATA_INIZIO_MOD    NUMBER(1)                  DEFAULT 0                     NOT NULL,
  DATA_INS           TIMESTAMP(6),
  DATE_CREATED_MOD   NUMBER(1)                  DEFAULT 0                     NOT NULL,
  DATA_UPD           TIMESTAMP(6),
  LAST_UPDATED_MOD   NUMBER(1)                  DEFAULT 0                     NOT NULL,
  ID_CFG_ITER        NUMBER(19),
  CFG_ITER_MOD       NUMBER(1)                  DEFAULT 0                     NOT NULL,
  ENTE               VARCHAR2(255),
  ENTE_MOD           NUMBER(1)                  DEFAULT 0                     NOT NULL,
  ID_STEP_CORRENTE   NUMBER(19),
  STEP_CORRENTE_MOD  NUMBER(1)                  DEFAULT 0                     NOT NULL,
  UTENTE_INS         VARCHAR2(255),
  UTENTE_INS_MOD     NUMBER(1)                  DEFAULT 0                     NOT NULL,
  UTENTE_UPD         VARCHAR2(255),
  UTENTE_UPD_MOD     NUMBER(1)                  DEFAULT 0                     NOT NULL
)
/

CREATE INDEX AGP_PCLO_REVI_FK ON AGP_PROTOCOLLI_CORR_LOG
(REV)
/

CREATE INDEX AGP_PCLO_REVI2_FK ON AGP_PROTOCOLLI_CORR_LOG
(REVEND)
/

CREATE INDEX AGP_PCL_DATA_LOG_IK ON AGP_PROTOCOLLI_CORR_LOG
(DATA_LOG)
/

CREATE INDEX GDO_DCLO_REVI_FK ON GDO_DOCUMENTI_COLLEGATI_LOG
(REV)
/

CREATE INDEX GDO_DCLO_REVI2_FK ON GDO_DOCUMENTI_COLLEGATI_LOG
(REVEND)
/

CREATE INDEX GDO_DOLO_REVI_FK ON GDO_DOCUMENTI_LOG
(REV)
/

CREATE INDEX GDO_DOLO_REVI2_FK ON GDO_DOCUMENTI_LOG
(REVEND)
/

CREATE INDEX GDO_DL_DATA_LOG_IK ON GDO_DOCUMENTI_LOG
(DATA_LOG)
/

CREATE INDEX GDO_FDLO_REVI_FK ON GDO_FILE_DOCUMENTO_LOG
(REV)
/

CREATE INDEX GDO_FDLO_REVI2_FK ON GDO_FILE_DOCUMENTO_LOG
(REVEND)
/

CREATE INDEX GDO_FDL_DATA_LOG_IK ON GDO_FILE_DOCUMENTO_LOG
(DATA_LOG)
/

CREATE INDEX WKF_EILO_REVEND_FK ON WKF_ENGINE_ITER_LOG
(REVEND)
/

CREATE INDEX WKF_EILO_REV_FK ON WKF_ENGINE_ITER_LOG
(REV)
/

CREATE TABLE AGP_PROTOCOLLI_LOG
(
  ID_DOCUMENTO                    NUMBER(19)    NOT NULL,
  REV                             NUMBER(19)    NOT NULL,
  ANNO                            NUMBER(10),
  ANNO_MOD                        NUMBER(1)     DEFAULT 0                     NOT NULL,
  ANNO_EMERGENZA                  NUMBER(10),
  ANNO_EMERGENZA_MOD              NUMBER(1)     DEFAULT 0                     NOT NULL,
  ANNULLATO                       CHAR(1),
  ANNULLATO_MOD                   NUMBER(1)     DEFAULT 0                     NOT NULL,
  CAMPI_PROTETTI                  VARCHAR2(4000),
  CAMPI_PROTETTI_MOD              NUMBER(1)     DEFAULT 0                     NOT NULL,
  CODICE_RACCOMANDATA             VARCHAR2(255),
  CODICE_RACCOMANDATA_MOD         NUMBER(1)     DEFAULT 0                     NOT NULL,
  CONTROLLO_FIRMATARIO            CHAR(1),
  CONTROLLO_FIRMATARIO_MOD        NUMBER(1)     DEFAULT 0                     NOT NULL,
  CONTROLLO_FUNZIONARIO           CHAR(1),
  CONTROLLO_FUNZIONARIO_MOD       NUMBER(1)     DEFAULT 0                     NOT NULL,
  DATA                            TIMESTAMP(6),
  DATA_MOD                        NUMBER(1)     DEFAULT 0                     NOT NULL,
  DATA_ANNULLAMENTO               TIMESTAMP(6),
  DATA_ANNULLAMENTO_MOD           NUMBER(1)     DEFAULT 0                     NOT NULL,
  DATA_COMUNICAZIONE              TIMESTAMP(6),
  DATA_COMUNICAZIONE_MOD          NUMBER(1)     DEFAULT 0                     NOT NULL,
  DATA_DOCUMENTO_ESTERNO          TIMESTAMP(6),
  DATA_DOCUMENTO_ESTERNO_MOD      NUMBER(1)     DEFAULT 0                     NOT NULL,
  DATA_REDAZIONE                  TIMESTAMP(6),
  DATA_REDAZIONE_MOD              NUMBER(1)     DEFAULT 0                     NOT NULL,
  DATA_STATO_ARCHIVIO             TIMESTAMP(6),
  DATA_STATO_ARCHIVIO_MOD         NUMBER(1)     DEFAULT 0                     NOT NULL,
  DATA_VERIFICA                   TIMESTAMP(6),
  DATA_VERIFICA_MOD               NUMBER(1)     DEFAULT 0                     NOT NULL,
  ESITO_VERIFICA                  VARCHAR2(255),
  ESITO_VERIFICA_MOD              NUMBER(1)     DEFAULT 0                     NOT NULL,
  IDRIF                           VARCHAR2(255),
  IDRIF_MOD                       NUMBER(1)     DEFAULT 0                     NOT NULL,
  MOVIMENTO                       VARCHAR2(255),
  MOVIMENTO_MOD                   NUMBER(1)     DEFAULT 0                     NOT NULL,
  NOTE                            VARCHAR2(4000),
  NOTE_MOD                        NUMBER(1)     DEFAULT 0                     NOT NULL,
  NOTE_TRASMISSIONE               VARCHAR2(4000),
  NOTE_TRASMISSIONE_MOD           NUMBER(1)     DEFAULT 0                     NOT NULL,
  NUMERO                          NUMBER(10),
  NUMERO_MOD                      NUMBER(1)     DEFAULT 0                     NOT NULL,
  NUMERO_DOCUMENTO_ESTERNO        VARCHAR2(255),
  NUMERO_DOCUMENTO_ESTERNO_MOD    NUMBER(1)     DEFAULT 0                     NOT NULL,
  NUMERO_EMERGENZA                NUMBER(10),
  NUMERO_EMERGENZA_MOD            NUMBER(1)     DEFAULT 0                     NOT NULL,
  OGGETTO                         VARCHAR2(4000),
  OGGETTO_MOD                     NUMBER(1)     DEFAULT 0                     NOT NULL,
  PROVVEDIMENTO_ANNULLAMENTO      VARCHAR2(255),
  PROVVEDIMENTO_ANNULLAMENTO_MOD  NUMBER(1)     DEFAULT 0                     NOT NULL,
  REGISTRO_EMERGENZA              VARCHAR2(255),
  REGISTRO_EMERGENZA_MOD          NUMBER(1)     DEFAULT 0                     NOT NULL,
  STATO_ARCHIVIO                  VARCHAR2(255),
  STATO_ARCHIVIO_MOD              NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_CLASSIFICAZIONE              NUMBER(19),
  CLASSIFICAZIONE_MOD             NUMBER(1)     DEFAULT 0                     NOT NULL,
  CORRISPONDENTI_MOD              NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_PROTOCOLLO_DATI_EMERGENZA    NUMBER(19),
  DATI_EMERGENZA_MOD              NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_PROTOCOLLO_DATI_INTEROP      NUMBER(19),
  DATI_INTEROPERABILITA_MOD       NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_PROTOCOLLO_DATI_SCARTO       NUMBER(19),
  DATI_SCARTO_MOD                 NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_FASCICOLO                    NUMBER(19),
  FASCICOLO_MOD                   NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_MODALITA_INVIO_RICEZIONE     NUMBER(19),
  MODALITA_INVIO_RICEZIONE_MOD    NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_SCHEMA_PROTOCOLLO            NUMBER(19),
  SCHEMA_PROTOCOLLO_MOD           NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_TIPO_PROTOCOLLO              NUMBER(19),
  TIPO_PROTOCOLLO_MOD             NUMBER(1)     DEFAULT 0                     NOT NULL,
  TIPO_REGISTRO                   VARCHAR2(255),
  TIPO_REGISTRO_MOD               NUMBER(1)     DEFAULT 0                     NOT NULL,
  UTENTE_ANNULLAMENTO             VARCHAR2(255),
  UTENTE_ANNULLAMENTO_MOD         NUMBER(1)     DEFAULT 0                     NOT NULL,
  ID_PROTOCOLLO_DATI_REG_GIORN    NUMBER(19),
  REGISTRO_GIORNALIERO_MOD        NUMBER(1)     DEFAULT 0                     NOT NULL
)
/

CREATE TABLE GDO_ALLEGATI_LOG
(
  ID_DOCUMENTO       NUMBER(19)                 NOT NULL,
  REV                NUMBER(19)                 NOT NULL,
  COMMENTO           VARCHAR2(255),
  COMMENTO_MOD       NUMBER(1)                  DEFAULT 0                     NOT NULL,
  DESCRIZIONE        VARCHAR2(255),
  DESCRIZIONE_MOD    NUMBER(1)                  DEFAULT 0                     NOT NULL,
  NUM_PAGINE         NUMBER(10),
  NUM_PAGINE_MOD     NUMBER(1)                  DEFAULT 0                     NOT NULL,
  ORIGINE            VARCHAR2(255),
  ORIGINE_MOD        NUMBER(1)                  DEFAULT 0                     NOT NULL,
  QUANTITA           NUMBER(10),
  QUANTITA_MOD       NUMBER(1)                  DEFAULT 0                     NOT NULL,
  SEQUENZA           NUMBER(10),
  SEQUENZA_MOD       NUMBER(1)                  DEFAULT 0                     NOT NULL,
  STAMPA_UNICA       CHAR(1),
  STAMPA_UNICA_MOD   NUMBER(1)                  DEFAULT 0                     NOT NULL,
  UBICAZIONE         VARCHAR2(255),
  UBICAZIONE_MOD     NUMBER(1)                  DEFAULT 0                     NOT NULL,
  ID_TIPO_ALLEGATO   NUMBER(19),
  TIPO_ALLEGATO_MOD  NUMBER(1)                  DEFAULT 0                     NOT NULL
)
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG ADD (
  CONSTRAINT AGP_MSG_RICEVUTI_DATI_PROT__PK
  PRIMARY KEY
  (ID_DOCUMENTO, REV)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_PROTOCOLLI_CORR_LOG ADD (
  CONSTRAINT AGP_PCLO_PK
  PRIMARY KEY
  (ID_PROTOCOLLO_CORRISPONDENTE, REV)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_PROTOCOLLI_DATI_SCARTO_LOG ADD (
  CONSTRAINT AGP_PROT_DATI_SCARTO_LOG_PK
  PRIMARY KEY
  (ID_PROTOCOLLO_DATI_SCARTO, REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_DOCUMENTI_COLLEGATI_LOG ADD (
  CONSTRAINT GDO_DCLO_PK
  PRIMARY KEY
  (ID_DOCUMENTO_COLLEGATO, REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_DOCUMENTI_LOG ADD (
  CONSTRAINT GDO_DOLO_PK
  PRIMARY KEY
  (ID_DOCUMENTO, REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_FILE_DOCUMENTO_LOG ADD (
  CONSTRAINT GDO_FDLO_PK
  PRIMARY KEY
  (ID_FILE_DOCUMENTO, REV)
  ENABLE VALIDATE)
/

ALTER TABLE WKF_ENGINE_ITER_LOG ADD (
  CONSTRAINT WKF_EILO_PK
  PRIMARY KEY
  (ID_ENGINE_ITER, REV)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_PROTOCOLLI_LOG ADD (
  CONSTRAINT AGP_PRLO_PK
  PRIMARY KEY
  (ID_DOCUMENTO, REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_ALLEGATI_LOG ADD (
  CONSTRAINT GDO_ALLO_PK
  PRIMARY KEY
  (ID_DOCUMENTO, REV)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_PROTOCOLLI_CORR_LOG ADD (
  CONSTRAINT AGP_PCLO_REVI_FK
  FOREIGN KEY (REV)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_PROTOCOLLI_CORR_LOG ADD (
  CONSTRAINT AGP_PCLO_REVI2_FK
  FOREIGN KEY (REVEND)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_DOCUMENTI_COLLEGATI_LOG ADD (
  CONSTRAINT GDO_DCLO_REVI_FK
  FOREIGN KEY (REV)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_DOCUMENTI_COLLEGATI_LOG ADD (
  CONSTRAINT GDO_DCLO_REVI2_FK
  FOREIGN KEY (REVEND)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_DOCUMENTI_LOG ADD (
  CONSTRAINT GDO_DOLO_REVI_FK
  FOREIGN KEY (REV)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_DOCUMENTI_LOG ADD (
  CONSTRAINT GDO_DOLO_REVI2_FK
  FOREIGN KEY (REVEND)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_FILE_DOCUMENTO_LOG ADD (
  CONSTRAINT GDO_FDLO_REVI_FK
  FOREIGN KEY (REV)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_FILE_DOCUMENTO_LOG ADD (
  CONSTRAINT GDO_FDLO_REVI2_FK
  FOREIGN KEY (REVEND)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE WKF_ENGINE_ITER_LOG ADD (
  CONSTRAINT WKF_EILO_REVEND_FK
  FOREIGN KEY (REVEND)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE WKF_ENGINE_ITER_LOG ADD (
  CONSTRAINT WKF_EILO_REV_FK
  FOREIGN KEY (REV)
  REFERENCES REVINFO (REV)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_PROTOCOLLI_LOG ADD (
  CONSTRAINT AGP_PRLO_DOLO_FK
  FOREIGN KEY (ID_DOCUMENTO, REV)
  REFERENCES GDO_DOCUMENTI_LOG (ID_DOCUMENTO,REV)
  ENABLE VALIDATE)
/

ALTER TABLE GDO_ALLEGATI_LOG ADD (
  CONSTRAINT GDO_ALLO_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO, REV)
  REFERENCES GDO_DOCUMENTI_LOG (ID_DOCUMENTO,REV)
  ENABLE VALIDATE)
/

CREATE OR REPLACE TRIGGER AGP_PROTOCOLLI_CORR_LOG_TIU
   BEFORE INSERT OR UPDATE
   ON AGP_PROTOCOLLI_CORR_LOG
   FOR EACH ROW
BEGIN
   --in fase di eliminazione imposto la data_upd uguale alla data di sistema
   IF (:NEW.REVTYPE = 2) THEN
      :NEW.DATA_UPD   := SYSDATE;
   END IF;

   :NEW.DATA_LOG   := TRUNC (:NEW.DATA_UPD);
END AGP_PROTOCOLLI_CORR_LOG_TIU;
/

CREATE OR REPLACE TRIGGER GDO_DOCUMENTI_LOG_TIU
   BEFORE INSERT OR UPDATE
   ON GDO_DOCUMENTI_LOG
   FOR EACH ROW
BEGIN
   :NEW.DATA_LOG   := TRUNC (:NEW.DATA_UPD);
END GDO_DOCUMENTI_LOG_TIU;
/

CREATE OR REPLACE TRIGGER GDO_FILE_DOCUMENTO_LOG_TIU
   BEFORE INSERT OR UPDATE
   ON GDO_FILE_DOCUMENTO_LOG
   FOR EACH ROW
BEGIN
   --in fase di eliminazione imposto la data_upd uguale alla data di sistema
   IF (:NEW.REVTYPE = 2) THEN
      :NEW.DATA_UPD   := SYSDATE;
   END IF;

   :NEW.DATA_LOG   := TRUNC (:NEW.DATA_UPD);
END GDO_FILE_DOCUMENTO_LOG_TIU;
/

--changeset rdestasio:4.0.0.0_20200317_036.storico.envers failOnError:false
ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG
   DROP CONSTRAINT AGP_MSG_RICEVUTI_DATI_PROT__PK
/

ALTER TABLE AGP_MSG_RICEVUTI_DATI_PROT_LOG ADD (
  CONSTRAINT AGP_MSG_RICE_DATI_PROT_LOG_PK
  PRIMARY KEY
  (ID_DOCUMENTO, rev)
  ENABLE VALIDATE)
/
