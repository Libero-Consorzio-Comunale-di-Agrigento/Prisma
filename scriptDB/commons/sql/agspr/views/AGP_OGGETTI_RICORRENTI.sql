--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_OGGETTI_RICORRENTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_OGGETTI_RICORRENTI" ("ID_OGGETTO_RICORRENTE", "CODICE", "OGGETTO", "ID_ENTE", "UTENTE_INS", "DATA_INS", "UTENTE_UPD", "DATA_UPD", "VALIDO", "VERSION", "ID_DOCUMENTO_ESTERNO") AS 
  SELECT -ts.id_documento ID_OGGETTO_RICORRENTE,
       tipo_frase codice,
       OGGETTO,
       ENTI.ID_ENTE,
       dati_creazione.utente_aggiornamento UTENTE_INS,
       dati_creazione.data_aggiornamento DATA_INS,
       d.utente_aggiornamento UTENTE_UPD,
       d.data_aggiornamento DATA_UPD,
       CAST (DECODE (d.stato_documento, 'BO', 'Y', 'N') AS CHAR (1)) valido,
       0 VERSION,
       ts.id_documento id_documento_esterno
  FROM gdm_SEG_TIPI_FRASE ts,
       gdm_documenti d,
       GDO_ENTI ENTI,
       (SELECT ID_DOCUMENTO, DATA_AGGIORNAMENTO, utente_aggiornamento
          FROM gdm_STATI_DOCUMENTO sd1
         WHERE NOT EXISTS
                  (SELECT 1
                     FROM gdm_STATI_DOCUMENTO sd2
                    WHERE     sd1.id_documento = sd2.id_documento
                          AND sd2.data_aggiornamento < sd1.data_aggiornamento))
       dati_creazione
 WHERE     d.id_documento = ts.id_documento
       AND dati_creazione.id_documento = ts.id_documento
       AND ENTI.AMMINISTRAZIONE = ts.CODICE_AMMINISTRAZIONE
       AND ENTI.AOO = ts.CODICE_AOO
       AND ENTI.OTTICA = GDM_AG_PARAMETRO.GET_VALORE (
                            'SO_OTTICA_PROT',
                            ts.CODICE_AMMINISTRAZIONE,
                            ts.CODICE_AOO,
                            '')
/
