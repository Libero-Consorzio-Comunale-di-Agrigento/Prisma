--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_DOCU_STATO_DOCUMENTO_TU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_DOCU_STATO_DOCUMENTO_TU
   AFTER UPDATE OF STATO_DOCUMENTO
   ON DOCUMENTI
   FOR EACH ROW
DECLARE
/******************************************************************************
   NAME:       ag_docu_stato_documento_tu
   PURPOSE: In caso venga passato a stato_documento = CA un documento di smistamento,
   l'eventuale flusso ad esso associato viene chiuso, in modo che non ci siano
   attivita' sulla scrivania legate a tale smistamento.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/06/2008             1. Created this trigger. A27756.4.0
   2.0        23/10/2018            SC  Elimina i riferimenti alla RIFERIMENTI
                                        di tipo PROT_PREC e PROT_DAAC.
   3.0        26/11/2018            MM  Gestione cancellazione tipo allegato
******************************************************************************/

BEGIN
   IF :NEW.stato_documento = 'CA'
   THEN
      DBMS_OUTPUT.PUT_LINE ('LO STATO E'' CA');

      IF ag_utilities_cruscotto.is_smistamento (:NEW.id_documento) = 1
      THEN
         DBMS_OUTPUT.PUT_LINE ('SI TRATTA DI UNO SMISTAMENTO');

         BEGIN
            ag_utilities_cruscotto.delete_task_esterni_commit (
               :NEW.id_documento);
            DBMS_OUTPUT.PUT_LINE ('HO CHIUSO IL FLUSSO');
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (
                  -20999,
                  'Fallita cancellazione smistamento perche'' e'' fallita la chiusura del flusso associato');
         END;
      END IF;

      IF ag_utilities_cruscotto.is_lettera (:NEW.id_documento) = 1
      THEN
         DBMS_OUTPUT.PUT_LINE ('SI TRATTA DI UNA LETTERA');

         BEGIN
            ag_utilities_cruscotto.chiudi_flusso_lettera (:NEW.id_documento);
            DBMS_OUTPUT.PUT_LINE ('HO CHIUSO IL FLUSSO');
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (
                  -20999,
                  'Fallita cancellazione lettera perche'' e'' fallita la chiusura del flusso associato');
         END;
      END IF;



      IF ag_utilities_cruscotto.is_rapporto (:NEW.id_documento) = 1
      THEN
         DBMS_OUTPUT.put_line ('SI TRATTA DI UN RAPPORTO');

         DECLARE
            d_mod        VARCHAR2 (10);
            d_rapp_ob    VARCHAR2 (1);
            d_idrif      VARCHAR2 (100);
            d_stato_pr   VARCHAR2 (10);
         BEGIN
            SELECT prot.modalita,
                   ag_parametro.get_valore ('RAPP_OB_',
                                            prot.codice_amministrazione,
                                            prot.codice_aoo,
                                            'N'),
                   prot.idrif,
                   NVL (prot.stato_pr, 'DP')
              INTO d_mod,
                   d_rapp_ob,
                   d_idrif,
                   d_stato_pr
              FROM proto_view prot, seg_soggetti_protocollo sogg
             WHERE     prot.idrif = sogg.idrif
                   AND sogg.id_documento = :NEW.id_documento;

            DBMS_OUTPUT.put_line ('modalita: ' || d_mod);
            DBMS_OUTPUT.put_line ('d_rapp_ob: ' || d_rapp_ob);

            IF d_stato_pr = 'PR' AND d_mod <> 'INT' AND d_rapp_ob = 'Y'
            THEN
               DECLARE
                  d_esistono   INTEGER := 0;
               BEGIN
                  SELECT COUNT (1)
                    INTO d_esistono
                    FROM seg_soggetti_protocollo
                   WHERE     idrif = d_idrif
                         AND tipo_rapporto <> 'DUMMY'
                         AND id_documento <> :NEW.id_documento;

                  IF d_esistono = 0
                  THEN
                     raise_application_error (
                        -20999,
                        'Fallita cancellazione rapporto: deve esistere almeno un mittente / destinatario!');
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RAISE;
               END;
            END IF;
         END;
      ELSE
         DBMS_OUTPUT.put_line ('NON SI TRATTA DI UN RAPPORTO');
      END IF;
      IF ag_utilities.is_protocollo (:NEW.id_tipodoc) = 1
      THEN
         DECLARE
            d_anno            NUMBER;
            d_numero          NUMBER;
            d_tipo_registro   VARCHAR2 (100);
         BEGIN
            SELECT anno, numero, tipo_registro
              INTO d_anno, d_numero, d_tipo_registro
              FROM proto_view
             WHERE id_documento = :NEW.id_documento;

            IF d_numero IS NOT NULL
            THEN
               raise_application_error (
                  -20999,
                     'Eliminazione non permessa: documento numerato ('
                  || d_tipo_registro
                  || ' '
                  || d_anno
                  || '/'
                  || d_numero
                  || ')');
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               RAISE;
         END;

         DELETE riferimenti
          WHERE     (   id_documento = :NEW.id_documento
                     OR id_documento_rif = :NEW.id_documento)
                AND tipo_relazione IN ('PROT_PREC', 'PROT_DAAC');
      END IF;

      DECLARE
         d_is_tial   NUMBER := 0;
      BEGIN
         BEGIN
            SELECT 1
              INTO d_is_tial
              FROM seg_tipi_allegato
             WHERE id_documento = :new.id_documento;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               d_is_tial := 0;
         END;

         IF d_is_tial = 1
         THEN
            AGSPR_INTEGRITYPACKAGE.initNestLevel;
            AGSPR_INTEGRITYPACKAGE.NextNestLevel;
            AGSPR_TIPI_ALLEGATO_PKG.upd (-:new.id_documento,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         'N',
                                         :new.utente_aggiornamento,
                                         :new.data_aggiornamento);
            AGSPR_INTEGRITYPACKAGE.initNestLevel;
         END IF;
      END;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      AGSPR_INTEGRITYPACKAGE.initNestLevel;
      RAISE;
END;
/
