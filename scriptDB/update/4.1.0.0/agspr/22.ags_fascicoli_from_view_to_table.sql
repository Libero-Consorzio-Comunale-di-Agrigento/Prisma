--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200828_22.ags_fascicoli_from_view_to_table

rename ags_fascicoli to ags_fascicoli_view
/
CREATE TABLE AGS_FASCICOLI
(
  ID_CLASSIFICAZIONE        NUMBER              NOT NULL,
  ID_DOCUMENTO              NUMBER,
  ANNO                      NUMBER,
  NUMERO                    VARCHAR2(255 BYTE),
  NUMERO_PROSSIMO_ANNO      CHAR(1 BYTE)        DEFAULT 'N'                   NOT NULL,
  OGGETTO                   VARCHAR2(4000 BYTE) NOT NULL,
  RESPONSABILE              VARCHAR2(4000 BYTE),
  RISERVATO                 CHAR(1 BYTE)        DEFAULT 'N'                   NOT NULL,
  DIGITALE                  CHAR(1 BYTE)        DEFAULT 'N'                   NOT NULL,
  ANNO_ARCHIVIAZIONE        VARCHAR2(255 BYTE),
  NOTE                      VARCHAR2(4000 BYTE),
  TOPOGRAFIA                VARCHAR2(4000 BYTE),
  DATA_CREAZIONE            DATE                NOT NULL,
  DATA_APERTURA             DATE,
  DATA_CHIUSURA             DATE,
  ANNO_NUMERO               VARCHAR2(255 BYTE),
  ULTIMO_NUMERO_SUB         NUMBER,
  MOVIMENTO                 VARCHAR2(255 BYTE),
  IDRIF                     VARCHAR2(255 BYTE),
  NUMERO_ORD                VARCHAR2(255 BYTE),
  ID_FASCICOLO_PADRE        NUMBER,
  STATO_FASCICOLO           VARCHAR2(255 BYTE),
  DATA_STATO                DATE,
  NOME                      VARCHAR2(255 BYTE),
  SUB                       NUMBER,
  DATA_ARCHIVIAZIONE        DATE,
  DATA_ULTIMA_OPERAZIONE    DATE,
  ID_DOCUMENTO_DATI_SCARTO  NUMBER,
  DESCRIZIONE_SCARTO        VARCHAR2(1000 BYTE),
  PEZZI_SCARTO              NUMBER(10),
  PESO_SCARTO               NUMBER(10,2),
  UBICAZIONE_SCARTO         VARCHAR2(1000 BYTE),
  OSSERVAZIONI_SCARTO       VARCHAR2(4000 BYTE)
)
/

CREATE UNIQUE INDEX AGS_FASCICOLI_PK ON AGS_FASCICOLI
(ID_DOCUMENTO)
/

ALTER TABLE AGS_FASCICOLI ADD (
  CONSTRAINT AGS_FASCICOLI_PK
  PRIMARY KEY
  (ID_DOCUMENTO)
  USING INDEX AGS_FASCICOLI_PK)
/

ALTER TABLE AGS_FASCICOLI
 ADD CONSTRAINT AGS_FASC_CL_FK
  FOREIGN KEY (ID_CLASSIFICAZIONE)
  REFERENCES AGS_CLASSIFICAZIONI (ID_CLASSIFICAZIONE)
/

CREATE INDEX AGS_FASC_CL_FK ON AGS_FASCICOLI
(ID_CLASSIFICAZIONE)
/

ALTER TABLE AGS_FASCICOLI
 ADD CONSTRAINT AGS_FASC_DS_FK
  FOREIGN KEY (ID_DOCUMENTO_DATI_SCARTO)
  REFERENCES AGP_DOCUMENTI_DATI_SCARTO (ID_DOCUMENTO_DATI_SCARTO)
/

CREATE UNIQUE INDEX AGS_FASC_DS_FK ON AGS_FASCICOLI
(ID_DOCUMENTO_DATI_SCARTO)
/

ALTER TABLE AGS_FASCICOLI
 ADD CONSTRAINT AGS_FASC_FP_FK
  FOREIGN KEY (ID_FASCICOLO_PADRE)
  REFERENCES AGS_FASCICOLI (ID_DOCUMENTO)
/

