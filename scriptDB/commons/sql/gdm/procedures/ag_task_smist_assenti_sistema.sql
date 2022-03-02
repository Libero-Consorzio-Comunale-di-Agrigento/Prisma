--liquibase formatted sql
--changeset scaputo:ag_task_smist_assenti_sistema runOnChange:true stripComments:false

CREATE OR REPLACE PROCEDURE ag_task_smist_assenti_sistema (
   a_id_smistamento    NUMBER DEFAULT NULL,
   a_data_dal          DATE DEFAULT TRUNC (SYSDATE))
AS
BEGIN
   FOR s
      IN (SELECT seg_smistamenti.id_documento
            FROM seg_smistamenti, DOCUMENTI
           WHERE     NOT EXISTS
                        (SELECT 1
                           FROM AGSPR_GDO_NOTIFICHE_ATTIVITA
                          WHERE id_riferimento =
                                   TO_CHAR (seg_smistamenti.id_documento))
                 AND seg_smistamenti.stato_smistamento IN ('R', 'C')
                 AND NOT EXISTS
                        (SELECT 1
                           FROM jwf_task_esterni
                          WHERE id_riferimento =
                                   TO_CHAR (seg_smistamenti.id_documento))
                 AND seg_smistamenti.id_documento =
                        DOCUMENTI.ID_DOCUMENTO
                 AND DOCUMENTI.STATO_DOCUMENTO = 'BO'
                 AND smistamento_dal > TRUNC (a_data_dal)
                 AND tipo_smistamento IN ('COMPETENZA', 'CONOSCENZA')
                 AND EXISTS
                        (SELECT 1
                           FROM smistabile_view
                          WHERE SEG_SMISTAMENTI.IDRIF =
                                   smistabile_view.IDRIF)
                 AND seg_smistamenti.id_documento =
                        NVL (a_id_smistamento, seg_smistamenti.id_documento))
   LOOP
      ag_task_da_id_smistamento (s.id_documento);
   END LOOP;
END;
/
