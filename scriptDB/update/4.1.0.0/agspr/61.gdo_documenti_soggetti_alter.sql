--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201023_61.gdo_documenti_soggetti_alter.sql failOnError:false

CREATE INDEX GDO_DOSO_DOCU_FK ON GDO_DOCUMENTI_SOGGETTI
(ID_DOCUMENTO)
/

ALTER TABLE GDO_DOCUMENTI_SOGGETTI ADD (
  CONSTRAINT GDO_DOSO_DOCU_FK
  FOREIGN KEY (ID_DOCUMENTO)
  REFERENCES GDO_DOCUMENTI (ID_DOCUMENTO))
/