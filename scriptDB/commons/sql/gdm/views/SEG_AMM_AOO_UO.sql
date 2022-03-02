--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_SEG_AMM_AOO_UO runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SEG_AMM_AOO_UO" ("DENOMINAZIONE", "EMAIL", "FAX", "MAILFAX", "PARTITA_IVA", "CF", "PI", "INDIRIZZO", "DENOMINAZIONE_PER_SEGNATURA", "COGNOME_PER_SEGNATURA", "NOME_PER_SEGNATURA", "INDIRIZZO_PER_SEGNATURA", "COMUNE_PER_SEGNATURA", "CAP_PER_SEGNATURA", "PROVINCIA_PER_SEGNATURA", "CF_PER_SEGNATURA", "DAL", "AL", "NI_PERSONA", "DAL_PERSONA", "NI", "COGNOME", "NOME", "INDIRIZZO_RES", "CAP_RES", "COMUNE_RES", "PROVINCIA_RES", "CODICE_FISCALE", "INDIRIZZO_DOM", "COMUNE_DOM", "CAP_DOM", "PROVINCIA_DOM", "MAIL_PERSONA", "TEL_RES", "FAX_RES", "SESSO", "COMUNE_NASCITA", "DATA_NASCITA", "TEL_DOM", "FAX_DOM", "CF_NULLABLE", "AMMIN", "DESCRIZIONE_AMM", "AOO", "DESCRIZIONE_AOO", "DESCRIZIONE_UO", "COD_AMM", "COD_AMM_ORIGINALE", "COD_AOO", "COD_AOO_ORIGINALE", "COD_UO", "COD_UO_ORIGINALE", "DATI_AMM", "DATI_AOO", "DATI_UO", "NI_AMM", "DAL_AMM", "TIPO", "INDIRIZZO_AMM", "CAP_AMM", "COMUNE_AMM", "SIGLA_PROV_AMM", "MAIL_AMM", "FAX_AMM", "INDIRIZZO_AOO", "CAP_AOO", "COMUNE_AOO", "SIGLA_PROV_AOO", "MAIL_AOO", "FAX_AOO", "INDIRIZZO_UO", "CAP_UO", "COMUNE_UO", "SIGLA_PROV_UO", "MAIL_UO", "TEL_UO", "FAX_UO", "CF_BENEFICIARIO", "DENOMINAZIONE_BENEFICIARIO", "PI_BENEFICIARIO", "COMUNE_BENEFICIARIO", "INDIRIZZO_BENEFICIARIO", "CAP_BENEFICIARIO", "DATA_NASCITA_BENEFICIARIO", "PROVINCIA_BENEFICIARIO", "VIS_INDIRIZZO", "MAIL_BENEFICIARIO", "FAX_BENEFICIARIO", "NI_IMPRESA", "IMPRESA", "DENOMINAZIONE_SEDE", "NATURA_GIURIDICA", "INSEGNA", "C_FISCALE_IMPRESA", "PARTITA_IVA_IMPRESA", "TIPO_LOCALIZZAZIONE", "COMUNE", "C_VIA_IMPRESA", "VIA_IMPRESA", "N_CIVICO_IMPRESA", "COMUNE_IMPRESA", "CAP_IMPRESA", "MAIL_IMPRESA", "NI_GSD", "ANAGRAFICA", "TIPO_SOGGETTO") AS 
  SELECT DECODE (
          tipo,
          'AMM', descrizione_amm,
          'AOO', TRIM (descrizione_amm) || ':AOO:' || TRIM (descrizione_aoo),
          TRIM (descrizione_amm) || ':UO:' || TRIM (descrizione_uo))
          denominazione,
       DECODE (
          tipo,
          'AMM', DECODE (mail_amm,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         mail_amm),
          'AOO', DECODE (mail_aoo,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         mail_aoo),
          DECODE (mail_uo, NULL, CAST (NULL AS VARCHAR2 (1)), mail_uo))
          email,
       DECODE (
          tipo,
          'AMM', DECODE (fax_amm, NULL, CAST (NULL AS VARCHAR2 (1)), fax_amm),
          'AOO', DECODE (fax_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), fax_aoo),
          DECODE (fax_uo, NULL, CAST (NULL AS VARCHAR2 (1)), fax_uo))
          fax,
       DECODE (
          tipo,
          'AMM', CAST (NULL AS VARCHAR2 (1)),
          'AOO', DECODE (mailfax_aoo,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         mailfax_aoo),
          DECODE (mailfax_uo, NULL, CAST (NULL AS VARCHAR2 (1)), mailfax_uo))
          mailfax,
       CAST (NULL AS VARCHAR2 (1)) partita_iva,
       CAST (NULL AS VARCHAR2 (1)) cf,
       CAST (NULL AS VARCHAR2 (1)) pi,
          DECODE (
             DECODE (tipo,
                     'AMM', indirizzo_amm,
                     'AOO', indirizzo_aoo,
                     indirizzo_uo),
             NULL, CAST (NULL AS VARCHAR2 (1)),
                DECODE (
                   tipo,
                   'AMM', DECODE (indirizzo_amm,
                                  NULL, CAST (NULL AS VARCHAR2 (1)),
                                  indirizzo_amm),
                   'AOO', DECODE (indirizzo_aoo,
                                  NULL, CAST (NULL AS VARCHAR2 (1)),
                                  indirizzo_aoo),
                   DECODE (indirizzo_uo,
                           NULL, CAST (NULL AS VARCHAR2 (1)),
                           indirizzo_uo))
             || ' ')
       || DECODE (
             DECODE (tipo,  'AMM', cap_amm,  'AOO', cap_aoo,  cap_uo),
             NULL, CAST (NULL AS VARCHAR2 (1)),
                LPAD (
                   TRIM (
                      DECODE (
                         tipo,
                         'AMM', DECODE (cap_amm,
                                        NULL, CAST (NULL AS VARCHAR2 (1)),
                                        cap_amm),
                         'AOO', DECODE (cap_aoo,
                                        NULL, CAST (NULL AS VARCHAR2 (1)),
                                        cap_aoo),
                         DECODE (cap_uo,
                                 NULL, CAST (NULL AS VARCHAR2 (1)),
                                 cap_uo))),
                   5,
                   '0')
             || ' ')
       || DECODE (
             DECODE (tipo,
                     'AMM', comune_amm,
                     'AOO', comune_aoo,
                     comune_uo),
             NULL, CAST (NULL AS VARCHAR2 (1)),
                DECODE (
                   tipo,
                   'AMM', DECODE (comune_amm,
                                  NULL, CAST (NULL AS VARCHAR2 (1)),
                                  comune_amm),
                   'AOO', DECODE (comune_aoo,
                                  NULL, CAST (NULL AS VARCHAR2 (1)),
                                  comune_aoo),
                   DECODE (comune_uo,
                           NULL, CAST (NULL AS VARCHAR2 (1)),
                           comune_uo))
             || ' ')
       || DECODE (
             DECODE (tipo,  'AMM', sigla_amm,  'AOO', sigla_aoo,  sigla_uo),
             NULL, CAST (NULL AS VARCHAR2 (1)),
                '('
             || DECODE (
                   tipo,
                   'AMM', DECODE (sigla_amm,
                                  NULL, CAST (NULL AS VARCHAR2 (1)),
                                  sigla_amm),
                   'AOO', DECODE (sigla_aoo,
                                  NULL, CAST (NULL AS VARCHAR2 (1)),
                                  sigla_aoo),
                   DECODE (sigla_uo,
                           NULL, CAST (NULL AS VARCHAR2 (1)),
                           sigla_uo))
             || ')')
          indirizzo,
       CTX_NULL denominazione_per_segnatura,
       DECODE (tipo,
               'AMM', descrizione_amm,
               'AOO', descrizione_aoo,
               descrizione_uo)
          cognome_per_segnatura,
       CAST (NULL AS VARCHAR2 (1)) nome_per_segnatura,
       DECODE (
          tipo,
          'AMM', DECODE (indirizzo_amm,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         indirizzo_amm),
          'AOO', DECODE (indirizzo_aoo,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         indirizzo_aoo),
          DECODE (indirizzo_uo,
                  NULL, CAST (NULL AS VARCHAR2 (1)),
                  indirizzo_uo))
          indirizzo_per_segnatura,
       DECODE (
          tipo,
          'AMM', DECODE (comune_amm,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         comune_amm),
          'AOO', DECODE (comune_aoo,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         comune_aoo),
          DECODE (comune_uo, NULL, CAST (NULL AS VARCHAR2 (1)), comune_uo))
          comune_per_segnatura,
       DECODE (
          tipo,
          'AMM', DECODE (cap_amm, NULL, CAST (NULL AS VARCHAR2 (1)), cap_amm),
          'AOO', DECODE (cap_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), cap_aoo),
          DECODE (cap_uo, NULL, CAST (NULL AS VARCHAR2 (1)), cap_uo))
          cap_per_segnatura,
       DECODE (
          tipo,
          'AMM', DECODE (sigla_amm,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         sigla_amm),
          'AOO', DECODE (sigla_aoo,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         sigla_aoo),
          DECODE (sigla_uo, NULL, CAST (NULL AS VARCHAR2 (1)), sigla_uo))
          provincia_per_segnatura,
       CAST (NULL AS VARCHAR2 (1)) cf_per_segnatura,
       dal,
       CAST (NULL AS DATE) al,
       CAST (NULL AS NUMBER (1)) ni_persona,
       CAST (NULL AS VARCHAR2 (1)) dal_persona,
       CAST (NULL AS VARCHAR2 (1)) ni,
       CAST (NULL AS VARCHAR2 (1)) cognome,
       CAST (NULL AS VARCHAR2 (1)) nome,
       CAST (NULL AS VARCHAR2 (1)) indirizzo_res,
       CAST (NULL AS VARCHAR2 (1)) cap_res,
       CAST (NULL AS VARCHAR2 (1)) comune_res,
       CAST (NULL AS VARCHAR2 (1)) provincia_res,
       CAST (NULL AS VARCHAR2 (1)) codice_fiscale,
       CAST (NULL AS VARCHAR2 (1)) indirizzo_dom,
       CAST (NULL AS VARCHAR2 (1)) comune_dom,
       CAST (NULL AS VARCHAR2 (1)) cap_dom,
       CAST (NULL AS VARCHAR2 (1)) provincia_dom,
       CAST (NULL AS VARCHAR2 (1)) mail_persona,
       CAST (NULL AS VARCHAR2 (1)) tel_res,
       CAST (NULL AS VARCHAR2 (1)) fax_res,
       CAST (NULL AS VARCHAR2 (1)) sesso,
       CAST (NULL AS VARCHAR2 (1)) comune_nascita,
       CAST (NULL AS VARCHAR2 (1)) data_nascita,
       CAST (NULL AS VARCHAR2 (1)) tel_dom,
       CAST (NULL AS VARCHAR2 (1)) fax_dom,
       CAST (NULL AS VARCHAR2 (1)) cf_nullable,
       descrizione_amm ammin,
       descrizione_amm,
       descrizione_aoo aoo,
       descrizione_aoo,
       descrizione_uo,
       codice_amministrazione cod_amm,
       codice_amm_originale cod_amm_originale,
       DECODE (codice_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), codice_aoo)
          cod_aoo,
       DECODE (codice_aoo_originale,
               NULL, CAST (NULL AS VARCHAR2 (1)),
               codice_aoo_originale)
          cod_aoo_originale,
       DECODE (codice_uo, NULL, CAST (NULL AS VARCHAR2 (1)), codice_uo)
          cod_uo,
       DECODE (codice_uo_originale,
               NULL, CAST (NULL AS VARCHAR2 (1)),
               codice_uo_originale)
          cod_uo_originale,
       descrizione_amm dati_amm,
       DECODE (
          tipo,
          'AOO', DECODE (descrizione_aoo,
                         NULL, CAST (NULL AS VARCHAR2 (1)),
                         descrizione_aoo),
          CAST (NULL AS
VARCHAR2 (1)))
          dati_aoo,
       DECODE (
          tipo,
          'UO', DECODE (descrizione_uo,
                        NULL, CAST (NULL AS VARCHAR2 (1)),
                        descrizione_uo),
          CAST (NULL AS VARCHAR2 (1)))
          dati_uo,
       ni ni_amm,
       TO_CHAR (dal, 'dd/mm/yyyy') dal_amm,
       tipo,
       DECODE (indirizzo_amm,
               NULL, CAST (NULL AS VARCHAR2 (1)),
               indirizzo_amm)
          indirizzo_amm,
       DECODE (cap_amm, NULL, CAST (NULL AS VARCHAR2 (1)), cap_amm) cap_amm,
       DECODE (comune_amm, NULL, CAST (NULL AS VARCHAR2 (1)), comune_amm)
          comune_amm,
       DECODE (sigla_amm, NULL, CAST (NULL AS VARCHAR2 (1)), sigla_amm)
          sigla_prov_amm,
       DECODE (mail_amm, NULL, CAST (NULL AS VARCHAR2 (1)), mail_amm)
          mail_amm,
       DECODE (fax_amm, NULL, CAST (NULL AS VARCHAR2 (1)), fax_amm) fax_amm,
       DECODE (indirizzo_aoo,
               NULL, CAST (NULL AS VARCHAR2 (1)),
               indirizzo_aoo)
          indirizzo_aoo,
       DECODE (cap_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), cap_aoo) cap_aoo,
       DECODE (comune_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), comune_aoo)
          comune_aoo,
       DECODE (sigla_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), sigla_aoo)
          sigla_prov_aoo,
       DECODE (mail_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), mail_aoo)
          mail_aoo,
       DECODE (fax_aoo, NULL, CAST (NULL AS VARCHAR2 (1)), fax_aoo) fax_aoo,
       DECODE (indirizzo_uo, NULL, CAST (NULL AS VARCHAR2 (1)), indirizzo_uo)
          indirizzo_uo,
       DECODE (cap_uo, NULL, CAST (NULL AS VARCHAR2 (1)), cap_uo) cap_uo,
       DECODE (comune_uo, NULL, CAST (NULL AS VARCHAR2 (1)), comune_uo)
          comune_uo,
       DECODE (sigla_uo, NULL, CAST (NULL AS VARCHAR2 (1)), sigla_uo)
          sigla_prov_uo,
       DECODE (mail_uo, NULL, CAST (NULL AS VARCHAR2 (1)), mail_uo) mail_uo,
       DECODE (tel_uo, NULL, CAST (NULL AS VARCHAR2 (1)), tel_uo) tel_uo,
       DECODE (fax_uo, NULL, CAST (NULL AS VARCHAR2 (1)), fax_uo) fax_uo,
       CAST (NULL AS VARCHAR2 (1)) cf_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) denominazione_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) pi_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) comune_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) indirizzo_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) cap_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) data_nascita_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) provincia_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) vis_indirizzo,
       CAST (NULL AS VARCHAR2 (1)) mail_beneficiario,
       CAST (NULL AS VARCHAR2 (1)) fax_beneficiario,
       CAST (NULL AS NUMBER) ni_impresa,
       CAST (NULL AS VARCHAR2 (1)) impresa,
       CAST (NULL AS VARCHAR2 (1)) denominazione_sede,
       CAST (NULL AS VARCHAR2 (1)) natura_giuridica,
       CAST (NULL AS VARCHAR2 (1)) insegna,
       CAST (NULL AS VARCHAR2 (1)) c_fiscale_impresa,
       CAST (NULL AS VARCHAR2 (1)) partita_iva_impresa,
       CAST (NULL AS VARCHAR2 (1)) tipo_localizzazione,
       CAST (NULL AS VARCHAR2 (1)) comune,
       CAST (NULL AS VARCHAR2 (1)) c_via_impresa,
       CAST (NULL AS VARCHAR2 (1)) via_impresa,
       CAST (NULL AS VARCHAR2 (1)) n_civico_impresa,
       CAST (NULL AS VARCHAR2 (1)) comune_impresa,
       CAST (NULL AS VARCHAR2 (1)) cap_impresa,
       CAST (NULL AS VARCHAR2 (1)) mail_impresa,
       CAST (NULL AS NUMBER) ni_gsd,
       anagrafica,
       2 tipo_soggetto
  FROM amm_aoo_valide_view, CTX_DUAL
/
