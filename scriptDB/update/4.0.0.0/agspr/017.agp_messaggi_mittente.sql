--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_017.agp_messaggi_mittente
CREATE TABLE AGP_MESSAGGI_MITTENTE
(
   id_messaggio_mittente   NUMBER NOT NULL,
   id_messaggio            NUMBER NOT NULL,
   tagmail                 VARCHAR2 (255) NOT NULL,
   tipo_consegna           VARCHAR2 (255) DEFAULT 'COMPLETA' NOT NULL,
   amministrazione         VARCHAR2 (255) NOT NULL,
   aoo                     VARCHAR2 (255),
   codice_uo               VARCHAR2 (255)
)
/

ALTER TABLE AGP_MESSAGGI_MITTENTE ADD (
  CONSTRAINT AGP_MESSAGGI_MITTENTE_PK
  PRIMARY KEY
  (id_messaggio_mittente)
  ENABLE VALIDATE)
/

ALTER TABLE AGP_MESSAGGI_MITTENTE ADD (
  CONSTRAINT AGP_MESSAGGI_MITTENTE_UK
  UNIQUE (id_messaggio)
  ENABLE VALIDATE)
/