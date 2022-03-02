--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200327.17.agp_messaggi_corrispondenti_alter failOnError:false
CREATE INDEX AGP_MECO_PRCO_FK ON AGP_MESSAGGI_CORRISPONDENTI
(ID_PROTOCOLLO_CORRISPONDENTE)
/
ALTER TABLE AGP_MESSAGGI_CORRISPONDENTI
 ADD CONSTRAINT AGP_MECO_PRCO_FK
  FOREIGN KEY (ID_PROTOCOLLO_CORRISPONDENTE)
  REFERENCES AGP_PROTOCOLLI_CORRISPONDENTI (ID_PROTOCOLLO_CORRISPONDENTE)
/