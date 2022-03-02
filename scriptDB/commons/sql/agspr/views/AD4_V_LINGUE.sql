--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AD4_V_LINGUE runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW "AD4_V_LINGUE" ("LINGUA", "DESCRIZIONE") AS
  SELECT "LINGUA","DESCRIZIONE"
     FROM AD4_LINGUE
/
