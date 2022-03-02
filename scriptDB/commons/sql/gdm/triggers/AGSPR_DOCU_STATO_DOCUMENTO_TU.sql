--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AGSPR_DOCU_STATO_DOCUMENTO_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AGSPR_DOCU_STATO_DOCUMENTO_TU
   AFTER UPDATE OF STATO_DOCUMENTO
   ON DOCUMENTI
   FOR EACH ROW
DECLARE
/******************************************************************************
   NAME:       AGSPR_DOCU_STATO_DOCUMENTO_TU
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/09/2018            SC     Cancellazione riferimenti alla lettera
                                           cancellata.
   1.1        13/12/2019         GMannella Evita di cancellare i riferimenti
                                           MAIL/FAX perchè il lavorolo fa lo
                                           scarto del memo.
******************************************************************************/

BEGIN
   IF :NEW.stato_documento = 'CA'
   THEN
      DBMS_OUTPUT.PUT_LINE ('LO STATO E'' CA');

      IF AGSPR_AGP_PROTOCOLLI_PKG.is_documento_agspr (:new.id_documento) = 1
      THEN
         DBMS_OUTPUT.PUT_LINE ('SI TRATTA DI UN documento agspr');

         BEGIN
            AGSPR_AGP_PROTOCOLLI_PKG.del (:NEW.id_documento,
                                          :NEW.UTENTE_AGGIORNAMENTO);

            -- EVITO DI CANCELLARE I TIPI MAIL/FAX PERCHe IL LAVORO LO FA LO SCARTA MEMO
            DELETE riferimenti
             WHERE     (   id_documento = :NEW.id_documento
                        OR id_documento_rif = :NEW.id_documento)
                   AND tipo_relazione NOT IN ('MAIL', 'FAX');


            jwf_utility.p_elimina_task_esterno (NULL,
                                                :NEW.id_documento,
                                                NULL);

            DBMS_OUTPUT.PUT_LINE ('HO cancellato il documento agspr');
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (
                  -20999,
                     'Fallita cancellazione documento agspr perche'' e'' fallita la cancellazione sullo user proprietario (AGSPR):'
                  || SQLERRM);
         END;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
