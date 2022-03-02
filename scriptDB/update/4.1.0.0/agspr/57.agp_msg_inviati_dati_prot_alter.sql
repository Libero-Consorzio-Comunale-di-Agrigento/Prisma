--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200904_42.agp_msg_inviati_dati_prot_alter failOnError:false

ALTER TABLE agp_msg_inviati_dati_prot
ADD (
  DATA_ACCETTAZIONE          DATE,
  DATA_NON_ACCETTAZIONE      DATE
)
/