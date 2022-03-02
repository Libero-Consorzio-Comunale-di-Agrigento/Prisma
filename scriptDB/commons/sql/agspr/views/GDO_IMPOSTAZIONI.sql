--liquibase formatted sql
--changeset esasdelli:AGSPR_VIEW_GDO_IMPOSTAZIONI runOnChange:true stripComments:false

CREATE OR REPLACE FORCE VIEW GDO_IMPOSTAZIONI
(
   ID_IMPOSTAZIONE,
   CODICE,
   DESCRIZIONE,
   VALORE,
   ETICHETTA,
   PREDEFINITO,
   CARATTERISTICHE,
   CODICE_ESTERNO,
   TIPO_MODELLO_ESTERNO,
   ID_ENTE,
   VERSION
)
AS
   SELECT -get_number_from_string (
                 codice
              || '_'
              || NVL (
                    DECODE (tipo_modello,
                            '@agVar@', 1,
                            '@agSped@', 1,
                            CAST (NULL AS NUMBER)),
                    ''))
             id_impostazione,
          DECODE (
             tipo_modello,
             '@agVar@', DECODE (
                           SUBSTR (codice, -2),
                           '_1', SUBSTR (codice, 1, LENGTH (codice) - 2),
                           codice),
             '@agSped@',    'SPED_'
                         || DECODE (
                               SUBSTR (codice, -2),
                               '_1', SUBSTR (codice, 1, LENGTH (codice) - 2),
                               codice),
             DECODE (codice, 'EXT_FILE_LETUSC', 'EDITOR_DEFAULT', codice))
             codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          DECODE (
             codice,
             'EXT_FILE_LETUSC', DECODE (valore,
                                        '.doc', 'WORD',
                                        '.docx', 'WORD',
                                        'SOFFICE'),
             valore)
             valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          DECODE (tipo_modello,
                  '@agVar@', 1,
                  '@agSped@', 1,
                  CAST (NULL AS NUMBER))
             id_ente,
          0 version
     FROM gdm_parametri
    WHERE     tipo_modello IN ('@ag@',
                               '@agStrut@',
                               '@agVar@',
                               '@agSped@')
          AND SUBSTR (codice, 1, 2) <> 'M_'
          AND codice NOT LIKE 'MODELLO_%'
          AND codice NOT LIKE 'BLOCCO_%'
          AND codice NOT LIKE 'MODULO_%'
          AND codice NOT LIKE 'MODULO%'
          AND codice NOT LIKE 'NOME_ITER_%'
          AND codice NOT LIKE 'JWFPDF_%'
          AND codice NOT LIKE 'JPDFSUITE_%'
          AND codice NOT LIKE 'MOD_%'
          AND codice NOT LIKE 'SERVER_PDF%'
          AND codice NOT LIKE 'COD_RIF_%'
          AND INSTR (NVL (note, ' '), 'Obsoleto.') = 0
   UNION
   SELECT -get_number_from_string ('COPIA_CONFORME_PDF') id_impostazione,
          'COPIA_CONFORME_PDF' codice,
          'Abilita la copia conforme anche per i file pdf non firmati'
             descrizione,
          valore,
          CAST (NULL AS VARCHAR2 (4000)) label,
          'N' predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'TIMBRA_PDF_1'
   UNION
   SELECT -get_number_from_string ('FORMATO_DEFAULT' || '_') id_impostazione,
          'FORMATO_DEFAULT' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          DECODE (valore,  '.doc', 'doc',  '.docx', 'docx',  'odt') valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agStrut@' AND codice = 'EXT_FILE_LETUSC'
   UNION
   SELECT -get_number_from_string ('OTTICA_SO4' || '_') id_impostazione,
          'OTTICA_SO4' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'SO_OTTICA_PROT_1'
   UNION
   SELECT -get_number_from_string ('FIRMA_HASH') id_impostazione,
          'FIRMA_HASH' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          DECODE (INSTR (valore, '&firmaHash=true'), 0, 'N', 'Y'),
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@STANDARD' AND codice = 'FIRMA_URL'
   UNION
   SELECT -get_number_from_string ('FIRMA_PADES') id_impostazione,
          'FIRMA_PADES' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          DECODE (INSTR (valore, '&firmaTipo=PDF'), 0, 'N', 'Y'),
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@STANDARD' AND codice = 'FIRMA_URL'
   UNION
   SELECT -get_number_from_string ('SO4_OTTICA_1') id_impostazione,
          'SO4_OTTICA' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'SO_OTTICA_PROT_1'
   UNION
   SELECT -get_number_from_string ('ADRIER_WS_1') id_impostazione,
          'ADRIER_WS' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'PARIX_WS_1'
   UNION
   SELECT -get_number_from_string ('ADRIER_WS_USER_1') id_impostazione,
          'ADRIER_WS_USER' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'PARIX_WS_USER_1'
   UNION
   SELECT -get_number_from_string ('ADRIER_WS_PSW_1') id_impostazione,
          'ADRIER_WS_PSW' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'PARIX_WS_PSW_1'
   UNION
   SELECT -get_number_from_string ('ADRIER_WS_URL_1') id_impostazione,
          'ADRIER_WS_URL' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'PARIX_WS_URL_1'
   UNION
   SELECT -get_number_from_string ('STAMPA_UNICA_FRASE_FOOTER')
             id_impostazione,
          'STAMPA_UNICA_FRASE_FOOTER' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agStrut@' AND codice = 'SU_FRASE_LETTERA'
   UNION
   SELECT -get_number_from_string ('STAMPA_UNICA') id_impostazione,
          'STAMPA_UNICA' codice,
          'Abilita la creazione della stampa unica come allegato' descrizione,
          DECODE (INSTR (valore || '#', '#STAMPA_UNICA#'), 0, 'N', 'Y')
             valore,
          CAST (NULL AS VARCHAR2 (4000)) label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          NULL,
          NULL,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agStrut@' AND codice = 'SU_ETICHETTA'
   UNION
   SELECT -get_number_from_string ('STAMPA_UNICA_SUBITO') id_impostazione,
          'STAMPA_UNICA_SUBITO' codice,
          'Abilita il download della stampa unica' descrizione,
          DECODE (INSTR (valore || '#', '#STAMPA_UNICA_SUBITO#'),
                  0, 'N',
                  'Y')
             valore,
          CAST (NULL AS VARCHAR2 (4000)) label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          NULL,
          NULL,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agStrut@' AND codice = 'SU_ETICHETTA'
   UNION
   SELECT -get_number_from_string ('TEMP_PATH' || '_') id_impostazione,
          'TEMP_PATH' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore,
          afc.get_stringparm (note, 'etichetta') label,
          CAST (NULL AS VARCHAR2 (255)) predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agViewer@' AND codice = 'TEMP_PATH'
   UNION
   SELECT -get_number_from_string ('COPIA_CONFORME_PDF') id_impostazione,
          'COPIA_CONFORME_PDF' codice,
          'Abilita la copia conforme anche per i file pdf non firmati'
             descrizione,
          valore,
          CAST (NULL AS VARCHAR2 (4000)) label,
          'N' predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'TIMBRA_PDF_1'
   UNION
   SELECT -get_number_from_string (stringa) id_impostazione,
          stringa codice,
          commento descrizione,
          valore,
          'MODULO SPEDIZIONE ATTIVO' etichetta,
          'N' predefinito,
          NULL caratteristiche,
          NULL codice_esterno,
          NULL tipo_modello_esterno,
          1 id_ente,
          0 version
     FROM gdm_registro
    WHERE (chiave = 'PRODUCT/AGS/AGSpr/SPED') AND stringa = 'MOD_SPED_ATTIVO'
   UNION
   SELECT -get_number_from_string (codiceads) id_impostazione,
          'URL_ANAGRAFICA' codice,
          'Url di gestione anagrafica' descrizione,
          url valore,
          'URL ANAGRAFICA' etichetta,
          '/Anagrafica/?progettoChiamante=AGS' predefinito,
          NULL caratteristiche,
          NULL codice_esterno,
          NULL tipo_modello_esterno,
          1 id_ente,
          0 version
     FROM gdm_collegamenti_esterni
    WHERE codiceads = 'SEGRETERIA#AS4'
   UNION
   SELECT -get_number_from_string ('UTENTE_PROTOCOLLO') id_impostazione,
          'UTENTE_PROTOCOLLO' codice,
          'Codice Utente di default da utilizzare in fasi automatiche'
             descrizione,
          valore,
          CAST (NULL AS VARCHAR2 (4000)) label,
          '' predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agVar@' AND codice = 'UTENTI_PROTOCOLLO_1'
   UNION
   SELECT -get_number_from_string ('PEC_' || codice) id_impostazione,
          'PEC_' || codice codice,
          TO_CHAR (note) descrizione,
          valore,
          CAST (NULL AS VARCHAR2 (4000)) label,
          'N' predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@agStrut@' AND codice LIKE '3DELETTRONICO%'
   UNION
   SELECT -get_number_from_string ('SCANNER') id_impostazione,
          'SCANNER' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          DECODE (NVL (VALORE, 'SI'), 'SI', 'Y', 'N'),
          'SCANNER' label,
          'Y' predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          NULL id_ente,
          0 version
     FROM gdm_parametri
    WHERE tipo_modello = '@STANDARD' AND codice = 'SCANNER'
   UNION
   SELECT -get_number_from_string ('CREA_PG_IN_PARTENZA_DA_MAIL')
             id_impostazione,
          'CREA_PG_IN_PARTENZA_DA_MAIL' codice,
          CAST (SUBSTR (note, 1, 4000) AS VARCHAR2 (4000)) descrizione,
          valore,
          CAST (NULL AS VARCHAR2 (4000)) label,
          '' predefinito,
          CAST (NULL AS VARCHAR2 (4000)) caratteristiche,
          codice,
          tipo_modello,
          1 id_ente,
          0 version
     FROM gdm_parametri
    WHERE     tipo_modello = '@agVar@'
          AND codice = 'MSG_ABILITA_CREAZIONE_PG_IN_PARTENZA_1'
