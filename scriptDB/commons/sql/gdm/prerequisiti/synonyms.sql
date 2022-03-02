--liquibase formatted sql
--changeset esasdelli:_20200220_synonyms_prerequisiti  runOnChange:true stripComments:false
create or replace synonym so4_soggetti_aoo for ${global.db.so4.username}.soggetti_aoo
/

create or replace synonym so4_soggetti_unita for ${global.db.so4.username}.soggetti_unita
/

create or replace synonym as4_registro for ${global.db.as4.username}.registro
/