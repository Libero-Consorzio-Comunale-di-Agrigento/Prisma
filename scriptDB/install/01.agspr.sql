--liquibase formatted sql
--changeset esasdelli:20200219

CREATE SEQUENCE HIBERNATE_SEQUENCE
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
/

CREATE TABLE AGP_DOCUMENTI_DATI_SCARTO
(
  ID_DOCUMENTO       NUMBER                     NOT NULL,
  DATA_NULLA_OSTA    DATE,
  NUMERO_NULLA_OSTA  VARCHAR2(255 BYTE),
  DATA_SCARTO        DATE,
  STATO_SCARTO       VARCHAR2(20 BYTE)
)
/


CREATE TABLE AGP_DOCUMENTI_SMISTAMENTI
(
  ID_DOCUMENTO_SMISTAMENTO   NUMBER             NOT NULL,
  ID_DOCUMENTO               NUMBER,
  UNITA_TRASMISSIONE_PROGR   NUMBER,
  UNITA_TRASMISSIONE_DAL     DATE,
  UNITA_TRASMISSIONE_OTTICA  VARCHAR2(255 BYTE),
  UTENTE_TRASMISSIONE        VARCHAR2(20 BYTE),
  UNITA_SMISTAMENTO_PROGR    NUMBER,
  UNITA_SMISTAMENTO_DAL      DATE,
  UNITA_SMISTAMENTO_OTTICA   VARCHAR2(255 BYTE),
  DATA_SMISTAMENTO           DATE,
  STATO_SMISTAMENTO          VARCHAR2(255 BYTE),
  TIPO_SMISTAMENTO           VARCHAR2(255 BYTE),
  UTENTE_PRESA_IN_CARICO     VARCHAR2(20 BYTE),
  DATA_PRESA_IN_CARICO       DATE,
  UTENTE_ESECUZIONE          VARCHAR2(20 BYTE),
  DATA_ESECUZIONE            DATE,
  UTENTE_ASSEGNANTE          VARCHAR2(20 BYTE),
  UTENTE_ASSEGNATARIO        VARCHAR2(20 BYTE),
  DATA_ASSEGNAZIONE          DATE,
  NOTE                       VARCHAR2(4000 BYTE),
  NOTE_UTENTE                VARCHAR2(4000 BYTE),
  VERSION                    NUMBER,
  VALIDO                     CHAR(1 BYTE),
  UTENTE_INS                 VARCHAR2(20 BYTE),
  DATA_INS                   DATE,
  UTENTE_UPD                 VARCHAR2(20 BYTE),
  DATA_UPD                   DATE,
  ID_DOCUMENTO_ESTERNO       NUMBER,
  UTENTE_RIFIUTO             VARCHAR2(20 BYTE),
  DATA_RIFIUTO               DATE,
  MOTIVO_RIFIUTO             VARCHAR2(4000 BYTE)
)
/


CREATE TABLE AGP_DOCUMENTI_TITOLARIO
(
  ID_DOCUMENTO_TITOLARIO  NUMBER                NOT NULL,
  ID_DOCUMENTO            NUMBER                NOT NULL,
  ID_CLASSIFICAZIONE      NUMBER                NOT NULL,
  ID_FASCICOLO            NUMBER,
  VERSION                 NUMBER,
  VALIDO                  CHAR(1 BYTE),
  UTENTE_INS              VARCHAR2(20 BYTE),
  DATA_INS                DATE,
  UTENTE_UPD              VARCHAR2(20 BYTE),
  DATA_UPD                DATE
)
/


CREATE TABLE AGP_MESSAGGI_CORRISPONDENTI
(
  ID_MESSAGGIO_CORRISPONDENTE   NUMBER          NOT NULL,
  ID_MESSAGGIO                  NUMBER          NOT NULL,
  DENOMINAZIONE                 VARCHAR2(4000 BYTE),
  EMAIL                         VARCHAR2(255 BYTE) NOT NULL,
  CONOSCENZA                    CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  DATA_SPEDIZIONE               DATE,
  REGISTRATA_CONSEGNA           CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  RIC_MANCATA_CONSEGNA          CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  RICEVUTA_CONFERMA             CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  DATA_RIC_CONFERMA             DATE,
  RICEVUTO_AGGIORNAMENTO        CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  DATA_RIC_AGGIORNAMENTO        DATE,
  RICEVUTO_ANNULLAMENTO         CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  DATA_RIC_ANNULLAMENTO         DATE,
  RICEVUTA_ECCEZIONE            CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  DATA_RIC_ECCEZIONE            DATE,
  REG_CONSEGNA_CONFERMA         CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  RIC_MANCATA_CONSEGNA_CONF     CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  REG_CONSEGNA_AGGIORNAMENTO    CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  RIC_MANCATA_CONSEGNA_AGG      CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  REG_CONSEGNA_ANNULLAMENTO     CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  RIC_MANCATA_CONSEGNA_ANN      CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  ID_PROTOCOLLO_CORRISPONDENTE  NUMBER          NOT NULL,
  UTENTE_INS                    VARCHAR2(255 BYTE),
  DATA_INS                      DATE,
  UTENTE_UPD                    VARCHAR2(255 BYTE),
  DATA_UPD                      DATE,
  VERSION                       NUMBER          NOT NULL,
  VALIDO                        CHAR(1 BYTE)
)
/


CREATE TABLE AGP_PROTOCOLLI
(
  ID_DOCUMENTO                 NUMBER           NOT NULL,
  ANNO                         NUMBER,
  TIPO_REGISTRO                VARCHAR2(255 BYTE),
  NUMERO                       NUMBER,
  DATA                         DATE,
  ID_TIPO_PROTOCOLLO           NUMBER,
  MOVIMENTO                    VARCHAR2(10 BYTE),
  OGGETTO                      VARCHAR2(4000 BYTE),
  DATA_VERIFICA                DATE,
  ESITO_VERIFICA               VARCHAR2(255 BYTE),
  ANNULLATO                    CHAR(1 BYTE)     DEFAULT 'N'                   NOT NULL,
  CONTROLLO_FUNZIONARIO        CHAR(1 BYTE)     DEFAULT 'N'                   NOT NULL,
  NOTE                         VARCHAR2(4000 BYTE),
  NOTE_TRASMISSIONE            VARCHAR2(4000 BYTE),
  IDRIF                        VARCHAR2(255 BYTE),
  ID_CLASSIFICAZIONE           NUMBER,
  ID_FASCICOLO                 NUMBER,
  DATA_REDAZIONE               DATE,
  ID_SCHEMA_PROTOCOLLO         NUMBER,
  ID_MODALITA_INVIO_RICEZIONE  NUMBER,
  DATA_ANNULLAMENTO            DATE,
  UTENTE_ANNULLAMENTO          VARCHAR2(255 BYTE),
  PROVVEDIMENTO_ANNULLAMENTO   VARCHAR2(255 BYTE),
  CONTROLLO_FIRMATARIO         CHAR(1 BYTE)     DEFAULT 'Y'                   NOT NULL,
  DATA_COMUNICAZIONE           DATE,
  DATA_DOCUMENTO_ESTERNO       DATE,
  NUMERO_DOCUMENTO_ESTERNO     VARCHAR2(255 BYTE),
  STATO_ARCHIVIO               VARCHAR2(255 BYTE),
  DATA_STATO_ARCHIVIO          DATE,
  CODICE_RACCOMANDATA          VARCHAR2(255 BYTE),
  ID_PROTOCOLLO_DATI_SCARTO    NUMBER,
  ID_PROTOCOLLO_DATI_INTEROP   NUMBER,
  CAMPI_PROTETTI               VARCHAR2(4000 BYTE)
)
/

COMMENT ON COLUMN AGP_PROTOCOLLI.DATA_COMUNICAZIONE IS 'Data di arrivo o spedizione'
/


CREATE TABLE AGP_PROTOCOLLI_ANNULLAMENTI
(
  ID_PROTOCOLLO_ANNULLAMENTO  NUMBER            NOT NULL,
  ID_DOCUMENTO                NUMBER            NOT NULL,
  MOTIVO                      VARCHAR2(4000 BYTE),
  STATO                       VARCHAR2(255 BYTE),
  UNITA_PROGR                 NUMBER,
  UNITA_DAL                   DATE,
  UNITA_OTTICA                VARCHAR2(255 BYTE),
  UTENTE_ACC_RIF              VARCHAR2(255 BYTE),
  DATA_ACC_RIF                DATE,
  MOTIVO_RIFIUTO              VARCHAR2(255 BYTE),
  VALIDO                      CHAR(1 BYTE)      DEFAULT 'Y',
  UTENTE_INS                  VARCHAR2(255 BYTE),
  DATA_INS                    DATE,
  UTENTE_UPD                  VARCHAR2(255 BYTE),
  DATA_UPD                    DATE,
  VERSION                     NUMBER            NOT NULL
)
/


CREATE TABLE AGP_PROTOCOLLI_CORR_INDIRIZZI
(
  ID_PROTOCOLLO_CORR_INDIRIZZO  NUMBER          NOT NULL,
  ID_PROTOCOLLO_CORRISPONDENTE  NUMBER          NOT NULL,
  INDIRIZZO                     VARCHAR2(4000 BYTE),
  CAP                           VARCHAR2(255 BYTE),
  COMUNE                        VARCHAR2(255 BYTE),
  PROVINCIA_SIGLA               VARCHAR2(10 BYTE),
  EMAIL                         VARCHAR2(255 BYTE),
  FAX                           VARCHAR2(255 BYTE),
  TIPO_INDIRIZZO                VARCHAR2(20 BYTE),
  CODICE                        VARCHAR2(255 BYTE),
  DENOMINAZIONE                 VARCHAR2(4000 BYTE),
  UTENTE_INS                    VARCHAR2(255 BYTE),
  DATA_INS                      DATE,
  UTENTE_UPD                    VARCHAR2(255 BYTE),
  DATA_UPD                      DATE,
  VERSION                       NUMBER          NOT NULL,
  VALIDO                        CHAR(1 BYTE)
)
/


CREATE TABLE AGP_PROTOCOLLI_CORRISPONDENTI
(
  ID_PROTOCOLLO_CORRISPONDENTE  NUMBER          NOT NULL,
  ID_DOCUMENTO                  NUMBER          NOT NULL,
  DENOMINAZIONE                 VARCHAR2(4000 BYTE),
  COGNOME                       VARCHAR2(255 BYTE),
  NOME                          VARCHAR2(255 BYTE),
  CODICE_FISCALE                VARCHAR2(255 BYTE),
  PARTITA_IVA                   VARCHAR2(255 BYTE),
  INDIRIZZO                     VARCHAR2(4000 BYTE),
  CAP                           VARCHAR2(255 BYTE),
  COMUNE                        VARCHAR2(255 BYTE),
  PROVINCIA_SIGLA               VARCHAR2(10 BYTE),
  EMAIL                         VARCHAR2(255 BYTE),
  FAX                           VARCHAR2(255 BYTE),
  CONOSCENZA                    CHAR(1 BYTE)    DEFAULT 'N'                   NOT NULL,
  TIPO_INDIRIZZO                VARCHAR2(255 BYTE),
  TIPO_CORRISPONDENTE           VARCHAR2(4 BYTE),
  TIPO_SOGGETTO                 NUMBER,
  BC_SPEDIZIONE                 VARCHAR2(255 BYTE),
  DATA_SPEDIZIONE               DATE,
  ID_DOCUMENTO_ESTERNO          NUMBER,
  UTENTE_INS                    VARCHAR2(255 BYTE),
  DATA_INS                      DATE,
  UTENTE_UPD                    VARCHAR2(255 BYTE),
  DATA_UPD                      DATE,
  VERSION                       NUMBER          NOT NULL,
  VALIDO                        CHAR(1 BYTE),
  ID_MODALITA_INVIO_RICEZIONE   NUMBER
)
/


CREATE TABLE AGP_PROTOCOLLI_DATI_ACCESSO
(
  ID_DATI_ACCESSO              NUMBER           NOT NULL,
  ID_PROTOCOLLO_DOMANDA        NUMBER           NOT NULL,
  ID_TIPO_ACCESSO_CIVICO       NUMBER,
  ID_TIPO_RICHIEDENTE_ACCESSO  NUMBER,
  DATA_PRESENTAZIONE           DATE,
  OGGETTO                      VARCHAR2(4000 BYTE),
  UNITA_COMPETENTE_PROGR       NUMBER,
  UNITA_COMPETENTE_DAL         DATE,
  UNITA_COMPETENTE_OTTICA      VARCHAR2(255 BYTE),
  PUBBLICA_DOMANDA             CHAR(1 BYTE)     DEFAULT 'N',
  ID_PROTOCOLLO_RISPOSTA       NUMBER,
  CONTROINTERESSATI            CHAR(1 BYTE)     DEFAULT 'N',
  ID_TIPO_ESITO                NUMBER,
  DATA_PROVVEDIMENTO           DATE,
  MOTIVO_RIFIUTO               VARCHAR2(4000 BYTE),
  UNITA_COMP_RIESAME_PROGR     NUMBER,
  UNITA_COMP_RIESAME_DAL       DATE,
  UNITA_COMP_RIESAME_OTTICA    VARCHAR2(255 BYTE),
  PUBBLICA                     CHAR(1 BYTE)     DEFAULT 'N',
  VERSION                      NUMBER           DEFAULT 0                     NOT NULL,
  UTENTE_INS                   VARCHAR2(255 BYTE) NOT NULL,
  DATA_INS                     DATE             NOT NULL,
  UTENTE_UPD                   VARCHAR2(255 BYTE),
  DATA_UPD                     DATE
)
/


CREATE TABLE AGP_PROTOCOLLI_DATI_INTEROP
(
  ID_PROTOCOLLO_DATI_INTEROP      NUMBER        NOT NULL,
  CODICE_AMM_PRIMA_REGISTRAZIONE  VARCHAR2(255 BYTE),
  CODICE_AOO_PRIMA_REGISTRAZIONE  VARCHAR2(255 BYTE),
  DATA_PRIMA_REGISTRAZIONE        DATE,
  NUMERO_PRIMA_REGISTRAZIONE      VARCHAR2(255 BYTE),
  CODICE_REG_PRIMA_REGISTRAZIONE  VARCHAR2(255 BYTE),
  RICHIESTA_CONFERMA              CHAR(1 BYTE)  DEFAULT 'N'                   NOT NULL,
  INVIATA_CONFERMA                CHAR(1 BYTE)  DEFAULT 'N'                   NOT NULL,
  ID_MESSAGGIO_CONFERMA           NUMBER,
  RICEVUTA_ACCETTAZIONE_CONFERMA  CHAR(1 BYTE)  DEFAULT 'N'                   NOT NULL,
  UTENTE_INS                      VARCHAR2(255 BYTE),
  DATA_INS                        DATE,
  UTENTE_UPD                      VARCHAR2(255 BYTE),
  DATA_UPD                        DATE,
  VERSION                         NUMBER        NOT NULL,
  MOTIVO_INTERVENTO_OPERAT_OLD    VARCHAR2(4000 BYTE),
  MOTIVO_INTERVENTO_OPERATORE     CLOB
)
/


CREATE TABLE AGP_PROTOCOLLI_DATI_SCARTO
(
  ID_PROTOCOLLO_DATI_SCARTO  NUMBER             NOT NULL,
  STATO                      VARCHAR2(255 BYTE),
  DATA_STATO                 DATE,
  NULLA_OSTA                 VARCHAR2(255 BYTE),
  DATA_NULLA_OSTA            DATE,
  UTENTE_INS                 VARCHAR2(255 BYTE),
  DATA_INS                   DATE,
  UTENTE_UPD                 VARCHAR2(255 BYTE),
  DATA_UPD                   DATE,
  VERSION                    NUMBER             NOT NULL
)
/


CREATE TABLE AGP_SCHEMI_COLLEGATI
(
  ID_SCHEMA_COLLEGATO   NUMBER(19)              NOT NULL,
  VERSION               NUMBER(19)              NOT NULL,
  ID_COLLEGATO          NUMBER(19)              NOT NULL,
  DATA_INS              DATE                    NOT NULL,
  ID_SCHEMA_PROTOCOLLO  NUMBER(19)              NOT NULL,
  DATA_UPD              DATE                    NOT NULL,
  UTENTE_INS            VARCHAR2(255 BYTE)      NOT NULL,
  UTENTE_UPD            VARCHAR2(255 BYTE)      NOT NULL,
  VALIDO                CHAR(1 BYTE)            NOT NULL
)
/


CREATE TABLE AGP_SCHEMI_PROT_ALLEGATI
(
  ID_SCHEMA_PROT_ALLEGATI  NUMBER               NOT NULL,
  ID_SCHEMA_PROTOCOLLO     NUMBER               NOT NULL,
  CONTENT_TYPE             VARCHAR2(255 BYTE)   NOT NULL,
  DIMENSIONE               NUMBER,
  ID_FILE_ESTERNO          NUMBER,
  NOME                     VARCHAR2(255 BYTE)   NOT NULL,
  ID_TIPO_ALLEGATO         NUMBER,
  SEQUENZA                 NUMBER               DEFAULT 0                     NOT NULL,
  UTENTE_INS               VARCHAR2(255 BYTE)   NOT NULL,
  DATA_INS                 DATE                 NOT NULL,
  UTENTE_UPD               VARCHAR2(255 BYTE)   NOT NULL,
  DATA_UPD                 DATE                 NOT NULL,
  VALIDO                   CHAR(1 BYTE)         DEFAULT 'Y'                   NOT NULL,
  VERSION                  NUMBER               DEFAULT 0                     NOT NULL
)
/


CREATE TABLE AGP_TIPI_ACCESSO_CIVICO
(
  ID_TIPO_ACCESSO_CIVICO  NUMBER                NOT NULL,
  CODICE                  VARCHAR2(255 BYTE)    NOT NULL,
  DESCRIZIONE             VARCHAR2(255 BYTE)    NOT NULL,
  COMMENTO                VARCHAR2(4000 BYTE),
  ID_ENTE                 NUMBER                NOT NULL,
  UTENTE_INS              VARCHAR2(255 BYTE)    NOT NULL,
  DATA_INS                DATE                  NOT NULL,
  UTENTE_UPD              VARCHAR2(255 BYTE)    NOT NULL,
  DATA_UPD                DATE                  NOT NULL,
  VALIDO                  CHAR(1 BYTE)          DEFAULT 'Y'                   NOT NULL,
  VERSION                 NUMBER                DEFAULT 0                     NOT NULL
)
/


