--liquibase formatted sql
--changeset mmalferrari:AGSPR_VIEW_SO4_VISTA_INDIRIZZI_TELEMATICI runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW SO4_VISTA_INDIRIZZI_TELEMATICI
AS
   SELECT * FROM ${global.db.so4.username}.vista_indirizzi_telematici
/