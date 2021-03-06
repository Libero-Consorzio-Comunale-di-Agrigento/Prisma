--liquibase formatted sql
--changeset esasdelli:20200219_AGSPR
CREATE TABLE AG_ABILITAZIONI_SMISTAMENTO
(
  TIPO_SMISTAMENTO             VARCHAR2(20 BYTE) NOT NULL,
  STATO_SMISTAMENTO            VARCHAR2(1 BYTE) NOT NULL,
  AZIONE                       VARCHAR2(20 BYTE) NOT NULL,
  TIPO_SMISTAMENTO_GENERABILE  VARCHAR2(20 BYTE) NOT NULL,
  AOO                          NUMBER           NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_ABILITAZIONI_SMISTAMENTO IS ' In base a tipo di smistamento e stato dello smistamento per cui si accede al documento, in questa tabella si indica se si puo'' ulteriormente smistare o inoltrare e il tipo di smistamento che verra'' generato.'
/

COMMENT ON COLUMN AG_ABILITAZIONI_SMISTAMENTO.TIPO_SMISTAMENTO IS 'tipo smistamento per cui si è ricevuto il documento'
/

COMMENT ON COLUMN AG_ABILITAZIONI_SMISTAMENTO.STATO_SMISTAMENTO IS 'stato in cui si ha il documento (da ricevere, in carico...)'
/

COMMENT ON COLUMN AG_ABILITAZIONI_SMISTAMENTO.AZIONE IS 'Azione che si puo'' compiere (smistare, inoltrare)'
/

COMMENT ON COLUMN AG_ABILITAZIONI_SMISTAMENTO.TIPO_SMISTAMENTO_GENERABILE IS 'Tipo smistamento che verra'' attribuito al nuovo passaggio'
/

COMMENT ON COLUMN AG_ABILITAZIONI_SMISTAMENTO.AOO IS 'Indice dell''Aoo nella tabella PARAMETRI'
/


CREATE TABLE AG_ACQUISIZIONE_ALLEGATI
(
  APPLICATIVO_ESTERNO           VARCHAR2(10 BYTE),
  ID_DOC_ESTERNO                NUMBER(10),
  APPLICATIVO_ESTERNO_ALLEGATO  VARCHAR2(10 BYTE),
  ID_DOC_ALLEGATO               NUMBER(10),
  DESCRIZIONE                   VARCHAR2(1000 BYTE),
  TIPO_DOCUMENTO                VARCHAR2(100 BYTE),
  FILE_DOCUMENTO                BLOB,
  NOMEFILE                      VARCHAR2(255 BYTE),
  STATO_FIRMA                   VARCHAR2(2 BYTE) DEFAULT 'DF'
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_ACQUISIZIONE_PROTOCOLLI
(
  APPLICATIVO_ESTERNO   VARCHAR2(10 BYTE),
  ID_DOC_ESTERNO        NUMBER(10),
  MOVIMENTO             VARCHAR2(10 BYTE)       DEFAULT 'PAR'                 NOT NULL,
  CODICE_MODELLO        VARCHAR2(100 BYTE)      NOT NULL,
  OGGETTO               VARCHAR2(1000 BYTE)     NOT NULL,
  CLASSIFICAZIONE       VARCHAR2(40 BYTE),
  ANNO_CLA              NUMBER(4),
  NUMERO_CLA            VARCHAR2(30 BYTE),
  UNITA_ESIBENTE        VARCHAR2(50 BYTE),
  UNITA_PROTOCOLLANTE   VARCHAR2(16 BYTE)       NOT NULL,
  UTENTE_PROTOCOLLANTE  VARCHAR2(40 BYTE)       NOT NULL,
  NOTE                  VARCHAR2(10 BYTE),
  APRI_REGISTRO         VARCHAR2(1 BYTE)        DEFAULT 'N'                   NOT NULL,
  UTENTE_DIRIGENTE      VARCHAR2(8 BYTE)        NOT NULL,
  FILE_DOCUMENTO        BLOB,
  STATO_ACQUISIZIONE    VARCHAR2(100 BYTE)      DEFAULT 'ELABORARE'           NOT NULL,
  NOMEFILE              VARCHAR2(255 BYTE),
  TIPO_DOCUMENTO        VARCHAR2(10 BYTE)
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON COLUMN AG_ACQUISIZIONE_PROTOCOLLI.UTENTE_DIRIGENTE IS 'Codice utente del dirigente che deve firmare il documento'
/

COMMENT ON COLUMN AG_ACQUISIZIONE_PROTOCOLLI.FILE_DOCUMENTO IS 'File da acquisire'
/

COMMENT ON COLUMN AG_ACQUISIZIONE_PROTOCOLLI.STATO_ACQUISIZIONE IS 'Stato elaborazione record: ELABORARE, ELABORANDO, ELABORATO, COLLEGATO che viene setta da applicativo esterno quando riceve i dati'
/


CREATE TABLE AG_ACQUISIZIONE_RAPPORTI
(
  ID_DOC_ESTERNO          NUMBER                NOT NULL,
  APPLICATIVO_ESTERNO     VARCHAR2(200 BYTE)    NOT NULL,
  TIPO_RAPPORTO           VARCHAR2(4 BYTE)      DEFAULT 'DEST'                NOT NULL,
  CODICE_FISCALE          VARCHAR2(50 BYTE),
  PARTITA_IVA             VARCHAR2(50 BYTE),
  CODICE_AMMINISTRAZIONE  VARCHAR2(50 BYTE),
  CODICE_AOO              VARCHAR2(50 BYTE),
  DENOMINAZIONE_AMM       VARCHAR2(240 BYTE),
  DENOMINAZIONE_AOO       VARCHAR2(240 BYTE),
  COGNOME                 VARCHAR2(240 BYTE),
  NOME                    VARCHAR2(36 BYTE),
  INDIRIZZO_RESIDENZA     VARCHAR2(2000 BYTE),
  PROVINCIA_RESIDENZA     VARCHAR2(50 BYTE),
  COMUNE_RESIDENZA        VARCHAR2(50 BYTE),
  TELEFONO_RESIDENZA      VARCHAR2(200 BYTE),
  FAX_RESIDENZA           VARCHAR2(200 BYTE),
  EMAIL                   VARCHAR2(750 BYTE),
  TIPO_SOGGETTO           NUMBER                DEFAULT 1                     NOT NULL,
  CAP_RESIDENZA           VARCHAR2(5 BYTE),
  PROGRESSIVO             NUMBER                NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_CS_MESSAGGI
(
  ID_DOCUMENTO_MEMO        NUMBER(10)           NOT NULL,
  ID_CS_MESSAGGIO          NUMBER(10)           NOT NULL,
  ID_DOCUMENTO_PROTOCOLLO  NUMBER(10)           NOT NULL,
  STATO_SPEDIZIONE         VARCHAR2(20 BYTE)    DEFAULT 'READYTOSEND'         NOT NULL,
  DATA_MODIFICA            DATE                 DEFAULT SYSDATE               NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_DOCUMENT_TOPRO
(
  IDDOCUMENTO  NUMBER(9)                        NOT NULL,
  DST_NUMBER   VARCHAR2(100 BYTE)               NOT NULL,
  OGGFILE      BLOB
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_DST
(
  DST_NUMBER  VARCHAR2(100 BYTE)                NOT NULL,
  UTENTE      VARCHAR2(40 BYTE)                 NOT NULL,
  PASSWORD    VARCHAR2(1000 BYTE),
  ISTANZA     VARCHAR2(10 BYTE)                 NOT NULL,
  DATA        DATE                              NOT NULL,
  ENTE        VARCHAR2(200 BYTE)                NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_ERR_TABLE
(
  ERR_CODE   NUMBER(9)                          NOT NULL,
  ERR_DESCR  VARCHAR2(200 BYTE)                 NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_LOG
(
  LOG_ID            NUMBER                      NOT NULL,
  LOG_DATE          DATE,
  LOG_TITLE         VARCHAR2(4000 BYTE),
  LOG_TEXT          CLOB,
  LOG_USER          VARCHAR2(20 BYTE),
  LOG_ELAPSED_TIME  NUMBER,
  LOG_LEVEL         VARCHAR2(20 BYTE)
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_MEMO_KEY
(
  MESSAGE_ID  VARCHAR2(100 BYTE)                NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_NUMERAZIONI_ESTERNE
(
  APPLICATIVO_ESTERNO       VARCHAR2(100 BYTE)  NOT NULL,
  ID_DOCUMENTO_ESTERNO      NUMBER              NOT NULL,
  ANNO_PROTOCOLLO           NUMBER,
  TIPO_REGISTRO_PROTOCOLLO  VARCHAR2(100 BYTE),
  NUMERO_PROTOCOLLO         NUMBER,
  DATA_PROTOCOLLO           DATE,
  ANNO_DETERMINA            NUMBER,
  TIPO_REGISTRO_DETERMINA   VARCHAR2(100 BYTE),
  NUMERO_DETERMINA          NUMBER,
  DATA_DETERMINA            DATE,
  FILE_DA_RESTITUIRE        BLOB
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_PATCH
(
  CODICE       VARCHAR2(100 BYTE)               NOT NULL,
  MIN_VERSION  VARCHAR2(20 BYTE)                NOT NULL,
  UTENTE       VARCHAR2(8 BYTE)                 NOT NULL,
  IS_CRITICAL  VARCHAR2(1 BYTE)                 NOT NULL,
  DATA         DATE                             NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_PRIV_D_UTENTE_TMP
(
  UTENTE            VARCHAR2(8 BYTE),
  UNITA             VARCHAR2(50 BYTE),
  RUOLO             VARCHAR2(8 BYTE),
  PRIVILEGIO        VARCHAR2(20 BYTE),
  DAL               DATE                        NOT NULL,
  AL                DATE,
  PROGR_UNITA       NUMBER(8),
  IS_ULTIMA_CHIUSA  NUMBER(1)                   DEFAULT 0
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_PRIV_D_UTENTE_TMP IS 'Per ogni utente registra le unita per le quali l''utente ha un ruolo, il ruoli e i relativi privilegi. Un utente ha ruolo per un''unita se vi appartiene (APPARTENZA D)'
/


CREATE TABLE AG_PRIVILEGI
(
  PRIVILEGIO     VARCHAR2(20 BYTE)              NOT NULL,
  DESCRIZIONE    VARCHAR2(100 BYTE)             NOT NULL,
  IS_UNIVERSALE  NUMBER                         DEFAULT 0
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_PRIVILEGI_RUOLO
(
  PRIVILEGIO  VARCHAR2(20 BYTE)                 NOT NULL,
  RUOLO       VARCHAR2(8 BYTE)                  NOT NULL,
  AOO         NUMBER                            DEFAULT 1                     NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_PRIVILEGI_RUOLO IS 'Tabella che associa i ruoli ai privilegi operativi dell''applicativo di Affari Generali'
/


CREATE TABLE AG_PRIVILEGI_SMISTAMENTO
(
  PRIVILEGIO        VARCHAR2(20 BYTE)           NOT NULL,
  TIPO_SMISTAMENTO  VARCHAR2(20 BYTE)           NOT NULL,
  AOO               NUMBER                      DEFAULT 1
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_PRIV_UTENTE_BLACKLIST
(
  UTENTE  VARCHAR2(8 BYTE)                      NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_PRIV_UTENTE_TMP
(
  UTENTE            VARCHAR2(8 BYTE),
  UNITA             VARCHAR2(50 BYTE)           NOT NULL,
  RUOLO             VARCHAR2(8 BYTE),
  PRIVILEGIO        VARCHAR2(20 BYTE),
  APPARTENENZA      VARCHAR2(1 BYTE)            DEFAULT 'E'                   NOT NULL,
  DAL               DATE                        NOT NULL,
  AL                DATE,
  PROGR_UNITA       NUMBER(8),
  IS_ULTIMA_CHIUSA  NUMBER(1)                   DEFAULT 0
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_PRIV_UTENTE_TMP IS 'Per ogni utente registra le unita per le quali l''utente ha un ruolo, il ruooi e i relativi privilegi. Un utente ha ruolo per un''unita se vi appartiene (APPARTENZA D) o se ha un ruolo che estende i suoi diritti su altre unita (APPARTENZA E)'
/

COMMENT ON COLUMN AG_PRIV_UTENTE_TMP.APPARTENENZA IS 'Appartenenza diretta (D) o da privilegio di estensione (E)'
/


CREATE TABLE AG_PROTO_KEY
(
  ANNO           NUMBER,
  TIPO_REGISTRO  VARCHAR2(8 BYTE),
  NUMERO         NUMBER
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_PROTO_MEMO_KEY
(
  ID_PROTOCOLLO  NUMBER,
  ID_MEMO        NUMBER
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE GLOBAL TEMPORARY TABLE AG_PRUT_TEMP
(
  UTENTE        VARCHAR2(8 BYTE),
  UNITA         VARCHAR2(50 BYTE),
  RUOLO         VARCHAR2(8 BYTE),
  PRIVILEGIO    VARCHAR2(20 BYTE),
  APPARTENENZA  VARCHAR2(1 BYTE)                DEFAULT 'E'                   NOT NULL,
  DAL           DATE                            NOT NULL,
  AL            DATE,
  PROGR_UNITA   NUMBER(8)
)
ON COMMIT DELETE ROWS
/


CREATE TABLE AG_RADICI_AREA_UTENTE_TMP
(
  UTENTE             VARCHAR2(8 BYTE)           NOT NULL,
  UNITA_RADICE_AREA  VARCHAR2(16 BYTE)          NOT NULL,
  PRIVILEGIO         VARCHAR2(20 BYTE)          NOT NULL,
  PROGR_UNITA        NUMBER(8)
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_RADICI_AREA_UTENTE_TMP IS 'Per ogni utente che ha un certo privilegio per l''unita x,  si registra qui l''unita radice dell''area di x. Se l''utente ha privilegio SMISTAAREA per pie unita, le cui radici fanno parte dello stesso ramo, si registra solo l''unita radice superiore nel ramo.'
/

COMMENT ON COLUMN AG_RADICI_AREA_UTENTE_TMP.UTENTE IS 'Codice utente che ha prvilegio SMISTAAREA'
/

COMMENT ON COLUMN AG_RADICI_AREA_UTENTE_TMP.UNITA_RADICE_AREA IS 'Codice unita radice di area'
/

COMMENT ON COLUMN AG_RADICI_AREA_UTENTE_TMP.PRIVILEGIO IS 'Privilegio dell''utente'
/


CREATE TABLE AG_RIFE_MAIL_KEY
(
  ID_MEMO         NUMBER                        NOT NULL,
  ID_PROTOCOLLO   NUMBER,
  TIPO_RELAZIONE  VARCHAR2(10 BYTE)             DEFAULT 'MAIL',
  AREA            VARCHAR2(200 BYTE)            DEFAULT 'SEGRETERIA.PROTOCOLLO'
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_SMISTAMENTI_SCADUTI
(
  ID_ITER             NUMBER                    NOT NULL,
  ID_SMISTAMENTO      NUMBER                    NOT NULL,
  ID_PROTOCOLLO       NUMBER                    NOT NULL,
  STATO_NOTIFICA      VARCHAR2(1 BYTE)          DEFAULT 'N'                   NOT NULL,
  DATA_NOTIFICA       DATE,
  INDICE_AOO          NUMBER                    NOT NULL,
  DATA_AGGIORNAMENTO  DATE                      DEFAULT SYSDATE               NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_SMISTAMENTI_SCADUTI IS 'Tabella per registrare gli  smistamenti scaduti.'
/

COMMENT ON COLUMN AG_SMISTAMENTI_SCADUTI.ID_ITER IS 'Key iter scaduto'
/

COMMENT ON COLUMN AG_SMISTAMENTI_SCADUTI.ID_SMISTAMENTO IS 'Id_Documento dello smistamento scaduto'
/

COMMENT ON COLUMN AG_SMISTAMENTI_SCADUTI.ID_PROTOCOLLO IS 'Id_Documento del protocollo'
/

COMMENT ON COLUMN AG_SMISTAMENTI_SCADUTI.STATO_NOTIFICA IS 'Indica se la scadenza è stata notificata Y/N'
/

COMMENT ON COLUMN AG_SMISTAMENTI_SCADUTI.DATA_NOTIFICA IS 'Data in cui viene notificata la scadenza'
/

COMMENT ON COLUMN AG_SMISTAMENTI_SCADUTI.INDICE_AOO IS 'Indice che identifica l''Aoo nella tabella PARAMETRI'
/


CREATE TABLE AG_STATI_MEMO
(
  STATO_MEMO   VARCHAR2(5 BYTE)                 NOT NULL,
  DESCRIZIONE  VARCHAR2(1000 BYTE)              NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_STATI_OPERAZIONE
(
  AZIONE            VARCHAR2(20 BYTE)           NOT NULL,
  TIPO_SMISTAMENTO  VARCHAR2(20 BYTE)           NOT NULL,
  STATO             VARCHAR2(1 BYTE)            NOT NULL,
  AOO               NUMBER                      NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_STATI_OPERAZIONE IS 'Tabella per indicare che tipo di smistamento è possibile creare, considerando lo smistamento precedente'
/


CREATE TABLE AG_STATI_SCARTO
(
  STATO        VARCHAR2(2 BYTE)                 NOT NULL,
  DESCRIZIONE  VARCHAR2(2000 BYTE)              NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_STORICO_FASC_DOCUMENTO
(
  ID_DOCUMENTO          NUMBER                  NOT NULL,
  ID_CARTELLA           NUMBER                  NOT NULL,
  DATA_AGGIORNAMENTO    DATE                    DEFAULT SYSDATE,
  UTENTE_AGGIORNAMENTO  VARCHAR2(8 BYTE)        DEFAULT 'GDM',
  DAL                   DATE                    NOT NULL,
  AL                    DATE
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_SUDDIVISIONI
(
  ID_SUDDIVISIONE  NUMBER                       NOT NULL,
  INDICE_AOO       NUMBER                       NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_TEMP_IPA
(
  ID_ITER  NUMBER,
  COD_AMM  VARCHAR2(20 BYTE),
  TODO     NUMBER,
  DATA     DATE
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE TABLE AG_TIPI_SMISTAMENTO
(
  TIPO_SMISTAMENTO  VARCHAR2(20 BYTE)           DEFAULT NULL                  NOT NULL,
  AOO               NUMBER                      DEFAULT 1                     NOT NULL,
  IMPORTANZA        NUMBER                      NOT NULL,
  DESCRIZIONE       VARCHAR2(100 BYTE)
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_TIPI_SMISTAMENTO IS 'Tabella per definire i tipi di smistamento utilizzati dall''Aoo e per dare loro una gerarchia.'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO.TIPO_SMISTAMENTO IS 'Tipo di smistamento, il valore sara'' visibile nelle maschere relative agli smistamenti'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO.AOO IS 'Indice che identifica l''Aoo nella tabella PARAMETRI'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO.IMPORTANZA IS 'Valore numerico che indica l''importanza, piu'' è piccolo piu'' il tipo di smistamento è importante'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO.DESCRIZIONE IS 'Descrizione da mostrare nei modelli di smistamento'
/


CREATE TABLE AG_TIPI_SMISTAMENTO_MODELLO
(
  AREA              VARCHAR2(200 BYTE)          NOT NULL,
  CODICE_MODELLO    VARCHAR2(100 BYTE)          NOT NULL,
  TIPO_SMISTAMENTO  VARCHAR2(20 BYTE)           NOT NULL,
  AOO               NUMBER                      NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_TIPI_SMISTAMENTO_MODELLO IS 'Tabelle per definire quali tipi di smistamento sono possibili per ogni modello'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO_MODELLO.AREA IS 'Area del modello'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO_MODELLO.CODICE_MODELLO IS 'Nome del modello'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO_MODELLO.TIPO_SMISTAMENTO IS 'Tipo di smistamento possibile'
/

COMMENT ON COLUMN AG_TIPI_SMISTAMENTO_MODELLO.AOO IS 'Indice che identifica l''aoo'
/


CREATE TABLE AG_TIPI_SOGGETTO
(
  TIPO_SOGGETTO  NUMBER                         NOT NULL,
  DESCRIZIONE    VARCHAR2(1000 BYTE)            NOT NULL,
  SEQUENZA       NUMBER                         NOT NULL
)
TABLESPACE ${global.db.gdm.tablespace.name}
/

COMMENT ON TABLE AG_TIPI_SOGGETTO IS 'Tabella dei possibili tipi di soggetto, serve per consentire di personalizzare la descrizione e l''ordine in cui far vedere i tipi di soggetto'
/

COMMENT ON COLUMN AG_TIPI_SOGGETTO.TIPO_SOGGETTO IS 'Codice tipo soggetto, stabilito in installazione e non modificabile dagli enti. I codici 3, 4 e 5 sono utilizzati per la Provincia di Modena'
/

COMMENT ON COLUMN AG_TIPI_SOGGETTO.DESCRIZIONE IS 'Descrizione del tipo di soggetto'
/

COMMENT ON COLUMN AG_TIPI_SOGGETTO.SEQUENZA IS 'Ordine in cui far vedere il tipo di soggetto negli elenchi'
/


CREATE TABLE AG_ULTIMI_BC
(
  TIPO_MODALITA_RICEVIMENTO  VARCHAR2(4 BYTE),
  ULTIMO_BC                  VARCHAR2(20 BYTE),
  UTENTE                     VARCHAR2(8 BYTE)
)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_ABIL_SMISTAMENTO_PK ON AG_ABILITAZIONI_SMISTAMENTO
(TIPO_SMISTAMENTO, STATO_SMISTAMENTO, AZIONE, AOO, TIPO_SMISTAMENTO_GENERABILE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_AQPR_IK1 ON AG_ACQUISIZIONE_PROTOCOLLI
(STATO_ACQUISIZIONE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_AQRA_IDX ON AG_ACQUISIZIONE_RAPPORTI
(ID_DOC_ESTERNO, APPLICATIVO_ESTERNO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_CS_MESSAGGI_IK ON AG_CS_MESSAGGI
(ID_CS_MESSAGGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_CS_MESSAGGI_PK ON AG_CS_MESSAGGI
(ID_DOCUMENTO_MEMO, ID_CS_MESSAGGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_DOCU_CSME_2_FK ON AG_CS_MESSAGGI
(ID_DOCUMENTO_PROTOCOLLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_LOG_PK ON AG_LOG
(LOG_ID)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_PATCH_PK ON AG_PATCH
(CODICE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PDUT_PRIVILEGIO_IK ON AG_PRIV_D_UTENTE_TMP
(UTENTE, PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PDUT_PROGR_RUOLO_IK ON AG_PRIV_D_UTENTE_TMP
(UTENTE, PROGR_UNITA, RUOLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PDUT_PRPUUT_IK ON AG_PRIV_D_UTENTE_TMP
(PRIVILEGIO, PROGR_UNITA, UTENTE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PDUT_PRUNUT_IK ON AG_PRIV_D_UTENTE_TMP
(PRIVILEGIO, UNITA, UTENTE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PDUT_UNITA_RUOLO_IK ON AG_PRIV_D_UTENTE_TMP
(UTENTE, UNITA, RUOLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_PRIV_UTENTE_BLACKLIST_PK ON AG_PRIV_UTENTE_BLACKLIST
(UTENTE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PRIV_UTENTE_D_TMP_IK ON AG_PRIV_D_UTENTE_TMP
(UTENTE, PROGR_UNITA, RUOLO, PRIVILEGIO, DAL)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PRIV_UTENTE_TMP_IK ON AG_PRIV_UTENTE_TMP
(UTENTE, PROGR_UNITA, RUOLO, PRIVILEGIO, DAL)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_PRIV_UTENTE_TMP_PK ON AG_PRIV_UTENTE_TMP
(UTENTE, UNITA, RUOLO, PRIVILEGIO, DAL)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_PROTO_KEY_PK ON AG_PROTO_KEY
(ANNO, TIPO_REGISTRO, NUMERO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_PROTO_MEMO_KEY_PK ON AG_PROTO_MEMO_KEY
(ID_MEMO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AGPR_PK ON AG_PRIVILEGI
(PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PRUT_PRIVILEGIO_IK ON AG_PRIV_UTENTE_TMP
(UTENTE, PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PRUT_PROGR_RUOLO_IK ON AG_PRIV_UTENTE_TMP
(UTENTE, PROGR_UNITA, RUOLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PRUT_PRPUUT_IK ON AG_PRIV_UTENTE_TMP
(PRIVILEGIO, PROGR_UNITA, UTENTE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PRUT_PRUNUT_IK ON AG_PRIV_UTENTE_TMP
(PRIVILEGIO, UNITA, UTENTE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_PRUT_TEMP_IK ON AG_PRUT_TEMP
(UTENTE, PROGR_UNITA, RUOLO, PRIVILEGIO, DAL)
/


CREATE INDEX AG_PRUT_TEMP_PK ON AG_PRUT_TEMP
(UTENTE, UNITA, RUOLO, PRIVILEGIO, DAL)
/


CREATE INDEX AG_PRUT_TEMP_PRIVILEGIO_IK ON AG_PRUT_TEMP
(UTENTE, PRIVILEGIO)
/


CREATE INDEX AG_PRUT_TEMP_PROGR_RUOLO_IK ON AG_PRUT_TEMP
(UTENTE, PROGR_UNITA, RUOLO)
/


CREATE INDEX AG_PRUT_TEMP_PRUNUT_IK ON AG_PRUT_TEMP
(PRIVILEGIO, UNITA, UTENTE)
/


CREATE INDEX AG_PRUT_TEMP_UNITA_RUOLO_IK ON AG_PRUT_TEMP
(UTENTE, UNITA, RUOLO)
/


CREATE INDEX AG_PRUT_UNITA_RUOLO_IK ON AG_PRIV_UTENTE_TMP
(UTENTE, UNITA, RUOLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_RAUT_IK ON AG_RADICI_AREA_UTENTE_TMP
(UTENTE, PROGR_UNITA, PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_RAUT_PK ON AG_RADICI_AREA_UTENTE_TMP
(UTENTE, UNITA_RADICE_AREA, PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_RAUT_PRIV_FK ON AG_RADICI_AREA_UTENTE_TMP
(PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_RIFE_MAIL_KEY_PK ON AG_RIFE_MAIL_KEY
(ID_MEMO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_SFDO_CART_FK ON AG_STORICO_FASC_DOCUMENTO
(ID_CARTELLA)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_SFDO_PK ON AG_STORICO_FASC_DOCUMENTO
(ID_DOCUMENTO, ID_CARTELLA, DAL)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_SFDO_UTEN_FK ON AG_STORICO_FASC_DOCUMENTO
(UTENTE_AGGIORNAMENTO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_SMSC_ITER_IK ON AG_SMISTAMENTI_SCADUTI
(ID_ITER)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_SMSC_PROT_IK ON AG_SMISTAMENTI_SCADUTI
(ID_PROTOCOLLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_SMSC_SMIS_IK ON AG_SMISTAMENTI_SCADUTI
(ID_SMISTAMENTO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX AG_SMSC_STATO_IK ON AG_SMISTAMENTI_SCADUTI
(STATO_NOTIFICA, DATA_NOTIFICA)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_STATI_MEMO_PK ON AG_STATI_MEMO
(STATO_MEMO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_STOP_PK ON AG_STATI_OPERAZIONE
(AOO, AZIONE, TIPO_SMISTAMENTO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_STSC_PK ON AG_STATI_SCARTO
(STATO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_TIPI_SMISTAMENTO_MODELLO_PK ON AG_TIPI_SMISTAMENTO_MODELLO
(AREA, CODICE_MODELLO, TIPO_SMISTAMENTO, AOO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_TIPI_SMISTAMENTO_PK ON AG_TIPI_SMISTAMENTO
(AOO, TIPO_SMISTAMENTO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_TIPI_SMISTAMENTO_UK ON AG_TIPI_SMISTAMENTO
(AOO, TIPO_SMISTAMENTO, IMPORTANZA)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX AG_TIPI_SOGGETTO_PK ON AG_TIPI_SOGGETTO
(TIPO_SOGGETTO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX ATSM_ATSMI_FK ON AG_TIPI_SMISTAMENTO_MODELLO
(AOO, TIPO_SMISTAMENTO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX DOC_DST_FK ON AG_DOCUMENT_TOPRO
(DST_NUMBER)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX NUMERAZIONI_ESTERNE_PK ON AG_NUMERAZIONI_ESTERNE
(APPLICATIVO_ESTERNO, ID_DOCUMENTO_ESTERNO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX PK_DOCUMENT_TOPRO ON AG_DOCUMENT_TOPRO
(IDDOCUMENTO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX PK_DST ON AG_DST
(DST_NUMBER)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX PK_ERR_TABLE ON AG_ERR_TABLE
(ERR_CODE)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX PK_MESSAGE_ID ON AG_MEMO_KEY
(MESSAGE_ID)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX PRRU_AGPR_FK ON AG_PRIVILEGI_RUOLO
(PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX PRRU_PK ON AG_PRIVILEGI_RUOLO
(AOO, PRIVILEGIO, RUOLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX PRRU_RUOL_FK ON AG_PRIVILEGI_RUOLO
(RUOLO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE INDEX PRSM_AGPR_FK ON AG_PRIVILEGI_SMISTAMENTO
(PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX PRSM_PK ON AG_PRIVILEGI_SMISTAMENTO
(TIPO_SMISTAMENTO, PRIVILEGIO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE UNIQUE INDEX SUDD_PK ON AG_SUDDIVISIONI
(ID_SUDDIVISIONE, INDICE_AOO)
TABLESPACE ${global.db.gdm.tablespace.name}
/


CREATE OR REPLACE TRIGGER ag_smsc_tiu
   BEFORE INSERT OR UPDATE
   ON ag_smistamenti_scaduti
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
/******************************************************************************
   NAME:       AG_SMSC_TIU
   PURPOSE:
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        128/01/2010  SC           1. Created this trigger. A35655.3.0.
   NOTES:
   Automatically available Auto Replace Keywords:
      Object Name:     AG_CLAS_TIU
      Sysdate:         17/02/2009
      Date and Time:   17/02/2009, 16.23.00, and 17/02/2009 16.23.00
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      SEG_CLASSIFICAZIONI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF :NEW.data_aggiornamento IS NULL
   THEN
      :NEW.data_aggiornamento := SYSDATE;
   END IF;
END ag_smsc_tiu;
/


CREATE OR REPLACE TRIGGER AG_LOG_TIU
   BEFORE INSERT OR UPDATE
   ON AG_LOG
   FOR EACH ROW
DECLARE
   integrity_error   EXCEPTION;
   errno             INTEGER;
   errmsg            CHAR (200);
   FOUND             BOOLEAN;
   inizio            date;
BEGIN
   BEGIN                                                 -- Set DATA Integrity
      /* NONE */
      NULL;
   END;

   BEGIN                                           -- Set FUNCTIONAL Integrity
      IF IntegrityPackage.GetNestLevel = 0
      THEN
         IntegrityPackage.NextNestLevel;

         BEGIN                       -- Global FUNCTIONAL Integrity at Level 0
            /* NONE */
            NULL;
         END;

         IntegrityPackage.PreviousNestLevel;
      END IF;

      IntegrityPackage.NextNestLevel;

      BEGIN                          -- Full FUNCTIONAL Integrity at Any Level
         IF :NEW.LOG_ID IS NULL
         THEN
            SELECT AG_LOG_SQ.NEXTVAL INTO :NEW.LOG_ID FROM DUAL;
         END IF;
      END;

      IntegrityPackage.PreviousNestLevel;

      IF     :new.LOG_ELAPSED_TIME IS NULL
         AND :new.LOG_TITLE = 'Protocolla (flex) fine'
      THEN
         SELECT LOG_DATE
           INTO inizio
           FROM ag_log
          WHERE log_id =
                   (SELECT MAX (log_id)
                      FROM ag_log
                     WHERE     LOG_USER = :new.log_user
                           AND log_title = 'Protocolla (flex)');
         -- IN MILLISECONDI
         :new.LOG_ELAPSED_TIME := (:new.LOG_DATE - inizio)  * 24 * 60 * 60 * 1000;
      END IF;
   END;
EXCEPTION
   WHEN integrity_error
   THEN
      IntegrityPackage.InitNestLevel;
      raise_application_error (errno, errmsg);
   WHEN OTHERS
   THEN
      IntegrityPackage.InitNestLevel;
      RAISE;
END;
/


CREATE OR REPLACE TRIGGER ag_cs_messaggi_tu
   BEFORE UPDATE
   ON ag_cs_messaggi
   FOR EACH ROW
BEGIN
   if  NVL (:OLD.stato_spedizione, 'READYTOSEND') in ('SENTOK', 'SENTFAILED') and  NVL (:new.stato_spedizione, 'READYTOSEND') in ('READYTOSEND', 'SENDING') then
      :new.stato_spedizione :=  NVL(:OLD.stato_spedizione, 'READYTOSEND');
   end if;

   IF (    NVL (:NEW.stato_spedizione, 'READYTOSEND') != 'READYTOSEND'
       AND NVL (:NEW.stato_spedizione, 'READYTOSEND') !=
                                    NVL (:OLD.stato_spedizione, 'READYTOSEND')
      )
   THEN
      IF :NEW.data_modifica IS NULL
      THEN
         :NEW.data_modifica := SYSDATE;
      END IF;
   END IF;
END;
/


CREATE OR REPLACE TRIGGER ag_acra_tiu
   BEFORE INSERT OR UPDATE
   ON ag_acquisizione_rapporti
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   tmpvar   NUMBER;
/******************************************************************************
   NAME:
   PURPOSE:
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/11/2007             1. Created this trigger.
   NOTES:
   Automatically available Auto Replace Keywords:
      Object Name:
      Sysdate:         22/11/2007
      Date and Time:   22/11/2007, 15.16.24, and 22/11/2007 15.16.24
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      AG_ACQUISIZIONE_RAPPORTI (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   IF INSERTING
   THEN
      tmpvar := 0;
      SELECT ag_acra_sq.NEXTVAL
        INTO tmpvar
        FROM DUAL;
      :NEW.progressivo := tmpvar;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/


ALTER TABLE AG_ABILITAZIONI_SMISTAMENTO ADD (
  CONSTRAINT AG_ABIL_SMISTAMENTO_PK
  PRIMARY KEY
  (TIPO_SMISTAMENTO, STATO_SMISTAMENTO, AZIONE, AOO, TIPO_SMISTAMENTO_GENERABILE)
  USING INDEX AG_ABIL_SMISTAMENTO_PK)
/

ALTER TABLE AG_ACQUISIZIONE_PROTOCOLLI ADD (
  PRIMARY KEY
  (APPLICATIVO_ESTERNO, ID_DOC_ESTERNO)
  USING INDEX
    TABLESPACE ${global.db.gdm.tablespace.name})
/

ALTER TABLE AG_CS_MESSAGGI ADD (
  CONSTRAINT AG_CS_MESSAGGI_PK
  PRIMARY KEY
  (ID_DOCUMENTO_MEMO, ID_CS_MESSAGGIO)
  USING INDEX AG_CS_MESSAGGI_PK)
/

ALTER TABLE AG_DOCUMENT_TOPRO ADD (
  CONSTRAINT PK_DOCUMENT_TOPRO
  PRIMARY KEY
  (IDDOCUMENTO)
  USING INDEX PK_DOCUMENT_TOPRO)
/

ALTER TABLE AG_DST ADD (
  CONSTRAINT PK_DST
  PRIMARY KEY
  (DST_NUMBER)
  USING INDEX PK_DST)
/

ALTER TABLE AG_ERR_TABLE ADD (
  CONSTRAINT PK_ERR_TABLE
  PRIMARY KEY
  (ERR_CODE)
  USING INDEX PK_ERR_TABLE)
/

ALTER TABLE AG_LOG ADD (
  CONSTRAINT AG_LOG_PK
  PRIMARY KEY
  (LOG_ID)
  USING INDEX AG_LOG_PK)
/

ALTER TABLE AG_MEMO_KEY ADD (
  CONSTRAINT PK_MESSAGE_ID
  PRIMARY KEY
  (MESSAGE_ID)
  USING INDEX PK_MESSAGE_ID)
/

ALTER TABLE AG_NUMERAZIONI_ESTERNE ADD (
  CONSTRAINT NUMERAZIONI_ESTERNE_PK
  PRIMARY KEY
  (APPLICATIVO_ESTERNO, ID_DOCUMENTO_ESTERNO)
  USING INDEX NUMERAZIONI_ESTERNE_PK)
/

ALTER TABLE AG_PATCH ADD (
  CONSTRAINT AG_PATCH_PK
  PRIMARY KEY
  (CODICE)
  USING INDEX AG_PATCH_PK)
/

ALTER TABLE AG_PRIVILEGI ADD (
  CONSTRAINT AGPR_PK
  PRIMARY KEY
  (PRIVILEGIO)
  USING INDEX AGPR_PK)
/

ALTER TABLE AG_PRIVILEGI_RUOLO ADD (
  CONSTRAINT PRRU_PK
  PRIMARY KEY
  (AOO, PRIVILEGIO, RUOLO)
  USING INDEX PRRU_PK,
  CONSTRAINT PRRU_UK
  UNIQUE (AOO, RUOLO, PRIVILEGIO)
  USING INDEX PRRU_PK)
/

ALTER TABLE AG_PRIVILEGI_SMISTAMENTO ADD (
  CONSTRAINT PRSM_PK
  PRIMARY KEY
  (TIPO_SMISTAMENTO, PRIVILEGIO)
  USING INDEX PRSM_PK)
/

ALTER TABLE AG_PRIV_UTENTE_BLACKLIST ADD (
  CONSTRAINT AG_PRIV_UTENTE_BLACKLIST_PK
  PRIMARY KEY
  (UTENTE)
  USING INDEX AG_PRIV_UTENTE_BLACKLIST_PK)
/

ALTER TABLE AG_PRIV_UTENTE_TMP ADD (
  CONSTRAINT AG_PRIV_UTENTE_TMP_PK
  PRIMARY KEY
  (UTENTE, UNITA, RUOLO, PRIVILEGIO, DAL)
  USING INDEX AG_PRIV_UTENTE_TMP_PK)
/

ALTER TABLE AG_PROTO_KEY ADD (
  CONSTRAINT AG_PROTO_KEY_PK
  PRIMARY KEY
  (ANNO, TIPO_REGISTRO, NUMERO)
  USING INDEX AG_PROTO_KEY_PK)
/

ALTER TABLE AG_PROTO_MEMO_KEY ADD (
  CONSTRAINT AG_PROTO_MEMO_KEY_PK
  PRIMARY KEY
  (ID_MEMO)
  USING INDEX AG_PROTO_MEMO_KEY_PK)
/

ALTER TABLE AG_RADICI_AREA_UTENTE_TMP ADD (
  CONSTRAINT AG_RAUT_PK
  PRIMARY KEY
  (UTENTE, UNITA_RADICE_AREA, PRIVILEGIO)
  USING INDEX AG_RAUT_PK)
/

ALTER TABLE AG_RIFE_MAIL_KEY ADD (
  CONSTRAINT AG_RIFE_MAIL_KEY_PK
  PRIMARY KEY
  (ID_MEMO)
  USING INDEX AG_RIFE_MAIL_KEY_PK)
/

ALTER TABLE AG_STATI_MEMO ADD (
  CONSTRAINT AG_STATI_MEMO_PK
  PRIMARY KEY
  (STATO_MEMO)
  USING INDEX AG_STATI_MEMO_PK)
/

ALTER TABLE AG_STATI_OPERAZIONE ADD (
  CONSTRAINT AG_STOP_PK
  PRIMARY KEY
  (AOO, AZIONE, TIPO_SMISTAMENTO)
  USING INDEX AG_STOP_PK)
/

ALTER TABLE AG_STATI_SCARTO ADD (
  CONSTRAINT AG_STSC_PK
  PRIMARY KEY
  (STATO)
  USING INDEX AG_STSC_PK)
/

ALTER TABLE AG_STORICO_FASC_DOCUMENTO ADD (
  CONSTRAINT AG_SFDO_PK
  PRIMARY KEY
  (ID_DOCUMENTO, ID_CARTELLA, DAL)
  USING INDEX AG_SFDO_PK)
/

ALTER TABLE AG_SUDDIVISIONI ADD (
  CONSTRAINT SUDD_PK
  PRIMARY KEY
  (ID_SUDDIVISIONE, INDICE_AOO)
  USING INDEX SUDD_PK)
/

ALTER TABLE AG_TIPI_SMISTAMENTO ADD (
  CONSTRAINT AG_TIPI_SMISTAMENTO_PK
  PRIMARY KEY
  (AOO, TIPO_SMISTAMENTO)
  USING INDEX AG_TIPI_SMISTAMENTO_PK,
  CONSTRAINT AG_TIPI_SMISTAMENTO_UK
  UNIQUE (AOO, TIPO_SMISTAMENTO, IMPORTANZA)
  USING INDEX AG_TIPI_SMISTAMENTO_UK)
/

ALTER TABLE AG_TIPI_SMISTAMENTO_MODELLO ADD (
  CONSTRAINT AG_TIPI_SMISTAMENTO_MODELLO_PK
  PRIMARY KEY
  (AREA, CODICE_MODELLO, TIPO_SMISTAMENTO, AOO)
  USING INDEX AG_TIPI_SMISTAMENTO_MODELLO_PK)
/

ALTER TABLE AG_TIPI_SOGGETTO ADD (
  CONSTRAINT AG_TIPI_SOGGETTO_PK
  PRIMARY KEY
  (TIPO_SOGGETTO)
  USING INDEX AG_TIPI_SOGGETTO_PK)
/

ALTER TABLE AG_CS_MESSAGGI ADD (
  CONSTRAINT AG_DOCU_CSME_FK
  FOREIGN KEY (ID_DOCUMENTO_MEMO)
  REFERENCES DOCUMENTI (ID_DOCUMENTO)
  ON DELETE CASCADE,
  CONSTRAINT AG_DOCU_CSME_2_FK
  FOREIGN KEY (ID_DOCUMENTO_PROTOCOLLO)
  REFERENCES DOCUMENTI (ID_DOCUMENTO))
/

ALTER TABLE AG_DOCUMENT_TOPRO ADD (
  CONSTRAINT DOC_DST_FK
  FOREIGN KEY (DST_NUMBER)
  REFERENCES AG_DST (DST_NUMBER)
  ON DELETE CASCADE)
/

ALTER TABLE AG_PRIVILEGI_RUOLO ADD (
  CONSTRAINT PRRU_AGPR_FK
  FOREIGN KEY (PRIVILEGIO)
  REFERENCES AG_PRIVILEGI (PRIVILEGIO),
  CONSTRAINT PRRU_RUOL_FK
  FOREIGN KEY (RUOLO)
  REFERENCES ${global.db.ad4.username}.RUOLI (RUOLO))
/

ALTER TABLE AG_PRIVILEGI_SMISTAMENTO ADD (
  CONSTRAINT PRSM_AGPR_FK
  FOREIGN KEY (PRIVILEGIO)
  REFERENCES AG_PRIVILEGI (PRIVILEGIO))
/

ALTER TABLE AG_RADICI_AREA_UTENTE_TMP ADD (
  CONSTRAINT AG_RAUT_PRIV_FK
  FOREIGN KEY (PRIVILEGIO)
  REFERENCES AG_PRIVILEGI (PRIVILEGIO))
/

ALTER TABLE AG_STORICO_FASC_DOCUMENTO ADD (
  CONSTRAINT AG_SFDO_CART_FK
  FOREIGN KEY (ID_CARTELLA)
  REFERENCES CARTELLE (ID_CARTELLA),
  CONSTRAINT AG_SFDO_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES DOCUMENTI (ID_DOCUMENTO)
  ON DELETE CASCADE,
  CONSTRAINT AG_SFDO_UTEN_FK
  FOREIGN KEY (UTENTE_AGGIORNAMENTO)
  REFERENCES ${global.db.ad4.username}.UTENTI (UTENTE))
/

ALTER TABLE AG_TIPI_SMISTAMENTO_MODELLO ADD (
  CONSTRAINT ATSM_ATSMI_FK
  FOREIGN KEY (AOO, TIPO_SMISTAMENTO)
  REFERENCES AG_TIPI_SMISTAMENTO (AOO,TIPO_SMISTAMENTO))
/
