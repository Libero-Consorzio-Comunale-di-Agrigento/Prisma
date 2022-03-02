--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_VISTA_PUBB_UNITA_ATTUALI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "VISTA_PUBB_UNITA_ATTUALI" ("ID_ELEMENTO", "OTTICA", "PROGR_UNITA_ORGANIZZATIVA", "DAL", "AL", "ID_UNITA_PADRE", "PROGR_UNITA_PADRE", "CODICE_UO") AS 
  SELECT    ID_ELEMENTO,
   OTTICA,
   PROGR_UNITA_ORGANIZZATIVA,
   DAL,
   AL,
   ID_UNITA_PADRE,
   PROGR_UNITA_PADRE,
   CODICE_UO
     FROM so4_vista_pubb_unita
    WHERE  SYSDATE BETWEEN dal
                          AND NVL (al,
                                 TO_DATE (3333333, 'j'))
/
