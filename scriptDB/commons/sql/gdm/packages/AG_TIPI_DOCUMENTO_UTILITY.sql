--liquibase formatted sql
--changeset esasdelli:20200221_AG_TIPI_DOCUMENTO_UTILITY runOnChange:true stripComments:false
CREATE OR REPLACE PACKAGE AG_TIPI_DOCUMENTO_UTILITY
IS
   /******************************************************************************
    NOME:        AG_TIPI_DOCUMENTO_UTILITY
    DESCRIZIONE: Procedure e Funzioni della tabella SEG_TIPI_DOCUMENTO.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   12/09/2017 MM     Creazione.
    01   18/12/2017 MM     Creata is_associato_flusso
    02   26/01/2018 MM     Creata is_domanda_accesso_civico
    03   31/01/2018 MM     Creata get_tipo_protocollo_risposta
    04   13/02/2019 MM     Creata funzione has_allegati
    05   22/02/2019 MM     Creata funzione get_tipo_allegato_tipo_docu
    06   21/06/2019 MM     Gestione campo riservato
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.06';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_codice (p_id_schema_protocollo NUMBER)
      RETURN VARCHAR2;

   FUNCTION crea (p_tipo_documento              VARCHAR2,
                  p_descrizione                 VARCHAR2,
                  p_class_cod                   VARCHAR2,
                  p_class_dal                   DATE,
                  p_fascicolo_anno              NUMBER,
                  p_fascicolo_numero            VARCHAR2,
                  p_modalita                    VARCHAR2,
                  p_oggetto                     VARCHAR2,
                  p_note                        VARCHAR2,
                  p_tipo_registro               VARCHAR2,
                  p_dataval_dal                 DATE,
                  p_dataval_al                  DATE,
                  p_segnatura                   VARCHAR2,
                  p_segnatura_completa          VARCHAR2,
                  p_tipo_doc_risposta           VARCHAR2,
                  p_risposta                    VARCHAR2,
                  p_id_tipo_protocollo          NUMBER,
                  p_anni_conservazione          NUMBER,
                  p_conservazione_illimitata    VARCHAR2,
                  p_scadenza                    NUMBER,
                  p_domanda_accesso             VARCHAR2,
                  p_ufficio_esibente            VARCHAR2,
                  p_riservato                   VARCHAR2,
                  p_codice_amministrazione      VARCHAR2,
                  p_codice_aoo                  VARCHAR2,
                  p_utente                      VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_smistamento (p_tipo_documento            VARCHAR2,
                              p_tipo_smistamento          VARCHAR2,
                              p_ufficio_smistamento       VARCHAR2,
                              p_sequenza                  NUMBER,
                              p_email                     VARCHAR2,
                              p_fascicolo_obbligatorio    VARCHAR2,
                              p_progressivo               NUMBER,
                              p_codice_amministrazione    VARCHAR2,
                              p_codice_aoo                VARCHAR2,
                              p_utente                    VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_unita_competente (p_tipo_documento            VARCHAR2,
                                   p_unita                     VARCHAR2,
                                   p_progressivo               NUMBER,
                                   p_codice_amministrazione    VARCHAR2,
                                   p_codice_aoo                VARCHAR2,
                                   p_utente                    VARCHAR2)
      RETURN NUMBER;

   FUNCTION has_sequenza_smistamenti (p_tipo_documento VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_next_unita_smistamento (p_tipo_documento      VARCHAR2,
                                        p_unita_precedente    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_prev_unita_smistamento (p_tipo_documento      VARCHAR2,
                                        p_unita_precedente    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_min_uo_smistamento (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_max_uo_smistamento (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION has_risposta_associata (p_tipo_documento VARCHAR2)
      RETURN NUMBER;

   FUNCTION IS_ELIMINABILE (P_ID_DOCUMENTO NUMBER, P_RISPOSTA VARCHAR2)
      RETURN NUMBER;

   FUNCTION IS_FASCICOLO_OBBLIGATORIO (p_tipo_documento    VARCHAR2,
                                       p_unita             VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_associato_flusso (p_tipo_documento VARCHAR2)
      RETURN NUMBER;

   FUNCTION is_domanda_accesso_civico (p_tipo_documento VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_domanda_accesso_civico (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_tipo_doc_risposta (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_risposta (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_tipo_protocollo_risposta (
      p_tipo_documento           IN seg_tipi_documento.descrizione_tipo_documento%TYPE,
      p_codice_amministrazione   IN VARCHAR2,
      p_codice_aoo               IN VARCHAR2,
      p_data_rif                 IN DATE DEFAULT SYSDATE)
      RETURN VARCHAR2;

   FUNCTION is_risposta_accesso_civico (p_tipo_documento VARCHAR2)
      RETURN NUMBER;

   FUNCTION has_allegati (p_tipo_documento VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_tipo_allegato_tipo_docu (p_tipo_documento    VARCHAR2,
                                         p_nomefile          VARCHAR2)
      RETURN VARCHAR2;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_TIPI_DOCUMENTO_UTILITY
IS
   /******************************************************************************
    NOME:        AG_TIPI_DOCUMENTO_UTILITY
    DESCRIZIONE: Procedure e Funzioni della tabella SEG_TIPI_DOCUMENTO.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000   12/09/2017 MM     Creazione.
    001   18/12/2017 MM     Creata is_associato_flusso
    002   26/01/2018 MM     Creata is_domanda_accesso_civico
    003   31/01/2018 MM     Creata get_tipo_protocollo_risposta
    004   13/02/2019 MM     Creata funzione has_allegati
    005   22/02/2019 MM     Creata funzione get_tipo_allegato_tipo_docu
    006   21/06/2019 MM     Gestione campo riservato
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '006';

   FUNCTION versione
      RETURN VARCHAR2
   IS
   /******************************************************************************
    NOME:        VERSIONE
    DESCRIZIONE; Restituisce versione e revisione di distribuzione del package.
    RITORNA:     stringa VARCHAR2 contenente versione e revisione.
    NOTE:        Primo numero  : versione compatibilita del Package.
                 Secondo numero: revisione del Package specification.
                 Terzo numero  : revisione del Package body.
   ******************************************************************************/
   BEGIN
      RETURN afc.VERSION (s_revisione, s_revisione_body);
   END versione;

   FUNCTION get_codice (p_id_schema_protocollo NUMBER)
      RETURN VARCHAR2
   AS
      ret   SEG_TIPI_DOCUMENTO.TIPO_DOCUMENTO%TYPE;
   BEGIN
      SELECT tipo_documento
        INTO ret
        FROM seg_tipi_documento
       WHERE id_documento = p_id_schema_protocollo;

      RETURN ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         ret := NULL;
         RETURN ret;
   END;

   FUNCTION crea (p_tipo_documento              VARCHAR2,
                  p_descrizione                 VARCHAR2,
                  p_class_cod                   VARCHAR2,
                  p_class_dal                   DATE,
                  p_fascicolo_anno              NUMBER,
                  p_fascicolo_numero            VARCHAR2,
                  p_modalita                    VARCHAR2,
                  p_oggetto                     VARCHAR2,
                  p_note                        VARCHAR2,
                  p_tipo_registro               VARCHAR2,
                  p_dataval_dal                 DATE,
                  p_dataval_al                  DATE,
                  p_segnatura                   VARCHAR2,
                  p_segnatura_completa          VARCHAR2,
                  p_tipo_doc_risposta           VARCHAR2,
                  p_risposta                    VARCHAR2,
                  p_id_tipo_protocollo          NUMBER,
                  p_anni_conservazione          NUMBER,
                  p_conservazione_illimitata    VARCHAR2,
                  p_scadenza                    NUMBER,
                  p_domanda_accesso             VARCHAR2,
                  p_ufficio_esibente            VARCHAR2,
                  p_riservato                   VARCHAR2,
                  p_codice_amministrazione      VARCHAR2,
                  p_codice_aoo                  VARCHAR2,
                  p_utente                      VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_nuovo           NUMBER;
      dep_cod_rif_allegato   VARCHAR2 (100);
   BEGIN
      IF p_tipo_documento IS NULL OR p_descrizione IS NULL
      THEN
         raise_application_error (
            -20999,
            'Indicare almeno il codice (p_tipo_documento) e la descrizione (p_descrizione).');
      END IF;

      dep_id_nuovo :=
         gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                     p_modello                   => 'DIZ_TIPI_DOCUMENTO',
                                     p_cr                        => NULL,
                                     p_utente                    => p_utente,
                                     p_crea_record_orizzontale   => 1);


      UPDATE seg_tipi_documento
         SET tipo_documento = p_tipo_documento,
             descrizione_tipo_documento = p_descrizione,
             class_cod = p_class_cod,
             class_dal = p_class_dal,
             fascicolo_anno = p_fascicolo_anno,
             fascicolo_numero = p_fascicolo_numero,
             modalita =
                DECODE (p_modalita,
                        'INTERNO', 'INT',
                        'PARTENZA', 'PAR',
                        'ARRIVO', 'ARR',
                        ''),
             oggetto = p_oggetto,
             note = p_note,
             tipo_registro_documento = p_tipo_registro,
             dataval_dal = TRUNC (p_dataval_dal),
             dataval_al = TRUNC (p_dataval_al),
             segnatura = p_segnatura,
             segnatura_completa = p_segnatura_completa,
             tipo_doc_risposta = p_tipo_doc_risposta,
             risposta = p_risposta,
             domanda_accesso = p_domanda_accesso,
             id_tipo_protocollo = p_id_tipo_protocollo,
             anni_conservazione = p_anni_conservazione,
             conservazione_illimitata = p_conservazione_illimitata,
             unita_esibente = p_ufficio_esibente,
             scadenza = p_scadenza,
             riservato = p_riservato,
             codice_amministrazione = p_codice_amministrazione,
             codice_aoo = p_codice_aoo
       WHERE id_documento = dep_id_nuovo;

      RETURN dep_id_nuovo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;


   FUNCTION crea_smistamento (p_tipo_documento            VARCHAR2,
                              p_tipo_smistamento          VARCHAR2,
                              p_ufficio_smistamento       VARCHAR2,
                              p_sequenza                  NUMBER,
                              p_email                     VARCHAR2,
                              p_fascicolo_obbligatorio    VARCHAR2,
                              p_progressivo               NUMBER,
                              p_codice_amministrazione    VARCHAR2,
                              p_codice_aoo                VARCHAR2,
                              p_utente                    VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_nuovo   NUMBER;
   BEGIN
      IF p_tipo_documento IS NULL OR p_ufficio_smistamento IS NULL
      THEN
         raise_application_error (
            -20999,
            'Indicare almeno il tipo_documento e l'' ufficio di smistamento.');
      END IF;

      dep_id_nuovo :=
         gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                     p_modello                   => 'M_SMISTAMENTO_TIPI_DOC',
                                     p_cr                        => NULL,
                                     p_utente                    => p_utente,
                                     p_crea_record_orizzontale   => 1);


      UPDATE SEG_SMISTAMENTI_TIPI_DOCUMENTO
         SET CODICE_AMMINISTRAZIONE = P_CODICE_AMMINISTRAZIONE,
             CODICE_AOO = P_CODICE_AOO,
             TIPO_DOCUMENTO = P_TIPO_DOCUMENTO,
             TIPO_SMISTAMENTO = P_TIPO_SMISTAMENTO,
             UFFICIO_SMISTAMENTO = P_UFFICIO_SMISTAMENTO,
             EMAIL = P_EMAIL,
             PROGRESSIVO = P_PROGRESSIVO,
             SEQUENZA = P_SEQUENZA,
             FASCICOLO_OBBLIGATORIO = P_FASCICOLO_OBBLIGATORIO
       WHERE id_documento = dep_id_nuovo;

      RETURN dep_id_nuovo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION crea_unita_competente (p_tipo_documento            VARCHAR2,
                                   p_unita                     VARCHAR2,
                                   p_progressivo               NUMBER,
                                   p_codice_amministrazione    VARCHAR2,
                                   p_codice_aoo                VARCHAR2,
                                   p_utente                    VARCHAR2)
      RETURN NUMBER
   IS
      dep_id_nuovo   NUMBER;
   BEGIN
      /*raise_application_error(-20999,'crea_unita_competente ('''||p_tipo_documento||''',
                                   '''||p_unita||''',
                                   '||p_progressivo||',
                                   '''||p_codice_amministrazione||''',
                                   '''||p_codice_aoo||''',
                                   '''||p_utente||''')');*/

      IF p_tipo_documento IS NULL --OR p_unita IS NULL
      THEN
         raise_application_error (
            -20999,
               'Indicare almeno il tipo_documento ('''
            || p_tipo_documento
            || ''').');
--         raise_application_error (
--            -20999,
--               'Indicare almeno il tipo_documento ('''
--            || p_tipo_documento
--            || ''') e l'' ufficio di competenza ('''
--            || p_unita
--            || ''').');
      END IF;

      dep_id_nuovo :=
         gdm_profilo.crea_documento (p_area                      => 'SEGRETERIA',
                                     p_modello                   => 'M_UNITA_TIPI_DOC',
                                     p_cr                        => NULL,
                                     p_utente                    => p_utente,
                                     p_crea_record_orizzontale   => 1);


      UPDATE SEG_UNITA_TIPI_DOC
         SET CODICE_AMMINISTRAZIONE = P_CODICE_AMMINISTRAZIONE,
             CODICE_AOO = P_CODICE_AOO,
             PROGRESSIVO = P_PROGRESSIVO,
             TIPO_DOCUMENTO = P_TIPO_DOCUMENTO,
             UNITA = P_UNITA
       WHERE id_documento = dep_id_nuovo;

      RETURN dep_id_nuovo;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION has_sequenza_smistamenti (p_tipo_documento VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER := 0;
   BEGIN
      SELECT DISTINCT 1
        INTO d_return
        FROM seg_smistamenti_tipi_documento smtd, documenti docu
       WHERE     tipo_documento = p_tipo_documento
             AND smtd.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND NVL (sequenza, -1) > 0;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION get_next_unita_smistamento (p_tipo_documento      VARCHAR2,
                                        p_unita_precedente    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return                   VARCHAR2 (100);
      d_next_sequenza            NUMBER;
      d_progr_unita_precedente   NUMBER;
      d_progr_unita_successiva   NUMBER;
   BEGIN
      d_progr_unita_precedente :=
         SO4_UTIL.ANUO_GET_PROGR (
            AG_UTILITIES.GET_OTTICA_AOO (AG_UTILITIES.get_defaultaooindex ()),
            NULL,
            p_unita_precedente,
            TRUNC (SYSDATE));

      SELECT MIN (smtd.sequenza)
        INTO d_next_sequenza
        FROM seg_smistamenti_tipi_documento smtd, documenti docu
       WHERE     smtd.tipo_documento = p_tipo_documento
             AND smtd.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND sequenza >=
                    (SELECT MAX (sequenza) + 1
                       FROM seg_smistamenti_tipi_documento smtd2,
                            documenti docu
                      WHERE     smtd2.tipo_documento = smtd.tipo_documento
                            AND smtd2.progressivo = d_progr_unita_precedente
                            AND smtd2.id_documento = docu.id_documento
                            AND docu.stato_documento NOT IN ('CA', 'RE', 'PB'))
             AND SO4_UTIL.ANUO_GET_CODICE_UO (progressivo, TRUNC (SYSDATE))
                    IS NOT NULL;

      IF d_next_sequenza IS NOT NULL AND d_next_sequenza > 0
      THEN
         SELECT progressivo
           INTO d_progr_unita_successiva
           FROM seg_smistamenti_tipi_documento smtd, documenti docu
          WHERE     smtd.tipo_documento = p_tipo_documento
                AND smtd.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND sequenza = d_next_sequenza;

         d_return :=
            SO4_UTIL.ANUO_GET_CODICE_UO (d_progr_unita_successiva,
                                         TRUNC (SYSDATE));
      END IF;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_next_unita_smistamento;

   FUNCTION is_fascicolo_obbligatorio (p_tipo_documento    VARCHAR2,
                                       p_unita             VARCHAR2)
      RETURN NUMBER
   IS
      d_return        NUMBER := 0;
      d_progr_unita   NUMBER;
   BEGIN
      d_progr_unita :=
         SO4_UTIL.ANUO_GET_PROGR (
            AG_UTILITIES.GET_OTTICA_AOO (AG_UTILITIES.get_defaultaooindex ()),
            NULL,
            p_unita,
            TRUNC (SYSDATE));

      SELECT DECODE (NVL (FASCICOLO_OBBLIGATORIO, 'N'), 'N', 0, 1)
        INTO d_return
        FROM seg_smistamenti_tipi_documento smtd, documenti docu
       WHERE     smtd.tipo_documento = p_tipo_documento
             AND smtd.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND progressivo = d_progr_unita;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END IS_FASCICOLO_OBBLIGATORIO;

   FUNCTION get_prev_unita_smistamento (p_tipo_documento      VARCHAR2,
                                        p_unita_precedente    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return                   VARCHAR2 (100);
      d_next_sequenza            NUMBER;
      d_progr_unita_precedente   NUMBER;
      d_progr_unita_successiva   NUMBER;
   BEGIN
      d_progr_unita_precedente :=
         SO4_UTIL.ANUO_GET_PROGR (
            AG_UTILITIES.GET_OTTICA_AOO (AG_UTILITIES.get_defaultaooindex ()),
            NULL,
            p_unita_precedente,
            TRUNC (SYSDATE));

      SELECT MAX (smtd.sequenza)
        INTO d_next_sequenza
        FROM seg_smistamenti_tipi_documento smtd, documenti docu
       WHERE     smtd.tipo_documento = p_tipo_documento
             AND smtd.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND sequenza <=
                    (SELECT MAX (sequenza) - 1
                       FROM seg_smistamenti_tipi_documento smtd2,
                            documenti docu
                      WHERE     smtd2.tipo_documento = smtd.tipo_documento
                            AND smtd2.progressivo = d_progr_unita_precedente
                            AND smtd2.id_documento = docu.id_documento
                            AND docu.stato_documento NOT IN ('CA', 'RE', 'PB'))
             AND SO4_UTIL.ANUO_GET_CODICE_UO (progressivo, TRUNC (SYSDATE))
                    IS NOT NULL;

      IF d_next_sequenza IS NOT NULL AND d_next_sequenza > 0
      THEN
         SELECT progressivo
           INTO d_progr_unita_successiva
           FROM seg_smistamenti_tipi_documento smtd, documenti docu
          WHERE     smtd.tipo_documento = p_tipo_documento
                AND smtd.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND sequenza = d_next_sequenza;

         d_return :=
            SO4_UTIL.ANUO_GET_CODICE_UO (d_progr_unita_successiva,
                                         TRUNC (SYSDATE));
      END IF;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_prev_unita_smistamento;

   FUNCTION get_min_uo_smistamento (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (255);
      d_progr    NUMBER;
   BEGIN
      SELECT progressivo
        INTO d_progr
        FROM seg_smistamenti_tipi_documento smtd, documenti docu
       WHERE     tipo_documento = p_tipo_documento
             AND smtd.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND sequenza IN (SELECT MIN (NVL (sequenza, -1))
                                FROM seg_smistamenti_tipi_documento smtd,
                                     documenti docu
                               WHERE     tipo_documento = p_tipo_documento
                                     AND smtd.id_documento =
                                            docu.id_documento
                                     AND docu.stato_documento NOT IN ('CA',
                                                                      'RE',
                                                                      'PB')
                                     AND NVL (sequenza, -1) > 0);

      d_return := SO4_UTIL.ANUO_GET_CODICE_UO (d_progr, TRUNC (SYSDATE));

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_max_uo_smistamento (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (255);
      d_progr    NUMBER;
   BEGIN
      SELECT progressivo
        INTO d_progr
        FROM seg_smistamenti_tipi_documento smtd, documenti docu
       WHERE     tipo_documento = p_tipo_documento
             AND smtd.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND sequenza IN (SELECT MAX (NVL (sequenza, -1))
                                FROM seg_smistamenti_tipi_documento smtd,
                                     documenti docu
                               WHERE     tipo_documento = p_tipo_documento
                                     AND smtd.id_documento =
                                            docu.id_documento
                                     AND docu.stato_documento NOT IN ('CA',
                                                                      'RE',
                                                                      'PB')
                                     AND NVL (sequenza, -1) > 0);

      d_return := SO4_UTIL.ANUO_GET_CODICE_UO (d_progr, TRUNC (SYSDATE));

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION has_risposta_associata (p_tipo_documento VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER := 0;
   BEGIN
      SELECT DISTINCT 1
        INTO d_return
        FROM seg_tipi_documento tido,
             seg_tipi_documento tido_risp,
             documenti docu_risp
       WHERE     tido.tipo_documento = p_tipo_documento
             AND tido_risp.tipo_documento = TIDO.TIPO_DOC_RISPOSTA
             AND tido_risp.id_documento = docu_risp.id_documento
             AND docu_risp.stato_documento NOT IN ('CA', 'RE', 'PB');

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   /*
   UN TIPO DOCUMENTO RISPOSTA è ELIMINABILE
   SE NON UTILIZZATO COME RISPOSTA
   O UTILIZZATO CON UN TIPO DOCUMENTO CANCELLATO
   */
   FUNCTION is_eliminabile (P_ID_DOCUMENTO NUMBER, P_RISPOSTA VARCHAR2)
      RETURN NUMBER
   AS
      RET        NUMBER := 1;
      d_codice   seg_tipi_documento.tipo_documento%TYPE;
   BEGIN
      IF NVL (p_risposta, 'N') = 'Y'
      THEN
         d_codice := GET_CODICE (P_ID_DOCUMENTO);

         BEGIN
            SELECT DISTINCT 0
              INTO RET
              FROM seg_tipi_documento tido, documenti docu
             WHERE     docu.id_documento = tido.id_documento
                   AND (   docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                        OR NVL (TIDO.DATAVAL_AL, TO_DATE ('3333333', 'j')) =
                              TO_DATE ('3333333', 'j'))
                   AND tido.tipo_doc_risposta = d_codice;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RET := 1;
         END;
      END IF;

      RETURN RET;
   END;

   FUNCTION is_associato_flusso (p_tipo_documento VARCHAR2)
      RETURN NUMBER
   IS
      d_id_documento   NUMBER := 0;
      d_return         NUMBER := 0;
   BEGIN
      SELECT tido.id_documento
        INTO d_id_documento
        FROM seg_tipi_documento tido, documenti docu
       WHERE     docu.id_documento = tido.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND SYSDATE BETWEEN NVL (TIDO.DATAVAL_DAL,
                                      TO_DATE ('2222222', 'j'))
                             AND NVL (TIDO.DATAVAL_AL,
                                      TO_DATE ('3333333', 'j'))
             AND tido.tipo_documento = p_tipo_documento;

      DBMS_OUTPUT.put_line (d_id_documento);

      d_return :=
         agspr_schemi_protocollo_pkg.is_associato_flusso (
            p_id_documento_esterno   => d_id_documento);
      DBMS_OUTPUT.put_line (d_return);

      RETURN d_return;
   END;

   FUNCTION is_risposta_accesso_civico (p_tipo_documento VARCHAR2)
      RETURN NUMBER
   IS
      d_is_risposta   NUMBER := 0;
   BEGIN
      SELECT DISTINCT 1
        INTO d_is_risposta
        FROM seg_tipi_documento tido, documenti docu_risp
       WHERE     docu_risp.id_documento = tido.id_documento
             AND docu_risp.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND tido.tipo_doc_risposta = p_tipo_documento
             AND NVL (domanda_accesso, 'N') <> 'N';

      RETURN d_is_risposta;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION is_domanda_accesso_civico (p_tipo_documento VARCHAR2)
      RETURN NUMBER
   IS
      d_is_domanda   NUMBER := 0;
   BEGIN
      IF p_tipo_documento IS NOT NULL
      THEN
         SELECT NVL (COUNT (1), 0)
           INTO d_is_domanda
           FROM seg_tipi_documento tido, documenti docu
          WHERE     docu.id_documento = tido.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND SYSDATE BETWEEN NVL (TIDO.DATAVAL_DAL,
                                         TO_DATE ('2222222', 'j'))
                                AND NVL (TIDO.DATAVAL_AL,
                                         TO_DATE ('3333333', 'j'))
                AND tido.tipo_documento = p_tipo_documento
                AND NVL (domanda_accesso, 'N') <> 'N';
      END IF;

      RETURN d_is_domanda;
   END;

   FUNCTION get_domanda_accesso_civico (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      d_domanda   VARCHAR2 (255);
   BEGIN
      IF p_tipo_documento IS NOT NULL
      THEN
         SELECT NVL (domanda_accesso, 'N')
           INTO d_domanda
           FROM seg_tipi_documento tido, documenti docu
          WHERE     docu.id_documento = tido.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND SYSDATE BETWEEN NVL (TIDO.DATAVAL_DAL,
                                         TO_DATE ('2222222', 'j'))
                                AND NVL (TIDO.DATAVAL_AL,
                                         TO_DATE ('3333333', 'j'))
                AND tido.tipo_documento = p_tipo_documento;
      END IF;

      RETURN d_domanda;
   END;

   FUNCTION get_tipo_doc_risposta (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (255);
   BEGIN
      IF p_tipo_documento IS NOT NULL
      THEN
         SELECT tipo_doc_risposta
           INTO d_return
           FROM seg_tipi_documento tido, documenti docu
          WHERE     docu.id_documento = tido.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND SYSDATE BETWEEN NVL (TIDO.DATAVAL_DAL,
                                         TO_DATE ('2222222', 'j'))
                                AND NVL (TIDO.DATAVAL_AL,
                                         TO_DATE ('3333333', 'j'))
                AND tido.tipo_documento = p_tipo_documento;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_risposta (p_tipo_documento VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (255);
   BEGIN
      IF p_tipo_documento IS NOT NULL
      THEN
         SELECT risposta
           INTO d_return
           FROM seg_tipi_documento tido, documenti docu
          WHERE     docu.id_documento = tido.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND SYSDATE BETWEEN NVL (TIDO.DATAVAL_DAL,
                                         TO_DATE ('2222222', 'j'))
                                AND NVL (TIDO.DATAVAL_AL,
                                         TO_DATE ('3333333', 'j'))
                AND tido.tipo_documento = p_tipo_documento;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_tipo_protocollo_risposta (
      p_tipo_documento           IN seg_tipi_documento.descrizione_tipo_documento%TYPE,
      p_codice_amministrazione   IN VARCHAR2,
      p_codice_aoo               IN VARCHAR2,
      p_data_rif                 IN DATE DEFAULT SYSDATE)
      RETURN VARCHAR2
   IS
      /*****************************************************************************
         NOME:        get_tipo_protocollo_risposta
         DESCRIZIONE: Reastituisce
         RITORNO:
         Rev.  Data       Autore  Descrizione.
         003   31/01/2018 MM      Creazione
      ********************************************************************************/
      d_result   VARCHAR2 (256);
   BEGIN
      SELECT agspr_tipi_protocollo_pkg.get_codice (
                tido_risposta.id_tipo_protocollo,
                tido_risposta.codice_amministrazione,
                tido_risposta.codice_aoo)
                tipo_protocollo_risposta
        INTO d_result
        FROM seg_tipi_documento tido,
             documenti docu_tido,
             seg_tipi_documento tido_risposta
       WHERE     tido_risposta.tipo_documento(+) = tido.tipo_doc_risposta
             AND docu_tido.id_documento = tido.id_documento
             AND docu_tido.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND NVL (tido.risposta, 'N') = 'N'
             AND ag_tipi_documento_utility.is_associato_flusso (
                    tido.tipo_documento) = 0
             AND TIDO.CODICE_AMMINISTRAZIONE = p_codice_amministrazione
             AND TIDO.CODICE_AOO = p_codice_aoo
             AND TRUNC (p_data_rif) BETWEEN NVL (tido.dataval_dal,
                                                 TO_DATE (2222222, 'j'))
                                        AND NVL (tido.dataval_al,
                                                 TO_DATE (3333333, 'j'))
             AND tido.tipo_documento = p_tipo_documento;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION has_allegati (p_tipo_documento VARCHAR2)
      RETURN NUMBER
   IS
      d_return   NUMBER := 0;
   BEGIN
      SELECT COUNT (1)
        INTO d_return
        FROM seg_tipi_documento tido,
             SEG_TIPI_DOCUMENTO_ALLEGATI tido_alle,
             documenti docu
       WHERE     tido.tipo_documento = p_tipo_documento
             AND tido.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND tido_alle.id_schema_protocollo = -tido.id_documento;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION get_tipo_allegato_tipo_docu (p_tipo_documento    VARCHAR2,
                                         p_nomefile          VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return   VARCHAR2 (100);
   BEGIN
      SELECT -id_tipo_allegato
        INTO d_return
        FROM seg_tipi_documento_allegati
       WHERE tipo_documento = p_tipo_documento AND nome = p_nomefile;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;
END;
/
