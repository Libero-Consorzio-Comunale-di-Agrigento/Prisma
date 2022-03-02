--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_022.agp_abilitazioni_smistamento
CREATE TABLE AGP_ABILITAZIONI_SMISTAMENTO
(
   ID_ABILITAZIONI_SMISTAMENTO   NUMBER NOT NULL,
   TIPO_SMISTAMENTO              VARCHAR2 (255) NOT NULL,
   STATO_SMISTAMENTO             VARCHAR2 (255) NOT NULL,
   AZIONE                        VARCHAR2 (255) NOT NULL,
   TIPO_SMISTAMENTO_GENERABILE   VARCHAR2 (255) NOT NULL,
   ID_ENTE                       NUMBER NOT NULL,
   VALIDO                        CHAR (1) DEFAULT 'Y',
   UTENTE_INS                    VARCHAR2 (8),
   DATA_INS                      DATE,
   UTENTE_UPD                    VARCHAR2 (8),
   DATA_UPD                      DATE,
   VERSION                       NUMBER (10)
)
/

COMMENT ON TABLE AGP_ABILITAZIONI_SMISTAMENTO IS
   'Possibili azioni e tipi di smistamento generabili da un dato tipo di smistamento e stato.'
/

COMMENT ON COLUMN AGP_ABILITAZIONI_SMISTAMENTO.TIPO_SMISTAMENTO IS
   'Tipo dello smistamento esistente'
/

COMMENT ON COLUMN AGP_ABILITAZIONI_SMISTAMENTO.STATO_SMISTAMENTO IS
   'Stato dello smistamento esistente'
/

COMMENT ON COLUMN AGP_ABILITAZIONI_SMISTAMENTO.AZIONE IS
   'Azione che si puo'' compiere sullo smistamento esistente (smistare, inoltrare, assegnare)'
/

COMMENT ON COLUMN AGP_ABILITAZIONI_SMISTAMENTO.TIPO_SMISTAMENTO_GENERABILE IS
   'Tipo smistamento attribuibile al nuovo smistamento'
/

COMMENT ON COLUMN AGP_ABILITAZIONI_SMISTAMENTO.ID_ENTE IS
   'Identificativo dell''ente'
/

CREATE UNIQUE INDEX AGP_ABSM_PK
   ON AGP_ABILITAZIONI_SMISTAMENTO (ID_ABILITAZIONI_SMISTAMENTO)
/

ALTER TABLE AGP_ABILITAZIONI_SMISTAMENTO ADD (
  CONSTRAINT AG_ABSM_PK
  PRIMARY KEY
  (ID_ABILITAZIONI_SMISTAMENTO)
  )
/

CREATE UNIQUE INDEX AGP_ABSM_UK
   ON AGP_ABILITAZIONI_SMISTAMENTO (TIPO_SMISTAMENTO,
                                    STATO_SMISTAMENTO,
                                    AZIONE,
                                    ID_ENTE,
                                    TIPO_SMISTAMENTO_GENERABILE)
/

ALTER TABLE AGP_ABILITAZIONI_SMISTAMENTO ADD (
  CONSTRAINT AG_ABSM_UK
  UNIQUE
  (TIPO_SMISTAMENTO, STATO_SMISTAMENTO, AZIONE, ID_ENTE, TIPO_SMISTAMENTO_GENERABILE))
/