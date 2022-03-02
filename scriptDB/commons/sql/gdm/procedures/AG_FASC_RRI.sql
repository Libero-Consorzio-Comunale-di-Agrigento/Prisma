--liquibase formatted sql
--changeset esasdelli:GDM_PROCEDURE_AG_FASC_RRI runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_fasc_rri (
   new_id_documento             NUMBER,
   new_class_cod                VARCHAR2,
   new_class_dal                DATE,
   new_fascicolo_anno           NUMBER,
   new_fascicolo_numero         VARCHAR2,
   new_codice_amministrazione   VARCHAR2,
   new_codice_aoo               VARCHAR2
)
IS
/******************************************************************************
   NAME:       AG_FASC_RRI
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/03/2009  SC        1. Created this procedure. A31537.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_FASC_RRI
      Sysdate:         03/03/2009
      Date and Time:   03/03/2009 , 16.50.08, and 17/02/2009 16.50.08
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
   dep_esiste   NUMBER := 0;
BEGIN
   SELECT min(fasc.id_documento)
              INTO dep_esiste
              FROM seg_fascicoli fasc, documenti docu
             WHERE fasc.id_documento = docu.id_documento
               AND docu.stato_documento NOT IN ('CA', 'RE')
               AND fasc.class_cod = new_class_cod
               AND fasc.class_dal = new_class_dal
               AND fasc.fascicolo_anno = new_fascicolo_anno
               AND fasc.fascicolo_numero = new_fascicolo_numero
               AND fasc.codice_amministrazione = new_codice_amministrazione
               AND fasc.codice_aoo = new_codice_aoo
               AND fasc.id_documento != nvl(new_id_documento, 0);

   IF nvl(dep_esiste,0) > 0
   THEN
      raise_application_error (-20999,'Fascicolo ' || new_class_cod ||' '||new_fascicolo_anno ||'/'||new_fascicolo_numero
                   || ' ('||new_id_documento||')'
                   ||' per amministrazione '||new_codice_amministrazione||' e aoo '||new_codice_aoo
                   || ' gia'' presente.');
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END ag_fasc_rri;
/
