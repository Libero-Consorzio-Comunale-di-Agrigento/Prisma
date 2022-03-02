--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20201013_4.seg_tipi_documento_alter failOnError:false

UPDATE SEG_TIPI_DOCUMENTO
   SET DA_FASCICOLARE = 'N'
 WHERE DA_FASCICOLARE IS NULL
/

UPDATE SEG_TIPI_DOCUMENTO
   SET CONSERVAZIONE_ILLIMITATA = 'N'
 WHERE CONSERVAZIONE_ILLIMITATA IS NULL
/

UPDATE SEG_TIPI_DOCUMENTO
   SET DOMANDA_ACCESSO = 'N'
 WHERE DOMANDA_ACCESSO IS NULL
/

UPDATE SEG_TIPI_DOCUMENTO
   SET SEGNATURA_COMPLETA = 'Y'
 WHERE SEGNATURA_COMPLETA IS NULL
/

UPDATE SEG_TIPI_DOCUMENTO
   SET SEGNATURA = 'Y'
 WHERE SEGNATURA IS NULL
/

UPDATE SEG_TIPI_DOCUMENTO
   SET RISPOSTA = 'N'
 WHERE RISPOSTA IS NULL
/

COMMIT
/

ALTER TABLE SEG_TIPI_DOCUMENTO
   MODIFY (CONSERVAZIONE_ILLIMITATA VARCHAR2 (1) DEFAULT 'N',
           DA_FASCICOLARE VARCHAR2 (1) DEFAULT 'N',
           SEGNATURA_COMPLETA VARCHAR2 (1) DEFAULT 'Y',
           SEGNATURA VARCHAR2 (1) DEFAULT 'Y',
           DOMANDA_ACCESSO VARCHAR2 (1) DEFAULT 'N',
           RISPOSTA VARCHAR2 (1) DEFAULT 'N',
           RISERVATO VARCHAR2 (1) DEFAULT 'N')
/