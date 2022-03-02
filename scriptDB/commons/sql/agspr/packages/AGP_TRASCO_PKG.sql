--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_TRASCO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_TRASCO_PKG
IS
   /******************************************************************************
    NOME:        AGP_TRASCO_PKG
    DESCRIZIONE: Gestione TRASCO da GDM.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    24/10/2010    mmalferrari    Prima emissione.
    01    24/09/2019    mmalferrari    Creata crea_memo_agspr
    02    07/01/2019    mmalferrari    Eliminata crea_memo_agspr e modificata
                                       crea_protocollo_agspr.
    03    21/02/2020    mmalferrari    Modificata crea_revinfo e aggiunta del_revinfo.
    04    10/03/2020    mmalferrari    Creata elimina_storico_documento
    05    27/04/2020    mmalferrari    Creata elimina_trasco_documento
    06    25/05/2020    mmalferrari    Modificato parametro p_dal_tras di crea_smistamento
                                       da VARCHAR2 a DATE.
    07    25/05/2020    svalenti       Creata crea_doc_titolario_agspr
    08    10/09/2020    mmalferrari    Aggiunto p_id_rev a crea_documento_soggetto
    09    13/10/2020    mmalferrari    Modificata crea_protocollo_agspr per gestione
                                       separata trasco storico.
    10    16/10/2020    mfrancesconi   Creata crea_trasco_scarico_ipa
    11    20/10/2020    mmalferrari    Creata crea_doc_da_fasc_agspr
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.11';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION crea_revinfo (p_data TIMESTAMP, p_rev NUMBER DEFAULT NULL)
      RETURN NUMBER;

   PROCEDURE del_revinfo (p_rev NUMBER);

   PROCEDURE calcola_unita (p_codice             VARCHAR2,
                            p_data               DATE,
                            p_progr_uo    IN OUT NUMBER,
                            p_dal_uo      IN OUT DATE,
                            p_ottica_uo   IN OUT VARCHAR2);

   PROCEDURE calcola_titolario (p_class_cod                   VARCHAR2,
                                p_class_dal                   DATE,
                                p_fascicolo_anno              NUMBER,
                                p_fascicolo_numero            VARCHAR2,
                                p_id_ente                     NUMBER,
                                p_id_classificazione   IN OUT NUMBER,
                                p_id_fascicolo         IN OUT NUMBER);

   PROCEDURE crea_smistamento (p_id_documento              NUMBER,
                               p_progr_tras                NUMBER,
                               p_dal_tras                  DATE,
                               p_ottica_tras               VARCHAR2,
                               p_utente_trasmissione       VARCHAR2,
                               p_progr_smis                NUMBER,
                               p_dal_smis                  DATE,
                               p_ottica_smis               VARCHAR2,
                               p_smistamento_dal           DATE,
                               p_stato_smistamento         VARCHAR2,
                               p_tipo_smistamento          VARCHAR2,
                               p_utente_presa_in_carico    VARCHAR2,
                               p_data_presa_in_carico      DATE,
                               p_utente_esecuzione         VARCHAR2,
                               p_data_esecuzione           DATE,
                               p_utente_assegnante         VARCHAR2,
                               p_utente_assegnatario       VARCHAR2,
                               p_data_assegnazione         DATE,
                               p_note                      VARCHAR2,
                               p_utente_inserimento        VARCHAR2,
                               p_data_inserimento          DATE,
                               p_utente_aggiornamento      VARCHAR2,
                               p_data_aggiornamento        VARCHAR2,
                               p_id_documento_esterno      NUMBER,
                               p_utente_rifiuto            VARCHAR2,
                               p_data_rifiuto              DATE,
                               p_motivo_rifiuto            VARCHAR2);

   PROCEDURE crea_titolario (p_id_documento            NUMBER,
                             p_id_classificazione      NUMBER,
                             p_id_fascicolo            NUMBER,
                             p_utente_inserimento      VARCHAR2,
                             p_data_inserimento        DATE,
                             p_utente_aggiornamento    VARCHAR2,
                             p_data_aggiornamento      DATE);

   FUNCTION get_url_protocollo (p_id_documento_gdm NUMBER)
      RETURN VARCHAR2;

   PROCEDURE elimina_documento (p_id_documento       NUMBER,
                                p_elimina_doc_gdm    NUMBER DEFAULT 1);

   PROCEDURE elimina_storico_documento (p_id_documento NUMBER);

   PROCEDURE crea_documento (
      p_id_documento_esterno          NUMBER,
      p_id_ente                       NUMBER,
      p_valido                        VARCHAR2,
      p_riservato                     VARCHAR2,
      p_utente_ins                    VARCHAR2,
      p_data_ins                      DATE,
      p_utente_upd                    VARCHAR2,
      p_data_upd                      DATE,
      p_stato                         VARCHAR2,
      p_tipo_oggetto                  VARCHAR2,
      p_stato_firma                   VARCHAR2,
      p_id_documento           IN OUT NUMBER,
      p_id_revisione           IN OUT NUMBER,
      p_crea_log                      BOOLEAN DEFAULT TRUE);

   FUNCTION crea_file_documento (p_id_documento       NUMBER,
                                 p_id_file_esterno    NUMBER,
                                 p_utente_ins         VARCHAR2,
                                 p_data_ins           DATE,
                                 p_utente_upd         VARCHAR2,
                                 p_data_upd           DATE,
                                 p_codice             VARCHAR2,
                                 p_filename           VARCHAR2,
                                 p_sequenza           NUMBER,
                                 p_firmato            VARCHAR2)
      RETURN NUMBER;

   FUNCTION crea_documento_soggetto (p_id_documento     NUMBER,
                                     p_tipo_soggetto    VARCHAR2,
                                     p_utente           VARCHAR2,
                                     p_progr_uo         NUMBER,
                                     p_dal_uo           DATE,
                                     p_ottica_uo        VARCHAR2,
                                     p_id_rev           NUMBER)
      RETURN NUMBER;

   PROCEDURE crea_protocollo (p_id_documento                   NUMBER,
                              p_anno                           NUMBER,
                              p_numero                         NUMBER,
                              p_tipo_registro                  VARCHAR2,
                              p_data                           DATE,
                              p_movimento                      VARCHAR2,
                              p_data_arrivo                    DATE,
                              p_data_redazione                 DATE,
                              p_oggetto                        VARCHAR2,
                              p_id_classificazione             NUMBER,
                              p_id_fascicolo                   NUMBER,
                              p_data_verifica                  DATE,
                              p_esito_verifica                 VARCHAR2,
                              p_codice_raccomandata            VARCHAR2,
                              p_data_documento                 DATE,
                              p_numero_documento               VARCHAR2,
                              p_id_schema_protocollo           NUMBER,
                              p_id_modalita_invio_ricezione    NUMBER,
                              p_stato_archivio                 VARCHAR2,
                              p_data_stato_archivio            DATE,
                              p_annullato                      VARCHAR2,
                              p_data_ann                       DATE,
                              p_utente_ann                     VARCHAR2,
                              p_provvedimento_ann              VARCHAR2,
                              p_note                           VARCHAR2,
                              p_id_tipo_protocollo             NUMBER,
                              p_controllo_funzionario          VARCHAR2,
                              p_controllo_firmatario           VARCHAR2,
                              p_idrif                          VARCHAR2,
                              p_id_doc_dati_scarto             NUMBER,
                              p_id_doc_dati_interop            NUMBER,
                              p_id_rev                         NUMBER);

   FUNCTION crea_protocollo_esterno (p_id_documento_esterno    NUMBER,
                                     p_id_ente                 NUMBER,
                                     p_valido                  VARCHAR2,
                                     p_riservato               VARCHAR2,
                                     p_id_tipo_protocollo      NUMBER,
                                     p_oggetto                 VARCHAR2,
                                     p_annullato               VARCHAR2,
                                     p_anno                    NUMBER,
                                     p_numero                  NUMBER,
                                     p_tipo_registro           VARCHAR2,
                                     p_data                    DATE,
                                     p_movimento               VARCHAR2,
                                     p_uo_protocollante        VARCHAR2,
                                     p_utente_protocollante    VARCHAR2,
                                     p_utente_ins              VARCHAR2,
                                     p_data_ins                DATE,
                                     p_utente_upd              VARCHAR2,
                                     p_data_upd                DATE)
      RETURN NUMBER;

   FUNCTION get_id_tipo_protocollo_default (p_categoria VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION crea_protocollo_agspr (
      p_id_documento_gdm      NUMBER,
      p_id_tipo_protocollo    NUMBER DEFAULT NULL,
      p_attiva_iter           NUMBER DEFAULT 0,
      p_trasco_storico        NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION crea_doc_titolario_agspr (p_id_documento_gdm          VARCHAR2,
                                      p_id_classificazione_gdm    VARCHAR2,
                                      p_id_fascicolo_gdm          VARCHAR2,
                                      p_utente                    VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE elimina_trasco_documento (p_id_documento NUMBER);

   PROCEDURE crea_trasco_scarico_ipa;

   FUNCTION crea_doc_da_fasc_agspr (p_id_documento_gdm    NUMBER)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_TRASCO_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_TRASCO_PKG
    DESCRIZIONE Gestione TRASCO da GDM.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   24/10/2018    mmalferrari   Prima emissione.
    001   24/09/2019    mmalferrari   Creata crea_memo_agspr
    002   07/01/2019    mmalferrari   Eliminata crea_memo_agspr e modificata
                                      crea_protocollo_agspr.
    003   17/01/2017    mmalferrari   Modificate:
                                      - crea_allegato per gestione sequenza (era
                                        sempre 1)
                                      - crea_corrispondente per gestione tipo_soggetto
                                        (se non presente in agp_tipi_soggetto mette
                                        tipo_soggetto = 1)
    004   21/01/2020    mmalferrari   Modificate:
                                      - elimina_documento: eliminato anche da
                                        gdo_documenti_firmatari
                                      - gestione rifiuto smistamento
    005   23/01/2020    mmalferrari   Modificata crea_corrispondente per gestione
                                      record in agp_messaggi_corrispondenti.
    006   24/01/2020    mmalferrari   Modificata crea_protocollo_agpr per gestione
                                      dimensione file.
    007   07/02/2020    mmalferrari   Modificata crea_file_documento per ignorare
                                      errori in calcolo dimensione file.
    008   02/03/2020    mmalferrari   Modificata crea_protocollo_agspr per gestire
                                      il caso che il campo destinatari di un messaggio
                                      sia vuoto.
    009   02/03/2020    mmalferrari   Modificata crea_revinfo e aggiunta del_revinfo.
    010   05/03/2020    mmalferrari   Modificata crea_allegato, crea_collegamento
                                      per gestione allegati cancellati.
    011   10/03/2020    mmalferrari   Creata elimina_storico_documento e modificata
                                      elimina_documento.
    012   26/03/2020    mmalferrari   Modificata crea_protocollo_agspr
    013   27/04/2020    mmalferrari   Creata elimina_trasco_documento
    014   25/05/2020    mmalferrari   Modificato parametro p_dal_tras di crea_smistamento
                                      da VARCHAR2 a DATE.
    015   25/06/2020    mmalferrari   Modificata elimina_storico_documento in modo
                                      che elimini da gdo_documenti_collegati solo
                                      gli allegati (che poi ricalcola)
    015   25/05/2020    svalenti      Creata crea_doc_titolario_agspr
    016   29/06/2020    mfrancesconi  Modificata crea_protocollo_agspr per gestire
                                      il caso che il cliente utilizzi ancora le pagine flex
    017   10/07/2020    mmalferrari   Modificate del_revinfo e crea_revinfo con
                                      chiamata a rispettive funzioni di revinfo_pkg
    018   16/07/2020    mmalferrari   Modificata crea_allegato per gestire substr
                                      della descrizione a 255
    019   31/08/2020    mmalferrari   Modificata crea_titolario per gestione
                                      AGP_DOCUMENTI_TITOLARIO_LOG.
    020   10/09/2020    mmalferrari   Modificata crea_documento_soggetto per gestione
                                      inserimento storico in gdo_documenti_soggetti.
    021   13/10/2020    mmalferrari   Modificata crea_protocollo_agspr per gestione
                                      separata trasco storico.
    022   15/10/2020    mmalferrari   Modificata crea_protocollo_agspr per correzione
                                      issue #45075: Visibilità pec a troppi utenti
                                      se c'è spazio nell'indirizzo destinatario
    023   16/10/2020    mfrancesconi  Creata crea_trasco_scarico_ipa
    024   20/10/2020    mmalferrari   Creata crea_doc_da_fasc_agspr
    025   26/10/2020    scaputo       Modificata crea_protocollo_agspr
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '025';

   CURSOR c_file_doc (
      p_id_documento    NUMBER)
   IS
      (SELECT o.id_oggetto_file,
              o.filename,
              NVL (l.utente_operazione, o.utente_aggiornamento) utente_ins,
              NVL (data_operazione, o.data_aggiornamento) data_ins,
              o.utente_aggiornamento utente_upd,
              o.data_aggiornamento data_upd
         FROM gdm_oggetti_file o, gdm_oggetti_file_log l
        WHERE     o.id_oggetto_file = l.id_oggetto_file(+)
              AND l.tipo_operazione(+) = 'C'
              AND o.id_documento = p_id_documento);

   CURSOR c_smistamenti (
      p_id_documento              NUMBER,
      p_idrif                     VARCHAR2,
      p_codice_amministrazione    VARCHAR2,
      p_codice_aoo                VARCHAR2)
   IS
      (SELECT s.*,
              d.utente_aggiornamento,
              d.data_aggiornamento,
              sd.utente_aggiornamento utente_inserimento,
              sd.data_aggiornamento data_inserimento,
              '' utente_rifiuto,
              TO_DATE ('') data_rifiuto,
              '' motivo_rifiuto
         FROM (SELECT ID_DOCUMENTO,
                      ANNO,
                      ASSEGNAZIONE_DAL,
                      ASSOCIATO_A_FLUSSO,
                      CODICE_AMMINISTRAZIONE,
                      CODICE_AOO,
                      CODICE_ASSEGNATARIO,
                      DATA,
                      DES_ASSEGNATARIO,
                      DES_UFFICIO_SMISTAMENTO,
                      DES_UFFICIO_TRASMISSIONE,
                      IDRIF,
                      NOTE,
                      NOTE_UTENTE,
                      NUMERO,
                      PRESA_IN_CARICO_DAL,
                      PRESA_IN_CARICO_UTENTE,
                      PROGRESSIVO,
                      SMISTAMENTO_DAL,
                      STATO_PR,
                      STATO_SMISTAMENTO,
                      TIPO_REGISTRO,
                      TIPO_SMISTAMENTO,
                      UFFICIO_SMISTAMENTO,
                      UFFICIO_TRASMISSIONE,
                      UTENTE_TRASMISSIONE,
                      KEY_ITER_SMISTAMENTO,
                      DATA_ESECUZIONE,
                      UTENTE_ESECUZIONE
                 FROM gdm_seg_smistamenti) s,
              gdm_documenti d,
              gdm_stati_documento sd
        WHERE     d.id_documento = s.id_documento
              AND idrif = p_idrif
              AND s.codice_amministrazione = p_codice_amministrazione
              AND s.codice_aoo = p_codice_aoo
              AND s.tipo_smistamento <> 'DUMMY'
              AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
              AND sd.id_stato IN (SELECT MIN (id_stato)
                                    FROM gdm_stati_documento
                                   WHERE id_documento = d.id_documento)
       UNION
       SELECT s.*,
              d.utente_aggiornamento,
              d.data_aggiornamento,
              sd.utente_aggiornamento utente_inserimento,
              sd.data_aggiornamento data_inserimento,
              d.utente_aggiornamento utente_rifiuto,
              dr.data_rifiuto,
              dr.motivo_rifiuto
         FROM (SELECT ID_DOCUMENTO,
                      ANNO,
                      ASSEGNAZIONE_DAL,
                      ASSOCIATO_A_FLUSSO,
                      CODICE_AMMINISTRAZIONE,
                      CODICE_AOO,
                      CODICE_ASSEGNATARIO,
                      DATA,
                      DES_ASSEGNATARIO,
                      DES_UFFICIO_SMISTAMENTO,
                      DES_UFFICIO_TRASMISSIONE,
                      IDRIF,
                      NOTE,
                      NOTE_UTENTE,
                      NUMERO,
                      PRESA_IN_CARICO_DAL,
                      PRESA_IN_CARICO_UTENTE,
                      PROGRESSIVO,
                      SMISTAMENTO_DAL,
                      STATO_PR,
                      STATO_SMISTAMENTO,
                      TIPO_REGISTRO,
                      TIPO_SMISTAMENTO,
                      UFFICIO_SMISTAMENTO,
                      UFFICIO_TRASMISSIONE,
                      UTENTE_TRASMISSIONE,
                      KEY_ITER_SMISTAMENTO,
                      DATA_ESECUZIONE,
                      UTENTE_ESECUZIONE
                 FROM gdm_seg_smistamenti) s,
              gdm_documenti d,
              gdm_stati_documento sd,
              temp_documenti_dati_rifiuto dr
        WHERE     d.id_documento = s.id_documento
              AND dr.id_documento_gdm = p_id_documento
              AND idrif = p_idrif
              AND s.codice_amministrazione = p_codice_amministrazione
              AND s.codice_aoo = p_codice_aoo
              AND s.tipo_smistamento <> 'DUMMY'
              AND d.stato_documento = 'CA'
              AND s.stato_smistamento = 'R'
              AND s.smistamento_dal = dr.data_smistamento
              AND sd.id_stato IN (SELECT MIN (id_stato)
                                    FROM gdm_stati_documento
                                   WHERE id_documento = d.id_documento));

   CURSOR c_allegati (
      p_idrif    VARCHAR2)
   IS
      SELECT s.*,
             DECODE (d.stato_documento, 'CA', 'N', 'Y') valido,
             sd.utente_aggiornamento utente_ins,
             sd.data_aggiornamento data_ins,
             d.utente_aggiornamento utente_upd,
             d.data_aggiornamento data_upd
        FROM gdm_seg_allegati_protocollo s,
             gdm_documenti d,
             gdm_stati_documento sd
       WHERE     d.id_documento = s.id_documento
             AND idrif = p_idrif
             AND d.id_documento = sd.id_documento
             AND sd.id_stato IN (SELECT MIN (id_stato)
                                   FROM gdm_stati_documento
                                  WHERE id_documento = d.id_documento);

   CURSOR c_file_alle (
      p_id_documento    NUMBER)
   IS
      SELECT o.id_oggetto_file,
             o.filename,
             NVL (l.utente_operazione, o.utente_aggiornamento) utente_ins,
             NVL (data_operazione, o.data_aggiornamento) data_ins,
             o.utente_aggiornamento utente_upd,
             o.data_aggiornamento data_upd
        FROM gdm_oggetti_file o, gdm_oggetti_file_log l
       WHERE     o.id_oggetto_file = l.id_oggetto_file(+)
             AND l.tipo_operazione(+) = 'C'
             AND id_documento = p_id_documento;

   CURSOR c_prec (
      p_id_documento    NUMBER,
      p_categoria       VARCHAR2)
   IS
      SELECT r.id_documento,
             r.tipo_relazione,
             r.data_aggiornamento data_agg_rif,
             r.utente_aggiornamento uten_agg_rif,
             prot.anno,
             prot.numero,
             prot.tipo_registro,
             prot.data,
             prot.oggetto,
             NVL (prot.annullato, 'N') annullato,
             prot.modalita,
             prot.unita_protocollante,
             prot.utente_protocollante,
             d.utente_aggiornamento,
             d.data_aggiornamento,
             0,
             NVL (prot.riservato, 'N') riservato,
             p_categoria
        FROM agp_proto_view prot, gdm_documenti d, gdm_riferimenti r
       WHERE     prot.id_documento = r.id_documento
             AND d.id_documento = prot.id_documento
             AND r.id_documento_rif = p_id_documento
             AND r.tipo_relazione = 'PROT_PREC';

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

   FUNCTION get_id_tipo_protocollo_default (p_categoria VARCHAR2)
      RETURN VARCHAR2
   IS
      d_id_tipo_prot   NUMBER;
   BEGIN
      SELECT id_tipo_documento
        INTO d_id_tipo_prot
        FROM agp_tipi_protocollo tp, gdo_tipi_documento td
       WHERE     categoria = p_categoria
             AND valido = 'Y'
             AND predefinito = 'Y'
             AND tp.id_tipo_protocollo = td.id_tipo_documento;

      RETURN d_id_tipo_prot;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            SELECT id_tipo_documento
              INTO d_id_tipo_prot
              FROM gdo_tipi_documento
             WHERE acronimo = 'def' || p_categoria AND valido = 'Y';

            RETURN d_id_tipo_prot;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               raise_application_error (
                  -20999,
                     'Impossibile determinare il flusso da associare al documento (non esiste nessun tipo protococollo valido con acronimo '
                  || p_categoria
                  || ''').');
         END;
   END;

   /* fine get_id_tipo_documento_default*/

   PROCEDURE calcola_unita (p_codice             VARCHAR2,
                            p_data               DATE,
                            p_progr_uo    IN OUT NUMBER,
                            p_dal_uo      IN OUT DATE,
                            p_ottica_uo   IN OUT VARCHAR2)
   IS
   BEGIN
      SELECT uopu.progr, uopu.dal, uopu.ottica
        INTO p_progr_uo, p_dal_uo, p_ottica_uo
        FROM so4_v_unita_organizzative_pubb uopu
       WHERE     uopu.codice = p_codice
             AND NVL (p_data, SYSDATE) BETWEEN uopu.dal
                                           AND NVL (uopu.al,
                                                    TO_DATE (3333333, 'j'))
             AND ROWNUM = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- se non trovo l'unità alla data di protocollo, provo ad oggi
         BEGIN
            SELECT uopu.progr, uopu.dal, uopu.ottica
              INTO p_progr_uo, p_dal_uo, p_ottica_uo
              FROM so4_v_unita_organizzative_pubb uopu
             WHERE     uopu.codice = p_codice
                   AND SYSDATE BETWEEN uopu.dal
                                   AND NVL (uopu.al, TO_DATE (3333333, 'j'))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               -- se non trovo l'unità nè alla data di protocollo nè ad oggi, ne
               -- prendo una a caso con quel codice
               BEGIN
                  SELECT uopu.progr, uopu.dal, uopu.ottica
                    INTO p_progr_uo, p_dal_uo, p_ottica_uo
                    FROM so4_v_unita_organizzative_pubb uopu
                   WHERE uopu.codice = p_codice AND ROWNUM = 1;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- se non trovo l'unità nè alla data di protocollo nè ad oggi, ne
                     -- prendo una a caso con codice TRASCO
                     BEGIN
                        SELECT uopu.progr, uopu.dal, uopu.ottica
                          INTO p_progr_uo, p_dal_uo, p_ottica_uo
                          FROM so4_v_unita_organizzative_pubb uopu
                         WHERE uopu.codice = 'TRASCO' AND ROWNUM = 1;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           RAISE_APPLICATION_ERROR (
                              -20999,
                                 'Unita'' '
                              || p_codice
                              || ' non trovata al '
                              || NVL (p_data, SYSDATE)
                              || '.');
                     END;
               END;
         END;
   END;

   /* fine calcola_unita*/

   FUNCTION crea_documento_soggetto (p_id_documento     NUMBER,
                                     p_tipo_soggetto    VARCHAR2,
                                     p_utente           VARCHAR2,
                                     p_progr_uo         NUMBER,
                                     p_dal_uo           DATE,
                                     p_ottica_uo        VARCHAR2,
                                     p_id_rev           NUMBER)
      RETURN NUMBER
   IS
      d_id_doc_sogg   NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id_doc_sogg FROM DUAL;

      INSERT INTO GDO_DOCUMENTI_SOGGETTI (ID_DOCUMENTO_SOGGETTO,
                                          VERSION,
                                          ATTIVO,
                                          ID_DOCUMENTO,
                                          SEQUENZA,
                                          TIPO_SOGGETTO,
                                          UTENTE,
                                          UNITA_PROGR,
                                          UNITA_DAL,
                                          UNITA_OTTICA)
           VALUES (d_id_doc_sogg,
                   0,
                   'Y',
                   p_id_documento,
                   0,
                   p_tipo_soggetto,
                   p_utente,
                   p_progr_uo,
                   p_dal_uo,
                   p_ottica_uo);

      INSERT INTO GDO_DOCUMENTI_SOGGETTI_LOG (ID_DOCUMENTO_SOGGETTO,
                                              ID_DOCUMENTO,
                                              REV,
                                              REVTYPE,
                                              VERSION,
                                              UTENTE,
                                              ATTIVO,
                                              TIPO_SOGGETTO,
                                              SEQUENZA,
                                              UNITA_PROGR,
                                              UNITA_DAL,
                                              UNITA_OTTICA)
           VALUES (d_id_doc_sogg,
                   p_id_documento,
                   p_id_rev,
                   0,
                   0,
                   p_utente,
                   'Y',
                   p_tipo_soggetto,
                   0,
                   p_progr_uo,
                   p_dal_uo,
                   p_ottica_uo);

      RETURN d_id_doc_sogg;
   END;

   /* fine crea_documento_soggetto*/

   FUNCTION crea_revinfo (p_data TIMESTAMP, p_rev NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
   BEGIN
      RETURN revinfo_pkg.crea_revinfo (p_data, p_rev);
   END;

   PROCEDURE del_revinfo (p_rev NUMBER)
   IS
   BEGIN
      revinfo_pkg.del_revinfo (p_rev);
   END;

   PROCEDURE crea_documento (p_id_documento_esterno          NUMBER,
                             p_id_ente                       NUMBER,
                             p_valido                        VARCHAR2,
                             p_riservato                     VARCHAR2,
                             p_utente_ins                    VARCHAR2,
                             p_data_ins                      DATE,
                             p_utente_upd                    VARCHAR2,
                             p_data_upd                      DATE,
                             p_stato                         VARCHAR2,
                             p_tipo_oggetto                  VARCHAR2,
                             p_stato_firma                   VARCHAR2,
                             p_id_documento           IN OUT NUMBER,
                             p_id_revisione           IN OUT NUMBER,
                             p_crea_log                      BOOLEAN)
   IS
   BEGIN
      BEGIN
         SELECT id_documento
           INTO p_id_documento
           FROM gdo_documenti d
          WHERE d.id_documento_esterno = p_id_documento_esterno;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            p_id_documento := NULL;
      END;

      IF p_id_documento IS NULL
      THEN
         --p_id_documento := hibernate_sequence.NEXTVAL;
         SELECT hibernate_sequence.NEXTVAL INTO p_id_documento FROM DUAL;

         INSERT INTO GDO_DOCUMENTI (ID_DOCUMENTO,
                                    ID_DOCUMENTO_ESTERNO,
                                    ID_ENTE,
                                    VALIDO,
                                    UTENTE_INS,
                                    DATA_INS,
                                    UTENTE_UPD,
                                    DATA_UPD,
                                    VERSION,
                                    RISERVATO,
                                    TIPO_OGGETTO)
              VALUES (p_id_documento,
                      p_id_documento_esterno,
                      p_id_ente,
                      p_VALIDO,
                      p_utente_ins,
                      p_data_ins,
                      p_utente_upd,
                      p_data_upd,
                      0,
                      NVL (p_riservato, 'N'),
                      p_tipo_oggetto);
      ELSE
         UPDATE GDO_DOCUMENTI
            SET STATO = p_stato,
                ID_ENTE = p_id_ente,
                TIPO_OGGETTO = p_tipo_oggetto,
                VALIDO = 'Y',
                UTENTE_INS = p_utente_ins,
                DATA_INS = p_data_ins,
                UTENTE_UPD = p_utente_upd,
                DATA_UPD = p_data_upd,
                RISERVATO = NVL (p_riservato, 'N'),
                STATO_FIRMA = p_stato_firma
          WHERE ID_DOCUMENTO = p_id_documento;

         IF p_id_revisione IS NULL
         THEN
            SELECT MAX (rev)
              INTO p_id_revisione
              FROM GDO_DOCUMENTI_LOG
             WHERE ID_DOCUMENTO = p_id_documento;
         END IF;
      END IF;

      IF p_crea_log AND p_id_revisione IS NULL
      THEN
         p_id_revisione :=
            crea_revinfo (
               TO_TIMESTAMP (p_data_upd, 'DD/MM/YYYY HH24:MI:SS,FF'));

         INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                        REV,
                                        REVTYPE,
                                        DATA_INS,
                                        DATE_CREATED_MOD,
                                        DATA_UPD,
                                        LAST_UPDATED_MOD,
                                        VALIDO,
                                        VALIDO_MOD,
                                        ID_DOCUMENTO_ESTERNO,
                                        ID_DOCUMENTO_ESTERNO_MOD,
                                        UTENTE_INS,
                                        UTENTE_INS_MOD,
                                        UTENTE_UPD,
                                        UTENTE_UPD_MOD,
                                        ID_ENTE,
                                        ENTE_MOD,
                                        DOCUMENTI_COLLEGATI_MOD,
                                        FILE_DOCUMENTI_MOD,
                                        ITER_MOD,
                                        TIPO_OGGETTO,
                                        TIPO_OGGETTO_MOD)
              VALUES (p_id_documento,
                      p_id_revisione,
                      0,
                      p_data_upd,
                      1,
                      p_data_upd,
                      1,
                      p_valido,
                      1,
                      p_id_documento_esterno,
                      1,
                      p_utente_ins,
                      1,
                      p_utente_upd,
                      1,
                      1,
                      1,
                      1,
                      0,
                      0,
                      p_tipo_oggetto,
                      0);
      END IF;
   END;


   PROCEDURE crea_protocollo (p_id_documento                   NUMBER,
                              p_anno                           NUMBER,
                              p_numero                         NUMBER,
                              p_tipo_registro                  VARCHAR2,
                              p_data                           DATE,
                              p_movimento                      VARCHAR2,
                              p_data_arrivo                    DATE,
                              p_data_redazione                 DATE,
                              p_oggetto                        VARCHAR2,
                              p_id_classificazione             NUMBER,
                              p_id_fascicolo                   NUMBER,
                              p_data_verifica                  DATE,
                              p_esito_verifica                 VARCHAR2,
                              p_codice_raccomandata            VARCHAR2,
                              p_data_documento                 DATE,
                              p_numero_documento               VARCHAR2,
                              p_id_schema_protocollo           NUMBER,
                              p_id_modalita_invio_ricezione    NUMBER,
                              p_stato_archivio                 VARCHAR2,
                              p_data_stato_archivio            DATE,
                              p_annullato                      VARCHAR2,
                              p_data_ann                       DATE,
                              p_utente_ann                     VARCHAR2,
                              p_provvedimento_ann              VARCHAR2,
                              p_note                           VARCHAR2,
                              p_id_tipo_protocollo             NUMBER,
                              p_controllo_funzionario          VARCHAR2,
                              p_controllo_firmatario           VARCHAR2,
                              p_idrif                          VARCHAR2,
                              p_id_doc_dati_scarto             NUMBER,
                              p_id_doc_dati_interop            NUMBER,
                              p_id_rev                         NUMBER)
   IS
      d_id_documento   NUMBER;
   BEGIN
      BEGIN
         SELECT id_documento
           INTO d_id_documento
           FROM agp_protocolli
          WHERE id_documento = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_documento := NULL;
      END;

      IF d_id_documento IS NULL
      THEN
         INSERT INTO AGP_PROTOCOLLI (ID_DOCUMENTO,
                                     ID_TIPO_PROTOCOLLO,
                                     MOVIMENTO,
                                     OGGETTO,
                                     CONTROLLO_FUNZIONARIO,
                                     IDRIF,
                                     ID_CLASSIFICAZIONE,
                                     ID_FASCICOLO,
                                     DATA_REDAZIONE,
                                     DATA_VERIFICA,
                                     ESITO_VERIFICA,
                                     ANNULLATO,
                                     NOTE,
                                     NOTE_TRASMISSIONE,
                                     ID_SCHEMA_PROTOCOLLO,
                                     ID_MODALITA_INVIO_RICEZIONE,
                                     DATA_ANNULLAMENTO,
                                     UTENTE_ANNULLAMENTO,
                                     PROVVEDIMENTO_ANNULLAMENTO,
                                     CONTROLLO_FIRMATARIO,
                                     ANNO,
                                     NUMERO,
                                     TIPO_REGISTRO,
                                     DATA,
                                     DATA_COMUNICAZIONE,
                                     DATA_DOCUMENTO_ESTERNO,
                                     NUMERO_DOCUMENTO_ESTERNO,
                                     STATO_ARCHIVIO,
                                     DATA_STATO_ARCHIVIO,
                                     CODICE_RACCOMANDATA,
                                     ID_PROTOCOLLO_DATI_SCARTO,
                                     ID_PROTOCOLLO_DATI_INTEROP)
              VALUES (p_id_documento,
                      p_id_tipo_protocollo,
                      p_movimento,
                      p_oggetto,
                      p_controllo_funzionario,
                      p_idrif,
                      p_id_classificazione,
                      p_id_fascicolo,
                      p_data_redazione,
                      p_data_verifica,
                      p_esito_verifica,
                      NVL (p_annullato, 'N'),
                      p_note,
                      NULL,
                      p_id_schema_protocollo,
                      p_id_modalita_invio_ricezione,
                      p_data_ann,
                      p_utente_ann,
                      p_provvedimento_ann,
                      p_controllo_firmatario,
                      p_anno,
                      p_numero,
                      p_tipo_registro,
                      p_data,
                      p_data_arrivo,
                      p_data_documento,
                      p_numero_documento,
                      p_stato_archivio,
                      p_data_stato_archivio,
                      p_codice_raccomandata,
                      p_id_doc_dati_scarto,
                      p_id_doc_dati_interop);

         IF p_id_rev IS NOT NULL
         THEN
            INSERT INTO AGP_PROTOCOLLI_LOG (ID_DOCUMENTO,
                                            REV,
                                            ANNO,
                                            ANNO_MOD,
                                            ANNULLATO,
                                            ANNULLATO_MOD,
                                            CODICE_RACCOMANDATA,
                                            CODICE_RACCOMANDATA_MOD,
                                            CONTROLLO_FIRMATARIO,
                                            CONTROLLO_FIRMATARIO_MOD,
                                            CONTROLLO_FUNZIONARIO,
                                            CONTROLLO_FUNZIONARIO_MOD,
                                            DATA,
                                            DATA_MOD,
                                            DATA_ANNULLAMENTO,
                                            DATA_ANNULLAMENTO_MOD,
                                            DATA_COMUNICAZIONE,
                                            DATA_COMUNICAZIONE_MOD,
                                            DATA_DOCUMENTO_ESTERNO,
                                            DATA_DOCUMENTO_ESTERNO_MOD,
                                            DATA_REDAZIONE,
                                            DATA_REDAZIONE_MOD,
                                            DATA_STATO_ARCHIVIO,
                                            DATA_STATO_ARCHIVIO_MOD,
                                            DATA_VERIFICA,
                                            DATA_VERIFICA_MOD,
                                            ESITO_VERIFICA,
                                            ESITO_VERIFICA_MOD,
                                            IDRIF,
                                            IDRIF_MOD,
                                            MOVIMENTO,
                                            MOVIMENTO_MOD,
                                            NOTE,
                                            NOTE_MOD,
                                            NOTE_TRASMISSIONE,
                                            NOTE_TRASMISSIONE_MOD,
                                            NUMERO,
                                            NUMERO_MOD,
                                            NUMERO_DOCUMENTO_ESTERNO,
                                            NUMERO_DOCUMENTO_ESTERNO_MOD,
                                            NUMERO_EMERGENZA,
                                            NUMERO_EMERGENZA_MOD,
                                            OGGETTO,
                                            OGGETTO_MOD,
                                            PROVVEDIMENTO_ANNULLAMENTO,
                                            PROVVEDIMENTO_ANNULLAMENTO_MOD,
                                            REGISTRO_EMERGENZA,
                                            REGISTRO_EMERGENZA_MOD,
                                            STATO_ARCHIVIO,
                                            STATO_ARCHIVIO_MOD,
                                            ID_CLASSIFICAZIONE,
                                            CLASSIFICAZIONE_MOD,
                                            ID_PROTOCOLLO_DATI_INTEROP,
                                            DATI_INTEROPERABILITA_MOD,
                                            ID_PROTOCOLLO_DATI_SCARTO,
                                            DATI_SCARTO_MOD,
                                            ID_FASCICOLO,
                                            FASCICOLO_MOD,
                                            ID_MODALITA_INVIO_RICEZIONE,
                                            MODALITA_INVIO_RICEZIONE_MOD,
                                            ID_SCHEMA_PROTOCOLLO,
                                            SCHEMA_PROTOCOLLO_MOD,
                                            ID_TIPO_PROTOCOLLO,
                                            TIPO_PROTOCOLLO_MOD,
                                            TIPO_REGISTRO,
                                            TIPO_REGISTRO_MOD,
                                            UTENTE_ANNULLAMENTO,
                                            UTENTE_ANNULLAMENTO_MOD)
                 VALUES (p_id_documento,
                         p_id_rev,
                         p_anno,
                         DECODE (p_anno, NULL, 0, 1),
                         NVL (p_annullato, 'N'),
                         1,
                         p_codice_raccomandata,
                         DECODE (p_codice_raccomandata, NULL, 0, 1),
                         p_controllo_firmatario,
                         DECODE (p_controllo_firmatario, NULL, 0, 1),
                         p_controllo_funzionario,
                         DECODE (p_controllo_funzionario, NULL, 0, 1),
                         p_data,
                         DECODE (p_data, NULL, 0, 1),
                         p_data_ann,
                         DECODE (p_data_ann, NULL, 0, 1),
                         p_data_arrivo,
                         DECODE (p_data_arrivo, NULL, 0, 1),
                         p_data_documento,
                         DECODE (p_data_documento, NULL, 0, 1),
                         p_data_redazione,
                         DECODE (p_data_redazione, NULL, 0, 1),
                         p_data_stato_archivio,
                         DECODE (p_data_stato_archivio, NULL, 0, 1),
                         p_data_verifica,
                         DECODE (p_data_verifica, NULL, 0, 1),
                         p_esito_verifica,
                         DECODE (p_esito_verifica, NULL, 0, 1),
                         p_idrif,
                         DECODE (p_idrif, NULL, 0, 1),
                         p_movimento,
                         DECODE (p_movimento, NULL, 0, 1),
                         p_note,
                         DECODE (p_note, NULL, 0, 1),
                         NULL,
                         0,
                         p_numero,
                         DECODE (p_numero, NULL, 0, 1),
                         p_numero_documento,
                         DECODE (p_numero_documento, NULL, 0, 1),
                         NULL,
                         0,
                         p_oggetto,
                         DECODE (p_oggetto, NULL, 0, 1),
                         p_provvedimento_ann,
                         DECODE (p_provvedimento_ann, NULL, 0, 1),
                         NULL,
                         0,
                         p_stato_archivio,
                         DECODE (p_stato_archivio, NULL, 0, 1),
                         p_id_classificazione,
                         DECODE (p_id_classificazione, NULL, 0, 1),
                         p_id_doc_dati_interop,
                         DECODE (p_id_doc_dati_interop, NULL, 0, 1),
                         p_id_doc_dati_scarto,
                         DECODE (p_id_doc_dati_scarto, NULL, 0, 1),
                         p_id_fascicolo,
                         DECODE (p_id_fascicolo, NULL, 0, 1),
                         p_id_modalita_invio_ricezione,
                         DECODE (p_id_modalita_invio_ricezione, NULL, 0, 1),
                         p_id_schema_protocollo,
                         DECODE (p_id_schema_protocollo, NULL, 0, 1),
                         p_id_tipo_protocollo,
                         DECODE (p_id_tipo_protocollo, NULL, 0, 1),
                         p_tipo_registro,
                         DECODE (p_tipo_registro, NULL, 0, 1),
                         p_utente_ann,
                         DECODE (p_utente_ann, NULL, 0, 1));
         END IF;
      ELSE
         UPDATE AGP_PROTOCOLLI
            SET ID_TIPO_PROTOCOLLO = p_id_tipo_protocollo,
                MOVIMENTO = p_movimento,
                OGGETTO = p_oggetto,
                CONTROLLO_FUNZIONARIO = p_controllo_funzionario,
                IDRIF = p_idrif,
                ID_CLASSIFICAZIONE = p_id_classificazione,
                ID_FASCICOLO = p_id_fascicolo,
                DATA_REDAZIONE = p_data_redazione,
                DATA_VERIFICA = p_data_verifica,
                ESITO_VERIFICA = p_esito_verifica,
                ANNULLATO = NVL (p_annullato, 'N'),
                NOTE = p_note,
                ID_SCHEMA_PROTOCOLLO = p_id_schema_protocollo,
                ID_MODALITA_INVIO_RICEZIONE = p_id_modalita_invio_ricezione,
                DATA_ANNULLAMENTO = p_data_ann,
                UTENTE_ANNULLAMENTO = p_utente_ann,
                PROVVEDIMENTO_ANNULLAMENTO = p_provvedimento_ann,
                CONTROLLO_FIRMATARIO = p_controllo_firmatario,
                ANNO = p_anno,
                NUMERO = p_numero,
                TIPO_REGISTRO = p_tipo_registro,
                DATA = p_data,
                DATA_COMUNICAZIONE = p_data_arrivo,
                DATA_DOCUMENTO_ESTERNO = p_data_documento,
                NUMERO_DOCUMENTO_ESTERNO = p_numero_documento,
                STATO_ARCHIVIO = p_stato_archivio,
                DATA_STATO_ARCHIVIO = p_data_stato_archivio,
                CODICE_RACCOMANDATA = p_codice_raccomandata,
                ID_PROTOCOLLO_DATI_SCARTO = p_id_doc_dati_scarto,
                ID_PROTOCOLLO_DATI_INTEROP = p_id_doc_dati_interop
          WHERE id_documento = d_id_documento;

         UPDATE AGP_PROTOCOLLI_LOG
            SET DATA = p_data, DATA_MOD = 1
          WHERE ID_DOCUMENTO = d_id_documento AND anno IS NOT NULL;
      END IF;
   END;

   FUNCTION crea_protocollo_esterno (p_id_documento_esterno    NUMBER,
                                     p_id_ente                 NUMBER,
                                     p_valido                  VARCHAR2,
                                     p_riservato               VARCHAR2,
                                     p_id_tipo_protocollo      NUMBER,
                                     p_oggetto                 VARCHAR2,
                                     p_annullato               VARCHAR2,
                                     p_anno                    NUMBER,
                                     p_numero                  NUMBER,
                                     p_tipo_registro           VARCHAR2,
                                     p_data                    DATE,
                                     p_movimento               VARCHAR2,
                                     p_uo_protocollante        VARCHAR2,
                                     p_utente_protocollante    VARCHAR2,
                                     p_utente_ins              VARCHAR2,
                                     p_data_ins                DATE,
                                     p_utente_upd              VARCHAR2,
                                     p_data_upd                DATE)
      RETURN NUMBER
   IS
      d_id_doc      NUMBER;
      d_id_rev      NUMBER;

      d_progr_uo    NUMBER;
      d_dal_uo      DATE;
      d_ottica_uo   VARCHAR2 (100);

      d_movimento   VARCHAR2 (255);
   BEGIN
      CREA_DOCUMENTO (P_ID_DOCUMENTO_ESTERNO,
                      p_id_ente,
                      p_valido,
                      P_RISERVATO,
                      p_utente_ins,
                      p_data_ins,
                      p_utente_upd,
                      p_data_upd,
                      NULL,
                      NULL,
                      NULL,
                      d_id_doc,
                      d_id_rev);

      /******************************************
              UO PROTOCOLLANTE
      ******************************************/
      IF p_uo_protocollante IS NOT NULL
      THEN
         DECLARE
            d_id_doc_sogg   NUMBER;
         BEGIN
            calcola_unita (p_uo_protocollante,
                           p_data_ins,
                           d_progr_uo,
                           d_dal_uo,
                           d_ottica_uo);
            d_id_doc_sogg :=
               crea_documento_soggetto (d_id_doc,
                                        'UO_PROTOCOLLANTE',
                                        '',
                                        d_progr_uo,
                                        d_dal_uo,
                                        d_ottica_uo,
                                        d_id_rev);
         END;
      END IF;

      /******************************************
              REDATTORE / PROTOCOLLANTE
      ******************************************/
      IF p_utente_protocollante IS NOT NULL
      THEN
         DECLARE
            d_id_doc_sogg   NUMBER;
         BEGIN
            d_id_doc_sogg :=
               crea_documento_soggetto (d_id_doc,
                                        'REDATTORE',
                                        p_utente_protocollante,
                                        d_progr_uo,
                                        d_dal_uo,
                                        d_ottica_uo,
                                        d_id_rev);
         END;
      END IF;


      IF p_movimento = 'INT'
      THEN
         d_movimento := 'INTERNO';
      ELSIF p_movimento = 'ARR'
      THEN
         d_movimento := 'ARRIVO';
      ELSIF p_movimento = 'PAR'
      THEN
         d_movimento := 'PARTENZA';
      END IF;

      crea_protocollo (d_id_doc,
                       p_anno,
                       p_numero,
                       p_tipo_registro,
                       p_data,
                       d_movimento,
                       NULL,
                       NULL,
                       p_oggetto,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       p_annullato,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       p_id_tipo_protocollo,
                       'N',
                       'N',
                       NULL,
                       NULL,
                       NULL,
                       d_id_rev);
      RETURN d_id_doc;
   END;

   PROCEDURE calcola_titolario (p_class_cod                   VARCHAR2,
                                p_class_dal                   DATE,
                                p_fascicolo_anno              NUMBER,
                                p_fascicolo_numero            VARCHAR2,
                                p_id_ente                     NUMBER,
                                p_id_classificazione   IN OUT NUMBER,
                                p_id_fascicolo         IN OUT NUMBER)
   IS
   BEGIN
      IF NVL (p_fascicolo_anno, 0) > 0
      THEN
         BEGIN
            SELECT f.id_classificazione, f.id_documento
              INTO p_id_classificazione, p_id_fascicolo
              FROM ags_fascicoli f, gdo_documenti d, ags_classificazioni c
             WHERE     d.id_documento = f.id_documento
                   AND c.id_classificazione = f.id_classificazione
                   AND classificazione = p_class_cod
                   AND classificazione_dal = p_class_dal
                   AND anno = p_fascicolo_anno
                   AND numero = p_fascicolo_numero
                   AND d.id_ente = p_id_ente;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;

               RAISE_APPLICATION_ERROR (
                  -20999,
                     'Errore in selezione fascicolo '
                  || p_class_cod
                  || ' del '
                  || p_class_dal
                  || ' '
                  || p_fascicolo_anno
                  || '/'
                  || p_fascicolo_numero
                  || ' per ente '
                  || p_id_ente
                  || ' '
                  || SQLERRM);
         END;
      ELSE
         IF p_class_cod IS NOT NULL
         THEN
            BEGIN
               SELECT id_classificazione
                 INTO p_id_classificazione
                 FROM ags_classificazioni
                WHERE     classificazione = p_class_cod
                      AND classificazione_dal = p_class_dal
                      AND id_ente = p_id_ente;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
                  RAISE_APPLICATION_ERROR (
                     -20999,
                        'Errore in selezione classifica '
                     || p_class_cod
                     || ' del '
                     || p_class_dal
                     || ' per ente '
                     || p_id_ente
                     || ' '
                     || SQLERRM);
            END;
         END IF;
      END IF;
   END;

   /* fine calcola_titolario*/

   FUNCTION crea_file_documento (p_id_documento       NUMBER,
                                 p_id_file_esterno    NUMBER,
                                 p_utente_ins         VARCHAR2,
                                 p_data_ins           DATE,
                                 p_utente_upd         VARCHAR2,
                                 p_data_upd           DATE,
                                 p_codice             VARCHAR2,
                                 p_filename           VARCHAR2,
                                 p_sequenza           NUMBER,
                                 p_firmato            VARCHAR2)
      RETURN NUMBER
   IS
      d_id_file_doc    NUMBER;
      d_id_revisione   NUMBER;
      d_dimensione     NUMBER;
   BEGIN
      d_dimensione := gdm_ag_oggetti_file.get_len (p_id_file_esterno);

      SELECT hibernate_sequence.NEXTVAL INTO d_id_file_doc FROM DUAL;

      INSERT INTO GDO_FILE_DOCUMENTO (ID_FILE_DOCUMENTO,
                                      ID_DOCUMENTO,
                                      UTENTE_INS,
                                      DATA_INS,
                                      UTENTE_UPD,
                                      DATA_UPD,
                                      VERSION,
                                      CONTENT_TYPE,
                                      CODICE,
                                      DIMENSIONE,
                                      FIRMATO,
                                      MODIFICABILE,
                                      NOME,
                                      VALIDO,
                                      ID_MODELLO_TESTO,
                                      SEQUENZA,
                                      ID_FILE_ESTERNO,
                                      TESTO,
                                      ID_FILE_DOCUMENTO_STORICO,
                                      REVISIONE_STORICO,
                                      FILE_ORIGINALE_ID,
                                      MARCATO)
              VALUES (
                        d_id_file_doc,
                        p_id_documento,
                        p_utente_ins,
                        p_data_ins,
                        p_utente_upd,
                        p_data_upd,
                        d_dimensione,
                        'application/octet-stream',
                        p_codice,
                        0,
                        NVL (
                           p_firmato,
                           DECODE (
                              UPPER (NVL (SUBSTR (p_filename, -4), 'NO')),
                              '.P7M', 'Y',
                              'N')),
                        'Y',
                        p_filename,
                        'Y',
                        NULL,
                        p_sequenza,
                        p_id_file_esterno,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        'N');

      d_id_revisione :=
         crea_revinfo (TO_TIMESTAMP (p_data_upd, 'DD/MM/YYYY HH24:MI:SS,FF'));

      INSERT INTO GDO_FILE_DOCUMENTO_LOG (ID_FILE_DOCUMENTO,
                                          REV,
                                          DATA_INS,
                                          DATE_CREATED_MOD,
                                          DATA_UPD,
                                          LAST_UPDATED_MOD,
                                          VALIDO,
                                          VALIDO_MOD,
                                          CODICE,
                                          CODICE_MOD,
                                          CONTENT_TYPE,
                                          CONTENT_TYPE_MOD,
                                          DIMENSIONE,
                                          DIMENSIONE_MOD,
                                          FIRMATO,
                                          FIRMATO_MOD,
                                          ID_FILE_ESTERNO,
                                          ID_FILE_ESTERNO_MOD,
                                          MARCATO,
                                          MARCATO_MOD,
                                          MODIFICABILE,
                                          MODIFICABILE_MOD,
                                          NOME,
                                          NOME_MOD,
                                          SEQUENZA,
                                          SEQUENZA_MOD,
                                          UTENTE_INS,
                                          UTENTE_INS_MOD,
                                          UTENTE_UPD,
                                          UTENTE_UPD_MOD,
                                          ID_DOCUMENTO,
                                          DOCUMENTO_MOD)
              VALUES (
                        d_id_file_doc,
                        d_id_revisione,
                        NVL (p_data_ins, SYSDATE),
                        1,
                        NVL (p_data_upd, SYSDATE),
                        1,
                        'Y',
                        1,
                        p_codice,
                        DECODE (p_codice, NULL, 0, 1),
                        'application/octet-stream',
                        1,
                        0,
                        1,
                        DECODE (UPPER (NVL (SUBSTR (p_filename, -4), 'NO')),
                                '.P7M', 'Y',
                                'N'),
                        1,
                        p_id_file_esterno,
                        1,
                        'N',
                        1,
                        'Y',
                        1,
                        p_filename,
                        1,
                        p_sequenza,
                        DECODE (p_sequenza, NULL, 0, 1),
                        NVL (p_utente_ins, 'RPI'),
                        1,
                        NVL (p_utente_upd, 'RPI'),
                        1,
                        p_id_documento,
                        1);

      RETURN d_id_file_doc;
   END;

   /* fine crea_file_documento*/

   PROCEDURE crea_smistamento (p_id_documento              NUMBER,
                               p_progr_tras                NUMBER,
                               p_dal_tras                  DATE,
                               p_ottica_tras               VARCHAR2,
                               p_utente_trasmissione       VARCHAR2,
                               p_progr_smis                NUMBER,
                               p_dal_smis                  DATE,
                               p_ottica_smis               VARCHAR2,
                               p_smistamento_dal           DATE,
                               p_stato_smistamento         VARCHAR2,
                               p_tipo_smistamento          VARCHAR2,
                               p_utente_presa_in_carico    VARCHAR2,
                               p_data_presa_in_carico      DATE,
                               p_utente_esecuzione         VARCHAR2,
                               p_data_esecuzione           DATE,
                               p_utente_assegnante         VARCHAR2,
                               p_utente_assegnatario       VARCHAR2,
                               p_data_assegnazione         DATE,
                               p_note                      VARCHAR2,
                               p_utente_inserimento        VARCHAR2,
                               p_data_inserimento          DATE,
                               p_utente_aggiornamento      VARCHAR2,
                               p_data_aggiornamento        VARCHAR2,
                               p_id_documento_esterno      NUMBER,
                               p_utente_rifiuto            VARCHAR2,
                               p_data_rifiuto              DATE,
                               p_motivo_rifiuto            VARCHAR2)
   IS
      d_id_doc_smist   NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id_doc_smist FROM DUAL;

      INSERT INTO AGP_DOCUMENTI_SMISTAMENTI (ID_DOCUMENTO_SMISTAMENTO,
                                             ID_DOCUMENTO,
                                             UNITA_TRASMISSIONE_PROGR,
                                             UNITA_TRASMISSIONE_DAL,
                                             UNITA_TRASMISSIONE_OTTICA,
                                             UTENTE_TRASMISSIONE,
                                             UNITA_SMISTAMENTO_PROGR,
                                             UNITA_SMISTAMENTO_DAL,
                                             UNITA_SMISTAMENTO_OTTICA,
                                             DATA_SMISTAMENTO,
                                             STATO_SMISTAMENTO,
                                             TIPO_SMISTAMENTO,
                                             UTENTE_PRESA_IN_CARICO,
                                             DATA_PRESA_IN_CARICO,
                                             UTENTE_ESECUZIONE,
                                             DATA_ESECUZIONE,
                                             UTENTE_ASSEGNANTE,
                                             UTENTE_ASSEGNATARIO,
                                             DATA_ASSEGNAZIONE,
                                             NOTE,
                                             NOTE_UTENTE,
                                             VERSION,
                                             VALIDO,
                                             UTENTE_INS,
                                             DATA_INS,
                                             UTENTE_UPD,
                                             DATA_UPD,
                                             ID_DOCUMENTO_ESTERNO,
                                             UTENTE_RIFIUTO,
                                             DATA_RIFIUTO,
                                             MOTIVO_RIFIUTO)
           VALUES (d_id_doc_smist,
                   p_id_documento,
                   p_progr_tras,
                   p_dal_tras,
                   p_ottica_tras,
                   p_utente_trasmissione,
                   p_progr_smis,
                   p_dal_smis,
                   p_ottica_smis,
                   p_smistamento_dal,
                   p_stato_smistamento,
                   p_tipo_smistamento,
                   p_utente_presa_in_carico,
                   p_data_presa_in_carico,
                   p_utente_esecuzione,
                   p_data_esecuzione,
                   p_utente_assegnante,
                   p_utente_assegnatario,
                   p_data_assegnazione,
                   p_note,
                   NULL                                      /* NOTE_UTENTE */
                       ,
                   0                                             /* VERSION */
                    ,
                   'Y'                                            /* VALIDO */
                      ,
                   p_utente_inserimento,
                   p_data_inserimento,
                   p_utente_aggiornamento,
                   p_data_aggiornamento,
                   p_id_documento_esterno,
                   p_utente_rifiuto,
                   p_data_rifiuto,
                   p_motivo_rifiuto);
   END;

   /* fine crea_smistamento*/

   FUNCTION crea_allegato (p_id_documento_esterno    NUMBER,
                           p_id_ente                 NUMBER,
                           p_descrizione             VARCHAR2,
                           p_numero_pag              VARCHAR2,
                           p_quantita                NUMBER,
                           p_origine                 VARCHAR2,
                           p_ubicazione              VARCHAR2,
                           p_id_tipo_allegato        NUMBER,
                           p_riservato               VARCHAR2,
                           p_sequenza                NUMBER,
                           p_stato                   VARCHAR2,
                           p_valido                  VARCHAR2,
                           p_utente_ins              VARCHAR2,
                           p_data_ins                DATE,
                           p_utente_upd              VARCHAR2,
                           p_data_upd                DATE)
      RETURN NUMBER
   IS
      d_id_alle            NUMBER;
      d_id_revisione       NUMBER;
      d_id_tipo_allegato   NUMBER;
   BEGIN
      crea_documento (p_id_documento_esterno,
                      p_id_ente,
                      p_valido,
                      p_riservato,
                      p_utente_ins,
                      p_data_ins,
                      p_utente_upd,
                      p_data_upd,
                      NULL,
                      '',
                      p_stato,
                      d_id_alle,
                      d_id_revisione);

      INSERT INTO GDO_ALLEGATI (ID_DOCUMENTO,
                                COMMENTO,
                                DESCRIZIONE,
                                NUM_PAGINE,
                                ORIGINE,
                                QUANTITA,
                                SEQUENZA,
                                STAMPA_UNICA,
                                UBICAZIONE,
                                ID_TIPO_ALLEGATO)
           VALUES (d_id_alle,
                   p_descrizione,
                   SUBSTR (p_descrizione, 1, 255),
                   p_numero_pag,
                   p_origine,
                   p_quantita,
                   p_sequenza,
                   'Y',                                     /* STAMPA_UNICA */
                   p_ubicazione,
                   p_id_tipo_allegato);

      INSERT INTO GDO_ALLEGATI_LOG (ID_DOCUMENTO,
                                    REV,
                                    COMMENTO,
                                    COMMENTO_MOD,
                                    DESCRIZIONE,
                                    DESCRIZIONE_MOD,
                                    NUM_PAGINE,
                                    NUM_PAGINE_MOD,
                                    ORIGINE,
                                    ORIGINE_MOD,
                                    QUANTITA,
                                    QUANTITA_MOD,
                                    SEQUENZA,
                                    SEQUENZA_MOD,
                                    STAMPA_UNICA,
                                    STAMPA_UNICA_MOD,
                                    UBICAZIONE,
                                    UBICAZIONE_MOD,
                                    ID_TIPO_ALLEGATO,
                                    TIPO_ALLEGATO_MOD)
           VALUES (d_id_alle,
                   d_id_revisione,
                   p_descrizione,
                   DECODE (p_descrizione, NULL, 0, 1),
                   SUBSTR (p_descrizione, 1, 255),
                   DECODE (p_descrizione, NULL, 0, 1),
                   p_numero_pag,
                   DECODE (p_numero_pag, NULL, 0, 1),
                   p_origine,
                   DECODE (p_origine, NULL, 0, 1),
                   p_quantita,
                   DECODE (p_quantita, NULL, 0, 1),
                   1,
                   1,
                   'Y',
                   1,
                   p_ubicazione,
                   DECODE (p_ubicazione, NULL, 0, 1),
                   p_id_tipo_allegato,
                   DECODE (p_id_tipo_allegato, NULL, 0, 1));

      RETURN d_id_alle;
   END;

   /* fine crea_allegato*/

   PROCEDURE crea_titolario (p_id_documento            NUMBER,
                             p_id_classificazione      NUMBER,
                             p_id_fascicolo            NUMBER,
                             p_utente_inserimento      VARCHAR2,
                             p_data_inserimento        DATE,
                             p_utente_aggiornamento    VARCHAR2,
                             p_data_aggiornamento      DATE)
   IS
      d_id_tito   NUMBER;
      d_rev       NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id_tito FROM DUAL;

      INSERT INTO AGP_DOCUMENTI_TITOLARIO (ID_DOCUMENTO_TITOLARIO,
                                           ID_DOCUMENTO,
                                           ID_CLASSIFICAZIONE,
                                           ID_FASCICOLO,
                                           VERSION,
                                           VALIDO,
                                           UTENTE_INS,
                                           DATA_INS,
                                           UTENTE_UPD,
                                           DATA_UPD)
           VALUES (d_id_tito,
                   p_id_documento,
                   p_ID_CLASSIFICAZIONE,
                   p_ID_FASCICOLO,
                   0                                             /* VERSION */
                    ,
                   'Y'                                            /* VALIDO */
                      ,
                   p_utente_inserimento,
                   p_data_inserimento,
                   p_utente_aggiornamento,
                   p_data_aggiornamento);

      d_rev :=
         REVINFO_PKG.CREA_REVINFO (NVL (p_data_inserimento, SYSTIMESTAMP));

      INSERT INTO AGP_DOCUMENTI_TITOLARIO_LOG (ID_DOCUMENTO_TITOLARIO,
                                               REV,
                                               REVTYPE,
                                               ID_DOCUMENTO,
                                               ID_CLASSIFICAZIONE,
                                               ID_FASCICOLO,
                                               VALIDO,
                                               UTENTE_INS,
                                               DATA_INS,
                                               UTENTE_UPD,
                                               DATA_UPD)
           VALUES (d_id_tito,
                   d_rev,
                   0,
                   p_id_documento,
                   p_ID_CLASSIFICAZIONE,
                   p_ID_FASCICOLO,
                   'Y'                                            /* VALIDO */
                      ,
                   p_utente_inserimento,
                   p_data_inserimento,
                   p_utente_aggiornamento,
                   p_data_aggiornamento);
   END;

   /* fine crea_titolario*/

   PROCEDURE crea_collegamento (p_id_documento         NUMBER,
                                p_id_collegato         NUMBER,
                                p_tipo_collegamento    VARCHAR2,
                                p_valido               VARCHAR2,
                                p_data_ins             DATE,
                                p_data_upd             DATE,
                                p_utente_ins           VARCHAR2,
                                p_utente_upd           VARCHAR2)
   IS
      d_id_colle        NUMBER;
      d_id_tipo_colle   NUMBER;
      d_id_revisione    NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id_colle FROM DUAL;

      SELECT id_tipo_collegamento
        INTO d_id_tipo_colle
        FROM GDO_TIPI_COLLEGAMENTO
       WHERE tipo_collegamento = p_tipo_collegamento;

      INSERT INTO GDO_DOCUMENTI_COLLEGATI (ID_DOCUMENTO_COLLEGATO,
                                           ID_DOCUMENTO,
                                           ID_COLLEGATO,
                                           ID_TIPO_COLLEGAMENTO,
                                           VALIDO,
                                           VERSION,
                                           DATA_INS,
                                           DATA_UPD,
                                           UTENTE_INS,
                                           UTENTE_UPD)
           VALUES (d_id_colle,
                   p_id_documento,
                   p_id_collegato,
                   d_id_tipo_colle,
                   p_valido,
                   0,
                   p_data_ins,
                   p_data_upd,
                   p_utente_ins,
                   p_utente_upd);

      d_id_revisione :=
         crea_revinfo (
            TO_TIMESTAMP (NVL (p_data_upd, p_data_ins),
                          'DD/MM/YYYY HH24:MI:SS,FF'));

      INSERT INTO GDO_DOCUMENTI_COLLEGATI_LOG (ID_DOCUMENTO_COLLEGATO,
                                               REV,
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
           VALUES (d_id_colle,
                   d_id_revisione,
                   p_data_ins,
                   DECODE (p_data_ins, NULL, 0, 1),
                   p_data_upd,
                   DECODE (p_data_upd, NULL, 0, 1),
                   'Y',
                   1,
                   p_utente_ins,
                   DECODE (p_utente_ins, NULL, 0, 1),
                   p_utente_upd,
                   DECODE (p_utente_upd, NULL, 0, 1),
                   p_id_collegato,
                   DECODE (p_id_collegato, NULL, 0, 1),
                   p_id_documento,
                   DECODE (p_id_documento, NULL, 0, 1),
                   d_id_tipo_colle,
                   DECODE (d_id_tipo_colle, NULL, 0, 1));
   END;

   FUNCTION get_firmatario (p_categoria    VARCHAR2,
                            p_ottica_uo    VARCHAR2,
                            p_progr_uo     NUMBER,
                            p_dal_uo       DATE)
      RETURN VARCHAR2
   IS
      d_utente_firmatario    VARCHAR2 (250);
      d_temp                 VARCHAR2 (200);
      d_startpos             NUMBER;
      d_stoppos              NUMBER;
      d_codice_unita_padre   VARCHAR2 (100);
   BEGIN
      -- il calcolo del responsabile serve solo per la lettera
      IF p_categoria = 'LETTERA'
      THEN
         BEGIN
            SELECT S.UTENTE utente_firmatario
              INTO d_utente_firmatario
              FROM so4_v_componenti_pubb c,
                   so4_v_unita_organizzative_pubb u,
                   as4_v_soggetti s
             WHERE     c.dal <= SYSDATE
                   AND (c.al IS NULL OR c.al >= SYSDATE)
                   AND c.ottica = u.ottica
                   AND C.PROGR_UNITA = U.PROGR
                   AND U.OTTICA = p_ottica_uo
                   AND u.PROGR = p_progr_uo
                   AND u.dal = p_dal_uo
                   AND s.dal <= SYSDATE
                   AND (s.al IS NULL OR s.al >= SYSDATE)
                   AND S.NI = c.id_soggetto
                   AND EXISTS
                          (SELECT 1
                             FROM SO4_V_RUOLI_COMPONENTE_PUBB rc
                            WHERE     RC.ID_COMPONENTE = c.id_componente
                                  AND rc.dal <= SYSDATE
                                  AND rc.ruolo =
                                         NVL (
                                            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                                               'RUOLO RESPONSABILE',
                                               1),
                                            'AGPRESP')
                                  AND (rc.al IS NULL OR rc.al >= SYSDATE))
                   AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  -- PROVIAMO SUL PADRE
                  SELECT so4_ags_pkg.unita_get_unita_padre (p_progr_uo,
                                                            p_ottica_uo,
                                                            SYSDATE)
                    INTO d_temp
                    FROM DUAL;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     d_temp := NULL;
               END;

               IF d_temp IS NOT NULL
               THEN
                  BEGIN
                     d_startpos := INSTR (d_temp, '#') + 1;
                     d_stoppos := INSTR (d_temp, '#', d_startpos);
                     d_codice_unita_padre :=
                        SUBSTR (d_temp, d_startpos, d_stoppos - d_startpos);

                     SELECT S.UTENTE utente_firmatario
                       INTO d_utente_firmatario
                       FROM so4_v_componenti_pubb c,
                            so4_v_unita_organizzative_pubb u,
                            as4_v_soggetti s
                      WHERE     c.dal <= SYSDATE
                            AND (c.al IS NULL OR c.al >= SYSDATE)
                            AND c.ottica = u.ottica
                            AND C.PROGR_UNITA = U.PROGR
                            AND U.OTTICA = p_ottica_uo
                            AND u.codice = d_codice_unita_padre
                            AND u.dal <= SYSDATE
                            AND (u.al IS NULL OR u.al >= SYSDATE)
                            AND s.dal <= SYSDATE
                            AND (s.al IS NULL OR s.al >= SYSDATE)
                            AND S.NI = c.id_soggetto
                            AND EXISTS
                                   (SELECT 1
                                      FROM SO4_V_RUOLI_COMPONENTE_PUBB rc
                                     WHERE     RC.ID_COMPONENTE =
                                                  c.id_componente
                                           AND rc.dal <= SYSDATE
                                           AND rc.ruolo =
                                                  NVL (
                                                     GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                                                        'RUOLO RESPONSABILE',
                                                        1),
                                                     'AGPRESP')
                                           AND (   rc.al IS NULL
                                                OR rc.al >= SYSDATE))
                            AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           -- PROVIAMO SUL PADRE
                           SELECT so4_ags_pkg.unita_get_unita_padre (
                                     d_codice_unita_padre,
                                     gdo_impostazioni_pkg.get_impostazione (
                                        'SO_OTTICA_PROT',
                                        1),
                                     SYSDATE,
                                     NULL)
                             INTO d_temp
                             FROM DUAL;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              d_temp := NULL;
                        END;

                        IF d_temp IS NOT NULL
                        THEN
                           BEGIN
                              d_startpos := INSTR (d_temp, '#') + 1;
                              d_stoppos := INSTR (d_temp, '#', d_startpos);
                              d_codice_unita_padre :=
                                 SUBSTR (d_temp,
                                         d_startpos,
                                         d_stoppos - d_startpos);

                              SELECT S.UTENTE utente_firmatario
                                INTO d_utente_firmatario
                                FROM so4_v_componenti_pubb c,
                                     so4_v_unita_organizzative_pubb u,
                                     as4_v_soggetti s
                               WHERE     c.dal <= SYSDATE
                                     AND (c.al IS NULL OR c.al >= SYSDATE)
                                     AND c.ottica = u.ottica
                                     AND C.PROGR_UNITA = U.PROGR
                                     AND U.OTTICA = p_ottica_uo
                                     AND u.codice = d_codice_unita_padre
                                     AND u.dal <= SYSDATE
                                     AND (u.al IS NULL OR u.al >= SYSDATE)
                                     AND s.dal <= SYSDATE
                                     AND (s.al IS NULL OR s.al >= SYSDATE)
                                     AND S.NI = c.id_soggetto
                                     AND EXISTS
                                            (SELECT 1
                                               FROM SO4_V_RUOLI_COMPONENTE_PUBB rc
                                              WHERE     RC.ID_COMPONENTE =
                                                           c.id_componente
                                                    AND rc.dal <= SYSDATE
                                                    AND rc.ruolo =
                                                           NVL (
                                                              GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                                                                 'RUOLO RESPONSABILE',
                                                                 1),
                                                              'AGPRESP')
                                                    AND (   rc.al IS NULL
                                                         OR rc.al >= SYSDATE))
                                     AND ROWNUM = 1;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 NULL;
                           END;
                        END IF;
                  END;
               END IF;
         END;
      END IF;

      RETURN d_utente_firmatario;
   END;

   FUNCTION get_id_schema_protocollo (p_codice VARCHAR2)
      RETURN VARCHAR2
   IS
      d_id_schema_protocollo   NUMBER;
   BEGIN
      BEGIN
         SELECT id_schema_protocollo
           INTO d_id_schema_protocollo
           FROM agp_schemi_protocollo
          WHERE codice = p_codice;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_id_schema_protocollo := NULL;
      END;

      RETURN d_id_schema_protocollo;
   END;

   FUNCTION get_id_modalita_invio_ricez (p_codice VARCHAR2)
      RETURN VARCHAR2
   IS
      d_id_modalita_invio_ricezione   NUMBER;
   BEGIN
      BEGIN
         SELECT id_modalita_invio_ricezione
           INTO d_id_modalita_invio_ricezione
           FROM ags_modalita_invio_ricezione
          WHERE codice = p_codice;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_id_modalita_invio_ricezione := NULL;
      END;

      RETURN d_id_modalita_invio_ricezione;
   END;

   FUNCTION get_id_tipo_allegato (p_codice VARCHAR2)
      RETURN VARCHAR2
   IS
      d_id_tipo_allegato   NUMBER;
   BEGIN
      BEGIN
         SELECT id_tipo_documento
           INTO d_id_tipo_allegato
           FROM gdo_tipi_documento
          WHERE codice = 'ALLEGATO' AND acronimo = NVL (p_codice, '0000');
      EXCEPTION
         WHEN OTHERS
         THEN
            BEGIN
               SELECT id_tipo_documento
                 INTO d_id_tipo_allegato
                 FROM gdo_tipi_documento
                WHERE codice = 'ALLEGATO' AND acronimo = '0000';
            EXCEPTION
               WHEN OTHERS
               THEN
                  d_id_tipo_allegato := NULL;
            END;
      END;

      RETURN d_id_tipo_allegato;
   END;



   PROCEDURE calcola_tipo_protocollo (
      p_id_tipo_protocollo             NUMBER,
      p_controllo_funzionario   IN OUT VARCHAR2,
      p_controllo_firmatario    IN OUT VARCHAR2)
   IS
   BEGIN
      SELECT tipr.funz_obbligatorio, tipr.firm_obbligatorio
        INTO p_controllo_funzionario, p_controllo_firmatario
        FROM agp_tipi_protocollo tipr
       WHERE tipr.id_tipo_protocollo = p_id_tipo_protocollo;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RAISE;
   END;


   FUNCTION crea_dati_interop (p_PRIMA_REG_COD_AMM         VARCHAR2,
                               p_PRIMA_REG_COD_AOO         VARCHAR2,
                               p_PRIMA_REG_DATA            DATE,
                               p_PRIMA_REG_NUMERO          VARCHAR2,
                               p_MOTIVO_RICH_INTERVENTO    VARCHAR2,
                               p_RICH_CONF_RIC             VARCHAR2)
      RETURN NUMBER
   IS
      d_id_doc_interop   NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id_doc_interop FROM DUAL;

      INSERT
        INTO AGP_PROTOCOLLI_DATI_INTEROP (ID_PROTOCOLLO_DATI_INTEROP,
                                          CODICE_AMM_PRIMA_REGISTRAZIONE,
                                          CODICE_AOO_PRIMA_REGISTRAZIONE,
                                          CODICE_REG_PRIMA_REGISTRAZIONE,
                                          DATA_INS,
                                          DATA_PRIMA_REGISTRAZIONE,
                                          DATA_UPD,
                                          INVIATA_CONFERMA,
                                          MOTIVO_INTERVENTO_OPERATORE,
                                          NUMERO_PRIMA_REGISTRAZIONE,
                                          RICEVUTA_ACCETTAZIONE_CONFERMA,
                                          RICHIESTA_CONFERMA,
                                          UTENTE_INS,
                                          UTENTE_UPD,
                                          VERSION)
      VALUES (d_id_doc_interop,
              p_PRIMA_REG_COD_AMM,
              p_PRIMA_REG_COD_AOO,
              NULL,                       /* CODICE_REG_PRIMA_REGISTRAZIONE */
              SYSDATE,
              p_PRIMA_REG_DATA,
              SYSDATE,
              'N',                                      /* INVIATA_CONFERMA */
              p_MOTIVO_RICH_INTERVENTO,
              p_PRIMA_REG_NUMERO,
              'N',                        /* RICEVUTA_ACCETTAZIONE_CONFERMA */
              NVL (p_RICH_CONF_RIC, 'N'),
              'RPI',
              'RPI',
              0);

      RETURN d_id_doc_interop;
   END;

   FUNCTION crea_dati_scarto (p_stato              VARCHAR2,
                              p_data_stato         DATE,
                              p_nulla_osta         VARCHAR2,
                              p_data_nulla_osta    DATE,
                              p_utente_ins         VARCHAR2,
                              p_data_ins           DATE)
      RETURN NUMBER
   IS
      d_id_dati_scarto   NUMBER;
      d_id_revisione     NUMBER;
   BEGIN
      SELECT hibernate_sequence.NEXTVAL INTO d_id_dati_scarto FROM DUAL;

      INSERT INTO AGP_PROTOCOLLI_DATI_SCARTO (ID_PROTOCOLLO_DATI_SCARTO,
                                              STATO,
                                              DATA_STATO,
                                              NULLA_OSTA,
                                              DATA_NULLA_OSTA,
                                              UTENTE_INS,
                                              DATA_INS,
                                              UTENTE_UPD,
                                              DATA_UPD,
                                              VERSION)
           VALUES (d_id_dati_scarto,
                   p_stato,
                   p_data_stato,
                   p_nulla_osta,
                   p_data_nulla_osta,
                   p_utente_ins,
                   p_data_ins,
                   p_utente_ins,
                   p_data_ins,
                   0);

      d_id_revisione :=
         crea_revinfo (TO_TIMESTAMP (p_DATA_INS, 'DD/MM/YYYY HH24:MI:SS,FF'));

      INSERT INTO AGP_PROTOCOLLI_DATI_SCARTO_LOG (ID_PROTOCOLLO_DATI_SCARTO,
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
           VALUES (d_id_dati_scarto,
                   d_id_revisione,
                   0,
                   p_stato,
                   p_data_stato,
                   p_nulla_osta,
                   p_data_nulla_osta,
                   p_utente_ins,
                   p_data_ins,
                   p_utente_ins,
                   p_data_ins);

      RETURN d_id_dati_scarto;
   END;

   PROCEDURE crea_corrispondente (p_id_documento                   NUMBER,
                                  p_denominazione_per_segnatura    VARCHAR2,
                                  p_cognome_per_segnatura          VARCHAR2,
                                  p_nome_per_segnatura             VARCHAR2,
                                  p_cf_per_segnatura               VARCHAR2,
                                  p_partita_iva                    VARCHAR2,
                                  p_indirizzo_per_segnatura        VARCHAR2,
                                  p_cap_per_segnatura              VARCHAR2,
                                  p_comune_per_segnatura           VARCHAR2,
                                  p_provincia_per_segnatura        VARCHAR2,
                                  p_email                          VARCHAR2,
                                  p_fax                            VARCHAR2,
                                  p_conoscenza                     VARCHAR2,
                                  p_tipo_indirizzo                 VARCHAR2,
                                  p_tipo_corrispondente            VARCHAR2,
                                  p_tipo_soggetto                  VARCHAR2,
                                  p_bc_spedizione                  VARCHAR2,
                                  p_data_spedizione                DATE,
                                  p_id_documento_esterno           NUMBER,
                                  p_id_modalita_invio_ricezione    NUMBER,
                                  p_cod_amm                        VARCHAR2,
                                  p_descrizione_amm                VARCHAR2,
                                  p_indirizzo_amm                  VARCHAR2,
                                  p_cap_amm                        VARCHAR2,
                                  p_comune_amm                     VARCHAR2,
                                  p_sigla_prov_amm                 VARCHAR2,
                                  p_mail_amm                       VARCHAR2,
                                  p_fax_amm                        VARCHAR2,
                                  p_cod_aoo                        VARCHAR2,
                                  p_descrizione_aoo                VARCHAR2,
                                  p_indirizzo_aoo                  VARCHAR2,
                                  p_cap_aoo                        VARCHAR2,
                                  p_comune_aoo                     VARCHAR2,
                                  p_sigla_prov_aoo                 VARCHAR2,
                                  p_mail_aoo                       VARCHAR2,
                                  p_fax_aoo                        VARCHAR2,
                                  p_cod_uo                         VARCHAR2,
                                  p_descrizione_uo                 VARCHAR2,
                                  p_indirizzo_uo                   VARCHAR2,
                                  p_cap_uo                         VARCHAR2,
                                  p_comune_uo                      VARCHAR2,
                                  p_sigla_prov_uo                  VARCHAR2,
                                  p_mail_uo                        VARCHAR2,
                                  p_fax_uo                         VARCHAR2,
                                  p_utente_inserimento             VARCHAR2,
                                  p_data_inserimento               DATE,
                                  p_utente_aggiornamento           VARCHAR2,
                                  p_data_aggiornamento             DATE,
                                  p_registrata_consegna            VARCHAR2,
                                  p_reg_consegna_aggiornamento     VARCHAR2,
                                  p_reg_consegna_annullamento      VARCHAR2,
                                  p_reg_consegna_conferma          VARCHAR2,
                                  p_ricevuta_conferma              VARCHAR2,
                                  p_ricevuta_eccezione             VARCHAR2,
                                  p_ricevuto_aggiornamento         VARCHAR2,
                                  p_ricevuto_annullamento          VARCHAR2,
                                  p_ric_mancata_consegna           VARCHAR2,
                                  p_ric_mancata_consegna_agg       VARCHAR2,
                                  p_ric_mancata_consegna_ann       VARCHAR2,
                                  p_ric_mancata_consegna_conf      VARCHAR2)
   IS
      d_id_doc_corr        NUMBER;
      d_id_doc_corr_indi   NUMBER;
      d_id_mess_corr       NUMBER;
      d_denominazione      VARCHAR2 (2000) := p_denominazione_per_segnatura;
      d_cognome            VARCHAR2 (2000) := p_cognome_per_segnatura;
      d_id_revisione       NUMBER;
      d_tipo_soggetto      VARCHAR2 (2000) := p_tipo_soggetto;
   BEGIN
      BEGIN
         SELECT tipo_soggetto
           INTO d_tipo_soggetto
           FROM agp_tipi_soggetto
          WHERE tipo_soggetto = p_tipo_soggetto;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_tipo_soggetto := 1;
      END;

      SELECT hibernate_sequence.NEXTVAL INTO d_id_doc_corr FROM DUAL;

      IF d_tipo_soggetto = 2
      THEN
         d_denominazione := p_descrizione_amm;

         -- se è AMM devo inserire il solo record dell'amministrazione,
         -- se è AOO devo inserire il record dell'aoo e quello dell'amministrazione,
         -- se è UO devo inserire il record dell'uo e quello dell'amministrazione.
         IF p_cod_uo IS NOT NULL
         THEN
            d_denominazione := d_denominazione || ':UO:' || p_descrizione_uo;
            d_cognome := p_descrizione_uo;

            SELECT hibernate_sequence.NEXTVAL
              INTO d_id_doc_corr_indi
              FROM DUAL;

            INSERT
              INTO AGP_PROTOCOLLI_CORR_INDIRIZZI (ID_PROTOCOLLO_CORR_INDIRIZZO,
                                                  ID_PROTOCOLLO_CORRISPONDENTE,
                                                  INDIRIZZO,
                                                  CAP,
                                                  COMUNE,
                                                  PROVINCIA_SIGLA,
                                                  EMAIL,
                                                  FAX,
                                                  TIPO_INDIRIZZO,
                                                  CODICE,
                                                  DENOMINAZIONE,
                                                  UTENTE_INS,
                                                  DATA_INS,
                                                  UTENTE_UPD,
                                                  DATA_UPD,
                                                  VERSION,
                                                  VALIDO)
            VALUES (d_id_doc_corr_indi,
                    d_id_doc_corr,
                    p_indirizzo_uo,
                    p_cap_uo,
                    p_comune_uo,
                    p_sigla_prov_uo,
                    p_mail_uo,
                    p_fax_uo,
                    'UO'                                  /* TIPO_INDIRIZZO */
                        ,
                    p_cod_uo,
                    p_descrizione_uo,
                    p_utente_inserimento                      /* UTENTE_INS */
                                        ,
                    p_data_inserimento                          /* DATA_INS */
                                      ,
                    p_utente_aggiornamento                    /* UTENTE_UPD */
                                          ,
                    p_data_aggiornamento                        /* DATA_UPD */
                                        ,
                    0                                            /* VERSION */
                     ,
                    'Y'                                           /* VALIDO */
                       );
         ELSE
            IF p_cod_aoo IS NOT NULL
            THEN
               d_denominazione :=
                  d_denominazione || ':AOO:' || p_descrizione_aoo;
               d_cognome := p_descrizione_aoo;

               SELECT hibernate_sequence.NEXTVAL
                 INTO d_id_doc_corr_indi
                 FROM DUAL;

               INSERT
                 INTO AGP_PROTOCOLLI_CORR_INDIRIZZI (
                         ID_PROTOCOLLO_CORR_INDIRIZZO,
                         ID_PROTOCOLLO_CORRISPONDENTE,
                         INDIRIZZO,
                         CAP,
                         COMUNE,
                         PROVINCIA_SIGLA,
                         EMAIL,
                         FAX,
                         TIPO_INDIRIZZO,
                         CODICE,
                         DENOMINAZIONE,
                         UTENTE_INS,
                         DATA_INS,
                         UTENTE_UPD,
                         DATA_UPD,
                         VERSION,
                         VALIDO)
               VALUES (d_id_doc_corr_indi,
                       d_id_doc_corr,
                       p_indirizzo_aoo,
                       p_cap_aoo,
                       p_comune_aoo,
                       p_sigla_prov_aoo,
                       p_mail_aoo,
                       p_fax_aoo,
                       'AOO'                              /* TIPO_INDIRIZZO */
                            ,
                       p_cod_aoo,
                       p_descrizione_aoo,
                       p_utente_inserimento,
                       p_data_inserimento,
                       p_utente_aggiornamento,
                       p_data_aggiornamento,
                       0                                         /* VERSION */
                        ,
                       'Y'                                        /* VALIDO */
                          );
            END IF;
         END IF;

         SELECT hibernate_sequence.NEXTVAL INTO d_id_doc_corr_indi FROM DUAL;

         INSERT
           INTO AGP_PROTOCOLLI_CORR_INDIRIZZI (ID_PROTOCOLLO_CORR_INDIRIZZO,
                                               ID_PROTOCOLLO_CORRISPONDENTE,
                                               INDIRIZZO,
                                               CAP,
                                               COMUNE,
                                               PROVINCIA_SIGLA,
                                               EMAIL,
                                               FAX,
                                               TIPO_INDIRIZZO,
                                               CODICE,
                                               DENOMINAZIONE,
                                               UTENTE_INS,
                                               DATA_INS,
                                               UTENTE_UPD,
                                               DATA_UPD,
                                               VERSION,
                                               VALIDO)
         VALUES (d_id_doc_corr_indi,
                 d_id_doc_corr,
                 p_indirizzo_amm,
                 p_cap_amm,
                 p_comune_amm,
                 p_sigla_prov_amm,
                 p_mail_amm,
                 p_fax_amm,
                 'AMM'                                    /* TIPO_INDIRIZZO */
                      ,
                 p_cod_amm,
                 p_descrizione_amm,
                 p_utente_inserimento,
                 p_data_inserimento,
                 p_utente_aggiornamento,
                 p_data_aggiornamento,
                 0                                               /* VERSION */
                  ,
                 'Y'                                              /* VALIDO */
                    );
      END IF;

      INSERT
        INTO AGP_PROTOCOLLI_CORRISPONDENTI (ID_PROTOCOLLO_CORRISPONDENTE,
                                            ID_DOCUMENTO,
                                            DENOMINAZIONE,
                                            COGNOME,
                                            NOME,
                                            CODICE_FISCALE,
                                            PARTITA_IVA,
                                            INDIRIZZO,
                                            CAP,
                                            COMUNE,
                                            PROVINCIA_SIGLA,
                                            EMAIL,
                                            FAX,
                                            CONOSCENZA,
                                            TIPO_INDIRIZZO,
                                            TIPO_CORRISPONDENTE,
                                            TIPO_SOGGETTO,
                                            BC_SPEDIZIONE,
                                            DATA_SPEDIZIONE,
                                            ID_DOCUMENTO_ESTERNO,
                                            UTENTE_INS,
                                            DATA_INS,
                                            UTENTE_UPD,
                                            DATA_UPD,
                                            VERSION,
                                            VALIDO,
                                            ID_MODALITA_INVIO_RICEZIONE)
      VALUES (d_id_doc_corr,
              p_id_documento,
              d_denominazione,
              d_cognome,
              p_nome_per_segnatura,
              p_cf_per_segnatura,
              p_partita_iva,
              p_indirizzo_per_segnatura,
              p_cap_per_segnatura,
              p_comune_per_segnatura,
              p_provincia_per_segnatura,
              p_email,
              p_fax,
              NVL (p_conoscenza, 'N'),
              p_tipo_indirizzo,
              p_tipo_corrispondente,
              d_tipo_soggetto,
              p_bc_spedizione,
              p_data_spedizione,
              p_id_documento_esterno,
              p_utente_inserimento,
              p_data_inserimento,
              p_utente_aggiornamento,
              p_data_aggiornamento,
              0                                                  /* VERSION */
               ,
              'Y'                                                 /* VALIDO */
                 ,
              p_id_modalita_invio_ricezione);

      d_id_revisione :=
         crea_revinfo (
            NVL (
               TO_TIMESTAMP (NVL (p_data_aggiornamento, p_data_inserimento),
                             'DD/MM/YYYY HH24:MI:SS,FF'),
               SYSTIMESTAMP));

      INSERT INTO AGP_PROTOCOLLI_CORR_LOG (ID_DOCUMENTO,
                                           REV,
                                           ID_PROTOCOLLO_CORRISPONDENTE,
                                           DENOMINAZIONE,
                                           DENOMINAZIONE_MOD,
                                           COGNOME,
                                           COGNOME_MOD,
                                           NOME,
                                           NOME_MOD,
                                           CODICE_FISCALE,
                                           CODICE_FISCALE_MOD,
                                           PARTITA_IVA,
                                           PARTITA_IVA_MOD,
                                           INDIRIZZO,
                                           INDIRIZZO_MOD,
                                           CAP,
                                           CAP_MOD,
                                           COMUNE,
                                           COMUNE_MOD,
                                           PROVINCIA_SIGLA,
                                           PROVINCIA_SIGLA_MOD,
                                           EMAIL,
                                           EMAIL_MOD,
                                           FAX,
                                           FAX_MOD,
                                           CONOSCENZA,
                                           CONOSCENZA_MOD,
                                           TIPO_INDIRIZZO,
                                           TIPO_INDIRIZZO_MOD,
                                           TIPO_CORRISPONDENTE,
                                           TIPO_CORRISPONDENTE_MOD,
                                           BC_SPEDIZIONE,
                                           BARCODE_SPEDIZIONE_MOD,
                                           DATA_SPEDIZIONE,
                                           DATA_SPEDIZIONE_MOD,
                                           ID_DOCUMENTO_ESTERNO,
                                           ID_DOCUMENTO_ESTERNO_MOD,
                                           UTENTE_INS,
                                           UTENTE_INS_MOD,
                                           DATA_INS,
                                           UTENTE_UPD,
                                           UTENTE_UPD_MOD,
                                           VALIDO,
                                           VALIDO_MOD)
           VALUES (p_id_documento,
                   d_id_revisione,
                   d_id_doc_corr,
                   d_denominazione,
                   DECODE (d_denominazione, NULL, 0, 1),
                   d_cognome,
                   DECODE (d_cognome, NULL, 0, 1),
                   p_nome_per_segnatura,
                   DECODE (p_nome_per_segnatura, NULL, 0, 1),
                   p_cf_per_segnatura,
                   DECODE (p_cf_per_segnatura, NULL, 0, 1),
                   p_partita_iva,
                   DECODE (p_partita_iva, NULL, 0, 1),
                   p_indirizzo_per_segnatura,
                   DECODE (p_indirizzo_per_segnatura, NULL, 0, 1),
                   p_cap_per_segnatura,
                   DECODE (p_cap_per_segnatura, NULL, 0, 1),
                   p_comune_per_segnatura,
                   DECODE (p_comune_per_segnatura, NULL, 0, 1),
                   p_provincia_per_segnatura,
                   DECODE (p_provincia_per_segnatura, NULL, 0, 1),
                   p_email,
                   DECODE (p_email, NULL, 0, 1),
                   p_fax,
                   DECODE (p_fax, NULL, 0, 1),
                   p_conoscenza,
                   DECODE (p_conoscenza, NULL, 0, 1),
                   p_tipo_indirizzo,
                   DECODE (p_tipo_indirizzo, NULL, 0, 1),
                   p_tipo_corrispondente,
                   DECODE (p_tipo_corrispondente, NULL, 0, 1),
                   p_bc_spedizione,
                   DECODE (p_bc_spedizione, NULL, 0, 1),
                   p_data_spedizione,
                   DECODE (p_data_spedizione, NULL, 0, 1),
                   p_id_documento_esterno,
                   DECODE (p_id_documento_esterno, NULL, 0, 1),
                   p_utente_inserimento,
                   DECODE (p_utente_inserimento, NULL, 0, 1),
                   p_data_inserimento,
                   p_utente_aggiornamento,
                   DECODE (p_utente_aggiornamento, NULL, 0, 1),
                   'Y',
                   1);

      DECLARE
         d_id_messaggio   NUMBER;
      BEGIN
         SELECT MIN (id_documento)
           INTO d_id_messaggio
           FROM agp_messaggi
          WHERE id_documento_esterno IN (SELECT id_documento_rif
                                           FROM gdm_riferimenti
                                          WHERE     id_documento =
                                                       (SELECT id_documento_esterno
                                                          FROM gdo_documenti
                                                         WHERE id_documento =
                                                                  p_id_documento)
                                                AND TIPO_RELAZIONE = 'MAIL');

         IF d_id_messaggio IS NOT NULL
         THEN
            SELECT hibernate_sequence.NEXTVAL INTO d_id_mess_corr FROM DUAL;

            INSERT
              INTO AGP_MESSAGGI_CORRISPONDENTI (ID_MESSAGGIO_CORRISPONDENTE,
                                                ID_MESSAGGIO,
                                                DENOMINAZIONE,
                                                EMAIL,
                                                CONOSCENZA,
                                                DATA_SPEDIZIONE,
                                                REGISTRATA_CONSEGNA,
                                                RIC_MANCATA_CONSEGNA,
                                                RICEVUTA_CONFERMA,
                                                DATA_RIC_CONFERMA,
                                                RICEVUTO_AGGIORNAMENTO,
                                                DATA_RIC_AGGIORNAMENTO,
                                                RICEVUTO_ANNULLAMENTO,
                                                DATA_RIC_ANNULLAMENTO,
                                                RICEVUTA_ECCEZIONE,
                                                DATA_RIC_ECCEZIONE,
                                                REG_CONSEGNA_CONFERMA,
                                                RIC_MANCATA_CONSEGNA_CONF,
                                                REG_CONSEGNA_AGGIORNAMENTO,
                                                RIC_MANCATA_CONSEGNA_AGG,
                                                REG_CONSEGNA_ANNULLAMENTO,
                                                RIC_MANCATA_CONSEGNA_ANN,
                                                ID_PROTOCOLLO_CORRISPONDENTE,
                                                UTENTE_INS,
                                                DATA_INS,
                                                UTENTE_UPD,
                                                DATA_UPD,
                                                VERSION,
                                                VALIDO)
               VALUES (
                         d_id_mess_corr,
                         d_id_messaggio,
                         NVL (d_denominazione,
                              d_cognome || ' ' || p_nome_per_segnatura),
                         NVL (p_email, '.'),
                         NVL (p_conoscenza, 'N'),
                         NULL,
                         NVL (p_REGISTRATA_CONSEGNA, 'N'),
                         NVL (p_RIC_MANCATA_CONSEGNA, 'N'),
                         NVL (p_RICEVUTA_CONFERMA, 'N'),
                         NULL,
                         NVL (p_RICEVUTO_AGGIORNAMENTO, 'N'),
                         NULL,
                         NVL (p_RICEVUTO_ANNULLAMENTO, 'N'),
                         NULL,
                         NVL (p_RICEVUTA_ECCEZIONE, 'N'),
                         NULL,
                         NVL (p_REG_CONSEGNA_CONFERMA, 'N'),
                         NVL (p_RIC_MANCATA_CONSEGNA_CONF, 'N'),
                         NVL (p_REG_CONSEGNA_AGGIORNAMENTO, 'N'),
                         NVL (p_RIC_MANCATA_CONSEGNA_AGG, 'N'),
                         NVL (p_REG_CONSEGNA_ANNULLAMENTO, 'N'),
                         NVL (p_RIC_MANCATA_CONSEGNA_ANN, 'N'),
                         d_id_doc_corr,
                         p_utente_aggiornamento,
                         p_data_aggiornamento,
                         p_utente_aggiornamento,
                         p_data_aggiornamento,
                         0,
                         'Y');
         END IF;
      END;
   END;

   PROCEDURE riempi_temp_dati_rifiuto (p_id_documento_gdm    NUMBER,
                                       p_dati_rifiuti        VARCHAR2)
   IS
      d_dati_rifiuti        VARCHAR2 (4000) := UPPER (p_dati_rifiuti);
      d_dati_rifiuto        VARCHAR2 (4000);

      d_numero_separatori   NUMBER;
      d_loop                NUMBER := 0;
      d_separatore          VARCHAR2 (100) := '***********';

      d_stringa_data        VARCHAR2 (100) := ' IN DATA ';
      d_stringa_motivo      VARCHAR2 (100) := ' PER IL SEGUENTE MOTIVO: ';

      d_data_smist          DATE;
      d_utente_rifiuto      VARCHAR2 (100);
      d_data_rif            DATE;
      d_motivo              VARCHAR2 (4000);
   BEGIN
      d_numero_separatori :=
         afc.countoccurrenceof (d_dati_rifiuti, d_separatore);

      WHILE d_loop <= d_numero_separatori
      LOOP
         d_dati_rifiuto := afc.get_substr (d_dati_rifiuti, d_separatore);
         d_dati_rifiuti := SUBSTR (d_dati_rifiuti, 3);

         d_data_smist := NULL;
         d_utente_rifiuto := NULL;
         d_data_rif := NULL;
         d_motivo := NULL;

         BEGIN
            SELECT TO_DATE (
                      SUBSTR (
                         d_dati_rifiuto,
                           INSTR (d_dati_rifiuto, d_stringa_data, -1)
                         + LENGTH (d_stringa_data),
                         19),
                      'dd/mm/yyyy hh24:mi:ss')
              INTO d_data_smist
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_data_smist := NULL;
         END;

         BEGIN
            SELECT SUBSTR (d_dati_rifiuto,
                           1,
                           INSTR (d_dati_rifiuto, d_stringa_data) - 1)
              INTO d_utente_rifiuto
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_utente_rifiuto := NULL;
         END;

         BEGIN
            SELECT TO_DATE (
                      SUBSTR (
                         d_dati_rifiuto,
                           INSTR (d_dati_rifiuto, d_stringa_data)
                         + LENGTH (d_stringa_data),
                         19),
                      'dd/mm/yyyy hh24:mi:ss')
              INTO d_data_rif
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_data_rif := NULL;
         END;

         BEGIN
            SELECT SUBSTR (
                      d_dati_rifiuto,
                        INSTR (d_dati_rifiuto, d_stringa_motivo)
                      + LENGTH (d_stringa_motivo))
              INTO d_motivo
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_motivo := NULL;
         END;

         IF    d_data_smist IS NULL
            OR d_utente_rifiuto IS NULL
            OR d_data_rif IS NULL
            OR d_motivo IS NULL
         THEN
            d_motivo := d_dati_rifiuto;
         END IF;

         INSERT INTO TEMP_DOCUMENTI_DATI_RIFIUTO (ID_DOCUMENTO_GDM,
                                                  DATA_SMISTAMENTO,
                                                  UTENTE_RIFIUTO,
                                                  DATA_RIFIUTO,
                                                  MOTIVO_RIFIUTO)
              VALUES (p_id_documento_gdm,
                      d_data_smist,
                      d_utente_rifiuto,
                      d_data_rif,
                      d_motivo);

         d_loop := d_loop + 1;
      END LOOP;
   END;

   PROCEDURE verifica_uso_maschere_zk (p_id_documento_gdm NUMBER)
   IS
      d_pagina_nuova   NUMBER := 0;
   BEGIN
      SELECT INSTR (url, 'standalone.zul')
        INTO d_pagina_nuova
        FROM gdm_jdms_link jl, gdm_tipi_documento gtd, gdm_documenti gd
       WHERE     jl.id_tipodoc = gtd.id_tipodoc
             AND jl.tag = 5
             AND gtd.id_tipodoc = gd.id_tipodoc
             AND gd.id_documento = p_id_documento_gdm;

      IF d_pagina_nuova = 0
      THEN
         raise_application_error (
            -20999,
               'Documento identificato da '
            || p_id_documento_gdm
            || ' utilizza ancora pagina flex.');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         d_pagina_nuova := 0;
   END;

   PROCEDURE verifica_esistenza_prot_gdm (p_id_documento_gdm NUMBER)
   IS
      d_esiste_documento_gdm   NUMBER := 0;
   BEGIN
      SELECT COUNT (1)
        INTO d_esiste_documento_gdm
        FROM gdm_proto_view p
       WHERE p.id_documento = p_id_documento_gdm;

      IF d_esiste_documento_gdm = 0
      THEN
         raise_application_error (
            -20999,
               'Documento identificato da '
            || p_id_documento_gdm
            || ' non presente.');
      END IF;
   END;

   PROCEDURE ver_esistenza_doc_da_fasc_gdm (p_id_documento_gdm NUMBER)
   IS
      d_esiste_documento_gdm   NUMBER := 0;
   BEGIN
      SELECT COUNT (1)
        INTO d_esiste_documento_gdm
        FROM gdm_spr_da_fascicolare p
       WHERE p.id_documento = p_id_documento_gdm;

      IF d_esiste_documento_gdm = 0
      THEN
         raise_application_error (
            -20999,
               'Documento da fascicolare identificato da '
            || p_id_documento_gdm
            || ' non presente.');
      END IF;
   END;

   FUNCTION esiste_doc_trascodificato (p_id_documento_gdm NUMBER)
      RETURN NUMBER
   IS
      d_esiste   NUMBER := 0;
      d_id_doc   NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO d_esiste
        FROM gdo_documenti d, agp_protocolli p
       WHERE     d.id_documento_esterno = p_id_documento_gdm
             AND p.id_documento = d.id_documento
             AND p.idrif IS NOT NULL;

      IF d_esiste > 0
      THEN
         -- controllo se deve essere fatto il log
         BEGIN
            SELECT p.id_documento
              INTO d_id_doc
              FROM gdo_documenti d, agp_protocolli p
             WHERE     d.id_documento_esterno = p_id_documento_gdm
                   AND p.id_documento = d.id_documento
                   AND p.idrif IS NOT NULL
                   AND p.anno IS NOT NULL
                   AND EXISTS
                          (SELECT 1
                             FROM AGP_TRASCO_STORICO_LOG l
                            WHERE     l.id_documento(+) = p.id_documento
                                  AND NVL (L.TRASCO_STORICO, 'N') = 'N');

            elimina_storico_documento (d_id_doc);
            AGP_TRASCO_STORICO_PKG.crea (p_id_documento_gdm);

            UPDATE AGP_TRASCO_STORICO_LOG
               SET TRASCO_STORICO = 'Y'
             WHERE ID_DOCUMENTO = d_id_doc;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               raise_application_error (
                  -20998,
                     'Documento identificato da '
                  || p_id_documento_gdm
                  || ' gia'' trascodificato.');
         END;
      END IF;

      RETURN d_esiste;
   END;

   FUNCTION crea_protocollo_agspr (
      p_id_documento_gdm      NUMBER,
      p_id_tipo_protocollo    NUMBER DEFAULT NULL,
      p_attiva_iter           NUMBER DEFAULT 0,
      p_trasco_storico        NUMBER DEFAULT 1)
      RETURN NUMBER
   IS
      d_id_ente                       NUMBER := 1;

      d_id_doc                        NUMBER;
      d_id_rev                        NUMBER;
      d_id_tipo_prot                  NUMBER := p_id_tipo_protocollo;

      d_id_classificazione            NUMBER;
      d_id_fascicolo                  NUMBER;

      d_progr_uo                      NUMBER;
      d_dal_uo                        DATE;
      d_ottica_uo                     VARCHAR2 (100);

      d_progr_uo_esibente             NUMBER;
      d_dal_uo_esibente               DATE;
      d_ottica_uo_esibente            VARCHAR2 (100);

      d_id_schema_protocollo          NUMBER;
      d_id_modalita_invio_ricezione   NUMBER;

      d_id_doc_interop                NUMBER;
      d_id_doc_dati_scarto            NUMBER;

      d_controllo_funzionario         VARCHAR2 (1);
      d_controllo_firmatario          VARCHAR2 (1);
      d_utente_firmatario             VARCHAR2 (100);

      d_id_cfg_iter                   NUMBER;
      d_id_cfg_step                   NUMBER;
      d_id_cfg_competenza             NUMBER;

      d_cancellazione                 VARCHAR2 (100);
      d_lettura                       VARCHAR2 (100);
      d_modifica                      VARCHAR2 (100);

      d_continua                      BOOLEAN := TRUE;

      d_fascicolo_numero              VARCHAR2 (255);
   BEGIN
      /******************************************************************************/
      /******************************************************************************/
      /*************************** Inizio crea_protocollo ***************************/
      /******************************************************************************/
      /******************************************************************************/
      verifica_uso_maschere_zk (p_id_documento_gdm);
      verifica_esistenza_prot_gdm (p_id_documento_gdm);

      IF esiste_doc_trascodificato (p_id_documento_gdm) = 0
      THEN
         FOR p
            IN (SELECT p.*,
                       s.utente_aggiornamento utente_ins,
                       s.data_aggiornamento data_ins,
                       d.utente_aggiornamento utente_upd,
                       d.data_aggiornamento data_upd
                  FROM agp_proto_view p,
                       gdm_documenti d,
                       gdm_stati_documento s
                 WHERE     p.id_documento = p_id_documento_gdm
                       AND d.id_documento = p.id_documento
                       AND s.id_stato IN (SELECT MIN (id_stato)
                                            FROM gdm_stati_documento
                                           WHERE id_documento =
                                                    d.id_documento))
         LOOP
            /* calcolo flusso per la categoria di protocolli */
            IF d_id_tipo_prot IS NULL
            THEN
               d_id_tipo_prot := get_id_tipo_protocollo_default (p.categoria);
            END IF;

            DBMS_OUTPUT.put_line ('d_id_tipo_prot:' || d_id_tipo_prot);

            d_id_ente := NVL (p.id_ente, 1);

            /******************************************
                    Calcolo UNITA_PROTOCOLLANTE
            ******************************************/
            IF p.unita_protocollante IS NOT NULL
            THEN
               calcola_unita (p.unita_protocollante,
                              p.data,
                              d_progr_uo,
                              d_dal_uo,
                              d_ottica_uo);
            END IF;

            /******************************************
                    Calcolo UNITA_ESIBENTE
            ******************************************/
            IF p.unita_esibente IS NOT NULL
            THEN
               calcola_unita (p.unita_esibente,
                              p.data,
                              d_progr_uo_esibente,
                              d_dal_uo_esibente,
                              d_ottica_uo_esibente);
            END IF;

            d_fascicolo_numero := LTRIM (p.fascicolo_numero, '0');
            /******************************************
               Calcolo CLASSIFICAZIONE E FASCICOLO
            ******************************************/
            calcola_titolario (p.class_cod,
                               p.class_dal,
                               p.fascicolo_anno,
                               d_fascicolo_numero,
                               d_id_ente,
                               d_id_classificazione,
                               d_id_fascicolo);

            /******************************************
                           FIRMATARIO
            ******************************************/
            d_utente_firmatario :=
               get_firmatario (p.categoria,
                               d_ottica_uo,
                               d_progr_uo,
                               d_dal_uo);

            /******************************************
                         CREA DOCUMENTO
            ******************************************/
            DECLARE
               d_stato   VARCHAR2 (100);
            BEGIN
               IF p.stato_pr = 'AN'
               THEN
                  d_stato := 'ANNULLATO';
               ELSIF p.stato_pr = 'DN'
               THEN
                  d_stato := 'DA_ANNULLARE';
               ELSE
                  d_stato := '';
               END IF;

               crea_documento (p.id_documento,
                               d_id_ente,
                               'Y',
                               p.riservato,
                               p.utente_ins,
                               p.data_ins,
                               p.utente_upd,
                               p.data_upd,
                               d_stato,
                               'PROTOCOLLO',
                               NULL,
                               d_id_doc,
                               d_id_rev,
                               TRUE                     --p_trasco_storico = 1
                                   );
               DBMS_OUTPUT.PUT_LINE ('Crea doc d_id_rev ' || d_id_rev);
            END;

            /******************************************
                         CREA FILE DOCUMENTO
            ******************************************/
            DECLARE
               d_codice   VARCHAR2 (1000) := 'FILE_PRINCIPALE';
            BEGIN
               IF p.categoria = 'PEC' AND p.anno IS NULL AND p.numero IS NULL
               THEN
                  DECLARE
                     d_count_file   NUMBER;
                  BEGIN
                     SELECT COUNT (1)
                       INTO d_count_file
                       FROM gdm_oggetti_file o
                      WHERE id_documento = p.id_documento;

                     IF d_count_file > 1
                     THEN
                        d_codice := 'FILE_DA_MAIL';
                     END IF;
                  END;
               END IF;

               DECLARE
                  d_id_file_doc   NUMBER;
                  d_sequenza      NUMBER := 0;
                  d_firmato       VARCHAR2 (1) := NULL;
               BEGIN
                  FOR file_prot IN c_file_doc (p.id_documento)
                  LOOP
                     IF d_codice = 'FILE_PRINCIPALE'
                     THEN
                        IF p.verifica_firma IN ('V', 'N', 'F')
                        THEN
                           d_firmato := 'Y';
                        END IF;
                     END IF;

                     d_id_file_doc :=
                        crea_file_documento (d_id_doc,
                                             file_prot.id_oggetto_file,
                                             file_prot.utente_ins,
                                             file_prot.data_ins,
                                             file_prot.utente_upd,
                                             file_prot.data_upd,
                                             d_codice,
                                             file_prot.filename,
                                             d_sequenza,
                                             d_firmato);
                     d_sequenza := d_sequenza + 1;
                  END LOOP;
               END;
            END;

            /******************************************
                    UO PROTOCOLLANTE
            ******************************************/
            DECLARE
               d_id_doc_sogg   NUMBER;
            BEGIN
               d_id_doc_sogg :=
                  crea_documento_soggetto (d_id_doc,
                                           'UO_PROTOCOLLANTE',
                                           '',
                                           d_progr_uo,
                                           d_dal_uo,
                                           d_ottica_uo,
                                           d_id_rev);
            END;

            /******************************************
                    UO ESIBENTE
            ******************************************/
            IF d_progr_uo_esibente IS NOT NULL
            THEN
               DECLARE
                  d_id_doc_sogg   NUMBER;
               BEGIN
                  d_id_doc_sogg :=
                     crea_documento_soggetto (d_id_doc,
                                              'UO_ESIBENTE',
                                              '',
                                              d_progr_uo_esibente,
                                              d_dal_uo_esibente,
                                              d_ottica_uo_esibente,
                                              d_id_rev);
               END;
            END IF;

            /******************************************
                    REDATTORE / PROTOCOLLANTE
            ******************************************/
            IF    p.categoria <> 'PEC'
               OR (    p.categoria = 'PEC'
                   AND p.anno IS NOT NULL
                   AND p.numero IS NOT NULL)
            THEN
               DECLARE
                  d_id_doc_sogg   NUMBER;
               BEGIN
                  d_id_doc_sogg :=
                     crea_documento_soggetto (
                        d_id_doc,
                        'REDATTORE',
                        NVL (p.utente_protocollante, 'RPI'),
                        d_progr_uo,
                        d_dal_uo,
                        d_ottica_uo,
                        d_id_rev);
               END;
            END IF;

            /******************************************
                           FIRMATARIO
            ******************************************/
            IF d_utente_firmatario IS NOT NULL
            THEN
               DECLARE
                  d_id_doc_sogg   NUMBER;
               BEGIN
                  d_id_doc_sogg :=
                     crea_documento_soggetto (d_id_doc,
                                              'FIRMATARIO',
                                              d_utente_firmatario,
                                              NULL,
                                              NULL,
                                              NULL,
                                              d_id_rev);
               END;
            END IF;

            /******************************************
                 Gestione dati INTEROPERABILITA
            ******************************************/
            IF p.categoria = 'PEC'
            THEN
               d_id_doc_interop :=
                  crea_dati_interop (p.PRIMA_REG_COD_AMM,
                                     p.PRIMA_REG_COD_AOO,
                                     p.PRIMA_REG_DATA,
                                     p.PRIMA_REG_NUMERO,
                                     p.MOTIVO_RICH_INTERVENTO,
                                     p.RICH_CONF_RIC);
            END IF;

            /******************************************
                     Gestione dati SCARTO
            ******************************************/
            DECLARE
               d_stato   VARCHAR2 (100);
            BEGIN
               IF p.stato_scarto = 'PS'
               THEN
                  d_stato := 'PROPOSTO_PER_LO_SCARTO';
               ELSIF p.stato_scarto = 'AA'
               THEN
                  d_stato := 'ATTESA_APPROVAZIONE';
               ELSIF p.stato_scarto = 'SC'
               THEN
                  d_stato := 'SCARTATO';
               ELSIF p.stato_scarto = 'CO'
               THEN
                  d_stato := 'CONSERVATO';
               ELSIF p.stato_scarto = 'RR'
               THEN
                  d_stato := 'RICHIESTA_RIFIUTATA';
               END IF;

               IF d_stato IS NOT NULL
               THEN
                  d_id_doc_dati_scarto :=
                     crea_dati_scarto (d_stato,
                                       p.data_stato_scarto,
                                       p.numero_nulla_osta,
                                       p.data_nulla_osta,
                                       NVL (p.utente_protocollante, 'RPI'),
                                       p.data_ins);
               ELSE
                  d_id_doc_dati_scarto := NULL;
               END IF;
            END;

            /******************************************
                          TIPO PROTOCOLLO
            ******************************************/
            calcola_tipo_protocollo (d_id_tipo_prot,
                                     d_controllo_funzionario,
                                     d_controllo_firmatario);

            /******************************************
                         SCHEMA PROTOCOLLO
            ******************************************/
            IF p.tipo_documento IS NOT NULL
            THEN
               d_id_schema_protocollo :=
                  get_id_schema_protocollo (p.tipo_documento);
            END IF;

            /******************************************
                   MODALITA INVIO / RICEZIONE
            ******************************************/
            IF p.documento_tramite IS NOT NULL
            THEN
               d_id_modalita_invio_ricezione :=
                  get_id_modalita_invio_ricez (p.documento_tramite);
            END IF;

            /******************************************
                          CREA PROTOCOLLO
            ******************************************/
            DECLARE
               d_movimento        VARCHAR2 (100);
               d_stato_archivio   VARCHAR2 (100);
            BEGIN
               IF p.modalita = 'INT'
               THEN
                  d_movimento := 'INTERNO';
               ELSIF p.modalita = 'PAR'
               THEN
                  d_movimento := 'PARTENZA';
               ELSIF p.modalita = 'ARR'
               THEN
                  d_movimento := 'ARRIVO';
               END IF;

               IF p.tipo_stato = '1'
               THEN
                  d_stato_archivio := 'CORRENTE';
               ELSIF p.tipo_stato = '2'
               THEN
                  d_stato_archivio := 'DEPOSITO';
               ELSIF p.tipo_stato = '3'
               THEN
                  d_stato_archivio := 'ARCHIVIO';
               ELSE
                  d_stato_archivio := '';
               END IF;

               crea_protocollo (d_id_doc,
                                p.anno,
                                p.numero,
                                p.tipo_registro,
                                p.data,
                                d_movimento,
                                p.data_arrivo,
                                p.data_ins,
                                p.oggetto,
                                d_id_classificazione,
                                d_id_fascicolo,
                                p.data_verifica,
                                p.verifica_firma,
                                p.raccomandata_numero,
                                p.data_documento,
                                p.numero_documento,
                                d_id_schema_protocollo,
                                d_id_modalita_invio_ricezione,
                                d_stato_archivio,
                                p.data_stato,
                                p.annullato,
                                p.data_ann,
                                p.utente_ann,
                                p.provvedimento_ann,
                                p.note,
                                d_id_tipo_prot,
                                d_controllo_funzionario,
                                d_controllo_firmatario,
                                p.idrif,
                                d_id_doc_dati_scarto,
                                d_id_doc_interop,
                                d_id_rev);
            END;

            /******************************************
                        CREA CORRISPONDENTI
            ******************************************/
            DECLARE
               d_id_doc_corr        NUMBER;
               d_id_doc_corr_indi   NUMBER;
               d_tipo_indirizzo     VARCHAR2 (100);
            BEGIN
               FOR corrispondenti
                  IN (SELECT s.*,
                             d.utente_aggiornamento,
                             d.data_aggiornamento,
                             sd.utente_aggiornamento utente_inserimento,
                             sd.data_aggiornamento data_inserimento
                        FROM gdm_seg_soggetti_protocollo s,
                             gdm_documenti d,
                             gdm_stati_documento sd
                       WHERE     d.id_documento = s.id_documento
                             AND idrif = p.idrif
                             AND stato_documento NOT IN ('CA', 'RE', 'PB')
                             AND d.id_documento = sd.id_documento
                             AND s.tipo_rapporto <> 'DUMMY'
                             AND sd.id_stato IN (SELECT MIN (id_stato)
                                                   FROM gdm_stati_documento
                                                  WHERE id_documento =
                                                           d.id_documento))
               LOOP
                  d_id_modalita_invio_ricezione := NULL;
                  d_tipo_indirizzo := NULL;

                  IF corrispondenti.documento_tramite IS NOT NULL
                  THEN
                     d_id_modalita_invio_ricezione :=
                        get_id_modalita_invio_ricez (
                           corrispondenti.documento_tramite);
                  END IF;

                  IF corrispondenti.tipo_soggetto = 2
                  THEN
                     IF corrispondenti.cod_uo IS NULL
                     THEN
                        IF corrispondenti.cod_aoo IS NULL
                        THEN
                           IF corrispondenti.cod_amm IS NULL
                           THEN
                              d_tipo_indirizzo := NULL;
                           ELSE
                              d_tipo_indirizzo := 'AMM';
                           END IF;
                        ELSE
                           d_tipo_indirizzo := 'AOO';
                        END IF;
                     ELSE
                        d_tipo_indirizzo := 'UO';
                     END IF;
                  END IF;

                  crea_corrispondente (
                     d_id_doc,
                     corrispondenti.denominazione_per_segnatura,
                     corrispondenti.cognome_per_segnatura,
                     corrispondenti.nome_per_segnatura,
                     corrispondenti.cf_per_segnatura,
                     corrispondenti.partita_iva,
                     corrispondenti.indirizzo_per_segnatura,
                     corrispondenti.cap_per_segnatura,
                     corrispondenti.comune_per_segnatura,
                     corrispondenti.provincia_per_segnatura,
                     corrispondenti.email,
                     corrispondenti.fax,
                     NVL (corrispondenti.conoscenza, 'N'),
                     d_tipo_indirizzo,
                     corrispondenti.tipo_rapporto,
                     corrispondenti.tipo_soggetto,
                     NULL,
                     NULL,
                     corrispondenti.id_documento,
                     d_id_modalita_invio_ricezione,
                     corrispondenti.cod_amm,
                     corrispondenti.descrizione_amm,
                     corrispondenti.indirizzo_amm,
                     corrispondenti.cap_amm,
                     corrispondenti.comune_amm,
                     corrispondenti.sigla_prov_amm,
                     corrispondenti.mail_amm,
                     corrispondenti.fax_amm,
                     corrispondenti.cod_aoo,
                     corrispondenti.descrizione_aoo,
                     corrispondenti.indirizzo_aoo,
                     corrispondenti.cap_aoo,
                     corrispondenti.comune_aoo,
                     corrispondenti.sigla_prov_aoo,
                     corrispondenti.mail_aoo,
                     corrispondenti.fax_aoo,
                     corrispondenti.cod_uo,
                     corrispondenti.descrizione_uo,
                     corrispondenti.indirizzo_uo,
                     corrispondenti.cap_uo,
                     corrispondenti.comune_uo,
                     corrispondenti.sigla_prov_uo,
                     corrispondenti.mail_uo,
                     corrispondenti.fax_uo,
                     corrispondenti.utente_inserimento,
                     corrispondenti.data_inserimento,
                     corrispondenti.utente_aggiornamento,
                     corrispondenti.data_aggiornamento,
                     corrispondenti.REGISTRATA_CONSEGNA,
                     corrispondenti.REG_CONSEGNA_AGGIORNAMENTO,
                     corrispondenti.REG_CONSEGNA_ANNULLAMENTO,
                     corrispondenti.REG_CONSEGNA_CONFERMA,
                     corrispondenti.RICEVUTA_CONFERMA,
                     corrispondenti.RICEVUTA_ECCEZIONE,
                     corrispondenti.RICEVUTO_AGGIORNAMENTO,
                     corrispondenti.RICEVUTO_ANNULLAMENTO,
                     corrispondenti.RIC_MANCATA_CONSEGNA,
                     corrispondenti.RIC_MANCATA_CONSEGNA_AGG,
                     corrispondenti.RIC_MANCATA_CONSEGNA_ANN,
                     corrispondenti.RIC_MANCATA_CONSEGNA_CONF);
               END LOOP;
            END;

            /******************************************
                          CREA SMISTAMENTI
            ******************************************/
            riempi_temp_dati_rifiuto (p.id_documento, p.dati_ripudio);

            DECLARE
               d_progr_tras          NUMBER;
               d_dal_tras            DATE;
               d_ottica_tras         VARCHAR2 (100);

               d_progr_smis          NUMBER;
               d_dal_smis            DATE;
               d_ottica_smis         VARCHAR2 (100);

               d_stato_smistamento   VARCHAR2 (100);

               d_stringa_data        VARCHAR2 (100) := ' in data ';
               d_stringa_motivo      VARCHAR2 (100)
                                        := ' per il seguente motivo: ';
            BEGIN
               FOR smistamenti IN c_smistamenti (p.id_documento,
                                                 p.idrif,
                                                 p.codice_amministrazione,
                                                 p.codice_aoo)
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
                     calcola_unita (smistamenti.ufficio_trasmissione,
                                    smistamenti.smistamento_dal,
                                    d_progr_tras,
                                    d_dal_tras,
                                    d_ottica_tras);
                     DBMS_OUTPUT.put_line ('------ Calcola unita ------');
                     DBMS_OUTPUT.put_line (smistamenti.ufficio_trasmissione);
                     DBMS_OUTPUT.put_line (smistamenti.smistamento_dal);
                     DBMS_OUTPUT.put_line (
                        TO_CHAR (d_dal_tras, 'dd/mm/yyyy'));
                  END IF;

                  /******************************************
                          Calcolo UNITA_SMISTAMENTO
                  ******************************************/
                  IF smistamenti.ufficio_smistamento IS NOT NULL
                  THEN
                     calcola_unita (smistamenti.ufficio_smistamento,
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
                     IF smistamenti.motivo_rifiuto IS NOT NULL
                     THEN
                        d_stato_smistamento := 'STORICO';
                     ELSE
                        d_stato_smistamento := 'DA_RICEVERE';
                     END IF;
                  ELSIF smistamenti.stato_smistamento = 'C'
                  THEN
                     d_stato_smistamento := 'IN_CARICO';
                  ELSIF smistamenti.stato_smistamento = 'E'
                  THEN
                     d_stato_smistamento := 'ESEGUITO';
                  ELSIF smistamenti.stato_smistamento = 'F'
                  THEN
                     d_stato_smistamento := 'STORICO';
                  END IF;

                  crea_smistamento (d_id_doc,
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
                                    NULL               /* UTENTE_ASSEGNANTE */
                                        ,
                                    smistamenti.codice_assegnatario,
                                    smistamenti.assegnazione_dal,
                                    smistamenti.note,
                                    smistamenti.utente_inserimento,
                                    smistamenti.data_inserimento,
                                    smistamenti.utente_aggiornamento,
                                    smistamenti.data_aggiornamento,
                                    smistamenti.id_documento, /* ID_DOCUMENTO_ESTERNO */
                                    smistamenti.utente_rifiuto,
                                    smistamenti.data_rifiuto,
                                    smistamenti.motivo_rifiuto);
               END LOOP;
            END;

            /******************************************
                          CREA ALLEGATI
            ******************************************/
            DECLARE
               d_id_tipo_allegato   NUMBER;
               d_sequenza           NUMBER := 1;
            BEGIN
               FOR allegati IN c_allegati (p.idrif)
               LOOP
                  /*----------------------------------------
                           CREA DOCUMENTO ALLEGATO
                  ----------------------------------------*/
                  DECLARE
                     d_stato         VARCHAR2 (100);
                     d_id_doc_alle   NUMBER;
                  BEGIN
                     IF p.stato_pr = 'DF'
                     THEN
                        d_stato := 'DA_FIRMARE';
                     ELSIF p.stato_pr = 'NF'
                     THEN
                        d_stato := 'DA_NON_FIRMARE';
                     ELSIF p.stato_pr = 'F'
                     THEN
                        d_stato := 'FIRMATO';
                     ELSE
                        d_stato := '';
                     END IF;

                     d_id_tipo_allegato :=
                        get_id_tipo_allegato (allegati.tipo_allegato);

                     /*----------------------------------------
                                 CREA ALLEGATO
                     ----------------------------------------*/
                     d_id_doc_alle :=
                        crea_allegato (allegati.id_documento,
                                       d_id_ente,
                                       allegati.descrizione,
                                       allegati.numero_pag,
                                       allegati.quantita,
                                       allegati.origine_doc,
                                       allegati.ubicazione_doc_originale,
                                       d_id_tipo_allegato,
                                       p.riservato,
                                       d_sequenza,
                                       d_stato,
                                       allegati.valido,
                                       allegati.utente_ins,
                                       allegati.data_ins,
                                       allegati.utente_upd,
                                       allegati.data_upd);
                     d_sequenza := d_sequenza + 1;

                     /*----------------------------------------
                     CREA collegamento tra DOCUMENTO e ALLEGATO
                     ----------------------------------------*/
                     crea_collegamento (d_id_doc,
                                        d_id_doc_alle,
                                        'ALLEGATO',
                                        allegati.valido,
                                        allegati.data_ins,
                                        allegati.data_upd,
                                        allegati.utente_ins,
                                        allegati.utente_upd);

                     /*----------------------------------------
                                 CREA FILE ALLEGATO
                     ----------------------------------------*/
                     DECLARE
                        d_id_file_doc   NUMBER;
                        d_sequenza      NUMBER := 0;
                     BEGIN
                        FOR file_alle IN c_file_alle (allegati.id_documento)
                        LOOP
                           d_id_file_doc :=
                              crea_file_documento (d_id_doc_alle,
                                                   file_alle.id_oggetto_file,
                                                   file_alle.utente_ins,
                                                   file_alle.data_ins,
                                                   file_alle.utente_upd,
                                                   file_alle.data_upd,
                                                   'FILE_ALLEGATO',
                                                   file_alle.filename,
                                                   d_sequenza,
                                                   NULL);
                           d_sequenza := d_sequenza + 1;
                        END LOOP;
                     END;
                  END;
               END LOOP;
            END;

            /******************************************
                  CREA COLLEGAMENTO AL PRECEDENTE
            ******************************************/
            DECLARE
               d_id_prec             NUMBER;
               d_id_tipo_prot_prec   NUMBER;
            BEGIN
               FOR prec IN c_prec (p.id_documento, p.categoria)
               LOOP
                  BEGIN
                     SELECT id_documento
                       INTO d_id_prec
                       FROM gdo_documenti
                      WHERE id_documento_esterno = prec.id_documento;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        /* calcolo flusso per la categoria di protocolli */
                        d_id_tipo_prot_prec :=
                           get_id_tipo_protocollo_default (p.categoria);
                        d_id_prec :=
                           crea_protocollo_esterno (
                              prec.id_documento,
                              1,
                              'Y',
                              prec.riservato,
                              d_id_tipo_prot_prec,
                              prec.oggetto,
                              prec.annullato,
                              prec.anno,
                              prec.numero,
                              prec.tipo_registro,
                              prec.data,
                              prec.modalita,
                              prec.unita_protocollante,
                              prec.utente_protocollante,
                              prec.utente_protocollante,
                              prec.data_aggiornamento,
                              prec.utente_aggiornamento,
                              prec.data_aggiornamento);
                        NULL;
                  END;

                  crea_collegamento (d_id_doc,
                                     d_id_prec,
                                     prec.tipo_relazione,
                                     'Y',
                                     prec.data_agg_rif,
                                     prec.data_agg_rif,
                                     prec.uten_agg_rif,
                                     prec.uten_agg_rif);
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
                          gdm_cartelle cart_fasc
                    WHERE     links.id_oggetto = p.id_documento
                          AND fasc.codice_amministrazione =
                                 p.codice_amministrazione
                          AND fasc.codice_aoo = p.codice_aoo
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
                          AND (   fasc.class_cod <> p.class_cod
                               OR fasc.class_dal <> p.class_dal
                               OR fasc.fascicolo_anno <> p.fascicolo_anno
                               OR fasc.fascicolo_numero <> p.fascicolo_numero)
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
                          gdm_cartelle cart_clas
                    WHERE     links.id_oggetto = p.id_documento
                          AND clas.codice_amministrazione =
                                 p.codice_amministrazione
                          AND clas.codice_aoo = p.codice_aoo
                          AND tipo_oggetto = 'D'
                          AND cart_clas.id_cartella = links.id_cartella
                          AND docu_clas.id_documento = clas.id_documento
                          AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND NVL (cart_clas.stato, 'BO') <> 'CA'
                          AND (   clas.class_cod <> p.class_cod
                               OR clas.class_dal <> p.class_dal))
            LOOP
               DECLARE
                  d_id_class           NUMBER;
                  d_id_fasc            NUMBER;
                  d_fascicolo_numero   VARCHAR2 (255);
               BEGIN
                  d_id_class := '';
                  d_id_fasc := '';
                  d_fascicolo_numero := LTRIM (tito.fascicolo_numero, '0');

                  calcola_titolario (tito.class_cod,
                                     tito.class_dal,
                                     tito.fascicolo_anno,
                                     d_fascicolo_numero,
                                     d_id_ente,
                                     d_id_class,
                                     d_id_fasc);
                  crea_titolario (d_id_doc,
                                  d_id_class,
                                  d_id_fasc,
                                  tito.utente_aggiornamento,
                                  tito.data_aggiornamento,
                                  tito.utente_aggiornamento,
                                  tito.data_aggiornamento);
               END;
            END LOOP;

            /******************************************
                          CREA ITER
                          TODO GESTIONE MODELLO!!
            ******************************************/
            IF p_attiva_iter = 1
            THEN
               BEGIN
                  SELECT iter.id_cfg_iter,
                         step.id_cfg_step,
                         comp.id_cfg_competenza,
                         comp.cancellazione,
                         comp.lettura,
                         comp.modifica
                    INTO d_id_cfg_iter,
                         d_id_cfg_step,
                         d_id_cfg_competenza,
                         d_cancellazione,
                         d_lettura,
                         d_modifica
                    FROM gdo_tipi_documento tido,
                         agp_tipi_protocollo tipr,
                         wkf_cfg_iter iter,
                         wkf_cfg_step step,
                         wkf_cfg_competenze comp
                   WHERE     tipr.id_tipo_protocollo = d_id_tipo_prot
                         AND tipr.id_tipo_protocollo = tido.id_tipo_documento
                         AND id_ente = d_id_ente
                         AND iter.progressivo = progressivo_cfg_iter
                         AND iter.stato = 'IN_USO'
                         AND step.id_cfg_iter = iter.id_cfg_iter
                         AND step.sequenza = 0                   -- PRIMO STEP
                         AND comp.id_cfg_step = step.id_cfg_step
                         AND comp.assegnazione = 'IN'
                         AND comp.id_attore =
                                NVL (step.id_attore, comp.id_attore);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     RAISE;
                  WHEN TOO_MANY_ROWS
                  THEN
                     BEGIN
                        SELECT iter.id_cfg_iter,
                               step.id_cfg_step,
                               comp.id_cfg_competenza,
                               comp.cancellazione,
                               comp.lettura,
                               comp.modifica
                          INTO d_id_cfg_iter,
                               d_id_cfg_step,
                               d_id_cfg_competenza,
                               d_cancellazione,
                               d_lettura,
                               d_modifica
                          FROM gdo_tipi_documento tido,
                               agp_tipi_protocollo tipr,
                               wkf_cfg_iter iter,
                               wkf_cfg_step step,
                               wkf_cfg_competenze comp
                         WHERE     tipr.id_tipo_protocollo = d_id_tipo_prot
                               AND tipr.id_tipo_protocollo =
                                      tido.id_tipo_documento
                               AND id_ente = d_id_ente
                               AND iter.progressivo = progressivo_cfg_iter
                               AND iter.stato = 'IN_USO'
                               AND step.id_cfg_iter = iter.id_cfg_iter
                               AND step.sequenza = 0             -- PRIMO STEP
                               AND comp.id_cfg_step = step.id_cfg_step
                               AND comp.assegnazione = 'IN'
                               AND comp.id_attore =
                                      NVL (step.id_attore, comp.id_attore)
                               AND comp.id_attore IN (SELECT id_attore
                                                        FROM wkf_diz_attori
                                                       WHERE nome =
                                                                'Utente Competenze Funzionali');
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           RAISE;
                     END;
               END;

               DECLARE
                  d_id_engine_iter            NUMBER;
                  d_id_engine_step            NUMBER;
                  d_id_engine_attore          NUMBER;
                  d_id_documento_competenza   NUMBER;
                  d_id_revisione              NUMBER;
               BEGIN
                  SELECT hibernate_sequence.NEXTVAL
                    INTO d_id_engine_iter
                    FROM DUAL;

                  INSERT INTO WKF_ENGINE_ITER (ID_ENGINE_ITER,
                                               VERSION,
                                               ID_CFG_ITER,
                                               DATA_INIZIO,
                                               DATA_INS,
                                               ENTE,
                                               DATA_UPD,
                                               UTENTE_INS,
                                               UTENTE_UPD)
                       VALUES (d_id_engine_iter,
                               0,
                               d_id_cfg_iter,
                               SYSDATE,
                               SYSDATE,
                               p.codice_amministrazione,
                               SYSDATE,
                               NVL (p.utente_protocollante, 'RPI'),
                               NVL (p.utente_protocollante, 'RPI'));

                  d_id_revisione := crea_revinfo (SYSTIMESTAMP);



                  INSERT INTO WKF_ENGINE_ITER_LOG (ID_ENGINE_ITER,
                                                   REV,
                                                   DATA_INIZIO,
                                                   DATA_INIZIO_MOD,
                                                   DATA_INS,
                                                   DATE_CREATED_MOD,
                                                   DATA_UPD,
                                                   LAST_UPDATED_MOD,
                                                   ID_CFG_ITER,
                                                   CFG_ITER_MOD,
                                                   ENTE,
                                                   ENTE_MOD,
                                                   UTENTE_INS,
                                                   UTENTE_INS_MOD,
                                                   UTENTE_UPD,
                                                   UTENTE_UPD_MOD)
                       VALUES (d_id_engine_iter,
                               d_id_revisione,
                               SYSDATE,
                               1,
                               SYSDATE,
                               1,
                               SYSDATE,
                               1,
                               d_id_cfg_iter,
                               1,
                               p.codice_amministrazione,
                               1,
                               NVL (p.utente_protocollante, 'RPI'),
                               1,
                               NVL (p.utente_protocollante, 'RPI'),
                               1);

                  UPDATE GDO_DOCUMENTI
                     SET ID_ENGINE_ITER = d_id_engine_iter
                   WHERE id_documento = d_id_doc;

                  SELECT hibernate_sequence.NEXTVAL
                    INTO d_id_engine_step
                    FROM DUAL;

                  INSERT INTO WKF_ENGINE_STEP (ID_ENGINE_STEP,
                                               VERSION,
                                               ID_CFG_STEP,
                                               DATA_INIZIO,
                                               DATA_INS,
                                               ID_ENGINE_ITER,
                                               DATA_UPD,
                                               UTENTE_INS,
                                               UTENTE_UPD)
                       VALUES (d_id_engine_step,
                               0,
                               d_id_cfg_step,
                               SYSDATE,
                               SYSDATE,
                               d_id_engine_iter,
                               SYSDATE,
                               NVL (p.utente_protocollante, 'RPI'),
                               NVL (p.utente_protocollante, 'RPI'));

                  UPDATE WKF_ENGINE_ITER
                     SET ID_STEP_CORRENTE = d_id_engine_step
                   WHERE ID_ENGINE_ITER = d_id_engine_iter;

                  SELECT hibernate_sequence.NEXTVAL
                    INTO d_id_engine_attore
                    FROM DUAL;

                  IF    (    p.categoria = 'PEC'
                         AND p.anno IS NOT NULL
                         AND p.numero IS NOT NULL)
                     OR p.categoria <> 'PEC'
                  THEN
                     INSERT INTO WKF_ENGINE_STEP_ATTORI (ID_ENGINE_ATTORE,
                                                         VERSION,
                                                         DATA_INS,
                                                         DATA_UPD,
                                                         ID_ENGINE_STEP,
                                                         UTENTE,
                                                         UTENTE_INS,
                                                         UTENTE_UPD)
                          VALUES (d_id_engine_attore,
                                  0,
                                  SYSDATE,
                                  SYSDATE,
                                  d_id_engine_step,
                                  NVL (p.utente_protocollante, 'RPI'),
                                  NVL (p.utente_protocollante, 'RPI'),
                                  NVL (p.utente_protocollante, 'RPI'));
                  END IF;

                  IF     p.categoria = 'PEC'
                     AND p.anno IS NULL
                     AND p.numero IS NULL
                  THEN
                     -- hanno competenza sul documento tutti gli utenti con privilegio
                     -- PMAILT
                     -- PMAILI se trattasi della casella istituzionale
                     -- PMAILU se trattasi di casella legata ad un ufficio
                     DECLARE
                        d_destinatari        VARCHAR2 (32000);
                        d_destinatari_memo   VARCHAR2 (32000);
                        d_destinatario       VARCHAR2 (32000);
                        d_id_ente            NUMBER;

                        d_numero_virgole     NUMBER;
                        d_loop               NUMBER := 0;
                     BEGIN
                        BEGIN
                           SELECT REPLACE (
                                     REPLACE (
                                           ','
                                        || REPLACE (destinatari, ';', ',')
                                        || ','
                                        || REPLACE (destinatari_conoscenza,
                                                    ';',
                                                    ',')
                                        || ',',
                                        ',,',
                                        ','),
                                     ',,',
                                     ',')
                                     mail,
                                  p.id_ente
                             INTO d_destinatari_memo, d_id_ente
                             FROM gdm_seg_memo_protocollo m,
                                  agp_proto_view p,
                                  gdm_riferimenti r
                            WHERE     p.id_documento = p_id_documento_gdm
                                  AND r.tipo_relazione = 'MAIL'
                                  AND r.id_documento_rif = m.id_documento
                                  AND r.id_documento = p.id_documento;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              raise_application_error (
                                 -20999,
                                    'Impossibile determinare il messaggio da cui il documento identificato da id '
                                 || p_id_documento_gdm
                                 || ' e'' stato generato.');
                        END;

                        d_destinatari_memo :=
                           nvl(trim(SUBSTR (d_destinatari_memo, 2, LENGTH (d_destinatari_memo) - 2)),',');
                        d_destinatari := d_destinatari_memo;
                        DBMS_OUTPUT.put_line (
                           'd_destinatari:' || d_destinatari);

                        d_numero_virgole :=
                           afc.countoccurrenceof (d_destinatari, ',');

                        WHILE d_loop <= d_numero_virgole
                        LOOP
                           d_destinatario :=
                              TRIM (AFC.GET_SUBSTR (d_destinatari, ','));

                           IF    d_destinatario IS NOT NULL
                              OR (    d_destinatario IS NULL
                                  AND TRIM(d_destinatari_memo) =',')
                           THEN
                              SELECT LOWER (
                                        SUBSTR (
                                           d_destinatario,
                                           INSTR (d_destinatario, '<') + 1,
                                           DECODE (
                                              INSTR (d_destinatario, '>'),
                                              0, LENGTH (d_destinatario),
                                                INSTR (d_destinatario, '>')
                                              - INSTR (d_destinatario, '<')
                                              - 1)))
                                INTO d_destinatario
                                FROM DUAL;

                              DBMS_OUTPUT.put_line (
                                 'd_destinatario:' || d_destinatario);

                              FOR utenti
                                 IN (SELECT r.utente
                                       FROM so4_v_unita_organizzative_pubb u,
                                            so4_v_utenti_ruoli_sogg_uo r,
                                            ag_priv_utente_tmp ut
                                      WHERE     u.codice IN (SELECT COD_UO
                                                               FROM seg_uo_mail
                                                              WHERE LOWER (
                                                                       TRIM (
                                                                          email)) =
                                                                       d_destinatario)
                                            AND SYSDATE BETWEEN u.dal
                                                            AND NVL (
                                                                   u.al,
                                                                   TO_DATE (
                                                                      3333333,
                                                                      'j'))
                                            AND r.uo_progr = u.progr
                                            AND r.uo_dal = u.dal
                                            AND r.ottica = u.ottica
                                            AND SYSDATE BETWEEN r.comp_dal
                                                            AND NVL (
                                                                   r.comp_al,
                                                                   TO_DATE (
                                                                      3333333,
                                                                      'j'))
                                            AND ut.utente = r.utente
                                            AND ut.privilegio = 'PMAILU'
                                            AND ut.unita = u.codice
                                            AND SYSDATE BETWEEN ut.dal
                                                            AND NVL (
                                                                   ut.al,
                                                                   TO_DATE (
                                                                      3333333,
                                                                      'j'))
                                     UNION
                                     SELECT utente
                                       FROM ag_priv_utente_tmp ut
                                      WHERE     privilegio = 'PMAILI'
                                            AND SYSDATE BETWEEN ut.dal
                                                            AND NVL (
                                                                   ut.al,
                                                                   TO_DATE (
                                                                      3333333,
                                                                      'j'))
                                            AND (   d_destinatario IS NULL
                                                 OR NOT EXISTS
                                                       (SELECT 1
                                                          FROM seg_uo_mail
                                                         WHERE LOWER (
                                                                  TRIM (
                                                                     email)) =
                                                                  d_destinatario)
                                                 OR d_destinatario IN (SELECT LOWER (
                                                                                 TRIM (
                                                                                    inte.indirizzo))
                                                                         FROM so4_aoo aoo,
                                                                              so4_indirizzi_telematici inte
                                                                        WHERE     inte.id_aoo(+) =
                                                                                     aoo.progr_aoo
                                                                              AND inte.tipo_entita(+) =
                                                                                     'AO'
                                                                              AND inte.tipo_indirizzo(+) =
                                                                                     'I'
                                                                              AND aoo.codice_amministrazione =
                                                                                     GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                                                                                        'CODICE_AMM',
                                                                                        d_id_ente)
                                                                              AND aoo.codice_aoo =
                                                                                     GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                                                                                        'CODICE_AOO',
                                                                                        d_id_ente)
                                                                              AND aoo.al
                                                                                     IS NULL))
                                     UNION
                                     SELECT utente
                                       FROM ag_priv_utente_tmp ut
                                      WHERE privilegio = 'PMAILT')
                              LOOP
                                 DBMS_OUTPUT.put_line (
                                    'utente:' || utenti.utente);

                                 SELECT hibernate_sequence.NEXTVAL
                                   INTO d_id_documento_competenza
                                   FROM DUAL;

                                 INSERT
                                   INTO GDO_DOCUMENTI_COMPETENZE (
                                           ID_DOCUMENTO_COMPETENZA,
                                           VERSION,
                                           CANCELLAZIONE,
                                           ID_CFG_COMPETENZA,
                                           LETTURA,
                                           MODIFICA,
                                           ID_DOCUMENTO,
                                           UTENTE)
                                 VALUES (d_id_documento_competenza,
                                         0,
                                         d_cancellazione,
                                         d_id_cfg_competenza,
                                         d_lettura,
                                         d_modifica,
                                         d_id_doc,
                                         utenti.utente);
                              END LOOP;
                           END IF;

                           d_loop := d_loop + 1;
                        END LOOP;
                     END;
                  END IF;
               END;
            END IF;

            IF p.categoria = 'LETTERA'
            THEN
               UPDATE gdm_spr_lettere_uscita
                  SET key_iter_lettera = -1
                WHERE id_documento = p_id_documento_gdm;
            ELSIF p.categoria = 'PEC'
            THEN
               UPDATE gdm_spr_protocolli_intero
                  SET key_iter_protocollo = -1
                WHERE id_documento = p_id_documento_gdm;
            ELSIF p.categoria = 'PROTOCOLLO'
            THEN
               UPDATE gdm_spr_protocolli
                  SET key_iter_protocollo = -1
                WHERE id_documento = p_id_documento_gdm;
            END IF;

            /*-----------------------------------------------------------------------*/
            /*                        GESTIONE STORICO                               */
            /*-----------------------------------------------------------------------*/
            DECLARE
               d_trasco_storico   VARCHAR2 (1) := 'N';
            BEGIN
               IF p.anno IS NULL
               THEN
                  d_trasco_storico := 'Y';
               ELSIF p_trasco_storico = 1
               THEN
                  elimina_storico_documento (d_id_doc);
                  AGP_TRASCO_STORICO_PKG.crea (p_id_documento_gdm);
                  d_trasco_storico := 'Y';
               END IF;

               INSERT
                 INTO AGP_TRASCO_STORICO_LOG (ID_DOCUMENTO,
                                              ID_DOCUMENTO_ESTERNO,
                                              TRASCO_STORICO)
               VALUES (d_id_doc, p_id_documento_gdm, d_trasco_storico);
            END;
         END LOOP;
      END IF;

      RETURN d_id_doc;
   END;

   /* Fine crea_protocollo */

   FUNCTION crea_doc_da_fasc_agspr (p_id_documento_gdm NUMBER)
      RETURN NUMBER
   IS
      d_id_ente                 NUMBER := 1;

      d_id_doc                  NUMBER;
      d_id_rev                  NUMBER;
      d_id_tipo_prot            NUMBER;

      d_id_classificazione      NUMBER;
      d_id_fascicolo            NUMBER;

      d_progr_uo                NUMBER;
      d_dal_uo                  DATE;
      d_ottica_uo               VARCHAR2 (100);

      d_id_schema_protocollo    NUMBER;

      d_id_doc_dati_scarto      NUMBER;
      /*
            d_id_cfg_iter                   NUMBER;
            d_id_cfg_step                   NUMBER;
            d_id_cfg_competenza             NUMBER;

            d_cancellazione                 VARCHAR2 (100);
            d_lettura                       VARCHAR2 (100);
            d_modifica                      VARCHAR2 (100);
      */

      d_controllo_funzionario   VARCHAR2 (1);
      d_controllo_firmatario    VARCHAR2 (1);

      d_categoria               VARCHAR2 (255) := 'DA_NON_PROTOCOLLARE';

      d_continua                BOOLEAN := TRUE;

      d_fascicolo_numero        VARCHAR2 (255);
   BEGIN
      /******************************************************************************/
      /******************************************************************************/
      /*************************** Inizio crea_doc_da_fasc ***************************/
      /******************************************************************************/
      /******************************************************************************/
      verifica_uso_maschere_zk (p_id_documento_gdm);
      ver_esistenza_doc_da_fasc_gdm (p_id_documento_gdm);

      IF esiste_doc_trascodificato (p_id_documento_gdm) = 0
      THEN
         FOR p
            IN (SELECT p.*,
                       d_categoria categoria,
                       e.id_ente,
                       s.utente_aggiornamento utente_ins,
                       s.data_aggiornamento data_ins,
                       d.utente_aggiornamento utente_upd,
                       d.data_aggiornamento data_upd
                  FROM gdm_spr_da_fascicolare p,
                       gdm_documenti d,
                       gdm_stati_documento s,
                       gdo_enti e
                 WHERE     E.AMMINISTRAZIONE = p.codice_amministrazione
                       AND E.Aoo = p.codice_aoo
                       AND p.id_documento = p_id_documento_gdm
                       AND d.id_documento = p.id_documento
                       AND s.id_stato IN (SELECT MIN (id_stato)
                                            FROM gdm_stati_documento
                                           WHERE id_documento =
                                                    d.id_documento))
         LOOP
            /* calcolo flusso per la categoria di protocolli */
            IF d_id_tipo_prot IS NULL
            THEN
               d_id_tipo_prot := get_id_tipo_protocollo_default (p.categoria);
            END IF;

            DBMS_OUTPUT.put_line ('d_id_tipo_prot:' || d_id_tipo_prot);

            d_id_ente := NVL (p.id_ente, 1);

            /******************************************
                    Calcolo UNITA_PROTOCOLLANTE
            ******************************************/
            IF p.unita_protocollante IS NOT NULL
            THEN
               calcola_unita (p.unita_protocollante,
                              p.data,
                              d_progr_uo,
                              d_dal_uo,
                              d_ottica_uo);
            END IF;

            /******************************************
               Calcolo CLASSIFICAZIONE E FASCICOLO
            ******************************************/
            d_fascicolo_numero := LTRIM (p.fascicolo_numero, '0');
            calcola_titolario (p.class_cod,
                               p.class_dal,
                               p.fascicolo_anno,
                               d_fascicolo_numero,
                               d_id_ente,
                               d_id_classificazione,
                               d_id_fascicolo);



            /******************************************
                         CREA DOCUMENTO
            ******************************************/
            DECLARE
               d_stato   VARCHAR2 (100) := '';
            BEGIN
               crea_documento (p.id_documento,
                               d_id_ente,
                               'Y',
                               p.riservato,
                               p.utente_ins,
                               p.data_ins,
                               p.utente_upd,
                               p.data_upd,
                               d_stato,
                               'PROTOCOLLO',
                               NULL,
                               d_id_doc,
                               d_id_rev,
                               TRUE                     --p_trasco_storico = 1
                                   );
               DBMS_OUTPUT.PUT_LINE ('Crea doc d_id_rev ' || d_id_rev);
            END;

            /******************************************
                         CREA FILE DOCUMENTO
            ******************************************/
            DECLARE
               d_codice   VARCHAR2 (1000) := 'FILE_PRINCIPALE';
            BEGIN
               DECLARE
                  d_id_file_doc   NUMBER;
                  d_sequenza      NUMBER := 0;
                  d_firmato       VARCHAR2 (1) := NULL;
               BEGIN
                  FOR file_doc_da_fasc IN c_file_doc (p.id_documento)
                  LOOP
                     d_id_file_doc :=
                        crea_file_documento (
                           d_id_doc,
                           file_doc_da_fasc.id_oggetto_file,
                           file_doc_da_fasc.utente_ins,
                           file_doc_da_fasc.data_ins,
                           file_doc_da_fasc.utente_upd,
                           file_doc_da_fasc.data_upd,
                           d_codice,
                           file_doc_da_fasc.filename,
                           d_sequenza,
                           d_firmato);
                     d_sequenza := d_sequenza + 1;
                  END LOOP;
               END;
            END;

            /******************************************
                    UO PROTOCOLLANTE
            ******************************************/
            DECLARE
               d_id_doc_sogg   NUMBER;
            BEGIN
               d_id_doc_sogg :=
                  crea_documento_soggetto (d_id_doc,
                                           'UO_PROTOCOLLANTE',
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
                  crea_documento_soggetto (
                     d_id_doc,
                     'REDATTORE',
                     NVL (p.utente_protocollante, 'RPI'),
                     d_progr_uo,
                     d_dal_uo,
                     d_ottica_uo,
                     d_id_rev);
            END;

            /******************************************
                     Gestione dati SCARTO
            ******************************************/
            DECLARE
               d_stato   VARCHAR2 (100);
            BEGIN
               IF p.stato_scarto = 'PS'
               THEN
                  d_stato := 'PROPOSTO_PER_LO_SCARTO';
               ELSIF p.stato_scarto = 'AA'
               THEN
                  d_stato := 'ATTESA_APPROVAZIONE';
               ELSIF p.stato_scarto = 'SC'
               THEN
                  d_stato := 'SCARTATO';
               ELSIF p.stato_scarto = 'CO'
               THEN
                  d_stato := 'CONSERVATO';
               ELSIF p.stato_scarto = 'RR'
               THEN
                  d_stato := 'RICHIESTA_RIFIUTATA';
               END IF;

               IF d_stato IS NOT NULL
               THEN
                  d_id_doc_dati_scarto :=
                     crea_dati_scarto (d_stato,
                                       p.data_stato_scarto,
                                       p.numero_nulla_osta,
                                       p.data_nulla_osta,
                                       NVL (p.utente_protocollante, 'RPI'),
                                       p.data_ins);
               ELSE
                  d_id_doc_dati_scarto := NULL;
               END IF;
            END;

            /******************************************
                          TIPO PROTOCOLLO
            ******************************************/
            calcola_tipo_protocollo (d_id_tipo_prot,
                                     d_controllo_funzionario,
                                     d_controllo_firmatario);

            /******************************************
                         SCHEMA PROTOCOLLO
            ******************************************/
            IF p.tipo_documento IS NOT NULL
            THEN
               d_id_schema_protocollo :=
                  get_id_schema_protocollo (p.tipo_documento);
            END IF;

            /******************************************
                          CREA PROTOCOLLO
            ******************************************/
            DECLARE
               d_movimento        VARCHAR2 (100);
               d_stato_archivio   VARCHAR2 (100);
            BEGIN
               crea_protocollo (d_id_doc,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                d_movimento,
                                NULL,
                                p.data_ins,
                                p.oggetto,
                                d_id_classificazione,
                                d_id_fascicolo,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                d_id_schema_protocollo,
                                NULL,
                                d_stato_archivio,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                p.note,
                                d_id_tipo_prot,
                                d_controllo_funzionario,
                                d_controllo_firmatario,
                                p.idrif,
                                d_id_doc_dati_scarto,
                                NULL,
                                d_id_rev);
            END;

            /******************************************
                          CREA SMISTAMENTI
            ******************************************/
            riempi_temp_dati_rifiuto (p.id_documento, p.dati_ripudio);

            DECLARE
               d_progr_tras          NUMBER;
               d_dal_tras            DATE;
               d_ottica_tras         VARCHAR2 (100);

               d_progr_smis          NUMBER;
               d_dal_smis            DATE;
               d_ottica_smis         VARCHAR2 (100);

               d_stato_smistamento   VARCHAR2 (100);

               d_stringa_data        VARCHAR2 (100) := ' in data ';
               d_stringa_motivo      VARCHAR2 (100)
                                        := ' per il seguente motivo: ';
            BEGIN
               FOR smistamenti IN c_smistamenti (p.id_documento,
                                                 p.idrif,
                                                 p.codice_amministrazione,
                                                 p.codice_aoo)
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
                     calcola_unita (smistamenti.ufficio_trasmissione,
                                    smistamenti.smistamento_dal,
                                    d_progr_tras,
                                    d_dal_tras,
                                    d_ottica_tras);
                     DBMS_OUTPUT.put_line ('------ Calcola unita ------');
                     DBMS_OUTPUT.put_line (smistamenti.ufficio_trasmissione);
                     DBMS_OUTPUT.put_line (smistamenti.smistamento_dal);
                     DBMS_OUTPUT.put_line (
                        TO_CHAR (d_dal_tras, 'dd/mm/yyyy'));
                  END IF;

                  /******************************************
                          Calcolo UNITA_SMISTAMENTO
                  ******************************************/
                  IF smistamenti.ufficio_smistamento IS NOT NULL
                  THEN
                     calcola_unita (smistamenti.ufficio_smistamento,
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
                     IF smistamenti.motivo_rifiuto IS NOT NULL
                     THEN
                        d_stato_smistamento := 'STORICO';
                     ELSE
                        d_stato_smistamento := 'DA_RICEVERE';
                     END IF;
                  ELSIF smistamenti.stato_smistamento = 'C'
                  THEN
                     d_stato_smistamento := 'IN_CARICO';
                  ELSIF smistamenti.stato_smistamento = 'E'
                  THEN
                     d_stato_smistamento := 'ESEGUITO';
                  ELSIF smistamenti.stato_smistamento = 'F'
                  THEN
                     d_stato_smistamento := 'STORICO';
                  END IF;

                  crea_smistamento (d_id_doc,
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
                                    NULL               /* UTENTE_ASSEGNANTE */
                                        ,
                                    smistamenti.codice_assegnatario,
                                    smistamenti.assegnazione_dal,
                                    smistamenti.note,
                                    smistamenti.utente_inserimento,
                                    smistamenti.data_inserimento,
                                    smistamenti.utente_aggiornamento,
                                    smistamenti.data_aggiornamento,
                                    smistamenti.id_documento, /* ID_DOCUMENTO_ESTERNO */
                                    smistamenti.utente_rifiuto,
                                    smistamenti.data_rifiuto,
                                    smistamenti.motivo_rifiuto);
               END LOOP;
            END;

            /******************************************
                          CREA ALLEGATI
            ******************************************/
            DECLARE
               d_id_tipo_allegato   NUMBER;
               d_sequenza           NUMBER := 1;
            BEGIN
               FOR allegati IN c_allegati (p.idrif)
               LOOP
                  /*----------------------------------------
                           CREA DOCUMENTO ALLEGATO
                  ----------------------------------------*/
                  DECLARE
                     d_stato         VARCHAR2 (100);
                     d_id_doc_alle   NUMBER;
                  BEGIN
                     d_id_tipo_allegato :=
                        get_id_tipo_allegato (allegati.tipo_allegato);

                     /*----------------------------------------
                                 CREA ALLEGATO
                     ----------------------------------------*/
                     d_id_doc_alle :=
                        crea_allegato (allegati.id_documento,
                                       d_id_ente,
                                       allegati.descrizione,
                                       allegati.numero_pag,
                                       allegati.quantita,
                                       allegati.origine_doc,
                                       allegati.ubicazione_doc_originale,
                                       d_id_tipo_allegato,
                                       p.riservato,
                                       d_sequenza,
                                       d_stato,
                                       allegati.valido,
                                       allegati.utente_ins,
                                       allegati.data_ins,
                                       allegati.utente_upd,
                                       allegati.data_upd);
                     d_sequenza := d_sequenza + 1;

                     /*----------------------------------------
                     CREA collegamento tra DOCUMENTO e ALLEGATO
                     ----------------------------------------*/
                     crea_collegamento (d_id_doc,
                                        d_id_doc_alle,
                                        'ALLEGATO',
                                        allegati.valido,
                                        allegati.data_ins,
                                        allegati.data_upd,
                                        allegati.utente_ins,
                                        allegati.utente_upd);

                     /*----------------------------------------
                                 CREA FILE ALLEGATO
                     ----------------------------------------*/
                     DECLARE
                        d_id_file_doc   NUMBER;
                        d_sequenza      NUMBER := 0;
                     BEGIN
                        FOR file_alle IN c_file_alle (allegati.id_documento)
                        LOOP
                           d_id_file_doc :=
                              crea_file_documento (d_id_doc_alle,
                                                   file_alle.id_oggetto_file,
                                                   file_alle.utente_ins,
                                                   file_alle.data_ins,
                                                   file_alle.utente_upd,
                                                   file_alle.data_upd,
                                                   'FILE_ALLEGATO',
                                                   file_alle.filename,
                                                   d_sequenza,
                                                   NULL);
                           d_sequenza := d_sequenza + 1;
                        END LOOP;
                     END;
                  END;
               END LOOP;
            END;

            /******************************************
                  CREA COLLEGAMENTO AL PRECEDENTE
            ******************************************/
            DECLARE
               d_id_prec             NUMBER;
               d_id_tipo_prot_prec   NUMBER;
            BEGIN
               FOR prec IN c_prec (p.id_documento, d_categoria)
               LOOP
                  BEGIN
                     SELECT id_documento
                       INTO d_id_prec
                       FROM gdo_documenti
                      WHERE id_documento_esterno = prec.id_documento;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        /* calcolo flusso per la categoria di protocolli */
                        d_id_tipo_prot_prec :=
                           get_id_tipo_protocollo_default (p.categoria);
                        d_id_prec :=
                           crea_protocollo_esterno (
                              prec.id_documento,
                              1,
                              'Y',
                              prec.riservato,
                              d_id_tipo_prot_prec,
                              prec.oggetto,
                              prec.annullato,
                              prec.anno,
                              prec.numero,
                              prec.tipo_registro,
                              prec.data,
                              prec.modalita,
                              prec.unita_protocollante,
                              prec.utente_protocollante,
                              prec.utente_protocollante,
                              prec.data_aggiornamento,
                              prec.utente_aggiornamento,
                              prec.data_aggiornamento);
                        NULL;
                  END;

                  crea_collegamento (d_id_doc,
                                     d_id_prec,
                                     prec.tipo_relazione,
                                     'Y',
                                     prec.data_agg_rif,
                                     prec.data_agg_rif,
                                     prec.uten_agg_rif,
                                     prec.uten_agg_rif);
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
                          gdm_cartelle cart_fasc
                    WHERE     links.id_oggetto = p.id_documento
                          AND fasc.codice_amministrazione =
                                 p.codice_amministrazione
                          AND fasc.codice_aoo = p.codice_aoo
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
                          AND (   fasc.class_cod <> p.class_cod
                               OR fasc.class_dal <> p.class_dal
                               OR fasc.fascicolo_anno <> p.fascicolo_anno
                               OR fasc.fascicolo_numero <> p.fascicolo_numero)
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
                          gdm_cartelle cart_clas
                    WHERE     links.id_oggetto = p.id_documento
                          AND clas.codice_amministrazione =
                                 p.codice_amministrazione
                          AND clas.codice_aoo = p.codice_aoo
                          AND tipo_oggetto = 'D'
                          AND cart_clas.id_cartella = links.id_cartella
                          AND docu_clas.id_documento = clas.id_documento
                          AND NVL (docu_clas.stato_documento, 'BO') NOT IN ('CA',
                                                                            'RE',
                                                                            'PB')
                          AND cart_clas.id_documento_profilo =
                                 docu_clas.id_documento
                          AND NVL (cart_clas.stato, 'BO') <> 'CA'
                          AND (   clas.class_cod <> p.class_cod
                               OR clas.class_dal <> p.class_dal))
            LOOP
               DECLARE
                  d_id_class           NUMBER;
                  d_id_fasc            NUMBER;
                  d_fascicolo_numero   VARCHAR2 (255);
               BEGIN
                  d_id_class := '';
                  d_id_fasc := '';
                  d_fascicolo_numero := LTRIM (tito.fascicolo_numero, '0');

                  calcola_titolario (tito.class_cod,
                                     tito.class_dal,
                                     tito.fascicolo_anno,
                                     d_fascicolo_numero,
                                     d_id_ente,
                                     d_id_class,
                                     d_id_fasc);
                  crea_titolario (d_id_doc,
                                  d_id_class,
                                  d_id_fasc,
                                  tito.utente_aggiornamento,
                                  tito.data_aggiornamento,
                                  tito.utente_aggiornamento,
                                  tito.data_aggiornamento);
               END;
            END LOOP;
         /******************************************
                       CREA ITER
                       TODO GESTIONE MODELLO!!
         ******************************************/
         /*
                     IF p_attiva_iter = 1
                     THEN
                        BEGIN
                           SELECT iter.id_cfg_iter,
                                  step.id_cfg_step,
                                  comp.id_cfg_competenza,
                                  comp.cancellazione,
                                  comp.lettura,
                                  comp.modifica
                             INTO d_id_cfg_iter,
                                  d_id_cfg_step,
                                  d_id_cfg_competenza,
                                  d_cancellazione,
                                  d_lettura,
                                  d_modifica
                             FROM gdo_tipi_documento tido,
                                  agp_tipi_protocollo tipr,
                                  wkf_cfg_iter iter,
                                  wkf_cfg_step step,
                                  wkf_cfg_competenze comp
                            WHERE     tipr.id_tipo_protocollo = d_id_tipo_prot
                                  AND tipr.id_tipo_protocollo = tido.id_tipo_documento
                                  AND id_ente = d_id_ente
                                  AND iter.progressivo = progressivo_cfg_iter
                                  AND iter.stato = 'IN_USO'
                                  AND step.id_cfg_iter = iter.id_cfg_iter
                                  AND step.sequenza = 0                   -- PRIMO STEP
                                  AND comp.id_cfg_step = step.id_cfg_step
                                  AND comp.assegnazione = 'IN'
                                  AND comp.id_attore =
                                         NVL (step.id_attore, comp.id_attore);
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              RAISE;
                           WHEN TOO_MANY_ROWS
                           THEN
                              BEGIN
                                 SELECT iter.id_cfg_iter,
                                        step.id_cfg_step,
                                        comp.id_cfg_competenza,
                                        comp.cancellazione,
                                        comp.lettura,
                                        comp.modifica
                                   INTO d_id_cfg_iter,
                                        d_id_cfg_step,
                                        d_id_cfg_competenza,
                                        d_cancellazione,
                                        d_lettura,
                                        d_modifica
                                   FROM gdo_tipi_documento tido,
                                        agp_tipi_protocollo tipr,
                                        wkf_cfg_iter iter,
                                        wkf_cfg_step step,
                                        wkf_cfg_competenze comp
                                  WHERE     tipr.id_tipo_protocollo = d_id_tipo_prot
                                        AND tipr.id_tipo_protocollo =
                                               tido.id_tipo_documento
                                        AND id_ente = d_id_ente
                                        AND iter.progressivo = progressivo_cfg_iter
                                        AND iter.stato = 'IN_USO'
                                        AND step.id_cfg_iter = iter.id_cfg_iter
                                        AND step.sequenza = 0             -- PRIMO STEP
                                        AND comp.id_cfg_step = step.id_cfg_step
                                        AND comp.assegnazione = 'IN'
                                        AND comp.id_attore =
                                               NVL (step.id_attore, comp.id_attore)
                                        AND comp.id_attore IN (SELECT id_attore
                                                                 FROM wkf_diz_attori
                                                                WHERE nome =
                                                                         'Utente Competenze Funzionali');
                              EXCEPTION
                                 WHEN NO_DATA_FOUND
                                 THEN
                                    RAISE;
                              END;
                        END;

                        DECLARE
                           d_id_engine_iter            NUMBER;
                           d_id_engine_step            NUMBER;
                           d_id_engine_attore          NUMBER;
                           d_id_documento_competenza   NUMBER;
                           d_id_revisione              NUMBER;
                        BEGIN
                           SELECT hibernate_sequence.NEXTVAL
                             INTO d_id_engine_iter
                             FROM DUAL;

                           INSERT INTO WKF_ENGINE_ITER (ID_ENGINE_ITER,
                                                        VERSION,
                                                        ID_CFG_ITER,
                                                        DATA_INIZIO,
                                                        DATA_INS,
                                                        ENTE,
                                                        DATA_UPD,
                                                        UTENTE_INS,
                                                        UTENTE_UPD)
                                VALUES (d_id_engine_iter,
                                        0,
                                        d_id_cfg_iter,
                                        SYSDATE,
                                        SYSDATE,
                                        p.codice_amministrazione,
                                        SYSDATE,
                                        NVL (p.utente_protocollante, 'RPI'),
                                        NVL (p.utente_protocollante, 'RPI'));

                           d_id_revisione := crea_revinfo (SYSTIMESTAMP);



                           INSERT INTO WKF_ENGINE_ITER_LOG (ID_ENGINE_ITER,
                                                            REV,
                                                            DATA_INIZIO,
                                                            DATA_INIZIO_MOD,
                                                            DATA_INS,
                                                            DATE_CREATED_MOD,
                                                            DATA_UPD,
                                                            LAST_UPDATED_MOD,
                                                            ID_CFG_ITER,
                                                            CFG_ITER_MOD,
                                                            ENTE,
                                                            ENTE_MOD,
                                                            UTENTE_INS,
                                                            UTENTE_INS_MOD,
                                                            UTENTE_UPD,
                                                            UTENTE_UPD_MOD)
                                VALUES (d_id_engine_iter,
                                        d_id_revisione,
                                        SYSDATE,
                                        1,
                                        SYSDATE,
                                        1,
                                        SYSDATE,
                                        1,
                                        d_id_cfg_iter,
                                        1,
                                        p.codice_amministrazione,
                                        1,
                                        NVL (p.utente_protocollante, 'RPI'),
                                        1,
                                        NVL (p.utente_protocollante, 'RPI'),
                                        1);

                           UPDATE GDO_DOCUMENTI
                              SET ID_ENGINE_ITER = d_id_engine_iter
                            WHERE id_documento = d_id_doc;

                           SELECT hibernate_sequence.NEXTVAL
                             INTO d_id_engine_step
                             FROM DUAL;

                           INSERT INTO WKF_ENGINE_STEP (ID_ENGINE_STEP,
                                                        VERSION,
                                                        ID_CFG_STEP,
                                                        DATA_INIZIO,
                                                        DATA_INS,
                                                        ID_ENGINE_ITER,
                                                        DATA_UPD,
                                                        UTENTE_INS,
                                                        UTENTE_UPD)
                                VALUES (d_id_engine_step,
                                        0,
                                        d_id_cfg_step,
                                        SYSDATE,
                                        SYSDATE,
                                        d_id_engine_iter,
                                        SYSDATE,
                                        NVL (p.utente_protocollante, 'RPI'),
                                        NVL (p.utente_protocollante, 'RPI'));

                           UPDATE WKF_ENGINE_ITER
                              SET ID_STEP_CORRENTE = d_id_engine_step
                            WHERE ID_ENGINE_ITER = d_id_engine_iter;

                           SELECT hibernate_sequence.NEXTVAL
                             INTO d_id_engine_attore
                             FROM DUAL;

                           IF    (    p.categoria = 'PEC'
                                  AND p.anno IS NOT NULL
                                  AND p.numero IS NOT NULL)
                              OR p.categoria <> 'PEC'
                           THEN
                              INSERT INTO WKF_ENGINE_STEP_ATTORI (ID_ENGINE_ATTORE,
                                                                  VERSION,
                                                                  DATA_INS,
                                                                  DATA_UPD,
                                                                  ID_ENGINE_STEP,
                                                                  UTENTE,
                                                                  UTENTE_INS,
                                                                  UTENTE_UPD)
                                   VALUES (d_id_engine_attore,
                                           0,
                                           SYSDATE,
                                           SYSDATE,
                                           d_id_engine_step,
                                           NVL (p.utente_protocollante, 'RPI'),
                                           NVL (p.utente_protocollante, 'RPI'),
                                           NVL (p.utente_protocollante, 'RPI'));
                           END IF;

                           IF     p.categoria = 'PEC'
                              AND p.anno IS NULL
                              AND p.numero IS NULL
                           THEN
                              -- hanno competenza sul documento tutti gli utenti con privilegio
                              -- PMAILT
                              -- PMAILI se trattasi della casella istituzionale
                              -- PMAILU se trattasi di casella legata ad un ufficio
                              DECLARE
                                 d_destinatari        VARCHAR2 (32000);
                                 d_destinatari_memo   VARCHAR2 (32000);
                                 d_destinatario       VARCHAR2 (32000);
                                 d_id_ente            NUMBER;

                                 d_numero_virgole     NUMBER;
                                 d_loop               NUMBER := 0;
                              BEGIN
                                 BEGIN
                                    SELECT REPLACE (
                                              REPLACE (
                                                    ','
                                                 || REPLACE (destinatari, ';', ',')
                                                 || ','
                                                 || REPLACE (destinatari_conoscenza,
                                                             ';',
                                                             ',')
                                                 || ',',
                                                 ',,',
                                                 ','),
                                              ',,',
                                              ',')
                                              mail,
                                           p.id_ente
                                      INTO d_destinatari_memo, d_id_ente
                                      FROM gdm_seg_memo_protocollo m,
                                           agp_proto_view p,
                                           gdm_riferimenti r
                                     WHERE     p.id_documento = p_id_documento_gdm
                                           AND r.tipo_relazione = 'MAIL'
                                           AND r.id_documento_rif = m.id_documento
                                           AND r.id_documento = p.id_documento;
                                 EXCEPTION
                                    WHEN NO_DATA_FOUND
                                    THEN
                                       raise_application_error (
                                          -20999,
                                             'Impossibile determinare il messaggio da cui il documento identificato da id '
                                          || p_id_documento_gdm
                                          || ' e'' stato generato.');
                                 END;

                                 d_destinatari_memo :=
                                    SUBSTR (d_destinatari_memo,
                                            2,
                                            LENGTH (d_destinatari_memo) - 2);
                                 d_destinatari := d_destinatari_memo;
                                 DBMS_OUTPUT.put_line (
                                    'd_destinatari:' || d_destinatari);

                                 d_numero_virgole :=
                                    afc.countoccurrenceof (d_destinatari, ',');

                                 WHILE d_loop <= d_numero_virgole
                                 LOOP
                                    d_destinatario :=
                                       TRIM (AFC.GET_SUBSTR (d_destinatari, ','));

                                    IF    d_destinatario IS NOT NULL
                                       OR (    d_destinatario IS NULL
                                           AND d_destinatari_memo IS NULL)
                                    THEN
                                       SELECT LOWER (
                                                 SUBSTR (
                                                    d_destinatario,
                                                    INSTR (d_destinatario, '<') + 1,
                                                    DECODE (
                                                       INSTR (d_destinatario, '>'),
                                                       0, LENGTH (d_destinatario),
                                                         INSTR (d_destinatario, '>')
                                                       - INSTR (d_destinatario, '<')
                                                       - 1)))
                                         INTO d_destinatario
                                         FROM DUAL;

                                       DBMS_OUTPUT.put_line (
                                          'd_destinatario:' || d_destinatario);

                                       FOR utenti
                                          IN (SELECT r.utente
                                                FROM so4_v_unita_organizzative_pubb u,
                                                     so4_v_utenti_ruoli_sogg_uo r,
                                                     ag_priv_utente_tmp ut
                                               WHERE     u.codice IN (SELECT COD_UO
                                                                        FROM seg_uo_mail
                                                                       WHERE LOWER (
                                                                                TRIM (
                                                                                   email)) =
                                                                                d_destinatario)
                                                     AND SYSDATE BETWEEN u.dal
                                                                     AND NVL (
                                                                            u.al,
                                                                            TO_DATE (
                                                                               3333333,
                                                                               'j'))
                                                     AND r.uo_progr = u.progr
                                                     AND r.uo_dal = u.dal
                                                     AND r.ottica = u.ottica
                                                     AND SYSDATE BETWEEN r.comp_dal
                                                                     AND NVL (
                                                                            r.comp_al,
                                                                            TO_DATE (
                                                                               3333333,
                                                                               'j'))
                                                     AND ut.utente = r.utente
                                                     AND ut.privilegio = 'PMAILU'
                                                     AND ut.unita = u.codice
                                                     AND SYSDATE BETWEEN ut.dal
                                                                     AND NVL (
                                                                            ut.al,
                                                                            TO_DATE (
                                                                               3333333,
                                                                               'j'))
                                              UNION
                                              SELECT utente
                                                FROM ag_priv_utente_tmp ut
                                               WHERE     privilegio = 'PMAILI'
                                                     AND SYSDATE BETWEEN ut.dal
                                                                     AND NVL (
                                                                            ut.al,
                                                                            TO_DATE (
                                                                               3333333,
                                                                               'j'))
                                                     AND (   d_destinatario IS NULL
                                                          OR NOT EXISTS
                                                                (SELECT 1
                                                                   FROM seg_uo_mail
                                                                  WHERE LOWER (
                                                                           TRIM (
                                                                              email)) =
                                                                           d_destinatario)
                                                          OR d_destinatario IN (SELECT LOWER (
                                                                                          TRIM (
                                                                                             inte.indirizzo))
                                                                                  FROM so4_aoo aoo,
                                                                                       so4_indirizzi_telematici inte
                                                                                 WHERE     inte.id_aoo(+) =
                                                                                              aoo.progr_aoo
                                                                                       AND inte.tipo_entita(+) =
                                                                                              'AO'
                                                                                       AND inte.tipo_indirizzo(+) =
                                                                                              'I'
                                                                                       AND aoo.codice_amministrazione =
                                                                                              GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                                                                                                 'CODICE_AMM',
                                                                                                 d_id_ente)
                                                                                       AND aoo.codice_aoo =
                                                                                              GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                                                                                                 'CODICE_AOO',
                                                                                                 d_id_ente)
                                                                                       AND aoo.al
                                                                                              IS NULL))
                                              UNION
                                              SELECT utente
                                                FROM ag_priv_utente_tmp ut
                                               WHERE privilegio = 'PMAILT')
                                       LOOP
                                          DBMS_OUTPUT.put_line (
                                             'utente:' || utenti.utente);

                                          SELECT hibernate_sequence.NEXTVAL
                                            INTO d_id_documento_competenza
                                            FROM DUAL;

                                          INSERT
                                            INTO GDO_DOCUMENTI_COMPETENZE (
                                                    ID_DOCUMENTO_COMPETENZA,
                                                    VERSION,
                                                    CANCELLAZIONE,
                                                    ID_CFG_COMPETENZA,
                                                    LETTURA,
                                                    MODIFICA,
                                                    ID_DOCUMENTO,
                                                    UTENTE)
                                          VALUES (d_id_documento_competenza,
                                                  0,
                                                  d_cancellazione,
                                                  d_id_cfg_competenza,
                                                  d_lettura,
                                                  d_modifica,
                                                  d_id_doc,
                                                  utenti.utente);
                                       END LOOP;
                                    END IF;

                                    d_loop := d_loop + 1;
                                 END LOOP;
                              END;
                           END IF;
                        END;
                     END IF;
         */
         /*-----------------------------------------------------------------------*/
         /*                        GESTIONE STORICO                               */
         /*-----------------------------------------------------------------------*/
         /*
         DECLARE
            d_trasco_storico   VARCHAR2 (1) := 'N';
         BEGIN
            IF p.anno IS NULL
            THEN
               d_trasco_storico := 'Y';
            ELSIF p_trasco_storico = 1
            THEN
               elimina_storico_documento (d_id_doc);
               AGP_TRASCO_STORICO_PKG.crea (p_id_documento_gdm);
               d_trasco_storico := 'Y';
            END IF;

            INSERT
              INTO AGP_TRASCO_STORICO_LOG (ID_DOCUMENTO,
                                           ID_DOCUMENTO_ESTERNO,
                                           TRASCO_STORICO)
            VALUES (d_id_doc, p_id_documento_gdm, d_trasco_storico);
         END;
         */
         END LOOP;
      END IF;

      RETURN d_id_doc;
   END;

   /* Fine crea_doc_da_fasc_agspr */

   FUNCTION get_url_protocollo (p_id_documento_gdm NUMBER)
      RETURN VARCHAR2
   IS
      d_return      VARCHAR2 (32000);
      d_id_ente     NUMBER;
      d_categoria   VARCHAR2 (2000);
   BEGIN
      SELECT p.id_ente, categoria
        INTO d_id_ente, d_categoria
        FROM agp_proto_view p
       WHERE p.id_documento = p_id_documento_gdm;

      d_return :=
            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('AG_SERVER_URL',
                                                   d_id_ente)
         || '/Protocollo/standalone.zul?operazione=APRI_DOCUMENTO&tipoDocumento='
         || d_categoria
         || '&idDoc='
         || p_id_documento_gdm;
      RETURN d_return;
   END;

   /* Fine get_url_protocollo */

   PROCEDURE elimina_documento (p_id_documento       NUMBER,
                                p_elimina_doc_gdm    NUMBER DEFAULT 1)
   AS
      A_ID_PROTOCOLLO_DATI_SCARTO      NUMBER;
      A_ID_PROTOCOLLO_DATI_INTEROP     NUMBER;
      A_ID_PROTOCOLLO_DATI_EMERGENZA   NUMBER;
      A_ID_PROTOCOLLO_DATI_REG_GIORN   NUMBER;
      A_ID_DOCUMENTO_ESTERNO           NUMBER;
      A_IS_ALLEGATO                    NUMBER;
   BEGIN
      DBMS_OUTPUT.put_line ('prima  select gdo_documenti ' || p_id_documento);

      SELECT ID_DOCUMENTO_ESTERNO
        INTO A_ID_DOCUMENTO_ESTERNO
        FROM GDO_DOCUMENTI
       WHERE ID_DOCUMENTO = p_id_documento;

      DBMS_OUTPUT.put_line ('dopo  select gdo_documenti' || p_id_documento);

      elimina_storico_documento (p_id_documento);

      SELECT COUNT (*)
        INTO A_IS_ALLEGATO
        FROM GDO_ALLEGATI
       WHERE GDO_ALLEGATI.ID_DOCUMENTO = p_id_documento;

      BEGIN
         SELECT ID_PROTOCOLLO_DATI_SCARTO,
                ID_PROTOCOLLO_DATI_INTEROP,
                ID_PROTOCOLLO_DATI_EMERGENZA,
                ID_PROTOCOLLO_DATI_REG_GIORN
           INTO A_ID_PROTOCOLLO_DATI_SCARTO,
                A_ID_PROTOCOLLO_DATI_INTEROP,
                A_ID_PROTOCOLLO_DATI_EMERGENZA,
                A_ID_PROTOCOLLO_DATI_REG_GIORN
           FROM AGP_PROTOCOLLI
          WHERE ID_DOCUMENTO = p_id_documento;

         UPDATE AGP_PROTOCOLLI
            SET ID_PROTOCOLLO_DATI_SCARTO = NULL,
                ID_PROTOCOLLO_DATI_INTEROP = NULL,
                ID_PROTOCOLLO_DATI_EMERGENZA = NULL,
                ID_PROTOCOLLO_DATI_REG_GIORN = NULL
          WHERE ID_DOCUMENTO = p_id_documento;

         DELETE FROM AGP_PROTOCOLLI_DATI_SCARTO
               WHERE ID_PROTOCOLLO_DATI_SCARTO = A_ID_PROTOCOLLO_DATI_SCARTO;

         DELETE FROM AGP_PROTOCOLLI_DATI_SCARTO_LOG
               WHERE ID_PROTOCOLLO_DATI_SCARTO = A_ID_PROTOCOLLO_DATI_SCARTO;

         DELETE FROM AGP_PROTOCOLLI_DATI_INTEROP
               WHERE ID_PROTOCOLLO_DATI_INTEROP =
                        A_ID_PROTOCOLLO_DATI_INTEROP;

         DELETE FROM AGP_PROTOCOLLI_DATI_EMERGENZA
               WHERE ID_PROTOCOLLO_DATI_EMERGENZA =
                        A_ID_PROTOCOLLO_DATI_EMERGENZA;

         DELETE FROM AGP_PROTOCOLLI_DATI_REG_GIORN
               WHERE ID_PROTOCOLLO_DATI_REG_GIORN =
                        A_ID_PROTOCOLLO_DATI_REG_GIORN;


         DELETE FROM AGP_PROTOCOLLI_CORR_LOG
               WHERE ID_DOCUMENTO = p_id_documento;

         DELETE FROM AGP_PROTOCOLLI_CORR_INDIRIZZI
               WHERE ID_PROTOCOLLO_CORRISPONDENTE IN (SELECT ID_PROTOCOLLO_CORRISPONDENTE
                                                        FROM AGP_PROTOCOLLI_CORRISPONDENTI
                                                       WHERE ID_DOCUMENTO =
                                                                p_id_documento);

         DELETE FROM agp_messaggi_corrispondenti
               WHERE id_protocollo_corrispondente IN (SELECT id_protocollo_corrispondente
                                                        FROM AGP_PROTOCOLLI_CORRISPONDENTI
                                                       WHERE ID_DOCUMENTO =
                                                                p_id_documento);

         DELETE FROM AGP_PROTOCOLLI_CORRISPONDENTI
               WHERE ID_DOCUMENTO = p_id_documento;

         DELETE FROM AGP_PROTOCOLLI_RIF_TELEMATICI
               WHERE ID_DOCUMENTO = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      DELETE FROM AGP_DOCUMENTI_SMISTAMENTI
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_DOCUMENTI_TITOLARIO
            WHERE ID_DOCUMENTO = p_id_documento;

      DBMS_OUTPUT.put_line ('prima allegati');

      -- GESTIONE DEGLI ALLEGATI
      FOR I
         IN (SELECT GDO_DOCUMENTI_COLLEGATI.ID_COLLEGATO
               FROM GDO_DOCUMENTI_COLLEGATI, GDO_ALLEGATI
              WHERE     GDO_DOCUMENTI_COLLEGATI.ID_DOCUMENTO = p_id_documento
                    AND GDO_DOCUMENTI_COLLEGATI.ID_COLLEGATO =
                           GDO_ALLEGATI.ID_DOCUMENTO)
      LOOP
         BEGIN
            elimina_documento (I.ID_COLLEGATO, p_elimina_doc_gdm);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE_APPLICATION_ERROR (
                  -20999,
                     'Errore in elimina ALLEGATO  con id '
                  || I.ID_COLLEGATO
                  || '. Errore='
                  || SQLERRM);
         END;
      END LOOP;

      DBMS_OUTPUT.put_line ('dopo allegati');

      -- ELIMINAZIONE TESTATE DOCUMENTI PRINCIPALI (UNA DI QUESTA DOVRà SICURAMENTE ESSERE)
      DELETE FROM GDO_ALLEGATI_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_ALLEGATI
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_PROTOCOLLI_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_PROTOCOLLI
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_MSG_RICEVUTI_DATI_PROT_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_MSG_RICEVUTI_DATI_PROT
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_MSG_INVIATI_DATI_PROT
            WHERE ID_DOCUMENTO = p_id_documento;

      -- ELIMINAZIONE TABELLE GENERICHE
      DELETE FROM GDO_DOCUMENTI_SOGGETTI
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_COLLEGATI_LOG
            WHERE    ID_DOCUMENTO = p_id_documento
                  OR ID_COLLEGATO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_COLLEGATI
            WHERE    ID_DOCUMENTO = p_id_documento
                  OR ID_COLLEGATO = p_id_documento;

      -- ELIMINAZIONE FILE DOCUMENTO, TRANNE PER I DOCUMENTI ALLEGATI PERCHE' GIA' ELIMINATI CON LA ELIMINA_DOCUMENTO DEL CICLO SOPRA
      --INOLTRE  NON ELIMINO I FILE SUL DOCUMENTALE CHE SONO REFERENZIATI DA ALTRI DOC
      -- CANCELLO SOLO QUELLI DI AREA SEGRETERIA , GLI ALTRI POTREBBERO SERVIRE COME REPOOSITORY PER ALTRI DOC
      IF p_elimina_doc_gdm = 1
      THEN
         FOR I
            IN (SELECT GDO_FILE_DOCUMENTO.ID_FILE_ESTERNO
                  FROM GDO_FILE_DOCUMENTO, GDM_DOCUMENTI, GDM_OGGETTI_FILE
                 WHERE     GDO_FILE_DOCUMENTO.ID_DOCUMENTO = p_id_documento
                       AND GDO_FILE_DOCUMENTO.ID_FILE_ESTERNO IS NOT NULL
                       AND GDM_OGGETTI_FILE.ID_OGGETTO_FILE =
                              GDO_FILE_DOCUMENTO.ID_FILE_ESTERNO
                       AND GDM_OGGETTI_FILE.ID_DOCUMENTO =
                              GDM_DOCUMENTI.ID_DOCUMENTO
                       AND GDM_DOCUMENTI.AREA IN ('SEGRETERIA',
                                                  'SEGRETERIA.PROTOCOLLO')
                       AND 0 = A_IS_ALLEGATO
                       AND 0 =
                              (SELECT COUNT (*)
                                 FROM GDO_FILE_DOCUMENTO FD
                                WHERE     FD.ID_FILE_ESTERNO =
                                             GDO_FILE_DOCUMENTO.ID_FILE_ESTERNO
                                      AND FD.ID_DOCUMENTO <> p_id_documento))
         LOOP
            BEGIN
               GDM_OGGETTI_FILE_PACK_GDM.DELETEOGGETTOFILE (
                  I.ID_FILE_ESTERNO);
            EXCEPTION
               WHEN OTHERS
               THEN
                  RAISE_APPLICATION_ERROR (
                     -20999,
                        'Errore in elimina FILE SU DOCUMENTALE  con id '
                     || I.ID_FILE_ESTERNO
                     || '. Errore='
                     || SQLERRM);
            END;
         END LOOP;
      END IF;

      DELETE FROM gdo_file_documento_firmatari
            WHERE id_file_documento IN (SELECT id_file_documento
                                          FROM gdo_file_documento
                                         WHERE id_documento = p_id_documento);

      DELETE FROM GDO_FILE_DOCUMENTO_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_FILE_DOCUMENTO
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_STORICO
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_COMPETENZE
            WHERE ID_DOCUMENTO = p_id_documento;

      IF A_ID_DOCUMENTO_ESTERNO IS NOT NULL AND p_elimina_doc_gdm = 1
      THEN
         DECLARE
            A_RET   NUMBER;
         BEGIN
            A_RET := F_ELIMINA_DOCUMENTO_GDM (A_ID_DOCUMENTO_ESTERNO, 0, 1);
         END;
      END IF;

      DELETE FROM GDO_DOCUMENTI_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI
            WHERE ID_DOCUMENTO = p_id_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
               'Errore in elimina_documento con id '
            || p_id_documento
            || '. Errore = '
            || SQLERRM);
   END;

   PROCEDURE elimina_storico_documento (p_id_documento NUMBER)
   IS
      d_rev_prot     NUMBER;
      d_is_lettera   NUMBER := 0;
      d_max_rev      NUMBER;
   BEGIN
      BEGIN
         SELECT 1
           INTO d_is_lettera
           FROM agp_protocolli p, agp_tipi_protocollo tp
          WHERE     id_documento = p_id_documento
                AND tp.id_tipo_protocollo = p.id_tipo_protocollo
                AND tp.categoria = 'LETTERA';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_is_lettera := 0;
      END;

      IF d_is_lettera = 1
      THEN
         -- nel caso di lettere devo mantenere lo storico flusso, quindi
         -- devo individuare la min revisione per cui anno è valorizzato
         SELECT MIN (rev)
           INTO d_rev_prot
           FROM agp_protocolli_log
          WHERE id_documento = p_id_documento AND anno IS NOT NULL;
      ELSE
         SELECT MIN (rev)
           INTO d_rev_prot
           FROM gdo_documenti_log
          WHERE id_documento = p_id_documento;
      END IF;


      DBMS_OUTPUT.put_line ('p_id_documento: ' || p_id_documento);
      DBMS_OUTPUT.put_line ('d_rev_prot: ' || d_rev_prot);

      DELETE agp_documenti_dati_scarto_log
       WHERE     rev >= d_rev_prot
             AND id_documento_dati_scarto IN (SELECT id_documento_dati_scarto
                                                FROM agp_protocolli
                                               WHERE id_documento =
                                                        p_id_documento);

      DELETE agp_protocolli_corr_log
       WHERE rev >= d_rev_prot AND id_documento = p_id_documento;

      DELETE agp_protocolli_LOG
       WHERE rev >= d_rev_prot AND id_documento = p_id_documento;

      DELETE GDO_file_DOCUMENTo_LOG
       WHERE rev >= d_rev_prot AND id_documento = p_id_documento;

      DELETE GDO_DOCUMENTI_LOG
       WHERE rev >= d_rev_prot AND id_documento = p_id_documento;

      DELETE GDO_FILE_DOCUMENTO_LOG
       WHERE rev >= d_rev_prot AND id_documento = p_id_documento;

      DELETE GDO_DOCUMENTI_COLLEGATI_LOG
       WHERE     rev >= d_rev_prot
             AND id_documento = p_id_documento
             AND id_tipo_collegamento IN (SELECT tc.id_tipo_collegamento
                                            FROM gdo_tipi_collegamento tc
                                           WHERE tc.tipo_collegamento =
                                                    'ALLEGATO');

      DELETE gdo_allegati_log
       WHERE     rev >= d_rev_prot
             AND id_documento IN (SELECT id_collegato
                                    FROM gdo_documenti_collegati dc,
                                         gdo_tipi_collegamento tc
                                   WHERE     dc.id_documento = p_id_documento
                                         AND tc.id_tipo_collegamento =
                                                dc.id_tipo_collegamento
                                         AND tc.tipo_collegamento =
                                                'ALLEGATO');

      DELETE GDO_FILE_DOCUMENTO_LOG
       WHERE     rev >= d_rev_prot
             AND id_documento IN (SELECT id_collegato
                                    FROM gdo_documenti_collegati dc,
                                         gdo_tipi_collegamento tc
                                   WHERE     dc.id_documento = p_id_documento
                                         AND tc.id_tipo_collegamento =
                                                dc.id_tipo_collegamento
                                         AND tc.tipo_collegamento =
                                                'ALLEGATO');

      DELETE GDO_DOCUMENTI_LOG
       WHERE     rev >= d_rev_prot
             AND id_documento IN (SELECT id_collegato
                                    FROM gdo_documenti_collegati dc,
                                         gdo_tipi_collegamento tc
                                   WHERE     dc.id_documento = p_id_documento
                                         AND tc.id_tipo_collegamento =
                                                dc.id_tipo_collegamento
                                         AND tc.tipo_collegamento =
                                                'ALLEGATO');

      DELETE GDO_DOCUMENTI_collegati_LOG
       WHERE     rev >= d_rev_prot
             AND id_documento IN (SELECT id_collegato
                                    FROM gdo_documenti_collegati dc,
                                         gdo_tipi_collegamento tc
                                   WHERE     dc.id_documento = p_id_documento
                                         AND tc.id_tipo_collegamento =
                                                dc.id_tipo_collegamento
                                         AND tc.tipo_collegamento =
                                                'ALLEGATO');

      -- devo individuare la max revisione rimasta per svuotare revend
      SELECT NVL (MAX (rev), -1)
        INTO d_max_rev
        FROM agp_protocolli_log
       WHERE id_documento = p_id_documento;

      DBMS_OUTPUT.put_line ('d_max_rev: ' || d_max_rev);

      IF d_max_rev <> -1
      THEN
         UPDATE agp_documenti_dati_scarto_log
            SET revend = NULL
          WHERE     rev = d_max_rev
                AND id_documento_dati_scarto IN (SELECT id_documento_dati_scarto
                                                   FROM agp_protocolli
                                                  WHERE id_documento =
                                                           p_id_documento);

         UPDATE agp_protocolli_corr_log
            SET revend = NULL
          WHERE rev = d_max_rev AND id_documento = p_id_documento;

         UPDATE gdo_file_documento_log
            SET revend = NULL
          WHERE rev = d_max_rev AND id_documento = p_id_documento;

         UPDATE GDO_DOCUMENTI_LOG
            SET revend = NULL
          WHERE rev = d_max_rev AND id_documento = p_id_documento;

         UPDATE GDO_FILE_DOCUMENTO_LOG
            SET revend = NULL
          WHERE rev = d_max_rev AND id_documento = p_id_documento;

         UPDATE GDO_DOCUMENTI_collegati_LOG
            SET revend = NULL
          WHERE rev = d_max_rev AND id_documento = p_id_documento;

         UPDATE GDO_FILE_DOCUMENTO_LOG
            SET revend = NULL
          WHERE     rev = d_max_rev
                AND id_documento IN (SELECT id_collegato
                                       FROM gdo_documenti_collegati dc,
                                            gdo_tipi_collegamento tc
                                      WHERE     dc.id_documento =
                                                   p_id_documento
                                            AND tc.id_tipo_collegamento =
                                                   dc.id_tipo_collegamento
                                            AND tc.tipo_collegamento =
                                                   'ALLEGATO');

         UPDATE GDO_DOCUMENTI_LOG
            SET revend = NULL
          WHERE     rev = d_max_rev
                AND id_documento IN (SELECT id_collegato
                                       FROM gdo_documenti_collegati dc,
                                            gdo_tipi_collegamento tc
                                      WHERE     dc.id_documento =
                                                   p_id_documento
                                            AND tc.id_tipo_collegamento =
                                                   dc.id_tipo_collegamento
                                            AND tc.tipo_collegamento =
                                                   'ALLEGATO');

         UPDATE gdo_documenti_collegati_log
            SET revend = NULL
          WHERE     rev = d_max_rev
                AND id_documento IN (SELECT id_collegato
                                       FROM gdo_documenti_collegati dc,
                                            gdo_tipi_collegamento tc
                                      WHERE     dc.id_documento =
                                                   p_id_documento
                                            AND tc.id_tipo_collegamento =
                                                   dc.id_tipo_collegamento
                                            AND tc.tipo_collegamento =
                                                   'ALLEGATO');
      END IF;
   END;

   PROCEDURE elimina_trasco_documento (p_id_documento NUMBER)
   AS
      A_ID_PROTOCOLLO_DATI_SCARTO      NUMBER;
      A_ID_PROTOCOLLO_DATI_INTEROP     NUMBER;
      A_ID_PROTOCOLLO_DATI_EMERGENZA   NUMBER;
      A_ID_PROTOCOLLO_DATI_REG_GIORN   NUMBER;
      A_ID_DOCUMENTO_ESTERNO           NUMBER;
   BEGIN
      agp_trasco_pkg.elimina_storico_documento (p_id_documento);

      UPDATE agp_protocolli
         SET idrif = NULL
       WHERE id_documento = p_id_documento;

      BEGIN
         SELECT ID_PROTOCOLLO_DATI_SCARTO,
                ID_PROTOCOLLO_DATI_INTEROP,
                ID_PROTOCOLLO_DATI_EMERGENZA,
                ID_PROTOCOLLO_DATI_REG_GIORN
           INTO A_ID_PROTOCOLLO_DATI_SCARTO,
                A_ID_PROTOCOLLO_DATI_INTEROP,
                A_ID_PROTOCOLLO_DATI_EMERGENZA,
                A_ID_PROTOCOLLO_DATI_REG_GIORN
           FROM AGP_PROTOCOLLI
          WHERE ID_DOCUMENTO = p_id_documento;

         UPDATE AGP_PROTOCOLLI
            SET ID_PROTOCOLLO_DATI_SCARTO = NULL,
                ID_PROTOCOLLO_DATI_INTEROP = NULL,
                ID_PROTOCOLLO_DATI_EMERGENZA = NULL,
                ID_PROTOCOLLO_DATI_REG_GIORN = NULL
          WHERE ID_DOCUMENTO = p_id_documento;

         DELETE FROM AGP_PROTOCOLLI_DATI_SCARTO
               WHERE ID_PROTOCOLLO_DATI_SCARTO = A_ID_PROTOCOLLO_DATI_SCARTO;

         DELETE FROM AGP_PROTOCOLLI_DATI_SCARTO_LOG
               WHERE ID_PROTOCOLLO_DATI_SCARTO = A_ID_PROTOCOLLO_DATI_SCARTO;

         DELETE FROM AGP_PROTOCOLLI_DATI_INTEROP
               WHERE ID_PROTOCOLLO_DATI_INTEROP =
                        A_ID_PROTOCOLLO_DATI_INTEROP;

         DELETE FROM AGP_PROTOCOLLI_DATI_EMERGENZA
               WHERE ID_PROTOCOLLO_DATI_EMERGENZA =
                        A_ID_PROTOCOLLO_DATI_EMERGENZA;

         DELETE FROM AGP_PROTOCOLLI_DATI_REG_GIORN
               WHERE ID_PROTOCOLLO_DATI_REG_GIORN =
                        A_ID_PROTOCOLLO_DATI_REG_GIORN;


         DELETE FROM AGP_PROTOCOLLI_CORR_LOG
               WHERE ID_DOCUMENTO = p_id_documento;

         DELETE FROM AGP_PROTOCOLLI_CORR_INDIRIZZI
               WHERE ID_PROTOCOLLO_CORRISPONDENTE IN (SELECT ID_PROTOCOLLO_CORRISPONDENTE
                                                        FROM AGP_PROTOCOLLI_CORRISPONDENTI
                                                       WHERE ID_DOCUMENTO =
                                                                p_id_documento);

         DELETE FROM agp_messaggi_corrispondenti
               WHERE id_protocollo_corrispondente IN (SELECT id_protocollo_corrispondente
                                                        FROM AGP_PROTOCOLLI_CORRISPONDENTI
                                                       WHERE ID_DOCUMENTO =
                                                                p_id_documento);

         DELETE FROM AGP_PROTOCOLLI_CORRISPONDENTI
               WHERE ID_DOCUMENTO = p_id_documento;

         DELETE FROM AGP_PROTOCOLLI_RIF_TELEMATICI
               WHERE ID_DOCUMENTO = p_id_documento;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      DELETE FROM AGP_DOCUMENTI_SMISTAMENTI
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_DOCUMENTI_TITOLARIO
            WHERE ID_DOCUMENTO = p_id_documento;

      -- GESTIONE DEGLI ALLEGATI
      FOR I
         IN (SELECT GDO_DOCUMENTI_COLLEGATI.ID_COLLEGATO
               FROM GDO_DOCUMENTI_COLLEGATI, GDO_ALLEGATI
              WHERE     GDO_DOCUMENTI_COLLEGATI.ID_DOCUMENTO = p_id_documento
                    AND GDO_DOCUMENTI_COLLEGATI.ID_COLLEGATO =
                           GDO_ALLEGATI.ID_DOCUMENTO)
      LOOP
         BEGIN
            elimina_trasco_documento (I.ID_COLLEGATO);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE_APPLICATION_ERROR (
                  -20999,
                     'Errore in elimina ALLEGATO  con id '
                  || I.ID_COLLEGATO
                  || '. Errore='
                  || SQLERRM);
         END;
      END LOOP;

      -- ELIMINAZIONE TESTATE DOCUMENTI PRINCIPALI (UNA DI QUESTA DOVRà SICURAMENTE ESSERE)
      DELETE FROM GDO_ALLEGATI_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_ALLEGATI
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_MSG_RICEVUTI_DATI_PROT_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM AGP_MSG_RICEVUTI_DATI_PROT
            WHERE ID_DOCUMENTO = p_id_documento;

      -- ELIMINAZIONE TABELLE GENERICHE
      DELETE FROM GDO_DOCUMENTI_SOGGETTI
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_COLLEGATI_LOG
            WHERE    ID_DOCUMENTO = p_id_documento
                  OR ID_COLLEGATO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_COLLEGATI
            WHERE    ID_DOCUMENTO = p_id_documento
                  OR ID_COLLEGATO = p_id_documento;

      DELETE FROM gdo_file_documento_firmatari
            WHERE id_file_documento IN (SELECT id_file_documento
                                          FROM gdo_file_documento
                                         WHERE id_documento = p_id_documento);

      DELETE FROM GDO_FILE_DOCUMENTO_LOG
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_FILE_DOCUMENTO
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_STORICO
            WHERE ID_DOCUMENTO = p_id_documento;

      DELETE FROM GDO_DOCUMENTI_COMPETENZE
            WHERE ID_DOCUMENTO = p_id_documento;

      SELECT ID_DOCUMENTO_ESTERNO
        INTO A_ID_DOCUMENTO_ESTERNO
        FROM GDO_DOCUMENTI
       WHERE ID_DOCUMENTO = p_id_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
               'Errore in elimina_documento con id '
            || p_id_documento
            || '. Errore = '
            || SQLERRM);
   END;

   FUNCTION crea_doc_titolario_agspr (p_id_documento_gdm          VARCHAR2,
                                      p_id_classificazione_gdm    VARCHAR2,
                                      p_id_fascicolo_gdm          VARCHAR2,
                                      p_utente                    VARCHAR2)
      RETURN VARCHAR2
   IS
      d_id_ente               NUMBER := 1;
      d_riservato             VARCHAR2 (255);

      d_id_doc                NUMBER;
      d_id_rev                NUMBER;
      d_id_classificazione    NUMBER;
      d_id_fascicolo          NUMBER;

      d_esistenza_titolario   NUMBER;
   BEGIN
      -- i valori id_ente e riservato al momento vengono impostati di default
      d_id_ente := 1;
      d_riservato := 'N';


      -- CREAZIONE DOCUMENTO
      crea_documento (p_id_documento_gdm,
                      d_id_ente,
                      'Y',
                      d_riservato,
                      p_utente,
                      SYSDATE,
                      p_utente,
                      SYSDATE,
                      NULL,
                      NULL,
                      NULL,
                      d_id_doc,
                      d_id_rev);


      -- INSERIMENTO TITOLARIO
      BEGIN
         SELECT id_classificazione
           INTO d_id_classificazione
           FROM ags_classificazioni
          WHERE id_documento_esterno = p_id_classificazione_gdm;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_classificazione := NULL;
      END;

      BEGIN
         SELECT id_documento
           INTO d_id_fascicolo
           FROM gdo_documenti
          WHERE id_documento_esterno = p_id_fascicolo_gdm;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_fascicolo := NULL;
      END;

      IF d_id_fascicolo IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO d_esistenza_titolario
           FROM agp_documenti_titolario
          WHERE     id_documento = d_id_doc
                AND id_classificazione = d_id_classificazione
                AND id_fascicolo = d_id_fascicolo;
      ELSE
         SELECT COUNT (1)
           INTO d_esistenza_titolario
           FROM agp_documenti_titolario
          WHERE     id_documento = d_id_doc
                AND id_classificazione = d_id_classificazione;
      END IF;

      IF d_esistenza_titolario = 0
      THEN
         crea_titolario (d_id_doc,
                         d_id_classificazione,
                         d_id_fascicolo,
                         p_utente,
                         SYSDATE,
                         p_utente,
                         SYSDATE);
      END IF;

      COMMIT;

      RETURN d_id_doc;
   END;

   PROCEDURE crea_trasco_scarico_ipa
   IS
      d_regione         NUMBER;
      d_regione_aoo     NUMBER;
      d_provincia       NUMBER;
      d_provincia_aoo   NUMBER;
      d_ipa_categoria   VARCHAR2 (1000);
   BEGIN
      FOR c
         IN (SELECT d.data_aggiornamento,
                    d.utente_aggiornamento,
                    cod_amm,
                    cod_aoo,
                    codice_amministrazione,
                    codice_aoo,
                    data_fine,
                    data_inizio,
                    descrizione_amm,
                    descrizione_aoo,
                    full_text,
                    ipa.id_documento,
                    DECODE (ipa_categoria, '*', NULL, ipa_categoria)
                       ipa_categoria,
                    msg_scarico,
                    posizione_flusso,
                    DECODE (provincia, '*', NULL, provincia) provincia,
                    DECODE (provincia_aoo, '*', NULL, provincia_aoo)
                       provincia_aoo,
                    regione,
                    regione_aoo,
                    DECODE (scaricare_ou, 'Y#', 'Y', 'N') scaricare_ou,
                    titolo_ipa,
                    DECODE (tutte_amministrazioni, 'Y#', 'Y', 'N')
                       tutte_amministrazioni,
                    DECODE (tutte_aoo, 'Y#', 'Y', 'N') tutte_aoo,
                    utente
               FROM gdm_spr_scarico_ipa ipa, gdm_documenti d
              WHERE     ipa.id_documento = d.id_documento
                    AND d.stato_documento = 'BO')
      LOOP
         d_regione := NULL;
         d_regione_aoo := NULL;
         d_provincia := NULL;
         d_provincia_aoo := NULL;
         d_ipa_categoria := NULL;

         IF (c.regione IS NOT NULL)
         THEN
            BEGIN
               SELECT ad4_regione.get_regione (c.regione)
                 INTO d_regione
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;

         IF (c.regione_aoo IS NOT NULL)
         THEN
            BEGIN
               SELECT ad4_regione.get_regione (c.regione_aoo)
                 INTO d_regione_aoo
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;

         IF (c.provincia IS NOT NULL)
         THEN
            BEGIN
               SELECT ad4_provincia.get_provincia (NULL, c.provincia)
                 INTO d_provincia
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;

         IF (c.provincia_aoo IS NOT NULL)
         THEN
            BEGIN
               SELECT ad4_provincia.get_provincia (NULL, c.provincia_aoo)
                 INTO d_provincia_aoo
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;

         IF (c.ipa_categoria IS NOT NULL)
         THEN
            SELECT DECODE (
                      c.ipa_categoria,
                      'L10', 'Agenzie ed Enti per il Turismo',
                      'L19', 'Agenzie ed Enti Regionali del Lavoro',
                      'L13', 'Agenzie ed Enti regionali di Sviluppo Agricolo',
                      'L2', 'Agenzie ed Enti Regionali per la Formazione, la Ricerca e l''Ambiente',
                      'L15', 'Agenzie, Enti e Consorzi Pubblici per il Diritto allo Studio Universitario',
                      'C10', 'Agenzie Fiscali',
                      'L20', 'Agenzie Regionali e Provinciale per la Rappresentanza Negoziale',
                      'L21', 'Agenzie Regionali per le Erogazioni in Agricoltura',
                      'L22', 'Agenzie Regionali Sanitarie',
                      'L1', 'Altri Enti Locali',
                      'C13', 'Automobile Club Federati ACI',
                      'C5', 'Autorita'' Amministrative Indipendenti',
                      'L40', 'Autorita'' di Bacino',
                      'L11', 'Autorita'' Portuali',
                      'L39', 'Aziende e Consorzi Pubblici Territoriali per l''Edilizia Residenziale',
                      'L46', 'Aziende ed Amministrazioni dello Stato ad Ordinamento Autonomo',
                      'L8', 'Aziende Ospedaliere, Aziende Ospedaliere Universitarie, Policlinici e Istituti di Ricovero e Cura a Carattere Scientifico Pubblici',
                      'L34', 'Aziende Pubbliche di Servizi alla Persona',
                      'L7', 'Aziende Sanitarie Locali',
                      'L35', 'Camere di Commercio, Industria, Artigianato e Agricoltura e loro Unioni Regionali',
                      'L45', 'Citta'' Metropolitane',
                      'L6', 'Comuni e loro Consorzi e Associazioni',
                      'L12', 'Comunita'' Montane e loro Consorzi e Associazioni',
                      'L24', 'Consorzi di Bacino Imbrifero Montano',
                      'L28', 'Consorzi Interuniversitari di Ricerca',
                      'L42', 'Consorzi per l''Area di Sviluppo Industriale',
                      'L36', 'Consorzi tra Amministrazioni Locali',
                      'L44', 'Enti di Regolazione dei Servizi Idrici e o dei Rifiuti',
                      'C8', 'Enti e Istituzioni di Ricerca Pubblici',
                      'C3', 'Enti Pubblici Non Economici',
                      'C7', 'Enti Pubblici Produttori di Servizi Assistenziali, Ricreativi e Culturali ',
                      'C14', 'Federazioni Nazionali, Ordini, Collegi e Consigli Professionali',
                      'L16', 'Fondazioni Lirico, Sinfoniche',
                      'C11', 'Forze di Polizia ad Ordinamento Civile e Militare per la Tutela dell''Ordine e della Sicurezza Pubblica',
                      'L33', 'Istituti di Istruzione Statale di Ogni Ordine e Grado',
                      'C12', 'Istituti Zooprofilattici Sperimentali',
                      'L43', 'Istituzioni per l''Alta Formazione Artistica, Musicale e Coreutica - AFAM',
                      'C2', 'Organi Costituzionali e di Rilievo Costituzionale',
                      'L38', 'Parchi Nazionali, Consorzi e Enti Gestori di Parchi e Aree Naturali Protette',
                      'C1', 'Presidenza del Consiglio dei Ministri, Ministeri e Avvocatura dello Stato',
                      'L5', 'Province e loro Consorzi e Associazioni',
                      'L4', 'Regioni, Province Autonome e loro Consorzi e Associazioni',
                      'L31', 'Teatri Stabili ad Iniziativa Pubblica',
                      'L18', 'Unioni di Comuni e loro Consorzi e Associazioni',
                      'L17', 'Universita'' e Istituti di Istruzione Universitaria Pubblici')
              INTO d_ipa_categoria
              FROM DUAL;
         END IF;

         INSERT INTO agp_scarico_ipa (id_scarico_ipa,
                                      codice_amm,
                                      codice_aoo,
                                      codice_provincia_amm,
                                      codice_provincia_aoo,
                                      codice_regione_amm,
                                      codice_regione_aoo,
                                      data_ins,
                                      data_upd,
                                      utente_ins,
                                      utente_upd,
                                      valido,
                                      version,
                                      id_ente,
                                      descrizione_amm,
                                      descrizione_aoo,
                                      import_tutte_amm,
                                      import_tutte_aoo,
                                      import_unita,
                                      nome_criterio,
                                      tipologia_ente)
              VALUES (hibernate_sequence.NEXTVAL,
                      c.cod_amm,
                      c.cod_aoo,
                      d_provincia,
                      d_provincia_aoo,
                      d_regione,
                      d_regione_aoo,
                      c.data_aggiornamento,
                      SYSDATE,
                      c.utente_aggiornamento,
                      'RPI',
                      'Y',
                      0,
                      1,
                      c.descrizione_amm,
                      c.descrizione_aoo,
                      c.tutte_amministrazioni,
                      c.tutte_aoo,
                      c.scaricare_ou,
                      c.titolo_ipa,
                      d_ipa_categoria);
      END LOOP;
   END;
END;
/