/



CREATE OR REPLACE TRIGGER GDO_IMPOSTAZIONI_TIO
   INSTEAD OF DELETE OR INSERT OR UPDATE
   ON GDO_IMPOSTAZIONI
   FOR EACH ROW
BEGIN
   IF INSERTING
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
         'L''inserimento di nuove impostazioni va effettuato dalla tabella del relativo dizionario nel documentale.');
   END IF;

   IF UPDATING
   THEN
      IF :new.codice = 'MOD_SPED_ATTIVO'
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
            'L''aggiornamento dell'' impostazione ''MOD_SPED_ATTIVO'' non e'' effettuabile.');
      END IF;

      IF :new.codice = 'URL_ANAGRAFICA'
      THEN
         RAISE_APPLICATION_ERROR (
            -20999,
            'L''aggiornamento dell'' impostazione ''URL_ANAGRAFICA'' non e'' effettuabile.');
      END IF;

      DECLARE
         d_valore   VARCHAR2 (10) := :new.valore;
      BEGIN
         IF :new.CODICE = 'SCANNER'
         THEN
            IF NVL (:new.valore, 'Y') = 'Y'
            THEN
               d_valore := 'SI';
            ELSE
               d_valore := 'NO';
            END IF;
         END IF;

         IF NVL (:OLD.valore, '*#*') <> NVL (:NEW.valore, '*#*')
         THEN
            UPDATE GDM_PARAMETRI
               SET VALORE = d_valore
             WHERE     TIPO_MODELLO = :NEW.TIPO_MODELLO_ESTERNO
                   AND CODICE = :NEW.CODICE_ESTERNO;
         END IF;
      END;
   END IF;


   IF DELETING
   THEN
      RAISE_APPLICATION_ERROR (
         -20999,
         'La cancellazione di impostazioni va effettuato dalla tabella del relativo dizionario nel documentale.');
   END IF;
END;
/