CREATE TABLE AGP_TIPI_ESITO_ACCESSO
(
  ID_TIPO_ESITO  NUMBER                         NOT NULL,
  CODICE         VARCHAR2(255 BYTE)             NOT NULL,
  DESCRIZIONE    VARCHAR2(255 BYTE)             NOT NULL,
  COMMENTO       VARCHAR2(4000 BYTE),
  TIPO           VARCHAR2(8 BYTE)               NOT NULL,
  ID_ENTE        NUMBER                         NOT NULL,
  UTENTE_INS     VARCHAR2(255 BYTE)             NOT NULL,
  DATA_INS       DATE                           NOT NULL,
  UTENTE_UPD     VARCHAR2(255 BYTE)             NOT NULL,
  DATA_UPD       DATE                           NOT NULL,
  VALIDO         CHAR(1 BYTE)                   DEFAULT 'Y'                   NOT NULL,
  VERSION        NUMBER                         NOT NULL
)
/


CREATE TABLE AGP_TIPI_PROTOCOLLO
(
  ID_TIPO_PROTOCOLLO    NUMBER                  NOT NULL,
  FUNZ_OBBLIGATORIO     CHAR(1 BYTE)            DEFAULT 'N'                   NOT NULL,
  ID_TIPO_REGISTRO      VARCHAR2(255 BYTE),
  CATEGORIA             VARCHAR2(255 BYTE)      DEFAULT 'LETTERA'             NOT NULL,
  MOVIMENTO             VARCHAR2(10 BYTE),
  RUOLO_UNITA_DEST      VARCHAR2(255 BYTE),
  UNITA_DEST_DAL        DATE,
  UNITA_DEST_OTTICA     VARCHAR2(255 BYTE),
  UNITA_DEST_PROGR      NUMBER(19),
  FIRM_OBBLIGATORIO     CHAR(1 BYTE)            DEFAULT 'Y'                   NOT NULL,
  FIRM_VISIBILE         CHAR(1 BYTE)            DEFAULT 'Y',
  FUNZ_VISIBILE         CHAR(1 BYTE)            DEFAULT 'Y',
  ID_SCHEMA_PROTOCOLLO  NUMBER
)
/


CREATE TABLE AGP_TIPI_RICHIEDENTE_ACCESSO
(
  ID_TIPO_RICHIEDENTE_ACCESSO  NUMBER           NOT NULL,
  CODICE                       VARCHAR2(255 BYTE) NOT NULL,
  DESCRIZIONE                  VARCHAR2(255 BYTE) NOT NULL,
  COMMENTO                     VARCHAR2(4000 BYTE),
  ID_ENTE                      NUMBER           NOT NULL,
  UTENTE_INS                   VARCHAR2(255 BYTE) NOT NULL,
  DATA_INS                     DATE             NOT NULL,
  UTENTE_UPD                   VARCHAR2(255 BYTE) NOT NULL,
  DATA_UPD                     DATE             NOT NULL,
  VALIDO                       CHAR(1 BYTE)     DEFAULT 'Y'                   NOT NULL,
  VERSION                      NUMBER           DEFAULT 0                     NOT NULL
)
/


CREATE TABLE FIRMA_DIGITALE_FILE
(
  ID                   NUMBER(19)               NOT NULL,
  VERSION              NUMBER(19)               NOT NULL,
  DATE_CREATED         DATE                     NOT NULL,
  FILE_DA_FIRMARE      BLOB,
  FILE_FIRMATO         BLOB,
  ID_RIFERIMENTO_FILE  VARCHAR2(255 BYTE),
  LAST_UPDATED         DATE                     NOT NULL,
  NOME                 VARCHAR2(200 BYTE)       NOT NULL,
  NOME_FIRMATO         VARCHAR2(255 BYTE),
  TRANSAZIONE_ID       NUMBER(19)               NOT NULL,
  UTENTE               VARCHAR2(255 BYTE)
)
/


