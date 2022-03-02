--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SEG_MEMO_PROTOCOLLO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE TRIGGER AG_SEG_MEMO_PROTOCOLLO_TIU
   BEFORE INSERT OR UPDATE
   ON SEG_MEMO_PROTOCOLLO
   FOR EACH ROW
BEGIN
   :NEW.memo_in_partenza := NVL (:NEW.memo_in_partenza, 'N');

   IF LENGTH (:new.mittente) > 200
   THEN
      :new.mittente := SUBSTR (:new.mittente, -1, 200);
   END IF;

   IF :NEW.tipo_messaggio IS NULL
   THEN
      IF SUBSTR (NVL (:NEW.oggetto, ' '), 1, LENGTH ('ANOMALIA')) <>
            'ANOMALIA'
      THEN
         :NEW.tipo_messaggio := 'PEC';
      ELSE
         :NEW.tipo_messaggio := 'NONPEC';
      END IF;
   END IF;


   IF INSERTING
   THEN
      IF :NEW.memo_in_partenza IS NOT NULL AND :NEW.memo_in_partenza = 'N'
      THEN
         -- Bug #33933 PEC scaricate con data ricezione futura
         DECLARE
            d_oggi   DATE := TRUNC (SYSDATE);
         BEGIN
            IF    :new.data_ricezione IS NULL
               OR NVL (:new.data_ricezione, d_oggi) > SYSDATE
            THEN
               :new.data_ricezione := d_oggi;
            END IF;
         END;

         :NEW.stato_memo := 'DG';
         :NEW.data_stato_memo := SYSDATE;
      END IF;

      IF :NEW.idrif IS NULL
      THEN
         SELECT seq_idrif.NEXTVAL INTO :NEW.idrif FROM DUAL;
      END IF;
   END IF;

   IF UPDATING
   THEN
      IF NVL (:NEW.memo_in_partenza, 'N') = 'N'
      THEN
         --Bug #33933     PEC scaricate con data ricezione futura
         DECLARE
            d_oggi   DATE := TRUNC (SYSDATE);
         BEGIN
            IF    :new.data_ricezione IS NULL
               OR NVL (:new.data_ricezione, d_oggi) > SYSDATE
            THEN
               :new.data_ricezione := d_oggi;
            END IF;
         END;

         IF :NEW.stato_memo IS NULL
         THEN
            :NEW.stato_memo := 'DG';
         END IF;

         IF     NVL (:OLD.stato_memo, 'DG') NOT IN ('NP',
                                                    'DP',
                                                    'DPS',
                                                    'PR')
            AND NVL (:OLD.class_cod, '*') != NVL (:NEW.class_cod, '*')
            AND NVL (:NEW.class_cod, '*') != '*'
         THEN
            :NEW.stato_memo := 'NP';
         END IF;

         IF     NVL (:OLD.stato_memo, 'DG') != 'SC'
            AND NVL (:NEW.stato_memo, 'DG') = 'SC'
         THEN
            AG_MEMO_UTILITY.ELIMINA_SMISTAMENTI (:NEW.idrif);
         END IF;

         IF     NVL (:OLD.generata_eccezione, 'N') !=
                   NVL (:NEW.generata_eccezione, 'N')
            AND NVL (:NEW.generata_eccezione, 'N') = 'Y'
         THEN
            :NEW.stato_memo := 'GE';
         END IF;

         IF    (NVL (:OLD.stato_memo, 'DG') != NVL (:NEW.stato_memo, 'DG'))
            OR (NVL (:OLD.processato_ag, 'N') !=
                   NVL (:NEW.processato_ag, 'N'))
         THEN
            DECLARE
               a_messaggio    VARCHAR2 (32000);
               a_istruzione   VARCHAR2 (32000);
            BEGIN
               a_messaggio :=
                  'Errore in aggiornamento di ' || :NEW.id_documento || '.';
               a_istruzione :=
                     'Begin '
                  || '   AG_MEPR_RRI('
                  || :NEW.id_documento
                  || ', '''
                  || :NEW.stato_memo
                  || ''', '''
                  || :NEW.processato_ag
                  || '''); '
                  || 'end; ';
               integritypackage.set_postevent (a_istruzione, a_messaggio);
            END;
         END IF;
      END IF;

      IF NVL (:OLD.stato_memo, '*') != NVL (:NEW.stato_memo, '*')
      THEN
         :NEW.data_stato_memo := SYSDATE;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/