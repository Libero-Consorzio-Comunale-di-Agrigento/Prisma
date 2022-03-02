--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_SEG_TIPI_DOCUMENTO_ALLEGATI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SEG_TIPI_DOCUMENTO_ALLEGATI" ("ID_SCHEMA_PROT_ALLEGATI", "ID_SCHEMA_PROTOCOLLO", "CONTENT_TYPE", "DIMENSIONE", "ID_FILE_ESTERNO", "NOME", "ID_TIPO_ALLEGATO", "SEQUENZA", "UTENTE_INS", "DATA_INS", "UTENTE_UPD", "DATA_UPD", "VALIDO", "VERSION", "TIPO_DOCUMENTO", "TIPO_ALLEGATO") AS 
  SELECT scal."ID_SCHEMA_PROT_ALLEGATI",
          scal."ID_SCHEMA_PROTOCOLLO",
          scal."CONTENT_TYPE",
          scal."DIMENSIONE",
          scal."ID_FILE_ESTERNO",
          scal."NOME",
          TIAL.ID_DOCUMENTO,
          scal."SEQUENZA",
          scal."UTENTE_INS",
          scal."DATA_INS",
          scal."UTENTE_UPD",
          scal."DATA_UPD",
          scal."VALIDO",
          scal."VERSION",
          tido.tipo_documento,
          TIAL.TIPO_ALLEGATO
     FROM agspr_AGP_SCHEMI_PROT_ALLEGATI scal,
          seg_tipi_documento tido,
          seg_tipi_allegato tial
    WHERE     TIDO.ID_DOCUMENTO = -SCAL.ID_SCHEMA_PROTOCOLLO
          AND TIAL.ID_DOCUMENTO(+) = -SCAL.ID_TIPO_ALLEGATO

/
