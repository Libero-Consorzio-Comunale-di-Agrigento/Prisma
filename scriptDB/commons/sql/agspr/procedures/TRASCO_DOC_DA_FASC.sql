--liquibase formatted sql
--changeset esasdelli:AGSPR_PROCEDURE_TRASCO_DOC_DA_FASC runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE TRASCO_DOC_DA_FASC
IS
   RetVal     NUMBER;
   d_errore   VARCHAR2 (32000);
BEGIN
   FOR ddf
      IN (  SELECT *
              FROM gdm_spr_da_fascicolare
             WHERE NOT EXISTS
                      (SELECT 1
                         FROM agp_protocolli p, gdo_documenti d
                        WHERE     d.id_documento = p.id_documento
                              AND D.ID_DOCUMENTO_ESTERNO =
                                     gdm_spr_da_fascicolare.id_documento
                              AND p.idrif IS NOT NULL)
          ORDER BY id_documento DESC)
   LOOP
      BEGIN
         RetVal := AGP_TRASCO_PKG.CREA_DOC_DA_FASC_AGSPR (ddf.ID_DOCUMENTO);
         --DBMS_OUTPUT.put_line (retval);
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_errore := SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            ROLLBACK;

            INSERT INTO AGP_TRASCO_LOG (ID_DOCUMENTO,
                                        ID_DOCUMENTO_ESTERNO,
                                        LOG,
                                        ISTRUZIONE,
                                        DATA_ESECUZIONE)
                 VALUES (retval,
                         ddf.ID_DOCUMENTO,
                         d_errore,
                         'AGP_TRASCO_PKG.CREA_DOC_DA_FASC_AGSPR',
                         SYSDATE);

            COMMIT;
      END;
   END LOOP;
END;
/