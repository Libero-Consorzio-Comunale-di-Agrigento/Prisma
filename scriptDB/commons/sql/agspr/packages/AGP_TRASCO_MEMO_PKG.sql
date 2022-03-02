--liquibase formatted sql
--changeset mmalferrari:AGSPR_PACKAGE_AGP_TRASCO_MEMO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_TRASCO_MEMO_PKG
IS
   /******************************************************************************
    NOME:        AGP_TRASCO_MEMO_PKG
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

   FUNCTION crea_memo_agspr (p_id_documento_gdm NUMBER)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_TRASCO_MEMO_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_TRASCO_MEMO_PKG
    DESCRIZIONEp_ Gestione TRASCO da GDM.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   23/12/2019    mmalferrari   Prima emissione.
    001   10/09/2020    mmalferrari   Modificate chiamate a
                                      agp_trasco_pkg.crea_documento_soggetto per
                                      passare idrev.
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '001';

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

   FUNCTION crea_messaggio_si4cs (p_id_documento_gdm          NUMBER,
                                  p_message_id                VARCHAR2,
                                  p_oggetto                   VARCHAR2,
                                  p_testo                     CLOB,
                                  p_mime_testo                VARCHAR2,
                                  p_data_ricezione            DATE,
                                  p_data_spedizione           VARCHAR2,
                                  p_mittente                  VARCHAR2,
                                  p_destinatari               VARCHAR2,
                                  p_destinatari_conoscenza    VARCHAR2,
                                  p_destinatari_nascosti      VARCHAR2,
                                  p_tipo                      VARCHAR2,
                                  p_note                      VARCHAR2,
                                  p_in_partenza               VARCHAR2,
                                  p_cs_tag                    VARCHAR2,
                                  p_padre                     NUMBER,
                                  p_id_documento_eml          NUMBER,
                                  p_id_oggetto_file_eml       NUMBER)
      RETURN NUMBER
   IS
      d_id_doc_eml         NUMBER;
      d_id_doc_messaggio   NUMBER;
   BEGIN
      -- gestione MESSAGGIO
      IF p_in_partenza = 'N'
      THEN
         ---------------------
         -- messaggi ricevuti
         ---------------------
         DECLARE
            d_esiste   NUMBER;
         BEGIN
            SELECT 1, messaggio
              INTO d_esiste, d_id_doc_messaggio
              FROM si4cs_messaggi_ricevuti
             WHERE     message_id = p_message_id
                   AND mittente = p_mittente
                   AND oggetto = p_oggetto
                   AND data_spedizione = p_data_spedizione
                   AND NVL (padre, -1) = NVL (p_padre, -1);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               DECLARE
                  d_data_sd          DATE;
                  d_certified_type   NUMBER;
               BEGIN
                  IF p_data_spedizione IS NULL
                  THEN
                     d_data_sd := p_data_ricezione;
                  ELSE
                     /*
                        Formati applicati alla data di spedizione gestiti
                        Wed Sep 04 16:41:17 CEST 2019
                        Sat Mar 30 21:11:07 CET 2019
                        lun, 19 dic 2011 10:34:18
                        30/09/2019
                        30/09/2019 12:11:25
                     */
                     IF    INSTR (p_data_spedizione, 'CEST') > 0
                        OR INSTR (p_data_spedizione, 'CET') > 0
                     THEN
                        BEGIN
                           d_data_sd :=
                              CAST (
                                 TO_TIMESTAMP_TZ (
                                    p_data_spedizione,
                                    'Dy Mon dd hh24:mi:ss tzd yyyy',
                                    'nls_date_language = AMERICAN') AS DATE);
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              BEGIN
                                 d_data_sd :=
                                    CAST (
                                       TO_TIMESTAMP_TZ (
                                          p_data_spedizione,
                                          'Dy Mon dd hh24:mi:ss tzd yyyy',
                                          'nls_date_language = ITALIAN') AS DATE);
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    d_data_sd := p_data_ricezione;
                              END;
                        END;
                     END IF;
                  END IF;

                  IF INSTR (p_data_spedizione, '/') > 0
                  THEN
                     BEGIN
                        d_data_sd :=
                           TO_DATE (p_data_spedizione,
                                    'dd/mm/yyyy hh24:mi:ss');
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           d_data_sd := p_data_ricezione;
                     END;
                  END IF;

                  IF INSTR (p_data_spedizione, ',') > 0
                  THEN
                     BEGIN
                        d_data_sd :=
                           TO_DATE (p_data_spedizione,
                                    'dy, dd mon yyyy hh24:mi:ss',
                                    'nls_date_language = AMERICAN');
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           BEGIN
                              d_data_sd :=
                                 TO_DATE (p_data_spedizione,
                                          'dy, dd mon yyyy hh24:mi:ss',
                                          'nls_date_language = ITALIAN');
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 d_data_sd := p_data_ricezione;
                           END;
                     END;
                  END IF;

                  IF    UPPER (NVL (p_oggetto, '*')) LIKE 'ACCETTAZIONE:%'
                     OR UPPER (NVL (p_oggetto, '*')) LIKE
                           'AVVISO MANCATA CONSEGNA:%'
                     OR UPPER (NVL (p_oggetto, '*')) LIKE
                           'AVVISO DI MANCATA CONSEGNA:%'
                     OR UPPER (NVL (p_oggetto, '*')) LIKE
                           'ERRORE_DI_CONSEGNA:%'
                     OR UPPER (NVL (p_oggetto, '*')) LIKE 'CONSEGNA:%'
                     OR UPPER (NVL (p_oggetto, '*')) LIKE
                           'AVVENUTA_CONSEGNA:%'
                     OR UPPER (NVL (p_oggetto, '*')) LIKE 'PRESA IN CARICO:%'
                     OR UPPER (NVL (p_oggetto, '*')) LIKE 'ERRORE:%'
                  THEN
                     d_certified_type := 3;
                  ELSIF p_tipo = 'PEC'
                  THEN
                     d_certified_type := 2;
                  ELSIF p_tipo = 'NONPEC'
                  THEN
                     d_certified_type := 1;
                  END IF;

                  d_id_doc_messaggio := si4cs_seq_messaggi.NEXTVAL;

                  INSERT
                    INTO SI4CS_MESSAGGI_RICEVUTI (MESSAGGIO,
                                                  MESSAGE_ID,
                                                  MITTENTE,
                                                  OGGETTO,
                                                  DATA_SPEDIZIONE,
                                                  DESTINATARI,
                                                  DESTINATARI_CONOSCENZA,
                                                  DESTINATARI_NASCOSTI,
                                                  PROCESSATO,
                                                  INFO,
                                                  ERRORE,
                                                  PROC_EXECUTOR,
                                                  DATA_RICEZIONE,
                                                  PADRE,
                                                  CS_TAG,
                                                  DATA_SD,
                                                  CERTIFIED_TYPE)
                  VALUES (d_id_doc_messaggio,
                          p_MESSAGE_ID,
                          p_MITTENTE,
                          p_OGGETTO,
                          p_DATA_SPEDIZIONE,
                          p_DESTINATARI,
                          p_DESTINATARI_CONOSCENZA,
                          p_DESTINATARI_NASCOSTI,
                          'Y',
                          NULL,
                          NULL,
                          NULL,
                          TO_CHAR (P_DATA_RICEZIONE, 'dd/mm/yyyy'),
                          P_PADRE,
                          P_CS_TAG,
                          d_data_sd,
                          d_certified_type);

                  -- SEQ_TESTI_MESSAGGI
                  INSERT INTO SI4CS_TESTI_MESSAGGI (TESTO_MESSAGGIO,
                                                    MESSAGGIO,
                                                    TESTO,
                                                    MIMETYPE)
                     SELECT si4cs_seq_testi_messaggi.NEXTVAL,
                            d_id_doc_messaggio,
                            p_testo,
                            p_mime_testo
                       FROM DUAL;

                  DECLARE
                     d_id_allegato   NUMBER;
                  BEGIN
                     FOR alle IN (SELECT filename, id_oggetto_file
                                    FROM gdm_oggetti_file
                                   WHERE id_documento = p_id_documento_gdm)
                     LOOP
                        -- SEQ_ALLEGATI
                        d_id_allegato := si4cs_seq_allegati.NEXTVAL;

                        INSERT INTO SI4CS_ALLEGATI (
                                       ALLEGATO,
                                       MESSAGGIO,
                                       CONTENT_TYPE_NAME,
                                       CONTENT_DISPOSITION_FNAME,
                                       INFO,
                                       ERRORE,
                                       CONTENT_TYPE)
                           SELECT d_id_allegato,
                                  d_id_doc_messaggio,
                                  alle.filename,
                                  alle.filename,
                                  NULL,
                                  NULL,
                                     'application/octet-stream; name='
                                  || alle.filename
                             FROM DUAL;

                        -- SEQ_BINARY_ALLEGATI
                        INSERT INTO SI4CS_BINARY_ALLEGATI (BINARY_ALLEGATO,
                                                           ALLEGATO,
                                                           ID_DOCUMENTO,
                                                           ID_OGGETTO_FILE)
                           SELECT si4cs_seq_binary_allegati.NEXTVAL,
                                  d_id_allegato,
                                  d_id_doc_messaggio,
                                  alle.id_oggetto_file
                             FROM DUAL;
                     END LOOP;
                  END;


                  IF p_id_documento_eml IS NOT NULL
                  THEN
                     DECLARE
                        d_esiste   NUMBER;
                     BEGIN
                        SELECT 1
                          INTO d_esiste
                          FROM SI4CS_MESSAGGI_BLOB
                         WHERE ID_OGGETTO_FILE = p_id_oggetto_file_eml;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           INSERT INTO SI4CS_MESSAGGI_BLOB (MESSAGGIO_BLOB,
                                                            MESSAGGIO,
                                                            BINARY,
                                                            ID_DOCUMENTO,
                                                            ID_OGGETTO_FILE)
                              SELECT si4cs_seq_messaggi_blob.NEXTVAL,
                                     d_id_doc_messaggio,
                                     NULL,
                                     p_id_documento_eml,
                                     p_id_oggetto_file_eml
                                FROM DUAL;
                     END;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     d_id_doc_messaggio := NULL;
               END;
         END;
      ELSE
         ---------------------
         -- messaggi inviati
         ---------------------
         DECLARE
            d_esiste                  NUMBER;
            d_id_contatto             NUMBER;
            d_id_messaggio_contatto   NUMBER;
            d_stato_msg               VARCHAR2 (20) := NULL;
            d_data_msg                DATE;
            d_id_allegato             NUMBER;
         BEGIN
            SELECT 1, messaggio
              INTO d_esiste, d_id_doc_messaggio
              FROM si4cs_messaggi, gdm_ag_cs_messaggi cs
             WHERE     messaggio = cs.id_cs_messaggio
                   AND cs.id_documento_memo = p_id_documento_gdm;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --CREAZIONE DEL CONTATTO E DEL MITTENTE
               d_id_contatto := si4cs_cont_sq.NEXTVAL;

               INSERT INTO SI4CS_CONTATTI (CONTATTO, NOME, EMAIL)
                    VALUES (d_id_contatto, p_mittente, p_mittente);

               --CREAZIONE DEL DEL MITTENTE
               d_id_messaggio_contatto := si4cs_mime_sq.NEXTVAL;

               INSERT
                 INTO SI4CS_MITTENTI_MESSAGGIO (MITTENTE_MESSAGGIO, CONTATTO)
               VALUES (d_id_messaggio_contatto, d_id_contatto);

               d_id_doc_messaggio := si4cs_seq_messaggi.NEXTVAL;

               SELECT MAX (stato_spedizione), MAX (data_modifica)
                 INTO d_stato_msg, d_data_msg
                 FROM gdm_ag_cs_messaggi
                WHERE id_documento_memo = p_id_documento_gdm;

               INSERT INTO SI4CS_MESSAGGI (MESSAGGIO,
                                           TIPO_MESSAGGIO,
                                           MITTENTE_MESSAGGIO,
                                           OGGETTO,
                                           TESTO,
                                           STATO,
                                           NOME_PROGETTO,
                                           MODULO_PROGETTO,
                                           FASE_PROGETTO,
                                           CS_TAG,
                                           DATA_MESSAGGIO)
                    VALUES (d_id_doc_messaggio,
                            'csagentmail',
                            d_id_messaggio_contatto,
                            p_OGGETTO,
                            p_testo,
                            d_stato_msg,
                            'AGSPR',
                            'AGSPR',
                            'PEC',
                            p_cs_tag,
                            d_data_msg);

               BEGIN
                  FOR alle IN (SELECT filename, id_oggetto_file
                                 FROM gdm_oggetti_file
                                WHERE id_documento = p_id_documento_gdm)
                  LOOP
                     d_id_allegato := SI4CS_SEQ_ALLEGATI_MESSAGGIO.NEXTVAL;

                     GDM_OGGETTI_FILE_PACK_GDM.DOWNLOADOGGETTOFILE_TMP (
                        alle.id_oggetto_file);

                     INSERT INTO SI4CS_ALLEGATI_MESSAGGIO (
                                    ALLEGATO_MESSAGGIO,
                                    MESSAGGIO,
                                    NOME,
                                    ALLEGATO)
                        SELECT d_id_allegato,
                               d_id_doc_messaggio,
                               alle.filename,
                               file_temporany
                          FROM GDM_TMP_FILE;
                  END LOOP;
               END;
         END;
      END IF;

      RETURN d_id_doc_messaggio;
   END;

   PROCEDURE crea_memo_ricevuto_inviato (
      p_id_documento              NUMBER,
      p_id_messaggio_si4cs        NUMBER,
      p_oggetto                   VARCHAR2,
      p_testo                     CLOB,
      p_mime_testo                VARCHAR2,
      p_data_ricezione            DATE,
      p_mittente                  VARCHAR2,
      p_destinatari               VARCHAR2,
      p_destinatari_conoscenza    VARCHAR2,
      p_destinatari_nascosti      VARCHAR2,
      p_tipo                      VARCHAR2,
      p_stato                     VARCHAR2,
      p_data_stato                DATE,
      p_id_classificazione        NUMBER,
      p_id_fascicolo              NUMBER,
      p_note                      VARCHAR2,
      p_in_partenza               VARCHAR2,
      p_data_spedizione           VARCHAR2)
   IS
      d_id_documento   NUMBER;
   BEGIN
      IF p_in_partenza = 'N'
      THEN
         BEGIN
            SELECT id_documento
              INTO d_id_documento
              FROM AGP_MSG_RICEVUTI_DATI_PROT
             WHERE id_documento = p_id_documento;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_id_documento := NULL;
         END;

         IF d_id_documento IS NULL
         THEN
            INSERT INTO AGP_MSG_RICEVUTI_DATI_PROT (id_documento,
                                                    id_messaggio_si4cs,
                                                    oggetto,
                                                    testo,
                                                    mime_testo,
                                                    data_ricezione,
                                                    mittente,
                                                    destinatari,
                                                    destinatari_conoscenza,
                                                    destinatari_nascosti,
                                                    tipo,
                                                    stato,
                                                    data_stato,
                                                    id_classificazione,
                                                    id_fascicolo,
                                                    note)
                 VALUES (p_id_documento,
                         p_id_messaggio_si4cs,
                         p_oggetto,
                         p_testo,
                         p_mime_testo,
                         p_data_ricezione,
                         p_mittente,
                         TRIM (p_destinatari),
                         TRIM (p_destinatari_conoscenza),
                         TRIM (p_destinatari_nascosti),
                         p_tipo,
                         p_stato,
                         p_data_stato,
                         p_id_classificazione,
                         p_id_fascicolo,
                         p_note);

            INSERT
              INTO AGP_MSG_RICEVUTI_DATI_PROT_LOG (ID_DOCUMENTO,
                                                   REV,
                                                   DATA_RICEZIONE,
                                                   DATA_RICEZIONE_MOD,
                                                   DATA_STATO,
                                                   DATA_STATO_MOD,
                                                   ID_MESSAGGIO_SI4CS,
                                                   ID_MESSAGGIO_SI4CS_MOD,
                                                   STATO,
                                                   STATO_MESSAGGIO_MOD,
                                                   ID_CLASSIFICAZIONE,
                                                   CLASSIFICAZIONE_MOD,
                                                   ID_FASCICOLO,
                                                   FASCICOLO_MOD)
            VALUES (p_id_documento,
                    1,
                    p_data_ricezione,
                    DECODE (p_data_ricezione, NULL, 0, 1),
                    p_data_stato,
                    DECODE (p_data_stato, NULL, 0, 1),
                    p_id_messaggio_si4cs,
                    DECODE (p_id_messaggio_si4cs, NULL, 0, 1),
                    p_stato,
                    DECODE (p_stato, NULL, 0, 1),
                    p_id_classificazione,
                    DECODE (p_id_classificazione, NULL, 0, 1),
                    p_id_fascicolo,
                    DECODE (p_id_fascicolo, NULL, 0, 1));
         ELSE
            UPDATE AGP_MSG_RICEVUTI_DATI_PROT
               SET id_documento = p_id_documento,
                   id_messaggio_si4cs = p_id_messaggio_si4cs,
                   oggetto = p_oggetto,
                   testo = p_testo,
                   mime_testo = p_mime_testo,
                   data_ricezione = p_data_ricezione,
                   mittente = p_mittente,
                   destinatari = p_destinatari,
                   destinatari_conoscenza = p_destinatari_conoscenza,
                   destinatari_nascosti = p_destinatari_nascosti,
                   tipo = p_tipo,
                   stato = p_stato,
                   data_stato = p_data_stato,
                   id_classificazione = p_id_classificazione,
                   id_fascicolo = p_id_fascicolo,
                   note = p_note
             WHERE id_documento = d_id_documento;
         END IF;
      ELSE
         BEGIN
            SELECT id_documento
              INTO d_id_documento
              FROM AGP_MSG_INVIATI_DATI_PROT
             WHERE id_documento = p_id_documento;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_id_documento := NULL;
         END;

         IF d_id_documento IS NULL
         THEN
            --todo  insert
            INSERT INTO AGP_MSG_INVIATI_DATI_PROT (ID_DOCUMENTO,
                                                   ID_MESSAGGIO_SI4CS,
                                                   OGGETTO,
                                                   TESTO,
                                                   DATA_SPEDIZIONE,
                                                   MITTENTE,
                                                   DESTINATARI,
                                                   DESTINATARI_CONOSCENZA,
                                                   DESTINATARI_NASCOSTI,
                                                   TAGMAIL)
               SELECT p_id_documento,
                      p_id_messaggio_si4cs,
                      p_oggetto,
                      p_testo,
                      DECODE (p_data_spedizione,
                              NULL, SYSDATE,
                              TO_DATE (p_data_spedizione, 'dd/mm/yyyy')),
                      p_mittente,
                      p_destinatari,
                      p_destinatari_conoscenza,
                      p_destinatari_nascosti,
                      cs_tag
                 FROM SI4CS_MESSAGGI
                WHERE MESSAGGIO = p_id_messaggio_si4cs;
         ELSE
            UPDATE AGP_MSG_INVIATI_DATI_PROT
               SET oggetto = p_oggetto,
                   testo = p_testo,
                   data_spedizione = p_data_spedizione,
                   mittente = p_mittente,
                   destinatari = p_destinatari,
                   destinatari_conoscenza = p_destinatari_conoscenza,
                   destinatari_nascosti = p_destinatari_nascosti
             WHERE id_documento = p_id_documento;
         END IF;
      END IF;
   END;

   /* fine crea_memo_ricevuto*/

   FUNCTION crea_memo_agspr (p_id_documento_gdm NUMBER)
      RETURN NUMBER
   IS
      d_esiste                      NUMBER := 0;
      d_id_ente                     NUMBER := 1;

      d_id_doc                      NUMBER;
      d_id_rev                      NUMBER;

      d_id_classificazione          NUMBER;
      d_id_fascicolo                NUMBER;

      d_progr_uo                    NUMBER;
      d_dal_uo                      DATE;
      d_ottica_uo                   VARCHAR2 (100);
      d_id_tipo_collegamento_mail   NUMBER;
   BEGIN
      /******************************************************************************/
      /******************************************************************************/
      /*************************** Inizio crea_memo_agspr ***************************/
      /******************************************************************************/
      /******************************************************************************/
      DECLARE
         d_esiste_documento_gdm   NUMBER := 0;
      BEGIN
         SELECT COUNT (1)
           INTO d_esiste_documento_gdm
           FROM gdm_seg_memo_protocollo p
          WHERE p.id_documento = p_id_documento_gdm;

         IF d_esiste_documento_gdm = 0
         THEN
            raise_application_error (
               -20999,
                  'Memo identificato da '
               || p_id_documento_gdm
               || ' non presente.');
         END IF;
      END;

      DECLARE
         d_esiste   NUMBER := 0;
      BEGIN
         SELECT 1
           INTO d_esiste
           FROM gdo_documenti d, AGP_MSG_RICEVUTI_DATI_PROT m
          WHERE     d.id_documento_esterno = p_id_documento_gdm
                AND m.id_documento = d.id_documento
         UNION
         SELECT 1
           FROM gdo_documenti d, AGP_MSG_INVIATI_DATI_PROT m
          WHERE     d.id_documento_esterno = p_id_documento_gdm
                AND m.id_documento = d.id_documento;

         IF d_esiste = 1
         THEN
            raise_application_error (
               -20999,
                  'Memo identificato da '
               || p_id_documento_gdm
               || ' gia'' presente tra i messaggi ricevuti/inviati in agspr.');
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      BEGIN
         SELECT id_tipo_collegamento
           INTO d_id_tipo_collegamento_mail
           FROM gdo_tipi_collegamento
          WHERE tipo_collegamento = 'MAIL';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (
               -20999,
               'Non è stato caricato sul dizionario GDO_TIPI_COLLEGAMENTO il collegamento di tipo MAIL. Non posso procedere con la trascodifica.');
      END;


      FOR m
         IN (SELECT m.id_documento id_documento_esterno,
                    cs.id_cs_messaggio id_cs_messaggio_inviato,
                    m.corpo,
                    m.data_ricezione,
                    m.destinatari,
                    m.destinatari_conoscenza,
                    m.destinatari_nascosti,
                    m.generata_eccezione,
                    m.info,
                    NVL (m.memo_in_partenza, 'Y') memo_in_partenza,
                    m.message_id,
                    m.mittente,
                    m.motivo_no_proc,
                    m.oggetto,
                    m.processato_ag,
                    m.spedito,
                    DECODE (m.stato_memo,
                            'DG', 'DA_GESTIRE',
                            'G', 'GESTITO',
                            'GE', 'GENERATA_ECCEZIONE',
                            'NP', 'NON_PROTOCOLLATO',
                            'SC', 'SCARTATO',
                            'PR', 'PROTOCOLLATO',
                            'DPS', 'DA_PROTOCOLLARE_SENZA_SEGNATURA',
                            'DP', 'DA_PROTOCOLLARE_CON_SEGNATURA')
                       stato_messaggio,
                    m.data_stato_memo data_stato,
                    m.data_spedizione_memo,
                    m.class_cod,
                    m.class_dal,
                    m.dati_ripudio,
                    m.destinatari_cc_clob,
                    m.destinatari_clob,
                    m.fascicolo_anno,
                    m.fascicolo_numero,
                    m.idrif,
                    m.riservato,
                    m.tag_mail,
                    m.tipo_messaggio,
                    m.unita_protocollante,
                    m.utente_protocollante,
                    m.tipo_corpo,
                    m.registrata_accettazione,
                    m.registrata_non_accettazione,
                    s.utente_aggiornamento utente_ins,
                    s.data_aggiornamento data_ins,
                    d.utente_aggiornamento utente_upd,
                    d.data_aggiornamento data_upd
               FROM gdm_seg_memo_protocollo m,
                    gdm_documenti d,
                    gdm_stati_documento s,
                    gdm_ag_cs_messaggi cs
              WHERE     m.id_documento = p_id_documento_gdm
                    AND d.id_documento = m.id_documento
                    AND s.id_stato IN (SELECT MIN (id_stato)
                                         FROM gdm_stati_documento
                                        WHERE id_documento = d.id_documento)
                    AND cs.id_documento_memo(+) = m.id_documento)
      LOOP
         /******************************************
                 Calcolo UNITA_CREAZIONE
         ******************************************/
         IF m.unita_protocollante IS NOT NULL
         THEN
            AGP_TRASCO_PKG.calcola_unita (m.unita_protocollante,
                                          m.data_ins,
                                          d_progr_uo,
                                          d_dal_uo,
                                          d_ottica_uo);
         END IF;

         /******************************************
            Calcolo CLASSIFICAZIONE E FASCICOLO
         ******************************************/
         AGP_TRASCO_PKG.calcola_titolario (m.class_cod,
                                           m.class_dal,
                                           m.fascicolo_anno,
                                           m.fascicolo_numero,
                                           d_id_ente,
                                           d_id_classificazione,
                                           d_id_fascicolo);


         /******************************************
                      CREA DOCUMENTO
         ******************************************/
         DECLARE
            d_stato   VARCHAR2 (100);
         BEGIN
            AGP_TRASCO_PKG.crea_documento (m.id_documento_esterno,
                                           d_id_ente,
                                           'Y',
                                           m.riservato,
                                           m.utente_ins,
                                           m.data_ins,
                                           m.utente_upd,
                                           m.data_upd,
                                           NULL,
                                           '',
                                           d_stato,
                                           d_id_doc,
                                           d_id_rev);
         END;

         /******************************************
                      CREA FILE DOCUMENTO
         ******************************************/
         DECLARE
            d_codice        VARCHAR2 (1000) := 'FILE_PRINCIPALE';
            d_id_file_doc   NUMBER;
            d_sequenza      NUMBER := 0;
         BEGIN
            FOR file_prot
               IN (SELECT o.id_oggetto_file,
                          o.filename,
                          NVL (l.utente_operazione, o.utente_aggiornamento)
                             utente_ins,
                          NVL (data_operazione, o.data_aggiornamento)
                             data_ins,
                          o.utente_aggiornamento utente_upd,
                          o.data_aggiornamento data_upd
                     FROM gdm_oggetti_file o, gdm_oggetti_file_log l
                    WHERE     o.id_oggetto_file = l.id_oggetto_file(+)
                          AND l.tipo_operazione(+) = 'C'
                          AND o.id_documento = m.id_documento_esterno)
            LOOP
               d_id_file_doc :=
                  AGP_TRASCO_PKG.crea_file_documento (
                     d_id_doc,
                     file_prot.id_oggetto_file,
                     file_prot.utente_ins,
                     file_prot.data_ins,
                     file_prot.utente_upd,
                     file_prot.data_upd,
                     d_codice,
                     file_prot.filename,
                     d_sequenza,
                     NULL);
               d_sequenza := d_sequenza + 1;
            END LOOP;
         END;

         /******************************************
                 UO NESSAGGIO
         ******************************************/
         DECLARE
            d_id_doc_sogg   NUMBER;
         BEGIN
            d_id_doc_sogg :=
               AGP_TRASCO_PKG.crea_documento_soggetto (d_id_doc,
                                                       'UO_MESSAGGIO',
                                                       '',
                                                       d_progr_uo,
                                                       d_dal_uo,
                                                       d_ottica_uo,
                                                       d_id_rev);
         END;

         /******************************************
                 REDATTORE / PROTOCOLLANTE
         ******************************************/
         DECLARE
            d_id_doc_sogg   NUMBER;
         BEGIN
            d_id_doc_sogg :=
               AGP_TRASCO_PKG.crea_documento_soggetto (
                  d_id_doc,
                  'REDATTORE',
                  NVL (m.utente_ins, 'RPI'),
                  d_progr_uo,
                  d_dal_uo,
                  d_ottica_uo,
                  d_id_rev);
         END;

         /******************************************
                       CREA MEMO
         ******************************************/
         DECLARE
            d_id_si4cs                       NUMBER;
            d_message_id                     VARCHAR2 (2000);
            d_oggetto                        VARCHAR2 (4000);

            d_id_documento_eml               NUMBER;
            d_id_oggetto_file_eml            NUMBER;

            d_id_si4cs_padre                 NUMBER;
            d_id_documento_padre             NUMBER;
            d_message_id_padre               VARCHAR2 (2000);
            d_oggetto_padre                  VARCHAR2 (4000);
            d_corpo_padre                    CLOB;
            d_tipo_corpo_padre               VARCHAR2 (100);
            d_data_ricezione_padre           DATE;
            d_data_spedizione_memo_padre     VARCHAR2 (100);
            d_mittente_padre                 VARCHAR2 (200);
            d_destinatari_padre              CLOB;
            d_destinatari_conoscenza_padre   CLOB;
            d_destinatari_nascosti_padre     CLOB;
            d_tipo_messaggio_padre           VARCHAR2 (100);
            d_motivo_no_proc_padre           VARCHAR2 (4000);
            d_memo_in_partenza_padre         VARCHAR2 (1);
         BEGIN
            BEGIN
               -- gestione STREAM
               SELECT r.id_documento_rif id_documento_eml,
                      ogfi.id_oggetto_file
                 INTO d_id_documento_eml, d_id_oggetto_file_eml
                 FROM gdm_seg_memo_protocollo m,
                      gdm_seg_stream_memo_proto s,
                      gdm_riferimenti r,
                      gdm_oggetti_file ogfi
                WHERE     m.id_documento = p_id_documento_gdm
                      AND r.id_documento(+) = m.id_documento
                      AND s.id_documento(+) = r.id_documento_rif
                      AND ogfi.id_documento(+) = s.id_documento
                      AND r.tipo_relazione(+) = 'STREAM';

               IF     d_id_documento_eml IS NOT NULL
                  AND d_id_oggetto_file_eml IS NOT NULL
               THEN
                  d_id_documento_eml :=
                     gdm_sposta_file_doc_in_rep (d_id_documento_eml);
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            -- gestione documenti imbustati (anomalie)
            BEGIN
               SELECT r.id_documento_rif,
                      m.message_id,
                      m.oggetto,
                      m.corpo,
                      m.tipo_corpo,
                      m.data_ricezione,
                      m.data_spedizione_memo,
                      m.mittente,
                      m.destinatari,
                      m.destinatari_conoscenza,
                      m.destinatari_nascosti,
                      m.tipo_messaggio,
                      m.motivo_no_proc,
                      m.memo_in_partenza
                 INTO d_id_documento_padre,
                      d_message_id_padre,
                      d_oggetto_padre,
                      d_corpo_padre,
                      d_tipo_corpo_padre,
                      d_data_ricezione_padre,
                      d_data_spedizione_memo_padre,
                      d_mittente_padre,
                      d_destinatari_padre,
                      d_destinatari_conoscenza_padre,
                      d_destinatari_nascosti_padre,
                      d_tipo_messaggio_padre,
                      d_motivo_no_proc_padre,
                      d_memo_in_partenza_padre
                 FROM gdm_seg_memo_protocollo m, gdm_riferimenti r
                WHERE     m.id_documento = p_id_documento_gdm
                      AND r.id_documento = m.id_documento
                      AND r.tipo_relazione = 'PRINCIPALE';

               d_id_si4cs_padre :=
                  crea_messaggio_si4cs (d_id_documento_padre,
                                        d_message_id_padre,
                                        d_oggetto_padre,
                                        d_corpo_padre,
                                        d_tipo_corpo_padre,
                                        d_data_ricezione_padre,
                                        d_data_spedizione_memo_padre,
                                        d_mittente_padre,
                                        d_destinatari_padre,
                                        d_destinatari_conoscenza_padre,
                                        d_destinatari_nascosti_padre,
                                        d_tipo_messaggio_padre,
                                        d_motivo_no_proc_padre,
                                        d_memo_in_partenza_padre,
                                        NULL,
                                        NULL,
                                        d_id_documento_eml,
                                        d_id_oggetto_file_eml);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;

            d_id_si4cs :=
               crea_messaggio_si4cs (p_id_documento_gdm,
                                     m.message_id,
                                     m.oggetto,
                                     m.corpo,
                                     m.tipo_corpo,
                                     m.data_ricezione,
                                     m.data_spedizione_memo,
                                     m.mittente,
                                     m.destinatari,
                                     m.destinatari_conoscenza,
                                     m.destinatari_nascosti,
                                     m.tipo_messaggio,
                                     m.motivo_no_proc,
                                     m.memo_in_partenza,
                                     NULL,
                                     d_id_si4cs_padre,
                                     d_id_documento_eml,
                                     d_id_oggetto_file_eml);

            IF d_id_documento_padre IS NOT NULL
            THEN
               d_id_si4cs := d_id_si4cs_padre;
               d_oggetto := d_oggetto_padre;
            ELSE
               d_oggetto := m.oggetto;
            END IF;

            crea_memo_ricevuto_inviato (d_id_doc,
                                        d_id_si4cs,
                                        d_oggetto,
                                        m.corpo,
                                        m.tipo_corpo,
                                        m.data_ricezione,
                                        m.mittente,
                                        m.destinatari,
                                        m.destinatari_conoscenza,
                                        m.destinatari_nascosti,
                                        m.tipo_messaggio,
                                        m.stato_messaggio,
                                        m.data_stato,
                                        d_id_classificazione,
                                        d_id_fascicolo,
                                        m.motivo_no_proc,
                                        m.memo_in_partenza,
                                        m.data_spedizione_memo);

            DECLARE
               id_eml                NUMBER;
               id_oggetto_file_eml   NUMBER;
            BEGIN
               SELECT id_oggetto_file
                 INTO id_oggetto_file_eml
                 FROM si4cs_messaggi_blob
                WHERE id_documento = d_id_si4cs;

               id_eml :=
                  AGP_TRASCO_PKG.crea_file_documento (d_id_doc,
                                                      id_oggetto_file_eml,
                                                      'RPI',
                                                      SYSDATE,
                                                      'RPI',
                                                      SYSDATE,
                                                      'FILE_EML',
                                                      'messaggio.eml',
                                                      1,
                                                      NULL);
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END;

         /******************************************
                       CREA COLLEGAMENTI CON PROTOCOLLO COLLEGATO (SE ESISTE)
         ******************************************/
         DECLARE
            d_id_protocollo_mail       NUMBER := NULL;
            d_id_protocollo_mail_gdm   NUMBER := NULL;
            d_data_agg_rif_mail        DATE;
            d_utente_agg_rif_mail      VARCHAR2 (8);
            d_id_documento_coll        NUMBER := NULL;
            d_id_revisione             NUMBER := NULL;
         BEGIN
            SELECT MAX (gdm_riferimenti.id_documento),
                   MAX (data_aggiornamento),
                   MAX (utente_aggiornamento)
              INTO d_id_protocollo_mail_gdm,
                   d_data_agg_rif_mail,
                   d_utente_agg_rif_mail
              FROM gdm_seg_memo_protocollo, gdm_riferimenti
             WHERE     gdm_riferimenti.ID_DOCUMENTO_rif =
                          m.id_documento_esterno
                   AND tipo_relazione = 'MAIL'
                   AND area = 'SEGRETERIA.PROTOCOLLO';

            IF d_id_protocollo_mail_gdm IS NOT NULL
            THEN
               d_id_protocollo_mail :=
                  AGP_TRASCO_PKG.CREA_PROTOCOLLO_AGSPR (
                     d_id_protocollo_mail_gdm,
                     NULL,
                     1,
                     0);

               d_id_documento_coll := HIBERNATE_SEQUENCE.NEXTVAL;

               --LI COLLEGO
               INSERT INTO GDO_DOCUMENTI_COLLEGATI (ID_DOCUMENTO_COLLEGATO,
                                                    VERSION,
                                                    ID_COLLEGATO,
                                                    DATA_INS,
                                                    ID_DOCUMENTO,
                                                    DATA_UPD,
                                                    ID_TIPO_COLLEGAMENTO,
                                                    UTENTE_INS,
                                                    UTENTE_UPD,
                                                    VALIDO)
                    VALUES (d_id_documento_coll,
                            0,
                            d_id_protocollo_mail,
                            d_data_agg_rif_mail,
                            d_id_doc,
                            d_data_agg_rif_mail,
                            d_id_tipo_collegamento_mail,
                            d_utente_agg_rif_mail,
                            d_utente_agg_rif_mail,
                            'Y');

               d_id_revisione :=
                  AGP_TRASCO_PKG.crea_revinfo (
                     TO_TIMESTAMP (d_data_agg_rif_mail,
                                   'DD/MM/YYYY HH24:MI:SS,FF'));

               INSERT
                 INTO GDO_DOCUMENTI_COLLEGATI_LOG (ID_DOCUMENTO_COLLEGATO,
                                                   REV,
                                                   REVTYPE,
                                                   REVEND,
                                                   DATA_INS,
                                                   DATE_CREATED_MOD,
                                                   DATA_UPD,
                                                   LAST_UPDATED_MOD,
                                                   VALIDO,
                                                   VALIDO_MOD,
                                                   UTENTE_INS,
                                                   UTENTE_INS_MOD,
                                                   UTENTE_UPD,
                                                   UTENTE_UPD_MOD,
                                                   ID_COLLEGATO,
                                                   COLLEGATO_MOD,
                                                   ID_DOCUMENTO,
                                                   DOCUMENTO_MOD,
                                                   ID_TIPO_COLLEGAMENTO,
                                                   TIPO_COLLEGAMENTO_MOD)
               VALUES (d_id_documento_coll,
                       d_id_revisione,
                       0,
                       NULL,
                       d_data_agg_rif_mail,
                       0,
                       d_data_agg_rif_mail,
                       0,
                       'Y',
                       0,
                       d_utente_agg_rif_mail,
                       0,
                       d_utente_agg_rif_mail,
                       0,
                       d_id_protocollo_mail,
                       0,
                       d_id_doc,
                       0,
                       d_id_tipo_collegamento_mail,
                       0);
            END IF;
         END;

         IF m.memo_in_partenza <> 'Y'
         THEN
            /******************************************
                          CREA SMISTAMENTI
            ******************************************/
            DECLARE
               d_progr_tras          NUMBER;
               d_dal_tras            DATE;
               d_ottica_tras         VARCHAR2 (100);

               d_progr_smis          NUMBER;
               d_dal_smis            DATE;
               d_ottica_smis         VARCHAR2 (100);

               d_stato_smistamento   VARCHAR2 (100);
            BEGIN
               FOR smistamenti
                  IN (SELECT s.*,
                             d.utente_aggiornamento,
                             d.data_aggiornamento,
                             sd.utente_aggiornamento utente_inserimento,
                             sd.data_aggiornamento data_inserimento
                        FROM gdm_seg_smistamenti s,
                             gdm_documenti d,
                             gdm_stati_documento sd
                       WHERE     d.id_documento = s.id_documento
                             AND idrif = m.idrif
                             AND s.tipo_smistamento <> 'DUMMY'
                             AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
                             AND sd.id_stato IN (SELECT MIN (id_stato)
                                                   FROM gdm_stati_documento
                                                  WHERE id_documento =
                                                           d.id_documento))
               LOOP
                  d_progr_tras := NULL;
                  d_dal_tras := NULL;
                  d_ottica_tras := NULL;

                  d_progr_smis := NULL;
                  d_dal_smis := NULL;
                  d_ottica_smis := NULL;

                  d_stato_smistamento := NULL;

                  /******************************************
                          Calcolo UNITA_TRASMISSIONE
                  ******************************************/
                  IF smistamenti.ufficio_trasmissione IS NOT NULL
                  THEN
                     AGP_TRASCO_PKG.calcola_unita (
                        smistamenti.ufficio_trasmissione,
                        smistamenti.smistamento_dal,
                        d_progr_tras,
                        d_dal_tras,
                        d_ottica_tras);
                  END IF;

                  /******************************************
                          Calcolo UNITA_SMISTAMENTO
                  ******************************************/
                  IF smistamenti.ufficio_smistamento IS NOT NULL
                  THEN
                     AGP_TRASCO_PKG.calcola_unita (
                        smistamenti.ufficio_smistamento,
                        smistamenti.smistamento_dal,
                        d_progr_smis,
                        d_dal_smis,
                        d_ottica_smis);
                  END IF;

                  IF smistamenti.stato_smistamento = 'N'
                  THEN
                     d_stato_smistamento := 'CREATO';
                  ELSIF smistamenti.stato_smistamento = 'R'
                  THEN
                     d_stato_smistamento := 'DA_RICEVERE';
                  ELSIF smistamenti.stato_smistamento = 'C'
                  THEN
                     d_stato_smistamento := 'IN_CARICO';
                  ELSIF smistamenti.stato_smistamento = 'E'
                  THEN
                     d_stato_smistamento := 'ESEGUITO';
                  ELSIF smistamenti.stato_smistamento = 'S'
                  THEN
                     d_stato_smistamento := 'STORICO';
                  END IF;

                  AGP_TRASCO_PKG.crea_smistamento (
                     d_id_doc,
                     d_progr_tras,
                     d_dal_tras,
                     d_ottica_tras,
                     smistamenti.utente_trasmissione,
                     d_progr_smis,
                     d_dal_smis,
                     d_ottica_smis,
                     smistamenti.smistamento_dal,
                     d_stato_smistamento,
                     smistamenti.tipo_smistamento,
                     smistamenti.presa_in_carico_utente,
                     smistamenti.presa_in_carico_dal,
                     smistamenti.utente_esecuzione,
                     smistamenti.data_esecuzione,
                     NULL                              /* UTENTE_ASSEGNANTE */
                         ,
                     smistamenti.codice_assegnatario,
                     smistamenti.assegnazione_dal,
                     smistamenti.note,
                     smistamenti.utente_inserimento,
                     smistamenti.data_inserimento,
                     smistamenti.utente_aggiornamento,
                     smistamenti.data_aggiornamento,
                     smistamenti.id_documento       /* ID_DOCUMENTO_ESTERNO */
                                             ,
                     NULL                                 /* UTENTE_RIFIUTO */
                         ,
                     NULL                                   /* DATA_RIFIUTO */
                         ,
                     NULL                                 /* MOTIVO_RIFIUTO */
                         );
               END LOOP;
            END;

            /******************************************
                    CREA CLASS/FASC SECONDARI
            ******************************************/
            FOR tito
               IN (SELECT clas.class_cod,
                          clas.class_dal,
                          fasc.fascicolo_anno,
                          fasc.fascicolo_numero,
                          links.utente_aggiornamento,
                          links.data_aggiornamento
                     FROM gdm_links links,
                          gdm_fascicoli fasc,
                          gdm_classificazioni clas,
                          gdm_documenti docu_clas,
                          gdm_documenti docu_fasc,
                          gdm_cartelle cart_clas,
                          gdm_cartelle cart_fasc,
                          gdo_enti enti
                    WHERE     links.id_oggetto = m.id_documento_esterno
                          AND enti.id_ente = d_id_ente
                          AND clas.codice_amministrazione =
                                 enti.amministrazione
                          AND clas.codice_aoo = enti.aoo
                          AND fasc.codice_amministrazione =
                                 enti.amministrazione
                          AND fasc.codice_aoo = enti.aoo
                          AND tipo_oggetto = 'D'
                          AND cart_fasc.id_cartella = links.id_cartella
                          AND cart_fasc.id_documento_profilo =
                                 docu_fasc.id_documento
                          AND NVL (cart_fasc.stato, 'BO') <> 'CA'
                          AND fasc.class_cod = clas.class_cod
                          AND fasc.class_dal = clas.class_dal
                          AND clas.codice_amministrazione =
                                 fasc.codice_amministrazione
                          AND clas.codice_aoo = fasc.codice_aoo
                          AND docu_clas.id_documento = clas.id_documento
                          AND docu_fasc.id_documento = fasc.id_documento
                          AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND NVL (docu_fasc.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND NVL (cart_clas.stato, 'BO') <> 'CA'
                          AND fasc.class_cod <> m.class_cod
                          AND fasc.class_dal <> m.class_dal
                          AND fasc.fascicolo_anno <> m.fascicolo_anno
                          AND fasc.fascicolo_numero <> m.fascicolo_numero
                   UNION
                   SELECT clas.class_cod,
                          clas.class_dal,
                          NULL,
                          '',
                          links.utente_aggiornamento,
                          links.data_aggiornamento
                     FROM gdm_links links,
                          gdm_classificazioni clas,
                          gdm_documenti docu_clas,
                          gdm_cartelle cart_clas,
                          gdo_enti enti
                    WHERE     links.id_oggetto = m.id_documento_esterno
                          AND enti.id_ente = d_id_ente
                          AND clas.codice_amministrazione =
                                 enti.amministrazione
                          AND clas.codice_aoo = enti.aoo
                          AND tipo_oggetto = 'D'
                          AND cart_clas.id_cartella = links.id_cartella
                          AND docu_clas.id_documento = clas.id_documento
                          AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND NVL (cart_clas.stato, 'BO') <> 'CA'
                          AND clas.class_cod <> m.class_cod
                          AND clas.class_dal <> m.class_dal)
            LOOP
               DECLARE
                  d_id_class   NUMBER;
                  d_id_fasc    NUMBER;
               BEGIN
                  d_id_class := '';
                  d_id_fasc := '';
                  AGP_TRASCO_PKG.calcola_titolario (tito.class_cod,
                                                    tito.class_dal,
                                                    tito.fascicolo_anno,
                                                    tito.fascicolo_numero,
                                                    d_id_ente,
                                                    d_id_class,
                                                    d_id_fasc);
                  AGP_TRASCO_PKG.crea_titolario (d_id_doc,
                                                 d_id_class,
                                                 d_id_fasc,
                                                 tito.utente_aggiornamento,
                                                 tito.data_aggiornamento,
                                                 tito.utente_aggiornamento,
                                                 tito.data_aggiornamento);
               END;
            END LOOP;
         END IF;
      END LOOP;

      RETURN d_id_doc;
   END;
END;
/
