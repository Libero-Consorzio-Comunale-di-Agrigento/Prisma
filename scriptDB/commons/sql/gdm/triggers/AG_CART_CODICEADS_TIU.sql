--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_CART_CODICEADS_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER ${global.db.gdm.username}.ag_cart_codiceads_tiu
   BEFORE INSERT OR UPDATE
   ON ${global.db.gdm.username}.CARTELLE
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   dep_area_documento           VARCHAR2 (1000);
   dep_cartella_con_codiceads   NUMBER;
/******************************************************************************
   NAME:       AG_CART_CODICEADS_TIU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/04/2012             1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     AG_CART_CODICEADS_TIU
      Sysdate:         13/04/2012
      Date and Time:   13/04/2012, 13.09.06, and 13/04/2012 13.09.06
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      CARTELLE (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
BEGIN
   if inserting or updating('NOME') then
      SELECT area,
             DECODE (tipi_documento.nome,
                     'DIZ_CLASSIFICAZIONE', 0,
                     'FASCICOLO', 0,
                     'DIZ_UNITA', 0,
                     1
                    )
        INTO dep_area_documento,
             dep_cartella_con_codiceads
        FROM documenti, tipi_documento
       WHERE id_documento = :NEW.id_documento_profilo
         AND tipi_documento.id_tipodoc = documenti.id_tipodoc
         AND tipi_documento.area_modello = documenti.area
         AND DOCUMENTI.AREA LIKE 'SEGRETERIA%'
         AND DOCUMENTI.AREA != 'SEGRETERIA.ATTI';
      IF dep_cartella_con_codiceads = 1
      THEN
         :NEW.codiceads :=
                  dep_area_documento || '#' || replace_for_codiceads (:NEW.nome);
      END IF;
   end if;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
