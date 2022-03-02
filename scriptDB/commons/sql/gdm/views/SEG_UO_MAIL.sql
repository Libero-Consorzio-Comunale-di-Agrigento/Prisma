--liquibase formatted sql
--changeset esasdelli:GDM_VIEW_SEG_UO_MAIL runOnChange:true stripComments:false

  CREATE OR REPLACE FORCE VIEW "SEG_UO_MAIL" ("COD_AMM", "COD_AOO", "COD_UO", "EMAIL", "MAILFAX") AS 
  SELECT cod_amm,           cod_aoo,           cod_uo,           EMAIL, mailfax      FROM seg_amm_aoo_uo_mv,           (SELECT pamm.valore codice_amministrazione, paoo.valore codice_aoo              FROM parametri paoo, parametri pamm             WHERE     pamm.tipo_modello = '@agVar@'                   AND paoo.tipo_modello = '@agVar@'                   AND pamm.codice =                          'CODICE_AMM_' || AG_UTILITIES.GET_DEFAULTAOOINDEX                   AND paoo.codice =                          'CODICE_AOO_' || AG_UTILITIES.GET_DEFAULTAOOINDEX) PARA     WHERE     COD_AMM = PARA.codice_amministrazione           AND COD_AOO = PARA.codice_aoo           AND al IS NULL           AND TIPO = 'UO'
/
