--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_AGP_PROTOCOLLI_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AGP_PROTOCOLLI_PKG
IS
   /******************************************************************************
    NOME:        AGP_PROTOCOLLI_PKG
    DESCRIZIONE: Gestione tabella AGP_PROTOCOLLI.
    ANNOTAZIONI: .
    REVISIONI:   Template Revision: 1.53.
    <CODE>
    Rev.  Data          Autore         Descrizione.
    00    23/03/2017    mmalferrari    Prima emissione.
    01    09/11/2017    mmalferrari    Creata annulla.
    02    31/01/2018    mmalferrari    Create procedure per gestione dati di accesso civico
    03    31/07/2018    mmalferrari    Creata get_id_documento
    04    07/12/2018    mmalferrari    Creata is_documento_agspr
    05    03/07/2019    mmalferrari    Creata is_protocollo_agspr
    06    06/07/2020    mmalferrari    Modificata aggiorna_titolario.
   ******************************************************************************/
   -- Revisione del Package
   s_revisione   CONSTANT AFC.t_revision := 'V1.06';

   -- Versione e revisione
   FUNCTION versione
      RETURN VARCHAR2;

   PROCEDURE del (p_id_documento_esterno NUMBER, p_utente VARCHAR2);

   FUNCTION get_tag_email_mittente (p_id_documento   IN NUMBER,
                                    p_utente         IN VARCHAR2)
      /*****************************************************************************
       NOME:        GET_TAG_EMAIL_MITTENTE
       DESCRIZIONE:
       RITORNO:
       Rev.  Data       Autore Descrizione.
       001   29/03/2017 MM     Creazione.
      ********************************************************************************/
      RETURN afc.t_ref_cursor;

   PROCEDURE AGGIORNA_TITOLARIO (P_ID_DOCUMENTO_ESTERNO    NUMBER,
                                 P_CLASS_COD_OLD           VARCHAR2,
                                 P_CLASS_DAL_OLD           DATE,
                                 P_FASCICOLO_ANNO_OLD      NUMBER,
                                 P_FASCICOLO_NUMERO_OLD    VARCHAR2,
                                 P_CLASS_COD               VARCHAR2,
                                 P_CLASS_DAL               DATE,
                                 P_FASCICOLO_ANNO          NUMBER,
                                 P_FASCICOLO_NUMERO        VARCHAR2,
                                 P_UTENTE_UPD              VARCHAR2,
                                 P_SPOSTA                  NUMBER DEFAULT 1,
                                 P_PRINCIPALE              NUMBER DEFAULT 1);

   FUNCTION get_ubicazione_fascicolo (p_id_documento NUMBER)
      RETURN VARCHAR2;

   PROCEDURE annulla (P_ID_DOCUMENTO_ESTERNO NUMBER);

   PROCEDURE set_data_annullamento (P_ID_DOCUMENTO_ESTERNO    NUMBER,
                                    P_DATA_ANN                DATE);

   PROCEDURE set_utente_annullamento (P_ID_DOCUMENTO_ESTERNO    NUMBER,
                                      P_UTENTE_ANN              VARCHAR2);

   PROCEDURE set_provvedimento_annullamento (
      P_ID_DOCUMENTO_ESTERNO    NUMBER,
      P_PROVVEDIMENTO           VARCHAR2);

   FUNCTION ins_da_esterno (p_utente                  VARCHAR2,
                            p_id_documento_esterno    NUMBER,
                            p_anno                    NUMBER,
                            p_numero                  NUMBER,
                            p_tipo_registro           VARCHAR2,
                            p_data                    DATE,
                            p_oggetto                 VARCHAR2,
                            p_riservato               VARCHAR2,
                            p_codice_amm              VARCHAR2,
                            p_codice_aoo              VARCHAR2,
                            p_modello                 VARCHAR2)
      RETURN NUMBER;

   PROCEDURE upd_da_esterno (p_utente                  VARCHAR2,
                             p_id_documento_esterno    NUMBER,
                             p_anno                    NUMBER,
                             p_numero                  NUMBER,
                             p_tipo_registro           VARCHAR2,
                             p_data                    DATE,
                             p_oggetto                 VARCHAR2,
                             p_riservato               VARCHAR2);

   FUNCTION crea_attestazione_conformita (p_class_cod           VARCHAR2,
                                          p_class_dal           VARCHAR2,
                                          p_fascicolo_anno      NUMBER,
                                          p_fascicolo_numero    VARCHAR2,
                                          p_utente              VARCHAR2,
                                          p_codice_amm          VARCHAR2,
                                          p_codice_aoo          VARCHAR2)
      RETURN VARCHAR2;


   FUNCTION is_attestazione_conformita (p_id_documento_esterno NUMBER)
      RETURN NUMBER;

   FUNCTION get_attestaz_conform_in_corso (p_class_cod           VARCHAR2,
                                           p_class_dal           VARCHAR2,
                                           p_fascicolo_anno      NUMBER,
                                           p_fascicolo_numero    VARCHAR2,
                                           p_utente              VARCHAR2,
                                           p_codice_amm          VARCHAR2,
                                           p_codice_aoo          VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_id_documento (p_id_documento_esterno NUMBER)
      RETURN NUMBER;

   FUNCTION is_documento_agspr (p_id_documento_esterno NUMBER)
      RETURN NUMBER;

   FUNCTION is_protocollo_agspr (p_id_documento_esterno NUMBER)
      RETURN NUMBER;

   PROCEDURE accetta_richiesta_annullamento (
      p_id_documento_esterno     NUMBER,
      p_data_acc_annullamento    DATE);
END;
/
CREATE OR REPLACE PACKAGE BODY AGP_PROTOCOLLI_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_PROTOCOLLI_PKG
    DESCRIZIONEp_ Gestione tabella AGP_PROTOCOLLI.
    ANNOTAZIONI .
    REVISIONI   .
    Rev.  Data          Autore        Descrizione.
    000   16/02/2017    mmalferrari   Prima emissione.
    001   09/11/2017    mmalferrari   Create procedure per aggiornamento dati di annullamento
    002   31/01/2018    mmalferrari   Create procedure per gestione dati di accesso civico
    003   31/07/2018    mmalferrari   Creata get_id_documento
    004   16/08/2018    mmalferrari   Modificata get_tag_email_mittente
    005   07/12/2018    mmalferrari   Creata is_documento_agspr
    006   05/08/2019    mmalferrari   Modificata get_tag_email_mittente per gestione
                                      _rownum in caso di più mail dello stesso tipo
                                      (nella lettera con stessa descrizione non
                                      sentiva il cambio di record).
    007   09/04/2019    mmalferrari   Modificata GET_TAG_EMAIL_MITTENTE in modo da passare
                                      N come default del flag segnatura_completa quando
                                      IS_ENTE_INTERPRO vale Y.
    008   12/06/2019    mmalferrari   modificata get_tag_mail_mittente per rstituire
                                      anche i codici amm, aoo e uo.
    009   03/07/2019    mmalferrari   Creata is_protocollo_agspr
    010   24/10/2019    scaputo       Bug #37724 Attestazione di conformita: bugs
    011   20/12/2019    mmalferrari   Modicata crea_attestazione_conformita per
                                      gestione tabelle di log.
    012   09/01/2020    mmalferrari   Eliminata get_id_ente per utilizzare quella
                                      di agp_utility_pkg
    013   25/03/2020    mmalferrari   Modificata crea_attestazione_conformita
    014   09/06/2020    mmalferrari   Modificata accetta_richiesta_annullamento
                                      in modo che non faccia nulla se il documento
                                      esiste gia' con idrif valorizzato.
    015   06/07/2020    mmalferrari   Modificata aggiorna_titolario con controllo
                                      su richiesta che sia un doc di agspr
    016   10/07/2020    mmalferrari   Modificate aggiorna_titolario per gestione
                                      storico.
    017   04/09/2020    mmalferrari   Modificata aggiorna_titolario.
    018   11/08/2020    mmalferrari   Gestione tabella AGS_FASCICOLI (sostituita alla vista)
    019   10/09/2020    mmalferrari   Modificate chiamate a agp_trasco_pkg.crea_documento_soggetto
                                      per passare idrev.
  ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '019';

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

   PROCEDURE del (p_id_documento_esterno NUMBER, p_utente VARCHAR2)
   IS
   BEGIN
      UPDATE gdo_documenti
         SET valido = 'N', data_upd = SYSDATE, utente_upd = p_utente
       WHERE id_documento_esterno = p_id_documento_esterno;
   END;

   FUNCTION get_tag_email_mittente (p_id_documento   IN NUMBER,
                                    p_utente         IN VARCHAR2)
      /*****************************************************************************
       NOME:        GET_TAG_EMAIL_MITTENTE
       DESCRIZIONE:
       RITORNO:
       Rev.  Data       Autore Descrizione.
       001   29/03/2017 MM     Creazione.
       006   09/04/2019 MM     Modificata GET_TAG_EMAIL_MITTENTE in modo da passare
                               N come default del flag segnatura_completa quando
                               IS_ENTE_INTERPRO vale Y.
      ********************************************************************************/
      RETURN afc.t_ref_cursor
   IS
      d_segnatura            VARCHAR2 (1);
      d_segnatura_completa   VARCHAR2 (1);
      d_unita_comp           VARCHAR2 (50);
      d_codice_amm           VARCHAR2 (100);
      d_codice_aoo           VARCHAR2 (100);
      d_result               afc.t_ref_cursor;
   BEGIN
      BEGIN
         SELECT NVL (
                   segnatura_completa,
                   DECODE (
                      NVL (
                         GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE (
                            'IS_ENTE_INTERPRO',
                            PROT.ID_ENTE),
                         'N'),
                      'Y', 'N',
                      'Y')),
                NVL (segnatura, 'Y'),
                NVL (DECODE (p.unita_esibente, '--', '', p.unita_esibente),
                     unita_protocollante),
                NVL (p.codice_amministrazione, E.AMMINISTRAZIONE),
                NVL (p.codice_aoo, E.AOO)
           INTO d_segnatura_completa,
                d_segnatura,
                d_unita_comp,
                d_codice_amm,
                d_codice_aoo
           FROM gdm_seg_tipi_documento tido,
                gdm_proto_view p,
                gdm_documenti docu,
                gdo_documenti prot,
                gdo_enti e
          WHERE     prot.id_documento = p_id_documento
                AND p.id_documento = prot.id_documento_esterno
                AND tido.tipo_documento(+) = p.tipo_documento
                AND docu.id_documento(+) = tido.id_documento
                AND NVL (docu.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
                AND TRUNC (p.data) BETWEEN NVL (TIDO.DATAVAL_DAL(+),
                                                TRUNC (p.data))
                                       AND NVL (TIDO.DATAVAL_AL(+),
                                                TRUNC (p.data))
                AND e.id_ente(+) = prot.id_ente;
      EXCEPTION
         WHEN OTHERS
         THEN
            d_segnatura_completa := 'Y';
            d_segnatura := 'Y';
      END;

      OPEN d_result FOR
         SELECT nome,
                tag_mail,
                email,
                tipo,
                d_segnatura_completa segnatura_completa,
                d_segnatura segnatura,
                d_codice_amm amministrazione,
                aoo,
                codice_uo,
                ordine
           FROM (SELECT 'UO' tipo,
                           DECODE (
                              inte.tipo_indirizzo,
                              'I', '(DEF) ',
                              'P',    '(PEC'
                                   || DECODE (ROWNUM,
                                              1, ') ',
                                              '_' || ROWNUM || ') '),
                              '(' || ROWNUM || ')')
                        || s.nome
                           nome,
                        inte.tag_mail,
                        inte.indirizzo email,
                        NULL aoo,
                        s.unita codice_uo,
                        DECODE (inte.tipo_indirizzo,  'I', 1,  'P', 2,  3)
                           ordine
                   FROM gdm_seg_unita s, so4_indirizzi_telematici inte
                  WHERE     unita = d_unita_comp
                        AND s.codice_amministrazione = d_codice_amm
                        AND SYSDATE BETWEEN s.dal
                                        AND NVL (s.al,
                                                 TO_DATE (3333333, 'j'))
                        AND inte.id_unita_organizzativa =
                               s.progr_unita_organizzativa
                        AND inte.tipo_indirizzo NOT IN ('R', 'M', 'F')
                 UNION
                 SELECT 'AOO',
                        aoo.denominazione,
                        gdm_ag_parametro.get_valore ('TAG_MAIL_ESTERNO_',
                                                     d_codice_amm,
                                                     d_codice_aoo,
                                                     '')
                           tag_mail,
                        indirizzo_istituzionale email,
                        d_codice_aoo aoo,
                        NULL codice_uo,
                        99 ordine
                   FROM so4_aoo_view aoo
                  WHERE     gdm_ag_utilities.verifica_privilegio_utente (
                               NULL,
                               'PINVIOI',
                               p_utente,
                               TRUNC (SYSDATE)) = 1
                        AND codice_amministrazione = d_codice_amm
                        AND codice_aoo = d_codice_aoo
                        AND SYSDATE BETWEEN aoo.dal
                                        AND NVL (aoo.al,
                                                 TO_DATE (3333333, 'j'))
                 ORDER BY ordine)
          WHERE tag_mail IS NOT NULL AND email IS NOT NULL;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AGP_PROTOCOLLI_PKG.GET_TAG_EMAIL_MITTENTE: ' || SQLERRM);
   END;

   PROCEDURE AGGIORNA_TITOLARIO (P_ID_DOCUMENTO_ESTERNO    NUMBER,
                                 P_CLASS_COD_OLD           VARCHAR2,
                                 P_CLASS_DAL_OLD           DATE,
                                 P_FASCICOLO_ANNO_OLD      NUMBER,
                                 P_FASCICOLO_NUMERO_OLD    VARCHAR2,
                                 P_CLASS_COD               VARCHAR2,
                                 P_CLASS_DAL               DATE,
                                 P_FASCICOLO_ANNO          NUMBER,
                                 P_FASCICOLO_NUMERO        VARCHAR2,
                                 P_UTENTE_UPD              VARCHAR2,
                                 P_SPOSTA                  NUMBER DEFAULT 1,
                                 P_PRINCIPALE              NUMBER DEFAULT 1)
   IS
      d_id_documento             NUMBER;
      d_id_classificazione       NUMBER;
      d_id_fascicolo             NUMBER;
      d_id_classificazione_old   NUMBER;
      d_id_fascicolo_old         NUMBER;
      d_version                  NUMBER;
      d_continua                 BOOLEAN := TRUE;
      d_id_revisione             NUMBER;
      d_class_mod                NUMBER := 0;
      d_fasc_mod                 NUMBER := 0;
      d_is_fasc_princ            NUMBER := P_PRINCIPALE;
   BEGIN
      /*
         raise_application_error (
            -20999,
               'AGGIORNA_TITOLARIO ('
            || P_ID_DOCUMENTO_ESTERNO
            || ','
            || P_CLASS_COD_OLD
            || ','
            || P_CLASS_DAL_OLD
            || ','
            || P_FASCICOLO_ANNO_OLD
            || ','
            || P_FASCICOLO_NUMERO_OLD
            || ','
            || P_CLASS_COD
            || ','
            || P_CLASS_DAL
            || ','
            || P_FASCICOLO_ANNO
            || ','
            || P_FASCICOLO_NUMERO
            || ','
            || P_UTENTE_UPD
            || ','
            || p_SPOSTA
            || ','
            || P_PRINCIPALE
            || ')');
   */

      IF NOT is_protocollo_agspr (p_id_documento_esterno) = 1
      THEN
         d_continua := FALSE;
      END IF;

      IF d_continua
      THEN
         SELECT id_documento
           INTO d_id_documento
           FROM gdo_documenti
          WHERE id_documento_esterno = p_id_documento_esterno;

         DBMS_OUTPUT.put_line ('d_id_documento: ' || d_id_documento);

         IF p_class_cod_old IS NOT NULL AND p_class_dal_old IS NOT NULL
         THEN
            SELECT id_classificazione
              INTO d_id_classificazione_old
              FROM ags_classificazioni
             WHERE     classificazione = p_class_cod_old
                   AND classificazione_dal = p_class_dal_old;

            DBMS_OUTPUT.put_line (
               'd_id_classificazione_old: ' || d_id_classificazione_old);
         END IF;

         IF     p_fascicolo_anno_old IS NOT NULL
            AND p_fascicolo_numero_old IS NOT NULL
         THEN
            SELECT id_documento
              INTO d_id_fascicolo_old
              FROM ags_fascicoli
             WHERE     id_classificazione = d_id_classificazione_old
                   AND anno = p_fascicolo_anno_old
                   AND numero = p_fascicolo_numero_old;

            DBMS_OUTPUT.put_line (
               'd_id_fascicolo_old: ' || d_id_fascicolo_old);
         END IF;

         SELECT id_classificazione
           INTO d_id_classificazione
           FROM ags_classificazioni
          WHERE     classificazione = p_class_cod
                AND classificazione_dal = p_class_dal;

         DBMS_OUTPUT.put_line (
            'd_id_classificazione: ' || d_id_classificazione);

         IF p_fascicolo_anno IS NOT NULL AND p_fascicolo_numero IS NOT NULL
         THEN
            SELECT id_documento
              INTO d_id_fascicolo
              FROM ags_fascicoli
             WHERE     id_classificazione = d_id_classificazione
                   AND anno = p_fascicolo_anno
                   AND numero = p_fascicolo_numero;

            DBMS_OUTPUT.put_line ('d_id_fascicolo: ' || d_id_fascicolo);
         END IF;

         DECLARE
            d_esiste   NUMBER := 0;
         BEGIN
            SELECT 1
              INTO d_esiste
              FROM agp_protocolli
             WHERE     id_classificazione = d_id_classificazione
                   AND NVL (id_fascicolo, 0) = NVL (d_id_fascicolo, 0)
                   AND id_documento = d_id_documento;

            d_continua := FALSE;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_continua := TRUE;
         END;

         DBMS_OUTPUT.put_line ('d_continua: false');

         IF d_continua
         THEN
            DBMS_OUTPUT.put_line ('d_continua: true');

            IF    NVL (d_id_classificazione_old, 0) <>
                     NVL (d_id_classificazione, 0)
               OR NVL (d_id_fascicolo_old, 0) <> NVL (d_id_fascicolo, 0)
            THEN
               IF NVL (d_id_classificazione_old, 0) <>
                     NVL (d_id_classificazione, 0)
               THEN
                  d_class_mod := 1;
               END IF;

               DBMS_OUTPUT.put_line ('d_class_mod: ' || d_class_mod);

               IF    NVL (d_id_fascicolo_old, 0) <> NVL (d_id_fascicolo, 0)
                  OR (d_class_mod = 1 AND d_id_fascicolo_old = d_id_fascicolo)
               THEN
                  d_fasc_mod := 1;
               END IF;

               DBMS_OUTPUT.put_line ('d_fasc_mod: ' || d_fasc_mod);

               DBMS_OUTPUT.put_line ('P_PRINCIPALE: ' || P_PRINCIPALE);

               IF P_PRINCIPALE = 0
               THEN
                  BEGIN
                     SELECT 1
                       INTO d_is_fasc_princ
                       FROM agp_protocolli
                      WHERE     id_documento = d_id_documento
                            AND NVL (id_classificazione, 0) =
                                   NVL (d_id_classificazione_old, 0)
                            AND NVL (id_fascicolo, 0) =
                                   NVL (d_id_fascicolo_old, 0);
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        d_is_fasc_princ := 0;
                  END;
               END IF;

               DBMS_OUTPUT.put_line ('d_is_fasc_princ: ' || d_is_fasc_princ);

               IF d_is_fasc_princ = 1
               THEN
                  -- modifica classifica / fascicolo principale di un documento
                  IF d_class_mod = 1 OR d_fasc_mod = 1
                  THEN
                     SELECT MAX (NVL (version, 0)) + 1
                       INTO d_version
                       FROM gdo_documenti
                      WHERE id_documento = d_id_documento;

                     UPDATE gdo_documenti
                        SET version = d_version,
                            utente_upd = p_utente_upd,
                            data_upd = SYSDATE
                      WHERE id_documento = d_id_documento;

                     d_id_revisione := revinfo_pkg.crea_revinfo (SYSTIMESTAMP);

                     UPDATE GDO_DOCUMENTI_LOG
                        SET revend = d_id_revisione
                      WHERE id_documento = d_id_documento AND revend IS NULL;

                     INSERT INTO GDO_DOCUMENTI_LOG (ID_DOCUMENTO,
                                                    REV,
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
                                                    TIPO_OGGETTO_MOD)
                        SELECT ID_DOCUMENTO,
                               d_id_revisione,
                               1,
                               NULL,
                               DATA_INS,
                               0,
                               DATA_UPD,
                               1,
                               VALIDO,
                               0,
                               ID_DOCUMENTO_ESTERNO,
                               0,
                               RISERVATO,
                               0,
                               STATO,
                               0,
                               STATO_CONSERVAZIONE,
                               0,
                               STATO_FIRMA,
                               0,
                               UTENTE_INS,
                               0,
                               UTENTE_UPD,
                               1,
                               ID_ENTE,
                               0,
                               0,
                               0,
                               ID_ENGINE_ITER,
                               0,
                               TIPO_OGGETTO,
                               0
                          FROM gdo_documenti
                         WHERE id_documento = d_id_documento;

                     UPDATE AGP_PROTOCOLLI
                        SET id_classificazione = d_id_classificazione,
                            id_fascicolo = d_id_fascicolo
                      WHERE     id_documento = d_id_documento
                            AND NVL (id_classificazione, 0) =
                                   NVL (d_id_classificazione_old,
                                        NVL (id_classificazione, 0))
                            AND NVL (id_fascicolo, 0) =
                                   NVL (d_id_fascicolo_old,
                                        NVL (id_fascicolo, 0));

                     INSERT INTO AGP_PROTOCOLLI_LOG (
                                    ID_DOCUMENTO,
                                    REV,
                                    ANNO,
                                    ANNO_MOD,
                                    ANNO_EMERGENZA,
                                    ANNO_EMERGENZA_MOD,
                                    ANNULLATO,
                                    ANNULLATO_MOD,
                                    CAMPI_PROTETTI,
                                    CAMPI_PROTETTI_MOD,
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
                                    CORRISPONDENTI_MOD,
                                    ID_PROTOCOLLO_DATI_EMERGENZA,
                                    DATI_EMERGENZA_MOD,
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
                                    UTENTE_ANNULLAMENTO_MOD,
                                    ID_PROTOCOLLO_DATI_REG_GIORN,
                                    REGISTRO_GIORNALIERO_MOD)
                        SELECT ID_DOCUMENTO,
                               d_id_revisione,
                               ANNO,
                               0,
                               ANNO_EMERGENZA,
                               0,
                               ANNULLATO,
                               0,
                               CAMPI_PROTETTI,
                               0,
                               CODICE_RACCOMANDATA,
                               0,
                               CONTROLLO_FIRMATARIO,
                               0,
                               CONTROLLO_FUNZIONARIO,
                               0,
                               DATA,
                               0,
                               DATA_ANNULLAMENTO,
                               0,
                               DATA_COMUNICAZIONE,
                               0,
                               DATA_DOCUMENTO_ESTERNO,
                               0,
                               DATA_REDAZIONE,
                               0,
                               DATA_STATO_ARCHIVIO,
                               0,
                               DATA_VERIFICA,
                               0,
                               ESITO_VERIFICA,
                               0,
                               IDRIF,
                               0,
                               MOVIMENTO,
                               0,
                               NOTE,
                               0,
                               NOTE_TRASMISSIONE,
                               0,
                               NUMERO,
                               0,
                               NUMERO_DOCUMENTO_ESTERNO,
                               0,
                               NUMERO_EMERGENZA,
                               0,
                               OGGETTO,
                               0,
                               PROVVEDIMENTO_ANNULLAMENTO,
                               0,
                               REGISTRO_EMERGENZA,
                               0,
                               STATO_ARCHIVIO,
                               0,
                               ID_CLASSIFICAZIONE,
                               d_class_mod,
                               0,
                               ID_PROTOCOLLO_DATI_EMERGENZA,
                               0,
                               ID_PROTOCOLLO_DATI_INTEROP,
                               0,
                               ID_PROTOCOLLO_DATI_SCARTO,
                               0,
                               ID_FASCICOLO,
                               d_fasc_mod,
                               ID_MODALITA_INVIO_RICEZIONE,
                               0,
                               ID_SCHEMA_PROTOCOLLO,
                               0,
                               ID_TIPO_PROTOCOLLO,
                               0,
                               TIPO_REGISTRO,
                               0,
                               UTENTE_ANNULLAMENTO,
                               0,
                               ID_PROTOCOLLO_DATI_REG_GIORN,
                               0
                          FROM AGP_PROTOCOLLI
                         WHERE id_documento = d_id_documento;
                  END IF;
               END IF;

               DBMS_OUTPUT.put_line (
                  'd_id_classificazione_old: ' || d_id_classificazione_old);

               IF d_is_fasc_princ = 0
               THEN
                  IF p_sposta = 1 AND d_id_classificazione_old IS NOT NULL
                  THEN
                     -- elimina precedente classifica / fascicolo secondario di un documento
                     AGP_DOCUMENTI_TITOLARIO_PKG.elimina (
                        P_ID_DOCUMENTO_ESTERNO,
                        P_CLASS_COD_OLD,
                        P_CLASS_DAL_OLD,
                        P_FASCICOLO_ANNO_OLD,
                        P_FASCICOLO_NUMERO_OLD,
                        P_UTENTE_UPD);
                  END IF;

                  -- inserisce documento in classifica / fascicolo secondario
                  AGP_DOCUMENTI_TITOLARIO_PKG.INSERISCI (
                     P_ID_DOCUMENTO_ESTERNO,
                     P_CLASS_COD,
                     P_CLASS_DAL,
                     P_FASCICOLO_ANNO,
                     P_FASCICOLO_NUMERO,
                     P_UTENTE_UPD);
               END IF;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_ubicazione_fascicolo (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      d_id_fasc   NUMBER;
      d_return    VARCHAR2 (4000) := '';
   BEGIN
      SELECT id_fascicolo
        INTO d_id_fasc
        FROM agp_protocolli
       WHERE id_documento = p_id_documento;

      IF d_id_fasc IS NOT NULL
      THEN
         d_return := AGS_FASCICOLI_PKG.GET_UBICAZIONE_FASCICOLO (d_id_fasc);
      END IF;

      RETURN d_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END;

   PROCEDURE annulla (P_ID_DOCUMENTO_ESTERNO NUMBER)
   IS
   BEGIN
      UPDATE gdo_documenti
         SET stato = 'ANNULLATO'
       WHERE id_documento_esterno = P_ID_DOCUMENTO_ESTERNO;

      UPDATE agp_protocolli
         SET annullato = 'Y'
       WHERE id_documento =
                (SELECT id_documento
                   FROM gdo_documenti
                  WHERE id_documento_esterno = P_ID_DOCUMENTO_ESTERNO);
   END;

   PROCEDURE set_data_annullamento (P_ID_DOCUMENTO_ESTERNO    NUMBER,
                                    P_DATA_ANN                DATE)
   IS
      d_id   NUMBER;
   BEGIN
      UPDATE AGP_PROTOCOLLI
         SET DATA_ANNULLAMENTO = P_DATA_ANN
       WHERE id_documento =
                (SELECT id_documento
                   FROM gdo_documenti
                  WHERE id_documento_esterno = p_id_documento_esterno);
   END;

   PROCEDURE set_utente_annullamento (P_ID_DOCUMENTO_ESTERNO    NUMBER,
                                      P_UTENTE_ANN              VARCHAR2)
   IS
      d_id   NUMBER;
   BEGIN
      UPDATE AGP_PROTOCOLLI
         SET UTENTE_ANNULLAMENTO = P_UTENTE_ANN
       WHERE id_documento =
                (SELECT id_documento
                   FROM gdo_documenti
                  WHERE id_documento_esterno = p_id_documento_esterno);
   END;

   PROCEDURE set_provvedimento_annullamento (
      P_ID_DOCUMENTO_ESTERNO    NUMBER,
      P_PROVVEDIMENTO           VARCHAR2)
   IS
      d_id   NUMBER;
   BEGIN
      UPDATE AGP_PROTOCOLLI
         SET provvedimento_annullamento = P_PROVVEDIMENTO
       WHERE id_documento =
                (SELECT id_documento
                   FROM gdo_documenti
                  WHERE id_documento_esterno = p_id_documento_esterno);
   END;

   FUNCTION ins_da_esterno (p_utente                  VARCHAR2,
                            p_id_documento_esterno    NUMBER,
                            p_anno                    NUMBER,
                            p_numero                  NUMBER,
                            p_tipo_registro           VARCHAR2,
                            p_data                    DATE,
                            p_oggetto                 VARCHAR2,
                            p_riservato               VARCHAR2,
                            p_codice_amm              VARCHAR2,
                            p_codice_aoo              VARCHAR2,
                            p_modello                 VARCHAR2)
      RETURN NUMBER
   IS
      d_id                   NUMBER;
      d_id_ente              NUMBER;
      d_id_tipo_protocollo   NUMBER;
   BEGIN
      BEGIN
         SELECT MIN (tipr.id_tipo_protocollo)
           INTO d_id_tipo_protocollo
           FROM agp_tipi_protocollo tipr
          WHERE tipr.categoria =
                   DECODE (NVL (p_modello, 'M_PROTOCOLLO'),
                           'M_REGISTRO_GIORNALIERO', 'REGISTRO_GIORNALIERO',
                           'M_PROTOCOLLO_INTEROPERABILITA', 'PEC',
                           'M_PROTOCOLLO_EMERGENZA', 'EMERGENZA',
                           'LETTERA_USCITA', 'LETTERA',
                           'M_PROVVEDIMENTO', 'PROVVEDIMENTO',
                           'PROTOCOLLO');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_tipo_protocollo := NULL;
      END;

      BEGIN
         SELECT id_documento, id_ente
           INTO d_id, d_id_ente
           FROM GDO_DOCUMENTI
          WHERE id_documento_esterno = p_id_documento_esterno;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT id_ente
                 INTO d_id_ente
                 FROM gdo_enti
                WHERE     amministrazione = p_codice_amm
                      AND aoo = p_codice_aoo
                      AND valido = 'Y';

               SELECT hibernate_sequence.NEXTVAL INTO d_id FROM DUAL;

               INSERT INTO GDO_DOCUMENTI (ID_DOCUMENTO,
                                          ID_DOCUMENTO_ESTERNO,
                                          ID_ENTE,
                                          VALIDO,
                                          UTENTE_INS,
                                          DATA_INS,
                                          VERSION,
                                          RISERVATO)
                    VALUES (d_id,
                            p_id_documento_esterno,
                            d_id_ente,
                            'Y',
                            p_utente,
                            SYSDATE,
                            0,
                            p_riservato);

               INSERT INTO AGP_PROTOCOLLI (ID_DOCUMENTO,
                                           ANNO,
                                           TIPO_REGISTRO,
                                           NUMERO,
                                           DATA,
                                           ID_TIPO_PROTOCOLLO,
                                           OGGETTO,
                                           CONTROLLO_FUNZIONARIO,
                                           CONTROLLO_FIRMATARIO)
                    VALUES (d_id,
                            p_anno,
                            p_tipo_registro,
                            p_numero,
                            p_data,
                            d_id_tipo_protocollo,
                            p_oggetto,
                            'N',
                            'N');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  raise_application_error (
                     -20999,
                        'Documento esterno '
                     || p_id_documento_esterno
                     || ' non disponibile.');
            END;
      END;

      RETURN d_id;
   END;

   PROCEDURE upd_da_esterno (p_utente                  VARCHAR2,
                             p_id_documento_esterno    NUMBER,
                             p_anno                    NUMBER,
                             p_numero                  NUMBER,
                             p_tipo_registro           VARCHAR2,
                             p_data                    DATE,
                             p_oggetto                 VARCHAR2,
                             p_riservato               VARCHAR2)
   IS
      d_id        NUMBER;
      d_version   NUMBER;
   BEGIN
      BEGIN
         SELECT id_documento
           INTO d_id
           FROM GDO_DOCUMENTI
          WHERE id_documento_esterno = p_id_documento_esterno;

         SELECT NVL (version, 0) + 1
           INTO d_version
           FROM GDO_DOCUMENTI
          WHERE ID_DOCUMENTO = d_id;

         UPDATE GDO_DOCUMENTI
            SET RISERVATO = p_riservato,
                UTENTE_INS = p_utente,
                data_upd = SYSDATE,
                version = d_version
          WHERE ID_DOCUMENTO = d_id;

         UPDATE AGP_PROTOCOLLI
            SET ANNO = p_anno,
                TIPO_REGISTRO = p_tipo_registro,
                NUMERO = p_numero,
                DATA = p_data,
                OGGETTO = p_oggetto
          WHERE ID_DOCUMENTO = d_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END;

   PROCEDURE get_id_titolario (p_class_cod                 VARCHAR2,
                               p_class_dal                 VARCHAR2,
                               p_fascicolo_anno            NUMBER,
                               p_fascicolo_numero          VARCHAR2,
                               p_codice_amm                VARCHAR2,
                               p_codice_aoo                VARCHAR2,
                               p_id_classifica      IN OUT NUMBER,
                               p_id_fascicolo       IN OUT NUMBER)
   IS
      d_id_ente   NUMBER := 1;
   BEGIN
      d_id_ente := agp_utility_pkg.get_id_ente (p_codice_amm, p_codice_aoo);

      BEGIN
         SELECT f.id_classificazione, f.id_documento
           INTO p_id_classifica, p_id_fascicolo
           FROM ags_fascicoli f, gdo_documenti d, ags_classificazioni c
          WHERE     C.classificazione = p_class_cod
                AND c.classificazione_dal =
                       TO_DATE (p_class_dal, 'DD/MM/YYYY')
                AND anno = p_fascicolo_anno
                AND numero = p_fascicolo_numero
                AND C.ID_CLASSIFICAZIONE = F.ID_CLASSIFICAZIONE
                AND d.id_documento = f.id_documento
                AND d.id_ente = d_id_ente;
      EXCEPTION
         WHEN OTHERS
         THEN
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
               || d_id_ente
               || ' '
               || SQLERRM);
      END;
   END;

   FUNCTION crea_attestazione_conformita (p_class_cod           VARCHAR2,
                                          p_class_dal           VARCHAR2,
                                          p_fascicolo_anno      NUMBER,
                                          p_fascicolo_numero    VARCHAR2,
                                          p_utente              VARCHAR2,
                                          p_codice_amm          VARCHAR2,
                                          p_codice_aoo          VARCHAR2)
      RETURN VARCHAR2
   IS
      d_return                  VARCHAR2 (32000);
      d_tipo_doc_scan           VARCHAR2 (100);
      d_esistono_doc_scan       NUMBER := 0;
      d_tipo_prot_conf_scan     VARCHAR2 (250);
      d_oggetto_doc_scan        VARCHAR2 (32000);
      d_id_doc                  NUMBER;
      d_id_doc_gdm              NUMBER;
      d_id_doc_sogg             NUMBER;
      d_id_tipo_prot            NUMBER;
      d_idrif                   VARCHAR2 (1000);
      d_id_classificazione      NUMBER;
      d_id_fascicolo            NUMBER;
      d_controllo_funzionario   VARCHAR2 (1);
      d_id_ente                 NUMBER := 1;
      d_id_cfg_iter             NUMBER;
      d_id_cfg_step             NUMBER;
      d_id_cfg_competenza       NUMBER;
      d_cancellazione           VARCHAR2 (100);
      d_lettura                 VARCHAR2 (100);
      d_modifica                VARCHAR2 (100);
      d_id_file_doc             NUMBER;
      d_id_modello              NUMBER;
      d_unita_protocollante     VARCHAR2 (100);
      d_progr_uo                NUMBER;
      d_dal_uo                  DATE;
      d_ottica_uo               VARCHAR2 (100);
      d_utente_firmatario       VARCHAR2 (100);

      d_temp                    VARCHAR2 (200);
      d_startpos                NUMBER;
      d_stoppos                 NUMBER;
      d_codice_unita_padre      VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT id_ente
           INTO d_id_ente
           FROM gdo_enti
          WHERE amministrazione = p_codice_amm AND aoo = p_codice_aoo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_ente := 1;
      END;

      BEGIN
         d_tipo_prot_conf_scan :=
            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('CONF_SCAN_FLUSSO',
                                                   d_id_ente);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_tipo_prot_conf_scan := NULL;
      END;

      BEGIN
         d_tipo_doc_scan :=
            GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('CONF_SCAN_TRAMITE',
                                                   d_id_ente);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_tipo_doc_scan := NULL;
      END;

      IF d_tipo_prot_conf_scan IS NULL AND d_tipo_doc_scan IS NULL
      THEN
         RETURN NULL;
      END IF;

      BEGIN
         SELECT uopu.codice,
                ursu.uo_progr,
                ursu.uo_dal,
                ursu.ottica
           INTO d_unita_protocollante,
                d_progr_uo,
                d_dal_uo,
                d_ottica_uo
           FROM so4_v_utenti_ruoli_sogg_uo ursu,
                so4_v_unita_organizzative_pubb uopu
          WHERE     uopu.progr = ursu.uo_progr
                AND uopu.dal = ursu.uo_dal
                AND uopu.ottica = ursu.ottica
                AND ursu.ruolo = 'AGPRED'
                AND ursu.utente = p_utente
                AND SYSDATE BETWEEN ursu.uo_dal
                                AND NVL (ursu.uo_al, TO_DATE (3333333, 'j'))
                AND SYSDATE BETWEEN ursu.ruolo_dal
                                AND NVL (ursu.ruolo_al,
                                         TO_DATE (3333333, 'j'))
                AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
               'L''utente ' || p_utente || ' non possiede ruolo ''AGPRED''.');
      END;

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
                AND U.OTTICA = d_ottica_uo
                AND u.PROGR = d_progr_uo
                AND u.dal = d_dal_uo
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
               SELECT so4_ags_pkg.unita_get_unita_padre (
                         d_unita_protocollante,
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
                         AND U.OTTICA = d_ottica_uo
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
                                  AND U.OTTICA = d_ottica_uo
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

      BEGIN
         SELECT f.id_classificazione, f.id_documento
           INTO d_id_classificazione, d_id_fascicolo
           FROM ags_fascicoli f, gdo_documenti d, ags_classificazioni c
          WHERE     C.classificazione = p_class_cod
                AND c.classificazione_dal =
                       TO_DATE (p_class_dal, 'DD/MM/YYYY')
                AND anno = p_fascicolo_anno
                AND numero = p_fascicolo_numero
                AND C.ID_CLASSIFICAZIONE = F.ID_CLASSIFICAZIONE
                AND d.id_documento = f.id_documento
                AND d.id_ente = d_id_ente;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_tipo_doc_scan := '';
         WHEN OTHERS
         THEN
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
               || d_id_ente
               || ' '
               || SQLERRM);
      END;

      BEGIN
         --010   24/10/2019    scaputo       Bug #37724 Attestazione di conformita: bugs
         -- verifica validita del tipo doc e da errore in caso di toomanyrows
         SELECT id_tipo_documento,
                tipr.funz_obbligatorio,
                iter.id_cfg_iter,
                step.id_cfg_step,
                comp.id_cfg_competenza,
                comp.cancellazione,
                comp.lettura,
                comp.modifica,
                id_modello
           INTO d_id_tipo_prot,
                d_controllo_funzionario,
                d_id_cfg_iter,
                d_id_cfg_step,
                d_id_cfg_competenza,
                d_cancellazione,
                d_lettura,
                d_modifica,
                d_id_modello
           FROM gdo_tipi_documento tido,
                agp_tipi_protocollo tipr,
                wkf_cfg_iter iter,
                wkf_cfg_step step,
                wkf_cfg_competenze comp,
                gte_modelli
          WHERE     tido.codice = d_tipo_prot_conf_scan
                AND tipr.id_tipo_protocollo = tido.id_tipo_documento
                AND tido.valido = 'Y'
                AND id_ente = d_id_ente
                AND iter.progressivo = progressivo_cfg_iter
                AND iter.stato = 'IN_USO'
                AND step.id_cfg_iter = iter.id_cfg_iter
                AND step.nome = 'REDAZIONE'
                AND comp.id_cfg_step = step.id_cfg_step
                AND comp.assegnazione = 'IN'
                AND tipo_modello = 'ATTESTAZIONE_CONFORMITA'
                AND gte_modelli.valido = 'Y'
                AND comp.id_attore = step.id_attore;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_tipo_doc_scan := '';
         WHEN TOO_MANY_ROWS
         THEN
            RAISE_APPLICATION_ERROR (
               -20999,
                  'Esistono più tipi di protocollo associati al flusso '
               || d_tipo_prot_conf_scan
               || '.');
      END;

      IF d_tipo_prot_conf_scan IS NOT NULL AND d_tipo_doc_scan IS NOT NULL
      THEN
         -- Verifica se esistono nel fascicolo dei documenti con tipologia associata alla scansione
         -- per cui la chiusura del fascicolo deve anche attestarne la conformità
         SELECT COUNT (1)
           INTO d_esistono_doc_scan
           FROM agp_proto_view
          WHERE     class_cod = p_class_cod
                AND class_dal = TO_DATE (p_class_dal, 'DD/MM/YYYY')
                AND fascicolo_anno = p_fascicolo_anno
                AND fascicolo_numero = p_fascicolo_numero
                AND documento_tramite = d_tipo_doc_scan;

         IF d_esistono_doc_scan > 0
         THEN
            d_id_doc_gdm :=
               gdm_profilo.crea_documento ('SEGRETERIA.PROTOCOLLO',
                                           'LETTERA_USCITA',
                                           NULL,
                                           p_utente,
                                           1);

            SELECT GDM_SEQ_IDRIF.NEXTVAL INTO d_idrif FROM DUAL;

            d_oggetto_doc_scan :=
               GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('CONF_SCAN_OGGETTO',
                                                      d_id_ente);

            DECLARE
               d_id_rev         NUMBER;
               d_id_file_doc    NUMBER;
               d_id_soggetto    NUMBER;
               d_id_revisione   NUMBER;
            BEGIN
               AGP_TRASCO_PKG.CREA_DOCUMENTO (d_id_doc_gdm,
                                              d_id_ente,
                                              'Y',
                                              'N',
                                              P_UTENTE,
                                              SYSDATE,
                                              P_UTENTE,
                                              SYSDATE,
                                              NULL,
                                              'PROTOCOLLO',
                                              NULL,
                                              d_id_doc,
                                              d_id_rev,
                                              TRUE);

               d_id_file_doc :=
                  AGP_TRASCO_PKG.crea_file_documento (d_id_doc,
                                                      NULL,
                                                      p_utente,
                                                      SYSDATE,
                                                      p_utente,
                                                      SYSDATE,
                                                      'FILE_PRINCIPALE',
                                                      'LETTERA.odt',
                                                      0,
                                                      'N');

               d_id_soggetto :=
                  AGP_TRASCO_PKG.crea_documento_soggetto (d_id_doc,
                                                          'REDATTORE',
                                                          p_utente,
                                                          d_progr_uo,
                                                          d_dal_uo,
                                                          d_ottica_uo,
                                                          d_id_rev);

               d_id_soggetto :=
                  AGP_TRASCO_PKG.crea_documento_soggetto (d_id_doc,
                                                          'UO_PROTOCOLLANTE',
                                                          p_utente,
                                                          d_progr_uo,
                                                          d_dal_uo,
                                                          d_ottica_uo,
                                                          d_id_rev);

               IF d_utente_firmatario IS NOT NULL
               THEN
                  d_id_soggetto :=
                     AGP_TRASCO_PKG.crea_documento_soggetto (d_id_doc,
                                                             'FIRMATARIO',
                                                             p_utente,
                                                             d_progr_uo,
                                                             d_dal_uo,
                                                             d_ottica_uo,
                                                             d_id_rev);
               END IF;

               AGP_TRASCO_PKG.crea_protocollo (d_id_doc,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               'INTERNO',
                                               NULL,
                                               SYSDATE,
                                               d_oggetto_doc_scan,
                                               d_id_classificazione,
                                               d_id_fascicolo,
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
                                               NULL,
                                               NULL,
                                               NULL,
                                               d_id_tipo_prot,
                                               d_controllo_funzionario,
                                               'Y',
                                               d_idrif,
                                               NULL,
                                               NULL,
                                               d_id_rev);
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
                            p_codice_amm,
                            SYSDATE,
                            p_utente,
                            p_utente);

               d_id_revisione :=
                  AGP_TRASCO_PKG.crea_revinfo (
                     TO_TIMESTAMP (SYSDATE, 'DD/MM/YYYY HH24:MI:SS,FF'));

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
                            p_codice_amm,
                            1,
                            NVL (p_utente, 'RPI'),
                            1,
                            NVL (p_utente, 'RPI'),
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
                            p_utente,
                            p_utente);

               UPDATE WKF_ENGINE_ITER
                  SET ID_STEP_CORRENTE = d_id_engine_step
                WHERE ID_ENGINE_ITER = d_id_engine_iter;

               SELECT hibernate_sequence.NEXTVAL
                 INTO d_id_engine_attore
                 FROM DUAL;

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
                            p_utente,
                            p_utente,
                            p_utente);


               SELECT hibernate_sequence.NEXTVAL
                 INTO d_id_documento_competenza
                 FROM DUAL;

               INSERT INTO GDO_DOCUMENTI_COMPETENZE (ID_DOCUMENTO_COMPETENZA,
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
                            p_utente);
            END;

            DECLARE
               d_cognome   VARCHAR2 (1000);
               d_nome      VARCHAR2 (1000);
            BEGIN
               BEGIN
                  SELECT cognome, nome
                    INTO d_cognome, d_nome
                    FROM as4_v_soggetti
                   WHERE utente = p_utente AND SYSDATE BETWEEN dal AND al;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     d_cognome := '';
                     d_nome := '';
               END;

               UPDATE gdm_lettere_uscita
                  SET oggetto = d_oggetto_doc_scan,
                      idrif = d_idrif,
                      class_cod = p_class_cod,
                      class_dal = TO_DATE (p_class_dal, 'DD/MM/YYYY'),
                      fascicolo_anno = p_fascicolo_anno,
                      fascicolo_numero = p_fascicolo_numero,
                      utente_protocollante = p_utente,
                      unita_protocollante = d_unita_protocollante,
                      codice_amministrazione = p_codice_amm,
                      codice_aoo = p_codice_aoo,
                      key_iter_lettera = -1,
                      master = 'Y',
                      modalita = 'INT',
                      posizione_flusso = 'REDAZIONE',
                      oggi = SYSDATE,
                      riservato = 'N',
                      stato_pr = 'DP',
                      tipo_lettera = 'INTERNA',
                      cognome = d_cognome,
                      nome = d_nome
                WHERE id_documento = d_id_doc_gdm;
            END;

            INSERT INTO gdm_riferimenti (ID_DOCUMENTO,
                                         ID_DOCUMENTO_RIF,
                                         AREA,
                                         TIPO_RELAZIONE,
                                         DATA_AGGIORNAMENTO,
                                         UTENTE_AGGIORNAMENTO)
                 VALUES (-d_id_fascicolo,
                         d_id_doc_gdm,
                         'SEGRETERIA.PROTOCOLLO',
                         'PROT_FATCO',
                         SYSDATE,
                         p_utente);

            d_return :=
                  GDO_IMPOSTAZIONI_PKG.GET_IMPOSTAZIONE ('AG_SERVER_URL',
                                                         d_id_ente)
               || '/Protocollo/standalone.zul?operazione=APRI_DOCUMENTO&tipoDocumento=LETTERA&idDoc='
               || d_id_doc_gdm;
            DBMS_OUTPUT.put_line (d_return);
         END IF;
      END IF;

      RETURN d_return;
   END;

   FUNCTION is_attestazione_conformita (p_id_documento_esterno NUMBER)
      RETURN NUMBER
   IS
      d_return   NUMBER := 0;
   BEGIN
      SELECT COUNT (1)
        INTO d_return
        FROM gdm_riferimenti r
       WHERE     r.id_documento_rif = p_id_documento_esterno
             AND area = 'SEGRETERIA.PROTOCOLLO'
             AND tipo_relazione = 'PROT_FATCO';

      IF d_return > 0
      THEN
         d_return := 1;
      END IF;

      RETURN d_return;
   END;

   FUNCTION get_attestaz_conform_in_corso (p_id_fascicolo    NUMBER,
                                           p_utente          VARCHAR2,
                                           p_id_ente         NUMBER)
      RETURN NUMBER
   IS
      d_return   NUMBER;
   BEGIN
      DECLARE
         d_id_doc_gdm_attestazione   NUMBER := 0;
      BEGIN
         SELECT MAX (id_documento_rif)
           INTO d_id_doc_gdm_attestazione
           FROM gdo_documenti d, agp_protocolli p, gdm_riferimenti r
          WHERE     r.id_documento = -p_id_fascicolo
                AND d.id_documento_esterno = id_documento_rif
                AND d.valido = 'Y'
                AND p.id_documento = d.id_documento
                AND p.numero IS NULL
                AND area = 'SEGRETERIA.PROTOCOLLO'
                AND tipo_relazione = 'PROT_FATCO';

         DBMS_OUTPUT.PUT_LINE (
            'd_id_doc_gdm_attestazione:' || d_id_doc_gdm_attestazione);

         d_return := d_id_doc_gdm_attestazione;
      END;

      RETURN d_return;
   END;

   FUNCTION get_attestaz_conform_in_corso (p_class_cod           VARCHAR2,
                                           p_class_dal           VARCHAR2,
                                           p_fascicolo_anno      NUMBER,
                                           p_fascicolo_numero    VARCHAR2,
                                           p_utente              VARCHAR2,
                                           p_codice_amm          VARCHAR2,
                                           p_codice_aoo          VARCHAR2)
      RETURN NUMBER
   IS
      d_id_ente         NUMBER := 1;
      d_id_fascicolo    NUMBER;
      d_id_classifica   NUMBER;
   BEGIN
      DBMS_OUTPUT.PUT_LINE (
            'get_attestaz_conform_in_corso ('''
         || p_class_cod
         || ''','''
         || p_class_dal
         || ''','
         || p_fascicolo_anno
         || ','''
         || p_fascicolo_numero
         || ''', '''
         || p_utente
         || ''', '''
         || p_codice_amm
         || ''', '''
         || p_codice_aoo
         || ''')');
      d_id_ente := agp_utility_pkg.get_id_ente (p_codice_amm, p_codice_aoo);
      get_id_titolario (p_class_cod,
                        p_class_dal,
                        p_fascicolo_anno,
                        p_fascicolo_numero,
                        p_codice_amm,
                        p_codice_aoo,
                        d_id_classifica,
                        d_id_fascicolo);


      DBMS_OUTPUT.PUT_LINE ('d_id_fascicolo:' || d_id_fascicolo);
      RETURN get_attestaz_conform_in_corso (d_id_fascicolo,
                                            p_utente,
                                            d_id_ente);
   END;

   FUNCTION get_id_documento (p_id_documento_esterno NUMBER)
      RETURN NUMBER
   IS
      d_id   NUMBER;
   BEGIN
      BEGIN
         SELECT id_documento
           INTO d_id
           FROM GDO_DOCUMENTI
          WHERE id_documento_esterno = p_id_documento_esterno;

         RETURN d_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN NULL;
      END;
   END;

   FUNCTION is_documento_agspr (p_id_documento_esterno NUMBER)
      RETURN NUMBER
   IS
      d_ret   NUMBER := 0;
   BEGIN
      SELECT COUNT (1)
        INTO d_ret
        FROM GDO_DOCUMENTI d
       WHERE d.id_documento_esterno = p_id_documento_esterno;

      IF d_ret > 0
      THEN
         d_ret := 1;
      END IF;

      RETURN d_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END;

   FUNCTION is_protocollo_agspr (p_id_documento_esterno NUMBER)
      RETURN NUMBER
   IS
      d_ret   NUMBER := 0;
   BEGIN
      SELECT COUNT (1)
        INTO d_ret
        FROM GDO_DOCUMENTI d, AGP_PROTOCOLLI p
       WHERE     d.id_documento_esterno = p_id_documento_esterno
             AND p.id_documento = d.id_documento
             AND p.idrif IS NOT NULL;

      IF d_ret > 0
      THEN
         d_ret := 1;
      END IF;

      RETURN d_ret;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END;

   FUNCTION crea_protocollo_esterno (p_id_documento_esterno NUMBER)
      RETURN NUMBER
   IS
      d_id_doc                 NUMBER;
      d_id_tipo_protocollo     NUMBER;
      d_utente_protocollante   VARCHAR2 (100);
   BEGIN
      BEGIN
         SELECT id_documento
           INTO d_id_doc
           FROM gdo_documenti
          WHERE id_documento_esterno = p_id_documento_esterno;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            FOR p
               IN (SELECT p.anno,
                          p.numero,
                          p.tipo_registro,
                          p.data,
                          p.oggetto,
                          NVL (p.annullato, 'N') annullato,
                          p.modalita,
                          p.unita_protocollante,
                          p.utente_protocollante,
                          d.utente_aggiornamento,
                          d.data_aggiornamento,
                          0,
                          NVL (p.riservato, 'N') riservato,
                          p.categoria
                     FROM agp_proto_view p, gdm_documenti d
                    WHERE     p.id_documento = p_id_documento_esterno
                          AND d.id_documento = p.id_documento)
            LOOP
               /* calcolo flusso per la categoria di protocolli */
               d_id_tipo_protocollo :=
                  agp_trasco_pkg.get_id_tipo_protocollo_default (p.categoria);

               IF    p.categoria <> 'PEC'
                  OR (    p.categoria = 'PEC'
                      AND p.anno IS NOT NULL
                      AND p.numero IS NOT NULL)
               THEN
                  d_utente_protocollante :=
                     NVL (p.utente_protocollante, 'RPI');
               END IF;

               d_id_doc :=
                  AGP_TRASCO_PKG.CREA_PROTOCOLLO_ESTERNO (
                     p_id_documento_esterno,
                     1,
                     'Y',
                     p.riservato,
                     d_id_tipo_protocollo,
                     p.oggetto,
                     p.annullato,
                     p.anno,
                     p.numero,
                     p.tipo_registro,
                     p.data,
                     p.modalita,
                     p.unita_protocollante,
                     d_utente_protocollante,
                     p.utente_protocollante,
                     p.data_aggiornamento,
                     p.utente_aggiornamento,
                     p.data_aggiornamento);
            END LOOP;
      END;

      RETURN d_id_doc;
   END;

   PROCEDURE accetta_richiesta_annullamento (
      p_id_documento_esterno     NUMBER,
      p_data_acc_annullamento    DATE)
   IS
      d_id_doc   NUMBER;
   BEGIN
      BEGIN
         -- se esiste gia' in agspr, non si deve fare nulla
         SELECT d.id_documento
           INTO d_id_doc
           FROM gdo_documenti d, agp_protocolli p
          WHERE     p.id_documento = d.id_documento
                AND d.id_documento_esterno = p_id_documento_esterno
                AND idrif IS NOT NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            d_id_doc := crea_protocollo_esterno (p_id_documento_esterno);

            UPDATE GDO_DOCUMENTI
               SET STATO = 'DA_ANNULLARE',
                   UTENTE_UPD = 'RPI',
                   DATA_UPD = p_data_acc_annullamento
             WHERE id_documento = d_id_doc;

            INSERT INTO AGP_PROTOCOLLI_ANNULLAMENTI (
                           ID_PROTOCOLLO_ANNULLAMENTO,
                           ID_DOCUMENTO,
                           MOTIVO,
                           STATO,
                           UNITA_PROGR,
                           UNITA_DAL,
                           UNITA_OTTICA,
                           UTENTE_ACC_RIF,
                           DATA_ACC_RIF,
                           VALIDO,
                           UTENTE_INS,
                           DATA_INS,
                           UTENTE_UPD,
                           DATA_UPD,
                           VERSION)
               SELECT hibernate_sequence.NEXTVAL,
                      d_id_doc,
                      p.motivo_ann,
                      'ACCETTATO',
                      u.progr,
                      u.dal,
                      u.ottica,
                      '',
                      p_data_acc_annullamento,
                      'Y',
                      p.utente_richiesta_ann,
                      p.data_richiesta_ann,
                      'RPI',
                      p_data_acc_annullamento,
                      1
                 FROM gdm_proto_view p, so4_v_unita_organizzative_pubb u
                WHERE     p.id_documento = p_id_documento_esterno
                      AND U.CODICE = p.unita_richiesta_ann
                      AND p.data_richiesta_ann BETWEEN u.dal
                                                   AND NVL (
                                                          al,
                                                          p.data_richiesta_ann);
      END;
   END;
END;
/