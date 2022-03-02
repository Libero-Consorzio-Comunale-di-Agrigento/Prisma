--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_AGS_RIFERIMENTI runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "AGS_RIFERIMENTI" ("ID_DOCUMENTO", "ID_DOCUMENTO_RIF", "DATA_AGGIORNAMENTO", "TIPO_RIFERIMENTO", "DESC_TIPO_RIFERIMENTO", "URL", "URL_RIF", "OGGETTO", "OGGETTO_RIF") AS 
  SELECT rife.id_documento,
            rife.id_documento_rif,
            rife.data_aggiornamento,
            tire.tipo_relazione tipo_riferimento,
            tire.descrizione desc_tipo_riferimento,
            gdc_utility_pkg.f_get_url_oggetto ('',
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
            gdc_utility_pkg.f_get_url_oggetto ('',
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
            ag_riferimenti_utility.get_oggetto_riferimento (rife.id_documento)
               oggetto,
            ag_riferimenti_utility.get_oggetto_riferimento (id_documento_rif)
               oggetto_rif
       FROM riferimenti rife,
            tipi_relazione tire,
            documenti docu,
            documenti docu_rif
      WHERE     tire.tipo_relazione = rife.tipo_relazione
            AND tire.area = rife.area
            AND docu.id_documento = rife.id_documento
            AND NVL (docu.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
            AND docu_rif.id_documento = rife.id_documento_rif
            AND NVL (docu_rif.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
            AND rife.tipo_relazione NOT IN ('PROT_ALLE',
                                            'PROT_SMIS',
                                            'PROT_SOGG',
                                            'PROT_LISTA',
                                            'PROT_FASC',
                                            'PROT_FASPR')
   ORDER BY rife.data_aggiornamento
/
