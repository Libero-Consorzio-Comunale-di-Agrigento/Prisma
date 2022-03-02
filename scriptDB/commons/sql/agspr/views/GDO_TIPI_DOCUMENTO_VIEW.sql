--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_GDO_TIPI_DOCUMENTO_VIEW runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "GDO_TIPI_DOCUMENTO_VIEW" ("ID_TIPO_DOCUMENTO", "ID_ENTE", "DESCRIZIONE", "COMMENTO", "CONSERVAZIONE_SOSTITUTIVA", "PROGRESSIVO_CFG_ITER", "TESTO_OBBLIGATORIO", "ID_TIPOLOGIA_SOGGETTO", "VALIDO", "UTENTE_INS", "DATA_INS", "UTENTE_UPD", "DATA_UPD", "VERSION", "CODICE", "ACRONIMO") AS 
  SELECT ID_TIPO_DOCUMENTO,
          ID_ENTE,
          DESCRIZIONE,
          COMMENTO,
          CONSERVAZIONE_SOSTITUTIVA,
          PROGRESSIVO_CFG_ITER,
          TESTO_OBBLIGATORIO,
          ID_TIPOLOGIA_SOGGETTO,
          VALIDO,
          UTENTE_INS,
          DATA_INS,
          UTENTE_UPD,
          DATA_UPD,
          VERSION,
          CODICE,
          ACRONIMO
     FROM GDO_TIPI_DOCUMENTO
   UNION
   SELECT -TIAL.id_documento ID_TIPO_DOCUMENTO,
          enti.id_ente ID_ENTE,
          TIAL.DESCRIZIONE_TIPO_ALLEGATO DESCRIZIONE,
          NULL COMMENTO,
          CAST ('Y' AS CHAR (1)) CONSERVAZIONE_SOSTITUTIVA,
          CAST (NULL AS NUMBER) PROGRESSIVO_CFG_ITER,
          CAST ('N' AS CHAR (1)) TESTO_OBBLIGATORIO,
          CAST (NULL AS NUMBER) ID_TIPOLOGIA_SOGGETTO,
          CAST (
             DECODE (NVL (docu.stato_documento, 'BO'), 'CA', 'N', 'Y') AS CHAR (1))
             VALIDO,
          '' UTENTE_INS,
          NULL DATA_INS,
          docu.utente_aggiornamento UTENTE_UPD,
          docu.data_aggiornamento DATA_UPD,
          0 VERSION,
          'ALLEGATO' CODICE,
          TIPO_ALLEGATO ACRONIMO
     FROM GDM_SEG_TIPI_ALLEGATO TIAL, gdm_documenti docu, GDO_ENTI ENTI
    WHERE     docu.id_documento = TIAL.id_documento
          AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
          AND ENTI.AMMINISTRAZIONE = TIAL.CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = TIAL.CODICE_AOO
          AND ENTI.OTTICA = GDM_AG_PARAMETRO.GET_VALORE (
                               'SO_OTTICA_PROT',
                               TIAL.CODICE_AMMINISTRAZIONE,
                               TIAL.CODICE_AOO,
                               '')
/
