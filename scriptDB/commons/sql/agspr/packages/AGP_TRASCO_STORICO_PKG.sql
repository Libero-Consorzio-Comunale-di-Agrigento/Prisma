--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_TRASCO_STORICO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_TRASCO_STORICO_PKG
IS
   /******************************************************************************
    NOME:        AGP_TRASCO_STORICO_PKG
    DESCRIZIONE: Gestione TRASCO da GDM.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    23/12/2019    mmalferrari    Prima emissione.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.00';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE crea (p_id_documento_gdm NUMBER);

   FUNCTION get_valore_log (p_tabella    VARCHAR2,
                            p_campo      VARCHAR2,
                            p_id         NUMBER)
      RETURN VARCHAR2;

   PROCEDURE crea_storico_protocollo (
      p_id_documento_gdm      NUMBER,
      p_id_documento_agspr    NUMBER DEFAULT NULL);

   PROCEDURE crea_storico_corrispondenti (p_id_documento_gdm NUMBER);

   PROCEDURE crea_storico_file_alle (p_id_documento_gdm NUMBER);

   PROCEDURE elimina_storico_documento (p_id_documento_gdm NUMBER);
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_TRASCO_STORICO_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_TRASCO_STORICO_PKG
    DESCRIZIONE   Gestione TRASCO da GDM.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   23/12/2019    mmalferrari   Prima emissione.
    001   02/04/2020    mmalferrari   Modificate crea_storico_allegati e
                                      crea_storico_corrispondenti
    002   27/05/2020    mmalferrari   Modificata crea e get_revinfo
    003   16/07/2020    mmalferrari   Modificata crea_storico_allegati per gestire
                                      substr della descrizione a 255
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '003';

   --------------------------------------------------------------------------------

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        versione
    DESCRIZIONE: Versione e revisione di distribuzione del package.
    RITORNA:     varchar2 stringa contenente versione e revisione.
    NOTE:        Primo numero  p_ versione compatibilità del Package.
                 Secondo numerop_ revisione del Package specification.
                 Terzo numero  p_ revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   --------------------------------------------------------------------------------

   FUNCTION get_valore_log (p_tabella    VARCHAR2,
                            p_campo      VARCHAR2,
                            p_id         NUMBER)
      RETURN VARCHAR2
   IS
      d_sql      VARCHAR2 (32000);
      d_return   VARCHAR2 (32000);
   BEGIN
      d_sql :=
            'SELECT '
         || p_campo
         || '  FROM '
         || p_tabella
         || ' WHERE ID = '
         || p_id
         || ' AND '
         || p_id
         || ' = 0 '
         || ' UNION '
         || 'SELECT '
         || p_campo
         || '  FROM '
         || p_tabella
         || ' WHERE '
         || p_id
         || ' > 0 AND '
         || p_campo
         || ' IS NOT NULL AND id = (SELECT MAX (id) FROM '
         || p_tabella
         || ' WHERE '
         || p_campo
         || ' IS NOT NULL AND id BETWEEN 1 AND '
         || p_id
         || ')';

      --DBMS_OUTPUT.put_line (d_sql);

      EXECUTE IMMEDIATE d_sql INTO d_return;

      RETURN d_return;
   END;

   --------------------------------------------------------------------------------

   FUNCTION get_id_rev (p_id_documento_prot          NUMBER,
                        p_id_documento_gdm           NUMBER,
                        p_log_data                   DATE,
                        p_log_utente                 VARCHAR2,
                        p_log_tabella_id             NUMBER,
                        p_log_tabella                VARCHAR2,
                        p_esiste_rev          IN OUT NUMBER,
                        p_esiste_rev_prot     IN OUT NUMBER)
      RETURN NUMBER
   IS
      d_id_rev   NUMBER;
   BEGIN
      BEGIN
         SELECT rev
           INTO d_id_rev
           FROM TEMP_STORICO
          WHERE     ID_DOCUMENTO = p_id_documento_prot
                AND LOG_DATA = p_LOG_DATA
                AND LOG_UTENTE = p_LOG_UTENTE
                AND tabella = 'GDO_DOCUMENTI_LOG'
                AND ROWNUM = 1;

         p_esiste_rev_prot := 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_rev := NULL;
            p_esiste_rev_prot := 0;
      END;

      IF p_esiste_rev_prot = 0
      THEN
         BEGIN
            SELECT rev
              INTO d_id_rev
              FROM GDO_DOCUMENTI_LOG
             WHERE     id_documento = p_id_documento_prot
                   AND data_ins = p_LOG_DATA
                   AND utente_ins = p_LOG_UTENTE;

            p_esiste_rev_prot := 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_id_rev := NULL;
               p_esiste_rev_prot := 0;
            WHEN TOO_MANY_ROWS
            THEN
               SELECT MAX (rev)
                 INTO d_id_rev
                 FROM GDO_DOCUMENTI_LOG
                WHERE     id_documento = p_id_documento_prot
                      AND data_ins = p_LOG_DATA
                      AND utente_ins = p_LOG_UTENTE;
         END;
      END IF;

      IF d_id_rev IS NOT NULL
      THEN
         BEGIN
            SELECT 1
              INTO p_esiste_rev
              FROM TEMP_STORICO
             WHERE     ID_DOCUMENTO = p_log_tabella_id
                   AND rev = d_id_rev
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               p_esiste_rev := 0;
         END;
      ELSE
         BEGIN
            SELECT rev
              INTO d_id_rev
              FROM TEMP_STORICO
             WHERE     ID_DOCUMENTO_prot_gdm = p_id_documento_gdm
                   AND LOG_DATA = p_LOG_DATA
                   AND LOG_UTENTE = p_LOG_UTENTE
                   AND tabella = p_log_tabella
                   AND ROWNUM = 1;

            BEGIN
               SELECT 1
                 INTO p_esiste_rev
                 FROM TEMP_STORICO
                WHERE     ID_DOCUMENTO = p_log_tabella_id
                      AND LOG_DATA = p_LOG_DATA
                      AND LOG_UTENTE = p_LOG_UTENTE
                      AND tabella = p_log_tabella
                      AND ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  p_esiste_rev := 0;
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT rev
                    INTO d_id_rev
                    FROM TEMP_STORICO
                   WHERE     ID_DOCUMENTO = p_log_tabella_id
                         AND LOG_DATA = p_LOG_DATA
                         AND LOG_UTENTE = p_LOG_UTENTE
                         AND tabella = p_log_tabella
                         AND ROWNUM = 1;

                  p_esiste_rev := 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     DECLARE
                        d_seq   NUMBER;
                     BEGIN
                        SELECT -temp_storico_sequence.NEXTVAL
                          INTO d_seq
                          FROM DUAL;

                        p_esiste_rev := 0;
                        d_id_rev :=
                           AGP_TRASCO_PKG.CREA_REVINFO (p_log_data, d_seq);
                     END;
               END;
         END;
      END IF;

      IF p_esiste_rev = 0
      THEN
         INSERT INTO TEMP_STORICO (ID_DOCUMENTO,
                                   REV,
                                   ID_DOCUMENTO_PROT_GDM,
                                   LOG_DATA,
                                   LOG_UTENTE,
                                   TABELLA)
              VALUES (p_log_tabella_id,
                      d_id_rev,
                      p_id_documento_gdm,
                      p_LOG_DATA,
                      p_LOG_UTENTE,
                      p_log_tabella);
      END IF;

      RETURN d_id_rev;
   END;

   PROCEDURE crea_storico_allegati (p_id_documento_gdm NUMBER)
   IS
      d_sql               VARCHAR2 (32000);

      d_id_rev            NUMBER;
      d_id_doc_allegato   NUMBER;

      d_esiste_rev        NUMBER := 0;
      d_esiste_rev_prot   NUMBER := 0;
      d_continua          BOOLEAN := TRUE;
   BEGIN
      FOR prot
         IN (SELECT p.*, d.id_documento_esterno
               FROM gdo_documenti d, agp_protocolli p
              WHERE     d.id_documento_esterno = p_id_documento_gdm
                    AND p.id_documento = d.id_documento)
      LOOP
         FOR allegato
            IN (SELECT a.ID_DOCUMENTO, d.stato_documento
                  FROM gdm_seg_allegati_protocollo a,
                       agp_proto_view P,
                       gdm_documenti d
                 WHERE     a.idrif = P.idrif
                       AND P.ID_DOCUMENTO = p_id_documento_gdm
                       AND d.id_documento = a.id_documento)
         LOOP
            DBMS_OUTPUT.put_line ('prot.id_documento ' || prot.id_documento);
            DBMS_OUTPUT.put_line (
               'allegato.id_documento ' || allegato.id_documento);

            DELETE TEMP_STORICO_ALLE;

            INSERT INTO TEMP_STORICO_ALLE (ID,
                                           ID_DOCUMENTO,
                                           IDRIF,
                                           LOG_ID_DOCUMENTO,
                                           LOG_DATA,
                                           LOG_UTENTE,
                                           ID_VALORE_LOG,
                                           DESCRIZIONE,
                                           TITOLO_DOCUMENTO,
                                           QUANTITA,
                                           NUMERO_PAG,
                                           RISERVATO,
                                           UBICAZIONE_DOC_ORIGINALE,
                                           DESCRIZIONE_MOD,
                                           TITOLO_DOCUMENTO_MOD,
                                           QUANTITA_MOD,
                                           NUMERO_PAG_MOD,
                                           RISERVATO_MOD,
                                           UBICAZIONE_DOC_ORIG_MOD)
               (SELECT -ROWNUM + 1 ID,
                       a.ID_DOCUMENTO ID_DOCUMENTO,
                       a.IDRIF IDRIF,
                       -1 LOG_ID_DOCUMENTO,
                       Prot.DATA - 1 LOG_DATA,
                       'TRASCO' LOG_UTENTE,
                       -1 ID_VALORE_LOG,
                       DESCRIZIONE,
                       TITOLO_DOCUMENTO,
                       QUANTITA,
                       NUMERO_PAG,
                       RISERVATO,
                       UBICAZIONE_DOC_ORIGINALE,
                       0 DESCRIZIONE_MOD,
                       0 TITOLO_DOCUMENTO_MOD,
                       0 QUANTITA_MOD,
                       0 NUMERO_PAG_MOD,
                       0 RISERVATO_MOD,
                       0 UBICAZIONE_DOC_ORIG_MOD
                  FROM gdm_seg_allegati_protocollo a
                 WHERE a.ID_DOCUMENTO = allegato.id_documento
                UNION
                SELECT ROWNUM id, LOG.*
                  FROM (  SELECT id_documento,
                                 idrif,
                                 log_id_documento,
                                 log_data,
                                 log_utente,
                                 MIN (id_valore_log) id_valore_log,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'DESCRIZIONE'
                                       THEN
                                          log_valore
                                    END)
                                    DESCRIZIONE,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'TITOLO_DOCUMENTO'
                                       THEN
                                          log_valore
                                    END)
                                    TITOLO_DOCUMENTO,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'QUANTITA'
                                       THEN
                                          TO_NUMBER (log_valore)
                                    END)
                                    QUANTITA,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'NUMERO_PAG'
                                       THEN
                                          TO_NUMBER (log_valore)
                                    END)
                                    NUMERO_PAG,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'RISERVATO'
                                       THEN
                                          log_valore
                                    END)
                                    RISERVATO,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'UBICAZIONE_DOC_ORIGINALE'
                                       THEN
                                          log_valore
                                    END)
                                    UBICAZIONE_DOC_ORIGINALE,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'DESCRIZIONE'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    DESCRIZIONE_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'TITOLO_DOCUMENTO'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    TITOLO_DOCUMENTO_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'QUANTITA' THEN 1
                                       ELSE 0
                                    END)
                                    QUANTITA_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'NUMERO_PAG'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    NUMERO_PAG_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'RISERVATO' THEN 1
                                       ELSE 0
                                    END)
                                    RISERVATO_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'UBICAZIONE_DOC_ORIGINALE'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    UBICAZIONE_DOC_ORIG_MOD
                            FROM (SELECT alle.id_documento,
                                         p.idrif,
                                         id_valore_log,
                                         activity_log.id_documento
                                            AS log_id_documento,
                                         NVL (
                                            TO_CHAR (LOG.valore_clob),
                                            NVL (
                                               TO_CHAR (LOG.valore_data,
                                                        'dd/mm/yyyy'),
                                               NVL (
                                                  TO_CHAR (LOG.valore_numero),
                                                  '')))
                                            AS log_valore,
                                         -- se la data è minore di quella di protocollazione, usa la data di protocollazione
                                         DECODE (
                                            SIGN (
                                                 NVL (p.data,
                                                      TO_DATE (2222222, 'j'))
                                               - activity_log.data_aggiornamento),
                                            -1, activity_log.data_aggiornamento,
                                            p.data)
                                            AS log_data,
                                         LOG.colonna AS log_nome_campo,
                                         -- se la data è minore di quella di protocollazione l'utente
                                         DECODE (
                                            SIGN (
                                                 NVL (p.data,
                                                      TO_DATE (2222222, 'j'))
                                               - activity_log.data_aggiornamento),
                                            -1, activity_log.utente_aggiornamento,
                                            DECODE (
                                               activity_log.utente_aggiornamento,
                                               'RPI', p.utente_protocollante,
                                               activity_log.utente_aggiornamento))
                                            AS log_utente
                                    FROM gdm_valori_log LOG,
                                         gdm_activity_log activity_log,
                                         gdm_dati_modello dati_modello,
                                         agp_proto_view p,
                                         gdm_seg_allegati_protocollo alle
                                   WHERE     p.id_documento =
                                                prot.id_documento_esterno
                                         AND alle.idrif = p.idrif
                                         AND alle.id_documento =
                                                allegato.id_documento
                                         AND activity_log.id_documento =
                                                alle.id_documento
                                         AND LOG.id_log = activity_log.id_log
                                         AND dati_modello.area = 'SEGRETERIA'
                                         AND dati_modello.codice_modello =
                                                'M_ALLEGATO_PROTOCOLLO'
                                         AND DATI_MODELLO.DATO = LOG.COLONNA
                                         /*AND (   LOG.valore_clob IS NOT NULL
                                              OR LOG.valore_data IS NOT NULL
                                              OR LOG.valore_numero IS NOT NULL)*/
                                         AND activity_log.data_aggiornamento >=
                                                NVL (
                                                   (SELECT MAX (
                                                              activity_log.data_aggiornamento)
                                                      FROM gdm_valori_log valori_log,
                                                           gdm_activity_log al
                                                     WHERE     activity_log.id_documento =
                                                                  al.id_documento
                                                           AND al.data_aggiornamento <=
                                                                  (SELECT data
                                                                     FROM agp_proto_view
                                                                    WHERE id_documento =
                                                                             al.id_documento)
                                                           AND valori_log.id_log =
                                                                  al.id_log
                                                           AND LOG.COLONNA =
                                                                  VALORI_LOG.COLONNA),
                                                   activity_log.data_aggiornamento))
                        GROUP BY id_documento,
                                 idrif,
                                 log_id_documento,
                                 log_data,
                                 log_utente
                        ORDER BY log_data, id_valore_log) LOG);

            FOR storico_alle
               IN (  SELECT TEMP_STORICO_ALLE.id,
                            LOG_DATA,
                            LOG_UTENTE,
                            id_documento,
                            get_valore_log ('TEMP_STORICO_ALLE',
                                            'DESCRIZIONE',
                                            TEMP_STORICO_ALLE.id)
                               DESCRIZIONE,
                            get_valore_log ('TEMP_STORICO_ALLE',
                                            'TITOLO_DOCUMENTO',
                                            TEMP_STORICO_ALLE.id)
                               TITOLO_DOCUMENTO,
                            get_valore_log ('TEMP_STORICO_ALLE',
                                            'QUANTITA',
                                            TEMP_STORICO_ALLE.id)
                               QUANTITA,
                            get_valore_log ('TEMP_STORICO_ALLE',
                                            'NUMERO_PAG',
                                            TEMP_STORICO_ALLE.id)
                               NUMERO_PAG,
                            get_valore_log ('TEMP_STORICO_ALLE',
                                            'RISERVATO',
                                            TEMP_STORICO_ALLE.id)
                               RISERVATO,
                            get_valore_log ('TEMP_STORICO_ALLE',
                                            'UBICAZIONE_DOC_ORIGINALE',
                                            TEMP_STORICO_ALLE.id)
                               UBICAZIONE_DOC_ORIGINALE,
                            DESCRIZIONE_MOD,
                            TITOLO_DOCUMENTO_MOD,
                            QUANTITA_MOD,
                            NUMERO_PAG_MOD,
                            RISERVATO_MOD,
                            UBICAZIONE_DOC_ORIG_MOD
                       FROM TEMP_STORICO_ALLE
                   ORDER BY id_documento, id)
            LOOP
               d_continua := TRUE;

               BEGIN
                  SELECT id_documento
                    INTO d_id_doc_allegato
                    FROM gdo_documenti
                   WHERE id_documento_esterno = storico_alle.id_documento;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- se non lo trova su agspr ma c'è su gdm cancellato,
                     -- lo inserisce non valido
                     IF allegato.stato_documento = 'CA'
                     THEN
                        --d_id_doc_allegato := hibernate_sequence.NEXTVAL;
                        SELECT hibernate_sequence.NEXTVAL
                          INTO d_id_doc_allegato
                          FROM DUAL;

                        INSERT INTO GDO_DOCUMENTI (ID_DOCUMENTO,
                                                   ID_DOCUMENTO_ESTERNO,
                                                   ID_ENTE,
                                                   TIPO_OGGETTO,
                                                   VALIDO,
                                                   UTENTE_INS,
                                                   DATA_INS,
                                                   UTENTE_UPD,
                                                   DATA_UPD,
                                                   riservato,
                                                   VERSION)
                           SELECT d_id_doc_allegato,
                                  storico_alle.id_documento,
                                  1,
                                  'ALLEGATO',
                                  'N',
                                  storico_alle.log_utente,
                                  storico_alle.log_data,
                                  storico_alle.log_utente,
                                  storico_alle.log_data,
                                  storico_alle.RISERVATO,
                                  0
                             FROM DUAL;

                        INSERT INTO GDO_ALLEGATI (ID_DOCUMENTO,
                                                  COMMENTO,
                                                  DESCRIZIONE,
                                                  NUM_PAGINE,
                                                  QUANTITA,
                                                  SEQUENZA,
                                                  UBICAZIONE)
                           SELECT d_id_doc_allegato,
                                  storico_alle.TITOLO_DOCUMENTO,
                                  storico_alle.DESCRIZIONE,
                                  storico_alle.NUMERO_PAG,
                                  storico_alle.QUANTITA,
                                  (SELECT MAX (NVL (SEQUENZA, 0)) + 1
                                     FROM GDO_ALLEGATI
                                    WHERE ID_DOCUMENTO = d_id_doc_allegato),
                                  storico_alle.UBICAZIONE_DOC_ORIGINALE
                             FROM DUAL;

                        INSERT INTO GDO_DOCUMENTI_COLLEGATI (
                                       ID_DOCUMENTO_COLLEGATO,
                                       ID_COLLEGATO,
                                       DATA_INS,
                                       ID_DOCUMENTO,
                                       DATA_UPD,
                                       ID_TIPO_COLLEGAMENTO,
                                       UTENTE_INS,
                                       UTENTE_UPD,
                                       VALIDO,
                                       VERSION)
                           SELECT hibernate_sequence.NEXTVAL,
                                  d_id_doc_allegato,
                                  storico_alle.log_data,
                                  prot.id_documento,
                                  storico_alle.log_data,
                                  ID_TIPO_COLLEGAMENTO,
                                  storico_alle.log_utente,
                                  storico_alle.log_utente,
                                  'N',
                                  0
                             FROM GDO_TIPI_COLLEGAMENTO
                            WHERE TIPO_COLLEGAMENTO = 'ALLEGATO';
                     ELSE
                        d_continua := FALSE;
                     END IF;
               END;

               IF d_continua
               THEN
                  d_id_rev :=
                     get_id_rev (prot.id_documento,
                                 p_id_documento_gdm,
                                 storico_alle.LOG_DATA,
                                 storico_alle.LOG_UTENTE,
                                 d_id_doc_allegato,
                                 'GDO_ALLEGATI_LOG',
                                 d_esiste_rev,
                                 d_esiste_rev_prot);

                  IF d_esiste_rev = 1
                  THEN
                     UPDATE GDO_DOCUMENTI_LOG
                        SET RISERVATO = storico_alle.RISERVATO,
                            RISERVATO_MOD = storico_alle.RISERVATO_MOD
                      WHERE     ID_DOCUMENTO = d_id_doc_allegato
                            AND REV = d_id_rev;


                     UPDATE GDO_ALLEGATI_LOG
                        SET DESCRIZIONE = storico_alle.DESCRIZIONE,
                            COMMENTO = storico_alle.TITOLO_DOCUMENTO,
                            QUANTITA = storico_alle.QUANTITA,
                            NUM_PAGINE = storico_alle.NUMERO_PAG,
                            DESCRIZIONE_MOD = storico_alle.DESCRIZIONE_MOD,
                            UBICAZIONE = storico_alle.UBICAZIONE_DOC_ORIGINALE
                      WHERE     ID_DOCUMENTO = d_id_doc_allegato
                            AND REV = d_id_rev;
                  ELSE
                     INSERT INTO GDO_DOCUMENTI_COLLEGATI_LOG (
                                    ID_DOCUMENTO_COLLEGATO,
                                    REV,
                                    REVTYPE,
                                    DATA_INS,
                                    DATA_UPD,
                                    VALIDO,
                                    UTENTE_INS,
                                    UTENTE_UPD,
                                    ID_COLLEGATO,
                                    ID_DOCUMENTO,
                                    ID_TIPO_COLLEGAMENTO)
                        SELECT ID_DOCUMENTO_COLLEGATO,
                               d_id_rev,
                               DECODE (storico_alle.log_utente,
                                       'TRASCO', 2,
                                       DECODE (storico_alle.id, 1, 0, 1)), -- 2 per evitare si vedano tra i dati di protocollazione,
                               /* REVEND ,*/
                               storico_alle.log_data,
                               storico_alle.log_data,
                               VALIDO,
                               storico_alle.log_utente,
                               storico_alle.log_utente,
                               d_id_doc_allegato,
                               prot.id_documento,
                               ID_TIPO_COLLEGAMENTO
                          FROM GDO_DOCUMENTI_COLLEGATI
                         WHERE     ID_COLLEGATO = d_id_doc_allegato
                               AND ID_DOCUMENTO = prot.id_documento
                               AND ID_TIPO_COLLEGAMENTO IN (SELECT ID_TIPO_COLLEGAMENTO
                                                              FROM GDO_TIPI_COLLEGAMENTO
                                                             WHERE TIPO_COLLEGAMENTO =
                                                                      'ALLEGATO');

                     INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                                    REV,
                                                    REVTYPE,
                                                    DATA_INS,
                                                    DATE_CREATED_MOD,
                                                    DATA_UPD,
                                                    VALIDO,
                                                    ID_DOCUMENTO_ESTERNO,
                                                    RISERVATO,
                                                    RISERVATO_MOD,
                                                    STATO,
                                                    STATO_CONSERVAZIONE,
                                                    STATO_FIRMA,
                                                    UTENTE_INS,
                                                    UTENTE_UPD,
                                                    ID_ENTE,
                                                    ID_ENGINE_ITER,
                                                    TIPO_OGGETTO)
                        SELECT d_id_doc_allegato,
                               d_id_rev,
                               DECODE (storico_alle.log_utente,
                                       'TRASCO', 2,
                                       DECODE (storico_alle.id, 1, 0, 1)), -- 2 per evitare si vedano tra i dati di protocollazione
                               storico_alle.log_data,
                               1,
                               storico_alle.log_data,
                               valido,
                               allegato.id_documento,
                               storico_alle.RISERVATO,
                               storico_alle.RISERVATO_MOD,
                               STATO,
                               STATO_CONSERVAZIONE,
                               STATO_FIRMA,
                               storico_alle.log_utente,
                               storico_alle.log_utente,
                               ID_ENTE,
                               ID_ENGINE_ITER,
                               TIPO_OGGETTO
                          FROM gdo_documenti
                         WHERE id_documento = d_id_doc_allegato;

                     INSERT INTO GDO_ALLEGATI_LOG (ID_DOCUMENTO,
                                                   REV,
                                                   COMMENTO,
                                                   COMMENTO_MOD,
                                                   DESCRIZIONE,
                                                   DESCRIZIONE_MOD,
                                                   NUM_PAGINE,
                                                   NUM_PAGINE_MOD,
                                                   QUANTITA,
                                                   QUANTITA_MOD,
                                                   UBICAZIONE,
                                                   UBICAZIONE_MOD)
                          VALUES (d_id_doc_allegato,
                                  d_id_rev,
                                  storico_alle.titolo_documento,
                                  storico_alle.titolo_documento_mod,
                                  SUBSTR (storico_alle.DESCRIZIONE, 1, 255),
                                  storico_alle.DESCRIZIONE_MOD,
                                  storico_alle.NUMERO_PAG,
                                  storico_alle.NUMERO_PAG_MOD,
                                  storico_alle.QUANTITA,
                                  storico_alle.QUANTITA_MOD,
                                  storico_alle.UBICAZIONE_DOC_ORIGINALE,
                                  storico_alle.UBICAZIONE_DOC_ORIG_MOD);



                     IF d_esiste_rev_prot = 0
                     THEN
                        INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                                       REV,
                                                       REVTYPE,
                                                       DATA_INS,
                                                       DATA_UPD,
                                                       UTENTE_INS,
                                                       UTENTE_UPD,
                                                       ID_DOCUMENTO_ESTERNO)
                             VALUES (prot.id_documento,
                                     d_id_rev,
                                     DECODE (d_id_doc_ALLEGATO, 0, 0, 1),
                                     storico_alle.log_data,
                                     storico_alle.log_data,
                                     storico_alle.LOG_UTENTE,
                                     storico_alle.LOG_UTENTE,
                                     p_id_documento_gdm);


                        INSERT INTO AGP_PROTOCOLLI_LOG (id_documento,
                                                        rev,
                                                        anno,
                                                        data,
                                                        idrif,
                                                        numero,
                                                        corrispondenti_mod,
                                                        tipo_registro)
                           SELECT prot.id_documento,
                                  d_id_rev,
                                  prot.anno,
                                  prot.data,
                                  prot.idrif,
                                  prot.numero,
                                  1,
                                  prot.tipo_registro
                             FROM DUAL;

                        INSERT INTO TEMP_STORICO (ID_DOCUMENTO,
                                                  REV,
                                                  ID_DOCUMENTO_PROT_GDM,
                                                  LOG_DATA,
                                                  LOG_UTENTE,
                                                  TABELLA)
                             VALUES (prot.id_documento,
                                     d_id_rev,
                                     p_id_documento_gdm,
                                     storico_alle.LOG_DATA,
                                     storico_alle.LOG_UTENTE,
                                     'AGP_PROTOCOLLI_LOG');
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;

      crea_storico_file_alle (p_id_documento_gdm);

      FOR r
         IN (  SELECT *
                 FROM GDO_DOCUMENTI_LOG
                WHERE id_documento IN (SELECT id_collegato
                                         FROM gdo_documenti d,
                                              gdo_documenti_collegati dc,
                                              gdo_tipi_collegamento tc
                                        WHERE     d.id_documento_esterno =
                                                     p_id_documento_gdm
                                              AND dc.id_documento =
                                                     d.id_documento
                                              AND tc.id_tipo_collegamento =
                                                     dc.id_tipo_collegamento
                                              AND tc.tipo_collegamento =
                                                     'ALLEGATO')
             ORDER BY data_ins)
      LOOP
         UPDATE GDO_DOCUMENTI_LOG
            SET revend =
                   (SELECT MAX (rev) revend
                      FROM GDO_DOCUMENTI_LOG p2
                     WHERE     p2.id_documento = r.id_documento
                           AND data_ins =
                                  (SELECT MIN (data_ins)
                                     FROM GDO_DOCUMENTI_LOG p3
                                    WHERE     p3.id_documento =
                                                 p2.id_documento
                                          AND p3.data_ins > r.data_ins))
          WHERE     id_documento = r.id_documento
                AND rev = r.rev
                AND NVL (revend, 0) <= 0;
      END LOOP;

      FOR C
         IN (  SELECT *
                 FROM GDO_DOCUMENTI_COLLEGATI_LOG
                WHERE id_documento_collegato IN (SELECT id_documento_collegato
                                                   FROM gdo_documenti d,
                                                        gdo_documenti_collegati dc,
                                                        gdo_tipi_collegamento tc
                                                  WHERE     d.id_documento_esterno =
                                                               p_id_documento_gdm
                                                        AND dc.id_documento =
                                                               d.id_documento
                                                        AND tc.id_tipo_collegamento =
                                                               dc.id_tipo_collegamento
                                                        AND tc.tipo_collegamento =
                                                               'ALLEGATO')
             ORDER BY data_ins)
      LOOP
         UPDATE GDO_DOCUMENTI_COLLEGATI_LOG
            SET revend =
                   (SELECT MAX (rev) revend
                      FROM GDO_DOCUMENTI_COLLEGATI_LOG p2
                     WHERE     p2.id_documento_collegato =
                                  C.id_documento_collegato
                           AND data_ins =
                                  (SELECT MIN (data_ins)
                                     FROM GDO_DOCUMENTI_COLLEGATI_LOG p3
                                    WHERE     p3.id_documento_collegato =
                                                 p2.id_documento_collegato
                                          AND p3.data_ins > C.data_ins))
          WHERE     id_documento_collegato = C.id_documento_collegato
                AND rev = C.rev
                AND NVL (revend, 0) <= 0;
      END LOOP;
   END;

   --------------------------------------------------------------------------------

   PROCEDURE crea_storico_file_alle (p_id_documento_gdm NUMBER)
   IS
      d_id_rev              NUMBER;
      d_id_file_documento   NUMBER;
      d_id_documento        NUMBER;
      d_revtype             NUMBER;
      d_sequenza            NUMBER;


      d_esiste_rev          NUMBER := 0;
      d_esiste_rev_prot     NUMBER := 0;
   BEGIN
      FOR prot
         IN (SELECT p.*, d.id_documento_esterno
               FROM gdo_documenti d, agp_protocolli p
              WHERE     d.id_documento_esterno = p_id_documento_gdm
                    AND p.id_documento = d.id_documento)
      LOOP
         FOR storico_file
            IN (  SELECT *
                    FROM (                               -- in protocollazione
                          SELECT activity_log.id_documento AS log_id_documento,
                                 LOG.FILENAME AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 LOG.data_aggiornamento AS log_data,
                                 'ALLEGATO_PRINCIPALE' AS log_nome_campo,
                                 activity_log.utente_aggiornamento
                                    AS log_utente,
                                 activity_log.TIPO_AZIONE tipo_operazione,
                                 LOG.id_oggetto_file AS ID_FILE,
                                 LOG.id_log AS ID_LOG,
                                 s.firmato
                            FROM gdm_oggetti_file_log LOG,
                                 gdm_activity_log activity_log,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND activity_log.id_documento = s.id_documento
                                 AND LOG.id_log = activity_log.id_log
                                 AND activity_log.data_aggiornamento >=
                                        (SELECT MAX (
                                                   activity_log.data_aggiornamento)
                                           FROM gdm_oggetti_file_log oggetti_file_log,
                                                gdm_activity_log activity_log
                                          WHERE     activity_log.id_documento =
                                                       s.id_documento
                                                AND activity_log.data_aggiornamento <=
                                                       p.data
                                                AND oggetti_file_log.id_log =
                                                       activity_log.id_log)
                                 AND LOG.FILENAME <> 'LETTERAUNIONE.RTFHIDDEN'
                                 AND tipo_operazione != 'E'
                          UNION
                          SELECT activity_log.id_documento AS log_id_documento,
                                 LOG.FILENAME AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 LOG.data_aggiornamento AS log_data,
                                 'FILE' AS log_nome_campo,
                                 activity_log.utente_aggiornamento
                                    AS log_utente,
                                 'M' tipo_operazione,
                                 LOG.id_oggetto_file AS ID_FILE,
                                 LOG.id_log AS ID_LOG,
                                 s.firmato
                            FROM gdm_oggetti_file_log LOG,
                                 gdm_activity_log activity_log,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND activity_log.id_documento = s.id_documento
                                 AND LOG.id_log = activity_log.id_log
                                 AND LOG.data_aggiornamento =
                                        (SELECT MAX (
                                                   oggetti_file_log.data_aggiornamento)
                                           FROM gdm_oggetti_file_log oggetti_file_log,
                                                gdm_activity_log activity_log
                                          WHERE     activity_log.id_documento =
                                                       s.id_documento
                                                AND oggetti_file_log.data_aggiornamento <=
                                                       p.data
                                                AND oggetti_file_log.id_log =
                                                       activity_log.id_log)
                                 AND LOG.FILENAME <> 'LETTERAUNIONE.RTFHIDDEN'
                                 AND tipo_operazione = 'E'
                                 AND LOG.data_aggiornamento !=
                                        LOG.data_operazione
                          UNION
                          SELECT oggetti_file.id_documento AS log_id_documento,
                                 oggetti_file.FILENAME AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 oggetti_file.data_aggiornamento AS log_data,
                                 'ALLEGATO_PRINCIPALE' AS log_nome_campo,
                                 oggetti_file.utente_aggiornamento
                                    AS log_utente,
                                 'M',
                                 oggetti_file.id_oggetto_file AS ID_FILE,
                                 NULL AS ID_LOG,
                                 s.firmato
                            FROM gdm_oggetti_file oggetti_file,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND oggetti_file.id_documento = s.id_documento
                                 AND oggetti_file.data_aggiornamento <=
                                        TO_DATE (p.data,
                                                 'dd/MM/yyyy hh24:mi:ss')
                                 AND oggetti_file.FILENAME <>
                                        'LETTERAUNIONE.RTFHIDDEN'
                          UNION
                          -- dopo protocollazione
                          SELECT activity_log.id_documento AS log_id_documento,
                                 LOG.FILENAME AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 LOG.data_aggiornamento AS log_data,
                                 'ALLEGATO_PRINCIPALE' AS log_nome_campo,
                                 LOG.utente_aggiornamento AS log_utente,
                                 activity_log.TIPO_AZIONE,
                                 LOG.id_oggetto_file AS ID_FILE,
                                 LOG.id_log AS ID_LOG,
                                 s.firmato
                            FROM gdm_oggetti_file_log LOG,
                                 gdm_activity_log activity_log,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND activity_log.id_documento = s.id_documento
                                 AND activity_log.data_aggiornamento >= p.data
                                 AND LOG.id_log = activity_log.id_log
                                 AND LOG.TIPO_OPERAZIONE =
                                        activity_log.tipo_azione
                                 AND LOG.FILENAME <> 'LETTERAUNIONE.RTFHIDDEN'
                                 AND LOG.tipo_operazione != 'E'
                                 AND NOT EXISTS
                                        (SELECT 1
                                           FROM gdm_oggetti_file oggetti_file
                                          WHERE     oggetti_file.id_documento =
                                                       s.id_documento
                                                AND oggetti_file.data_aggiornamento >=
                                                       p.data
                                                AND oggetti_file.FILENAME <>
                                                       'LETTERAUNIONE.RTFHIDDEN'
                                                AND oggetti_file.FILENAME =
                                                       LOG.FILENAME
                                                AND oggetti_file.UTENTE_aggiornamento =
                                                       LOG.utente_aggiornamento)
                          UNION
                          SELECT activity_log.id_documento AS log_id_documento,
                                 LOG.FILENAME AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 LOG.data_aggiornamento AS log_data,
                                 'ALLEGATO_PRINCIPALE' AS log_nome_campo,
                                 activity_log.utente_aggiornamento
                                    AS log_utente,
                                 activity_log.TIPO_AZIONE,
                                 LOG.id_oggetto_file AS ID_FILE,
                                 LOG.id_log AS ID_LOG,
                                 s.firmato
                            FROM gdm_oggetti_file_log LOG,
                                 gdm_activity_log activity_log,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND activity_log.id_documento = s.id_documento
                                 AND LOG.data_operazione >=
                                        TO_DATE (p.data,
                                                 'dd/MM/yyyy hh24:mi:ss')
                                 AND LOG.id_log = activity_log.id_log
                                 AND LOG.FILENAME <> 'LETTERAUNIONE.RTFHIDDEN'
                                 AND LOG.tipo_operazione = 'E'
                          UNION
                          SELECT oggetti_file.id_documento AS log_id_documento,
                                 oggetti_file.FILENAME AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 oggetti_file.data_aggiornamento AS log_data,
                                 'ALLEGATO_PRINCIPALE' AS log_nome_campo,
                                 oggetti_file.utente_aggiornamento
                                    AS log_utente,
                                 'C',
                                 oggetti_file.id_oggetto_file AS ID_FILE,
                                 NULL AS ID_LOG,
                                 s.firmato
                            FROM gdm_oggetti_file oggetti_file,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND oggetti_file.id_documento = s.id_documento
                                 --  AND oggetti_file.data_aggiornamento >= p.data
                                 AND oggetti_file.FILENAME <>
                                        'LETTERAUNIONE.RTFHIDDEN'
                          UNION
                          SELECT oggetti_file.id_documento AS log_id_documento,
                                 oggetti_file.FILENAME AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 stati_documento.data_aggiornamento AS log_data,
                                 'ALLEGATO_PRINCIPALE' AS log_nome_campo,
                                 stati_documento.utente_aggiornamento
                                    AS log_utente,
                                 'E',
                                 oggetti_file.id_oggetto_file AS ID_FILE,
                                 NULL AS ID_LOG,
                                 s.firmato
                            FROM gdm_oggetti_file oggetti_file,
                                 gdm_stati_documento stati_documento,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND stati_documento.id_documento =
                                        s.id_documento
                                 AND stati_documento.STATO = 'CA'
                                 AND oggetti_file.id_documento = s.id_documento
                                 AND oggetti_file.data_aggiornamento >= p.data
                                 AND oggetti_file.FILENAME <>
                                        'LETTERAUNIONE.RTFHIDDEN'
                          UNION
                          -- file cancellati
                          SELECT activity_log.id_documento AS log_id_documento, --'0' AS log_id_documento,
                                 ogfi.filename AS log_valore,
                                 'Documento Allegato' AS log_label_campo,
                                 OGFI.DATA_OPERAZIONE AS log_data,
                                 'ALLEGATO_PRINCIPALE' AS log_nome_campo,
                                 OGFI.UTENTE_OPERAZIONE AS log_utente,
                                 OGFI.TIPO_OPERAZIONE,
                                 OGFI.id_oggetto_file AS ID_FILE,
                                 activity_log.id_log AS ID_LOG,
                                 s.firmato
                            FROM gdm_documenti docu,
                                 gdm_activity_log activity_log,
                                 gdm_oggetti_file_log OGFI,
                                 gdm_seg_allegati_protocollo s,
                                 agp_proto_view p
                           WHERE     p.id_documento = p_id_documento_gdm
                                 AND s.idrif = p.idrif
                                 AND docu.id_documento = s.id_documento
                                 AND docu.id_documento =
                                        activity_log.id_documento
                                 AND activity_log.id_log = OGFI.id_log
                                 AND OGFI.DATA_OPERAZIONE >= p.data
                                 AND OGFI.TIPO_OPERAZIONE = 'E')
                ORDER BY NVL (id_log, 9999999999), log_id_documento, log_data)
         LOOP
            FOR file_alle
               IN (  SELECT id_file_documento, d.id_documento, sequenza
                       FROM gdo_file_documento fd, gdo_documenti d
                      WHERE     d.id_documento_esterno =
                                   storico_file.log_id_documento
                            AND fd.id_documento = d.id_documento
                            AND codice IN ('FILE_ALLEGATO', 'FILE_ORIGINALE')
                   ORDER BY d.id_documento, sequenza)
            LOOP
               d_id_file_documento := file_alle.id_file_documento;
               d_id_documento := file_alle.id_documento;
               d_sequenza := file_alle.sequenza;

               DBMS_OUTPUT.put_line (
                     'ottengo idrev per id_docuemnto '
                  || prot.id_documento
                  || ' data '
                  || TO_CHAR (storico_file.LOG_DATA, 'dd/mm/yyyy hh24:mi:ss')
                  || ' utente '
                  || storico_file.LOG_UTENTE);

               d_id_rev :=
                  get_id_rev (prot.id_documento,
                              p_id_documento_gdm,
                              storico_file.LOG_DATA,
                              storico_file.LOG_UTENTE,
                              d_id_file_documento,
                              'GDO_FILE_DOCUMENTO_LOG',
                              d_esiste_rev,
                              d_esiste_rev_prot);

               IF storico_file.tipo_operazione = 'C'
               THEN
                  d_revtype := 0;
               ELSIF storico_file.tipo_operazione = 'E'
               THEN
                  d_revtype := 2;
               ELSE
                  d_revtype := 1;
               END IF;

               DECLARE
                  d_dim   NUMBER := 0;
               BEGIN
                  BEGIN
                     d_dim :=
                        gdm_ag_oggetti_file.get_len_storico (
                           storico_file.id_file);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        d_dim := 0;
                  END;

                  IF d_esiste_rev = 1
                  THEN
                     UPDATE GDO_FILE_DOCUMENTO_LOG
                        SET dimensione = d_dim,
                            dimensione_mod = 1,
                            firmato = storico_file.firmato,
                            firmato_mod = 1,
                            id_file_esterno = storico_file.id_file,
                            id_file_esterno_mod = 1,
                            nome = storico_file.log_valore,
                            nome_mod = 1,
                            sequenza = d_sequenza,
                            sequenza_mod = 1,
                            revisione_storico = storico_file.id_log,
                            revisione_mod = 1
                      WHERE     id_file_documento = d_id_file_documento
                            AND rev = d_id_rev;
                  ELSE
                     INSERT INTO GDO_FILE_DOCUMENTO_LOG (id_file_documento,
                                                         rev,
                                                         revtype,
                                                         data_ins,
                                                         date_created_mod,
                                                         data_upd,
                                                         last_updated_mod,
                                                         valido,
                                                         valido_mod,
                                                         codice,
                                                         codice_mod,
                                                         content_type,
                                                         content_type_mod,
                                                         dimensione,
                                                         dimensione_mod,
                                                         firmato,
                                                         firmato_mod,
                                                         id_file_esterno,
                                                         id_file_esterno_mod,
                                                         modificabile,
                                                         modificabile_mod,
                                                         nome,
                                                         nome_mod,
                                                         sequenza,
                                                         sequenza_mod,
                                                         utente_ins,
                                                         utente_ins_mod,
                                                         utente_upd,
                                                         utente_upd_mod,
                                                         id_documento,
                                                         documento_mod,
                                                         revisione_storico,
                                                         revisione_mod)
                        SELECT d_id_file_documento,
                               d_id_rev,
                               d_revtype,
                               storico_file.log_data,
                               1,
                               storico_file.log_data,
                               1,
                               'Y',
                               1,
                               'FILE_ALLEGATO',
                               1,
                               'application/octet-stream',
                               1,
                               d_dim,
                               1,
                               storico_file.firmato,
                               1,
                               storico_file.id_file id_file_esterno,
                               1 id_file_esterno_mod,
                               'Y',
                               1,
                               storico_file.log_valore,
                               1,
                               d_sequenza,
                               1,
                               storico_file.log_utente,
                               1,
                               storico_file.log_utente,
                               1,
                               d_id_documento,
                               1,
                               storico_file.id_log,
                               1
                          FROM DUAL;
                  END IF;
               END;

               IF d_esiste_rev_prot = 0
               THEN
                  DECLARE
                     d_data_log   DATE := storico_file.log_data;
                     d_esiste     NUMBER := 0;
                  BEGIN
                     SELECT COUNT (1)
                       INTO d_esiste
                       FROM GDO_DOCUMENTI_LOG
                      WHERE     id_documento = prot.id_documento
                            AND data_ins = d_data_log;

                     IF d_esiste > 0
                     THEN
                        d_data_log := d_data_log + 1 / (24 * 3600);
                     END IF;

                     INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                                    REV,
                                                    REVTYPE,
                                                    DATA_INS,
                                                    DATA_UPD,
                                                    UTENTE_INS,
                                                    UTENTE_UPD,
                                                    id_documento_esterno)
                        SELECT prot.id_documento,
                               d_id_rev,
                               DECODE (d_id_file_documento, 0, 0, 1),
                               d_data_log,
                               d_data_log,
                               storico_file.LOG_UTENTE,
                               storico_file.LOG_UTENTE,
                               p_id_documento_gdm
                          FROM DUAL
                         WHERE NOT EXISTS
                                  (SELECT 1
                                     FROM GDO_DOCUMENTI_LOG
                                    WHERE     ID_DOCUMENTO =
                                                 prot.id_documento
                                          AND rev = d_id_rev);
                  END;

                  INSERT INTO AGP_PROTOCOLLI_LOG (id_documento,
                                                  rev,
                                                  anno,
                                                  data,
                                                  idrif,
                                                  numero,
                                                  corrispondenti_mod,
                                                  tipo_registro)
                     SELECT prot.id_documento,
                            d_id_rev,
                            prot.anno,
                            prot.data,
                            prot.idrif,
                            prot.numero,
                            1,
                            prot.tipo_registro
                       FROM DUAL
                      WHERE NOT EXISTS
                               (SELECT 1
                                  FROM AGP_PROTOCOLLI_LOG
                                 WHERE     ID_DOCUMENTO = prot.id_documento
                                       AND rev = d_id_rev);

                  INSERT INTO TEMP_STORICO (ID_DOCUMENTO,
                                            REV,
                                            ID_DOCUMENTO_PROT_GDM,
                                            LOG_DATA,
                                            LOG_UTENTE,
                                            TABELLA)
                     SELECT d_id_file_documento,
                            d_id_rev,
                            p_id_documento_gdm,
                            storico_file.LOG_DATA,
                            storico_file.LOG_UTENTE,
                            'GDO_FILE_DOCUMENTO_LOG'
                       FROM DUAL
                      WHERE NOT EXISTS
                               (SELECT 1
                                  FROM TEMP_STORICO
                                 WHERE     ID_DOCUMENTO = prot.id_documento
                                       AND rev = d_id_rev
                                       AND TABELLA = 'GDO_FILE_DOCUMENTO_LOG');
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;

      -- Aggiusto i revtype in base alle regole di envers per cui:
      --    il primo record è sempre CREATO (0)
      --    un record ELIMINATO (2) è sempre l'ultimo perchè non può essere aggiornato
      --    gli altri sono sempre MODIFICATI (1)
      -- le rev sono, in questo momento, negative, perciò il min = max e viceversa
      FOR f
         IN (  SELECT MIN (rev) max_rev, MAX (rev) min_rev, id_file_documento
                 FROM GDO_FILE_DOCUMENTO_LOG
                WHERE id_documento IN (SELECT id_collegato
                                         FROM gdo_documenti d,
                                              gdo_documenti_collegati dc,
                                              gdo_tipi_collegamento tc
                                        WHERE     d.id_documento_esterno =
                                                     p_id_documento_gdm
                                              AND dc.id_documento =
                                                     d.id_documento
                                              AND tc.id_tipo_collegamento =
                                                     dc.id_tipo_collegamento
                                              AND tc.tipo_collegamento =
                                                     'ALLEGATO')
             GROUP BY id_file_documento)
      LOOP
         UPDATE GDO_FILE_DOCUMENTO_LOG
            SET revtype = 1
          WHERE     id_file_documento = f.id_file_documento
                AND rev NOT IN (f.min_rev, f.max_rev)
                AND revtype = 2;

         UPDATE GDO_FILE_DOCUMENTO_LOG
            SET revtype = 0
          WHERE id_file_documento = f.id_file_documento AND rev = f.min_rev;
      END LOOP;

      FOR r
         IN (  SELECT *
                 FROM GDO_FILE_DOCUMENTO_LOG
                WHERE id_documento IN (SELECT id_collegato
                                         FROM gdo_documenti d,
                                              gdo_documenti_collegati dc,
                                              gdo_tipi_collegamento tc
                                        WHERE     d.id_documento_esterno =
                                                     p_id_documento_gdm
                                              AND dc.id_documento =
                                                     d.id_documento
                                              AND tc.id_tipo_collegamento =
                                                     dc.id_tipo_collegamento
                                              AND tc.tipo_collegamento =
                                                     'ALLEGATO')
             ORDER BY data_ins)
      LOOP
         UPDATE GDO_FILE_DOCUMENTO_LOG
            SET revend =
                   (SELECT MIN (rev) revend
                      FROM GDO_FILE_DOCUMENTO_LOG prco2
                     WHERE     prco2.id_documento = r.id_documento
                           AND prco2.id_file_documento = r.id_file_documento
                           AND data_ins =
                                  (SELECT MIN (data_ins)
                                     FROM GDO_FILE_DOCUMENTO_LOG prco3
                                    WHERE     prco3.id_documento =
                                                 prco2.id_documento
                                          AND prco3.id_file_documento =
                                                 prco2.id_file_documento
                                          AND prco3.data_ins > r.data_ins))
          WHERE     id_file_documento = r.id_file_documento
                AND rev = r.rev
                AND NVL (revend, 0) <= 0;
      END LOOP;
   END;

   --------------------------------------------------------------------------------

   PROCEDURE crea_storico_file_princ (p_id_documento_gdm NUMBER)
   IS
      d_id_rev              NUMBER;
      d_id_file_documento   NUMBER;
      d_id_documento        NUMBER;
      d_revtype             NUMBER;
      d_sequenza            NUMBER;


      d_esiste_rev          NUMBER := 0;
      d_esiste_rev_prot     NUMBER := 0;
   BEGIN
      FOR prot
         IN (SELECT p.*, d.id_documento_esterno
               FROM gdo_documenti d, agp_protocolli p
              WHERE     d.id_documento_esterno = p_id_documento_gdm
                    AND p.id_documento = d.id_documento)
      LOOP
         FOR storico_file_princ
            IN (                                  -- file alla protocollazione
                SELECT   *
                    FROM (SELECT activity_log.id_documento AS log_id_documento,
                                 LOG.FILENAME AS log_valore,
                                 'Documento Principale' AS log_label_campo,
                                 p.data AS log_data,
                                 'FILE' AS log_nome_campo,
                                 p.utente_protocollante AS log_utente,
                                 DECODE (
                                    LOG.data_aggiornamento,
                                    LOG.data_operazione, LOG.tipo_operazione,
                                    'M')
                                    tipo_operazione,
                                 LOG.id_oggetto_file AS ID_FILE,
                                 LOG.id_log AS ID_LOG,
                                 NVL (p.firmato, 'N') firmato
                            FROM gdm_oggetti_file_log LOG,
                                 gdm_activity_log activity_log,
                                 agp_proto_view p
                           WHERE     activity_log.id_documento =
                                        p_id_documento_gdm
                                 AND p.id_documento = activity_log.id_documento
                                 AND LOG.id_log = activity_log.id_log
                                 AND LOG.data_aggiornamento =
                                        (SELECT MAX (
                                                   gdm_oggetti_file_log.data_aggiornamento)
                                           FROM gdm_oggetti_file_log,
                                                gdm_activity_log activity_log
                                          WHERE     activity_log.id_documento =
                                                       p.id_documento
                                                AND gdm_oggetti_file_log.data_aggiornamento <=
                                                       p.DATA
                                                AND gdm_oggetti_file_log.id_log =
                                                       activity_log.id_log
                                                AND LOG.FILENAME <>
                                                       'LETTERAUNIONE.RTFHIDDEN'
                                                AND tipo_operazione != 'E')
                                 AND LOG.FILENAME <> 'LETTERAUNIONE.RTFHIDDEN'
                                 AND tipo_operazione != 'E'
                          UNION
                          -- file dopo la protocollazione
                          SELECT activity_log.id_documento AS log_id_documento,
                                 LOG.FILENAME AS log_valore,
                                 'Documento Principale' AS log_label_campo,
                                 DECODE (LOG.tipo_operazione,
                                         'E', LOG.data_operazione,
                                         LOG.data_aggiornamento)
                                    AS log_data,
                                 'FILE' AS log_nome_campo,
                                 activity_log.utente_aggiornamento
                                    AS log_utente,
                                 LOG.tipo_operazione,
                                 LOG.id_oggetto_file AS ID_FILE,
                                 LOG.id_log AS ID_LOG,
                                 NVL (p.firmato, 'N') firmato
                            FROM gdm_oggetti_file_log LOG,
                                 gdm_activity_log activity_log,
                                 agp_proto_view p
                           WHERE     activity_log.id_documento =
                                        p_id_documento_gdm
                                 AND p.id_documento = activity_log.id_documento
                                 AND DECODE (LOG.tipo_operazione,
                                             'E', LOG.data_operazione,
                                             LOG.data_aggiornamento) >= p.DATA
                                 AND LOG.id_log = activity_log.id_log
                                 AND LOG.FILENAME <> 'LETTERAUNIONE.RTFHIDDEN'
                          UNION
                          -- file attuale
                          SELECT LOG.id_documento AS log_id_documento,
                                 LOG.FILENAME AS log_valore,
                                 'Documento Principale' AS log_label_campo,
                                 LOG.data_aggiornamento AS log_data,
                                 'FILE' AS log_nome_campo,
                                 LOG.utente_aggiornamento AS log_utente,
                                 'M',
                                 LOG.id_oggetto_file AS ID_FILE,
                                 NULL AS ID_LOG,
                                 NVL (p.firmato, 'N') firmato
                            FROM gdm_oggetti_file LOG, agp_proto_view p
                           WHERE     LOG.id_documento = p_id_documento_gdm
                                 AND p.id_documento = LOG.id_documento
                                 --AND LOG.data_aggiornamento > p.data
                                 AND LOG.FILENAME <> 'LETTERAUNIONE.RTFHIDDEN')
                ORDER BY NVL (id_log, 9999999999))
         LOOP
            FOR princ
               IN (SELECT id_file_documento,
                          d.id_documento,
                          sequenza,
                          codice
                     FROM gdo_file_documento fd, gdo_documenti d
                    WHERE     d.id_documento_esterno =
                                 storico_file_princ.log_id_documento
                          AND fd.id_documento = d.id_documento
                          AND fd.codice IN ('FILE_PRINCIPALE',
                                            'FILE_ORIGINALE',
                                            'FILE_FRONTESPIZIO')
                          AND fd.valido = 'Y')
            LOOP
               d_id_file_documento := princ.id_file_documento;
               d_id_documento := princ.id_documento;
               d_sequenza := princ.sequenza;

               DBMS_OUTPUT.put_line (
                     '=== Revisione per id_documento_gdm '
                  || p_id_documento_gdm
                  || ', data '
                  || TO_CHAR (storico_file_princ.LOG_DATA,
                              'dd/mm/yyyy hh24:mi:ss')
                  || ', utente '
                  || storico_file_princ.LOG_UTENTE
                  || '?');
               d_id_rev :=
                  get_id_rev (prot.id_documento,
                              p_id_documento_gdm,
                              storico_file_princ.LOG_DATA,
                              storico_file_princ.LOG_UTENTE,
                              d_id_file_documento,
                              'GDO_FILE_DOCUMENTO_LOG',
                              d_esiste_rev,
                              d_esiste_rev_prot);
               DBMS_OUTPUT.put_line (
                     '=== '
                  || d_id_rev
                  || ' esiste rev? '
                  || d_esiste_rev
                  || ' esiste rev prot?'
                  || d_esiste_rev_prot);

               IF storico_file_princ.tipo_operazione = 'C'
               THEN
                  d_revtype := 0;
               ELSIF storico_file_princ.tipo_operazione = 'E'
               THEN
                  d_revtype := 2;
               ELSE
                  d_revtype := 1;
               END IF;

               IF d_esiste_rev = 1
               THEN
                  DBMS_OUTPUT.put_line (
                        'UPDATE GDO_FILE_DOCUMENTO_LOG WHERE     id_file_documento = '
                     || d_id_file_documento
                     || '  AND rev = '
                     || d_id_rev);
                  DBMS_OUTPUT.put_line (
                        'UPDATE GDO_FILE_DOCUMENTO_LOG SET dimensione = '
                     || gdm_ag_oggetti_file.get_len_storico (
                           storico_file_princ.id_file)
                     || ','
                     || 'dimensione_mod = 1,'
                     || 'firmato = '
                     || storico_file_princ.firmato
                     || ','
                     || 'firmato_mod = 1,'
                     || 'id_file_esterno = '
                     || storico_file_princ.id_file
                     || ','
                     || 'id_file_esterno_mod = 1,'
                     || 'nome = '
                     || storico_file_princ.log_valore
                     || ','
                     || 'nome_mod = '
                     || storico_file_princ.log_valore
                     || ','
                     || 'sequenza = '
                     || d_sequenza
                     || ','
                     || 'sequenza_mod = 1,'
                     || 'revisione_storico = '
                     || storico_file_princ.id_log
                     || ','
                     || 'revisione_mod = 1'
                     || ' WHERE     id_file_documento = '
                     || d_id_file_documento
                     || ' AND rev = '
                     || d_id_rev);

                  UPDATE GDO_FILE_DOCUMENTO_LOG
                     SET dimensione =
                            gdm_ag_oggetti_file.get_len_storico (
                               storico_file_princ.id_file),
                         dimensione_mod = 1,
                         firmato = storico_file_princ.firmato,
                         firmato_mod = 1,
                         id_file_esterno = storico_file_princ.id_file,
                         id_file_esterno_mod = 1,
                         nome = storico_file_princ.log_valore,
                         nome_mod = 1,
                         sequenza = d_sequenza,
                         sequenza_mod = 1,
                         revisione_storico = storico_file_princ.id_log,
                         revisione_mod = 1
                   WHERE     id_file_documento = d_id_file_documento
                         AND rev = d_id_rev;

                  DBMS_OUTPUT.put_line ('dopo');
               ELSE
                  INSERT INTO GDO_FILE_DOCUMENTO_LOG (id_file_documento,
                                                      rev,
                                                      revtype,
                                                      data_ins,
                                                      date_created_mod,
                                                      data_upd,
                                                      last_updated_mod,
                                                      valido,
                                                      valido_mod,
                                                      codice,
                                                      codice_mod,
                                                      content_type,
                                                      content_type_mod,
                                                      dimensione,
                                                      dimensione_mod,
                                                      firmato,
                                                      firmato_mod,
                                                      id_file_esterno,
                                                      id_file_esterno_mod,
                                                      modificabile,
                                                      modificabile_mod,
                                                      nome,
                                                      nome_mod,
                                                      sequenza,
                                                      sequenza_mod,
                                                      utente_ins,
                                                      utente_ins_mod,
                                                      utente_upd,
                                                      utente_upd_mod,
                                                      id_documento,
                                                      documento_mod,
                                                      revisione_storico,
                                                      revisione_mod)
                     SELECT d_id_file_documento,
                            d_id_rev,
                            d_revtype,
                            storico_file_princ.log_data,
                            1,
                            storico_file_princ.log_data,
                            1,
                            'Y',
                            1,
                            princ.codice,
                            1,
                            'application/octet-stream',
                            1,
                            gdm_ag_oggetti_file.get_len_storico (
                               storico_file_princ.id_file),
                            1,
                            storico_file_princ.firmato,
                            1,
                            storico_file_princ.id_file id_file_esterno,
                            1 id_file_esterno_mod,
                            'Y',
                            1,
                            storico_file_princ.log_valore,
                            1,
                            d_sequenza,
                            1,
                            storico_file_princ.log_utente,
                            1,
                            storico_file_princ.log_utente,
                            1,
                            d_id_documento,
                            1,
                            storico_file_princ.id_log,
                            1
                       FROM DUAL;
               END IF;

               IF d_esiste_rev_prot = 0
               THEN
                  DBMS_OUTPUT.put_line (
                        '=== INSERT INTO GDO_DOCUMENTI_LOG ID_DOCUMENTO '
                     || prot.id_documento
                     || ', REV '
                     || d_id_rev);

                  INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                                 REV,
                                                 REVTYPE,
                                                 DATA_INS,
                                                 DATA_UPD,
                                                 UTENTE_INS,
                                                 UTENTE_UPD,
                                                 id_documento_esterno)
                     SELECT prot.id_documento,
                            d_id_rev,
                            DECODE (d_id_file_documento, 0, 0, 1),
                            storico_file_princ.log_data,
                            storico_file_princ.log_data,
                            storico_file_princ.LOG_UTENTE,
                            storico_file_princ.LOG_UTENTE,
                            p_id_documento_gdm
                       FROM DUAL
                      WHERE NOT EXISTS
                               (SELECT 1
                                  FROM GDO_DOCUMENTI_LOG
                                 WHERE     ID_DOCUMENTO = prot.id_documento
                                       AND rev = d_id_rev);


                  INSERT INTO AGP_PROTOCOLLI_LOG (id_documento,
                                                  rev,
                                                  anno,
                                                  data,
                                                  idrif,
                                                  numero,
                                                  tipo_registro)
                     SELECT prot.id_documento,
                            d_id_rev,
                            prot.anno,
                            prot.data,
                            prot.idrif,
                            prot.numero,
                            prot.tipo_registro
                       FROM DUAL
                      WHERE NOT EXISTS
                               (SELECT 1
                                  FROM AGP_PROTOCOLLI_LOG
                                 WHERE     ID_DOCUMENTO = prot.id_documento
                                       AND rev = d_id_rev);

                  INSERT INTO TEMP_STORICO (ID_DOCUMENTO,
                                            REV,
                                            ID_DOCUMENTO_PROT_GDM,
                                            LOG_DATA,
                                            LOG_UTENTE,
                                            TABELLA)
                       VALUES (prot.id_documento,
                               d_id_rev,
                               p_id_documento_gdm,
                               storico_file_princ.log_data,
                               storico_file_princ.LOG_UTENTE,
                               'AGP_PROTOCOLLI_LOG');
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;

      -- Aggiusto i revtype in base alle regole di envers per cui:
      --    il primo record è sempre CREATO (0)
      --    un record ELIMINATO (2) è sempre l'ultimo perchè non può essere aggiornato
      --    gli altri sono sempre MODIFICATI (1)
      -- le rev sono in questo momento negative, perciò il min = max e viceversa
      FOR f
         IN (  SELECT MIN (rev) max_rev, MAX (rev) min_rev, id_file_documento
                 FROM GDO_FILE_DOCUMENTO_LOG
                WHERE id_documento =
                         (SELECT id_documento
                            FROM gdo_documenti
                           WHERE id_documento_esterno = p_id_documento_gdm)
             GROUP BY id_file_documento)
      LOOP
         UPDATE GDO_FILE_DOCUMENTO_LOG
            SET revtype = 1
          WHERE     id_file_documento = f.id_file_documento
                AND rev NOT IN (f.min_rev, f.max_rev)
                AND revtype = 2;

         UPDATE GDO_FILE_DOCUMENTO_LOG
            SET revtype = 0
          WHERE id_file_documento = f.id_file_documento AND rev = f.min_rev;
      END LOOP;

      DECLARE
         d_conta_neg   NUMBER := 0;
      BEGIN
         FOR r
            IN (  SELECT *
                    FROM GDO_FILE_DOCUMENTO_LOG
                   WHERE id_documento =
                            (SELECT id_documento
                               FROM gdo_documenti
                              WHERE     id_documento_esterno =
                                           p_id_documento_gdm
                                    AND valido = 'Y')
                ORDER BY data_ins)
         LOOP
            IF r.rev < 0
            THEN
               d_conta_neg := d_conta_neg + 1;
            END IF;

            IF d_conta_neg = 1
            THEN
               UPDATE GDO_FILE_DOCUMENTO_LOG
                  SET revend = r.rev
                WHERE     id_file_documento = r.id_file_documento
                      AND revend IS NULL
                      AND NVL (rev, 0) > 0;
            END IF;

            UPDATE GDO_FILE_DOCUMENTO_LOG
               SET revend =
                      (SELECT MAX (rev) revend
                         FROM GDO_FILE_DOCUMENTO_LOG prco2
                        WHERE     prco2.id_documento = r.id_documento
                              AND prco2.id_file_documento =
                                     r.id_file_documento
                              AND prco2.rev < r.rev)
             WHERE     id_file_documento = r.id_file_documento
                   AND rev = r.rev
                   AND NVL (rev, 0) < 0;
         END LOOP;
      END;
   END;

   --------------------------------------------------------------------------------

   PROCEDURE crea_storico_corrispondenti (p_id_documento_gdm NUMBER)
   IS
      d_sql                 VARCHAR2 (32000);

      d_id_rev              NUMBER;
      d_id_doc_corr_agspr   NUMBER;

      d_esiste_rev          NUMBER := 0;
      d_esiste_rev_prot     NUMBER := 0;
      d_continua            BOOLEAN := TRUE;
   BEGIN
      FOR prot
         IN (SELECT p.*, d.id_documento_esterno
               FROM gdo_documenti d, agp_protocolli p
              WHERE     d.id_documento_esterno = p_id_documento_gdm
                    AND p.id_documento = d.id_documento)
      LOOP
         FOR soggetto
            IN (SELECT S.ID_DOCUMENTO, d.stato_documento
                  FROM gdm_seg_soggetti_protocollo S,
                       agp_proto_view P,
                       gdm_documenti d
                 WHERE     S.idrif = P.idrif
                       AND tipo_rapporto <> 'DUMMY'
                       AND P.ID_DOCUMENTO = p_id_documento_gdm
                       AND d.id_documento = p.id_documento)
         LOOP
            DBMS_OUTPUT.put_line ('prot.id_documento ' || prot.id_documento);
            DBMS_OUTPUT.put_line (
               'soggetto.id_documento ' || soggetto.id_documento);

            DELETE temp_storico_corr;

            INSERT INTO temp_storico_corr (ID,
                                           ID_DOCUMENTO,
                                           IDRIF,
                                           LOG_ID_DOCUMENTO,
                                           LOG_DATA,
                                           LOG_UTENTE,
                                           ID_VALORE_LOG,
                                           DENOMINAZIONE_PER_SEGNATURA,
                                           COGNOME_PER_SEGNATURA,
                                           NOME_PER_SEGNATURA,
                                           DESCRIZIONE_AMM,
                                           DESCRIZIONE_AOO,
                                           CONOSCENZA,
                                           DENOMINAZIONE_MOD,
                                           COGNOME_MOD,
                                           NOME_MOD,
                                           DESCRIZIONE_AMM_MOD,
                                           DESCRIZIONE_AOO_MOD,
                                           CONOSCENZA_MOD)
               (SELECT -ROWNUM + 1,
                       S.ID_DOCUMENTO,
                       S.IDRIF,
                       -1,
                       Prot.DATA - 1,
                       'TRASCO',
                       -1,
                       DENOMINAZIONE_PER_SEGNATURA,
                       COGNOME_PER_SEGNATURA,
                       NOME_PER_SEGNATURA,
                       DESCRIZIONE_AMM,
                       DESCRIZIONE_AOO,
                       CONOSCENZA,
                       0 DENOMINAZIONE_MOD,
                       0 COGNOME_MOD,
                       0 NOME_MOD,
                       0 DESCRIZIONE_AMM_MOD,
                       0 DESCRIZIONE_AOO_MOD,
                       0 CONOSCENZA_MOD
                  FROM gdm_seg_soggetti_protocollo S
                 WHERE s.ID_DOCUMENTO = soggetto.id_documento
                UNION
                SELECT ROWNUM id, LOG.*
                  FROM (  SELECT id_documento,
                                 idrif,
                                 log_id_documento,
                                 log_data,
                                 log_utente,
                                 MIN (id_valore_log) id_valore_log,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'DENOMINAZIONE_PER_SEGNATURA'
                                       THEN
                                          log_valore
                                    END)
                                    DENOMINAZIONE_PER_SEGNATURA,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'COGNOME_PER_SEGNATURA'
                                       THEN
                                          log_valore
                                    END)
                                    COGNOME_PER_SEGNATURA,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'NOME_PER_SEGNATURA'
                                       THEN
                                          log_valore
                                    END)
                                    NOME_PER_SEGNATURA,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'DESCRIZIONE_AMM'
                                       THEN
                                          log_valore
                                    END)
                                    DESCRIZIONE_AMM,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'DESCRIZIONE_AMM'
                                       THEN
                                          log_valore
                                    END)
                                    DESCRIZIONE_AOO,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'CONOSCENZA'
                                       THEN
                                          log_valore
                                    END)
                                    CONOSCENZA,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'DENOMINAZIONE_PER_SEGNATURA'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    DENOMINAZIONE_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'COGNOME_PER_SEGNATURA'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    COGNOME_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo =
                                               'NOME_PER_SEGNATURA'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    NOME_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'DESCRIZIONE_AMM'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    DESCRIZIONE_AMM_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'DESCRIZIONE_AOO'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    DESCRIZIONE_AOO_MOD,
                                 MAX (
                                    CASE
                                       WHEN log_nome_campo = 'CONOSCENZA'
                                       THEN
                                          1
                                       ELSE
                                          0
                                    END)
                                    CONOSCENZA_MOD
                            FROM (SELECT sogg.id_documento,
                                         p.idrif,
                                         id_valore_log,
                                         activity_log.id_documento
                                            AS log_id_documento,
                                         NVL (
                                            TO_CHAR (LOG.valore_clob),
                                            NVL (
                                               TO_CHAR (LOG.valore_data,
                                                        'dd/mm/yyyy'),
                                               NVL (
                                                  TO_CHAR (LOG.valore_numero),
                                                  '')))
                                            AS log_valore,
                                         /* se la data è minore di quella di protocollazione, usa la data di protocollazione */
                                         DECODE (
                                            SIGN (
                                                 NVL (p.data,
                                                      TO_DATE (2222222, 'j'))
                                               - activity_log.data_aggiornamento),
                                            -1, activity_log.data_aggiornamento,
                                            p.data)
                                            AS log_data,
                                         LOG.colonna AS log_nome_campo,
                                         /* se la data è minore di quella di protocollazione l'utente */
                                         DECODE (
                                            SIGN (
                                                 NVL (p.data,
                                                      TO_DATE (2222222, 'j'))
                                               - activity_log.data_aggiornamento),
                                            -1, activity_log.utente_aggiornamento,
                                            DECODE (
                                               activity_log.utente_aggiornamento,
                                               'RPI', p.utente_protocollante,
                                               activity_log.utente_aggiornamento))
                                            AS log_utente
                                    FROM gdm_valori_log LOG,
                                         gdm_activity_log activity_log,
                                         gdm_dati_modello dati_modello,
                                         agp_proto_view p,
                                         gdm_seg_soggetti_protocollo sogg
                                   WHERE     p.id_documento =
                                                prot.id_documento_esterno
                                         AND sogg.idrif = p.idrif
                                         AND sogg.id_documento =
                                                soggetto.id_documento
                                         AND sogg.tipo_rapporto <> 'DUMMY'
                                         AND activity_log.id_documento =
                                                sogg.id_documento
                                         AND LOG.id_log = activity_log.id_log
                                         AND dati_modello.area = 'SEGRETERIA'
                                         AND dati_modello.codice_modello =
                                                'M_SOGGETTO'
                                         AND DATI_MODELLO.DATO = LOG.COLONNA
                                         /*AND (   LOG.valore_clob IS NOT NULL
                                              OR LOG.valore_data IS NOT NULL
                                              OR LOG.valore_numero IS NOT NULL)*/
                                         AND activity_log.data_aggiornamento >=
                                                NVL (
                                                   (SELECT MAX (
                                                              activity_log.data_aggiornamento)
                                                      FROM gdm_valori_log valori_log,
                                                           gdm_activity_log al
                                                     WHERE     activity_log.id_documento =
                                                                  al.id_documento
                                                           AND al.data_aggiornamento <=
                                                                  (SELECT data
                                                                     FROM agp_proto_view
                                                                    WHERE id_documento =
                                                                             al.id_documento)
                                                           AND valori_log.id_log =
                                                                  al.id_log
                                                           AND LOG.COLONNA =
                                                                  VALORI_LOG.COLONNA),
                                                   activity_log.data_aggiornamento))
                        GROUP BY id_documento,
                                 idrif,
                                 log_id_documento,
                                 log_data,
                                 log_utente
                        ORDER BY log_data, id_valore_log) LOG);

            FOR storico_corr
               IN (  SELECT TEMP_STORICO_CORR.id,
                            LOG_DATA,
                            LOG_UTENTE,
                            id_documento,
                            get_valore_log ('TEMP_STORICO_CORR',
                                            'DENOMINAZIONE_PER_SEGNATURA',
                                            TEMP_STORICO_CORR.id)
                               DENOMINAZIONE_PER_SEGNATURA,
                            get_valore_log ('TEMP_STORICO_CORR',
                                            'COGNOME_PER_SEGNATURA',
                                            TEMP_STORICO_CORR.id)
                               COGNOME_PER_SEGNATURA,
                            get_valore_log ('TEMP_STORICO_CORR',
                                            'NOME_PER_SEGNATURA',
                                            TEMP_STORICO_CORR.id)
                               NOME_PER_SEGNATURA,
                            get_valore_log ('TEMP_STORICO_CORR',
                                            'DESCRIZIONE_AMM',
                                            TEMP_STORICO_CORR.id)
                               DESCRIZIONE_AMM,
                            get_valore_log ('TEMP_STORICO_CORR',
                                            'DESCRIZIONE_AOO',
                                            TEMP_STORICO_CORR.id)
                               DESCRIZIONE_AOO,
                            get_valore_log ('TEMP_STORICO_CORR',
                                            'CONOSCENZA',
                                            TEMP_STORICO_CORR.id)
                               CONOSCENZA,
                            DENOMINAZIONE_MOD,
                            COGNOME_MOD,
                            NOME_MOD,
                            DESCRIZIONE_AMM_MOD,
                            DESCRIZIONE_AOO_MOD,
                            CONOSCENZA_MOD
                       FROM TEMP_STORICO_CORR
                   ORDER BY id_documento, id)
            LOOP
               d_continua := TRUE;

               BEGIN
                  SELECT id_protocollo_corrispondente
                    INTO d_id_doc_corr_agspr
                    FROM agp_protocolli_corrispondenti
                   WHERE id_documento_esterno = storico_corr.id_documento;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- se non lo trova su agspr ma c'è su gdm cancellato,
                     -- lo inserisce non valido
                     IF soggetto.stato_documento = 'CA'
                     THEN
                        INSERT INTO AGP_PROTOCOLLI_CORRISPONDENTI (
                                       ID_PROTOCOLLO_CORRISPONDENTE,
                                       ID_DOCUMENTO,
                                       DENOMINAZIONE,
                                       COGNOME,
                                       NOME,
                                       CONOSCENZA,
                                       ID_DOCUMENTO_ESTERNO,
                                       UTENTE_INS,
                                       DATA_INS,
                                       UTENTE_UPD,
                                       DATA_UPD,
                                       VERSION,
                                       VALIDO)
                           SELECT hibernate_sequence.NEXTVAL,
                                  prot.id_documento,
                                  DECODE (
                                     storico_corr.DENOMINAZIONE_PER_SEGNATURA,
                                     NULL, DECODE (
                                              storico_corr.DESCRIZIONE_AOO,
                                              NULL, DECODE (
                                                       storico_corr.DESCRIZIONE_AMM,
                                                       NULL, DECODE (
                                                                storico_corr.NOME_PER_SEGNATURA,
                                                                NULL, storico_corr.COGNOME_PER_SEGNATURA,
                                                                   storico_corr.COGNOME_PER_SEGNATURA
                                                                || ' '
                                                                || storico_corr.NOME_PER_SEGNATURA),
                                                       storico_corr.DESCRIZIONE_AMM),
                                                 storico_corr.DESCRIZIONE_AMM
                                              || ':AOO:'
                                              || storico_corr.DESCRIZIONE_AOO),
                                     storico_corr.DENOMINAZIONE_PER_SEGNATURA),
                                  storico_corr.COGNOME_PER_SEGNATURA,
                                  storico_corr.NOME_PER_SEGNATURA,
                                  storico_corr.CONOSCENZA,
                                  soggetto.ID_DOCUMENTO,
                                  storico_corr.log_utente,
                                  storico_corr.log_data,
                                  storico_corr.log_utente,
                                  storico_corr.log_data,
                                  0,
                                  'N'
                             FROM DUAL;
                     ELSE
                        d_continua := FALSE;
                     END IF;
               END;

               IF d_continua
               THEN
                  d_id_rev :=
                     get_id_rev (prot.id_documento,
                                 p_id_documento_gdm,
                                 storico_corr.LOG_DATA,
                                 storico_corr.LOG_UTENTE,
                                 d_id_doc_corr_agspr,
                                 'AGP_PROTOCOLLI_CORR_LOG',
                                 d_esiste_rev,
                                 d_esiste_rev_prot);
                  DBMS_OUTPUT.put_line (
                        ' === Rev: '
                     || d_id_rev
                     || ' esiste? '
                     || d_esiste_rev
                     || ' esiste prot? '
                     || d_esiste_rev_prot);



                  IF d_esiste_rev = 1
                  THEN
                     UPDATE AGP_PROTOCOLLI_CORR_LOG
                        SET DENOMINAZIONE =
                               DECODE (
                                  storico_corr.DENOMINAZIONE_PER_SEGNATURA,
                                  NULL, DECODE (
                                           storico_corr.DESCRIZIONE_AOO,
                                           NULL, DECODE (
                                                    storico_corr.DESCRIZIONE_AMM,
                                                    NULL, DECODE (
                                                             storico_corr.NOME_PER_SEGNATURA,
                                                             NULL, storico_corr.COGNOME_PER_SEGNATURA,
                                                                storico_corr.COGNOME_PER_SEGNATURA
                                                             || ' '
                                                             || storico_corr.NOME_PER_SEGNATURA),
                                                    storico_corr.DESCRIZIONE_AMM),
                                              storico_corr.DESCRIZIONE_AMM
                                           || ':AOO:'
                                           || storico_corr.DESCRIZIONE_AOO),
                                  storico_corr.DENOMINAZIONE_PER_SEGNATURA),
                            COGNOME = storico_corr.COGNOME_PER_SEGNATURA,
                            NOME = storico_corr.NOME_PER_SEGNATURA,
                            CONOSCENZA = storico_corr.CONOSCENZA,
                            DENOMINAZIONE_MOD = storico_corr.DENOMINAZIONE_MOD,
                            COGNOME_MOD = storico_corr.COGNOME_MOD,
                            NOME_MOD = storico_corr.NOME_MOD
                      WHERE     ID_PROTOCOLLO_CORRISPONDENTE =
                                   d_id_doc_corr_agspr
                            AND REV = d_id_rev;
                  ELSE
                     DBMS_OUTPUT.put_line (
                           ' === sto inserendo in AGP_PROTOCOLLI_CORR_LOG  ID_PROTOCOLLO_CORRISPONDENTE: '
                        || d_id_doc_corr_agspr
                        || ', rev: '
                        || d_id_rev);

                     INSERT
                       INTO AGP_PROTOCOLLI_CORR_LOG (
                               ID_PROTOCOLLO_CORRISPONDENTE,
                               REV,
                               REVTYPE,
                               DATA_INS,
                               DATE_CREATED_MOD,
                               DATA_UPD,
                               DENOMINAZIONE,
                               COGNOME,
                               NOME,
                               CONOSCENZA,
                               DENOMINAZIONE_MOD,
                               COGNOME_MOD,
                               NOME_MOD,
                               CONOSCENZA_MOD,
                               UTENTE_INS,
                               UTENTE_UPD,
                               ID_DOCUMENTO)
                        VALUES (
                                  d_id_doc_corr_agspr,
                                  d_id_rev,
                                  DECODE (storico_corr.log_utente,
                                          'TRASCO', 2,
                                          DECODE (storico_corr.id, 1, 0, 1)), -- 2 per evitare si vedano tra i dati di protocollazione
                                  storico_corr.log_data,
                                  1,
                                  storico_corr.log_data,
                                  DECODE (
                                     storico_corr.DENOMINAZIONE_PER_SEGNATURA,
                                     NULL, DECODE (
                                              storico_corr.DESCRIZIONE_AOO,
                                              NULL, DECODE (
                                                       storico_corr.DESCRIZIONE_AMM,
                                                       NULL, DECODE (
                                                                storico_corr.NOME_PER_SEGNATURA,
                                                                NULL, storico_corr.COGNOME_PER_SEGNATURA,
                                                                   storico_corr.COGNOME_PER_SEGNATURA
                                                                || ' '
                                                                || storico_corr.NOME_PER_SEGNATURA),
                                                       storico_corr.DESCRIZIONE_AMM),
                                                 storico_corr.DESCRIZIONE_AMM
                                              || ':AOO:'
                                              || storico_corr.DESCRIZIONE_AOO),
                                     storico_corr.DENOMINAZIONE_PER_SEGNATURA),
                                  storico_corr.COGNOME_PER_SEGNATURA,
                                  storico_corr.NOME_PER_SEGNATURA,
                                  storico_corr.CONOSCENZA,
                                  storico_corr.DENOMINAZIONE_MOD,
                                  storico_corr.COGNOME_MOD,
                                  storico_corr.NOME_MOD,
                                  storico_corr.CONOSCENZA_MOD,
                                  storico_corr.LOG_UTENTE,
                                  storico_corr.LOG_UTENTE,
                                  prot.id_documento);

                     IF d_esiste_rev_prot = 1
                     THEN
                        UPDATE AGP_PROTOCOLLI_LOG
                           SET corrispondenti_mod = 1
                         WHERE     ID_DOCUMENTO = prot.id_documento
                               AND REV = d_id_rev;
                     ELSE
                        INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                                       REV,
                                                       REVTYPE,
                                                       DATA_INS,
                                                       DATA_UPD,
                                                       UTENTE_INS,
                                                       UTENTE_UPD,
                                                       id_documento_esterno)
                             VALUES (prot.id_documento,
                                     d_id_rev,
                                     DECODE (d_id_doc_corr_agspr, 0, 0, 1),
                                     storico_corr.LOG_DATA,
                                     storico_corr.LOG_DATA,
                                     storico_corr.LOG_UTENTE,
                                     storico_corr.LOG_UTENTE,
                                     p_id_documento_gdm);


                        INSERT INTO AGP_PROTOCOLLI_LOG (id_documento,
                                                        rev,
                                                        anno,
                                                        data,
                                                        idrif,
                                                        numero,
                                                        corrispondenti_mod,
                                                        tipo_registro)
                           SELECT prot.id_documento,
                                  d_id_rev,
                                  prot.anno,
                                  prot.data,
                                  prot.idrif,
                                  prot.numero,
                                  1,
                                  prot.tipo_registro
                             FROM DUAL;

                        INSERT INTO TEMP_STORICO (ID_DOCUMENTO,
                                                  REV,
                                                  ID_DOCUMENTO_PROT_GDM,
                                                  LOG_DATA,
                                                  LOG_UTENTE,
                                                  TABELLA)
                             VALUES (prot.id_documento,
                                     d_id_rev,
                                     p_id_documento_gdm,
                                     storico_corr.LOG_DATA,
                                     storico_corr.LOG_UTENTE,
                                     'AGP_PROTOCOLLI_LOG');
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;


      FOR r
         IN (  SELECT *
                 FROM AGP_PROTOCOLLI_CORR_LOG
                WHERE id_documento =
                         (SELECT id_documento
                            FROM gdo_documenti
                           WHERE id_documento_esterno = p_id_documento_gdm)
             ORDER BY data_ins)
      LOOP
         UPDATE AGP_PROTOCOLLI_CORR_LOG
            SET revend =
                   (SELECT MIN (rev) revend
                      FROM AGP_PROTOCOLLI_CORR_LOG prco2
                     WHERE     prco2.id_documento = r.id_documento
                           AND prco2.id_protocollo_corrispondente =
                                  r.id_protocollo_corrispondente
                           AND data_ins =
                                  (SELECT MIN (data_ins)
                                     FROM AGP_PROTOCOLLI_CORR_LOG prco3
                                    WHERE     prco3.id_documento =
                                                 prco2.id_documento
                                          AND prco3.id_protocollo_corrispondente =
                                                 prco2.id_protocollo_corrispondente
                                          AND prco3.data_ins > r.data_ins))
          WHERE     id_protocollo_corrispondente =
                       r.id_protocollo_corrispondente
                AND rev = r.rev
                AND NVL (revend, 0) <= 0;
      END LOOP;
   END;

   PROCEDURE crea_storico_dati_scarto (p_id_documento_gdm NUMBER)
   IS
      d_sql                  VARCHAR2 (32000);

      d_id_rev               NUMBER;
      d_id_doc_dati_scarto   NUMBER;

      d_esiste_rev           NUMBER := 0;
      d_esiste_rev_prot      NUMBER := 0;
   BEGIN
      FOR prot
         IN (SELECT p.*, d.id_documento_esterno
               FROM gdo_documenti d, agp_protocolli p
              WHERE     d.id_documento_esterno = p_id_documento_gdm
                    AND p.id_documento = d.id_documento
                    AND id_protocollo_dati_scarto IS NOT NULL)
      LOOP
         INSERT INTO TEMP_STORICO_DOC_DATI_SCARTO (ID,
                                                   ID_DOCUMENTO,
                                                   LOG_ID_DOCUMENTO,
                                                   LOG_DATA,
                                                   LOG_UTENTE,
                                                   ID_VALORE_LOG,
                                                   STATO,
                                                   DATA_STATO,
                                                   NULLA_OSTA,
                                                   DATA_NULLA_OSTA,
                                                   STATO_MOD,
                                                   DATA_STATO_MOD,
                                                   NULLA_OSTA_MOD,
                                                   DATA_NULLA_OSTA_MOD)
            (SELECT -ROWNUM + 1 ID,
                    ID_DOCUMENTO,
                    -1 LOG_ID_DOCUMENTO,
                    DATA - 1 LOG_DATA,
                    'TRASCO' LOG_UTENTE,
                    -1 ID_VALORE_LOG,
                    STATO_SCARTO,
                    DATA_STATO_SCARTO,
                    NUMERO_NULLA_OSTA,
                    DATA_NULLA_OSTA,
                    0,
                    0,
                    0,
                    0
               FROM AGP_PROTO_VIEW
              WHERE ID_DOCUMENTO = p_id_documento_gdm
             UNION
             SELECT ROWNUM id, LOG.*
               FROM (  SELECT id_documento,
                              log_id_documento,
                              log_data,
                              log_utente,
                              MIN (id_valore_log) id_valore_log,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'STATO_SCARTO'
                                    THEN
                                       log_valore
                                 END)
                                 STATO,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'DATA_STATO_SCARTO'
                                    THEN
                                       TO_DATE (log_valore,
                                                'dd/mm/yyyy hh24:mi:ss')
                                 END)
                                 DATA_STATO,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'NUMERO_NULLA_OSTA'
                                    THEN
                                       log_valore
                                 END)
                                 NULLA_OSTA,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'DATA_NULLA_OSTA'
                                    THEN
                                       TO_DATE (log_valore,
                                                'dd/mm/yyyy hh24:mi:ss')
                                 END)
                                 DATA_NULLA_OSTA,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'STATO_SCARTO' THEN 1
                                    ELSE 0
                                 END)
                                 STATO_MOD,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'DATA_STATO_SCARTO'
                                    THEN
                                       1
                                    ELSE
                                       0
                                 END)
                                 DATA_SCARTO_MOD,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'NUMERO_NULLA_OSTA'
                                    THEN
                                       1
                                    ELSE
                                       0
                                 END)
                                 NULLA_OSTA_MOD,
                              MAX (
                                 CASE
                                    WHEN log_nome_campo = 'DATA_NULLA_OSTA'
                                    THEN
                                       1
                                    ELSE
                                       0
                                 END)
                                 DATA_NULLA_OSTA_MOD
                         FROM (SELECT p.id_documento,
                                      id_valore_log,
                                      activity_log.id_documento
                                         AS log_id_documento,
                                      NVL (
                                         TO_CHAR (LOG.valore_clob),
                                         NVL (
                                            TO_CHAR (LOG.valore_data,
                                                     'dd/mm/yyyy hh24:mi:ss'),
                                            NVL (TO_CHAR (LOG.valore_numero),
                                                 '')))
                                         AS log_valore,
                                      -- se la data è minore di quella di protocollazione, usa la data di protocollazione
                                      DECODE (
                                         SIGN (
                                              NVL (p.data,
                                                   TO_DATE (2222222, 'j'))
                                            - activity_log.data_aggiornamento),
                                         -1, activity_log.data_aggiornamento,
                                         p.data)
                                         AS log_data,
                                      LOG.colonna AS log_nome_campo,
                                      -- se la data è minore di quella di protocollazionee l'utente
                                      DECODE (
                                         SIGN (
                                              NVL (p.data,
                                                   TO_DATE (2222222, 'j'))
                                            - activity_log.data_aggiornamento),
                                         -1, activity_log.utente_aggiornamento,
                                         DECODE (
                                            activity_log.utente_aggiornamento,
                                            'RPI', p.utente_protocollante,
                                            activity_log.utente_aggiornamento))
                                         AS log_utente
                                 FROM gdm_valori_log LOG,
                                      gdm_activity_log activity_log,
                                      gdm_dati_modello dati_modello,
                                      agp_proto_view p
                                WHERE     activity_log.id_documento =
                                             p_id_documento_gdm
                                      AND p.id_documento =
                                             activity_log.id_documento
                                      AND LOG.id_log = activity_log.id_log
                                      AND dati_modello.area =
                                             'SEGRETERIA.PROTOCOLLO'
                                      AND dati_modello.codice_modello =
                                             'M_PROTOCOLLO'
                                      AND DATI_MODELLO.DATO = LOG.COLONNA
                                      AND LOG.colonna IN ('STATO_SCARTO',
                                                          'DATA_STATO_SCARTO',
                                                          'NUMERO_NULLA_OSTA',
                                                          'DATA_NULLA_OSTA')
                                      AND activity_log.data_aggiornamento >=
                                             NVL (
                                                (SELECT MAX (
                                                           activity_log.data_aggiornamento)
                                                   FROM gdm_valori_log valori_log,
                                                        gdm_activity_log al
                                                  WHERE     activity_log.id_documento =
                                                               al.id_documento
                                                        AND al.data_aggiornamento <=
                                                               (SELECT data
                                                                  FROM agp_proto_view
                                                                 WHERE id_documento =
                                                                          al.id_documento)
                                                        AND valori_log.id_log =
                                                               al.id_log
                                                        AND LOG.COLONNA =
                                                               VALORI_LOG.COLONNA),
                                                activity_log.data_aggiornamento))
                     GROUP BY id_documento,
                              log_id_documento,
                              log_data,
                              log_utente
                     ORDER BY log_data, id_valore_log) LOG);

         FOR storico
            IN (  SELECT TEMP_STORICO_DOC_DATI_SCARTO.id,
                         LOG_DATA,
                         LOG_UTENTE,
                         id_documento,
                         get_valore_log ('TEMP_STORICO_DOC_DATI_SCARTO',
                                         'STATO',
                                         TEMP_STORICO_DOC_DATI_SCARTO.id)
                            STATO,
                         get_valore_log ('TEMP_STORICO_DOC_DATI_SCARTO',
                                         'DATA_STATO',
                                         TEMP_STORICO_DOC_DATI_SCARTO.id)
                            DATA_STATO,
                         get_valore_log ('TEMP_STORICO_DOC_DATI_SCARTO',
                                         'NULLA_OSTA',
                                         TEMP_STORICO_DOC_DATI_SCARTO.id)
                            NULLA_OSTA,
                         get_valore_log ('TEMP_STORICO_DOC_DATI_SCARTO',
                                         'DATA_NULLA_OSTA',
                                         TEMP_STORICO_DOC_DATI_SCARTO.id)
                            DATA_NULLA_OSTA,
                         STATO_MOD,
                         DATA_STATO_MOD,
                         NULLA_OSTA_MOD,
                         DATA_NULLA_OSTA_MOD
                    FROM TEMP_STORICO_DOC_DATI_SCARTO
                ORDER BY id_documento, id)
         LOOP
            d_id_doc_dati_scarto := prot.id_protocollo_dati_scarto;
            d_id_rev :=
               get_id_rev (prot.id_documento,
                           p_id_documento_gdm,
                           storico.LOG_DATA,
                           storico.LOG_UTENTE,
                           d_id_doc_dati_scarto,
                           'AGP_DOCUMENTI_DATI_SCARTO_LOG',
                           d_esiste_rev,
                           d_esiste_rev_prot);

            IF d_esiste_rev = 1
            THEN
               UPDATE AGP_DOCUMENTI_DATI_SCARTO_LOG
                  SET STATO = storico.STATO,
                      DATA_STATO = storico.DATA_STATO,
                      NULLA_OSTA = storico.NULLA_OSTA,
                      DATA_NULLA_OSTA = storico.DATA_NULLA_OSTA
                WHERE     ID_DOCUMENTO_DATI_SCARTO = d_id_doc_dati_scarto
                      AND rev = d_id_rev;
            ELSE
               INSERT
                 INTO AGP_DOCUMENTI_DATI_SCARTO_LOG (
                         ID_DOCUMENTO_DATI_SCARTO,
                         REV,
                         REVTYPE,
                         STATO,
                         DATA_STATO,
                         NULLA_OSTA,
                         DATA_NULLA_OSTA,
                         UTENTE_INS,
                         DATA_INS,
                         UTENTE_UPD,
                         DATA_UPD)
                  VALUES (
                            d_id_doc_dati_scarto,
                            d_id_rev,
                            DECODE (storico.log_utente,
                                    'TRASCO', 2,
                                    DECODE (storico.id, 1, 0, 1)), -- 2 per evitare si vedano tra i dati di protocollazione
                            storico.STATO,
                            storico.DATA_STATO,
                            storico.NULLA_OSTA,
                            storico.DATA_NULLA_OSTA,
                            storico.LOG_UTENTE,
                            storico.LOG_DATA,
                            storico.LOG_UTENTE,
                            storico.LOG_DATA);
            END IF;

            IF d_esiste_rev_prot = 0
            THEN
               INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                              REV,
                                              REVTYPE,
                                              DATA_INS,
                                              DATA_UPD,
                                              UTENTE_INS,
                                              UTENTE_UPD)
                    VALUES (prot.id_documento,
                            d_id_rev,
                            DECODE (d_id_doc_dati_scarto, 0, 0, 1),
                            storico.log_data,
                            storico.log_data,
                            storico.LOG_UTENTE,
                            storico.LOG_UTENTE);

               INSERT INTO AGP_PROTOCOLLI_LOG (id_documento,
                                               rev,
                                               anno,
                                               data,
                                               idrif,
                                               numero,
                                               dati_scarto_mod,
                                               tipo_registro)
                  SELECT prot.id_documento,
                         d_id_rev,
                         prot.anno,
                         prot.data,
                         prot.idrif,
                         prot.numero,
                         1,
                         prot.tipo_registro
                    FROM DUAL;

               INSERT INTO TEMP_STORICO (ID_DOCUMENTO,
                                         REV,
                                         ID_DOCUMENTO_PROT_GDM,
                                         LOG_DATA,
                                         LOG_UTENTE,
                                         TABELLA)
                    VALUES (prot.id_documento,
                            d_id_rev,
                            p_id_documento_gdm,
                            storico.LOG_DATA,
                            storico.LOG_UTENTE,
                            'AGP_PROTOCOLLI_LOG');
            END IF;
         END LOOP;
      END LOOP;

      FOR r
         IN (  SELECT *
                 FROM AGP_DOCUMENTI_DATI_SCARTO_LOG
                WHERE id_documento_dati_scarto =
                         (SELECT id_documento_dati_scarto
                            FROM agp_protocolli p, gdo_documenti d
                           WHERE     id_documento_esterno = p_id_documento_gdm
                                 AND p.id_documento = d.id_documento)
             ORDER BY data_ins)
      LOOP
         UPDATE AGP_DOCUMENTI_DATI_SCARTO_LOG
            SET revend =
                   (SELECT MIN (rev) revend
                      FROM AGP_DOCUMENTI_DATI_SCARTO_LOG prco2
                     WHERE     prco2.id_documento_dati_scarto =
                                  r.id_documento_dati_scarto
                           AND data_ins =
                                  (SELECT MIN (data_ins)
                                     FROM AGP_DOCUMENTI_DATI_SCARTO_LOG prco3
                                    WHERE     prco3.id_documento_dati_scarto =
                                                 prco2.id_documento_dati_scarto
                                          AND prco3.data_ins > r.data_ins))
          WHERE     id_documento_dati_scarto = r.id_documento_dati_scarto
                AND rev = r.rev
                AND NVL (revend, 0) <= 0;
      END LOOP;
   END;

   PROCEDURE crea_storico_protocollo (p_id_documento_gdm      NUMBER,
                                      p_id_documento_agspr    NUMBER)
   IS
      d_id_class       NUMBER;
      d_id_fascicolo   NUMBER;

      d_sql            VARCHAR2 (32000);

      d_id_doc_agspr   NUMBER := p_id_documento_agspr;
      d_id_rev         NUMBER;

      d_esiste_rev     NUMBER := 0;
   BEGIN
      IF d_id_doc_agspr IS NULL
      THEN
         BEGIN
            SELECT id_documento
              INTO d_id_doc_agspr
              FROM gdo_documenti
             WHERE id_documento_esterno = p_id_documento_gdm;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               raise_application_error (
                  -20999,
                     'Nessun documento trovato in GDO_DOCUMENTI con id_documento_esterno '
                  || p_id_documento_gdm);
         END;
      END IF;

      INSERT INTO TEMP_STORICO_PROT (ID,
                                     ID_DOCUMENTO,
                                     IDRIF,
                                     LOG_ID_DOCUMENTO,
                                     LOG_DATA,
                                     LOG_UTENTE,
                                     ID_VALORE_LOG,
                                     OGGETTO,
                                     MODALITA,
                                     CLASS_COD,
                                     FASCICOLO_ANNO,
                                     FASCICOLO_NUMERO,
                                     DATA_ARRIVO,
                                     DATA_DOCUMENTO,
                                     NUMERO_DOCUMENTO,
                                     RISERVATO,
                                     OGGETTO_MOD,
                                     MODALITA_MOD,
                                     CLASS_COD_MOD,
                                     FASCICOLO_ANNO_MOD,
                                     FASCICOLO_NUMERO_MOD,
                                     DATA_ARRIVO_MOD,
                                     DATA_DOCUMENTO_MOD,
                                     NUMERO_DOCUMENTO_MOD,
                                     RISERVATO_MOD)
         (SELECT 0,
                 ID_DOCUMENTO,
                 IDRIF,
                 -1,
                 DATA - 1,
                 'TRASCO',
                 -1,
                 OGGETTO,
                 MODALITA,
                 CLASS_COD,
                 TO_CHAR (FASCICOLO_ANNO),
                 FASCICOLO_NUMERO,
                 DATA_ARRIVO,
                 TO_CHAR (DATA_DOCUMENTO, 'DD/MM/YYYY HH24:MI:SS'),
                 NUMERO_DOCUMENTO,
                 RISERVATO,
                 0 OGGETTO_MOD,
                 0 MODALITA_MOD,
                 0 CLASS_COD_MOD,
                 0 FASCICOLO_ANNO_MOD,
                 0 FASCICOLO_NUMERO_MOD,
                 0 DATA_ARRIVO_MOD,
                 0 DATA_DOCUMENTO_MOD,
                 0 NUMERO_DOCUMENTO_MOD,
                 0 RISERVATO_MOD
            FROM AGP_PROTO_VIEW
           WHERE ID_DOCUMENTO = p_id_documento_gdm
          UNION
          SELECT ROWNUM id, LOG.*
            FROM (  SELECT id_documento,
                           idrif,
                           log_id_documento,
                           log_data,
                           log_utente,
                           MIN (id_valore_log) id_valore_log,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'OGGETTO'
                                 THEN
                                    log_valore
                              END)
                              OGGETTO,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'MODALITA'
                                 THEN
                                    log_valore
                              END)
                              MODALITA,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'CLASS_COD'
                                 THEN
                                    log_valore
                              END)
                              CLASS_COD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'FASCICOLO_ANNO'
                                 THEN
                                    log_valore
                              END)
                              FASCICOLO_ANNO,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'FASCICOLO_NUMERO'
                                 THEN
                                    log_valore
                              END)
                              FASCICOLO_NUMERO,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'DATA_ARRIVO'
                                 THEN
                                    TO_DATE (log_valore,
                                             'dd/mm/yyyy hh24:mi:ss')
                              END)
                              DATA_ARRIVO,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'DATA_DOCUMENTO'
                                 THEN
                                    log_valore
                              END)
                              DATA_DOCUMENTO,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'NUMERO_DOCUMENTO'
                                 THEN
                                    log_valore
                              END)
                              NUMERO_DOCUMENTO,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'RISERVATO'
                                 THEN
                                    log_valore
                              END)
                              RISERVATO,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'OGGETTO' THEN 1
                                 ELSE 0
                              END)
                              OGGETTO_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'MODALITA' THEN 1
                                 ELSE 0
                              END)
                              MODALITA_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'CLASS_COD' THEN 1
                                 ELSE 0
                              END)
                              CLASS_COD_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'FASCICOLO_ANNO' THEN 1
                                 ELSE 0
                              END)
                              FASCICOLO_ANNO_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'FASCICOLO_NUMERO'
                                 THEN
                                    1
                                 ELSE
                                    0
                              END)
                              FASCICOLO_NUMERO_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'DATA_ARRIVO' THEN 1
                                 ELSE 0
                              END)
                              DATA_ARRIVO_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'DATA_DOCUMENTO' THEN 1
                                 ELSE 0
                              END)
                              DATA_DOCUMENTO_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'NUMERO_DOCUMENTO'
                                 THEN
                                    1
                                 ELSE
                                    0
                              END)
                              NUMERO_DOCUMENTO_MOD,
                           MAX (
                              CASE
                                 WHEN log_nome_campo = 'RISERVATO' THEN 1
                                 ELSE 0
                              END)
                              RISERVATO_MOD
                      FROM (SELECT p.id_documento,
                                   p.idrif,
                                   id_valore_log,
                                   activity_log.id_documento
                                      AS log_id_documento,
                                   NVL (
                                      TO_CHAR (LOG.valore_clob),
                                      NVL (
                                         TO_CHAR (LOG.valore_data,
                                                  'dd/mm/yyyy'),
                                         NVL (TO_CHAR (LOG.valore_numero), '')))
                                      AS log_valore,
                                   /* se la data è minore di quella di protocollazione, usa la data di protocollazione */
                                   DECODE (
                                      SIGN (
                                           NVL (p.data, TO_DATE (2222222, 'j'))
                                         - activity_log.data_aggiornamento),
                                      -1, activity_log.data_aggiornamento,
                                      p.data)
                                      AS log_data,
                                   LOG.colonna AS log_nome_campo,
                                   /* se la data è minore di quella di protocollazionee l'utente */
                                   DECODE (
                                      SIGN (
                                           NVL (p.data, TO_DATE (2222222, 'j'))
                                         - activity_log.data_aggiornamento),
                                      -1, activity_log.utente_aggiornamento,
                                      DECODE (
                                         activity_log.utente_aggiornamento,
                                         'RPI', p.utente_protocollante,
                                         activity_log.utente_aggiornamento))
                                      AS log_utente
                              FROM gdm_valori_log LOG,
                                   gdm_activity_log activity_log,
                                   gdm_dati_modello dati_modello,
                                   agp_proto_view p
                             WHERE     activity_log.id_documento =
                                          p_id_documento_gdm
                                   AND p.id_documento =
                                          activity_log.id_documento
                                   AND LOG.id_log = activity_log.id_log
                                   AND dati_modello.area =
                                          'SEGRETERIA.PROTOCOLLO'
                                   AND dati_modello.codice_modello =
                                          'M_PROTOCOLLO'
                                   AND DATI_MODELLO.DATO = LOG.COLONNA
                                   AND LOG.colonna IN ('OGGETTO',
                                                       'MODALITA',
                                                       'CLASS_COD',
                                                       'FASCICOLO_ANNO',
                                                       'FASCICOLO_NUMERO',
                                                       'DATA_ARRIVO',
                                                       'DATA_DOCUMENTO',
                                                       'NUMERO_DOCUMENTO',
                                                       'RISERVATO')
                                   AND activity_log.data_aggiornamento >=
                                          NVL (
                                             (SELECT MAX (
                                                        activity_log.data_aggiornamento)
                                                FROM gdm_valori_log valori_log,
                                                     gdm_activity_log al
                                               WHERE     activity_log.id_documento =
                                                            al.id_documento
                                                     AND al.data_aggiornamento <=
                                                            (SELECT data
                                                               FROM agp_proto_view
                                                              WHERE id_documento =
                                                                       al.id_documento)
                                                     AND valori_log.id_log =
                                                            al.id_log
                                                     AND LOG.COLONNA =
                                                            VALORI_LOG.COLONNA),
                                             activity_log.data_aggiornamento))
                  GROUP BY id_documento,
                           idrif,
                           log_id_documento,
                           log_data,
                           log_utente
                  ORDER BY log_data, id_valore_log) LOG);

      FOR storico
         IN (  SELECT TEMP_STORICO_PROT.id,
                      LOG_DATA,
                      LOG_UTENTE,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'RISERVATO',
                                      temp_storico_prot.id)
                         riservato,
                      DECODE (
                         get_valore_log ('TEMP_STORICO_PROT',
                                         'MODALITA',
                                         temp_storico_prot.id),
                         'ARR', 'ARRIVO',
                         'INT', 'INTERNO',
                         'PAR', 'PARTENZA')
                         modalita,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'OGGETTO',
                                      temp_storico_prot.id)
                         oggetto,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'CLASS_COD',
                                      temp_storico_prot.id)
                         class_cod,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'FASCICOLO_ANNO',
                                      temp_storico_prot.id)
                         fascicolo_anno,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'FASCICOLO_NUMERO',
                                      TEMP_STORICO_PROT.id)
                         fascicolo_numero,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'DATA_ARRIVO',
                                      temp_storico_prot.id)
                         data_arrivo,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'DATA_DOCUMENTO',
                                      temp_storico_prot.id)
                         data_documento,
                      get_valore_log ('TEMP_STORICO_PROT',
                                      'NUMERO_DOCUMENTO',
                                      temp_storico_prot.id)
                         numero_documento,
                      temp_storico_prot.oggetto_mod,
                      temp_storico_prot.modalita_mod,
                      temp_storico_prot.class_cod_mod,
                      temp_storico_prot.fascicolo_anno_mod,
                      temp_storico_prot.fascicolo_numero_mod,
                      temp_storico_prot.data_arrivo_mod,
                      temp_storico_prot.data_documento_mod,
                      temp_storico_prot.numero_documento_mod,
                      temp_storico_prot.riservato_mod
                 FROM TEMP_STORICO_PROT
             ORDER BY id)
      LOOP
         BEGIN
            SELECT rev
              INTO d_id_rev
              FROM TEMP_STORICO
             WHERE     ID_DOCUMENTO = d_id_doc_agspr
                   AND LOG_DATA = storico.LOG_DATA
                   AND LOG_UTENTE = storico.LOG_UTENTE
                   AND tabella = 'AGP_PROTOCOLLI_LOG';

            d_esiste_rev := 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               DECLARE
                  d_seq   NUMBER;
               BEGIN
                  SELECT -temp_storico_sequence.NEXTVAL
                    INTO d_seq
                    FROM DUAL;

                  d_esiste_rev := 0;
                  d_id_rev :=
                     AGP_TRASCO_PKG.CREA_REVINFO (storico.log_data, d_seq);
               END;

               INSERT INTO TEMP_STORICO (ID_DOCUMENTO,
                                         REV,
                                         ID_DOCUMENTO_PROT_GDM,
                                         LOG_DATA,
                                         LOG_UTENTE,
                                         TABELLA)
                    VALUES (d_id_doc_agspr,
                            d_id_rev,
                            p_id_documento_gdm,
                            storico.LOG_DATA,
                            storico.LOG_UTENTE,
                            'AGP_PROTOCOLLI_LOG');
         END;


         IF storico.class_cod IS NOT NULL
         THEN
            BEGIN
               SELECT id_classificazione
                 INTO d_id_class
                 FROM ags_classificazioni
                WHERE     classificazione = storico.class_cod
                      AND storico.log_data BETWEEN classificazione_dal
                                               AND NVL (classificazione_al,
                                                        storico.log_data);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     SELECT id_classificazione
                       INTO d_id_class
                       FROM ags_classificazioni
                      WHERE     classificazione = storico.class_cod
                            AND classificazione_dal =
                                   (SELECT MAX (classificazione_dal)
                                      FROM ags_classificazioni
                                     WHERE classificazione =
                                              storico.class_cod);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        d_id_class := NULL;
                        d_id_fascicolo := NULL;
                  END;
               WHEN OTHERS
               THEN
                  d_id_class := NULL;
                  d_id_fascicolo := NULL;
            END;

            IF     d_id_class IS NOT NULL
               AND storico.fascicolo_anno IS NOT NULL
               AND storico.fascicolo_numero IS NOT NULL
            THEN
               BEGIN
                  SELECT id_documento
                    INTO d_id_fascicolo
                    FROM ags_fascicoli
                   WHERE     id_classificazione = d_id_class
                         AND anno = storico.fascicolo_anno
                         AND numero = storico.fascicolo_numero;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     d_id_fascicolo := NULL;
               END;
            ELSE
               d_id_fascicolo := NULL;
            END IF;
         ELSE
            d_id_class := NULL;
            d_id_fascicolo := NULL;
         END IF;

         IF d_esiste_rev = 1
         THEN
            UPDATE GDO_DOCUMENTI_LOG
               SET RISERVATO = storico.RISERVATO,
                   RISERVATO_MOD = storico.RISERVATO_MOD,
                   id_documento_esterno = p_id_documento_gdm
             WHERE ID_DOCUMENTO = d_id_doc_agspr AND REV = d_id_rev;

            DBMS_OUTPUT.put_line (
                  '            UPDATE AGP_PROTOCOLLI_LOG
               SET DATA_COMUNICAZIONE = '
               || storico.DATA_ARRIVO
               || ',
                   DATA_COMUNICAZIONE_MOD = '
               || storico.DATA_ARRIVO_MOD
               || ',
                   DATA_DOCUMENTO_ESTERNO = '
               || storico.DATA_DOCUMENTO
               || ',
                   DATA_DOCUMENTO_ESTERNO_MOD = '
               || storico.DATA_DOCUMENTO_MOD
               || ',
                   MOVIMENTO = '
               || storico.modalita
               || ',
                   MOVIMENTO_MOD = '
               || storico.modalita_mod
               || ',
                   numero_mod = DECODE ('
               || storico.id
               || ', 1, 1, 0),
                   NUMERO_DOCUMENTO_ESTERNO = '
               || storico.NUMERO_DOCUMENTO
               || ',
                   NUMERO_DOCUMENTO_ESTERNO_MOD = '
               || storico.NUMERO_DOCUMENTO_MOD
               || ',
                   OGGETTO = '
               || storico.OGGETTO
               || ',
                   OGGETTO_MOD = '
               || storico.OGGETTO_MOD
               || ',
                   ID_CLASSIFICAZIONE = '
               || d_id_class
               || ',
                   CLASSIFICAZIONE_MOD = '
               || storico.class_cod_mod
               || ',
                   ID_FASCICOLO = '
               || d_id_fascicolo
               || ',
                   FASCICOLO_MOD =
                      DECODE (
                           '
               || storico.fascicolo_anno_mod
               || '
                         + '
               || storico.fascicolo_numero_mod
               || ',
                         0, 0,
                         1)
             WHERE ID_DOCUMENTO = '
               || d_id_doc_agspr
               || ' AND REV = '
               || d_id_rev
               || ';');

            UPDATE AGP_PROTOCOLLI_LOG
               SET DATA_COMUNICAZIONE = storico.DATA_ARRIVO,
                   DATA_COMUNICAZIONE_MOD = storico.DATA_ARRIVO_MOD,
                   DATA_DOCUMENTO_ESTERNO =
                      TO_DATE (storico.DATA_DOCUMENTO,
                               'dd/mm/yyyy hh24:mi:ss'),
                   DATA_DOCUMENTO_ESTERNO_MOD = storico.DATA_DOCUMENTO_MOD,
                   MOVIMENTO = storico.modalita,
                   MOVIMENTO_MOD = storico.modalita_mod,
                   numero_mod = DECODE (storico.id, 1, 1, 0),
                   NUMERO_DOCUMENTO_ESTERNO = storico.NUMERO_DOCUMENTO,
                   NUMERO_DOCUMENTO_ESTERNO_MOD = storico.NUMERO_DOCUMENTO_MOD,
                   OGGETTO = storico.OGGETTO,
                   OGGETTO_MOD = storico.OGGETTO_MOD,
                   ID_CLASSIFICAZIONE = d_id_class,
                   CLASSIFICAZIONE_MOD = storico.class_cod_mod,
                   ID_FASCICOLO = d_id_fascicolo,
                   FASCICOLO_MOD =
                      DECODE (
                           storico.fascicolo_anno_mod
                         + storico.fascicolo_numero_mod,
                         0, 0,
                         1)
             WHERE ID_DOCUMENTO = d_id_doc_agspr AND REV = d_id_rev;
         ELSE
            INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                           REV,
                                           REVTYPE,
                                           DATA_INS,
                                           DATE_CREATED_MOD,
                                           DATA_UPD,
                                           VALIDO,
                                           ID_DOCUMENTO_ESTERNO,
                                           RISERVATO,
                                           RISERVATO_MOD,
                                           STATO,
                                           STATO_CONSERVAZIONE,
                                           STATO_FIRMA,
                                           UTENTE_INS,
                                           UTENTE_UPD,
                                           ID_ENTE,
                                           ID_ENGINE_ITER,
                                           TIPO_OGGETTO)
               SELECT d_id_doc_agspr,
                      d_id_rev,
                      DECODE (storico.log_utente,
                              'TRASCO', 2,
                              DECODE (storico.id, 1, 0, 1)), -- 2 per evitare si vedano tra i dati di protocollazione
                      storico.log_data,
                      1,
                      storico.log_data,
                      valido,
                      p_id_documento_gdm,
                      storico.RISERVATO,
                      storico.RISERVATO_MOD,
                      STATO,
                      STATO_CONSERVAZIONE,
                      STATO_FIRMA,
                      storico.log_utente,
                      storico.log_utente,
                      ID_ENTE,
                      ID_ENGINE_ITER,
                      TIPO_OGGETTO
                 FROM gdo_documenti
                WHERE id_documento = d_id_doc_agspr;

            INSERT INTO AGP_PROTOCOLLI_LOG (ID_DOCUMENTO,
                                            REV,
                                            ANNO,
                                            ANNO_EMERGENZA,
                                            ANNULLATO,
                                            CODICE_RACCOMANDATA,
                                            DATA,
                                            DATA_ANNULLAMENTO,
                                            DATA_COMUNICAZIONE,
                                            DATA_COMUNICAZIONE_MOD,
                                            DATA_DOCUMENTO_ESTERNO,
                                            DATA_DOCUMENTO_ESTERNO_MOD,
                                            DATA_REDAZIONE,
                                            DATA_STATO_ARCHIVIO,
                                            DATA_VERIFICA,
                                            ESITO_VERIFICA,
                                            IDRIF,
                                            MOVIMENTO,
                                            MOVIMENTO_MOD,
                                            NOTE,
                                            NUMERO,
                                            numero_mod,
                                            NUMERO_DOCUMENTO_ESTERNO,
                                            NUMERO_DOCUMENTO_ESTERNO_MOD,
                                            NUMERO_EMERGENZA,
                                            OGGETTO,
                                            OGGETTO_MOD,
                                            PROVVEDIMENTO_ANNULLAMENTO,
                                            REGISTRO_EMERGENZA,
                                            STATO_ARCHIVIO,
                                            ID_CLASSIFICAZIONE,
                                            CLASSIFICAZIONE_MOD,
                                            ID_PROTOCOLLO_DATI_EMERGENZA,
                                            ID_PROTOCOLLO_DATI_INTEROP,
                                            ID_PROTOCOLLO_DATI_SCARTO,
                                            ID_FASCICOLO,
                                            FASCICOLO_MOD,
                                            ID_MODALITA_INVIO_RICEZIONE,
                                            ID_SCHEMA_PROTOCOLLO,
                                            ID_TIPO_PROTOCOLLO,
                                            TIPO_REGISTRO,
                                            UTENTE_ANNULLAMENTO,
                                            ID_PROTOCOLLO_DATI_REG_GIORN)
               SELECT d_id_doc_agspr,
                      d_id_rev,
                      p.ANNO,
                      p.ANNO_EMERGENZA,
                      p.ANNULLATO,
                      p.CODICE_RACCOMANDATA,
                      p.DATA,
                      p.DATA_ANNULLAMENTO,
                      storico.DATA_ARRIVO,
                      storico.DATA_ARRIVO_MOD,
                      TO_DATE (storico.DATA_DOCUMENTO,
                               'dd/mm/yyyy hh24:mi:ss'),
                      storico.DATA_DOCUMENTO_MOD,
                      p.DATA_REDAZIONE,
                      p.DATA_STATO_ARCHIVIO,
                      p.DATA_VERIFICA,
                      p.ESITO_VERIFICA,
                      p.IDRIF,
                      storico.modalita,
                      storico.modalita_mod,
                      p.NOTE,
                      p.NUMERO,
                      DECODE (storico.id, 1, 1, 0),
                      storico.NUMERO_DOCUMENTO,
                      storico.NUMERO_DOCUMENTO_MOD,
                      p.NUMERO_EMERGENZA,
                      storico.OGGETTO,
                      storico.OGGETTO_MOD,
                      p.PROVVEDIMENTO_ANNULLAMENTO,
                      p.REGISTRO_EMERGENZA,
                      p.STATO_ARCHIVIO,
                      d_id_class,
                      storico.class_cod_mod,
                      p.ID_PROTOCOLLO_DATI_EMERGENZA,
                      p.ID_PROTOCOLLO_DATI_INTEROP,
                      p.ID_PROTOCOLLO_DATI_SCARTO,
                      d_id_fascicolo,
                      DECODE (
                           storico.fascicolo_anno_mod
                         + storico.fascicolo_numero_mod,
                         0, 0,
                         1),
                      p.ID_MODALITA_INVIO_RICEZIONE,
                      p.ID_SCHEMA_PROTOCOLLO,
                      p.ID_TIPO_PROTOCOLLO,
                      p.TIPO_REGISTRO,
                      p.UTENTE_ANNULLAMENTO,
                      p.id_protocollo_dati_reg_giorn
                 FROM agp_protocolli p
                WHERE id_documento = d_id_doc_agspr;
         END IF;
      END LOOP;
   /*
         FOR r
            IN (  SELECT *
                    FROM GDO_DOCUMENTI_LOG
                   WHERE id_documento =
                            (SELECT id_documento
                               FROM gdo_documenti
                              WHERE id_documento_esterno = p_id_documento_gdm)
                ORDER BY data_ins)
         LOOP
            UPDATE GDO_DOCUMENTI_LOG
               SET revend =
                      (SELECT MIN (rev) revend
                         FROM GDO_DOCUMENTI_LOG p2
                        WHERE     p2.id_documento = r.id_documento
                              AND p2.rev <> r.rev
                              AND data_ins =
                                     (SELECT MIN (data_ins)
                                        FROM GDO_DOCUMENTI_LOG p3
                                       WHERE     p3.id_documento =
                                                    p2.id_documento
                                             AND p3.data_ins > r.data_ins)),
                   id_documento_esterno = p_id_documento_gdm
             WHERE     id_documento = r.id_documento
                   AND rev = r.rev
                   AND NVL (revend, 0) <= 0;

            NULL;
         END LOOP;
         */
   /* Gestire dati annullamento: (?)
     ACCETTAZIONE_ANNULLAMENTO
     ANNULLATO
     DATA_ACCETTAZIONE_ANN
     DATA_ANN
     DATA_RICHIESTA_ANN
     MOTIVO_ANN
     PROVVEDIMENTO_ANN
     UNITA_RICHIESTA_ANN
     UTENTE_ANN
     UTENTE_RICHIESTA_ANN
   */

   /* Gestire dati precedente: (?)
      ANNO_PROT_PREC_SUCC
      NUMERO_PROT_PREC_SUCC
   */

   /* Gestire: (?)
      DATA_ARRIVO
      UFFICIO_ESIBENTE
   */
   END;

   PROCEDURE aggiorna_rev_protocollo_log (p_id_documento    NUMBER,
                                          p_rev             NUMBER,
                                          p_rev_new         NUMBER)
   IS
      d_id_rev   NUMBER;
      d_sql      VARCHAR2 (32000);
   BEGIN
      INSERT INTO GDO_DOCUMENTI_LOG
         SELECT ID_DOCUMENTO,
                p_rev_new,
                REVTYPE,
                REVEND,
                DATA_INS,
                DATE_CREATED_MOD,
                DATA_UPD,
                LAST_UPDATED_MOD,
                VALIDO,
                VALIDO_MOD,
                ID_DOCUMENTO_ESTERNO,
                ID_DOCUMENTO_ESTERNO_MOD,
                RISERVATO,
                RISERVATO_MOD,
                STATO,
                STATO_MOD,
                STATO_CONSERVAZIONE,
                STATO_CONSERVAZIONE_MOD,
                STATO_FIRMA,
                STATO_FIRMA_MOD,
                UTENTE_INS,
                UTENTE_INS_MOD,
                UTENTE_UPD,
                UTENTE_UPD_MOD,
                ID_ENTE,
                ENTE_MOD,
                DOCUMENTI_COLLEGATI_MOD,
                FILE_DOCUMENTI_MOD,
                ID_ENGINE_ITER,
                ITER_MOD,
                TIPO_OGGETTO,
                TIPO_OGGETTO_MOD,
                DATA_LOG
           FROM GDO_DOCUMENTI_LOG
          WHERE rev = p_rev;

      UPDATE agp_protocolli_log
         SET rev = p_rev_new
       WHERE rev = p_rev;

      UPDATE GDO_DOCUMENTI_LOG
         SET revend = p_rev_new
       WHERE revend = p_rev AND NVL (revend, 0) <= 0;
   END;

   PROCEDURE aggiorna_rev_allegati_log (p_id_documento    NUMBER,
                                        p_rev             NUMBER,
                                        p_rev_new         NUMBER)
   IS
      d_id_rev   NUMBER;
      d_sql      VARCHAR2 (32000);
   BEGIN
      INSERT INTO GDO_DOCUMENTI_LOG
         SELECT ID_DOCUMENTO,
                p_rev_new,
                REVTYPE,
                REVEND,
                DATA_INS,
                DATE_CREATED_MOD,
                DATA_UPD,
                LAST_UPDATED_MOD,
                VALIDO,
                VALIDO_MOD,
                ID_DOCUMENTO_ESTERNO,
                ID_DOCUMENTO_ESTERNO_MOD,
                RISERVATO,
                RISERVATO_MOD,
                STATO,
                STATO_MOD,
                STATO_CONSERVAZIONE,
                STATO_CONSERVAZIONE_MOD,
                STATO_FIRMA,
                STATO_FIRMA_MOD,
                UTENTE_INS,
                UTENTE_INS_MOD,
                UTENTE_UPD,
                UTENTE_UPD_MOD,
                ID_ENTE,
                ENTE_MOD,
                DOCUMENTI_COLLEGATI_MOD,
                FILE_DOCUMENTI_MOD,
                ID_ENGINE_ITER,
                ITER_MOD,
                TIPO_OGGETTO,
                TIPO_OGGETTO_MOD,
                DATA_LOG
           FROM GDO_DOCUMENTI_LOG
          WHERE     rev = p_rev
                AND NOT EXISTS
                       (SELECT 1
                          FROM GDO_DOCUMENTI_LOG
                         WHERE rev = p_rev_new);

      UPDATE GDO_ALLEGATI_LOG
         SET rev = p_rev_new
       WHERE rev = p_rev;

      UPDATE GDO_DOCUMENTI_COLLEGATI_LOG
         SET rev = p_rev_new
       WHERE rev = p_rev;

      UPDATE GDO_DOCUMENTI_LOG
         SET revend = p_rev_new
       WHERE revend = p_rev AND NVL (revend, 0) <= 0;

      UPDATE GDO_DOCUMENTI_COLLEGATI_LOG
         SET revend = p_rev_new
       WHERE revend = p_rev AND NVL (revend, 0) <= 0;
   END;

   PROCEDURE crea (p_id_documento_gdm NUMBER)
   IS
      d_id_rev        NUMBER;
      d_sql           VARCHAR2 (32000);
      d_id_rev_prec   NUMBER := 0;
   BEGIN
      crea_storico_corrispondenti (p_id_documento_gdm);

      crea_storico_dati_scarto (p_id_documento_gdm);

      crea_storico_allegati (p_id_documento_gdm);

      crea_storico_file_princ (p_id_documento_gdm);

      crea_storico_protocollo (p_id_documento_gdm);

      FOR s
         IN (  SELECT *
                 FROM temp_storico
             ORDER BY log_data,
                      REV DESC,
                      DECODE (tabella, 'AGP_PROTOCOLLI_LOG', 1, 0))
      LOOP
         DBMS_OUTPUT.put_line (
            'rev ' || s.rev || ' rev_prec ' || d_id_rev_prec);

         IF s.rev <> d_id_rev_prec AND s.rev < 0
         THEN
            d_id_rev := AGP_TRASCO_PKG.crea_revinfo (s.log_data);
            DBMS_OUTPUT.put_line (
               'aggiorno ' || s.tabella || ' rev ' || d_id_rev);
            aggiorna_rev_protocollo_log (s.id_documento, s.rev, d_id_rev);
         END IF;

         IF     s.tabella NOT IN ('GDO_DOCUMENTI_LOG',
                                  'AGP_PROTOCOLLI_LOG',
                                  'GDO_ALLEGATI_LOG')
            AND s.rev < 0
         THEN
            d_sql :=
                  'update '
               || s.tabella
               || ' set rev = '
               || d_id_rev
               || ' where rev = '
               || s.rev;
            DBMS_OUTPUT.put_line (d_sql);

            EXECUTE IMMEDIATE d_sql;


            d_sql :=
                  'update '
               || s.tabella
               || ' set revend = '
               || d_id_rev
               || ' where revend = '
               || s.rev
               || ' and nvl(revend, 0) <= 0 ';
            DBMS_OUTPUT.put_line (d_sql);

            EXECUTE IMMEDIATE d_sql;
         ELSIF s.tabella IN ('GDO_ALLEGATI_LOG')
         THEN
            aggiorna_rev_allegati_log (s.id_documento, s.rev, d_id_rev);
         END IF;

         d_id_rev_prec := s.rev;
      END LOOP;

      FOR s IN (SELECT DISTINCT rev
                  FROM temp_storico
                 WHERE rev < 0)
      LOOP
         DELETE GDO_DOCUMENTI_LOG
          WHERE rev = s.rev;

         DBMS_OUTPUT.put_line ('delete REVINFO where rev = ' || s.rev);
         AGP_TRASCO_PKG.del_revinfo (s.rev);
      END LOOP;


      DECLARE
         d_revend   NUMBER;
      BEGIN
         FOR r
            IN (  SELECT *
                    FROM GDO_DOCUMENTI_LOG
                   WHERE     id_documento_esterno = p_id_documento_gdm
                         AND revend IS NULL
                ORDER BY data_ins, rev)
         LOOP
            d_revend := NULL;

            BEGIN
               SELECT MIN (rev) revend
                 INTO d_revend
                 FROM GDO_DOCUMENTI_LOG p2
                WHERE     p2.id_documento = r.id_documento
                      AND p2.rev <> r.rev
                      AND data_ins =
                             (SELECT MIN (data_ins)
                                FROM GDO_DOCUMENTI_LOG p3
                               WHERE     p3.id_documento = p2.id_documento
                                     AND p3.data_ins > r.data_ins)
               HAVING NVL (MIN (rev), 0) > 0
               UNION
               SELECT MIN (rev) revend
                 FROM GDO_DOCUMENTI_LOG p2
                WHERE     p2.id_documento = r.id_documento
                      AND p2.rev > r.rev
                      AND data_ins =
                             (SELECT MIN (data_ins)
                                FROM GDO_DOCUMENTI_LOG p3
                               WHERE     p3.id_documento = p2.id_documento
                                     AND p3.data_ins = r.data_ins)
                      AND NOT EXISTS
                             (SELECT MIN (rev) revend
                                FROM GDO_DOCUMENTI_LOG p2
                               WHERE     p2.id_documento = r.id_documento
                                     AND p2.rev <> r.rev
                                     AND data_ins =
                                            (SELECT MIN (data_ins)
                                               FROM GDO_DOCUMENTI_LOG p3
                                              WHERE     p3.id_documento =
                                                           p2.id_documento
                                                    AND p3.data_ins >
                                                           r.data_ins)
                              HAVING NVL (MIN (rev), 0) > 0)
               HAVING NVL (MIN (rev), 0) > 0;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  d_revend := NULL;
            END;

            UPDATE GDO_DOCUMENTI_LOG
               SET revend = d_revend,
                   id_documento_esterno = p_id_documento_gdm
             WHERE     id_documento = r.id_documento
                   AND rev = r.rev
                   AND NVL (revend, 0) <= 0;
         END LOOP;
      END;
   END;


   PROCEDURE elimina_storico_documento (p_id_documento_gdm NUMBER)
   IS
      d_id_documento   NUMBER;
   BEGIN
      SELECT d.id_documento
        INTO d_id_documento
        FROM gdo_documenti d
       WHERE d.id_documento_esterno = p_id_documento_gdm;

      agp_trasco_pkg.elimina_storico_documento (d_id_documento);
   END;
END;
/
