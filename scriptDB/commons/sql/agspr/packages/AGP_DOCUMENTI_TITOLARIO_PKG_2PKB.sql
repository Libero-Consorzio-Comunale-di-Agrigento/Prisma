--liquibase formatted sql
--changeset esasdelli:AGSPR_PACKAGE_BODY_AGP_DOCUMENTI_TITOLARIO_PKG runOnChange:true stripComments:false

CREATE OR REPLACE PACKAGE BODY AGP_DOCUMENTI_TITOLARIO_PKG
IS
   /******************************************************************************
    NOMEp_        AGP_DOCUMENTI_TITOLARIO_PKG
    DESCRIZIONEp_ Gestione tabella AGP_DOCUMENTI_TITOLARIO.
    ANNOTAZIONIp_ .
    REVISIONIp_   .
    Rev.  Data          Autore        Descrizione.
    000   16/02/2017    mmalferrari   Prima emissione.
    001   28/07/2020    scaputo       issue 43883
                        Classificazioni secondarie: fallisce caricamento in agspr
                        se documento ancora non trascodificato: creata is_documento_agspr
                        e modificata inserisci
    002   11/08/2020    mmalferrari   Gestione tabella AGS_FASCICOLI (sostituita alla vista)
   ******************************************************************************/
   s_revisione_body   CONSTANT afc.t_revision := '002';

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

   --------------------------------------------------------------------------------
   PROCEDURE inserisci (p_id_documento_esterno    NUMBER,
                        p_class_cod               VARCHAR2,
                        p_class_dal               DATE,
                        p_fascicolo_anno          NUMBER,
                        p_fascicolo_numero        VARCHAR2,
                        p_utente_ins              VARCHAR2)
   IS
      d_id_documento         NUMBER;
      d_new_id               NUMBER;
      d_id_classificazione   NUMBER;
      d_id_fascicolo         NUMBER;
      d_esiste               NUMBER;
   BEGIN
      IF is_documento_agspr (p_id_documento_esterno) = 1
      THEN
         SELECT id_documento
           INTO d_id_documento
           FROM gdo_documenti
          WHERE id_documento_esterno = p_id_documento_esterno;

         SELECT id_classificazione
           INTO d_id_classificazione
           FROM ags_classificazioni
          WHERE     classificazione = p_class_cod
                AND classificazione_dal = p_class_dal;

         IF p_fascicolo_anno IS NOT NULL AND p_fascicolo_numero IS NOT NULL
         THEN
            SELECT id_documento
              INTO d_id_fascicolo
              FROM ags_fascicoli
             WHERE     id_classificazione = d_id_classificazione
                   AND anno = p_fascicolo_anno
                   AND numero = p_fascicolo_numero;
         END IF;

         SELECT HIBERNATE_SEQUENCE.NEXTVAL INTO d_new_id FROM DUAL;

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
              VALUES (d_new_id,
                      d_id_documento,
                      d_id_classificazione,
                      d_id_fascicolo,
                      0,
                      'Y',
                      p_utente_ins,
                      SYSDATE,
                      p_utente_ins,
                      SYSDATE);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   --------------------------------------------------------------------------------
   PROCEDURE elimina (p_id_documento_esterno    NUMBER,
                      p_class_cod               VARCHAR2,
                      p_class_dal               DATE,
                      p_fascicolo_anno          NUMBER,
                      p_fascicolo_numero        VARCHAR2,
                      p_utente_upd              VARCHAR2)
   IS
      d_id_documento         NUMBER;
      d_id_classificazione   NUMBER;
      d_id_fascicolo         NUMBER;
      d_version              NUMBER;
   BEGIN
      IF is_documento_agspr (p_id_documento_esterno) = 1
      THEN
         BEGIN
            SELECT id_documento
              INTO d_id_documento
              FROM gdo_documenti
             WHERE id_documento_esterno = p_id_documento_esterno;

            SELECT id_classificazione
              INTO d_id_classificazione
              FROM ags_classificazioni
             WHERE     classificazione = p_class_cod
                   AND classificazione_dal = p_class_dal;

            IF     p_fascicolo_anno IS NOT NULL
               AND p_fascicolo_numero IS NOT NULL
            THEN
               SELECT id_documento
                 INTO d_id_fascicolo
                 FROM ags_fascicoli
                WHERE     id_classificazione = d_id_classificazione
                      AND anno = p_fascicolo_anno
                      AND numero = p_fascicolo_numero;
            END IF;

            SELECT MAX (NVL (version, 0)) + 1
              INTO d_version
              FROM AGP_DOCUMENTI_TITOLARIO
             WHERE id_documento = d_id_documento;

            UPDATE agp_documenti_titolario
               SET version = d_version,
                   valido = 'N',
                   utente_upd = p_utente_upd,
                   data_upd = SYSDATE
             WHERE     id_documento = d_id_documento
                   AND id_classificazione = d_id_classificazione
                   AND NVL (id_fascicolo, -1) = NVL (d_id_fascicolo, -1);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE;
         END;
      END IF;
   END;
END;
/
