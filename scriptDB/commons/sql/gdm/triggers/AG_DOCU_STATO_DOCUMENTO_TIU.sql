--liquibase formatted sql
--changeset esasdelli:GDM_TRIGGER_AG_DOCU_STATO_DOCUMENTO_TIU runOnChange:true stripComments:false
CREATE OR REPLACE  TRIGGER AG_DOCU_STATO_DOCUMENTO_TIU
   BEFORE UPDATE OF STATO_DOCUMENTO
   ON DOCUMENTI
   FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.stato_documento = 'CA'
   THEN
      /***************************************************************************
         Se un memo viene cancellato (stato_documento = CA), i suoi eventuali
         smistamenti vengono eliminati e quindi tutte le attivita' sulla scrivania
         legate a tali smistamenti.
      ***************************************************************************/
      IF ag_utilities.is_memo (:NEW.id_tipodoc) = 1
      THEN
         BEGIN
            DECLARE
               a_messaggio    VARCHAR2 (32000);
               a_istruzione   VARCHAR2 (32000);
            BEGIN
               a_messaggio :=
                     'Errore in eliminazione smistamenti associati a memo '
                  || :NEW.id_documento
                  || '.';
               a_istruzione :=
                     'Begin AG_MEMO_UTILITY.ELIMINA_SMISTAMENTI('
                  || :NEW.id_documento
                  || '); end; ';
               integritypackage.set_postevent (a_istruzione, a_messaggio);
            END;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (-20999,
                                        'Fallita cancellazione:' || SQLERRM);
         END;
      END IF;


      IF ag_utilities.is_fascicolo (:NEW.id_documento) = 1
      THEN
         DBMS_OUTPUT.PUT_LINE ('SI TRATTA DI UN fascicolo');

         DECLARE
            a_messaggio    VARCHAR2 (32000);
            a_istruzione   VARCHAR2 (32000);
         BEGIN
            a_messaggio :=
                  'Errore in scarto memo associato a documento '
               || :NEW.id_documento
               || '.';
            a_istruzione :=
                  'Begin '
               || '   AG_FASCICOLO_UTILITY.ELIMINA_SMISTAMENTI('
               || :NEW.id_documento
               || '); '
               || 'end; ';
            integritypackage.set_postevent (a_istruzione, a_messaggio);
         END;
      END IF;

      IF ag_utilities.is_prot_interop (:NEW.id_documento) = 1
      THEN
         DECLARE
            d_id_memo             NUMBER;
            esiste_eccezione      NUMBER := 0;
            esistono_altri_prot   NUMBER := 0;
            elimina               NUMBER;
         BEGIN
            BEGIN
               SELECT id_documento_rif
                 INTO d_id_memo
                 FROM riferimenti
                WHERE     id_documento = :NEW.id_documento
                      AND tipo_relazione IN ('MAIL', 'FAX');

               SELECT COUNT (*)
                 INTO esistono_altri_prot
                 FROM riferimenti
                WHERE     tipo_relazione IN ('MAIL', 'FAX')
                      AND id_documento_rif = d_id_memo
                      AND id_documento != :NEW.id_documento;

               SELECT COUNT (*)
                 INTO esiste_eccezione
                 FROM riferimenti
                WHERE     tipo_relazione = 'PROT_ECC'
                      AND id_documento = d_id_memo;

               IF esistono_altri_prot != 0 OR esiste_eccezione != 0
               THEN
                  DELETE riferimenti
                   WHERE     id_documento = :NEW.id_documento
                         AND tipo_relazione IN ('MAIL', 'FAX')
                         AND id_documento_rif = d_id_memo;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         BEGIN
            DECLARE
               a_messaggio    VARCHAR2 (32000);
               a_istruzione   VARCHAR2 (32000);
            BEGIN
               a_messaggio :=
                     'Errore in scarto memo associato a documento '
                  || :NEW.id_documento
                  || '.';
               a_istruzione :=
                     'Begin '
                  || '  AG_MEMO_UTILITY.scarta_memo_from_prot('
                  || :NEW.id_documento
                  || '); '
                  || 'end; ';

               integritypackage.initNestLevel;
               integritypackage.NextNestLevel;
               integritypackage.set_postevent (a_istruzione, a_messaggio);
            END;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (-20999,
                                        'Fallita cancellazione:' || SQLERRM);
         END;
      END IF;

      IF ag_utilities.is_soggetto_protocollo (:NEW.id_tipodoc) = 1
      THEN
         BEGIN
            DECLARE
               a_messaggio    VARCHAR2 (32000);
               a_istruzione   VARCHAR2 (32000);
               a_idrif        VARCHAR2 (100);
            BEGIN
               a_messaggio :=
                     'Errore in aggiornamento attivita'' in scrivania '
                  || :NEW.id_documento
                  || '.';
               a_idrif := f_valore_campo (:NEW.id_documento, 'IDRIF');
               --raise_application_error(-20999, 'ci sono a_idrif '||a_idrif);
               a_istruzione :=
                     'Begin '
                  || '   AG_UTILITIES_CRUSCOTTO.UPD_DETT_TASK_EST('
                  || 'p_id_rapporto => '''
                  || :NEW.id_documento
                  || '''); '
                  || 'end; ';
               integritypackage.set_postevent (a_istruzione, a_messaggio);
            END;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (-20999,
                                        'Fallita cancellazione:' || SQLERRM);
         END;
      END IF;

      /***************************************************************************
         Se un doc da fascicolare viene cancellato (stato_documento = CA), i suoi
         eventuali smistamenti vengono eliminati e quindi tutte le attivita' sulla
         scrivania legate a tali smistamenti.
      ***************************************************************************/
      IF     ag_utilities.is_doc_da_fasc (:NEW.id_tipodoc) = 1
         AND agspr_agp_protocolli_pkg.is_protocollo_agspr (:NEW.id_documento) =
                0
      THEN
         BEGIN
            DECLARE
               a_messaggio    VARCHAR2 (32000);
               a_istruzione   VARCHAR2 (32000);
            BEGIN
               a_messaggio :=
                     'Errore in eliminazione smistamenti associati a memo '
                  || :NEW.id_documento
                  || '.';
               a_istruzione :=
                     'Begin AG_DOC_DA_FASC_UTILITY.ELIMINA_SMISTAMENTI('
                  || :NEW.id_documento
                  || '); end; ';
               integritypackage.set_postevent (a_istruzione, a_messaggio);
            END;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (-20999,
                                        'Fallita cancellazione:' || SQLERRM);
         END;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END;
/
