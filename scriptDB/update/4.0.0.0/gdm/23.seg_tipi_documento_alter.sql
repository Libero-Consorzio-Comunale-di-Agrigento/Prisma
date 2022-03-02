--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_23.seg_tipi_documento_alter failOnError:false
alter table seg_tipi_documento add (riservato varchar2(1) default 'N' not null)
/
alter table seg_tipi_documento modify (tipo_registro_documento varchar2(8))
/