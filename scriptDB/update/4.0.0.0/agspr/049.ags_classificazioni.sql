--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_049.ags_classificazioni
CREATE TABLE AGS_CLASSIFICAZIONI_NEW
(
  ID_CLASSIFICAZIONE     NUMBER                 NOT NULL,
  ID_DOCUMENTO_ESTERNO   NUMBER,
  PROGRESSIVO            NUMBER                 NOT NULL,
  PROGRESSIVO_PADRE      NUMBER,
  CLASSIFICAZIONE        VARCHAR2(255),
  CLASSIFICAZIONE_DAL    DATE                   NOT NULL,
  CLASSIFICAZIONE_AL     DATE,
  DESCRIZIONE            VARCHAR2(4000),
  CONTENITORE_DOCUMENTI  CHAR(1)           DEFAULT 'Y'                   NOT NULL,
  DOC_FASCICOLI_SUB      CHAR(1)           DEFAULT 'Y'                   NOT NULL,
  NUM_ILLIMITATA         CHAR(1)           DEFAULT 'N'                   NOT NULL,
  NOTE                   VARCHAR2(4000),
  ID_ENTE                NUMBER                 NOT NULL,
  VALIDO                 CHAR(1)           DEFAULT 'Y'                   NOT NULL,
  UTENTE_INS             VARCHAR2(255)     NOT NULL,
  DATA_INS               DATE                   NOT NULL,
  UTENTE_UPD             VARCHAR2(255)     NOT NULL,
  DATA_UPD               DATE                   NOT NULL,
  VERSION                NUMBER                 NOT NULL
)
/

COMMENT ON COLUMN AGS_CLASSIFICAZIONI_NEW.PROGRESSIVO IS 'Progressivo distinto per ogni classificazione. In caso di revisione questo valore non cambia'
/

COMMENT ON COLUMN AGS_CLASSIFICAZIONI_NEW.PROGRESSIVO_PADRE IS 'Progressivo del documento padre per la classificazione corrente. La struttura ad albero si basa su questo campo'
/

COMMENT ON COLUMN AGS_CLASSIFICAZIONI_NEW.CONTENITORE_DOCUMENTI IS 'Indica se può contenere direttamente dei documenti'
/

COMMENT ON COLUMN AGS_CLASSIFICAZIONI_NEW.DOC_FASCICOLI_SUB IS 'Indica se i fascicoli con sotto-fascicoli possono contenere documenti'
/

COMMENT ON COLUMN AGS_CLASSIFICAZIONI_NEW.NUM_ILLIMITATA IS 'Indica se la numerazione del fascicolo è annuale (N) o se la numerazione continua sempre (Y)'
/


CREATE INDEX AGS_CLA_ENTE_FK ON AGS_CLASSIFICAZIONI_NEW
(ID_ENTE)
/



ALTER TABLE AGS_CLASSIFICAZIONI_NEW ADD (
  CONSTRAINT AGS_CLASSIFICAZIONI_PK
  PRIMARY KEY
  (ID_CLASSIFICAZIONE)
  ENABLE VALIDATE)
/


ALTER TABLE AGS_CLASSIFICAZIONI_NEW ADD (
  CONSTRAINT AGS_CLA_ENTE_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE)
  ENABLE VALIDATE)
/


create table ags_classificazioni_num (id_classificazione_num        number not null
                                    , id_classificazione            number not null
                                    , anno                          number not null
                                    , ultimo_numero_fascicolo       number not null
                                    , id_ente                       number not null
                                    , valido                        char (1) default 'Y' not null
                                    , utente_ins                    varchar2 (255) not null
                                    , data_ins                      date not null
                                    , utente_upd                    varchar2 (255) not null
                                    , data_upd                      date not null
                                    , version                       number not null)
/

create unique index ags_classificazioni_num_uk
   on ags_classificazioni_num (id_classificazione, anno, id_ente)
/

create index ags_clanum_cla_fk
   on ags_classificazioni_num (id_classificazione)
/

create index ags_clanum_enti_fk
   on ags_classificazioni_num (id_ente)
/

create unique index ags_classificazioni_num_pk
   on ags_classificazioni_num (id_classificazione_num)
/

alter table ags_classificazioni_num add (
  constraint ags_classificazioni_num_pk
  primary key
  (id_classificazione_num)
  using index ags_classificazioni_num_pk
  enable validate)
/

alter table ags_classificazioni_num add (
  constraint ags_clanum_cla_fk
  foreign key (id_classificazione)
  references ags_classificazioni_new (id_classificazione)
  enable validate,
  constraint ags_clanum_enti_fk
  foreign key (id_ente)
  references gdo_enti (id_ente)
  enable validate)
/

create table ags_classificazioni_unita (id_classificazione_unita   number not null
                                      , id_classificazione         number not null
                                      , unita_progr                number
                                      , unita_dal                  date
                                      , unita_ottica               varchar2 (255)
                                      , id_ente                    number not null
                                      , valido                     char (1) default 'Y' not null
                                      , utente_ins                 varchar2 (255) not null
                                      , data_ins                   date not null
                                      , utente_upd                 varchar2 (255) not null
                                      , data_upd                   date not null
                                      , version                    number not null)
/

create index ags_clauni_enti_fk
   on ags_classificazioni_unita (id_ente)
/

create index ags_clauni_cla_fk
   on ags_classificazioni_unita (id_classificazione)
/

create unique index ags_classificazioni_unita_pk
   on ags_classificazioni_unita (id_classificazione_unita)
/

alter table ags_classificazioni_unita add (
  constraint ags_classificazioni_unita_pk
  primary key
  (id_classificazione_unita)
  using index ags_classificazioni_unita_pk
  enable validate)
/

alter table ags_classificazioni_unita add (
  constraint ags_clauni_cla_fk
  foreign key (id_classificazione)
  references ags_classificazioni_new (id_classificazione)
  enable validate,
  constraint ags_clauni_enti_fk
  foreign key (id_ente)
  references gdo_enti (id_ente)
  enable validate)
/