CREATE INDEX AGS_FASC_FP_FK ON AGS_FASCICOLI
(ID_FASCICOLO_PADRE)
/

CREATE OR REPLACE TRIGGER AGS_FASCICOLI_TAIU
   AFTER INSERT OR UPDATE
   ON "AGS_FASCICOLI"
   FOR EACH ROW
DECLARE
   a_messaggio    VARCHAR2 (4000);
   a_istruzione   VARCHAR2 (32767);
   d_operazione   VARCHAR2 (255);
BEGIN
   IF INSERTING
   THEN
      d_operazione := '''I''';
   ELSIF UPDATING
   THEN
      d_operazione := '''U''';
   END IF;

   a_messaggio := '';

   a_istruzione :=
         'allinea_fascicolo_gdm('
      || d_operazione
      || ', '''
      || NVL (:new.anno, '')
      || ''', '''
      || NVL (:new.anno, '')
      || ''', '''
      || :new.anno_numero
      || ''', '''
      || TO_CHAR (:new.data_apertura, 'dd/mm/yyyy')
      || ''', '''
      || TO_CHAR (:new.data_archiviazione, 'dd/mm/yyyy')
      || ''', '''
      || TO_CHAR (:new.data_chiusura, 'dd/mm/yyyy')
      || ''', '''
      || TO_CHAR (:new.data_creazione, 'dd/mm/yyyy')
      || ''', '''
      || TO_CHAR (:new.data_stato, 'dd/mm/yyyy')
      || ''', '''
      || :new.digitale
      || ''', '
      || :new.id_classificazione
      || ', '
      || :new.id_documento
      || ', '
      || NVL (TO_CHAR (:new.id_fascicolo_padre), 'null')
      || ', '''
      || :new.idrif
      || ''', '''
      || REPLACE (:new.nome, '''', '''''')
      || ''', '''
      || REPLACE (:new.note, '''', '''''')
      || ''', '''
      || :new.numero
      || ''', '''
      || NVL (:new.numero_ord, '')
      || ''', '''
      || :new.numero_prossimo_anno
      || ''', '''
      || REPLACE (:new.oggetto, '''', '''''')
      || ''', '''
      || REPLACE (:new.responsabile, '''', '''''')
      || ''', '''
      || :new.riservato
      || ''', '''
      || :new.stato_fascicolo
      || ''', '
      || :new.sub
      || ', '''
      || REPLACE (:new.topografia, '''', '''''')
      || ''', '
      || NVL (TO_CHAR (:new.ultimo_numero_sub), 'null')
      || ', '
      || NVL (TO_CHAR (:old.id_fascicolo_padre), 'null')
      || ')';

   integritypackage.set_postevent (a_istruzione, a_messaggio);
END;
/

CREATE OR REPLACE TRIGGER ags_fascicoli_TB
   BEFORE INSERT OR UPDATE OR DELETE
   ON "AGS_FASCICOLI"
BEGIN
   /* RESET PostEvent for Custom Functional Check */
   IF IntegrityPackage.GetNestLevel = 0
   THEN
      IntegrityPackage.InitNestLevel;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER ags_fascicoli_TC
   AFTER INSERT OR UPDATE OR DELETE
   ON "AGS_FASCICOLI"
BEGIN
   /* EXEC PostEvent for Custom Functional Check */
   IntegrityPackage.Exec_PostEvent;
END;
/

CREATE TABLE AGS_FASCICOLI_LOG
(
  ANNO                        NUMBER,
  ANNO_MOD                    NUMBER(1)         DEFAULT 0                     NOT NULL,
  ANNO_ARCHIVIAZIONE          VARCHAR2(255 BYTE),
  ANNO_ARCHIVIAZIONE_MOD      NUMBER(1)         DEFAULT 0                     NOT NULL,
  DATA_APERTURA               DATE,
  DATA_APERTURA_MOD           NUMBER(1)         DEFAULT 0                     NOT NULL,
  DATA_CHIUSURA               DATE,
  DATA_CHIUSURA_MOD           NUMBER(1)         DEFAULT 0                     NOT NULL,
  DATA_CREAZIONE              DATE,
  DATA_CREAZIONE_MOD          NUMBER(1)         DEFAULT 0                     NOT NULL,
  DIGITALE                    CHAR(1 BYTE),
  DIGITALE_MOD                NUMBER(1)         DEFAULT 0                     NOT NULL,
  NOTE                        VARCHAR2(4000 BYTE),
  NOTE_MOD                    NUMBER(1)         DEFAULT 0                     NOT NULL,
  NUMERO                      NUMBER(19),
  NUMERO_MOD                  NUMBER(1)         DEFAULT 0                     NOT NULL,
  NUMERO_PROSSIMO_ANNO        CHAR(1 BYTE),
  NUMERO_PROSSIMO_ANNO_MOD    NUMBER(1)         DEFAULT 0                     NOT NULL,
  OGGETTO                     VARCHAR2(4000 BYTE),
  OGGETTO_MOD                 NUMBER(1)         DEFAULT 0                     NOT NULL,
  RESPONSABILE                VARCHAR2(4000 BYTE),
  RESPONSABILE_MOD            NUMBER(1)         DEFAULT 0                     NOT NULL,
  RISERVATO                   CHAR(1 BYTE),
  RISERVATO_MOD               NUMBER(1)         DEFAULT 0                     NOT NULL,
  TOPOGRAFIA                  VARCHAR2(4000 BYTE),
  TOPOGRAFIA_MOD              NUMBER(1)         DEFAULT 0                     NOT NULL,
  ID_CLASSIFICAZIONE          NUMBER(19),
  ID_CLASSIFICAZIONE_MOD      NUMBER(1)         DEFAULT 0                     NOT NULL,
  ID_DOCUMENTO                NUMBER,
  REV                         NUMBER(19),
  ANNO_NUMERO_MOD             NUMBER(1)         DEFAULT 0                     NOT NULL,
  ANNO_NUMERO                 VARCHAR2(400 BYTE),
  ULTIMO_NUMERO_SUB           NUMBER(19),
  ULTIMO_NUMERO_SUB_MOD       NUMBER(1)         DEFAULT 0                     NOT NULL,
  MOVIMENTO                   VARCHAR2(4000 BYTE),
  MOVIMENTO_MOD               NUMBER            DEFAULT 0                     NOT NULL,
  IDRIF                       VARCHAR2(4000 BYTE),
  IDRIF_MOD                   NUMBER(1)         DEFAULT 0                     NOT NULL,
  NUMERO_ORD                  VARCHAR2(4000 BYTE),
  NUMERO_ORD_MOD              NUMBER(1)         DEFAULT 0                     NOT NULL,
  ID_FASCICOLO_PADRE          NUMBER(19),
  ID_FASCICOLO_PADRE_MOD      NUMBER(1)         DEFAULT 0                     NOT NULL,
  STATO_FASCICOLO             VARCHAR2(4000 BYTE),
  STATO_FASCICOLO_MOD         NUMBER(1)         DEFAULT 0                     NOT NULL,
  DATA_STATO                  DATE,
  DATA_STATO_MOD              NUMBER(1)         DEFAULT 0                     NOT NULL,
  NOME                        VARCHAR2(4000 BYTE),
  NOME_MOD                    NUMBER(1)         DEFAULT 0                     NOT NULL,
  SUB                         NUMBER,
  SUB_MOD                     NUMBER(1)         DEFAULT 0                     NOT NULL,
  DATA_ARCHIVIAZIONE          DATE,
  DATA_ARCHIVIAZIONE_MOD      NUMBER(1)         DEFAULT 0                     NOT NULL,
  CLASSIFICAZIONE             NUMBER,
  CLASSIFICAZIONE_MOD         NUMBER(1)         DEFAULT 0                     NOT NULL,
  DATA_ULTIMA_OPERAZIONE      DATE,
  DATA_ULTIMA_OPERAZIONE_MOD  NUMBER(1)         DEFAULT 0                     NOT NULL,
  ID_DOCUMENTO_DATI_SCARTO    NUMBER(19),
  DATI_SCARTO_MOD             NUMBER            DEFAULT 0                     NOT NULL,
  DESCRIZIONE_SCARTO          VARCHAR2(1000 BYTE),
  PEZZI_SCARTO                NUMBER(10),
  PESO_SCARTO                 NUMBER(10,2),
  UBICAZIONE_SCARTO           VARCHAR2(1000 BYTE),
  OSSERVAZIONI_SCARTO         VARCHAR2(4000 BYTE),
  DESCRIZIONE_SCARTO_MOD      VARCHAR2(1000 BYTE),
  PEZZI_SCARTO_MOD            NUMBER(10),
  PESO_SCARTO_MOD             NUMBER(10,2),
  UBICAZIONE_SCARTO_MOD       VARCHAR2(1000 BYTE),
  OSSERVAZIONI_SCARTO_MOD     VARCHAR2(4000 BYTE)
)
/


CREATE UNIQUE INDEX AGS_FALO_PK ON AGS_FASCICOLI_LOG
(ID_DOCUMENTO, REV)
/

ALTER TABLE AGS_FASCICOLI_LOG ADD (
  CONSTRAINT AGS_FALO_PK
  PRIMARY KEY
  (ID_DOCUMENTO, REV)
  USING INDEX AGS_FALO_PK
  ENABLE VALIDATE)
/

ALTER TABLE AGS_FASCICOLI_LOG ADD (
  CONSTRAINT AGS_FALO_DOLO_FK 
  FOREIGN KEY (ID_DOCUMENTO, REV) 
  REFERENCES GDO_DOCUMENTI_LOG (ID_DOCUMENTO,REV)
  ENABLE VALIDATE)
/

CREATE OR REPLACE FORCE VIEW AGS_FASCICOLI_TRASCO_VIEW
(
   ID_FASCICOLO,
   ID_DOCUMENTO_ESTERNO,
   ID_CLASSIFICAZIONE,
   CLASS_COD,
   CLASS_DAL,
   ANNO,
   NUMERO,
   OGGETTO,
   ANNO_NUMERO,
   ULTIMO_NUMERO_SUB,
   NUMERO_PROSSIMO_ANNO,
   DIGITALE,
   RISERVATO,
   RESPONSABILE,
   DATA_APERTURA,
   DATA_CHIUSURA,
   IDRIF,
   SUB,
   UTENTE_CREAZIONE,
   ANNO_ARCHIVIAZIONE,
   DATA_ARCHIVIAZIONE,
   STATO,
   DATA_STATO,
   TOPOGRAFIA,
   NOTE,
   STATO_SCARTO,
   DATA_STATO_SCARTO,
   DESCRIZIONE_SCARTO,
   OSSERVAZIONI_SCARTO,
   PEZZI_SCARTO,
   PESO_SCARTO,
   UBICAZIONE_SCARTO,
   ANNO_MASSIMO_SCARTO,
   ANNO_MINIMO_SCARTO,
   ANNO_RICHIESTA_SCARTO,
   DATA_NULLA_OSTA,
   NUMERO_NULLA_OSTA,
   NUMERO_ORD,
   ID_ENTE,
   UNITA_CREAZIONE_PROGR,
   UNITA_CREAZIONE_DAL,
   UNITA_CREAZIONE_OTTICA,
   UNITA_COMPETENZA_PROGR,
   UNITA_COMPETENZA_DAL,
   UNITA_COMPETENZA_OTTICA,
   UNITA_ASSEGNATARIA_PROGR,
   UNITA_ASSEGNATARIA_DAL,
   UNITA_ASSEGNATARIA_OTTICA,
   UTENTE_INS,
   DATA_INS,
   VALIDO,
   UTENTE_UPD,
   DATA_UPD,
   VERSION,
   UFFICIO_COMPETENZA,
   UFFICIO_CREAZIONE,
   DATA_CREAZIONE,
   NUMERO_FASCICOLO_PADRE,
   ANNO_FASCICOLO_PADRE,
   CR_PADRE
)
AS
   SELECT -ts.id_documento AS id_fascicolo,
          ts.id_documento ID_DOCUMENTO_ESTERNO,
          tc.id_classificazione id_CLASSIFICAZIONE,
          ts.class_cod,
          ts.class_dal,
          fascicolo_anno ANNO,
          fascicolo_numero NUMERO,
          fascicolo_oggetto OGGETTO,
          fascicolo_anno || '/' || fascicolo_numero ANNO_NUMERO,
          ULTIMO_NUMERO_SUB,
          NUMERAZIONE_AUTOMATICA,
          ARCHIVIO_DIGITALE,
          CAST (NVL (riservato, 'N') AS CHAR (1)),
          RESPONSABILE,
          DATA_APERTURA,
          DATA_CHIUSURA,
          ts.IDRIF,
          SUB,
          UTENTE_CREAZIONE,
          ANNO_ARCHIVIAZIONE,
          DATA_ARCHIVIAZIONE,
          stato_fascicolo STATO,
          DATA_STATO,
          TOPOGRAFIA,
          ts.NOTE,
          STATO_SCARTO,
          DATA_STATO_SCARTO,
          DESCRIZIONE_SCARTO,
          OSSERVAZIONI_SCARTO,
          PEZZI_SCARTO,
          PESO_SCARTO,
          UBICAZIONE_SCARTO,
          ANNO_MASSIMO_SCARTO,
          ANNO_MINIMO_SCARTO,
          ANNO_RICHIESTA_SCARTO,
          DATA_NULLA_OSTA,
          NUMERO_NULLA_OSTA,
          AGS_FASCICOLI_PKG.get_numero_fasc_ord (fascicolo_numero) NUMERO_ORD,
          enti.ID_ENTE,
          UNITA_CRE.PROGR_unita_organizzativa UNITA_CREAZIONE_PROGR,
          UNITA_CRE.DAL UNITA_CREAZIONE_DAL,
          UNITA_CRE.OTTICA UNITA_CREAZIONE_OTTICA,
          UNITA_COMP.PROGR_unita_organizzativa UNITA_COMPETENZA_PROGR,
          UNITA_COMP.DAL UNITA_COMPETENZA_DAL,
          UNITA_COMP.OTTICA UNITA_COMPETENZA_OTTICA,
          TO_NUMBER (NULL)               --UNITA_ASS.PROGR_unita_organizzativa
                          UNITA_ASSEGNATARIA_PROGR,
          TO_DATE (NULL)                                       --UNITA_ASS.dal
                        UNITA_ASSEGNATARIA_DAL,
          TO_CHAR (NULL)                                    --UNITA_ASS.OTTICA
                        UNITA_ASSEGNATARIA_OTTICA,
          UTENTE_CREAZIONE UTENTE_INS,
          DATA_CREAZIONE DATA_INS,
          CAST (
             DECODE (NVL (C.STATO, 'BO'),
                     'CA', 'N',
                     DECODE (NVL (d.stato_documento, 'BO'), 'CA', 'N', 'Y')) AS CHAR (1))
             valido,
          d.utente_aggiornamento UTENTE_UPD,
          d.data_aggiornamento DATA_UPD,
          0 VERSION,
          ts.UFFICIO_COMPETENZA,
          ts.UFFICIO_CREAZIONE,
          ts.DATA_CREAZIONE,
          DECODE (NUMERO_FASCICOLO_PADRE, 0, NULL, NUMERO_FASCICOLO_PADRE),
          DECODE (ANNO_FASCICOLO_PADRE, 0, NULL, ANNO_FASCICOLO_PADRE),
          CR_PADRE
     FROM gdm_fascicoli ts,
          ags_classificazioni tc,
          gdm_documenti d,
          GDM_CARTELLE C,
          GDO_ENTI ENTI,
          vista_pubb_unita_attuali unita_comp,
          vista_pubb_unita_attuali unita_cre
    WHERE     d.id_documento = ts.id_documento
          AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
          AND C.ID_DOCUMENTO_PROFILO = D.ID_DOCUMENTO
          AND NVL (C.STATO, ' ') <> 'CA'
          AND TC.CLASSIFICAZIONE = ts.class_cod
          AND TC.CLASSIFICAZIONE_dal = ts.class_dal
          AND ENTI.AMMINISTRAZIONE = ts.CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = ts.CODICE_AOO
          AND ENTI.OTTICA = (SELECT GDM_AG_PARAMETRO.GET_VALORE (
                                       'SO_OTTICA_PROT',
                                       ts.CODICE_AMMINISTRAZIONE,
                                       ts.CODICE_AOO,
                                       '')
                               FROM DUAL)
          AND UNITA_CRE.CODICE_UO(+) = ts.ufficio_creazione
          AND unita_comp.CODICE_UO(+) = ts.ufficio_competenza
          AND TC.VALIDO = 'Y'
          AND NVL (UNITA_CRE.ottica, ENTI.OTTICA) = ENTI.OTTICA
          AND NVL (unita_comp.ottica, ENTI.OTTICA) = ENTI.OTTICA
/
