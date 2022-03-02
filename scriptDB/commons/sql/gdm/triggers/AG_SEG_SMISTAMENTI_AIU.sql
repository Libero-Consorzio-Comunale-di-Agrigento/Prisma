--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SEG_SMISTAMENTI_AIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SEG_SMISTAMENTI_AIU
   AFTER INSERT OR UPDATE
   ON SEG_SMISTAMENTI
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
   X_JOB   NUMBER;
BEGIN
   --raise_application_error(-20999, NVL (:new.stato_smistamento, '*'));
   IF     :new.id_documento IS NOT NULL
      AND NVL (:new.stato_smistamento, '*') IN ('R', 'C')
      AND NVL (:old.stato_smistamento, '*') <>
             NVL (:new.stato_smistamento, '*')
      AND NVL (:new.tipo_smistamento, '*') = 'COMPETENZA'
   THEN
      DBMS_JOB.SUBMIT (
         job         => X_JOB,
         what        =>    'BEGIN '
                        || '    AG_SMISTAMENTO.INVIA_MAIL_SMISTAMENTO ('
                        || :new.id_documento
                        || ', '''
                        || :NEW.STATO_SMISTAMENTO
                        || '''); '
                        || 'END;',
         next_date   => SYSDATE,
         no_parse    => FALSE);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
