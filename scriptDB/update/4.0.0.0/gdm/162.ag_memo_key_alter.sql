--liquibase formatted sql
--changeset mmalferrari:4.0.0.0_20200506_162_ag_memo_key_alter
alter table ag_memo_key modify MESSAGE_ID VARCHAR2(200)
/