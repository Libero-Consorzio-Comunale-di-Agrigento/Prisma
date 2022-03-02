--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_L190_REGISTRO_ACCESSI_VIEW runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "L190_REGISTRO_ACCESSI_VIEW" ("VERSION", "ANNO_DOMANDA", "NUMERO_DOMANDA", "TIPO_REGISTRO_DOMANDA", "DATA_PROTOCOLLO_DOMANDA", "TIPO_ACCESSO", "TIPO_RICHIEDENTE", "OGGETTO", "DATA_DOMANDA", "UFFICIO", "CONTROINTERESSATI", "ESITO", "DATA_PROVVEDIMENTO", "MOTIVO_RIFIUTO", "ANNO_RISPOSTA", "NUMERO_RISPOSTA", "TIPO_REGISTRO_RISPOSTA", "DATA_PROTOCOLLO_RISPOSTA") AS 
  SELECT 0,
          prot_doma.anno anno_domanda,
          prot_doma.numero numero_domanda,
          prot_doma.tipo_registro tipo_registro_domanda,
          prot_doma.data data_protocollo_domanda,
          taci.descrizione tipo_accesso,
          trac.descrizione tipo_richiedente,
          daac.oggetto oggetto,
          data_presentazione data_domanda,
          uopu.descrizione ufficio,
          CAST (DECODE (prot_risp.annullato, 'Y', 'N', controinteressati) AS CHAR (1))     
             controinteressati,
          DECODE (prot_risp.annullato,
                  'Y', NULL,
                  DECODE (pubblica, 'Y', teac.descrizione, NULL))
             esito,
          CAST (DECODE (prot_risp.annullato,
                  'Y', NULL,
                  DECODE (pubblica, 'Y', data_provvedimento, NULL)) as DATE)
             data_provvedimento,
          DECODE (prot_risp.annullato,
                  'Y', NULL,
                  DECODE (pubblica, 'Y', motivo_rifiuto, NULL))
             motivo_rifiuto,
          CAST (DECODE (prot_risp.annullato,
                  'Y', NULL,
                  DECODE (pubblica, 'Y', prot_risp.anno, NULL)) as NUMBER)
             anno_risposta,
          CAST (DECODE (prot_risp.annullato,
                  'Y', NULL,
                  DECODE (pubblica, 'Y', prot_risp.numero, NULL)) as NUMBER)
             numero_risposta,
          DECODE (prot_risp.annullato,
                  'Y', NULL,
                  DECODE (pubblica, 'Y', prot_risp.tipo_registro, NULL))
             tipo_registro_risposta,
          CAST (DECODE (prot_risp.annullato,
                  'Y', NULL,
                  DECODE (pubblica, 'Y', prot_risp.data, NULL)) as DATE)
             data_protocollo_risposta
     FROM agp_protocolli_dati_accesso daac,
          agp_protocolli prot_doma,
          agp_protocolli prot_risp,
          agp_tipi_accesso_civico taci,
          agp_tipi_esito_accesso teac,
          agp_tipi_richiedente_accesso trac,
          so4_v_unita_organizzative_pubb uopu
    WHERE     prot_doma.id_documento = daac.id_protocollo_domanda
          AND prot_doma.annullato = 'N'
          AND prot_risp.id_documento(+) = daac.id_protocollo_risposta
          AND (   (    pubblica = 'Y'
                   AND prot_risp.anno IS NOT NULL
                   AND prot_risp.numero IS NOT NULL
                   AND prot_risp.tipo_registro IS NOT NULL)
               OR (    pubblica_domanda = 'Y'
                   AND prot_doma.anno IS NOT NULL
                   AND prot_doma.numero IS NOT NULL
                   AND prot_doma.tipo_registro IS NOT NULL))
          AND taci.id_tipo_accesso_civico(+) = daac.id_tipo_accesso_civico
          AND teac.id_tipo_esito(+) = daac.id_tipo_esito
          AND trac.id_tipo_richiedente_accesso(+) =
                 daac.id_tipo_richiedente_accesso
          AND uopu.ottica(+) = unita_competente_ottica
          AND uopu.progr(+) = unita_competente_progr
          AND uopu.dal(+) = unita_competente_dal
/
