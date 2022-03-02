--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_BOTTONI_NOTIFICHE runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_BOTTONI_NOTIFICHE" ("ID", "TIPO", "STATO", "AZIONE", "LABEL", "TOOLTIP", "ICONA", "ICONA_SHORT", "MODELLO", "TIPO_AZIONE", "AZIONE_MULTIPLA", "MODELLO_AZIONE", "ASSEGNAZIONE", "TIPO_SMISTAMENTO", "VERSION", "UTENTE_INS", "UTENTE_UPD", "DATA_INS", "DATA_UPD", "VALIDO_DAL", "VALIDO_AL", "VALIDO", "ID_ENTE", "SEQUENZA", "URL_AZIONE") AS 
  SELECT -id,
          TIPO,
          STATO,
          AZIONE,
          LABEL,
          TOOLTIP,
          ICONA,
          ICONA_SHORT,
          MODELLO,
          TIPO_AZIONE,
          AZIONE_MULTIPLA,
          MODELLO_AZIONE,
          ASSEGNAZIONE,
          TIPO_SMISTAMENTO,
          gdm_seg_bottoni_notifiche.version,
          UTENTE_INS,
          UTENTE_UPD,
          DATA_INS,
          DATA_UPD,
          VALIDO_DAL,
          VALIDO_AL,
          CAST (DECODE (VALIDO_AL, NULL, 'Y', 'N') AS CHAR (1)) valido,
          enti.ID_ENTE,
          gdm_seg_bottoni_notifiche.sequenza,
          URL_AZIONE
     FROM gdm_seg_bottoni_notifiche, GDO_ENTI ENTI
    WHERE     ENTI.AMMINISTRAZIONE = CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = CODICE_AOO
/
