--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201007_47.job_lob_alter
ALTER TABLE JOB_LOG
MODIFY(STACKTRACE VARCHAR2(4000 BYTE))
/