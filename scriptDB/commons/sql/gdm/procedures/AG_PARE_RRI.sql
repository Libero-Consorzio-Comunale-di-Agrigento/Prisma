--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_PARE_RRI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_pare_rri (
   p_parametro           VARCHAR2,
   new_valore              VARCHAR2,
   p_tipo_modello        VARCHAR2
)
IS
/******************************************************************************
   NAME: AG_PARE_RRI
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0       28/01/2016  SC        1. Created this procedure

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_CLAS_RRI
      Sysdate:         17/02/2009
      Date and Time:   17/02/2009, 16.50.08, and 17/02/2009 16.50.08
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN

 UPDATE parametri
         SET VALORE = new_valore
       WHERE tipo_modello = p_tipo_modello AND codice = p_parametro;

EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_pare_rri;
/
