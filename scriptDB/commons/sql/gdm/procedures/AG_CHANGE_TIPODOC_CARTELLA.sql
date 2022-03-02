--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_CHANGE_TIPODOC_CARTELLA runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_change_tipodoc_cartella (
   p_nome_cartella         IN   VARCHAR2,
   p_nome_tipo_documento   IN   VARCHAR2,
   p_nuova_area                 VARCHAR2,
   p_area_cartella_padre   IN   VARCHAR2,
   p_cm_cartella_padre     IN   VARCHAR2
)
IS
   id_documento_cartella   NUMBER;
   RET VARCHAR2(32000);
/******************************************************************************
   NAME:       AG_CHANGE_TIPODOC_CARTELLA
   PURPOSE:    Cambiare l'area del modello cui la cartella con nome P_NOME e' associata.
                Per identificare la cartella, cercando di non spostare cartelle di altri
                applicativi che avessero lo stesso nome, ci si fa passare area e modello
                di una cartelle in cui essa e' contenuta.
                Per esempio la cartella Diizonari sta dentro la cartella Amministrazione
                che ha area SEGRETERIA  e modello WRKSPStandard, non si puo' confondere
                con la cartella Dizionari dell'applicativo di qualita'
                che non dovrebbe essere dentro una workarea di SEGRETERIA.

   p_nome_cartella         IN   VARCHAR2 NOME DELLA CARTELLA DA SPOSTARE
   p_nome_tipo_documento   IN   VARCHAR2 NOME TIPO DOCUMENTO DELLA CARTELLA DA SPOSTARE
   p_nuova_area                 VARCHAR2 AREA IN CUI SPOSTARE LA CARTELLA
   p_area_cartella_padre   IN   VARCHAR2 AREA DELLA CARTELLA IN CUI LA CARTELLA DA SPSOTARE e' CONTENUTA
   p_cm_cartella_padre     IN   VARCHAR2    CODICE MODELLO DELLA CARTELLA IN CUI LA CARTELLA DA SPSOTARE e' CONTENUTA

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/07/2008          1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SC_CHANGE_TIPODOC_CARTELLA
      Sysdate:         07/07/2008
      Date and Time:   07/07/2008, 19.08.39, and 07/07/2008 19.08.39
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   SELECT d_diz.id_documento
     INTO id_documento_cartella
     FROM cartelle c_diz,
          documenti d_diz,
          tipi_documento td_diz,
          links l_diz,
          cartelle c_amm,
          documenti d_amm,
          tipi_documento td_amm
    WHERE c_diz.nome = p_nome_cartella
      AND c_diz.id_documento_profilo = d_diz.id_documento
      AND d_diz.id_tipodoc = td_diz.id_tipodoc
      AND td_diz.nome = p_nome_tipo_documento
	  AND TD_DIZ.AREA_MODELLO<>p_nuova_area
      AND l_diz.id_oggetto = c_diz.id_cartella
      AND l_diz.tipo_oggetto = 'C'
      AND l_diz.id_cartella = c_amm.id_cartella
      AND c_amm.id_documento_profilo = d_amm.id_documento
      AND d_amm.id_tipodoc = td_amm.id_tipodoc
      AND td_amm.area_modello = p_area_cartella_padre
      AND td_amm.nome = p_cm_cartella_padre;

   ret := f_sposta_documento (id_documento_cartella, p_nuova_area);

   IF ret IS NOT NULL
   THEN
      raise_application_error (-20999, ret);
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_change_tipodoc_cartella;
/
