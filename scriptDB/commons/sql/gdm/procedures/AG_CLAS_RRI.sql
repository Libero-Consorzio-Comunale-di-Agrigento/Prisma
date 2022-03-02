--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_CLAS_RRI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_clas_rri (
   new_id_documento             NUMBER,
   new_class_cod                VARCHAR2,
   new_class_dal                DATE,
   new_class_al                 DATE,
   new_codice_amministrazione   VARCHAR2,
   new_codice_aoo               VARCHAR2
)
IS
/******************************************************************************
   NAME:       AG_CLAS_RRI
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/02/2009  SC        1. Created this procedure. A25969.0.2 D526.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_CLAS_RRI
      Sysdate:         17/02/2009
      Date and Time:   17/02/2009, 16.50.08, and 17/02/2009 16.50.08
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN

   FOR clas_presenti IN (SELECT class_cod, class_dal, class_al
                           FROM seg_classificazioni clas, documenti docu
                          WHERE clas.id_documento = docu.id_documento
                            AND docu.stato_documento NOT IN ('CA', 'RE')
                            AND clas.class_cod = new_class_cod
                            AND clas.codice_amministrazione =
                                                    new_codice_amministrazione
                            AND clas.codice_aoo = new_codice_aoo
                            AND clas.id_documento != NVL (new_id_documento, 0))
   LOOP
      IF clas_presenti.class_dal = new_class_dal
      THEN
         raise_application_error (-20999,
                                     'Classificazione '
                                  || new_class_cod
                                  || ' del '
                                  || TO_CHAR (new_class_dal, 'dd/mm/yyyy')
                                  || ' gia'' presente '
                                 );
      END IF;

      IF clas_presenti.class_al IS NULL AND new_class_al IS NULL
      THEN
         raise_application_error (-20999,
                                     'Classificazione '
                                  || new_class_cod
                                  || ' gia'' presente '
                                 );
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_clas_rri;
/
