--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_SEG_ANAGRAFICI_ALTRI runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW SEG_ANAGRAFICI_ALTRI
(DENOMINAZIONE, COGNOME, NOME, CODICE_FISCALE, PARTITA_IVA,
 INDIRIZZO, INDIRIZZO_COMPLETO, CAP, COMUNE, PROVINCIA_SIGLA,
 EMAIL, FAX, TIPO_SOGGETTO, ANAGRAFICA, COD_AMM,
 COD_AOO, COD_UO, NI, DAL, AL,
 TIPO_INDIRIZZO, ID_RECAPITO, ID_CONTATTO, CF_ESTERO, ID_TIPO_RECAPITO,
 TIPO_SPEDIZIONE)
AS
SELECT DENOMINAZIONE DENOMINAZIONE,
       COGNOME_PER_SEGNATURA COGNOME,
       NOME_PER_SEGNATURA NOME,
       CF_PER_SEGNATURA CODICE_FISCALE,
       PI PARTITA_IVA,
       INDIRIZZO_PER_SEGNATURA INDIRIZZO,
       indirizzo INDIRIZZO_COMPLETO,
       CAP_PER_SEGNATURA CAP,
       COMUNE_PER_SEGNATURA COMUNE,
       PROVINCIA_PER_SEGNATURA PROVINCIA_SIGLA,
       EMAIL,
       FAX,
       TIPO_SOGGETTO,
       DECODE (anagrafica,
               'B', 'Beneficiario',
               'D', 'Dipendente',
               'G', 'Anagrafe',
               'I', 'Impresa',
               'T', 'CittadinoRT')
          ANAGRAFICA,
       COD_AMM,
       COD_AOO,
       COD_UO,
       DECODE (anagrafica, 'T', TO_NUMBER (ni), ni_gsd) NI,
       DAL,
       AL,
       DECODE (tipo_localizzazione, NULL, 'RESIDENZA', tipo_localizzazione)
          TIPO_INDIRIZZO,
       TO_NUMBER (NULL),
       TO_NUMBER (NULL),
       cf_estero,
       TO_NUMBER (NULL),
       CAST (TO_NUMBER (NULL) AS VARCHAR2 (1))
  FROM SEG_soggetti_mv
/
