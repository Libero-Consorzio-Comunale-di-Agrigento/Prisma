--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_009.agp_tipi_protocollo_alter
ALTER TABLE AGP_TIPI_PROTOCOLLO
ADD (PREDEFINITO CHAR(1) DEFAULT 'N' NOT NULL)
/