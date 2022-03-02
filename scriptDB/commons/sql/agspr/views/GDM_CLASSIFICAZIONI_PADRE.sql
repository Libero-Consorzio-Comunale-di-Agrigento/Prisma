--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_GDM_CLASSIFICAZIONI_PADRE runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "GDM_CLASSIFICAZIONI_PADRE" ("ID_DOCUMENTO", "CLASS_COD", "CLASS_DAL", "CLASS_AL", "ID_DOCUMENTO_PADRE", "CLASS_COD_PADRE", "CLASS_DAL_PADRE") AS 
  select gc.id_documento
        , gc.class_cod
        , gc.class_dal
        , gc.class_al
        , gc_padre.id_documento
        , gc_padre.class_cod
        , gc_padre.class_dal
     from gdm_classificazioni gc, gdm_classificazioni gc_padre
    where gc.class_padre = gc_padre.class_cod
      and gc.dal_padre = gc_padre.class_dal
/
