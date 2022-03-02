--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGS_RIFERIMENTI runOnChange:true stripComments:false

 CREATE OR REPLACE FORCE VIEW AGS_RIFERIMENTI
(
   ID_DOCUMENTO,
   ID_DOCUMENTO_RIF,
   DATA_AGGIORNAMENTO,
   TIPO_RIFERIMENTO,
   DESC_TIPO_RIFERIMENTO,
   URL,
   URL_RIF,
   OGGETTO,
   OGGETTO_RIF
)
AS
 SELECT rife.id_documento,
          rife.id_documento_rif,
          rife.data_aggiornamento,
          tire.tipo_relazione tipo_riferimento,
          tire.descrizione desc_tipo_riferimento,
          gdm_gdc_utility_pkg.f_get_url_oggetto ('',
                                                 '',
                                                 rife.id_documento,
                                                 'D',
                                                 '',
                                                 '',
                                                 '',
                                                 'R',
                                                 '',
                                                 '',
                                                 '5',
                                                 'N')
             url,
          gdm_gdc_utility_pkg.f_get_url_oggetto ('',
                                                 '',
                                                 id_documento_rif,
                                                 'D',
                                                 '',
                                                 '',
                                                 '',
                                                 'R',
                                                 '',
                                                 '',
                                                 '5',
                                                 'N')
             url_rif,
          gdm_ag_riferimenti_utility.get_oggetto_riferimento (
             rife.id_documento)
             oggetto,
          gdm_ag_riferimenti_utility.get_oggetto_riferimento (
             id_documento_rif)
             oggetto_rif
     FROM gdm_riferimenti rife,
          gdm_tipi_relazione tire,
          gdm_documenti d,
          gdm_documenti dr
    WHERE     d.id_documento = rife.id_documento
          AND d.stato_documento = 'BO'
          AND dr.id_documento = rife.id_documento_rif
          AND dr.stato_documento = 'BO'
          AND NOT EXISTS
                 (SELECT 1
                    FROM gdo_tipi_collegamento tc,
                         gdo_documenti d,
                         gdo_documenti c,
                         gdo_documenti_collegati dc
                   WHERE     TC.ID_TIPO_COLLEGAMENTO =
                                DC.ID_TIPO_COLLEGAMENTO
                         AND tipo_collegamento = rife.tipo_relazione
                         AND d.id_documento = DC.ID_DOCUMENTO
                         AND c.id_documento = DC.ID_COLLEGATO
                         AND D.ID_DOCUMENTO_ESTERNO = rife.id_documento
                         AND C.ID_DOCUMENTO_ESTERNO = rife.ID_DOCUMENTO_RIF)
          AND NOT EXISTS
                 (SELECT 1
                    FROM gdo_tipi_collegamento tc,
                         gdo_documenti d,
                         gdo_documenti c,
                         gdo_documenti_collegati dc
                   WHERE     TC.ID_TIPO_COLLEGAMENTO =
                                DC.ID_TIPO_COLLEGAMENTO
                         AND tipo_collegamento = rife.tipo_relazione
                         AND d.id_documento = DC.ID_DOCUMENTO
                         AND c.id_documento = DC.ID_COLLEGATO
                         AND C.ID_DOCUMENTO_ESTERNO = rife.id_documento
                         AND D.ID_DOCUMENTO_ESTERNO = rife.ID_DOCUMENTO_RIF)
          AND rife.tipo_relazione NOT IN ('PROT_ALLE',
                                          'PROT_SMIS',
                                          'PROT_SOGG',
                                          'PROT_LISTA',
                                          'PROT_FASC',
                                          'PROT_FASPR')
          AND tire.area = rife.area
          AND tire.tipo_relazione = rife.tipo_relazione
/