CREATE TABLE FIRMA_DIGITALE_TRANSAZIONE
(
  ID            NUMBER(19)                      NOT NULL,
  VERSION       NUMBER(19)                      NOT NULL,
  DATA_FIRMA    DATE,
  DATE_CREATED  DATE                            NOT NULL,
  LAST_UPDATED  DATE                            NOT NULL,
  UTENTE        VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_ALLEGATI
(
  ID_DOCUMENTO      NUMBER(19)                  NOT NULL,
  COMMENTO          VARCHAR2(255 BYTE),
  DESCRIZIONE       VARCHAR2(255 BYTE),
  NUM_PAGINE        NUMBER(10),
  ORIGINE           VARCHAR2(255 BYTE),
  QUANTITA          NUMBER(10),
  SEQUENZA          NUMBER(10),
  STAMPA_UNICA      CHAR(1 BYTE),
  UBICAZIONE        VARCHAR2(255 BYTE),
  ID_TIPO_ALLEGATO  NUMBER                      NOT NULL
)
/


CREATE TABLE GDO_CODA_FIRMA
(
  ID_CODA_FIRMA                NUMBER(19)       NOT NULL,
  VERSION                      NUMBER(19)       NOT NULL,
  DATA_FIRMA                   DATE,
  DATA_INS                     DATE             NOT NULL,
  ID_DOCUMENTO                 NUMBER(19)       NOT NULL,
  ID_ENTE                      NUMBER(19)       NOT NULL,
  UTENTE_FIRMATARIO            VARCHAR2(255 BYTE) NOT NULL,
  FIRMATO                      CHAR(1 BYTE)     NOT NULL,
  DATA_UPD                     DATE             NOT NULL,
  SEQUENZA                     NUMBER(10)       NOT NULL,
  UTENTE_INS                   VARCHAR2(255 BYTE) NOT NULL,
  UTENTE_UPD                   VARCHAR2(255 BYTE) NOT NULL,
  VALIDO                       CHAR(1 BYTE)     NOT NULL,
  ID_TRANSAZIONE_FIRMA         NUMBER(19),
  UTENTE_FIRMATARIO_EFFETTIVO  VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_DOCUMENTI
(
  ID_DOCUMENTO          NUMBER                  NOT NULL,
  STATO                 VARCHAR2(255 BYTE),
  STATO_FIRMA           VARCHAR2(255 BYTE),
  STATO_CONSERVAZIONE   VARCHAR2(255 BYTE),
  ID_ENGINE_ITER        NUMBER,
  ID_DOCUMENTO_ESTERNO  NUMBER,
  ID_ENTE               NUMBER                  NOT NULL,
  TIPO_OGGETTO          VARCHAR2(255 BYTE),
  VALIDO                CHAR(1 BYTE)            DEFAULT 'Y',
  UTENTE_INS            VARCHAR2(255 BYTE),
  DATA_INS              DATE,
  UTENTE_UPD            VARCHAR2(255 BYTE),
  DATA_UPD              DATE,
  VERSION               NUMBER                  NOT NULL,
  RISERVATO             CHAR(1 BYTE)
)
/


CREATE TABLE GDO_DOCUMENTI_COLLEGATI
(
  ID_DOCUMENTO_COLLEGATO  NUMBER(19)            NOT NULL,
  VERSION                 NUMBER(19)            NOT NULL,
  ID_COLLEGATO            NUMBER(19)            NOT NULL,
  DATA_INS                DATE                  NOT NULL,
  ID_DOCUMENTO            NUMBER(19)            NOT NULL,
  DATA_UPD                DATE                  NOT NULL,
  ID_TIPO_COLLEGAMENTO    NUMBER(19)            NOT NULL,
  UTENTE_INS              VARCHAR2(255 BYTE)    NOT NULL,
  UTENTE_UPD              VARCHAR2(255 BYTE)    NOT NULL,
  VALIDO                  CHAR(1 BYTE)          NOT NULL
)
/


CREATE TABLE GDO_DOCUMENTI_COMPETENZE
(
  ID_DOCUMENTO_COMPETENZA  NUMBER(19)           NOT NULL,
  VERSION                  NUMBER(19)           NOT NULL,
  CANCELLAZIONE            CHAR(1 BYTE)         NOT NULL,
  ID_CFG_COMPETENZA        NUMBER(19),
  LETTURA                  CHAR(1 BYTE)         NOT NULL,
  MODIFICA                 CHAR(1 BYTE)         NOT NULL,
  ID_DOCUMENTO             NUMBER(19)           NOT NULL,
  RUOLO                    VARCHAR2(255 BYTE),
  UNITA_PROGR              NUMBER(19),
  UNITA_DAL                DATE,
  UNITA_OTTICA             VARCHAR2(255 BYTE),
  UTENTE                   VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_DOCUMENTI_SOGGETTI
(
  ID_DOCUMENTO_SOGGETTO  NUMBER(19)             NOT NULL,
  VERSION                NUMBER(19)             NOT NULL,
  ATTIVO                 CHAR(1 BYTE)           NOT NULL,
  ID_DOCUMENTO           NUMBER(19)             NOT NULL,
  SEQUENZA               NUMBER(10)             NOT NULL,
  TIPO_SOGGETTO          VARCHAR2(255 BYTE)     NOT NULL,
  UNITA_PROGR            NUMBER(19),
  UNITA_DAL              DATE,
  UNITA_OTTICA           VARCHAR2(255 BYTE),
  UTENTE                 VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_DOCUMENTI_STORICO
(
  ID_DOCUMENTO_STORICO  NUMBER                  NOT NULL,
  ID_DOCUMENTO          NUMBER                  NOT NULL,
  REVISIONE             NUMBER                  NOT NULL,
  DATI_STORICIZZATI     CLOB                    NOT NULL,
  DATI_MODIFICATI       CLOB,
  VALIDO                CHAR(1 BYTE)            DEFAULT 'Y'                   NOT NULL,
  UTENTE_INS            VARCHAR2(255 BYTE)      NOT NULL,
  DATA_INS              DATE                    NOT NULL,
  UTENTE_UPD            VARCHAR2(255 BYTE)      NOT NULL,
  DATA_UPD              DATE                    NOT NULL,
  VERSION               NUMBER                  NOT NULL
)
/


CREATE TABLE GDO_EMAIL
(
  ID_EMAIL         NUMBER(19)                   NOT NULL,
  VERSION          NUMBER(19)                   NOT NULL,
  COGNOME          VARCHAR2(255 BYTE),
  DATA_INS         DATE                         NOT NULL,
  INDIRIZZO_EMAIL  VARCHAR2(255 BYTE)           NOT NULL,
  DATA_UPD         DATE                         NOT NULL,
  NOME             VARCHAR2(255 BYTE),
  RAGIONE_SOCIALE  VARCHAR2(255 BYTE),
  UTENTE_INS       VARCHAR2(255 BYTE)           NOT NULL,
  UTENTE_UPD       VARCHAR2(255 BYTE)           NOT NULL,
  VALIDO           CHAR(1 BYTE)                 NOT NULL
)
/


CREATE TABLE GDO_ENTI
(
  ID_ENTE          NUMBER                       NOT NULL,
  AMMINISTRAZIONE  VARCHAR2(255 BYTE)           NOT NULL,
  AOO              VARCHAR2(255 BYTE),
  OTTICA           VARCHAR2(255 BYTE),
  DESCRIZIONE      VARCHAR2(255 BYTE)           NOT NULL,
  VALIDO           CHAR(1 BYTE)                 DEFAULT NULL                  NOT NULL,
  VERSION          NUMBER                       NOT NULL,
  SEQUENZA         NUMBER(10)                   NOT NULL
)
/


CREATE TABLE GDO_FILE_DOCUMENTO
(
  ID_FILE_DOCUMENTO          NUMBER             NOT NULL,
  ID_DOCUMENTO               NUMBER             NOT NULL,
  UTENTE_INS                 VARCHAR2(255 BYTE) NOT NULL,
  DATA_INS                   DATE               NOT NULL,
  UTENTE_UPD                 VARCHAR2(255 BYTE) NOT NULL,
  DATA_UPD                   DATE               NOT NULL,
  VERSION                    NUMBER             NOT NULL,
  CONTENT_TYPE               VARCHAR2(255 BYTE) NOT NULL,
  CODICE                     VARCHAR2(256 BYTE) DEFAULT 'ALLEGATO',
  DIMENSIONE                 NUMBER,
  FIRMATO                    CHAR(1 BYTE)       DEFAULT NULL                  NOT NULL,
  ID_FILE_ESTERNO            NUMBER,
  MODIFICABILE               CHAR(1 BYTE)       DEFAULT NULL                  NOT NULL,
  NOME                       VARCHAR2(255 BYTE) NOT NULL,
  TESTO                      CLOB,
  VALIDO                     CHAR(1 BYTE)       DEFAULT NULL                  NOT NULL,
  ID_MODELLO_TESTO           NUMBER(19),
  SEQUENZA                   NUMBER             DEFAULT 0                     NOT NULL,
  ID_FILE_DOCUMENTO_STORICO  NUMBER,
  REVISIONE_STORICO          NUMBER(19),
  FILE_ORIGINALE_ID          NUMBER(19),
  MARCATO                    CHAR(1 BYTE)       DEFAULT 'N'                   NOT NULL
)
/


CREATE TABLE GDO_FILE_DOCUMENTO_FIRMATARI
(
  ID_FIRMATARIO      NUMBER(19)                 NOT NULL,
  VERSION            NUMBER(19)                 NOT NULL,
  DATA_FIRMA         DATE,
  DATA_INS           DATE                       NOT NULL,
  ID_FILE_DOCUMENTO  NUMBER(19),
  DATA_UPD           DATE                       NOT NULL,
  SEQUENZA           NUMBER(10)                 NOT NULL,
  UTENTE_AD4         VARCHAR2(255 BYTE),
  UTENTE_INS         VARCHAR2(255 BYTE)         NOT NULL,
  UTENTE_UPD         VARCHAR2(255 BYTE)         NOT NULL,
  VALIDO             CHAR(1 BYTE)               NOT NULL,
  STATO              VARCHAR2(100 BYTE),
  NOMINATIVO         VARCHAR2(1000 BYTE),
  DATA_VERIFICA      DATE
)
/


CREATE TABLE GDO_NOTIFICHE
(
  ID_NOTIFICA              NUMBER(19)           NOT NULL,
  VERSION                  NUMBER(19)           NOT NULL,
  ALLEGATI                 VARCHAR2(255 BYTE),
  DATA_INS                 DATE                 NOT NULL,
  ID_ENTE                  NUMBER(19)           NOT NULL,
  DATA_UPD                 DATE                 NOT NULL,
  OGGETTI                  VARCHAR2(255 BYTE),
  OGGETTO                  VARCHAR2(4000 BYTE)  NOT NULL,
  TESTO                    VARCHAR2(4000 BYTE),
  TIPO_NOTIFICA            VARCHAR2(255 BYTE)   NOT NULL,
  TITOLO                   VARCHAR2(255 BYTE)   NOT NULL,
  UTENTE_INS               VARCHAR2(255 BYTE)   NOT NULL,
  UTENTE_UPD               VARCHAR2(255 BYTE)   NOT NULL,
  VALIDO                   CHAR(1 BYTE)         NOT NULL,
  VALIDO_AL                DATE,
  VALIDO_DAL               DATE                 NOT NULL,
  MODALITA_INVIO           VARCHAR2(255 BYTE),
  MESSAGGIO_TODO           VARCHAR2(4000 BYTE),
  TIPO_NOTIFICA_SCRIVANIA  VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_NOTIFICHE_ATTIVITA
(
  ID_NOTIFICA_ATTIVITA   NUMBER(19)             NOT NULL,
  VERSION                NUMBER(19)             NOT NULL,
  ID_ATTIVITA_JWORKLIST  VARCHAR2(255 BYTE)     NOT NULL,
  UNITA_PROGR            NUMBER(19),
  UNITA_DAL              DATE,
  UNITA_OTTICA           VARCHAR2(255 BYTE),
  UTENTE_AD4             VARCHAR2(255 BYTE)     NOT NULL,
  ID_DOCUMENTO           NUMBER(19),
  TIPO_NOTIFICA          VARCHAR2(255 BYTE)     NOT NULL,
  ID_RIFERIMENTO         VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_NOTIFICHE_DESTINATARI
(
  ID_NOTIFICA_DESTINATARIO  NUMBER(19)          NOT NULL,
  VERSION                   NUMBER(19)          NOT NULL,
  DATA_INS                  DATE                NOT NULL,
  EMAIL                     VARCHAR2(255 BYTE),
  ID_ENTE                   NUMBER(19)          NOT NULL,
  FUNZIONE                  VARCHAR2(255 BYTE),
  DATA_UPD                  DATE                NOT NULL,
  ID_NOTIFICA               NUMBER(19)          NOT NULL,
  RUOLO                     VARCHAR2(255 BYTE),
  ID_SOGGETTO               NUMBER(19),
  UNITA_PROGR               NUMBER(19),
  UNITA_DAL                 DATE,
  UNITA_OTTICA              VARCHAR2(255 BYTE),
  UTENTE_INS                VARCHAR2(255 BYTE)  NOT NULL,
  UTENTE_UPD                VARCHAR2(255 BYTE)  NOT NULL,
  VALIDO                    CHAR(1 BYTE)        NOT NULL,
  SEQUENZA                  NUMBER(10),
  ASSEGNAZIONE              VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_NOTIFICHE_EMAIL
(
  ID_NOTIFICA_EMAIL  NUMBER(19)                 NOT NULL,
  VERSION            NUMBER(19)                 NOT NULL,
  UNITA_PROGR        NUMBER(19),
  UNITA_DAL          DATE,
  UNITA_OTTICA       VARCHAR2(255 BYTE),
  TESTO              VARCHAR2(4000 BYTE),
  TIPO_NOTIFICA      VARCHAR2(255 BYTE),
  OGGETTO            VARCHAR2(255 BYTE),
  DESTINATARI        VARCHAR2(255 BYTE),
  ID_RIFERIMENTO     VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_TIPI_ALLEGATO
(
  ID_TIPO_DOCUMENTO  NUMBER(19)                 NOT NULL,
  STAMPA_UNICA       CHAR(1 BYTE)
)
/


CREATE TABLE GDO_TIPI_COLLEGAMENTO
(
  ID_TIPO_COLLEGAMENTO  NUMBER                  NOT NULL,
  TIPO_COLLEGAMENTO     VARCHAR2(255 BYTE)      NOT NULL,
  DESCRIZIONE           VARCHAR2(255 BYTE)      NOT NULL,
  COMMENTO              VARCHAR2(4000 BYTE),
  ID_ENTE               NUMBER                  NOT NULL,
  UTENTE_INS            VARCHAR2(255 BYTE)      NOT NULL,
  DATA_INS              DATE                    NOT NULL,
  UTENTE_UPD            VARCHAR2(255 BYTE)      NOT NULL,
  DATA_UPD              DATE                    NOT NULL,
  VALIDO                CHAR(1 BYTE)            DEFAULT 'Y'                   NOT NULL
)
/


CREATE TABLE GDO_TIPI_DOCUMENTO
(
  ID_TIPO_DOCUMENTO          NUMBER             NOT NULL,
  ID_ENTE                    NUMBER             NOT NULL,
  DESCRIZIONE                VARCHAR2(255 BYTE) NOT NULL,
  COMMENTO                   VARCHAR2(4000 BYTE),
  CONSERVAZIONE_SOSTITUTIVA  CHAR(1 BYTE)       NOT NULL,
  PROGRESSIVO_CFG_ITER       NUMBER,
  TESTO_OBBLIGATORIO         CHAR(1 BYTE)       NOT NULL,
  ID_TIPOLOGIA_SOGGETTO      NUMBER,
  VALIDO                     CHAR(1 BYTE)       NOT NULL,
  UTENTE_INS                 VARCHAR2(255 BYTE) NOT NULL,
  DATA_INS                   DATE               NOT NULL,
  UTENTE_UPD                 VARCHAR2(255 BYTE) NOT NULL,
  DATA_UPD                   DATE               NOT NULL,
  VERSION                    NUMBER             NOT NULL,
  CODICE                     VARCHAR2(255 BYTE),
  ACRONIMO                   VARCHAR2(255 BYTE)
)
/


CREATE TABLE GDO_TIPI_DOCUMENTO_COMPETENZE
(
  ID_TIPO_DOCUMENTO_COMPETENZE  NUMBER          NOT NULL,
  ID_TIPO_DOCUMENTO             NUMBER          NOT NULL,
  DESCRIZIONE                   VARCHAR2(255 BYTE) NOT NULL,
  RUOLO                         VARCHAR2(255 BYTE),
  UTENTE                        VARCHAR2(255 BYTE),
  UNITA_PROGR                   NUMBER,
  UNITA_DAL                     DATE,
  UNITA_OTTICA                  VARCHAR2(255 BYTE),
  CANCELLAZIONE                 CHAR(1 BYTE)    NOT NULL,
  LETTURA                       CHAR(1 BYTE)    NOT NULL,
  MODIFICA                      CHAR(1 BYTE)    NOT NULL,
  VERSION                       NUMBER          NOT NULL
)
/


CREATE TABLE GDO_TIPI_DOCUMENTO_MODELLI
(
  ID_TIPO_DOCUMENTO_MODELLO  NUMBER             NOT NULL,
  ID_TIPO_DOCUMENTO          NUMBER             NOT NULL,
  ID_MODELLO                 NUMBER             NOT NULL,
  PREDEFINITO                CHAR(1 BYTE)       DEFAULT 'N'                   NOT NULL,
  VERSION                    NUMBER             NOT NULL,
  CODICE                     VARCHAR2(255 BYTE) NOT NULL
)
/


CREATE TABLE GDO_TIPI_DOCUMENTO_PARERI
(
  ID_TIPO_DOCUMENTO_PARERE  NUMBER              NOT NULL,
  ID_TIPO_DOCUMENTO         NUMBER              NOT NULL,
  ID_TIPO_PARERE            NUMBER
)
/


CREATE TABLE GDO_TIPI_PARERE
(
  ID_TIPO_PARERE           NUMBER               NOT NULL,
  CODICE                   VARCHAR2(255 BYTE)   NOT NULL,
  DESCRIZIONE              VARCHAR2(255 BYTE)   NOT NULL,
  COMMENTO                 VARCHAR2(4000 BYTE),
  ID_ENTE                  NUMBER               NOT NULL,
  ID_TIPOLOGIA_SOGGETTO    NUMBER               NOT NULL,
  CON_FIRMA                CHAR(1 BYTE)         NOT NULL,
  CON_REDAZIONE_DIRIGENTE  CHAR(1 BYTE)         NOT NULL,
  CON_REDAZIONE_UNITA      CHAR(1 BYTE)         NOT NULL,
  CONTABILE                CHAR(1 BYTE)         NOT NULL,
  ID_MODELLO_TESTO         NUMBER,
  PROGRESSIVO_CFG_ITER     NUMBER,
  UNITA_DESTINATARIE       VARCHAR2(255 BYTE),
  VALIDO                   CHAR(1 BYTE)         NOT NULL,
  VALIDO_DAL               DATE                 NOT NULL,
  VALIDO_AL                DATE,
  STAMPA_UNICA             CHAR(1 BYTE)         DEFAULT 'Y'                   NOT NULL,
  SEQUENZA_STAMPA_UNICA    NUMBER(10)           NOT NULL,
  PUBBLICAZIONE            CHAR(1 BYTE)         DEFAULT 'Y'                   NOT NULL,
  TESTO_OBBLIGATORIO       CHAR(1 BYTE)         DEFAULT 'Y'                   NOT NULL,
  UTENTE_INS               VARCHAR2(255 BYTE)   NOT NULL,
  DATA_INS                 DATE                 NOT NULL,
  UTENTE_UPD               VARCHAR2(255 BYTE)   NOT NULL,
  DATA_UPD                 DATE                 NOT NULL,
  VERSION                  NUMBER               NOT NULL
)
/


CREATE TABLE GDO_TIPOLOGIE_SOGGETTO
(
  ID_TIPOLOGIA_SOGGETTO  NUMBER                 NOT NULL,
  DESCRIZIONE            VARCHAR2(255 BYTE),
  COMMENTO               VARCHAR2(4000 BYTE)    NOT NULL,
  LAYOUT_SOGGETTI        VARCHAR2(255 BYTE)     NOT NULL,
  TIPO_OGGETTO           VARCHAR2(255 BYTE)     NOT NULL,
  ID_ENTE                NUMBER                 NOT NULL,
  VALIDO                 CHAR(1 BYTE)           DEFAULT NULL                  NOT NULL,
  UTENTE_INS             VARCHAR2(255 BYTE)     NOT NULL,
  DATA_INS               DATE                   NOT NULL,
  UTENTE_UPD             VARCHAR2(255 BYTE)     NOT NULL,
  DATA_UPD               DATE                   NOT NULL,
  VERSION                NUMBER                 NOT NULL
)
/


CREATE TABLE GDO_TIPOLOGIE_SOGGETTO_REGOLE
(
  ID_TIPOLOGIA_SOGGETTO_REGOLA  NUMBER(19)      NOT NULL,
  VERSION                       NUMBER(19)      NOT NULL,
  DATA_INS                      DATE            NOT NULL,
  ID_ENTE                       NUMBER(19)      NOT NULL,
  DATA_UPD                      DATE            NOT NULL,
  REGOLA_DEFAULT_NOME_BEAN      VARCHAR2(255 BYTE),
  REGOLA_DEFAULT_NOME_METODO    VARCHAR2(255 BYTE),
  REGOLA_LISTA_NOME_BEAN        VARCHAR2(255 BYTE),
  REGOLA_LISTA_NOME_METODO      VARCHAR2(255 BYTE),
  RUOLO                         VARCHAR2(255 BYTE),
  SEQUENZA                      NUMBER(10)      NOT NULL,
  TIPO_SOGGETTO                 VARCHAR2(255 BYTE) NOT NULL,
  TIPO_SOGGETTO_PARTENZA        VARCHAR2(255 BYTE),
  ID_TIPOLOGIA_SOGGETTO         NUMBER(19)      NOT NULL,
  UTENTE_INS                    VARCHAR2(255 BYTE) NOT NULL,
  UTENTE_UPD                    VARCHAR2(255 BYTE) NOT NULL,
  VALIDO                        CHAR(1 BYTE)    NOT NULL
)
/


CREATE TABLE GDO_TOKEN_INTEGRAZIONI
(
  ID_TOKEN        NUMBER(19)                    NOT NULL,
  VERSION         NUMBER(19)                    NOT NULL,
  DATA_INS        DATE                          NOT NULL,
  DATI            VARCHAR2(255 BYTE),
  ID_RIFERIMENTO  VARCHAR2(255 BYTE)            NOT NULL,
  DATA_UPD        DATE                          NOT NULL,
  STATO           VARCHAR2(255 BYTE)            NOT NULL,
  TIPO            VARCHAR2(255 BYTE)            NOT NULL,
  UTENTE_INS      VARCHAR2(255 BYTE)            NOT NULL,
  UTENTE_UPD      VARCHAR2(255 BYTE)            NOT NULL,
  VALIDO          CHAR(1 BYTE)                  NOT NULL
)
/


CREATE TABLE GTE_DETTAGLI_LOCK
(
  ID_DETTAGLIO_LOCK   NUMBER(19)                NOT NULL,
  VERSION             NUMBER(19)                NOT NULL,
  DATA_FINE_LOCK      DATE,
  DATA_INIZIO_LOCK    DATE                      NOT NULL,
  ID_LOCK             VARCHAR2(255 BYTE)        NOT NULL,
  LOCK_PERMANENTE     NUMBER(1)                 NOT NULL,
  NOME_FILE           VARCHAR2(255 BYTE),
  NOTE                VARCHAR2(255 BYTE)        NOT NULL,
  ID_TIPO_MODELLO     VARCHAR2(255 BYTE),
  URL_DOCUMENTO       VARCHAR2(255 BYTE),
  UTENTE_FINE_LOCK    VARCHAR2(255 BYTE),
  UTENTE_INIZIO_LOCK  VARCHAR2(255 BYTE)
)
/


CREATE TABLE GTE_LOCK
(
  ID_RIFERIMENTO_TESTO  VARCHAR2(255 BYTE)      NOT NULL,
  VERSION               NUMBER(19)              NOT NULL,
  LOCKED                NUMBER(1)               NOT NULL
)
/


CREATE TABLE GTE_MODELLI
(
  ID_MODELLO     NUMBER(19)                     NOT NULL,
  VERSION        NUMBER(19)                     NOT NULL,
  DATA_INS       DATE                           NOT NULL,
  DESCRIZIONE    VARCHAR2(255 BYTE),
  ENTE           VARCHAR2(255 BYTE),
  FILE_TEMPLATE  BLOB                           NOT NULL,
  DATA_UPD       DATE                           NOT NULL,
  NOME           VARCHAR2(255 BYTE)             NOT NULL,
  TIPO           VARCHAR2(255 BYTE)             NOT NULL,
  TIPO_MODELLO   VARCHAR2(255 BYTE)             NOT NULL,
  UTENTE_INS     VARCHAR2(255 BYTE)             NOT NULL,
  UTENTE_UPD     VARCHAR2(255 BYTE)             NOT NULL,
  VALIDO         CHAR(1 BYTE)                   NOT NULL,
  VALIDO_AL      DATE,
  VALIDO_DAL     DATE                           NOT NULL
)
/


CREATE TABLE GTE_MODELLI_COMPETENZA
(
  ID_MODELLI_COMPETENZA  NUMBER(19)             NOT NULL,
  VERSION                NUMBER(19)             NOT NULL,
  CANCELLAZIONE          CHAR(1 BYTE)           NOT NULL,
  DESCRIZIONE            VARCHAR2(255 BYTE)     NOT NULL,
  ID_MODELLO             NUMBER(19)             NOT NULL,
  LETTURA                CHAR(1 BYTE)           NOT NULL,
  MODIFICA               CHAR(1 BYTE)           NOT NULL,
  RUOLO                  VARCHAR2(255 BYTE),
  UNITA_PROGR            NUMBER(19),
  UNITA_DAL              DATE,
  UNITA_OTTICA           VARCHAR2(255 BYTE),
  UTENTE                 VARCHAR2(255 BYTE)
)
/


CREATE TABLE GTE_TIPI_MODELLO
(
  CODICE       VARCHAR2(255 BYTE)               NOT NULL,
  VERSION      NUMBER(19)                       NOT NULL,
  DATA_INS     DATE                             NOT NULL,
  DESCRIZIONE  VARCHAR2(255 BYTE)               NOT NULL,
  ENTE         VARCHAR2(255 BYTE),
  DATA_UPD     DATE                             NOT NULL,
  QUERY        BLOB                             NOT NULL,
  UTENTE_INS   VARCHAR2(255 BYTE)               NOT NULL,
  UTENTE_UPD   VARCHAR2(255 BYTE)               NOT NULL,
  VALIDO       CHAR(1 BYTE)                     NOT NULL,
  VALIDO_AL    DATE,
  VALIDO_DAL   DATE                             NOT NULL
)
/


CREATE TABLE PARAMETRI_TIPOLOGIE
(
  ID_PARAMETRO_TIPOLOGIA  NUMBER(19)            NOT NULL,
  VERSION                 NUMBER(19)            NOT NULL,
  CODICE                  VARCHAR2(255 BYTE)    NOT NULL,
  ID_GRUPPO_STEP          NUMBER(19),
  ID_TIPO_PROTOCOLLO      NUMBER(19),
  VALORE                  VARCHAR2(255 BYTE)
)
/


CREATE TABLE SNAP_USER_CONS_COLUMNS
(
  OWNER            VARCHAR2(30 BYTE)            NOT NULL,
  CONSTRAINT_NAME  VARCHAR2(30 BYTE)            NOT NULL,
  TABLE_NAME       VARCHAR2(30 BYTE)            NOT NULL,
  COLUMN_NAME      VARCHAR2(4000 BYTE),
  POSITION         NUMBER
)
/


CREATE TABLE SNAP_USER_CONSTRAINTS
(
  OWNER              VARCHAR2(30 BYTE),
  CONSTRAINT_NAME    VARCHAR2(30 BYTE)          NOT NULL,
  CONSTRAINT_TYPE    VARCHAR2(1 BYTE),
  TABLE_NAME         VARCHAR2(30 BYTE)          NOT NULL,
  SEARCH_CONDITION   CLOB,
  R_OWNER            VARCHAR2(30 BYTE),
  R_CONSTRAINT_NAME  VARCHAR2(30 BYTE),
  DELETE_RULE        VARCHAR2(9 BYTE),
  STATUS             VARCHAR2(8 BYTE),
  DEFERRABLE         VARCHAR2(14 BYTE),
  DEFERRED           VARCHAR2(9 BYTE),
  VALIDATED          VARCHAR2(13 BYTE),
  GENERATED          VARCHAR2(14 BYTE),
  BAD                VARCHAR2(3 BYTE),
  RELY               VARCHAR2(4 BYTE),
  LAST_CHANGE        DATE,
  INDEX_OWNER        VARCHAR2(30 BYTE),
  INDEX_NAME         VARCHAR2(30 BYTE),
  INVALID            VARCHAR2(7 BYTE),
  VIEW_RELATED       VARCHAR2(14 BYTE)
)
/


CREATE TABLE SNAP_USER_IND_COLUMNS
(
  INDEX_NAME       VARCHAR2(30 BYTE),
  TABLE_NAME       VARCHAR2(30 BYTE),
  COLUMN_NAME      VARCHAR2(4000 BYTE),
  COLUMN_POSITION  NUMBER,
  COLUMN_LENGTH    NUMBER,
  CHAR_LENGTH      NUMBER,
  DESCEND          VARCHAR2(4 BYTE)
)
/


CREATE TABLE SNAP_USER_INDEXES
(
  INDEX_NAME               VARCHAR2(30 BYTE)    NOT NULL,
  INDEX_TYPE               VARCHAR2(27 BYTE),
  TABLE_OWNER              VARCHAR2(30 BYTE)    NOT NULL,
  TABLE_NAME               VARCHAR2(30 BYTE)    NOT NULL,
  TABLE_TYPE               VARCHAR2(11 BYTE),
  UNIQUENESS               VARCHAR2(9 BYTE),
  COMPRESSION              VARCHAR2(8 BYTE),
  PREFIX_LENGTH            NUMBER,
  TABLESPACE_NAME          VARCHAR2(30 BYTE),
  INI_TRANS                NUMBER,
  MAX_TRANS                NUMBER,
  INITIAL_EXTENT           NUMBER,
  NEXT_EXTENT              NUMBER,
  MIN_EXTENTS              NUMBER,
  MAX_EXTENTS              NUMBER,
  PCT_INCREASE             NUMBER,
  PCT_THRESHOLD            NUMBER,
  INCLUDE_COLUMN           NUMBER,
  FREELISTS                NUMBER,
  FREELIST_GROUPS          NUMBER,
  PCT_FREE                 NUMBER,
  LOGGING                  VARCHAR2(3 BYTE),
  BLEVEL                   NUMBER,
  LEAF_BLOCKS              NUMBER,
  DISTINCT_KEYS            NUMBER,
  AVG_LEAF_BLOCKS_PER_KEY  NUMBER,
  AVG_DATA_BLOCKS_PER_KEY  NUMBER,
  CLUSTERING_FACTOR        NUMBER,
  STATUS                   VARCHAR2(8 BYTE),
  NUM_ROWS                 NUMBER,
  SAMPLE_SIZE              NUMBER,
  LAST_ANALYZED            DATE,
  DEGREE                   VARCHAR2(40 BYTE),
  INSTANCES                VARCHAR2(40 BYTE),
  PARTITIONED              VARCHAR2(3 BYTE),
  TEMPORARY                VARCHAR2(1 BYTE),
  GENERATED                VARCHAR2(1 BYTE),
  SECONDARY                VARCHAR2(1 BYTE),
  BUFFER_POOL              VARCHAR2(7 BYTE),
  FLASH_CACHE              VARCHAR2(7 BYTE),
  CELL_FLASH_CACHE         VARCHAR2(7 BYTE),
  USER_STATS               VARCHAR2(3 BYTE),
  DURATION                 VARCHAR2(15 BYTE),
  PCT_DIRECT_ACCESS        NUMBER,
  ITYP_OWNER               VARCHAR2(30 BYTE),
  ITYP_NAME                VARCHAR2(30 BYTE),
  PARAMETERS               VARCHAR2(1000 BYTE),
  GLOBAL_STATS             VARCHAR2(3 BYTE),
  DOMIDX_STATUS            VARCHAR2(12 BYTE),
  DOMIDX_OPSTATUS          VARCHAR2(6 BYTE),
  FUNCIDX_STATUS           VARCHAR2(8 BYTE),
  JOIN_INDEX               VARCHAR2(3 BYTE),
  IOT_REDUNDANT_PKEY_ELIM  VARCHAR2(3 BYTE),
  DROPPED                  VARCHAR2(3 BYTE),
  VISIBILITY               VARCHAR2(9 BYTE),
  DOMIDX_MANAGEMENT        VARCHAR2(14 BYTE),
  SEGMENT_CREATED          VARCHAR2(3 BYTE)
)
/


CREATE TABLE SNAP_USER_TAB_COLUMNS
(
  TABLE_NAME            VARCHAR2(30 BYTE)       NOT NULL,
  COLUMN_NAME           VARCHAR2(30 BYTE)       NOT NULL,
  DATA_TYPE             VARCHAR2(106 BYTE),
  DATA_TYPE_MOD         VARCHAR2(3 BYTE),
  DATA_TYPE_OWNER       VARCHAR2(30 BYTE),
  DATA_LENGTH           NUMBER                  NOT NULL,
  DATA_PRECISION        NUMBER,
  DATA_SCALE            NUMBER,
  NULLABLE              VARCHAR2(1 BYTE),
  COLUMN_ID             NUMBER,
  DEFAULT_LENGTH        NUMBER,
  DATA_DEFAULT          CLOB,
  NUM_DISTINCT          NUMBER,
  LOW_VALUE             RAW(32),
  HIGH_VALUE            RAW(32),
  DENSITY               NUMBER,
  NUM_NULLS             NUMBER,
  NUM_BUCKETS           NUMBER,
  LAST_ANALYZED         DATE,
  SAMPLE_SIZE           NUMBER,
  CHARACTER_SET_NAME    VARCHAR2(44 BYTE),
  CHAR_COL_DECL_LENGTH  NUMBER,
  GLOBAL_STATS          VARCHAR2(3 BYTE),
  USER_STATS            VARCHAR2(3 BYTE),
  AVG_COL_LEN           NUMBER,
  CHAR_LENGTH           NUMBER,
  CHAR_USED             VARCHAR2(1 BYTE),
  V80_FMT_IMAGE         VARCHAR2(3 BYTE),
  DATA_UPGRADED         VARCHAR2(3 BYTE)
)
/


CREATE TABLE SNAP_USER_TABLES
(
  TABLE_NAME                 VARCHAR2(30 BYTE)  NOT NULL,
  TABLESPACE_NAME            VARCHAR2(30 BYTE),
  CLUSTER_NAME               VARCHAR2(30 BYTE),
  IOT_NAME                   VARCHAR2(30 BYTE),
  STATUS                     VARCHAR2(8 BYTE),
  PCT_FREE                   NUMBER,
  PCT_USED                   NUMBER,
  INI_TRANS                  NUMBER,
  MAX_TRANS                  NUMBER,
  INITIAL_EXTENT             NUMBER,
  NEXT_EXTENT                NUMBER,
  MIN_EXTENTS                NUMBER,
  MAX_EXTENTS                NUMBER,
  PCT_INCREASE               NUMBER,
  FREELISTS                  NUMBER,
  FREELIST_GROUPS            NUMBER,
  LOGGING                    VARCHAR2(3 BYTE),
  BACKED_UP                  VARCHAR2(1 BYTE),
  NUM_ROWS                   NUMBER,
  BLOCKS                     NUMBER,
  EMPTY_BLOCKS               NUMBER,
  AVG_SPACE                  NUMBER,
  CHAIN_CNT                  NUMBER,
  AVG_ROW_LEN                NUMBER,
  AVG_SPACE_FREELIST_BLOCKS  NUMBER,
  NUM_FREELIST_BLOCKS        NUMBER,
  DEGREE                     VARCHAR2(10 BYTE),
  INSTANCES                  VARCHAR2(10 BYTE),
  CACHE                      VARCHAR2(5 BYTE),
  TABLE_LOCK                 VARCHAR2(8 BYTE),
  SAMPLE_SIZE                NUMBER,
  LAST_ANALYZED              DATE,
  PARTITIONED                VARCHAR2(3 BYTE),
  IOT_TYPE                   VARCHAR2(12 BYTE),
  TEMPORARY                  VARCHAR2(1 BYTE),
  SECONDARY                  VARCHAR2(1 BYTE),
  NESTED                     VARCHAR2(3 BYTE),
  BUFFER_POOL                VARCHAR2(7 BYTE),
  FLASH_CACHE                VARCHAR2(7 BYTE),
  CELL_FLASH_CACHE           VARCHAR2(7 BYTE),
  ROW_MOVEMENT               VARCHAR2(8 BYTE),
  GLOBAL_STATS               VARCHAR2(3 BYTE),
  USER_STATS                 VARCHAR2(3 BYTE),
  DURATION                   VARCHAR2(15 BYTE),
  SKIP_CORRUPT               VARCHAR2(8 BYTE),
  MONITORING                 VARCHAR2(3 BYTE),
  CLUSTER_OWNER              VARCHAR2(30 BYTE),
  DEPENDENCIES               VARCHAR2(8 BYTE),
  COMPRESSION                VARCHAR2(8 BYTE),
  COMPRESS_FOR               VARCHAR2(12 BYTE),
  DROPPED                    VARCHAR2(3 BYTE),
  READ_ONLY                  VARCHAR2(3 BYTE),
  SEGMENT_CREATED            VARCHAR2(3 BYTE),
  RESULT_CACHE               VARCHAR2(7 BYTE)
)
/


CREATE TABLE WKF_CFG_COMPETENZE
(
  ID_CFG_COMPETENZA        NUMBER(19)           NOT NULL,
  VERSION                  NUMBER(19)           NOT NULL,
  ASSEGNAZIONE             VARCHAR2(3 BYTE),
  ID_ATTORE                NUMBER(19)           NOT NULL,
  CANCELLAZIONE            CHAR(1 BYTE)         NOT NULL,
  ID_CFG_STEP              NUMBER(19),
  CREAZIONE                CHAR(1 BYTE)         NOT NULL,
  DATA_INS                 DATE                 NOT NULL,
  ENTE                     VARCHAR2(255 BYTE)   NOT NULL,
  DATA_UPD                 DATE                 NOT NULL,
  LETTURA                  CHAR(1 BYTE)         NOT NULL,
  MODIFICA                 CHAR(1 BYTE)         NOT NULL,
  ID_PULSANTE              NUMBER(19),
  ID_PULSANTE_PROVENIENZA  NUMBER(19),
  TIPO_OGGETTO             VARCHAR2(255 BYTE)   NOT NULL,
  UTENTE_INS               VARCHAR2(255 BYTE)   NOT NULL,
  UTENTE_UPD               VARCHAR2(255 BYTE)   NOT NULL
)
/


CREATE TABLE WKF_CFG_ITER
(
  ID_CFG_ITER            NUMBER(19)             NOT NULL,
  VERSION                NUMBER(19)             NOT NULL,
  DATA_INS               DATE                   NOT NULL,
  DESCRIZIONE            VARCHAR2(4000 BYTE),
  ENTE                   VARCHAR2(255 BYTE)     NOT NULL,
  ID_CFG_ITER_REVISIONE  NUMBER(19),
  DATA_UPD               DATE                   NOT NULL,
  NOME                   VARCHAR2(255 BYTE)     NOT NULL,
  PROGRESSIVO            NUMBER(19)             NOT NULL,
  REVISIONE              NUMBER(19)             NOT NULL,
  STATO                  VARCHAR2(255 BYTE)     NOT NULL,
  TIPO_OGGETTO           VARCHAR2(255 BYTE)     NOT NULL,
  UTENTE_INS             VARCHAR2(255 BYTE)     NOT NULL,
  UTENTE_UPD             VARCHAR2(255 BYTE)     NOT NULL,
  VERIFICATO             CHAR(1 BYTE)           NOT NULL
)
/


CREATE TABLE WKF_CFG_PULSANTI
(
  ID_CFG_PULSANTE         NUMBER(19)            NOT NULL,
  VERSION                 NUMBER(19)            NOT NULL,
  ID_CFG_STEP             NUMBER(19)            NOT NULL,
  ID_CFG_STEP_SUCCESSIVO  NUMBER(19),
  DATA_INS                DATE                  NOT NULL,
  ENTE                    VARCHAR2(255 BYTE)    NOT NULL,
  DATA_UPD                DATE                  NOT NULL,
  ID_PULSANTE             NUMBER(19)            NOT NULL,
  UTENTE_INS              VARCHAR2(255 BYTE)    NOT NULL,
  UTENTE_UPD              VARCHAR2(255 BYTE)    NOT NULL,
  SEQUENZA                NUMBER(10)
)
/


CREATE TABLE WKF_CFG_PULSANTI_ATTORI
(
  ID_CFG_PULSANTE  NUMBER(19)                   NOT NULL,
  ID_ATTORE        NUMBER(19)
)
/


CREATE TABLE WKF_CFG_STEP
(
  ID_CFG_STEP           NUMBER(19)              NOT NULL,
  VERSION               NUMBER(19)              NOT NULL,
  ID_ATTORE             NUMBER(19),
  ID_CFG_ITER           NUMBER(19)              NOT NULL,
  ID_CFG_STEP_NO        NUMBER(19),
  ID_CFG_STEP_SBLOCCO   NUMBER(19),
  ID_CFG_STEP_SI        NUMBER(19),
  ID_AZIONE_CONDIZIONE  NUMBER(19),
  ID_AZIONE_SBLOCCO     NUMBER(19),
  DATA_INS              DATE                    NOT NULL,
  DESCRIZIONE           VARCHAR2(255 BYTE),
  ID_GRUPPO_STEP        NUMBER(19),
  DATA_UPD              DATE                    NOT NULL,
  NOME                  VARCHAR2(255 BYTE)      NOT NULL,
  SEQUENZA              NUMBER(10)              NOT NULL,
  TITOLO                VARCHAR2(255 BYTE)      NOT NULL,
  UTENTE_INS            VARCHAR2(255 BYTE)      NOT NULL,
  UTENTE_UPD            VARCHAR2(255 BYTE)      NOT NULL
)
/


CREATE TABLE WKF_CFG_STEP_AZIONI_IN
(
  ID_CFG_STEP          NUMBER(19)               NOT NULL,
  ID_AZIONE_IN         NUMBER(19),
  AZIONI_INGRESSO_IDX  NUMBER(10)
)
/


CREATE TABLE WKF_CFG_STEP_AZIONI_OUT
(
  ID_CFG_STEP        NUMBER(19)                 NOT NULL,
  ID_AZIONE_OUT      NUMBER(19),
  AZIONI_USCITA_IDX  NUMBER(10)
)
/


CREATE TABLE WKF_DIZ_ATTORI
(
  ID_ATTORE          NUMBER(19)                 NOT NULL,
  VERSION            NUMBER(19)                 NOT NULL,
  DATA_INS           DATE                       NOT NULL,
  DESCRIZIONE        VARCHAR2(255 BYTE),
  ENTE               VARCHAR2(255 BYTE),
  DATA_UPD           DATE                       NOT NULL,
  ID_AZIONE_CALCOLO  NUMBER(19),
  NOME               VARCHAR2(255 BYTE)         NOT NULL,
  RUOLO              VARCHAR2(255 BYTE),
  TIPO_OGGETTO       VARCHAR2(255 BYTE),
  UNITA_PROGR        NUMBER(19),
  UNITA_DAL          DATE,
  UNITA_OTTICA       VARCHAR2(255 BYTE),
  UTENTE             VARCHAR2(255 BYTE),
  UTENTE_INS         VARCHAR2(255 BYTE)         NOT NULL,
  UTENTE_UPD         VARCHAR2(255 BYTE)         NOT NULL,
  VALIDO             CHAR(1 BYTE)               NOT NULL
)
/


CREATE TABLE WKF_DIZ_AZIONI
(
  ID_AZIONE       NUMBER(19)                    NOT NULL,
  VERSION         NUMBER(19)                    NOT NULL,
  CATEGORIA       VARCHAR2(255 BYTE),
  DESCRIZIONE     VARCHAR2(255 BYTE),
  NOME            VARCHAR2(255 BYTE)            NOT NULL,
  NOME_BEAN       VARCHAR2(255 BYTE),
  NOME_METODO     VARCHAR2(255 BYTE),
  TIPO            VARCHAR2(255 BYTE)            NOT NULL,
  TIPO_OGGETTO    VARCHAR2(255 BYTE),
  VALIDO          CHAR(1 BYTE)                  NOT NULL,
  ISTRUZIONE_SQL  VARCHAR2(255 BYTE)
)
/


CREATE TABLE WKF_DIZ_AZIONI_PARAMETRI
(
  ID_AZIONE_PARAMETRO  NUMBER(19)               NOT NULL,
  VERSION              NUMBER(19)               NOT NULL,
  ID_AZIONE            NUMBER(19)               NOT NULL,
  CODICE               VARCHAR2(255 BYTE)       NOT NULL,
  DESCRIZIONE          VARCHAR2(255 BYTE)
)
/


CREATE TABLE WKF_DIZ_GRUPPI_STEP
(
  ID_GRUPPO_STEP  NUMBER(19)                    NOT NULL,
  VERSION         NUMBER(19)                    NOT NULL,
  DATA_INS        DATE                          NOT NULL,
  DESCRIZIONE     VARCHAR2(255 BYTE),
  ENTE            VARCHAR2(255 BYTE)            NOT NULL,
  DATA_UPD        DATE                          NOT NULL,
  NOME            VARCHAR2(255 BYTE)            NOT NULL,
  UTENTE_INS      VARCHAR2(255 BYTE)            NOT NULL,
  UTENTE_UPD      VARCHAR2(255 BYTE)            NOT NULL,
  VALIDO          CHAR(1 BYTE)                  NOT NULL
)
/


CREATE TABLE WKF_DIZ_PULSANTI
(
  ID_PULSANTE               NUMBER(19)          NOT NULL,
  VERSION                   NUMBER(19)          NOT NULL,
  COMPETENZA_IN_MODIFICA    CHAR(1 BYTE)        NOT NULL,
  ID_CONDIZIONE_VISIBILITA  NUMBER(19),
  DATA_INS                  DATE                NOT NULL,
  DESCRIZIONE               VARCHAR2(255 BYTE),
  ENTE                      VARCHAR2(255 BYTE)  NOT NULL,
  ETICHETTA                 VARCHAR2(255 BYTE)  NOT NULL,
  ICONA                     VARCHAR2(255 BYTE),
  DATA_UPD                  DATE                NOT NULL,
  MESSAGGIO_CONFERMA        VARCHAR2(255 BYTE),
  TIPO_OGGETTO              VARCHAR2(255 BYTE),
  TOOLTIP                   VARCHAR2(255 BYTE),
  UTENTE_INS                VARCHAR2(255 BYTE)  NOT NULL,
  UTENTE_UPD                VARCHAR2(255 BYTE)  NOT NULL,
  VALIDO                    CHAR(1 BYTE)        NOT NULL
)
/


CREATE TABLE WKF_DIZ_PULSANTI_AZIONI
(
  ID_PULSANTE  NUMBER(19)                       NOT NULL,
  ID_AZIONE    NUMBER(19),
  AZIONI_IDX   NUMBER(10)
)
/


CREATE TABLE WKF_DIZ_TIPI_OGGETTO
(
  CODICE         VARCHAR2(255 BYTE)             NOT NULL,
  DESCRIZIONE    VARCHAR2(255 BYTE),
  ITERABILE      CHAR(1 BYTE)                   NOT NULL,
  NOME           VARCHAR2(255 BYTE)             NOT NULL,
  OGGETTI_FIGLI  VARCHAR2(255 BYTE),
  VALIDO         CHAR(1 BYTE)                   NOT NULL
)
/


CREATE TABLE WKF_ENGINE_ITER
(
  ID_ENGINE_ITER    NUMBER(19)                  NOT NULL,
  VERSION           NUMBER(19)                  NOT NULL,
  ID_CFG_ITER       NUMBER(19)                  NOT NULL,
  DATA_FINE         DATE,
  DATA_INIZIO       DATE                        NOT NULL,
  DATA_INS          DATE                        NOT NULL,
  ENTE              VARCHAR2(255 BYTE)          NOT NULL,
  DATA_UPD          DATE                        NOT NULL,
  ID_STEP_CORRENTE  NUMBER(19),
  UTENTE_INS        VARCHAR2(255 BYTE)          NOT NULL,
  UTENTE_UPD        VARCHAR2(255 BYTE)          NOT NULL
)
/


CREATE TABLE WKF_ENGINE_STEP
(
  ID_ENGINE_STEP  NUMBER(19)                    NOT NULL,
  VERSION         NUMBER(19)                    NOT NULL,
  ID_CFG_STEP     NUMBER(19)                    NOT NULL,
  DATA_FINE       DATE,
  DATA_INIZIO     DATE                          NOT NULL,
  DATA_INS        DATE                          NOT NULL,
  ID_ENGINE_ITER  NUMBER(19),
  DATA_UPD        DATE                          NOT NULL,
  UTENTE_INS      VARCHAR2(255 BYTE)            NOT NULL,
  UTENTE_UPD      VARCHAR2(255 BYTE)            NOT NULL
)
/


CREATE TABLE WKF_ENGINE_STEP_ATTORI
(
  ID_ENGINE_ATTORE  NUMBER(19)                  NOT NULL,
  VERSION           NUMBER(19)                  NOT NULL,
  DATA_INS          DATE                        NOT NULL,
  DATA_UPD          DATE                        NOT NULL,
  RUOLO             VARCHAR2(255 BYTE),
  ID_ENGINE_STEP    NUMBER(19)                  NOT NULL,
  UNITA_PROGR       NUMBER(19),
  UNITA_DAL         DATE,
  UNITA_OTTICA      VARCHAR2(255 BYTE),
  UTENTE            VARCHAR2(255 BYTE),
  UTENTE_INS        VARCHAR2(255 BYTE)          NOT NULL,
  UTENTE_UPD        VARCHAR2(255 BYTE)          NOT NULL
)
/


CREATE TABLE WKF_IMPOSTAZIONI
(
  CODICE           VARCHAR2(255 BYTE)           NOT NULL,
  ENTE             VARCHAR2(255 BYTE)           NOT NULL,
  VERSION          NUMBER(19)                   NOT NULL,
  CARATTERISTICHE  VARCHAR2(255 BYTE),
  DESCRIZIONE      VARCHAR2(255 BYTE)           NOT NULL,
  ETICHETTA        VARCHAR2(255 BYTE)           NOT NULL,
  MODIFICABILE     CHAR(1 BYTE)                 NOT NULL,
  PREDEFINITO      VARCHAR2(255 BYTE),
  VALORE           VARCHAR2(255 BYTE)           NOT NULL
)
/


CREATE UNIQUE INDEX AGP_DOCUMENTI_DATI_SCARTO_PK ON AGP_DOCUMENTI_DATI_SCARTO
(ID_DOCUMENTO)
/


CREATE UNIQUE INDEX AGP_DOCUMENTI_SMISTAMENTI_PK ON AGP_DOCUMENTI_SMISTAMENTI
(ID_DOCUMENTO_SMISTAMENTO)
/


CREATE UNIQUE INDEX AGP_DOCUMENTI_TITOLARIO_PK ON AGP_DOCUMENTI_TITOLARIO
(ID_DOCUMENTO_TITOLARIO)
/


CREATE UNIQUE INDEX AGP_DOCUMENTI_TITOLARIO_UK ON AGP_DOCUMENTI_TITOLARIO
(ID_DOCUMENTO, ID_CLASSIFICAZIONE, ID_FASCICOLO)
/


CREATE INDEX AGP_DOSM_DOCU_FK ON AGP_DOCUMENTI_SMISTAMENTI
(ID_DOCUMENTO)
/


CREATE INDEX AGP_DOTI_DOCU_FK ON AGP_DOCUMENTI_TITOLARIO
(ID_DOCUMENTO)
/


CREATE INDEX AGP_MECO_CORR_FK ON AGP_MESSAGGI_CORRISPONDENTI
(ID_PROTOCOLLO_CORRISPONDENTE)
/


CREATE INDEX AGP_MECO_MESS_IK ON AGP_MESSAGGI_CORRISPONDENTI
(ID_MESSAGGIO)
/


CREATE UNIQUE INDEX AGP_MESSAGGI_CORRISPONDENTI_PK ON AGP_MESSAGGI_CORRISPONDENTI
(ID_MESSAGGIO_CORRISPONDENTE)
/


CREATE INDEX AGP_PCIN_CORR_FK ON AGP_PROTOCOLLI_CORR_INDIRIZZI
(ID_PROTOCOLLO_CORRISPONDENTE)
/


CREATE UNIQUE INDEX AGP_PCIN_PK ON AGP_PROTOCOLLI_CORR_INDIRIZZI
(ID_PROTOCOLLO_CORR_INDIRIZZO)
/


CREATE INDEX AGP_PDAC_PROT_RISP_FK ON AGP_PROTOCOLLI_DATI_ACCESSO
(ID_PROTOCOLLO_RISPOSTA)
/


CREATE INDEX AGP_PDAC_TACC_FK ON AGP_PROTOCOLLI_DATI_ACCESSO
(ID_TIPO_ACCESSO_CIVICO)
/


CREATE INDEX AGP_PDAC_TEAC_FK ON AGP_PROTOCOLLI_DATI_ACCESSO
(ID_TIPO_ESITO)
/


CREATE INDEX AGP_PDAC_TRAC_FK ON AGP_PROTOCOLLI_DATI_ACCESSO
(ID_TIPO_RICHIEDENTE_ACCESSO)
/


CREATE INDEX AGP_PRAN_PROT_FK ON AGP_PROTOCOLLI_ANNULLAMENTI
(ID_DOCUMENTO)
/


CREATE INDEX AGP_PRCO_DOCU_FK ON AGP_PROTOCOLLI_CORRISPONDENTI
(ID_DOCUMENTO)
/


CREATE UNIQUE INDEX AGP_PROT_CORRISPONDENTI_PK ON AGP_PROTOCOLLI_CORRISPONDENTI
(ID_PROTOCOLLO_CORRISPONDENTE)
/


CREATE UNIQUE INDEX AGP_PROTOCOLLI_ANNULLAMENTI_PK ON AGP_PROTOCOLLI_ANNULLAMENTI
(ID_PROTOCOLLO_ANNULLAMENTO)
/


CREATE UNIQUE INDEX AGP_PROTOCOLLI_DATI_ACCESSO_PK ON AGP_PROTOCOLLI_DATI_ACCESSO
(ID_DATI_ACCESSO)
/


CREATE UNIQUE INDEX AGP_PROTOCOLLI_DATI_ACCESSO_UK ON AGP_PROTOCOLLI_DATI_ACCESSO
(ID_PROTOCOLLO_DOMANDA)
/


CREATE UNIQUE INDEX AGP_PROTOCOLLI_DATI_INTEROP_PK ON AGP_PROTOCOLLI_DATI_INTEROP
(ID_PROTOCOLLO_DATI_INTEROP)
/


CREATE UNIQUE INDEX AGP_PROTOCOLLI_DATI_SCARTO_PK ON AGP_PROTOCOLLI_DATI_SCARTO
(ID_PROTOCOLLO_DATI_SCARTO)
/


CREATE UNIQUE INDEX AGP_PROTOCOLLI_PK ON AGP_PROTOCOLLI
(ID_DOCUMENTO)
/


CREATE UNIQUE INDEX AGP_PROTOCOLLI_UK ON AGP_PROTOCOLLI
(ANNO, TIPO_REGISTRO, NUMERO)
/


CREATE INDEX AGP_PROT_PDIN_FK ON AGP_PROTOCOLLI
(ID_PROTOCOLLO_DATI_INTEROP)
/


CREATE INDEX AGP_PROT_TIPR_FK ON AGP_PROTOCOLLI
(ID_TIPO_PROTOCOLLO)
/


CREATE INDEX AGP_SCCO_COLL_FK ON AGP_SCHEMI_COLLEGATI
(ID_COLLEGATO)
/


CREATE INDEX AGP_SCCO_SCPR_FK ON AGP_SCHEMI_COLLEGATI
(ID_SCHEMA_PROTOCOLLO)
/


CREATE UNIQUE INDEX AGP_SCHEMI_COLLEGATI_PK ON AGP_SCHEMI_COLLEGATI
(ID_SCHEMA_COLLEGATO)
/


CREATE UNIQUE INDEX AGP_SCHEMI_PROT_ALLEGATI_PK ON AGP_SCHEMI_PROT_ALLEGATI
(ID_SCHEMA_PROT_ALLEGATI)
/


CREATE UNIQUE INDEX AGP_TIPI_ACCESSO_CIVICO_PK ON AGP_TIPI_ACCESSO_CIVICO
(ID_TIPO_ACCESSO_CIVICO)
/


CREATE UNIQUE INDEX AGP_TIPI_ACCESSO_CIVICO_UK ON AGP_TIPI_ACCESSO_CIVICO
(CODICE)
/


CREATE UNIQUE INDEX AGP_TIPI_ESITO_ACCESSO_PK ON AGP_TIPI_ESITO_ACCESSO
(ID_TIPO_ESITO)
/


CREATE UNIQUE INDEX AGP_TIPI_ESITO_ACCESSO_UK ON AGP_TIPI_ESITO_ACCESSO
(CODICE)
/


CREATE UNIQUE INDEX AGP_TIPI_PROTOCOLLO_PK ON AGP_TIPI_PROTOCOLLO
(ID_TIPO_PROTOCOLLO)
/


CREATE UNIQUE INDEX AGP_TIPI_RICHIEDENTE_ACCE_PK ON AGP_TIPI_RICHIEDENTE_ACCESSO
(ID_TIPO_RICHIEDENTE_ACCESSO)
/


CREATE UNIQUE INDEX AGP_TIPI_RICHIEDENTE_ACCE_UK ON AGP_TIPI_RICHIEDENTE_ACCESSO
(CODICE)
/


CREATE INDEX COFI_FIDITR_ID_FK ON GDO_CODA_FIRMA
(ID_TRANSAZIONE_FIRMA)
/


CREATE INDEX FDFI_FDTR_FK ON FIRMA_DIGITALE_FILE
(TRANSAZIONE_ID)
/


CREATE INDEX FIDO_FIDOSTO_FK ON GDO_FILE_DOCUMENTO
(ID_FILE_DOCUMENTO_STORICO)
/


CREATE INDEX FIDO_MODE_FK ON GDO_FILE_DOCUMENTO
(ID_MODELLO_TESTO)
/


CREATE UNIQUE INDEX FIRMA_DIGITALE_FILE_PK ON FIRMA_DIGITALE_FILE
(ID)
/


CREATE UNIQUE INDEX FIRMA_DIGITALE_TRANSAZIONE_PK ON FIRMA_DIGITALE_TRANSAZIONE
(ID)
/


CREATE UNIQUE INDEX GDO_ALLEGATI_PK ON GDO_ALLEGATI
(ID_DOCUMENTO)
/


CREATE UNIQUE INDEX GDO_CODA_FIRMA_PK ON GDO_CODA_FIRMA
(ID_CODA_FIRMA)
/


CREATE INDEX GDO_COFI_DOCU_FK ON GDO_CODA_FIRMA
(ID_DOCUMENTO)
/


CREATE INDEX GDO_COFI_ENTI_FK ON GDO_CODA_FIRMA
(ID_ENTE)
/


CREATE INDEX GDO_DOCO_DOCU_FK ON GDO_DOCUMENTI_COMPETENZE
(ID_DOCUMENTO)
/


CREATE INDEX GDO_DOCO_DOCU2_FK ON GDO_DOCUMENTI_COLLEGATI
(ID_DOCUMENTO)
/


CREATE INDEX GDO_DOCO_DOCU3_FK ON GDO_DOCUMENTI_COLLEGATI
(ID_COLLEGATO)
/


CREATE INDEX GDO_DOCO_TICO_FK ON GDO_DOCUMENTI_COLLEGATI
(ID_TIPO_COLLEGAMENTO)
/


CREATE INDEX GDO_DOCO_WKFCFGCOM_FK ON GDO_DOCUMENTI_COMPETENZE
(ID_CFG_COMPETENZA)
/


CREATE INDEX GDO_DOCU_ENIT_FK ON GDO_DOCUMENTI
(ID_ENGINE_ITER)
/


CREATE INDEX GDO_DOCU_ENTI_FK ON GDO_DOCUMENTI
(ID_ENTE)
/


CREATE UNIQUE INDEX GDO_DOCUMENTI_COLLEGATI_PK ON GDO_DOCUMENTI_COLLEGATI
(ID_DOCUMENTO_COLLEGATO)
/


CREATE UNIQUE INDEX GDO_DOCUMENTI_COMPETENZE_PK ON GDO_DOCUMENTI_COMPETENZE
(ID_DOCUMENTO_COMPETENZA)
/


CREATE UNIQUE INDEX GDO_DOCUMENTI_PK ON GDO_DOCUMENTI
(ID_DOCUMENTO)
/


CREATE UNIQUE INDEX GDO_DOCUMENTI_SOGGETTI_PK ON GDO_DOCUMENTI_SOGGETTI
(ID_DOCUMENTO_SOGGETTO)
/


CREATE UNIQUE INDEX GDO_DOCUMENTI_STORICO_PK ON GDO_DOCUMENTI_STORICO
(ID_DOCUMENTO_STORICO)
/


CREATE INDEX GDO_DOCU_TIOG_FK ON GDO_DOCUMENTI
(TIPO_OGGETTO)
/


CREATE INDEX GDO_DOST_DOCU_FK ON GDO_DOCUMENTI_STORICO
(ID_DOCUMENTO)
/


CREATE UNIQUE INDEX GDO_EMAIL_PK ON GDO_EMAIL
(ID_EMAIL)
/


CREATE UNIQUE INDEX GDO_ENTI_PK ON GDO_ENTI
(ID_ENTE)
/


CREATE INDEX GDO_FDFI_FIDO_FK ON GDO_FILE_DOCUMENTO_FIRMATARI
(ID_FILE_DOCUMENTO)
/


CREATE INDEX GDO_FIDO_FIDO_FK ON GDO_FILE_DOCUMENTO
(FILE_ORIGINALE_ID)
/


CREATE UNIQUE INDEX GDO_FILE_DOCU_FIRMATARI_PK ON GDO_FILE_DOCUMENTO_FIRMATARI
(ID_FIRMATARIO)
/


CREATE UNIQUE INDEX GDO_FILE_DOCUMENTO_PK ON GDO_FILE_DOCUMENTO
(ID_FILE_DOCUMENTO)
/


CREATE INDEX GDO_ID_DOCU_ESTERNO_IK ON GDO_DOCUMENTI
(ID_DOCUMENTO_ESTERNO)
/


CREATE INDEX GDO_NODE_ENTI_FK ON GDO_NOTIFICHE_DESTINATARI
(ID_ENTE)
/


CREATE INDEX GDO_NODE_NOTI_FK ON GDO_NOTIFICHE_DESTINATARI
(ID_NOTIFICA)
/


CREATE INDEX GDO_NOTI_ENTI_FK ON GDO_NOTIFICHE
(ID_ENTE)
/


CREATE UNIQUE INDEX GDO_NOTIFICHE_ATTIVITA_PK ON GDO_NOTIFICHE_ATTIVITA
(ID_NOTIFICA_ATTIVITA)
/


CREATE UNIQUE INDEX GDO_NOTIFICHE_DESTINATARI_PK ON GDO_NOTIFICHE_DESTINATARI
(ID_NOTIFICA_DESTINATARIO)
/


CREATE UNIQUE INDEX GDO_NOTIFICHE_EMAIL_PK ON GDO_NOTIFICHE_EMAIL
(ID_NOTIFICA_EMAIL)
/


CREATE UNIQUE INDEX GDO_NOTIFICHE_PK ON GDO_NOTIFICHE
(ID_NOTIFICA)
/


CREATE INDEX GDO_SPAL_TIAL_FK ON AGP_SCHEMI_PROT_ALLEGATI
(ID_TIPO_ALLEGATO)
/


CREATE INDEX GDO_TDCO_TIDO_FK ON GDO_TIPI_DOCUMENTO_COMPETENZE
(ID_TIPO_DOCUMENTO)
/


CREATE INDEX GDO_TDMT_MODE_FK ON GDO_TIPI_DOCUMENTO_MODELLI
(ID_MODELLO)
/


CREATE INDEX GDO_TDMT_TIDO_FK ON GDO_TIPI_DOCUMENTO_MODELLI
(ID_TIPO_DOCUMENTO)
/


CREATE INDEX GDO_TDPA_TIDO_FK ON GDO_TIPI_DOCUMENTO_PARERI
(ID_TIPO_DOCUMENTO)
/


CREATE INDEX GDO_TDPA_TIPA_FK ON GDO_TIPI_DOCUMENTO_PARERI
(ID_TIPO_PARERE)
/


CREATE INDEX GDO_TICO_ENTI_FK ON GDO_TIPI_COLLEGAMENTO
(ID_ENTE)
/


CREATE INDEX GDO_TICO_IDX ON GDO_TIPI_COLLEGAMENTO
(TIPO_COLLEGAMENTO)
/


CREATE UNIQUE INDEX GDO_TIDO_COMPETENZE_PK ON GDO_TIPI_DOCUMENTO_COMPETENZE
(ID_TIPO_DOCUMENTO_COMPETENZE)
/


CREATE INDEX GDO_TIDO_ENTI_FK ON GDO_TIPI_DOCUMENTO
(ID_ENTE)
/


CREATE INDEX GDO_TIDO_TISO_FK ON GDO_TIPI_DOCUMENTO
(ID_TIPOLOGIA_SOGGETTO)
/


CREATE INDEX GDO_TIPA_MODE_FK ON GDO_TIPI_PARERE
(ID_MODELLO_TESTO)
/


CREATE INDEX GDO_TIPA_TISO_FK ON GDO_TIPI_PARERE
(ID_TIPOLOGIA_SOGGETTO)
/


CREATE UNIQUE INDEX GDO_TIPI_ALLEGATO_TABLE_PK ON GDO_TIPI_ALLEGATO
(ID_TIPO_DOCUMENTO)
/


CREATE UNIQUE INDEX GDO_TIPI_COLLEGAMENTO_PK ON GDO_TIPI_COLLEGAMENTO
(ID_TIPO_COLLEGAMENTO)
/


CREATE UNIQUE INDEX GDO_TIPI_COLLEGAMENTO_UK ON GDO_TIPI_COLLEGAMENTO
(TIPO_COLLEGAMENTO, ID_ENTE)
/


CREATE UNIQUE INDEX GDO_TIPI_DOCUMENTO_MODELLI_PK ON GDO_TIPI_DOCUMENTO_MODELLI
(ID_TIPO_DOCUMENTO_MODELLO)
/


CREATE UNIQUE INDEX GDO_TIPI_DOCUMENTO_MODELLI_UK ON GDO_TIPI_DOCUMENTO_MODELLI
(ID_TIPO_DOCUMENTO, ID_MODELLO, CODICE)
/


CREATE UNIQUE INDEX GDO_TIPI_DOCUMENTO_PARERI_PK ON GDO_TIPI_DOCUMENTO_PARERI
(ID_TIPO_DOCUMENTO_PARERE)
/


CREATE UNIQUE INDEX GDO_TIPI_DOCUMENTO_PARERI_UK ON GDO_TIPI_DOCUMENTO_PARERI
(ID_TIPO_DOCUMENTO, ID_TIPO_PARERE)
/


CREATE UNIQUE INDEX GDO_TIPI_DOCUMENTO_PK ON GDO_TIPI_DOCUMENTO
(ID_TIPO_DOCUMENTO)
/


CREATE UNIQUE INDEX GDO_TIPI_PARERE ON GDO_TIPI_PARERE
(ID_TIPO_PARERE)
/


CREATE UNIQUE INDEX GDO_TIPO_ACRONIMO_UK ON GDO_TIPI_DOCUMENTO
(ACRONIMO)
/


CREATE UNIQUE INDEX GDO_TIPOLOGIE_SOGG_REGOLE_PK ON GDO_TIPOLOGIE_SOGGETTO_REGOLE
(ID_TIPOLOGIA_SOGGETTO_REGOLA)
/


CREATE INDEX GDO_TISO_ENTI_FK ON GDO_TIPOLOGIE_SOGGETTO
(ID_ENTE)
/


CREATE UNIQUE INDEX GDO_TISO_PK ON GDO_TIPOLOGIE_SOGGETTO
(ID_TIPOLOGIA_SOGGETTO)
/


CREATE INDEX GDO_TISO_TIOG_FK ON GDO_TIPOLOGIE_SOGGETTO
(TIPO_OGGETTO)
/


CREATE UNIQUE INDEX GDO_TOKEN_INTEGRAZIONI_PK ON GDO_TOKEN_INTEGRAZIONI
(ID_TOKEN)
/


CREATE UNIQUE INDEX GDO_TOKEN_INTEGRAZIONI_UK ON GDO_TOKEN_INTEGRAZIONI
(TIPO, ID_RIFERIMENTO)
/


CREATE INDEX GDO_TSRE_ENTI_FK ON GDO_TIPOLOGIE_SOGGETTO_REGOLE
(ID_ENTE)
/


CREATE INDEX GDO_TSRE_TISO_FK ON GDO_TIPOLOGIE_SOGGETTO_REGOLE
(ID_TIPOLOGIA_SOGGETTO)
/


CREATE INDEX GTE_DELO_LOCK_FK ON GTE_DETTAGLI_LOCK
(ID_LOCK)
/


CREATE INDEX GTE_DELO_TIMO_FK ON GTE_DETTAGLI_LOCK
(ID_TIPO_MODELLO)
/


CREATE UNIQUE INDEX GTE_DETTAGLI_LOCK_PK ON GTE_DETTAGLI_LOCK
(ID_DETTAGLIO_LOCK)
/


CREATE UNIQUE INDEX GTE_LOCK_PK ON GTE_LOCK
(ID_RIFERIMENTO_TESTO)
/


CREATE INDEX GTE_MOCO_MODE_FK ON GTE_MODELLI_COMPETENZA
(ID_MODELLO)
/


CREATE UNIQUE INDEX GTE_MODELLI_COMPETENZA_PK ON GTE_MODELLI_COMPETENZA
(ID_MODELLI_COMPETENZA)
/


CREATE UNIQUE INDEX GTE_MODELLI_PK ON GTE_MODELLI
(ID_MODELLO)
/


CREATE INDEX GTETESMOD_GTETIPMOD_FK ON GTE_MODELLI
(TIPO_MODELLO)
/


CREATE UNIQUE INDEX GTE_TIPI_MODELLO_PK ON GTE_TIPI_MODELLO
(CODICE)
/


CREATE UNIQUE INDEX PARAMETRI_TIPOLOGIE_PK ON PARAMETRI_TIPOLOGIE
(ID_PARAMETRO_TIPOLOGIA)
/


CREATE INDEX PROTSOG_TIPSOG_FK ON GDO_DOCUMENTI_SOGGETTI
(TIPO_SOGGETTO)
/


CREATE INDEX UNITA_IDX ON GDO_DOCUMENTI_SOGGETTI
(UNITA_PROGR, UNITA_DAL, UNITA_OTTICA)
/


CREATE INDEX WKF_CFCO_CFST_FK ON WKF_CFG_COMPETENZE
(ID_CFG_STEP)
/


CREATE INDEX WKF_CFCO_DIAZ_FK ON WKF_CFG_COMPETENZE
(ID_ATTORE)
/


CREATE INDEX WKF_CFCO_DIPU_FK ON WKF_CFG_COMPETENZE
(ID_PULSANTE)
/


CREATE INDEX WKF_CFCO_DIPU2_FK ON WKF_CFG_COMPETENZE
(ID_PULSANTE_PROVENIENZA)
/


CREATE UNIQUE INDEX WKF_CFG_COMPETENZE_PK ON WKF_CFG_COMPETENZE
(ID_CFG_COMPETENZA)
/


CREATE INDEX WKFCFGCOM_WKFDIZTIPOGG_FK ON WKF_CFG_COMPETENZE
(TIPO_OGGETTO)
/


CREATE INDEX WKFCFGITE_PRO_IK ON WKF_CFG_ITER
(PROGRESSIVO)
/


CREATE UNIQUE INDEX WKF_CFG_ITER_PK ON WKF_CFG_ITER
(ID_CFG_ITER)
/


CREATE INDEX WKFCFGITE_WKFDIZTIPOGG_FK ON WKF_CFG_ITER
(TIPO_OGGETTO)
/


CREATE UNIQUE INDEX WKF_CFG_PULSANTI_PK ON WKF_CFG_PULSANTI
(ID_CFG_PULSANTE)
/


CREATE UNIQUE INDEX WKF_CFG_STEP_PK ON WKF_CFG_STEP
(ID_CFG_STEP)
/


CREATE INDEX WKF_CFPU_CFST_FK ON WKF_CFG_PULSANTI
(ID_CFG_STEP_SUCCESSIVO)
/


CREATE INDEX WKF_CFPU_CFST2_FK ON WKF_CFG_PULSANTI
(ID_CFG_STEP)
/


CREATE INDEX WKF_CFPU_DIPU_FK ON WKF_CFG_PULSANTI
(ID_PULSANTE)
/


CREATE INDEX WKF_CFST_CFIT_FK ON WKF_CFG_STEP
(ID_CFG_ITER)
/


CREATE INDEX WKF_CFST_CFST_FK ON WKF_CFG_STEP
(ID_CFG_STEP_NO)
/


CREATE INDEX WKF_CFST_CFST2_FK ON WKF_CFG_STEP
(ID_CFG_STEP_SI)
/


CREATE INDEX WKF_CFST_CFST3_FK ON WKF_CFG_STEP
(ID_CFG_STEP_SBLOCCO)
/


CREATE INDEX WKF_CFST_DGST_FK ON WKF_CFG_STEP
(ID_GRUPPO_STEP)
/


CREATE INDEX WKF_CFST_DIAZ_FK ON WKF_CFG_STEP
(ID_AZIONE_SBLOCCO)
/


CREATE INDEX WKF_CFST_DIAZ2_FK ON WKF_CFG_STEP
(ID_ATTORE)
/


CREATE INDEX WKF_CFST_DIAZ3_FK ON WKF_CFG_STEP
(ID_AZIONE_CONDIZIONE)
/


CREATE INDEX WKF_CPAT_CFPU_FK ON WKF_CFG_PULSANTI_ATTORI
(ID_CFG_PULSANTE)
/


CREATE INDEX WKF_CPAT_DIAZ_FK ON WKF_CFG_PULSANTI_ATTORI
(ID_ATTORE)
/


CREATE INDEX WKF_CSAI_DIAZ_FK ON WKF_CFG_STEP_AZIONI_IN
(ID_AZIONE_IN)
/


CREATE INDEX WKF_CSAO_DIAZ_FK ON WKF_CFG_STEP_AZIONI_OUT
(ID_AZIONE_OUT)
/


CREATE INDEX WKF_DAPA_DIAZ_FK ON WKF_DIZ_AZIONI_PARAMETRI
(ID_AZIONE)
/


CREATE INDEX WKF_DIAZ_DIAZ_FK ON WKF_DIZ_ATTORI
(ID_AZIONE_CALCOLO)
/


CREATE INDEX WKF_DIPU_DIAZ_FK ON WKF_DIZ_PULSANTI
(ID_CONDIZIONE_VISIBILITA)
/


CREATE UNIQUE INDEX WKF_DIZ_ATTORI_PK ON WKF_DIZ_ATTORI
(ID_ATTORE)
/


CREATE UNIQUE INDEX WKFDIZAZ_BNMTSQL_UK ON WKF_DIZ_AZIONI
(ISTRUZIONE_SQL, TIPO_OGGETTO, NOME_METODO, NOME_BEAN)
/


CREATE UNIQUE INDEX WKF_DIZ_AZIONI_PARAMETRI_PK ON WKF_DIZ_AZIONI_PARAMETRI
(ID_AZIONE_PARAMETRO)
/


CREATE UNIQUE INDEX WKF_DIZ_AZIONI_PK ON WKF_DIZ_AZIONI
(ID_AZIONE)
/


CREATE UNIQUE INDEX WKF_DIZ_GRUPPI_STEP_PK ON WKF_DIZ_GRUPPI_STEP
(ID_GRUPPO_STEP)
/


CREATE UNIQUE INDEX WKF_DIZ_PULSANTI_PK ON WKF_DIZ_PULSANTI
(ID_PULSANTE)
/


CREATE UNIQUE INDEX WKF_DIZ_TIPI_OGGETTO_PK ON WKF_DIZ_TIPI_OGGETTO
(CODICE)
/


CREATE INDEX WKF_DPAZ_DIAZ_FK ON WKF_DIZ_PULSANTI_AZIONI
(ID_AZIONE)
/


CREATE UNIQUE INDEX WKF_ENGINE_ITER_PK ON WKF_ENGINE_ITER
(ID_ENGINE_ITER)
/


CREATE UNIQUE INDEX WKF_ENGINE_STEP_ATTORI_PK ON WKF_ENGINE_STEP_ATTORI
(ID_ENGINE_ATTORE)
/


CREATE UNIQUE INDEX WKF_ENGINE_STEP_PK ON WKF_ENGINE_STEP
(ID_ENGINE_STEP)
/


CREATE INDEX WKF_ENIT_CGIT_FK ON WKF_ENGINE_ITER
(ID_CFG_ITER)
/


CREATE INDEX WKF_ENIT_ENST_FK ON WKF_ENGINE_ITER
(ID_STEP_CORRENTE)
/


CREATE INDEX WKF_ENSTA_ENST_FK ON WKF_ENGINE_STEP_ATTORI
(ID_ENGINE_STEP)
/


CREATE INDEX WKF_ENST_CFST_FK ON WKF_ENGINE_STEP
(ID_CFG_STEP)
/


CREATE INDEX WKF_ENST_ENIT_FK ON WKF_ENGINE_STEP
(ID_ENGINE_ITER)
/


CREATE UNIQUE INDEX WKF_IMPOSTAZIONI_PK ON WKF_IMPOSTAZIONI
(CODICE, ENTE)
/


CREATE INDEX WKF_PATI_DGST_FK ON PARAMETRI_TIPOLOGIE
(ID_GRUPPO_STEP)
/


CREATE OR REPLACE TRIGGER agp_protocolli_tiu
   BEFORE INSERT OR UPDATE
   ON AGP_PROTOCOLLI
   FOR EACH ROW
BEGIN
   IF     :new.tipo_registro IS NOT NULL
      AND (:new.anno IS NULL OR :new.numero IS NULL)
   THEN
      :new.tipo_registro := NULL;
   END IF;
END;
/


CREATE OR REPLACE TRIGGER gdo_coda_firma_tiu
   BEFORE INSERT OR UPDATE
   ON gdo_coda_firma
   FOR EACH ROW
BEGIN
   IF :new.utente_firmatario_effettivo IS NULL
   THEN
      :new.utente_firmatario_effettivo := :new.utente_firmatario;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/


CREATE OR REPLACE TRIGGER GDO_DOCUMENTI_TU
   AFTER UPDATE OF VALIDO
   ON GDO_DOCUMENTI
   FOR EACH ROW
DECLARE
   d_apri_fasc                   NUMBER := 0;
   d_esiste_altra_attestazione   NUMBER := 0;
BEGIN
   IF :NEW.VALIDO = 'N'
   THEN
      BEGIN
         SELECT -p.id_fascicolo
           INTO d_apri_fasc
           FROM agp_protocolli p, gdo_tipi_documento td
          WHERE     p.id_documento = :new.id_documento
                AND td.id_tipo_documento = p.id_tipo_protocollo
                AND td.codice =
                       GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                          'CONF_SCAN_FLUSSO',
                          :new.id_ente)
                AND p.numero IS NULL;

         UPDATE gdm_fascicoli
            SET data_chiusura = NULL, stato_fascicolo = 1
          WHERE id_documento = d_apri_fasc;

         DELETE gdm_riferimenti
          WHERE     tipo_relazione = 'PROT_FATCO'
                AND id_documento = :new.id_documento_esterno;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/


CREATE OR REPLACE TRIGGER GDO_TIPI_ALLEGATO_TIU
   BEFORE DELETE OR INSERT OR UPDATE
   ON GDO_TIPI_ALLEGATO
   FOR EACH ROW
BEGIN
   IF INTEGRITYPACKAGE.getNestLevel = 0
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
         'L''inserimento / eliminazione /aggiornamento dei tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
   END IF;
END;
/


CREATE OR REPLACE TRIGGER GDO_TIPI_DOCUMENTO_TIU
   BEFORE DELETE OR INSERT OR UPDATE
   ON GDO_TIPI_DOCUMENTO
   FOR EACH ROW
BEGIN
   IF INSERTING
   THEN
      IF :NEW.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'L''inserimento di nuovi tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;

   IF UPDATING
   THEN
      IF :OLD.ID_TIPO_DOCUMENTO < 0 AND :OLD.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'L''aggiornamento dei tipi di allegato va effettuato dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;

   IF DELETING
   THEN
      IF :OLD.ID_TIPO_DOCUMENTO < 0 AND :OLD.CODICE = 'ALLEGATO'
      THEN
         IF INTEGRITYPACKAGE.getNestLevel = 0
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'La cancellazione dei tipi di allegato va effettuata dalla maschera del relativo dizionario nel documentale.');
         END IF;
      END IF;
   END IF;
END;
/


CREATE OR REPLACE TRIGGER ag_meco_tiu
   BEFORE UPDATE OR INSERT
   ON agp_messaggi_corrispondenti
   FOR EACH ROW
DECLARE
BEGIN
   :new.email := TRIM (:new.email);
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/


CREATE OR REPLACE TRIGGER ag_prco_tiu
   BEFORE UPDATE OR INSERT
   ON agp_protocolli_corrispondenti
   FOR EACH ROW
DECLARE
BEGIN
   :new.email := TRIM (:new.email);
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/


CREATE OR REPLACE TRIGGER GDO_FILE_DOCUMENTO_TIU
   BEFORE INSERT OR UPDATE
   ON GDO_FILE_DOCUMENTO
   FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.content_type = 'application/pkcs7-mime'
   THEN
      :NEW.content_type := 'application/octet-stream';
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/


ALTER TABLE AGP_DOCUMENTI_DATI_SCARTO ADD (
  CONSTRAINT AGP_DOCUMENTI_DATI_SCARTO_PK
  PRIMARY KEY
  (ID_DOCUMENTO)
  USING INDEX AGP_DOCUMENTI_DATI_SCARTO_PK)
/

ALTER TABLE AGP_DOCUMENTI_SMISTAMENTI ADD (
  CONSTRAINT AGP_DOCUMENTI_SMISTAMENTI_PK
  PRIMARY KEY
  (ID_DOCUMENTO_SMISTAMENTO)
  USING INDEX AGP_DOCUMENTI_SMISTAMENTI_PK)
/

ALTER TABLE AGP_DOCUMENTI_TITOLARIO ADD (
  CONSTRAINT AGP_DOCUMENTI_TITOLARIO_PK
  PRIMARY KEY
  (ID_DOCUMENTO_TITOLARIO)
  USING INDEX AGP_DOCUMENTI_TITOLARIO_PK,
  CONSTRAINT AGP_DOCUMENTI_TITOLARIO_UK
  UNIQUE (ID_DOCUMENTO, ID_CLASSIFICAZIONE, ID_FASCICOLO)
  USING INDEX AGP_DOCUMENTI_TITOLARIO_UK)
/

ALTER TABLE AGP_MESSAGGI_CORRISPONDENTI ADD (
  CONSTRAINT AGP_MESSAGGI_CORRISPONDENTI_PK
  PRIMARY KEY
  (ID_MESSAGGIO_CORRISPONDENTE)
  USING INDEX AGP_MESSAGGI_CORRISPONDENTI_PK)
/

ALTER TABLE AGP_PROTOCOLLI ADD (
  CONSTRAINT AGP_PROT_MOVIMENTO_CC
  CHECK (MOVIMENTO IN ('ARRIVO', 'PARTENZA', 'INTERNO')),
  CONSTRAINT AGP_PROT_STATO_ARCHIVIO_CC
  CHECK (STATO_ARCHIVIO IN ('CORRENTE', 'DEPOSITO', 'ARCHIVIO')),
  CONSTRAINT AGP_PROTOCOLLI_PK
  PRIMARY KEY
  (ID_DOCUMENTO)
  USING INDEX AGP_PROTOCOLLI_PK,
  CONSTRAINT AGP_PROTOCOLLI_UK
  UNIQUE (ANNO, TIPO_REGISTRO, NUMERO)
  USING INDEX AGP_PROTOCOLLI_UK)
/

ALTER TABLE AGP_PROTOCOLLI_ANNULLAMENTI ADD (
  CONSTRAINT AGP_PROTOCOLLI_ANNULLAMENTI_PK
  PRIMARY KEY
  (ID_PROTOCOLLO_ANNULLAMENTO)
  USING INDEX AGP_PROTOCOLLI_ANNULLAMENTI_PK)
/

ALTER TABLE AGP_PROTOCOLLI_CORR_INDIRIZZI ADD (
  CONSTRAINT AGP_PCIN_PK
  PRIMARY KEY
  (ID_PROTOCOLLO_CORR_INDIRIZZO)
  USING INDEX AGP_PCIN_PK)
/

ALTER TABLE AGP_PROTOCOLLI_CORRISPONDENTI ADD (
  CONSTRAINT AGP_PROT_CORRISPONDENTI_PK
  PRIMARY KEY
  (ID_PROTOCOLLO_CORRISPONDENTE)
  USING INDEX AGP_PROT_CORRISPONDENTI_PK)
/

ALTER TABLE AGP_PROTOCOLLI_DATI_ACCESSO ADD (
  CONSTRAINT AGP_PROTOCOLLI_DATI_ACCESSO_PK
  PRIMARY KEY
  (ID_DATI_ACCESSO)
  USING INDEX AGP_PROTOCOLLI_DATI_ACCESSO_PK)
/

ALTER TABLE AGP_PROTOCOLLI_DATI_INTEROP ADD (
  CONSTRAINT AGP_PROTOCOLLI_DATI_INTEROP_PK
  PRIMARY KEY
  (ID_PROTOCOLLO_DATI_INTEROP)
  USING INDEX AGP_PROTOCOLLI_DATI_INTEROP_PK)
/

ALTER TABLE AGP_PROTOCOLLI_DATI_SCARTO ADD (
  CONSTRAINT AGP_PROTOCOLLI_DATI_SCARTO_PK
  PRIMARY KEY
  (ID_PROTOCOLLO_DATI_SCARTO)
  USING INDEX AGP_PROTOCOLLI_DATI_SCARTO_PK)
/

ALTER TABLE AGP_SCHEMI_COLLEGATI ADD (
  CONSTRAINT AGP_SCHEMI_COLLEGATI_PK
  PRIMARY KEY
  (ID_SCHEMA_COLLEGATO)
  USING INDEX AGP_SCHEMI_COLLEGATI_PK)
/

ALTER TABLE AGP_SCHEMI_PROT_ALLEGATI ADD (
  CONSTRAINT AGP_SCHEMI_PROT_ALLEGATI_PK
  PRIMARY KEY
  (ID_SCHEMA_PROT_ALLEGATI)
  USING INDEX AGP_SCHEMI_PROT_ALLEGATI_PK)
/

ALTER TABLE AGP_TIPI_ACCESSO_CIVICO ADD (
  CONSTRAINT AGP_TIPI_ACCESSO_CIVICO_PK
  PRIMARY KEY
  (ID_TIPO_ACCESSO_CIVICO)
  USING INDEX AGP_TIPI_ACCESSO_CIVICO_PK)
/

ALTER TABLE AGP_TIPI_ESITO_ACCESSO ADD (
  CONSTRAINT AGP_TIPI_ESITO_ACCESSO_TIPO_CC
  CHECK (TIPO in ('POSITIVO','NEGATIVO') and TIPO = upper(TIPO)),
  CONSTRAINT AGP_TIPI_ESITO_ACCESSO_PK
  PRIMARY KEY
  (ID_TIPO_ESITO)
  USING INDEX AGP_TIPI_ESITO_ACCESSO_PK)
/

ALTER TABLE AGP_TIPI_PROTOCOLLO ADD (
  CONSTRAINT AGP_TIPR_CATEGORIA_CC
  CHECK (CATEGORIA IN ('LETTERA','PROTOCOLLO','PEC','EMERGENZA','PROVVEDIMENTO','REGISTRO_GIORNALIERO','DA_NON_PROTOCOLLARE')),
  CONSTRAINT AGP_TIPI_PROTOCOLLO_PK
  PRIMARY KEY
  (ID_TIPO_PROTOCOLLO)
  USING INDEX AGP_TIPI_PROTOCOLLO_PK)
/

ALTER TABLE AGP_TIPI_RICHIEDENTE_ACCESSO ADD (
  CONSTRAINT AGP_TIPI_RICHIEDENTE_ACCE_PK
  PRIMARY KEY
  (ID_TIPO_RICHIEDENTE_ACCESSO)
  USING INDEX AGP_TIPI_RICHIEDENTE_ACCE_PK)
/

ALTER TABLE FIRMA_DIGITALE_FILE ADD (
  CONSTRAINT FIRMA_DIGITALE_FILE_PK
  PRIMARY KEY
  (ID)
  USING INDEX FIRMA_DIGITALE_FILE_PK)
/

ALTER TABLE FIRMA_DIGITALE_TRANSAZIONE ADD (
  CONSTRAINT FIRMA_DIGITALE_TRANSAZIONE_PK
  PRIMARY KEY
  (ID)
  USING INDEX FIRMA_DIGITALE_TRANSAZIONE_PK)
/

ALTER TABLE GDO_ALLEGATI ADD (
  CONSTRAINT GDO_ALLEGATI_PK
  PRIMARY KEY
  (ID_DOCUMENTO)
  USING INDEX GDO_ALLEGATI_PK)
/

ALTER TABLE GDO_CODA_FIRMA ADD (
  CONSTRAINT GDO_CODA_FIRMA_PK
  PRIMARY KEY
  (ID_CODA_FIRMA)
  USING INDEX GDO_CODA_FIRMA_PK)
/

ALTER TABLE GDO_DOCUMENTI ADD (
  CONSTRAINT GDO_DOCUMENTI_PK
  PRIMARY KEY
  (ID_DOCUMENTO)
  USING INDEX GDO_DOCUMENTI_PK)
/

ALTER TABLE GDO_DOCUMENTI_COLLEGATI ADD (
  CONSTRAINT GDO_DOCUMENTI_COLLEGATI_PK
  PRIMARY KEY
  (ID_DOCUMENTO_COLLEGATO)
  USING INDEX GDO_DOCUMENTI_COLLEGATI_PK)
/

ALTER TABLE GDO_DOCUMENTI_COMPETENZE ADD (
  CONSTRAINT GDO_DOCUMENTI_COMPETENZE_PK
  PRIMARY KEY
  (ID_DOCUMENTO_COMPETENZA)
  USING INDEX GDO_DOCUMENTI_COMPETENZE_PK)
/

ALTER TABLE GDO_DOCUMENTI_SOGGETTI ADD (
  CONSTRAINT GDO_DOCUMENTI_SOGGETTI_PK
  PRIMARY KEY
  (ID_DOCUMENTO_SOGGETTO)
  USING INDEX GDO_DOCUMENTI_SOGGETTI_PK)
/

ALTER TABLE GDO_DOCUMENTI_STORICO ADD (
  CONSTRAINT GDO_DOCUMENTI_STORICO_PK
  PRIMARY KEY
  (ID_DOCUMENTO_STORICO)
  USING INDEX GDO_DOCUMENTI_STORICO_PK)
/

ALTER TABLE GDO_EMAIL ADD (
  CONSTRAINT GDO_EMAIL_PK
  PRIMARY KEY
  (ID_EMAIL)
  USING INDEX GDO_EMAIL_PK)
/

ALTER TABLE GDO_ENTI ADD (
  CONSTRAINT GDO_ENTI_PK
  PRIMARY KEY
  (ID_ENTE)
  USING INDEX GDO_ENTI_PK)
/

ALTER TABLE GDO_FILE_DOCUMENTO ADD (
  CONSTRAINT GDO_FILE_DOCUMENTO_PK
  PRIMARY KEY
  (ID_FILE_DOCUMENTO)
  USING INDEX GDO_FILE_DOCUMENTO_PK)
/

ALTER TABLE GDO_FILE_DOCUMENTO_FIRMATARI ADD (
  CONSTRAINT GDO_FILE_DOCU_FIRMATARI_PK
  PRIMARY KEY
  (ID_FIRMATARIO)
  USING INDEX GDO_FILE_DOCU_FIRMATARI_PK)
/

ALTER TABLE GDO_NOTIFICHE ADD (
  CONSTRAINT GDO_NOTIFICHE_PK
  PRIMARY KEY
  (ID_NOTIFICA)
  USING INDEX GDO_NOTIFICHE_PK)
/

ALTER TABLE GDO_NOTIFICHE_ATTIVITA ADD (
  CONSTRAINT GDO_NOTIFICHE_ATTIVITA_PK
  PRIMARY KEY
  (ID_NOTIFICA_ATTIVITA)
  USING INDEX GDO_NOTIFICHE_ATTIVITA_PK)
/

ALTER TABLE GDO_NOTIFICHE_DESTINATARI ADD (
  CONSTRAINT GDO_NOTIFICHE_DESTINATARI_PK
  PRIMARY KEY
  (ID_NOTIFICA_DESTINATARIO)
  USING INDEX GDO_NOTIFICHE_DESTINATARI_PK)
/

ALTER TABLE GDO_TIPI_ALLEGATO ADD (
  CONSTRAINT GDO_TIPI_ALLEGATO_TABLE_PK
  PRIMARY KEY
  (ID_TIPO_DOCUMENTO)
  USING INDEX GDO_TIPI_ALLEGATO_TABLE_PK)
/

ALTER TABLE GDO_TIPI_COLLEGAMENTO ADD (
  CONSTRAINT GDO_TIPI_COLLEGAMENTO_PK
  PRIMARY KEY
  (ID_TIPO_COLLEGAMENTO)
  USING INDEX GDO_TIPI_COLLEGAMENTO_PK,
  CONSTRAINT GDO_TIPI_COLLEGAMENTO_UK
  UNIQUE (TIPO_COLLEGAMENTO, ID_ENTE)
  USING INDEX GDO_TIPI_COLLEGAMENTO_UK)
/

ALTER TABLE GDO_TIPI_DOCUMENTO ADD (
  CONSTRAINT GDO_TIPI_DOCUMENTO_PK
  PRIMARY KEY
  (ID_TIPO_DOCUMENTO)
  USING INDEX GDO_TIPI_DOCUMENTO_PK)
/

ALTER TABLE GDO_TIPI_DOCUMENTO_COMPETENZE ADD (
  CONSTRAINT GDO_TIDO_COMPETENZE_PK
  PRIMARY KEY
  (ID_TIPO_DOCUMENTO_COMPETENZE)
  USING INDEX GDO_TIDO_COMPETENZE_PK)
/

ALTER TABLE GDO_TIPI_DOCUMENTO_MODELLI ADD (
  CONSTRAINT GDO_TIPI_DOCUMENTO_MODELLI_PK
  PRIMARY KEY
  (ID_TIPO_DOCUMENTO_MODELLO)
  USING INDEX GDO_TIPI_DOCUMENTO_MODELLI_PK,
  CONSTRAINT GDO_TIPI_DOCUMENTO_MODELLI_UK
  UNIQUE (ID_TIPO_DOCUMENTO, ID_MODELLO, CODICE)
  USING INDEX GDO_TIPI_DOCUMENTO_MODELLI_UK)
/

ALTER TABLE GDO_TIPI_DOCUMENTO_PARERI ADD (
  CONSTRAINT GDO_TIPI_DOCUMENTO_PARERI_PK
  PRIMARY KEY
  (ID_TIPO_DOCUMENTO_PARERE)
  USING INDEX GDO_TIPI_DOCUMENTO_PARERI_PK,
  CONSTRAINT GDO_TIPI_DOCUMENTO_PARERI_UK
  UNIQUE (ID_TIPO_DOCUMENTO, ID_TIPO_PARERE)
  USING INDEX GDO_TIPI_DOCUMENTO_PARERI_UK)
/

ALTER TABLE GDO_TIPI_PARERE ADD (
  CONSTRAINT GDO_TIPI_PARERE
  PRIMARY KEY
  (ID_TIPO_PARERE)
  USING INDEX GDO_TIPI_PARERE)
/

ALTER TABLE GDO_TIPOLOGIE_SOGGETTO ADD (
  CONSTRAINT GDO_TISO_PK
  PRIMARY KEY
  (ID_TIPOLOGIA_SOGGETTO)
  USING INDEX GDO_TISO_PK)
/

ALTER TABLE GDO_TIPOLOGIE_SOGGETTO_REGOLE ADD (
  CONSTRAINT GDO_TIPOLOGIE_SOGG_REGOLE_PK
  PRIMARY KEY
  (ID_TIPOLOGIA_SOGGETTO_REGOLA)
  USING INDEX GDO_TIPOLOGIE_SOGG_REGOLE_PK)
/

ALTER TABLE GDO_TOKEN_INTEGRAZIONI ADD (
  CONSTRAINT GDO_TOKEN_INTEGRAZIONI_PK
  PRIMARY KEY
  (ID_TOKEN)
  USING INDEX GDO_TOKEN_INTEGRAZIONI_PK,
  CONSTRAINT GDO_TOKEN_INTEGRAZIONI_UK
  UNIQUE (TIPO, ID_RIFERIMENTO)
  USING INDEX GDO_TOKEN_INTEGRAZIONI_UK)
/

ALTER TABLE GTE_DETTAGLI_LOCK ADD (
  CONSTRAINT GTE_DETTAGLI_LOCK_PK
  PRIMARY KEY
  (ID_DETTAGLIO_LOCK)
  USING INDEX GTE_DETTAGLI_LOCK_PK)
/

ALTER TABLE GTE_LOCK ADD (
  CONSTRAINT GTE_LOCK_PK
  PRIMARY KEY
  (ID_RIFERIMENTO_TESTO)
  USING INDEX GTE_LOCK_PK)
/

ALTER TABLE GTE_MODELLI ADD (
  CONSTRAINT GTE_MODELLI_PK
  PRIMARY KEY
  (ID_MODELLO)
  USING INDEX GTE_MODELLI_PK)
/

ALTER TABLE GTE_MODELLI_COMPETENZA ADD (
  CONSTRAINT GTE_MODELLI_COMPETENZA_PK
  PRIMARY KEY
  (ID_MODELLI_COMPETENZA)
  USING INDEX GTE_MODELLI_COMPETENZA_PK)
/

ALTER TABLE GTE_TIPI_MODELLO ADD (
  CONSTRAINT GTE_TIPI_MODELLO_PK
  PRIMARY KEY
  (CODICE)
  USING INDEX GTE_TIPI_MODELLO_PK)
/

ALTER TABLE PARAMETRI_TIPOLOGIE ADD (
  CONSTRAINT PARAMETRI_TIPOLOGIE_PK
  PRIMARY KEY
  (ID_PARAMETRO_TIPOLOGIA)
  USING INDEX PARAMETRI_TIPOLOGIE_PK)
/

ALTER TABLE WKF_CFG_COMPETENZE ADD (
  CONSTRAINT WKF_CFG_COMPETENZE_PK
  PRIMARY KEY
  (ID_CFG_COMPETENZA)
  USING INDEX WKF_CFG_COMPETENZE_PK)
/

ALTER TABLE WKF_CFG_ITER ADD (
  CONSTRAINT WKF_CFG_ITER_PK
  PRIMARY KEY
  (ID_CFG_ITER)
  USING INDEX WKF_CFG_ITER_PK)
/

ALTER TABLE WKF_CFG_PULSANTI ADD (
  CONSTRAINT WKF_CFG_PULSANTI_PK
  PRIMARY KEY
  (ID_CFG_PULSANTE)
  USING INDEX WKF_CFG_PULSANTI_PK)
/

ALTER TABLE WKF_CFG_STEP ADD (
  CONSTRAINT WKF_CFG_STEP_PK
  PRIMARY KEY
  (ID_CFG_STEP)
  USING INDEX WKF_CFG_STEP_PK)
/

ALTER TABLE WKF_DIZ_ATTORI ADD (
  CONSTRAINT WKF_DIZ_ATTORI_PK
  PRIMARY KEY
  (ID_ATTORE)
  USING INDEX WKF_DIZ_ATTORI_PK)
/

ALTER TABLE WKF_DIZ_AZIONI ADD (
  CONSTRAINT WKF_DIZ_AZIONI_PK
  PRIMARY KEY
  (ID_AZIONE)
  USING INDEX WKF_DIZ_AZIONI_PK,
  CONSTRAINT WKFDIZAZ_BNMTSQL_UK
  UNIQUE (ISTRUZIONE_SQL, TIPO_OGGETTO, NOME_METODO, NOME_BEAN)
  USING INDEX WKFDIZAZ_BNMTSQL_UK)
/

ALTER TABLE WKF_DIZ_AZIONI_PARAMETRI ADD (
  CONSTRAINT WKF_DIZ_AZIONI_PARAMETRI_PK
  PRIMARY KEY
  (ID_AZIONE_PARAMETRO)
  USING INDEX WKF_DIZ_AZIONI_PARAMETRI_PK)
/

ALTER TABLE WKF_DIZ_GRUPPI_STEP ADD (
  CONSTRAINT WKF_DIZ_GRUPPI_STEP_PK
  PRIMARY KEY
  (ID_GRUPPO_STEP)
  USING INDEX WKF_DIZ_GRUPPI_STEP_PK)
/

ALTER TABLE WKF_DIZ_PULSANTI ADD (
  CONSTRAINT WKF_DIZ_PULSANTI_PK
  PRIMARY KEY
  (ID_PULSANTE)
  USING INDEX WKF_DIZ_PULSANTI_PK)
/

ALTER TABLE WKF_DIZ_TIPI_OGGETTO ADD (
  CONSTRAINT WKF_DIZ_TIPI_OGGETTO_PK
  PRIMARY KEY
  (CODICE)
  USING INDEX WKF_DIZ_TIPI_OGGETTO_PK)
/

ALTER TABLE WKF_ENGINE_ITER ADD (
  CONSTRAINT WKF_ENGINE_ITER_PK
  PRIMARY KEY
  (ID_ENGINE_ITER)
  USING INDEX WKF_ENGINE_ITER_PK)
/

ALTER TABLE WKF_ENGINE_STEP ADD (
  CONSTRAINT WKF_ENGINE_STEP_PK
  PRIMARY KEY
  (ID_ENGINE_STEP)
  USING INDEX WKF_ENGINE_STEP_PK)
/

ALTER TABLE WKF_ENGINE_STEP_ATTORI ADD (
  CONSTRAINT WKF_ENGINE_STEP_ATTORI_PK
  PRIMARY KEY
  (ID_ENGINE_ATTORE)
  USING INDEX WKF_ENGINE_STEP_ATTORI_PK)
/

ALTER TABLE WKF_IMPOSTAZIONI ADD (
  CONSTRAINT WKF_IMPOSTAZIONI_PK
  PRIMARY KEY
  (CODICE, ENTE)
  USING INDEX WKF_IMPOSTAZIONI_PK)
/

ALTER TABLE AGP_DOCUMENTI_DATI_SCARTO ADD (
  CONSTRAINT AGP_DDSC_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO))
/

ALTER TABLE AGP_DOCUMENTI_SMISTAMENTI ADD (
  CONSTRAINT AGP_DOSM_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO))
/

ALTER TABLE AGP_DOCUMENTI_TITOLARIO ADD (
  CONSTRAINT AGP_DOTI_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO))
/

ALTER TABLE AGP_PROTOCOLLI ADD (
  CONSTRAINT AGP_PROT_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO),
  CONSTRAINT AGP_PROT_PDIN_FK
  FOREIGN KEY (ID_PROTOCOLLO_DATI_INTEROP)
  REFERENCES AGP_PROTOCOLLI_DATI_INTEROP (ID_PROTOCOLLO_DATI_INTEROP),
  CONSTRAINT AGP_PROT_TIPR_FK
  FOREIGN KEY (ID_TIPO_PROTOCOLLO)
  REFERENCES AGP_TIPI_PROTOCOLLO (ID_TIPO_PROTOCOLLO))
/

ALTER TABLE AGP_PROTOCOLLI_ANNULLAMENTI ADD (
  CONSTRAINT AGP_PRAN_PROT_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES AGP_PROTOCOLLI (ID_DOCUMENTO))
/

ALTER TABLE AGP_PROTOCOLLI_CORRISPONDENTI ADD (
  CONSTRAINT AGP_PRCO_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES AGP_PROTOCOLLI (ID_DOCUMENTO))
/

ALTER TABLE AGP_PROTOCOLLI_DATI_ACCESSO ADD (
  CONSTRAINT AGP_PDAC_PROT_DOMA_FK
  FOREIGN KEY (ID_PROTOCOLLO_DOMANDA)
  REFERENCES AGP_PROTOCOLLI (ID_DOCUMENTO),
  CONSTRAINT AGP_PDAC_PROT_RISP_FK
  FOREIGN KEY (ID_PROTOCOLLO_RISPOSTA)
  REFERENCES AGP_PROTOCOLLI (ID_DOCUMENTO),
  CONSTRAINT AGP_PDAC_TACC_FK
  FOREIGN KEY (ID_TIPO_ACCESSO_CIVICO)
  REFERENCES AGP_TIPI_ACCESSO_CIVICO (ID_TIPO_ACCESSO_CIVICO),
  CONSTRAINT AGP_PDAC_TEAC_FK
  FOREIGN KEY (ID_TIPO_ESITO)
  REFERENCES AGP_TIPI_ESITO_ACCESSO (ID_TIPO_ESITO),
  CONSTRAINT AGP_PDAC_TRAC_FK
  FOREIGN KEY (ID_TIPO_RICHIEDENTE_ACCESSO)
  REFERENCES AGP_TIPI_RICHIEDENTE_ACCESSO (ID_TIPO_RICHIEDENTE_ACCESSO))
/

ALTER TABLE AGP_SCHEMI_PROT_ALLEGATI ADD (
  CONSTRAINT GDO_SPAL_TIAL_FK
  FOREIGN KEY (ID_TIPO_ALLEGATO)
  REFERENCES GDO_TIPI_ALLEGATO (ID_TIPO_DOCUMENTO))
/

ALTER TABLE FIRMA_DIGITALE_FILE ADD (
  CONSTRAINT FDFI_FDTR_FK
  FOREIGN KEY (TRANSAZIONE_ID)
  REFERENCES FIRMA_DIGITALE_TRANSAZIONE (ID))
/

ALTER TABLE GDO_CODA_FIRMA ADD (
  CONSTRAINT COFI_FIDITR_ID_FK
  FOREIGN KEY (ID_TRANSAZIONE_FIRMA)
  REFERENCES FIRMA_DIGITALE_TRANSAZIONE (ID),
  CONSTRAINT GDO_COFI_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO),
  CONSTRAINT GDO_COFI_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE))
