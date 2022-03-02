--liquibase formatted sql
--changeset esasdelli:AGSPR_TRIGGER_AGP_SCHEMI_PROTOCOLLO_TIO runOnChange:true stripComments:false

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
                WHERE id_documento = :NEW.id_fascicolo;
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
                WHERE id_documento = :NEW.id_fascicolo;
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
