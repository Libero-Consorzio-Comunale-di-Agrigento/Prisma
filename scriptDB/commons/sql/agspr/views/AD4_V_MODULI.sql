--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AD4_V_MODULI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AD4_V_MODULI" ("MODULO", "DESCRIZIONE", "PROGETTO", "NOTE") AS 
  SELECT modulo,
          descrizione,
          progetto,
          note
     FROM AD4_MODULI
/
