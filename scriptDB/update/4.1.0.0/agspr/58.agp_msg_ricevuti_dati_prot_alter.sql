--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200904_42.agp_msg_ricevuti_dati_prot_alter failOnError:false

ALTER TABLE agp_msg_ricevuti_dati_prot
   ADD IDRIF VARCHAR2 (255)
/