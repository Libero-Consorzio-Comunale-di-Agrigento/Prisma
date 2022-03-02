--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_MESSAGGI_PROTOCOLLI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_MESSAGGI_PROTOCOLLI" ("ID_MESSAGGIO_PROTOCOLLO", "ID_MESSAGGIO", "ID_PROTOCOLLO", "VALIDO", "UTENTE_INS", "DATA_INS", "UTENTE_UPD", "DATA_UPD", "VERSION") AS 
  SELECT -get_number_from_string (M.ID_DOCUMENTO || '_' || R.ID_DOCUMENTO)
             ID_MESSAGGIO_PROTOCOLLO,
          -M.ID_DOCUMENTO ID_MESSAGGIO,
          R.ID_DOCUMENTO ID_PROTOCOLLO,
          CAST ('Y' AS CHAR (1)) valido,
          TO_CHAR (NULL) UTENTE_INS,
          TO_DATE (NULL) DATA_INS,
          TO_CHAR (NULL) UTENTE_UPD,
          TO_DATE (NULL) DATA_UPD,
          0 VERSION
     FROM gdm_seg_memo_protocollo m, gdm_riferimenti r, gdo_documenti p
    WHERE     r.id_documento_rif = m.id_documento
          AND p.id_documento_esterno = r.id_documento
          AND r.tipo_relazione = 'MAIL'
          AND r.area = 'SEGRETERIA.PROTOCOLLO'
/
