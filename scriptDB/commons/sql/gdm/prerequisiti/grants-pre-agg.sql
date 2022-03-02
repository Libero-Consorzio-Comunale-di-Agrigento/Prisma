--liquibase formatted sql
--property name:global.db.agspr.username value:PROVA
--changeset rdestasio:_20200510_01.gdm  runOnChange:true stripComments:false

grant execute on AG_PARAMETRO to ${global.db.so4.username}
/
grant all on AG_PRIV_UTENTE_BLACKLIST to ${global.db.agspr.username} WITH GRANT OPTION
/
grant execute on AG_SPEDIZIONE_UTILITY to ${global.db.agspr.username} WITH GRANT OPTION
/