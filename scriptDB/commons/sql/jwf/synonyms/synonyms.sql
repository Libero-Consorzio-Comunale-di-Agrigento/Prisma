--liquibase formatted sql
--changeset mmalferrari:_20200331_synonyms  runOnChange:true stripComments:false
create or replace synonym ag_comp_crea_protocollo for ${global.db.gdm.username}.ag_comp_crea_protocollo
/
create or replace synonym ag_verifica_privilegi_utente for ${global.db.gdm.username}.ag_verifica_privilegi_utente
/