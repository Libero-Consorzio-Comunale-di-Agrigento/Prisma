--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_124.drop_agp_schemi_collegati failOnError:false
DROP TABLE AGP_SCHEMI_COLLEGATI CASCADE CONSTRAINTS
/