/

ALTER TABLE GDO_DOCUMENTI ADD (
  CONSTRAINT GDO_DOCU_ENIT_FK
  FOREIGN KEY (ID_ENGINE_ITER)
  REFERENCES WKF_ENGINE_ITER (ID_ENGINE_ITER),
  CONSTRAINT GDO_DOCU_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE),
  CONSTRAINT GDO_DOCU_TIOG_FK
  FOREIGN KEY (TIPO_OGGETTO)
  REFERENCES WKF_DIZ_TIPI_OGGETTO (CODICE))
/

ALTER TABLE GDO_DOCUMENTI_COLLEGATI ADD (
  CONSTRAINT GDO_DOCO_DOCU2_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO),
  CONSTRAINT GDO_DOCO_DOCU3_FK
  FOREIGN KEY (ID_COLLEGATO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO),
  CONSTRAINT GDO_DOCO_TICO_FK
  FOREIGN KEY (ID_TIPO_COLLEGAMENTO)
  REFERENCES GDO_TIPI_COLLEGAMENTO (ID_TIPO_COLLEGAMENTO))
/

ALTER TABLE GDO_DOCUMENTI_COMPETENZE ADD (
  CONSTRAINT GDO_DOCO_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO)
  ON DELETE CASCADE,
  CONSTRAINT GDO_DOCO_WKFCFGCOM_FK
  FOREIGN KEY (ID_CFG_COMPETENZA)
  REFERENCES WKF_CFG_COMPETENZE (ID_CFG_COMPETENZA))
