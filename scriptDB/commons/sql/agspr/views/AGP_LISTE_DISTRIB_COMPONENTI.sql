--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_LISTE_DISTRIB_COMPONENTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGP_LISTE_DISTRIB_COMPONENTI" ("ID_DOCUMENTO_ESTERNO", "ID_COMPONENTE", "ID_LISTA", "CODICE_LISTA", "COD_AMM", "COD_AOO", "COD_UO", "NI", "ID_ANAGRAFICA", "ID_RECAPITO", "ID_CONTATTO", "CAP", "CODICE_FISCALE", "DENOMINAZIONE", "COGNOME", "NOME", "COMUNE", "EMAIL", "FAX", "INDIRIZZO", "PARTITA_IVA", "PROVINCIA_SIGLA", "ID_ENTE", "UTENTE_INS", "DATA_INS", "VALIDO", "UTENTE_UPD", "DATA_UPD", "VERSION") AS 
  SELECT TS.ID_DOCUMENTO ID_DOCUMENTO_ESTERNO,
          -TS.ID_DOCUMENTO id_componente,
          -LIDI.ID_DOCUMENTO ID_LISTA,
          TS.CODICE_LISTA_DISTRIBUZIONE CODICE_LISTA,
          TS.COD_AMM,
          TS.COD_AOO,
          TS.COD_UO,
          TS.NI,
          TS.ID_ANAGRAFICA,
          TS.ID_RECAPITO_AS4,
          TS.ID_CONTATTO_AS4,
          TS.CAP_PER_SEGNATURA,
          CF_PER_SEGNATURA,
          DENOMINAZIONE_SOGGETTI DENOMINAZIONE,
          COGNOME_PER_SEGNATURA COGNOME,
          NOME_PER_SEGNATURA NOME,
          COMUNE_PER_SEGNATURA,
          EMAIL,
          FAX,
          INDIRIZZO_PER_SEGNATURA,
          PARTITA_IVA,
          PROVINCIA_PER_SEGNATURA,
          ENTI.ID_ENTE,
          d.utente_aggiornamento UTENTE_INS,
          d.data_aggiornamento DATA_INS,
          CAST (
             DECODE (NVL (d.stato_documento, 'BO'), 'CA', 'N', 'Y') AS CHAR (1))
             valido,
          d.utente_aggiornamento UTENTE_UPD,
          d.data_aggiornamento DATA_UPD,
          0 VERSION
     FROM gdm_SEG_COMPONENTI_LISTA TS,
          gdm_SEG_LISTE_DISTRIBUZIONE LIDI,
          gdm_documenti d_LIDI,
          gdm_documenti d,
          GDO_ENTI ENTI
    WHERE     d.id_documento = ts.id_documento
          AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
          AND d_LIDI.id_documento = LIDI.id_documento
          AND LIDI.CODICE_LISTA_DISTRIBUZIONE = TS.CODICE_LISTA_DISTRIBUZIONE
          AND ENTI.AMMINISTRAZIONE = LIDI.CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = LIDI.CODICE_AOO
          AND ENTI.AMMINISTRAZIONE = ts.CODICE_AMMINISTRAZIONE
          AND ENTI.AOO = ts.CODICE_AOO
          AND ENTI.OTTICA = GDM_AG_PARAMETRO.GET_VALORE (
                               'SO_OTTICA_PROT',
                               ts.CODICE_AMMINISTRAZIONE,
                               ts.CODICE_AOO,
                               '')

/
