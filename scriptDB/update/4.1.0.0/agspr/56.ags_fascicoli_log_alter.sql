--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201021_56.ags_fascicoli_log_alter failOnError:false

alter table ags_fascicoli_log modify numero varchar2(255)
/