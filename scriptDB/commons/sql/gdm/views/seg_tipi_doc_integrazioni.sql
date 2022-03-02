CREATE OR REPLACE FORCE VIEW seg_tipi_doc_integrazioni
AS
   SELECT spin.APPLICATIVO,
          tido.TIPO_DOCUMENTO,
          spin.ID_SCHEMA_PROT_INTEGRAZIONI,
          -TIDO.ID_DOCUMENTO ID_SCHEMA_PROTOCOLLO
     FROM agp_schemi_prot_integrazioni spin,
          seg_tipi_documento tido,
          documenti docu
    WHERE     -spin.ID_SCHEMA_PROTOCOLLO = tido.id_documento
          AND spin.VALIDO = 'Y'
          AND docu.id_documento = tido.id_documento
          AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
/