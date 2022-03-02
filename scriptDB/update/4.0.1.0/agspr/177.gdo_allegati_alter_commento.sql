--liquibase formatted sql
--changeset mmalferrari:4.0.1.0_20200711_176.gdo_allegati_alter_commento

alter table gdo_allegati modify commento varchar2(4000)
/
