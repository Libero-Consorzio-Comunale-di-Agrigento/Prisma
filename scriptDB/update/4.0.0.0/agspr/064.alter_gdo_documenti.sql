--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_064.alter_gdo_documenti
update GDO_DOCUMENTI
set RISERVATO = 'N'
where RISERVATO is null
/

ALTER TABLE GDO_DOCUMENTI
MODIFY(RISERVATO DEFAULT 'N' NOT NULL)
/