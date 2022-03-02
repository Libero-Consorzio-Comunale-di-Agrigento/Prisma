--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_SPR_LETTERE_USCITA_ANN_AU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_SPR_LETTERE_USCITA_ANN_AU
   AFTER UPDATE
   ON SPR_LETTERE_USCITA
   FOR EACH ROW
DECLARE
   d_is_provvedimento_modulistica   NUMBER := 1;
BEGIN
   BEGIN
      SELECT 0
        INTO d_is_provvedimento_modulistica
        FROM jdms_link
       WHERE     id_tipodoc IN (SELECT id_tipodoc
                                  FROM tipi_documento
                                 WHERE nome = 'M_PROVVEDIMENTO')
             AND INSTR (url, '/Protocollo/standalone.zul') > 0
             AND tag = 5;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         d_is_provvedimento_modulistica := 1;
   END;

   /*
      Gestione annullamento con provvedimento in modulistica
      che annulla lettere in zk
   */

   IF     AG_PARAMETRO.GET_VALORE ('ANN_DIRETTO',
                                   :new.codice_amministrazione,
                                   :new.codice_aoo,
                                   'Y') <> 'Y'
      AND d_is_provvedimento_modulistica = 1
   THEN
      IF NVL (:OLD.provvedimento_ann, ' ') !=
            NVL (:NEW.provvedimento_ann, ' ')
      THEN
         BEGIN
            AGSPR_AGP_PROTOCOLLI_PKG.set_provvedimento_annullamento (
               :new.id_documento,
               :NEW.provvedimento_ann);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE_APPLICATION_ERROR (
                  -20999,
                     'Fallito aggiornamento provvedimento in AGSPR. Errore: '
                  || SQLERRM);
         END;
      END IF;

      IF     NVL (:OLD.stato_pr, ' ') != NVL (:NEW.stato_pr, ' ')
         AND NVL (:NEW.stato_pr, ' ') = 'AN'
      THEN
         BEGIN
            AGSPR_AGP_PROTOCOLLI_PKG.annulla (:new.id_documento);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE_APPLICATION_ERROR (
                  -20999,
                  'Fallito aggiornamento stato in AGSPR. Errore: ' || SQLERRM);
         END;
      END IF;

      IF NVL (:OLD.utente_ann, TO_DATE (3333333, 'j')) !=
            NVL (:NEW.utente_ann, TO_DATE (3333333, 'j'))
      THEN
         BEGIN
            AGSPR_AGP_PROTOCOLLI_PKG.set_utente_annullamento (
               :new.id_documento,
               :NEW.utente_ann);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE_APPLICATION_ERROR (
                  -20999,
                     'Fallito aggiornamento utente di annullamento in AGSPR. Errore: '
                  || SQLERRM);
         END;
      END IF;

      IF NVL (:OLD.data_ann, TO_DATE (3333333, 'j')) !=
            NVL (:NEW.data_ann, TO_DATE (3333333, 'j'))
      THEN
         BEGIN
            AGSPR_AGP_PROTOCOLLI_PKG.set_data_annullamento (
               :new.id_documento,
               :NEW.data_ann);
         EXCEPTION
            WHEN OTHERS
            THEN
               RAISE_APPLICATION_ERROR (
                  -20999,
                     'Fallito aggiornamento data di annullamento in AGSPR. Errore: '
                  || SQLERRM);
         END;
      END IF;
   END IF;
END;
/
