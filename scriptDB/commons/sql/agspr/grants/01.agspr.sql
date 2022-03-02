--liquibase formatted sql
--changeset mfrancesconi:20200226_GDM_GRANTS  runOnChange:true stripComments:false stripComments:false

grant execute on AGP_COMPETENZE_DOCUMENTO to ${global.db.gdm.username} WITH GRANT OPTION
/

grant all on gdo_file_documento to ${global.db.gdm.username} WITH GRANT OPTION
/

grant all on GDO_NOTIFICHE_ATTIVITA to ${global.db.gdm.username} WITH GRANT OPTION
/
