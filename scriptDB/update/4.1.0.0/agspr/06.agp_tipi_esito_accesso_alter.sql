--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200327.6.agp_tipi_esito_accesso_alter
CREATE INDEX AGP_TEAC_ENTI_FK ON AGP_TIPI_ESITO_ACCESSO
(ID_ENTE)
/
ALTER TABLE AGP_TIPI_ESITO_ACCESSO
 ADD CONSTRAINT AGP_TEAC_ENTI_FK
  FOREIGN KEY (ID_ENTE)
  REFERENCES GDO_ENTI (ID_ENTE)
/