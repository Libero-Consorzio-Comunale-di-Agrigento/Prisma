--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_SCHEMI_PROT_SMISTAMENTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_SCHEMI_PROT_SMISTAMENTI" ("ID_SCHEMA_PROT_SMISTAMENTO", "ID_SCHEMA_PROTOCOLLO", "UFFICIO_SMISTAMENTO_OTTICA", "UFFICIO_SMISTAMENTO_PROGR", "UFFICIO_SMISTAMENTO_DAL", "TIPO_SMISTAMENTO", "UFFICIO_SMISTAMENTO", "ID_DOCUMENTO_ESTERNO", "ID_ENTE", "UTENTE_INS", "DATA_INS", "UTENTE_UPD", "DATA_UPD", "VALIDO", "SEQUENZA", "EMAIL", "FASCICOLO_OBBLIGATORIO", "VERSION") AS 
  SELECT -ts.id_documento id_schema_prot_smistamento,
          -tD.ID_DOCUMENTO id_schema_protocollo,
          U1.OTTICA,
          u1.progr_unita_organizzativa,
          u1.dal,
          ts.tipo_smistamento tipo_smistamento,
          ts.ufficio_smistamento ufficio_smistamento,
          ts.id_documento id_documento_esterno,
          ENTI.ID_ENTE,
          d.utente_aggiornamento UTENTE_INS,
          d.data_aggiornamento DATA_INS,
          d.utente_aggiornamento UTENTE_UPD,
          d.data_aggiornamento DATA_UPD,
          CAST ('Y' AS CHAR (1)) valido,
          ts.sequenza,
          email,
          CAST (NVL(fascicolo_obbligatorio,'N') AS CHAR (1)),
          1 version
     FROM gdm_SMISTAMENTI_TIPI_DOCUMENTO ts,
          gdm_documenti d,
          GDO_ENTI ENTI,
          gdm_seg_TIPI_DOCUMENTO td,
          gdm_documenti dtd,
          so4_unita_organizzative_pubb U1
    WHERE     d.id_documento = ts.id_documento
          AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
          AND ENTI.AMMINISTRAZIONE = ts.CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = ts.CODICE_AOO
          AND ENTI.OTTICA = GDM_AG_PARAMETRO.GET_VALORE (
                               'SO_OTTICA_PROT',
                               ts.CODICE_AMMINISTRAZIONE,
                               ts.CODICE_AOO,
                               '')
          AND td.tipo_documento = ts.TIPO_DOCUMENTO
          AND dtd.id_documento = td.id_documento
          AND dtd.stato_documento NOT IN ('CA', 'RE', 'PB')
          AND U1.OTTICA = ENTI.OTTICA
          AND U1.CODICE_UO = TS.UFFICIO_SMISTAMENTO
          AND u1.dal =
                 get_unita_max_dal (u1.progr_unita_organizzativa, U1.OTTICA)
/