/

ALTER TABLE GDO_DOCUMENTI_STORICO ADD (
  CONSTRAINT GDO_DOST_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO))
/

ALTER TABLE GDO_FILE_DOCUMENTO ADD (
  CONSTRAINT FIDO_FIDOSTO_FK
  FOREIGN KEY (ID_FILE_DOCUMENTO_STORICO)
  REFERENCES GDO_FILE_DOCUMENTO (ID_FILE_DOCUMENTO),
  CONSTRAINT FIDO_MODE_FK
  FOREIGN KEY (ID_MODELLO_TESTO)
  REFERENCES GTE_MODELLI (ID_MODELLO),
  CONSTRAINT GDO_FIDO_FIDO_FK
  FOREIGN KEY (FILE_ORIGINALE_ID)
  REFERENCES GDO_FILE_DOCUMENTO (ID_FILE_DOCUMENTO))
/

ALTER TABLE GDO_FILE_DOCUMENTO_FIRMATARI ADD (
  CONSTRAINT GDO_FDFI_FIDO_FK
  FOREIGN KEY (ID_FILE_DOCUMENTO)
  REFERENCES GDO_FILE_DOCUMENTO (ID_FILE_DOCUMENTO))
/

ALTER TABLE GDO_NOTIFICHE ADD (
  CONSTRAINT GDO_NOTI_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE))
