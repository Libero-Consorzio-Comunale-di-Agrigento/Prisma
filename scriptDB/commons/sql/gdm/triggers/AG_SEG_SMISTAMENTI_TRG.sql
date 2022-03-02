--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SEG_SMISTAMENTI_TRG runOnChange:true stripComments:false
CREATE OR REPLACE TRIGGER AG_SEG_SMISTAMENTI_TRG
    BEFORE INSERT OR UPDATE
    ON SEG_SMISTAMENTI
    FOR EACH ROW
DECLARE
    d_id_doc_padre   NUMBER;
BEGIN
    IF UPDATING AND NVL (:old.idrif, '0') != NVL (:new.idrif, '0')
    THEN
        UPDATE seg_memo_protocollo
           SET stato_memo = 'NP'
         WHERE     idrif = :NEW.idrif
               AND stato_memo NOT IN ('DP',
                                      'DPS',
                                      'NP',
                                      'PR');
    END IF;

    IF     UPDATING
       AND :new.key_iter_smistamento IS NULL
       AND NVL (:new.tipo_smistamento, 'DUMMY') != 'DUMMY'
    THEN
        :new.key_iter_smistamento := -1;
    END IF;
END;
/

