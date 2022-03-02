--liquibase formatted sql
--changeset mfrancesconi:4.0.0.0_20200226_125_drop_agp_documenti_dati_scarto

DROP TABLE AGP_DOCUMENTI_DATI_SCARTO CASCADE CONSTRAINTS
/