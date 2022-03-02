--liquibase formatted sql
--changeset esasdelli:GDM_PACKAGE_AG_UTILITIES_STAMPA runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE "AG_UTILITIES_STAMPA"
AS
   /******************************************************************************
    NOME:        AG_UTILITIES_STAMPA.
    DESCRIZIONE: Procedure e Funzioni di utility in fase di stama o estrazione dati
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    00   07/03/2017 MM     V2.7.
   ******************************************************************************/
   s_revisione   afc.t_revision := 'V1.00';

   FUNCTION versione
      RETURN VARCHAR2;

   FUNCTION get_denominazione_rapporto (p_id_rapporto VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_comune_res_rapporto (p_id_rapporto VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_altra_registrazione (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION count_rapporti (p_idrif VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_dati_documento (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN afc.t_ref_cursor;

   FUNCTION exists_documento_principale (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_allegati (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_cognome_nome_utente (p_utente VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_descrizione_unita (p_unita                     VARCHAR2,
                                   p_data                      DATE,
                                   p_codice_amministrazione    VARCHAR2,
                                   p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_precedente (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_descrizione_tipo_documento (
      p_tipo_documento            VARCHAR2,
      p_data                      DATE,
      p_codice_amministrazione    VARCHAR2,
      p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_descrizione_tramite (p_tramite                   VARCHAR2,
                                     p_data                      DATE,
                                     p_codice_amministrazione    VARCHAR2,
                                     p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_conservato (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_estremi_emergenza (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_estremi_atto (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_documento_principale (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_riservato (p_id_documento NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_corrispondenti (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_smistamenti (p_idrif VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_descrizione_classifica (p_class_cod                 VARCHAR2,
                                        p_class_dal                 DATE,
                                        p_codice_amministrazione    VARCHAR2,
                                        p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_descrizione_fascicolo (p_class_cod                 VARCHAR2,
                                       p_class_dal                 DATE,
                                       p_fascicolo_anno            NUMBER,
                                       p_fasccolo_numero           VARCHAR2,
                                       p_codice_amministrazione    VARCHAR2,
                                       p_codice_aoo                VARCHAR2,
                                       p_utente                    VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_descrizione_tipo_registro (
      p_anno                      NUMBER,
      p_tipo_registro             VARCHAR2,
      p_codice_amministrazione    VARCHAR2,
      p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2;
      FUNCTION elimina_file_stampa_unica (p_idrif VARCHAR2)
      RETURN number;
END ag_utilities_stampa;
/
CREATE OR REPLACE PACKAGE BODY AG_UTILITIES_STAMPA
AS
   /******************************************************************************
    NOME:        AG_FASCICOLO_UTILITY
    DESCRIZIONE: Procedure e Funzioni di utility in fase di inserimento/aggiornamento
                 fascicolo.
    ANNOTAZIONI: Progetto AFFARI_GENERALI.
    REVISIONI:
    Rev. Data       Autore Descrizione
    ---- ---------- ------ ------------------------------------------------------
    001  07/03/2017 MM     Versione 2.7
    002  30/05/2017 MM     Modificata get_denominazione_rapporto in modo che per
                           tipi_soggetto non compresi tra 1 e 10 (ad esempio -1,
                           che corrisponde a rapporti inseriti dall'utente senza
                           riferimento a nessuna anagrafica oppure a soggetti
                           presi da un'anagrafica ma poi modiifcati), se la
                           denominazione è nulla prenda la concatenzaione di nome
                           e cognome.
   ******************************************************************************/
   s_revisione_body   afc.t_revision := '002';

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

   FUNCTION get_denominazione_rapporto (p_id_rapporto VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT DECODE (
                tipo_soggetto,
                '1', cognome_per_segnatura || ' ' || nome_per_segnatura,
                '2', descrizione_amm,
                '3', denominazione_per_segnatura,
                '4', denominazione_per_segnatura,
                '5', cognome_per_segnatura || ' ' || nome_per_segnatura,
                '7', cognome_per_segnatura,
                '8', cognome_per_segnatura,
                '9', cognome_per_segnatura || ' ' || nome_per_segnatura,
                '10', cognome_per_segnatura || ' ' || nome_per_segnatura,
                DECODE (
                   denominazione_per_segnatura,
                   NULL, DECODE (
                               cognome_per_segnatura
                            || ' '
                            || nome_per_segnatura,
                            ' ', descrizione_amm,
                               cognome_per_segnatura
                            || ' '
                            || nome_per_segnatura),
                   denominazione_per_segnatura))
        INTO retval
        FROM seg_soggetti_protocollo
       WHERE id_documento = p_id_rapporto;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_denominazione_rapporto;

   FUNCTION get_comune_res_rapporto (p_id_rapporto VARCHAR2)
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (32000);
   BEGIN
      SELECT DECODE (tipo_soggetto,
                     '1', comune_per_segnatura,
                     '2', comune_amm,
                     comune_per_segnatura)
        INTO retval
        FROM seg_soggetti_protocollo
       WHERE id_documento = p_id_rapporto;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_comune_res_rapporto;

   FUNCTION count_rapporti (p_idrif VARCHAR2)
      RETURN NUMBER
   IS
      ret   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO ret
        FROM seg_soggetti_protocollo sopr, documenti docu
       WHERE     sopr.idrif = p_idrif
             AND sopr.id_documento = docu.id_documento
             AND sopr.tipo_rapporto != 'DUMMY'
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');

      RETURN ret;
   END;

   FUNCTION get_altra_registrazione (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      s_select    VARCHAR2 (32000) := 'SELECT ';
      s_tabella   VARCHAR2 (32000);
      retval      VARCHAR2 (32000) := '';
   BEGIN
      IF ag_utilities.verifica_categoria_documento (p_id_documento, 'ATTI') =
            1
      THEN
         s_tabella := ag_utilities.get_tabella (p_id_documento);

         IF s_tabella LIKE 'SAT%'
         THEN
            s_select :=
                  s_select
               || 'nvl(DESCRIZIONE_TIPO_REGISTRO, TIPO_REGISTRO)||'' ''||ANNO_DETERMINA||''/''||N_DETERMINA ';
         END IF;

         IF s_tabella = 'GAT_DELIBERA'
         THEN
            s_select :=
                  s_select
               || 'nvl(DESCR_REGISTRO_DELIBERA, TIPO_REGISTRO)||'' ''||ANNO_DELIBERA||''/''||NUMERO_DELIBERA ';
         END IF;

         IF s_tabella = 'GAT_DETERMINA'
         THEN
            s_select :=
                  s_select
               || 'nvl(DESCR_REGISTRO_DETERMINA, TIPO_REGISTRO)||'' ''||ANNO_DETERMINA||''/''||NUMERO_DETERMINA ';
         END IF;

         s_select := s_select || ' FROM ' || s_tabella;
         s_select := s_select || ' WHERE ID_DOCUMENTO  = :id_documento';

         EXECUTE IMMEDIATE s_select INTO retval USING p_id_documento;
      END IF;


      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_altra_registrazione;

   FUNCTION get_descrizione_tipo_registro (
      p_anno                      NUMBER,
      p_tipo_registro             VARCHAR2,
      p_codice_amministrazione    VARCHAR2,
      p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_descrizione   SEG_REGISTRI.DESCRIZIONE_TIPO_REGISTRO%TYPE;
   BEGIN
      SELECT DESCRIZIONE_TIPO_REGISTRO
        INTO dep_descrizione
        FROM seg_registri regi, documenti docu
       WHERE     regi.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND regi.anno_reg = p_anno
             AND regi.tipo_Registro = p_tipo_registro
             AND regi.codice_amministrazione = p_codice_amministrazione
             AND regi.codice_aoo = p_codice_aoo;

      RETURN dep_descrizione;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_descrizione_tipo_registro;


   FUNCTION get_corrispondenti (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_corrispondenti              VARCHAR2 (32000) := NULL;
      dep_corrispondenti_diretti      VARCHAR2 (32000) := NULL;
      dep_corrispondenti_conoscenza   VARCHAR2 (32000) := NULL;
   BEGIN
      FOR rapporti
         IN (  SELECT    '- '
                      || NVL (
                            NVL (
                               denominazione_per_segnatura,
                                  cognome_per_segnatura
                               || DECODE (nome_per_segnatura,
                                          NULL, '',
                                          ' ' || nome_per_segnatura)),
                            email)
                         corrispondente
                 FROM seg_soggetti_protocollo sopr, documenti docu
                WHERE     sopr.idrif = p_idrif
                      AND sopr.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND sopr.tipo_rapporto != 'DUMMY'
                      AND sopr.conoscenza = 'N'
             ORDER BY 1)
      LOOP
         IF dep_corrispondenti_diretti IS NULL
         THEN
            dep_corrispondenti_diretti := rapporti.corrispondente;
         ELSE
            dep_corrispondenti_diretti :=
                  dep_corrispondenti_diretti
               || CHR (10)
               || rapporti.corrispondente;
         END IF;
      END LOOP;

      --dbms_output.put_line('dep_corrispondenti_diretti '||dep_corrispondenti_diretti);
      FOR conoscenza
         IN (  SELECT    '- '
                      || NVL (
                            NVL (
                               denominazione_per_segnatura,
                                  cognome_per_segnatura
                               || DECODE (nome_per_segnatura,
                                          NULL, '',
                                          ' ' || nome_per_segnatura)),
                            email)
                         corrispondente
                 FROM seg_soggetti_protocollo sopr, documenti docu
                WHERE     sopr.idrif = p_idrif
                      AND sopr.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND sopr.tipo_rapporto != 'DUMMY'
                      AND sopr.conoscenza = 'Y'
             ORDER BY 1)
      LOOP
         IF dep_corrispondenti_conoscenza IS NULL
         THEN
            dep_corrispondenti_conoscenza := 'Per conoscenza ';
            dep_corrispondenti_conoscenza :=
                  dep_corrispondenti_conoscenza
               || CHR (10)
               || conoscenza.corrispondente;
         ELSE
            dep_corrispondenti_conoscenza :=
                  dep_corrispondenti_conoscenza
               || CHR (10)
               || conoscenza.corrispondente;
         END IF;
      END LOOP;

      --dbms_output.put_line('dep_corrispondenti_conoscenza '||dep_corrispondenti_conoscenza);
      dep_corrispondenti := dep_corrispondenti_diretti;

      IF dep_corrispondenti_conoscenza IS NOT NULL
      THEN
         dep_corrispondenti :=
               dep_corrispondenti
            || CHR (10)
            || CHR (13)
            || dep_corrispondenti_conoscenza;
      END IF;

      --dbms_output.put_line('dep_corrispondenti '||dep_corrispondenti);
      RETURN dep_corrispondenti;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_corrispondenti;

   FUNCTION get_smistamenti (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_smistamenti                VARCHAR2 (32000) := '';
      dep_smistamenti_competenza_R   VARCHAR2 (32000) := '';
      dep_smistamenti_competenza_C   VARCHAR2 (32000) := '';
      dep_smistamenti_conoscenza_R   VARCHAR2 (32000) := '';
   BEGIN
      FOR competenza_R
         IN (  SELECT    TO_CHAR (smistamento_dal, 'dd/mm/yyyy hh24:mi:ss')
                      || ' - '
                      || get_descrizione_unita (smis.ufficio_smistamento,
                                                smis.smistamento_dal,
                                                smis.codice_amministrazione,
                                                smis.codice_aoo)
                         smistamento
                 FROM seg_smistamenti smis, documenti docu
                WHERE     smis.idrif = p_idrif
                      AND smis.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND smis.tipo_smistamento = 'COMPETENZA'
                      AND stato_smistamento = 'R'
             ORDER BY smistamento_dal,
                      get_descrizione_unita (smis.ufficio_smistamento,
                                             smis.smistamento_dal,
                                             smis.codice_amministrazione,
                                             smis.codice_aoo))
      LOOP
         IF dep_smistamenti_competenza_R IS NULL
         THEN
            dep_smistamenti_competenza_R :=
                  'Per competenza - Da ricevere '
               || CHR (10)
               || competenza_R.smistamento;
         ELSE
            dep_smistamenti_competenza_R :=
                  dep_smistamenti_competenza_R
               || CHR (10)
               || competenza_R.smistamento;
         END IF;
      END LOOP;

      FOR competenza_C
         IN (  SELECT    TO_CHAR (smistamento_dal, 'dd/mm/yyyy hh24:mi:ss')
                      || ' - '
                      || get_descrizione_unita (smis.ufficio_smistamento,
                                                smis.smistamento_dal,
                                                smis.codice_amministrazione,
                                                smis.codice_aoo)
                         smistamento
                 FROM seg_smistamenti smis, documenti docu
                WHERE     smis.idrif = p_idrif
                      AND smis.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND smis.tipo_smistamento = 'COMPETENZA'
                      AND stato_smistamento = 'C'
             ORDER BY smistamento_dal,
                      get_descrizione_unita (smis.ufficio_smistamento,
                                             smis.smistamento_dal,
                                             smis.codice_amministrazione,
                                             smis.codice_aoo))
      LOOP
         IF dep_smistamenti_competenza_C IS NULL
         THEN
            dep_smistamenti_competenza_C :=
                  'Per competenza - In carico '
               || CHR (10)
               || competenza_C.smistamento;
         ELSE
            dep_smistamenti_competenza_C :=
                  dep_smistamenti_competenza_C
               || CHR (10)
               || competenza_C.smistamento;
         END IF;
      END LOOP;

      FOR conoscenza_R
         IN (  SELECT    TO_CHAR (smistamento_dal, 'dd/mm/yyyy hh24:mi:ss')
                      || ' - '
                      || get_descrizione_unita (smis.ufficio_smistamento,
                                                smis.smistamento_dal,
                                                smis.codice_amministrazione,
                                                smis.codice_aoo)
                         smistamento
                 FROM seg_smistamenti smis, documenti docu
                WHERE     smis.idrif = p_idrif
                      AND smis.id_documento = docu.id_documento
                      AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND smis.tipo_smistamento = 'CONOSCENZA'
                      AND stato_smistamento = 'R'
             ORDER BY smistamento_dal,
                      get_descrizione_unita (smis.ufficio_smistamento,
                                             smis.smistamento_dal,
                                             smis.codice_amministrazione,
                                             smis.codice_aoo))
      LOOP
         IF dep_smistamenti_conoscenza_R IS NULL
         THEN
            dep_smistamenti_conoscenza_R :=
                  'Per conoscenza - Da ricevere '
               || CHR (10)
               || conoscenza_R.smistamento;
         ELSE
            dep_smistamenti_conoscenza_R :=
                  dep_smistamenti_conoscenza_R
               || CHR (10)
               || conoscenza_R.smistamento;
         END IF;
      END LOOP;


      IF dep_smistamenti_competenza_R IS NOT NULL
      THEN
         dep_smistamenti := dep_smistamenti_competenza_R;
      END IF;

      IF dep_smistamenti_competenza_C IS NOT NULL
      THEN
         IF dep_smistamenti IS NULL
         THEN
            dep_smistamenti := dep_smistamenti_competenza_C;
         ELSE
            dep_smistamenti :=
               dep_smistamenti || CHR (10) || dep_smistamenti_competenza_C;
         END IF;
      END IF;

      IF dep_smistamenti_conoscenza_R IS NOT NULL
      THEN
         IF dep_smistamenti IS NULL
         THEN
            dep_smistamenti := dep_smistamenti_conoscenza_R;
         ELSE
            dep_smistamenti :=
                  dep_smistamenti
               || CHR (10)
               || CHR (13)
               || dep_smistamenti_conoscenza_R;
         END IF;
      END IF;


      RETURN dep_smistamenti;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_smistamenti;

   FUNCTION get_allegati (p_idrif VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_allegati   VARCHAR2 (32000) := '';
   BEGIN
      FOR a
         IN (  SELECT    alpr.quantita
                      || DECODE (tial.descrizione_tipo_allegato,
                                 NULL, ' ',
                                 ' ' || tial.descrizione_tipo_allegato)
                      || ' '
                      || alpr.descrizione
                         ALLEGATO
                 FROM seg_allegati_protocollo alpr,
                      documenti docu_alpr,
                      seg_tipi_allegato tial,
                      documenti docu_tial
                WHERE     alpr.idrif = p_idrif
                      AND alpr.id_documento = docu_alpr.id_documento
                      AND docu_alpr.stato_documento NOT IN ('CA', 'RE', 'PB')
                      AND alpr.tipo_allegato = tial.tipo_allegato(+)
                      AND tial.id_documento = docu_tial.id_documento(+)
                      AND docu_tial.stato_documento(+) NOT IN ('CA', 'RE', 'PB')
             ORDER BY alpr.quantita,
                      tial.descrizione_tipo_allegato,
                      alpr.descrizione)
      LOOP
         IF dep_allegati IS NULL
         THEN
            DEP_ALLEGATI := A.ALLEGATO;
         ELSE
            DEP_ALLEGATI := DEP_ALLEGATI || CHR (10) || A.ALLEGATO;
         END IF;
      END LOOP;

      RETURN dep_allegati;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_allegati;

   FUNCTION get_descrizione_classifica (p_class_cod                 VARCHAR2,
                                        p_class_dal                 DATE,
                                        p_codice_amministrazione    VARCHAR2,
                                        p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_descrizione   VARCHAR2 (32000) := '';
   BEGIN
      SELECT clas.class_descr
        INTO dep_descrizione
        FROM seg_classificazioni clas, documenti docu, cartelle cart
       WHERE     clas.class_cod = p_class_cod
             AND clas.class_dal = p_class_dal
             AND clas.codice_amministrazione = p_codice_amministrazione
             AND clas.codice_aoo = p_codice_aoo
             AND clas.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND cart.id_documento_profilo = docu.id_documento
             AND cart.stato IS NULL;

      RETURN dep_descrizione;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_descrizione_classifica;

   FUNCTION get_estremi_atto (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_estremi   VARCHAR2 (32000) := '';
   BEGIN
      RETURN ag_utilities_stampa.get_altra_registrazione (p_id_documento);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_estremi_atto;

   FUNCTION get_estremi_emergenza (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_estremi   VARCHAR2 (32000) := '';
   BEGIN
      SELECT    ANNO_EMERGENZA
             || '/'
             || NUMERO_EMERGENZA
             || ' '
             || GET_DESCRIZIONE_TIPO_REGISTRO (ANNO_EMERGENZA,
                                               REGISTRO_EMERGENZA,
                                               CODICE_AMMINISTRAZIONE,
                                               CODICE_AOO)
        INTO DEP_ESTREMI
        FROM PROTO_VIEW PROT
       WHERE     PROT.ID_DOCUMENTO = P_ID_DOCUMENTO
             AND PROT.ANNO_EMERGENZA IS NOT NULL
             AND PROT.NUMERO_EMERGENZA IS NOT NULL
             AND PROT.REGISTRO_EMERGENZA IS NOT NULL;

      RETURN dep_estremi;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_estremi_emergenza;

   FUNCTION get_conservato (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_conservato   VARCHAR2 (2) := '';
   BEGIN
      SELECT 'SI'
        INTO dep_conservato
        FROM gdm_t_log_conservazione loco,
             documenti docu,
             documenti docu_prot
       WHERE     docu_prot.id_documento = p_id_documento
             AND loco.id_documento_rif = docu_prot.id_documento
             AND loco.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND loco.stato_conservazione = 'CC';

      RETURN dep_conservato;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_conservato;

   FUNCTION get_riservato (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_riservato   VARCHAR2 (40) := 'NO';
   BEGIN
      SELECT DECODE (riservato, 'Y', 'SI', 'NO')
        INTO dep_riservato
        FROM proto_view prot
       WHERE prot.id_documento = p_id_documento;

      IF dep_riservato = 'NO'
      THEN
         SELECT 'INSERITO IN FASCICOLO RISERVATO'
           INTO dep_riservato
           FROM proto_view prot,
                seg_fascicoli fasc,
                documenti docu_fasc,
                cartelle cart
          WHERE     prot.id_documento = p_id_documento
                AND fasc.class_cod = prot.class_cod
                AND fasc.class_dal = prot.class_dal
                AND fasc.fascicolo_anno = prot.fascicolo_anno
                AND fasc.fascicolo_numero = prot.fascicolo_numero
                AND fasc.codice_amministrazione = prot.codice_amministrazione
                AND fasc.codice_aoo = prot.codice_aoo
                AND fasc.riservato = 'Y'
                AND docu_fasc.id_documento = fasc.id_documento
                AND cart.id_documento_profilo = fasc.id_documento
                AND cart.stato IS NULL
                AND docu_fasc.stato_documento NOT IN ('CA', 'RE', 'PB');
      END IF;

      RETURN dep_riservato;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN dep_riservato;
   END get_riservato;

   FUNCTION get_descrizione_unita (p_unita                     VARCHAR2,
                                   p_data                      DATE,
                                   p_codice_amministrazione    VARCHAR2,
                                   p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_descrizione   VARCHAR2 (32000) := '';
   BEGIN
      SELECT nome
        INTO dep_descrizione
        FROM seg_unita unit
       WHERE     unit.codice_amministrazione = p_codice_amministrazione
             AND unit.codice_aoo = p_codice_aoo
             AND unit.unita = p_unita
             AND p_data BETWEEN dal
                            AND NVL (al, TO_DATE ('31122999', 'ddmmyyyy'));

      RETURN dep_descrizione;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_descrizione_unita;

   FUNCTION get_precedente (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_precedente   VARCHAR2 (32000) := '';
   BEGIN
      SELECT prot.anno || '/' || prot.numero
        INTO dep_precedente
        FROM proto_view prot, documenti docu, riferimenti rife
       WHERE     prot.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND docu.id_documento = rife.id_documento
             AND rife.tipo_relazione = 'PROT_PREC'
             AND rife.id_documento_rif = p_id_documento;

      RETURN dep_precedente;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_precedente;

   FUNCTION get_descrizione_fascicolo (p_class_cod                 VARCHAR2,
                                       p_class_dal                 DATE,
                                       p_fascicolo_anno            NUMBER,
                                       p_fasccolo_numero           VARCHAR2,
                                       p_codice_amministrazione    VARCHAR2,
                                       p_codice_aoo                VARCHAR2,
                                       p_utente                    VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_descrizione   VARCHAR2 (32000) := '';
   BEGIN
      SELECT DECODE (fasc.riservato,
                     'Y', DECODE (GDM_COMPETENZA.GDM_VERIFICA (
                                     'VIEW_CARTELLA',
                                     TO_CHAR (view_cart.ID_VIEWCARTELLA),
                                     'L',
                                     p_utente,
                                     'GDM',
                                     TO_CHAR (SYSDATE, 'DD/MM/YYYY'),
                                     'N'),
                                  1, fasc.fascicolo_oggetto,
                                  'FASCICOLO RISERVATO'),
                     fasc.fascicolo_oggetto)
        INTO dep_descrizione
        FROM seg_fascicoli fasc,
             documenti docu,
             cartelle cart,
             view_cartella view_cart
       WHERE     fasc.class_Cod = p_class_cod
             AND fasc.class_Dal = p_Class_dal
             AND fasc.fascicolo_anno = p_fascicolo_anno
             AND fasc.fascicolo_numero = p_fasccolo_numero
             AND fasc.codice_amministrazione = p_codice_amministrazione
             AND fasc.codice_aoo = p_codice_aoo
             AND fasc.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND cart.id_documento_profilo = docu.id_documento
             AND cart.stato IS NULL
             AND view_cart.id_cartella = cart.id_cartella;

      RETURN dep_descrizione;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_descrizione_fascicolo;

   FUNCTION get_descrizione_tipo_documento (
      p_tipo_documento            VARCHAR2,
      p_data                      DATE,
      p_codice_amministrazione    VARCHAR2,
      p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_descrizione   VARCHAR2 (32000) := '';
   BEGIN
      SELECT descrizione_tipo_documento
        INTO dep_descrizione
        FROM seg_tipi_documento tido, documenti docu
       WHERE     tido.tipo_documento = p_tipo_documento
             AND tido.id_documento = docu.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
             AND tido.codice_amministrazione = p_codice_amministrazione
             AND tido.codice_aoo = p_codice_aoo;

      RETURN dep_descrizione;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_descrizione_tipo_documento;

   FUNCTION get_descrizione_tramite (p_tramite                   VARCHAR2,
                                     p_data                      DATE,
                                     p_codice_amministrazione    VARCHAR2,
                                     p_codice_aoo                VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_descrizione   VARCHAR2 (32000) := '';
   BEGIN
      SELECT DESCRIZIONE_MOD_RICEVIMENTO
        INTO DEP_DESCRIZIONE
        FROM SEG_MODALITA_RICEVIMENTO MORI, DOCUMENTI DOCU
       WHERE     MORI.CODICE_AMMINISTRAZIONE = P_CODICE_AMMINISTRAZIONE
             AND MORI.CODICE_AOO = P_CODICE_AOO
             AND MORI.MOD_RICEVIMENTO = P_TRAMITE
             AND docu.id_documento = mori.id_documento
             AND docu.stato_documento NOT IN ('CA', 'RE', 'PB');

      RETURN dep_descrizione;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_descrizione_tramite;

   FUNCTION get_cognome_nome_utente (p_utente VARCHAR2)
      RETURN VARCHAR2
   IS
      dep_descrizione   VARCHAR2 (32000) := '';
   BEGIN
      SELECT sogg.cognome || ' ' || sogg.nome
        INTO dep_descrizione
        FROM ad4_utenti uten, ad4_utenti_soggetti utso, as4_soggetti sogg
       WHERE     uten.utente = p_utente
             AND uten.utente = utso.utente
             AND utso.soggetto = sogg.ni;

      RETURN dep_descrizione;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '';
   END get_cognome_nome_utente;

   FUNCTION exists_documento_principale (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_si_no   VARCHAR2 (2) := 'NO';
   BEGIN
      SELECT 'SI'
        INTO dep_si_no
        FROM oggetti_file ogfi, proto_view prot
       WHERE     prot.id_documento = p_id_documento
             AND ogfi.id_documento = prot.id_documento
             AND UPPER (OGFI.FILENAME) NOT IN (UPPER (
                                                     numero
                                                  || '_'
                                                  || anno
                                                  || '_'
                                                  || tipo_registro
                                                  || '.PDF'),
                                               'LETTERAUNIONE.RTFHIDDEN');

      RETURN dep_si_no;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN dep_si_no;
   END exists_documento_principale;

   FUNCTION get_documento_principale (p_id_documento NUMBER)
      RETURN VARCHAR2
   IS
      dep_nome   OGGETTI_FILE.FILENAME%TYPE := '';
   BEGIN
      SELECT ogfi.filename
        INTO dep_nome
        FROM oggetti_file ogfi, proto_view prot
       WHERE     prot.id_documento = p_id_documento
             AND ogfi.id_documento = prot.id_documento
             AND UPPER (OGFI.FILENAME) NOT IN (UPPER (
                                                     numero
                                                  || '_'
                                                  || anno
                                                  || '_'
                                                  || tipo_registro
                                                  || '.PDF'),
                                               'LETTERAUNIONE.RTFHIDDEN');

      --DBMS_OUTPUT.PUT_LINE('NOME FILE '||DEP_NOME);
      RETURN dep_nome;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLERRM;
   END get_documento_principale;

   FUNCTION get_dati_documento (p_id_documento NUMBER, p_utente VARCHAR2)
      RETURN afc.t_ref_cursor
   IS
      d_ref_cursor   afc.t_ref_cursor;
   BEGIN
      OPEN d_ref_cursor FOR
         SELECT anno,
                get_descrizione_tipo_registro (anno,
                                               tipo_registro,
                                               prot.codice_amministrazione,
                                               prot.codice_aoo)
                   registro,
                numero,
                TO_CHAR (data, 'dd/mm/yyyy hh24:mi:ss') data,
                DECODE (prot.modalita,
                        'ARR', 'ARRIVO',
                        'PAR', 'PARTENZA',
                        'INT', 'INTERNO',
                        modalita)
                   modalita,
                oggetto,
                get_corrispondenti (idrif) corrispondenti,
                get_smistamenti (idrif) smistamenti,
                class_cod,
                get_descrizione_classifica (class_cod,
                                            class_dal,
                                            prot.codice_amministrazione,
                                            prot.codice_aoo)
                   descrizione_classifica,
                fascicolo_anno,
                fascicolo_numero,
                get_descrizione_fascicolo (class_cod,
                                           class_Dal,
                                           fascicolo_anno,
                                           fascicolo_numero,
                                           prot.codice_amministrazione,
                                           prot.codice_aoo,
                                           p_utente)
                   oggetto_fascicolo,
                exists_documento_principale (prot.id_documento)
                   documento_principale,
                get_documento_principale (prot.id_documento)
                   nome_documento_principale,
                get_allegati (idrif) allegati,
                get_cognome_nome_utente (prot.utente_protocollante)
                   utente_protocollante,
                get_descrizione_unita (prot.unita_protocollante,
                                       prot.data,
                                       prot.codice_amministrazione,
                                       prot.codice_aoo)
                   unita_protocollante,
                get_descrizione_unita (prot.unita_esibente,
                                       prot.data,
                                       prot.codice_amministrazione,
                                       prot.codice_aoo)
                   unita_esibente,
                get_precedente (prot.id_documento) precedente,
                DECODE (
                   stato_pr,
                   'DN',    'Richiesta effettuata il '
                         || TO_CHAR (data_richiesta_ann, 'dd/mm/yyyy'),
                   'AN', 'ANNULLATO',
                   '')
                   annullamento,
                get_riservato (prot.id_documento) riservato,
                TO_CHAR (data_arrivo, 'DD/MM/YYYY') data_arrivo,
                TO_CHAR (data_spedizione, 'dd/mm/yyyy') data_spedizione,
                TO_CHAR (data_documento, 'dd/mm/yyyy') data_documento_esterno,
                numero_documento numero_documento_esterno,
                get_descrizione_tipo_documento (tipo_documento,
                                                data,
                                                prot.codice_amministrazione,
                                                prot.codice_aoo)
                   tipo_documento,
                get_descrizione_tramite (documento_tramite,
                                         data,
                                         prot.codice_amministrazione,
                                         prot.codice_aoo)
                   modalita_spedizione_arrivo,
                DECODE (spedito, 'Y', 'SI', '') spedito,
                DECODE (registrata_accettazione, 'Y', 'SI', '')
                   registrata_accettazione,
                DECODE (registrata_non_accettazione, 'Y', 'SI', '')
                   registrata_no_accettazione,
                note,
                get_conservato (prot.id_documento) conservato,
                get_altra_registrazione (prot.id_documento) estremi_atto,
                get_estremi_emergenza (prot.id_documento) estremi_emergenza
           FROM proto_view prot, documenti docu
          WHERE     prot.id_documento = p_id_documento
                AND docu.id_documento = prot.id_documento
                AND docu.stato_documento NOT IN ('CA', 'RE', 'PB')
                AND prot.stato_pr != 'DP';

      RETURN d_ref_cursor;
   END;
   FUNCTION elimina_file_stampa_unica (p_idrif VARCHAR2)
      RETURN number
   IS
      retval   number:=1;
   BEGIN
       for cur0 in (select id_documento from spr_frontespizio where idrif= p_idrif union select id_documento from spr_allegati_rep where idrif= p_idrif)
       loop
        retval:=F_ELIMINA_DOCUMENTO(cur0.id_documento,1,1);
       end loop;
       commit;
       return retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END elimina_file_stampa_unica;
END ag_utilities_stampa;
/
