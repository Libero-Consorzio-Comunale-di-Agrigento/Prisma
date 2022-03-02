--liquibase formatted sql
--changeset mmalferrari:20200511 runOnChange:true
create or replace synonym gdm_ag_parametro for ${global.db.gdm.username}.ag_parametro
/