/

ALTER TABLE GDO_NOTIFICHE_DESTINATARI ADD (
  CONSTRAINT GDO_NODE_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE),
  CONSTRAINT GDO_NODE_NOTI_FK
  FOREIGN KEY (ID_NOTIFICA)
  REFERENCES GDO_NOTIFICHE (ID_NOTIFICA))
/

ALTER TABLE GDO_TIPI_ALLEGATO ADD (
  CONSTRAINT GDO_TIAL_TIDO_FK
  FOREIGN KEY (ID_TIPO_DOCUMENTO)
  REFERENCES GDO_TIPI_DOCUMENTO (ID_TIPO_DOCUMENTO))
/

ALTER TABLE GDO_TIPI_COLLEGAMENTO ADD (
  CONSTRAINT GDO_TICO_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE))
/

ALTER TABLE GDO_TIPI_DOCUMENTO ADD (
  CONSTRAINT GDO_TIDO_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE),
  CONSTRAINT GDO_TIDO_TISO_FK
  FOREIGN KEY (ID_TIPOLOGIA_SOGGETTO)
  REFERENCES GDO_TIPOLOGIE_SOGGETTO (ID_TIPOLOGIA_SOGGETTO))
/

ALTER TABLE GDO_TIPI_DOCUMENTO_COMPETENZE ADD (
  CONSTRAINT GDO_TDCO_TIDO_FK
  FOREIGN KEY (ID_TIPO_DOCUMENTO)
  REFERENCES GDO_TIPI_DOCUMENTO (ID_TIPO_DOCUMENTO)
  ON DELETE CASCADE)
