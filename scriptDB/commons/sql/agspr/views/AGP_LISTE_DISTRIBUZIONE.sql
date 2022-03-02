--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_LISTE_DISTRIBUZIONE runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_LISTE_DISTRIBUZIONE" ("ID_DOCUMENTO_ESTERNO", "ID_LISTA", "CODICE", "DESCRIZIONE", "ID_ENTE", "UTENTE_INS", "DATA_INS", "VALIDO", "UTENTE_UPD", "DATA_UPD", "VERSION") AS 
  SELECT TS.ID_DOCUMENTO ID_DOCUMENTO_ESTERNO,
          -TS.ID_DOCUMENTO id_lista,
          CODICE_LISTA_DISTRIBUZIONE CODICE,
          DES_LISTA_DISTRIBUZIONE DESCRIZIONE,
          ENTI.ID_ENTE,
          d.utente_aggiornamento UTENTE_INS,
          d.data_aggiornamento DATA_INS,
          CAST (
             DECODE (NVL (d.stato_documento, 'BO'), 'CA', 'N', 'Y') AS CHAR (1))
             valido,
          d.utente_aggiornamento UTENTE_UPD,
          d.data_aggiornamento DATA_UPD,
          0 VERSION
     FROM gdm_SEG_LISTE_DISTRIBUZIONE TS, gdm_documenti d, GDO_ENTI ENTI
    WHERE     d.id_documento = ts.id_documento
          AND ENTI.AMMINISTRAZIONE = ts.CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = ts.CODICE_AOO
          AND ENTI.OTTICA = GDM_AG_PARAMETRO.GET_VALORE (
                               'SO_OTTICA_PROT',
                               ts.CODICE_AMMINISTRAZIONE,
                               ts.CODICE_AOO,
                               '')

/
