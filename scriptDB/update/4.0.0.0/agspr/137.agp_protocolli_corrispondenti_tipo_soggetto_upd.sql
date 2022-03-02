--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_137.agp_protocolli_corrispondenti_tipo_soggetto_upd
update agp_protocolli_corrispondenti
set tipo_soggetto = 1
where tipo_soggetto = -1
/