/

ALTER TABLE GDO_TIPI_DOCUMENTO_MODELLI ADD (
  CONSTRAINT GDO_TDMT_MODE_FK
  FOREIGN KEY (ID_MODELLO)
  REFERENCES GTE_MODELLI (ID_MODELLO),
  CONSTRAINT GDO_TDMT_TIDO_FK
  FOREIGN KEY (ID_TIPO_DOCUMENTO)
  REFERENCES GDO_TIPI_DOCUMENTO (ID_TIPO_DOCUMENTO))
/

ALTER TABLE GDO_TIPI_DOCUMENTO_PARERI ADD (
  CONSTRAINT GDO_TDPA_TIDO_FK
  FOREIGN KEY (ID_TIPO_DOCUMENTO)
  REFERENCES GDO_TIPI_DOCUMENTO (ID_TIPO_DOCUMENTO),
  CONSTRAINT GDO_TDPA_TIPA_FK
  FOREIGN KEY (ID_TIPO_PARERE)
  REFERENCES GDO_TIPI_PARERE (ID_TIPO_PARERE))
/

ALTER TABLE GDO_TIPI_PARERE ADD (
  CONSTRAINT GDO_TIPA_MODE_FK
  FOREIGN KEY (ID_MODELLO_TESTO)
  REFERENCES GTE_MODELLI (ID_MODELLO),
  CONSTRAINT GDO_TIPA_TISO_FK
  FOREIGN KEY (ID_TIPOLOGIA_SOGGETTO)
  REFERENCES GDO_TIPOLOGIE_SOGGETTO (ID_TIPOLOGIA_SOGGETTO))
