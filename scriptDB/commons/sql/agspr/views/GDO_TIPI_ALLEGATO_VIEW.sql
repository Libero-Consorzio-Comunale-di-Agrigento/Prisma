--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_GDO_TIPI_ALLEGATO_VIEW runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "GDO_TIPI_ALLEGATO_VIEW" ("ID_TIPO_DOCUMENTO", "STAMPA_UNICA") AS 
  SELECT id_tipo_documento, stampa_unica FROM gdo_tipi_allegato
   UNION
   SELECT id_tipo_documento, 'N'
     FROM gdo_tipi_documento_view
    WHERE codice = 'ALLEGATO' AND id_tipo_documento < 0
/
