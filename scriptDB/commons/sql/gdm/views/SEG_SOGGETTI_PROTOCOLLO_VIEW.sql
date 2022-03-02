--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_SEG_SOGGETTI_PROTOCOLLO_VIEW runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SEG_SOGGETTI_PROTOCOLLO_VIEW" ("ID_DOCUMENTO", "ANNO", "APRI_IN_STESSA_FINESTRA", "CAP_AMM", "CAP_AOO", "CAP_DOM", "CAP_DOM_DIPENDENTE", "CAP_IMPRESA", "CAP_IMPRESA_EXTRA", "CAP_PER_SEGNATURA", "CAP_RES", "CAP_RES_DIPENDENTE", "CFP_EXTRA", "CF_PER_SEGNATURA", "CODICE_AMMINISTRAZIONE", "CODICE_AOO", "CODICE_FISCALE", "CODICE_FISCALE_DIPENDENTE", "COD_AMM", "COD_AOO", "COD_UO", "COGNOME", "COGNOME_DIPENDENTE", "COGNOME_IMPRESA_EXTRA", "COGNOME_PER_SEGNATURA", "COMUNE_AMM", "COMUNE_AOO", "COMUNE_DOM", "COMUNE_DOM_DIPENDENTE", "COMUNE_IMPRESA", "COMUNE_IMPRESA_EXTRA", "COMUNE_NASCITA", "COMUNE_NASCITA_EXTRA", "COMUNE_PER_SEGNATURA", "COMUNE_RES", "COMUNE_RES_DIPENDENTE", "C_FISCALE_IMPRESA", "C_FISCALE_IMPRESA_EXTRA", "C_VIA_IMPRESA", "C_VIA_IMPRESA_EXTRA", "DAL", "DAL_AMM", "DAL_DIPENDENTE", "DAL_PERSONA", "DATA_NASCITA", "DATA_NASCITA_EXTRA", "DENOMINAZIONE_PER_SEGNATURA", "DENOMINAZIONE_SEDE", "DENOMINAZIONE_SEDE_EXTRA", "DESCRIZIONE_AMM", "DESCRIZIONE_AOO", "DESCRIZIONE_INCARICO", "DESCRIZIONE_UO", "DESC_TIPO_RAPPORTO", "EMAIL", "FAX_DOM", "FAX_RES", "IDRIF", "INDIRIZZO_AMM", "INDIRIZZO_AOO", "INDIRIZZO_DOM", "INDIRIZZO_DOM_DIPENDENTE", "INDIRIZZO_PER_SEGNATURA", "INDIRIZZO_RES", "INDIRIZZO_RES_DIPENDENTE", "INSEGNA", "INSEGNA_EXTRA", "MAIL_AMM", "MAIL_AOO", "MAIL_DIPENDENTE", "MAIL_PERSONA", "NATURA_GIURIDICA", "NATURA_GIURIDICA_EXTRA", "NI", "NI_AMM", "NI_DIPENDENTE", "NI_IMPRESA", "NI_IMPRESA_EXTRA", "NI_PERSONA", "NOME", "NOME_DIPENDENTE", "NOME_IMPRESA_EXTRA", "NOME_PER_SEGNATURA", "NOMINATIVO_COMPONENTE", "NUMERO", "N_CIVICO_IMPRESA", "N_CIVICO_IMPRESA_EXTRA", "PARENT_URL", "PARTITA_IVA_IMPRESA", "PARTITA_IVA_IMPRESA_EXTRA", "PROVINCIA_DOM", "PROVINCIA_DOM_DIPENDENTE", "PROVINCIA_PER_SEGNATURA", "PROVINCIA_RES", "PROVINCIA_RES_DIPENDENTE", "REGISTRATA_CONSEGNA", "REG_CONSEGNA_AGGIORNAMENTO", "REG_CONSEGNA_ANNULLAMENTO", "REG_CONSEGNA_CONFERMA", "RICEVUTA_CONFERMA", "RICEVUTA_ECCEZIONE", "RICEVUTO_AGGIORNAMENTO", "RICEVUTO_ANNULLAMENTO", "RIC_MANCATA_CONSEGNA", "RIC_MANCATA_CONSEGNA_AGG", "RIC_MANCATA_CONSEGNA_ANN", "RIC_MANCATA_CONSEGNA_CONF", "SESSO", "SIGLA_PROV_AMM", "SIGLA_PROV_AOO", "TEL_DOM", "TEL_RES", "TIPO", "TIPO_LOCALIZZAZIONE", "TIPO_LOCALIZZAZIONE_EXTRA", "TIPO_RAPPORTO", "TIPO_REGISTRO", "TIPO_SOGGETTO", "VIA_IMPRESA", "VIA_IMPRESA_EXTRA", "FULL_TEXT", "TXT", "PARTITA_IVA", "DESCRIZIONE", "DOCUMENTO_TRAMITE", "ID_LISTA_DISTRIBUZIONE", "MODALITA", "STATO_PR", "CF_NULLABLE", "RACCOMANDATA_NUMERO", "CF_BENEFICIARIO", "DATA_NASCITA_BENEFICIARIO", "DENOMINAZIONE_BENEFICIARIO", "PI_BENEFICIARIO", "CAP_BENEFICIARIO", "COMUNE_BENEFICIARIO", "INDIRIZZO_BENEFICIARIO", "PROVINCIA_BENEFICIARIO", "MAIL_IMPRESA", "CAP_UO", "COMUNE_UO", "FAX_UO", "INDIRIZZO_UO", "MAIL_UO", "SIGLA_PROV_UO", "TEL_UO", "DOCUMENTO_TRAMITE_FORM", "QUANTITA", "DATA_SPED", "DATA_RIC_AGGIORNAMENTO", "DATA_RIC_ANNULLAMENTO", "DATA_RIC_CONFERMA", "DATA_RIC_ECCEZIONE", "MAIL_BENEFICIARIO", "FAX", "FAX_AMM", "FAX_AOO", "FAX_BENEFICIARIO", "TXT_AMM", "CONOSCENZA", "BC_SPEDIZIONE", "AREA", "CODICE_RICHIESTA", "DATA_AGGIORNAMENTO", "UTENTE_AGGIORNAMENTO", "STATO_DOCUMENTO", "DENOMINAZIONE_VIS", "INDIRIZZO_VIS") AS 
  SELECT sogg."ID_DOCUMENTO",
          sogg."ANNO",
          sogg."APRI_IN_STESSA_FINESTRA",
          sogg."CAP_AMM",
          sogg."CAP_AOO",
          sogg."CAP_DOM",
          sogg."CAP_DOM_DIPENDENTE",
          sogg."CAP_IMPRESA",
          sogg."CAP_IMPRESA_EXTRA",
          sogg."CAP_PER_SEGNATURA",
          sogg."CAP_RES",
          sogg."CAP_RES_DIPENDENTE",
          sogg."CFP_EXTRA",
          sogg."CF_PER_SEGNATURA",
          sogg."CODICE_AMMINISTRAZIONE",
          sogg."CODICE_AOO",
          sogg."CODICE_FISCALE",
          sogg."CODICE_FISCALE_DIPENDENTE",
          sogg."COD_AMM",
          sogg."COD_AOO",
          sogg."COD_UO",
          sogg."COGNOME",
          sogg."COGNOME_DIPENDENTE",
          sogg."COGNOME_IMPRESA_EXTRA",
          sogg."COGNOME_PER_SEGNATURA",
          sogg."COMUNE_AMM",
          sogg."COMUNE_AOO",
          sogg."COMUNE_DOM",
          sogg."COMUNE_DOM_DIPENDENTE",
          sogg."COMUNE_IMPRESA",
          sogg."COMUNE_IMPRESA_EXTRA",
          sogg."COMUNE_NASCITA",
          sogg."COMUNE_NASCITA_EXTRA",
          sogg."COMUNE_PER_SEGNATURA",
          sogg."COMUNE_RES",
          sogg."COMUNE_RES_DIPENDENTE",
          sogg."C_FISCALE_IMPRESA",
          sogg."C_FISCALE_IMPRESA_EXTRA",
          sogg."C_VIA_IMPRESA",
          sogg."C_VIA_IMPRESA_EXTRA",
          sogg."DAL",
          sogg."DAL_AMM",
          sogg."DAL_DIPENDENTE",
          sogg."DAL_PERSONA",
          sogg."DATA_NASCITA",
          sogg."DATA_NASCITA_EXTRA",
          sogg."DENOMINAZIONE_PER_SEGNATURA",
          sogg."DENOMINAZIONE_SEDE",
          sogg."DENOMINAZIONE_SEDE_EXTRA",
          sogg."DESCRIZIONE_AMM",
          sogg."DESCRIZIONE_AOO",
          sogg."DESCRIZIONE_INCARICO",
          sogg."DESCRIZIONE_UO",
          sogg."DESC_TIPO_RAPPORTO",
          sogg."EMAIL",
          sogg."FAX_DOM",
          sogg."FAX_RES",
          sogg."IDRIF",
          sogg."INDIRIZZO_AMM",
          sogg."INDIRIZZO_AOO",
          sogg."INDIRIZZO_DOM",
          sogg."INDIRIZZO_DOM_DIPENDENTE",
          sogg."INDIRIZZO_PER_SEGNATURA",
          sogg."INDIRIZZO_RES",
          sogg."INDIRIZZO_RES_DIPENDENTE",
          sogg."INSEGNA",
          sogg."INSEGNA_EXTRA",
          sogg."MAIL_AMM",
          sogg."MAIL_AOO",
          sogg."MAIL_DIPENDENTE",
          sogg."MAIL_PERSONA",
          sogg."NATURA_GIURIDICA",
          sogg."NATURA_GIURIDICA_EXTRA",
          sogg."NI",
          sogg."NI_AMM",
          sogg."NI_DIPENDENTE",
          sogg."NI_IMPRESA",
          sogg."NI_IMPRESA_EXTRA",
          sogg."NI_PERSONA",
          sogg."NOME",
          sogg."NOME_DIPENDENTE",
          sogg."NOME_IMPRESA_EXTRA",
          sogg."NOME_PER_SEGNATURA",
          sogg."NOMINATIVO_COMPONENTE",
          sogg."NUMERO",
          sogg."N_CIVICO_IMPRESA",
          sogg."N_CIVICO_IMPRESA_EXTRA",
          sogg."PARENT_URL",
          sogg."PARTITA_IVA_IMPRESA",
          sogg."PARTITA_IVA_IMPRESA_EXTRA",
          sogg."PROVINCIA_DOM",
          sogg."PROVINCIA_DOM_DIPENDENTE",
          sogg."PROVINCIA_PER_SEGNATURA",
          sogg."PROVINCIA_RES",
          sogg."PROVINCIA_RES_DIPENDENTE",
          sogg."REGISTRATA_CONSEGNA",
          sogg."REG_CONSEGNA_AGGIORNAMENTO",
          sogg."REG_CONSEGNA_ANNULLAMENTO",
          sogg."REG_CONSEGNA_CONFERMA",
          sogg."RICEVUTA_CONFERMA",
          sogg."RICEVUTA_ECCEZIONE",
          sogg."RICEVUTO_AGGIORNAMENTO",
          sogg."RICEVUTO_ANNULLAMENTO",
          sogg."RIC_MANCATA_CONSEGNA",
          sogg."RIC_MANCATA_CONSEGNA_AGG",
          sogg."RIC_MANCATA_CONSEGNA_ANN",
          sogg."RIC_MANCATA_CONSEGNA_CONF",
          sogg."SESSO",
          sogg."SIGLA_PROV_AMM",
          sogg."SIGLA_PROV_AOO",
          sogg."TEL_DOM",
          sogg."TEL_RES",
          sogg."TIPO",
          sogg."TIPO_LOCALIZZAZIONE",
          sogg."TIPO_LOCALIZZAZIONE_EXTRA",
          sogg."TIPO_RAPPORTO",
          sogg."TIPO_REGISTRO",
          sogg."TIPO_SOGGETTO",
          sogg."VIA_IMPRESA",
          sogg."VIA_IMPRESA_EXTRA",
          sogg."FULL_TEXT",
          sogg."TXT",
          sogg."PARTITA_IVA",
          sogg."DESCRIZIONE",
          sogg."DOCUMENTO_TRAMITE",
          sogg."ID_LISTA_DISTRIBUZIONE",
          sogg."MODALITA",
          sogg."STATO_PR",
          sogg."CF_NULLABLE",
          sogg."RACCOMANDATA_NUMERO",
          sogg."CF_BENEFICIARIO",
          sogg."DATA_NASCITA_BENEFICIARIO",
          sogg."DENOMINAZIONE_BENEFICIARIO",
          sogg."PI_BENEFICIARIO",
          sogg."CAP_BENEFICIARIO",
          sogg."COMUNE_BENEFICIARIO",
          sogg."INDIRIZZO_BENEFICIARIO",
          sogg."PROVINCIA_BENEFICIARIO",
          sogg."MAIL_IMPRESA",
          sogg."CAP_UO",
          sogg."COMUNE_UO",
          sogg."FAX_UO",
          sogg."INDIRIZZO_UO",
          sogg."MAIL_UO",
          sogg."SIGLA_PROV_UO",
          sogg."TEL_UO",
          sogg."DOCUMENTO_TRAMITE_FORM",
          sogg."QUANTITA",
          sogg."DATA_SPED",
          sogg."DATA_RIC_AGGIORNAMENTO",
          sogg."DATA_RIC_ANNULLAMENTO",
          sogg."DATA_RIC_CONFERMA",
          sogg."DATA_RIC_ECCEZIONE",
          sogg."MAIL_BENEFICIARIO",
          sogg."FAX",
          sogg."FAX_AMM",
          sogg."FAX_AOO",
          sogg."FAX_BENEFICIARIO",
          sogg."TXT_AMM",
          sogg."CONOSCENZA",
          sogg."BC_SPEDIZIONE",
          documenti.area,
          documenti.codice_richiesta,
          documenti.data_aggiornamento,
          documenti.utente_aggiornamento,
          documenti.stato_documento,
          DECODE (
             cognome_per_segnatura,
             NULL, DECODE (
                      denominazione_per_segnatura,
                      NULL, DECODE (
                               cod_uo,
                               NULL, DECODE (
                                        cod_aoo,
                                        NULL, DECODE (
                                                 cod_amm,
                                                 NULL, DECODE (
                                                          descrizione_uo,
                                                          NULL, DECODE (
                                                                   descrizione_aoo,
                                                                   NULL, DECODE (
                                                                            descrizione_amm,
                                                                            NULL, NULL,
                                                                            descrizione_amm),
                                                                      DECODE (
                                                                         descrizione_amm,

NULL, NULL,
                                                                         descrizione_amm)
                                                                   || ':AOO:'
                                                                   || descrizione_aoo),
                                                             DECODE (
                                                                descrizione_amm,
                                                                NULL, NULL,
                                                                descrizione_amm)
                                                          || DECODE (
                                                                descrizione_aoo,
                                                                NULL, NULL,
                                                                   ':AOO:'
                                                                || descrizione_aoo)
                                                          || ':UO:'
                                                          || descrizione_uo),
                                                 descrizione_amm),
                                           DECODE (descrizione_amm,
                                                   NULL, NULL,
                                                   descrizione_amm)
                                        || ':AOO:'
                                        || descrizione_aoo),
                                  DECODE (descrizione_amm,
                                          NULL, NULL,
                                          descrizione_amm)
                               || DECODE (descrizione_aoo,
                                          NULL, NULL,
                                          ':AOO:' || descrizione_aoo)
                               || ':UO:'
                               || descrizione_uo),
                      denominazione_per_segnatura),
             DECODE (nome_per_segnatura,
                     NULL, cognome_per_segnatura,
                     cognome_per_segnatura || ' ' || nome_per_segnatura))
             denominazione_vis,
          DECODE (
             indirizzo_per_segnatura,
             NULL, DECODE (
                      cod_uo,
                      NULL, DECODE (
                               cod_aoo,
                               NULL, DECODE (
                                        cod_amm,
                                        NULL, DECODE (
                                                 descrizione_uo,
                                                 NULL, DECODE (
                                                          descrizione_aoo,
                                                          NULL, DECODE (
                                                                   descrizione_amm,
                                                                   NULL, NULL,
                                                                      indirizzo_amm
                                                                   || DECODE (
                                                                         comune_amm,
                                                                         NULL, NULL,
                                                                            ' '
                                                                         || comune_amm
                                                                         || DECODE (
                                                                               sigla_prov_amm,
                                                                               NULL, NULL,
                                                                                  ' ('
                                                                               || sigla_prov_amm
                                                                               || ')'))),
                                                             indirizzo_aoo
                                                          || DECODE (
                                                                comune_aoo,
                                                                NULL, NULL,
                                                                   ' '
                                                                || comune_aoo
                                                                || DECODE (
                                                                      sigla_prov_aoo,
                                                                      NULL, NULL,
                                                                         ' ('
                                                                      || sigla_prov_aoo
                                                                      || ')'))),
                                                    indirizzo_uo
                                                 || DECODE (
                                                       comune_uo,
                                                       NULL, NULL,
                                                          ' '
                                                       || comune_uo
                                                       || DECODE (
                                                             sigla_prov_uo,
                                                             NULL, NULL,
                                                                ' ('
                                                             || sigla_prov_uo
                                                             || ')'))),
                                           indirizzo_amm
                                        || DECODE (
                                              comune_amm,
                                              NULL, NULL,
                                                 ' '
                                              || comune_amm
                                              || DECODE (
                                                    sigla_prov_amm,
                                                    NULL, NULL,
                                                       ' ('
                                                    || sigla_prov_amm
                                                    || ')'))),
                                  indirizzo_aoo
                               || DECODE (
                                     comune_aoo,
                                     NULL, NULL,
                                        ' '
                                     || comune_aoo
                                     || DECODE (
                                           sigla_prov_aoo,
                                           NULL, NULL,
                                           ' (' || sigla_prov_aoo || ')'))),
                         indirizzo_uo
                      || DECODE (
                            comune_uo,
                            NULL, NULL,
                               ' '
                            || comune_uo
                            || DECODE (sigla_prov_uo,
                                       NULL, NULL,
                                       ' (' || sigla_prov_uo || ')'))),
                indirizzo_per_segnatura
             || DECODE (
                   comune_per_segnatura,
                   NULL, NULL,
                      ' '
                   || comune_per_segnatura
                   || DECODE (provincia_per_segnatura,
                              NULL, NULL,
                              ' (' || provincia_per_segnatura || ')')))
             indirizzo_vis
     FROM seg_soggetti_protocollo sogg, documenti
    WHERE     documenti.id_documento = sogg.id_documento
          AND NVL (documenti.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
          AND NVL (sogg.tipo_rapporto, ' ') <> 'DUMMY'
/
