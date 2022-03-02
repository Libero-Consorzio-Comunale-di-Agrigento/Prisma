--liquibase formatted sql
--changeset mmalferrari:4.1.0.0_20201008_51.ag_priv_utente_blacklist
create or replace view ag_priv_utente_blacklist as
select * from ${global.db.gdm.username}.ag_priv_utente_blacklist
/