--liquibase formatted sql
--changeset esasdelli:_20200220_AG_CREA_VISTE_ANAGRAFICA  runAlways:true runOnChange:true failOnError:false
BEGIN
  AG_CREA_VISTE_ANAGRAFICA.CREA();
END;
/

grant all on SEG_ANAGRAFICI to ${global.db.agspr.username}
/