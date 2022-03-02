--liquibase formatted sql
--changeset esasdelli:4.0.0.0_20200221_100.gdo_notifiche_ins
/* Formatted on 11/12/2019 18:52:39 (QP5 v5.269.14213.34746) */
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
                   'Presa Visione - PG [ANNO_PROTOCOLLO] / [NUMERO_7_PROTOCOLLO]: [OGGETTO]',
                   'SMISTAMENTO_DA_RICEVERE_CONOSCENZA',
                   'Smistamento inviato per conoscenza',
                   'RPI',
                   '729',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'SMISTAMENTO_DA_RICEVERE_CONOSCENZA' and ID_ENTE = d_id_ente);

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
                   'In carico (assegnato) - PG [ANNO_PROTOCOLLO] / [NUMERO_7_PROTOCOLLO]: [OGGETTO]',
                   'SMISTAMENTO_IN_CARICO_ASSEGNATO',
                   'Smistamento assegnato',
                   'RPI',
                   '729',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'SMISTAMENTO_IN_CARICO_ASSEGNATO' and ID_ENTE = d_id_ente);

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
                   'In carico - PG [ANNO_PROTOCOLLO] / [NUMERO_7_PROTOCOLLO]: [OGGETTO]',
                   'SMISTAMENTO_IN_CARICO',
                   'Presa In Carico',
                   'RPI',
                   '729',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'SMISTAMENTO_IN_CARICO' and ID_ENTE = d_id_ente);

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
                   '[STATO_SMISTAMENTO] - [DATI_PROTOCOLLO]: [OGGETTO]',
                   'SMISTAMENTO_RIFIUTATO',
                   'Smistamento Rifiutato',
                   'RPI',
                   '729',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'SMISTAMENTO_RIFIUTATO' and ID_ENTE = d_id_ente);

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
                       'GET_SOGGETTO_REDATTORE',
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
                   'Prendi in carico - PG [ANNO_PROTOCOLLO] / [NUMERO_7_PROTOCOLLO]: [OGGETTO]',
                   'SMISTAMENTO_DA_RICEVERE_COMPETENZA',
                   'Smistamento Inviato per competenza',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'SMISTAMENTO_DA_RICEVERE_COMPETENZA' and ID_ENTE = d_id_ente);

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
                                       TESTO,
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
                   'PROTOCOLLO',
                   '[TIPO_PROTOCOLLO] [MOVIMENTO] [DATI_PROTOCOLLO] da [REDATTORE] - [NOME_NODO] - [PRIMO_DESTINATARIO] - [OGGETTO]',
                   '[OGGETTO]',
                   'CAMBIO_NODO',
                   'Cambio nodo',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'CAMBIO_NODO' and ID_ENTE = d_id_ente);

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
                       'GET_SOGGETTI_NODO_CORRENTE',
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
                                       MODALITA_INVIO,
                                       TIPO_NOTIFICA_SCRIVANIA)
            SELECT d_id,
                   0,
                   SYSDATE,
                   d_id_ente,
                   SYSDATE,
                   'PROTOCOLLO',
                   'Richiesta di Annullamento del documento n. [NUMERO_PROTOCOLLO_PROT]/[ANNO_PROTOCOLLO_PROT]',
                   'RICHIESTA_ANNULLAMENTO',
                   'Richiesta Annullamento',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST',
                   'RICHIESTA_ANNULLAMENTO'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'RICHIESTA_ANNULLAMENTO' and ID_ENTE = d_id_ente);

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
                       'GET_UTENTE_RICHIESTA_ANNULLAMENTO',
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
                                       MODALITA_INVIO,
                                       TIPO_NOTIFICA_SCRIVANIA)
            SELECT d_id,
                   0,
                   SYSDATE,
                   d_id_ente,
                   SYSDATE,
                   'PROTOCOLLO',
                   'La richiesta di annullamento del documento n. [NUMERO_PROTOCOLLO_PROT]/[ANNO_PROTOCOLLO_PROT] e'' stata accettata. L''annullamento avverra'' con successivo Provvedimento',
                   'ANNULLAMENTO_APPROVATO',
                   'Richiesta Annullamento Approvata',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST',
                   'ACCETTAZIONE_RICHIESTA_ANNULLAMENTO'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'ANNULLAMENTO_APPROVATO' and ID_ENTE = d_id_ente);

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
                       'GET_UTENTE_RICHIESTA_ANNULLAMENTO',
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
                                       MODALITA_INVIO,
                                       TIPO_NOTIFICA_SCRIVANIA)
            SELECT d_id,
                   0,
                   SYSDATE,
                   d_id_ente,
                   SYSDATE,
                   'PROTOCOLLO',
                   'La richiesta di annullamento del documento n. [NUMERO_PROTOCOLLO_PROT]/[ANNO_PROTOCOLLO_PROT] e'' stata rifiutata con la seguente motivazione: [MOTIVO_RIFIUTO]',
                   'ANNULLAMENTO_RIFIUTATO',
                   'Richiesta Annullamento Rifiutata',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST',
                   'RIFIUTA_RICHIESTA_ANNULLAMENTO'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'ANNULLAMENTO_RIFIUTATO' and ID_ENTE = d_id_ente);

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
                       'GET_UTENTE_RICHIESTA_ANNULLAMENTO',
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
                                       TESTO,
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
                   'PROTOCOLLO',
                   'Lettera [MOVIMENTO] [DATI_PROTOCOLLO] da [REDATTORE] - [NOME_NODO] - [PRIMO_DESTINATARIO] - [OGGETTO]',
                   '[OGGETTO]',
                   'CAMBIO_NODO_FIRMATARIO',
                   'Cambio nodo - Step DA INVIARE (Firmatario)',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'CAMBIO_NODO_FIRMATARIO' and ID_ENTE = d_id_ente);

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
                       'GET_SOGGETTO_DIRIGENTE',
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
                   'Prendi in carico : [OGGETTO]',
                   'SMISTAMENTO_DA_RICEVERE_COMPETENZA_DA_NON_PROTOCOLLARE',
                   'Smistamento Inviato per competenza - Da non protocollare',
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
                       'SMISTAMENTO_DA_RICEVERE_COMPETENZA_DA_NON_PROTOCOLLARE' and ID_ENTE = d_id_ente);

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
                   'In carico -  [OGGETTO]',
                   'SMISTAMENTO_IN_CARICO_DA_NON_PROTOCOLLARE',
                   'Presa In Carico - Da non protocollare',
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
                       'SMISTAMENTO_IN_CARICO_DA_NON_PROTOCOLLARE' and ID_ENTE = d_id_ente);

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
                                       TESTO,
                                       TIPO_NOTIFICA,
                                       TITOLO,
                                       UTENTE_INS,
                                       UTENTE_UPD,
                                       VALIDO,
                                       VALIDO_DAL,
                                       MODALITA_INVIO,
                                       TIPO_NOTIFICA_SCRIVANIA)
            SELECT d_id,
                   0,
                   SYSDATE,
                   d_id_ente,
                   SYSDATE,
                   'PROTOCOLLO',
                   'Non tutti i documenti associati al registro di emergenza sono stati protocollati - Oggetto: [OGGETTO]',
                   'Documento n. [NUMERO_PROTOCOLLO_PROT]/[ANNO_PROTOCOLLO_PROT] - [UNITA_PROTOCOLLANTE] [URL_DOCUMENTO]',
                   'NOTIFICA_PROTOCOLLO_EMERGENZA',
                   'Notifica Protocollo Emergenza',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST',
                   'PROTOCOLLO_EMERGENZA'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'NOTIFICA_PROTOCOLLO_EMERGENZA' and ID_ENTE = d_id_ente);

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
                       'GET_SOGGETTO_REDATTORE',
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
                   'In carico (assegnato): [OGGETTO]',
                   'SMISTAMENTO_IN_CARICO_ASSEGNATO_DA_NON_PROTOCOLLARE',
                   'Smistamento assegnato - Da non protocollare',
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
                       'SMISTAMENTO_IN_CARICO_ASSEGNATO_DA_NON_PROTOCOLLARE' and ID_ENTE = d_id_ente);

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
                   'Presa Visione: [OGGETTO]',
                   'SMISTAMENTO_DA_RICEVERE_CONOSCENZA_DA_NON_PROTOCOLLARE',
                   'Smistamento inviato per conoscenza - Da non protocollare',
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
                       'SMISTAMENTO_DA_RICEVERE_CONOSCENZA_DA_NON_PROTOCOLLARE' and ID_ENTE = d_id_ente);

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
                   '[STATO_SMISTAMENTO] : [OGGETTO]',
                   'SMISTAMENTO_RIFIUTATO_DA_NON_PROTOCOLLARE',
                   'Smistamento Rifiutato - Da non protocollare',
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
                       'SMISTAMENTO_RIFIUTATO_DA_NON_PROTOCOLLARE' and ID_ENTE = d_id_ente);

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
                       'GET_SOGGETTO_REDATTORE',
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
                   'PROTOCOLLO',
                   'Il registro con oggetto [OGGETTO] è fallito',
                   'ERRORE_REGISTRO_GIORNALIERO',
                   'Fallimento registro giornaliero',
                   'RPI',
                   'RPI',
                   'Y',
                   SYSDATE,
                   'JWORKLIST'
            FROM DUAL
            WHERE NOT EXISTS
                (SELECT 1
                 FROM GDO_NOTIFICHE
                 WHERE TIPO_NOTIFICA = 'ERRORE_REGISTRO_GIORNALIERO' and ID_ENTE = d_id_ente);

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
                       'GET_SOGGETTO_REDATTORE',
                       SYSDATE,
                       'RPI',
                       'RPI',
                       'Y',
                       0,
                       'COMPETENZA'
                FROM DUAL;
            END IF;

        end loop;
END;
/