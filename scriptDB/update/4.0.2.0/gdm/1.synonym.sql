--liquibase formatted sql
--changeset mmalferrari:4.0.2.0_20200812_1.synonym failOnError:false

create or replace synonym BLACKLISTCHAR for ${global.db.agspr.username}.BLACKLISTCHAR
/