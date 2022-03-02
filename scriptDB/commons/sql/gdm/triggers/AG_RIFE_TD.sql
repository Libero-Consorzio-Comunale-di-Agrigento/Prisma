--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_RIFE_TD runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_RIFE_TD
   BEFORE DELETE
   ON RIFERIMENTI
   FOR EACH ROW
DECLARE
/******************************************************************************
   NAME:       AG_RIFE_TD
   PURPOSE:

   REVISIONS:
   Ver        Date        Author   Description
   ---------  ----------  -------  -------------------------------------------
   1.0        31/01/2018  MM       1. Created this trigger.
   1.1        18/10/2018  SC       #30709 gestisce il nuovo riferimento PROT_DAAC.
   1.2        14/11/2018  MM       Cancellazione record in ag_proto_memo_key
******************************************************************************/
isMemo varchar2(1);
a_messaggio varchar2(2000);
BEGIN
   IF :old.tipo_relazione IN ('FAX', 'MAIL')
   THEN
      BEGIN
         DELETE ag_proto_memo_key
             where id_protocollo =:old.id_documento
               and id_memo = :old.id_documento_rif;
         END;
   END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
