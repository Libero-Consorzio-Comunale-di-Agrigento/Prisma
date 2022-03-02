--liquibase formatted sql
--changeset rdestasio:4.1.0.0_20200301_33.gdo_notifiche_memo_ins

DECLARE
   d_id        NUMBER;
   d_id_ente   NUMBER;
BEGIN
   FOR ente IN (SELECT *
                  FROM gdo_enti)
   LOOP
      d_id_ente := ente.id_ente;

      SELECT hibernate_sequence.NEXTVAL INTO d_id FROM DUAL;

      INSERT INTO GDO_NOTIFICHE (ID_NOTIFICA,
                                 VERSION,
                                 DATA_INS,
                                 ID_ENTE,
                                 DATA_UPD,
                                 OGGETTI,
                                 OGGETTO,
                                 TIPO_NOTIFICA,
                                 TITOLO,
                                 UTENTE_INS,
                                 UTENTE_UPD,
                                 VALIDO,
                                 VALIDO_DAL,
                                 MODALITA_INVIO)
         SELECT d_id,
                0,
                SYSDATE,
                d_id_ente,
                SYSDATE,
                'SMISTAMENTO',
                'Da ricevere mail [OGGETTO]',
                'SMISTAMENTO_DA_RICEVERE_COMPETENZA_MEMO',
                'Smistamento Inviato per competenza - Memo',
                'RPI',
                'RPI',
                'Y',
                SYSDATE,
                'JWORKLIST'
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM GDO_NOTIFICHE
                     WHERE     TIPO_NOTIFICA =
                                  'SMISTAMENTO_DA_RICEVERE_COMPETENZA_MEMO'
                           AND ID_ENTE = d_id_ente);

      IF SQL%ROWCOUNT > 0
      THEN
         DECLARE
            d_seq   NUMBER;
         BEGIN
            SELECT hibernate_sequence.NEXTVAL INTO d_seq FROM DUAL;

            INSERT INTO GDO_NOTIFICHE_DESTINATARI (ID_NOTIFICA_DESTINATARIO,
                                                   ID_NOTIFICA,
                                                   VERSION,
                                                   DATA_INS,
                                                   ID_ENTE,
                                                   FUNZIONE,
                                                   DATA_UPD,
                                                   UTENTE_INS,
                                                   UTENTE_UPD,
                                                   VALIDO,
                                                   SEQUENZA,
                                                   ASSEGNAZIONE)
               SELECT d_seq,
                      d_id,
                      0,
                      SYSDATE,
                      d_id_ente,
                      'DESTINATARI_SMISTAMENTO',
                      SYSDATE,
                      'RPI',
                      'RPI',
                      'Y',
                      0,
                      'COMPETENZA'
                 FROM DUAL;
         END;
      END IF;

      SELECT hibernate_sequence.NEXTVAL INTO d_id FROM DUAL;

      INSERT INTO GDO_NOTIFICHE (ID_NOTIFICA,
                                 VERSION,
                                 DATA_INS,
                                 ID_ENTE,
                                 DATA_UPD,
                                 OGGETTI,
                                 OGGETTO,
                                 TIPO_NOTIFICA,
                                 TITOLO,
                                 UTENTE_INS,
                                 UTENTE_UPD,
                                 VALIDO,
                                 VALIDO_DAL,
                                 MODALITA_INVIO)
         SELECT d_id,
                0,
                SYSDATE,
                d_id_ente,
                SYSDATE,
                'SMISTAMENTO',
                'In carico mail [OGGETTO]',
                'SMISTAMENTO_IN_CARICO_MEMO',
                'Presa In Carico - Memo',
                'RPI',
                'RPI',
                'Y',
                SYSDATE,
                'JWORKLIST'
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM GDO_NOTIFICHE
                     WHERE     TIPO_NOTIFICA = 'SMISTAMENTO_IN_CARICO_MEMO'
                           AND ID_ENTE = d_id_ente);

      IF SQL%ROWCOUNT > 0
      THEN
         DECLARE
            d_seq   NUMBER;
         BEGIN
            SELECT hibernate_sequence.NEXTVAL INTO d_seq FROM DUAL;

            INSERT INTO GDO_NOTIFICHE_DESTINATARI (ID_NOTIFICA_DESTINATARIO,
                                                   ID_NOTIFICA,
                                                   VERSION,
                                                   DATA_INS,
                                                   ID_ENTE,
                                                   FUNZIONE,
                                                   DATA_UPD,
                                                   UTENTE_INS,
                                                   UTENTE_UPD,
                                                   VALIDO,
                                                   SEQUENZA,
                                                   ASSEGNAZIONE)
               SELECT d_seq,
                      d_id,
                      0,
                      SYSDATE,
                      d_id_ente,
                      'DESTINATARI_SMISTAMENTO',
                      SYSDATE,
                      'RPI',
                      'RPI',
                      'Y',
                      0,
                      'COMPETENZA'
                 FROM DUAL;
         END;
      END IF;

      SELECT hibernate_sequence.NEXTVAL INTO d_id FROM DUAL;

      INSERT INTO GDO_NOTIFICHE (ID_NOTIFICA,
                                 VERSION,
                                 DATA_INS,
                                 ID_ENTE,
                                 DATA_UPD,
                                 OGGETTI,
                                 OGGETTO,
                                 TIPO_NOTIFICA,
                                 TITOLO,
                                 UTENTE_INS,
                                 UTENTE_UPD,
                                 VALIDO,
                                 VALIDO_DAL,
                                 MODALITA_INVIO)
         SELECT d_id,
                0,
                SYSDATE,
                d_id_ente,
                SYSDATE,
                'SMISTAMENTO',
                'Assegnata mail [OGGETTO]',
                'SMISTAMENTO_IN_CARICO_ASSEGNATO_MEMO',
                'Smistamento assegnato - Memo',
                'RPI',
                'RPI',
                'Y',
                SYSDATE,
                'JWORKLIST'
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM GDO_NOTIFICHE
                     WHERE     TIPO_NOTIFICA =
                                  'SMISTAMENTO_IN_CARICO_ASSEGNATO_MEMO'
                           AND ID_ENTE = d_id_ente);

      IF SQL%ROWCOUNT > 0
      THEN
         DECLARE
            d_seq   NUMBER;
         BEGIN
            SELECT hibernate_sequence.NEXTVAL INTO d_seq FROM DUAL;

            INSERT INTO GDO_NOTIFICHE_DESTINATARI (ID_NOTIFICA_DESTINATARIO,
                                                   ID_NOTIFICA,
                                                   VERSION,
                                                   DATA_INS,
                                                   ID_ENTE,
                                                   FUNZIONE,
                                                   DATA_UPD,
                                                   UTENTE_INS,
                                                   UTENTE_UPD,
                                                   VALIDO,
                                                   SEQUENZA,
                                                   ASSEGNAZIONE)
               SELECT d_seq,
                      d_id,
                      0,
                      SYSDATE,
                      d_id_ente,
                      'DESTINATARI_SMISTAMENTO',
                      SYSDATE,
                      'RPI',
                      'RPI',
                      'Y',
                      0,
                      'COMPETENZA'
                 FROM DUAL;
         END;
      END IF;

      SELECT hibernate_sequence.NEXTVAL INTO d_id FROM DUAL;

      INSERT INTO GDO_NOTIFICHE (ID_NOTIFICA,
                                 VERSION,
                                 DATA_INS,
                                 ID_ENTE,
                                 DATA_UPD,
                                 OGGETTI,
                                 OGGETTO,
                                 TIPO_NOTIFICA,
                                 TITOLO,
                                 UTENTE_INS,
                                 UTENTE_UPD,
                                 VALIDO,
                                 VALIDO_DAL,
                                 MODALITA_INVIO)
         SELECT d_id,
                0,
                SYSDATE,
                d_id_ente,
                SYSDATE,
                'SMISTAMENTO',
                'Presa visione mail [OGGETTO]',
                'SMISTAMENTO_DA_RICEVERE_CONOSCENZA_MEMO',
                'Smistamento inviato per conoscenza - Memo',
                'RPI',
                'RPI',
                'Y',
                SYSDATE,
                'JWORKLIST'
           FROM DUAL
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM GDO_NOTIFICHE
                     WHERE     TIPO_NOTIFICA =
                                  'SMISTAMENTO_DA_RICEVERE_CONOSCENZA_MEMO'
                           AND ID_ENTE = d_id_ente);

      IF SQL%ROWCOUNT > 0
      THEN
         DECLARE
            d_seq   NUMBER;
         BEGIN
            SELECT hibernate_sequence.NEXTVAL INTO d_seq FROM DUAL;

            INSERT INTO GDO_NOTIFICHE_DESTINATARI (ID_NOTIFICA_DESTINATARIO,
                                                   ID_NOTIFICA,
                                                   VERSION,
                                                   DATA_INS,
                                                   ID_ENTE,
                                                   FUNZIONE,
                                                   DATA_UPD,
                                                   UTENTE_INS,
                                                   UTENTE_UPD,
                                                   VALIDO,
                                                   SEQUENZA,
                                                   ASSEGNAZIONE)
               SELECT d_seq,
                      d_id,
                      0,
                      SYSDATE,
                      d_id_ente,
                      'DESTINATARI_SMISTAMENTO',
                      SYSDATE,
                      'RPI',
                      'RPI',
                      'Y',
                      0,
                      'CONOSCENZA'
                 FROM DUAL;
         END;
      END IF;
   END LOOP;
END;
/