--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_MEMO_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE ag_memo_utility
IS
    /******************************************************************************
     NOME:        AG_MEMO_UTILITY.
     DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                  MEMO.
     ANNOTAZIONI: Progetto AFFARI_GENERALI.
     REVISIONI:
     Rev. Data       Autore Descrizione
     ---- ---------- ------ ------------------------------------------------------
     00   05/07/2012 MM     Creazione.
     01   26/05/2013 MM     Modifiche release 2.3.
     02   13/08/2015 MM     Gestione riferimenti manuali a pg (associa_protocollo) e
                            eliminazione elimina_smistamenti (spostata in ag_smistamento)
     03   07/03/2017 MM     V2.7
     04   14/06/2019 MM     crea, crea_in_partenza, cancella e aggiorna
    ******************************************************************************/
    s_revisione   afc.t_revision := 'V1.04';

    FUNCTION versione
        RETURN VARCHAR2;

    FUNCTION get_instr_mail_aoo_uo (p_destinatari IN CLOB)
        RETURN VARCHAR2;

    PROCEDURE set_stato_from_prot (a_id_protocollo    NUMBER,
                                   a_stato_memo       VARCHAR2);

    FUNCTION get_memo (p_id_documento IN NUMBER, p_utente IN VARCHAR2)
        RETURN afc.t_ref_cursor;

    FUNCTION get_stati_memo
        RETURN afc.t_ref_cursor;

    FUNCTION get_memo_from_prot (p_id_doc_prot IN NUMBER)
        RETURN NUMBER;

    PROCEDURE set_stato_memo (p_id_documento NUMBER, p_stato IN VARCHAR2);

    FUNCTION get_data_memo (p_id_doc IN NUMBER)
        RETURN DATE;

    PROCEDURE scarta_memo_from_prot (p_id_doc_prot IN NUMBER);

    FUNCTION identifica_msg_spedito (p_id_protocollo       NUMBER,
                                     p_dest_address        VARCHAR2,
                                     p_dest_elenco         VARCHAR2,
                                     p_oggetto             VARCHAR2,
                                     p_data_msg_pec        VARCHAR2,
                                     p_oggetto_like        VARCHAR2,
                                     p_tipo_riferimento    VARCHAR2)
        RETURN NUMBER;

    FUNCTION confronta_elenco (p_elenco_origine    VARCHAR2,
                               p_elenco_match      VARCHAR2,
                               p_separatore        VARCHAR2)
        RETURN NUMBER;

    PROCEDURE ins_ag_cs_messaggi (p_id_protocollo       IN VARCHAR2,
                                  p_id_documento_memo   IN VARCHAR2,
                                  p_id_cs_messaggio     IN VARCHAR2);

    FUNCTION get_invii (p_id_documento NUMBER, p_tipo_relazione VARCHAR2)
        RETURN afc.t_ref_cursor;

    PROCEDURE elimina_smistamenti (p_id_memo NUMBER);

    --PROCEDURE elimina_smistamenti(p_idrif varchar2);

    PROCEDURE scarta_memo (p_id_documento NUMBER);

    FUNCTION get_prot_from_memo (p_id_memo IN NUMBER)
        RETURN NUMBER;

    PROCEDURE ASSOCIA_PROTOCOLLO (p_id_memo             NUMBER,
                                  p_anno_pg             NUMBER,
                                  p_tipo_registro_pg    VARCHAR2,
                                  p_numero_pg           NUMBER,
                                  p_codice_amm          VARCHAR2,
                                  p_codice_aoo          VARCHAR2,
                                  p_utente              VARCHAR2);

    PROCEDURE elimina_smistamenti (p_idrif VARCHAR2);

    FUNCTION crea (p_mittente                  VARCHAR2,
                   p_destinatari_clob          CLOB,
                   p_destinatari_cc_clob       CLOB,
                   p_destinatari_nascosti      VARCHAR2,
                   p_oggetto                   VARCHAR2,
                   p_corpo                     CLOB,
                   p_data_ricezione            DATE,
                   p_memo_in_partenza          VARCHAR2,
                   p_message_id                VARCHAR2,
                   p_motivo_no_proc            VARCHAR2,
                   p_processato_ag             VARCHAR2,
                   p_stato_memo                VARCHAR2,
                   p_data_stato_memo           DATE,
                   p_data_spedizione_memo      VARCHAR2,
                   p_class_cod                 VARCHAR2,
                   p_class_dal                 DATE,
                   p_destinatari               VARCHAR2,
                   p_destinatari_conoscenza    VARCHAR2,
                   p_fascicolo_anno            NUMBER,
                   p_fascicolo_numero          VARCHAR2,
                   p_idrif                     VARCHAR2,
                   p_riservato                 VARCHAR2,
                   p_tipo_messaggio            VARCHAR2,
                   p_tipo_corpo                VARCHAR2,
                   p_tag_mail                  VARCHAR2,
                   p_unita                     VARCHAR2,
                   p_utente                    VARCHAR2)
        RETURN NUMBER;

    FUNCTION crea_in_partenza (p_mittente                  VARCHAR2,
                               p_destinatari               CLOB,
                               p_destinatari_conoscenza    CLOB,
                               p_destinatari_nascosti      VARCHAR2,
                               p_oggetto                   VARCHAR2,
                               p_corpo                     CLOB,
                               p_utente                    VARCHAR2)
        RETURN NUMBER;

    PROCEDURE cancella (p_id_documento NUMBER, p_utente VARCHAR2);

    PROCEDURE aggiorna (p_id_documento                   NUMBER,
                        p_mittente                       VARCHAR2,
                        p_destinatari                    CLOB,
                        p_destinatari_conoscenza         CLOB,
                        p_destinatari_nascosti           VARCHAR2,
                        p_oggetto                        VARCHAR2,
                        p_corpo                          CLOB,
                        p_data_ricezione                 DATE,
                        p_memo_in_partenza               VARCHAR2,
                        p_message_id                     VARCHAR2,
                        p_motivo_no_proc                 VARCHAR2,
                        p_processato_ag                  VARCHAR2,
                        p_stato_memo                     VARCHAR2,
                        p_data_stato_memo                DATE,
                        p_data_spedizione_memo           VARCHAR2,
                        p_class_cod                      VARCHAR2,
                        p_class_dal                      DATE,
                        p_destinatari_cc_ente            VARCHAR2,
                        p_destinatari_ente               VARCHAR2,
                        p_fascicolo_anno                 NUMBER,
                        p_fascicolo_numero               VARCHAR2,
                        p_idrif                          VARCHAR2,
                        p_riservato                      VARCHAR2,
                        p_tipo_messaggio                 VARCHAR2,
                        p_tipo_corpo                     VARCHAR2,
                        p_tag_mail                       VARCHAR2,
                        p_spedito                        VARCHAR2,
                        p_generata_eccezione             VARCHAR2,
                        p_registrata_accettazione        VARCHAR2,
                        p_registrata_non_accettazione    VARCHAR2,
                        p_unita                          VARCHAR2,
                        p_utente                         VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY ag_memo_utility
IS
    /******************************************************************************
     NOME:        AG_MEMO_UTILITY
     DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                  MEMO.
     ANNOTAZIONI: Progetto AFFARI_GENERALI.
     REVISIONI:
     Rev. Data       Autore Descrizione
     ---- ---------- ------ ------------------------------------------------------
     000  05/07/2012 MM     Creazione.
     001  01/07/2014 MM     Mod.get_instr_mail_aoo_uo
     002  26/05/2013 MM     Modifiche release 2.3.
     003  14/07/2015 MM     Mod. get_memo e creata GET_PROT_FROM_MEMO
     004  13/08/2015 MM     Gestione riferimenti manuali a pg (associa_protocollo)
                            e eliminazione elimina_smistamenti (spostata in
                            ag_smistamento).
     005  13/09/2016 MM     Modificata procedure scarta_memo_from_prot
     006  13/09/2016 AM     Modificata set_stato_from_prot  (funziona anche per piu' seg memo )
     007  07/03/2017 MM     V2.7
     008  14/06/2019 MM     crea, crea_in_partenza, cancella e aggiorna
     009  07/01/2020 GM     Modificato get_invii
    ******************************************************************************/
    s_revisione_body   afc.t_revision := '009';

    FUNCTION versione
        RETURN VARCHAR2
        IS
        /******************************************************************************
         NOME:        VERSIONE
         DESCRIZIONE: Restituisce versione e revisione di distribuzione del package.
         RITORNA:     stringa VARCHAR2 contenente versione e revisione.
         NOTE:        Primo numero  : versione compatibilita del Package.
                      Secondo numero: revisione del Package specification.
                      Terzo numero  : revisione del Package body.
        ******************************************************************************/
    BEGIN
        RETURN afc.VERSION (s_revisione, s_revisione_body);
    END versione;

    FUNCTION get_instr_mail_aoo_uo (p_destinatari IN CLOB)
        RETURN VARCHAR2
        /*****************************************************************************
           NOME:        GET_INSTR_MAIL_AOO_UO

           DESCRIZIONE:   ritorna tutti e soli gli indirizzicontenuti in p_indirizzo
                          che corrispondono alla mail dell'aoo o di una uo dell'ente.

           RITORNO:   concatenazione degli indirizzi.

           Rev.  Data       Autore    Descrizione.
           000   05/07/2012 MM        Creazione.
           001   01/07/2014 MM        Mod.in modo che utilizzi seg_uo_mail invece che
                                      seg_unita.
        ********************************************************************************/
        IS
        d_dest        VARCHAR2 (4000);
        d_destinari   CLOB := p_destinatari;
    BEGIN
        d_destinari :=
                    ','
                    || REPLACE (
                            REPLACE (
                                    REPLACE (
                                            REPLACE (
                                                    REPLACE (
                                                            REPLACE (
                                                                    REPLACE (REPLACE (p_destinatari, ' ', ','),
                                                                             ';',
                                                                             ','),
                                                                    CHR (9),
                                                                    ','),
                                                            '<',
                                                            ','),
                                                    '>',
                                                    ','),
                                            '"',
                                            ','),
                                    CHR (10),
                                    ','),
                            CHR (13),
                            ',')
                    || ',';

        FOR indi
            IN (SELECT LOWER (inte.indirizzo) indirizzo_mail
                FROM so4_aoo aoo,
                     so4_indirizzi_telematici inte,
                     (SELECT pamm.valore codice_amministrazione,
                             paoo.valore codice_aoo
                      FROM parametri paoo, parametri pamm
                      WHERE     paoo.tipo_modello = '@agVar@'
                        AND pamm.codice =
                            'CODICE_AMM_'
                                || ag_utilities.get_defaultaooindex
                        AND paoo.codice =
                            'CODICE_AOO_'
                                || ag_utilities.get_defaultaooindex) para
                WHERE     inte.id_aoo = aoo.progr_aoo
                  AND inte.tipo_entita = 'AO'
                  AND inte.tipo_indirizzo IN ('F', 'I')
                  AND aoo.codice_amministrazione =
                      para.codice_amministrazione
                  AND aoo.codice_aoo = para.codice_aoo
                  AND aoo.al IS NULL
                  AND INSTR (d_destinari,
                             ',' || LOWER (inte.indirizzo) || ',') > 0
                UNION
                SELECT email
                FROM seg_uo_mail
                HAVING INSTR (d_destinari, ',' || LOWER (email) || ',') > 0
                GROUP BY email
                UNION
                SELECT mailfax
                FROM seg_uo_mail
                HAVING INSTR (d_destinari, ',' || LOWER (mailfax) || ',') > 0
                GROUP BY mailfax)
            LOOP
                d_dest := d_dest || ', ' || indi.indirizzo_mail;
            END LOOP;

        d_dest := SUBSTR (d_dest, 2);
        RETURN d_dest;
    EXCEPTION
        WHEN OTHERS
            THEN
                RAISE;
    END;

    PROCEDURE set_stato_from_prot (a_id_protocollo    NUMBER,
                                   a_stato_memo       VARCHAR2)
    AS
    BEGIN
        FOR cur0
            IN (SELECT id_documento_rif
                FROM riferimenti rife, documenti docu
                WHERE     rife.id_documento = a_id_protocollo
                  AND (   rife.tipo_relazione = 'MAIL'
                    OR rife.tipo_relazione = 'FAX')
                  AND docu.id_documento = rife.id_documento_rif
                  AND docu.stato_documento NOT IN ('CA', 'RE', 'PB'))
            LOOP
                UPDATE seg_memo_protocollo
                SET stato_memo = a_stato_memo
                WHERE     id_documento = cur0.id_documento_rif
                  AND stato_memo IN ('DP', 'DPS');
            END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN
                NULL;
        WHEN OTHERS
            THEN
                raise_application_error (
                        -20999,
                        'AG_MEMO_UTILITY.SET_STATO_FROM_PROT PER PROTOCOLLO '
                            || a_id_protocollo,
                        TRUE);
    END;

    FUNCTION get_memo (p_id_documento IN NUMBER, p_utente IN VARCHAR2)
        RETURN afc.t_ref_cursor
        IS
        /*****************************************************************************
           NOME:        GET_MEMO

           DESCRIZIONE:

           RITORNO:

           Rev.  Data       Autore    Descrizione.
           000   05/12/2008 SN        Prima emissione.
           003   14/07/2015 MM        Introduzione campo id_allegato.
        ********************************************************************************/
        d_result   afc.t_ref_cursor;
    BEGIN
        OPEN d_result FOR
            SELECT memo.*,
                   (CASE
                        WHEN INSTR (memo.oggetto, 'ANOMALIA MESSAGGIO') > 0
                            THEN
                            figlio.corpo
                        ELSE
                            memo.corpo
                       END)
                                                   corpo_mail,
                   DECODE (cs.stato_spedizione,
                           'SENTFAILED', 'Inoltro a casella per invio FALLITO',
                           'SENTOK', 'Inoltrato a casella per invio',
                           'SENDING', 'In fase di inoltro a casella',
                           'READYTOSEND', 'In attesa di inoltro a casella',
                           cs.stato_spedizione)
                                                   stato_spedizione,
                   seg_classificazioni.class_descr descrizione_classifica,
                   ag_fascicolo_utility.get_oggetto (seg_fascicoli.id_documento,
                                                     p_utente)
                                                   descrizione_fascicolo,
                   ag_fascicolo_utility.get_desc_ubicazione (
                           memo.class_cod,
                           TO_CHAR (memo.class_dal, 'dd/mm/yyyy'),
                           memo.fascicolo_anno,
                           memo.fascicolo_numero)
                                                   ubicazione_fascicolo,
                   ag_competenze_memo.lettura (memo.id_documento, p_utente)
                                                   lettura,
                   ag_competenze_memo.modifica (memo.id_documento, p_utente)
                                                   modifica,
                   ag_competenze_memo.eliminazione (memo.id_documento, p_utente)
                                                   eliminazione,
                   figlio.id_documento_rif
            FROM seg_memo_protocollo memo,
                 documenti docu,
                 ag_cs_messaggi cs,
                 (SELECT seg_classificazioni.*
                  FROM seg_classificazioni,
                       documenti docu_clas,
                       cartelle cart_clas
                  WHERE     docu_clas.id_documento =
                            seg_classificazioni.id_documento
                    AND docu_clas.stato_documento NOT IN ('CA',
                                                          'RE',
                                                          'PB')
                    AND cart_clas.id_documento_profilo =
                        seg_classificazioni.id_documento
                    AND NVL (cart_clas.stato, 'BO') <> 'CA')
                     seg_classificazioni,
                 (SELECT seg_fascicoli.*
                  FROM seg_fascicoli,
                       documenti docu_fasc,
                       cartelle cart_fasc
                  WHERE     docu_fasc.id_documento =
                            seg_fascicoli.id_documento
                    AND docu_fasc.stato_documento NOT IN ('CA',
                                                          'RE',
                                                          'PB')
                    AND cart_fasc.id_documento_profilo =
                        seg_fascicoli.id_documento
                    AND NVL (cart_fasc.stato, 'BO') <> 'CA')
                     seg_fascicoli,
                 (SELECT rif.id_documento,
                         rif.id_documento_rif,
                         memo.corpo corpo
                  FROM riferimenti rif, seg_memo_protocollo memo
                  WHERE     rif.tipo_relazione = 'PRINCIPALE'
                    AND memo.id_documento = rif.id_documento_rif) figlio
            WHERE --seg_fascicoli.codice_amministrazione(+) = memo.codice_amministrazione
              --AND seg_fascicoli.codice_aoo(+) = memo.codice_aoo
              --AND
                    seg_fascicoli.class_cod(+) = memo.class_cod
              AND seg_fascicoli.class_dal(+) = memo.class_dal
              AND seg_fascicoli.fascicolo_anno(+) = memo.fascicolo_anno
              AND seg_fascicoli.fascicolo_numero(+) = memo.fascicolo_numero
              --AND seg_classificazioni.codice_amministrazione(+) = memo.codice_amministrazione
              --AND seg_classificazioni.codice_aoo(+) = memo.codice_aoo
              AND seg_classificazioni.class_cod(+) = memo.class_cod
              AND seg_classificazioni.class_dal(+) = memo.class_dal
              AND memo.id_documento = p_id_documento
              AND docu.id_documento = memo.id_documento
              AND NVL (docu.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
              AND cs.id_documento_memo(+) = memo.id_documento
              AND figlio.id_documento(+) = memo.id_documento;

        RETURN d_result;
    EXCEPTION
        WHEN OTHERS
            THEN
                raise_application_error (-20999,
                                         'AG_MEMO_UTILITY.GET_MEMO: ' || SQLERRM);
    END;

    FUNCTION get_stati_memo
        RETURN afc.t_ref_cursor
        IS
        /*****************************************************************************
           NOME:   GET_STATI_MEMO

           DESCRIZIONE:

           RITORNO:

           Rev.  Data       Autore  Descrizione.
           00    05/12/2008  SN  Prima emissione.
        ********************************************************************************/
        d_result   afc.t_ref_cursor;
    BEGIN
        OPEN d_result FOR SELECT * FROM ag_stati_memo;

        RETURN d_result;
    EXCEPTION
        WHEN OTHERS
            THEN
                raise_application_error (
                        -20999,
                        'AG_MEMO_UTILITY.GET_STATI_MEMO: ' || SQLERRM);
    END;

    FUNCTION get_data_memo (p_id_doc IN NUMBER)
        RETURN DATE
        IS
        ret   DATE;
    BEGIN
        SELECT memo.data_ricezione
        INTO ret
        FROM seg_memo_protocollo memo
        WHERE memo.id_documento = p_id_doc;

        IF ret IS NULL
        THEN
            SELECT MIN (data_aggiornamento)
            INTO ret
            FROM stati_documento
            WHERE id_documento = p_id_doc;
        END IF;

        RETURN ret;
    EXCEPTION
        WHEN OTHERS
            THEN
                RETURN NULL;
    END;

    FUNCTION get_memo_from_prot (p_id_doc_prot IN NUMBER)
        RETURN NUMBER
        IS
        /*****************************************************************************
           NOME:        GET_MEMO_FROM_PROT

           DESCRIZIONE:

           RITORNO:

           Rev.  Data       Autore  Descrizione.
           00    05/12/2008  SN  Prima emissione.
        ********************************************************************************/
        d_id_doc_memo   NUMBER;
    BEGIN
        SELECT memo.id_documento
        INTO d_id_doc_memo
        FROM seg_memo_protocollo memo, riferimenti rife
        WHERE     rife.id_documento = p_id_doc_prot
          AND rife.id_documento_rif = memo.id_documento
          AND (rife.tipo_relazione = 'MAIL' OR rife.tipo_relazione = 'FAX');

        RETURN d_id_doc_memo;
    EXCEPTION
        WHEN OTHERS
            THEN
                RETURN -1;
    END;

    PROCEDURE scarta_memo_from_prot (p_id_doc_prot IN NUMBER)
        IS
        /*****************************************************************************
           NOME:        scarta_memo_from_prot

           DESCRIZIONE:

           RITORNO:

           Rev.  Data       Autore    Descrizione.
           00    05/12/2008 SN        Prima emissione.
           005   13/09/2016 MM        Cancellazione ag_proto_memo_key.
        ********************************************************************************/
        d_id_doc_memo   NUMBER;
    BEGIN
        FOR m
            IN (SELECT memo.id_documento, stato_memo
                FROM seg_memo_protocollo memo, riferimenti rife
                WHERE     rife.id_documento = p_id_doc_prot
                  AND rife.id_documento_rif = memo.id_documento
                  AND (   rife.tipo_relazione = 'MAIL'
                    OR rife.tipo_relazione = 'FAX'))
            LOOP
                DELETE riferimenti
                WHERE     id_documento_rif = m.id_documento
                  AND (tipo_relazione = 'MAIL' OR tipo_relazione = 'FAX')
                  AND id_documento = p_id_doc_prot;

                DELETE ag_proto_memo_key
                WHERE id_protocollo = p_id_doc_prot AND id_memo = m.id_documento;

                DECLARE
                    esistono_prot   NUMBER := 0;
                BEGIN
                    SELECT COUNT (*)
                    INTO esistono_prot
                    FROM riferimenti
                    WHERE     id_documento_rif = m.id_documento
                      AND (tipo_relazione = 'MAIL' OR tipo_relazione = 'FAX')
                      AND riferimenti.id_documento != p_id_doc_prot;

                    IF esistono_prot = 0 AND m.stato_memo IN ('DP', 'DPS')
                    THEN
                        ag_memo_utility.set_stato_memo (m.id_documento, 'SC');
                    END IF;
                END;
            END LOOP;
    EXCEPTION
        WHEN OTHERS
            THEN
                raise_application_error (-20999, 'Fallito scarto memo. ' || SQLERRM);
    END;

    PROCEDURE set_stato_memo (p_id_documento NUMBER, p_stato IN VARCHAR2)
        IS
        /*****************************************************************************
           NOME:   SET_STATO_MEMO

           DESCRIZIONE:

           RITORNO:

           Rev.  Data       Autore  Descrizione.
           00    05/12/2008  SN  Prima emissione.
        ********************************************************************************/
    BEGIN
        UPDATE seg_memo_protocollo
        SET stato_memo = p_stato
        WHERE id_documento = p_id_documento;
    EXCEPTION
        WHEN OTHERS
            THEN
                raise_application_error (
                        -20999,
                        'AG_MEMO_UTILITY.SET_STATO_MEMO: ' || SQLERRM);
    END;

    FUNCTION concat_separatore (p_origine VARCHAR2, p_separatore VARCHAR2)
        RETURN VARCHAR2
        IS
        dep_origine   VARCHAR2 (32000) := p_origine;
    BEGIN
        IF SUBSTR (dep_origine, LENGTH (dep_origine)) != p_separatore
        THEN
            dep_origine := dep_origine || p_separatore;
        END IF;

        IF SUBSTR (dep_origine, 1, 1) != p_separatore
        THEN
            dep_origine := p_separatore || dep_origine;
        END IF;

        RETURN dep_origine;
    END;

    FUNCTION confronta_elenco (p_elenco_origine    VARCHAR2,
                               p_elenco_match      VARCHAR2,
                               p_separatore        VARCHAR2)
        RETURN NUMBER
        IS
        retval               NUMBER := 0;
        dep_substr           VARCHAR2 (32000);
        dep_elenco_origine   VARCHAR2 (32000);
        dep_prima            VARCHAR2 (32000);
        dep_elenco_match     VARCHAR2 (32000);
    BEGIN
        dep_elenco_origine := concat_separatore (p_elenco_origine, p_separatore);
        dep_elenco_match := concat_separatore (p_elenco_match, p_separatore);

        WHILE dep_elenco_match IS NOT NULL OR dep_elenco_match != p_separatore
            LOOP
                dep_substr :=
                            afc.get_substr (dep_elenco_match, p_separatore) || p_separatore;

                IF INSTR (dep_elenco_origine, dep_substr) = 0
                THEN
                    EXIT;
                END IF;

                dep_prima := afc.get_substr (dep_elenco_origine, dep_substr);
                dep_elenco_origine := NVL (dep_prima, '') || dep_elenco_origine;

                IF     dep_elenco_origine IS NULL
                    AND (   dep_elenco_match IS NOT NULL
                        OR dep_elenco_match != p_separatore)
                THEN
                    EXIT;
                END IF;
            END LOOP;

        IF     dep_elenco_origine IS NULL
            AND (dep_elenco_match IS NULL OR dep_elenco_match = p_separatore)
        THEN
            retval := 1;
        END IF;

        RETURN retval;
    END confronta_elenco;

    FUNCTION identifica_msg_spedito (p_id_protocollo       NUMBER,
                                     p_dest_address        VARCHAR2,
                                     p_dest_elenco         VARCHAR2,
                                     p_oggetto             VARCHAR2,
                                     p_data_msg_pec        VARCHAR2,
                                     p_oggetto_like        VARCHAR2,
                                     p_tipo_riferimento    VARCHAR2)
        RETURN NUMBER
    AS
        dep_id_messaggio   NUMBER;
        dep_consegnato     NUMBER;
        dep_data           DATE
                                        := TO_DATE (p_data_msg_pec, 'dd/mm/yyyy hh24:mi:ss');
        dep_separatore     VARCHAR2 (1) := ';';
    BEGIN
        FOR m
            IN (  SELECT seg_memo_protocollo.id_documento,
                         oggetto,
                         data_spedizione_memo,
                         UPPER (REPLACE (destinatari, ';', ','))
                  FROM seg_memo_protocollo,
                       riferimenti,
                       documenti,
                       activity_log
                  WHERE     riferimenti.id_documento = p_id_protocollo
                    AND tipo_relazione = p_tipo_riferimento
                    AND seg_memo_protocollo.id_documento =
                        riferimenti.id_documento_rif
                    AND seg_memo_protocollo.memo_in_partenza = 'Y'
                    AND INSTR (
                                    dep_separatore
                                    || UPPER (destinatari)
                                    || dep_separatore,
                                    dep_separatore
                                        || UPPER (p_dest_address)
                                        || dep_separatore) > 0
                    AND UPPER (oggetto) LIKE UPPER (p_oggetto)
                    AND documenti.id_documento =
                        seg_memo_protocollo.id_documento
                    AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                    AND activity_log.id_documento = documenti.id_documento
                    AND activity_log.tipo_azione = 'C'
                    AND dep_data >= activity_log.data_aggiornamento
                    AND ag_memo_utility.confronta_elenco (
                                UPPER (seg_memo_protocollo.destinatari),
                                UPPER (p_dest_elenco),
                                dep_separatore) = 1
                  ORDER BY seg_memo_protocollo.id_documento)
            LOOP
                dep_id_messaggio := m.id_documento;

                BEGIN
                    SELECT 1
                    INTO dep_consegnato
                    FROM riferimenti, seg_memo_protocollo
                    WHERE     riferimenti.id_documento = dep_id_messaggio
                      AND tipo_relazione = 'PROT_PEC'
                      AND id_documento_rif = seg_memo_protocollo.id_documento
                      AND UPPER (seg_memo_protocollo.oggetto) LIKE
                          UPPER (p_oggetto_like);
                EXCEPTION
                    WHEN NO_DATA_FOUND
                        THEN
                            EXIT;
                END;
            END LOOP;

        RETURN dep_id_messaggio;
    END identifica_msg_spedito;

    PROCEDURE ins_ag_cs_messaggi (p_id_protocollo       IN VARCHAR2,
                                  p_id_documento_memo   IN VARCHAR2,
                                  p_id_cs_messaggio     IN VARCHAR2)
        IS
        d_id_protocollo   NUMBER := TO_NUMBER (p_id_protocollo);
    BEGIN
        IF d_id_protocollo IS NULL
        THEN
            BEGIN
                -- ricavo id doc di protocollo
                SELECT r.id_documento
                INTO d_id_protocollo
                FROM riferimenti r, documenti d
                WHERE     id_documento_rif = p_id_documento_memo
                  AND tipo_relazione = 'MAIL'
                  AND r.id_documento = d.id_documento
                  AND d.stato_documento NOT IN ('CA', 'RE', 'PB');
            EXCEPTION
                WHEN OTHERS
                    THEN
                        NULL;
            END;
        END IF;

        INSERT
        INTO ag_cs_messaggi (id_documento_protocollo,
                             id_documento_memo,
                             id_cs_messaggio)
        VALUES (d_id_protocollo, p_id_documento_memo, p_id_cs_messaggio);
    END;

    FUNCTION get_invii (p_id_documento NUMBER, p_tipo_relazione VARCHAR2)
        RETURN afc.t_ref_cursor
        IS
        d_result   afc.t_ref_cursor;
    BEGIN
        OPEN d_result FOR
            SELECT rife.id_documento,
                   rife.id_documento_rif,
                   rife.data_aggiornamento,
                   gdc_utility_pkg.f_get_url_oggetto (
                           '',
                           '',
                           DECODE (p_id_documento,
                                   rife.id_documento, id_documento_rif,
                                   rife.id_documento),
                           'D',
                           '',
                           '',
                           '',
                           'R',
                           '',
                           '',
                           '5',
                           'N')
                          url,
                   DECODE (p_id_documento,
                           rife.id_documento, 'attivo',
                           'passivo')
                          tipo_riferimento,
                   memo.oggetto,
                   (memo.destinatari || ' ' || memo.destinatari_conoscenza)
                       AS destinatari,
                   DECODE (cs.stato_spedizione,
                           'SENTFAILED', 'Inoltro a casella per invio FALLITO',
                           'SENTOK', 'Inoltrato a casella per invio',
                           'SENDING', 'In fase di inoltro a casella',
                           'READYTOSEND', 'In attesa di inoltro a casella',
                           cs.stato_spedizione)
                          stato_spedizione,
                   DECODE (cs.stato_spedizione, 'SENTOK', cs.data_modifica, '')
                          data_spedizione
            FROM riferimenti rife,
                 documenti docu,
                 documenti docu_rif,
                 seg_memo_protocollo memo,
                 ag_cs_messaggi cs
            WHERE     (   rife.id_documento = p_id_documento
                OR id_documento_rif = p_id_documento)
              AND docu.id_documento = rife.id_documento
              AND NVL (docu.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
              AND docu_rif.id_documento = rife.id_documento_rif
              AND NVL (docu_rif.stato_documento, 'BO') NOT IN ('CA',
                                                               'RE',
                                                               'PB')
              AND rife.tipo_relazione = p_tipo_relazione
              AND memo.id_documento =
                  DECODE (p_id_documento,
                          rife.id_documento, id_documento_rif,
                          rife.id_documento)
              AND cs.id_documento_memo(+) = memo.id_documento
              AND memo.memo_in_partenza = 'Y'
            ORDER BY rife.data_aggiornamento;

        RETURN d_result;
    EXCEPTION
        WHEN OTHERS
            THEN
                raise_application_error (-20999,
                                         'ag_memo_utility.get_invii: ' || SQLERRM);
    END;

    PROCEDURE elimina_smistamenti (p_id_memo NUMBER)
        IS
        d_idrif   VARCHAR2 (100);
    BEGIN
        SELECT idrif
        INTO d_idrif
        FROM seg_memo_protocollo
        WHERE id_documento = p_id_memo;

        ag_smistamento.elimina_smistamenti (d_idrif);
    END;

    PROCEDURE elimina_smistamenti (p_idrif VARCHAR2)
        IS
        a_ret   NUMBER;
    BEGIN
        ag_smistamento.elimina_smistamenti (p_idrif);
    END;

    PROCEDURE scarta_memo (p_id_documento NUMBER)
        IS
    BEGIN
        UPDATE seg_memo_protocollo
        SET STATO_MEMO = 'SC',
            CLASS_COD = '',
            CLASS_DAL = NULL,
            FASCICOLO_ANNO = NULL,
            FASCICOLO_NUMERO = NULL
        WHERE id_documento = p_id_documento AND stato_memo IN ('DG', 'NP');
    END scarta_memo;

    FUNCTION get_prot_from_memo (p_id_memo IN NUMBER)
        RETURN NUMBER
        IS
        /*****************************************************************************
           NOME:        GET_PROT_FROM_MEMO

           DESCRIZIONE:

           RITORNO:

           Rev.  Data       Autore Descrizione.
           003   16/07/2015 MM     Prima emissione.
        ********************************************************************************/
        d_id_prot   NUMBER;
    BEGIN
        SELECT rife.id_documento
        INTO d_id_prot
        FROM documenti proto, riferimenti rife
        WHERE     proto.id_documento = rife.id_documento
          AND rife.id_documento_rif IN (SELECT NVL (
                                                       MIN (id_documento_rif),
                                                       p_id_memo)
                                        FROM riferimenti
                                        WHERE     id_documento =
                                                  p_id_memo
                                          AND tipo_relazione =
                                              'PRINCIPALE')
          AND rife.tipo_relazione IN ('MAIL', 'FAX')
          AND proto.stato_documento NOT IN ('CA', 'RE', 'PB');

        RETURN d_id_prot;
    EXCEPTION
        WHEN OTHERS
            THEN
                RETURN -1;
    END;

    PROCEDURE associa_protocollo (p_id_memo             NUMBER,
                                  p_anno_pg             NUMBER,
                                  p_tipo_registro_pg    VARCHAR2,
                                  p_numero_pg           NUMBER,
                                  p_codice_amm          VARCHAR2,
                                  p_codice_aoo          VARCHAR2,
                                  p_utente              VARCHAR2)
        IS
        /*****************************************************************************
           NOME:        ASSOCIA_PROTOCOLLO

           DESCRIZIONE: Gestione riferimenti manuali a pg: crea riferimento tra memo
                        e protocollo e mette lo stato del memo a G (Gestito).

           Rev. Data       Autore Descrizione.
           004  13/08/2015 MM     Creazione.
        *******************************************************************************/
        d_id_prot         NUMBER;
        d_tipo_registro   VARCHAR2 (100)
            := NVL (p_tipo_registro_pg,
                    AG_PARAMETRO.GET_VALORE ('TIPO_REGISTRO',
                                             p_codice_Amm,
                                             p_codice_aoo,
                                             ''));
    BEGIN
        BEGIN
            SELECT id_documento
            INTO d_id_prot
            FROM proto_view
            WHERE     anno = p_anno_pg
              AND tipo_registro = d_tipo_registro
              AND numero = p_numero_pg
              AND codice_amministrazione = p_codice_amm
              AND codice_aoo = p_codice_aoo;
        EXCEPTION
            WHEN NO_DATA_FOUND
                THEN
                    raise_application_error (
                            -20999,
                            d_tipo_registro
                                || ' '
                                || p_anno_pg
                                || '/'
                                || p_numero_pg
                                || ' per amm. '
                                || p_codice_amm
                                || ' e aoo '
                                || p_codice_aoo
                                || 'non esistente.');
            WHEN OTHERS
                THEN
                    raise_application_error (
                            -20999,
                            d_tipo_registro
                                || ' '
                                || p_anno_pg
                                || '/'
                                || p_numero_pg
                                || ' per amm. '
                                || p_codice_amm
                                || ' e aoo '
                                || p_codice_aoo
                                || ' non selezionabile: '
                                || SQLERRM);
        END;

        BEGIN
            INSERT INTO riferimenti (id_documento,
                                     id_documento_rif,
                                     libreria_remota,
                                     area,
                                     tipo_relazione,
                                     data_aggiornamento,
                                     utente_aggiornamento)
            VALUES (d_id_prot,
                    p_id_memo,
                    NULL,
                    'SEGRETERIA.PROTOCOLLO',
                    'PROT_RIFE',
                    SYSDATE,
                    p_utente);

            IF SQL%ROWCOUNT = 0
            THEN
                raise_application_error (
                        -20999,
                        'Riferimento a '
                            || d_tipo_registro
                            || ' '
                            || p_anno_pg
                            || '/'
                            || p_numero_pg
                            || ' per amm. '
                            || p_codice_amm
                            || ' e aoo '
                            || p_codice_aoo
                            || ' non inserito: '
                            || SQLERRM);
            END IF;

            set_stato_memo (p_id_memo, 'G');
        END;
    END;

    FUNCTION crea_in_partenza (p_mittente                  VARCHAR2,
                               p_destinatari               CLOB,
                               p_destinatari_conoscenza    CLOB,
                               p_destinatari_nascosti      VARCHAR2,
                               p_oggetto                   VARCHAR2,
                               p_corpo                     CLOB,
                               p_utente                    VARCHAR2)
        RETURN NUMBER
        IS
        dep_id_nuovo             NUMBER;
        d_data_ricezione         DATE;
        d_memo_in_partenza       VARCHAR2 (32767);
        d_message_id             VARCHAR2 (32767);
        d_motivo_no_proc         VARCHAR2 (32767);
        d_processato_ag          VARCHAR2 (32767);
        d_stato_memo             VARCHAR2 (32767);
        d_data_stato_memo        DATE;
        d_data_spedizione_memo   VARCHAR2 (32767);
        d_class_cod              VARCHAR2 (32767);
        d_class_dal              DATE;
        d_fascicolo_anno         NUMBER;
        d_fascicolo_numero       VARCHAR2 (32767);
        d_destinatari_cc_ente    VARCHAR2 (32767);
        d_destinatari_ente       VARCHAR2 (32767);
        d_idrif                  VARCHAR2 (32767);
        d_riservato              VARCHAR2 (32767);
        d_tipo_messaggio         VARCHAR2 (32767);
        d_tipo_corpo             VARCHAR2 (32767);
        d_tag_mail               VARCHAR2 (32767);
        d_unita                  VARCHAR2 (32767);
    BEGIN
        d_data_ricezione := NULL;
        d_memo_in_partenza := 'Y';
        d_message_id := NULL;
        d_motivo_no_proc := NULL;
        d_processato_ag := NULL;
        d_stato_memo := 'DG';
        d_data_stato_memo := NULL;
        d_data_spedizione_memo := NULL;
        d_class_cod := NULL;
        d_class_dal := NULL;
        d_destinatari_cc_ente := NULL;
        d_destinatari_ente := NULL;
        d_fascicolo_anno := NULL;
        d_fascicolo_numero := NULL;
        d_riservato := 'N';
        d_tipo_messaggio := 'PEC';
        d_tipo_corpo := NULL;
        d_tag_mail := NULL;
        d_unita := NULL;

        IF d_idrif IS NULL
        THEN
            SELECT TO_CHAR (SEQ_IDRIF.NEXTVAL) INTO d_idrif FROM DUAL;
        END IF;

        dep_id_nuovo :=
                crea (p_mittente,
                      p_destinatari,
                      p_destinatari_conoscenza,
                      p_destinatari_nascosti,
                      p_oggetto,
                      p_corpo,
                      d_data_ricezione,
                      d_memo_in_partenza,
                      d_message_id,
                      d_motivo_no_proc,
                      d_processato_ag,
                      d_stato_memo,
                      d_data_stato_memo,
                      d_data_spedizione_memo,
                      d_class_cod,
                      d_class_dal,
                      d_destinatari_ente,
                      d_destinatari_cc_ente,
                      d_fascicolo_anno,
                      d_fascicolo_numero,
                      d_idrif,
                      d_riservato,
                      d_tipo_messaggio,
                      d_tipo_corpo,
                      d_tag_mail,
                      d_unita,
                      p_utente);
    END;

    FUNCTION crea (p_mittente                  VARCHAR2,
                   p_destinatari_clob          CLOB,
                   p_destinatari_cc_clob       CLOB,
                   p_destinatari_nascosti      VARCHAR2,
                   p_oggetto                   VARCHAR2,
                   p_corpo                     CLOB,
                   p_data_ricezione            DATE,
                   p_memo_in_partenza          VARCHAR2,
                   p_message_id                VARCHAR2,
                   p_motivo_no_proc            VARCHAR2,
                   p_processato_ag             VARCHAR2,
                   p_stato_memo                VARCHAR2,
                   p_data_stato_memo           DATE,
                   p_data_spedizione_memo      VARCHAR2,
                   p_class_cod                 VARCHAR2,
                   p_class_dal                 DATE,
                   p_destinatari               VARCHAR2,
                   p_destinatari_conoscenza    VARCHAR2,
                   p_fascicolo_anno            NUMBER,
                   p_fascicolo_numero          VARCHAR2,
                   p_idrif                     VARCHAR2,
                   p_riservato                 VARCHAR2,
                   p_tipo_messaggio            VARCHAR2,
                   p_tipo_corpo                VARCHAR2,
                   p_tag_mail                  VARCHAR2,
                   p_unita                     VARCHAR2,
                   p_utente                    VARCHAR2)
        RETURN NUMBER
        IS
        dep_id_nuovo   NUMBER;
        dep_idrif      VARCHAR2 (255);
    BEGIN
        IF p_mittente IS NULL OR p_destinatari IS NULL
        THEN
            raise_application_error (
                    -20999,
                    'Indicare almeno il mittente (p_mittente) ed i destinatari (p_destinatari).');
        END IF;

        dep_id_nuovo :=
                gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                            p_modello                   => 'MEMO_PROTOCOLLO',
                                            p_cr                        => NULL,
                                            p_utente                    => p_utente,
                                            p_crea_record_orizzontale   => 1);


        UPDATE seg_memo_protocollo
        SET corpo = p_corpo,
            data_ricezione = p_data_ricezione,
            destinatari = p_destinatari,
            destinatari_conoscenza = p_destinatari_conoscenza,
            destinatari_nascosti = p_destinatari_nascosti,
            generata_eccezione = 'N',
            memo_in_partenza = p_memo_in_partenza,
            message_id = p_message_id,
            mittente = p_mittente,
            motivo_no_proc = p_motivo_no_proc,
            oggetto = p_oggetto,
            processato_ag = p_processato_ag,
            spedito = 'N',
            stato_memo = p_stato_memo,
            data_stato_memo = p_data_stato_memo,
            data_spedizione_memo = p_data_spedizione_memo,
            class_cod = p_class_cod,
            class_dal = p_class_dal,
            destinatari_cc_clob = p_destinatari_cc_clob,
            destinatari_clob = p_destinatari_clob,
            fascicolo_anno = p_fascicolo_anno,
            fascicolo_numero = p_fascicolo_numero,
            idrif = p_idrif,
            riservato = p_riservato,
            tag_mail = p_tag_mail,
            tipo_messaggio = p_tipo_messaggio,
            unita_protocollante = p_unitA,
            utente_protocollante = p_utente,
            tipo_corpo = p_tipo_corpo,
            registrata_accettazione = 'N',
            registrata_non_accettazione = 'N'
        WHERE id_documento = dep_id_nuovo;

        RETURN dep_id_nuovo;
    EXCEPTION
        WHEN OTHERS
            THEN
                RAISE;
    END;

    PROCEDURE cancella (p_id_documento NUMBER, p_utente VARCHAR2)
        IS
        d_ret   NUMBER;
    BEGIN
        d_ret := GDM_PROFILO.CANCELLA (p_id_documento, p_utente);
    END;

    PROCEDURE aggiorna (p_id_documento                   NUMBER,
                        p_mittente                       VARCHAR2,
                        p_destinatari                    CLOB,
                        p_destinatari_conoscenza         CLOB,
                        p_destinatari_nascosti           VARCHAR2,
                        p_oggetto                        VARCHAR2,
                        p_corpo                          CLOB,
                        p_data_ricezione                 DATE,
                        p_memo_in_partenza               VARCHAR2,
                        p_message_id                     VARCHAR2,
                        p_motivo_no_proc                 VARCHAR2,
                        p_processato_ag                  VARCHAR2,
                        p_stato_memo                     VARCHAR2,
                        p_data_stato_memo                DATE,
                        p_data_spedizione_memo           VARCHAR2,
                        p_class_cod                      VARCHAR2,
                        p_class_dal                      DATE,
                        p_destinatari_cc_ente            VARCHAR2,
                        p_destinatari_ente               VARCHAR2,
                        p_fascicolo_anno                 NUMBER,
                        p_fascicolo_numero               VARCHAR2,
                        p_idrif                          VARCHAR2,
                        p_riservato                      VARCHAR2,
                        p_tipo_messaggio                 VARCHAR2,
                        p_tipo_corpo                     VARCHAR2,
                        p_tag_mail                       VARCHAR2,
                        p_spedito                        VARCHAR2,
                        p_generata_eccezione             VARCHAR2,
                        p_registrata_accettazione        VARCHAR2,
                        p_registrata_non_accettazione    VARCHAR2,
                        p_unita                          VARCHAR2,
                        p_utente                         VARCHAR2)
        IS
    BEGIN
        UPDATE seg_memo_protocollo
        SET corpo = p_corpo,
            data_ricezione = p_data_ricezione,
            destinatari = p_destinatari_ente,
            destinatari_conoscenza = p_destinatari_cc_ente,
            destinatari_nascosti = p_destinatari_nascosti,
            generata_eccezione = p_generata_eccezione,
            memo_in_partenza = p_memo_in_partenza,
            message_id = p_message_id,
            mittente = p_mittente,
            motivo_no_proc = p_motivo_no_proc,
            oggetto = p_oggetto,
            processato_ag = p_processato_ag,
            spedito = p_spedito,
            stato_memo = p_stato_memo,
            data_stato_memo = p_data_stato_memo,
            data_spedizione_memo = p_data_spedizione_memo,
            class_cod = p_class_cod,
            class_dal = p_class_dal,
            destinatari_cc_clob = p_destinatari_conoscenza,
            destinatari_clob = p_destinatari,
            fascicolo_anno = p_fascicolo_anno,
            fascicolo_numero = p_fascicolo_numero,
            idrif = p_idrif,
            riservato = p_riservato,
            tag_mail = p_tag_mail,
            tipo_messaggio = p_tipo_messaggio,
            unita_protocollante = p_unita,
            utente_protocollante = p_utente,
            tipo_corpo = p_tipo_corpo,
            registrata_accettazione = p_registrata_accettazione,
            registrata_non_accettazione = p_registrata_non_accettazione
        WHERE id_documento = p_id_documento;
    EXCEPTION
        WHEN OTHERS
            THEN
                RAISE;
    END;
END;
/
