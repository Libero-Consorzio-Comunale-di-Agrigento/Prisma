--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200904_42.agp_msg_inviati_dati_prot_log_alter failOnError:false

ALTER TABLE agp_msg_inviati_dati_prot_log
ADD (
  DATA_ACCETTAZIONE          DATE,
  DATA_ACCETTAZIONE_MOD      NUMBER(1)          DEFAULT 0                     NOT NULL,
  DATA_NON_ACCETTAZIONE      DATE,
  DATA_NON_ACCETTAZIONE_MOD  NUMBER(1)          DEFAULT 0                     NOT NULL
)
/