--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_099.trmp_storico_prot
CREATE GLOBAL TEMPORARY TABLE temp_storico_prot
(
   ID                      NUMBER NOT NULL,
   ID_DOCUMENTO            NUMBER NOT NULL,
   IDRIF                   VARCHAR2 (20),
   LOG_ID_DOCUMENTO        NUMBER NOT NULL,
   LOG_DATA                DATE,
   LOG_UTENTE              VARCHAR2 (20),
   ID_VALORE_LOG           NUMBER,
   OGGETTO                 VARCHAR2 (4000),
   MODALITA                VARCHAR2 (4000),
   CLASS_COD               VARCHAR2 (4000),
   FASCICOLO_ANNO          NUMBER,
   FASCICOLO_NUMERO        VARCHAR2 (4000),
   DATA_ARRIVO             DATE,
   DATA_DOCUMENTO          VARCHAR2 (4000),
   NUMERO_DOCUMENTO        VARCHAR2 (4000),
   RISERVATO               VARCHAR2 (4000)
) ON COMMIT DELETE ROWS
/

CREATE GLOBAL TEMPORARY TABLE temp_storico_corr
(
   ID                      NUMBER NOT NULL,
   ID_DOCUMENTO            NUMBER NOT NULL,
   IDRIF                   VARCHAR2 (20),
   LOG_ID_DOCUMENTO        NUMBER NOT NULL,
   LOG_DATA                DATE,
   LOG_UTENTE              VARCHAR2 (20),
   ID_VALORE_LOG           NUMBER,
   DENOMINAZIONE_PER_SEGNATURA                 VARCHAR2 (4000),
   COGNOME_PER_SEGNATURA                VARCHAR2 (4000),
   NOME_PER_SEGNATURA               VARCHAR2 (4000),
   DESCRIZIONE_AMM        VARCHAR2 (4000),
   DESCRIZIONE_AOO          VARCHAR2 (4000),
   CONOSCENZA               VARCHAR2 (4000)
) ON COMMIT DELETE ROWS
/
