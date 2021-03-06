--liquibase formatted sql
--changeset rdestasio:install_20200221_10

CREATE OR REPLACE FORCE VIEW SO4_V_INDIRIZZI_TELEMATICI
(
   OTTICA_UO,
   UTENTE_AGGIORNAMENTO,
   UTENTE,
   TIPO_INDIRIZZO,
   TIPO_ENTITA,
   TAG_MAIL,
   SSL,
   SERVER,
   PROTOCOL,
   PORT,
   PASSWORD,
   NOTE,
   INDIRIZZO,
   PROGR_UO,
   DAL_UO,
   ID_INDIRIZZO,
   PROGR_AOO,
   DAL_AOO,
   ID_AMMINISTRAZIONE,
   DAL_AMM,
   DATA_AGGIORNAMENTO,
   AUTHENTICATION,
   DES_TIPO_INDIRIZZO
)
AS
   SELECT TO_CHAR (NULL) ottica,
          ind.UTENTE_AGGIORNAMENTO,
          ind.UTENTE,
          ind.TIPO_INDIRIZZO,
          ind.TIPO_ENTITA,
          ind.TAG_MAIL,
          ind.SSL,
          ind.SERVER,
          ind.PROTOCOL,
          ind.PORT,
          ind.PASSWORD,
          ind.NOTE,
          ind.INDIRIZZO,
          ind.ID_UNITA_ORGANIZZATIVA,
          TO_DATE (NULL) dal_uo,
          ind.ID_INDIRIZZO,
          NULL,
          TO_DATE (NULL) dal_aoo,
          amm.CODICE_AMMINISTRAZIONE,
          ana.dal dal_amministrazione,
          ind.DATA_AGGIORNAMENTO,
          ind.AUTHENTICATION,
          DECODE (ind.tipo_indirizzo,
                  'I', 'Indirizzo Istituzionale',
                  'R', 'Risposta automatica',
                  'M', 'Protocollo manuale',
                  'G', 'Generico',
                  'C', 'Contatto',
                  'P', 'Contatto PEC',
                  'Altro')
     FROM SO4_INDIRIZZI_TELEMATICI ind,
          as4_anagrafe_soggetti ana,
          so4_amministrazioni amm
    WHERE ind.id_amministrazione = amm.ni AND ana.ni = amm.ni
   UNION
   -- aoo
   SELECT TO_CHAR (NULL) ottica,
          ind.UTENTE_AGGIORNAMENTO,
          ind.UTENTE,
          ind.TIPO_INDIRIZZO,
          ind.TIPO_ENTITA,
          ind.TAG_MAIL,
          ind.SSL,
          ind.SERVER,
          ind.PROTOCOL,
          ind.PORT,
          ind.PASSWORD,
          ind.NOTE,
          ind.INDIRIZZO,
          ind.ID_UNITA_ORGANIZZATIVA,
          TO_DATE (NULL) dal_uo,
          ind.ID_INDIRIZZO,
          ind.ID_AOO,
          aoo.dal dal_aoo,
          AOO.CODICE_AMMINISTRAZIONE,
          TO_DATE (NULL) dal_amministrazione,
          ind.DATA_AGGIORNAMENTO,
          ind.AUTHENTICATION,
          DECODE (ind.tipo_indirizzo,
                  'I', 'Indirizzo Istituzionale',
                  'R', 'Risposta automatica',
                  'M', 'Protocollo manuale',
                  'G', 'Generico',
                  'C', 'Contatto',
                  'P', 'Contatto PEC',
                  'Altro')
     FROM so4_indirizzi_telematici ind, so4_aoo_view aoo
    WHERE ind.id_aoo = aoo.ni
   UNION
   -- uo
   SELECT auo.ottica,
          ind.UTENTE_AGGIORNAMENTO,
          ind.UTENTE,
          ind.TIPO_INDIRIZZO,
          ind.TIPO_ENTITA,
          ind.TAG_MAIL,
          ind.SSL,
          ind.SERVER,
          ind.PROTOCOL,
          ind.PORT,
          ind.PASSWORD,
          ind.NOTE,
          ind.INDIRIZZO,
          ind.ID_UNITA_ORGANIZZATIVA,
          auo.dal dal_uo,
          ind.ID_INDIRIZZO,
          NULL,
          TO_DATE (NULL) dal_aoo,
          TO_CHAR (NULL) id_amministrazione,
          TO_DATE (NULL) dal_amministrazione,
          ind.DATA_AGGIORNAMENTO,
          ind.AUTHENTICATION,
          DECODE (ind.tipo_indirizzo,
                  'I', 'Indirizzo Istituzionale',
                  'R', 'Risposta automatica',
                  'M', 'Protocollo manuale',
                  'G', 'Generico',
                  'C', 'Contatto',
                  'P', 'Contatto PEC',
                  'Altro')
     FROM so4_indirizzi_telematici ind, SO4_VISTA_UNITA_ORG_PUBB auo
    WHERE ind.id_unita_organizzativa = auo.progr_unita_organizzativa
/