/

ALTER TABLE GDO_TIPOLOGIE_SOGGETTO ADD (
  CONSTRAINT GDO_TISO_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE),
  CONSTRAINT GDO_TISO_TIOG_FK
  FOREIGN KEY (TIPO_OGGETTO)
  REFERENCES WKF_DIZ_TIPI_OGGETTO (CODICE))
/

ALTER TABLE GDO_TIPOLOGIE_SOGGETTO_REGOLE ADD (
  CONSTRAINT GDO_TSRE_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE),
  CONSTRAINT GDO_TSRE_TISO_FK
  FOREIGN KEY (ID_TIPOLOGIA_SOGGETTO)
  REFERENCES GDO_TIPOLOGIE_SOGGETTO (ID_TIPOLOGIA_SOGGETTO))
/

ALTER TABLE GTE_DETTAGLI_LOCK ADD (
  CONSTRAINT GTE_DELO_LOCK_FK
  FOREIGN KEY (ID_LOCK)
  REFERENCES GTE_LOCK (ID_RIFERIMENTO_TESTO),
  CONSTRAINT GTE_DELO_TIMO_FK
  FOREIGN KEY (ID_TIPO_MODELLO)
  REFERENCES GTE_TIPI_MODELLO (CODICE))
/

ALTER TABLE GTE_MODELLI ADD (
  CONSTRAINT GTETESMOD_GTETIPMOD_FK
  FOREIGN KEY (TIPO_MODELLO)
  REFERENCES GTE_TIPI_MODELLO (CODICE))
/

ALTER TABLE GTE_MODELLI_COMPETENZA ADD (
  CONSTRAINT GTE_MOCO_MODE_FK
  FOREIGN KEY (ID_MODELLO)
  REFERENCES GTE_MODELLI (ID_MODELLO))
/

ALTER TABLE PARAMETRI_TIPOLOGIE ADD (
  CONSTRAINT WKF_PATI_DGST_FK
  FOREIGN KEY (ID_GRUPPO_STEP)
  REFERENCES WKF_DIZ_GRUPPI_STEP (ID_GRUPPO_STEP))
/

ALTER TABLE WKF_CFG_COMPETENZE ADD (
  CONSTRAINT WKF_CFCO_CFST_FK
  FOREIGN KEY (ID_CFG_STEP)
  REFERENCES WKF_CFG_STEP (ID_CFG_STEP),
  CONSTRAINT WKF_CFCO_DIAZ_FK
  FOREIGN KEY (ID_ATTORE)
  REFERENCES WKF_DIZ_ATTORI (ID_ATTORE),
  CONSTRAINT WKF_CFCO_DIPU_FK
  FOREIGN KEY (ID_PULSANTE)
  REFERENCES WKF_DIZ_PULSANTI (ID_PULSANTE),
  CONSTRAINT WKF_CFCO_DIPU2_FK
  FOREIGN KEY (ID_PULSANTE_PROVENIENZA)
  REFERENCES WKF_DIZ_PULSANTI (ID_PULSANTE))
/

ALTER TABLE WKF_CFG_PULSANTI ADD (
  CONSTRAINT WKF_CFPU_CFST_FK
  FOREIGN KEY (ID_CFG_STEP_SUCCESSIVO)
  REFERENCES WKF_CFG_STEP (ID_CFG_STEP),
  CONSTRAINT WKF_CFPU_CFST2_FK
  FOREIGN KEY (ID_CFG_STEP)
  REFERENCES WKF_CFG_STEP (ID_CFG_STEP),
  CONSTRAINT WKF_CFPU_DIPU_FK
  FOREIGN KEY (ID_PULSANTE)
  REFERENCES WKF_DIZ_PULSANTI (ID_PULSANTE))
/

ALTER TABLE WKF_CFG_PULSANTI_ATTORI ADD (
  CONSTRAINT WKF_CPAT_CFPU_FK
  FOREIGN KEY (ID_CFG_PULSANTE)
  REFERENCES WKF_CFG_PULSANTI (ID_CFG_PULSANTE),
  CONSTRAINT WKF_CPAT_DIAZ_FK
  FOREIGN KEY (ID_ATTORE)
  REFERENCES WKF_DIZ_ATTORI (ID_ATTORE))
/

ALTER TABLE WKF_CFG_STEP ADD (
  CONSTRAINT WKF_CFST_CFIT_FK
  FOREIGN KEY (ID_CFG_ITER)
  REFERENCES WKF_CFG_ITER (ID_CFG_ITER),
  CONSTRAINT WKF_CFST_CFST_FK
  FOREIGN KEY (ID_CFG_STEP_NO)
  REFERENCES WKF_CFG_STEP (ID_CFG_STEP),
  CONSTRAINT WKF_CFST_CFST2_FK
  FOREIGN KEY (ID_CFG_STEP_SI)
  REFERENCES WKF_CFG_STEP (ID_CFG_STEP),
  CONSTRAINT WKF_CFST_CFST3_FK
  FOREIGN KEY (ID_CFG_STEP_SBLOCCO)
  REFERENCES WKF_CFG_STEP (ID_CFG_STEP),
  CONSTRAINT WKF_CFST_DGST_FK
  FOREIGN KEY (ID_GRUPPO_STEP)
  REFERENCES WKF_DIZ_GRUPPI_STEP (ID_GRUPPO_STEP),
  CONSTRAINT WKF_CFST_DIAZ_FK
  FOREIGN KEY (ID_AZIONE_SBLOCCO)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE),
  CONSTRAINT WKF_CFST_DIAZ2_FK
  FOREIGN KEY (ID_ATTORE)
  REFERENCES WKF_DIZ_ATTORI (ID_ATTORE),
  CONSTRAINT WKF_CFST_DIAZ3_FK
  FOREIGN KEY (ID_AZIONE_CONDIZIONE)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE))
/

ALTER TABLE WKF_CFG_STEP_AZIONI_IN ADD (
  CONSTRAINT WKF_CSAI_DIAZ_FK
  FOREIGN KEY (ID_AZIONE_IN)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE))
/

ALTER TABLE WKF_CFG_STEP_AZIONI_OUT ADD (
  CONSTRAINT WKF_CSAO_DIAZ_FK
  FOREIGN KEY (ID_AZIONE_OUT)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE))
/

ALTER TABLE WKF_DIZ_ATTORI ADD (
  CONSTRAINT WKF_DIAZ_DIAZ_FK
  FOREIGN KEY (ID_AZIONE_CALCOLO)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE))
/

ALTER TABLE WKF_DIZ_AZIONI_PARAMETRI ADD (
  CONSTRAINT WKF_DAPA_DIAZ_FK
  FOREIGN KEY (ID_AZIONE)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE))
/

ALTER TABLE WKF_DIZ_PULSANTI ADD (
  CONSTRAINT WKF_DIPU_DIAZ_FK
  FOREIGN KEY (ID_CONDIZIONE_VISIBILITA)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE))
/

ALTER TABLE WKF_DIZ_PULSANTI_AZIONI ADD (
  CONSTRAINT WKF_DPAZ_DIAZ_FK
  FOREIGN KEY (ID_AZIONE)
  REFERENCES WKF_DIZ_AZIONI (ID_AZIONE))
/

ALTER TABLE WKF_ENGINE_ITER ADD (
  CONSTRAINT WKF_ENIT_CGIT_FK
  FOREIGN KEY (ID_CFG_ITER)
  REFERENCES WKF_CFG_ITER (ID_CFG_ITER),
  CONSTRAINT WKF_ENIT_ENST_FK
  FOREIGN KEY (ID_STEP_CORRENTE)
  REFERENCES WKF_ENGINE_STEP (ID_ENGINE_STEP))
/

ALTER TABLE WKF_ENGINE_STEP ADD (
  CONSTRAINT WKF_ENST_CFST_FK
  FOREIGN KEY (ID_CFG_STEP)
  REFERENCES WKF_CFG_STEP (ID_CFG_STEP),
  CONSTRAINT WKF_ENST_ENIT_FK
  FOREIGN KEY (ID_ENGINE_ITER)
  REFERENCES WKF_ENGINE_ITER (ID_ENGINE_ITER))
/

ALTER TABLE WKF_ENGINE_STEP_ATTORI ADD (
  CONSTRAINT WKF_ENSTA_ENST_FK
  FOREIGN KEY (ID_ENGINE_STEP)
  REFERENCES WKF_ENGINE_STEP (ID_ENGINE_STEP))
/
