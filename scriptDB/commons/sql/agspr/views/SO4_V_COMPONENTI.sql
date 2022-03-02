--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_SO4_V_COMPONENTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SO4_V_COMPONENTI" ("ID_COMPONENTE", "PROGR_UNITA", "DAL", "AL", "ID_SOGGETTO", "NOMINATIVO_SOGGETTO", "CI_SOGGETTO_GP4", "OTTICA", "STATO") AS 
  SELECT id_componente,
          progr_unita_organizzativa progr_unita,
          dal,
          al,
          ni id_soggetto,
          nominativo nominativo_soggetto,
          ci ci_soggetto_Gp4,
          ottica,
          stato
     FROM SO4_COMPONENTI

/
