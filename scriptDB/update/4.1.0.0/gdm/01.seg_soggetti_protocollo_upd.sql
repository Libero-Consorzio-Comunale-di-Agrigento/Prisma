--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20200707_001.seg_soggetti_protocollo_upd

UPDATE seg_soggetti_protocollo
SET insegna_extra = TRIM('.' FROM insegna_Extra)||'.'
WHERE insegna_extra IS NOT NULL
/