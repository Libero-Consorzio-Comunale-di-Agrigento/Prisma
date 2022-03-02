--liquibase formatted sql
--changeset esasdelli:20200219_AS4_GRANTS  runOnChange:true stripComments:false stripComments:false

grant select on ANAGRAFE_SOGGETTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ANAGRAFE_SOGGETTI_PKG to ${global.db.agspr.username}
/

grant execute on ANAGRAFE_SOGGETTI_REFRESH to ${global.db.agspr.username}
/

grant execute on ANAGRAFE_SOGGETTI_TPK to ${global.db.agspr.username}
/

grant select on ANAGRAFICI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on ANAGRAFICI_PKG to ${global.db.agspr.username}
/

grant execute on ANAGRAFICI_TPK to ${global.db.agspr.username}
/

grant select on AS4_V_ANAGRAFICI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_ANAGRAFICI_STRUTTURA to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_CONTATTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_RECAPITI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_RECAPITI_CORRENTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_SOGGETTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_SOGGETTI_CORRENTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_SOGGETTI_STORICO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_TIPI_CONTATTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_TIPI_RECAPITO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on AS4_V_TIPI_SOGGETTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on CONTATTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on CONTATTI_PKG to ${global.db.agspr.username}
/

grant execute on CONTATTI_TPK to ${global.db.agspr.username}
/

grant select on RECAPITI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on RECAPITI_PKG to ${global.db.agspr.username}
/

grant execute on RECAPITI_TPK to ${global.db.agspr.username}
/

grant select on SOGGETTI to ${global.db.agspr.username} WITH GRANT OPTION
/

grant select on TIPI_CONTATTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on TIPI_CONTATTO_TPK to ${global.db.agspr.username}
/

grant select on TIPI_RECAPITO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on TIPI_RECAPITO_TPK to ${global.db.agspr.username}
/

grant select on TIPI_SOGGETTO to ${global.db.agspr.username} WITH GRANT OPTION
/

grant execute on TIPI_SOGGETTO_TPK to ${global.db.agspr.username}
/

grant all on registro to ${global.db.gdm.username}
/

grant execute on tipi_recapito_tpk to ${global.db.agspr.username}
/