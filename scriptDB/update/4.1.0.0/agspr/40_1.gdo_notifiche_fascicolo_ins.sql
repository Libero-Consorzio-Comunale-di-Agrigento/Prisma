--liquibase formatted sql
--changeset lpratola:4.1.0.0_20200301_40.gdo_notifiche_memo_ins

DECLARE
    d_id      NUMBER;
    d_id_ente NUMBER;
BEGIN

    for ente in (select * from gdo_enti )
        loop
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
                   'Fascicolo da ricevere [CLASSIFICA_CODICE] [ANNO_FASCICOLO]/[NUMERO_7_FASCICOLO] [OGGETTO_FASCICOLO]',
                   'SMISTAMENTO_DA_RICEVERE_COMPETENZA_FASCICOLO',
                   'Smistamento Inviato per competenza - Fascicolo',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA =
                       'SMISTAMENTO_DA_RICEVERE_COMPETENZA_FASCICOLO' and ID_ENTE = d_id_ente);

            IF SQL%ROWCOUNT > 0
            THEN
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
                SELECT hibernate_sequence.NEXTVAL,
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
                   'Fascicolo in carico [CLASSIFICA_CODICE] [ANNO_FASCICOLO]/[NUMERO_7_FASCICOLO] [OGGETTO_FASCICOLO]',
                   'SMISTAMENTO_IN_CARICO_FASCICOLO',
                   'Presa In Carico - Fascicolo',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA =
                       'SMISTAMENTO_IN_CARICO_FASCICOLO' and ID_ENTE = d_id_ente);

            IF SQL%ROWCOUNT > 0
            THEN
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
                SELECT hibernate_sequence.NEXTVAL,
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
                   'Fascicolo assegnato [CLASSIFICA_CODICE] [ANNO_FASCICOLO]/[NUMERO_7_FASCICOLO] [OGGETTO_FASCICOLO]',
                   'SMISTAMENTO_IN_CARICO_ASSEGNATO_FASCICOLO',
                   'Smistamento assegnato - fascicolo',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA =
                       'SMISTAMENTO_IN_CARICO_ASSEGNATO_FASCICOLO' and ID_ENTE = d_id_ente);

            IF SQL%ROWCOUNT > 0
            THEN
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
                SELECT hibernate_sequence.NEXTVAL,
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
                   'Fascicolo da visionare [CLASSIFICA_CODICE] [ANNO_FASCICOLO]/[NUMERO_7_FASCICOLO] [OGGETTO_FASCICOLO]',
                   'SMISTAMENTO_DA_RICEVERE_CONOSCENZA_FASCICOLO',
                   'Smistamento inviato per conoscenza - fascicolo',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA =
                       'SMISTAMENTO_DA_RICEVERE_CONOSCENZA_FASCICOLO' and ID_ENTE = d_id_ente);

            IF SQL%ROWCOUNT > 0
            THEN
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
                SELECT hibernate_sequence.NEXTVAL,
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
            END IF;

        end loop;
END;
/