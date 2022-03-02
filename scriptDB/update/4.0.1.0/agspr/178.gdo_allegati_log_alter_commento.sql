--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200711_176.gdo_allegati_log_alter_commento

alter table gdo_allegati_log modify commento varchar2(4000)
/
