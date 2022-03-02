--liquibase formatted sql
--changeset esasdelli:20200219_SO4_GRANTS  runOnChange:true stripComments:false stripComments:false

grant select on AMMINISTRAZIONI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on ANAGRAFE_UNITA_ORGANIZZATIVE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AOO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AOO_VIEW to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on APPLICATIVI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on COMPETENZE_DELEGA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on COMPETENZE_DELEGA_TPK to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on DELEGHE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on INDIRIZZI_TELEMATICI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on OTTICHE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on RUOLI_COMPONENTE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on SOGGETTI_UNITA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on SO4_AGS_PKG to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on SO4_UTIL to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on SUDDIVISIONI_STRUTTURA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant all on UNITA_ORGANIZZATIVE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_ATCO_GRAILS to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_ATCO_GRAILS_PUBB to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_COMP_GRAILS to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_COMP_GRAILS_PUBB to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_PUBB_RUCO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_PUBB_UNITA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_UNITA_ORGANIZZATIVE to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on VISTA_UNITA_ORGANIZZATIVE_PUBB to ${global.db.agspr.username} WITH GRANT OPTION
/

GRANT EXECUTE ON INDIRIZZO_TELEMATICO TO ${global.db.agspr.username} WITH GRANT OPTION
/

GRANT EXECUTE ON CODICI_IPA_TPK TO ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on anagrafe_unita_organizzativa to ${global.db.agspr.username} with grant option
/

grant select on soggetti_aoo to ${global.db.gdm.username} with grant option
/

GRANT select on SOGGETTI_UNITA to ${global.db.gdm.username} with grant option
/

grant select on aoo to ${global.db.gdm.username} with grant option
/

grant select on vista_indirizzi_telematici to ${global.db.agspr.username} with grant option
/
