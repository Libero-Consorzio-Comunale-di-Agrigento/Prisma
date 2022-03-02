--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201023_60.agp_protocolli_corrispondenti_log_alter.sql failOnError:false

alter table AGP_PROTOCOLLI_CORR_LOG
add(suap char(1) default 'N' not null,
suap_mod NUMBER(1)       DEFAULT 0 not null)
/