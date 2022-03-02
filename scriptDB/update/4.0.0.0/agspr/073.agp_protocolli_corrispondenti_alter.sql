--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_073.agp_protocolli_corrispondenti_alter
alter table AGP_PROTOCOLLI_CORRISPONDENTI
add (ID_FISCALE_ESTERO VARCHAR2(255))
/