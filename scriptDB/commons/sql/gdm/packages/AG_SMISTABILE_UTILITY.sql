--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_SMISTABILE_UTILITY runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE AG_SMISTABILE_UTILITY
IS
   /******************************************************************************
    NOME:        AG_SMISTABILE_UTILITY
    DESCRIZIONE: Procedure e Funzioni di utility documenti smistabili.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   10/02/2014 MM     Creazione.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_gestione_smistamenti (p_area         IN VARCHAR2,
                                      p_cm           IN VARCHAR2,
                                      p_cr           IN VARCHAR2,
                                      p_utente       IN VARCHAR2,
                                      p_codice_amm   IN VARCHAR2,
                                      p_codice_aoo   IN VARCHAR2,
                                      p_rw           IN VARCHAR2,
                                      p_stato_pr     IN VARCHAR2,
                                      p_modalita     IN VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION ricongiungi_a_fascicolo (p_area      VARCHAR2,
                                     p_cm        VARCHAR2,
                                     p_cr        VARCHAR2,
                                     p_utente    VARCHAR2,
                                     p_unita     VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION calcola_icona (p_idrif_documento    VARCHAR2,
                           p_id_cartella        NUMBER,
                           p_icona_default      VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION GET_TIPO_DOCUMENTO (P_ID_DOCUMENTO NUMBER)
      RETURN VARCHAR2;

   FUNCTION HAS_TIDO_SEQUENZA (P_ID_DOCUMENTO NUMBER)
      RETURN NUMBER;

   FUNCTION HAS_TIDO_SEQUENZA (P_IDRIF VARCHAR2)
      RETURN NUMBER;

   FUNCTION GET_NEXT_UNITA_RICEVENTE (p_id_documento          NUMBER,
                                      p_unita_trasmissione    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION GET_NEXT_UNITA_RICEVENTE (p_idrif                 VARCHAR2,
                                      p_unita_trasmissione    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION IS_FASCICOLO_OBBLIGATORIO (p_id_documento          NUMBER,
                                       p_unita_trasmissione    VARCHAR2)
      RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY AG_SMISTABILE_UTILITY
IS
   /******************************************************************************
    NOME:        AG_SMISTABILE_UTILITY
    DESCRIZIONE: Procedure e Funzioni di utility documenti smistabili.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    000  10/02/2014 MM     Creazione.
         26/04/2017 SC     ALLINEATO ALLO STANDARD
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '000';

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

   FUNCTION get_gestione_smistamenti (p_area         IN VARCHAR2,
                                      p_cm           IN VARCHAR2,
                                      p_cr           IN VARCHAR2,
                                      p_utente       IN VARCHAR2,
                                      p_codice_amm   IN VARCHAR2,
                                      p_codice_aoo   IN VARCHAR2,
                                      p_rw           IN VARCHAR2,
                                      p_stato_pr     IN VARCHAR2,
                                      p_modalita     IN VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      /*****************************************************************************
         NOME:        GET_GESTIONE_SMISTAMENTI

         DESCRIZIONE:

         RITORNO:

         Rev.  Data       Autore  Descrizione.
         00    05/12/2008  MM  Prima emissione.
      ********************************************************************************/
      d_result                afc.t_ref_cursor;
      d_abilita_smista_iter   VARCHAR2 (1) := 'N';
   BEGIN
      d_abilita_smista_iter :=
         UPPER (ag_parametro.get_valore ('ITER_FASCICOLI_',
                                         p_codice_amm,
                                         p_codice_aoo,
                                         'N'));

      OPEN d_result FOR
         SELECT ag_barra.get_ripudio (p_area,
                                      p_cm,
                                      p_cr,
                                      p_utente)
                   AS ripudio,
                ag_barra.get_da_ricevere (p_area,
                                          p_cm,
                                          p_cr,
                                          p_utente,
                                          p_codice_amm,
                                          p_codice_aoo)
                   da_ricevere,
                ag_barra.get_in_carico (p_area,
                                        p_cm,
                                        p_cr,
                                        p_utente,
                                        p_rw,
                                        p_codice_amm,
                                        p_codice_aoo)
                   in_carico,
                ag_barra.get_eseguito (p_area,
                                       p_cm,
                                       p_cr,
                                       p_utente,
                                       p_codice_amm,
                                       p_codice_aoo)
                   AS eseguito,
                ag_barra.get_visualizza (p_area,
                                         p_cm,
                                         p_cr,
                                         p_utente,
                                         NVL (p_rw, 'R'),
                                         NVL (p_stato_pr, stato_pr),
                                         p_codice_amm,
                                         p_codice_aoo,
                                         NVL (p_modalita, modalita))
                   lettura,
                DECODE ( /*ag_competenze_protocollo.abilita_azione_smistamento
                                                                         (p_cr,
                                            ,                             p_area,
                                                                          p_cm,
                                                                          p_utente,
                                                                          'SMISTA'
                                                                         )*/
                        0, 1, 'SMISTA_TUTTI') AS smista_tutti,
                d_abilita_smista_iter abilitazione_per_iter
           FROM DOCUMENTI, SMISTABILE_VIEW, TIPI_DOCUMENTO
          WHERE     DOCUMENTI.AREA = p_area
                AND DOCUMENTI.CODICE_RICHIESTA = P_CR
                AND TIPI_DOCUMENTO.NOME = P_CM
                AND SMISTABILE_VIEW.ID_DOCUMENTO = DOCUMENTI.ID_DOCUMENTO
                AND TIPI_DOCUMENTO.ID_TIPODOC = DOCUMENTI.ID_TIPODOC;

      RETURN d_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         raise_application_error (
            -20999,
            'AG_DOCUMENTO_UTILITY.GET_GESTIONE_SMISTEMENTI: ' || SQLERRM);
   END get_gestione_smistamenti;

   FUNCTION ricongiungi_a_fascicolo (p_area      VARCHAR2,
                                     p_cm        VARCHAR2,
                                     p_cr        VARCHAR2,
                                     p_utente    VARCHAR2,
                                     p_unita     VARCHAR2)
      RETURN VARCHAR2
   IS
      ret                        VARCHAR2 (32000) := '';
      dep_class_cod              VARCHAR2 (32000);
      dep_class_dal              DATE;
      dep_fascicolo_anno         NUMBER;
      dep_fascicolo_numero       VARCHAR2 (32000);
      dep_idrif_documento        VARCHAR2 (32000);
      dep_idrif_fascicolo        VARCHAR2 (32000);
      dep_id_documento           NUMBER;
      dep_ubicazione_fascicolo   VARCHAR2 (32000);
      dep_assegnatore            NUMBER := 0;
      dep_data_rif               DATE;
   BEGIN
      SELECT class_cod,
             class_dal,
             fascicolo_anno,
             fascicolo_numero,
             smistabile_view.idrif,
             smistabile_view.id_documento
        INTO dep_class_cod,
             dep_class_dal,
             dep_fascicolo_anno,
             dep_fascicolo_numero,
             dep_idrif_documento,
             dep_id_documento
        FROM smistabile_view, documenti, tipi_documento
       WHERE     smistabile_view.id_documento = documenti.id_documento
             AND documenti.area = p_area
             AND documenti.codice_richiesta = p_cr
             AND documenti.id_tipodoc = tipi_documento.id_tipodoc
             AND tipi_documento.area_modello = p_area
             AND tipi_documento.nome = p_cm;

      dep_data_rif := ag_utilities.get_Data_rif_privilegi (dep_id_documento);

      BEGIN
         SELECT idrif
           INTO dep_idrif_fascicolo
           FROM seg_fascicoli fasc, cartelle cart, documenti docu
          WHERE     fasc.class_cod = dep_class_cod
                AND fasc.class_dal = dep_class_dal
                AND fasc.fascicolo_numero = dep_fascicolo_numero
                AND fasc.fascicolo_anno = dep_fascicolo_anno
                AND fasc.id_documento = docu.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND docu.id_documento = cart.id_documento_profilo
                AND NVL (cart.stato, 'BO') != 'CA';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            dep_idrif_fascicolo := NULL;
      END;

      IF dep_idrif_fascicolo IS NOT NULL
      THEN
         dep_ubicazione_fascicolo :=
            ag_fascicolo_utility.get_unita_comp_attuale (dep_idrif_fascicolo);

         IF     dep_ubicazione_fascicolo IS NOT NULL
            AND NVL (p_unita, dep_ubicazione_fascicolo) =
                   dep_ubicazione_fascicolo
         THEN
            IF    ag_utilities.verifica_privilegio_utente (NULL,
                                                           'ASSTOT',
                                                           p_utente,
                                                           TRUNC (SYSDATE)) >
                     0
               OR ag_utilities.verifica_privilegio_utente (
                     dep_ubicazione_fascicolo,
                     'ASS',
                     p_utente,
                     dep_data_rif) > 0
            THEN
               dep_assegnatore := 1;
            END IF;

            IF    (    ag_utilities.verifica_categoria_documento (
                          dep_id_documento,
                          'PROTO') = 1
                   AND   ag_competenze_protocollo.da_ricevere (
                            dep_id_documento,
                            p_utente,
                            0,
                            dep_assegnatore,
                            dep_ubicazione_fascicolo)
                       + ag_competenze_protocollo.in_carico (
                            dep_id_documento,
                            p_utente,
                            0,
                            dep_assegnatore,
                            dep_ubicazione_fascicolo)
                       + ag_competenze_protocollo.eseguito (
                            dep_id_documento,
                            p_utente,
                            dep_ubicazione_fascicolo) > 0)
               OR (    ag_utilities.verifica_categoria_documento (
                          dep_id_documento,
                          'PROTO') = 0
                   AND   ag_competenze_documento.da_ricevere (
                            dep_id_documento,
                            p_utente,
                            0,
                            dep_assegnatore,
                            dep_ubicazione_fascicolo)
                       + ag_competenze_documento.in_carico (
                            dep_id_documento,
                            p_utente,
                            0,
                            dep_assegnatore,
                            dep_ubicazione_fascicolo)
                       + ag_competenze_documento.eseguito (
                            dep_id_documento,
                            p_utente,
                            dep_ubicazione_fascicolo) > 0)
            THEN
               FOR s
                  IN (SELECT smis_prot.id_documento
                        FROM seg_smistamenti smis_prot
                       WHERE     smis_prot.tipo_smistamento = 'COMPETENZA'
                             AND smis_prot.stato_smistamento IN ('R',
                                                                 'C',
                                                                 'E')
                             AND smis_prot.ufficio_smistamento =
                                    dep_ubicazione_fascicolo
                             AND (   dep_assegnatore > 0
                                  OR NVL (smis_prot.codice_assegnatario,
                                          p_utente) = p_utente)
                             AND smis_prot.idrif = dep_idrif_documento)
               LOOP
                  UPDATE seg_smistamenti
                     SET stato_smistamento = 'F',
                         note =
                               DECODE (note,
                                       NULL, '',
                                       note || CHR (10) || CHR (13))
                            || 'Smistamento storicizzato in data '
                            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi:ss')
                            || ' per ricongiungimento a Fascicolo '
                            || dep_class_cod
                            || ' - '
                            || dep_fascicolo_anno
                            || '/'
                            || dep_fascicolo_numero
                            || ' su richiesta di '
                            || ag_soggetto.get_denominazione (p_utente)
                            || '.'
                   WHERE id_documento = s.id_documento;

                  ag_smistamento.delete_task_esterni (s.id_documento);
               END LOOP;
            END IF;
         ELSE
            IF dep_ubicazione_fascicolo IS NULL
            THEN
               ret := ' non ha ubicazione ';
            END IF;

            IF dep_ubicazione_fascicolo IS NOT NULL AND p_unita IS NOT NULL
            THEN
               ret :=
                     ' e'' ubicato in '
                  || ag_unita_utility.get_descrizione (
                        dep_ubicazione_fascicolo,
                        SYSDATE)
                  || ', non in '
                  || ag_unita_utility.get_descrizione (p_unita, SYSDATE);
            END IF;

            ret :=
                  'Il fascicolo '
               || dep_class_cod
               || ' - '
               || dep_fascicolo_anno
               || '/'
               || dep_fascicolo_numero
               || ret;
         END IF;
      END IF;

      RETURN ret;
   EXCEPTION
      WHEN OTHERS
      THEN
         ret := 'Ricongiungimento al fascicolo fallito ' || SQLERRM;
         RETURN ret;
   END;

   FUNCTION calcola_icona (p_idrif_documento    VARCHAR2,
                           p_id_cartella        NUMBER,
                           p_icona_default      VARCHAR2)
      RETURN VARCHAR2
   AS
      ret                        icone.icona%TYPE;
      dep_class_cod              seg_classificazioni.class_cod%TYPE;
      dep_class_dal              seg_classificazioni.class_dal%TYPE;
      dep_fascicolo_anno         seg_fascicoli.fascicolo_anno%TYPE;
      dep_fascicolo_numero       seg_fascicoli.fascicolo_numero%TYPE;
      dep_class_cod_doc          seg_classificazioni.class_cod%TYPE;
      dep_class_dal_doc          seg_classificazioni.class_dal%TYPE;
      dep_fascicolo_anno_doc     seg_fascicoli.fascicolo_anno%TYPE;
      dep_fascicolo_numero_doc   seg_fascicoli.fascicolo_numero%TYPE;
      dep_idrif_f                seg_fascicoli.idrif%TYPE;
      dep_id_documento           NUMBER;
   BEGIN
      IF NVL (p_id_cartella, 0) = 0
      THEN
         RETURN p_icona_default;
      END IF;

      BEGIN
         IF ag_fascicolo_utility.is_fascicolo (p_id_cartella) = 0
         THEN
            RETURN p_icona_default;
         END IF;

         SELECT class_cod,
                class_dal,
                fascicolo_anno,
                fascicolo_numero,
                documenti.id_documento
           INTO dep_class_cod_doc,
                dep_class_dal_doc,
                dep_fascicolo_anno_doc,
                dep_fascicolo_numero_doc,
                dep_id_documento
           FROM smistabile_view, documenti
          WHERE     documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND documenti.id_documento = smistabile_view.id_documento
                AND smistabile_view.idrif = p_idrif_documento;

         IF NVL (dep_fascicolo_anno_doc, 0) = 0
         THEN
            RETURN p_icona_default || '_SEC';
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN p_icona_default;
      END;

      BEGIN
         SELECT class_cod,
                class_dal,
                fascicolo_anno,
                fascicolo_numero,
                idrif
           INTO dep_class_cod,
                dep_class_dal,
                dep_fascicolo_anno,
                dep_fascicolo_numero,
                dep_idrif_f
           FROM seg_fascicoli, cartelle, documenti
          WHERE     cartelle.id_cartella = p_id_cartella
                AND NVL (cartelle.stato, 'BO') = 'BO'
                AND cartelle.id_documento_profilo = documenti.id_documento
                AND documenti.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND documenti.id_documento = seg_fascicoli.id_documento;

         IF     dep_class_cod = dep_class_cod_doc
            AND dep_class_dal = dep_class_dal_doc
            AND dep_fascicolo_anno = dep_fascicolo_anno_doc
            AND dep_fascicolo_numero = dep_fascicolo_numero_doc
         THEN
            IF ag_fascicolo_utility.check_ubicazione_vs_fascicolo (
                  dep_idrif_f,
                  dep_id_documento) = 1
            THEN
               RETURN p_icona_default || '_OUT';
            ELSE
               RETURN p_icona_default;
            END IF;
         ELSE
            RETURN p_icona_default || '_SEC';
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN p_icona_default;
      END;
   END;

   FUNCTION GET_TIPO_DOCUMENTO (P_ID_DOCUMENTO NUMBER)
      RETURN VARCHAR2
   AS
      D_TIPO_DOCUMENTO   VARCHAR2 (100);
   BEGIN
      SELECT TIPO_DOCUMENTO
        INTO D_TIPO_DOCUMENTO
        FROM SMISTABILE_VIEW
       WHERE ID_DOCUMENTO = P_ID_DOCUMENTO;

      RETURN d_tipo_documento;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END GET_TIPO_DOCUMENTO;

   FUNCTION HAS_TIDO_SEQUENZA (P_ID_DOCUMENTO NUMBER)
      RETURN NUMBER
   AS
      D_TIPO_DOCUMENTO   VARCHAR2 (100);
   BEGIN
      D_TIPO_DOCUMENTO := GET_TIPO_DOCUMENTO (P_ID_DOCUMENTO);

      IF D_TIPO_DOCUMENTO IS NOT NULL
      THEN
         RETURN AG_TIPI_DOCUMENTO_UTILITY.HAS_SEQUENZA_SMISTAMENTI (
                   D_TIPO_DOCUMENTO);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END HAS_TIDO_SEQUENZA;

   FUNCTION HAS_TIDO_SEQUENZA (P_IDRIF VARCHAR2)
      RETURN NUMBER
   AS
      D_TIPO_DOCUMENTO   VARCHAR2 (100);
      D_ID_DOCUMENTO     NUMBER;
   BEGIN
      D_ID_DOCUMENTO := AG_UTILITIES.GET_ID_DOCUMENTO_FROM_IDRIF (P_IDRIF);
      RETURN HAS_TIDO_SEQUENZA (D_ID_DOCUMENTO);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END HAS_TIDO_SEQUENZA;

   FUNCTION GET_NEXT_UNITA_RICEVENTE (p_id_documento          NUMBER,
                                      p_unita_trasmissione    VARCHAR2)
      RETURN VARCHAR2
   AS
      d_tipo_documento   VARCHAR2 (100);
   BEGIN
      d_tipo_documento := get_tipo_documento (p_id_documento);
      RETURN ag_tipi_documento_utility.get_next_unita_smistamento (
                d_tipo_documento,
                p_unita_trasmissione);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END GET_NEXT_UNITA_RICEVENTE;

   FUNCTION GET_NEXT_UNITA_RICEVENTE (p_idrif                 VARCHAR2,
                                      p_unita_trasmissione    VARCHAR2)
      RETURN VARCHAR2
   AS
      D_ID_DOCUMENTO   NUMBER;
   BEGIN
      D_ID_DOCUMENTO := AG_UTILITIES.GET_ID_DOCUMENTO_FROM_IDRIF (P_IDRIF);
      RETURN GET_NEXT_UNITA_RICEVENTE (D_ID_DOCUMENTO, P_UNITA_TRASMISSIONE);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END GET_NEXT_UNITA_RICEVENTE;

   FUNCTION IS_FASCICOLO_OBBLIGATORIO (p_id_documento          NUMBER,
                                       p_unita_trasmissione    VARCHAR2)
      RETURN NUMBER
   AS
      d_tipo_documento   VARCHAR2 (100);
   BEGIN
      d_tipo_documento := get_tipo_documento (p_id_documento);
      RETURN ag_tipi_documento_utility.IS_FASCICOLO_OBBLIGATORIO (
                d_tipo_documento,
                p_unita_trasmissione);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END IS_FASCICOLO_OBBLIGATORIO;
END;
/
