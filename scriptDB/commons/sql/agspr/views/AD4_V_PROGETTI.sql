--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AD4_V_PROGETTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AD4_V_PROGETTI" ("PROGETTO", "DESCRIZIONE", "PRIORITA", "NOTE") AS 
  SELECT p.progetto,
          p.descrizione,
          p.priorita,
          p.note
     FROM AD4_PROGETTI p
/
