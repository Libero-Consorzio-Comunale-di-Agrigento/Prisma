--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_SO4_V_COMPONENTI_PUBB runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SO4_V_COMPONENTI_PUBB" ("ID_COMPONENTE", "ID_SOGGETTO", "NOMINATIVO_SOGGETTO", "CI_SOGGETTO_GP4", "PROGR_UNITA", "DAL", "AL", "OTTICA", "STATO") AS 
  SELECT id_componente,
          ni id_soggetto,
          nominativo nominativo_soggetto,
          ci ci_soggetto_Gp4,
          progr_unita_organizzativa progr_unita,
          dal,
          al,
          ottica,
          stato
     FROM SO4_COMPONENTI_PUBB

/
