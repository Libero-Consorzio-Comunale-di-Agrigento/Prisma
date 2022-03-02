--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_122.gdo_tipi_allegato_ins
alter table gdo_tipi_documento disable all triggers
/

alter table GDO_TIPI_ALLEGATO disable all triggers
/

INSERT INTO gdo_tipi_documento (ID_TIPO_DOCUMENTO,
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
                                ACRONIMO)
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
          'RPI' UTENTE_INS,
          SYSDATE DATA_INS,
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
          AND NOT EXISTS
                 (SELECT 1
                    FROM gdo_tipi_documento
                   WHERE gdo_tipi_documento.ID_TIPO_DOCUMENTO =
                            -TIAL.id_documento)
/

INSERT INTO GDO_TIPI_ALLEGATO (ID_TIPO_DOCUMENTO, STAMPA_UNICA)
   SELECT ID_TIPO_DOCUMENTO, 'N'
     FROM GDO_TIPI_DOCUMENTO
    WHERE     CODICE = 'ALLEGATO'
          AND NOT EXISTS
                 (SELECT DISTINCT 1
                    FROM GDO_TIPI_ALLEGATO
                   WHERE ID_TIPO_DOCUMENTO =
                            GDO_TIPI_DOCUMENTO.ID_TIPO_DOCUMENTO)
/

alter table gdo_tipi_documento enable all triggers
/

alter table GDO_TIPI_ALLEGATO enable all triggers
/
