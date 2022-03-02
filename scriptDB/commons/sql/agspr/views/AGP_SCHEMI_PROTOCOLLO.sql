--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_AGP_SCHEMI_PROTOCOLLO runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW agp_schemi_protocollo
(
   id_schema_protocollo,
   id_schema_protocollo_risposta,
   codice,
   descrizione,
   id_classificazione,
   id_fascicolo,
   id_ente,
   tipo_registro,
   oggetto,
   movimento,
   anni_conservazione,
   conservazione_illimitata,
   da_fascicolare,
   segnatura_completa,
   segnatura,
   scadenza,
   id_documento_esterno,
   utente_ins,
   data_ins,
   utente_upd,
   data_upd,
   valido_dal,
   valido_al,
   valido,
   risposta,
   id_tipo_protocollo,
   ufficio_esibente_ottica,
   ufficio_esibente_progr,
   ufficio_esibente_dal,
   note,
   domanda_accesso,
   riservato,
   version
)
AS
   SELECT -ts.id_documento id_schema_protocollo,
          -ts_risp.id_documento id_schema_protocollo_risposta,
          ts.tipo_documento codice,
          ts.descrizione_tipo_documento descrizione,
          cl.id_classificazione id_classificazione,
          -f.id_documento id_fascicolo,
          enti.id_ente,
          ts.tipo_registro_documento tipo_registro,
          ts.oggetto,
          DECODE (ts.modalita,
                  'ARR', 'ARRIVO',
                  'PAR', 'PARTENZA',
                  'INT', 'INTERNO',
                  ts.modalita)
             movimento,
          ts.anni_conservazione,
          CAST (ts.conservazione_illimitata AS CHAR (1)),
          CAST (ts.da_fascicolare AS CHAR (1)),
          CAST (ts.segnatura_completa AS CHAR (1)),
          CAST (ts.segnatura AS CHAR (1)),
          ts.scadenza,
          ts.id_documento,
          dati_creazione.utente_aggiornamento utente_ins,
          dati_creazione.data_aggiornamento data_ins,
          d.utente_aggiornamento utente_upd,
          d.data_aggiornamento data_upd,
          NVL (ts.dataval_dal, TO_DATE (2222222, 'j')),
          ts.dataval_al,
          CAST (
             DECODE (
                SIGN (SYSDATE - NVL (ts.dataval_dal, TO_DATE (2222222, 'j'))),
                -1, 'N',
                DECODE (
                   SIGN (
                      NVL (ts.dataval_al, TO_DATE (3333333, 'j')) - SYSDATE),
                   -1, 'N',
                   'Y')) AS CHAR (1))
             valido,
          CAST (ts.risposta AS CHAR (1)),
          ts.id_tipo_protocollo,
          u1.ottica ufficio_esibente_ottica,
          u1.progr_unita_organizzativa ufficio_esibente_progr,
          u1.dal ufficio_esibente_dal,
          ts.note,
          CAST (ts.domanda_accesso AS CHAR (1)),
          CAST (ts.riservato AS CHAR (1)),
          1 version
     FROM gdm_seg_tipi_documento ts,
          gdm_seg_tipi_documento ts_risp,
          gdm_documenti d,
          gdo_enti enti,
          ags_classificazioni cl,
          gdm_documenti dc,
          gdm_fascicoli f,
          gdm_documenti df,
          (SELECT id_documento, data_aggiornamento, utente_aggiornamento
             FROM gdm_stati_documento sd1
            WHERE NOT EXISTS
                     (SELECT 1
                        FROM gdm_stati_documento sd2
                       WHERE     sd1.id_documento = sd2.id_documento
                             AND sd2.data_aggiornamento <
                                    sd1.data_aggiornamento)) dati_creazione,
          (SELECT ottica,
                  progr_unita_organizzativa,
                  dal,
                  al,
                  codice_uo
             FROM so4_unita_organizzative_pubb unor1
            WHERE NOT EXISTS
                     (SELECT 1
                        FROM so4_unita_organizzative_pubb unor2
                       WHERE     unor2.ottica = unor1.ottica
                             AND unor2.progr_unita_organizzativa =
                                    unor1.progr_unita_organizzativa
                             AND NVL (unor2.al, TO_DATE (3333333, 'j')) >
                                    NVL (unor1.al, TO_DATE (3333333, 'j'))))
          u1
    WHERE     d.id_documento = ts.id_documento
          AND d.stato_documento NOT IN ('CA', 'RE', 'PB')
          AND df.id_documento(+) = f.id_documento
          AND NVL (df.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
          AND ts.id_documento = dati_creazione.id_documento
          AND ts_risp.tipo_documento(+) = ts.tipo_doc_risposta
          AND enti.amministrazione = ts.codice_amministrazione
          AND enti.aoo = ts.codice_aoo
          AND enti.ottica = gdm_ag_parametro.get_valore (
                               'SO_OTTICA_PROT',
                               ts.codice_amministrazione,
                               ts.codice_aoo,
                               '')
          AND cl.classificazione(+) = ts.class_cod
          AND cl.classificazione_dal(+) = ts.class_dal
          AND dc.id_documento(+) = cl.id_documento_esterno
          AND NVL (dc.stato_documento, 'BO') NOT IN ('CA', 'RE', 'PB')
          AND f.class_cod(+) = ts.class_cod
          AND f.class_dal(+) = ts.class_dal
          AND f.fascicolo_anno(+) = ts.fascicolo_anno
          AND f.fascicolo_numero(+) = ts.fascicolo_numero
          AND NVL (u1.ottica, enti.ottica) = enti.ottica
          AND u1.codice_uo(+) = ts.unita_esibente
/

CREATE OR REPLACE TRIGGER AGP_SCHEMI_PROTOCOLLO_TIO
   INSTEAD OF DELETE OR INSERT OR UPDATE
   ON AGP_SCHEMI_PROTOCOLLO
   FOR EACH ROW
DECLARE
   d_class_Cod        VARCHAR2 (100);
   d_class_dal        DATE;
   d_fasc_anno        NUMBER;
   d_fasc_numero      VARCHAR2 (1000);
   d_salva_class      NUMBER := 0;
   d_salva_fasc       NUMBER := 0;
   d_salva_risposta   NUMBER := 0;
   d_codice_amm       VARCHAR2 (100);
   d_codice_aoo       VARCHAR2 (100);
   d_esiste           NUMBER := 0;
   d_unita            VARCHAR2 (100);
   d_cod_risposta     VARCHAR2 (255);
   d_dataval_al       DATE := NULL;

   PROCEDURE aggiorna_profilo_gdm (p_utente VARCHAR2, p_id_documento NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE GDM_DOCUMENTI
         SET DATA_AGGIORNAMENTO = SYSDATE, UTENTE_AGGIORNAMENTO = p_utente
       WHERE ID_DOCUMENTO = p_id_documento;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RAISE;
   END;

   PROCEDURE cancella_profilo_gdm (p_utente          VARCHAR2,
                                   p_id_documento    VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      d_ret   NUMBER;
   BEGIN
      d_ret := gdm_profilo.cancella (p_id_documento, p_utente);
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         RAISE;
   END;
BEGIN
   IF INSERTING OR UPDATING
   THEN
      d_dataval_al := :new.valido_al;

      IF NVL (:new.valido, 'Y') = 'N' AND NVL (:old.valido, 'Y') = 'Y'
      THEN
         d_dataval_al := SYSDATE;
      END IF;

      IF NVL (:new.valido, 'Y') = 'Y' AND NVL (:old.valido, 'Y') = 'N'
      THEN
         d_dataval_al := NULL;
      END IF;
   END IF;

   IF INSERTING
   THEN
      SELECT amministrazione, aoo
        INTO d_codice_amm, d_codice_aoo
        FROM gdo_enti
       WHERE id_ente = :new.id_ente;

      BEGIN
         SELECT DISTINCT 1
           INTO d_esiste
           FROM gdm_seg_tipi_documento
          WHERE     codice_amministrazione = d_codice_amm
                AND codice_aoo = d_codice_aoo
                AND tipo_documento = :NEW.codice;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF d_esiste = 1
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
            'Tipo di documento ''' || :NEW.codice || ''' gia'' presente.');
      END IF;

      IF NVL (:NEW.id_classificazione, 0) <> NVL (:OLD.id_classificazione, 0)
      THEN
         d_salva_class := 1;

         IF NVL (:NEW.id_classificazione, 0) = 0
         THEN
            d_class_cod := NULL;
            d_class_dal := NULL;
         ELSE
            BEGIN
               SELECT classificazione, classificazione_dal
                 INTO d_class_cod, d_class_dal
                 FROM ags_classificazioni
                WHERE id_classificazione = :NEW.id_classificazione;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      IF NVL (:NEW.id_fascicolo, 0) <> NVL (:OLD.id_fascicolo, 0)
      THEN
         d_salva_fasc := 1;

         IF NVL (:NEW.id_fascicolo, 0) = 0
         THEN
            d_class_Cod := NULL;
            d_class_dal := NULL;
         ELSE
            BEGIN
               SELECT anno, numero
                 INTO d_fasc_anno, d_fasc_numero
                 FROM ags_fascicoli
                WHERE id_fascicolo = :NEW.id_fascicolo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      DECLARE
         RetVal   NUMBER;
      BEGIN
         IF NVL (:NEW.ufficio_esibente_progr, 0) = 0
         THEN
            d_unita := NULL;
         ELSE
            BEGIN
               SELECT codice
                 INTO d_unita
                 FROM so4_v_unita_organizzative_pubb
                WHERE     progr = :new.ufficio_esibente_progr
                      AND ottica = :new.ufficio_esibente_ottica
                      AND dal = :new.ufficio_esibente_dal;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RAISE_APPLICATION_ERROR (
                     -20999,
                        :new.ufficio_esibente_progr
                     || ' '
                     || :new.ufficio_esibente_ottica
                     || ' '
                     || :new.ufficio_esibente_dal);
            END;
         END IF;

         IF NVL (:NEW.ID_SCHEMA_PROTOCOLLO_RISPOSTA, 0) <>
               NVL (:OLD.ID_SCHEMA_PROTOCOLLO_RISPOSTA, 0)
         THEN
            d_salva_risposta := 1;

            IF NVL (:NEW.ID_SCHEMA_PROTOCOLLO_RISPOSTA, 0) = 0
            THEN
               d_cod_risposta := NULL;
            ELSE
               BEGIN
                  d_cod_risposta :=
                     GDM_TIPI_DOCUMENTO_UTILITY.GET_CODICE (
                        -:NEW.ID_SCHEMA_PROTOCOLLO_RISPOSTA);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END IF;
         END IF;

         RetVal :=
            GDM_TIPI_DOCUMENTO_UTILITY.CREA (:NEW.CODICE,
                                             :NEW.DESCRIZIONE,
                                             d_class_cod,
                                             d_class_dal,
                                             d_fasc_anno,
                                             d_fasc_numero,
                                             :NEW.MOVIMENTO,
                                             :NEW.OGGETTO,
                                             :NEW.NOTE,
                                             :NEW.TIPO_REGISTRO,
                                             :NEW.VALIDO_DAL,
                                             d_dataval_al,
                                             :NEW.SEGNATURA,
                                             :NEW.SEGNATURA_COMPLETA,
                                             d_cod_risposta,
                                             :NEW.RISPOSTA,
                                             :NEW.ID_TIPO_PROTOCOLLO,
                                             :NEW.ANNI_CONSERVAZIONE,
                                             :NEW.CONSERVAZIONE_ILLIMITATA,
                                             :NEW.SCADENZA,
                                             :NEW.DOMANDA_ACCESSO,
                                             d_unita,
                                             :NEW.riservato,
                                             d_codice_amm,
                                             d_codice_aoo,
                                             :NEW.UTENTE_ins);
      END;
   END IF;

   IF UPDATING
   THEN
      IF NVL (:NEW.id_classificazione, 0) <> NVL (:OLD.id_classificazione, 0)
      THEN
         d_salva_class := 1;

         IF NVL (:NEW.id_classificazione, 0) = 0
         THEN
            d_class_Cod := NULL;
            d_class_dal := NULL;
         ELSE
            BEGIN
               SELECT classificazione, classificazione_dal
                 INTO d_class_cod, d_class_dal
                 FROM ags_classificazioni
                WHERE id_classificazione = :NEW.id_classificazione;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      --raise_application_error(-20999, 'd_salva_class '||d_salva_class||' d_class_cod '||d_class_cod);

      IF NVL (:NEW.id_fascicolo, 0) <> NVL (:OLD.id_fascicolo, 0)
      THEN
         d_salva_fasc := 1;

         IF NVL (:NEW.id_fascicolo, 0) = 0
         THEN
            d_fasc_anno := NULL;
            d_fasc_numero := NULL;
         ELSE
            BEGIN
               SELECT anno, numero
                 INTO d_fasc_anno, d_fasc_numero
                 FROM ags_fascicoli
                WHERE id_fascicolo = :NEW.id_fascicolo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      IF NVL (:NEW.ufficio_esibente_progr, 0) <>
            NVL (:OLD.ufficio_esibente_progr, 0)
      THEN
         BEGIN
            SELECT codice
              INTO d_unita
              FROM so4_v_unita_organizzative_pubb
             WHERE     progr = :new.ufficio_esibente_progr
                   AND ottica = :new.ufficio_esibente_ottica
                   AND dal = :new.ufficio_esibente_dal;
         EXCEPTION
            WHEN OTHERS
            THEN
               d_unita := NULL;
         END;
      END IF;

      IF NVL (:NEW.ID_SCHEMA_PROTOCOLLO_RISPOSTA, 0) <>
            NVL (:OLD.ID_SCHEMA_PROTOCOLLO_RISPOSTA, 0)
      THEN
         d_salva_risposta := 1;

         IF NVL (:NEW.ID_SCHEMA_PROTOCOLLO_RISPOSTA, 0) = 0
         THEN
            d_cod_risposta := NULL;
         ELSE
            BEGIN
               d_cod_risposta :=
                  GDM_TIPI_DOCUMENTO_UTILITY.GET_CODICE (
                     -:NEW.ID_SCHEMA_PROTOCOLLO_RISPOSTA);
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      UPDATE gdm_seg_tipi_documento
         SET dataval_al = d_dataval_al,
             descrizione_tipo_documento = :NEW.descrizione,
             anni_conservazione = :NEW.anni_conservazione,
             conservazione_illimitata = :NEW.conservazione_illimitata,
             modalita =
                DECODE (:NEW.movimento,
                        'PARTENZA', 'PAR',
                        'ARRIVO', 'ARR',
                        'INTERNO', 'INT',
                        ''),
             note = :NEW.note,
             oggetto = :NEW.oggetto,
             risposta = :NEW.risposta,
             id_tipo_protocollo = :NEW.id_tipo_protocollo,
             segnatura = :NEW.segnatura,
             segnatura_completa = :NEW.segnatura_completa,
             tipo_registro_documento = :NEW.tipo_registro,
             id_class =
                DECODE (d_salva_class, 0, id_class, -:NEW.id_classificazione),
             class_cod = DECODE (d_salva_class, 0, class_cod, d_class_cod),
             class_dal = DECODE (d_salva_class, 0, class_dal, d_class_dal),
             id_fasc = DECODE (d_salva_fasc, 0, id_fasc, -:NEW.id_fascicolo),
             fascicolo_anno =
                DECODE (d_salva_fasc, 0, fascicolo_anno, d_fasc_anno),
             fascicolo_numero =
                DECODE (d_salva_fasc, 0, fascicolo_numero, d_fasc_numero),
             unita_esibente = d_unita,
             tipo_doc_risposta =
                DECODE (d_salva_risposta,
                        0, tipo_doc_risposta,
                        d_cod_risposta),
             scadenza = :NEW.SCADENZA,
             domanda_accesso = :NEW.DOMANDA_ACCESSO,
             riservato = :NEW.riservato
       WHERE ID_DOCUMENTO = -:OLD.ID_SCHEMA_PROTOCOLLO;

      aggiorna_profilo_gdm (:NEW.UTENTE_UPD, -:OLD.ID_SCHEMA_PROTOCOLLO);
   END IF;

   IF DELETING
   THEN
      DECLARE
         ret   NUMBER;
      BEGIN
         IF gdm_tipi_documento_utility.IS_ELIMINABILE (
               :old.id_documento_esterno,
               :old.risposta) = 1
         THEN
            cancella_profilo_gdm ('RPI', :old.id_documento_esterno);
         ELSE
            raise_application_error (
               -20999,
               'Tipo documento non eliminabile perchè utilizzato.');
         END IF;
      END;
   END IF;
END;
/

CREATE OR REPLACE TRIGGER AGP_SCHEMI_PROTOCOLLO_TIOIUD
/******************************************************************************
          NOME:        AGP_SCHEMI_PROTOCOLLO_TIOIUD
          DESCRIZIONE: Trigger instead of INSERT or UPDATE or DELETE on View AGP_SCHEMI_PROTOCOLLO
                       per l'allineamento con SO4.COMPETENZE_DELEGA
          ANNOTAZIONI: -
          REVISIONI:
          Rev. Data       Autore       Descrizione
          ---- ---------- ------      ------------------------------------------------------
             0 19/12/2017 MMalferrari  Creazione.
         ******************************************************************************/
   INSTEAD OF INSERT OR UPDATE OR DELETE
   ON AGP_SCHEMI_PROTOCOLLO
   FOR EACH ROW
DECLARE
   d_id_applicativo   NUMBER;
   d_modulo           VARCHAR2 (10) := 'AGSPR';
BEGIN
   IF INSERTING
   THEN
      DECLARE
         d_dataval_al   DATE := NULL;
      BEGIN
         d_dataval_al := :new.valido_al;

         IF NVL (:new.valido, 'Y') = 'N' AND NVL (:old.valido, 'Y') = 'Y'
         THEN
            d_dataval_al := SYSDATE;
         END IF;

         IF NVL (:new.valido, 'Y') = 'Y' AND NVL (:old.valido, 'Y') = 'N'
         THEN
            d_dataval_al := NULL;
         END IF;

         FOR app
            IN (SELECT id_applicativo
                  FROM so4_applicativi appl, ad4_istanze ista
                 WHERE     modulo = d_modulo
                       AND ista.user_oracle = USER
                       AND appl.istanza = ista.istanza)
         LOOP
            so4_competenze_delega_tpk.ins (NULL,
                                           :new.codice,
                                           :new.descrizione,
                                           app.id_applicativo,
                                           d_dataval_al);
         END LOOP;
      END;
   END IF;

   IF UPDATING
   THEN
      FOR code
         IN (SELECT id_competenza_delega
               FROM so4_competenze_delega code,
                    ad4_istanze ista,
                    so4_applicativi appl
              WHERE     appl.modulo = d_modulo
                    AND ista.user_oracle = USER
                    AND appl.istanza = ista.istanza
                    AND code.id_applicativo = appl.id_applicativo
                    AND code.codice = :new.codice)
      LOOP
         so4_competenze_delega_tpk.upd (
            p_check_old                  => 0,
            p_new_id_competenza_delega   => code.id_competenza_delega,
            p_new_codice                 => :new.codice,
            p_new_descrizione            => :new.descrizione,
            p_new_fine_validita          => :new.valido_al);
      END LOOP;
   END IF;

   IF DELETING
   THEN
      FOR code
         IN (SELECT id_competenza_delega
               FROM so4_competenze_delega code,
                    ad4_istanze ista,
                    so4_applicativi appl
              WHERE     appl.modulo = d_modulo
                    AND ista.user_oracle = USER
                    AND appl.istanza = ista.istanza
                    AND code.id_applicativo = appl.id_applicativo
                    AND code.codice = :new.codice)
      LOOP
         so4_competenze_delega_tpk.del (0, code.id_competenza_delega);
      END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/
