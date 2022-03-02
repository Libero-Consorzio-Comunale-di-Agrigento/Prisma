--liquibase formatted sql
--property name:global.db.agspr.username value:AGSPR
--changeset mmalferrari:_20200408_grants  runOnChange:true stripComments:false

grant execute on ASSISTENTE_VIRTUALE_PKG to ${global.db.agspr.username}
/