--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200904_59.aagp_protocolli_corrispondenti_alter.sql failOnError:false

alter table AGP_PROTOCOLLI_CORRISPONDENTI
add(suap char(1))
/
update AGP_PROTOCOLLI_CORRISPONDENTI
set suap = 'N'
/
alter table AGP_PROTOCOLLI_CORRISPONDENTI
modify(suap default 'N' not null)
/