--liquibase formatted sql
--changeset esasdelli:AGSPR_PROCEDURE_TRASCO_PG runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE trasco_pg
IS
BEGIN
   FOR p
      IN (  SELECT anno,
                   tipo_registro,
                   numero,
                   id_documento,
                   idrif,
                   ordinamento
              FROM (SELECT p.anno,
                           p.tipo_registro,
                           p.numero,
                           p.id_documento,
                           p.idrif,
                           1 ordinamento
                      FROM gdm_proto_view p, gdm_seg_smistamenti s
                     WHERE     s.idrif = p.idrif
                           AND s.stato_smistamento IN ('C', 'R')
                    UNION
                    SELECT anno,
                           tipo_registro,
                           numero,
                           id_documento,
                           idrif,
                           2 ordinamento
                      FROM gdm_proto_view p
                     WHERE NOT EXISTS
                              (SELECT 1
                                 FROM gdm_seg_smistamenti s
                                WHERE     s.idrif = p.idrif
                                      AND s.stato_smistamento IN ('C', 'R'))) p
             WHERE     NOT EXISTS
                          (SELECT 1
                             FROM agp_protocolli prot, gdo_documenti d
                            WHERE     d.id_documento = prot.id_documento
                                  AND D.ID_DOCUMENTO_ESTERNO = p.id_documento
                                  AND prot.idrif IS NOT NULL)
                   AND anno IS NOT NULL
          ORDER BY 6,
                   1 DESC,
                   2,
                   3 DESC)
   LOOP
      DECLARE
         RetVal                 NUMBER;
         P_ID_DOCUMENTO_GDM     NUMBER := p.id_documento;
         p_id_tipo_protocollo   NUMBER := NULL;
         p_attiva_iter          NUMBER := 0;
         p_trasco_storico       NUMBER := 0;
         D_ID_DOC               NUMBER;
         d_errore               VARCHAR2 (4000);
      BEGIN
         D_ID_DOC :=
            AGP_TRASCO_PKG.crea_protocollo_agspr (p_id_documento_gdm,
                                                  p_id_tipo_protocollo,
                                                  p_attiva_iter,
                                                  p_trasco_storico);
         DBMS_OUTPUT.put_line (D_ID_DOC);
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_errore := SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            ROLLBACK;

            IF INSTR (d_errore, '-20998') = 0
            THEN
               INSERT INTO AGP_TRASCO_LOG (ID_DOCUMENTO,
                                           ID_DOCUMENTO_ESTERNO,
                                           LOG,
                                           ISTRUZIONE,
                                           DATA_ESECUZIONE)
                    VALUES (D_ID_DOC,
                            p_id_documento_gdm,
                            d_errore,
                            'AGP_TRASCO_PKG.crea_protocollo_agspr',
                            SYSDATE);

               COMMIT;
            END IF;
      END;
   END LOOP;
END;
/